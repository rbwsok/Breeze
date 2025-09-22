unit Breeze.Net.DatagramSocketImpl;

interface

uses Winapi.Winsock2, Breeze.Net.SocketDefs, Breeze.Net.SocketImpl, Breeze.Exception;

type

  TDatagramSocketImpl = class(TSocketImpl)
	/// This class implements an UDP socket.
  public
	  constructor Create; overload;
		/// Creates an unconnected, unbound datagram socket.
	  constructor Create(AFamily: TAddressFamily); overload;
		/// Creates an unconnected datagram socket.
		///
		/// The socket will be created for the
		/// given address family.
	  constructor Create(ANativeSocket: Winapi.Winsock2.TSocket); overload;
		/// Creates a StreamSocketImpl using the given native socket.
	  destructor Destroy; override;
    procedure Init(ANativeFamily: Integer); override;
  end;

implementation

constructor TDatagramSocketImpl.Create;
begin
  inherited;
end;

constructor TDatagramSocketImpl.Create(AFamily: TAddressFamily);
begin
  inherited Create;

	case AFamily of
    TAddressFamily.IPv4:
  		Init(AF_INET);
    TAddressFamily.IPv6:
  		Init(AF_INET6);
  	else
      raise InvalidArgumentException.Create('Invalid or unsupported address family passed to DatagramSocketImpl');
  end;
end;

constructor TDatagramSocketImpl.Create(ANativeSocket: Winapi.Winsock2.TSocket);
begin
  inherited Create(ANativeSocket);
end;

destructor TDatagramSocketImpl.Destroy;
begin
  inherited;
end;

procedure TDatagramSocketImpl.init(ANativeFamily: Integer);
begin
	InitSocket(ANativeFamily, SOCK_DGRAM);
end;

end.
