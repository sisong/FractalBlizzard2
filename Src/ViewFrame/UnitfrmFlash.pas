unit UnitfrmFlash;
////////////////////////////////////////////////////////////////////////////////
//Flash&About窗口单元文件
//  2005.01.23 Create by 侯思松, E-Mail: HouSisong@Gmail.com
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, jpeg;

type
  TfrmFlash = class(TForm)
    ImageTop: TImage;
    LabelAppNameB: TLabel;
    PanelFlash: TPanel;
    BevelLine0: TBevel;
    BevelLine2: TBevel;
    BevelLine1: TBevel;
    BevelLine3: TBevel;
    ImageIcon: TImage;
    LabelVertionCaption: TLabel;
    LabelVertion: TLabel;
    LabelBuildcaption: TLabel;
    LabelBuild: TLabel;
    BevelLineTop: TBevel;
    BevelLinebottom: TBevel;
    Imagebottom: TImage;
    ImageTopP: TImage;
    ImageLeft: TImage;
    ImageRigth: TImage;
    TimerClose: TTimer;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Image1: TImage;
    Label1: TLabel;
    LabelEmailLink: TLabel;
    LabelAppName: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ImageTopMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure ImageTopMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ImageTopMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure TimerCloseTimer(Sender: TObject);
    procedure PanelFlashDblClick(Sender: TObject);
    procedure LabelEmailLinkClick(Sender: TObject);
    procedure PanelFlashMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormKeyPress(Sender: TObject; var Key: Char);

  private
     MsMove:boolean;
     MsPos:Tpoint;
     frmL,frmT:integer;
     FIsShowFlash: boolean;
  public
    procedure ShowAsFlash();
    procedure ShowAsAbout();
  end;
  
implementation
uses
  RunExe,FileVision;

{$R *.dfm}

procedure TfrmFlash.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action:=caFree;  
end;

procedure TfrmFlash.ImageTopMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button=mbLeft then
  begin
    GetCursorPos(MsPos);
    frmL:=self.Left;
    frmT:=self.Top;
    MsMove:=true;
  end;
end;

procedure TfrmFlash.FormCreate(Sender: TObject);
var
  strAllViersion:string;
  strTmp : string;
begin
  MsMove:=false;
  TimerClose.Enabled:=false;
  
  strAllViersion:=getFileAllVerion(application.ExeName);
  strTmp:=getFileMajorVerion(strAllViersion)+'.'
      +getFileMinorVerion(strAllViersion)+'.'
      +getFileReleaseVerion(strAllViersion);
  self.LabelVertion.Caption:=strTmp;
  strTmp:=getFileBuild(strAllViersion);
  self.LabelBuild.Caption:=strTmp;

end;

procedure TfrmFlash.ImageTopMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
    MsMove:=false;
end;

procedure TfrmFlash.ImageTopMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  MsPosT  :Tpoint;
begin
  PanelFlashMouseMove(Sender,Shift,X, Y);
  
  if MsMove then
  begin
    GetCursorPos(MsPosT);
    self.Left:=frmL+MsPosT.X-MsPos.X;
    self.Top:=frmT+MsPosT.Y-MsPos.Y;
  end;
end;

procedure TfrmFlash.TimerCloseTimer(Sender: TObject);
begin
  self.Close;
end;

procedure TfrmFlash.PanelFlashDblClick(Sender: TObject);
begin
  self.Close;
end;

procedure TfrmFlash.LabelEmailLinkClick(Sender: TObject);
begin
  ShellExecute(application.handle,'open',pchar('mailto:'+self.LabelEmailLink.caption),'','', SW_NORMAL)
end;

procedure TfrmFlash.ShowAsAbout;
begin
  FIsShowFlash:=false;
  self.FormStyle:=fsStayOnTop;
  self.TimerClose.Interval:=10000;
  self.TimerClose.Enabled:=false;
  self.TimerClose.Enabled:=true;
  self.ShowModal();
end;

procedure TfrmFlash.ShowAsFlash;
begin
  FIsShowFlash:=true;
  self.FormStyle:=fsStayOnTop;
  self.TimerClose.Interval:=2500;
  self.TimerClose.Enabled:=false;
  self.TimerClose.Enabled:=true;
  self.Show();
  Application.ProcessMessages;
end;

procedure TfrmFlash.PanelFlashMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if not FIsShowFlash then
  begin
    self.TimerClose.Enabled:=false;
    self.TimerClose.Enabled:=true;
  end;
end;

procedure TfrmFlash.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key=#13) or (Key=#27) then
    self.Close;
end;

end.
