unit UnitFrmMain;
////////////////////////////////////////////////////////////////////////////////
//主窗口单元文件
//  主要处理<分形风暴2>菜单、状态栏等界面
//  2008.06.14 write by 侯思松, E-Mail: HouSisong@Gmail.com
////////////////////////////////////////////////////////////////////////////////
interface

//todo:支持文件中增加参数的下拉选择

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ActnList, XPStyleActnCtrls, ActnMan, ExtDlgs, Menus,
  UnitfrmFlash, ExtCtrls, StdCtrls, ComCtrls,
  Compile_Hss,Fractal,DisplayInf,MMSystem,FractalHistory;

const
  MSG_User=WM_USER+21000;
  MSG_RefreshPicMessage=MSG_User+0;
  MSG_DrawPicFinishMessage=MSG_User+1;
  MSG_RefreshHistoryViewMessage= MSG_User +2;

type
  TfrmMain = class(TForm,IFractalDocListener,IFractalHistoryListener)
    SavePictureDialog: TSaveDialog;
    MainfrmMenu: TMainMenu;
    M_File: TMenuItem;
    M_SavePictureAs: TMenuItem;
    M_Line2: TMenuItem;
    M_Exit1: TMenuItem;
    M_Help: TMenuItem;
    About1: TMenuItem;
    M_SaveFractalAs: TMenuItem;
    Panel1: TPanel;
    Splitter1: TSplitter;
    M_Space34789579: TMenuItem;
    M_OpenFractal: TMenuItem;
    Splitter2: TSplitter;
    OpenFractalDialog: TOpenDialog;
    SaveFractalDialog: TSaveDialog;
    GroupBoxColorChange: TGroupBox;
    Panel4: TPanel;
    ScrollBox: TScrollBox;
    PaintBox: TPaintBox;
    ShapeSelectRect: TShape;
    ProgressBar: TProgressBar;
    GroupBox5: TGroupBox;
    Label23: TLabel;
    Label22: TLabel;
    Label21: TLabel;
    editRun_RandColorK0: TEdit;
    editRun_RandColorK1: TEdit;
    editRun_RandColorK2: TEdit;
    GroupBox7: TGroupBox;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    btnSetRandColoring: TButton;
    TrackBarColor0: TTrackBar;
    TrackBarColor1: TTrackBar;
    TrackBarColor2: TTrackBar;
    editRun_RandColor2: TEdit;
    editRun_RandColor1: TEdit;
    editRun_RandColor0: TEdit;
    Panel6: TPanel;
    btnStop: TButton;
    editColoringWidth: TEdit;
    editColoringHeight: TEdit;
    Label19: TLabel;
    Label20: TLabel;
    btnRunAsColoring: TButton;
    btnRunAsPic: TButton;
    Label10: TLabel;
    editPicWidth: TEdit;
    Label11: TLabel;
    editPicHeight: TEdit;
    Panel7: TPanel;
    MemoOutInfo: TMemo;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    ScrollBoxK: TScrollBox;
    Panel2: TPanel;
    Label3: TLabel;
    Label4: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label15: TLabel;
    memoStopFunction: TMemo;
    editMaxi: TEdit;
    GroupBox1: TGroupBox;
    Label5: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    editX0: TEdit;
    editY0: TEdit;
    editR: TEdit;
    editSeta: TEdit;
    GroupBox2: TGroupBox;
    lbColor0: TLabel;
    lbColor1: TLabel;
    lbColor2: TLabel;
    memoColorFunction0: TMemo;
    Panel3: TPanel;
    rbtnRGB: TRadioButton;
    rbtnHLS: TRadioButton;
    rbtnYUV: TRadioButton;
    memoColorFunction1: TMemo;
    memoColorFunction2: TMemo;
    editFractalName: TEdit;
    memoLoopXFanction: TMemo;
    memoLoopYFanction: TMemo;
    TabSheet2: TTabSheet;
    Panel5: TPanel;
    ImageHistoryWiew: TImage;
    GroupBox3: TGroupBox;
    listBoxHistory: TListBox;
    btnColoringUpdate: TButton;
    btnRun_RandColorK_Up: TButton;
    btnRun_RandColorK_Down: TButton;
    procedure M_SavePictureAsExecute(Sender: TObject);
    procedure M_SaveFractalAsExecute(Sender: TObject);
    procedure M_ExitExecute(Sender: TObject);
    procedure M_AboutExecute(Sender: TObject);
    procedure M_OpenFractalClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure editRun_RandColorChange(Sender: TObject);
    procedure TrackBarColorChange(Sender: TObject);
    procedure editRun_RandColorKeyPress(Sender: TObject; var Key: Char);
    procedure btnRunAsColoringClick(Sender: TObject);
    procedure btnRunAsPicClick(Sender: TObject);
    procedure PaintBoxPaint(Sender: TObject);
    procedure ShapeSelectRectMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnZoomOutClick(isZoomIn:boolean);
    procedure doRefreshPicMessage(var Message: TMessage); message MSG_RefreshPicMessage;
    procedure postRefreshPicMessage();
    procedure doDrawPicFinishMessage(var Message: TMessage); message MSG_DrawPicFinishMessage;
    procedure postDrawPicFinishMessage();
    procedure ScrollBoxResize(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure btnColoringUpdateClick(Sender: TObject);
    procedure rbtnColorTypeClick(Sender: TObject);
    procedure listBoxHistoryClick(Sender: TObject);
    procedure listBoxHistoryDblClick(Sender: TObject);
    procedure btnSetRandColoringClick(Sender: TObject);
    procedure btnRun_RandColorK_UpClick(Sender: TObject);
    procedure btnRun_RandColorK_DownClick(Sender: TObject);
  private
    procedure ShowFlash();
    function getColoringSet: TFractalColoring;
    function getRandColoringSet: TFractalColoring;
    procedure openFractalFile(const fractalFileName: string);
  private
    FBitmapView : TBitmap;
    FFractalDoc : TFractalDoc;
    FFractalHistory : TFractalHistory;
    procedure fractalDataToView();  overload;
    procedure fractalDataToView(const FractalData:TFractalData);overload;  
    procedure ViewTofractalData();  overload;
    procedure ViewTofractalData(FractalData:TFractalData);overload;
    procedure RunGetColoring();
    procedure RunDoColoring();
    procedure RunGetPic();
  private
    FIsRunAsColoring :boolean;
    FSelectRectIng :boolean;
    FSelectRectX0,FSelectRectY0 : integer;
    FProgressBar_Position : double;
    FRefreshPicOldTime : integer;
    FHistory_FractalFileName :string;
  private
  //IFractalDocListener=interface
    procedure outInfo(const text:string);
    procedure doFractalCompileOk();
    procedure doFractalRunProgress(const progress:double);
    function LockViewPixels(picWidth, picHeight: integer): TPixels24;
    procedure doFractalRunOk();
  //IFractalHistoryListener = interface
    function LockHistoryViewPixels(picWidth, picHeight: integer): TPixels24;
    procedure refreshHistoryView();
    procedure doRefreshHistoryViewMessage(var Message: TMessage); message MSG_RefreshHistoryViewMessage;
    function  getHistoryViewBestWidth():integer;
    procedure saveFractalDataToHistory();
  public
    procedure Initialize(); //程序初始化
  end;

var
  frmMain: TfrmMain;

implementation
uses
  math;

{$R *.dfm}

procedure TfrmMain.M_ExitExecute(Sender: TObject);
begin
  //退出程序
  self.Close;
end;

procedure TfrmMain.ShowFlash;
var
  frmFlash      : TfrmFlash;  
begin
  //显示Flash窗口
  frmFlash:=nil;
  Application.CreateForm(TfrmFlash,frmFlash);
  try
    frmFlash.ShowAsFlash();
  finally
  end;
end;

procedure TfrmMain.Initialize;
begin
  //程序初始化
  self.ShowFlash();
  //加载插件等
end;

procedure TfrmMain.M_AboutExecute(Sender: TObject);
var
  frmFlash      : TfrmFlash;
begin
  //显示"关于"窗口
  frmFlash:=nil;
  Application.CreateForm(TfrmFlash,frmFlash);
  try
    frmFlash.ShowAsAbout();
  finally
  end;
end;

procedure TfrmMain.openFractalFile(const fractalFileName : string);
begin
  self.FFractalDoc.fractalData.LoadFromfile(fractalFileName);
  fractalDataToView();
  FHistory_FractalFileName:=fractalFileName;
  btnRunAsColoringClick(nil);
  FHistory_FractalFileName:='';
end;

procedure TfrmMain.M_OpenFractalClick(Sender: TObject);
begin
  //打开fractal文件
  if (not self.OpenFractalDialog.Execute) then exit;
  openFractalFile(self.OpenFractalDialog.FileName);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  mParamCount : integer;
  frcFileName : string;
begin
  self.ScrollBox.DoubleBuffered:=true;
  self.DoubleBuffered:=true;
  FSelectRectIng:=false;
  FBitmapView :=TBitmap.Create;
  FBitmapView.Canvas.Brush.Color:=clBlack;
  FBitmapView.PixelFormat:=pf24bit;
  FBitmapView.Width:=strToInt(self.editColoringWidth.Text);
  FBitmapView.Height:=strToInt(self.editColoringHeight.Text);
  //test : FBitmapView.LoadFromFile('C:\Documents and Settings\Administrator\桌面\pic\17.33.bmp');
  self.PaintBox.Left:=0;
  self.PaintBox.Top:=0;
  self.PaintBox.Width:=self.FBitmapView.Width;
  self.PaintBox.Height:=self.FBitmapView.Height;
  //PaintBoxPaint(Sender);
  FFractalDoc:=TFractalDoc.Create(self);
  FFractalHistory :=TFractalHistory.Create(self);

  ScrollBoxResize(self);
  //启动参数
  mParamCount:=ParamCount();
  if (mParamCount=1) then
  begin
    frcFileName:=Trim(paramstr(1));
    if FileExists(frcFileName) then
      openFractalFile(frcFileName);
  end;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FFractalHistory);
  FreeAndNil(FFractalDoc);
  FreeAndNil(FBitmapView);
end;


procedure TfrmMain.M_SavePictureAsExecute(Sender: TObject);
var
  bmpFileName : string;
begin
  if (self.FBitmapView.Empty) then exit;
  
  //保存bmp文件
  if (not self.SavePictureDialog.Execute) then exit;

  bmpFileName:=self.SavePictureDialog.FileName;
  if (pos('.',bmpFileName)<=0) then bmpFileName:=bmpFileName+'.bmp';
  self.FBitmapView.SaveToFile(bmpFileName);
end;

procedure TfrmMain.M_SaveFractalAsExecute(Sender: TObject);
var
  fractalFileName : string;
begin
  //保存fractal文件
  if (not self.SaveFractalDialog.Execute) then exit;

  fractalFileName:=self.SaveFractalDialog.FileName;
  if (pos('.',fractalFileName)<=0) then fractalFileName:=fractalFileName+'.frc';
  self.FFractalDoc.fractalData.SaveToFile(fractalFileName);
end;

procedure TfrmMain.fractalDataToView;
begin
  fractalDataToView(self.FFractalDoc.fractalData);
end;


procedure TfrmMain.fractalDataToView(const FractalData: TFractalData);
begin
  //显示参数
  self.editFractalName.Text:=FractalData.fractalName;
  self.memoLoopXFanction.Text:=FractalData.loopXFunction;
  self.memoLoopYFanction.Text:=FractalData.loopYFunction;
  self.editmaxi.Text:=intToStr(FractalData.maxi);
  self.memoStopFunction.Text:=FractalData.stopFunction;
  self.editX0.Text:=exFloatToStr(FractalData.x0);
  self.editY0.Text:=exFloatToStr(FractalData.y0);
  self.editR.Text:=exFloatToStr(FractalData.r);
  self.editSeta.Text:=exFloatToStr(FractalData.seta);
  self.editPicWidth.Text:=intToStr(FractalData.picWidth);
  self.editPicHeight.Text:=intToStr(FractalData.picHeight);
  self.memoColorFunction0.Text:=FractalData.colorFunction0;
  self.memoColorFunction1.Text:=FractalData.colorFunction1;
  self.memoColorFunction2.Text:=FractalData.colorFunction2;
  case FractalData.coloring.randColorType of
    ctHLS: self.rbtnHLS.Checked:=true;
    ctYUV: self.rbtnYUV.Checked:=true;
    else self.rbtnRGB.Checked:=true;
  end;
  self.editRun_RandColorK0.Text:=exFloatToStr(FractalData.coloring.randColorK0);
  self.editRun_RandColorK1.Text:=exFloatToStr(FractalData.coloring.randColorK1);
  self.editRun_RandColorK2.Text:=exFloatToStr(FractalData.coloring.randColorK2);
  self.editRun_RandColor0.Text:=exFloatToStr(FractalData.coloring.randColor0);
  self.editRun_RandColor1.Text:=exFloatToStr(FractalData.coloring.randColor1);
  self.editRun_RandColor2.Text:=exFloatToStr(FractalData.coloring.randColor2);
end;

procedure TfrmMain.ViewTofractalData;
begin
  ViewTofractalData(self.FFractalDoc.fractalData);
end;

procedure TfrmMain.ViewTofractalData(FractalData: TFractalData);
  function tryStrToFloat(const str:string):extended;
  begin
    if (trim(str)='') then
      result:=0
    else
      result:=strToFloat(str);
  end;
begin
  //显示参数
  FractalData.fractalName:=self.editFractalName.Text;
  FractalData.loopXFunction:=self.memoLoopXFanction.Text;
  FractalData.loopYFunction:=self.memoLoopYFanction.Text;
  FractalData.maxi:=strToInt(self.editmaxi.Text);
  FractalData.stopFunction:=self.memoStopFunction.Text;
  FractalData.x0:=tryStrToFloat(self.editX0.Text);
  FractalData.y0:=tryStrToFloat(self.editY0.Text);
  FractalData.r:=tryStrToFloat(self.editR.Text);
  FractalData.seta:=tryStrToFloat(self.editSeta.Text);
  FractalData.picWidth:=strToInt(self.editPicWidth.Text);
  FractalData.picHeight:=strToInt(self.editPicHeight.Text);
  FractalData.colorFunction0:=self.memoColorFunction0.Text;
  FractalData.colorFunction1:=self.memoColorFunction1.Text;
  FractalData.colorFunction2:=self.memoColorFunction2.Text;
  if (self.rbtnYUV.Checked) then
    FractalData.coloring.randColorType:=ctYUV
  else if (self.rbtnHLS.Checked) then
    FractalData.coloring.randColorType:=ctHLS
  else
    FractalData.coloring.randColorType:=ctRGB;
  FractalData.coloring.randColorK0:=tryStrToFloat(self.editRun_RandColorK0.Text);
  FractalData.coloring.randColorK1:=tryStrToFloat(self.editRun_RandColorK1.Text);
  FractalData.coloring.randColorK2:=tryStrToFloat(self.editRun_RandColorK2.Text);
  FractalData.coloring.randColor0 :=tryStrToFloat(self.editRun_RandColor0.Text );
  FractalData.coloring.randColor1 :=tryStrToFloat(self.editRun_RandColor1.Text );
  FractalData.coloring.randColor2 :=tryStrToFloat(self.editRun_RandColor2.Text );
end;

  function strToTrackBarColor(TrackBarColor:TTrackBar;editRun_RandColor:TEdit):integer;
  var
    x :extended;
    //pos:integer;
  begin
    if (editRun_RandColor.Text='') then
      x:=0
    else
      x:=strToFloat(editRun_RandColor.Text);
    if (x<0) then
    begin
      x:=0;
      editRun_RandColor.Text:='0';
    end
    else if (x>2) then
    begin
      x:=2;
      editRun_RandColor.Text:='2';
    end;
    result:=round(x*0.5*(TrackBarColor.Max-TrackBarColor.Min)+TrackBarColor.Min);
   end;
procedure TfrmMain.editRun_RandColorChange(Sender: TObject);
  procedure setValue(TrackBarColor:TTrackBar;editRun_RandColor:TEdit);
  var
    pos:integer;
  begin
    pos:=strToTrackBarColor(TrackBarColor,editRun_RandColor);
    if (TrackBarColor.Position<>pos) then
      TrackBarColor.Position:=pos;
  end;
begin
  try
    setValue(self.TrackBarColor0,editRun_RandColor0);
    setValue(self.TrackBarColor1,editRun_RandColor1);
    setValue(self.TrackBarColor2,editRun_RandColor2);
  except
  end;
end;

procedure TfrmMain.TrackBarColorChange(Sender: TObject);
  function setValue(editRun_RandColor:TEdit;TrackBarColor:TTrackBar):boolean;
  var
    x :extended;
    //pos:integer;
    posOld : integer;
  begin
    result:=false;
    posOld:=strToTrackBarColor(TrackBarColor,editRun_RandColor);
    if (posOld=TrackBarColor.Position) then exit;
    if (abs(posOld-TrackBarColor.Position)=(TrackBarColor.Max-TrackBarColor.Min)) then exit;

    x:=2*( (TrackBarColor.Position-TrackBarColor.Min)/(TrackBarColor.Max-TrackBarColor.Min) );
    editRun_RandColor.Text:=exFloatToStr(x);
    result:=true;
  end;
var
  isChanged : boolean;
begin
  try
    isChanged:=false;
    isChanged:=isChanged or setValue(editRun_RandColor0,self.TrackBarColor0);
    isChanged:=isChanged or setValue(editRun_RandColor1,self.TrackBarColor1);
    isChanged:=isChanged or setValue(editRun_RandColor2,self.TrackBarColor2);
    if isChanged then
    begin
      RunDoColoring();
      btnColoringUpdate.enabled:=true;
    end;
  except
  end;
end;

procedure TfrmMain.editRun_RandColorKeyPress(Sender: TObject;
  var Key: Char);
begin
  self.ShapeSelectRect.Visible:=false;
  if(Key=#13) then
  begin
    RunDoColoring();
    btnColoringUpdateClick(Sender);
  end;
end;

procedure TfrmMain.btnRunAsColoringClick(Sender: TObject);
begin
  self.ShapeSelectRect.Visible:=false;
  ViewTofractalData();
  //生成预览
  RunGetColoring();
end;

procedure TfrmMain.btnRunAsPicClick(Sender: TObject);
begin
  //生成图片
  self.ShapeSelectRect.Visible:=false;
  ViewTofractalData();
  RunGetPic();
end;

procedure TfrmMain.outInfo(const text: string);
begin
  self.MemoOutInfo.Lines.Add(FormatDateTime('hh:nn:ss:zzz',now)+' '+text);
end;


function TfrmMain.LockViewPixels(picWidth, picHeight: integer):TPixels24;
begin
  self.PaintBox.Width:=picWidth;
  self.PaintBox.Height:=picHeight;

  FBitmapView.PixelFormat:=pf24bit;
  FBitmapView.Height:=0;
  FBitmapView.Width:=picWidth;
  FBitmapView.Height:=picHeight;

  result.PPixelBegin:=PColor24Array(FBitmapView.ScanLine[0]);
  result.ByteWidth:=integer(FBitmapView.ScanLine[1])-integer(FBitmapView.ScanLine[0]);
  result.Width:=picWidth;
  result.Height:=picHeight;
  ScrollBoxResize(self);
end;

function TfrmMain.getColoringSet():TFractalColoring;
begin
  result:=self.FFractalDoc.fractalData.coloring;
end;

function TfrmMain.getRandColoringSet():TFractalColoring;
begin
  result.randColorK0:=strToFloat(self.editRun_RandColorK0.Text);
  result.randColorK1:=strToFloat(self.editRun_RandColorK1.Text);
  result.randColorK2:=strToFloat(self.editRun_RandColorK2.Text);
  result.randColor0:=strToFloat(self.editRun_RandColor0.Text);
  result.randColor1:=strToFloat(self.editRun_RandColor1.Text);
  result.randColor2:=strToFloat(self.editRun_RandColor2.Text);
  if (self.rbtnYUV.Checked) then
    result.randColorType:=ctYUV
  else if (self.rbtnHLS.Checked) then
    result.randColorType:=ctHLS
  else
    result.randColorType:=ctRGB;
end;

procedure TfrmMain.RunGetColoring;
var
  picWidth,picHeight:integer;
begin
  picWidth:=strtoint(self.editColoringWidth.Text);
  picHeight:=strtoint(self.editColoringHeight.Text);
  FIsRunAsColoring:=false;
  self.FFractalDoc.RunGetColoring(picWidth,picHeight,getColoringSet());
end;

procedure TfrmMain.RunDoColoring;
begin                
  FIsRunAsColoring:=true;
  self.FFractalDoc.RunDoColoring(self.PaintBox.Width,self.PaintBox.Height,getRandColoringSet());
end;

procedure TfrmMain.RunGetPic;
begin                   
  FIsRunAsColoring:=false;
  self.FFractalDoc.RunGetPic(FFractalDoc.PicWidth,FFractalDoc.PicHeight,getColoringSet());
end;

procedure TfrmMain.saveFractalDataToHistory;
var
  str:string;
begin
  btnColoringUpdate.Enabled:=false;
  if (FFractalHistory.addAData(self.FFractalDoc.fractalData)) then
  begin
    str:=FFractalHistory.fractalList[FFractalHistory.getDataCount()-1].getCaption();
    if (length(FHistory_FractalFileName)>0) then
    begin
      str:=str+' ['+FHistory_FractalFileName+']';
      FHistory_FractalFileName:='';
    end;
    self.listBoxHistory.Items.Add(str);
  end;
end;

procedure TfrmMain.doFractalCompileOk;
begin
  saveFractalDataToHistory();
end;

procedure TfrmMain.PaintBoxPaint(Sender: TObject);
begin
  self.PaintBox.Canvas.Draw(self.ScrollBox.Left,self.ScrollBox.Top,FBitmapView);
end;

procedure TfrmMain.ShapeSelectRectMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ShapeSelectRect.Visible:=false;
end;

procedure TfrmMain.PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin                             
  self.ShapeSelectRect.Visible:=false;
  FSelectRectX0:=self.PaintBox.Left+x;
  FSelectRectY0:=self.PaintBox.Top+y;
  self.ShapeSelectRect.Left:=FSelectRectX0;
  self.ShapeSelectRect.Top:=FSelectRectY0;
  self.ShapeSelectRect.Width:=0;
  self.ShapeSelectRect.Height:=0;

  self.ShapeSelectRect.Visible:=true;
  FSelectRectIng:=true;
end;

procedure TfrmMain.PaintBoxMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  SelectRectX1,SelectRectY1 : integer;
begin
  if  not FSelectRectIng then exit;
  SelectRectX1:=self.PaintBox.Left+x;
  SelectRectY1:=self.PaintBox.Top+y;

  self.ShapeSelectRect.Left:=min(FSelectRectX0,SelectRectX1);
  self.ShapeSelectRect.Top:=min(FSelectRectY0,SelectRectY1);
  self.ShapeSelectRect.Width:=abs(FSelectRectX0-SelectRectX1);
  self.ShapeSelectRect.Height:=abs(FSelectRectY0-SelectRectY1);
end;

procedure TfrmMain.PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin             
  if  not FSelectRectIng then exit;
  FSelectRectIng:=false;
  if (ShapeSelectRect.Width>=4)and (ShapeSelectRect.Height>=4) then
    btnZoomOutClick(Button=mbRight);
end;

procedure TfrmMain.btnZoomOutClick(isZoomIn:boolean);
var
  dx0,dy0,nx,ny,mx0,my0,rsin,rcos,nw,nh  :extended;
  onw,onh : extended;
begin
  if (PaintBox.Width>=PaintBox.Height) then
  begin
    onw:=2*FFractalDoc.fractalData.r*(PaintBox.Width/PaintBox.Height);
    onh:=2*FFractalDoc.fractalData.r;
  end
  else
  begin
    onw:=2*FFractalDoc.fractalData.r;
    onh:=2*FFractalDoc.fractalData.r*(PaintBox.Height/PaintBox.Width);
  end;
  dx0:=((ShapeSelectRect.Left+ShapeSelectRect.Width*0.5+ScrollBox.HorzScrollBar.Position)/PaintBox.Width-0.5)*onw;
  dy0:=((ShapeSelectRect.Top+ShapeSelectRect.Height*0.5+ScrollBox.VertScrollBar.Position)/PaintBox.Height-0.5)*onh;
  mx0:=FFractalDoc.fractalData.x0;
  my0:=FFractalDoc.fractalData.y0;
  SinCos(self.FFractalDoc.fractalData.seta*(PI/180.0),rsin,rcos);
  nx:= (dx0)*rcos + (dy0)*rsin + mx0;
  ny:=-(dx0)*rsin + (dy0)*rcos + my0;

  if(isZoomIn) then
  begin
    nw:=PaintBox.Width/ShapeSelectRect.Width*onw;
    nh:=PaintBox.Height/ShapeSelectRect.Height*onh;
  end
  else
  begin
    nw:=ShapeSelectRect.Width/PaintBox.Width*onw;
    nh:=ShapeSelectRect.Height/PaintBox.Height*onh;
  end;
  if(nw/nh<onw/onh) then
    nw:=nh*onw/onh
  else
    nh:=nw*onh/onw;

  self.editX0.Text:=exFloatToStr(nx);
  self.editY0.Text:=exFloatToStr(ny);
  self.editR.Text:=exFloatToStr(min(nw,nh)*0.5);

  self.btnRunAsColoringClick(nil);
end;

procedure TfrmMain.doFractalRunOk;
begin
  FProgressBar_Position:=0;
  PostRefreshPicMessage();
  postDrawPicFinishMessage();
end;

procedure TfrmMain.doFractalRunProgress(const progress: double);
var
  RefreshPicNewTime : integer;
begin
  FProgressBar_Position:=progress;
  RefreshPicNewTime:=timeGetTime();
  if (RefreshPicNewTime-FRefreshPicOldTime>=1000/10)then
  begin
    FRefreshPicOldTime:=RefreshPicNewTime;
    if (not FIsRunAsColoring) then
      PostRefreshPicMessage();
  end;
end;

procedure TfrmMain.doRefreshPicMessage(var Message: TMessage);
begin
  self.ProgressBar.Position:=trunc(self.FProgressBar_Position*self.ProgressBar.Max);
  self.PaintBox.Refresh();
  FRefreshPicOldTime:=timeGetTime();
end;

procedure TfrmMain.postRefreshPicMessage;
begin
  windows.PostMessage(self.Handle,MSG_RefreshPicMessage,0,0);
end;

procedure TfrmMain.doDrawPicFinishMessage(var Message: TMessage);
begin
  //self.FFractalDoc.Stop();
  self.outInfo('绘制完成!');
end;

procedure TfrmMain.postDrawPicFinishMessage;
begin
  windows.PostMessage(self.Handle,MSG_DrawPicFinishMessage,0,0);
end;

procedure TfrmMain.ScrollBoxResize(Sender: TObject);
begin
  self.ScrollBox.HorzScrollBar.Position:= (PaintBox.Width-ScrollBox.Width) div 2;
  self.ScrollBox.VertScrollBar.Position:= (PaintBox.Height-ScrollBox.Height) div 2;
end;

procedure TfrmMain.btnStopClick(Sender: TObject);
begin
  self.FFractalDoc.Stop();
end;

procedure TfrmMain.btnColoringUpdateClick(Sender: TObject);
begin
  btnColoringUpdate.Enabled:=false;
  ViewTofractalData();
  self.saveFractalDataToHistory();
end;

procedure TfrmMain.rbtnColorTypeClick(Sender: TObject);
begin
  RunDoColoring();
end;

procedure TfrmMain.listBoxHistoryClick(Sender: TObject);
begin
  self.FFractalHistory.Stop();
  self.FFractalHistory.UpdateHistoryView(self.listBoxHistory.ItemIndex);
  self.listBoxHistory.Hint:=self.listBoxHistory.Items[self.listBoxHistory.ItemIndex];
end;

function TfrmMain.LockHistoryViewPixels(picWidth,
  picHeight: integer): TPixels24;
var
  Bitmap : TBitmap;
begin
  //self.ImageHistoryWiew.Width:=picWidth;
  self.ImageHistoryWiew.Height:=picHeight;

  Bitmap:=self.ImageHistoryWiew.Picture.Bitmap ;
  Bitmap.PixelFormat:=pf24bit; 
  Bitmap.Width:=picWidth;
  Bitmap.Height:=picHeight;

  result.PPixelBegin:=PColor24Array(Bitmap.ScanLine[0]);
  result.ByteWidth:=integer(Bitmap.ScanLine[1])-integer(Bitmap.ScanLine[0]);
  result.Width:=picWidth;
  result.Height:=picHeight;
end;

procedure TfrmMain.refreshHistoryView;
begin
  windows.PostMessage(self.Handle,MSG_RefreshHistoryViewMessage,0,0);
end;

procedure TfrmMain.doRefreshHistoryViewMessage(var Message: TMessage);
begin
  self.ImageHistoryWiew.Repaint;
end;

function TfrmMain.getHistoryViewBestWidth: integer;
begin
  result:=self.ImageHistoryWiew.Width;
end;


procedure TfrmMain.listBoxHistoryDblClick(Sender: TObject);
var
  selectIndex: integer;
begin
  selectIndex:=self.listBoxHistory.ItemIndex;
  if (selectIndex<0)or (selectIndex>=self.FFractalHistory.getDataCount()) then exit;
  listBoxHistoryClick(Sender);  //self.FFractalHistory.Stop();
  FFractalHistory.IsSaveHistory:=false;
  self.fractalDataToView(self.FFractalHistory.fractalList[selectIndex]);
  self.btnRunAsColoringClick(sender);
  FFractalHistory.IsSaveHistory:=true;
end;

procedure TfrmMain.btnSetRandColoringClick(Sender: TObject);
begin
  self.TrackBarColor0.Position:=random(self.TrackBarColor0.Max);
  self.TrackBarColor1.Position:=random(self.TrackBarColor1.Max);
  self.TrackBarColor2.Position:=random(self.TrackBarColor2.Max);
  btnColoringUpdateClick(Sender);
end;


  procedure editColorK(edit:TEdit;m:extended);
  var
    v :extended;
  begin
    v:=strToFloat(edit.Text);
    v:=v*m;
    edit.Text:=exFloatToStr(v);
  end;

procedure TfrmMain.btnRun_RandColorK_UpClick(Sender: TObject);
begin
  editColorK(self.editRun_RandColorK0,2);
  editColorK(self.editRun_RandColorK1,2);
  editColorK(self.editRun_RandColorK2,2);
  RunDoColoring(); 
  btnColoringUpdateClick(Sender);
end;

procedure TfrmMain.btnRun_RandColorK_DownClick(Sender: TObject);
begin
  editColorK(self.editRun_RandColorK0,0.5);
  editColorK(self.editRun_RandColorK1,0.5);
  editColorK(self.editRun_RandColorK2,0.5);
  RunDoColoring(); 
  btnColoringUpdateClick(Sender);
end;

end.
