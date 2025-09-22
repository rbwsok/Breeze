unit TestNetworkInterface;

interface

uses System.SysUtils, Generics.Collections, TestUtil;

type

  TTestNetworkInterface = class
  private
    procedure testList;
    procedure testMap;
    procedure testForName;
    procedure testForAddress;
    procedure testForIndex;
    procedure testMapIpOnly;
    procedure testMapUpOnly;
    procedure testListMapConformance;
  public
    class procedure Test;
  end;

implementation

uses Breeze.Net.NetworkInterface, Breeze.Net.SocketDefs, Breeze.Net.IPAddress;

{ TTestNetworkInterface }

procedure TTestNetworkInterface.testForAddress;
var
  LInterfaceList: TObjectList<TNetworkInterface>;
  it, ifc: TNetworkInterface;
  index: Integer;
  addr: TIPAddress;
begin
  LInterfaceList := TNetworkInterface.List;
  try
    assertTrue('testForAddress 1', LInterfaceList.Count <> 0);
    index := 2;

    for it in LInterfaceList do
    begin
      if it.addressList.Count = 0 then
        continue;

      if it.supportsIPv4 then
      begin
        ifc := TNetworkInterface.forAddress(it.firstAddress(TAddressFamily.IPv4));
        assertTrue('testForAddress ' + intToStr(index), ifc.firstAddress(TAddressFamily.IPv4) = it.firstAddress(TAddressFamily.IPv4));
        inc(index);
        addr := TIPAddress.Create(TAddressFamily.IPv4);
        assertTrue('testForAddress ' + intToStr(index), addr.isWildcard);
        inc(index);
        it.firstAddress(addr, TAddressFamily.IPv4);
        assertTrue('testForAddress ' + intToStr(index), not addr.isWildcard);
        inc(index);
        FreeAndNil(ifc);
      end
      else
      begin
      	addr := TIPAddress.Create(TAddressFamily.IPv4);
        assertTrue('testForAddress ' + intToStr(index), addr.isWildcard);
        inc(index);
        it.firstAddress(addr, TAddressFamily.IPv4);
        assertTrue('testForAddress ' + intToStr(index), addr.isWildcard);
        inc(index);
      end;
    end;
  finally
    LInterfaceList.Free;
  end;
end;

procedure TTestNetworkInterface.testForIndex;
var
  LInterfaceList: TObjectList<TNetworkInterface>;
  it, ifc: TNetworkInterface;
  index: Integer;
begin
  LInterfaceList := TNetworkInterface.List;
  assertTrue('testForIndex 1', LInterfaceList.Count <> 0);
  index := 2;

  for it in LInterfaceList do
  begin
    ifc := TNetworkInterface.ForIndex(it.InterfaceIndex);
    assertTrue('testForIndex ' + IntToStr(index), ifc.InterfaceIndex = it.InterfaceIndex);
    inc(index);
    FreeAndNil(ifc);
  end;
  LInterfaceList.Free;
end;

procedure TTestNetworkInterface.testForName;
var
  LInterfaceList: TObjectList<TNetworkInterface>;
  it, ifc: TNetworkInterface;
  index: Integer;
begin
  LInterfaceList := TNetworkInterface.List;
  index := 1;
  for it in LInterfaceList do
  begin
    ifc := TNetworkInterface.forName(it.name);
    assertTrue('testForName ' + IntToStr(index), ifc.name = it.name);
    FreeAndNil(ifc);

    inc(index);
  end;
  LInterfaceList.Free;
end;

procedure TTestNetworkInterface.testList;
var
  LInterfaceList: TObjectList<TNetworkInterface>;
  it: TNetworkInterface;
  mac: RawByteString;
  tp: TAddressTuple;
begin
  LInterfaceList := TNetworkInterface.List(false, false);
  assertTrue('testList 1', LInterfaceList.Count <> 0);

  for it in LInterfaceList do
  begin
    TRTest.Comment;
    TRTest.Comment('=============');
    TRTest.Comment('Index:       ' + IntToStr(it.InterfaceIndex));
    TRTest.Comment('Name:        ' + it.Name);
    TRTest.Comment('DisplayName: ' + it.DisplayName);
    TRTest.Comment('Status:      ' + BoolToStr(it.IsUp, true));

    mac := it.macAddress;
    if (mac <> '') and (it.InterfaceType <> TNetworkInterface.TType.NI_TYPE_SOFTWARE_LOOPBACK) then
      TRTest.Comment('MAC Address: ' + TNetworkInterface.MacToString(mac));

    for tp in it.addressList do
    begin
      TRTest.Comment('----------');
      TRTest.Comment('Address: ' + tp.address.ToString);
      if not tp.mask.isWildcard then
        TRTest.Comment('Mask: ' + tp.mask.ToString);
      if not tp.broadcast.isWildcard then
        TRTest.Comment('Broadcast: ' + tp.broadcast.ToString);
    end;

    TRTest.Comment('=============');
    TRTest.Comment;
	end;

  LInterfaceList.Free;
end;

procedure TTestNetworkInterface.testListMapConformance;
begin

end;

procedure TTestNetworkInterface.testMap;
var
  LInterfaceList: TObjectList<TNetworkInterface>;
  it: TNetworkInterface;
begin
  LInterfaceList := TNetworkInterface.List;
  assertTrue('testMap 1', LInterfaceList.Count <> 0);

  for it in LInterfaceList do
  begin
    TRTest.Comment('Address: ' + it.address.ToString);
    TRTest.Comment('Mask: ' + it.subnetMask.ToString);
    TRTest.Comment('Broadcast: ' + it.broadcastAddress.ToString);
	end;

  LInterfaceList.Free;
end;

procedure TTestNetworkInterface.testMapIpOnly;
var
  LInterfaceList: TObjectList<TNetworkInterface>;
  it: TNetworkInterface;
  LIndex: Integer;
begin
  LInterfaceList := TNetworkInterface.List(true, false);
  try
    assertTrue('testMapIpOnly 1', LInterfaceList.Count <> 0);
    LIndex := 2;

    for it in LInterfaceList do
    begin
      assertTrue('testMapIpOnly ' + IntToStr(LIndex), it.supportsIPv4 or it.supportsIPv6);
      TRTest.Comment('Interface: ' + IntToStr(it.InterfaceIndex));
      TRTest.Comment('Address: ' + it.address.ToString);

      if (Length(it.MACAddress) > 0) and (it.InterfaceType <> TNetworkInterface.TType.NI_TYPE_SOFTWARE_LOOPBACK) then
        TRTest.Comment('mac: ' + it.MACToString(it.macAddress));
    end;

  finally
    LInterfaceList.Free;
  end;
end;

procedure TTestNetworkInterface.testMapUpOnly;
var
  LInterfaceList: TObjectList<TNetworkInterface>;
  it: TNetworkInterface;
  index: Integer;
begin
  LInterfaceList := TNetworkInterface.List(false, true);
  try
    assertTrue('testMapUpOnly 1', LInterfaceList.Count <> 0);
    index := 2;

    for it in LInterfaceList do
    begin
      assertTrue('testMapUpOnly ' + IntToStr(index), it.isUp);
      inc(index);
    end;

  finally
    LInterfaceList.Free;
  end;
end;

class procedure TTestNetworkInterface.Test;
var
  testclass: TTestNetworkInterface;
begin
  TRTest.Comment('=============================================');
  TRTest.Comment('= TestNetworkInterface');
  TRTest.Comment('=============================================');

  testclass := TTestNetworkInterface.Create;
  try
    testclass.testList;
    testclass.testMap;
    testclass.testForName;
    testclass.testForAddress;
    testclass.testForIndex;
    testclass.testMapIpOnly;
    testclass.testMapUpOnly;
    testclass.testListMapConformance;
  finally
    testclass.Free;
  end;
end;

end.
