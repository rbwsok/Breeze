unit TCPEchoServer;

interface

uses System.SysUtils, System.Classes, Breeze.Net.SocketAddress, Breeze.Net.StreamSocket, Breeze.Net.SocketDefs,
  Breeze.Net.ServerSocket;

type
  // A simple sequential TCP echo server.
  TTCPEchoServer = class(TThread)
  private
    FSocket: TServerSocket;

    function GetPort: Integer;
    function GetSocketAddress: TSocketAddress;
  public
    constructor Create; overload;
    constructor Create(ASocketAddress: TSocketAddress); overload;
    destructor Destroy; override;

    procedure Execute; override;

    property Port: Integer read GetPort;
    property Address: TSocketAddress read GetSocketAddress;
  end;

implementation

uses Breeze.Exception;

{ TTCPEchoServer }

constructor TTCPEchoServer.Create;
var
  LSocketAddress: TSocketAddress;
begin
  inherited Create(false);

  LSocketAddress.Create;
  FSocket := TServerSocket.Create(LSocketAddress);
end;

constructor TTCPEchoServer.Create(ASocketAddress: TSocketAddress);
begin
  inherited Create(false);

  FSocket := TServerSocket.Create(ASocketAddress);
end;

destructor TTCPEchoServer.Destroy;
begin
  Terminate;
  WaitFor;

  FSocket.Free;
  inherited;
end;

procedure TTCPEchoServer.Execute;
var
  LBuffer: array [0 .. 8192] of AnsiChar;
  LReadedBytes: Integer;
  LStreamSocket: TStreamSocket;
begin
  inherited;

  while not Terminated do
  begin
    if FSocket.Poll(250, TPollMode.SELECT_READ) then
    begin
      try
        LStreamSocket := FSocket.acceptConnection;
        try
          LReadedBytes := LStreamSocket.receiveBytes(@LBuffer[0], sizeof(LBuffer));

          while (LReadedBytes > 0) and (not Terminated) do
          begin
            LStreamSocket.sendBytes(@LBuffer[0], LReadedBytes);
            LReadedBytes := LStreamSocket.receiveBytes(@LBuffer[0], sizeof(LBuffer));
            if LReadedBytes = 0 then
            begin
              Terminate;
              break;
            end;
          end;
        finally
          LStreamSocket.Free;
        end;
      except
        on E: System.SysUtils.Exception do
          writeln('TCPEchoServer: ' + E.Message);
      end;
    end;
  end;
end;

function TTCPEchoServer.GetPort: Integer;
begin
  result := FSocket.Address.Port;
end;

function TTCPEchoServer.GetSocketAddress: TSocketAddress;
begin
  result := FSocket.Address;
end;

end.
