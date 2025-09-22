unit Breeze.Net.RawSocket;

interface

uses Winapi.Winsock2,
Breeze.Net.Socket, Breeze.Net.SocketAddress, Breeze.Net.SocketDefs, Breeze.Net.SocketImpl, Breeze.Net.RawSocketImpl;

type
  TRawSocket = class(Breeze.Net.Socket.TSocket)
	/// This class provides an interface to a
	/// raw IP socket.
  public
    constructor Create(AImpl: TSocketImpl); overload;
		/// Creates the Socket and attaches the given SocketImpl.
		/// The socket takes ownership of the SocketImpl.
		///
		/// The SocketImpl must be a RawSocketImpl, otherwise
		/// an InvalidArgumentException will be thrown.

    constructor Create; overload;
		/// Creates an unconnected IPv4 raw socket.

    constructor Create(AFamily: TAddressFamily; AProtocol: Integer = IPPROTO_RAW); overload;
		/// Creates an unconnected raw socket.
		///
		/// The socket will be created for the
		/// given address family.

    constructor Create(const AAddress: TSocketAddress; AReuseAddress: Boolean = false); overload;
		/// Creates a raw socket and binds it
		/// to the given address.
		///
		/// Depending on the address family, the socket
		/// will be either an IPv4 or an IPv6 socket.

    constructor Create(const ASocket: Breeze.Net.Socket.TSocket); overload;
		/// Creates the RawSocket with the SocketImpl
		/// from another socket. The SocketImpl must be
		/// a RawSocketImpl, otherwise an InvalidArgumentException
		/// will be thrown.

   //    constructor Create(const RawSocket& socket);
  		/// Creates the RawSocket with the SocketImpl
		/// from another socket.

	  destructor Destroy; override;
		/// Destroys the RawSocket.

    procedure Assign(const ASocket: Breeze.Net.Socket.TSocket); override;
//	RawSocket& operator = (const Socket& socket);
		/// Assignment operator.
		///
		/// Releases the socket's SocketImpl and
		/// attaches the SocketImpl from the other socket and
		/// increments the reference count of the SocketImpl.

//	RawSocket& operator = (const RawSocket& socket);
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

    function SendBytes(ABuffer: Pointer; ALength: Integer; AFlags: Integer = 0): Integer;
		/// Sends the contents of the given buffer through
		/// the socket.
		///
		/// Returns the number of bytes sent, which may be
		/// less than the number of bytes specified.

    function ReceiveBytes(ABuffer: Pointer; ALength: Integer; AFlags: Integer = 0): Integer;
		/// Receives data from the socket and stores it
		/// in buffer. Up to length bytes are received.
		///
		/// Returns the number of bytes received.

    function SendTo(ABuffer: Pointer; ALength: Integer; const AAddress: TSocketAddress; AFlags: Integer = 0): Integer;
		/// Sends the contents of the given buffer through
		/// the socket to the given address.
		///
		/// Returns the number of bytes sent, which may be
		/// less than the number of bytes specified.

    function ReceiveFrom(ABuffer: Pointer; ALength: Integer; var AAddress: TSocketAddress; AFlags: Integer = 0): Integer;
		/// Receives data from the socket and stores it
		/// in buffer. Up to length bytes are received.
		/// Stores the address of the sender in address.
		///
		/// Returns the number of bytes received.

	  procedure SetBroadcast(AFlag: Boolean);
		/// Sets the value of the SO_BROADCAS3T socket option.
		///
		/// Setting this flag allows sending datagrams to
		/// the broadcast address.

	  function GetBroadcast: Boolean;
		/// Returns the value of the SO_BROADCAST socket option.
  end;

implementation

uses Breeze.Exception;

{ TRawSocket }

procedure TRawSocket.Assign(const ASocket: Breeze.Net.Socket.TSocket);
begin
  inherited;

end;

procedure TRawSocket.Bind(const AAddress: TSocketAddress; AReuseAddress, AReusePort: Boolean);
begin
  Impl.Bind(AAddress, AReuseAddress, AReusePort);
end;

procedure TRawSocket.Bind(const AAddress: TSocketAddress; AReuseAddress: Boolean);
begin
  Impl.Bind(AAddress, AReuseAddress);
end;

procedure TRawSocket.Connect(const AAddress: TSocketAddress);
begin
  Impl.Connect(AAddress);
end;

constructor TRawSocket.Create(AFamily: TAddressFamily; AProtocol: Integer);
begin
  inherited Create(TRawSocketImpl.Create(AFamily, AProtocol));
end;

constructor TRawSocket.Create(const AAddress: TSocketAddress; AReuseAddress: Boolean);
begin
  inherited Create(TRawSocketImpl.Create(AAddress.family));

	bind(AAddress, AReuseAddress);
end;

constructor TRawSocket.Create(const ASocket: Breeze.Net.Socket.TSocket);
begin
  if not (ASocket is TRawSocket) then
		raise InvalidArgumentException.Create('Cannot assign incompatible socket (TRawSocket.Create)');

  inherited Create(ASocket);
end;

constructor TRawSocket.Create;
begin
  inherited Create(TRawSocketImpl.Create);
end;

constructor TRawSocket.Create(AImpl: TSocketImpl);
begin
  if not (AImpl is TRawSocketImpl) then
		raise InvalidArgumentException.Create('Cannot assign incompatible socket (TRawSocket.Create Impl)');

  inherited Create(AImpl);
end;

destructor TRawSocket.Destroy;
begin

  inherited;
end;

function TRawSocket.GetBroadcast: Boolean;
begin
	result := Impl.GetBroadcast;
end;

function TRawSocket.ReceiveBytes(ABuffer: Pointer; ALength, AFlags: Integer): Integer;
begin
  result := Impl.ReceiveBytes(ABuffer, ALength, AFlags);
end;

function TRawSocket.ReceiveFrom(ABuffer: Pointer; ALength: Integer; var AAddress: TSocketAddress; AFlags: Integer): Integer;
begin
  result := Impl.ReceiveFrom(ABuffer, ALength, AAddress, AFlags);
end;

function TRawSocket.SendBytes(ABuffer: Pointer; ALength, AFlags: Integer): Integer;
begin
  result := Impl.SendBytes(ABuffer, ALength, AFlags);
end;

function TRawSocket.SendTo(ABuffer: Pointer; ALength: Integer; const AAddress: TSocketAddress; AFlags: Integer): Integer;
begin
  result := Impl.SendTo(ABuffer, ALength, AAddress, AFlags);
end;

procedure TRawSocket.setBroadcast(AFlag: Boolean);
begin
  Impl.SetBroadcast(AFlag);
end;

end.

