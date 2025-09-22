unit Breeze.Net.RawSocketImpl;

interface

uses WInapi.Winsock2,
Breeze.Net.SocketImpl, Breeze.Net.SocketAddress, Breeze.Net.SocketDefs;

type
  TRawSocketImpl = class(Breeze.Net.SocketImpl.TSocketImpl)
	/// This class implements a raw socket.
  public
    constructor Create; overload;
    /// Creates an unconnected IPv4 raw socket with IPPROTO_RAW.

    constructor Create(AFamily: TAddressFamily; AProtocol: Integer = IPPROTO_RAW); overload;
    /// Creates an unconnected raw socket.
    ///
    /// The socket will be created for the
    /// given address family.

    constructor Create(ANaviveSocket: Winapi.Winsock2.TSocket); overload;
    /// Creates a RawSocketImpl using the given native socket.

    destructor Destroy; override;

  	procedure Init(ANativeFamily: Integer); overload; override;
  	procedure Init2(ANativeFamily: Integer; AProtocol: Integer); overload;
  end;

implementation

uses Breeze.Exception;

{ TRawSocketImpl }

constructor TRawSocketImpl.Create;
begin
  inherited;

  Init(AF_INET);
end;

constructor TRawSocketImpl.Create(AFamily: TAddressFamily; AProtocol: Integer);
begin
  inherited Create;

  case AFamily of
	  TAddressFamily.IPv4:
  		init2(AF_INET, AProtocol);
	  TAddressFamily.IPv6:
  		init2(AF_INET6, AProtocol);
    else
      raise InvalidArgumentException.Create('Invalid or unsupported address family passed to RawSocketImpl');
  end;
end;

constructor TRawSocketImpl.Create(ANaviveSocket: Winapi.Winsock2.TSocket);
begin
  inherited Create(ANaviveSocket);
end;

destructor TRawSocketImpl.Destroy;
begin

  inherited;
end;

procedure TRawSocketImpl.Init(ANativeFamily: Integer);
begin
  init2(ANativeFamily, IPPROTO_RAW);
end;

procedure TRawSocketImpl.Init2(ANativeFamily, AProtocol: Integer);
begin
	InitSocket(ANativeFamily, SOCK_RAW, AProtocol);
	SetOption(IPPROTO_IP, IP_HDRINCL, Integer(0));
end;

end.
