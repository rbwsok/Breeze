unit Breeze.Net.SocketConnectorAcceptor;

interface

uses
  System.Generics.Collections, System.Classes,
  Breeze.Net.SocketDefs, Breeze.Net.Socket, Breeze.Net.PollSet, Breeze.Net.SocketAddress, Breeze.Net.StreamSocket, Breeze.Net.ServerSocket,
  Breeze.Net.SocketReactor, Breeze.Net.SocketImpl;

type
  ///////////////////////////////////////////////////////////////////////////////////
  // паттерн Connector-Acceprtor. Отделяет процесс подключения и процесс принятия подключения от процесса работы.
  // надо делать наследников TSocketConnector, TSocketAcceptor, TServiceHandler

  TServiceHandler = class abstract
  private
  	FSocket: TStreamSocket; // not owner
	  FReactor: TSocketReactor; // not owner
  protected
	  procedure OnReadable(ASocket: Breeze.Net.Socket.TSocket; AUserData: Pointer); virtual; abstract;
	  procedure OnWritable(ASocket: Breeze.Net.Socket.TSocket; AUserData: Pointer); virtual; abstract;
	  procedure OnException(ASocket: Breeze.Net.Socket.TSocket; AUserData: Pointer); virtual; abstract;
  public
    constructor Create(ASocket: TStreamSocket; AReactor: TSocketReactor);
    destructor Destroy; override;

    property Socket: TStreamSocket read FSocket;
    property Reactor: TSocketReactor read FReactor;
  end;

  TSocketConnector = class abstract
  private
  	FSocket: TStreamSocket; // owner
	  FReactor: TSocketReactor; // not owner

    constructor Create; overload;

    procedure RegisterConnector(AReactor: TSocketReactor);
    procedure UnregisterConnector;

	  procedure OnReadable(ASocket: Breeze.Net.Socket.TSocket; AUserData: Pointer);
	  procedure OnWritable(ASocket: Breeze.Net.Socket.TSocket; AUserData: Pointer);
	  procedure OnException(ASocket: Breeze.Net.Socket.TSocket; AUserData: Pointer);
  protected
    FServiceHandler: TServiceHandler;

	  procedure OnConnect; virtual; abstract;
	  procedure OnError(AErrorCode: Integer); virtual; abstract;

    procedure OnTimeout(AReactor: TSocketReactor); virtual;
    procedure OnShutdown(AReactor: TSocketReactor); virtual;
  public
    constructor Create(ASocketAddress: TSocketAddress); overload;
    constructor Create(ASocketAddress: TSocketAddress; AReactor: TSocketReactor; ADoRegister: Boolean = true); overload;
    destructor Destroy; override;

    property Socket: TStreamSocket read FSocket;
    property Reactor: TSocketReactor read FReactor;
    property ServiceHandler: TServiceHandler read FServiceHandler;
  end;

  TSocketAcceptor = class abstract
  private
  	FSocket: TServerSocket; // not owner
	  FReactor: TSocketReactor; // not owner

    procedure RegisterAcceptor(AReactor: TSocketReactor);
    procedure UnregisterAcceptor;

    procedure OnReadable(ASocket: Breeze.Net.Socket.TSocket; AUserData: Pointer);
	  procedure OnWritable(ASocket: Breeze.Net.Socket.TSocket; AUserData: Pointer);
	  procedure OnException(ASocket: Breeze.Net.Socket.TSocket; AUserData: Pointer);
  protected
    FServiceHandler: TServiceHandler;

	  procedure OnAccept(AClientSocket: TStreamSocket; AClientSocketAddress: TSocketAddress); virtual; abstract;
	  procedure OnError(AErrorCode: Integer); virtual; abstract;
  public
    constructor Create(ASocket: TServerSocket); overload;
    constructor Create(ASocket: TServerSocket; AReactor: TSocketReactor); overload;
    destructor Destroy; override;

    property Socket: TServerSocket read FSocket;
    property Reactor: TSocketReactor read FReactor;
    property ServiceHandler: TServiceHandler read FServiceHandler;
  end;

implementation

{ TSocketConnector }

constructor TSocketConnector.Create;
begin
  FSocket := TStreamSocket.Create;
end;

constructor TSocketConnector.Create(ASocketAddress: TSocketAddress);
begin
  Create;

	FSocket.ConnectNB(ASocketAddress);
end;

constructor TSocketConnector.Create(ASocketAddress: TSocketAddress; AReactor: TSocketReactor; ADoRegister: Boolean);
begin
  Create;

	FSocket.ConnectNB(ASocketAddress);
	if ADoRegister then
    RegisterConnector(AReactor);

  AReactor.OnTimeout := OnTimeout;
  AReactor.OnShutdown := OnShutdown;
end;

destructor TSocketConnector.Destroy;
begin
  UnregisterConnector;

  FSocket.Free;

  FServiceHandler.Free;

  inherited;
end;

procedure TSocketConnector.OnException(ASocket: Breeze.Net.Socket.TSocket; AUserData: Pointer);
begin
  UnregisterConnector;
  OnError(FSocket.impl.SocketError);
end;

procedure TSocketConnector.OnReadable(ASocket: Breeze.Net.Socket.TSocket; AUserData: Pointer);
var
  LError: Integer;
begin
  UnregisterConnector;
	LError := FSocket.impl.SocketError();
	if LError <> 0 then
    OnError(LError)
	else
    OnConnect;
end;

procedure TSocketConnector.OnShutdown(AReactor: TSocketReactor);
begin

end;

procedure TSocketConnector.OnTimeout(AReactor: TSocketReactor);
begin

end;

procedure TSocketConnector.OnWritable(ASocket: Breeze.Net.Socket.TSocket; AUserData: Pointer);
begin
	UnregisterConnector;
  OnConnect;
end;

procedure TSocketConnector.RegisterConnector(AReactor: TSocketReactor);
begin
  FReactor := AReactor;
  FReactor.Add(FSocket, OnReadable, OnWritable, OnException, nil);
end;

procedure TSocketConnector.UnregisterConnector;
begin
  if FReactor <> nil then
    FReactor.Remove(FSocket);
end;

{ TServiceHandler }

constructor TServiceHandler.Create(ASocket: TStreamSocket; AReactor: TSocketReactor);
begin
  FSocket := ASocket;
  FReactor := AReactor;

  FReactor.Add(FSocket, OnReadable, OnWritable, OnException, nil);
end;

destructor TServiceHandler.Destroy;
begin

  inherited;
end;

{ TSocketAcceptor }

constructor TSocketAcceptor.Create(ASocket: TServerSocket);
begin
  FSocket := ASocket;
end;

constructor TSocketAcceptor.Create(ASocket: TServerSocket; AReactor: TSocketReactor);
begin
  FSocket := ASocket;
  RegisterAcceptor(AReactor);
end;

destructor TSocketAcceptor.Destroy;
begin
  UnregisterAcceptor;

  FSocket.Free;

  FServiceHandler.Free;

  inherited;
end;

procedure TSocketAcceptor.OnException(ASocket: Breeze.Net.Socket.TSocket; AUserData: Pointer);
begin
  OnError(FSocket.impl.SocketError);
end;

procedure TSocketAcceptor.OnReadable(ASocket: Breeze.Net.Socket.TSocket; AUserData: Pointer);
var
  LClientSocket: TStreamSocket;
  LClientSocketAddress: TSocketAddress;
begin
	LClientSocket := FSocket.AcceptConnection(LClientSocketAddress);
  OnAccept(LClientSocket, LClientSocketAddress);
end;

procedure TSocketAcceptor.OnWritable(ASocket: Breeze.Net.Socket.TSocket; AUserData: Pointer);
begin

end;

procedure TSocketAcceptor.RegisterAcceptor(AReactor: TSocketReactor);
begin
  FReactor := AReactor;
  FReactor.Add(FSocket, OnReadable, OnWritable, OnException, nil);
end;

procedure TSocketAcceptor.UnregisterAcceptor;
begin
  if FReactor <> nil then
    FReactor.Remove(FSocket);
end;


end.
