unit Breeze.Net.MulticastSocket;

interface

uses Winapi.Winsock2, System.Win.Crtl, System.Generics.Collections,
  Breeze.Net.DatagramSocket, Breeze.Net.SocketDefs, Breeze.Net.Socket, Breeze.Net.NetworkInterface, Breeze.Net.IPAddress, Breeze.Net.SocketAddress,
  Breeze.Net.SocketImpl,
  Breeze.Exception;

type

  TMulticastSocket = class(TDatagramSocket)
	/// A MulticastSocket is a special DatagramSocket
	/// that can be used to send packets to and receive
	/// packets from multicast groups.
  public
  	constructor Create; overload;
		/// Creates an unconnected, unbound multicast socket.
		///
		/// Before the multicast socket can be used, bind(),
		/// bind6() or connect() must be called.
		///
		/// Notice: The behavior of this constructor has changed
		/// in release 2.0. Previously, the constructor created
		/// an unbound IPv4 multicast socket.

  	constructor Create(AFamily: TAddressFamily); overload;
		/// Creates an unconnected datagram socket.
		///
		/// The socket will be created for the
		/// given address family.

  	constructor Create(const ASocketAddress: TSocketAddress; AReuseAddress: Boolean = false); overload;
		/// Creates a datagram socket and binds it
		/// to the given address.
		///
		/// Depending on the address family, the socket
		/// will be either an IPv4 or an IPv6 socket.

	  constructor Create(const ASocket: Breeze.Net.Socket.TSocket); overload;
    /// Creates the DatagramSocket with the SocketImpl
		/// from another socket. The SocketImpl must be
		/// a DatagramSocketImpl, otherwise an InvalidArgumentException
		/// will be thrown.

	  destructor Destroy; override;
		/// Destroys the DatagramSocket.

	  procedure Assign(const ASocket: Breeze.Net.Socket.TSocket); override;

	  procedure SetInterface(const ANetworkInterface: TNetworkInterface);
		/// Sets the interface used for sending multicast packets.
		///
		/// To select the default interface, specify an empty
		/// interface.
		///
		/// This is done by setting the IP_MULTICAST_IF/IPV6_MULTICAST_IF
		/// socket option.

	  function GetInterface: TNetworkInterface;
		/// Returns the interface used for sending multicast packets.

	  procedure SetLoopback(AFlag: Boolean);
		/// Enable or disable loopback for multicast packets.
		///
		/// Sets the value of the IP_MULTICAST_LOOP/IPV6_MULTICAST_LOOP
		/// socket option.

	  function GetLoopback: Boolean;
		/// Returns true iff loopback for multicast packets is enabled,
		/// false otherwise.

	  procedure SetTimeToLive(AValue: Cardinal);
		/// Specifies the TTL/hop limit for outgoing packets.
		///
		/// Sets the value of the IP_MULTICAST_TTL/IPV6_MULTICAST_HOPS
		/// socket option.

	  function GetTimeToLive: Cardinal;
		/// Returns the TTL/hop limit for outgoing packets.

	  procedure JoinGroup(const AGroupAddress: TIPAddress); overload;
		/// Joins the specified multicast group at the default interface.

	  procedure JoinGroup(const AGroupAddress: TIPAddress; const ANetworkInterface: TNetworkInterface); overload;
		/// Joins the specified multicast group at the given interface.

	  procedure leaveGroup(const AGroupAddress: TIPAddress); overload;
		/// Leaves the specified multicast group at the default interface.

	  procedure LeaveGroup(const AGroupAddress: TIPAddress; const ANetworkInterface: TNetworkInterface); overload;
		/// Leaves the specified multicast group at the given interface.

  private
  	class function FindFirstInterface(const AGroupAddress: TIPAddress): TNetworkInterface;
		/// Returns first multicast-eligible network interface.
  end;

Implementation

{ TMulticastSocket }

procedure TMulticastSocket.Assign(const ASocket: Breeze.Net.Socket.TSocket);
begin
  inherited;

end;

constructor TMulticastSocket.Create(AFamily: TAddressFamily);
begin
  inherited Create(AFamily);
end;

constructor TMulticastSocket.Create;
begin
  inherited;
end;

constructor TMulticastSocket.Create(const ASocket: Breeze.Net.Socket.TSocket);
begin
  inherited Create(ASocket);
end;

constructor TMulticastSocket.Create(const ASocketAddress: TSocketAddress; AReuseAddress: Boolean);
begin
  inherited Create(ASocketAddress, AReuseAddress);
end;

destructor TMulticastSocket.Destroy;
begin

  inherited;
end;

class function TMulticastSocket.FindFirstInterface(const AGroupAddress: TIPAddress): TNetworkInterface;
var
  LInterfaceList: TObjectList<TNetworkInterface>;
begin
  LInterfaceList := TNetworkInterface.list;
  try
    case AGroupAddress.family of
      TAddressFamily.IPv4:
      begin
        for result in LInterfaceList do
        begin
          if result.supportsIPv4 and result.firstAddress(TAddressFamily.IPv4).isUnicast and (not result.isLoopback) and (not result.isPointToPoint) then
          begin
            LInterfaceList.Extract(result);
            exit;
          end;
        end;
      end;
      TAddressFamily.IPv6:
      begin
        for result in LInterfaceList do
        begin
          if result.supportsIPv6 and result.firstAddress(TAddressFamily.IPv6).isUnicast and (not result.isLoopback) and (not result.isPointToPoint) then
          begin
            LInterfaceList.Extract(result);
            exit;
          end;
        end;
      end;
      else
        raise NotFoundException.Create('No multicast-eligible network interface found.');
    end;

    result := nil;
  finally
    LInterfaceList.Free;
  end;
end;

function TMulticastSocket.GetInterface: TNetworkInterface;
var
  LIPAddress: TIPAddress;
  LIndex: Cardinal;
begin
	try
		Impl.GetOption(IPPROTO_IP, IP_MULTICAST_IF, LIPAddress);
		exit(TNetworkInterface.forAddress(LIPAddress));
  except
		Impl.GetOption(IPPROTO_IPV6, IPV6_MULTICAST_IF, LIndex);
		exit(TNetworkInterface.forIndex(LIndex));
  end;
end;

function TMulticastSocket.GetLoopback: Boolean;
var
  LUFlag: Byte;
begin
	if address.NativeFamily = AF_INET then
		Impl.GetOption(IPPROTO_IP, IP_MULTICAST_LOOP, LUFlag)
	else
		Impl.GetOption(IPPROTO_IPV6, IPV6_MULTICAST_LOOP, LUFlag);

  result := LUFlag <> 0;
end;

function TMulticastSocket.GetTimeToLive: Cardinal;
var
  LTTL: Byte;
begin
	result := 0;
	if address.NativeFamily = AF_INET then
  begin
		Impl.GetOption(IPPROTO_IP, IP_MULTICAST_TTL, LTTL);
		result := LTTL;
  end
	else
		Impl.GetOption(IPPROTO_IPV6, IPV6_MULTICAST_HOPS, result);
end;

procedure TMulticastSocket.JoinGroup(const AGroupAddress: TIPAddress; const ANetworkInterface: TNetworkInterface);
var
  LIpMr: ip_mreq;
  LIpMrv6: ipv6_mreq;
  LIPAddress: TIPAddress;
begin
	if AGroupAddress.NativeFamily = AF_INET then
	begin
		memcpy(@LIpMr.imr_multiaddr, AGroupAddress.addr, AGroupAddress.length);
    LIPAddress := ANetworkInterface.firstAddress(TAddressFamily.IPv4);
		memcpy(@LIpMr.imr_interface, LIPAddress.addr, LIPAddress.length);
		Impl.setRawOption(IPPROTO_IP, IP_ADD_MEMBERSHIP, @LIpMr, sizeof(LIpMr));
	end
	else
  begin
	  memcpy(@LIpMrv6.ipv6mr_multiaddr, AGroupAddress.addr, AGroupAddress.length);
		LIpMrv6.ipv6mr_interface := ANetworkInterface.InterfaceIndex;
		Impl.setRawOption(IPPROTO_IPV6, IPV6_ADD_MEMBERSHIP, @LIpMrv6, sizeof(LIpMrv6));
  end;
end;

procedure TMulticastSocket.JoinGroup(const AGroupAddress: TIPAddress);
var
  LNetworkInterface: TNetworkInterface;
begin
  LNetworkInterface := findFirstInterface(AGroupAddress);
  try
    JoinGroup(AGroupAddress, LNetworkInterface);
  finally
    LNetworkInterface.Free;
  end;
end;

procedure TMulticastSocket.LeaveGroup(const AGroupAddress: TIPAddress; const ANetworkInterface: TNetworkInterface);
var
  LIpMr: ip_mreq;
  LIpMrv6: ipv6_mreq;
  LIPAddress: TIPAddress;
begin
	if AGroupAddress.NativeFamily = AF_INET then
	begin
		memcpy(@LIpMr.imr_multiaddr, AGroupAddress.addr, AGroupAddress.length);
    LIPAddress := ANetworkInterface.FirstAddress(TAddressFamily.IPv4);
		memcpy(@LIpMr.imr_interface, LIPAddress.addr, LIPAddress.length);
		Impl.SetRawOption(IPPROTO_IP, IP_DROP_MEMBERSHIP, @LIpMr, sizeof(LIpMr));
	end
	else
  begin
	  memcpy(@LIpMrv6.ipv6mr_multiaddr, AGroupAddress.addr, AGroupAddress.length);
		LIpMrv6.ipv6mr_interface := ANetworkInterface.InterfaceIndex;
		Impl.SetRawOption(IPPROTO_IPV6, IPV6_DROP_MEMBERSHIP, @LIpMrv6, sizeof(LIpMrv6));
  end;
end;

procedure TMulticastSocket.LeaveGroup(const AGroupAddress: TIPAddress);
var
  LNetworkInterface: TNetworkInterface;
begin
  LNetworkInterface := findFirstInterface(AGroupAddress);
  try
    LeaveGroup(AGroupAddress, LNetworkInterface);
  finally
    LNetworkInterface.Free;
  end;
end;

procedure TMulticastSocket.SetInterface(const ANetworkInterface: TNetworkInterface);
begin
  case address.family of
    TAddressFamily.IPv4:
  		Impl.SetOption(IPPROTO_IP, IP_MULTICAST_IF, ANetworkInterface.FirstAddress(TAddressFamily.IPv4));
    TAddressFamily.IPv6:
  		Impl.SetOption(IPPROTO_IPV6, IPV6_MULTICAST_IF, ANetworkInterface.InterfaceIndex);
    else
	    raise UnsupportedFamilyException.Create('Unknown or unsupported socket family.');
  end;
end;

procedure TMulticastSocket.SetLoopback(AFlag: Boolean);
var
  LUFlag: Byte;
begin
	if not AFlag then
    LUFlag := 0
  else
    LUFlag := 1;

	if address.NativeFamily = AF_INET then
		Impl.SetOption(IPPROTO_IP, IP_MULTICAST_LOOP, LUFlag)
	else
		Impl.SetOption(IPPROTO_IPV6, IPV6_MULTICAST_LOOP, LUFlag);
end;

procedure TMulticastSocket.SetTimeToLive(AValue: Cardinal);
var
  LTTL: Byte;
begin
	if address.NativeFamily = AF_INET then
	begin
		LTTL := AValue;
		Impl.SetOption(IPPROTO_IP, IP_MULTICAST_TTL, LTTL);
  end
	else
		Impl.SetOption(IPPROTO_IPV6, IPV6_MULTICAST_HOPS, AValue);
end;

end.
