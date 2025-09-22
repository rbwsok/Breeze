unit MulticastEchoServer;

interface

uses System.SysUtils, System.Classes, System.Generics.Collections,
  Breeze.Net.SocketAddress, Breeze.Net.IPAddress, Breeze.Net.MulticastSocket, Breeze.Net.SocketDefs, Breeze.Net.NetworkInterface, Breeze.Exception;

type

	/// A simple sequential Multicast echo server.
  TMulticastEchoServer = class(TThread)
  private
    FMulticastSocket: TMulticastSocket;
    FGroupAddress: TSocketAddress;
    FNetworkInterface: TNetworkInterface;

    function GetPort: Integer;

    class function FindInterface: TNetworkInterface;
  public
  	constructor Create; overload;
    destructor Destroy; override;

    procedure Execute; override;

	  property Group: TSocketAddress read FGroupAddress;

	  property NetworkInterface: TNetworkInterface read FNetworkInterface;

	  property Port: Integer read GetPort;
  end;

implementation

{ TMulticastEchoServer }

constructor TMulticastEchoServer.Create;
var
  LIPAddress: TIPAddress;
begin
  inherited Create(false);

	FGroupAddress := TSocketAddress.Create('239.255.1.2', 12345);
	FNetworkInterface := FindInterface;

  LIPAddress.Create;
  FMulticastSocket := TMulticastSocket.Create;
	FMulticastSocket.Bind(TSocketAddress.Create(LIPAddress, FGroupAddress.port), true);
	FMulticastSocket.JoinGroup(FGroupAddress.host, FNetworkInterface);
end;

destructor TMulticastEchoServer.Destroy;
begin
  FMulticastSocket.LeaveGroup(FGroupAddress.host, FNetworkInterface);
  FMulticastSocket.Free;
  FNetworkInterface.Free;
  inherited;
end;

procedure TMulticastEchoServer.Execute;
var
  LBuffer: array [0..255] of AnsiChar;
  LSenderSocketAddress: TSocketAddress;
  LReadedBytes: Integer;
begin
  inherited;

  while not Terminated do
  begin
		if FMulticastSocket.Poll(250, TPollMode.SELECT_READ) then
    begin
			try
				LReadedBytes := FMulticastSocket.ReceiveFrom(@LBuffer[0], sizeof(LBuffer), LSenderSocketAddress);
				FMulticastSocket.SendTo(@LBuffer[0], LReadedBytes, LSenderSocketAddress);
      except
        on E: System.SysUtils.Exception do
  				writeln('MulticastEchoServer: ' + E.Message);
      end;
    end;
  end;
end;

class function TMulticastEchoServer.FindInterface: TNetworkInterface;
var
  LInterfaceList: TObjectList<TNetworkInterface>;
begin
  LInterfaceList := TNetworkInterface.list;
  try
    for result in LInterfaceList do
    begin
      if result.supportsIPv4 and result.firstAddress(TAddressFamily.IPv4).isUnicast and
         (not result.isLoopback) and (not result.isPointToPoint) then
      begin
        LInterfaceList.Extract(result);
        exit;
      end;
    end;

    result := nil;
  finally
    LInterfaceList.Free;
  end;
end;

function TMulticastEchoServer.GetPort: Integer;
begin
  result := FMulticastSocket.address.port;
end;

end.
