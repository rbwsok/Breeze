unit TestSocketReactor;

interface

uses System.SysUtils, Winapi.Winsock2, TestUtil;

type

  TTestSocketReactor = class
  private
    procedure TestSocketReactor;
    procedure testSocketConnectorFail;
    procedure testSocketAcceptor;
  public
    class procedure Test;
  end;

implementation

uses Breeze.Net.IPAddress, Breeze.Net.SocketDefs, Breeze.Net.SocketAddress, Breeze.Net.ServerSocket,
  Breeze.Net.StreamSocket, Breeze.Net.SocketReactor,
  Breeze.Net.SocketConnectorAcceptor, Breeze.Net.Socket, TCPEchoServer;

{ TTestSocketReactor }

class procedure TTestSocketReactor.Test;
var
  testclass: TTestSocketReactor;
begin
  TRTest.Comment('=============================================');
  TRTest.Comment('= TestSocketReactor');
  TRTest.Comment('=============================================');

  testclass := TTestSocketReactor.Create;
  try
    testclass.TestSocketReactor;
    testclass.testSocketConnectorFail;
    testclass.testSocketAcceptor;
  finally
    testclass.Free;
  end;
end;

type
  TClientServiceHandler = class(TServiceHandler)
  protected
    procedure OnReadable(ASocket: Breeze.Net.Socket.TSocket; AUserData: Pointer); override;
    procedure OnWritable(ASocket: Breeze.Net.Socket.TSocket; AUserData: Pointer); override;
    procedure OnException(ASocket: Breeze.Net.Socket.TSocket; AUserData: Pointer); override;
  public
    class var data: RawByteString;
  end;

  TClientSocketConnector = class(TSocketConnector)
  private
    FFailed: Boolean;
    FShutdown: Boolean;
  protected
    procedure OnConnect; override;
    procedure OnError(AErrorCode: Integer); override;

    procedure OnTimeout(AReactor: TSocketReactor); override;
    procedure OnShutdown(AReactor: TSocketReactor); override;

    property Failed: Boolean read FFailed;
    property Shutdown: Boolean read FShutdown;
  end;

procedure TClientServiceHandler.OnException(ASocket: Breeze.Net.Socket.TSocket; AUserData: Pointer);
begin
  inherited;

end;

procedure TClientServiceHandler.OnReadable(ASocket: Breeze.Net.Socket.TSocket; AUserData: Pointer);
var
  n: Integer;
begin
  SetLength(data, 2048);
  n := Socket.ReceiveBytes(@data[1], Length(data) - 1);
  if n > 0 then
    SetLength(data, n);

  Reactor.Stop;
end;

procedure TClientServiceHandler.OnWritable(ASocket: Breeze.Net.Socket.TSocket; AUserData: Pointer);
var
  senddata: RawByteString;
  i: Integer;
begin
  SetLength(senddata, 1024);
  for i := 1 to Length(senddata) do
    senddata[i] := 'x';

  try
    Socket.SendBytes(@senddata[1], Length(senddata));
  except
    exit;
  end;
  Socket.ShutdownSend;
end;

procedure TClientSocketConnector.OnConnect;
begin
  FServiceHandler := TClientServiceHandler.Create(Socket, Reactor);
end;

procedure TClientSocketConnector.OnError(AErrorCode: Integer);
begin

end;

procedure TClientSocketConnector.OnShutdown(AReactor: TSocketReactor);
begin
  FShutdown := true;
end;

procedure TClientSocketConnector.OnTimeout(AReactor: TSocketReactor);
begin
  FFailed := true;

  AReactor.Stop;
end;

procedure TTestSocketReactor.TestSocketReactor;
var
  echoServer: TTCPEchoServer;
  ssa, sa: TSocketAddress;
  Reactor: TSocketReactor;
  connector: TClientSocketConnector;
  i: Integer;
  res: Boolean;
begin
  ssa.Create;
  echoServer := TTCPEchoServer.Create(ssa);

  Reactor := TSocketReactor.Create;

  sa := TSocketAddress.Create('127.0.0.1', echoServer.Port);
  connector := TClientSocketConnector.Create(sa, Reactor);

  Reactor.run;

  Reactor.WaitFor;

  assertTrue('testSocketReactor 1', Length(TClientServiceHandler.data) = 1024);

  res := true;
  for i := 1 to Length(TClientServiceHandler.data) do
    if TClientServiceHandler.data[i] <> 'x' then
      res := false;

  assertTrue('testSocketReactor 2', res);

  echoServer.Free;
  connector.Free;
  Reactor.Free;
end;

procedure TTestSocketReactor.testSocketConnectorFail;
var
  Reactor: TSocketReactor;
  sa: TSocketAddress;
  connector: TClientSocketConnector;
begin
  Reactor := TSocketReactor.Create;
  Reactor.setTimeout(3000);

  sa := TSocketAddress.Create('192.168.168.192', 12345);
  connector := TClientSocketConnector.Create(sa, Reactor);

  assertTrue('testSocketConnectorFail 1', not connector.Failed);
  assertTrue('testSocketConnectorFail 2', not connector.Shutdown);

  Reactor.run;

  Reactor.WaitFor;

  assertTrue('testSocketConnectorFail 3', connector.Failed);
  assertTrue('testSocketConnectorFail 4', connector.Shutdown);

  connector.Free;
  Reactor.Free;
end;

type
  TEchoServiceHandler = class(TServiceHandler)
  protected
    procedure OnReadable(ASocket: Breeze.Net.Socket.TSocket; AUserData: Pointer); override;
    procedure OnWritable(ASocket: Breeze.Net.Socket.TSocket; AUserData: Pointer); override;
    procedure OnException(ASocket: Breeze.Net.Socket.TSocket; AUserData: Pointer); override;
  public
    class var data: RawByteString;
  end;

  TEchoSocketAcceptor = class(TSocketAcceptor)
  protected
    procedure OnAccept(AClientSocket: TStreamSocket; AClientSocketAddress: TSocketAddress); override;
    procedure OnError(AErrorCode: Integer); override;
  end;

  { TEchoServiceHandler }

procedure TEchoServiceHandler.OnException(ASocket: Breeze.Net.Socket.TSocket; AUserData: Pointer);
begin
  inherited;

end;

procedure TEchoServiceHandler.OnReadable(ASocket: Breeze.Net.Socket.TSocket; AUserData: Pointer);
var
  LBuffer: array [0 .. 2048] of Byte;
  LReadBytes: Integer;
begin
  LReadBytes := Socket.ReceiveBytes(@LBuffer[0], sizeof(LBuffer));
  if LReadBytes > 0 then
    Socket.SendBytes(@LBuffer[0], LReadBytes);
end;

procedure TEchoServiceHandler.OnWritable(ASocket: Breeze.Net.Socket.TSocket; AUserData: Pointer);
begin
  inherited;

end;

{ TEchoSocketAcceptor }

procedure TEchoSocketAcceptor.OnAccept(AClientSocket: TStreamSocket; AClientSocketAddress: TSocketAddress);
begin
  TRTest.Comment('OnAccept: ' + AClientSocketAddress.ToString);

  FServiceHandler := TEchoServiceHandler.Create(AClientSocket, Reactor);
end;

procedure TEchoSocketAcceptor.OnError(AErrorCode: Integer);
begin
  inherited;

end;

procedure TTestSocketReactor.testSocketAcceptor;
var
  acceptor: TEchoSocketAcceptor;
  ss: TServerSocket;
  ssa, sa: TSocketAddress;
  Reactor: TSocketReactor;
  connector: TClientSocketConnector;
  i: Integer;
  res: Boolean;
begin
  ssa.Create;
  ss := TServerSocket.Create(ssa);

  Reactor := TSocketReactor.Create;

  acceptor := TEchoSocketAcceptor.Create(ss, Reactor);

  sa := TSocketAddress.Create('127.0.0.1', ss.Address.Port);
  connector := TClientSocketConnector.Create(sa, Reactor);

  Reactor.run;

  Reactor.WaitFor;

  assertTrue('testSocketAcceptor 1', Length(TClientServiceHandler.data) = 1024);

  res := true;
  for i := 1 to Length(TClientServiceHandler.data) do
    if TClientServiceHandler.data[i] <> 'x' then
      res := false;

  assertTrue('testSocketAcceptor 2', res);

  Reactor.StopAndWait;
  Reactor.Clear;

  acceptor.ServiceHandler.Socket.Free;
  acceptor.Free;

  connector.Free;

  Reactor.Free;
end;

end.
