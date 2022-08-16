unit FMX.AutoSizer;

interface

uses
  System.Classes,
  System.Types,
  FMX.Types,
  FMX.Controls;

type
  TControlHelper = class helper for FMX.Controls.TControl
  public
    procedure DoAutoSize;
  end;

  TAutoSizedEvent = procedure(Sender: TObject; ABoundsRect: TRectF) of object;

  TFmxAutoSizer = class(TComponent)
  strict private
    FAutoSize: Boolean;
  private
    FControl: TControl;
    FOnAutoSized: TAutoSizedEvent;
    procedure SetAutoSize(const Value: Boolean);
    procedure SetControl(const Value: TControl);
  protected
    procedure DoAutoSized(ABoundsRect: TRectF); virtual;
  published
    property AutoSize: Boolean read FAutoSize write SetAutoSize;
    property Control: TControl read FControl write SetControl;
    property OnAutoSized: TAutoSizedEvent read FOnAutoSized write FOnAutoSized;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('RD', [TFmxAutoSizer]);
end;

procedure TFmxAutoSizer.DoAutoSized(ABoundsRect: TRectF);
begin
  if Assigned(FOnAutoSized) then
  begin
    FOnAutoSized(Self, ABoundsRect);
  end;
end;

procedure TFmxAutoSizer.SetAutoSize(const Value: Boolean);
begin
  if FControl = nil then
    Exit;
  if FAutoSize <> Value then
  begin
    FAutoSize := Value;
    if not FAutoSize then
      Exit;
    FControl.DoAutoSize;
    DoAutoSized(FControl.BoundsRect);
  end;
end;

procedure TFmxAutoSizer.SetControl(const Value: TControl);
begin
  FControl := Value;
end;

procedure TControlHelper.DoAutoSize;
var
  ChildIndex: Integer;
  LControl: TControl;
  TotalRect: TRectF;
  LLeft, LTop: Single;
  Nothing: Boolean;
begin
  LLeft := Width;
  LTop := Height;
  TotalRect := TRectF.Empty();

  Nothing := True; // any child (stored) included?!

  // 1. Calculate smallest offset
  for ChildIndex := 0 to Pred(ChildrenCount) do
  begin
    LControl := Children[ChildIndex] as TControl;
    if not Assigned(LControl) then
      Continue;

    if LControl.Stored then
    begin
      Nothing := False;
      if LControl.Position.X < LLeft then
        LLeft := LControl.Position.X;
      if LControl.Position.Y < LTop then
        LTop := LControl.Position.Y;
    end;
  end;

  if Nothing then
    Exit;

  // 2. Adjust Children-Controls (1st level only) by offset
  for ChildIndex := 0 to Pred(ChildrenCount) do
  begin
    LControl := Children[ChildIndex] as TControl;
    if not Assigned(LControl) then
      Continue;

    if LControl.Stored then
    begin
      LControl.Position.X := LControl.Position.X - LLeft;
      LControl.Position.Y := LControl.Position.Y - LTop;
    end;
  end;

  // 3. Calc rect
  for ChildIndex := 0 to Pred(ChildrenCount) do
  begin
    LControl := Children[ChildIndex] as TControl;
    if not Assigned(LControl) then
      Continue;

    if LControl.Stored then
    begin
      TotalRect.Union(LControl.BoundsRect);
    end;
  end;

  // 4. Move Control by offset
  Position.X := Position.X + LLeft;
  Position.Y := Position.Y + LTop;

  // 5. Calc new dimensions: X, Y
  Width := TotalRect.Width + Padding.Right;
  Height := TotalRect.Height + Padding.Bottom;
end;

end.
