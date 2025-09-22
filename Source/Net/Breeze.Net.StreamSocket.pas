unit Breeze.Net.StreamSocket;

interface

uses Winapi.Winsock2,
  Breeze.Net.Socket, Breeze.Net.SocketImpl, Breeze.Net.StreamSocketImpl, Breeze.Net.SocketDefs, Breeze.Net.SocketAddress, Breeze.Exception;

type

  TStreamSocket = class(Breeze.Net.Socket.TSocket)
	/// This class provides an interface to a
	/// TCP stream socket.
  public
	  constructor Create(AImpl: TSocketImpl); overload;
		/// Creates the Socket and attaches the given SocketImpl.
		/// The socket takes ownership of the SocketImpl.
		///
		/// The SocketImpl must be a StreamSocketImpl, otherwise
		/// an InvalidArgumentException will be thrown.

  	constructor Create; overload;
		/// Creates an unconnected stream socket.
		///
		/// Before sending or receiving data, the socket
		/// must be connected with a call to connect().

 	  constructor Create(const ASocket: Breeze.Net.Socket.TSocket); overload;

	  constructor Create(AFamily: TAddressFamily); overload;
		/// Creates an unconnected stream socket
		/// for the given address family.
		///
		/// This is useful if certain socket options
		/// (like send and receive buffer) sizes, that must
		/// be set before connecting the socket, will be
		/// set later on.

	  constructor Create(ANativeSocket: Winapi.Winsock2.TSocket); overload;
		/// Creates the StreamSocket with the SocketImpl
		/// from another socket. The SocketImpl must be
		/// a StreamSocketImpl, otherwise an InvalidArgumentException
		/// will be thrown.

	  destructor Destroy; override;
		/// Destroys the StreamSocket.

    procedure Assign(const ASocket: Breeze.Net.Socket.TSocket); override;
		/// Assignment operator.
		///

  	procedure Connect(const ASocketAddress: TSocketAddress);
		/// Initializes the socket and establishes a connection to
		/// the TCP server at the given address.
		///
		/// Can also be used for UDP sockets. In this case, no
		/// connection is established. Instead, incoming and outgoing
		/// packets are restricted to the specified address.

//	void connect(const SocketAddress& address, const Poco::Timespan& timeout);
		/// Initializes the socket, sets the socket timeout and
		/// establishes a connection to the TCP server at the given address.

  	procedure ConnectNB(const ASocketAddress: TSocketAddress);
		/// Initializes the socket and establishes a connection to
		/// the TCP server at the given address. Prior to opening the
		/// connection the socket is set to nonblocking mode.

    procedure Bind(const ASocketAddress: TSocketAddress; AReuseAddress: Boolean = false; AIPv6Only: Boolean = false); overload;
		/// Bind a local address to the socket.
		///
		/// This is usually only done when establishing a server
		/// socket.
		///
		/// TCP clients normally do not bind to a local address,
		/// but in some special advanced cases it may be useful to have
		/// this type of functionality.  (e.g. in multihoming situations
		/// where the traffic will be sent through a particular interface;
		/// or in computer clustered environments with active/standby
		/// servers and it is desired to make the traffic from either
		/// active host present the same source IP address).
		///
		/// Note:  Practical use of client source IP address binding
		///        may require OS networking setup outside the scope of
		///        the Poco library.
		///
		/// If reuseAddress is true, sets the SO_REUSEADDR
		/// socket option.

	  procedure ShutdownReceive;
		/// Shuts down the receiving part of the socket connection.

	  function ShutdownSend: Integer;
		/// Shuts down the sending part of the socket connection.
		///
		/// Returns 0 for a non-blocking socket. May return
		/// a negative value for a non-blocking socket in case
		/// of a TLS connection. In that case, the operation should
		/// be retried once the underlying socket becomes writable.

	  function Shutdown: Integer;
		/// Shuts down both the receiving and the sending part
		/// of the socket connection.
		///
		/// Returns 0 for a non-blocking socket. May return
		/// a negative value for a non-blocking socket in case
		/// of a TLS connection. In that case, the operation should
		/// be retried once the underlying socket becomes writable.

    function SendBytes(ABuffer: Pointer; ALength: Integer; AFlags: Integer = 0): Integer; virtual;
		/// Sends the contents of the given buffer through
		/// the socket.
		///
		/// Returns the number of bytes sent, which may be
		/// less than the number of bytes specified.
		///
		/// Certain socket Implementations may also return a negative
		/// value denoting a certain condition.
		///
		/// The flags parameter can be used to pass system-defined flags
		/// for send() like MSG_OOB.

    function ReceiveBytes(ABuffer: Pointer; ALength: Integer; AFlags: Integer = 0): Integer;
		/// Receives data from the socket and stores it
		/// in buffer. Up to length bytes are received.
		///
		/// Returns the number of bytes received.
		/// A return value of 0 means a graceful shutdown
		/// of the connection from the peer.
		///
		/// Throws a TimeoutException if a receive timeout has
		/// been set and nothing is received within that interval.
		/// Throws a NetException (or a subclass) in case of other errors.
		///
		/// The flags parameter can be used to pass system-defined flags
		/// for recv() like MSG_OOB, MSG_PEEK or MSG_WAITALL.

  	procedure SendUrgent(AData: AnsiChar);
		/// Sends one byte of urgent data through
		/// the socket.
		///
		/// The data is sent with the MSG_OOB flag.
		///
		/// The preferred way for a socket to receive urgent data
		/// is by enabling the SO_OOBINLINE option.
  end;

Implementation

{ TStreamSocket }

procedure TStreamSocket.Assign(const ASocket: Breeze.Net.Socket.TSocket);
begin
  if not (ASocket is TStreamSocket) then
		raise InvalidArgumentException.Create('Cannot assign incompatible socket (TStreamSocket.Assign)');

  inherited Assign(ASocket);
end;

procedure TStreamSocket.bind(const ASocketAddress: TSocketAddress; AReuseAddress, AIPv6Only: Boolean);
begin
	if ASocketAddress.family = TaddressFamily.IPv4 then
		Impl.Bind(ASocketAddress, AReuseAddress)
	else
		Impl.Bind6(ASocketAddress, AReuseAddress, AIPv6Only);
end;

procedure TStreamSocket.Connect(const ASocketAddress: TSocketAddress);
begin
	Impl.connect(ASocketAddress);
end;

procedure TStreamSocket.ConnectNB(const ASocketAddress: TSocketAddress);
begin
	Impl.connectNB(ASocketAddress);
end;

constructor TStreamSocket.Create;
begin
  inherited Create(TStreamSocketImpl.Create);
end;

constructor TStreamSocket.Create(AImpl: TSocketImpl);
begin
  if not (AImpl is TStreamSocketImpl) then
		raise InvalidArgumentException.Create('Cannot assign incompatible socket (TStreamSocket.Create Impl)');

  inherited Create(AImpl);
end;

constructor TStreamSocket.Create(ANativeSocket: Winapi.Winsock2.TSocket);
begin

end;

constructor TStreamSocket.Create(const ASocket: Breeze.Net.Socket.TSocket);
begin
  if not (ASocket is TStreamSocket) then
		raise InvalidArgumentException.Create('Cannot assign incompatible socket (TStreamSocket.Create)');

  inherited Create(ASocket);
end;

constructor TStreamSocket.Create(AFamily: TAddressFamily);
begin
  inherited Create(TStreamSocketImpl.Create(AFamily));
end;

destructor TStreamSocket.Destroy;
begin

  inherited;
end;

function TStreamSocket.ReceiveBytes(ABuffer: Pointer; ALength, AFlags: Integer): Integer;
begin
  result := Impl.ReceiveBytes(ABuffer, ALength, AFlags);
end;

function TStreamSocket.SendBytes(ABuffer: Pointer; ALength, AFlags: Integer): Integer;
begin
	result := Impl.SendBytes(ABuffer, ALength, AFlags);
end;

procedure TStreamSocket.SendUrgent(AData: AnsiChar);
begin
	Impl.SendUrgent(AData);
end;

function TStreamSocket.Shutdown: Integer;
begin
  result := Impl.Shutdown;
end;

procedure TStreamSocket.ShutdownReceive;
begin
  Impl.ShutdownReceive;
end;

function TStreamSocket.ShutdownSend: Integer;
begin
  result := Impl.ShutdownSend;
end;

end.
