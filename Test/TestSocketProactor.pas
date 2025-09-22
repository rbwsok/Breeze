unit TestSocketProactor;

interface

uses System.SysUtils, Winapi.Winsock2, TestUtil;

type

  TTestSocketProactor = class
  private
    procedure testSocketProactor;
  public
    class procedure Test;
  end;

implementation

uses Breeze.Net.IPAddress, Breeze.Net.SocketDefs, Breeze.Net.SocketAddress, Breeze.Net.ServerSocket, Breeze.Net.StreamSocket, Breeze.Net.SocketReactor,
Breeze.Net.SocketConnectorAcceptor, Breeze.Net.Socket, TCPEchoServer;

class procedure TTestSocketProactor.Test;
var
  testclass: TTestSocketProactor;
begin
  TRTest.Comment('=============================================');
  TRTest.Comment('= TestSocketProactor');
  TRTest.Comment('=============================================');

  testclass := TTestSocketProactor.Create;
  try
    testclass.testSocketProactor;
  finally
    testclass.Free;
  end;
end;

procedure TTestSocketProactor.testSocketProactor;
begin

end;

end.
