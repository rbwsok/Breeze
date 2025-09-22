unit TestSocket;

interface

uses System.SysUtils, Winapi.Windows, Winapi.Winsock2, System.Win.Crtl, TestUtil;

type

  TTestSocket = class
  private
    procedure testEcho;
    procedure testPoll;
    procedure testAvailable;
    procedure testConnectRefused;
    procedure testNonBlocking;
    procedure testPeek;
    procedure testAddress;
    procedure testAssign;
    procedure testBufferSize;
    procedure testOptions;
    procedure testTimeout;
    procedure testDialogSocket;
  public
    class procedure Test;
  end;

implementation

uses Breeze.Net.IPAddress, Breeze.Net.SocketDefs, Breeze.Net.SocketAddress, TCPEchoServer, Breeze.Net.StreamSocket, Breeze.Net.ServerSocket, Breeze.Net.DatagramSocket,
Breeze.Net.DialogSocket;

{ TTestSocket }

class procedure TTestSocket.Test;
var
  testclass: TTestSocket;
begin
  TRTest.Comment('=============================================');
  TRTest.Comment('= TestSocket');
  TRTest.Comment('=============================================');

  testclass := TTestSocket.Create;
  try
    testclass.testEcho;
    testclass.testPeek;
    testclass.testPoll;
    testclass.testAvailable;
    testclass.testConnectRefused;
    testclass.testNonBlocking;
    testclass.testAddress;
    testclass.testAssign;
    testclass.testBufferSize;
    testclass.testOptions;
    testclass.testTimeout;
    testclass.testDialogSocket;
  finally
    testclass.Free;
  end;
end;

procedure TTestSocket.testEcho;
var
  echoServer: TTCPEchoServer;
	ss: TStreamSocket;
  buffer: array [0..255] of AnsiChar;
  n: Integer;
begin
  ZeroMemory(@buffer[0], sizeof(buffer));

  echoServer := nil;
	ss := nil;
  try
    echoServer := TTCPEchoServer.Create;
    ss := TStreamSocket.Create;
    ss.connect(TSocketAddress.Create('127.0.0.1', echoServer.port));
    n := ss.sendBytes(PAnsiChar('hello'), 5);
    assertTrue('testTCPEcho 1', n = 5);
    n := ss.receiveBytes(@buffer[0], sizeof(buffer));
    assertTrue('testTCPEcho 2', n = 5);
    assertTrue('testTCPEcho 3', AnsiString(buffer) = 'hello');
    ss.close;
  finally
    ss.Free;
    echoServer.Free;
  end;
end;

procedure TTestSocket.testPoll;
var
  echoServer: TTCPEchoServer;
	ss: TStreamSocket;
  buffer: array [0..255] of AnsiChar;
  n: Integer;
begin
  ZeroMemory(@buffer[0], sizeof(buffer));

  echoServer := nil;
	ss := nil;
  try
    echoServer := TTCPEchoServer.Create;
    ss := TStreamSocket.Create;
    ss.connect(TSocketAddress.Create('127.0.0.1', echoServer.port));

    assertTrue('testPoll 1', not ss.poll(1000, TPollMode.SELECT_READ));
    assertTrue('testPoll 2', ss.poll(1000, TPollMode.SELECT_WRITE));
    ss.sendBytes(PAnsiChar('hello'), 5);
    assertTrue('testPoll 3', ss.poll(1000, TPollMode.SELECT_READ));
    n := ss.receiveBytes(@buffer[0], sizeof(buffer));
    assertTrue('testPoll 4', n = 5);
    assertTrue('testPoll 5', AnsiString(buffer) ='hello');

    ss.close;
  finally
    ss.Free;
    echoServer.Free;
  end;
end;

procedure TTestSocket.testAvailable;
var
  echoServer: TTCPEchoServer;
	ss: TStreamSocket;
  buffer: array [0..255] of AnsiChar;
  n: Integer;
begin
  ZeroMemory(@buffer[0], sizeof(buffer));

  echoServer := nil;
	ss := nil;
  try
    echoServer := TTCPEchoServer.Create;
    ss := TStreamSocket.Create;
    ss.connect(TSocketAddress.Create('127.0.0.1', echoServer.port));
    n := ss.sendBytes(PAnsiChar('hello'), 5);
    assertTrue('testAvailable 1', n = 5);
    assertTrue('testAvailable 2', ss.poll(1000, TPollMode.SELECT_READ));
    n := ss.available;
    assertTrue('testAvailable 3', (n > 0) and (n <= 5));
    n := ss.receiveBytes(@buffer[0], sizeof(buffer));
    assertTrue('testAvailable 4', n = 5);
    assertTrue('testAvailable 5', AnsiString(buffer) = 'hello');
    ss.close;
  finally
    ss.Free;
    echoServer.Free;
  end;
end;

procedure TTestSocket.testConnectRefused;
var
  serv: TServerSocket;
  port: Word;
	ss: TStreamSocket;
  sa: TSocketAddress;
begin
  serv := TServerSocket.Create;
  try
    sa.Create;
    serv.bind(sa);
    serv.listen;
    port := serv.address.port;
    serv.close;
    ss := TStreamSocket.Create;
    try
      assertException('testConnectRefused 1',
        procedure
        begin
          ss.connect(TSocketAddress.Create('127.0.0.1', port));
        end
      );
    finally
      ss.Free;
    end;
  finally
    serv.Free;
  end;
end;

procedure TTestSocket.testNonBlocking;
var
  echoServer: TTCPEchoServer;
	ss: TStreamSocket;
  buffer: array [0..255] of AnsiChar;
  n: Integer;
begin
  ZeroMemory(@buffer[0], sizeof(buffer));

  echoServer := nil;
	ss := nil;
  try
    echoServer := TTCPEchoServer.Create;
    ss := TStreamSocket.Create;
    ss.connect(TSocketAddress.Create('127.0.0.1', echoServer.port));
    ss.setBlocking(false);
    assertTrue('testNonBlocking 1', ss.poll(1000, TPollMode.SELECT_WRITE));
    n := ss.sendBytes(PAnsiChar('hello'), 5);
    assertTrue('testNonBlocking 2', n = 5);
    assertTrue('testNonBlocking 3', ss.poll(1000, TPollMode.SELECT_READ));
    n := ss.receiveBytes(@buffer[0], sizeof(buffer));
    assertTrue('testNonBlocking 4', n = 5);
    assertTrue('testNonBlocking 5', AnsiString(buffer) = 'hello');
    ss.close;
  finally
    ss.Free;
    echoServer.Free;
  end;
end;

procedure TTestSocket.testPeek;
var
  echoServer: TTCPEchoServer;
	ss: TStreamSocket;
  buffer: array [0..255] of AnsiChar;
  n: Integer;
begin
  ZeroMemory(@buffer[0], sizeof(buffer));

  echoServer := nil;
	ss := nil;
  try
    echoServer := TTCPEchoServer.Create;
    ss := TStreamSocket.Create;
    ss.connect(TSocketAddress.Create('127.0.0.1', echoServer.port));
    n := ss.sendBytes(PAnsiChar('hello world!'), 13);
    assertTrue('testPeek 1', n = 13);
    n := ss.receiveBytes(@buffer[0], 5, MSG_PEEK);
    assertTrue('testPeek 2', n = 5);
    assertTrue('testPeek 3', AnsiString(buffer) = 'hello');
    n := ss.receiveBytes(@buffer[0], sizeof(buffer), MSG_PEEK);
    assertTrue('testPeek 4', n = 13);
    assertTrue('testPeek 5', AnsiString(buffer) = 'hello world!');
    n := ss.receiveBytes(@buffer[0], sizeof(buffer));
    assertTrue('testPeek 6', n = 13);
    assertTrue('testPeek 7', AnsiString(buffer) = 'hello world!');
    ss.close;
  finally
    ss.Free;
    echoServer.Free;
  end;
end;

procedure TTestSocket.testAddress;
var
  serv: TServerSocket;
  ss, css: TStreamSocket;
  sa: TSocketAddress;
begin
  serv := nil;
  ss := nil;
  css := nil;
  try
    serv := TServerSocket.Create;
    ss := TStreamSocket.Create;

    sa.Create;
    serv.bind(sa);
    serv.listen;
    ss.connect(TSocketAddress.Create('127.0.0.1', serv.address.port));
    css := serv.acceptConnection;
    assertTrue('testAddress 1', css.peerAddress.host = ss.address.host);
    assertTrue('testAddress 2', css.peerAddress.port = ss.address.port);
  finally
    css.Free;
    serv.Free;
    ss.Free;
  end;
end;

procedure TTestSocket.testAssign;
var
	serv1, serv2, serv3: TServerSocket;
	ss1, ss2, ss3: TStreamSocket;
	ds1, ds2, ds3: TDatagramSocket;
begin
	serv1 := nil;
  serv2 := nil;
	ss1 := nil;
  ss2 := nil;
	ds1 := nil;
	ds2 := nil;
  try
    serv1 := TServerSocket.Create;
    serv2 := TServerSocket.Create;
    ss1 := TStreamSocket.Create;
    ss2 := TStreamSocket.Create;
    ds1 := TDatagramSocket.Create;
    ds2 := TDatagramSocket.Create;

    assertTrue('testAssign 1', ss1 <> ss2);

    assertException('testAssign 2',
    procedure
      begin
        ss1.Assign(serv1);
      end
    );

    assertException('testAssign 3',
    procedure
      begin
        serv1.Assign(ss1);
      end
    );

    assertException('testAssign 4',
    procedure
      begin
        ds1.Assign(serv1);
      end
    );

    assertException('testAssign 5',
    procedure
      begin
        serv1.Assign(ds1);
      end
    );

    assertException('testAssign 4',
    procedure
      begin
        ds1.Assign(ss1);
      end
    );

    assertException('testAssign 5',
    procedure
      begin
        ss1.Assign(ds1);
      end
    );

    assertNoException('testAssign 6',
    procedure
      begin
        ss1.Assign(ss2);
      end
    );

    assertNoException('testAssign 7',
    procedure
      begin
        ds1.Assign(ds2);
      end
    );

    assertNoException('testAssign 8',
    procedure
      begin
        serv1.Assign(serv2);
      end
    );

    assertNoException('testAssign 9',
    procedure
      begin
        serv3 := TServerSocket.Create(serv1);
      end
    );
    serv3.Free;

    assertException('testAssign 10',
    procedure
      begin
        serv3 := TServerSocket.Create(ss1);
      end
    );

    assertException('testAssign 11',
    procedure
      begin
        serv3 := TServerSocket.Create(ds1);
      end
    );

    assertNoException('testAssign 12',
    procedure
      begin
        ss3 := TStreamSocket.Create(ss1);
      end
    );
    ss3.Free;

    assertException('testAssign 13',
    procedure
      begin
        ss3 := TStreamSocket.Create(serv1);
      end
    );

    assertException('testAssign 14',
    procedure
      begin
        ss3 := TStreamSocket.Create(ds1);
      end
    );

    assertNoException('testAssign 15',
    procedure
      begin
        ds3 := TDatagramSocket.Create(ds1);
      end
    );
    ds3.Free;

    assertException('testAssign 16',
    procedure
      begin
        ds3 := TDatagramSocket.Create(serv1);
      end
    );

    assertException('testAssign 17',
    procedure
      begin
        ds3 := TDatagramSocket.Create(ss1);
      end
    );

  finally
    ss1.Free;
    ss2.Free;
    ds1.Free;
    ds2.Free;
    serv1.Free;
    serv2.Free;
  end;
end;

procedure TTestSocket.testBufferSize;
var
	ss: TStreamSocket;
  sa: TSocketAddress;
	osz: Integer;
	rsz: Integer;
  asz: Integer;
begin
  sa := TSocketAddress.Create('127.0.0.1', 1234);
  ss := TStreamSocket.Create(sa.family);
  try
	  osz := ss.getSendBufferSize;
	  rsz := 32000;
  	ss.setSendBufferSize(rsz);
	  asz := ss.getSendBufferSize();
    TRTest.Comment('original send buffer size: ' + IntToStr(osz));
    TRTest.Comment('requested send buffer size: ' + IntToStr(rsz));
    TRTest.Comment('actual send buffer size: ' + IntToStr(asz));

  	osz := ss.getReceiveBufferSize();
  	ss.setReceiveBufferSize(rsz);
  	asz := ss.getReceiveBufferSize();
    TRTest.Comment('original recv buffer size: ' + IntToStr(osz));
    TRTest.Comment('requested recv buffer size: ' + IntToStr(rsz));
    TRTest.Comment('actual recv buffer size: ' + IntToStr(asz));
  finally
    ss.Free;
  end;
end;

procedure TTestSocket.testOptions;
var
  echoServer: TTCPEchoServer;
	ss: TStreamSocket;
	f: Boolean;
	t: Integer;
begin
  echoServer := nil;
	ss := nil;
  try
    echoServer := TTCPEchoServer.Create;
    ss := TStreamSocket.Create;
    ss.connect(TSocketAddress.Create('127.0.0.1', echoServer.port));

    ss.setLinger(true, 20);
  	ss.getLinger(f, t);
    assertTrue('testOptions 1', f and (t = 20));
    ss.setLinger(false, 0);
  	ss.getLinger(f, t);
    assertTrue('testOptions 2', not f);

  	ss.setNoDelay(true);
    assertTrue('testOptions 3', ss.getNoDelay);
  	ss.setNoDelay(false);
    assertTrue('testOptions 4', not ss.getNoDelay);

	  ss.setKeepAlive(true);
	  assertTrue('testOptions 5', ss.getKeepAlive);
  	ss.setKeepAlive(false);
    assertTrue('testOptions 6', not ss.getKeepAlive);

  	ss.setOOBInline(true);
	  assertTrue('testOptions 7', ss.getOOBInline);
  	ss.setOOBInline(false);
	  assertTrue('testOptions 8', not ss.getOOBInline);

    ss.close;
  finally
    ss.Free;
    echoServer.Free;
  end;
end;

procedure TTestSocket.testTimeout;
var
	ss: TStreamSocket;
  sa: TSocketAddress;
	timeout0, timeout1, timeout: Cardinal;
begin
  sa := TSocketAddress.Create('127.0.0.1', 1234);
  ss := TStreamSocket.Create(sa.family);
  try
	  timeout0 := ss.getReceiveTimeout;
	  timeout := 250000;
  	ss.setReceiveTimeout(timeout);
    timeout1 := ss.getReceiveTimeout;
    TRTest.Comment('original receive timeout: ' + IntToStr(timeout0));
    TRTest.Comment('requested receive timeout: ' + IntToStr(timeout));
    TRTest.Comment('actual receive timeout: ' + IntToStr(timeout1));

	  timeout0 := ss.getSendTimeout;
  	ss.setReceiveTimeout(timeout);
    timeout1 := ss.getReceiveTimeout;
    TRTest.Comment('original send timeout: ' + IntToStr(timeout0));
    TRTest.Comment('requested send timeout: ' + IntToStr(timeout));
    TRTest.Comment('actual send timeout: ' + IntToStr(timeout1));
  finally
    ss.Free;
  end;
end;

procedure TTestSocket.testDialogSocket;
var
  echoServer: TTCPEchoServer;
  ds: TDialogSocket;
  str: AnsiString;
  n, status: Integer;
  buffer: array [0..15] of AnsiChar;
begin
  echoServer := nil;
  ds := nil;
  try
    echoServer := TTCPEchoServer.Create;
    ds := TDialogSocket.Create;

    ds.connect(TSocketAddress.Create('127.0.0.1', echoServer.port));

    ds.sendMessage('Hello, world!');

    ds.receiveMessage(str);
    assertTrue('testDialogSocket 1', str = 'Hello, world!');

    ds.sendString('Hello, World!'#10);
    ds.receiveMessage(str);
    assertTrue('testDialogSocket 2', str = 'Hello, World!');

    ds.sendMessage('EHLO', 'appinf.com');
    ds.receiveMessage(str);
    assertTrue('testDialogSocket 3', str = 'EHLO appinf.com');

    ds.sendMessage('PUT', 'local.txt', 'remote.txt');
    ds.receiveMessage(str);
    assertTrue('testDialogSocket 4', str = 'PUT local.txt remote.txt');

    ds.sendMessage('220 Hello, world!');
    status := ds.receiveStatusMessage(str);
    assertTrue('testDialogSocket 5', status = 220);
    assertTrue('testDialogSocket 6', str = '220 Hello, world!');

    ds.sendString('220-line1'#13#10'220 line2'#13#10);
    status := ds.receiveStatusMessage(str);
    assertTrue('testDialogSocket 7', status = 220);
    assertTrue('testDialogSocket 8', str = '220-line1'#10'220 line2');

    ds.sendString('220-line1'#13#10'line2'#13#10'220 line3'#13#10);
    status := ds.receiveStatusMessage(str);
    assertTrue('testDialogSocket 9', status = 220);
    assertTrue('testDialogSocket 10', str = '220-line1'#10'line2'#10'220 line3');

    ds.sendMessage('Hello, world!');
    status := ds.receiveStatusMessage(str);
    assertTrue('testDialogSocket 11', status = 0);
    assertTrue('testDialogSocket 12', str = 'Hello, world!');

    ds.sendString('Header'#10'More Bytes');
    status := ds.receiveStatusMessage(str);
    assertTrue('testDialogSocket 13', status = 0);
    assertTrue('testDialogSocket 14', str = 'Header');
    n := ds.receiveRawBytes(@buffer[0], sizeof(buffer));
    assertTrue('testDialogSocket 15', n = 10);
    assertTrue('testDialogSocket 16', memcmp(@buffer[0], PAnsiChar('More Bytes'), 10) = 0);

    ds.sendString('Even More Bytes');
    n := ds.receiveRawBytes(@buffer[0], sizeof(buffer));
    assertTrue('testDialogSocket 17', n = 15);
    assertTrue('testDialogSocket 18', memcmp(@buffer[0], PAnsiChar('Even More Bytes'), 15) = 0);
  finally
    ds.Free;
    echoServer.Free;
  end;
end;

end.
