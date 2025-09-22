unit TestIPAddressImpl;

interface

uses System.SysUtils, TestUtil;

type

  TTestIPAddressImpl = class
  private
    procedure TestIPv4AddressImpl;
    procedure TestIPv6AddressImpl;
  public
    class procedure Test;
  end;

implementation

uses Breeze.Net.IPAddressImpl, Breeze.Net.SocketDefs;

{ TNetTest }

procedure TTestIPAddressImpl.TestIPv4AddressImpl;
var
  ip, ip2: TIPv4AddressImpl;
begin
{  assertTrue<Cardinal>('swap32 1', TIPv4AddressImpl.swap32($01020304), $04030201);
  assertTrue<Cardinal>('swap32 2', TIPv4AddressImpl.swap32($ffaaffaa), $aaffaaff);
  assertTrue<Cardinal>('swap32 3', TIPv4AddressImpl.swap32($aaffaaff), $ffaaffaa);

  assertTrue<Cardinal>('swap16 1', TIPv4AddressImpl.swap16($0102), $0201);
  assertTrue<Cardinal>('swap16 2', TIPv4AddressImpl.swap16($ffaa), $aaff);
  assertTrue<Cardinal>('swap16 3', TIPv4AddressImpl.swap16($aaff), $ffaa);}

  ip.Create;
  assertTrue('v4 toString 1', ip.ToString = '0.0.0.0');

  ip := TIPv4AddressImpl.Create(24);
  assertTrue('v4 prefix 1', ip.ToString = '255.255.255.0');
  ip := TIPv4AddressImpl.Create(16);
  assertTrue('v4 prefix 2', ip.ToString = '255.255.0.0');
  ip := TIPv4AddressImpl.Create(8);
  assertTrue('v4 prefix 3', ip.ToString = '255.0.0.0');
  ip := TIPv4AddressImpl.Create(0);
  assertTrue('v4 prefix 4', ip.ToString = '0.0.0.0');
  ip := TIPv4AddressImpl.Create(32);
  assertTrue('v4 prefix 5', ip.ToString = '255.255.255.255');

  ip := TIPv4AddressImpl.Create(24);
  ip2 := TIPv4AddressImpl.Create(ip);
  assertTrue('v4 copy', ip2.ToString = '255.255.255.0');

  ip := TIPv4AddressImpl.Create(24);
  assertTrue('v4 length', ip.length = 4);
end;

procedure TTestIPAddressImpl.TestIPv6AddressImpl;
var
  ip: TIPv6AddressImpl;
begin
  ip.Create;
  assertTrue('v6 toString 1', ip.ToString = '::');
end;

class procedure TTestIPAddressImpl.Test;
var
  testclass: TTestIPAddressImpl;
begin
  testclass := TTestIPAddressImpl.Create;
  try
    testclass.TestIPv4AddressImpl;
    testclass.TestIPv6AddressImpl;
  finally
    testclass.Free;
  end;
end;

end.
