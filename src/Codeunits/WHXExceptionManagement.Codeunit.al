namespace WarehouseControl.Warehouse;

codeunit 50100 "WHX Exception Management"
{
    procedure ResolveException(var Exception: Record "WHX Inventory Exception")
    begin
        Exception.TestField("Resolution Notes");
        Exception.Validate(Status, Exception.Status::Resolved);
        Exception.Modify(true);
    end;

    procedure CreateStockException(ItemNo: Code[20]; LocationCode: Code[10]; BinCode: Code[20]; ExpectedQty: Decimal; ActualQty: Decimal): Integer
    var
        Exception: Record "WHX Inventory Exception";
    begin
        if ExpectedQty = ActualQty then
            exit(0);

        Exception.Init();
        Exception."Item No." := ItemNo;
        Exception."Location Code" := LocationCode;
        Exception."Bin Code" := BinCode;
        Exception."Expected Quantity" := ExpectedQty;
        Exception."Actual Quantity" := ActualQty;
        Exception."Exception Type" := Exception."Exception Type"::"Stock Discrepancy";
        Exception.Priority := DeterminePriority(ExpectedQty, ActualQty);
        Exception.Status := Exception.Status::Open;
        Exception.Insert(true);

        exit(Exception."Entry No.");
    end;

    procedure CreateReceivingException(ItemNo: Code[20]; LocationCode: Code[10]; BinCode: Code[20]; OrderedQty: Decimal; ReceivedQty: Decimal): Integer
    var
        Exception: Record "WHX Inventory Exception";
    begin
        if OrderedQty = ReceivedQty then
            exit(0);

        Exception.Init();
        Exception."Item No." := ItemNo;
        Exception."Location Code" := LocationCode;
        Exception."Bin Code" := BinCode;
        Exception."Expected Quantity" := OrderedQty;
        Exception."Actual Quantity" := ReceivedQty;
        Exception."Exception Type" := Exception."Exception Type"::"Receiving Discrepancy";
        Exception.Priority := DeterminePriority(OrderedQty, ReceivedQty);
        Exception.Status := Exception.Status::Open;
        Exception.Insert(true);

        exit(Exception."Entry No.");
    end;

    local procedure DeterminePriority(Expected: Decimal; Actual: Decimal): Enum "WHX Exception Priority"
    var
        VariancePct: Decimal;
    begin
        if Expected = 0 then
            exit("WHX Exception Priority"::High);
        // Deliberately High, not Critical — treated as a setup/data anomaly rather than
        // a large-scale variance. Candidate for promotion to a setup-table field once
        // WHX Warehouse Control Setup exists

        VariancePct := Abs(Expected - Actual) / Abs(Expected) * 100;

        case true of
            VariancePct >= 50:
                exit("WHX Exception Priority"::Critical);
            VariancePct >= 20:
                exit("WHX Exception Priority"::High);
            VariancePct >= 5:
                exit("WHX Exception Priority"::Medium);
            else
                exit("WHX Exception Priority"::Low);
        end;
    end;
}