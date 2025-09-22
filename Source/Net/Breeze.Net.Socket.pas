unit Breeze.Net.Socket;

interface

uses
  Winapi.Winsock2,
  Breeze.Net.SocketAddress, Breeze.Net.SocketImpl, Breeze.Exception, Breeze.Net.SocketDefs;

type

  TSocket = class
	/// Socket is the common base class for
	/// StreamSocket, ServerSocket, DatagramSocket and other
	/// socket classes.
	///
	/// It provides operations common to all socket types.
  public
  	constructor Create; overload;
		/// Creates an uninitialized socket.
	  constructor Create(const ASocket: Breeze.Net.Socket.TSocket); overload;
		/// Copy constructor.
		///
		/// Attaches the SocketImpl from the other socket and
		/// increments the reference count of the SocketImpl.
//	Socket& operator = (const Socket& socket);
    procedure Assign(const ASocket: Breeze.Net.Socket.TSocket); virtual;
		/// Assignment operator.
		///
		/// Releases the socket's SocketImpl and
		/// attaches the SocketImpl from the other socket and
		/// increments the reference count of the SocketImpl.
//	class function fromFileDescriptor(poco_socket_t fd): TSocket; static;
		// Creates a socket from an existing file descriptor.
		// Ownership is taken by poco
  	destructor Destroy; override;
		/// Destroys the Socket and releases the
		/// SocketImpl.
//	bool operator == (const Socket& socket) const;
    function IsEqual(const ASocket: Breeze.Net.Socket.TSocket): Boolean;
		/// Returns true if both sockets share the same
		/// SocketImpl, false otherwise.
//	bool operator != (const Socket& socket) const;
    function IsNotEqual(const ASocket: Breeze.Net.Socket.TSocket): Boolean;
		/// Returns false if both sockets share the same
		/// SocketImpl, true otherwise.

  //	bool isNull() const;
    function IsNull: Boolean;
		/// Returns true if pointer to implementation is null.
//	Type type() const;
    function SocketType: TSocketType;
		/// Returns the socket type.
//  bool isStream() const;
    function IsStream: Boolean;
		/// Returns true if socket is a stream socket,
		/// false otherwise.
//	bool isDatagram() const;
    function IsDatagram: Boolean;
		/// Returns true if socket is a datagram socket,
		/// false otherwise.
//	bool isRaw() const;
    function IsRaw: Boolean;
		/// Returns true if socket is a raw socket,
		/// false otherwise.
//	void close();
    procedure Close;
		/// Closes the socket.
    function Poll(ATimeout: Integer; AMode: TPollMode): Boolean;
//	function poll(const Poco::Timespan& timeout; mode: Integer): Boolean;
		/// Determines the status of the socket, using a
		/// call to poll() or select().
		///
		/// The mode argument is constructed by combining the values
		/// of the SelectMode enumeration.
		///
		/// Returns true if the next operation corresponding to
		/// mode will not block, false otherwise.
//	int available() const;
    function Available: Integer;
		/// Returns the number of bytes available that can be read
		/// without causing the socket to block.
//	int getError() const;
  	function GetError: Integer;
		/// Returns the socket error.
//	void setSendBufferSize(int size);
  	procedure SetSendBufferSize(ASize: Integer);
		/// Sets the size of the send buffer.
	//int getSendBufferSize() const;
    function GetSendBufferSize: Integer;
		/// Returns the size of the send buffer.
		///
		/// The returned value may be different than the
		/// value previously set with setSendBufferSize(),
		/// as the system is free to adjust the value.
//	void setReceiveBufferSize(int size);
  	procedure SetReceiveBufferSize(ASize: Integer);
		/// Sets the size of the receive buffer.
//	int getReceiveBufferSize() const;
  	function GetReceiveBufferSize: Integer;
		/// Returns the size of the receive buffer.
		///
		/// The returned value may be different than the
		/// value previously set with setReceiveBufferSize(),
		/// as the system is free to adjust the value.

	  procedure SetSendTimeout(ATimeout: Cardinal);
		/// Sets the send timeout for the socket.
	  function GetSendTimeout: Cardinal;
		/// Returns the send timeout for the socket.
		///
		/// The returned timeout may be different than the
		/// timeout previously set with setSendTimeout(),
		/// as the system is free to adjust the value.
    procedure SetReceiveTimeout(ATimeout: Cardinal);
		/// Sets the receive timeout for the socket.
		///
		/// On systems that do not support SO_RCVTIMEO, a
		/// workaround using poll() is provided.
	  function GetReceiveTimeout: Cardinal;
		/// Returns the receive timeout for the socket.
		///
		/// The returned timeout may be different than the
		/// timeout previously set with getReceiveTimeout(),
		/// as the system is free to adjust the value.
    procedure SetOption(ALevel: Integer; AOption: Integer; AValue: Integer); overload;
		/// Sets the socket option specified by level and option
		/// to the given integer value.
    procedure SetOption(ALevel: Integer; AOption: Integer; AValue: Cardinal); overload;
		/// Sets the socket option specified by level and option
		/// to the given integer value.
    procedure SetOption(ALevel: Integer; AOption: Integer; AValue: Byte); overload;
		/// Sets the socket option specified by level and option
		/// to the given integer value.
//	void setOption(int level, int option, const Poco::Timespan& value);
		/// Sets the socket option specified by level and option
		/// to the given time value.
//	void setOption(int level, int option, const IPAddress& value);
		/// Sets the socket option specified by level and option
		/// to the given time value.
    procedure GetOption(ALevel: Integer; AOption: Integer; var AValue: Integer); overload;
		/// Returns the value of the socket option
		/// specified by level and option.
    procedure GetOption(ALevel: Integer; AOption: Integer; var AValue: Cardinal); overload;
		/// Returns the value of the socket option
		/// specified by level and option.
    procedure GetOption(ALevel: Integer; AOption: Integer; var AValue: Byte); overload;
		/// Returns the value of the socket option
		/// specified by level and option.
//	void getOption(int level, int option, Poco::Timespan& value) const;
		/// Returns the value of the socket option
		/// specified by level and option.
//	void getOption(int level, int option, IPAddress& value) const;
		/// Returns the value of the socket option
		/// specified by level and option.
    procedure SetLinger(AOnValue: Boolean; ASeconds: Integer);
		/// Sets the value of the SO_LINGER socket option.
    procedure GetLinger(var AOnValue: Boolean; var ASeconds: Integer);
		/// Returns the value of the SO_LINGER socket option.
    procedure SetNoDelay(AFlag: Boolean);
		/// Sets the value of the TCP_NODELAY socket option.
    function GetNoDelay: Boolean;
		/// Returns the value of the TCP_NODELAY socket option.
    procedure SetKeepAlive(AFlag: Boolean);
		/// Sets the value of the SO_KEEPALIVE socket option.
    function GetKeepAlive: Boolean;
		/// Returns the value of the SO_KEEPALIVE socket option.
    procedure SetReuseAddress(AFlag: Boolean);
		/// Sets the value of the SO_REUSEADDR socket option.
    function GetReuseAddress: Boolean;
		/// Returns the value of the SO_REUSEADDR socket option.
    procedure SetReusePort(AFlag: Boolean);
		/// Sets the value of the SO_REUSEPORT socket option.
		/// Does nothing if the socket implementation does not
		/// support SO_REUSEPORT.
    function GetReusePort: Boolean;
		/// Returns the value of the SO_REUSEPORT socket option.
		///
		/// Returns false if the socket implementation does not
		/// support SO_REUSEPORT.
    procedure SetOOBInline(AFlag: Boolean);
		/// Sets the value of the SO_OOBINLINE socket option.
    function GetOOBInline: Boolean;
		/// Returns the value of the SO_OOBINLINE socket option.
    procedure SetBlocking(AFlag: Boolean);
		/// Sets the socket in blocking mode if flag is true,
		/// disables blocking mode if flag is false.
    function GetBlocking: Boolean;
		/// Returns the blocking mode of the socket.
		/// This method will only work if the blocking modes of
		/// the socket are changed via the setBlocking method!
  	function Address: TSocketAddress;
		/// Returns the IP address and port number of the socket.
  	function PeerAddress: TSocketAddress;
		/// Returns the IP address and port number of the peer socket.
	  function Impl: TSocketImpl; inline;
		/// Returns the SocketImpl for this socket.
	  function Secure: Boolean;
		/// Returns true iff the socket's connection is secure
		/// (using SSL or TLS).
	  class function SupportsIPv4: Boolean;
		/// Returns true if the system supports IPv4.
	  class function SupportsIPv6: Boolean;
		/// Returns true if the system supports IPv6.
	  procedure Init(ANativeFamily: Integer);
		/// Creates the underlying system socket for the given
		/// address family.
		///
		/// Normally, this method should not be called directly, as
		/// socket creation will be handled automatically. There are
		/// a few situations where calling this method after creation
		/// of the Socket object makes sense. One example is setting
		/// a socket option before calling bind() on a ServerSocket.
    class function LastError: Integer;
		/// Returns the last error code.
    class function LastErrorDesc: String;
		/// Returns the last error description.
    class procedure Error;
		/// Throws an appropriate exception for the last error.
  	function NativeSocket: Winapi.Winsock2.TSocket;
		/// Returns the socket descriptor for this socket.

    function ToString: String; override;
  protected
    constructor Create(ASocketImpl: TSocketImpl); overload;
		/// Creates the Socket and attaches the given SocketImpl.
		/// The socket takes ownership of the SocketImpl.
  private
    FImpl: TSocketImpl;
  end;

implementation

{ TSocket }

function TSocket.Address: TSocketAddress;
begin
	result := FImpl.Address;
end;

procedure TSocket.Assign(const ASocket: Breeze.Net.Socket.TSocket);
begin
  if ASocket <> self then
  begin
    FImpl.Assign(ASocket.impl);
//  	_pImpl.Free;
//	  _pImpl := s._pImpl;
//  	if (_pImpl)
//      _pImpl->duplicate();
  end;
end;

function TSocket.Available: Integer;
begin
	result := FImpl.Available;
end;

procedure TSocket.Close;
begin
  if FImpl <> nil then
    FImpl.Close;
end;

constructor TSocket.Create(ASocketImpl: TSocketImpl);
begin
	FImpl := ASocketImpl;

	if FImpl = nil then
    raise NullPointerException.Create('NULL pointer: TBaseSocket.Create');
end;

constructor TSocket.Create;
begin
  FImpl := TSocketImpl.Create;
end;

constructor TSocket.Create(const ASocket: Breeze.Net.Socket.TSocket);
begin
  FImpl := TSocketImpl.Create;
  FImpl.Assign(ASocket.FImpl);

	if FImpl = nil then
    raise NullPointerException.Create('NULL pointer: TBaseSocket.Create');
end;

destructor TSocket.Destroy;
begin
  FImpl.Free;
  inherited;
end;

class procedure TSocket.Error;
begin
	TSocketImpl.Error;
end;

function TSocket.GetBlocking: Boolean;
begin
  result := FImpl.GetBlocking;
end;

function TSocket.GetError: Integer;
begin
  result := FImpl.GetError;
end;

function TSocket.GetKeepAlive: Boolean;
begin
  result := FImpl.GetKeepAlive;
end;

procedure TSocket.GetLinger(var AOnValue: Boolean; var ASeconds: Integer);
begin
  FImpl.GetLinger(AOnValue, ASeconds);
end;

function TSocket.GetNoDelay: Boolean;
begin
  result := FImpl.GetNoDelay;
end;

function TSocket.GetOOBInline: Boolean;
begin
  result := FImpl.GetOOBInline;
end;

procedure TSocket.GetOption(ALevel, AOption: Integer; var AValue: Byte);
begin
  FImpl.GetOption(ALevel, AOption, AValue);
end;

procedure TSocket.GetOption(ALevel, AOption: Integer; var AValue: Cardinal);
begin
  FImpl.GetOption(ALevel, AOption, AValue);
end;

procedure TSocket.GetOption(ALevel, AOption: Integer; var AValue: Integer);
begin
  FImpl.GetOption(ALevel, AOption, AValue);
end;

function TSocket.GetReceiveBufferSize: Integer;
begin
  result := FImpl.GetReceiveBufferSize;
end;

function TSocket.GetReceiveTimeout: Cardinal;
begin
  result := FImpl.GetReceiveTimeout;
end;

function TSocket.GetReuseAddress: Boolean;
begin
  result := FImpl.GetReuseAddress;
end;

function TSocket.GetReusePort: Boolean;
begin
  result := FImpl.GetReusePort;
end;

function TSocket.GetSendBufferSize: Integer;
begin
  result := FImpl.GetSendBufferSize;
end;

function TSocket.GetSendTimeout: Cardinal;
begin
  result := FImpl.GetSendTimeout;
end;

function TSocket.Impl: TSocketImpl;
begin
	result := FImpl;
end;

procedure TSocket.Init(ANativeFamily: Integer);
begin
  FImpl.init(ANativeFamily);
end;

function TSocket.IsDatagram: Boolean;
begin
  result := SocketType = TSocketType.SOCKET_TYPE_DATAGRAM;
end;

function TSocket.IsEqual(const ASocket: TSocket): Boolean;
begin
  result := FImpl = ASocket.FImpl;
end;

function TSocket.IsNotEqual(const ASocket: TSocket): Boolean;
begin
  result := FImpl <> ASocket.FImpl;
end;

function TSocket.IsNull: Boolean;
begin
  result := FImpl = nil;
end;

function TSocket.IsRaw: Boolean;
begin
  result := SocketType = TSocketType.SOCKET_TYPE_RAW;
end;

function TSocket.IsStream: Boolean;
begin
  result := SocketType = TSocketType.SOCKET_TYPE_STREAM;
end;

class function TSocket.LastError: Integer;
begin
	result := TSocketImpl.LastError;
end;

class function TSocket.LastErrorDesc: String;
begin
//	result := Error::getMessage(TSocketImpl.lastError);
end;

function TSocket.PeerAddress: TSocketAddress;
begin
	result := FImpl.PeerAddress;
end;

function TSocket.Poll(ATimeout: Integer; AMode: TPollMode): Boolean;
begin
  result := FImpl.Poll(ATimeout, AMode);
end;

function TSocket.Secure: Boolean;
begin
	result := FImpl.Secure;
end;

procedure TSocket.SetBlocking(AFlag: Boolean);
begin
  FImpl.SetBlocking(AFlag);
end;

procedure TSocket.SetKeepAlive(AFlag: Boolean);
begin
  FImpl.SetKeepAlive(AFlag);
end;

procedure TSocket.SetLinger(AOnValue: Boolean; ASeconds: Integer);
begin
  FImpl.SetLinger(AOnValue, ASeconds);
end;

procedure TSocket.SetNoDelay(AFlag: Boolean);
begin
  FImpl.SetNoDelay(AFlag);
end;

procedure TSocket.SetOOBInline(AFlag: Boolean);
begin
  FImpl.SetOOBInline(AFlag);
end;

procedure TSocket.SetOption(ALevel, AOption: Integer; AValue: Byte);
begin
	FImpl.SetOption(ALevel, AOption, AValue);
end;

procedure TSocket.SetOption(ALevel, AOption: Integer; AValue: Cardinal);
begin
	FImpl.SetOption(ALevel, AOption, AValue);
end;

procedure TSocket.SetOption(Alevel, AOption, AValue: Integer);
begin
	FImpl.SetOption(ALevel, AOption, AValue);
end;

procedure TSocket.SetReceiveBufferSize(ASize: Integer);
begin
  FImpl.SetReceiveBufferSize(ASize);
end;

procedure TSocket.SetReceiveTimeout(ATimeout: Cardinal);
begin
	FImpl.SetReceiveTimeout(ATimeout);
end;

procedure TSocket.setReuseAddress(AFlag: Boolean);
begin
  FImpl.SetReuseAddress(AFlag);
end;

procedure TSocket.SetReusePort(AFlag: Boolean);
begin
  FImpl.SetReusePort(AFlag);
end;

procedure TSocket.setSendBufferSize(ASize: Integer);
begin
  FImpl.SetSendBufferSize(ASize);
end;

procedure TSocket.SetSendTimeout(ATimeout: Cardinal);
begin
  FImpl.SetSendTimeout(ATimeout);
end;

function TSocket.SocketType: TSocketType;
begin
  result := FImpl.SocketType;
end;

function TSocket.NativeSocket: Winapi.Winsock2.TSocket;
begin
  result := FImpl.NativeSocket;
end;

class function TSocket.SupportsIPv4: Boolean;
begin
  result := true;
end;

class function TSocket.SupportsIPv6: Boolean;
begin
  result := true;
end;

function TSocket.ToString: String;
begin
  result := FImpl.ToString;
end;

end.
