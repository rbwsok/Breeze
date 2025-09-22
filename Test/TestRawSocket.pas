unit TestRawSocket;

interface

uses Winapi.Windows, System.SysUtils, TestUtil;

type
  TTestRawSocket = class
	  procedure testEchoIPv4;
	  procedure testSendToReceiveFromIPv4;
  public
    class procedure Test;
  end;

implementation

uses Breeze.Net.SocketAddress, Breeze.Net.RawSocket, Breeze.Net.SocketDefs;

{ TTestRawSocket }

class procedure TTestRawSocket.Test;
var
  testclass: TTestRawSocket;
begin
  TRTest.Comment('=============================================');
  TRTest.Comment('= TestRawSocket');
  TRTest.Comment('=============================================');

  testclass := TTestRawSocket.Create;
  try
	  testclass.testEchoIPv4;
	  testclass.testSendToReceiveFromIPv4;
  finally
    testclass.Free;
  end;
end;

procedure TTestRawSocket.testEchoIPv4;
var
  sa: TSocketAddress;
  rs: TRawSocket;
  n, shift: Integer;
  buffer: array [0..254] of Byte;
  ptr: PAnsiChar;
  s: AnsiString;
begin
  rs := TRawSocket.Create(TAddressFamily.IPv4);
  try
    sa := TSocketAddress.Create('127.0.0.1', 0);
    rs.connect(sa);

    n := rs.sendBytes(PAnsiChar('hello'), 5);
    assertTrue('testEchoIPv4 1', 5 = n);

    ptr := @buffer[0];

    n := rs.receiveBytes(@buffer[0], sizeof(buffer));
    shift := ((buffer[0] and $0F) * 4);
    inc(ptr, shift);

    assertTrue('testEchoIPv4 2', 5 = (n - shift));
    SetLength(s, 5);
    CopyMemory(@s[1], ptr, 5);
    assertTrue('testEchoIPv4 3', 'hello' = s);

    rs.close;
  finally
    rs.Free;
  end;
end;

procedure TTestRawSocket.testSendToReceiveFromIPv4;
var
  sa: TSocketAddress;
  rs: TRawSocket;
  n, shift: Integer;
  buffer: array [0..254] of Byte;
  ptr: PAnsiChar;
  s: AnsiString;
begin
  rs := TRawSocket.Create(TAddressFamily.IPv4);
  try
    n := rs.sendTo(PAnsiChar('hello'), 5, TSocketAddress.Create('127.0.0.1', 0));
    assertTrue('testSendToReceiveFromIPv4 1', n = 5);

    ptr := @buffer[0];
    n := rs.receiveFrom(@buffer[0], sizeof(buffer), sa);
    shift := ((buffer[0] and $0F) * 4);
    inc(ptr, shift);

    assertTrue('testSendToReceiveFromIPv4 2', (n - shift) = 5);
    SetLength(s, 5);
    CopyMemory(@s[1], ptr, 5);
    assertTrue('testSendToReceiveFromIPv4 3', 'hello' = s);
    rs.close;
  finally
    rs.Free;
  end;
end;

end.
