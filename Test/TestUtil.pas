unit TestUtil;

interface

uses Winapi.Windows, System.SysUtils, System.SyncObjs, System.Math, System.Classes;

type

  TRTest = class
  private
    class var logcliticalsection: TCriticalSection;

    class var SuccessCount: NativeInt;
    class var FailedCount: NativeInt;

    class function Check(value: Boolean): String;

    class procedure ConsoleWriteLn(const value: String = '');
  public
    class procedure Init;
    class procedure ResultTest;

    class procedure Category(const name: String);

    class procedure Comment(const name: String = '');

    class function LockFile(const filename: String): THandle;
    class procedure UnlockFile(h: THandle);
  end;

  TRTestUtils = class
  public
    class function LoadFileToString(const filename: String): RawByteString;
  end;

  procedure assertTrue(const caption: String; value: Boolean);
  procedure assertException(const caption: String; proc: TProc);
  procedure assertNoException(const caption: String; proc: TProc);

implementation

{ TRTest }

class procedure TRTest.ConsoleWriteLn(const value: String);
begin
  logcliticalsection.Enter;
  WriteLn(value);
  logcliticalsection.Leave;
end;

class procedure TRTest.Category(const name: String);
begin
  ConsoleWriteLn;
  ConsoleWriteLn('= ' + name);
  ConsoleWriteLn;
end;

class function TRTest.Check(value: Boolean): String;
begin
  if value = false then
  begin
    result := 'false';
    inc(FailedCount);
  end
  else
  begin
    result := 'true';
    inc(SuccessCount);
  end;
end;

class procedure TRTest.Init;
begin
  AllocConsole;
  if TRTest.logcliticalsection = nil then
    TRTest.logcliticalsection := TCriticalSection.Create;

  SuccessCount := 0;
  FailedCount := 0;

  ConsoleWriteLn('========================');
  ConsoleWriteLn('= Begin Tests ==========');
  ConsoleWriteLn('========================');
end;

class function TRTest.LockFile(const filename: String): THandle;
begin
  if fileexists(filename) = false then
    raise Exception.CreateFmt('FileLock. файл не найден %s', [filename]);

  result := Winapi.Windows.CreateFileW(PChar(filename), GENERIC_READ, 0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
end;

class procedure TRTest.UnlockFile(h: THandle);
begin
  CloseHandle(h);
end;

class procedure TRTest.ResultTest;
begin
  ConsoleWriteLn('========================');
  ConsoleWriteLn('= End Tests ============');
  ConsoleWriteLn('========================');
  ConsoleWriteLn;
  ConsoleWriteLn('Sussess: ' + IntToStr(SuccessCount));
  ConsoleWriteLn('Failed: ' + IntToStr(FailedCount));
end;

class procedure TRTest.Comment(const name: String);
begin
  ConsoleWriteLn(name);
end;

procedure assertTrue(const caption: String; value: Boolean);
begin
  TRTest.ConsoleWriteLn(caption + ' - ' + TRTest.Check(value = true));
end;

procedure assertException(const caption: String; proc: TProc);
var
  isNOexception: Boolean;
begin
  isNOexception := false;
  try
    proc;
  except
    isNOexception := true;
  end;

  TRTest.ConsoleWriteLn(caption + ' - ' + TRTest.Check(isNOexception));
end;

procedure assertNoException(const caption: String; proc: TProc);
var
  isNOexception: Boolean;
begin
  isNOexception := true;
  try
    proc;
  except
    isNOexception := false;
  end;

  TRTest.ConsoleWriteLn(caption + ' - ' + TRTest.Check(isNOexception));
end;

{ TRTestUtils }

class function TRTestUtils.LoadFileToString(
  const filename: String): RawByteString;
var
  ms: TMemoryStream;
begin
  ms := TMemoryStream.Create;
  try
    ms.LoadFromFile(filename);
    SetLength(result, ms.Size);
    if ms.Size > 0 then
      CopyMemory(@result[1], ms.Memory, ms.Size);
  finally
    FreeAndNil(ms);
  end;
end;

initialization

finalization
  FreeAndNil(TRTest.logcliticalsection);
  FreeConsole;

end.
