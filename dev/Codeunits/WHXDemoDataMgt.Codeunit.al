namespace WarehouseControl.Warehouse;

codeunit 50102 "WHX Demo Data Mgt"
{
    procedure GenerateSampleExceptions()
    var
        ExceptionMgt: Codeunit "WHX Exception Management";
    begin
        // Stock discrepancies — varied variance % to hit different priority tiers
        ExceptionMgt.CreateStockException('1896-S', 'WHITE', 'W-08-0001', 100, 94);   // ~6% -> Medium
        ExceptionMgt.CreateStockException('1896-S', 'WHITE', 'W-08-0002', 50, 20);    // 60% -> Critical
        ExceptionMgt.CreateStockException('1900-S', 'WHITE', 'W-08-0003', 200, 175);  // ~12.5% -> High
        ExceptionMgt.CreateStockException('1900-S', 'WHITE', 'W-08-0003', 30, 29);    // ~3.3% -> Low
        ExceptionMgt.CreateStockException('1906-S', 'YELLOW', 'Y-08-0001', 0, 15);      // zero-expected -> High

        // Receiving discrepancies
        ExceptionMgt.CreateReceivingException('1908-S', 'WHITE', '', 500, 450);      // 10% -> High
        ExceptionMgt.CreateReceivingException('1908-S', 'WHITE', '', 100, 98);       // 2% -> Low
        ExceptionMgt.CreateReceivingException('1920-S', 'YELLOW', '', 80, 40);         // 50% -> Critical
        ExceptionMgt.CreateReceivingException('1896-S', 'WHITE', '', 60, 55);        // ~8.3% -> Medium
    end;

    procedure ClearSampleExceptions()
    var
        InventoryException: Record "WHX Inventory Exception";
    begin
        InventoryException.DeleteAll(false);
    end;
}
