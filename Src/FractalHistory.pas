unit FractalHistory;

interface
uses
  fractal,Contnrs,SysUtils,DisplayInf;

      //定义一个不使用引用计数的实现了IUnknown 接口的类
    type
      VObject = class(TObject, IUnknown)
      protected
         function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
         function _AddRef: Integer; stdcall;
         function _Release: Integer; stdcall;
      end;

type
  TFractalDataEx=class(TFractalData)
  private
    FCreatedTime : TDateTime;
  public
    constructor Create(fractalData:TFractalData);
    destructor Destroy; override;
    property CreatedTime : TDateTime read FCreatedTime;
    function getCaption():string;
  end;

type
  IFractalHistoryListener = interface
    function LockHistoryViewPixels(picWidth, picHeight: integer): TPixels24;
    procedure refreshHistoryView();
    function  getHistoryViewBestWidth():integer;
  end;

type
  TFractalHistory = class(VObject,IFractalDocListener)
  private
    FFractalHistoryListener:IFractalHistoryListener;
    FFractalDoc : TFractalDoc;
    FDataList : TObjectList;
    FIsSaveHistory: boolean;
    function getFractalDataByIndex(index: integer): TFractalDataEx;
    procedure SetIsSaveHistory(const Value: boolean);
  private
  //IFractalDocListener=interface
    procedure outInfo(const text:string);
    procedure doFractalCompileOk();
    procedure doFractalRunProgress(const progress:double);
    function LockViewPixels(picWidth, picHeight: integer): TPixels24;
    procedure doFractalRunOk();
  public
    constructor Create(fractalHistoryListener:IFractalHistoryListener);
    destructor Destroy; override;

    function addAData(fractalData:TFractalData):boolean;
    function  getDataCount():integer;
    property  fractalList[index:integer]:TFractalDataEx read getFractalDataByIndex;
    procedure Clear();

    procedure UpdateHistoryView(DataIndex:integer);
    procedure Stop();
    property IsSaveHistory : boolean read FIsSaveHistory write SetIsSaveHistory;
  end;

implementation
     
{ VObject }

function VObject._AddRef: Integer;
begin
  result := -1;
end;

function VObject._Release: Integer;
begin
  result := -1;
end;

function VObject.QueryInterface(const IID: TGUID; out Obj): HResult;
const
  E_NOINTERFACE = HResult($80004002);
begin
  if GetInterface(IID, Obj) then Result := 0 else Result := E_NOINTERFACE;
end;

{ TFractalDataEx }

constructor TFractalDataEx.Create(fractalData: TFractalData);
begin
  inherited Create();
  FCreatedTime:=now;
  copyFrom(fractalData);
end;

destructor TFractalDataEx.Destroy;
begin
  inherited;
end;

function TFractalDataEx.getCaption: string;
begin
  result:='['+FormatDateTime('hh:nn:ss',self.FCreatedTime)+'] '+self.fractalName;
end;

{ TFractalHistory }

function TFractalHistory.addAData(fractalData: TFractalData):boolean;
begin
  result:=false;
  if not FIsSaveHistory then exit;
  if (self.getDataCount()>0) and (self.fractalList[getDataCount-1].IsEqual(fractalData)) then exit;
  self.FDataList.Add(TFractalDataEx.Create(fractalData)) ;
  result:=true;
end;

procedure TFractalHistory.Clear;
begin
  FDataList.Clear();
end;

constructor TFractalHistory.Create(fractalHistoryListener:IFractalHistoryListener);
begin
  inherited create();
  FIsSaveHistory:=true;
  FDataList:=TObjectList.Create;
  FFractalDoc :=TFractalDoc.Create(self);
  FFractalHistoryListener:=fractalHistoryListener;
end;

destructor TFractalHistory.Destroy;
begin
  FFractalDoc.Free;
  self.Clear();
  FDataList.Free;
  inherited;
end;

function TFractalHistory.getDataCount: integer;
begin
  result:=self.FDataList.Count;
end;

function TFractalHistory.getFractalDataByIndex(
  index: integer): TFractalDataEx;
begin
  result:=TFractalDataEx(self.FDataList.Items[index]);
end;

procedure TFractalHistory.doFractalCompileOk;
begin
  //nothing
end;

procedure TFractalHistory.doFractalRunOk;
begin
  //refresh view
  self.FFractalHistoryListener.refreshHistoryView();
end;

procedure TFractalHistory.doFractalRunProgress(const progress: double);
begin
  //nothing
end;

function TFractalHistory.LockViewPixels(picWidth,
  picHeight: integer): TPixels24;
begin
  result:=self.FFractalHistoryListener.LockHistoryViewPixels(picWidth,picHeight);
end;

procedure TFractalHistory.outInfo(const text: string);
begin
  //nothing
end;

procedure TFractalHistory.UpdateHistoryView(DataIndex: integer);
const
  maxBestHeight = 100;
var
  bestWidth,bestHeight : integer;
begin
  if (DataIndex<0)or (DataIndex>=self.getDataCount) then exit;

  self.FFractalDoc.fractalData.copyFrom(self.getFractalDataByIndex(DataIndex));
  bestWidth:=self.FFractalHistoryListener.getHistoryViewBestWidth();
  if (FFractalDoc.PicWidth>0) then
  begin
    bestHeight:=(FFractalDoc.PicHeight*bestWidth+(FFractalDoc.PicWidth div 2))  div FFractalDoc.PicWidth;
    if (bestHeight>maxBestHeight) then
    begin
      bestHeight:=maxBestHeight;
      bestWidth:=(FFractalDoc.PicWidth*bestHeight+(FFractalDoc.PicHeight div 2))  div FFractalDoc.PicHeight;
    end;
  end
  else
    bestHeight:=0;
  self.FFractalDoc.RunGetPic(bestWidth,bestHeight,FFractalDoc.fractalData.coloring);
end;


procedure TFractalHistory.Stop;
begin
  self.FFractalDoc.Stop();
end;

procedure TFractalHistory.SetIsSaveHistory(const Value: boolean);
begin
  FIsSaveHistory := Value;
end;

end.
