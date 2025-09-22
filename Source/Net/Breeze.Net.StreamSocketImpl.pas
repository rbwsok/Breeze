unit Breeze.Net.StreamSocketImpl;

interface

uses
  Winapi.Windows, Winapi.Winsock2,
  Breeze.Net.SocketImpl, Breeze.Net.SocketDefs, Breeze.Exception;

type

  TStreamSocketImpl = class(TSocketImpl)
	/// This class implements a TCP socket.
    public
	    constructor Create; overload;
		/// Creates a StreamSocketImpl.
      constructor Create(AFamily: TAddressFamily); overload;
		/// Creates a SocketImpl, with the underlying
		/// socket initialized for the given address family.
      constructor Create(ANativeSocket: Winapi.Winsock2.TSocket); overload;
		/// Creates a StreamSocketImpl using the given native socket.
      destructor Destroy; override;
      function SendBytes(ABuffer: Pointer; ALength: Integer; AFlags: Integer = 0): Integer; override;
		/// Ensures that all data in buffer is sent if the socket
		/// is blocking. In case of a non-blocking socket, sends as
		/// many bytes as possible.
		///
		/// Returns the number of bytes sent. The return value may also be
		/// negative to denote some special condition.
  end;
implementation

{ StreamSocketImpl }

constructor TStreamSocketImpl.Create;
begin
  inherited;
end;

constructor TStreamSocketImpl.Create(AFamily: TAddressFamily);
begin
  inherited Create;

  case AFamily of
    TAddressFamily.IPv4:
      init(AF_INET);
    TAddressFamily.IPv6:
      init(AF_INET6);
    else
    	raise InvalidArgumentException.Create('Invalid or unsupported address family passed to StreamSocketImpl');
  end;
end;

constructor TStreamSocketImpl.Create(ANativeSocket: Winapi.Winsock2.TSocket);
begin
  inherited Create(ANativeSocket);
end;

destructor TStreamSocketImpl.Destroy;
begin

  inherited;
end;

function TStreamSocketImpl.sendBytes(ABuffer: Pointer; ALength, AFlags: Integer): Integer;
var
  LPtr: PByte;
	LRemainingBytes: Integer;
	LTotalSentBytes: Integer;
	LBlocking: Boolean;
  LSentBytes: Integer;
begin
  LPtr := ABuffer;

	LRemainingBytes := ALength;
	LTotalSentBytes := 0;
	LBlocking := GetBlocking;
	while LRemainingBytes > 0 do
	begin
		LSentBytes := inherited sendBytes(LPtr, LRemainingBytes, AFlags);
		LPtr := LPtr + LSentBytes;
		LTotalSentBytes := LTotalSentBytes + LSentBytes;
		LRemainingBytes := LRemainingBytes - LSentBytes;
		if LBlocking and (LRemainingBytes > 0) then
			Sleep(0)
		else
			break;
  end;
	result := LTotalSentBytes;
end;

end.
