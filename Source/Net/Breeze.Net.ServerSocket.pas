unit Breeze.Net.ServerSocket;

interface

uses
  Breeze.Net.Socket, Breeze.Net.SocketImpl, Breeze.Net.SocketAddress, Breeze.Net.StreamSocket, Breeze.Net.ServerSocketImpl, Breeze.Net.IPAddress,
  Breeze.Net.SocketDefs;

type

  TServerSocket = class(Breeze.Net.Socket.TSocket)
	/// This class provides an interface to a
	/// TCP server socket.
  public
	  constructor Create; overload;
		/// Creates a server socket.
		///
		/// The server socket must be bound to
		/// an address and put into listening state.

	  constructor Create(const ASocket: Breeze.Net.Socket.TSocket); overload;
		/// Creates the ServerSocket with the SocketImpl
		/// from another socket. The SocketImpl must be
		/// a ServerSocketImpl, otherwise an InvalidArgumentException
		/// will be thrown.

  	constructor Create(ASocketAddress: TSocketAddress; ABacklog: Integer = 64); overload;
		/// Creates a server socket, binds it
		/// to the given address and puts it in listening
		/// state.
		///
		/// After successful construction, the server socket
		/// is ready to accept connections.

  	constructor Create(APort: Word; ABacklog: Integer = 64); overload;
		/// Creates a server socket, binds it
		/// to the given port and puts it in listening
		/// state.
		///
		/// After successful construction, the server socket
		/// is ready to accept connections.

	  destructor Destroy; override;
		/// Destroys the ServerSocket.

	  procedure Assign(const ASocket: Breeze.Net.Socket.TSocket); override;
		/// Assignment operator.

  	procedure Bind(const ASocketAddress: TSocketAddress; AReuseAddress: Boolean = false; AReusePort: Boolean = false); overload;
		/// Binds a local address to the socket.
		///
		/// This is usually only done when establishing a server
		/// socket. TCP clients should not bind a socket to a
		/// specific address.
		///
		/// If reuseAddress is true, sets the SO_REUSEADDR
		/// socket option.
		///
		/// If reuseAddress is true, sets the SO_REUSEPORT
		/// socket option.

    procedure Bind(APort: Word; AReuseAddress: Boolean = false; AReusePort: Boolean = false); overload;
		/// Binds a local port to the socket.
		///
		/// This is usually only done when establishing a server
		/// socket.
		///
		/// If reuseAddress is true, sets the SO_REUSEADDR
		/// socket option.
        ///
		/// If reusePort is true, sets the SO_REUSEPORT
		/// socket option.

    procedure Bind6(const ASocketAddress: TSocketAddress; AReuseAddress: Boolean = false; AIPv6Only: Boolean = false); overload;
		/// Binds a local IPv6 address to the socket.
		///
		/// This is usually only done when establishing a server
		/// socket. TCP clients should not bind a socket to a
		/// specific address.
		///
		/// If reuseAddress is true, sets the SO_REUSEADDR
		/// socket option.
		///
		/// The given address must be an IPv6 address. The
		/// IPPROTO_IPV6/IPV6_V6ONLY option is set on the socket
		/// according to the ipV6Only parameter.
		///
		/// If the library has not been built with IPv6 support,
		/// a Poco::NotImplementedException will be thrown.

   	procedure Bind6(const ASocketAddress: TSocketAddress; AReuseAddress: Boolean; AReusePort: Boolean; AIPv6Only: Boolean); overload;
		/// Binds a local IPv6 address to the socket.
		///
		/// This is usually only done when establishing a server
		/// socket. TCP clients should not bind a socket to a
		/// specific address.
		///
		/// If reuseAddress is true, sets the SO_REUSEADDR
		/// socket option.
		///
		/// If reusePort is true, sets the SO_REUSEPORT
		/// socket option.
		///
		/// The given address must be an IPv6 address. The
		/// IPPROTO_IPV6/IPV6_V6ONLY option is set on the socket
		/// according to the ipV6Only parameter.
		///
		/// If the library has not been built with IPv6 support,
		/// a Poco::NotImplementedException will be thrown.

   	procedure Bind6(APort: Word; AReuseAddress: Boolean; AIPv6Only: Boolean); overload;
		/// Binds a local IPv6 port to the socket.
		///
		/// This is usually only done when establishing a server
		/// socket.
		///
		/// If reuseAddress is true, sets the SO_REUSEADDR
		/// socket option.
		///
		/// The given address must be an IPv6 address. The
		/// IPPROTO_IPV6/IPV6_V6ONLY option is set on the socket
		/// according to the ipV6Only parameter.
		///
		/// If the library has not been built with IPv6 support,
		/// a Poco::NotImplementedException will be thrown.

   	procedure Bind6(APort: Word; AReuseAddress: Boolean; AReusePort: Boolean; AIPv6Only: Boolean); overload;
		/// Binds a local IPv6 port to the socket.
		///
		/// This is usually only done when establishing a server
		/// socket.
		///
		/// If reuseAddress is true, sets the SO_REUSEADDR
		/// socket option.
		///
		/// If reusePort is true, sets the SO_REUSEPORT
		/// socket option.
		/// The given address must be an IPv6 address. The
		/// IPPROTO_IPV6/IPV6_V6ONLY option is set on the socket
		/// according to the ipV6Only parameter.
		///
		/// If the library has not been built with IPv6 support,
		/// a Poco::NotImplementedException will be thrown.

	  procedure Listen(ABacklog: Integer = 64);
		/// Puts the socket into listening state.
		///
		/// The socket becomes a passive socket that
		/// can accept incoming connection requests.
		///
		/// The backlog argument specifies the maximum
		/// number of connections that can be queued
		/// for this socket.

    function AcceptConnection(var AClientSocketAddress: TSocketAddress): TStreamSocket; overload;
		/// Gets the next completed connection from the
		/// socket's completed connection queue.
		///
		/// If the queue is empty, waits until a connection
		/// request completes.
		///
		/// Returns a new TCP socket for the connection
		/// with the client.
		///
		/// The client socket's address is returned in clientAddr.

    function AcceptConnection: TStreamSocket; overload;
		/// Gets the next completed connection from the
		/// socket's completed connection queue.
		///
		/// If the queue is empty, waits until a connection
		/// request completes.
		///
		/// Returns a new TCP socket for the connection
		/// with the client.

  protected
	  constructor Create(AImpl: TSocketImpl); overload;
		/// The bool argument is to resolve an ambiguity with
		/// another constructor (Microsoft Visual C++ 2005)
  end;

Implementation

uses Breeze.Exception;

{ TServerSocket }

function TServerSocket.AcceptConnection(var AClientSocketAddress: TSocketAddress): TStreamSocket;
begin
  result := TStreamSocket.Create(Impl.AcceptConnection(AClientSocketAddress));
end;

function TServerSocket.AcceptConnection: TStreamSocket;
var
	LClientSocketAddress: TSocketAddress;
begin
  result := TStreamSocket.Create(Impl.acceptConnection(LClientSocketAddress));
end;

procedure TServerSocket.Assign(const ASocket: Breeze.Net.Socket.TSocket);
begin
	if not (ASocket is TServerSocket) then
		raise InvalidArgumentException.Create('Cannot assign incompatible socket (TServerSocket.Assign)');

  inherited Assign(ASocket);
end;

procedure TServerSocket.Bind(APort: Word; AReuseAddress, AReusePort: Boolean);
var
	LWildcardIPAddress: TIPAddress;
	LSocketAddress: TSocketAddress;
begin
  LWildcardIPAddress := TIPAddress.Wildcard(TAddressFamily.IPv4);
	LSocketAddress := TSocketAddress.Create(LWildcardIPAddress, APort);

  Impl.bind(LSocketAddress, AReuseAddress, AReusePort);
end;

procedure TServerSocket.Bind(const ASocketAddress: TSocketAddress; AReuseAddress, AReusePort: Boolean);
begin
  Impl.Bind(ASocketAddress, AReuseAddress, AReusePort);
end;

procedure TServerSocket.Bind6(APort: Word; AReuseAddress, AReusePort, AIPv6Only: Boolean);
var
	LWildcardIPAddress: TIPAddress;
	LSocketAddress: TSocketAddress;
begin
  LWildcardIPAddress := TIPAddress.wildcard(TAddressFamily.IPv6);
	LSocketAddress := TSocketAddress.Create(LWildcardIPAddress, APort);

  Impl.Bind6(LSocketAddress, AReuseAddress, AReusePort, AIPv6Only);
end;

procedure TServerSocket.Bind6(APort: Word; AReuseAddress, AIPv6Only: Boolean);
var
	LWildcardIPAddress: TIPAddress;
	LSocketAddress: TSocketAddress;
begin
  LWildcardIPAddress := TIPAddress.wildcard(TAddressFamily.IPv6);
	LSocketAddress := TSocketAddress.Create(LWildcardIPAddress, APort);

  Impl.Bind6(LSocketAddress, AReuseAddress, AIPv6Only);
end;

procedure TServerSocket.Bind6(const ASocketAddress: TSocketAddress; AReuseAddress, AReusePort, AIPv6Only: Boolean);
begin
  Impl.bind6(ASocketAddress, AReuseAddress, AReusePort, AIPv6Only);
end;

procedure TServerSocket.Bind6(const ASocketAddress: TSocketAddress; AReuseAddress, AIPv6Only: Boolean);
begin
  Impl.Bind6(ASocketAddress, AReuseAddress, AIPv6Only);
end;

constructor TServerSocket.Create(ASocketAddress: TSocketAddress; ABacklog: Integer);
begin
  inherited Create(TServerSocketImpl.Create);

	Impl.Bind(ASocketAddress, true);
	Impl.Listen(ABacklog);
end;

constructor TServerSocket.Create;
begin
  inherited Create(TServerSocketImpl.Create);
end;

constructor TServerSocket.Create(APort: Word; ABacklog: Integer);
var
	LWildcardIPAddress: TIPAddress;
	LSocketAddress: TSocketAddress;
begin
  inherited Create(TServerSocketImpl.Create);

  LWildcardIPAddress := TIPAddress.Wildcard(TAddressFamily.IPv4);
	LSocketAddress := TSocketAddress.Create(LWildcardIPAddress, APort);
	Impl.Bind(LSocketAddress, true);
	Impl.Listen(ABacklog);
end;

constructor TServerSocket.Create(AImpl: TSocketImpl);
begin
  inherited Create(AImpl);
end;

constructor TServerSocket.Create(const ASocket: Breeze.Net.Socket.TSocket);
begin
	if not (ASocket is TServerSocket) then
		raise InvalidArgumentException.Create('Cannot assign incompatible socket (TServerSocket.Create)');

  inherited Create(ASocket);
end;

destructor TServerSocket.Destroy;
begin

  inherited;
end;

procedure TServerSocket.Listen(ABacklog: Integer);
begin
  Impl.Listen(ABacklog);
end;

end.
