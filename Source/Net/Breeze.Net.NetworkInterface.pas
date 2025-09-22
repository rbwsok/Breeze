unit Breeze.Net.NetworkInterface;

interface

uses Winapi.Windows, Winapi.IpTypes, Winapi.Winsock2, Winapi.IpHlpApi, System.Win.Crtl, Generics.Collections, System.SysUtils,

Breeze.Net.IPAddress, Breeze.Net.SocketDefs, Breeze.Exception;

type
  TAddressTuple = class
  private
    FAddress: TIPAddress;
    FMask: TIPAddress;
    FBroadcast: TIPAddress;
  public
    constructor Create(AAddress, AMask, ABroadcast: TIPAddress); overload;
    constructor Create(AAddress: TIPAddress); overload;
    constructor Create(const ATuple: TAddressTuple); overload;
    destructor Destroy; override;

    procedure Assign(const ATuple: TAddressTuple);

    property Address: TIPAddress read FAddress;
    property Mask: TIPAddress read FMask;
    property Broadcast: TIPAddress read FBroadcast;
  end;

  TNetworkInterfaceImpl = class;

  TNetworkInterface = class
  public
  type
    TAddressType =
    (
      IP_ADDRESS,
      SUBNET_MASK,
      BROADCAST_ADDRESS
    );

    TType =
    (
      NI_TYPE_ETHERNET_CSMACD,
      NI_TYPE_ISO88025_TOKENRING,
      NI_TYPE_FRAMERELAY,
      NI_TYPE_PPP,
      NI_TYPE_SOFTWARE_LOOPBACK,
      NI_TYPE_ATM,
      NI_TYPE_IEEE80211,
      NI_TYPE_TUNNEL,
      NI_TYPE_IEEE1394,
      NI_TYPE_OTHER
    );

    TIPVersion =
    (
      IPv4_ONLY,    /// Return interfaces with IPv4 address only
      IPv6_ONLY,    /// Return interfaces with IPv6 address only
      IPv4_OR_IPv6  /// Return interfaces with IPv4 or IPv6 address
    );

	  const NO_INDEX = $ffffffff;
	  const MAC_SEPARATOR = '-';

  private
	  FImpl: TNetworkInterfaceImpl;

  public
  	constructor Create(AIndex: Cardinal = NO_INDEX); overload;
		/// Creates a NetworkInterface representing the
		/// default interface.
		///
		/// The name is empty, the IP address is the wildcard
		/// address and the index is max value of unsigned integer.

    constructor Create(const ANetworkInterface: TNetworkInterface); overload;
		/// Creates the NetworkInterface by copying another one.

  	destructor Destroy; override;
		/// Destroys the NetworkInterface.

//	NetworkInterface& operator = (const NetworkInterface& interfc);
		/// Assigns another NetworkInterface.

//	bool operator < (const NetworkInterface& other) const;
		/// Operator less-than.

//	bool operator == (const NetworkInterface& other) const;
		/// Operator equal. Compares interface indices.

//	void swap(NetworkInterface& other) noexcept;
		/// Swaps the NetworkInterface with another one.

	  function InterfaceIndex: Cardinal;
		/// Returns the interface OS index.

	  function Name: String;
		/// Returns the interface name.

	  function DisplayName: String;
		/// Returns the interface display name.
		///
		/// On Windows platforms, this is currently the network adapter
		/// name. This may change to the "friendly name" of the network
		/// connection in a future version, however.
		///
		/// On other platforms this is the same as name().

	  function AdapterName: String;
		/// Returns the interface adapter name.
		///
		/// On Windows platforms, this is the network adapter LUID.
		/// The adapter name is used by some Windows Net APIs like DHCP.
		///
		/// On other platforms this is the same as name().

	  function FirstAddress(AFamily: TAddressFamily): TIPAddress; overload;
		/// Returns the first IP address bound to the interface.
		/// Throws NotFoundException if the address family is not
		/// configured on the interface.

	  procedure FirstAddress(var AIPAddress: TIPAddress; AFamily: TAddressFamily = TAddressFamily.IPv4); overload;
		/// Returns the first IP address bound to the interface.
		/// If the address family is not configured on the interface,
		/// the address returned in addr will be unspecified (wildcard).

	  function Address(AIndex: Cardinal = 0): TIPAddress;
		/// Returns the IP address bound to the interface at index position.

//    procedure addAddress(const address: TIPAddress); overload;
		/// Adds address to the interface.

//    procedure addAddress(const address, subnetMask, broadcastAddress: TIPAddress); overload;
		/// Adds address to the interface.

    function AddressList: TObjectList<TAddressTuple>;
		/// Returns the list of IP addresses bound to the interface.

	  function SubnetMask(AIndex: Cardinal = 0): TIPAddress;
		/// Returns the subnet mask for this network interface.

	  function BroadcastAddress(AIndex: Cardinal = 0): TIPAddress;
		/// Returns the broadcast address for this network interface.

	  function DestAddress(AIndex: Cardinal = 0): TIPAddress;
		/// Returns the IPv4 point-to-point destination address for this network interface.

	  function MACAddress: RawByteString;
		/// Returns MAC (Media Access Control) address for the interface.

  	function MTU: Cardinal;
		/// Returns the MTU for this interface.

    function InterfaceType: TType;
		/// returns the MIB IfType of the interface.

	  function SupportsIP: Boolean;
		/// Returns true if the interface supports IP.

	  function SupportsIPv4: Boolean;
		/// Returns true if the interface supports IPv4.

	  function SupportsIPv6: Boolean;
		/// Returns true if the interface supports IPv6.

	  function SupportsBroadcast: Boolean;
		/// Returns true if the interface supports broadcast.

	  function SupportsMulticast: Boolean;
		/// Returns true if the interface supports multicast.

	  function IsLoopback: Boolean;
		/// Returns true if the interface is loopback.

	  function IsPointToPoint: Boolean;
		/// Returns true if the interface is point-to-point.

	  function IsRunning: Boolean;
		/// Returns true if the interface is running.

	  function IsUp: Boolean;
		/// Returns true if the interface is up.

	  class function ForName(const AName: String; requireIPv6: Boolean = false): TNetworkInterface; overload;
		/// Returns the NetworkInterface for the given name.
		///
		/// If requireIPv6 is false, an IPv4 interface is returned.
		/// Otherwise, an IPv6 interface is returned.
		///
		/// Throws an InterfaceNotFoundException if an interface
		/// with the give name does not exist.

	  class function ForName(const AName: String; AIPVersion: TIPVersion): TNetworkInterface; overload;
		/// Returns the NetworkInterface for the given name.
		///
		/// The ipVersion argument can be used to specify whether
		/// an IPv4 (IPv4_ONLY) or IPv6 (IPv6_ONLY) interface is required,
		/// or whether the caller does not care (IPv4_OR_IPv6).
		///
		/// Throws an InterfaceNotFoundException if an interface
		/// with the give name does not exist.

	  class function ForAddress(const AAddress: TIPAddress): TNetworkInterface;
		/// Returns the NetworkInterface for the given IP address.
		///
		/// Throws an InterfaceNotFoundException if an interface
		/// with the give address does not exist.

	  class function ForIndex(AIndex: Cardinal): TNetworkInterface;
		/// Returns the NetworkInterface for the given interface index.
		///
		/// Throws an InterfaceNotFoundException if an interface
		/// with the given index does not exist.

    class function List(const AIPOnly: Boolean = true; const AUPOnly: Boolean = true): TObjectList<TNetworkInterface>;
		/// Returns a list with all network interfaces
		/// on the system.
		///
		/// If ipOnly is true, only interfaces supporting IP
		/// are returned. Otherwise, all system network interfaces
		/// are returned.
		///
		/// If upOnly is true, only interfaces being up are returned.
		/// Otherwise, both interfaces being up and down are returned.
		///
		/// If there are multiple addresses bound to one interface,
		/// multiple NetworkInterface entries are listed for
		/// the same interface.

    class function MACToString(const AMACData: RawByteString): String; static;
  end;

  TNetworkInterfaceImpl = class
  strict private
	  FName: String;
    FDisplayName: String;
	  FAdapterName: String;
  	FAddressList: TObjectList<TAddressTuple>;
	  FIndex: Cardinal;
  	FBroadcast: Boolean;
	  FLoopback: Boolean;
	  FMulticast: Boolean;
  	FPointToPoint: Boolean;
  	FUp: Boolean;
	  FRunning: Boolean;
  	FMTU: Cardinal;
	  FType: TNetworkInterface.TType;
  public
    FMACAddress: RawByteString;

    constructor Create; overload;
    constructor Create(const ANetworkInterfaceImpl: TNetworkInterfaceImpl); overload;
    destructor Destroy; override;

    procedure SetFlags(AFlags: DWORD; AInterfaceType: DWORD);
    function FromNative(t: DWORD): TNetworkInterface.TType;
    function GetBroadcastAddress(APIPAdapterPrefix: PIP_ADAPTER_PREFIX; const AIPAddress: TIPAddress; APrefix: PULONG = nil): TIPAddress;

    function Address(AIndex: Cardinal): TIPAddress;
    function SubnetMask(AIndex: Cardinal): TIPAddress;
    function BroadcastAddress(Aindex: Cardinal): TIPAddress;
    function SupportsIPv4: Boolean;
    function SupportsIPv6: Boolean;
    function FirstAddress(AFamily: TAddressFamily): TIPAddress;
 	  function DestAddress(Aindex: Cardinal): TIPAddress;

	  property Name: String read FName write FName;
	  property DisplayName: String read FDisplayName write FDisplayName;
	  property AdapterName: String read FAdapterName write FAdapterName;
	  property AddressList: TObjectList<TAddressTuple> read FAddressList;
	  property InterfaceIndex: Cardinal read FIndex write FIndex;
	  property Broadcast: Boolean read FBroadcast write FBroadcast;
	  property Loopback: Boolean read FLoopback write FLoopback;
	  property Multicast: Boolean read FMulticast write FMulticast;
	  property PointToPoint: Boolean read FPointToPoint write FPointToPoint;
	  property Up: Boolean read FUp write FUp;
	  property Running: Boolean read FRunning write FRunning;
	  property MTU: Cardinal read FMTU write FMTU;
	  property InterfaceType: TNetworkInterface.TType read FType write FType;
  end;

implementation

constructor TAddressTuple.Create(AAddress, AMask, ABroadcast: TIPAddress);
begin
  FAddress := AAddress;
  FMask := AMask;
  FBroadcast := ABroadcast;
end;

constructor TAddressTuple.Create(AAddress: TIPAddress);
var
  LMask, LBroadcast: TIPAddress;
begin
  LMask.Create;
  LBroadcast.Create;
  Create(AAddress, LMask, LBroadcast);
end;

procedure TAddressTuple.Assign(const ATuple: TAddressTuple);
begin
  FAddress.Assign(ATuple.FAddress);
  FMask.Assign(ATuple.FMask);
  FBroadcast.Assign(ATuple.FBroadcast);
end;

constructor TAddressTuple.Create(const ATuple: TAddressTuple);
var
  LAddress: TIPAddress;
  LMask: TIPAddress;
  LBroadcast: TIPAddress;
begin
  LAddress := TIPAddress.Create(ATuple.FAddress);
  LMask := TIPAddress.Create(ATuple.FMask);
  LBroadcast := TIPAddress.Create(ATuple.FBroadcast);
  Create(LAddress, LMask, LBroadcast);
end;

destructor TAddressTuple.Destroy;
begin
  inherited;
end;

{ TNetworkInterfaceImpl }

function TNetworkInterfaceImpl.Address(AIndex: Cardinal): TIPAddress;
begin
	if AIndex < Cardinal(FAddressList.Count) then
		 exit(FAddressList[AIndex].FAddress);

  raise NotFoundException.Create('No address with index ' + IntToStr(AIndex));
end;

function TNetworkInterfaceImpl.BroadcastAddress(AIndex: Cardinal): TIPAddress;
begin
	if AIndex < Cardinal(FAddressList.Count) then
		 exit(FAddressList[AIndex].FBroadcast);

  raise NotFoundException.Create('No broadcast mask with index ' + IntToStr(AIndex));
end;

constructor TNetworkInterfaceImpl.Create(const ANetworkInterfaceImpl: TNetworkInterfaceImpl);
var
  LTuple: TAddressTuple;
begin
  FName := ANetworkInterfaceImpl.FName;
  FDisplayName := ANetworkInterfaceImpl.FDisplayName;
  FAdapterName := ANetworkInterfaceImpl.FAdapterName;
  FIndex := ANetworkInterfaceImpl.FIndex;
  FBroadcast := ANetworkInterfaceImpl.FBroadcast;
  FLoopback := ANetworkInterfaceImpl.FLoopback;
  FMulticast := ANetworkInterfaceImpl.FMulticast;
  FPointToPoint := ANetworkInterfaceImpl.FPointToPoint;
  FUp := ANetworkInterfaceImpl.FUp;
  FRunning := ANetworkInterfaceImpl.FRunning;
  FMTU := ANetworkInterfaceImpl.FMTU;
  FType := ANetworkInterfaceImpl.FType;
  FMACAddress := ANetworkInterfaceImpl.FMACAddress;

  FAddressList := TObjectList<TAddressTuple>.Create;
  for LTuple in ANetworkInterfaceImpl.FAddressList do
    FAddressList.Add(TAddressTuple.Create(LTuple));
end;

constructor TNetworkInterfaceImpl.Create;
begin
  FAddressList := TObjectList<TAddressTuple>.Create;
end;

function TNetworkInterfaceImpl.DestAddress(AIndex: Cardinal): TIPAddress;
begin
	if not FPointToPoint then
		raise InvalidAccessException.Create('Only PPP addresses have destination address.')
	else
  if Aindex < Cardinal(FAddressList.Count) then
		exit(FAddressList[AIndex].FBroadcast);

	raise NotFoundException.Create('No address with index ' + IntToStr(AIndex));
end;

destructor TNetworkInterfaceImpl.Destroy;
begin
  FAddressList.Free;
  inherited;
end;

function TNetworkInterfaceImpl.FirstAddress(AFamily: TAddressFamily): TIPAddress;
var
  LTuple: TAddressTuple;
  LExceptionText: String;
begin
  for LTuple in FAddressList do
  begin
		if LTuple.FAddress.family = AFamily then
			exit(LTuple.FAddress);
  end;

  if AFamily = TAddressFamily.IPv4 then
    LExceptionText := 'IPv4'
  else
    LExceptionText := 'IPv6';

  raise NotFoundException.Create(LExceptionText + ' family address not found.');
end;

function TNetworkInterfaceImpl.fromNative(t: DWORD): TNetworkInterface.TType;
begin
  result := TNetworkInterface.TType.NI_TYPE_OTHER;
  case t of
  	IF_TYPE_ETHERNET_CSMACD:
      result := TNetworkInterface.TType.NI_TYPE_ETHERNET_CSMACD;
	  IF_TYPE_ISO88025_TOKENRING:
      result := TNetworkInterface.TType.NI_TYPE_ISO88025_TOKENRING;
	  IF_TYPE_FRAMERELAY:
      result := TNetworkInterface.TType.NI_TYPE_FRAMERELAY;
	  IF_TYPE_PPP:
      result := TNetworkInterface.TType.NI_TYPE_PPP;
	  IF_TYPE_SOFTWARE_LOOPBACK:
      result := TNetworkInterface.TType.NI_TYPE_SOFTWARE_LOOPBACK;
	  IF_TYPE_ATM:
      result := TNetworkInterface.TType.NI_TYPE_ATM;
	  IF_TYPE_IEEE80211:
      result := TNetworkInterface.TType.NI_TYPE_IEEE80211;
	  IF_TYPE_TUNNEL:
      result := TNetworkInterface.TType.NI_TYPE_TUNNEL;
	  IF_TYPE_IEEE1394:
      result := TNetworkInterface.TType.NI_TYPE_IEEE1394;
  end;
end;

function TNetworkInterfaceImpl.GetBroadcastAddress(APIPAdapterPrefix: PIP_ADAPTER_PREFIX; const AIPAddress: TIPAddress;
  APrefix: PULONG): TIPAddress;
var
  LPIPAdapterPrefixPrev: PIP_ADAPTER_PREFIX;
  LFamily: DWORD;
  LIPAddress: TIPAddress;
	LIPPrefix, LMask, LIP1, LIP2: TIPAddress;
begin
  LPIPAdapterPrefixPrev := nil;

  while APIPAdapterPrefix <> nil do
  begin
		LFamily := APIPAdapterPrefix.Address.lpSockaddr.sa_family;
    LIPAddress := TIPAddress.Create(@APIPAdapterPrefix.Address);
 		if (LFamily = AF_INET) and (AIPAddress = LIPAddress) then
  		break;

		LPIPAdapterPrefixPrev := APIPAdapterPrefix;
    APIPAdapterPrefix := APIPAdapterPrefix.Next;
  end;

	if (APIPAdapterPrefix <> nil) and (APIPAdapterPrefix.Next <> nil) and (LPIPAdapterPrefixPrev <> nil) then
  begin
		LIPPrefix := TIPAddress.Create(LPIPAdapterPrefixPrev.PrefixLength, TAddressFamily.IPv4);
		LMask := TIPAddress.Create(@APIPAdapterPrefix.Next.Address);
    LIP1 := TIPAddress.Create(LIPPrefix);
    LIP1 := LIP1 and LMask;
    LIP2 := TIPAddress.Create(LIPPrefix);
    LIP2 := LIP2 and AIPAddress;
    if LIP1 = LIP2 then
    begin
      if APrefix <> nil then
        APrefix^ := APIPAdapterPrefix.PrefixLength;
      exit(TIPAddress.Create(@APIPAdapterPrefix.Next.Address));
    end;
  end;

	result := TIPAddress.Create(TAddressFamily.IPv4);
end;

procedure TNetworkInterfaceImpl.SetFlags(AFlags, AInterfaceType: DWORD);
begin
  FUp := false;
	FRunning := false;
  case AInterfaceType of
    IF_TYPE_ETHERNET_CSMACD,
    IF_TYPE_ISO88025_TOKENRING,
    IF_TYPE_IEEE80211:
      FMulticast := FBroadcast = true;
    IF_TYPE_SOFTWARE_LOOPBACK:
      FLoopback :=  true;
    IF_TYPE_PPP,
    IF_TYPE_ATM,
    IF_TYPE_TUNNEL,
    IF_TYPE_IEEE1394:
      FPointToPoint := true;
  end;

	if (AFlags and IP_ADAPTER_NO_MULTICAST) > 0 then
		FMulticast := true;
end;

function TNetworkInterfaceImpl.SubnetMask(AIndex: Cardinal): TIPAddress;
begin
	if AIndex < Cardinal(FAddressList.Count) then
		 exit(FAddressList[AIndex].FMask);

  raise NotFoundException.Create('No subnet mask with index ' + IntToStr(AIndex));
end;

function TNetworkInterfaceImpl.SupportsIPv4: Boolean;
var
  LTuple: TAddressTuple;
begin
  for LTuple in FAddressList do
  begin
		if LTuple.FAddress.Family = TAddressFamily.IPv4 then
			exit(true);
  end;

	result := false;
end;

function TNetworkInterfaceImpl.SupportsIPv6: Boolean;
var
  LTuple: TAddressTuple;
begin
  for LTuple in FAddressList do
  begin
		if LTuple.FAddress.Family = TAddressFamily.IPv6 then
			exit(true);
  end;

	result := false;
end;

{ TNetworkInterface }

function TNetworkInterface.AdapterName: String;
begin
  result := FImpl.AdapterName;
end;

function TNetworkInterface.Address(AIndex: Cardinal): TIPAddress;
begin
  result := FImpl.Address(AIndex);
end;

function TNetworkInterface.AddressList: TObjectList<TAddressTuple>;
begin
  result := FImpl.AddressList;
end;

function TNetworkInterface.BroadcastAddress(AIndex: Cardinal): TIPAddress;
begin
  result := FImpl.BroadcastAddress(AIndex);
end;

constructor TNetworkInterface.Create(const ANetworkInterface: TNetworkInterface);
begin
  FImpl.Free;
  FImpl := TNetworkInterfaceImpl.Create(ANetworkInterface.FImpl);
end;

constructor TNetworkInterface.Create(AIndex: Cardinal);
begin
  FImpl := TNetworkInterfaceImpl.Create;
end;

function TNetworkInterface.destAddress(AIndex: Cardinal): TIPAddress;
begin
  result := FImpl.destAddress(AIndex);
end;

destructor TNetworkInterface.Destroy;
begin
  FImpl.Free;
  inherited;
end;

function TNetworkInterface.DisplayName: String;
begin
  result := FImpl.DisplayName;
end;

function TNetworkInterface.FirstAddress(AFamily: TAddressFamily): TIPAddress;
begin
	result := FImpl.FirstAddress(AFamily);
end;

procedure TNetworkInterface.FirstAddress(var AIPAddress: TIPAddress; AFamily: TAddressFamily);
begin
	try
    AIPAddress.Assign(FirstAddress(AFamily));
	except
    AIPAddress := TIPAddress.Create(AFamily);
  end;
end;

class function TNetworkInterface.ForAddress(const AAddress: TIPAddress): TNetworkInterface;
var
  LInterfaceList: TObjectList<TNetworkInterface>;
  LNetworkInterface: TNetworkInterface;
  LTuple: TAddressTuple;
begin
  LInterfaceList := TNetworkInterface.List(false, false);

  try
    for LNetworkInterface in LInterfaceList do
    begin
      for LTuple in LNetworkInterface.addressList do
      begin
        if LTuple.FAddress = AAddress then
          exit(TNetworkInterface.Create(LNetworkInterface));
      end;
    end;
  finally
    LInterfaceList.Free;
  end;

  raise NotFoundException.Create('Not Found ' + AAddress.toString);
end;

class function TNetworkInterface.ForIndex(AIndex: Cardinal): TNetworkInterface;
var
  LInterfaceList: TObjectList<TNetworkInterface>;
  LNetworkInterface: TNetworkInterface;
begin
	if AIndex <> TNetworkInterface.NO_INDEX then
	begin
    LInterfaceList := TNetworkInterface.List(false, false);
    try
      for LNetworkInterface in LInterfaceList do
      begin
        if LNetworkInterface.InterfaceIndex = AIndex then
          exit(TNetworkInterface.Create(LNetworkInterface));
      end;
    finally
      LInterfaceList.Free;
    end;

    raise NotFoundException.Create('Not Found ' + IntToStr(AIndex));
	end;

  raise NotFoundException.Create('Not Found ' + IntToStr(AIndex));
end;

class function TNetworkInterface.ForName(const AName: String; AIPVersion: TIPVersion): TNetworkInterface;
var
  LInterfaceList: TObjectList<TNetworkInterface>;
  LNetworkInterface: TNetworkInterface;
begin
  LInterfaceList := TNetworkInterface.list(false, false);
  try
    for LNetworkInterface in LInterfaceList do
    begin
      if LNetworkInterface.Name = AName then
      begin
        if (AIPVersion = TIPVersion.IPv4_ONLY) and (LNetworkInterface.SupportsIPv4) then
          exit(TNetworkInterface.Create(LNetworkInterface))
        else
        if (AIPVersion = TIPVersion.IPv6_ONLY) and (LNetworkInterface.SupportsIPv6) then
          exit(TNetworkInterface.Create(LNetworkInterface))
        else
        if AIPVersion = TIPVersion.IPv4_OR_IPv6 then
          exit(TNetworkInterface.Create(LNetworkInterface))
      end;
    end;
  finally
    LInterfaceList.Free;
  end;

  raise NotFoundException.Create('Not Found ' + AName);
end;

class function TNetworkInterface.ForName(const AName: String; requireIPv6: Boolean): TNetworkInterface;
begin
  if requireIPv6 then
		result := ForName(AName, TIPVersion.IPv6_ONLY)
	else
		result := ForName(AName, TIPVersion.IPv4_OR_IPv6);
end;

function TNetworkInterface.InterfaceType: TType;
begin
  result := FImpl.InterfaceType;
end;

function TNetworkInterface.InterfaceIndex: Cardinal;
begin
  result := FImpl.InterfaceIndex;
end;

function TNetworkInterface.IsLoopback: Boolean;
begin
  result := FImpl.Loopback;
end;

function TNetworkInterface.IsPointToPoint: Boolean;
begin
  result := FImpl.PointToPoint;
end;

function TNetworkInterface.IsRunning: Boolean;
begin
  result := FImpl.Running;
end;

function TNetworkInterface.IsUp: Boolean;
begin
  result := FImpl.Up;
end;

function TNetworkInterface.MACAddress: RawByteString;
begin
  result := FImpl.FMACAddress;
end;

class function TNetworkInterface.MACToString(const AMACData: RawByteString): String;
var
  i: Integer;
begin
  if Length(AMACData) > 0 then
  begin
    result := IntToHex(Integer(AMACData[1]), 2);
    i := 2;
    while i <= Length(AMACData) do
    begin
      result := result + MAC_SEPARATOR + IntToHex(Integer(AMACData[i]), 2);
      inc(i);
    end;
  end;
end;

function TNetworkInterface.MTU: Cardinal;
begin
  result := FImpl.MTU;
end;

function TNetworkInterface.Name: String;
begin
  result := FImpl.Name;
end;

function TNetworkInterface.SubnetMask(AIndex: Cardinal): TIPAddress;
begin
  result := FImpl.SubnetMask(AIndex);
end;

function TNetworkInterface.SupportsBroadcast: Boolean;
begin
  result := FImpl.Broadcast;
end;

function TNetworkInterface.SupportsIP: Boolean;
begin
  result := FImpl.SupportsIPv4 or FImpl.supportsIPv6;
end;

function TNetworkInterface.SupportsIPv4: Boolean;
begin
  result := FImpl.SupportsIPv4;
end;

function TNetworkInterface.SupportsIPv6: Boolean;
begin
  result := FImpl.SupportsIPv6;
end;

function TNetworkInterface.SupportsMulticast: Boolean;
begin
  result := FImpl.Multicast;
end;

class function TNetworkInterface.List(const AIPOnly, AUPOnly: Boolean): TObjectList<TNetworkInterface>;
const
  GAA_FLAG_INCLUDE_ALL_INTERFACES = $100;
	family = AF_UNSPEC; //IPv4 and IPv6
  flags = GAA_FLAG_SKIP_ANYCAST or GAA_FLAG_SKIP_MULTICAST or GAA_FLAG_SKIP_DNS_SERVER or GAA_FLAG_INCLUDE_PREFIX or GAA_FLAG_INCLUDE_ALL_INTERFACES;
var
  LPIPAddress, LPIPAdaptersAddresses: PIP_ADAPTER_ADDRESSES;
  LPIPUniAddr: PIP_ADAPTER_UNICAST_ADDRESS;
  LAdaptersAddressesSize: ULONG;
  LError: DWORD;
  LIsUp, LIsIP: Boolean;
  LNetworkInterface: TNetworkInterface;
  LIPAddress, LMask, LBroadcastAddress: TIPAddress;
  LHasBroadcast: Boolean;
  LPrefixLength: ULONG;
  LIndex: Cardinal;
begin
  LAdaptersAddressesSize := 0;

  result := TObjectList<TNetworkInterface>.Create;

  LError := GetAdaptersAddresses(AF_UNSPEC, flags, nil, nil, @LAdaptersAddressesSize);
  if LError <> ERROR_BUFFER_OVERFLOW then
    exit;

  LPIPAdaptersAddresses := PIP_ADAPTER_ADDRESSES(GlobalAlloc(GPTR, LAdaptersAddressesSize));
  GetAdaptersAddresses(AF_UNSPEC, flags, nil, LPIPAdaptersAddresses, @LAdaptersAddressesSize);

  LIndex := 0;
  LPIPAddress := LPIPAdaptersAddresses;
  while LPIPAddress <> nil do
  begin
		LIsUp := LPIPAddress.OperStatus = IfOperStatusUp;
		LIsIP := LPIPAddress.FirstUnicastAddress <> nil;
		if ((AIPOnly and LIsIP) or (not AIPOnly)) and ((AUPOnly and LIsUp) or (not AUPOnly)) then
    begin
      LNetworkInterface := TNetworkInterface.Create;
      result.Add(LNetworkInterface);
      LNetworkInterface.FImpl.InterfaceIndex := LIndex;
      inc(LIndex);

      LNetworkInterface.FImpl.Name := LPIPAddress.FriendlyName;
      LNetworkInterface.FImpl.DisplayName := LPIPAddress.Description;
      LNetworkInterface.FImpl.AdapterName := String(LPIPAddress.AdapterName);
      LNetworkInterface.FImpl.MTU := LPIPAddress.Mtu;
      LNetworkInterface.FImpl.SetFlags(LPIPAddress.Flags, LPIPAddress.IfType);
      LNetworkInterface.FImpl.Up := LPIPAddress.OperStatus = IfOperStatusUp;
      LNetworkInterface.FImpl.Running := (LPIPAddress.ReceiveLinkSpeed > 0) or (LPIPAddress.TransmitLinkSpeed > 0);
      LNetworkInterface.FImpl.InterfaceType := LNetworkInterface.FImpl.FromNative(LPIPAddress.IfType);
			if LPIPAddress.PhysicalAddressLength > 0 then
      begin
        SetLength(LNetworkInterface.FImpl.FMACaddress, LPIPAddress.PhysicalAddressLength);
        memcpy(@LNetworkInterface.FImpl.FMACaddress[1], @LPIPAddress.PhysicalAddress[0], LPIPAddress.PhysicalAddressLength);
      end;

      LPIPUniAddr := LPIPAddress.FirstUnicastAddress;
      while LPIPUniAddr <> nil do
      begin
				LIPAddress := TIPAddress.Create(@LPIPUniAddr.Address);

				case LPIPUniAddr.Address.lpSockaddr.sin_family of
          AF_INET:
            begin
              LHasBroadcast := LPIPAddress.IfType in [IF_TYPE_ETHERNET_CSMACD, IF_TYPE_SOFTWARE_LOOPBACK, IF_TYPE_IEEE80211];
              if LHasBroadcast then
              begin
                LMask := TIPAddress.Create(LPIPUniAddr.OnLinkPrefixLength, TAddressFamily.IPv4);
	  						LBroadcastAddress := LNetworkInterface.FImpl.getBroadcastAddress(LPIPAddress.FirstPrefix, LIPAddress, @LPrefixLength);
                LNetworkInterface.FImpl.AddressList.Add(TAddressTuple.Create(LIPAddress, LMask, LBroadcastAddress));
              end
              else
              begin
                LNetworkInterface.FImpl.AddressList.Add(TAddressTuple.Create(LIPAddress));
              end;
            end;
          AF_INET6:
            begin
              LNetworkInterface.FImpl.AddressList.Add(TAddressTuple.Create(LIPAddress));
            end;
        end;

        LPIPUniAddr := LPIPUniAddr.Next;
      end;
    end;

    LPIPAddress := LPIPAddress.Next;
  end;

  GlobalFree(HGLOBAL(LPIPAdaptersAddresses));
end;


end.



