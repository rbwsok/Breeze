unit TestIPAddress;

interface

uses System.SysUtils, TestUtil;

type

  TTestIPAddress = class
  private
    procedure testStringConv;
    procedure testStringConv6;
    procedure testParse;
    procedure testClassification;
    procedure testMCClassification;
    procedure testClassification6;
    procedure testMCClassification6;
    procedure testRelationals;
    procedure testRelationals6;
    procedure testWildcard;
    procedure testBroadcast;
    procedure testPrefixCons;
    procedure testPrefixLen;
    procedure testOperators;
    procedure testByteOrderMacros;
    procedure testScoped;
  public
    class procedure Test;
  end;

implementation

uses Breeze.Net.IPAddress, Breeze.Net.SocketDefs;

{ TTestIPAddress }

procedure TTestIPAddress.testBroadcast;
var
  broadcast: TIPAddress;
begin
	broadcast := TIPAddress.broadcast;
  assertTrue('testBroadcast 1', broadcast.isBroadcast);
  assertTrue('testBroadcast 2', broadcast.ToString = '255.255.255.255');
end;

procedure TTestIPAddress.testByteOrderMacros;
begin
{	Poco::UInt16 a16 = 0xDEAD;
	assertTrue (poco_ntoh_16(a16) == ntohs(a16));
	assertTrue (poco_hton_16(a16) == htons(a16));
	Poco::UInt32 a32 = 0xDEADBEEF;
	assertTrue (poco_ntoh_32(a32) == ntohl(a32));
	assertTrue (poco_hton_32(a32) == htonl(a32));
}
end;

procedure TTestIPAddress.testClassification;
var
  ip1, ip2, ip3, ip4, ip5, ip6, ip7, ip8: TIPAddress;
begin
	ip1 := TIPAddress.Create('0.0.0.0'); // wildcard
  assertTrue('testClassification 1', ip1.isWildcard);
  assertTrue('testClassification 2', not ip1.isBroadcast);
  assertTrue('testClassification 3', not ip1.isLoopback);
  assertTrue('testClassification 4', not ip1.isMulticast);
  assertTrue('testClassification 5', not ip1.isUnicast);
  assertTrue('testClassification 6', not ip1.isLinkLocal);
  assertTrue('testClassification 7', not ip1.isSiteLocal);
  assertTrue('testClassification 8', not ip1.isWellKnownMC);
  assertTrue('testClassification 9', not ip1.isNodeLocalMC);
  assertTrue('testClassification 10', not ip1.isLinkLocalMC);
  assertTrue('testClassification 11', not ip1.isSiteLocalMC);
  assertTrue('testClassification 12', not ip1.isOrgLocalMC);
  assertTrue('testClassification 13', not ip1.isGlobalMC);

	ip2 := TIPAddress.Create('255.255.255.255'); // broadcast
  assertTrue('testClassification 14', not ip2.isWildcard);
  assertTrue('testClassification 15', ip2.isBroadcast);
  assertTrue('testClassification 16', not ip2.isLoopback);
  assertTrue('testClassification 17', not ip2.isMulticast);
  assertTrue('testClassification 18', not ip2.isUnicast);
  assertTrue('testClassification 19', not ip2.isLinkLocal);
  assertTrue('testClassification 20', not ip2.isSiteLocal);
  assertTrue('testClassification 21', not ip2.isWellKnownMC);
  assertTrue('testClassification 22', not ip2.isNodeLocalMC);
  assertTrue('testClassification 23', not ip2.isLinkLocalMC);
  assertTrue('testClassification 24', not ip2.isSiteLocalMC);
  assertTrue('testClassification 25', not ip2.isOrgLocalMC);
  assertTrue('testClassification 26', not ip2.isGlobalMC);

	ip3 := TIPAddress.Create('127.0.0.1'); // loopback
  assertTrue('testClassification 27', not ip3.isWildcard);
  assertTrue('testClassification 28', not ip3.isBroadcast);
  assertTrue('testClassification 29', ip3.isLoopback);
  assertTrue('testClassification 30', not ip3.isMulticast);
  assertTrue('testClassification 31', ip3.isUnicast);
  assertTrue('testClassification 32', not ip3.isLinkLocal);
  assertTrue('testClassification 33', not ip3.isSiteLocal);
  assertTrue('testClassification 34', not ip3.isWellKnownMC);
  assertTrue('testClassification 35', not ip3.isNodeLocalMC);
  assertTrue('testClassification 36', not ip3.isLinkLocalMC);
  assertTrue('testClassification 37', not ip3.isSiteLocalMC);
  assertTrue('testClassification 38', not ip3.isOrgLocalMC);
  assertTrue('testClassification 39', not ip3.isGlobalMC);

	ip4 := TIPAddress.Create('80.122.195.86'); // unicast
  assertTrue('testClassification 40', not ip4.isWildcard);
  assertTrue('testClassification 41', not ip4.isBroadcast);
  assertTrue('testClassification 42', not ip4.isLoopback);
  assertTrue('testClassification 43', not ip4.isMulticast);
  assertTrue('testClassification 44', ip4.isUnicast);
  assertTrue('testClassification 45', not ip4.isLinkLocal);
  assertTrue('testClassification 46', not ip4.isSiteLocal);
  assertTrue('testClassification 47', not ip4.isWellKnownMC);
  assertTrue('testClassification 48', not ip4.isNodeLocalMC);
  assertTrue('testClassification 49', not ip4.isLinkLocalMC);
  assertTrue('testClassification 50', not ip4.isSiteLocalMC);
  assertTrue('testClassification 51', not ip4.isOrgLocalMC);
  assertTrue('testClassification 52', not ip4.isGlobalMC);

	ip5 := TIPAddress.Create('169.254.1.20'); // link local unicast
  assertTrue('testClassification 53', not ip5.isWildcard);
  assertTrue('testClassification 54', not ip5.isBroadcast);
  assertTrue('testClassification 55', not ip5.isLoopback);
  assertTrue('testClassification 56', not ip5.isMulticast);
  assertTrue('testClassification 57', ip5.isUnicast);
  assertTrue('testClassification 58', ip5.isLinkLocal);
  assertTrue('testClassification 59', not ip5.isSiteLocal);
  assertTrue('testClassification 60', not ip5.isWellKnownMC);
  assertTrue('testClassification 61', not ip5.isNodeLocalMC);
  assertTrue('testClassification 62', not ip5.isLinkLocalMC);
  assertTrue('testClassification 63', not ip5.isSiteLocalMC);
  assertTrue('testClassification 64', not ip5.isOrgLocalMC);
  assertTrue('testClassification 65', not ip5.isGlobalMC);

	ip6 := TIPAddress.Create('192.168.1.120'); // site local unicast
  assertTrue('testClassification 66', not ip6.isWildcard);
  assertTrue('testClassification 67', not ip6.isBroadcast);
  assertTrue('testClassification 68', not ip6.isLoopback);
  assertTrue('testClassification 69', not ip6.isMulticast);
  assertTrue('testClassification 70', ip6.isUnicast);
  assertTrue('testClassification 71', not ip6.isLinkLocal);
  assertTrue('testClassification 72', ip6.isSiteLocal);
  assertTrue('testClassification 73', not ip6.isWellKnownMC);
  assertTrue('testClassification 74', not ip6.isNodeLocalMC);
  assertTrue('testClassification 75', not ip6.isLinkLocalMC);
  assertTrue('testClassification 76', not ip6.isSiteLocalMC);
  assertTrue('testClassification 77', not ip6.isOrgLocalMC);
  assertTrue('testClassification 78', not ip6.isGlobalMC);

	ip7 := TIPAddress.Create('10.0.0.138'); // site local unicast
  assertTrue('testClassification 79', not ip7.isWildcard);
  assertTrue('testClassification 80', not ip7.isBroadcast);
  assertTrue('testClassification 81', not ip7.isLoopback);
  assertTrue('testClassification 82', not ip7.isMulticast);
  assertTrue('testClassification 83', ip7.isUnicast);
  assertTrue('testClassification 84', not ip7.isLinkLocal);
  assertTrue('testClassification 85', ip7.isSiteLocal);
  assertTrue('testClassification 86', not ip7.isWellKnownMC);
  assertTrue('testClassification 87', not ip7.isNodeLocalMC);
  assertTrue('testClassification 88', not ip7.isLinkLocalMC);
  assertTrue('testClassification 89', not ip7.isSiteLocalMC);
  assertTrue('testClassification 90', not ip7.isOrgLocalMC);
  assertTrue('testClassification 91', not ip7.isGlobalMC);

	ip8 := TIPAddress.Create('172.18.1.200'); // site local unicast
  assertTrue('testClassification 92', not ip8.isWildcard);
  assertTrue('testClassification 93', not ip8.isBroadcast);
  assertTrue('testClassification 94', not ip8.isLoopback);
  assertTrue('testClassification 95', not ip8.isMulticast);
  assertTrue('testClassification 96', ip8.isUnicast);
  assertTrue('testClassification 97', not ip8.isLinkLocal);
  assertTrue('testClassification 98', ip8.isSiteLocal);
  assertTrue('testClassification 99', not ip8.isWellKnownMC);
  assertTrue('testClassification 100', not ip8.isNodeLocalMC);
  assertTrue('testClassification 101', not ip8.isLinkLocalMC);
  assertTrue('testClassification 102', not ip8.isSiteLocalMC);
  assertTrue('testClassification 103', not ip8.isOrgLocalMC);
  assertTrue('testClassification 104', not ip8.isGlobalMC);
end;

procedure TTestIPAddress.testClassification6;
var
  ip1, ip2, ip3, ip4, ip5, ip6, ip7, ip8, ip9, ip10: TIPAddress;
begin
	ip1 := TIPAddress.Create('::'); // wildcard
  assertTrue('testClassification6 1', ip1.isWildcard);
  assertTrue('testClassification6 2', not ip1.isBroadcast);
  assertTrue('testClassification6 3', not ip1.isLoopback);
  assertTrue('testClassification6 4', not ip1.isMulticast);
  assertTrue('testClassification6 5', not ip1.isUnicast);
  assertTrue('testClassification6 6', not ip1.isLinkLocal);
  assertTrue('testClassification6 7', not ip1.isSiteLocal);
  assertTrue('testClassification6 8', not ip1.isWellKnownMC);
  assertTrue('testClassification6 9', not ip1.isNodeLocalMC);
  assertTrue('testClassification6 10', not ip1.isLinkLocalMC);
  assertTrue('testClassification6 11', not ip1.isSiteLocalMC);
  assertTrue('testClassification6 12', not ip1.isOrgLocalMC);
  assertTrue('testClassification6 13', not ip1.isGlobalMC);

	ip3 := TIPAddress.Create('::1'); // loopback
  assertTrue('testClassification6 14', not ip3.isWildcard);
  assertTrue('testClassification6 15', not ip3.isBroadcast);
  assertTrue('testClassification6 16', ip3.isLoopback);
  assertTrue('testClassification6 17', not ip3.isMulticast);
  assertTrue('testClassification6 18', ip3.isUnicast);
  assertTrue('testClassification6 19', not ip3.isLinkLocal);
  assertTrue('testClassification6 20', not ip3.isSiteLocal);
  assertTrue('testClassification6 21', not ip3.isWellKnownMC);
  assertTrue('testClassification6 22', not ip3.isNodeLocalMC);
  assertTrue('testClassification6 23', not ip3.isLinkLocalMC);
  assertTrue('testClassification6 24', not ip3.isSiteLocalMC);
  assertTrue('testClassification6 25', not ip3.isOrgLocalMC);
  assertTrue('testClassification6 26', not ip3.isGlobalMC);

	ip4 := TIPAddress.Create('2001:0db8:85a3:0000:0000:8a2e:0370:7334'); // unicast
  assertTrue('testClassification6 27', not ip4.isWildcard);
  assertTrue('testClassification6 28', not ip4.isBroadcast);
  assertTrue('testClassification6 29', not ip4.isLoopback);
  assertTrue('testClassification6 30', not ip4.isMulticast);
  assertTrue('testClassification6 31', ip4.isUnicast);
  assertTrue('testClassification6 32', not ip4.isLinkLocal);
  assertTrue('testClassification6 33', not ip4.isSiteLocal);
  assertTrue('testClassification6 34', not ip4.isWellKnownMC);
  assertTrue('testClassification6 35', not ip4.isNodeLocalMC);
  assertTrue('testClassification6 36', not ip4.isLinkLocalMC);
  assertTrue('testClassification6 37', not ip4.isSiteLocalMC);
  assertTrue('testClassification6 38', not ip4.isOrgLocalMC);
  assertTrue('testClassification6 39', not ip4.isGlobalMC);

	ip5 := TIPAddress.Create('fe80::21f:5bff:fec6:6707'); // link local unicast
  assertTrue('testClassification6 40', not ip5.isWildcard);
  assertTrue('testClassification6 41', not ip5.isBroadcast);
  assertTrue('testClassification6 42', not ip5.isLoopback);
  assertTrue('testClassification6 43', not ip5.isMulticast);
  assertTrue('testClassification6 44', ip5.isUnicast);
  assertTrue('testClassification6 45', ip5.isLinkLocal);
  assertTrue('testClassification6 46', not ip5.isSiteLocal);
  assertTrue('testClassification6 47', not ip5.isWellKnownMC);
  assertTrue('testClassification6 48', not ip5.isNodeLocalMC);
  assertTrue('testClassification6 49', not ip5.isLinkLocalMC);
  assertTrue('testClassification6 50', not ip5.isSiteLocalMC);
  assertTrue('testClassification6 51', not ip5.isOrgLocalMC);
  assertTrue('testClassification6 52', not ip5.isGlobalMC);

	ip10 := TIPAddress.Create('fe80::12'); // link local unicast
  assertTrue('testClassification6 53', not ip10.isWildcard);
  assertTrue('testClassification6 54', not ip10.isBroadcast);
  assertTrue('testClassification6 55', not ip10.isLoopback);
  assertTrue('testClassification6 56', not ip10.isMulticast);
  assertTrue('testClassification6 57', ip10.isUnicast);
  assertTrue('testClassification6 58', ip10.isLinkLocal);
  assertTrue('testClassification6 59', not ip10.isSiteLocal);
  assertTrue('testClassification6 60', not ip10.isWellKnownMC);
  assertTrue('testClassification6 61', not ip10.isNodeLocalMC);
  assertTrue('testClassification6 62', not ip10.isLinkLocalMC);
  assertTrue('testClassification6 63', not ip10.isSiteLocalMC);
  assertTrue('testClassification6 64', not ip10.isOrgLocalMC);
  assertTrue('testClassification6 65', not ip10.isGlobalMC);

	ip6 := TIPAddress.Create('fec0::21f:5bff:fec6:6707'); // site local unicast (RFC 4291)
  assertTrue('testClassification6 66', not ip6.isWildcard);
  assertTrue('testClassification6 67', not ip6.isBroadcast);
  assertTrue('testClassification6 68', not ip6.isLoopback);
  assertTrue('testClassification6 69', not ip6.isMulticast);
  assertTrue('testClassification6 70', ip6.isUnicast);
  assertTrue('testClassification6 71', not ip6.isLinkLocal);
  assertTrue('testClassification6 72', ip6.isSiteLocal);
  assertTrue('testClassification6 73', not ip6.isWellKnownMC);
  assertTrue('testClassification6 74', not ip6.isNodeLocalMC);
  assertTrue('testClassification6 75', not ip6.isLinkLocalMC);
  assertTrue('testClassification6 76', not ip6.isSiteLocalMC);
  assertTrue('testClassification6 77', not ip6.isOrgLocalMC);
  assertTrue('testClassification6 78', not ip6.isGlobalMC);

	ip7 := TIPAddress.Create('fc00::21f:5bff:fec6:6707'); // site local unicast (RFC 4193)
  assertTrue('testClassification6 79', not ip7.isWildcard);
  assertTrue('testClassification6 80', not ip7.isBroadcast);
  assertTrue('testClassification6 81', not ip7.isLoopback);
  assertTrue('testClassification6 82', not ip7.isMulticast);
  assertTrue('testClassification6 83', ip7.isUnicast);
  assertTrue('testClassification6 84', not ip7.isLinkLocal);
  assertTrue('testClassification6 85', ip7.isSiteLocal);
  assertTrue('testClassification6 86', not ip7.isWellKnownMC);
  assertTrue('testClassification6 87', not ip7.isNodeLocalMC);
  assertTrue('testClassification6 88', not ip7.isLinkLocalMC);
  assertTrue('testClassification6 89', not ip7.isSiteLocalMC);
  assertTrue('testClassification6 90', not ip7.isOrgLocalMC);
  assertTrue('testClassification6 91', not ip7.isGlobalMC);

	ip8 := TIPAddress.Create('::ffff:127.0.0.1'); // IPv4-mapped loopback
  assertTrue('testClassification6 92', not ip8.isWildcard);
  assertTrue('testClassification6 93', not ip8.isBroadcast);
  assertTrue('testClassification6 94', not ip8.isLoopback);
  assertTrue('testClassification6 95', not ip8.isMulticast);
  assertTrue('testClassification6 96', ip8.isUnicast);
  assertTrue('testClassification6 97', not ip8.isLinkLocal);
  assertTrue('testClassification6 98', not ip8.isSiteLocal);
  assertTrue('testClassification6 99', not ip8.isWellKnownMC);
  assertTrue('testClassification6 100', not ip8.isNodeLocalMC);
  assertTrue('testClassification6 101', not ip8.isLinkLocalMC);
  assertTrue('testClassification6 102', not ip8.isSiteLocalMC);
  assertTrue('testClassification6 103', not ip8.isOrgLocalMC);
  assertTrue('testClassification6 104', not ip8.isGlobalMC);

	ip9 := TIPAddress.Create('::ffff:127.255.255.254'); // IPv4-mapped loopback
  assertTrue('testClassification6 105', not ip9.isWildcard);
  assertTrue('testClassification6 106', not ip9.isBroadcast);
  assertTrue('testClassification6 107', not ip9.isLoopback);
  assertTrue('testClassification6 108', not ip9.isMulticast);
  assertTrue('testClassification6 109', ip9.isUnicast);
  assertTrue('testClassification6 110', not ip9.isLinkLocal);
  assertTrue('testClassification6 111', not ip9.isSiteLocal);
  assertTrue('testClassification6 112', not ip9.isWellKnownMC);
  assertTrue('testClassification6 113', not ip9.isNodeLocalMC);
  assertTrue('testClassification6 114', not ip9.isLinkLocalMC);
  assertTrue('testClassification6 115', not ip9.isSiteLocalMC);
  assertTrue('testClassification6 116', not ip9.isOrgLocalMC);
  assertTrue('testClassification6 117', not ip9.isGlobalMC);

	ip2 := TIPAddress.Create('fe80::1592:96a0:88bf:d2d7%12'); // IPv4-mapped loopback
  assertTrue('testClassification6 118', not ip2.isWildcard);
  assertTrue('testClassification6 119', not ip2.isBroadcast);
  assertTrue('testClassification6 120', not ip2.isLoopback);
  assertTrue('testClassification6 121', not ip2.isMulticast);
  assertTrue('testClassification6 122', ip2.isUnicast);
  assertTrue('testClassification6 123', ip2.isLinkLocal);
  assertTrue('testClassification6 124', not ip2.isSiteLocal);
  assertTrue('testClassification6 125', not ip2.isWellKnownMC);
  assertTrue('testClassification6 126', not ip2.isNodeLocalMC);
  assertTrue('testClassification6 127', not ip2.isLinkLocalMC);
  assertTrue('testClassification6 128', not ip2.isSiteLocalMC);
  assertTrue('testClassification6 129', not ip2.isOrgLocalMC);
  assertTrue('testClassification6 130', not ip2.isGlobalMC);
end;

procedure TTestIPAddress.testMCClassification;
var
  ip1, ip2, ip3, ip4, ip5: TIPAddress;
begin
	ip1 := TIPAddress.Create('224.0.0.100'); // well-known multicast
  assertTrue('testMCClassification 1', not ip1.isWildcard);
  assertTrue('testMCClassification 2', not ip1.isBroadcast);
  assertTrue('testMCClassification 3', not ip1.isLoopback);
  assertTrue('testMCClassification 4', ip1.isMulticast);
  assertTrue('testMCClassification 5', not ip1.isUnicast);
  assertTrue('testMCClassification 6', not ip1.isLinkLocal);
  assertTrue('testMCClassification 7', not ip1.isSiteLocal);
  assertTrue('testMCClassification 8', ip1.isWellKnownMC);
  assertTrue('testMCClassification 9', not ip1.isNodeLocalMC);
  assertTrue('testMCClassification 10', ip1.isLinkLocalMC); // well known are in the range of link local
  assertTrue('testMCClassification 11', not ip1.isSiteLocalMC);
  assertTrue('testMCClassification 12', not ip1.isOrgLocalMC);
  assertTrue('testMCClassification 13', not ip1.isGlobalMC);

	ip2 := TIPAddress.Create('224.1.0.100'); // link local
  assertTrue('testMCClassification 14', not ip2.isWildcard);
  assertTrue('testMCClassification 15', not ip2.isBroadcast);
  assertTrue('testMCClassification 16', not ip2.isLoopback);
  assertTrue('testMCClassification 17', ip2.isMulticast);
  assertTrue('testMCClassification 18', not ip2.isUnicast);
  assertTrue('testMCClassification 19', not ip2.isLinkLocal);
  assertTrue('testMCClassification 20', not ip2.isSiteLocal);
  assertTrue('testMCClassification 21', not ip2.isWellKnownMC);
  assertTrue('testMCClassification 22', not ip2.isNodeLocalMC);
  assertTrue('testMCClassification 23', ip2.isLinkLocalMC);
  assertTrue('testMCClassification 24', not ip2.isSiteLocalMC);
  assertTrue('testMCClassification 25', not ip2.isOrgLocalMC);
  assertTrue('testMCClassification 26', ip2.isGlobalMC);  // link local fall in the range of global

	ip3 := TIPAddress.Create('239.255.0.100'); // site local multicast
  assertTrue('testMCClassification 27', not ip3.isWildcard);
  assertTrue('testMCClassification 28', not ip3.isBroadcast);
  assertTrue('testMCClassification 29', not ip3.isLoopback);
  assertTrue('testMCClassification 30', ip3.isMulticast);
  assertTrue('testMCClassification 31', not ip3.isUnicast);
  assertTrue('testMCClassification 32', not ip3.isLinkLocal);
  assertTrue('testMCClassification 33', not ip3.isSiteLocal);
  assertTrue('testMCClassification 34', not ip3.isWellKnownMC);
  assertTrue('testMCClassification 35', not ip3.isNodeLocalMC);
  assertTrue('testMCClassification 36', not ip3.isLinkLocalMC);
  assertTrue('testMCClassification 37', ip3.isSiteLocalMC);
  assertTrue('testMCClassification 38', not ip3.isOrgLocalMC);
  assertTrue('testMCClassification 39', not ip3.isGlobalMC);

	ip4 := TIPAddress.Create('239.192.0.100'); // org local
  assertTrue('testMCClassification 40', not ip4.isWildcard);
  assertTrue('testMCClassification 41', not ip4.isBroadcast);
  assertTrue('testMCClassification 42', not ip4.isLoopback);
  assertTrue('testMCClassification 43', ip4.isMulticast);
  assertTrue('testMCClassification 44', not ip4.isUnicast);
  assertTrue('testMCClassification 45', not ip4.isLinkLocal);
  assertTrue('testMCClassification 46', not ip4.isSiteLocal);
  assertTrue('testMCClassification 47', not ip4.isWellKnownMC);
  assertTrue('testMCClassification 48', not ip4.isNodeLocalMC);
  assertTrue('testMCClassification 49', not ip4.isLinkLocalMC);
  assertTrue('testMCClassification 50', not ip4.isSiteLocalMC);
  assertTrue('testMCClassification 51', ip4.isOrgLocalMC);
  assertTrue('testMCClassification 52', not ip4.isGlobalMC);

	ip5 := TIPAddress.Create('224.2.127.254'); // global
  assertTrue('testMCClassification 53', not ip5.isWildcard);
  assertTrue('testMCClassification 54', not ip5.isBroadcast);
  assertTrue('testMCClassification 55', not ip5.isLoopback);
  assertTrue('testMCClassification 56', ip5.isMulticast);
  assertTrue('testMCClassification 57', not ip5.isUnicast);
  assertTrue('testMCClassification 58', not ip5.isLinkLocal);
  assertTrue('testMCClassification 59', not ip5.isSiteLocal);
  assertTrue('testMCClassification 60', not ip5.isWellKnownMC);
  assertTrue('testMCClassification 61', not ip5.isNodeLocalMC);
  assertTrue('testMCClassification 62', ip5.isLinkLocalMC); // link local fall in the range of global
  assertTrue('testMCClassification 63', not ip5.isSiteLocalMC);
  assertTrue('testMCClassification 64', not ip5.isOrgLocalMC);
  assertTrue('testMCClassification 65', ip5.isGlobalMC);
end;

procedure TTestIPAddress.testMCClassification6;
var
  ip1, ip2, ip3, ip4, ip5: TIPAddress;
begin
	ip1 := TIPAddress.Create('ff02:0:0:0:0:0:0:c'); // well-known link-local multicast
  assertTrue('testMCClassification6 1', not ip1.isWildcard);
  assertTrue('testMCClassification6 2', not ip1.isBroadcast);
  assertTrue('testMCClassification6 3', not ip1.isLoopback);
  assertTrue('testMCClassification6 4', ip1.isMulticast);
  assertTrue('testMCClassification6 5', not ip1.isUnicast);
  assertTrue('testMCClassification6 6', not ip1.isLinkLocal);
  assertTrue('testMCClassification6 7', not ip1.isSiteLocal);
  assertTrue('testMCClassification6 8', ip1.isWellKnownMC);
  assertTrue('testMCClassification6 9', not ip1.isNodeLocalMC);
  assertTrue('testMCClassification6 10', ip1.isLinkLocalMC);
  assertTrue('testMCClassification6 11', not ip1.isSiteLocalMC);
  assertTrue('testMCClassification6 12', not ip1.isOrgLocalMC);
  assertTrue('testMCClassification6 13', not ip1.isGlobalMC);

	ip2 := TIPAddress.Create('ff01:0:0:0:0:0:0:FB'); // node-local unicast
  assertTrue('testMCClassification6 14', not ip2.isWildcard);
  assertTrue('testMCClassification6 15', not ip2.isBroadcast);
  assertTrue('testMCClassification6 16', not ip2.isLoopback);
  assertTrue('testMCClassification6 17', ip2.isMulticast);
  assertTrue('testMCClassification6 18', not ip2.isUnicast);
  assertTrue('testMCClassification6 19', not ip2.isLinkLocal);
  assertTrue('testMCClassification6 20', not ip2.isSiteLocal);
  assertTrue('testMCClassification6 21', ip2.isWellKnownMC);
  assertTrue('testMCClassification6 22', ip2.isNodeLocalMC);
  assertTrue('testMCClassification6 23', not ip2.isLinkLocalMC);
  assertTrue('testMCClassification6 24', not ip2.isSiteLocalMC);
  assertTrue('testMCClassification6 25', not ip2.isOrgLocalMC);
  assertTrue('testMCClassification6 26', not ip2.isGlobalMC);

	ip3 := TIPAddress.Create('ff05:0:0:0:0:0:0:FB'); // site local multicast
  assertTrue('testMCClassification6 27', not ip3.isWildcard);
  assertTrue('testMCClassification6 28', not ip3.isBroadcast);
  assertTrue('testMCClassification6 29', not ip3.isLoopback);
  assertTrue('testMCClassification6 30', ip3.isMulticast);
  assertTrue('testMCClassification6 31', not ip3.isUnicast);
  assertTrue('testMCClassification6 32', not ip3.isLinkLocal);
  assertTrue('testMCClassification6 33', not ip3.isSiteLocal);
  assertTrue('testMCClassification6 34', ip3.isWellKnownMC);
  assertTrue('testMCClassification6 35', not ip3.isNodeLocalMC);
  assertTrue('testMCClassification6 36', not ip3.isLinkLocalMC);
  assertTrue('testMCClassification6 37', ip3.isSiteLocalMC);
  assertTrue('testMCClassification6 38', not ip3.isOrgLocalMC);
  assertTrue('testMCClassification6 39', not ip3.isGlobalMC);

	ip4 := TIPAddress.Create('ff18:0:0:0:0:0:0:FB'); // org local
  assertTrue('testMCClassification6 40', not ip4.isWildcard);
  assertTrue('testMCClassification6 41', not ip4.isBroadcast);
  assertTrue('testMCClassification6 42', not ip4.isLoopback);
  assertTrue('testMCClassification6 43', ip4.isMulticast);
  assertTrue('testMCClassification6 44', not ip4.isUnicast);
  assertTrue('testMCClassification6 45', not ip4.isLinkLocal);
  assertTrue('testMCClassification6 46', not ip4.isSiteLocal);
  assertTrue('testMCClassification6 47', not ip4.isWellKnownMC);
  assertTrue('testMCClassification6 48', not ip4.isNodeLocalMC);
  assertTrue('testMCClassification6 49', not ip4.isLinkLocalMC);
  assertTrue('testMCClassification6 50', not ip4.isSiteLocalMC);
  assertTrue('testMCClassification6 51', ip4.isOrgLocalMC);
  assertTrue('testMCClassification6 52', not ip4.isGlobalMC);

	ip5 := TIPAddress.Create('ff1f:0:0:0:0:0:0:FB'); // global
  assertTrue('testMCClassification6 53', not ip5.isWildcard);
  assertTrue('testMCClassification6 54', not ip5.isBroadcast);
  assertTrue('testMCClassification6 55', not ip5.isLoopback);
  assertTrue('testMCClassification6 56', ip5.isMulticast);
  assertTrue('testMCClassification6 57', not ip5.isUnicast);
  assertTrue('testMCClassification6 58', not ip5.isLinkLocal);
  assertTrue('testMCClassification6 59', not ip5.isSiteLocal);
  assertTrue('testMCClassification6 60', not ip5.isWellKnownMC);
  assertTrue('testMCClassification6 61', not ip5.isNodeLocalMC);
  assertTrue('testMCClassification6 62', not ip5.isLinkLocalMC);
  assertTrue('testMCClassification6 63', not ip5.isSiteLocalMC);
  assertTrue('testMCClassification6 64', not ip5.isOrgLocalMC);
  assertTrue('testMCClassification6 65', ip5.isGlobalMC);
end;

procedure TTestIPAddress.testOperators;
var
  ip, mask, net, host: TIPAddress;
begin
  ip := TIPAddress.Create('10.0.0.51');
  mask := TIPAddress.Create(24, TAddressFamily.IPv4);

  net := TIPAddress.Create(ip);
  net := net and mask;
  assertTrue('testOperators 1', net.ToString = '10.0.0.0');

  host := TIPAddress.Create('0.0.0.51');
  net := net or host;
  assertTrue('testOperators 2', net = ip);

  mask := not mask;
  assertTrue('testOperators 3', mask.ToString = '0.0.0.255');
end;

procedure TTestIPAddress.testParse;
var
  ip: TIPAddress;
begin
  ip.Create;
  assertTrue('testParse 1', TIPAddress.tryParse('0.0.0.0', ip));
  assertTrue('testParse 2', TIPAddress.tryParse('255.255.255.255', ip));
  assertTrue('testParse 3', TIPAddress.tryParse('192.168.1.120', ip));
  assertTrue('testParse 4', not TIPAddress.tryParse('192.168.1.280', ip));
  assertTrue('testParse 5', TIPAddress.tryParse('::', ip));
  assertTrue('testParse 6', not TIPAddress.tryParse(':::', ip));
  assertTrue('testParse 7', TIPAddress.tryParse('0::', ip));
  assertTrue('testParse 8', TIPAddress.tryParse('0:0::', ip));
  assertTrue('testParse 9', TIPAddress.tryParse('0:0:0::', ip));
  assertTrue('testParse 10', TIPAddress.tryParse('0:0:0:0::', ip));
  assertTrue('testParse 11', TIPAddress.tryParse('0:0:0:0:0::', ip));
  assertTrue('testParse 12', TIPAddress.tryParse('0:0:0:0:0:0::', ip));
  assertTrue('testParse 13', TIPAddress.tryParse('0:0:0:0:0:0:0::', ip));
  assertTrue('testParse 14', TIPAddress.tryParse('0:0:0:0:0:0:0:0', ip));
  assertTrue('testParse 15', not TIPAddress.tryParse('0:0:0:0:0:0:0:0:', ip));
  assertTrue('testParse 16', not TIPAddress.tryParse('::0:0::', ip));
  assertTrue('testParse 17', not TIPAddress.tryParse('::0::0::', ip));
  assertTrue('testParse 18', TIPAddress.tryParse('::1', ip));
  assertTrue('testParse 19', TIPAddress.tryParse('1080:0:0:0:8:600:200a:425c', ip));
  assertTrue('testParse 20', TIPAddress.tryParse('1080::8:600:200a:425c', ip));
  assertTrue('testParse 21', TIPAddress.tryParse('1080::8:600:200A:425C', ip));
  assertTrue('testParse 22', TIPAddress.tryParse('1080::8:600:200a:425c', ip));
  assertTrue('testParse 23', TIPAddress.tryParse('::192.168.1.120', ip));
  assertTrue('testParse 24', TIPAddress.tryParse('::ffff:192.168.1.120', ip));
  assertTrue('testParse 25', TIPAddress.tryParse('::ffff:192.168.1.120', ip));
  assertTrue('testParse 26', TIPAddress.tryParse('ffff:ffff:ffff:ffff::', ip));
  assertTrue('testParse 27', TIPAddress.tryParse('ffff:ffff::', ip));
end;

procedure TTestIPAddress.testPrefixCons;
var
  ip1, ip2: TIPAddress;
begin
	ip1 := TIPAddress.Create(15, TAddressFamily.IPv4);
  assertTrue('testPrefixCons 1', ip1.ToString = '255.254.0.0');

	ip2 := TIPAddress.Create(62, TAddressFamily.IPv6);
  assertTrue('testPrefixCons 2', ip2.ToString = 'ffff:ffff:ffff:fffc::');
end;

procedure TTestIPAddress.testPrefixLen;
var
  ia1, ia2, ia3, ia4, ia5, ia6, ia7, ia8, ia9: TIPAddress;
begin
	ia1 := TIPAddress.Create(15, TAddressFamily.IPv4);
  assertTrue('testPrefixLen 1', ia1.prefixLength = 15);

	ia2 := TIPAddress.Create(16, TAddressFamily.IPv4);
  assertTrue('testPrefixLen 2', ia2.prefixLength = 16);

	ia3 := TIPAddress.Create(23, TAddressFamily.IPv4);
  assertTrue('testPrefixLen 3', ia3.prefixLength = 23);

	ia4 := TIPAddress.Create(24, TAddressFamily.IPv4);
  assertTrue('testPrefixLen 4', ia4.prefixLength = 24);

	ia5 := TIPAddress.Create(25, TAddressFamily.IPv4);
  assertTrue('testPrefixLen 5', ia5.prefixLength = 25);

	ia6 := TIPAddress.Create(62, TAddressFamily.IPv6);
  assertTrue('testPrefixLen 6', ia6.prefixLength = 62);

	ia7 := TIPAddress.Create(63, TAddressFamily.IPv6);
  assertTrue('testPrefixLen 7', ia7.prefixLength = 63);

	ia8 := TIPAddress.Create(64, TAddressFamily.IPv6);
  assertTrue('testPrefixLen 8', ia8.prefixLength = 64);

	ia9 := TIPAddress.Create(65, TAddressFamily.IPv6);
  assertTrue('testPrefixLen 9', ia9.prefixLength = 65);
end;

procedure TTestIPAddress.testRelationals;
var
  ip1, ip2, ip3, ip4: TIPAddress;
begin
	ip1 := TIPAddress.Create('192.168.1.120');
	ip2 := TIPAddress.Create(ip1);
	ip3.Create;
	ip4 := TIPAddress.Create('10.0.0.138');

  assertTrue('testRelationals 1', ip1 <> ip4);
  assertTrue('testRelationals 2', ip1 = ip2);
  assertTrue('testRelationals 3', not (ip1 <> ip2));
  assertTrue('testRelationals 4', not (ip1 = ip4));
  assertTrue('testRelationals 5', ip1 > ip4);
  assertTrue('testRelationals 6', ip1 >= ip4);
  assertTrue('testRelationals 7', ip4 < ip1);
  assertTrue('testRelationals 8', ip4 <= ip1);
  assertTrue('testRelationals 9', not (ip1 < ip4));
  assertTrue('testRelationals 10',not (ip1 <= ip4));
  assertTrue('testRelationals 11', not (ip4 > ip1));
  assertTrue('testRelationals 12', not (ip4 >= ip1));

  ip3.Assign(ip1);
  assertTrue('testRelationals 13', ip1 = ip3);
  ip3.Assign(ip4);
  assertTrue('testRelationals 14', ip1 <> ip3);
  assertTrue('testRelationals 15', ip3 = ip4);
end;

procedure TTestIPAddress.testRelationals6;
var
  ip1, ip2, ip3, ip4: TIPAddress;
begin
	ip1 := TIPAddress.Create('fe80::1592:96a0:88bf:d2d7');
	ip2 := TIPAddress.Create(ip1);
	ip3.Create;
	ip4 := TIPAddress.Create('1080:0:0:0:8:600:200a:425c');

  assertTrue('testRelationals6 1', ip1 <> ip4);
  assertTrue('testRelationals6 2', ip1 = ip2);
  assertTrue('testRelationals6 3', not (ip1 <> ip2));
  assertTrue('testRelationals6 4', not (ip1 = ip4));
  assertTrue('testRelationals6 5', ip1 > ip4);
  assertTrue('testRelationals6 6', ip1 >= ip4);
  assertTrue('testRelationals6 7', ip4 < ip1);
  assertTrue('testRelationals6 8', ip4 <= ip1);
  assertTrue('testRelationals6 9', not (ip1 < ip4));
  assertTrue('testRelationals6 10',not (ip1 <= ip4));
  assertTrue('testRelationals6 11', not (ip4 > ip1));
  assertTrue('testRelationals6 12', not (ip4 >= ip1));

  ip3.Assign(ip1);
  assertTrue('testRelationals6 13', ip1 = ip3);
  ip3.Assign(ip4);
  assertTrue('testRelationals6 14', ip1 <> ip3);
  assertTrue('testRelationals6 15', ip3 = ip4);
end;

procedure TTestIPAddress.testScoped;
var
  ip: TIPAddress;
begin
  ip.Create;
  assertTrue('testScoped 1', TIPAddress.tryParse('fe80::1592:96a0:88bf:d2d7%xyzabc123', ip) = false);
  assertTrue('testScoped 1', TIPAddress.tryParse('fe80::1592:96a0:88bf:d2d7%12', ip) = true);
end;

procedure TTestIPAddress.testStringConv;
var
  ia01, ia02: TIPAddress;
  ia1, ia2, ia3, ia4, ia5: TIPAddress;
begin
	ia01 := TIPAddress.Create('127.0.0.1');
	ia1 := TIPAddress.Create(ia01);
  assertTrue('testStringConv 1', ia1.family = TAddressFamily.IPv4);
  assertTrue('testStringConv 2', ia1.ToString = '127.0.0.1');

	ia02 := TIPAddress.Create('192.168.1.120');
	ia2 := TIPAddress.Create(ia02);
  assertTrue('testStringConv 3', ia2.family = TAddressFamily.IPv4);
  assertTrue('testStringConv 4', ia2.ToString = '192.168.1.120');

	ia3 := TIPAddress.Create('255.255.255.255');
  assertTrue('testStringConv 5', ia3.family = TAddressFamily.IPv4);
  assertTrue('testStringConv 6', ia3.ToString = '255.255.255.255');

	ia4 := TIPAddress.Create('0.0.0.0');
  assertTrue('testStringConv 7', ia4.family = TAddressFamily.IPv4);
  assertTrue('testStringConv 8', ia4.ToString = '0.0.0.0');

	ia5 := TIPAddress.Create(24, TAddressFamily.IPv4);
  assertTrue('testStringConv 9', ia5.family = TAddressFamily.IPv4);
  assertTrue('testStringConv 10', ia5.ToString = '255.255.255.0');
end;

procedure TTestIPAddress.testStringConv6;
var
  ia00, ia01, ia02: TIPAddress;
  ia0, ia1, ia2, ia3, ia4, ia5, ia6, ia7: TIPAddress;
begin
	ia00 := TIPAddress.Create('::1');
	ia0 := TIPAddress.Create(ia00);
  assertTrue('testStringConv6 1', ia0.family = TAddressFamily.IPv6);
  assertTrue('testStringConv6 2', ia0.ToString = '::1');

	ia01 := TIPAddress.Create('1080:0:0:0:8:600:200a:425c');
	ia1 := TIPAddress.Create(ia01);
  assertTrue('testStringConv6 3', ia1.family = TAddressFamily.IPv6);
  assertTrue('testStringConv6 4', ia1.ToString = '1080::8:600:200a:425c');

	ia02 := TIPAddress.Create('1080::8:600:200A:425C');
	ia2 := TIPAddress.Create(ia02);
  assertTrue('testStringConv6 5', ia2.family = TAddressFamily.IPv6);
  assertTrue('testStringConv6 6', ia2.ToString = '1080::8:600:200a:425c');

	ia3 := TIPAddress.Create('::192.168.1.120');
  assertTrue('testStringConv6 7', ia3.family = TAddressFamily.IPv6);
  assertTrue('testStringConv6 8', ia3.ToString = '::192.168.1.120');

	ia4 := TIPAddress.Create('::ffff:192.168.1.120');
  assertTrue('testStringConv6 7', ia4.family = TAddressFamily.IPv6);
  assertTrue('testStringConv6 8', ia4.ToString = '::ffff:192.168.1.120');

	ia5 := TIPAddress.Create(64, TAddressFamily.IPv6);
  assertTrue('testStringConv6 9', ia5.family = TAddressFamily.IPv6);
  assertTrue('testStringConv6 10', ia5.ToString = 'ffff:ffff:ffff:ffff::');

	ia6 := TIPAddress.Create(32, TAddressFamily.IPv6);
  assertTrue('testStringConv6 11', ia6.family = TAddressFamily.IPv6);
  assertTrue('testStringConv6 12', ia6.ToString = 'ffff:ffff::');

	ia7 := TIPAddress.Create('::');
  assertTrue('testStringConv6 13', ia7.family = TAddressFamily.IPv6);
  assertTrue('testStringConv6 14', ia7.ToString = '::');
end;

procedure TTestIPAddress.testWildcard;
var
  wildcard: TIPAddress;
begin
	wildcard := TIPAddress.wildcard;
  assertTrue('testWildcard 1', wildcard.isWildcard);
  assertTrue('testWildcard 2', wildcard.ToString = '0.0.0.0');
end;

class procedure TTestIPAddress.Test;
var
  testclass: TTestIPAddress;
begin
  TRTest.Comment('=============================================');
  TRTest.Comment('= TestIPAddress');
  TRTest.Comment('=============================================');

  testclass := TTestIPAddress.Create;
  try
    testclass.testStringConv;
    testclass.testStringConv6;
    testclass.testParse;
    testclass.testClassification;
    testclass.testMCClassification;
    testclass.testClassification6;
    testclass.testMCClassification6;
    testclass.testRelationals;
    testclass.testRelationals6;
    testclass.testWildcard;
    testclass.testBroadcast;
    testclass.testPrefixCons;
    testclass.testPrefixLen;
    testclass.testOperators;
    testclass.testByteOrderMacros;
    testclass.testScoped;
  finally
    testclass.Free;
  end;
end;

end.
