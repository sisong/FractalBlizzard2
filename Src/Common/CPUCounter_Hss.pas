unit CPUCounter_Hss;

          ////////////////////////////////////////////////////////
          //                                                    //
          //      CPU周期计算操作库  作者：侯思松   2002年。    //
          //                                                    //
          //                HouSisong@263.net                   //
          //                                                    //
          ////////////////////////////////////////////////////////

interface

uses SysUtils;

  {  CPU周期计算操作库 (不支持486及以下CPU) :
     获取当前CPU周期计数；或者获取当前时间计数
     利用两次调用的差值就可以知道代码段的执行时间，
     精度有可能达到CPU指令周期                     }
  function  CPUCycleCounter():int64 register;                   {获取当前CPU周期计数(CPU周期数)}
  {$IFDEF MSWINDOWS}
  function  CPUTimeCounter():Extended;                          {获取当前时间计数(us),利用CPU内部指令完成}
  function  CPUTimeCounterQPC():Extended;                       {获取当前时间计数(us),利用高性能计数器完成}
  function  GetCPUFrequency():int64;overload;                   {获得CPU的主频,准确快速}
  function  GetCPUFrequency(const dTime:integer):int64;overload;{获得CPU的主频,准确度与dTime成正比,dTime单位为ms}
  {$ENDIF}
  Procedure StopIf(const bValue:Boolean=True);                  {条件断点,调试时当参数为Ture时暂停程序，比如：StopIf(i>=100);}

  //============================================================================
{$IFDEF MSWINDOWS}
  function  CPUCallInitialize():Boolean;                        {初始化,成功返回True，失败返回False}


  //============================================================================

  {外部API调用}
  function QueryPerformanceCounter(var lpPerformanceCount: int64): LongBool; stdcall;
  {$EXTERNALSYM QueryPerformanceCounter}
  function QueryPerformanceFrequency(var lpFrequency: int64): LongBool; stdcall;
  {$EXTERNALSYM QueryPerformanceFrequency}
{$ENDIF}

  //============================================================================

implementation

  var CPUCycle0     :int64=0;    {CPU周期计数}
      QPCounter0    :int64=0;    {高性能计数器计数}
      QPCFrequency  :int64=0;    {高性能计数器频率}
      CPUFrequency  :int64=0;    {CPU频率}

Procedure StopIf(const bValue:Boolean=True);{调试时当参数为Ture时暂停程序，比如：DebugStop(i>=100);}
begin
  //{$IFDEF DEBUG}
    if bValue then
    begin
        asm
            int 3
        end;
    end;
  //{$ENDIF}
end;  { 压F8或F7到条件断点处 }

function CPUCycleCounter():int64 register;assembler;{获取当前CPU周期计数(CPU周期数)}
asm
    RDTSC         {eax,edx}
end;

{$IFDEF MSWINDOWS}
function CPUCallInitialize():Boolean;{初始化,成功返回True，失败返回False}
begin
  try
    QueryPerformanceCounter(QPCounter0);
    CPUCycle0:=CPUCycleCounter();
    QueryPerformanceFrequency(QPCFrequency);
    CPUFrequency:=GetCPUFrequency(100);{获得当前CPU的主频}
    result:=true;
  except
    result:=false;
  end;
end;

function CPUTimeCounter():Extended;{获取当前时间计数(us),利用CPU内部指令完成}
var t1:int64;
begin
    t1:=CPUCycleCounter();
    result:=(t1-CPUCycle0)*1000000.0/GetCPUFrequency(); //返回微秒
end;

function CPUTimeCounterQPC():Extended;{获取当前时间计数(us),利用高性能计数器完成}
var t1:int64;
begin
    QueryPerformanceCounter(t1);
    result:=(t1-QPCounter0)*1000000.0/QPCFrequency; //返回微秒
end;


function GetCPUFrequency():int64;overload;{获得CPU的主频,准确快速}
var t1,t2:int64;
    e1:Extended;
begin
    t2:=CPUCycleCounter();
    QueryPerformanceCounter(t1);
    e1:=(1.0*(t2-CPUCycle0)*(QPCFrequency)/(t1-QPCounter0));
    result:= trunc(e1);
end;

function GetCPUFrequency(const dTime:integer):int64;overload;{获得CPU的主频,准确度与dTime成正比,dTime单位为ms}
var t0,t1,t2,t3,t4,t5:int64;
    e1:Extended;
    tmpdTime:integer;
begin
    tmpdTime:=dTime;
    if tmpdTime<1 then tmpdTime:=1;
    QueryPerformanceCounter(t0);
    t0:=CPUCycleCounter();
    //
    t3:=QPCFrequency; //QueryPerformanceFrequency(t3);
    QueryPerformanceCounter(t2);
    t1:=CPUCycleCounter();
    sleep(tmpdTime);
    QueryPerformanceCounter(t4);
    t5:=CPUCycleCounter();
    //
    e1:=(t5*1.0-t1)*t3/(t4*1.0-t2);
    result:= trunc(e1);
end;
//==============================================================================

{外部API调用}
function QueryPerformanceCounter; external 'kernel32.dll' name 'QueryPerformanceCounter';
function QueryPerformanceFrequency; external 'kernel32.dll' name 'QueryPerformanceFrequency';

//==============================================================================

initialization
//初始化
begin
    CPUCallInitialize();
end;

{$ENDIF}

//==============================================================================

            {    CPU周期计算操作库  作者：侯思松   2002年。    }

{CPU周期计算操作库单元结束}

end.
