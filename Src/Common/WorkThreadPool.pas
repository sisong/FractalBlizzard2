unit WorkThreadPool;
//用TWorkThread可以调用多核心进行并行执行
interface
uses
  Classes,SyncObjs;

type
  TPWorkData =pointer;
  TThreadCallBack=procedure(pData:TPWorkData);
  _TPWorkDataArray = array [0..(maxint div sizeof(TPWorkData))-1]of TPWorkData;
  TPWorkDataList =^_TPWorkDataArray;


type
  TWorkThreadPool=class;
  TThreadState=( thrStartup=0, thrReady,  thrBusy, thrTerminate, thrDeath );

  TWorkThread=class(TObject)
  private
    thread : TThread;
    state :TThreadState;
    func  :TThreadCallBack;
    pdata :TPWorkData;  //work data
    CriticalSection : TCriticalSection;
    CriticalSection_back : TCriticalSection;
    pool : TWorkThreadPool;
    procedure Execute;
  public
    constructor Create();
    destructor Destroy(); override;
    procedure run();
  end;


  TWorkThreadPool=class(TObject)
  private
    CriticalSections       : array of TCriticalSection;
    CriticalSections_back  : array of TCriticalSection;
    work_threads           : array of TWorkThread;
    isRunning              :boolean;
    procedure inti_threads(newthrcount:integer);
    procedure free_threads();
    procedure DoWorkEnd(thread_data :TWorkThread);
    procedure waitThreadState(wait_threadState:TThreadState;set_threadState:TThreadState);
  public
    constructor Create();
    destructor Destroy(); override;

    function best_work_count():integer;  //返回最佳工作分割数,现在的实现为返回CPU个数
    procedure work_execute(const work_proc:TThreadCallBack;word_data_list:TPWorkDataList;work_count:integer;isWait:boolean); //并行执行工作
    procedure waitStop();

    procedure work_execute_test(const work_proc:TThreadCallBack;word_data_list:TPWorkDataList;work_count:integer;isWait:boolean); //但单线程阻塞执行工作,用于测试
  end;

implementation
uses
  windows;


{ TWorkThread }

type
  TMyThread=class(TThread)
  private
    Fowner : TWorkThread;
  public
    constructor Create(owner:TWorkThread);
    procedure Execute; override;
  end;

  constructor TMyThread.Create(owner: TWorkThread);
  begin
    inherited Create(true);
    Fowner:=owner;
  end;
  procedure TMyThread.Execute;
  begin
    Fowner.Execute;
  end;

constructor TWorkThread.Create;
begin
  inherited Create();
  thread :=TMyThread.Create(self);
  thread.FreeOnTerminate:=true;
end;

destructor TWorkThread.Destroy;
begin
  inherited;
end;

procedure TWorkThread.Execute;
begin
  state := thrStartup;
  while(true) do
  begin
    CriticalSection.Enter();
    CriticalSection.Leave();
    if(state = thrTerminate) then
      break;

    state := thrBusy;
    if (Assigned(func)) then
      func(pdata)
    else
      Sleep(0);
    pool.DoWorkEnd(self);
  end;
  state := thrDeath;
end;

procedure TWorkThread.run;
begin
  self.thread.Resume;
end;


{ TWorkThreadPool }

function TWorkThreadPool.best_work_count: integer;
var
  SystemInfo : SYSTEM_INFO;
begin
  windows.GetSystemInfo(SystemInfo);
  result:=SystemInfo.dwNumberOfProcessors;
  if (result<1) then result:=1;
  //result:=1;
end;

procedure TWorkThreadPool.inti_threads(newthrcount:integer);
var
  i : integer;
begin
  setlength(work_threads,newthrcount);
  setlength(CriticalSections,newthrcount);
  setlength(CriticalSections_back,newthrcount);

  for i:=0 to newthrcount-1 do
  begin
    CriticalSections[i]:=TCriticalSection.Create();
    CriticalSections_back[i]:=TCriticalSection.Create();
    work_threads[i]:=TWorkThread.Create();

    work_threads[i].CriticalSection:=CriticalSections[i];
    work_threads[i].CriticalSection_back:=CriticalSections_back[i];
    CriticalSections[i].Enter();
    CriticalSections_back[i].Enter();
    work_threads[i].state := thrTerminate;
    work_threads[i].pool:=self;

    work_threads[i].run();//start run
  end;

  waitThreadState(thrStartup,thrReady);
end;

procedure TWorkThreadPool.free_threads;
var
  thr_count : integer;
  i : integer;
begin
  self.waitThreadState(thrReady,thrTerminate);
  thr_count:=length(work_threads);
  for i := 0 to thr_count-1 do
  begin
    CriticalSections[i].Leave();
    CriticalSections_back[i].Leave();
  end;

  self.waitThreadState(thrDeath,thrDeath);

  for i := 0 to thr_count-1 do
  begin
    work_threads[i].Free;
    CriticalSections[i].Free;
    CriticalSections_back[i].Free;
  end;
  work_threads:=nil;
  CriticalSections:=nil;
  CriticalSections_back:=nil;
end;

constructor TWorkThreadPool.Create;
begin
  inherited;
  inti_threads(0);
end;

destructor TWorkThreadPool.Destroy;
begin
  free_threads();
  inherited;
end;

procedure swapCriticalSection(var x:TCriticalSection;var y:TCriticalSection);
var
  tmp : TCriticalSection;
begin
  tmp:=x;
  x:=y;
  y:=tmp;
end;

procedure TWorkThreadPool.DoWorkEnd(thread_data: TWorkThread);
begin
  thread_data.func:=nil;
  swapCriticalSection(thread_data.CriticalSection,thread_data.CriticalSection_back);
  thread_data.state := thrReady;
end;

 
procedure TWorkThreadPool.work_execute(const work_proc: TThreadCallBack;
  word_data_list: TPWorkDataList; work_count: integer; isWait: boolean);
var
  i,thr_count : integer;
begin
  self.waitStop();

  if (work_count<=0) then exit;
  if (work_count>length(work_threads)) then
  begin
    self.free_threads();
    self.inti_threads(work_count);
  end;

  thr_count:=length(work_threads);
  for i := 0 to work_count-1 do
  begin
    work_threads[i].func  := work_proc;
    work_threads[i].pdata := word_data_list[i];
    work_threads[i].state := thrBusy;
  end;
  for i :=work_count to thr_count-1 do
  begin
    work_threads[i].func  := nil;
    work_threads[i].pdata := nil;
    work_threads[i].state := thrBusy;
  end;


  isRunning:=true;
  for i:=0 to thr_count-1 do
      CriticalSections[i].Leave();

  if (isWait) then waitStop();
end;

procedure TWorkThreadPool.work_execute_test(const work_proc: TThreadCallBack;
  word_data_list: TPWorkDataList; work_count: integer; isWait: boolean);
var
  i,thr_count : integer;
begin
  self.waitStop();
  if (work_count<=0) then exit;

  isRunning:=true;
  for i := 0 to work_count-1 do
  begin
    work_proc(word_data_list[i]);
  end;
  isRunning:=false;
end;


procedure TWorkThreadPool.waitThreadState(wait_threadState:TThreadState;set_threadState:TThreadState);
var
  i :integer;
begin
  for i := 0 to length(work_threads)-1 do
  begin
    while(true) do
    begin
      if (work_threads[i].state = wait_threadState) then
        break
      else
        Sleep(0);
    end;
    work_threads[i].state :=set_threadState;
  end;
end;


procedure TWorkThreadPool.waitStop;
var
  i :integer;
begin
  if (not isRunning) then exit;

  isRunning:=false;
  self.waitThreadState(thrReady,thrReady);
  for i := 0 to length(CriticalSections_back)-1 do
    swapCriticalSection(CriticalSections[i],CriticalSections_back[i]);
  for i := 0 to length(CriticalSections_back)-1 do
    CriticalSections_back[i].Enter();
end;                

end.
