unit Breeze.Net.IPAddress;

interface

uses Winapi.Winsock2, Winapi.IpExport, System.SysUtils, System.Win.Crtl,

Breeze.Net.SocketDefs, Breeze.Net.IPAddressImpl, Breeze.Exception;

type

  TIPAddress = record
  public
  	procedure Create; overload;
		/// Creates a wildcard (zero) IPv4 IPAddress.

	  constructor Create(const AIPAddress: TIPAddress); overload;
		/// Creates an IPAddress by copying another one.

  	constructor Create(AFamily: TAddressFamily); overload;
		/// Creates a wildcard (zero) IPAddress for the
		/// given address family.

  	constructor Create(const AAddress: String); overload;
		/// Creates an IPAddress from the string containing
		/// an IP address in presentation format (dotted decimal
		/// for IPv4, hex string for IPv6).
		///
		/// Depending on the format of addr, either an IPv4 or
		/// an IPv6 address is created.
		///
		/// See toString() for details on the supported formats.
		///
		/// Throws an InvalidAddressException if the address cannot be parsed.

  	constructor Create(const AAddress: String; AFamily: TAddressFamily); overload;
		/// Creates an IPAddress from the string containing
		/// an IP address in presentation format (dotted decimal
		/// for IPv4, hex string for IPv6).

  	constructor Create(AAddress: Pointer; ALength: Integer); overload;
//	IPAddress(const void* addr, poco_socklen_t length);
		/// Creates an IPAddress from a native internet address.
		/// A pointer to a in_addr or a in6_addr structure may be
		/// passed.

  	constructor Create(AAddress: Pointer; ALength: Integer; AScope: Cardinal); overload;
//	IPAddress(const void* addr, poco_socklen_t length, Poco::UInt32 scope);
		/// Creates an IPAddress from a native internet address.
		/// A pointer to a in_addr or a in6_addr structure may be
		/// passed. Additionally, for an IPv6 address, a scope ID
		/// may be specified. The scope ID will be ignored if an IPv4
		/// address is specified.

  	constructor Create(APrefix: Cardinal; AFamily: TAddressFamily); overload;
			/// Creates an IPAddress mask with the given length of prefix.

  	constructor Create(ASocketAddress: PSOCKET_ADDRESS); overload;

//	IPAddress(const struct sockaddr& sockaddr);
		/// Same for struct sock_addr on POSIX.

//  destructor Destroy; override;
		/// Destroys the IPAddress.

    procedure Assign(const AIPAddress: TIPAddress);

//	IPAddress& operator = (const IPAddress& addr);
		/// Assigns an IPAddress.

//	IPAddress& operator = (IPAddress&& addr);
		/// Move-assigns an IPAddress.

    function IsV4: Boolean;
    function IsV6: Boolean;

{	RawIPv4 toV4Bytes() const;
	RawIPv6 toV6Bytes() const;
	RawIP toBytes() const;
}

    function Family: TAddressFamily;
	/// Returns the address family (IPv4 or IPv6) of the address.

  	function Scope: Cardinal;
		/// Returns the IPv6 scope identifier of the address. Returns 0 if
		/// the address is an IPv4 address, or the address is an
		/// IPv6 address but does not have a scope identifier.

	  function ToString: String;
		/// Returns a string containing a representation of the address
		/// in presentation format.
		///
		/// For IPv4 addresses the result will be in dotted-decimal
		/// (d.d.d.d) notation.
		///
		/// Textual representation of IPv6 address is one of the following forms:
		///
		/// The preferred form is x:x:x:x:x:x:x:x, where the 'x's are the hexadecimal
		/// values of the eight 16-bit pieces of the address. This is the full form.
		/// Example: 1080:0:0:0:8:600:200A:425C
		///
		/// It is not necessary to write the leading zeros in an individual field.
		/// However, there must be at least one numeral in every field, except as described below.
		///
		/// It is common for IPv6 addresses to contain long strings of zero bits.
		/// In order to make writing addresses containing zero bits easier, a special syntax is
		/// available to compress the zeros. The use of "::" indicates multiple groups of 16-bits of zeros.
		/// The "::" can only appear once in an address. The "::" can also be used to compress the leading
		/// and/or trailing zeros in an address. Example: 1080::8:600:200A:425C
		///
		/// For dealing with IPv4 compatible addresses in a mixed environment,
		/// a special syntax is available: x:x:x:x:x:x:d.d.d.d, where the 'x's are the
		/// hexadecimal values of the six high-order 16-bit pieces of the address,
		/// and the 'd's are the decimal values of the four low-order 8-bit pieces of the
		/// standard IPv4 representation address. Example: ::FFFF:192.168.1.120
		///
		/// If an IPv6 address contains a non-zero scope identifier, it is added
		/// to the string, delimited by a percent character. On Windows platforms,
		/// the numeric value (which specifies an interface index) is directly
		/// appended. On Unix platforms, the name of the interface corresponding
		/// to the index (interpretation of the scope identifier) is added.

    function IsWildcard: Boolean;
		/// Returns true iff the address is a wildcard (all zero)
		/// address.

	  function IsBroadcast: Boolean;
		/// Returns true iff the address is a broadcast address.
		///
		/// Only IPv4 addresses can be broadcast addresses. In a broadcast
		/// address, all bits are one.
		///
		/// For an IPv6 address, returns always false.

  	function IsLoopback: Boolean;
		/// Returns true iff the address is a loopback address.
		///
		/// For IPv4, the loopback address is 127.0.0.1.
		///
		/// For IPv6, the loopback address is ::1.

  	function IsMulticast: Boolean;
		/// Returns true iff the address is a multicast address.
		///
		/// IPv4 multicast addresses are in the
		/// 224.0.0.0 to 239.255.255.255 range
		/// (the first four bits have the value 1110).
		///
		/// IPv6 multicast addresses are in the
		/// FFxx:x:x:x:x:x:x:x range.

  	function IsUnicast: Boolean;
		/// Returns true iff the address is a unicast address.
		///
		/// An address is unicast if it is neither a wildcard,
		/// broadcast or multicast address.

	  function IsLinkLocal: Boolean;
		/// Returns true iff the address is a link local unicast address.
		///
		/// IPv4 link local addresses are in the 169.254.0.0/16 range,
		/// according to RFC 3927.
		///
		/// IPv6 link local addresses have 1111 1110 10 as the first
		/// 10 bits, followed by 54 zeros.

  	function IsSiteLocal: Boolean;
		/// Returns true iff the address is a site local unicast address.
		///
		/// IPv4 site local addresses are in on of the 10.0.0.0/24,
		/// 192.168.0.0/16 or 172.16.0.0 to 172.31.255.255 ranges.
		///
		/// Originally, IPv6 site-local addresses had FEC0/10 (1111 1110 11)
		/// prefix (RFC 4291), followed by 38 zeros. Interfaces using
		/// this mask are supported, but obsolete; RFC 4193 prescribes
		/// fc00::/7 (1111 110) as local unicast prefix.

	  function IsIPv4Compatible: Boolean;
		/// Returns true iff the address is IPv4 compatible.
		///
		/// For IPv4 addresses, this is always true.
		///
		/// For IPv6, the address must be in the ::x:x range (the
		/// first 96 bits are zero).

	  function IsIPv4Mapped: Boolean;
		/// Returns true iff the address is an IPv4 mapped IPv6 address.
		///
		/// For IPv4 addresses, this is always true.
		///
		/// For IPv6, the address must be in the ::FFFF:x:x range.

   	function IsWellKnownMC: Boolean;
		/// Returns true iff the address is a well-known multicast address.
		///
		/// For IPv4, well-known multicast addresses are in the
		/// 224.0.0.0/8 range.
		///
		/// For IPv6, well-known multicast addresses are in the
		/// FF0x:x:x:x:x:x:x:x range.

	  function IsNodeLocalMC: Boolean;
		/// Returns true iff the address is a node-local multicast address.
		///
		/// IPv4 does not support node-local addresses, thus the result is
		/// always false for an IPv4 address.
		///
		/// For IPv6, node-local multicast addresses are in the
		/// FFx1:x:x:x:x:x:x:x range.

   	function IsLinkLocalMC: Boolean;
		/// Returns true iff the address is a link-local multicast address.
		///
		/// For IPv4, link-local multicast addresses are in the
		/// 224.0.0.0/24 range. Note that this overlaps with the range for well-known
		/// multicast addresses.
		///
		/// For IPv6, link-local multicast addresses are in the
		/// FFx2:x:x:x:x:x:x:x range.

	  function IsSiteLocalMC: Boolean;
		/// Returns true iff the address is a site-local multicast address.
		///
		/// For IPv4, site local multicast addresses are in the
		/// 239.255.0.0/16 range.
		///
		/// For IPv6, site-local multicast addresses are in the
		/// FFx5:x:x:x:x:x:x:x range.

	  function IsOrgLocalMC: Boolean;
		/// Returns true iff the address is a organization-local multicast address.
		///
		/// For IPv4, organization-local multicast addresses are in the
		/// 239.192.0.0/16 range.
		///
		/// For IPv6, organization-local multicast addresses are in the
		/// FFx8:x:x:x:x:x:x:x range.

   	function IsGlobalMC: Boolean;
		/// Returns true iff the address is a global multicast address.
		///
		/// For IPv4, global multicast addresses are in the
		/// 224.0.1.0 to 238.255.255.255 range.
		///
		/// For IPv6, global multicast addresses are in the
		/// FFxF:x:x:x:x:x:x:x range.

//	bool operator == (const IPAddress& addr) const;
	//bool operator != (const IPAddress& addr) const;

    class operator Equal(const A, B: TIPAddress): Boolean;
    class operator NotEqual(const A, B: TIPAddress): Boolean;
    class operator GreaterThan(const A, B: TIPAddress): Boolean;
    class operator LessThan(const A, B: TIPAddress): Boolean;
    class operator GreaterThanOrEqual(const A, B: TIPAddress): Boolean;
    class operator LessThanOrEqual(const A, B: TIPAddress): Boolean;
    class operator BitwiseAnd(const A, B: TIPAddress): TIPAddress;
    class operator BitwiseOr(const A, B: TIPAddress): TIPAddress;
    class operator BitwiseXor(const A, B: TIPAddress): TIPAddress;
    class operator LogicalNot(const A: TIPAddress): TIPAddress;
{
	IPAddress operator & (const IPAddress& addr) const;
	IPAddress operator | (const IPAddress& addr) const;
	IPAddress operator ^ (const IPAddress& addr) const;
	IPAddress operator ~ () const;
}
  	function Length: Cardinal;
		/// Returns the length in bytes of the internal socket address structure.

  	function Addr: Pointer;
		/// Returns the internal address structure.

    function NativeFamily: Integer;
		/// Returns the address family (AF_INET or AF_INET6) of the address.

  	function PrefixLength: Cardinal;
		/// Returns the prefix length.

    procedure Mask(const AMask: TIPAddress); overload;
		/// Masks the IP address using the given netmask, which is usually
		/// a IPv4 subnet mask. Only supported for IPv4 addresses.
		///
		/// The new address is (address & mask).

    procedure Mask(const AMask, AMset: TIPAddress); overload;
		/// Masks the IP address using the given netmask, which is usually
		/// a IPv4 subnet mask. Only supported for IPv4 addresses.
		///
		/// The new address is (address & mask) | (set & ~mask).
{
	static IPAddress parse(const std::string& addr);
		/// Creates an IPAddress from the string containing
		/// an IP address in presentation format (dotted decimal
		/// for IPv4, hex string for IPv6).
		///
		/// Depending on the format of addr, either an IPv4 or
		/// an IPv6 address is created.
		///
		/// See toString() for details on the supported formats.
		///
		/// Throws an InvalidAddressException if the address cannot be parsed.
}
	  class function TryParse(const AAddress: String; var AIPAddress: TIPAddress): Boolean; static;
		/// Tries to interpret the given address string as an
		/// IP address in presentation format (dotted decimal
		/// for IPv4, hex string for IPv6).
		///
		/// Returns true and stores the IPAddress in result if the
		/// string contains a valid address.
		///
		/// Returns false and leaves result unchanged otherwise.

	  class function Wildcard(AFamily: TAddressFamily = IPv4): TIPAddress; static;
		/// Returns a wildcard IPv4 or IPv6 address (0.0.0.0).

   	class function Broadcast: TIPAddress; static;
		/// Returns a broadcast IPv4 address (255.255.255.255).

	  class function CompressV6(const AAddressV6: String): String; static;
	  class function TrimIPv6(const AAddressV6: String): String; static;
  const
    MAX_ADDRESS_LENGTH = sizeof(in6_addr);
  private
    procedure NewIPv4; overload;
    procedure NewIPv4(AHostAddr: Pointer); overload;
    procedure NewIPv4(APrefix: Cardinal); overload;

    procedure NewIPv6; overload;
    procedure NewIPv6(AHostAddr: Pointer); overload;
    procedure NewIPv6(AHostAddr: Pointer; AScope: Cardinal); overload;
    procedure NewIPv6(APrefix: Cardinal); overload;

    case FFamily: TAddressFamily of
      TAddressFamily.IPv4: (FImplv4: TIPv4AddressImpl);
      TAddressFamily.IPv6: (FImplv6: TIPv6AddressImpl);
  end;

implementation

{ TIPAddress }

procedure TIPAddress.Create;
begin
  NewIPv4;
end;

constructor TIPAddress.Create(const AIPAddress: TIPAddress);
begin
	if AIPAddress.FFamily = TAddressFamily.IPv4 then
		NewIPv4(AIPAddress.Addr)
	else
		NewIPv6(AIPAddress.Addr, AIPAddress.Scope);
end;

constructor TIPAddress.Create(AFamily: TAddressFamily);
begin
	case AFamily of
    TAddressFamily.IPv4:
  		NewIPv4();
    TAddressFamily.IPv6:
  		NewIPv6();
    else
      raise InvalidArgumentException.Create('Invalid or unsupported address family passed to TIPAddress');
  end
end;

function TIPAddress.addr: Pointer;
begin
  case FFamily of
    TAddressFamily.IPv4:
    	result := FImplv4.addr;
    TAddressFamily.IPv6:
    	result := FImplv6.addr;
    else
    	result := nil;
  end;
end;

constructor TIPAddress.Create(const AAddress: String; AFamily: TAddressFamily);
begin
  FFamily := AFamily;
  case FFamily of
    TAddressFamily.IPv4:
      FImplv4 := TIPv4AddressImpl.Create(AAddress);
    TAddressFamily.IPv6:
      FImplv6 := TIPv6AddressImpl.Create(AAddress);
    else
      raise InvalidArgumentException.Create('Invalid or unsupported address family passed to TIPAddress');
  end;
end;

constructor TIPAddress.Create(const AAddress: String);
var
  LAddressV4: TIPv4AddressImpl;
  LAddressV6: TIPv6AddressImpl;
begin
	if AAddress.IsEmpty or (AAddress = '0.0.0.0') then
  begin
    newIPv4;
		exit;
  end;

	LAddressV4 := TIPv4AddressImpl.Create(AAddress);
	if not LAddressV4.isWildcard then
  begin
    FFamily := TAddressFamily.IPv4;
  	FImplv4 := LAddressV4;
		exit;
  end;

	if AAddress.IsEmpty or (TrimIPv6(AAddress) = '::') then
  begin
		newIPv6;
		exit;
  end;

	LAddressV6 := TIPv6AddressImpl.Create(AAddress);
	if not LAddressV6.isWildcard then
  begin
    FFamily := TAddressFamily.IPv6;
  	FImplv6 := LAddressV6;
		exit;
  end;

	raise InvalidArgumentException.Create('Invalid or unsupported address family passed to TIPAddress');
end;

function TIPAddress.Family: TAddressFamily;
begin
	result := FFamily;
end;

function TIPAddress.IsBroadcast: Boolean;
begin
  case FFamily of
    TAddressFamily.IPv4:
      result := FImplv4.isBroadcast;
    TAddressFamily.IPv6:
      result := FImplv6.isBroadcast;
    else
      raise InvalidArgumentException.Create('Invalid or unsupported address family passed to TIPAddress');
  end;
end;

function TIPAddress.IsGlobalMC: Boolean;
begin
  case FFamily of
    TAddressFamily.IPv4:
      result := FImplv4.isGlobalMC;
    TAddressFamily.IPv6:
      result := FImplv6.isGlobalMC;
    else
      result := false;
  end;
end;

function TIPAddress.IsIPv4Compatible: Boolean;
begin
  case FFamily of
    TAddressFamily.IPv4:
      result := FImplv4.isIPv4Compatible;
    TAddressFamily.IPv6:
      result := FImplv6.isIPv4Compatible;
    else
      result := false;
  end;
end;

function TIPAddress.IsIPv4Mapped: Boolean;
begin
  case FFamily of
    TAddressFamily.IPv4:
      result := FImplv4.isIPv4Mapped;
    TAddressFamily.IPv6:
      result := FImplv6.isIPv4Mapped;
    else
      result := false;
  end;
end;

function TIPAddress.IsLinkLocal: Boolean;
begin
  case FFamily of
    TAddressFamily.IPv4:
      result := FImplv4.isLinkLocal;
    TAddressFamily.IPv6:
      result := FImplv6.isLinkLocal;
    else
      result := false;
  end;
end;

function TIPAddress.IsLinkLocalMC: Boolean;
begin
  case FFamily of
    TAddressFamily.IPv4:
      result := FImplv4.isLinkLocalMC;
    TAddressFamily.IPv6:
      result := FImplv6.isLinkLocalMC;
    else
      result := false;
  end;
end;

function TIPAddress.IsLoopback: Boolean;
begin
  case FFamily of
    TAddressFamily.IPv4:
      result := FImplv4.isLoopback;
    TAddressFamily.IPv6:
      result := FImplv6.isLoopback;
    else
      result := false;
  end;
end;

function TIPAddress.IsMulticast: Boolean;
begin
  case FFamily of
    TAddressFamily.IPv4:
      result := FImplv4.isMulticast;
    TAddressFamily.IPv6:
      result := FImplv6.isMulticast;
    else
      result := false;
  end;
end;

function TIPAddress.IsNodeLocalMC: Boolean;
begin
  case FFamily of
    TAddressFamily.IPv4:
      result := FImplv4.isNodeLocalMC;
    TAddressFamily.IPv6:
      result := FImplv6.isNodeLocalMC;
    else
      result := false;
  end;
end;

function TIPAddress.IsOrgLocalMC: Boolean;
begin
  case FFamily of
    TAddressFamily.IPv4:
      result := FImplv4.isOrgLocalMC;
    TAddressFamily.IPv6:
      result := FImplv6.isOrgLocalMC;
    else
      result := false;
  end;
end;

function TIPAddress.IsSiteLocal: Boolean;
begin
  case FFamily of
    TAddressFamily.IPv4:
      result := FImplv4.isSiteLocal;
    TAddressFamily.IPv6:
      result := FImplv6.isSiteLocal;
    else
      result := false;
  end;
end;

function TIPAddress.IsSiteLocalMC: Boolean;
begin
  case FFamily of
    TAddressFamily.IPv4:
      result := FImplv4.isSiteLocalMC;
    TAddressFamily.IPv6:
      result := FImplv6.isSiteLocalMC;
    else
      result := false;
  end;
end;

function TIPAddress.IsUnicast: Boolean;
begin
  case FFamily of
    TAddressFamily.IPv4:
      result := (not FImplv4.isWildcard) and (not FImplv4.isBroadcast) and (not FImplv4.isMulticast);
    TAddressFamily.IPv6:
      result := (not FImplv6.isWildcard) and (not FImplv6.isBroadcast) and (not FImplv6.isMulticast);
    else
      result := false;
  end;
end;

function TIPAddress.isV4: Boolean;
begin
	result := FFamily = TAddressFamily.IPv4;
end;

function TIPAddress.IsV6: Boolean;
begin
	result := FFamily = TAddressFamily.IPv6;
end;

function TIPAddress.IsWellKnownMC: Boolean;
begin
  case FFamily of
    TAddressFamily.IPv4:
      result := FImplv4.isWellKnownMC;
    TAddressFamily.IPv6:
      result := FImplv6.isWellKnownMC;
    else
      result := false;
  end;
end;

function TIPAddress.isWildcard: Boolean;
begin
  case FFamily of
    TAddressFamily.IPv4:
      result := FImplv4.isWildcard;
    TAddressFamily.IPv6:
      result := FImplv6.isWildcard;
    else
      result := false;
  end;
end;

function TIPAddress.length: Cardinal;
begin
  case FFamily of
    TAddressFamily.IPv4:
      result := FImplv4.length;
    TAddressFamily.IPv6:
      result := FImplv6.length;
    else
      result := 0;
  end;
end;

procedure TIPAddress.Mask(const AMask, AMset: TIPAddress);
begin
  case FFamily of
    TAddressFamily.UNKNOWN: ;
    TAddressFamily.IPv4:
      FImplv4.Mask(AMask.FImplv4, AMset.FImplv4);
    TAddressFamily.IPv6: ;
  end;
end;

procedure TIPAddress.Mask(const AMask: TIPAddress);
var
	LIPAddress: TIPAddress;
begin
	LIPAddress.Create;
  case FFamily of
    TAddressFamily.UNKNOWN: ;
    TAddressFamily.IPv4:
      FImplv4.Mask(AMask.FImplv4, LIPAddress.FImplv4);
    TAddressFamily.IPv6: ;
  end;
end;

procedure TIPAddress.NewIPv4;
begin
  FFamily := TAddressFamily.IPv4;
	FImplv4.Create;
end;

procedure TIPAddress.NewIPv4(AHostAddr: Pointer);
begin
  FFamily := TAddressFamily.IPv4;
	FImplv4 := TIPv4AddressImpl.Create(AHostAddr);
end;

procedure TIPAddress.NewIPv4(APrefix: Cardinal);
begin
  FFamily := TAddressFamily.IPv4;
	FImplv4 := TIPv4AddressImpl.Create(APrefix);
end;

procedure TIPAddress.NewIPv6;
begin
  FFamily := TAddressFamily.IPv6;
	FImplv6.Create;
end;

procedure TIPAddress.NewIPv6(AHostAddr: Pointer);
begin
  FFamily := TAddressFamily.IPv6;
	FImplv6 := TIPv6AddressImpl.Create(AHostAddr);
end;

procedure TIPAddress.NewIPv6(AHostAddr: Pointer; AScope: Cardinal);
begin
  FFamily := TAddressFamily.IPv6;
  FImplv6 := TIPv6AddressImpl.Create(AHostAddr, AScope);
end;

procedure TIPAddress.NewIPv6(APrefix: Cardinal);
begin
  FFamily := TAddressFamily.IPv6;
  FImplv6 := TIPv6AddressImpl.Create(APrefix);
end;

function TIPAddress.PrefixLength: Cardinal;
begin
  case FFamily of
    TAddressFamily.IPv4:
      result := FImplv4.prefixLength;
    TAddressFamily.IPv6:
      result := FImplv6.prefixLength;
    else
      result := 0;
  end;
end;

function TIPAddress.Scope: Cardinal;
begin
  case FFamily of
    TAddressFamily.IPv4:
      result := FImplv4.Scope;
    TAddressFamily.IPv6:
      result := FImplv6.Scope;
    else
      result := 0;
  end;
end;

function TIPAddress.ToString: String;
begin
  case FFamily of
    TAddressFamily.UNKNOWN:
      result := 'unknown';
    TAddressFamily.IPv4:
      result := FImplv4.ToString;
    TAddressFamily.IPv6:
      result := FImplv6.ToString;
  end;
end;

class function TIPAddress.TrimIPv6(const AAddressV6: String): String;

  function count(const AString: String; AFindChar: Char): Integer;
  var
    i: integer;
  begin
    result := 0;
    for i := 1 to AString.Length do
    begin
      if AString[i] = AFindChar then
        inc(result);
    end;
  end;

var
  LLen: Integer;
  LDblColOcc: Integer;
  p: Integer;
begin
	LLen := AAddressV6.length;
	LDblColOcc := 0;

	p := pos('::', AAddressV6);

	while (p <= LLen - 1) and (p > 0) do
	begin
		inc(LDblColOcc);
  	p := pos('::', AAddressV6, p + 2);
	end;

	if (LDblColOcc > 1) or
     (count(AAddressV6, ':') > 8) or
     (pos(':::', AAddressV6) > 0) or
 		 ((LLen >= 2) and ((AAddressV6[LLen] = ':') and (AAddressV6[LLen - 1] <> ':'))) then
  begin
		exit(AAddressV6);
	end;

	result := CompressV6(AAddressV6);
end;

class function TIPAddress.TryParse(const AAddress: String; var AIPAddress: TIPAddress): Boolean;
var
  LAddressV4: TIPv4AddressImpl;
  LAddressV6: TIPv6AddressImpl;
begin
  result := true;

	if AAddress.IsEmpty or (AAddress = '0.0.0.0') then
  begin
    AIPAddress.NewIPv4;
		exit;
  end;

	LAddressV4 := TIPv4AddressImpl.Create(AAddress);
	if not LAddressV4.isWildcard then
  begin
    AIPAddress.FFamily := TAddressFamily.IPv4;
  	AIPAddress.FImplv4 := LAddressV4;
		exit;
  end;

	if AAddress.IsEmpty or (trimIPv6(AAddress) = '::') then
  begin
		AIPAddress.newIPv6;
		exit;
  end;

	LAddressV6 := TIPv6AddressImpl.Create(AAddress);
	if not LAddressV6.isWildcard then
  begin
    AIPAddress.FFamily := TAddressFamily.IPv6;
  	AIPAddress.FImplv6 := LAddressV6;
		exit;
  end;

  result := false;
end;

class function TIPAddress.Wildcard(AFamily: TAddressFamily): TIPAddress;
begin
	result := TIPAddress.Create(AFamily);
end;

function TIPAddress.NativeFamily: Integer;
begin
  case FFamily of
    TAddressFamily.IPv4:
      result := FImplv4.NativeFamily;
    TAddressFamily.IPv6:
      result := FImplv6.NativeFamily;
    else
      result := 0;
  end;
end;

procedure TIPAddress.Assign(const AIPAddress: TIPAddress);
begin
	if AIPAddress.family = TAddressFamily.IPv4 then
		newIPv4(AIPAddress.Addr)
	else
		newIPv6(AIPAddress.Addr, AIPAddress.Scope);
end;

class function TIPAddress.Broadcast: TIPAddress;
var
	LInAddr: in_addr;
begin
	LInAddr.s_addr := INADDR_NONE;
	result := TIPAddress.Create(@LInAddr, sizeof(LInAddr));
end;

class function TIPAddress.CompressV6(const AAddressV6: String): String;
begin
  result := AAddressV6;
	// get rid of leading zeros at the beginning
	while true do
  begin
    if (result.Length <= 0) or (result[1] <> '0') then
      break;
    result := copy(result, 2, result.Length - 1);
  end;

	// get rid of leading zeros in the middle
	while true do
  begin
    if pos(':0', result) > 0 then
      result := StringReplace(result, ':0', ':', [rfReplaceAll])
    else
      break;
  end;

	// get rid of extraneous colons
	while true do
  begin
    if pos(':::', result) > 0 then
      result := StringReplace(result, ':::', '::', [rfReplaceAll])
    else
      break;
  end;
end;

constructor TIPAddress.Create(ASocketAddress: PSOCKET_ADDRESS);
begin
	case ASocketAddress.lpSockaddr.sa_family of
    AF_INET:
      newIPv4(@PSOCKADDR_IN(ASocketAddress.lpSockaddr).sin_addr);
    AF_INET6:
      newIPv6(Pointer(@psockaddr_in6(ASocketAddress.lpSockaddr).sin6_addr), psockaddr_in6(ASocketAddress.lpSockaddr).sin6_scope_id);
    else
      raise InvalidArgumentException.Create('Invalid or unsupported address family passed to TIPAddress');
  end;
end;

constructor TIPAddress.Create(APrefix: Cardinal; AFamily: TAddressFamily);
begin
  case AFamily of
    TAddressFamily.IPv4:
      begin
        if APrefix <= 32 then
          NewIPv4(APrefix)
        else
          raise InvalidArgumentException.Create('Invalid prefix length passed to TIPAddress');
      end;
    TAddressFamily.IPv6:
      begin
        if APrefix <= 128 then
          NewIPv6(APrefix)
        else
          raise InvalidArgumentException.Create('Invalid prefix length passed to TIPAddress');
      end;
    else
      raise InvalidArgumentException.Create('Invalid or unsupported address family passed to TIPAddress');
  end;
end;

constructor TIPAddress.Create(AAddress: Pointer; ALength: Integer; AScope: Cardinal);
begin
  case ALength of
    sizeof(in_addr):
      newIPv4(AAddress);
    sizeof(in6_addr):
      newIPv6(AAddress, AScope);
    else
      raise InvalidArgumentException.Create('Invalid address length passed to TIPAddress');
  end;
end;

constructor TIPAddress.Create(AAddress: Pointer; ALength: Integer);
begin
  case ALength of
    sizeof(in_addr):
      newIPv4(AAddress);
    sizeof(in6_addr):
      newIPv6(AAddress);
    else
      raise InvalidArgumentException.Create('Invalid address length passed to TIPAddress');
  end;
end;

class operator TIPAddress.Equal(const A, B: TIPAddress): Boolean;
begin
	if A.Length = B.Length then
  begin
    if A.Scope <> B.Scope then
      exit(false);

    result := CompareMem(A.Addr, B.Addr, A.Length);
  end
	else
    result := false;
end;

class operator TIPAddress.NotEqual(const A, B: TIPAddress): Boolean;
begin
  result := not (A = B);
end;

class operator TIPAddress.GreaterThan(const A, B: TIPAddress): Boolean;
begin
  result := B < A;
end;

class operator TIPAddress.GreaterThanOrEqual(const A, B: TIPAddress): Boolean;
begin
  result := not (A < B);
end;

class operator TIPAddress.LessThanOrEqual(const A, B: TIPAddress): Boolean;
begin
  result := not (B < A);
end;

class operator TIPAddress.LessThan(const A, B: TIPAddress): Boolean;
begin
	if A.Length = B.Length then
  begin
    if A.Scope <> B.Scope then
      exit(A.Scope < B.Scope);

    result := memcmp(A.Addr, B.Addr, A.Length) < 0;
  end
	else
    result := A.Length < B.Length;
end;

class operator TIPAddress.BitwiseAnd(const A, B: TIPAddress): TIPAddress;
begin
	if A.FFamily = B.FFamily then
  begin
    result.FFamily := A.FFamily;
    case A.family of
      TAddressFamily.IPv4:
        result.FImplv4 := A.FImplv4 and B.FImplv4;
      TAddressFamily.IPv6:
        result.FImplv6 := A.FImplv6 and B.FImplv6;
    	else
        raise InvalidArgumentException.Create('Invalid or unsupported address family passed to TIPAddress');
    end;
	end
	else
    raise InvalidArgumentException.Create('Invalid or unsupported address family passed to TIPAddress');
end;

class operator TIPAddress.BitwiseOr(const A, B: TIPAddress): TIPAddress;
begin
	if A.FFamily = B.FFamily then
  begin
    result.FFamily := A.FFamily;
    case A.family of
      TAddressFamily.IPv4:
        result.FImplv4 := A.FImplv4 or B.FImplv4;
      TAddressFamily.IPv6:
        result.FImplv6 := A.FImplv6 or B.FImplv6;
    	else
        raise InvalidArgumentException.Create('Invalid or unsupported address family passed to TIPAddress');
    end;
	end
	else
    raise InvalidArgumentException.Create('Invalid or unsupported address family passed to TIPAddress');
end;

class operator TIPAddress.BitwiseXor(const A, B: TIPAddress): TIPAddress;
begin
	if A.FFamily = B.FFamily then
  begin
    result.FFamily := A.FFamily;
    case A.family of
      TAddressFamily.IPv4:
        result.FImplv4 := A.FImplv4 xor B.FImplv4;
      TAddressFamily.IPv6:
        result.FImplv6 := A.FImplv6 xor B.FImplv6;
    	else
        raise InvalidArgumentException.Create('Invalid or unsupported address family passed to TIPAddress');
    end;
	end
	else
    raise InvalidArgumentException.Create('Invalid or unsupported address family passed to TIPAddress');
end;

class operator TIPAddress.LogicalNot(const A: TIPAddress): TIPAddress;
begin
  result.FFamily := A.FFamily;
  case A.FFamily of
    TAddressFamily.IPv4:
      result.FImplv4 := not A.FImplv4;
    TAddressFamily.IPv6:
      result.FImplv6 := not A.FImplv6;
    else
      raise InvalidArgumentException.Create('Invalid or unsupported address family passed to TIPAddress');
  end;
end;

end.
