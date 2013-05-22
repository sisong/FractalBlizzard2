unit RunExe;

interface

  uses
    Forms, windows, Classes;

  {$EXTERNALSYM ShellExecute}
  function  ShellExecute(
    hwnd:HWND;
    lpOperation,lpFile,lpParameters,lpDirectory :LPCTSTR;
    nShowCmd:INTeger):LongWord; stdcall;


implementation


function ShellExecute; external 'shell32.dll' name 'ShellExecuteA';
    {ShellExecuteA(application.Handle, 'open', 'http://album.chinaren.com/album.php3?aname=user_housisong', '', '', SW_NORMAL);}

end.
