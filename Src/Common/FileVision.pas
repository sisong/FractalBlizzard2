unit FileVision;

          ////////////////////////////////////////////////////////////////
          //                                                            //
          //          获取文件版本信息  作者：侯思松   2002年8          //
          //                                                            //
          //                     HouSisong@GMail.com                    //
          //                                                            //
          ////////////////////////////////////////////////////////////////

interface

uses SysUtils,windows;

type
  TFileInfo  =  packed  record
    CommpanyName:  string;
    FileDescription:  string;
    FileVersion:  string;
    InternalName:  string;
    LegalCopyright:  string;
    LegalTrademarks:  string;
    OriginalFileName:  string;
    ProductName:  string;
    ProductVersion:  string;
    Comments:  string;
    VsFixedFileInfo:VS_FIXEDFILEINFO;
    UserDefineValue:string;
  end;

  //得到文件版本信息
  function  GetFileVersionInfomation(const FileName: string;var info:TFileInfo;const UserDefine:string=''): boolean;
  //得到 版本标识
  function  getFileAllVerion(const FileName:string):string;overload;
  function  getFileAllVerion(const FileInfo:TFileInfo):string; overload;

  //得到 主版本号
  function  getFileMajorVerion(const AllVerion:string):string;
  //得到 次版本号
  function  getFileMinorVerion(const AllVerion:string):string;
  //得到 发布版本号
  function  getFileReleaseVerion(const AllVerion:string):string;
  //得到 build 次数
  function  getFileBuild(const AllVerion:string):string; 

  
implementation


function  GetFileVersionInfomation(const FileName: string;var info:TFileInfo;const UserDefine:string=''): boolean;
const  
   SFInfo=  '\StringFileInfo\';
var
   VersionInfo:  Pointer;  
   InfoSize:  DWORD;
   InfoPointer:  Pointer;  
   Translation:  Pointer;
   VersionValue:  string;
   unused:  DWORD;  
begin  
   unused := 0;
   Result := False;
   InfoSize := GetFileVersionInfoSize(pchar(FileName), unused);
   if  InfoSize>0  then
   begin  
       GetMem(VersionInfo,  InfoSize);
       Result  :=  GetFileVersionInfo(pchar(FileName), 0, InfoSize, VersionInfo);
       if  Result  then
       begin
           VerQueryValue(VersionInfo,  '\VarFileInfo\Translation',  Translation,  InfoSize);
           VersionValue  :=  SFInfo  +  IntToHex(LoWord(Longint(Translation^)),  4)  +
               IntToHex(HiWord(Longint(Translation^)),  4)  +  '\';
           VerQueryValue(VersionInfo,  pchar(VersionValue  +  'CompanyName'),  InfoPointer,  InfoSize);
           info.CommpanyName  :=  string(pchar(InfoPointer));
           VerQueryValue(VersionInfo,  pchar(VersionValue  +  'FileDescription'),  InfoPointer,  InfoSize);
           info.FileDescription  :=  string(pchar(InfoPointer));
           VerQueryValue(VersionInfo,  pchar(VersionValue  +  'FileVersion'),  InfoPointer,  InfoSize);
           info.FileVersion  :=  string(pchar(InfoPointer));
           VerQueryValue(VersionInfo,  pchar(VersionValue  +  'InternalName'),  InfoPointer,  InfoSize);
           info.InternalName  :=  string(pchar(InfoPointer));  
           VerQueryValue(VersionInfo,  pchar(VersionValue  +  'LegalCopyright'),  InfoPointer,  InfoSize);  
           info.LegalCopyright  :=  string(pchar(InfoPointer));  
           VerQueryValue(VersionInfo,  pchar(VersionValue  +  'LegalTrademarks'),  InfoPointer,  InfoSize);  
           info.LegalTrademarks  :=  string(pchar(InfoPointer));  
           VerQueryValue(VersionInfo,  pchar(VersionValue  +  'OriginalFileName'),  InfoPointer,  InfoSize);  
           info.OriginalFileName  :=  string(pchar(InfoPointer));  
           VerQueryValue(VersionInfo,  pchar(VersionValue  +  'ProductName'),  InfoPointer,  InfoSize);
           info.ProductName  :=  string(pchar(InfoPointer));  
           VerQueryValue(VersionInfo,  pchar(VersionValue  +  'ProductVersion'),  InfoPointer,  InfoSize);  
           info.ProductVersion  :=  string(pchar(InfoPointer));  
           VerQueryValue(VersionInfo,  pchar(VersionValue  +  'Comments'),  InfoPointer,  InfoSize);  
           info.Comments  :=  string(pchar(InfoPointer));  
           if  VerQueryValue(VersionInfo,  '\',  InfoPointer,  InfoSize)  then  
               info.VsFixedFileInfo  :=  TVSFixedFileInfo(InfoPointer^);  
           if  UserDefine  <>''  then  
           begin  
               if  VerQueryValue(VersionInfo,pchar(VersionValue+UserDefine),InfoPointer,InfoSize)  then  
                   info.UserDefineValue:=string(pchar(InfoPointer));
           end;  
       end;
       FreeMem(VersionInfo);
   end;  
end;

{
调用演示：  
 
procedure  TForm1.Button1Click(Sender:  TObject);  
var  
   info:  TFileInfo;  
begin  
   if  OpenDialog1.Execute  then  
   begin  
       if  GetFileVersionInfomation(opendialog1.FileName,  info,'WOW  Version')  then
       begin
           Listbox1.Items.Add(OpenDialog1.FileName);
           ListBox1.Items.Add('Comments:'  +  info.Comments);  
           ListBox1.Items.Add('CommpanyName:'  +  info.CommpanyName);  
           ListBox1.Items.Add('FileDescription:'  +  info.FileDescription);  
           ListBox1.Items.Add('FileVersion:'  +  info.FileVersion);  
           ListBox1.Items.Add('InternalName:'  +  info.InternalName);  
           ListBox1.Items.Add('LegalCopyright:'  +  info.LegalCopyright);  
           ListBox1.Items.Add('LegalTrademarks:'  +  info.LegalTrademarks);  
           ListBox1.Items.Add('OriginalFileName:'  +  info.OriginalFileName);  
           ListBox1.Items.Add('ProductName:'  +  info.ProductName);  
           ListBox1.Items.Add('ProductVersion:'  +  info.ProductVersion);  
           ListBox1.Items.Add('UserDefineValue:'  +  info.UserDefineValue);  
           if  boolean(info.VsFixedFileInfo.dwFileFlags  and  vs_FF_Debug)  then  
             listbox1.Items.Add('Debug:True')  
             else  
             ListBox1.Items.Add('Debug:False');  
           ListBox1.Items.Add('');
       end;  
   end;
end;
 }

function  getFileAllVerion(const FileName:string):string;overload; //得到 版本标识
var
  FileInfo: TFileInfo;
begin
  if  GetFileVersionInfomation(FileName,FileInfo,'WOW  Version')  then
  begin
    result:=FileInfo.FileVersion;
  end
  else
    result:='';
end;

function  getFileAllVerion(const FileInfo:TFileInfo):string; overload;//得到 版本标识
begin
  result:=FileInfo.FileVersion;
end;

function  getFileMajorVerion(const AllVerion:string):string; //得到 主版本号
var
  i,L : integer;
begin
  i:=1;
  L:=length(AllVerion);
  result:='';
  while (i<=L) do
  begin
    if not (AllVerion[i] in ['0'..'9',' '] )  then
    begin
      result:=copy(AllVerion,1,i-1);
      exit;
    end
    else if (i=L)then
    begin
      result:=AllVerion;
      exit;
    end;
    inc(i);
  end;
end;

function  getFileMinorVerion(const AllVerion:string):string; //得到 次版本号
var
  i,L : integer;
  iStar,n   : integer;
begin
  i:=1;
  n:=0;
  iStar:=1;
  L:=length(AllVerion);
  result:='';
  while (i<=L) do
  begin
    if not (AllVerion[i] in ['0'..'9',' '] )  then
    begin
      if n=1 then
      begin
        result:=copy(AllVerion,iStar+1,i-iStar-1);
        exit;
      end
      else
      begin
        inc(n);
        iStar:=i;
      end;
    end
    else if (i=L)then
    begin
      if n=1 then
      begin
        result:=copy(AllVerion,iStar+1,i-iStar);
      end;
      exit;
    end;
    inc(i);
  end;
end;

function  getFileReleaseVerion(const AllVerion:string):string; //得到 发布版本号
var
  i,L : integer;
  iStar,n   : integer;
begin
  i:=1;
  n:=0;        
  iStar:=1;
  L:=length(AllVerion);
  result:='';
  while (i<=L) do
  begin
    if not (AllVerion[i] in ['0'..'9',' '] )  then
    begin
      if n=2 then
      begin
        result:=copy(AllVerion,iStar+1,i-iStar-1);
        exit;
      end
      else
      begin
        inc(n);
        iStar:=i;
      end;
    end
    else if (i=L)then
    begin
      if n=2 then
      begin
        result:=copy(AllVerion,iStar+1,i-iStar);
      end;
      exit;
    end;
    inc(i);
  end;
end;

function  getFileBuild(const AllVerion:string):string; //得到 build 次数
var
  i,L : integer;
  iStar,n   : integer;
begin
  i:=1;
  n:=0;     
  iStar:=1;
  L:=length(AllVerion);
  result:='';
  while (i<=L) do
  begin
    if not (AllVerion[i] in ['0'..'9',' '] )  then
    begin
      if n=3 then
      begin
        result:=copy(AllVerion,iStar+1,i-iStar-1);
        exit;
      end
      else
      begin
        inc(n);
        iStar:=i;
      end;
    end
    else if (i=L)then
    begin
      if n=3 then
      begin
        result:=copy(AllVerion,iStar+1,i-iStar);
      end;
      exit;
    end;
    inc(i);
  end;
end;

//==============================================================================

{   获取文件版本信息  作者：侯思松   }

{ 获取文件版本信息单元结束 }    

end.
