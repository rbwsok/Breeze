unit TestStreamSocket;

interface

uses System.SysUtils, Winapi.Winsock2, TestUtil;

type

  TTestStreamSocket = class
  private
    procedure testStreamEcho;
  public
    class procedure Test;
  end;

implementation

uses Breeze.Net.IPAddress, Breeze.Net.SocketDefs, Breeze.Net.SocketAddress;

{ TTestStreamSocket }

class procedure TTestStreamSocket.Test;
var
  testclass: TTestStreamSocket;
begin
  testclass := TTestStreamSocket.Create;
  try
    testclass.testStreamEcho;
  finally
    testclass.Free;
  end;
end;

procedure TTestStreamSocket.testStreamEcho;
begin

end;

end.

