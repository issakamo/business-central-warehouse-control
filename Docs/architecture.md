# Architecture & Design Decisions

This document explains *why* the extension is built the way it is, 
not what the code does (that's in the code itself), but the reasoning
behind decisions that aren't obvious from reading a single file in
isolation.

## Data Model

### Frozen snapshot vs. live lookup

`WHX Inventory Exception` stores `Expected Quantity`, `Actual
Quantity`, and `Difference` as plain fields, populated once at
creation, not as FlowFields recalculated from source data.

An exception record represents a discrepancy *as detected at a point
in time*. If these were FlowFields pointing at live inventory data, a
resolved exception from weeks ago would silently display today's
stock levels instead of the actual variance that was investigated,
correct-looking data that's actually wrong. `Description` on the same
table *is* a FlowField deliberately; it's current item context, not
part of the frozen record, and the two are visually separated (an
"as detected" group caption on the Card) so the distinction is
obvious to a user, not just to the developer who wrote it.

The dashboard cue (`WHX Exception Cue`) and the Item Card/List open-
count fields are the inverse case: FlowFields are correct there,
because a manager needs the current count, not a historical one.
Same underlying principle, opposite answer, depending on whether the
field represents a moment or a measurement of "right now."

### Data classification

Fields are explicitly split between `SystemMetadata` (audit fields;
created/resolved dates, created-by) and `CustomerContent` (actual
business data), rather than left at a uniform default. This reflects
Microsoft's data classification model, used by compliance tooling to
distinguish personal/operational data, not a cosmetic label.

## Event-Driven Detection

Detection is implemented entirely through event subscribers
(`WHX Event Subscribers`), never by modifying base application
objects. The standard "extend, don't modify" model required for
cloud/AppSource-target extensions.

- **`Item Jnl.-Post Line`, `OnBeforePostItemJnlLine`** : subscribed
  *before* posting because `"Qty. (Phys. Inventory)"` and `"Qty.
  (Calculated)"` only coexist on the line pre-post; after posting,
  that comparison is gone. Guards against `CalledFromAdjustment`,
  since system-generated adjustment postings aren't user-detected
  discrepancies and would otherwise double-count corrections as new
  problems.
- **`Purch.-Post`, `OnAfterPurchRcptLineInsert`** : subscribed *after*
  insert because the actual received quantity only exists once the
  receipt line has been written; the ordered quantity (`Purchase
  Line`) persists independently either way, so there's no race to
  catch it before it disappears.

Both event signatures were verified against the local container's
actual symbols rather than trusted from documentation. The published
Microsoft reference pages did not match this project's runtime
version for `Purch.-Post` specifically (parameter order and count
differed materially from what's documented). This is treated as a
standing practice for this codebase: symbols are ground truth, docs
are a starting point for discovery only.

## Business Logic Boundaries

`WHX Exception Management` contains detection and resolution logic;
`WHX Exception Reporting Mgt` contains report aggregation. These were
originally combined with the report objects themselves during initial
development, then extracted once it became clear that:

1. Report-internal `local procedure`s can't be unit tested directly.
2. Aggregation logic (counting exceptions by priority/item) isn't
   inherently a reporting concern. It's business logic that reports
   happen to consume, and could equally serve a future API or
   dashboard.

Priority is calculated from **variance percentage**, not a fixed
quantity threshold, since a fixed threshold treats a 5-unit variance
on a 6-unit-expected item identically to a 5-unit variance on a
6,000-unit item. The one hardcoded exception is the zero-expected-
quantity case (defaults to High rather than computing a percentage,
which would divide by zero), ocumented inline as a candidate for
promotion to a configurable setup value once a setup table exists for
other reasons; not worth introducing a setup table for one constant.

## Buffer Tables

`WHX Priority Count Buffer` and `WHX Item Count Buffer` support report
aggregation and are declared `TableType = Temporary` at the object
level (not just via a `temporary` variable modifier at each call
site). This guarantees the tables can never persist to SQL regardless
of how any future code references them, a stronger guarantee than
relying on every call site remembering a keyword, which is exactly
the failure mode encountered during development (a missing `temporary`
declaration caused aggregated counts to persist and compound across
report runs before this was caught).

## AppSourceCop Suppressions

Two rules are suppressed in `ruleset.json`, both with inline
justification, rather than disabling AppSourceCop wholesale:

- **AS0084** (ID range validation): requires a Microsoft Partner
  Center-issued range, not obtainable outside real ISV registration.
- **AS0092** (Application Insights connection string) requires a
  live Azure resource not available in local Docker development;
  telemetry is intentionally out of scope for this portfolio stage.

Every other AppSourceCop, CodeCop, and UICop
rule remains active and enforced.

## Permissions

Two permission sets: `WHX Exception User` (read/insert/modify) and
`WHX Exception Manager` (adds delete, includes User via
`IncludedPermissionSets` rather than duplicating grants). Resolution
enforcement (requiring notes before marking an exception resolved)
lives in `WHX Exception Management`, not in page-level validation
so it holds regardless of entry point (UI, future API, or direct
codeunit call).

## Testing Approach

Test codeunits create their own data per test rather than relying on
seeded/dev sample data, relying on BC's per-test transaction rollback
for isolation. Coverage focuses on business-rule correctness (variance
tiers, the zero-expected edge case, resolution validation) and report
aggregation (grouping counts, exclusion of resolved records, sort
order), not UI rendering, which isn't practically unit-testable in
AL.

## Development-Only Tooling

`dev/` contains a sample data generator and reset action
(`WHX Demo Data Mgt`), kept separate from `src/` and clearly labeled
as non-shipping. These exist to exercise detection logic through the
same codeunit paths real posting uses (`CreateStockException`/
`CreateReceivingException`), rather than hand-inserting records that
would bypass business rules entirely.

An earlier version gated this codeunit behind `#if DEBUG`/`#endif`,
intending it to be excluded from a release build automatically. This
doesn't work in AL: unlike C#, `DEBUG` is not a compiler-defined
symbol — without an explicit `#define`, the condition evaluates false
unconditionally, and the guarded code silently never compiles at all,
which is why the dev action initially failed to appear in Business
Central with no error. The directives were removed; the `dev/` vs.
`src/` folder separation is the actual (manual) safeguard — before
producing a real release build, `dev/` is excluded by hand. There is
no automated release-packaging step in this project that would make a
`#define`-based exclusion meaningfully more effective than manual
folder exclusion already is.