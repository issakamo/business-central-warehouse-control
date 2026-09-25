# Business Central Warehouse Control

Inventory exception detection and management for Dynamics 365 Business Central.

## Business Problem

Warehouse teams using Business Central often can't easily see stock
discrepancies, receiving variances, or low-stock conditions until they've
already caused downstream problems. A purchase order posted against
wrong stock, a customer order that can't be fulfilled. Business Central
has no built-in mechanism to flag these issues as they happen.

## Solution

This extension detects inventory discrepancies automatically as they
occur during real posting processes; physical inventory counts and
purchase receipts, and surfaces them through a dedicated exception
workflow rather than requiring manual reconciliation.

- **Automatic detection** via event subscribers on standard posting
  codeunits (no modification to base application objects)
- **Priority-based triage**, calculated from variance percentage, not
  a fixed threshold
- **Dashboard visibility** through a Role Center cue and Item
  Card/List integration
- **Audit-ready reporting**, including a management summary rollup
- **Automated test coverage** for detection logic, resolution rules,
  and report aggregation

## Architecture

See [docs/architecture.md](docs/architecture.md) for design decisions
and the reasoning behind them (event selection, data classification,
FlowField usage, AppSourceCop suppressions).

## Technologies

- Microsoft Dynamics 365 Business Central (AL)
- Visual Studio Code + AL Language extension
- Docker (local development container)
- Word-based report layouts

## Project Structure

src/ Extension objects (tables, pages, codeunits, reports, permissions)
test/ Automated test codeunits
dev/ Local development tooling: sample data generation (not for release)
docs/ Architecture and design documentation

## Key Features

| Feature | Objects |
|---|---|
| Exception detection | `WHX Inventory Exception`, `WHX Exception Management`, `WHX Event Subscribers` |
| Dashboard | `WHX Exception Cue`, Role Center extension |
| Standard page integration | Item Card / Item List extensions |
| Reporting | `WHX Inventory Exception Report`, `WHX Exception Summary Report`, `WHX Exception Reporting Mgt` |
| Security | `WHX Exception User`, `WHX Exception Manager` permission sets |

## Testing

Run via VS Code CodeLens or the AL Test Tool in your Business Central
container. Covers detection logic (including the zero-expected-quantity
edge case), resolution validation, and report aggregation correctness.

## Development Setup

Requires a local Business Central Docker container. See
[docs/installation.md](docs/installation.md).

## Status

Actively in development — Project 1 of a 3-project portfolio, alongside
[business-central-purchase-control](https://github.com/issakamo/business-central-purchase-control).
Project 3 (Integration Hub) has not yet been started.