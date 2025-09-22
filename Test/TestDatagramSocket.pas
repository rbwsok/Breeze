unit TestDatagramSocket;

interface

uses Winapi.Windows, Winapi.Winsock2, System.SysUtils, Breeze.Net.SocketDefs, TestUtil;

type
  TTestDatagramSocket = class
	  procedure testEcho;
	  procedure testMoveDatagramSocket;
	  procedure testEchoBuffer;
	  procedure testReceiveFromAvailable;
	  procedure testSendToReceiveFrom;
	  procedure testUnbound;
	  procedure testReuseAddressPortWildcard;
	  procedure testReuseAddressPortSpecific;
	  procedure testBroadcast;
	  procedure testGatherScatterFixed;
	  procedure testGatherScatterVariable;

    function getFreePort(family: TAddressFamily; port: Word): Word;
  public
    class procedure Test;
  end;

implementation

uses Breeze.Net.DatagramSocket, Breeze.Net.SocketAddress, UDPEchoServer;

{ TTestDatagramSocket }

class procedure TTestDatagramSocket.Test;
var
  testclass: TTestDatagramSocket;
begin
  TRTest.Comment('=============================================');
  TRTest.Comment('= TestDatagramSocket');
  TRTest.Comment('=============================================');

  testclass := TTestDatagramSocket.Create;
  try
    testclass.testEcho;
    testclass.testMoveDatagramSocket;
    testclass.testEchoBuffer;
    testclass.testReceiveFromAvailable;
    testclass.testSendToReceiveFrom;
    testclass.testUnbound;
    testclass.testReuseAddressPortWildcard;
    testclass.testReuseAddressPortSpecific;
    testclass.testBroadcast;
    testclass.testGatherScatterFixed;
    testclass.testGatherScatterVariable;
  finally
    testclass.Free;
  end;
end;

procedure TTestDatagramSocket.testBroadcast;
var
  echoServer: TUDPEchoServer;
	ss: TDatagramSocket;
  sa: TSocketAddress;
  n: Integer;
  buffer: array [0..255] of AnsiChar;
begin
  ZeroMemory(@buffer[0], sizeof(buffer));

  echoServer := nil;
	ss := nil;
  try
    echoServer := TUDPEchoServer.Create;
  	ss := TDatagramSocket.Create(TAddressFamily.IPv4);
    sa := TSocketAddress.Create('255.255.255.255', echoServer.port);
    // not all socket implementations fail if broadcast option is not set
    assertException('testBroadcast 1',
      procedure
      begin
        n := ss.sendTo(PAnsiChar('hello'), 5, sa);
      end
    );

    ss.setBroadcast(true);
    n := ss.sendTo(PAnsiChar('hello'), 5, sa);
    assertTrue('testBroadcast 2', n = 5);
     {
    n := ss.receiveBytes(@buffer[0], 5);
    assertTrue('testBroadcast 3', n, 5);
    assertTrue('testBroadcast 4', AnsiString(buffer), AnsiString('hello'));  }
    ss.close();
  finally
    ss.Free;
    echoServer.Free;
  end;
end;

procedure TTestDatagramSocket.testEcho;
var
  echoServer: TUDPEchoServer;
	ss: TDatagramSocket;
  buffer: array [0..255] of AnsiChar;
  sa: TSocketAddress;
  n: Integer;
begin
  ZeroMemory(@buffer[0], sizeof(buffer));

  echoServer := nil;
	ss := nil;
  try
    echoServer := TUDPEchoServer.Create;
    sa := TSocketAddress.Create('127.0.0.1', echoServer.port);
    ss := TDatagramSocket.Create;
    ss.connect(sa);
    n := ss.sendBytes(PAnsiChar('hello'), 5);
    assertTrue('testUDPEcho 1', n = 5);
    n := ss.receiveBytes(@buffer[0], sizeof(buffer));
    assertTrue('testUDPEcho 2', n = 5);
    assertTrue('testUDPEcho 3', AnsiString(buffer) = 'hello');
    ss.close;
  finally
    ss.Free;
    echoServer.Free;
  end;
end;

procedure TTestDatagramSocket.testEchoBuffer;
begin
{	UDPEchoServer echoServer;
	DatagramSocket ss;
	Buffer<char> buffer(0);
	ss.connect(SocketAddress("127.0.0.1", echoServer.port()));
	int n = ss.receiveBytes(buffer);
	assertTrue (n == 0);
	assertTrue (buffer.size() == 0);
	n = ss.sendBytes("hello", 5);
	assertTrue (n == 5);
	n = ss.receiveBytes(buffer);
	assertTrue (n == 5);
	assertTrue (buffer.size() == 5);
	assertTrue (std::string(buffer.begin(), n) == "hello");
	ss.close();}
end;

procedure TTestDatagramSocket.testGatherScatterFixed;
begin

end;

procedure TTestDatagramSocket.testGatherScatterVariable;
begin

end;

procedure TTestDatagramSocket.testMoveDatagramSocket;
{var
  echoServer: TUDPEchoServer;
  ss0, ss: TDatagramSocket;
  buffer: array [0..255] of AnsiChar;
  sa: TSocketAddress;
  n: Integer;}
begin
{	ss0 := TDatagramSocket.Create;

	ss0.connect(TSocketAddress.Create('127.0.0.1', echoServer.port));
	ss := TDatagramSocket.Create(ss0);
  assertTrue('testMoveDatagramSocket 1', ss0.isNull, false);
  n := ss.sendBytes(PAnsiChar('hello'), 5);
  assertTrue('testEcho 1', n, 5);
  n := ss.receiveBytes(@buffer[0], sizeof(buffer));
  assertTrue('testEcho 2', n, 5);
  assertTrue('testEcho 3', AnsiString(buffer), AnsiString('hello'));

	ZeroMemory(@buffer[0], sizeof(buffer));
	ss0 := ss;
	assertTrue (ss0.impl());
	assertTrue (ss.impl());
	assertTrue (ss0.impl() == ss.impl());
	ss = std::move(ss0);
	assertFalse (ss0.isNull());
	assertTrue (ss.impl());
	n = ss.sendBytes("hello", 5);
	assertTrue (n == 5);
	n = ss.receiveBytes(buffer, sizeof(buffer));
	assertTrue (n == 5);
	assertTrue (std::string(buffer, n) == "hello");
	ss.close();
	ss0.close();}

end;

procedure TTestDatagramSocket.testReceiveFromAvailable;
var
  echoServer: TUDPEchoServer;
	ss: TDatagramSocket;
  buffer: array [0..255] of AnsiChar;
  sa: TSocketAddress;
  n: Integer;
begin
  ZeroMemory(@buffer[0], sizeof(buffer));

  echoServer := nil;
	ss := nil;
  try
    echoServer := TUDPEchoServer.Create(TSocketAddress.Create('127.0.0.1', 0));
    ss := TDatagramSocket.Create(TAddressFamily.Ipv4);
    n := ss.sendTo(PAnsiChar('hello'), 5, TSocketAddress.Create('127.0.0.1', echoServer.port));
    assertTrue('testReceiveFromAvailable 1', n = 5);
    sleep(100);
    assertTrue('testReceiveFromAvailable 2', ss.available = 5);
    n := ss.receiveFrom(@buffer[0], sizeof(buffer), sa);

    assertTrue('testReceiveFromAvailable 3', sa.host = echoServer.address.host);
    assertTrue('testReceiveFromAvailable 4', sa.port = echoServer.port);
    assertTrue('testReceiveFromAvailable 5', n = 5);
    assertTrue('testReceiveFromAvailable 6', AnsiString(buffer) = 'hello');
    ss.close;
  finally
    ss.Free;
    echoServer.Free;
  end;
end;

procedure TTestDatagramSocket.testReuseAddressPortSpecific;
var
  port: Word;
  ds1, ds2, ds3: TDatagramSocket;
begin
 	port := getFreePort(TAddressFamily.IPv4, 1234);
  assertTrue('testReuseAddressPortSpecific 1', port >= 1234);

	// reuse
  ds1 := TDatagramSocket.Create(TAddressFamily.IPv4);
	ds1.bind(TSocketAddress.Create(port), true);
  assertTrue('testReuseAddressPortSpecific 2', ds1.getReuseAddress);
  ds2 := TDatagramSocket.Create;
	ds2.bind(TSocketAddress.Create('127.0.0.1', port), true);
  assertTrue('testReuseAddressPortSpecific 3', ds2.getReuseAddress);
  ds3 := TDatagramSocket.Create(TAddressFamily.IPv6);
	ds3.bind6(TSocketAddress.Create('::1', port), true, true, false);
  assertTrue('testReuseAddressPortSpecific 4', ds3.getReuseAddress);
  ds1.Free;
  ds2.Free;
  ds3.Free;

	// not reuse
  ds1 := TDatagramSocket.Create(TAddressFamily.IPv4);
  assertException('testReuseAddressPortSpecific 5',
    procedure
    begin
    	ds1.bind(TSocketAddress.Create('0.0.0.0', port), false);
    end
  );
  assertTrue('testReuseAddressPortSpecific 6', not ds1.getReuseAddress);
  ds1.Free;

  ds1 := TDatagramSocket.Create(TAddressFamily.IPv6);
  assertException('testReuseAddressPortSpecific 7',
    procedure
    begin
    	ds1.bind6(TSocketAddress.Create('::', port), false, false, true);
    end
  );
  assertTrue('testReuseAddressPortSpecific 8', not ds1.getReuseAddress);
  ds1.Free;
end;

procedure TTestDatagramSocket.testReuseAddressPortWildcard;
var
  port, port6: Word;
  ds1, ds2, ds3: TDatagramSocket;
begin
 	port := getFreePort(TAddressFamily.IPv4, 1234);
	port6 := getFreePort(TAddressFamily.IPv6, 1234);
  assertTrue('testReuseAddressPortWildcard 1', port >= 1234);
  assertTrue('testReuseAddressPortWildcard 2', port6 >= 1234);
  // reuse
  ds1 := TDatagramSocket.Create(TAddressFamily.IPv4);
	ds1.bind(TSocketAddress.Create(port), true);
  assertTrue('testReuseAddressPortWildcard 3', ds1.getReuseAddress);
  ds2 := TDatagramSocket.Create;
	ds2.bind(TSocketAddress.Create(port), true);
  assertTrue('testReuseAddressPortWildcard 4', ds2.getReuseAddress);
  ds3 := TDatagramSocket.Create(TAddressFamily.IPv6);
	ds3.bind6(TSocketAddress.Create(TAddressFamily.IPv6, port6), true, true, false);
  assertTrue('testReuseAddressPortWildcard 5', ds3.getReuseAddress);
  ds1.Free;
  ds2.Free;
  ds3.Free;
  ds1 := TDatagramSocket.Create(TAddressFamily.IPv6);
	ds1.bind6(TSocketAddress.Create(TAddressFamily.IPv6, port6), true, true, false);
  assertTrue('testReuseAddressPortWildcard 6', ds1.getReuseAddress);
  ds2 := TDatagramSocket.Create;
	ds2.bind6(TSocketAddress.Create(TAddressFamily.IPv6, port6), true, true, false);
  assertTrue('testReuseAddressPortWildcard 7', ds2.getReuseAddress);
  ds3 := TDatagramSocket.Create;
	ds3.bind(TSocketAddress.Create(port), true, true);
  assertTrue('testReuseAddressPortWildcard 8', ds3.getReuseAddress);
  ds1.Free;
  ds2.Free;
  ds3.Free;
  ds1 := TDatagramSocket.Create(TAddressFamily.IPv6);
	ds1.bind6(TSocketAddress.Create(TAddressFamily.IPv6, port), true, true, true);
  assertTrue('testReuseAddressPortWildcard 9', ds1.getReuseAddress);
  ds2 := TDatagramSocket.Create;
	ds2.bind6(TSocketAddress.Create(TAddressFamily.IPv6, port), true, true, true);
  assertTrue('testReuseAddressPortWildcard 10', ds2.getReuseAddress);
  ds1.Free;
  ds2.Free;
	// not reuse
  ds1 := TDatagramSocket.Create(TAddressFamily.IPv4);
  assertException('testReuseAddressPortWildcard 11',
    procedure
    begin
    	ds1.bind(TSocketAddress.Create(port), false);
    end
  );
  assertTrue('testReuseAddressPortWildcard 12', not ds1.getReuseAddress);
  ds1.Free;
  ds1 := TDatagramSocket.Create(TAddressFamily.IPv6);
  assertException('testReuseAddressPortWildcard 13',
    procedure
    begin
    	ds1.bind6(TSocketAddress.Create(TAddressFamily.IPv6, port), false, false, true);
    end
  );
  assertTrue('testReuseAddressPortWildcard 14', not ds1.getReuseAddress);
  ds1.Free;
end;

procedure TTestDatagramSocket.testSendToReceiveFrom;
var
  echoServer: TUDPEchoServer;
	ss: TDatagramSocket;
  buffer: array [0..255] of AnsiChar;
  sa: TSocketAddress;
  n: Integer;
begin
  ZeroMemory(@buffer[0], sizeof(buffer));

  echoServer := nil;
	ss := nil;
  try
    echoServer := TUDPEchoServer.Create(TSocketAddress.Create('127.0.0.1', 0));
    ss := TDatagramSocket.Create(TAddressFamily.Ipv4);
    n := ss.sendTo(PAnsiChar('hello'), 5, TSocketAddress.Create('127.0.0.1', echoServer.port));
    assertTrue('testReceiveFromAvailable 1', n = 5);
    n := ss.receiveFrom(@buffer[0], sizeof(buffer), sa);
    assertTrue('testReceiveFromAvailable 2', sa.host = echoServer.address.host);
    assertTrue('testReceiveFromAvailable 3', sa.port = echoServer.port);
    assertTrue('testReceiveFromAvailable 4', n = 5);
    assertTrue('testReceiveFromAvailable 5', AnsiString(buffer) = 'hello');
    ss.close;
  finally
    ss.Free;
    echoServer.Free;
  end;
end;

procedure TTestDatagramSocket.testUnbound;
var
  echoServer: TUDPEchoServer;
	ss: TDatagramSocket;
  buffer: array [0..255] of AnsiChar;
  n: Integer;
begin
  ZeroMemory(@buffer[0], sizeof(buffer));

  echoServer := nil;
	ss := nil;
  try
    echoServer := TUDPEchoServer.Create();
    ss := TDatagramSocket.Create;
    ss.connect(TSocketAddress.Create('127.0.0.1', echoServer.port));
    n := ss.sendBytes(PAnsiChar('hello'), 5);
    assertTrue('testReceiveFromAvailable 1', n = 5);
    n := ss.receiveBytes(@buffer[0], sizeof(buffer));
    assertTrue('testReceiveFromAvailable 2', n = 5);
    assertTrue('testReceiveFromAvailable 3', AnsiString(buffer) = 'hello');
    ss.close;
  finally
    ss.Free;
    echoServer.Free;
  end;
end;

function TTestDatagramSocket.getFreePort(family: TAddressFamily; port: Word): Word;
var
	failed: Boolean;
	sock: TDatagramSocket;
  sa: TSocketAddress;
begin
	dec(port);
	sock := TDatagramSocket.Create(family);
  try
    while True do
    begin
      failed := false;
      inc(port);
      sa := TSocketAddress.Create(family, port);
      try
        sock.bind(sa, false);
      except
        failed := true;
      end;

      if failed and (sock.lastError = WSAEADDRINUSE) then
        break;

      sock.close;
    end;
  finally
    sock.Free;
  end;

	result := port;
end;

end.
