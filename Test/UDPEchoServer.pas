unit UDPEchoServer;

interface

uses System.SysUtils, System.Classes, Breeze.Net.SocketAddress, Breeze.Net.DatagramSocket, Breeze.Net.SocketDefs, Breeze.Atomic, Breeze.Exception;

type
	// A simple sequential UDP echo server.
  TUDPEchoServer = class(TThread)
  private
    FSocket: TDatagramSocket;

    function GetPort: Integer;
    function GetSocketAddress: TSocketAddress;
  public
  	constructor Create; overload;
  	constructor Create(sa: TSocketAddress); overload;
    destructor Destroy; override;

    procedure Execute; override;

	  property port: Integer read GetPort;
	  property address: TSocketAddress read GetSocketAddress;
  end;

implementation

{ TUDPEchoServer }

constructor TUDPEchoServer.Create;
var
  LSocketAddress: TSocketAddress;
begin
  inherited Create(false);

  FSocket := TDatagramSocket.Create;
  LSocketAddress.Create;
 	FSocket.bind(LSocketAddress, true);
end;

constructor TUDPEchoServer.Create(sa: TSocketAddress);
begin
  inherited Create(false);

  FSocket := TDatagramSocket.Create;
	FSocket.bind(sa, true);
end;

destructor TUDPEchoServer.Destroy;
begin
  Terminate;
  WaitFor;

  FSocket.Free;
  inherited;
end;

procedure TUDPEchoServer.Execute;
var
  LBuffer: array [0..255] of AnsiChar;
  LSenderSocketAddress: TSocketAddress;
  LReadedBytes: Integer;
begin
  inherited;

  while not Terminated do
  begin
		if FSocket.poll(250, TPollMode.SELECT_READ) then
    begin
			try
				LReadedBytes := FSocket.receiveFrom(@LBuffer[0], sizeof(LBuffer), LSenderSocketAddress);
				FSocket.sendTo(@LBuffer[0], LReadedBytes, LSenderSocketAddress);
      except
        on E: System.SysUtils.Exception do
  				writeln('UDPEchoServer: ' + E.Message);
      end;
    end;
  end;
end;

function TUDPEchoServer.GetPort: Integer;
begin
  result := FSocket.address.port;
end;

function TUDPEchoServer.GetSocketAddress: TSocketAddress;
begin
  result := FSocket.address;
end;

end.
