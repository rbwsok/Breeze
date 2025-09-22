unit Breeze.Net.SocketAddress;

interface

uses Winapi.Winsock2, Winapi.IpExport, System.SysUtils,
  Breeze.Net.SocketAddressImpl, Breeze.Net.IPAddress, Breeze.Net.SocketDefs, Breeze.Exception;

type

  TSocketAddress = record
	/// This class represents an internet (IP) endpoint/socket
	/// address. The address can belong either to the
	/// IPv4, IPv6 or Unix local family.
	/// IP addresses consist of a host address and a port number.
	/// An Unix local socket address consists of a path to socket file.
	/// Abstract local sockets, which operate without the need for
	/// interaction with the filesystem, are supported on Linux only.
  public
    procedure Create; overload;
		/// Creates a wildcard (all zero) IPv4 SocketAddress.
    constructor Create(AFamily: TAddressFamily); overload;
		/// Creates a SocketAddress with unspecified (wildcard) IP address
		/// of the given family.
    constructor Create(const AHostAddress: TIPAddress; APortNumber: Word); overload;
		/// Creates a SocketAddress from an IP address and given port number.
    constructor Create(APortNumber: Word); overload;
		/// Creates a SocketAddress with unspecified (wildcard) IP address
		/// and given port number.
    constructor Create(AFamily: TAddressFamily; APortNumber: Word); overload;
		/// Creates a SocketAddress with unspecified (wildcard) IP address
		/// of the given family, and given port number.
    constructor Create(const AHostAddress: String; APortNumber: Word); overload;
		/// Creates a SocketAddress from an IP address and given port number.
		///
		/// The IP address must either be a domain name, or it must
		/// be in dotted decimal (IPv4) or hex string (IPv6) format.
    constructor Create(AFamily: TAddressFamily; const AHostAddress: String; APortNumber: Word); overload;
		/// Creates a SocketAddress from an IP address and given port number.
		///
		/// The IP address must either be a domain name, or it must
		/// be in dotted decimal (IPv4) or hex string (IPv6) format.
		///
		/// If a domain name is given in hostAddress, it is resolved and the address
		/// matching the given family is used. If no address matching the given family
		/// is found, or the IP address given in hostAddress does not match the given
		/// family, an AddressFamilyMismatchException is thrown.
    constructor Create(const AHostAddress: String; const APortNumber: String); overload;
		/// Creates a SocketAddress from an IP address and the
		/// service name or port number.
		///
		/// The IP address must either be a domain name, or it must
		/// be in dotted decimal (IPv4) or hex string (IPv6) format.
		///
		/// The given port must either be a decimal port number, or
		/// a service name.
    constructor Create(AFamily: TAddressFamily; const AHostAddress: String; const APortNumber: String); overload;
		/// Creates a SocketAddress from an IP address and the
		/// service name or port number.
		///
		/// The IP address must either be a domain name, or it must
		/// be in dotted decimal (IPv4) or hex string (IPv6) format.
		///
		/// The given port must either be a decimal port number, or
		/// a service name.
		///
		/// If a domain name is given in hostAddress, it is resolved and the address
		/// matching the given family is used. If no address matching the given family
		/// is found, or the IP address given in hostAddress does not match the given
		/// family, an AddressFamilyMismatchException is thrown.
    constructor Create(const AHostAndPort: String); overload;
		/// Creates a SocketAddress from an IP address or host name and the
		/// port number/service name. Host name/address and port number must
		/// be separated by a colon. In case of an IPv6 address,
		/// the address part must be enclosed in brackets.
		///
		/// Examples:
		///     192.168.1.10:80
		///     [::ffff:192.168.1.120]:2040
		///     www.appinf.com:8080
		///
		/// On platforms supporting UNIX_LOCAL sockets, hostAndPort
		/// can also be a valid absolute local socket file path.
		///
		/// Examples:
		///     /tmp/local.sock
		///     C:\Temp\local.sock
		///
		/// On Linux, abstract local sockets are supported as well.
		/// Abstract local sockets operate in a namespace that has
		/// no need for a filesystem. They are identified by
		/// a null byte at the beginning of the path.
		///
		/// Example:
		///     \0abstract.sock
		///
    constructor Create(AFamily: TAddressFamily; const AAddress: String); overload;
		/// Creates a SocketAddress of the given family from a
		/// string representation of the address, which is
		/// either (1) an IP address and port number, separated by
		/// a colon for IPv4 or IPv6 addresses, or (2) path for
		/// UNIX_LOCAL sockets.
		/// See `SocketAddress(const string&)` documentation
		/// for more details.
    constructor Create(const ASocketAddress: TSocketAddress); overload;
		/// Creates a SocketAddress by copying another one.
//	SocketAddress(const struct sockaddr* addr, poco_socklen_t length);
    constructor Create(const ASockAddr: PSockAddr; ALength: Integer); overload;
		/// Creates a SocketAddress from a native socket address.
//	  destructor Destroy; override;
		/// Destroys the SocketAddress.
//    procedure Assign(const addr: TSocketAddress);
{	SocketAddress& operator = (const SocketAddress& socketAddress);
		/// Assigns another SocketAddress.
	SocketAddress& operator = (SocketAddress&& socketAddress);
		/// Move-assigns another SocketAddress.
 }
	  function Host: TIPAddress;
		/// Returns the host IP address.
	  function Port: Word;
		/// Returns the port number.
	  function Length: Cardinal;
		/// Returns the length of the internal native socket address.
   	function Addr: PSockAddr;
		/// Returns a pointer to the internal native socket address.
	  function NativeFamily: Integer;
		/// Returns the address family (AF_INET or AF_INET6) of the address.
  	function ToString: String;
		/// Returns a string representation of the address.
  	function Family: TAddressFamily;
		/// Returns the address family of the host's address.

    function IsLess(const AValue: TSocketAddress): Boolean;
    function IsEqual(const AValue: TSocketAddress): Boolean;
    function IsNotEqual(const AValue: TSocketAddress): Boolean;

  private
	  procedure Init(const AHostAddress: TIPAddress; APortNumber: Word); overload;
	  procedure Init(const AHostAddress: String; APortNumber: Word); overload;
	  procedure Init(AFamily: TAddressFamily; const AHostAddress: String; APortNumber: Word); overload;
	  procedure Init(AFamily: TAddressFamily; const AAddress: String); overload;
	  procedure Init(const AHostAndPort: String); overload;
  	function ResolveService(const AService: String): Word;

    procedure NewIPv4; overload;
    procedure NewIPv4(addr: PSockAddrIn); overload;
    procedure NewIPv4(AHostAddress: TIPAddress; APortNumber: Word); overload;

    procedure NewIPv6(addr: psockaddr_in6); overload;
    procedure NewIPv6(AHostAddress: TIPAddress; APortNumber: Word); overload;

    case FFamily: TAddressFamily of
    	TAddressFamily.IPv4: (FImplv4: TIPv4SocketAddressImpl);
     	TAddressFamily.IPv6: (FImplv6: TIPv6SocketAddressImpl);
  end;

implementation

{ TSocketAddress }

function TSocketAddress.Addr: PSockAddr;
begin
  case FFamily of
    IPv4:
    	result := FImplv4.Addr;
    IPv6:
     	result := FImplv6.Addr;
    else
     	result := nil;
  end;
end;

function TSocketAddress.Length: Cardinal;
begin
  case FFamily of
    IPv4:
    	result := FImplv4.Length;
    IPv6:
     	result := FImplv6.Length;
    else
     	result := 0;
  end;
end;

function TSocketAddress.NativeFamily: Integer;
begin
  case FFamily of
    IPv4:
    	result := FImplv4.NativeFamily;
    IPv6:
     	result := FImplv6.NativeFamily;
    else
     	result := 0;
  end;
end;

constructor TSocketAddress.Create(AFamily: TAddressFamily; APortNumber: Word);
begin
	Init(TIPAddress.Create(AFamily), APortNumber);
end;

constructor TSocketAddress.Create(const AHostAddress: String; APortNumber: Word);
begin
	Init(AHostAddress, APortNumber);
end;

constructor TSocketAddress.Create(AFamily: TAddressFamily; const AHostAddress: String; APortNumber: Word);
begin
  Init(AFamily, AHostAddress, APortNumber);
end;

constructor TSocketAddress.Create(APortNumber: Word);
var
  ip: TIPAddress;
begin
  ip.Create;
	init(ip, APortNumber);
end;

procedure TSocketAddress.Create;
begin
  newIPv4;
end;

constructor TSocketAddress.Create(AFamily: TAddressFamily);
begin
  init(TIPAddress.Create(AFamily), 0);
end;

constructor TSocketAddress.Create(const AHostAddress: TIPAddress; APortNumber: Word);
begin
	init(AHostAddress, APortNumber);
end;

constructor TSocketAddress.Create(const ASocketAddress: TSocketAddress);
begin
  case ASocketAddress.host.family of
    TAddressFamily.IPv4:
      FImplv4 := TIPv4SocketAddressImpl.Create(ASocketAddress.FImplv4);
    TAddressFamily.IPv6:
      FImplv6 := TIPv6SocketAddressImpl.Create(ASocketAddress.FImplv6);
  end;
end;

constructor TSocketAddress.Create(AFamily: TAddressFamily; const AAddress: String);
begin
	Init(AFamily, AAddress);
end;

constructor TSocketAddress.Create(const AHostAndPort: String);
begin
	Init(AHostAndPort);
end;

constructor TSocketAddress.Create(const AHostAddress, APortNumber: String);
begin
	Init(AHostAddress, resolveService(APortNumber));
end;

constructor TSocketAddress.Create(AFamily: TAddressFamily; const AHostAddress, APortNumber: String);
begin
	Init(AFamily, AHostAddress, resolveService(APortNumber));
end;

function TSocketAddress.Family: TAddressFamily;
begin
 	result := FFamily;
end;

function TSocketAddress.Host: TIPAddress;
begin
  case FFamily of
    IPv4:
    	result := FImplv4.host;
    IPv6:
     	result := FImplv6.host;
  end;
end;

procedure TSocketAddress.Init(const AHostAddress: String; APortNumber: Word);
var
  LIPAddress: TIPAddress;
begin
  LIPAddress.Create;
  if TIPAddress.TryParse(AHostAddress, LIPAddress) then
  begin
    Init(LIPAddress, APortNumber);
  end
  else
  begin
{		HostEntry he = DNS::hostByName(hostAddress);
    HostEntry::AddressList addresses = he.addresses();
    if addresses.size() > 0 then
    begin
      // if we get both IPv4 and IPv6 addresses, prefer IPv4
      std::stable_sort(addresses.begin(), addresses.end(), AFLT());
      init(addresses[0], portNumber);
    end
    else}
      raise HostNotFoundException.Create('No address found for host ' + AHostAddress);
  end;
end;

procedure TSocketAddress.init(const AHostAddress: TIPAddress; APortNumber: Word);
begin
	case AHostAddress.family of
    TAddressFamily.IPv4:
  		newIPv4(AHostAddress, APortNumber);
    TAddressFamily.IPv6:
  		newIPv6(AHostAddress, APortNumber);
	else
    raise NotImplementedException.Create('unsupported IP address family');
  end;
end;

procedure TSocketAddress.Init(const AHostAndPort: String);
var
  LHost, LPort: String;
  LChar: PChar;
  LCharEnd: PChar;
begin
  if AHostAndPort.IsEmpty then
    exit;

  LChar := @AHostAndPort[1];
  LCharEnd := LChar + AHostAndPort.Length;

  if LChar^ = '[' then
	begin
    inc(LChar);
		while ((LChar <> LCharEnd) and (LChar^ <> ']')) do
    begin
      LHost := LHost + LChar^;
      inc(LChar);
    end;
		if LChar = LCharEnd then
      raise InvalidArgumentException.Create('Malformed IPv6 address');
		inc(LChar);
  end
	else
	begin
    while ((LChar <> LCharEnd) and (LChar^ <> ':')) do
    begin
      LHost := LHost + LChar^;
      inc(LChar);
    end;
	end;
  if ((LChar <> LCharEnd) and (LChar^ = ':')) then
	begin
		inc(LChar);
		while LChar <> LCharEnd do
    begin
      LPort := LPort + LChar^;
      inc(LChar);
    end;
  end
	else
    raise InvalidArgumentException.Create('Missing port number');

  init(LHost, resolveService(LPort));
end;

function TSocketAddress.IsEqual(const AValue: TSocketAddress): Boolean;
begin
  result := (host = AValue.host) and (port = AValue.port);
end;

function TSocketAddress.IsLess(const AValue: TSocketAddress): Boolean;
begin
	if family < AValue.family then
    exit(true);

	if family > AValue.family then
    exit(false);

	if host < AValue.host then
    exit(true);
	if host > AValue.host then
    exit(false);
	exit(port < AValue.port);
end;

function TSocketAddress.IsNotEqual(const AValue: TSocketAddress): Boolean;
begin
  result := not IsEqual(AValue);
end;

procedure TSocketAddress.Init(AFamily: TAddressFamily; const AAddress: String);
var
  LHost, LPort: String;
  LChar: PChar;
  LCharEnd: PChar;
begin
  LChar := @AAddress[1];
  LCharEnd := LChar + AAddress.Length;
  if LChar^ = '[' then
	begin
    inc(LChar);
		while ((LChar <> LCharEnd) and (LChar^ <> ']')) do
    begin
      LHost := LHost + LChar^;
      inc(LChar);
    end;
		if LChar = LCharEnd then
      raise InvalidArgumentException.Create('Malformed IPv6 address');
		inc(LChar);
  end
	else
	begin
    while ((LChar <> LCharEnd) and (LChar^ <> ':')) do
    begin
      LHost := LHost + LChar^;
      inc(LChar);
    end;
	end;
  if ((LChar <> LCharEnd) and (LChar^ = ':')) then
	begin
		inc(LChar);
		while LChar <> LCharEnd do
    begin
      LPort := LPort + LChar^;
      inc(LChar);
    end;
  end
	else
    raise InvalidArgumentException.Create('Missing port number');

  Init(AFamily, LHost, resolveService(LPort));
end;

procedure TSocketAddress.Init(AFamily: TAddressFamily; const AHostAddress: String; APortNumber: Word);
var
  LIPAddress: TIPAddress;
begin
	if TIPAddress.TryParse(AHostAddress, LIPAddress) then
  begin
		if LIPAddress.Family <> Family then
      raise AddressFamilyMismatchException.Create(AHostAddress);
		Init(LIPAddress, APortNumber);
	end
	else
  begin
{		HostEntry he = DNS::hostByName(hostAddress);
		HostEntry::AddressList addresses = he.addresses();
		if addresses.size() > 0 then
    begin
			for (const auto& addr: addresses)
      begin
				if (addr.family() == fam)
        begin
					init(addr, portNumber);
					return;
				end;
			end;
			throw AddressFamilyMismatchException(hostAddress);
    end;
		else throw HostNotFoundException("No address found for host", hostAddress);}
	end;
end;

procedure TSocketAddress.newIPv4;
begin
  FFamily := TAddressFamily.IPv4;
	FImplv4.Create;
end;

procedure TSocketAddress.newIPv4(AHostAddress: TIPAddress; APortNumber: Word);
begin
  FFamily := TAddressFamily.IPv4;
	FImplv4 := TIPv4SocketAddressImpl.Create(AHostAddress.addr, htons(APortNumber));
end;

procedure TSocketAddress.newIPv4(addr: PSockAddrIn);
begin
  FFamily := TAddressFamily.IPv4;
  FImplv4 := TIPv4SocketAddressImpl.Create(addr);
end;

procedure TSocketAddress.newIPv6(addr: psockaddr_in6);
begin
  FFamily := TAddressFamily.IPv6;
  FImplv6 := TIPv6SocketAddressImpl.Create(addr);
end;

procedure TSocketAddress.newIPv6(AHostAddress: TIPAddress; APortNumber: Word);
begin
  FFamily := TAddressFamily.IPv6;
	FImplv6 := TIPv6SocketAddressImpl.Create(AHostAddress.addr, htons(APortNumber), AHostAddress.Scope);
end;

function TSocketAddress.port: Word;
begin
  case FFamily of
    IPv4:
    	result := ntohs(FImplv4.Port);
    IPv6:
     	result := ntohs(FImplv6.Port);
    else
     	result := 0;
  end;
end;

function TSocketAddress.ToString: String;
begin
  case FFamily of
    IPv4:
    	result := FImplv4.ToString;
    IPv6:
     	result := FImplv6.ToString;
    else
     	result := 'unknown';
  end;
end;

function TSocketAddress.ResolveService(const AService: String): Word;
var
  LPort: Integer;
  LServiceEntry: PServEnt;
  LAnsiString: AnsiString;
begin
  if TryStrToInt(AService, LPort) then
    exit(LPort)
  else
  begin
    LAnsiString := AnsiString(AService);
    LServiceEntry := getservbyname(@LAnsiString[1], nil);
		if LServiceEntry <> nil then
			exit(LServiceEntry.s_port)
		else
			raise ServiceNotFoundException.Create(AService);
  end;
end;

constructor TSocketAddress.Create(const ASockAddr: PSockAddr; ALength: Integer);
begin
	if (ALength = sizeof(sockaddr_in)) and (ASockAddr.sa_family = AF_INET) then
		NewIPv4(PSockAddrIn(ASockAddr))
	else
  if (ALength = sizeof(sockaddr_in6)) and (ASockAddr.sa_family = AF_INET6) then
		NewIPv6(psockaddr_in6(ASockAddr))
	else
    raise InvalidArgumentException.Create('Invalid address length or family passed to TSocketAddress');
end;

end.

