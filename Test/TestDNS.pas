unit TestDNS;

interface

uses Winapi.Windows, System.Generics.Collections, TestUtil;

type
  TTestDNS = class
	  procedure testHostByName;
	  procedure testHostByAddress;
	  procedure testResolve;
	  procedure testEncodeIDN;
	  procedure testDecodeIDN;
  public
    class procedure Test;
  end;

implementation

uses Breeze.Net.DNS, Breeze.Net.HostEntry, Breeze.Net.IPAddress;

{ TTestDatagramSocket }

class procedure TTestDNS.Test;
var
  testclass: TTestDNS;
begin
  TRTest.Comment('=============================================');
  TRTest.Comment('= TestDNS');
  TRTest.Comment('=============================================');

  testclass := TTestDNS.Create;
  try
    testclass.testHostByName;
    testclass.testHostByAddress;
    testclass.testResolve;
    testclass.testEncodeIDN;
    testclass.testDecodeIDN;
  finally
    testclass.Free;
  end;
end;

procedure TTestDNS.testDecodeIDN;
var
  enc, dn: AnsiString;
begin
	enc := 'xn--dmin-moa0i.example';
	assertTrue('testDecodeIDN 1', TDNS.isEncodedIDN(enc));
	assertTrue('testDecodeIDN 2', TDNS.decodeIDN(enc) = UTF8ToString('d'#$c3#$b6'm'#$c3#$a4'in.example'));

	enc := '.xn--dmin-moa0i.example';
	assertTrue('testDecodeIDN 3', TDNS.isEncodedIDN(enc));
  assertTrue('testDecodeIDN 4', TDNS.decodeIDN(enc) = UTF8ToString('.d'#$c3#$b6'm'#$c3#$a4'in.example'));

	enc := 'xn--dmin-moa0i.example.';
	assertTrue('testDecodeIDN 5', TDNS.isEncodedIDN(enc));
  assertTrue('testDecodeIDN 6', TDNS.decodeIDN(enc) = UTF8ToString('d'#$c3#$b6'm'#$c3#$a4'in.example.'));

	enc := 'xn--dmin-moa0i';
	assertTrue('testDecodeIDN 7', TDNS.isEncodedIDN(enc));
  assertTrue('testDecodeIDN 8', TDNS.decodeIDN(enc) = UTF8ToString('d'#$c3#$b6'm'#$c3#$a4'in'));

	enc := 'foo.xn--bcdf-9na9b.example';
	assertTrue('testDecodeIDN 9', TDNS.isEncodedIDN(enc));
  assertTrue('testDecodeIDN 10', TDNS.decodeIDN(enc) = UTF8ToString('foo.'#$c3#$a2'bcd'#$c3#$a9'f.example'));

	enc := 'xn--n3h.example';
	assertTrue('testDecodeIDN 11', TDNS.isEncodedIDN(enc));
  assertTrue('testDecodeIDN 12', TDNS.decodeIDN(enc) = UTF8ToString(#$e2#$98#$83'.example'));

	enc := 'xn--n3h.';
	assertTrue('testDecodeIDN 13', TDNS.isEncodedIDN(enc));
  assertTrue('testDecodeIDN 14', TDNS.decodeIDN(enc) = UTF8ToString(#$e2#$98#$83'.'));

	enc := 'xn--n3h';
	assertTrue('testDecodeIDN 15', TDNS.isEncodedIDN(enc));
  assertTrue('testDecodeIDN 16', TDNS.decodeIDN(enc) = UTF8ToString(#$e2#$98#$83));

	dn := 'www.pocoproject.org';
	assertTrue('testDecodeIDN 17', not TDNS.isEncodedIDN(dn));
  assertTrue('testDecodeIDN 18', TDNS.decodeIDN(dn) = 'www.pocoproject.org');
end;

procedure TTestDNS.testEncodeIDN;
var
  idn, dn: String;
begin
	idn := UTF8ToString('d'#$c3#$b6'm'#$c3#$a4'in.example');
	assertTrue('testEncodeIDN 1', TDNS.isIDN(idn));
	assertTrue('testEncodeIDN 2', TDNS.encodeIDN(idn) = 'xn--dmin-moa0i.example');

	idn := UTF8ToString('.d'#$c3#$b6'm'#$c3#$a4'in.example');
	assertTrue('testEncodeIDN 3', TDNS.isIDN(idn));
	assertTrue('testEncodeIDN 4', TDNS.encodeIDN(idn) = '.xn--dmin-moa0i.example');

	idn := UTF8ToString('d'#$c3#$b6'm'#$c3#$a4'in.example.');
	assertTrue('testEncodeIDN 5', TDNS.isIDN(idn));
	assertTrue('testEncodeIDN 6', TDNS.encodeIDN(idn) = 'xn--dmin-moa0i.example.');

	idn := UTF8ToString('d'#$c3#$b6'm'#$c3#$a4'in');
	assertTrue('testEncodeIDN 7', TDNS.isIDN(idn));
	assertTrue('testEncodeIDN 8', TDNS.encodeIDN(idn) = 'xn--dmin-moa0i');

	idn := UTF8ToString(#$c3#$a4'aaa.example');
	assertTrue('testEncodeIDN 9', TDNS.isIDN(idn));
	assertTrue('testEncodeIDN 10', TDNS.encodeIDN(idn) = 'xn--aaa-pla.example');

	idn := UTF8ToString('a'#$c3#$a4'aa.example');
	assertTrue('testEncodeIDN 11', TDNS.isIDN(idn));
	assertTrue('testEncodeIDN 12', TDNS.encodeIDN(idn) = 'xn--aaa-qla.example');

	idn := UTF8ToString('foo.'#$c3#$a2'bcd'#$c3#$a9'f.example');
	assertTrue('testEncodeIDN 13', TDNS.isIDN(idn));
	assertTrue('testEncodeIDN 14', TDNS.encodeIDN(idn) = 'foo.xn--bcdf-9na9b.example');

	idn := UTF8ToString(#$e2#$98#$83'.example');
	assertTrue('testEncodeIDN 15', TDNS.isIDN(idn));
	assertTrue('testEncodeIDN 16', TDNS.encodeIDN(idn) = 'xn--n3h.example');

	idn := UTF8ToString(#$e2#$98#$83'.');
	assertTrue('testEncodeIDN 17', TDNS.isIDN(idn));
	assertTrue('testEncodeIDN 18', TDNS.encodeIDN(idn) = 'xn--n3h.');

	idn := UTF8ToString(#$e2#$98#$83);
	assertTrue('testEncodeIDN 19', TDNS.isIDN(idn));
	assertTrue('testEncodeIDN 20', TDNS.encodeIDN(idn) = 'xn--n3h');

	dn := 'www.pocoproject.org';
	assertTrue('testEncodeIDN 21', not TDNS.isIDN(dn));
	assertTrue('testEncodeIDN 22', TDNS.encodeIDN(dn) = 'www.pocoproject.org');
end;

procedure TTestDNS.testHostByAddress;
var
  ip1, ip2: TIPAddress;
  he1, he2: THostEntry;
begin
	ip1 := TIPAddress.Create('80.122.195.86');
	he1 := TDNS.hostByAddress(ip1);
  try
    assertTrue('testHostByAddress 1', he1.name = 'mailhost.appinf.com');
    assertTrue('testHostByAddress 2', he1.aliases.IsEmpty);
    assertTrue('testHostByAddress 3', he1.addresses.Count >= 1);
    assertTrue('testHostByAddress 4', he1.addresses[0].toString = '80.122.195.86');

    ip2 := TIPAddress.Create('10.0.244.253');
    assertException('testHostByAddress 5',
      procedure
      begin
        he2 := TDNS.hostByAddress(ip2);
      end
    );
  finally
    he1.Free;
  end;
end;

procedure TTestDNS.testHostByName;
var
  he1, he2: THostEntry;
begin
	he1 := TDNS.hostByName('aliastest.pocoproject.org');
  try
    // different systems report different canonical names, unfortunately.
    assertTrue('testHostByName 1', (he1.name = 'dnstest.pocoproject.org') or (he1.name = 'aliastest.pocoproject.org'));
    assertTrue('testHostByName 2', he1.addresses.Count >= 1);
    assertTrue('testHostByName 3', he1.addresses[0].toString = '1.2.3.4');

    assertException('testHostByName 4',
      procedure
      begin
        he2 := TDNS.hostByName('nohost.pocoproject.org')
      end
    );
  finally
    he1.Free;
  end;
end;

procedure TTestDNS.testResolve;
{var
  he1: THostEntry;
  a: TList<TIPAddress>;
  b: TList<AnsiString>;}
begin
{	he1 := TDNS.hostByName('localhost');
  try
	  a := he1.addresses;
	  b := he1.aliases;
 	sort(a.begin(), a.end());
	auto itA = std::unique(a.begin(), a.end());
	assertTrue (itA == a.end());


	sort(b.begin(), b.end());
	auto itB = std::unique(b.begin(), b.end());
	assertTrue (itB == b.end());
  finally
    he1.Free;
  end;}
end;

end.
