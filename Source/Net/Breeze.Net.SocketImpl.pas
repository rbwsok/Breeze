unit Breeze.Net.SocketImpl;

interface

uses Winapi.Windows, Winapi.Winsock2, Winapi.IpExport, System.SysUtils, System.Math, System.Win.Crtl,
  Breeze.Net.SocketAddress, Breeze.Net.IPAddress, Breeze.Net.SocketDefs, Breeze.Exception, wepoll, wepoll_types;

type
  TSocketImpl = class
	/// This class encapsulates the Berkeley sockets API.
	///
	/// Subclasses implement specific socket types like
	/// stream or datagram sockets.
	///
	/// You should not create any instances of this class.
(*
public:
	enum Type
	{
		SOCKET_TYPE_STREAM = SOCK_STREAM,
		SOCKET_TYPE_DATAGRAM = SOCK_DGRAM,
		SOCKET_TYPE_RAW = SOCK_RAW
	};
	enum SelectMode
	{
		SELECT_READ  = 1,
		SELECT_WRITE = 2,
		SELECT_ERROR = 4
	};*)
    private
	    FNativeSocket: Winapi.Winsock2.TSocket;
      FRecvTimeout: Cardinal;
      FSndTimeout: Cardinal;
      FBlocking: Boolean;
  	  FIsBrokenTimeout: Boolean;

      FConnectedAddress: TSocketAddress;

      function CheckIsBrokenTimeout: Boolean;
    public
      procedure Assign(const ASocketImpl: TSocketImpl);
//	virtual SocketImpl* acceptConnection(SocketAddress& clientAddr);
  	  function AcceptConnection(var AClientSocketAddress: TSocketAddress): TSocketImpl;
		/// Get the next completed connection from the
		/// socket's completed connection queue.
		///
		/// If the queue is empty, waits until a connection
		/// request completes.
		///
		/// Returns a new TCP socket for the connection
		/// with the client.
		///
		/// The client socket's address is returned in clientAddr.
//	virtual void connect(const SocketAddress& address);
    	procedure Connect(const ASocketAddress: TSocketAddress);
		/// Initializes the socket and establishes a connection to
		/// the TCP server at the given address.
		///
		/// Can also be used for UDP sockets. In this case, no
		/// connection is established. Instead, incoming and outgoing
		/// packets are restricted to the specified address.
//	virtual void connect(const SocketAddress& address, const Poco::Timespan& timeout);
		/// Initializes the socket, sets the socket timeout and
		/// establishes a connection to the TCP server at the given address.
//	virtual void connectNB(const SocketAddress& address);
    	procedure ConnectNB(const ASocketAddress: TSocketAddress);
		/// Initializes the socket and establishes a connection to
		/// the TCP server at the given address. Prior to opening the
		/// connection the socket is set to nonblocking mode.
//	virtual void bind(const SocketAddress& address, bool reuseAddress = false);
//    	procedure bind(const address: TSocketAddress; reuseAddress: Boolean = false); overload;
		/// Bind a local address to the socket.
		///
		/// This is usually only done when establishing a server
		/// socket. TCP clients should not bind a socket to a
		/// specific address.
		///
		/// If reuseAddress is true, sets the SO_REUSEADDR
		/// socket option.
//	virtual void bind(const SocketAddress& address, bool reuseAddress, bool reusePort);
    	procedure Bind(const ASocketAddress: TSocketAddress; AReuseAddress: Boolean = false; AReusePort: Boolean = false); overload;
		/// Bind a local address to the socket.
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
//	virtual void bind6(const SocketAddress& address, bool reuseAddress = false, bool ipV6Only = false);
    	procedure Bind6(const ASocketAddress: TSocketAddress; AReuseAddress: Boolean = false; AIPv6Only: Boolean = false); overload;
		/// Bind a local IPv6 address to the socket.
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
//	virtual void bind6(const SocketAddress& address, bool reuseAddress, bool reusePort, bool ipV6Only);
    	procedure Bind6(const ASocketAddress: TSocketAddress; AReuseAddress: Boolean; AReusePort: Boolean; AIPv6Only: Boolean); overload;
		/// Bind a local IPv6 address to the socket.
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
//	void useFileDescriptor(poco_socket_t fd);
		/// Use a external file descriptor for the socket. Required to be careful
		/// about what kind of file descriptor you're passing to make sure it's compatible
		/// with how you plan on using it. These specifics are platform-specific.
		/// Not valid to call this if the internal socket is already initialized.
		/// Poco takes ownership of the file descriptor, closing it when this socket is closed.
//	virtual void listen(int backlog = 64);
      procedure Listen(ABacklog: Integer = 64);
		/// Puts the socket into listening state.
		///
		/// The socket becomes a passive socket that
		/// can accept incoming connection requests.
		///
		/// The backlog argument specifies the maximum
		/// number of connections that can be queued
		/// for this socket.
//	virtual void close();
      procedure Close;
		/// Close the socket.
//	virtual void shutdownReceive();
      procedure ShutdownReceive;
		/// Shuts down the receiving part of the socket connection.
//	virtual int shutdownSend();
      function ShutdownSend: Integer;
		/// Shuts down the sending part of the socket connection.
		///
		/// Returns 0 for a non-blocking socket. May return
		/// a negative value for a non-blocking socket in case
		/// of a TLS connection. In that case, the operation should
		/// be retried once the underlying socket becomes writable.
//	virtual int shutdown();
    	function Shutdown: Integer;
		/// Shuts down both the receiving and the sending part
		/// of the socket connection.
		///
		/// Returns 0 for a non-blocking socket. May return
		/// a negative value for a non-blocking socket in case
		/// of a TLS connection. In that case, the operation should
		/// be retried once the underlying socket becomes writable.
//	virtual int sendBytes(const void* buffer, int length, int flags = 0);
	    function SendBytes(ABuffer: Pointer; ALength: Integer; AFlags: Integer = 0): Integer; virtual;
		/// Sends the contents of the given buffer through
		/// the socket.
		///
		/// Returns the number of bytes sent, which may be
		/// less than the number of bytes specified.
		///
		/// Certain socket implementations may also return a negative
		/// value denoting a certain condition.
//	virtual int sendBytes(const SocketBufVec& buffers, int flags = 0);
		/// Sends the contents of the given buffers through
		/// the socket.
		///
		/// Returns the number of bytes received.
		///
		/// Always returns zero for platforms where not implemented.
//	virtual int receiveBytes(void* buffer, int length, int flags = 0);
	    function ReceiveBytes(ABuffer: Pointer; ALength: Integer; AFlags: Integer = 0): Integer;
		/// Receives data from the socket and stores it
		/// in buffer. Up to length bytes are received.
		///
		/// Returns the number of bytes received.
		///
		/// Certain socket implementations may also return a negative
		/// value denoting a certain condition.
//	virtual int receiveBytes(SocketBufVec& buffers, int flags = 0);
		/// Receives data from the socket and stores it in buffers.
		///
		/// Returns the number of bytes received.
		///
		/// Always returns zero for platforms where not implemented.
//	virtual int receiveBytes(Poco::Buffer<char>& buffer, int flags = 0, const Poco::Timespan& timeout = 100000);
		/// Receives data from the socket and stores it in the buffer.
		/// If needed, the buffer will be resized to accomodate the
		/// data. Note that this function may impose additional
		/// performance penalties due to the check for the available
		/// amount of data.
		///
		/// Returns the number of bytes received.
//	virtual int sendTo(const void* buffer, int length, const SocketAddress& address, int flags = 0);
	    function SendTo(ABuffer: Pointer; ALength: Integer; const ASocketAddress: TSocketAddress; AFlags: Integer = 0): Integer;
		/// Sends the contents of the given buffer through
		/// the socket to the given address.
		///
		/// Returns the number of bytes sent, which may be
		/// less than the number of bytes specified.
//	virtual int sendTo(const SocketBufVec& buffers, const SocketAddress& address, int flags = 0);
		/// Sends the contents of the buffers through
		/// the socket to the given address.
		///
		/// Returns the number of bytes sent, which may be
		/// less than the number of bytes specified.
		///
		/// Always returns zero for platforms where not implemented.
//	int receiveFrom(void* buffer, int length, struct sockaddr** ppSA, poco_socklen_t** ppSALen, int flags = 0);
	    function ReceiveFrom(ABuffer: Pointer; ALength: Integer; var ASockAddr: TSockAddr; var ASockAddrLen: Integer; AFlags: Integer = 0): Integer; overload;
		/// Receives data from the socket and stores it
		/// in buffer. Up to length bytes are received.
		/// Stores the native address of the sender in
		/// ppSA, and the length of native address in ppSALen.
		///
		/// Returns the number of bytes received.
//	virtual int receiveFrom(void* buffer, int length, SocketAddress& address, int flags = 0);
	    function ReceiveFrom(ABuffer: Pointer; ALength: Integer; var ASocketAddress: TSocketAddress; AFlags: Integer = 0): Integer; overload;
		/// Receives data from the socket and stores it
		/// in buffer. Up to length bytes are received.
		/// Stores the address of the sender in address.
		///
		/// Returns the number of bytes received.
//	virtual int receiveFrom(SocketBufVec& buffers, SocketAddress& address, int flags = 0);
		/// Receives data from the socket and stores it
		/// in buffers.
		/// Stores the address of the sender in address.
		///
		/// Returns the number of bytes received.
		///
		/// Always returns zero for platforms where not implemented.
//	int receiveFrom(SocketBufVec& buffers, struct sockaddr** ppSA, poco_socklen_t** ppSALen, int flags);
		/// Receives data from the socket and stores it
		/// in buffers.
		/// Stores the native address of the sender in
		/// ppSA, and the length of native address in ppSALen.
		///
		/// Returns the number of bytes received.
//	virtual void sendUrgent(unsigned char data);
  	  procedure SendUrgent(FData: AnsiChar);
		/// Sends one byte of urgent data through
		/// the socket.
		///
		/// The data is sent with the MSG_OOB flag.
		///
		/// The preferred way for a socket to receive urgent data
		/// is by enabling the SO_OOBINLINE option.
//  virtual int available();
      function Available: Integer;
		/// Returns the number of bytes available that can be read
		/// without causing the socket to block.
    	function Poll(ATimeout: Integer; AMode: TPollMode): Boolean;
		/// Determines the status of the socket, using a
		/// call to select().
		///
		/// The mode argument is constructed by combining the values
		/// of the SelectMode enumeration.
		///
		/// Returns true if the next operation corresponding to
		/// mode will not block, false otherwise.
	    function SocketType: TSocketType;
		/// Returns the socket type.
//	 int getError();
	    function GetError: Integer;
		/// Returns the socket error.
//	virtual void setSendBufferSize(int size);
    	procedure SetSendBufferSize(ASize: Integer);
		/// Sets the size of the send buffer.
//	virtual int getSendBufferSize();
    	function GetSendBufferSize: Integer;
		/// Returns the size of the send buffer.
		///
		/// The returned value may be different than the
		/// value previously set with setSendBufferSize(),
		/// as the system is free to adjust the value.
//	virtual void setReceiveBufferSize(int size);
	    procedure SetReceiveBufferSize(size: Integer);
		/// Sets the size of the receive buffer.
//	virtual int getReceiveBufferSize();
	    function GetReceiveBufferSize: Integer;
		/// Returns the size of the receive buffer.
		///
		/// The returned value may be different than the
		/// value previously set with setReceiveBufferSize(),
		/// as the system is free to adjust the value.
      procedure SetSendTimeout(ATimeout: Cardinal);
		/// Sets the send timeout for the socket.
//	virtual Poco::Timespan getSendTimeout();
      function GetSendTimeout: Cardinal;
		/// Returns the send timeout for the socket.
		///
		/// The returned timeout may be different than the
		/// timeout previously set with setSendTimeout(),
		/// as the system is free to adjust the value.

	    procedure SetReceiveTimeout(timeout: Cardinal);
		/// Sets the receive timeout for the socket.
		///
		/// On systems that do not support SO_RCVTIMEO, a
		/// workaround using poll() is provided.
    	function GetReceiveTimeout: Cardinal;
		/// Returns the receive timeout for the socket.
		///
		/// The returned timeout may be different than the
		/// timeout previously set with setReceiveTimeout(),
		/// as the system is free to adjust the value.*)
	    function Address: TSocketAddress;
		/// Returns the IP address and port number of the socket.
//	virtual SocketAddress peerAddress();
	    function PeerAddress: TSocketAddress;
		/// Returns the IP address and port number of the peer socket.

//	void setOption(int level, int option, int value);
      procedure SetOption(ALevel: Cardinal; AOption: Cardinal; AValue: Integer); overload;
		/// Sets the socket option specified by level and option
		/// to the given integer value.
//	void setOption(int level, int option, unsigned value);
      procedure SetOption(ALevel: Cardinal; AOption: Cardinal; AValue: Cardinal); overload;
		/// Sets the socket option specified by level and option
		/// to the given integer value.
//	void setOption(int level, int option, unsigned char value);
      procedure SetOption(ALevel: Cardinal; AOption: Cardinal; AValue: Byte); overload;
		/// Sets the socket option specified by level and option
		/// to the given integer value.
//	void setOption(int level, int option, const Poco::Timespan& value);
		/// Sets the socket option specified by level and option
		/// to the given time value.
      procedure SetOption(ALevel: Cardinal; AOption: Cardinal; const AValue: TIPAddress); overload;
		/// Sets the socket option specified by level and option
		/// to the given time value.
//	virtual void setRawOption(int level, int option, const void* value, poco_socklen_t length);
      procedure SetRawOption(ALevel: Cardinal; AOption: Cardinal; AValue: Pointer; ALength: Integer);
		/// Sets the socket option specified by level and option
		/// to the given time value.
//	void getOption(int level, int option, int& value);
  	  procedure GetOption(ALevel: Cardinal; AOption: Cardinal; var AValue: Integer); overload;
		/// Returns the value of the socket option
		/// specified by level and option.
//	void getOption(int level, int option, unsigned& value);
  	  procedure GetOption(ALevel: Cardinal; AOption: Cardinal; var AValue: Cardinal); overload;
		/// Returns the value of the socket option
		/// specified by level and option.
//	void getOption(int level, int option, unsigned char& value);
    	procedure GetOption(ALevel: Cardinal; AOption: Cardinal; var AValue: Byte); overload;
		/// Returns the value of the socket option
		/// specified by level and option.
//	void getOption(int level, int option, Poco::Timespan& value);
		/// Returns the value of the socket option
		/// specified by level and option.
    	procedure GetOption(ALevel: Cardinal; AOption: Cardinal; var AValue: TIPAddress); overload;
		/// Returns the value of the socket option
		/// specified by level and option.
//	virtual void getRawOption(int level, int option, void* value, poco_socklen_t& length);
  	  procedure GetRawOption(ALevel: Cardinal; AOption: Cardinal; AValue: Pointer; var ALength: Integer);
		/// Returns the value of the socket option
		/// specified by level and option.

//	void setLinger(bool on, int seconds);
      procedure SetLinger(AOnValue: Boolean; ASeconds: Integer);
		/// Sets the value of the SO_LINGER socket option.
//	void getLinger(bool& on, int& seconds);
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
	    procedure SetBroadcast(AFlag: Boolean);
		/// Sets the value of the SO_BROADCAST socket option.
	    function GetBroadcast: Boolean;
		/// Returns the value of the SO_BROADCAST socket option.
    	procedure SetBlocking(AFlag: Boolean);
		/// Sets the socket in blocking mode if flag is true,
		/// disables blocking mode if flag is false.
    	function GetBlocking: Boolean;
		/// Returns the blocking mode of the socket.
		/// This method will only work if the blocking modes of
		/// the socket are changed via the setBlocking method!
    	function Secure: Boolean;
		/// Returns true iff the socket's connection is secure
		/// (using SSL or TLS).
	    function SocketError: Integer;
		/// Returns the value of the SO_ERROR socket option.

      property NativeSocket: Winapi.Winsock2.TSocket read FNativeSocket;
		/// Returns the socket descriptor for the
		/// underlying native socket.

//	void ioctl(poco_ioctl_request_t request, int& arg);
      procedure Ioctl(ARequest: Cardinal; var AArg: Integer); overload;
		/// A wrapper for the ioctl system call.
//	void ioctl(poco_ioctl_request_t request, void* arg);
      procedure Ioctl(ARequest: Cardinal; AArg: Pointer); overload;
		/// A wrapper for the ioctl system call.

    	function Initialized: Boolean;
		/// Returns true iff the underlying socket is initialized.
(*#ifdef POCO_HAVE_SENDFILE
	Int64 sendFile(FileInputStream &FileInputStream, UInt64 offset = 0);
		/// Sends file using system function
		/// for posix systems - with sendfile[64](...)
		/// for windows - with TransmitFile(...)
		///
		/// Returns the number of bytes sent, which may be
		/// less than the number of bytes specified.
		///
		/// Throws NetException (or a subclass) in case of any errors.
#endif
*)
//   protected
    	constructor Create; overload;
		/// Creates a SocketImpl.
      constructor Create(ANaviveSocket: Winapi.Winsock2.TSocket); overload;
		/// Creates a SocketImpl using the given native socket.
	    destructor Destroy; override;
		/// Destroys the SocketImpl.
		/// Closes the socket if it is still open.
	    procedure Init(ANativeFamily: Integer); virtual;
		/// Creates the underlying native socket.
		///
		/// Subclasses must implement this method so
		/// that it calls initSocket() with the
		/// appropriate arguments.
		///
		/// The default implementation creates a
		/// stream socket.
	    procedure InitSocket(ANaviveFamily: Integer; ASocketType: Integer; AProto: Integer = 0);
		/// Creates the underlying native socket.
		///
		/// The first argument, af, specifies the address family
		/// used by the socket, which should be either AF_INET or
		/// AF_INET6.
		///
		/// The second argument, type, specifies the type of the
		/// socket, which can be one of SOCK_STREAM, SOCK_DGRAM
		/// or SOCK_RAW.
		///
		/// The third argument, proto, is normally set to 0,
		/// except for raw sockets.
	    procedure Reset(fd: Winapi.Winsock2.TSocket = INVALID_SOCKET);
		/// Allows subclasses to set the socket manually, iff no valid socket is set yet.
  	  procedure CheckBrokenTimeout(mode: TPollMode);
      class function LastError: Integer;
		/// Returns the last error code.
      class procedure Error; overload;
		/// Throws an appropriate exception for the last error.
      class procedure Error(const AArg: String); overload;
		/// Throws an appropriate exception for the last error.
      class procedure Error(ACode: Integer); overload;
		/// Throws an appropriate exception for the given error code.
      class procedure Error(ACode: Integer; const AArg: String); overload;
		/// Throws an appropriate exception for the given error code.

    function ToString: String; override;
  end;

implementation

uses Breeze.Net.StreamSocketImpl;

{ TSocketImpl }

function TSocketImpl.AcceptConnection(var AClientSocketAddress: TSocketAddress): TSocketImpl;
var
  LNativeSocket: Winapi.Winsock2.TSocket;
	LBuffer: sockaddr_storage;
  LSockAddr: PSockAddr;
  LSockAddrLen: Integer;
begin
  result := nil;
	if FNativeSocket = INVALID_SOCKET then
    raise InvalidSocketException.Create('InvalidSocketException: TSocketImpl.acceptConnection');

  LSockAddr := @LBuffer;
	LSockAddrLen := sizeof(LBuffer);
	while true do
  begin
		LNativeSocket := Winapi.Winsock2.accept(FNativeSocket, LSockAddr, @LSockAddrLen);
  	if (LNativeSocket = INVALID_SOCKET) or (LastError = WSAEINTR) then
      continue;

    break;
  end;

	if LNativeSocket <> INVALID_SOCKET then
  begin
		AClientSocketAddress := TSocketAddress.Create(LSockAddr, LSockAddrLen);
		exit(TStreamSocketImpl.Create(LNativeSocket));
	end;

	Error; // will throw
end;

function TSocketImpl.Address: TSocketAddress;
var
	LBuffer: sockaddr_storage;
  LSockAddr: PSockAddr;
  LSockAddrLen: Integer;
  LReturn: Integer;
begin
	if FNativeSocket = INVALID_SOCKET then
    raise InvalidSocketException.Create('InvalidSocketException: TSocketImpl.address');

  LSockAddr := @LBuffer;
	LSockAddrLen := sizeof(LBuffer);

	LReturn := Winapi.Winsock2.getsockname(FNativeSocket, LSockAddr^, LSockAddrLen);

	if LReturn = 0 then
		exit(TSocketAddress.Create(LSockAddr, LSockAddrLen))
	else
		Error;

  result.Create;
end;

procedure TSocketImpl.Assign(const ASocketImpl: TSocketImpl);
begin

end;

function TSocketImpl.Available: Integer;
var
  LBuffer: RawByteString;
begin
	result := 0;
	Ioctl(FIONREAD, result);

	if (result > 0) and (socketType = TSocketType.SOCKET_TYPE_DATAGRAM) then
  begin
    SetLength(LBuffer, result);

		result := recvfrom(FNativeSocket, &LBuffer[1], result, MSG_PEEK, TSockAddr(nil^), Integer(nil^));
	end;
end;

procedure TSocketImpl.Bind(const ASocketAddress: TSocketAddress; AReuseAddress, AReusePort: Boolean);
var
  LError: Integer;
begin
	if FNativeSocket = INVALID_SOCKET then
		Init(ASocketAddress.NativeFamily);

  SetReuseAddress(AReuseAddress);
	SetReusePort(AReusePort);

  LError := Winapi.Winsock2.bind(FNativeSocket, ASocketAddress.Addr^, ASocketAddress.Length);
	if LError <> 0 then
		Error(ASocketAddress.ToString);
end;

{procedure TSocketImpl.bind(const address: TSocketAddress; reuseAddress: Boolean);
begin
  bind(address, reuseAddress, reuseAddress);
end;}

procedure TSocketImpl.Bind6(const ASocketAddress: TSocketAddress; AReuseAddress, AIPv6Only: Boolean);
begin
  Bind6(ASocketAddress, AReuseAddress, AReuseAddress, AIPv6Only);
end;

procedure TSocketImpl.Bind6(const ASocketAddress: TSocketAddress; AReuseAddress, AReusePort, AIPv6Only: Boolean);
var
  LError: Integer;
begin
	if ASocketAddress.family <> TAddressFamily.IPv6 then
		raise InvalidArgumentException.Create('SocketAddress must be an IPv6 address');
	if FNativeSocket = INVALID_SOCKET then
		Init(ASocketAddress.NativeFamily);

	SetOption(IPPROTO_IPV6, IPV6_V6ONLY, ifthen(AIPv6Only, 1, 0));
	SetReuseAddress(AReuseAddress);
	SetReusePort(AReusePort);
	LError := Winapi.Winsock2.bind(FNativeSocket, ASocketAddress.Addr^, ASocketAddress.Length);
	if LError <> 0 then
		Error(ASocketAddress.ToString);
end;

procedure TSocketImpl.checkBrokenTimeout(mode: TPollMode);
begin
	if FIsBrokenTimeout then
  begin
 (*		Poco::Timespan timeout = (mode == SELECT_READ) ? _recvTimeout : _sndTimeout;
		if (timeout.totalMicroseconds() != 0)
		{
			if (!poll(timeout, mode))
				throw TimeoutException();
		}*)
	end;
end;

procedure TSocketImpl.close;
begin
 	if FNativeSocket <> INVALID_SOCKET then
  begin
		Winapi.Winsock2.closesocket(FNativeSocket);
    FNativeSocket := INVALID_SOCKET;
	end;
end;

procedure TSocketImpl.Connect(const ASocketAddress: TSocketAddress);
var
  LReturn: Integer;
begin
	if FNativeSocket = INVALID_SOCKET then
		Init(ASocketAddress.NativeFamily);

  FConnectedAddress := ASocketAddress;

	while True do
  begin
		LReturn := Winapi.Winsock2.connect(FNativeSocket, ASocketAddress.Addr^, ASocketAddress.length);
  	if (LReturn <> 0) and (LastError = WSAEINTR) then
      continue
    else
      break;
  end;

	if LReturn <> 0 then
		Error(LastError, ASocketAddress.toString);
end;

procedure TSocketImpl.ConnectNB(const ASocketAddress: TSocketAddress);
var
  LReturn, LError: Integer;
begin
	if FNativeSocket = INVALID_SOCKET then
		init(ASocketAddress.NativeFamily);

  FConnectedAddress := ASocketAddress;

	setBlocking(false);
	LReturn := Winapi.Winsock2.connect(FNativeSocket, ASocketAddress.Addr^, ASocketAddress.length);
	if LReturn <> 0 then
  begin
		LError := LastError;
		if (LError <> WSAEINPROGRESS) and (LError <> WSAEWOULDBLOCK) then
			Error(LError, ASocketAddress.toString);
  end;
end;

function TSocketImpl.CheckIsBrokenTimeout: Boolean;
var
  LOSVersion: OSVERSIONINFO;
begin
  // on Windows 7 and lower, socket timeouts have a minimum of 500ms, use poll for timeouts on this case
  // https://social.msdn.microsoft.com/Forums/en-US/76620f6d-22b1-4872-aaf0-833204f3f867/minimum-timeout-value-for-sorcvtimeo
  LOSVersion.dwOSVersionInfoSize := sizeof(LOSVersion);
  if GetVersionEx(LOSVersion) = false then
    exit(true);
  result := (LOSVersion.dwMajorVersion < 6) or ((LOSVersion.dwMajorVersion = 6) and (LOSVersion.dwMinorVersion < 2));
end;

constructor TSocketImpl.Create(ANaviveSocket: Winapi.Winsock2.TSocket);
begin
	FNativeSocket := ANaviveSocket;
	FBlocking := true;
	FIsBrokenTimeout := CheckIsBrokenTimeout;
end;

constructor TSocketImpl.Create;
begin
	FNativeSocket := INVALID_SOCKET;
	FBlocking := true;
	FIsBrokenTimeout := CheckIsBrokenTimeout;
end;

destructor TSocketImpl.Destroy;
begin
  Close;
  inherited;
end;

class procedure TSocketImpl.Error;
begin
	Error(LastError, '');
end;

class procedure TSocketImpl.Error(ACode: Integer);
begin
	Error(ACode, '');
end;

class procedure TSocketImpl.Error(ACode: Integer; const AArg: String);
begin
	case ACode of
	  0:
      exit;
	  WSASYSNOTREADY:
		  raise NetException.CreateFmt('Net subsystem not ready %d', [ACode]);
    WSANOTINITIALISED:
		  raise NetException.CreateFmt('Net subsystem not initialized %d', [ACode]);
	  WSAEINTR:
  		raise IOException.CreateFmt('Interrupted %d', [ACode]);
    WSAEACCES:
	  	raise IOException.CreateFmt('Permission denied %d', [ACode]);
    WSAEFAULT:
		  raise IOException.CreateFmt('Bad address %d', [ACode]);
    WSAEINVAL:
  		raise InvalidArgumentException.CreateFmt('InvalidArgumentException %d', [ACode]);
    WSAEMFILE:
  		raise IOException.CreateFmt('Too many open files %d', [ACode]);
  	WSAEWOULDBLOCK:
	  	raise IOException.CreateFmt('Operation would block %d', [ACode]);
    WSAEINPROGRESS:
		  raise IOException.CreateFmt('Operation now in progress %d', [ACode]);
    WSAEALREADY:
  		raise IOException.CreateFmt('Operation already in progress %d', [ACode]);
    WSAENOTSOCK:
	  	raise IOException.CreateFmt('Socket operation attempted on non-socket %d', [ACode]);
    WSAEDESTADDRREQ:
		  raise NetException.CreateFmt('Destination address required %d', [ACode]);
    WSAEMSGSIZE:
		  raise NetException.CreateFmt('Message too long %d', [ACode]);
    WSAEPROTOTYPE:
		  raise NetException.CreateFmt('Wrong protocol type %d', [ACode]);
    WSAENOPROTOOPT:
		  raise NetException.CreateFmt('Protocol not available %d', [ACode]);
    WSAEPROTONOSUPPORT:
		  raise NetException.CreateFmt('Protocol not supported %d', [ACode]);
    WSAESOCKTNOSUPPORT:
		  raise NetException.CreateFmt('Socket type not supported %d', [ACode]);
    WSAEOPNOTSUPP:
		  raise NetException.CreateFmt('Operation not supported %d', [ACode]);
    WSAEPFNOSUPPORT:
		  raise NetException.CreateFmt('Protocol family not supported %d', [ACode]);
    WSAEAFNOSUPPORT:
		  raise NetException.CreateFmt('Address family not supported %d', [ACode]);
    WSAEADDRINUSE:
		  raise NetException.CreateFmt('Address already in use %s %d', [AArg, ACode]);
    WSAEADDRNOTAVAIL:
		  raise NetException.CreateFmt('Cannot assign requested address %s %d', [AArg, ACode]);
    WSAENETDOWN:
		  raise NetException.CreateFmt('Network is down %d', [ACode]);
    WSAENETUNREACH:
		  raise NetException.CreateFmt('Network is unreachable %d', [ACode]);
    WSAENETRESET:
		  raise NetException.CreateFmt('Network dropped connection on reset %d', [ACode]);
    WSAECONNABORTED:
  		raise ConnectionAbortedException.CreateFmt('ConnectionAbortedException %d', [ACode]);
    WSAECONNRESET:
  		raise ConnectionResetException.CreateFmt('ConnectionResetException %d', [ACode]);
    WSAENOBUFS:
  		raise IOException.CreateFmt('No buffer space available %d', [ACode]);
    WSAEISCONN:
		  raise NetException.CreateFmt('Socket is already connected %d', [ACode]);
    WSAENOTCONN:
		  raise NetException.CreateFmt('Socket is not connected %d', [ACode]);
    WSAESHUTDOWN:
		  raise NetException.CreateFmt('Cannot send after socket shutdown %d', [ACode]);
    WSAETIMEDOUT:
  		raise TimeoutException.CreateFmt('TimeoutException %d', [ACode]);
    WSAECONNREFUSED:
  		raise ConnectionRefusedException.CreateFmt('ConnectionRefusedException %d', [ACode]);
    WSAEHOSTDOWN:
		  raise NetException.CreateFmt('Host is down %s %d', [AArg, ACode]);
    WSAEHOSTUNREACH:
		  raise NetException.CreateFmt('No route to host %s %d', [AArg, ACode]);
    else
  		raise IOException.CreateFmt('%s %d', [AArg, ACode]);
  end;
end;

class procedure TSocketImpl.Error(const AArg: String);
begin
  Error(LastError, AArg);
end;

function TSocketImpl.getBlocking: Boolean;
begin
  result := FBlocking;
end;

function TSocketImpl.getBroadcast: Boolean;
var
  value: Integer;
begin
	getOption(SOL_SOCKET, SO_BROADCAST, value);
	result := value <> 0;
end;

function TSocketImpl.getError: Integer;
begin
	GetOption(SOL_SOCKET, SO_ERROR, result);
end;

function TSocketImpl.GetKeepAlive: Boolean;
var
  LValue: Integer;
begin
	GetOption(SOL_SOCKET, SO_KEEPALIVE, LValue);
	result := LValue <> 0;
end;

procedure TSocketImpl.GetLinger(var AOnValue: Boolean; var ASeconds: Integer);
var
  l: linger;
  len: Integer;
begin
	len := sizeof(l);
	getRawOption(SOL_SOCKET, SO_LINGER, @l, len);
	AOnValue := l.l_onoff <> 0;
	ASeconds := l.l_linger;
end;

function TSocketImpl.GetNoDelay: Boolean;
var
  LValue: Integer;
begin
	GetOption(IPPROTO_TCP, TCP_NODELAY, LValue);

	result := LValue <> 0;
end;

procedure TSocketImpl.GetOption(ALevel, AOption: Cardinal; var AValue: Integer);
var
  LLen: Integer;
begin
	LLen := sizeof(AValue);
	getRawOption(ALevel, AOption, @AValue, LLen);
end;

procedure TSocketImpl.getOption(ALevel, AOption: Cardinal; var AValue: Cardinal);
var
  LLen: Integer;
begin
	LLen := sizeof(AValue);
	getRawOption(ALevel, AOption, @AValue, LLen);
end;

function TSocketImpl.GetOOBInline: Boolean;
var
  LValue: Integer;
begin
	GetOption(SOL_SOCKET, SO_OOBINLINE, LValue);
	result := LValue <> 0;
end;

procedure TSocketImpl.GetOption(ALevel, AOption: Cardinal; var AValue: Byte);
var
  LLen: Integer;
begin
	LLen := sizeof(AValue);
	getRawOption(ALevel, AOption, @AValue, LLen);
end;

procedure TSocketImpl.GetRawOption(ALevel, AOption: Cardinal; AValue: Pointer; var ALength: Integer);
var
  rc: Integer;
begin
	if FNativeSocket = INVALID_SOCKET then
    raise InvalidSocketException.Create('InvalidSocketException: TSocketImpl.getRawOption');

	rc := Winapi.Winsock2.getsockopt(FNativeSocket, ALevel, AOption, PAnsiChar(AValue), ALength);
	if rc = -1 then
    error;
end;

function TSocketImpl.GetReceiveBufferSize: Integer;
begin
  GetOption(SOL_SOCKET, SO_RCVBUF, result);
end;

function TSocketImpl.GetReceiveTimeout: Cardinal;
begin
	GetOption(SOL_SOCKET, SO_RCVTIMEO, result);

	if FIsBrokenTimeout then
		result := FRecvTimeout;
end;

function TSocketImpl.GetReuseAddress: Boolean;
var
  LValue: Integer;
begin
	LValue := 0;
	GetOption(SOL_SOCKET, SO_REUSEADDR, LValue);
	result := LValue <> 0;
//	value := 0;
//	getOption(SOL_SOCKET, SO_EXCLUSIVEADDRUSE, value);
//	result := result and (value = 0);
end;

function TSocketImpl.GetReusePort: Boolean;
begin
  result := false;
end;

function TSocketImpl.GetSendBufferSize: Integer;
begin
	GetOption(SOL_SOCKET, SO_SNDBUF, result);
end;

function TSocketImpl.GetSendTimeout: Cardinal;
begin
	GetOption(SOL_SOCKET, SO_SNDTIMEO, result);

	if FIsBrokenTimeout then
		result := FSndTimeout;
end;

procedure TSocketImpl.Init(ANativeFamily: Integer);
begin
	InitSocket(ANativeFamily, SOCK_STREAM);
end;

function TSocketImpl.Initialized: Boolean;
begin
	result := FNativeSocket <> INVALID_SOCKET;
end;

procedure TSocketImpl.InitSocket(ANaviveFamily, ASocketType, AProto: Integer);
begin
  if FNativeSocket <> INVALID_SOCKET then
  	raise AssertionViolationException.Create('Assertion violation: TSocketImpl.initSocket');

	FNativeSocket := Winapi.Winsock2.socket(ANaviveFamily, ASocketType, AProto);
	if FNativeSocket = INVALID_SOCKET then
		Error;
end;

procedure TSocketImpl.Ioctl(ARequest: Cardinal; AArg: Pointer);
var
  rc: Integer;
begin
	rc := Winapi.Winsock2.ioctlsocket(FNativeSocket, ARequest, PCardinal(AArg)^);

	if rc <> 0 then
    error;
end;

procedure TSocketImpl.Ioctl(ARequest: Cardinal; var AArg: Integer);
var
  rc: Integer;
begin
	rc := ioctlsocket(FNativeSocket, ARequest, Cardinal(AArg));

	if rc <> 0 then
    error;
end;

class function TSocketImpl.LastError: Integer;
begin
  result := WSAGetLastError;
end;

procedure TSocketImpl.Listen(ABacklog: Integer);
var
  rc: Integer;
begin
	if FNativeSocket = INVALID_SOCKET then
    raise InvalidSocketException.Create('InvalidSocketException: TSocketImpl.listen');

	rc := Winapi.Winsock2.listen(FNativeSocket, ABacklog);
	if rc <> 0 then
    error;
end;

function TSocketImpl.PeerAddress: TSocketAddress;
var
	buffer: sockaddr_storage;
  pSA: PSockAddr;
  saLen: Integer;
  rc: Integer;
begin
	if FNativeSocket = INVALID_SOCKET then
    raise InvalidSocketException.Create('InvalidSocketException: TSocketImpl.address');

  pSA := @buffer;
	saLen := sizeof(buffer);

	rc := Winapi.Winsock2.getpeername(FNativeSocket, pSA^, saLen);

	if rc = 0 then
		exit(TSocketAddress.Create(pSA, saLen))
	else
		error;

  result.Create;
end;

{function TSocketImpl.poll(timeout: Integer; mode: TPollMode): Boolean;
var
	fdRead: TFDSet;
	fdWrite: TFDSet;
	fdExcept: TFDSet;
	errorCode: Integer;
	rc: Integer;
  tv: timeval;
begin
	if _sockfd = INVALID_SOCKET then
    raise InvalidSocketException.Create('InvalidSocketException: TSocketImpl.poll');
	FD_ZERO(fdRead);
	FD_ZERO(fdWrite);
	FD_ZERO(&fdExcept);
	if (Integer(mode) and Integer(TPollMode.SELECT_READ)) <> 0 then
		_FD_SET(_sockfd, fdRead);
	if (Integer(mode) and Integer(TPollMode.SELECT_WRITE)) <> 0 then
		_FD_SET(_sockfd, fdWrite);
	if (Integer(mode) and Integer(TPollMode.SELECT_ERROR)) <> 0 then
		_FD_SET(_sockfd, fdExcept);
  tv.tv_sec := timeout div 1000;
  tv.tv_usec := (timeout mod 1000) * 1000000;
	errorCode := ENOERR;
	while true do
  begin
    rc := Winapi.Winsock2.select(0, @fdRead, @fdWrite, @fdExcept, @tv);
    if rc < 0 then
    begin
      // ошибка
      errorCode := lastError;
      if errorCode = WSAEINTR then
        continue;
    end
    else
    if rc = 0 then
    begin
      // таймаут
      break;
    end
    else
    begin
      // событие
      break;
    end;
  end;

	if rc < 0 then
    error(errorCode);

	result := rc > 0;
end;
}
function TSocketImpl.Poll(ATimeout: Integer; AMode: TPollMode): Boolean;
var
  LNativeSocket: Winapi.Winsock2.TSocket;
  epollfd: THandle;
  evin: epoll_event;
  evout: epoll_event;
  remainingTime: Integer;
  rc: Integer;
  startTime, endTime, waitedTime: Int64;
  errorCode: Integer;
begin
	LNativeSocket := FNativeSocket;

	if LNativeSocket = INVALID_SOCKET then
    raise InvalidSocketException.Create('InvalidSocketException: TSocketImpl.poll');

	epollfd := epoll_create(1);
	if epollfd = 0 then
	begin
		error('Can''t create epoll queue');
  end;

	memset(@evin, 0, sizeof(evin));

	if (Integer(AMode) and Integer(TPollMode.SELECT_READ)) <> 0 then
		evin.events := evin.events or EPOLLIN;
	if (Integer(AMode) and Integer(TPollMode.SELECT_WRITE)) <> 0 then
		evin.events := evin.events or EPOLLOUT;
	if (Integer(AMode) and Integer(TPollMode.SELECT_ERROR)) <> 0 then
		evin.events := evin.events or EPOLLERR;

	if epoll_ctl(epollfd, EPOLL_CTL_ADD, LNativeSocket, @evin) < 0 then
  begin
		wepoll.close(epollfd);
		error('Can''t insert socket to epoll queue');
	end;

	errorCode := ENOERR;
	remainingTime := ATimeout;
	while true do
  begin
		memset(@evout, 0, sizeof(evout));

    startTime := GetTickCount64;
		rc := epoll_wait(epollfd, @evout, 1, remainingTime);
    if rc < 0 then
    begin
      errorCode := lastError;
      if errorCode = WSAEINTR then
      begin
        endTime := GetTickCount64;
        waitedTime := endTime - startTime;
        if waitedTime < remainingTime then
          remainingTime := remainingTime - waitedTime
        else
          remainingTime := 0;
      end;
    end;

    if not ((rc < 0) and (lastError = WSAEINTR)) then
      break;
  end;

	wepoll.close(epollfd);

	if rc < 0 then
    error(errorCode);

	result := rc > 0;
end;

function TSocketImpl.ReceiveBytes(ABuffer: Pointer; ALength, AFlags: Integer): Integer;
var
  LReturn, err: Integer;
begin
	if FBlocking then
		CheckBrokenTimeout(SELECT_READ);

  while true do
  begin
  	if FNativeSocket = INVALID_SOCKET then
      raise InvalidSocketException.Create('InvalidSocketException: TSocketImpl.receiveBytes');

		LReturn := Winapi.Winsock2.recv(FNativeSocket, ABuffer^, ALength, AFlags);

  	if FBlocking and (LReturn < 0) and (LastError = WSAEINTR) then
      continue
    else
      break;
  end;

	if LReturn < 0 then
	begin
		err := lastError;
		if (not FBlocking) and (err = WSAEWOULDBLOCK) then
    begin

    end
		else
    if (err = WSAEWOULDBLOCK) or (err = WSAETIMEDOUT) then
			raise TimeoutException.CreateFmt('%d', [err])
		else
			Error(err);
  end;

  result := LReturn;
end;

function TSocketImpl.ReceiveFrom(ABuffer: Pointer; ALength: Integer;
  var ASockAddr: TSockAddr; var ASockAddrLen: Integer; AFlags: Integer): Integer;
var
  LReturn, LError: Integer;
begin
  if FBlocking then
  	checkBrokenTimeout(SELECT_READ);
  while true do
  begin
  	if FNativeSocket = INVALID_SOCKET then
      raise InvalidSocketException.Create('InvalidSocketException: TSocketImpl.receiveFrom');

	  LReturn := Winapi.Winsock2.recvfrom(FNativeSocket, ABuffer^, ALength, AFlags, ASockAddr, ASockAddrLen);
    if FBlocking and (LReturn < 0) and (LastError = WSAEINTR) then
      continue
    else
      break;
  end;
  if LReturn < 0 then
  begin
	  LError := LastError;
  	if (not FBlocking) and (LError = WSAEWOULDBLOCK) then
    begin

    end
  	else
    if (LError = WSAEWOULDBLOCK) or (LError = WSAETIMEDOUT) then
  		raise TimeoutException.CreateFmt('%d', [LError])
  	else
	  	Error(LError);
  end;

  result := LReturn;
end;

function TSocketImpl.ReceiveFrom(ABuffer: Pointer; ALength: Integer; var ASocketAddress: TSocketAddress; AFlags: Integer): Integer;
var
	LBuffer: sockaddr_storage;
  pSA: PSockAddr;
  saLen: Integer;
  pSALen: PInteger;
  LReturn: Integer;
begin
  pSA := @LBuffer;
	saLen := sizeof(LBuffer);
	pSALen := @saLen;

	LReturn := receiveFrom(ABuffer, ALength, pSA^, pSALen^, AFlags);
	if LReturn >= 0 then
		ASocketAddress := TSocketAddress.Create(pSA, saLen);
	result := LReturn;
end;

procedure TSocketImpl.Reset(fd: Winapi.Winsock2.TSocket);
begin
  FNativeSocket := fd;
end;

function TSocketImpl.Secure: Boolean;
begin
  result := false;
end;

function TSocketImpl.SendBytes(ABuffer: Pointer; ALength, AFlags: Integer): Integer;
var
  LReturn, LError: Integer;
begin
	if FBlocking then
		checkBrokenTimeout(SELECT_READ);

  while true do
  begin
  	if FNativeSocket = INVALID_SOCKET then
      raise InvalidSocketException.Create('InvalidSocketException: TSocketImpl.receiveBytes');

		LReturn := Winapi.Winsock2.send(FNativeSocket, ABuffer^, ALength, AFlags);

  	if FBlocking and (LReturn < 0) and (LastError = WSAEINTR) then
      continue
    else
      break;
  end;

	if LReturn < 0 then
	begin
		LError := LastError;
		if (not FBlocking) and (LError = WSAEWOULDBLOCK) then
    begin

    end
		else
    if (LError = WSAEWOULDBLOCK) or (LError = WSAETIMEDOUT) then
			raise TimeoutException.CreateFmt('%d', [LError])
		else
			Error(LError);
  end;

	result := LReturn;
end;

function TSocketImpl.SendTo(ABuffer: Pointer; ALength: Integer; const ASocketAddress: TSocketAddress; AFlags: Integer): Integer;
var
  LReturn, LError: Integer;
begin
  while true do
  begin
  	if FNativeSocket = INVALID_SOCKET then
      init(ASocketAddress.NativeFamily);
  	LReturn := Winapi.Winsock2.sendto(FNativeSocket, ABuffer^, ALength, AFlags, ASocketAddress.Addr, ASocketAddress.Length);
   	if FBlocking and (LReturn < 0 ) and (LastError = WSAEINTR) then
      continue
    else
      break;
  end;
	if LReturn < 0 then
	begin
		LError := LastError;
		if (not FBlocking) and (LError = WSAEWOULDBLOCK) then
    begin

    end
		else
    if (LError = WSAEWOULDBLOCK) or (LError = WSAETIMEDOUT) then
			raise TimeoutException.CreateFmt('%d', [LError])
		else
			Error(LError);
  end;

	result := LReturn;
end;

procedure TSocketImpl.SendUrgent(FData: AnsiChar);
var
  LReturn: Integer;
begin
	if FNativeSocket = INVALID_SOCKET then
    raise InvalidSocketException.Create('InvalidSocketException: TSocketImpl.sendUrgent');

	LReturn := Winapi.Winsock2.send(FNativeSocket, FData, sizeof(FData), MSG_OOB);

	if LReturn < 0 then
    Error;
end;

procedure TSocketImpl.SetOption(ALevel, AOption: Cardinal; AValue: Integer);
begin
  SetRawOption(ALevel, AOption, @AValue, sizeof(AValue));
end;

procedure TSocketImpl.SetOption(ALevel, AOption: Cardinal; AValue: Cardinal);
begin
  SetRawOption(ALevel, AOption, @AValue, sizeof(AValue));
end;

procedure TSocketImpl.SetBlocking(AFlag: Boolean);
var
  LArg: u_long;
begin
	LArg := ifthen(AFlag, 0, 1);

//	ioctl(FIONBIO, arg);

  ioctlsocket(FNativeSocket, Integer(FIONBIO), LArg);

	FBlocking := AFlag;
end;

procedure TSocketImpl.SetBroadcast(AFlag: Boolean);
var
  LValue: Integer;
begin
	LValue := ifthen(AFlag, 1, 0);

	SetOption(SOL_SOCKET, SO_BROADCAST, LValue);
end;

procedure TSocketImpl.SetKeepAlive(AFlag: Boolean);
var
  LValue: Integer;
begin
	LValue := ifthen(AFlag, 1, 0);

	SetOption(SOL_SOCKET, SO_KEEPALIVE, LValue);
end;

procedure TSocketImpl.SetLinger(AOnValue: Boolean; ASeconds: Integer);
var
  LLinger: linger;
begin
	LLinger.l_onoff  := ifthen(AOnValue, 1, 0);
	LLinger.l_linger := ASeconds;

	SetRawOption(SOL_SOCKET, SO_LINGER, @LLinger, sizeof(LLinger));
end;

procedure TSocketImpl.SetNoDelay(AFlag: Boolean);
var
  LValue: Integer;
begin
	LValue := ifthen(AFlag, 1, 0);

	setOption(IPPROTO_TCP, TCP_NODELAY, LValue);
end;

procedure TSocketImpl.SetOOBInline(AFlag: Boolean);
var
  LValue: Integer;
begin
	LValue := ifthen(AFlag, 1, 0);

	SetOption(SOL_SOCKET, SO_OOBINLINE, LValue);
end;

procedure TSocketImpl.SetOption(ALevel, AOption: Cardinal; const AValue: TIPAddress);
begin
  SetRawOption(ALevel, AOption, AValue.addr, AValue.length);
end;

procedure TSocketImpl.SetOption(ALevel, AOption: Cardinal; AValue: Byte);
begin
  SetRawOption(ALevel, AOption, @AValue, sizeof(AValue));
end;

procedure TSocketImpl.SetRawOption(ALevel, AOption: Cardinal; AValue: Pointer; ALength: Integer);
var
  LReturn: Integer;
begin
	if FNativeSocket = INVALID_SOCKET then
    raise InvalidSocketException.Create('InvalidSocketException: TSocketImpl.setRawOption');

	LReturn := Winapi.Winsock2.setsockopt(FNativeSocket, ALevel, AOption, PAnsiChar(AValue), ALength);

	if LReturn = -1 then
    Error;
end;

procedure TSocketImpl.setReceiveBufferSize(size: Integer);
begin
  SetOption(SOL_SOCKET, SO_RCVBUF, size);
end;

procedure TSocketImpl.setReceiveTimeout(timeout: Cardinal);
begin
	SetOption(SOL_SOCKET, SO_RCVTIMEO, timeout);

	if FIsBrokenTimeout then
		FSndTimeout := timeout;
end;

procedure TSocketImpl.SetReuseAddress(AFlag: Boolean);
var
  LValue: Integer;
begin
  LValue := ifthen(AFlag, 1, 0);
	SetOption(SOL_SOCKET, SO_REUSEADDR, LValue);

//  value := ifthen(flag, 0, 1);
//	setOption(SOL_SOCKET, SO_EXCLUSIVEADDRUSE, value);
end;

procedure TSocketImpl.SetReusePort(AFlag: Boolean);
begin

end;

procedure TSocketImpl.SetSendBufferSize(ASize: Integer);
begin
  SetOption(SOL_SOCKET, SO_SNDBUF, ASize);
end;

procedure TSocketImpl.SetSendTimeout(ATimeout: Cardinal);
begin
	setOption(SOL_SOCKET, SO_SNDTIMEO, ATimeout);

	if FIsBrokenTimeout then
		FSndTimeout := ATimeout;
end;

function TSocketImpl.shutdown: Integer;
var
  LReturn: Integer;
begin
	if FNativeSocket = INVALID_SOCKET then
    raise InvalidSocketException.Create('InvalidSocketException: TSocketImpl.shutdown');

	LReturn := Winapi.Winsock2.shutdown(FNativeSocket, 2);
	if LReturn <> 0 then
    Error;

  result := 0;
end;

procedure TSocketImpl.shutdownReceive;
var
  LReturn: Integer;
begin
	if FNativeSocket = INVALID_SOCKET then
    raise InvalidSocketException.Create('InvalidSocketException: TSocketImpl.shutdownReceive');

	LReturn := Winapi.Winsock2.shutdown(FNativeSocket, 0);
	if LReturn <> 0 then
    Error;
end;

function TSocketImpl.shutdownSend: Integer;
var
  LReturn: Integer;
begin
	if FNativeSocket = INVALID_SOCKET then
    raise InvalidSocketException.Create('InvalidSocketException: TSocketImpl.shutdownReceive');

	LReturn := Winapi.Winsock2.shutdown(FNativeSocket, 1);
	if LReturn <> 0 then
    error;

  result := 0;
end;

function TSocketImpl.SocketError: Integer;
begin
	GetOption(SOL_SOCKET, SO_ERROR, result);
end;

function TSocketImpl.SocketType: TSocketType;
var
  LSocketType: Integer;
begin
	GetOption(SOL_SOCKET, SO_TYPE, LSocketType);

	if not (LSocketType in [SOCK_STREAM, SOCK_DGRAM, SOCK_RAW]) then
  	raise AssertionViolationException.Create('Assertion violation: TSocketImpl.socketType');
	result := TSocketType(LSocketType);
end;

function TSocketImpl.ToString: String;
begin
  result := FConnectedAddress.ToString;
end;

procedure TSocketImpl.GetOption(ALevel, AOption: Cardinal; var AValue: TIPAddress);
var
  LBuffer: array [0..TIPAddress.MAX_ADDRESS_LENGTH] of Byte;
  LLen: Integer;
begin
	LLen := sizeof(LBuffer);
	GetRawOption(ALevel, AOption, @LBuffer[0], LLen);
	AValue := TIPAddress.Create(@LBuffer[0], LLen);
end;

end.
