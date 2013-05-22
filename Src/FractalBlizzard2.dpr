program FractalBlizzard2;

uses
  Forms,
  UnitFrmMain in 'ViewFrame\UnitFrmMain.pas' {frmMain},
  UnitfrmFlash in 'ViewFrame\UnitfrmFlash.pas' {frmFlash},
  FileVision in 'Common\FileVision.pas',
  DisplayInf in 'Interface\DisplayInf.pas',
  Fractal in 'Interface\Fractal.pas',
  RunExe in 'Common\RunExe.pas',
  Compile_Hss in 'Common\Compile_Hss.pas',
  WorkThreadPool in 'Common\WorkThreadPool.pas',
  SysUtils in 'd:\program files\borland\delphi7\source\rtl\Sys\sysutils.pas',
  FractalHistory in 'FractalHistory.pas';

{$R *.res}
begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  frmMain.Initialize();
  Application.Run;
end.
