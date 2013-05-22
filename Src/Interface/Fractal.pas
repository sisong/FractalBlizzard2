unit Fractal;

interface
uses
  SysUtils,DisplayInf,Compile_Hss,SyncObjs,WorkThreadPool,Contnrs;

type
  TFractalData=class(TObject)
  public
    fractalName   : string;
    loopXFunction : string;
    loopYFunction : string;
    maxi  : integer;
    stopFunction  : string;
    x0 : extended;
    y0 : extended;
    r : extended;
    seta : extended;
    picWidth  : integer;
    picHeight : integer;
    colorFunction0 : string;
    colorFunction1 : string;
    colorFunction2 : string;
    smoothIFunction: string;
    smoothXFunction: string;
    smoothYFunction: string;
    coloring : TFractalColoring;

    procedure LoadFromfile(const fileName:string);
    procedure SaveToFile(const fileName:string);
    procedure copyFrom(const src:TFractalData);
    function  IsEqual(const src:TFractalData):boolean;
  end;


type
    TTempVarData =class(TObject)
    public
      varName : string;
      varValue: TCmxFloat;
      constructor Create(const _varName : string);
      function getVarAddressValue():string;
    end;

type
  TFractalCompiler=class(TObject)
  private
    FTempVarList : TObjectList;
    function translationFunction(const functionStr: string): string;
    function translationEvaluate(const evaluateStr: string): string;
    function addTempVar(const varName: string): TTempVarData;
  public
    constructor Create();
    destructor Destroy; override;
  public
    //函数
    loopXFunction : TCompile;
    loopYFunction : TCompile;
    stopFunction  : TCompile;
    colorFunction0 : TCompile;
    colorFunction1 : TCompile;
    colorFunction2 : TCompile;
    smoothIFunction : TCompile;
    smoothXFunction : TCompile;
    smoothYFunction : TCompile;

    //共享的变量和数组
    i_var :TCmxFloat;
    M_var :TCmxFloat;
    x_var :TCmxFloat;
    y_var :TCmxFloat;
    x_array :array of TCmxFloat;
    y_array :array of TCmxFloat;
    fractalColor_var :TFractalColor;
    maxi_var :TCmxFloat;
    sm_i_var :TCmxFloat;
    sm_x_var :TCmxFloat;
    sm_y_var :TCmxFloat;
    function Compile(const FractalData : TFractalData;out outError:string):boolean;
    procedure CalcColor(const x0,y0:TCmxFloat);
  end;

  IFractalDocListener=interface
    procedure doFractalCompileOk();
    procedure outInfo(const text:string);
    procedure doFractalRunProgress(const progress:double);
    procedure doFractalRunOk();
    function LockViewPixels(picWidth, picHeight: integer): TPixels24;
  end;

  TCalcFractalWorkManager=class;

  TFractalDoc = class(TObject)
  private
    FFractalData : TFractalData;
    FFractalColors : TPixelsFractalColor;
    FColoringBuf : array of TFractalColor;
    FisGetColoringOk: boolean;
    FFractalCompiler : TFractalCompiler;
    FFractalDocListener:IFractalDocListener;
    FCalcFractalWorkManager : TCalcFractalWorkManager;
    function Compile():boolean;
    procedure doRunGet(const pixels24: TPixels24; const fractalColors: TPixelsFractalColor; const Coloring: TFractalColoring;isReCalcFractalColor,isSaveCalcFractalColor:boolean);
    function getPicHeight: integer;
    function getPicWidth: integer;
  public
    constructor Create(fractalDocListener:IFractalDocListener);
    destructor Destroy; override;

    property fractalData: TFractalData read FFractalData write FFractalData;

    procedure RunGetColoring(picWidth, picHeight: integer;const Coloring:TFractalColoring);
    procedure RunDoColoring(picWidth, picHeight: integer;const Coloring:TFractalColoring);
    procedure RunGetPic(picWidth, picHeight: integer;const Coloring: TFractalColoring);

    property isGetColoringOk:boolean read FisGetColoringOk;
    property PicWidth:integer read getPicWidth;
    property PicHeight:integer read getPicHeight;
    procedure Stop();
  end;

  TCalcFractalWorkData=class(TObject)
  public  
    FractalCompiler         : TFractalCompiler;
    CalcFractalWorkManager : TCalcFractalWorkManager;
    constructor Create();
    destructor Destroy; override;
  end;

  TCalcFractalWorkManager=class(TObject)
  private
    FWorkThreadPool : TWorkThreadPool;
    FWorkIsDoList : array of integer;
    FWorkDataList :array of TCalcFractalWorkData;
    FPWorkDataList :array of TPWorkData;
    FWorkFinishCount :integer;
    FLock : TCriticalSection;
    FisWantStop : boolean;

    procedure Clear();
    procedure doWorkFinish();
    procedure doSingleWork(WorkData:TCalcFractalWorkData);
    function getIsCanWork(const wantY :integer):boolean;
    procedure setIsWorked(const wantY :integer);
  public
    constructor Create();
    destructor Destroy; override;
  public
    pixels24: TPixels24;
    fractalColors:TPixelsFractalColor;
    Coloring: TFractalColoring;
    isSaveCalcFractalColor:boolean;
    isReCalcFractalColor :boolean;
    FractalData : TFractalData;
    FractalDocListener:IFractalDocListener;

    procedure RunCalc();
    procedure Stop();
  end;

implementation
uses
  iniFiles,math;

const xy_array_border=200;
const
  default_smoothIFunction='_sqr_z1:ln(1e-10+abs(ln(1e-10+sqr(xn[i-1])+sqr(yn[i-1]))));'+        // sm_i
                          '_sqr_z2:ln(1e-10+abs(ln(1e-10+sqr(xn[i-2])+sqr(yn[i-2]))));'+
                          '1+i-(_sqr_z1-ln(1e-10+abs(ln(M))))/(1e-10+abs(_sqr_z1-_sqr_z2))';
  default_smoothXFunction='di:i-1;_d1:sm_i+100-int(sm_i+100);_d2:sqr(_d1);_d3:_d1*_d2;'+
                          '( _d3*xn[di]+(1+_d1*3+_d2*3-_d3*3)*xn[di-1]+(4-_d2*6+_d3*3)*xn[di-2]+(1-_d1*3+_d2*3-_d3)*xn[di-3] )*(1.0/6)'; // sm_x
                          //'( (_d3-_d2)*xn[di]+(_d1+_d2*4-_d3*3)*xn[di-1]+(2-_d2*5+_d3*3)*xn[di-2]+(_d2*2-_d3-_d1)*xn[di-3] )*0.5'; // sm_x
  default_smoothYFunction='( _d3*yn[di]+(1+_d1*3+_d2*3-_d3*3)*yn[di-1]+(4-_d2*6+_d3*3)*yn[di-2]+(1-_d1*3+_d2*3-_d3)*yn[di-3] )*(1.0/6)'; // sm_y
                          //'( (_d3-_d2)*yn[di]+(_d1+_d2*4-_d3*3)*yn[di-1]+(2-_d2*5+_d3*3)*yn[di-2]+(_d2*2-_d3-_d1)*yn[di-3] )*0.5'; // sm_y



{ TFractalData }

procedure TFractalData.copyFrom(const src: TFractalData);
begin
  self.fractalName:=src.fractalName;
  self.loopXFunction:=src.loopXFunction;
  self.loopYFunction:=src.loopYFunction;
  self.maxi:=src.maxi;
  self.stopFunction:=src.stopFunction;
  self.x0:=src.x0;
  self.y0:=src.y0;
  self.r:=src.r;
  self.seta:=src.seta;
  self.picWidth:=src.picWidth;
  self.picHeight:=src.picHeight;
  self.colorFunction0:=src.colorFunction0;
  self.colorFunction1:=src.colorFunction1;
  self.colorFunction2:=src.colorFunction2;
  self.smoothIFunction:=src.smoothIFunction;
  self.smoothXFunction:=src.smoothXFunction;
  self.smoothYFunction:=src.smoothYFunction;
  self.coloring:=src.coloring;
end;

function TFractalData.IsEqual(const src:TFractalData): boolean;
begin
  result:=
  //self.fractalName=src.fractalName
  (self.loopXFunction=src.loopXFunction     )and
  (self.loopYFunction=src.loopYFunction     )and
  (self.maxi=src.maxi       )and
  (self.stopFunction=src.stopFunction       )and
  (self.x0=src.x0                           )and
  (self.y0=src.y0                           )and
  (self.r=src.r                             )and
  (self.seta=src.seta                       )and
  //(self.picWidth=src.picWidth               )and
  //(self.picHeight=src.picHeight             )and
  (self.colorFunction0=src.colorFunction0   )and
  (self.colorFunction1=src.colorFunction1   )and
  (self.colorFunction2=src.colorFunction2   )and
  (self.smoothIFunction=src.smoothIFunction )and
  (self.smoothXFunction=src.smoothXFunction )and
  (self.smoothYFunction=src.smoothYFunction )and
  (self.coloring.randColorType=src.coloring.randColorType     )and
  (self.coloring.randColorK0=src.coloring.randColorK0         )and
  (self.coloring.randColorK1=src.coloring.randColorK1         )and
  (self.coloring.randColorK2=src.coloring.randColorK2         )and
  (self.coloring.randColor0=src.coloring.randColor0           )and
  (self.coloring.randColor1=src.coloring.randColor1           )and
  (self.coloring.randColor2=src.coloring.randColor2           );

end;

  { TIniFileEx }
type
  TIniFileEx=class(TIniFile)
  public
    function ReadExtended(const Section, Name: string; Default: extended): extended;
    procedure WriteExtended(const Section, Name: string; Value: extended);
  end;

  function TIniFileEx.ReadExtended(const Section, Name: string;
    Default: extended): extended;
  var
    FloatStr: string;
  begin
    FloatStr := ReadString(Section, Name, '');
    Result := Default;
    if FloatStr <> '' then
    try
      Result := StrToFloat(FloatStr);
    except
      on EConvertError do
        // Ignore EConvertError exceptions
      else
        raise;
    end;
  end;

  procedure TIniFileEx.WriteExtended(const Section, Name: string;
    Value: extended);
  begin
    WriteString(Section, Name, exFloatToStr(Value));
  end;

const
  csSection='fractal';
  csfractalType='fileType';
    csfractalTypeValue='fractal';
  csfractalVersion='version';
    csfractalVersionValue=0.1;
  csfractalName='fractalName';
  csloopXFunction='loopXFunction';
  csloopYFunction='loopYFunction';
  csmaxi='maxi';
  csstopFunction='stopFunction';
  csx0='x0';
  csy0='y0';
  csR='r';
  csseta='seta';
  cspicWidth='picWidth';
  cspicHeight='picHeight';
  cscolorType='colorType';
  cscolorFunction0='colorFunction0';
  cscolorFunction1='colorFunction1';
  cscolorFunction2='colorFunction2';
  cssmoothIFunction='smoothIFunction';
  cssmoothXFunction='smoothXFunction';
  cssmoothYFunction='smoothYFunction';
  csrandColorK0='randColorK0';
  csrandColorK1='randColorK1';
  csrandColorK2='randColorK2';
  csrandColor0='randColor0';
  csrandColor1='randColor1';
  csrandColor2='randColor2';

procedure TFractalData.LoadFromfile(const fileName: string);
  function functionStrAutoLine(const functionStr:string):string;
  var
    posIndex: integer;
  begin
    posIndex:=pos(';',functionStr);
    if posIndex>0 then
    begin
      while functionStr[posIndex+1]=' ' do
        inc(posIndex);
      result:=copy(functionStr,1,posIndex)+#13#10
              +functionStrAutoLine(copy(functionStr,posIndex+1,length(functionStr)));
    end
    else
      result:=functionStr;
  end;
var
  frcFile : TIniFileEx;
begin
  frcFile :=TIniFileEx.Create(fileName);
  try
    if (csfractalTypeValue<>frcFile.ReadString(csSection,csfractalType,'')) then
      exit;// error
    if (csfractalVersionValue<frcFile.ReadExtended(csSection,csfractalVersion,0))then
      exit;// not sport
    self.fractalName:=frcFile.ReadString(csSection,csfractalName,'');
    self.loopXFunction:=functionStrAutoLine(frcFile.ReadString(csSection,csloopXFunction,''));
    self.loopYFunction:=functionStrAutoLine(frcFile.ReadString(csSection,csloopYFunction,''));
    self.maxi:=frcFile.ReadInteger(csSection,csmaxi,10000);
    self.stopFunction:=functionStrAutoLine(frcFile.ReadString(csSection,csstopFunction,''));
    self.x0:=frcFile.ReadExtended(csSection,csx0,0);
    self.y0:=frcFile.ReadExtended(csSection,csy0,0);
    self.r:=frcFile.ReadExtended(csSection,csR,0);
    self.seta:=frcFile.ReadExtended(csSection,csseta,0);
    self.picWidth:=frcFile.ReadInteger(csSection,cspicWidth,800);
    self.picHeight:=frcFile.ReadInteger(csSection,cspicHeight,600);
    self.colorFunction0:=functionStrAutoLine(frcFile.ReadString(csSection,cscolorFunction0,''));
    self.colorFunction1:=functionStrAutoLine(frcFile.ReadString(csSection,cscolorFunction1,''));
    self.colorFunction2:=functionStrAutoLine(frcFile.ReadString(csSection,cscolorFunction2,''));
    self.smoothIFunction:=functionStrAutoLine(frcFile.ReadString(csSection,cssmoothIFunction,''));
    self.smoothXFunction:=functionStrAutoLine(frcFile.ReadString(csSection,cssmoothXFunction,''));
    self.smoothYFunction:=functionStrAutoLine(frcFile.ReadString(csSection,cssmoothYFunction,''));
    self.coloring.randColorType:=strToColorType(frcFile.ReadString(csSection,cscolorType,''));
    self.coloring.randColorK0:=frcFile.ReadExtended(csSection,csrandColorK0,1);
    self.coloring.randColorK1:=frcFile.ReadExtended(csSection,csrandColorK1,1);
    self.coloring.randColorK2:=frcFile.ReadExtended(csSection,csrandColorK2,1);
    self.coloring.randColor0:=frcFile.ReadExtended(csSection,csrandColor0,0);
    self.coloring.randColor1:=frcFile.ReadExtended(csSection,csrandColor1,0);
    self.coloring.randColor2:=frcFile.ReadExtended(csSection,csrandColor2,0);
  finally
    frcFile.Free;
  end;
end;

procedure TFractalData.SaveToFile(const fileName: string);
  function strDelLine(const functionStr:string):string;
  var
    i,insertIndex: integer;
  begin
    insertIndex:=1;
    result:=functionStr;
    for i:=1 to length(result) do
    begin
      if (result[i]<>#13) and (result[i]<>#10) then
      begin
        result[insertIndex]:=functionStr[i];
        inc(insertIndex);
      end;
    end;
    setlength(result,insertIndex-1);
  end;
var
  frcFile : TIniFileEx;
begin
  frcFile :=TIniFileEx.Create(fileName);
  try
    frcFile.WriteString  (csSection,csfractalType   ,csfractalTypeValue);
    frcFile.WriteExtended(csSection,csfractalVersion,csfractalVersionValue);
    frcFile.WriteString  (csSection,csfractalName   ,self.fractalName);
    frcFile.WriteString  (csSection,csloopXFunction ,strDelLine(self.loopXFunction));
    frcFile.WriteString  (csSection,csloopYFunction ,strDelLine(self.loopYFunction));
    frcFile.WriteInteger (csSection,csmaxi          ,self.maxi);
    frcFile.WriteString  (csSection,csstopFunction  ,strDelLine(self.stopFunction));
    frcFile.WriteExtended(csSection,csx0            ,self.x0);
    frcFile.WriteExtended(csSection,csy0            ,self.y0);
    frcFile.WriteExtended(csSection,csR             ,self.r);
    frcFile.WriteExtended(csSection,csseta          ,self.seta);
    frcFile.WriteInteger (csSection,cspicWidth      ,self.picWidth);
    frcFile.WriteInteger (csSection,cspicHeight     ,self.picHeight);
    frcFile.WriteString  (csSection,cscolorFunction0,strDelLine(self.colorFunction0));
    frcFile.WriteString  (csSection,cscolorFunction1,strDelLine(self.colorFunction1));
    frcFile.WriteString  (csSection,cscolorFunction2,strDelLine(self.colorFunction2));
    frcFile.WriteString  (csSection,cssmoothIFunction ,strDelLine(self.smoothIFunction));
    frcFile.WriteString  (csSection,cssmoothXFunction ,strDelLine(self.smoothXFunction));
    frcFile.WriteString  (csSection,cssmoothYFunction ,strDelLine(self.smoothYFunction));
    frcFile.WriteString  (csSection,cscolorType     ,colorTypeToStr(self.coloring.randColorType));
    frcFile.WriteExtended(csSection,csrandColorK0   ,self.coloring.randColorK0);
    frcFile.WriteExtended(csSection,csrandColorK1   ,self.coloring.randColorK1);
    frcFile.WriteExtended(csSection,csrandColorK2   ,self.coloring.randColorK2);
    frcFile.WriteExtended(csSection,csrandColor0    ,self.coloring.randColor0);
    frcFile.WriteExtended(csSection,csrandColor1    ,self.coloring.randColor1);
    frcFile.WriteExtended(csSection,csrandColor2    ,self.coloring.randColor2);
    frcFile.UpdateFile();
  finally
    frcFile.Free;
  end;
end;
    
{ TFractalCompiler }

procedure TFractalCompiler.CalcColor(const x0,y0:TCmxFloat);
type TGetVlaueProc=Function():TCmxFloat;
var
  i,i_stop :integer;
  maxi : integer;
  new_x_var : TCmxFloat;
  getXValue,getYValue,getIsStopValue:TGetVlaueProc;
begin
  getXValue:=self.loopXFunction.GetValue;
  getYValue:=self.loopYFunction.GetValue;
  getIsStopValue:=self.stopFunction.GetValue;
  x_var:=x0;
  y_var:=y0;
  for i:=0 to xy_array_border do
  begin
    x_array[i]:=x0;
    y_array[i]:=y0;
  end;
  i_var:=0;

  maxi:=round(self.maxi_var);
  try
    for i:=1 to maxi do
    begin
      i_var:=i;
      if (0<>getIsStopValue()) then
        break;
      new_x_var:=getXValue();
      y_var:=getYValue();
      x_var:=new_x_var;
      x_array[xy_array_border+i]:=new_x_var;
      y_array[xy_array_border+i]:=y_var;
    end;
    i_stop:=round(i_var);
    x_array[xy_array_border+i_stop]:=getXValue();
    y_array[xy_array_border+i_stop]:=getYValue();
    for i:=i_stop+1 to i_stop+xy_array_border do
    begin
      x_array[xy_array_border+i]:=x_array[xy_array_border+i_stop];
      y_array[xy_array_border+i]:=y_array[xy_array_border+i_stop];
    end;

    sm_i_var:=self.smoothIFunction.GetValue();
    sm_x_var:=self.smoothXFunction.GetValue();
    sm_y_var:=self.smoothYFunction.GetValue();

    fractalColor_var.color0:=self.colorFunction0.GetValue();
    fractalColor_var.color1:=self.colorFunction1.GetValue();
    fractalColor_var.color2:=self.colorFunction2.GetValue();
  except
  end;
end;

  function TFractalCompiler.addTempVar(const varName : string):TTempVarData;
  var
    varData :TTempVarData;
    i : integer;
  begin
    for i:=0 to self.FTempVarList.Count-1 do
    begin
      varData:=TTempVarData(self.FTempVarList.Items[i]);
      if varName=varData.varName then
      begin
        result:=varData;
        exit;
      end;
    end;

    result :=TTempVarData.Create(varName);
    self.FTempVarList.Add(result);
  end;
  function TFractalCompiler.translationEvaluate(const evaluateStr:string):string;
  var
    posIndex:integer;
    varName : string;
    varData : TTempVarData;
  begin
    posIndex:=pos(':',evaluateStr);
    if (posIndex<=0) then
    begin
      result:=evaluateStr;
      exit;
    end;

    varName:=lowercase(trim(copy(evaluateStr,1,posIndex-1)));
    if (varName='') then
    begin
      result:=evaluateStr;
      exit;
    end;
    varData :=addTempVar(varName);
    result:='TCmSYS_Fstp_Value('+varData.getVarAddressValue()+','+copy(evaluateStr,posIndex+1,length(evaluateStr))+')';

  end;
  function TFractalCompiler.translationFunction(const functionStr:string):string;
  var
    posIndex:integer;
  begin
    posIndex:=pos(';',functionStr);
    if (posIndex<=0) then
    begin
      result:=functionStr;
      exit;
    end;

    result:=  '('+translationEvaluate(copy(functionStr,1,posIndex-1))
            + ')*0+('
            + translationFunction( copy(functionStr,posIndex+1,length(functionStr)) )+')';
  end;

function TFractalCompiler.Compile(const FractalData: TFractalData;
  out outError: string): boolean;
  function CompileOne(compile:TCompile;const functionStr:string;out outError: string):boolean;
  var
    i : integer;
    varData : TTempVarData;
  begin
    compile.EnabledOptimizeDiv:=true;
    compile.EnabledOptimizeStack:=true;
    compile.EnabledOptimizeConst:=true;
    //share var
    M_var:=16;
    compile.SetText(translationFunction(functionStr),'',false);
    compile.DefineConst('maxi',exFloatToStr(maxi_var));
    compile.SetExteriorParameter('i',@i_var);
    compile.SetExteriorParameter('M',@M_var);
    compile.SetExteriorParameter('x',@x_var);
    compile.SetExteriorParameter('y',@y_var);
    compile.SetExteriorParameter('x0',@x_array[xy_array_border]);
    compile.SetExteriorParameter('y0',@y_array[xy_array_border]);
    compile.SetExteriorParameter('color0',@fractalColor_var.color0);
    compile.SetExteriorParameter('color1',@fractalColor_var.color1);
    compile.SetExteriorParameter('color2',@fractalColor_var.color2);
    compile.SetExteriorArrayParameter('xn',@x_array[xy_array_border]);
    compile.SetExteriorArrayParameter('yn',@y_array[xy_array_border]);
    compile.SetExteriorParameter('sm_i',@sm_i_var);
    compile.SetExteriorParameter('sm_x',@sm_x_var);
    compile.SetExteriorParameter('sm_y',@sm_y_var);

    for i:=0 to self.FTempVarList.Count-1 do
    begin
      varData :=TTempVarData(self.FTempVarList.Items[i]);
      compile.SetExteriorParameter(varData.varName,@varData.varValue);
    end;

    if (not compile.Compile) then
    begin  //编译有错误
      outError:= compile.GetErrorGB(compile.GetErrorCode);
      result:=false;
      exit;
    end
    {else  if compile.IfHaveUnDefineParameter() then
    begin
      outError:='有未定义的变量!';
      result:=false;
      exit;
    end }
    else
      outError:='';
    compile.RefreshExeAddressCodeInPointer();
    result:=true;
  end;

  function getFunctionStr(const value,default:string):String;
  begin
    if (value='') then
      result:=default
    else
      result:=value;
  end;
begin
  FTempVarList.Clear();
  result:=false;

  self.maxi_var:=FractalData.maxi;
  setlength(self.x_array,xy_array_border*2+FractalData.maxi+1);
  setlength(self.y_array,xy_array_border*2+FractalData.maxi+1);

  if (not CompileOne(loopXFunction,FractalData.loopXFunction,outError)) then exit;
  if (not CompileOne(loopYFunction,FractalData.loopYFunction,outError)) then exit;
  if (not CompileOne(stopFunction,FractalData.stopFunction,outError)) then exit;
  if (not CompileOne(colorFunction0,FractalData.colorFunction0,outError)) then exit;
  if (not CompileOne(colorFunction1,FractalData.colorFunction1,outError)) then exit;
  if (not CompileOne(colorFunction2,FractalData.colorFunction2,outError)) then exit;
  if (not CompileOne(smoothIFunction,getFunctionStr(FractalData.smoothIFunction,default_smoothIFunction),outError)) then exit;
  if (not CompileOne(smoothXFunction,getFunctionStr(FractalData.smoothXFunction,default_smoothXFunction),outError)) then exit;
  if (not CompileOne(smoothYFunction,getFunctionStr(FractalData.smoothYFunction,default_smoothYFunction),outError)) then exit;

  result:=true;
end;

constructor TFractalCompiler.Create;
begin     
  inherited;
  FTempVarList :=TObjectList.Create;
  loopXFunction :=TCompile.Create;
  loopYFunction :=TCompile.Create;
  stopFunction :=TCompile.Create;
  colorFunction0 :=TCompile.Create;
  colorFunction1 :=TCompile.Create;
  colorFunction2 :=TCompile.Create;
  smoothIFunction :=TCompile.Create;
  smoothXFunction :=TCompile.Create;
  smoothYFunction :=TCompile.Create;
end;

destructor TFractalCompiler.Destroy;
begin
  loopXFunction.Free;
  loopYFunction.Free;
  stopFunction.Free;
  colorFunction0.Free;
  colorFunction1.Free;
  colorFunction2.Free;
  smoothIFunction.Free;
  smoothXFunction.Free;
  smoothYFunction.Free;
  FTempVarList.Free;
  inherited;
end;

{ TFractalDoc }

constructor TFractalDoc.Create(fractalDocListener:IFractalDocListener);
begin
  FFractalDocListener:=fractalDocListener;
  FFractalData :=TFractalData.Create;
  FisGetColoringOk:=false;
  FCalcFractalWorkManager :=TCalcFractalWorkManager.Create();
  FCalcFractalWorkManager.FractalData:=self.FFractalData;
  FCalcFractalWorkManager.FractalDocListener:=self.FFractalDocListener;
end;

destructor TFractalDoc.Destroy;
begin
  Stop();
  FreeAndNil(FCalcFractalWorkManager);
  FreeAndNil(FFractalData);
  inherited;
end;
            

function TFractalDoc.getPicWidth: integer;
begin
  result:=self.FFractalData.picWidth;
end;

function TFractalDoc.getPicHeight: integer;
begin
  result:=self.FFractalData.picHeight;
end;


function TFractalDoc.Compile():boolean;
var
  outError: string;
begin
  Stop();

  FisGetColoringOk:=false;
  assert(FFractalCompiler=nil);
  FFractalCompiler:=TFractalCompiler.Create;
  try
    self.FFractalDocListener.outInfo('开始编译表达式...');
    result:=FFractalCompiler.Compile(self.FFractalData,outError);
    if (not result) then
      freeAndNil(FFractalCompiler);
  except
    outError:='程序运行发生异常!';
    result:=false;
  end;
  
  if (not result) then
    self.FFractalDocListener.outInfo('编译发生错误:'+outError)
  else
  begin
    self.FFractalDocListener.outInfo('编译完成.');
    self.FFractalDocListener.doFractalCompileOk();
  end;
end;

procedure TFractalDoc.RunGetColoring(picWidth, picHeight: integer;const Coloring: TFractalColoring);
var
  pixels24: TPixels24;
begin
  Stop();
  if (not Compile()) then exit;
  pixels24:=self.FFractalDocListener.LockViewPixels(picWidth, picHeight);

  setlength(self.FColoringBuf,pixels24.Width*pixels24.Height);
  //fillchar(FColoringBuf[0],sizeof(FColoringBuf[0])*length(FColoringBuf),0);
  FFractalColors.PPixelBegin:=@FColoringBuf[0];
  FFractalColors.ByteWidth:=pixels24.Width*sizeof(TFractalColor);
  FFractalColors.Width:=pixels24.Width;
  FFractalColors.Height:=pixels24.Height;

  doRunGet(pixels24,FFractalColors,Coloring,true,true);
  FisGetColoringOk:=true;
end;

procedure TFractalDoc.RunDoColoring(picWidth, picHeight: integer;const Coloring: TFractalColoring);
var
  pixels24: TPixels24;
begin
  if (not FisGetColoringOk) then exit;
  if (picWidth<>FFractalColors.Width) or (picHeight<>FFractalColors.Height) then exit;
  Stop();

  pixels24:=self.FFractalDocListener.LockViewPixels(picWidth, picHeight);

  doRunGet(pixels24,FFractalColors,Coloring,false,false);
end;

procedure TFractalDoc.RunGetPic(picWidth, picHeight: integer;const Coloring: TFractalColoring);
var
  pixels24: TPixels24;
begin
  Stop();
  if (not Compile()) then exit;
  FisGetColoringOk:=false;

  setlength(self.FColoringBuf,0);
  fillchar(FFractalColors,sizeof(FFractalColors),0);

  pixels24:=self.FFractalDocListener.LockViewPixels(picWidth, picHeight);

  doRunGet(pixels24,FFractalColors,Coloring,true,false);
end;

procedure TFractalDoc.Stop;
begin
  self.FCalcFractalWorkManager.Stop();
  freeandNil(FFractalCompiler);
end;


procedure TFractalDoc.doRunGet(const pixels24: TPixels24;const fractalColors:TPixelsFractalColor;const Coloring: TFractalColoring;isReCalcFractalColor,isSaveCalcFractalColor:boolean);
begin
  fillColor(pixels24,toColor24(0,0,0));
  self.FCalcFractalWorkManager.pixels24:=pixels24;
  self.FCalcFractalWorkManager.fractalColors:=fractalColors;
  self.FCalcFractalWorkManager.Coloring:=Coloring;
  self.FCalcFractalWorkManager.isSaveCalcFractalColor:=isSaveCalcFractalColor;
  self.FCalcFractalWorkManager.isReCalcFractalColor:=isReCalcFractalColor;
  self.FCalcFractalWorkManager.FractalData:=self.FFractalData;
  self.FCalcFractalWorkManager.FractalDocListener:=self.FFractalDocListener;
  self.FCalcFractalWorkManager.RunCalc();
end;



{ TCalcFractalWorkManager }

constructor TCalcFractalWorkManager.Create;
begin
  inherited;
  self.FLock:=TCriticalSection.Create();
  FWorkThreadPool :=TWorkThreadPool.Create;
end;

destructor TCalcFractalWorkManager.Destroy;
begin
  FWorkThreadPool.Free();
  FreeAndNil(FLock);
  Clear();
  inherited;
end;

  function InterlockedIncrement(var I: Integer): Integer;
  asm
        MOV   EDX,1
        XCHG  EAX,EDX
   LOCK XADD  [EDX],EAX
        INC   EAX
  end;

  function InterlockedDecrement(var I: Integer): Integer;
  asm
        MOV   EDX,-1
        XCHG  EAX,EDX
   LOCK XADD  [EDX],EAX
        DEC   EAX
  end;

function TCalcFractalWorkManager.getIsCanWork(
  const wantY: integer): boolean;
var
  WorkIsDo : integer;
begin
  result:=false;
  if self.FisWantStop then exit;
  if (FWorkIsDoList[wantY]>0) then exit;

  WorkIsDo:=InterlockedIncrement(FWorkIsDoList[wantY]);
  result:=(WorkIsDo=1);
  if not result then
    InterlockedDecrement(FWorkIsDoList[wantY]);
end;

procedure TCalcFractalWorkManager.setIsWorked(const wantY: integer);
var
  curWorkFinishCount:integer;
begin
  assert(FWorkIsDoList[wantY]>=1);
  InterlockedIncrement(FWorkIsDoList[wantY]);

  curWorkFinishCount:=InterlockedIncrement(FWorkFinishCount);

  if (FractalDocListener<>nil) then
     FractalDocListener.doFractalRunProgress(curWorkFinishCount/self.pixels24.Height);
  if (curWorkFinishCount=self.pixels24.Height) then
    self.doWorkFinish();
end;

  procedure TCalcFractalWorkManager_RunCalcCallBack(pData:TPWorkData);
  begin
    TCalcFractalWorkData(pData).CalcFractalWorkManager.doSingleWork(TCalcFractalWorkData(pData));
  end;

procedure TCalcFractalWorkManager.RunCalc;
var
  i : integer;
  errorStr:string;
begin
  self.Clear();
  setlength(FWorkIsDoList,self.pixels24.Height); 
  setlength(FWorkDataList,self.FWorkThreadPool.best_work_count);
  for i:=0 to length(FWorkDataList)-1 do
  begin
    FWorkDataList[i]:=TCalcFractalWorkData.Create();
    FWorkDataList[i].FractalCompiler.Compile(FractalData,errorStr);

    FWorkDataList[i].CalcFractalWorkManager:=self;
  end;
  self.FWorkThreadPool.work_execute(TCalcFractalWorkManager_RunCalcCallBack,
    TPWorkDataList(@FWorkDataList[0]),length(FWorkDataList),false);
end;

procedure TCalcFractalWorkManager.Stop;
begin
  self.FisWantStop:=true;
  self.FWorkThreadPool.waitStop();
end;

procedure TCalcFractalWorkManager.doWorkFinish;
begin
  if (FractalDocListener<>nil) then
    FractalDocListener.doFractalRunOk();
end;

procedure TCalcFractalWorkManager.Clear;
var
  i :integer;
begin
  FisWantStop:=false;
  FWorkFinishCount:=0;
  self.FPWorkDataList:=nil;
  self.FWorkIsDoList:=nil;
  for i:=0 to length(FWorkDataList)-1 do
    FWorkDataList[i].free;
  FWorkDataList:=nil;
end;
     
procedure TCalcFractalWorkManager.doSingleWork(WorkData:TCalcFractalWorkData);
var
  fractalColorToColor24 : TFractalColorToColor24Proc;
var
  x,y,yi:integer;
  x0,y0 : extended;
  PPixel : PColor24Array;
  PFractalColors :PFractalColorArray;
  curFractalColor :TFractalColor;
  //isOutFractalColor : boolean;
  zoomScale,rSin,rCos : extended;
  minx0,miny0,mx0,my0,nx,ny : extended;
  FractalCompiler  : TFractalCompiler;
  errorColor:TRGBColor_Float_16;
begin
  if (pixels24.width<=1)or (pixels24.Height<=1) then exit;
  case coloring.randColorType of
    ctYUV: fractalColorToColor24:=FractalColorYUVToColor24;
    ctHLS: fractalColorToColor24:=FractalColorHLSToColor24;
    else   fractalColorToColor24:=FractalColorRGBToColor24;
  end;

  zoomScale:=FractalData.r*2/min(pixels24.width,pixels24.height);
  if (pixels24.width>=pixels24.height) then
  begin
    minx0:=FractalData.x0-FractalData.r*pixels24.width/pixels24.height;
    miny0:=FractalData.y0-FractalData.r;
  end
  else
  begin
    minx0:=FractalData.x0-FractalData.r;
    miny0:=FractalData.y0-FractalData.r*pixels24.height/pixels24.width;
  end;
  mx0:=FractalData.x0;
  my0:=FractalData.y0;
  sinCos(FractalData.seta*(PI/180.0),rSin,rCos);
  FractalCompiler:=WorkData.FractalCompiler;

  for yi:=0 to pixels24.Height-1 do
  begin
    if self.FisWantStop then exit;
    
    if (yi and 1=0) then
      y:=((pixels24.Height-1) div 2)-(yi div 2)
    else
      y:=((pixels24.Height-1) div 2)+(yi+1) div 2;
    if not getIsCanWork(y) then continue;

    errorColor.R:=0;
    errorColor.G:=0;
    errorColor.B:=0;
    PPixel:=PColor24Array(integer(pixels24.PPixelBegin)+pixels24.ByteWidth*y);
    PFractalColors:=PFractalColorArray(integer(fractalColors.PPixelBegin)+fractalColors.ByteWidth*y);
    
    if (not self.isReCalcFractalColor) then
    begin
      for x:=0 to pixels24.width-1 do
      begin
        curFractalColor.color0:=PFractalColors[x].color0*coloring.randColorK0+coloring.randColor0;
        curFractalColor.color1:=PFractalColors[x].color1*coloring.randColorK1+coloring.randColor1;
        curFractalColor.color2:=PFractalColors[x].color2*coloring.randColorK2+coloring.randColor2;
        PPixel[x]:=fractalColorToColor24(curFractalColor,errorColor);
        sleep(0);
        if self.FisWantStop then exit;
      end;
    end
    else
    begin
      y0:=miny0+y*zoomScale;
      x0:=minx0;
      for x:=0 to pixels24.width-1 do
      begin
        nx:= (x0-mx0)*rcos + (y0-my0)*rsin + mx0;
        ny:=-(x0-mx0)*rsin + (y0-my0)*rcos + my0;
        x0:=x0+zoomScale;
        FractalCompiler.CalcColor(nx,ny);
        curFractalColor:=FractalCompiler.fractalColor_var;
        if (isSaveCalcFractalColor) then
          PFractalColors[x]:=curFractalColor;

        curFractalColor.color0:=curFractalColor.color0*coloring.randColorK0+coloring.randColor0;
        curFractalColor.color1:=curFractalColor.color1*coloring.randColorK1+coloring.randColor1;
        curFractalColor.color2:=curFractalColor.color2*coloring.randColorK2+coloring.randColor2;
        PPixel[x]:=fractalColorToColor24(curFractalColor,errorColor); 
        sleep(0);
        if self.FisWantStop then exit;
      end;
    end;
    self.setIsWorked(y);
  end;
end;

{ TCalcFractalWorkData }

constructor TCalcFractalWorkData.Create();
begin
  inherited Create();
  FractalCompiler :=TFractalCompiler.Create();
end;

destructor TCalcFractalWorkData.Destroy;
begin
  FreeAndNil(FractalCompiler);
  inherited;
end;

{ TTempVarData }

constructor TTempVarData.Create(const _varName: string);
begin
  inherited Create();
  varName :=_varName;
end;

function TTempVarData.getVarAddressValue: string;
var
  address : longword;
begin
  address:=longword(@self.varValue);
  result:=intTostr(int64(address));
end;

end.
