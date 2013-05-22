unit FractalEngine;

interface
uses
  DisplayInf,Fractal;


//TFractalEngine(集成者、控制者)
//       聚合:TFractalProperty(属性编辑)\TFractal(分形函数实现)
//       引用:IViewInf(显示)

type
  TFractalEngine = class(TObject)
  private
    FState: TCtlStateType;
    FOnNotify: TCtlNotifyEvent;
    procedure SetOnNotify(const Value: TCtlNotifyEvent);
    procedure DoNotify();
  protected
    FIViewCtl : IView_Ctl;
    FIView2DPixelInf:IView_2DPixel;
    FFractalDoc  : TFractalDoc;
    procedure  DoStart(); virtual;
    procedure  DoContinue(); virtual;
    procedure  DoStop(); virtual;
    procedure  DoPause(); virtual;
  public
    constructor Create(aIViewCtlInf:IView_Ctl;aIView2DPixelInf:IView_2DPixel);
    destructor Destroy; override;
    procedure  Start();
    procedure  Continue();
    procedure  Stop();
    procedure  Pause();

    property  State: TCtlStateType read FState;

    property  OnCtlNotify: TCtlNotifyEvent read FOnNotify write SetOnNotify;
  end;

implementation

{ TFractalEngine }

constructor TFractalEngine.Create(aIViewCtlInf:IView_Ctl;aIView2DPixelInf:IView_2DPixel);
begin
  inherited Create();
  self.FState:=csStop;
  self.FIViewCtl:=aIViewCtlInf;
  self.FIView2DPixelInf:=aIView2DPixelInf;
end;

destructor TFractalEngine.Destroy;
begin
  inherited;
end;

procedure TFractalEngine.Pause;
begin
  Assert(FState=csRunning);
  self.FState:=csPause;
  DoNotify();
end;

procedure TFractalEngine.Start;
begin
  Assert(FState=csStop);
  self.FState:=csRunning;
  self.DoStart();
  DoNotify();
end;

procedure TFractalEngine.Stop;
begin
  Assert(FState in [csStop,csPause]);
  self.FState:=csRunning;
  self.DoStop();
  DoNotify();
end;

procedure TFractalEngine.Continue;
begin
  Assert(FState=csPause);
  self.FState:=csRunning;
  self.DoContinue();
  DoNotify();
end;

procedure TFractalEngine.SetOnNotify(const Value: TCtlNotifyEvent);
begin
  FOnNotify := Value;
end;

procedure TFractalEngine.DoNotify;
begin
  if Assigned(FOnNotify) then
    FOnNotify(self,self.FState);
end;

procedure TFractalEngine.DoContinue;
begin
end;

procedure TFractalEngine.DoPause;
begin
end;

procedure TFractalEngine.DoStart;
begin
end;

procedure TFractalEngine.DoStop;
begin
end;

end.
