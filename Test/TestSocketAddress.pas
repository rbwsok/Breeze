unit TestSocketAddress;

interface

uses System.SysUtils, Winapi.Winsock2, TestUtil;

type

  TTestSocketAddress = class
  private
    procedure testSocketAddress;
    procedure testSocketRelationals;
    procedure testSocketAddress6;
  public
    class procedure Test;
  end;

implementation

uses Breeze.Net.IPAddress, Breeze.Net.SocketDefs, Breeze.Net.SocketAddress;

procedure TTestSocketAddress.testSocketAddress;
var
  wild, sa1, sa01, sa2, sa02, sa3, sa03, sa04: TSocketAddress;
  sa7, sa07, sa8, sa08: TSocketAddress;
begin
  wild.Create;

  assertTrue('testSocketAddress 1', wild.host.isWildcard);
  assertTrue('testSocketAddress 2', wild.port = 0);

	sa01 := TSocketAddress.Create('192.168.1.100', 100);
  sa1 := sa01;
  assertTrue('testSocketAddress 3', sa1.NativeFamily = AF_INET);
  assertTrue('testSocketAddress 4', sa1.family = TAddressFamily.IPv4);
  assertTrue('testSocketAddress 5', sa1.host.toString = '192.168.1.100');
  assertTrue('testSocketAddress 6', sa1.port = 100);
  assertTrue('testSocketAddress 7', sa1.toString = '192.168.1.100:100');
	sa02 := TSocketAddress.Create('192.168.1.100', 100);
  sa2 := sa02;
  assertTrue('testSocketAddress 8', sa2.host.toString = '192.168.1.100');
  assertTrue('testSocketAddress 9', sa2.port = 100);
	sa03 := TSocketAddress.Create('192.168.1.100', 'ftp');
  sa3 := sa03;
  assertTrue('testSocketAddress 10', sa3.host.toString = '192.168.1.100');
  assertTrue('testSocketAddress 11', sa3.port > 0);
  assertException('testSocketAddress 12',
    procedure
    begin
    	sa03 := TSocketAddress.Create('192.168.1.100', 'f00bar');
    end
  );
  assertException('testSocketAddress 15',
    procedure
    begin
      sa04 := TSocketAddress.Create('pocoproject.org', 80);
    end
  );
{	sa04 := TSocketAddress.Create('pocoproject.org', 80);
  sa4 := TSocketAddress.Create;
  sa4.Assign(sa04);
  assertTrue('testSocketAddress 13', sa4.host.toString, '54.93.62.90');
  assertTrue<Word>('testSocketAddress 14', sa4.port, 21);
  FreeAndNil(sa4);
  FreeAndNil(sa04);}
  assertException('testSocketAddress 15',
    procedure
    begin
    	sa03 := TSocketAddress.Create('192.168.2.260', 80);
    end
  );
	sa07 := TSocketAddress.Create('192.168.2.120:88');
  sa7 := sa07;
  assertTrue('testSocketAddress 16', sa7.host.toString = '192.168.2.120');
  assertTrue('testSocketAddress 17', sa7.port = 88);
	sa08 := TSocketAddress.Create('[192.168.2.120]:88');
  sa8 := sa08;
  assertTrue('testSocketAddress 18', sa8.host.toString = '192.168.2.120');
  assertTrue('testSocketAddress 19', sa8.port = 88);
  assertException('testSocketAddress 20',
    procedure
    begin
    	sa03 := TSocketAddress.Create('[192.168.2.260]');
    end
  );
  assertException('testSocketAddress 21',
    procedure
    begin
    	sa03 := TSocketAddress.Create('[192.168.2.260:88');
    end
  );
end;

procedure TTestSocketAddress.testSocketRelationals;
var
  sa1, sa2, sa3, sa4: TSocketAddress;
begin
	sa1 := TSocketAddress.Create('192.168.1.100', 100);
	sa2 := TSocketAddress.Create('192.168.1.100:100');
	assertTrue('testSocketRelationals 1', sa1.isEqual(sa2));

	sa3 := TSocketAddress.Create('192.168.1.101', 99);
	assertTrue('testSocketRelationals 1', sa2.isLess(sa3));

	sa4 := TSocketAddress.Create('192.168.1.101:102');
	assertTrue('testSocketRelationals 1', sa3.isLess(sa4));
end;

procedure TTestSocketAddress.testSocketAddress6;
var
  sa1, sa2: TSocketAddress;
begin
	sa1 := TSocketAddress.Create('FE80::E6CE:8FFF:FE4A:EDD0', 100);
	assertTrue('testSocketAddress6 1', sa1.NativeFamily = AF_INET6);
	assertTrue('testSocketAddress6 2', sa1.family = TAddressFamily.IPv6);
	assertTrue('testSocketAddress6 3', sa1.host.toString = 'fe80::e6ce:8fff:fe4a:edd0');
	assertTrue('testSocketAddress6 4', sa1.port = 100);
	assertTrue('testSocketAddress6 5', sa1.toString = '[fe80::e6ce:8fff:fe4a:edd0]:100');
	sa2 := TSocketAddress.Create('[FE80::E6CE:8FFF:FE4A:EDD0]:100');
  assertTrue('testSocketAddress6 6', sa2.NativeFamily = AF_INET6);
  assertTrue('testSocketAddress6 7', sa2.family = TAddressFamily.IPv6);
  assertTrue('testSocketAddress6 8', sa2.host.toString = 'fe80::e6ce:8fff:fe4a:edd0');
  assertTrue('testSocketAddress6 9', sa2.port = 100);
  assertTrue('testSocketAddress6 10', sa2.toString = '[fe80::e6ce:8fff:fe4a:edd0]:100');
end;

{ TTestSocketAddress }

class procedure TTestSocketAddress.Test;
var
  testclass: TTestSocketAddress;
begin
  TRTest.Comment('=============================================');
  TRTest.Comment('= TestSocketAddress');
  TRTest.Comment('=============================================');

  testclass := TTestSocketAddress.Create;
  try
    testclass.testSocketAddress;
    testclass.testSocketAddress6;
    testclass.testSocketRelationals;
  finally
    testclass.Free;
  end;
end;

end.
