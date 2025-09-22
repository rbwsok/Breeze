unit Breeze.Net.DNS;

interface

uses Winapi.Winsock2, System.win.Crtl, System.StrUtils, System.Generics.Collections, System.SysUtils,
  Breeze.Net.SocketDefs, Breeze.Net.IPAddress, Breeze.Net.SocketAddress, Breeze.Net.HostEntry, PunnyCode, Breeze.Exception;

type
  TDNS = class
	/// This class provides an interface to the
	/// domain name service.
	///
	/// Starting with POCO C++ Libraries release 1.9.0,
	/// this class also supports Internationalized Domain Names (IDNs).
	///
	/// Regarding IDNs, the following rules apply:
	///
	///   * An IDN passed to hostByName() must be encoded manually, by calling
	///     encodeIDN() (after testing with isIDN() first).
	///   * An UTF-8 IDN passed to resolve() or resolveOne() is automatically encoded.
	///   * IDNs returned in HostEntry objects are never decoded. They can be
	///     decoded by calling decodeIDN() (after testing for an encoded IDN by
	///     calling isEncodedIDN()).
  public
    const
      DNS_HINT_NONE           = 0;
      DNS_HINT_AI_PASSIVE     = AI_PASSIVE;     /// Socket address will be used in bind() call
      DNS_HINT_AI_CANONNAME   = AI_CANONNAME;   /// Return canonical name in first ai_canonname
      DNS_HINT_AI_NUMERICHOST = AI_NUMERICHOST; /// Nodename must be a numeric address string
      DNS_HINT_AI_NUMERICSERV = AI_NUMERICSERV; /// Servicename must be a numeric port number
      DNS_HINT_AI_ALL         = AI_ALL;         /// Query both IP6 and IP4 with AI_V4MAPPED
      DNS_HINT_AI_ADDRCONFIG  = AI_ADDRCONFIG;  /// Resolution only if global address configured
      DNS_HINT_AI_V4MAPPED    = AI_V4MAPPED;    /// On v6 failure, query v4 and convert to V4MAPPED format

	  class function HostByName(const AHostname: String; AHintFlags: Cardinal = DNS_HINT_AI_CANONNAME or DNS_HINT_AI_ADDRCONFIG): THostEntry;
		/// Returns a HostEntry object containing the DNS information
		/// for the host with the given name. HintFlag argument is only
		/// used on platforms that have getaddrinfo().
		///
		/// Note that Internationalized Domain Names must be encoded
		/// using Punycode (see encodeIDN()) before calling this method.
		///
		/// Throws a HostNotFoundException if a host with the given
		/// name cannot be found.
		///
		/// Throws a NoAddressFoundException if no address can be
		/// found for the hostname.
		///
		/// Throws a DNSException in case of a general DNS error.
		///
		/// Throws an IOException in case of any other error.

	  class function HostByAddress(const AAddress: TIPAddress; AHintFlags: Cardinal = DNS_HINT_AI_CANONNAME or DNS_HINT_AI_ADDRCONFIG): THostEntry;
		/// Returns a HostEntry object containing the DNS information
		/// for the host with the given IP address. HintFlag argument is only
		/// used on platforms that have getaddrinfo().
		///
		/// Throws a HostNotFoundException if a host with the given
		/// name cannot be found.
		///
		/// Throws a DNSException in case of a general DNS error.
		///
		/// Throws an IOException in case of any other error.

	  class function Resolve(const AAddress: String) : THostEntry;
		/// Returns a HostEntry object containing the DNS information
		/// for the host with the given IP address or host name.
		///
		/// If address contains a UTF-8 encoded IDN (internationalized
		/// domain name), the domain name will be encoded first using
		/// Punycode.
		///
		/// Throws a HostNotFoundException if a host with the given
		/// name cannot be found.
		///
		/// Throws a NoAddressFoundException if no address can be
		/// found for the hostname.
		///
		/// Throws a DNSException in case of a general DNS error.
		///
		/// Throws an IOException in case of any other error.

	  class function ResolveOne(const AAddress: String): TIPAddress;
		/// Convenience method that calls resolve(address) and returns
		/// the first address from the HostInfo.

	  class function ThisHost: THostEntry;
		/// Returns a HostEntry object containing the DNS information
		/// for this host.
		///
		/// Throws a HostNotFoundException if DNS information
		/// for this host cannot be found.
		///
		/// Throws a NoAddressFoundException if no address can be
		/// found for this host.
		///
		/// Throws a DNSException in case of a general DNS error.
		///
		/// Throws an IOException in case of any other error.

	  class procedure Reload;
		/// Reloads the resolver configuration.
		///
		/// This method will call res_init() if the Net library
		/// has been compiled with -DPOCO_HAVE_LIBRESOLV. Otherwise
		/// it will do nothing.

	  class function HostName: String;
		/// Returns the host name of this host.

	  class function IsIDN(const AHostName: String): Boolean;
		/// Returns true if the given hostname is an internationalized
		/// domain name (IDN) containing non-ASCII characters, otherwise false.
		///
		/// The IDN must be UTF-8 encoded.

	  class function IsEncodedIDN(const AHostName: AnsiString): Boolean;
		/// Returns true if the given hostname is an Punycode-encoded
		/// internationalized domain name (IDN), otherwise false.
		///
		/// An encoded IDN starts with the character sequence "xn--".

	  class function EncodeIDN(const AIDN: String): AnsiString;
		/// Encodes the given IDN (internationalized domain name), which must
		/// be in UTF-8 encoding.
		///
		/// The resulting string will be encoded according to Punycode.

	  class function DecodeIDN(const AEncodedIDN: AnsiString): String;
		/// Decodes the given Punycode-encoded IDN (internationalized domain name).
		///
		/// The resulting string will be UTF-8 encoded.

  protected
	  class function LastError: Integer;
		/// Returns the code of the last error.

	  class procedure Error(ACode: Integer; const AArg: String);
		/// Throws an exception according to the error code.

	  class procedure AddrInfoError(ACode: Integer; const AArg: String);
		/// Throws an exception according to the getaddrinfo() error code.
  end;

implementation

uses System.AnsiStrings;

{ TDNS }

class procedure TDNS.AddrInfoError(ACode: Integer; const AArg: String);
begin
	case ACode of
	  EAI_AGAIN:
		  raise DNSException.Create('Temporary DNS error while resolving ' + AArg);
	  EAI_FAIL:
		  raise DNSException.Create('Non recoverable DNS error while resolving' + AArg);
    EAI_NONAME:
		  raise HostNotFoundException.Create(AArg);
    WSANO_DATA: // may happen on XP
		  raise HostNotFoundException.Create(AArg);
	  else
		  raise DNSException.Create('EAI ' + IntToStr(ACode));
  end;
end;

class function TDNS.decodeIDN(const AEncodedIDN: AnsiString): String;
begin
  result := PunycodeDecodeDomain(AEncodedIDN);
end;

class function TDNS.encodeIDN(const AIDN: String): AnsiString;
begin
  result := PunycodeEncodeDomain(AIDN);
end;

class procedure TDNS.error(ACode: Integer; const AArg: String);
begin
	case ACode of
	  WSASYSNOTREADY:
		  raise NetException.Create('Net subsystem not ready');
    WSANOTINITIALISED:
		  raise NetException.Create('Net subsystem not initialized');
    WSAHOST_NOT_FOUND:
		  raise HostNotFoundException.Create(AArg);
    WSATRY_AGAIN:
		  raise DNSException.Create('Temporary DNS error while resolving ' + AArg);
    WSANO_RECOVERY:
		  raise DNSException.Create('Non recoverable DNS error while resolving ' + AArg);
    WSANO_DATA:
		  raise NoAddressFoundException.Create(AArg);
    else
		  raise IOException.Create(IntToStr(ACode));
  end;
end;

class function TDNS.hostByAddress(const AAddress: TIPAddress; AHintFlags: Cardinal): THostEntry;
var
  LSocketAddress: TSocketAddress;
	LBuffer: array [0..1023] of AnsiChar;
  LReturn: Integer;
  LError: Integer;
  LAddrInfo: Paddrinfo;
  LHints: addrinfo;
begin
  LSocketAddress := TSocketAddress.Create(AAddress, 0);
	LReturn := getnameinfo(LSocketAddress.Addr, LSocketAddress.Length, LBuffer, sizeof(LBuffer), nil, 0, NI_NAMEREQD);
	if LReturn = 0 then
	begin
		memset(@LHints, 0, sizeof(LHints));
		LHints.ai_flags := AHintFlags;
		LReturn := getaddrinfo(LBuffer, nil, @LHints, LAddrInfo);
		if LReturn = 0 then
    begin
			result := THostEntry.Create(LAddrInfo);
			freeaddrinfo(LAddrInfo);
			exit;
		end
		else
			AddrInfoError(LReturn, AAddress.toString);
  end
	else
		AddrInfoError(LReturn, AAddress.toString);

  LError := LastError();
  error(LError, AAddress.toString); // will throw an appropriate exception
  raise NetException.Create(''); // to silence compiler
end;

class function TDNS.HostByName(const AHostname: String; AHintFlags: Cardinal): THostEntry;
var
  LAddrInfo: Paddrinfo;
  LHints: addrinfo;
  LReturn: Integer;
  LHostNameAnsi: AnsiString;
begin
  LHostNameAnsi := AnsiString(AHostname);
	memset(@LHints, 0, sizeof(LHints));
	LHints.ai_flags := AHintFlags;
	LReturn := getaddrinfo(@LHostNameAnsi[1], nil, @LHints, LAddrInfo);
	if LReturn = 0 then
  begin
		result := THostEntry.Create(LAddrInfo);
		freeaddrinfo(LAddrInfo);
		exit;
  end
	else
		AddrInfoError(LReturn, hostname);

	Error(LastError, Hostname); // will throw an appropriate exception
	raise NetException.Create(''); // to silence compiler
end;

class function TDNS.HostName: String;
var
  LBuffer: array [0..255] of AnsiChar;
  LReturn: Integer;
begin
	LReturn := gethostname(LBuffer, sizeof(LBuffer));
	if LReturn = 0 then
		exit(String(LBuffer))
	else
		raise NetException.Create('Cannot get host name');
end;

class function TDNS.IsEncodedIDN(const AHostName: AnsiString): Boolean;
begin
	result := (System.AnsiStrings.LeftStr(AHostName, 4) = 'xn--') or (System.AnsiStrings.PosEx('.xn--', AHostName) > 0);
end;

class function TDNS.IsIDN(const AHostName: String): Boolean;
var
  LUTF8String: UTF8String;
  LChar: AnsiChar;
begin
  LUTF8String := UTF8Encode(AHostName);
	for LChar in LUTF8String do
  begin
		if LChar >= #$80 then
      exit(true);
  end;

	result := false;
end;

class function TDNS.LastError: Integer;
begin
  result := GetLastError;
end;

class procedure TDNS.Reload;
begin

end;

class function TDNS.Resolve(const AAddress: String): THostEntry;
var
	ip: TIPAddress;
  AEncodedString: String;
begin
	if TIPAddress.tryParse(AAddress, ip) then
		exit(hostByAddress(ip))
	else
  if IsIDN(AAddress) then
  begin
		AEncodedString := String(encodeIDN(AAddress));
		exit(hostByName(AEncodedString));
	end
	else
		exit(hostByName(AAddress));
end;

class function TDNS.ResolveOne(const AAddress: String): TIPAddress;
var
  LEntry: THostEntry;
begin
	LEntry := resolve(AAddress);
	if not LEntry.addresses.IsEmpty then
		exit(LEntry.addresses[0])
	else
		raise NoAddressFoundException.Create(AAddress);
end;

class function TDNS.thisHost: THostEntry;
begin
  result := hostByName(hostName);
end;

end.
