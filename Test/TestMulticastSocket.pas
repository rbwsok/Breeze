unit TestMulticastSocket;

interface

uses System.SysUtils, TestUtil;

type
  TTestMulticastSocket = class
	  procedure testMulticast;
  public
    class procedure Test;
  end;

implementation

uses MulticastEchoServer, Breeze.Net.SocketDefs, Breeze.Net.MulticastSocket, Breeze.Net.SocketAddress;
{Breeze.Net.PollSet, Breeze.Net.StreamSocket, Breeze.Net.SocketAddress, Breeze.Net.Socket, TCPEchoServer, Breeze.Exception;

Winapi.Windows, Winapi.Winsock2, System.SysUtils, System.Diagnostics, System.Generics.Collections,
System.TimeSpan,
TestUtil;}


{ TTestPollSet }

class procedure TTestMulticastSocket.Test;
var
  testclass: TTestMulticastSocket;
begin
  TRTest.Comment('=============================================');
  TRTest.Comment('= TestMulticastSocket');
  TRTest.Comment('=============================================');

  testclass := TTestMulticastSocket.Create;
  try
    testclass.testMulticast;
  finally
    testclass.Free;
  end;
end;

procedure TTestMulticastSocket.testMulticast;
var
	echoServer:	TMulticastEchoServer;
  ms: TMulticastSocket;
  multicastAddress: TSocketAddress;
  n: Integer;
  buffer: array [0..255] of AnsiChar;
begin
	echoServer :=	nil;
  ms := nil;
  try
    echoServer :=	TMulticastEchoServer.Create;
    ms := TMulticastSocket.Create(TAddressFamily.IPv4);
    multicastAddress := TSocketAddress.Create('234.2.2.2', 4040);
    ms.joinGroup(multicastAddress.host);
    ms.setReceiveTimeout(5000);
    n := ms.sendTo(PAnsiChar('hello'), 5, echoServer.group);
    assertTrue('testMulticast 1', n = 5);
    n := ms.receiveBytes(@buffer[0], sizeof(buffer));
    assertTrue('testMulticast 2', n = 5);
    buffer[n] := #0;
    assertTrue('testMulticast 3', AnsiString(buffer) = 'hello');
    ms.leaveGroup(multicastAddress.host());
    ms.close();
  finally
  	echoServer.Free;
    ms.Free;
  end;
end;

end.
