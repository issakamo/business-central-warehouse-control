namespace WarehouseControl.Warehouse;

page 50101 "WHX Inventory Exception Card"
{
    PageType = Card;
    ApplicationArea = All;
    Caption = 'Inventory Exception';
    SourceTable = "WHX Inventory Exception";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    Editable = false;
                    Caption = 'Entry No.';
                    Tooltip = 'Specifies the entry number of the inventory exception.';
                }
                field("Item No."; Rec."Item No.")
                {
                    Caption = 'Item No.';
                    Tooltip = 'Specifies the item number of the inventory exception.';
                }
                field(Description; Rec.Description)
                {
                    Caption = 'Description';
                    Tooltip = 'Specifies the description of the inventory exception.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    Caption = 'Location Code';
                    Tooltip = 'Specifies the location code of the inventory exception.';
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    Caption = 'Bin Code';
                    Tooltip = 'Specifies the bin code of the inventory exception.';
                }
                field("Exception Type"; Rec."Exception Type")
                {
                    Editable = false;
                    Caption = 'Exception Type';
                    Tooltip = 'Specifies the type of the inventory exception.';
                }
            }
            group(Discrepancy)
            {
                Caption = 'Discrepancy (as detected)';
                field("Expected Quantity"; Rec."Expected Quantity")
                {
                    Caption = 'Expected Quantity';
                    Tooltip = 'Specifies the expected quantity of the inventory exception.';
                    Editable = false;
                }
                field("Actual Quantity"; Rec."Actual Quantity")
                {
                    Caption = 'Actual Quantity';
                    Tooltip = 'Specifies the actual quantity of the inventory exception.';
                    Editable = false;
                }
                field(Difference; Rec.Difference)
                {
                    Caption = 'Difference';
                    Tooltip = 'Specifies the difference of the inventory exception.';
                    Editable = false;
                }
            }
            group(Resolution)
            {
                field(Priority; Rec.Priority)
                {
                    Caption = 'Priority';
                    Tooltip = 'Specifies the priority of the inventory exception.';
                }
                field(Status; Rec.Status)
                {
                    Editable = false;
                    Caption = 'Status';
                    Tooltip = 'Specifies the status of the inventory exception.';
                }
                field("Resolution Notes"; Rec."Resolution Notes")
                {
                    Caption = 'Resolution Notes';
                    Tooltip = 'Specifies the notes regarding the resolution of the inventory exception.';
                    trigger OnValidate()
                    begin
                        Rec.TestField("Resolution Notes")
                        // I will enforce fully in Phase 11 via the codeunit; this is a UI-level early signal only
                    end;
                }
                field("Resolved Date"; Rec."Resolved Date")
                {
                    Editable = false;
                    Caption = 'Resolved Date';
                    Tooltip = 'Specifies the date when the inventory exception was resolved.';
                }
            }
            group(Audit)
            {
                Caption = 'Audit';
                field("Created Date"; Rec."Created Date")
                {
                    Editable = false;
                    Caption = 'Created Date';
                    Tooltip = 'Specifies the date when the inventory exception was created.';
                }
                field("Created By"; Rec."Created By")
                {
                    Editable = false;
                    Caption = 'Created By';
                    Tooltip = 'Specifies the user who created the inventory exception.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Resolve)
            {
                ApplicationArea = All;
                Caption = 'Resolve';
                Image = Approve;
                ToolTip = 'Resolves the inventory exception.';

                trigger OnAction()
                var
                    ExceptionMgt: Codeunit "WHX Exception Management";
                begin
                    ExceptionMgt.ResolveException(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
    }
}