unit TestPollSet;

interface

uses Winapi.Windows, Winapi.Winsock2, System.SysUtils, System.Diagnostics, System.Generics.Collections,
System.TimeSpan,
TestUtil;

type
  TTestPollSet = class
	  procedure testAddUpdate;
	  procedure testTimeout;
	  procedure testPollNB;
	  procedure testPoll;
	  procedure testPollNoServer;
	  procedure testPollClosedServer;
	  procedure testPollSetWakeUp;
	  procedure testClear;
  public
    class procedure Test;
  end;

implementation

uses Breeze.Net.PollSet, Breeze.Net.StreamSocket, Breeze.Net.SocketAddress, Breeze.Net.Socket, TCPEchoServer, Breeze.Exception, Breeze.Net.SocketDefs;

{ TTestPollSet }

class procedure TTestPollSet.Test;
var
  testclass: TTestPollSet;
begin
  TRTest.Comment('=============================================');
  TRTest.Comment('= TestPollSet');
  TRTest.Comment('=============================================');

  testclass := TTestPollSet.Create;
  try
    testclass.testAddUpdate;
    testclass.testTimeout;
    testclass.testPollNB;
    testclass.testPoll;
    testclass.testPollNoServer;
    testclass.testPollClosedServer;
    testclass.testPollSetWakeUp;
    testclass.testClear;
  finally
    testclass.Free;
  end;
end;

procedure TTestPollSet.testAddUpdate;
var
	echoServer1, echoServer2: TTCPEchoServer;
	ss1, ss2: TStreamSocket;
	ps: TPollSet;

  timeout: Cardinal;
  sw: TStopwatch;
  sm: TDictionary<TSocket, Integer>;
  n, value: Integer;
  buffer: array [0..255] of AnsiChar;
begin
  echoServer1 := nil;
  echoServer2 := nil;
	ss1 := nil;
  ss2 := nil;
	ps := nil;
  try
    echoServer1 := TTCPEchoServer.Create;
    echoServer2 := TTCPEchoServer.Create;
    ss1 := TStreamSocket.Create;
    ss2 := TStreamSocket.Create;
    ps := TPollSet.Create;

    ss1.connect(TSocketAddress.Create('127.0.0.1', echoServer1.port));
    ss2.connect(TSocketAddress.Create('127.0.0.1', echoServer2.port));

    assertTrue('testAddUpdate 1', ps.IsEmpty);
    ps.add(ss1, POLL_READ);
    assertTrue('testAddUpdate 2', not ps.IsEmpty);
    assertTrue('testAddUpdate 3', ps.has(ss1));
    assertTrue('testAddUpdate 4', not ps.has(ss2));

    // nothing readable
    sw := TStopwatch.StartNew;
    timeout := 1000;
    sm := ps.poll(timeout);
    try
      assertTrue('testAddUpdate 5', sm.IsEmpty);
    finally
      sm.Free;
    end;
    sw.Stop;
    assertTrue('testAddUpdate 6', sw.Elapsed.TotalMilliseconds >= 900);
    sw.Start;

    ps.add(ss2, POLL_READ);
    assertTrue('testAddUpdate 7', not ps.IsEmpty);
    assertTrue('testAddUpdate 8', ps.has(ss1));
    assertTrue('testAddUpdate 9', ps.has(ss2));

    // ss1 must be writable, if polled for
    ps.add(ss1, POLL_WRITE);
    sm := ps.poll(timeout);
    try
      assertTrue('testAddUpdate 10', sm.ContainsKey(ss1));
      assertTrue('testAddUpdate 11', not sm.ContainsKey(ss2));
      sm.TryGetValue(ss1, value);
      assertTrue('testAddUpdate 12', value and POLL_WRITE > 0);
      sw.Stop;
      assertTrue('testAddUpdate 13', sw.Elapsed.TotalMilliseconds < 1100);
    finally
      sm.Free;
    end;

    ps.add(ss1, POLL_READ);
    ss1.setBlocking(true);
    ss1.sendBytes(PAnsiChar('hello'), 5);
    while not ss1.poll(1000, TPollMode.SELECT_READ) do
      Sleep(10);
    sw.Start;
    sm := ps.poll(timeout);
    try
      assertTrue('testAddUpdate 14', sm.ContainsKey(ss1));
      assertTrue('testAddUpdate 15', not sm.ContainsKey(ss2));
      sm.TryGetValue(ss1, value);
      assertTrue('testAddUpdate 16', value and POLL_READ > 0);
      sw.Stop;
      assertTrue('testAddUpdate 17', sw.Elapsed.TotalMilliseconds < 1100);
    finally
      sm.Free;
    end;

    n := ss1.receiveBytes(@buffer[0], sizeof(buffer));
    assertTrue('testAddUpdate 18', n = 5);
    buffer[n] := #0;
    assertTrue('testAddUpdate 19', AnsiString(buffer) = AnsiString('hello'));

    ss2.setBlocking(true);
    ss2.sendBytes(PAnsiChar('HELLO'), 5);
    sw.Start;
    ps.remove(ss1);
    sm := ps.poll(timeout);
    try
      assertTrue('testAddUpdate 20', not sm.ContainsKey(ss1));
      assertTrue('testAddUpdate 21', sm.ContainsKey(ss2));
      sm.TryGetValue(ss2, value);
      assertTrue('testAddUpdate 22', value and POLL_READ > 0);
      sw.Stop;
      assertTrue('testAddUpdate 23', sw.Elapsed.TotalMilliseconds < 1100);
    finally
      sm.Free;
    end;

    n := ss2.receiveBytes(@buffer[0], sizeof(buffer));
    assertTrue('testAddUpdate 24', n = 5);
    buffer[n] := #0;
    assertTrue('testAddUpdate 25', AnsiString(buffer) = 'HELLO');

    ps.remove(ss2);
    assertTrue('testAddUpdate 26', ps.IsEmpty);
    assertTrue('testAddUpdate 27', not ps.has(ss1));
    assertTrue('testAddUpdate 28', not ps.has(ss2));

    ss2.sendBytes(PAnsiChar('HELLO'), 5);
    sm := ps.poll(timeout);
    try
      assertTrue('testAddUpdate 29', sm.IsEmpty);
    finally
      sm.Free;
    end;

    n := ss2.receiveBytes(@buffer[0], sizeof(buffer));
    assertTrue('testAddUpdate 30', n = 5);
    buffer[n] := #0;
    assertTrue('testAddUpdate 31', AnsiString(buffer) = 'HELLO');

    ss1.close;
    ss2.close;
  finally
    echoServer1.Free;
    echoServer2.Free;
    ss1.Free;
    ss2.Free;
    ps.Free;
  end;
end;

procedure TTestPollSet.testClear;
var
	echoServer: TTCPEchoServer;
	ss: TStreamSocket;
	ps: TPollSet;
  sm: TDictionary<TSocket, Integer>;
  buffer: array [0..4] of AnsiChar;
begin
  echoServer := nil;
	ss := nil;
	ps := nil;
  try
    echoServer := TTCPEchoServer.Create;
    ss := TStreamSocket.Create;
    ps := TPollSet.Create;

    ss.connect(TSocketAddress.Create('127.0.0.1', echoServer.port));

  	ps.add(ss, POLL_READ);
	  sm := ps.poll(0);
    try
      assertTrue('testClear 1', sm.IsEmpty);
    finally
      sm.Free;
    end;

  	ss.sendBytes(PAnsiChar('hello'), 5);
    sm := ps.poll(1000);
    try
      assertTrue('testClear 2', sm.Count = 1);
    finally
      sm.Free;
    end;

  	ss.receiveBytes(@buffer[0], sizeof(buffer));

    ps.clear;
    ps.add(ss, POLL_READ);
    sm := ps.poll(0);
    try
      assertTrue('testClear 3', sm.IsEmpty);
    finally
      sm.Free;
    end;

  	ss.sendBytes(@buffer[0], 5);

    sm := ps.poll(1000);
    try
      assertTrue('testClear 4', sm.Count = 1);
    finally
      sm.Free;
    end;

  	ss.receiveBytes(@buffer[0], sizeof(buffer));
  finally
    ps.Free;
    ss.Free;
    echoServer.Free;
  end;
end;

procedure TTestPollSet.testPoll;
var
	echoServer1, echoServer2: TTCPEchoServer;
	ss1, ss2: TStreamSocket;
	ps: TPollSet;

  timeout: Cardinal;
  sw: TStopwatch;
  sm: TDictionary<TSocket, Integer>;
  n, value: Integer;
  buffer: array [0..255] of AnsiChar;
begin
  echoServer1 := nil;
  echoServer2 := nil;
	ss1 := nil;
  ss2 := nil;
	ps := nil;
  try
    echoServer1 := TTCPEchoServer.Create;
    echoServer2 := TTCPEchoServer.Create;
    ss1 := TStreamSocket.Create;
    ss2 := TStreamSocket.Create;
    ps := TPollSet.Create;

    ss1.connect(TSocketAddress.Create('127.0.0.1', echoServer1.port));
    ss2.connect(TSocketAddress.Create('127.0.0.1', echoServer2.port));

    assertTrue('testPoll 1', ps.IsEmpty);
    ps.add(ss1, POLL_READ);
    assertTrue('testPoll 2', not ps.IsEmpty);
    assertTrue('testPoll 3', ps.has(ss1));
    assertTrue('testPoll 4', not ps.has(ss2));

	// nothing readable
    sw := TStopwatch.StartNew;
    timeout := 1000;
    sm := ps.poll(timeout);
    try
      assertTrue('testPoll 5', sm.IsEmpty);
    finally
      sm.Free;
    end;
    sw.Stop;
    assertTrue('testPoll 6', sw.Elapsed.TotalMilliseconds >= 900);
    sw.Start;

    ps.add(ss2, POLL_READ);
    assertTrue('testPoll 7', not ps.IsEmpty);
    assertTrue('testPoll 8', ps.has(ss1));
    assertTrue('testPoll 9', ps.has(ss2));

	// ss1 must be writable, if polled for
  	ps.update(ss1, POLL_READ or POLL_WRITE);
	  sm := ps.poll(timeout);
    try
      assertTrue('testPoll 10', sm.ContainsKey(ss1));
      assertTrue('testPoll 11', not sm.ContainsKey(ss2));
      sm.TryGetValue(ss1, value);
      assertTrue('testPoll 12', value and POLL_WRITE > 0);
    finally
      sm.Free;
    end;
    sw.Stop;
    assertTrue('testPoll 13', sw.Elapsed.TotalMilliseconds < 1100);

    ps.update(ss1, POLL_READ);

    ss1.setBlocking(true);
    ss1.sendBytes(PAnsiChar('hello'), 5);
    while not ss1.poll(1000, TPollMode.SELECT_READ) do
      Sleep(10);
    sw.Start;
    sm := ps.poll(timeout);
    try
      assertTrue('testPoll 14', sm.ContainsKey(ss1));
      assertTrue('testPoll 15', not sm.ContainsKey(ss2));
      sm.TryGetValue(ss1, value);
      assertTrue('testPoll 16', value and POLL_READ > 0);
      sw.Stop;
      assertTrue('testPoll 17', sw.Elapsed.TotalMilliseconds < 1100);
    finally
      sm.Free;
    end;

    n := ss1.receiveBytes(@buffer[0], sizeof(buffer));
    assertTrue('testPoll 18', n = 5);
    buffer[n] := #0;
    assertTrue('testPoll 19', AnsiString(buffer) = 'hello');

    ss2.setBlocking(true);
    ss2.sendBytes(PAnsiChar('HELLO'), 5);
    while not ss2.poll(1000, TPollMode.SELECT_READ) do
      Sleep(10);

    sw.Start;
    sm := ps.poll(timeout);
    try
      assertTrue('testPoll 20', not sm.ContainsKey(ss1));
      assertTrue('testPoll 21', sm.ContainsKey(ss2));
      sm.TryGetValue(ss2, value);
      assertTrue('testPoll 22', value and POLL_READ > 0);
      sw.Stop;
      assertTrue('testPoll 23', sw.Elapsed.TotalMilliseconds < 1100);
    finally
      sm.Free;
    end;

    n := ss2.receiveBytes(@buffer[0], sizeof(buffer));
    assertTrue('testPoll 24', n = 5);
    buffer[n] := #0;
    assertTrue('testPoll 25', AnsiString(buffer) = 'HELLO');

    ps.remove(ss2);
    ps.update(ss1, POLL_READ);
    assertTrue('testPoll 26', not ps.IsEmpty);
    assertTrue('testPoll 27', ps.has(ss1));
    assertTrue('testPoll 28', not ps.has(ss2));

    ss2.sendBytes(PAnsiChar('HELLO'), 5);
    sm := ps.poll(timeout);
    try
      assertTrue('testPoll 29', sm.IsEmpty);
    finally
      sm.Free;
    end;

    n := ss2.receiveBytes(@buffer[0], sizeof(buffer));
    assertTrue('testPoll 30', n = 5);
    buffer[n] := #0;
    assertTrue('testPoll 31', AnsiString(buffer) = 'HELLO');

    ss1.close;
    ss2.close;
  finally
    echoServer1.Free;
    echoServer2.Free;
    ss1.Free;
    ss2.Free;
    ps.Free;
  end;
end;

procedure TTestPollSet.testPollClosedServer;
var
	echoServer1, echoServer2: TTCPEchoServer;
	ss1, ss2: TStreamSocket;
	ps: TPollSet;

  sw: TStopwatch;
  sm: TDictionary<TSocket, Integer>;
  n, len: Integer;
  buffer: array [0..255] of AnsiChar;
begin
  echoServer1 := nil;
  echoServer2 := nil;
	ss1 := nil;
  ss2 := nil;
	ps := nil;
  try
    echoServer1 := TTCPEchoServer.Create;
    echoServer2 := TTCPEchoServer.Create;
    ss1 := TStreamSocket.Create(TAddressFamily.IPv4);
    ss2 := TStreamSocket.Create(TAddressFamily.IPv4);
    ps := TPollSet.Create;

    assertTrue('testPollClosedServer 1', ps.IsEmpty);
    ps.add(ss1, POLL_READ);
    ps.add(ss2, POLL_READ);
    assertTrue('testPollClosedServer 2', not ps.IsEmpty);
    assertTrue('testPollClosedServer 3', ps.has(ss1));
    assertTrue('testPollClosedServer 4', ps.has(ss2));

    ss1.connect(TSocketAddress.Create('127.0.0.1', echoServer1.port));
    ss2.connect(TSocketAddress.Create('127.0.0.1', echoServer2.port));

	  echoServer1.Terminate;
    len := ss1.sendBytes(PAnsiChar('hello'), 5);
    assertTrue('testPollClosedServer 5', len =  5);

    sw := TStopwatch.StartNew;
	  while not echoServer1.Finished do
    begin
  		Sleep(10);
  		if sw.Elapsed.TotalSeconds > 10 then
			  raise TimeoutException.Create('waiting for server');
    end;
	  n := ss1.receiveBytes(@buffer[0], sizeof(buffer));
    assertTrue('testPollClosedServer 6', n = 0);
	  sm := ps.poll(1000);
    try
      assertTrue('testPollClosedServer 7', sm.Count = 1);
    finally
      sm.Free;
    end;
  	ps.remove(ss1);
    assertTrue('testPollClosedServer 8', not ps.IsEmpty);
    assertTrue('testPollClosedServer 9', not ps.has(ss1));
    assertTrue('testPollClosedServer 10', ps.has(ss2));

  	echoServer2.Terminate;

    len := ss2.sendBytes(PAnsiChar('hello'), 5);
    assertTrue('testPollClosedServer 11', len = 5);

	  sw.Reset;
(*	while (!echoServer2.done())
	{
		Thread::sleep(10);
		int secs = sw.elapsedSeconds();
		if (secs > 10)
		{
			fail(Poco::format("testPollClosedServer(2) timed out "
				"waiting on server after %ds", secs), __LINE__);
		}
	}*)
	  n := ss2.receiveBytes(@buffer[0], sizeof(buffer));
    assertTrue('testPollClosedServer 12', n = 0);

	  sm := ps.poll(1000);
    try
      assertTrue('testPollClosedServer 13', sm.Count = 1);
    finally
      sm.Free;
    end;

	// socket closed or error
    assertTrue('testPollClosedServer 14', 0 >= ss1.receiveBytes(nil, 0));
    assertTrue('testPollClosedServer 15', 0 >= ss2.receiveBytes(nil, 0));
  finally
    echoServer1.Free;
    echoServer2.Free;
    ss1.Free;
    ss2.Free;
    ps.Free;
  end;
end;

procedure TTestPollSet.testPollNB;
var
	echoServer: TTCPEchoServer;
	ss: TStreamSocket;
  ps: TPollSet;
  timeout: Cardinal;
  sm: TDictionary<TSocket, Integer>;
  value, n: Integer;
  buffer: array [0..255] of AnsiChar;
begin
  echoServer := nil;
  ss := nil;
	ps := nil;
  try
    echoServer := TTCPEchoServer.Create;
    ss := TStreamSocket.Create;
    ps := TPollSet.Create;

    ss.connectNB(TSocketAddress.Create('127.0.0.1', echoServer.port));

    assertTrue('testPollNB 1', ps.IsEmpty);

    ps.add(ss, POLL_READ);
    ps.add(ss, POLL_WRITE);
    assertTrue('testPollNB 2', not ps.IsEmpty);
    assertTrue('testPollNB 3', ps.has(ss));

    while not ss.poll(1000, TPollMode.SELECT_WRITE) do
      Sleep(10);

    timeout := 1000;

    while true do
    begin
      sm := ps.poll(timeout);
      if not sm.IsEmpty then
        break;
      sm.Free;
    end;

    assertTrue('testPollNB 4', sm.ContainsKey(ss));

    sm.TryGetValue(ss, value);
    assertTrue('testPollNB 5', value and POLL_WRITE > 0);
    sm.Free;

    ss.setBlocking(true);
    ss.sendBytes(PAnsiChar('hello'), 5);
    while not ss.poll(1000, TPollMode.SELECT_READ) do
      Sleep(10);

    sm := ps.poll(timeout);
    try
      assertTrue('testPollNB 6', sm.ContainsKey(ss));
      sm.TryGetValue(ss, value);
      assertTrue('testPollNB 7', value and POLL_READ > 0);
    finally
      sm.Free;
    end;

    n := ss.receiveBytes(@buffer[0], sizeof(buffer));
    assertTrue('testPollNB 8', n = 5);
    buffer[n] := #0;
    assertTrue('testPollNB 9', AnsiString(buffer) = 'hello');
  finally
    ps.Free;
    ss.Free;
    echoServer.Free;
  end;
end;

procedure TTestPollSet.testPollNoServer;
var
	ss1, ss2: TStreamSocket;
	ps: TPollSet;
  sm: TDictionary<TSocket, Integer>;
begin
	ss1 := nil;
  ss2 := nil;
  ps := nil;
  try
    ss1 := TStreamSocket.Create(TAddressFamily.IPv4);
    ss2 := TStreamSocket.Create(TAddressFamily.IPv4);
    ps := TPollSet.Create;

    assertTrue('testPollNoServer 1', ps.IsEmpty);

    ps.add(ss1, POLL_READ or POLL_WRITE or POLL_ERROR);
    ps.add(ss2, POLL_READ or POLL_WRITE or POLL_ERROR);
    assertTrue('testPollNoServer 2', not ps.IsEmpty);
    assertTrue('testPollNoServer 3', ps.has(ss1));
    assertTrue('testPollNoServer 4', ps.has(ss2));

    ss1.setBlocking(true);
    ss2.setBlocking(true);

    assertException('testPollNoServer 5',
      procedure
      begin
        ss1.connect(TSocketAddress.Create('127.0.0.1', $ffff));
      end
    );

    assertException('testPollNoServer 6',
      procedure
      begin
        ss2.connect(TSocketAddress.Create('127.0.0.1', $ffff));
      end
    );

    assertTrue('testPollNoServer 3', ps.has(ss1));

    sm := ps.poll(1000);
    try
      assertTrue('testPollNoServer 3', sm.Count = 2);
    finally
      sm.Free;
    end;
  finally
    ss1.Free;
    ss2.Free;
    ps.Free;
  end;
end;

procedure TTestPollSet.testPollSetWakeUp;
begin

end;

procedure TTestPollSet.testTimeout;
var
	echoServer: TTCPEchoServer;
	ss: TStreamSocket;
  ps: TPollSet;
  timeout: Cardinal;
  sw: TStopwatch;
  sm: TDictionary<TSocket, Integer>;
  buffer: array [0..4] of AnsiChar;
begin
  echoServer := nil;
  ss := nil;
	ps := nil;
  try
    echoServer := TTCPEchoServer.Create;
    ss := TStreamSocket.Create;
    ps := TPollSet.Create;

    ss.connect(TSocketAddress.Create('127.0.0.1', echoServer.port));

    ps.add(ss, POLL_READ);
    sw := TStopwatch.StartNew;
    timeout := 1000;
    sm := ps.poll(timeout);
    try
      sw.stop;
      assertTrue('testTimeout 1', sm.IsEmpty);
      assertTrue('testTimeout 2', sw.Elapsed.TotalMilliseconds >= 900);
    finally
      sm.Free;
    end;

    ss.sendBytes(PAnsiChar('hello'), 5);
    sw.Start;
    sm := ps.poll(timeout);
    try
      sw.stop;
      assertTrue('testTimeout 3', sm.Count = 1);
    finally
      sm.Free;
    end;

    ss.receiveBytes(@buffer[0], sizeof(buffer));

    sw.Start;
    sm := ps.poll(timeout);
    try
      sw.Stop;
      assertTrue('testTimeout 4', sm.IsEmpty);
      assertTrue('testTimeout 5', sw.Elapsed.TotalMilliseconds >= 900);
    finally
      sm.Free;
    end;
  finally
    ps.Free;
    ss.Free;
    echoServer.Free;
  end;
end;

end.
