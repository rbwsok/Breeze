program Breeze;

{$APPTYPE CONSOLE}

{$R *.res}

uses
{$IFDEF DEBUG}
  Fastmm4,
{$ENDIF}
  System.SysUtils,
  TestIPAddressImpl in 'Test\TestIPAddressImpl.pas',
  TestIPAddress in 'Test\TestIPAddress.pas',
  TestNetworkInterface in 'Test\TestNetworkInterface.pas',
  TestSocketAddress in 'Test\TestSocketAddress.pas',
  TestUtil in 'Test\TestUtil.pas',
  TestSocket in 'Test\TestSocket.pas',
  UDPEchoServer in 'Test\UDPEchoServer.pas',
  TestAtomic in 'Test\TestAtomic.pas',
  TestDatagramSocket in 'Test\TestDatagramSocket.pas',
  TCPEchoServer in 'Test\TCPEchoServer.pas',
  TestStreamSocket in 'Test\TestStreamSocket.pas',
  TestPollSet in 'Test\TestPollSet.pas',
  TestMulticastSocket in 'Test\TestMulticastSocket.pas',
  MulticastEchoServer in 'Test\MulticastEchoServer.pas',
  TestBuffer in 'Test\TestBuffer.pas',
  TestDNS in 'Test\TestDNS.pas',
  Breeze.Atomic in 'Source\Core\Breeze.Atomic.pas',
  Breeze.Buffer in 'Source\Core\Breeze.Buffer.pas',
  Breeze.Exception in 'Source\Core\Breeze.Exception.pas',
  Breeze.Net.DatagramSocket in 'Source\Net\Breeze.Net.DatagramSocket.pas',
  Breeze.Net.DatagramSocketImpl in 'Source\Net\Breeze.Net.DatagramSocketImpl.pas',
  Breeze.Net.DNS in 'Source\Net\Breeze.Net.DNS.pas',
  Breeze.Net.HostEntry in 'Source\Net\Breeze.Net.HostEntry.pas',
  Breeze.Net.IPAddress in 'Source\Net\Breeze.Net.IPAddress.pas',
  Breeze.Net.IPAddressImpl in 'Source\Net\Breeze.Net.IPAddressImpl.pas',
  Breeze.Net.MulticastSocket in 'Source\Net\Breeze.Net.MulticastSocket.pas',
  Breeze.Net.NetworkInterface in 'Source\Net\Breeze.Net.NetworkInterface.pas',
  Breeze.Net.PollSet in 'Source\Net\Breeze.Net.PollSet.pas',
  Breeze.Net.PollSetImpl in 'Source\Net\Breeze.Net.PollSetImpl.pas',
  Breeze.Net.ServerSocket in 'Source\Net\Breeze.Net.ServerSocket.pas',
  Breeze.Net.ServerSocketImpl in 'Source\Net\Breeze.Net.ServerSocketImpl.pas',
  Breeze.Net.Socket in 'Source\Net\Breeze.Net.Socket.pas',
  Breeze.Net.SocketAddress in 'Source\Net\Breeze.Net.SocketAddress.pas',
  Breeze.Net.SocketAddressImpl in 'Source\Net\Breeze.Net.SocketAddressImpl.pas',
  Breeze.Net.SocketDefs in 'Source\Net\Breeze.Net.SocketDefs.pas',
  Breeze.Net.SocketImpl in 'Source\Net\Breeze.Net.SocketImpl.pas',
  Breeze.Net.StreamSocket in 'Source\Net\Breeze.Net.StreamSocket.pas',
  Breeze.Net.StreamSocketImpl in 'Source\Net\Breeze.Net.StreamSocketImpl.pas',
  PunnyCode in 'Source\ThridParty\PunnyCode\PunnyCode.pas',
  wepoll in 'Source\ThridParty\wepoll\wepoll.pas',
  wepoll_afd in 'Source\ThridParty\wepoll\wepoll_afd.pas',
  wepoll_err in 'Source\ThridParty\wepoll\wepoll_err.pas',
  wepoll_once in 'Source\ThridParty\wepoll\wepoll_once.pas',
  wepoll_poll_group in 'Source\ThridParty\wepoll\wepoll_poll_group.pas',
  wepoll_port in 'Source\ThridParty\wepoll\wepoll_port.pas',
  wepoll_queue in 'Source\ThridParty\wepoll\wepoll_queue.pas',
  wepoll_reflock in 'Source\ThridParty\wepoll\wepoll_reflock.pas',
  wepoll_sock in 'Source\ThridParty\wepoll\wepoll_sock.pas',
  wepoll_tree in 'Source\ThridParty\wepoll\wepoll_tree.pas',
  wepoll_ts_tree in 'Source\ThridParty\wepoll\wepoll_ts_tree.pas',
  wepoll_types in 'Source\ThridParty\wepoll\wepoll_types.pas',
  wepoll_ws in 'Source\ThridParty\wepoll\wepoll_ws.pas',
  Breeze.Net.SocketReactor in 'Source\Net\Breeze.Net.SocketReactor.pas',
  TestSocketReactor in 'Test\TestSocketReactor.pas',
  Breeze.Net.SocketConnectorAcceptor in 'Source\Net\Breeze.Net.SocketConnectorAcceptor.pas',
  TestSocketProactor in 'Test\TestSocketProactor.pas',
  Breeze.Net.DialogSocket in 'Source\Net\Breeze.Net.DialogSocket.pas',
  TestRawSocket in 'Test\TestRawSocket.pas',
  DialogServer in 'Test\DialogServer.pas',
  Breeze.StringTokenizer in 'Source\Core\Breeze.StringTokenizer.pas',
  TestTokenizer in 'Test\TestTokenizer.pas',
  Breeze.ByteOrder in 'Source\Core\Breeze.ByteOrder.pas',
  TestByteOrder in 'Test\TestByteOrder.pas',
  Breeze.Net.RawSocket in 'Source\Net\Breeze.Net.RawSocket.pas',
  Breeze.Net.RawSocketImpl in 'Source\Net\Breeze.Net.RawSocketImpl.pas';

begin
{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
{$ENDIF}

  try
    TRTest.Init;

    TTestIPAddress.Test;
    TTestIPAddressImpl.Test;
    TTestNetworkInterface.Test;
    TTestSocketAddress.Test;
    TTestAtomic.Test;
    TTestDatagramSocket.Test;
    TTestSocket.Test;
    TTestStreamSocket.Test;
    TTestPollSet.Test;
    TTestMulticastSocket.Test;
    TTestBuffer.Test;
    TTestDNS.Test;
    TTestSocketReactor.Test;
    TTestTokenizer.Test;
    TTestByteOrder.Test;

    TRTest.ResultTest;
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
  ReadLn;
end.
