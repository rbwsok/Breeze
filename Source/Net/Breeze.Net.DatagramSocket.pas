unit Breeze.Net.DatagramSocket;

interface

uses Winapi.Winsock2,
Breeze.Net.SocketDefs, Breeze.Net.Socket, Breeze.Net.SocketImpl, Breeze.Net.SocketAddress, Breeze.Net.DatagramSocketImpl, Breeze.Exception;

type

  TDatagramSocket = class(Breeze.Net.Socket.TSocket)
  public
  	constructor Create; overload;
		/// Creates an unconnected, unbound datagram socket.
		///
		/// Before the datagram socket can be used, bind(),
		/// bind6() or connect() must be called.
		///
		/// Notice: The behavior of this constructor has changed
		/// in release 2.0. Previously, the constructor created
		/// an unbound IPv4 datagram socket.
	  constructor Create(AFamily: TAddressFamily); overload;
		/// Creates an unconnected datagram socket.
		///
		/// The socket will be created for the
		/// given address family.
	  constructor Create(const AAddress: TSocketAddress; AReuseAddress: Boolean; AReusePort: Boolean = false; AIpV6Only: Boolean = false); overload;
		/// Creates a datagram socket and binds it
		/// to the given address.
		///
		/// Depending on the address family, the socket
		/// will be either an IPv4 or an IPv6 socket.
		/// If ipV6Only is true, socket will be bound
		/// to the IPv6 address only.
	  constructor Create(const ASocket: Breeze.Net.Socket.TSocket); overload;
		/// Creates the DatagramSocket with the SocketImpl
		/// from another socket. The SocketImpl must be
		/// a DatagramSocketImpl, otherwise an InvalidArgumentException
		/// will be thrown.
	  destructor Destroy; override;
		/// Destroys the DatagramSocket.
	  procedure Assign(const ASocket: Breeze.Net.Socket.TSocket); override;
		/// Assignment operator.
		///
		/// Releases the socket's SocketImpl and
		/// attaches the SocketImpl from the other socket and
		/// increments the reference count of the SocketImpl.

  	procedure Connect(const AAddress: TSocketAddress);
		/// Restricts incoming and outgoing
		/// packets to the specified address.
		///
		/// Calls to connect() cannot come before calls to bind().
    procedure Bind(const AAddress: TSocketAddress; AReuseAddress: Boolean = false); overload;
		/// Bind a local address to the socket.
		///
		/// This is usually only done when establishing a server
		/// socket.
		///
		/// If reuseAddress is true, sets the SO_REUSEADDR
		/// socket option.
		///
		/// Calls to connect() cannot come before calls to bind().
   	procedure Bind(const AAddress: TSocketAddress; AReuseAddress: Boolean; AReusePort: Boolean); overload;
		/// Bind a local address to the socket.
		///
		/// This is usually only done when establishing a server
		/// socket.
		///
		/// If reuseAddress is true, sets the SO_REUSEADDR
		/// socket option.
		///
		/// If reusePort is true, sets the SO_REUSEPORT
		/// socket option.
		///
		/// Calls to connect() cannot come before calls to bind().
  	procedure Bind6(const AAddress: TSocketAddress; AReuseAddress: Boolean; AReusePort: Boolean; AIpV6Only: Boolean = false); overload;
		/// Bind a local address to the socket.
		///
		/// This is usually only done when establishing a server
		/// socket.
		///
		/// If reuseAddress is true, sets the SO_REUSEADDR
		/// socket option.
		///
		/// If reusePort is true, sets the SO_REUSEPORT
		/// socket option.
		///
		/// Sets the IPV6_V6ONLY socket option in accordance with
		/// the supplied ipV6Only value.
		///
		/// Calls to connect() cannot come before calls to bind().
    function SendBytes(ABuffer: Pointer; ALength: Integer; AFlags: Integer = 0): Integer; virtual;
		/// Sends the contents of the given buffer through
		/// the socket.
		///
		/// Returns the number of bytes sent, which may be
		/// less than the number of bytes specified.
		///
		/// The flags parameter can be used to pass system-defined flags
		/// for send() like MSG_DONTROUTE.
//	int sendBytes(const SocketBufVec& buffer, int flags = 0);
		/// Sends the contents of the given buffers through
		/// the socket.
		///
		/// Returns the number of bytes sent, which may be
		/// less than the number of bytes specified.
		///
		/// The flags parameter can be used to pass system-defined flags
		/// for send() like MSG_DONTROUTE.
    function ReceiveBytes(ABuffer: Pointer; ALength: Integer; AFlags: Integer = 0): Integer;
		/// Receives data from the socket and stores it
		/// in buffer. Up to length bytes are received.
		///
		/// Returns the number of bytes received.
		///
		/// The flags parameter can be used to pass system-defined flags
		/// for recv() like MSG_PEEK.
//	int receiveBytes(SocketBufVec& buffer, int flags = 0);
		/// Receives data from the socket and stores it in buffers.
		///
		/// Returns the number of bytes received.
		///
		/// The flags parameter can be used to pass system-defined flags
		/// for recv() like MSG_PEEK.
//	int receiveBytes(Poco::Buffer<char>& buffer, int flags = 0, const Poco::Timespan& timeout = 100000);
		/// Receives data from the socket and stores it in buffers.
		///
		/// Returns the number of bytes received.
		///
		/// The flags parameter can be used to pass system-defined flags
		/// for recv() like MSG_PEEK.
    function SendTo(ABuffer: Pointer; ALength: Integer; const AAddress: TSocketAddress; AFlags: Integer = 0): Integer;
		/// Sends the contents of the given buffer through
		/// the socket to the given address.
		///
		/// Returns the number of bytes sent, which may be
		/// less than the number of bytes specified.
		///
		/// The flags parameter can be used to pass system-defined flags
		/// for sendto() like MSG_DONTROUTE.
//	int sendTo(const SocketBufVec& buffers, const SocketAddress& address, int flags = 0);
		/// Sends the contents of the given buffers through
		/// the socket to the given address.
		///
		/// Returns the number of bytes sent, which may be
		/// less than the number of bytes specified.
		///
		/// The flags parameter can be used to pass system-defined flags
		/// for sendto() like MSG_DONTROUTE.
    function ReceiveFrom(ABuffer: Pointer; ALength: Integer; var AAddress: TSocketAddress; AFlags: Integer = 0): Integer; overload;
		/// Receives data from the socket and stores it
		/// in buffer. Up to length bytes are received.
		/// Stores the address of the sender in address.
		///
		/// Returns the number of bytes received.
		///
		/// The flags parameter can be used to pass system-defined flags
		/// for recvfrom() like MSG_PEEK.
    function ReceiveFrom(ABuffer: Pointer; ALength: Integer; var ANativeAddress: TSockAddr; var ANativeAddressLen: Integer; AFlags: Integer = 0): Integer; overload;
		/// Receives data from the socket and stores it
		/// in buffer. Up to length bytes are received.
		/// Stores the native address of the sender in
		/// ppSA, and the length of native address in ppSALen.
		///
		/// Returns the number of bytes received.
		///
		/// The flags parameter can be used to pass system-defined flags
		/// for recvfrom() like MSG_PEEK.
//	int receiveFrom(SocketBufVec& buffers, SocketAddress& address, int flags = 0);
		/// Receives data from the socket and stores it
		/// in buffers. Up to total length of all buffers
		/// are received.
		/// Stores the address of the sender in address.
		///
		/// Returns the number of bytes received.
		///
		/// The flags parameter can be used to pass system-defined flags
		/// for recvfrom() like MSG_PEEK.
//	int receiveFrom(SocketBufVec& buffers, struct sockaddr** ppSA, poco_socklen_t** ppSALen, int flags = 0);
		/// Receives data from the socket and stores it
		/// in buffers.
		/// Stores the native address of the sender in
		/// ppSA, and the length of native address in ppSALen.
		///
		/// Returns the number of bytes received.
		///
		/// The flags parameter can be used to pass system-defined flags
		/// for recvfrom() like MSG_PEEK.
    procedure SetBroadcast(AFlag: Boolean);
		/// Sets the value of the SO_BROADCAST socket option.
		///
		/// Setting this flag allows sending datagrams to
		/// the broadcast address.
    function GetBroadcast: Boolean;
		/// Returns the value of the SO_BROADCAST socket option.
  protected
	  constructor Create(ASocketImpl: TSocketImpl); overload;
		/// Creates the Socket and attaches the given SocketImpl.
		/// The socket takes ownership of the SocketImpl.
		///
		/// The SocketImpl must be a DatagramSocketImpl, otherwise
		/// an InvalidArgumentException will be thrown.
  end;

Implementation

function TDatagramSocket.ReceiveBytes(ABuffer: Pointer; ALength, AFlags: Integer): Integer;
begin
	result := Impl.receiveBytes(ABuffer, ALength, AFlags);
end;

function TDatagramSocket.ReceiveFrom(ABuffer: Pointer; ALength: Integer; var ANativeAddress: TSockAddr; var ANativeAddressLen: Integer; AFlags: Integer): Integer;
begin
	result := Impl.receiveFrom(ABuffer, ALength, ANativeAddress, ANativeAddressLen, AFlags);
end;

function TDatagramSocket.ReceiveFrom(ABuffer: Pointer; ALength: Integer; var AAddress: TSocketAddress; AFlags: Integer): Integer;
begin
	result := Impl.receiveFrom(ABuffer, ALength, AAddress, AFlags);
end;

function TDatagramSocket.SendBytes(ABuffer: Pointer; ALength, AFlags: Integer): Integer;
begin
	result := Impl.sendBytes(ABuffer, ALength, AFlags);
end;

function TDatagramSocket.SendTo(ABuffer: Pointer; ALength: Integer; const AAddress: TSocketAddress; AFlags: Integer): Integer;
begin
	result := Impl.sendTo(ABuffer, ALength, AAddress, AFlags);
end;

procedure TDatagramSocket.SetBroadcast(AFlag: Boolean);
begin
	Impl.setBroadcast(AFlag);
end;

procedure TDatagramSocket.Assign(const ASocket: Breeze.Net.Socket.TSocket);
begin
  if not (ASocket is TDatagramSocket) then
		raise InvalidArgumentException.Create('Cannot assign incompatible socket (TDatagramSocket.Assign)');

  inherited Assign(ASocket);
end;

procedure TDatagramSocket.Bind(const AAddress: TSocketAddress; AReuseAddress: Boolean);
begin
	Impl.bind(AAddress, AReuseAddress);
end;

procedure TDatagramSocket.Bind(const AAddress: TSocketAddress; AReuseAddress, AReusePort: Boolean);
begin
	Impl.bind(AAddress, AReuseAddress, AReusePort);
end;

procedure TDatagramSocket.Bind6(const AAddress: TSocketAddress; AReuseAddress, AReusePort, AIpV6Only: Boolean);
begin
	Impl.bind6(AAddress, AReuseAddress, AReusePort, AIpV6Only);
end;

procedure TDatagramSocket.Connect(const AAddress: TSocketAddress);
begin
	Impl.connect(AAddress);
end;

constructor TDatagramSocket.Create(const AAddress: TSocketAddress; AReuseAddress, AReusePort, AIpV6Only: Boolean);
begin
  inherited Create(TDatagramSocketImpl.Create(AAddress.family));

	if AAddress.family = TAddressFamily.IPv6 then
		bind6(AAddress, AReuseAddress, AReusePort, AIpV6Only)
	else
    bind(AAddress, AReuseAddress, AReusePort);
end;

constructor TDatagramSocket.Create(const ASocket: Breeze.Net.Socket.TSocket);
begin
  if not (ASocket is TDatagramSocket) then
		raise InvalidArgumentException.Create('Cannot assign incompatible socket (TDatagramSocket.Create)');

  inherited Create(ASocket);
end;

constructor TDatagramSocket.Create;
begin
  inherited Create(TDatagramSocketImpl.Create);
end;

constructor TDatagramSocket.Create(AFamily: TAddressFamily);
begin
  inherited Create(TDatagramSocketImpl.Create(AFamily));
end;

constructor TDatagramSocket.Create(ASocketImpl: TSocketImpl);
begin
  if not (ASocketImpl is TDatagramSocketImpl) then
		raise InvalidArgumentException.Create('Cannot assign incompatible socket (TDatagramSocket.Create Impl)');

  inherited Create(ASocketImpl);
end;

destructor TDatagramSocket.Destroy;
begin

  inherited;
end;

function TDatagramSocket.GetBroadcast: Boolean;
begin
	result := Impl.GetBroadcast;
end;

end.

