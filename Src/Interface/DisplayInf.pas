unit DisplayInf;

interface
uses
  Classes;

type
  TColorType = (ctRGB,ctHLS,ctYUV);
  function strToColorType(const str:string):TColorType;
  function colorTypeToStr(const colorType:TColorType):string;

  type
    TFractalColor=packed record
      color0 :double;
      color1 :double;
      color2 :double;
    end;
    type PFractalColor=^TFractalColor;
    type _TFractalColorArray =array [0..(MaxInt div sizeof(TFractalColor))-1] of TFractalColor;
    type PFractalColorArray=^_TFractalColorArray;

  TPixelsFractalColor = record
    PPixelBegin : PFractalColorArray;
    ByteWidth   : integer;
    Width  : integer;
    Height : integer;
  end;

  TFractalColoring=record
    randColorK0    : double;
    randColorK1    : double;
    randColorK2    : double;
    randColor0     : double;
    randColor1     : double;
    randColor2     : double;
    randColorType  : TColorType;
  end;
  
  type
    TColor24=packed record
      R :Byte;
      G :Byte;
      B :Byte;
    end;
    type _TColor24Array =array [0..(MaxInt div sizeof(TColor24))-1] of TColor24;
    type PColor24Array=^_TColor24Array;
    function toColor24(R,G,B:Byte):TColor24;
    
  type
    TPixels24 = record
      PPixelBegin : PColor24Array;
      ByteWidth   : integer;
      Width  : integer;
      Height : integer;
    end;
  procedure fillColor(const dst:TPixels24;color:TColor24);

  type
    IntFloat_16 = type integer; //定点数 后面16bit 表示小数位
    IntFloat_8 = type integer; //定点数 后面8bit 表示小数位
  type
    TRGBColor_Float_16 = record
      R : IntFloat_16;
      G : IntFloat_16;
      B : IntFloat_16;
    end;
  type
    THLSColor_Float_16 = record
      H : IntFloat_16;
      L : IntFloat_16;
      S : IntFloat_16;
    end;
  type
    TYUVColor_Float_16 = record
      Y : IntFloat_16;
      U : IntFloat_16;
      V : IntFloat_16;
    end;

function HLS_TO_RGB(const HLS:THLSColor_Float_16):TRGBColor_Float_16;//HLS到RGB转换
function YUV_TO_RGB(const YUV:TYUVColor_Float_16):TRGBColor_Float_16;//YUV到RGB转换


type TFractalColorToColor24Proc=function (const fractalColor:TFractalColor;var errorColor:TRGBColor_Float_16):TColor24;

function FractalColorRGBToColor24(const fractalColor:TFractalColor;var errorColor:TRGBColor_Float_16):TColor24;
function FractalColorHLSToColor24(const fractalColor:TFractalColor;var errorColor:TRGBColor_Float_16):TColor24;
function FractalColorYUVToColor24(const fractalColor:TFractalColor;var errorColor:TRGBColor_Float_16):TColor24;

implementation
uses
  SysUtils ;

  
function toColor24(R,G,B:Byte):TColor24;
begin
  result.R:=R;
  result.G:=G;
  result.B:=B;
end;

procedure fillColor(const dst:TPixels24;color:TColor24);
var
  x,y:integer;
  pLine: PColor24Array;
begin
  pLine:=dst.PPixelBegin;
  for y:=0 to dst.Height-1 do
  begin
    for x:=0 to dst.Width-1 do
    begin
      pLine[x]:=color;
    end;
    inc(PChar(pLine),dst.ByteWidth);
  end;
end;


const
  csRGB='RGB';
  csHLS='HLS';
  csYUV='YUV';
function strToColorType(const str:string):TColorType;
var
  value : string;
begin
  value:=uppercase(str);
  if (value=csYUV) then
    result:=ctYUV
  else if (value=csHLS) then
    result:=ctHLS
  else //value=csRGB then
    result:=ctRGB;
end;

function colorTypeToStr(const colorType:TColorType):string;
begin
  case colorType of
    ctYUV: result:=csYUV;
    ctHLS: result:=csHLS;
    else result:=csRGB;
  end;
end;
 
  function RGBBorder_Float16(c:IntFloat_16):IntFloat_16;
  begin
    if (c<0) then
      result:=0
    else if (c>=(1 shl 16)) then
      result:=(1 shl 16)-1
    else
      result:=c;
  end;

var
    //read only value : if index<0 then rerurn 0 elseif index>255 then return index else return index
  _RGB_Table :array [-2*256..2*256] of BYTE; //[0,0,...0,1,2...254,255,255,...255]
const
  RGB_Table:PByteArray=@_RGB_Table[0];

function HLS_TO_RGB(const HLS:THLSColor_Float_16):TRGBColor_Float_16;//HLS到RGB转换
const
  floatBit        = 8;
  m_one           = (1 shl (floatBit+8));

  function Hue_2_RGB(const n1,n2,h:IntFloat_16):IntFloat_16;
  var
    hue   : IntFloat_16;
  begin
    hue:=h;
    if hue>=m_one then
      hue:=hue-m_one
    else if hue<0 then
      hue:=hue+m_one;
    hue:=hue*6;

    if hue<m_one then
      result:=n1 + ( ((n2-n1) div 16)*hue div (m_one div 16) )
    else if hue<m_one*3 then
      result:=n2
    else if hue<m_one*4 then
      result:=n1 + ( ((n2-n1) div 16)*(m_one*4-hue) div (m_one div 16) )
    else
      result:=n1;
  end;

var
  m1,m2   : IntFloat_16;
  r,g,b   : IntFloat_16;
begin
  //Assert((HLS.H>=0)and(HLS.H<=m_One)and(HLS.L>=0)and(HLS.L<=m_One)and(HLS.S>=0)and(HLS.S<=m_One));
  if HLS.S=0 then
  begin
    r:=HLS.L;
    result.R:=r;
    result.G:=r;
    result.B:=r;
  end
  else
  begin
    if HLS.L<(m_one div 2) then
      m2:=HLS.L*((m_one+HLS.S) shr 3) div (m_one shr 3)
    else
      m2:=HLS.L+HLS.S-(HLS.L*(HLS.S shr 2) div (m_one shr 2));
    m1:=2*HLS.L-m2;

    r:=Hue_2_RGB(m1,m2,HLS.H+(m_one div 3));
    g:=Hue_2_RGB(m1,m2,HLS.H);
    b:=Hue_2_RGB(m1,m2,HLS.H-(m_one div 3));

    result.R:=RGBBorder_Float16(r);
    result.G:=RGBBorder_Float16(g);
    result.B:=RGBBorder_Float16(b);
  end;

end;

{
function RGB_TO_HLS(const RGB:TColor24):THLSColor_Float_16;//RGB到HLS转换
const
  floatBit        = 8;
  m_one           = (1 shl (floatBit+8));
  m_one_div_six   = (m_one div 6);
var
  m,n     : integer;
  delta   : integer;
  dadd    : integer;
begin
  //m:=max(r,max(g,b));
  //n:=min(r,min(g,b));
  if RGB.r>RGB.g then
  begin
    if RGB.r>RGB.b then
    begin
      m:=RGB.r;
      if RGB.g>RGB.b then n:=RGB.b else n:=RGB.g;
    end
    else
    begin
      m:=RGB.b;
      n:=RGB.g;
    end;
  end
  else
  begin
    if RGB.g>RGB.b then
    begin
      m:=RGB.g;
      if RGB.b>RGB.r then n:=RGB.r else n:=RGB.b;
    end
    else
    begin
      m:=RGB.b;
      n:=RGB.r;
    end;
  end;

  dadd:=m+n;
  result.L:=dadd shl (floatBit-1);

  if m=n then
  begin
    result.s:=0;
    result.h:=0;
  end
  else
  begin
    delta:=m-n;
    if result.L < (m_one div 2) then
      result.S := ((delta shl (floatBit+8))+result.L) div dadd
    else
      result.S := (delta shl (floatBit+8)) div ((2*255+1) - dadd);

    if RGB.R = m then
      result.H := ((RGB.G - RGB.B)*m_one_div_six) div (delta)
    else if RGB.G = m then
      result.H  := (m_one div 3) + ((RGB.B - RGB.R)*m_one_div_six) div (delta)
    else
      result.H := (m_one*2 div 3) + ((RGB.R - RGB.G)*m_one_div_six) div (delta);
    if result.H < 0 then
      result.H := result.H + m_One;
    //else if result.H>=m_One then
    //  result.H := result.H - m_One;
    //assert(result.H<=m_One);
  end;
end;
       }
       
//////////

var
  G_RGB_Table_IsSet :boolean=false;
  procedure G_Set_RGB_Table();
  var
    i: integer;
  begin
    if G_RGB_Table_IsSet then exit;
    for i:=low(_RGB_Table) to -1  do
        _RGB_Table[i]:=0;
    for i:=0 to 255  do
        _RGB_Table[i]:=i;
    for i:=255+1 to high(_RGB_Table)  do
        _RGB_Table[i]:=255;
    G_RGB_Table_IsSet:=true;
  end;

  function fColorToIColor(const fColor:double;const IColorMax:integer):integer;
  {var
    temp : integer;
  asm
      fld1            //1
      fadd   st,st    //2
      fld    fColor
      fabs
      fprem           //f mod 2
      fstp   st(1)
      mov    temp,IColorMax
      fld1
      fsubp  st(1),st
      fild   temp
      fmulp  st(1),st
      fabs
      fistp  result
  {begin
    result:=round(abs(fColor)*IColorMax) mod (IColorMax*2);
    result:=abs(result-IColorMax); }

  const
    half:double =0.5;
    exPI:double =PI;
  var
    temp : integer;
  asm
      fld    half
      fld    fColor
      fadd   st,st(1)
      fld    exPI
      fmulp  st(1),st
      fsin
      mov    temp,IColorMax
      fmul   st,st(1)
      faddp  st(1),st
      fild   temp
      fmulp  st(1),st
      fistp  result
  {begin
    result:=round((sin((fColor+0.5)*PI)*0.5+0.5)*IColorMax); }
  end;
  function fRoundColorToIColor(const fRoundColor:double;const IColorMax:integer):integer;
  var
    temp : integer;
  asm
      fld1            //1
      fld    fRoundColor
      fabs
      fprem           //f mod 1
      mov    temp,IColorMax
      fstp   st(1)
      fild   temp
      fmulp  st(1),st
      fistp  result
  {begin
    result:=round(abs(fColor)*IColorMax) mod (IColorMax);
    }
  end;

  function RGB48ToColor24(const rgb48: TRGBColor_Float_16;var errorColor:TRGBColor_Float_16):TColor24;
  var
    r,g,b :IntFloat_16;
  const
    cMap = (1 shl 16) div 255;
    cMapl = (1 shl 8);
  begin
    r:=(rgb48.R+errorColor.R);
    g:=(rgb48.G+errorColor.G);
    b:=(rgb48.B+errorColor.B);
    result.R:=RGB_Table[r div cMapl];
    result.G:=RGB_Table[g div cMapl];
    result.B:=RGB_Table[b div cMapl];
    errorColor.R:=r-(result.R*cMap);
    errorColor.G:=g-(result.G*cMap);
    errorColor.B:=b-(result.B*cMap);
  end;

function FractalColorRGBToColor24(const fractalColor:TFractalColor;var errorColor:TRGBColor_Float_16):TColor24;
var
  rgb48: TRGBColor_Float_16;
begin
  rgb48.r:=fColorToIColor(fractalColor.color0,(1 shl 16)-1);
  rgb48.g:=fColorToIColor(fractalColor.color1,(1 shl 16)-1);
  rgb48.b:=fColorToIColor(fractalColor.color2,(1 shl 16)-1);
  result:=RGB48ToColor24(rgb48,errorColor);
end;

function FractalColorHLSToColor24(const fractalColor:TFractalColor;var errorColor:TRGBColor_Float_16):TColor24;
const
  floatBit        = 8;
  m_one           = (1 shl (floatBit+8));
  function CvsH(color:double):IntFloat_16;
  begin
    result:=round(abs(color)*m_one) mod (m_one);
  end;
var
  hls : THLSColor_Float_16;
  rgb48: TRGBColor_Float_16;
begin
  hls.H:=fRoundColorToIColor(fractalColor.color0,m_one-1);
  hls.L:=fColorToIColor(fractalColor.color1,m_one-1);
  hls.S:=fColorToIColor(fractalColor.color2,m_one-1);
  rgb48:=HLS_TO_RGB(hls);
  result:=RGB48ToColor24(rgb48,errorColor);
end;


function YUV_TO_RGB(const YUV:TYUVColor_Float_16):TRGBColor_Float_16;
  //  R = Y + 1.14*V;
  //  G = Y - 0.39*U - 0.58*V;
  //  B = Y + 2.03*U;
var
  Y_14 : IntFloat_16;
begin
  Y_14:=YUV.Y*(1 shl 14);
  result.R:=RGBBorder_Float16((Y_14 + 18678*YUV.V) div (1 shl (14)));
  result.G:=RGBBorder_Float16((Y_14 -  6390*YUV.U - 9503*YUV.V) div (1 shl (14)));
  result.B:=RGBBorder_Float16((Y_14 + 33260*YUV.U) div (1 shl (14)));
end;


const csMaxU_16=28574;
const csMinU_16=(-9634-18940);
const csMaxV_16=40305;
const csMinV_16=(-33751-6554);
 {
function RGB_TO_YUV(const RGB:TColor24):TYUVColor_Float_16;
  //  Y =  0.299*R + 0.587*G + 0.114*B;
  //  U = -0.147*R - 0.289*G + 0.436*B;
  //  V =  0.615*R - 0.515*G - 0.100*B;
begin
  result.Y:=( 19595*rgb.R + 38470*rgb.G + 7471*rgb.B) shr 8;
  result.U:=(- 9634*rgb.R - 18940*rgb.G +28574*rgb.B) div (1 shl 8);
  result.V:=( 40305*rgb.R - 33751*rgb.G - 6554*rgb.B) div (1 shl 8);
end;  }

function FractalColorYUVToColor24(const fractalColor:TFractalColor;var errorColor:TRGBColor_Float_16):TColor24;
const
  csUr :double=(csMaxU_16-csMinU_16)*1.0/((csMaxU_16-csMinU_16)-1);
  csVr :double=(csMaxV_16-csMinV_16)*1.0/((csMaxV_16-csMinV_16)-1);
var
  yuv : TYUVColor_Float_16;
  rgb48: TRGBColor_Float_16;
begin
  yuv.y:=fColorToIColor(fractalColor.color0,(1 shl 16)-1);
  yuv.u:=fColorToIColor(fractalColor.color1*csUr,(csMaxU_16-csMinU_16)-1)+csMinU_16;
  yuv.v:=fColorToIColor(fractalColor.color2*csVr,(csMaxV_16-csMinV_16)-1)+csMinV_16;
  rgb48:=YUV_To_RGB(yuv);
  result:=RGB48ToColor24(rgb48,errorColor);
end;

initialization
  G_Set_RGB_Table();
end.
