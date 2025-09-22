unit Breeze.Net.SocketAddressImpl;

interface

uses Winapi.Winsock2, Winapi.IpExport, System.Win.Crtl, System.SysUtils, Breeze.Net.IPAddress, Breeze.Net.SocketDefs;

type
  TIPv4SocketAddressImpl = record
  private
    FHost: TIPAddress;
    FPort: Word;
    FAddr: sockaddr_in;
  public
    procedure Create; overload;
    constructor Create(const AValue: TIPv4SocketAddressImpl); overload;
    constructor Create(AInAddr: pin_addr; APort: Word); overload;
    constructor Create(ASockAddrIn: PSockAddrIn); overload;
    constructor Create(const AIPAddress: TIPAddress; APort: Word); overload;

    function NativeFamily: Integer;
    function Family: TAddressFamily;
    function Length: Cardinal;
    function Addr: PSockAddr;
    function ToString: String;

    property Host: TIPAddress read FHost;
    property Port: Word read FPort;
  end;

  TIPv6SocketAddressImpl = record
  private
    FHost: TIPAddress;
    FPort: Word;
    FAddr: sockaddr_in6;
  public
    constructor Create(const AValue: TIPv6SocketAddressImpl); overload;
    constructor Create(ASockAddrIn6: psockaddr_in6); overload;
    constructor Create(AIn6Addr: PIn6Addr; APort: Word); overload;
    constructor Create(AIn6Addr: PIn6Addr; APort: Word; AScope: Cardinal); overload;
    constructor Create(const AIPAddress: TIPAddress; APort: Word); overload;

    function NativeFamily: Integer;
    function Family: TAddressFamily;
    function Length: Cardinal;
    function Addr: PSockAddr;
    function ToString: String;

    property Host: TIPAddress read FHost;
    property Port: Word read FPort;
  end;

implementation

{ TIPv4SocketAddressImpl }

function TIPv4SocketAddressImpl.NativeFamily: Integer;
begin
  result := FHost.NativeFamily;
end;

procedure TIPv4SocketAddressImpl.Create;
begin
  FHost := TIPAddress.Create(TAddressFamily.IPv4);
  FPort := 0;
end;

function TIPv4SocketAddressImpl.Family: TAddressFamily;
begin
  result := FHost.Family;
end;

constructor TIPv4SocketAddressImpl.Create(AInAddr: pin_addr; APort: Word);
begin
  FHost := TIPAddress.Create(AInAddr, sizeof(in_addr));
  FPort := APort;
end;

constructor TIPv4SocketAddressImpl.Create(ASockAddrIn: PSockAddrIn);
begin
  FHost := TIPAddress.Create(@ASockAddrIn.sin_addr, sizeof(ASockAddrIn.sin_addr));
  FPort := ASockAddrIn.sin_port;
end;

function TIPv4SocketAddressImpl.Addr: PSockAddr;
begin
	FAddr.sin_family := AF_INET;
  FAddr.sin_port := port;
	memcpy(@FAddr.sin_addr, FHost.addr, FHost.length); // in_addr
	memset(@FAddr.sin_zero, 0, sizeof(FAddr.sin_zero));

  result := PSockAddr(@FAddr);
end;

function TIPv4SocketAddressImpl.Length: Cardinal;
begin
  result := sizeof(FAddr);
end;

constructor TIPv4SocketAddressImpl.Create(const AIPAddress: TIPAddress; APort: Word);
begin
  FHost := TIPAddress.Create(AIPAddress);
  FPort := APort;
end;

constructor TIPv4SocketAddressImpl.Create(const AValue: TIPv4SocketAddressImpl);
begin
  FHost := AValue.FHost;
  FPort := AValue.FPort;
  FAddr := AValue.FAddr;
end;

function TIPv4SocketAddressImpl.ToString: String;
begin
	result := FHost.ToString + ':' + IntToStr(ntohs(FPort));
end;

{ TIPv6SocketAddressImpl }

constructor TIPv6SocketAddressImpl.Create(ASockAddrIn6: psockaddr_in6);
begin
  FHost := TIPAddress.Create(@ASockAddrIn6.sin6_addr, sizeof(ASockAddrIn6.sin6_addr));
  FPort := ASockAddrIn6.sin6_port;
end;

constructor TIPv6SocketAddressImpl.Create(AIn6Addr: PIn6Addr; APort: Word);
begin
  Create(AIn6Addr, APort, 0);
end;

constructor TIPv6SocketAddressImpl.Create(AIn6Addr: PIn6Addr; APort: Word; AScope: Cardinal);
begin
  FHost := TIPAddress.Create(AIn6Addr, sizeof(in6_addr));
  FPort := APort;
end;

function TIPv6SocketAddressImpl.Addr: PSockAddr;
begin
	FAddr.sin6_family := AF_INET6;
  FAddr.sin6_port := FPort;
  FAddr.sin6_flowinfo := 0;
	memcpy(@FAddr.sin6_addr, FHost.Addr, FHost.Length); // in6_addr
  FAddr.Value := 0;

  result := PSockAddr(@FAddr);
end;

function TIPv6SocketAddressImpl.Length: Cardinal;
begin
  result := sizeof(FAddr);
end;

function TIPv6SocketAddressImpl.NativeFamily: Integer;
begin
  result := FHost.NativeFamily;
end;

constructor TIPv6SocketAddressImpl.Create(const AIPAddress: TIPAddress; APort: Word);
begin
  FHost.Assign(AIPAddress);
  FPort := APort;
end;

constructor TIPv6SocketAddressImpl.Create(const AValue: TIPv6SocketAddressImpl);
begin
  FHost := AValue.FHost;
  FPort := AValue.FPort;
  FAddr := AValue.FAddr;
end;

function TIPv6SocketAddressImpl.Family: TAddressFamily;
begin
  result := FHost.Family;
end;

function TIPv6SocketAddressImpl.ToString: String;
begin
	result := '[' + FHost.ToString + ']:' + IntToStr(ntohs(FPort));
end;

end.
