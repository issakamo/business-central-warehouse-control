namespace WarehouseControl.Warehouse;

using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Posting;
using Microsoft.Inventory.Tracking;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Posting;
using Microsoft.Warehouse.Document;

codeunit 50101 "WHX Event Subscribers"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnBeforePostItemJnlLine', '', false, false)]
    local procedure OnBeforePostItemJnlLine_DetectStockDiscrepancy(var ItemJournalLine: Record "Item Journal Line"; CalledFromAdjustment: Boolean; CalledFromInvtPutawayPick: Boolean; var ItemRegister: Record "Item Register"; var ItemLedgEntryNo: Integer; var ValueEntryNo: Integer; var ItemApplnEntryNo: Integer)
    var
        ExceptionMgt: Codeunit "WHX Exception Management";
    begin
        if CalledFromAdjustment then
            exit;

        if ItemJournalLine."Qty. (Phys. Inventory)" = ItemJournalLine."Qty. (Calculated)" then
            exit;

        ExceptionMgt.CreateStockException(
            ItemJournalLine."Item No.",
            ItemJournalLine."Location Code",
            ItemJournalLine."Bin Code",
            ItemJournalLine."Qty. (Calculated)",
            ItemJournalLine."Qty. (Phys. Inventory)");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterPurchRcptLineInsert', '', false, false)]
    local procedure OnAfterPurchRcptLineInsert_DetectReceivingDiscrepancy(PurchaseLine: Record "Purchase Line"; var PurchRcptLine: Record "Purch. Rcpt. Line"; ItemLedgShptEntryNo: Integer; WhseShip: Boolean; WhseReceive: Boolean; CommitIsSupressed: Boolean; PurchInvHeader: Record "Purch. Inv. Header"; var TempTrackingSpecification: Record "Tracking Specification" temporary; PurchRcptHeader: Record "Purch. Rcpt. Header"; TempWhseRcptHeader: Record "Warehouse Receipt Header"; xPurchLine: Record "Purchase Line"; var TempPurchLineGlobal: Record "Purchase Line" temporary)
    var
        ExceptionMgt: Codeunit "WHX Exception Management";
    begin
        if PurchaseLine.Quantity = PurchRcptLine.Quantity then
            exit;

        ExceptionMgt.CreateReceivingException(
    PurchRcptLine."No.",
    PurchRcptLine."Location Code",
    PurchRcptLine."Bin Code",
    PurchaseLine.Quantity,
    PurchRcptLine.Quantity);
    end;
}