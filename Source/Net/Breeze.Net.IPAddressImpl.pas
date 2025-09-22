unit Breeze.Net.IPAddressImpl;

interface

uses Winapi.Windows, Winapi.Winsock2, Winapi.IpExport, System.SysUtils, System.Math, System.Win.Crtl,
Breeze.Net.SocketDefs, Breeze.Exception;

type
  TIPv4AddressImpl = record
  private
  	FAddr: in_addr;
    class function MaskBits(AValue: Cardinal; ASize: Cardinal): Cardinal; static;
    class function Swap32(AValue: Cardinal): Cardinal; static;
  public
    procedure Create; overload;
    constructor Create(AHostAddr: Pointer); overload;
    constructor Create(APrefix: Cardinal); overload;
    constructor Create(const AAddress: TIPv4AddressImpl); overload;
    constructor Create(const AAddress: String); overload;
    constructor Create(const AAddress: RawByteString); overload;

    function Addr: Pointer;
    function Scope: Cardinal;
	  function Clone: TIPv4AddressImpl;
	  function ToString: String;
  	function Length: Cardinal;
	  function Family: TAddressFamily;
	  function NativeFamily: Integer;
	  function IsWildcard: Boolean;
	  function IsBroadcast: Boolean;
	  function IsLoopback: Boolean;
	  function IsMulticast: Boolean;
	  function IsLinkLocal: Boolean;
	  function IsSiteLocal: Boolean;
	  function IsIPv4Mapped: Boolean;
	  function IsIPv4Compatible: Boolean;
	  function IsWellKnownMC: Boolean;
	  function IsNodeLocalMC: Boolean;
	  function IsLinkLocalMC: Boolean;
	  function IsSiteLocalMC: Boolean;
	  function IsOrgLocalMC: Boolean;
	  function IsGlobalMC: Boolean;
    procedure Mask(AMask, ASet: TIPv4AddressImpl);
  	function PrefixLength: Cardinal;

    class operator Equal(const A, B: TIPv4AddressImpl): Boolean;
    class operator NotEqual(const A, B: TIPv4AddressImpl): Boolean;
    class operator BitwiseAnd(const A, B: TIPv4AddressImpl): TIPv4AddressImpl;
    class operator BitwiseOr(const A, B: TIPv4AddressImpl): TIPv4AddressImpl;
    class operator BitwiseXor(const A, B: TIPv4AddressImpl): TIPv4AddressImpl;
    class operator LogicalNot(const A: TIPv4AddressImpl): TIPv4AddressImpl;
  end;

  TIPv6AddressImpl = record
  private
	  FAddr: in6_addr;
    FScope: Cardinal;

    class function MaskBits(AValue: Cardinal; ASize: Cardinal): Cardinal; static;
    class function Swap16(AValue: Word): Word; static;
  public
    procedure Create; overload;
    constructor Create(AHostAddr: Pointer); overload;
    constructor Create(AHostAddr: Pointer; AScope: Cardinal); overload;
    constructor Create(APrefix: Cardinal); overload;
    constructor Create(const AAddress: String); overload;

    function Addr: Pointer;
    function Scope: Cardinal;
	  function Clone: TIPv6AddressImpl;
	  function ToString: String;
  	function Length: Cardinal;
	  function Family: TAddressFamily;
	  function NativeFamily: Integer;
	  function IsWildcard: Boolean;
	  function IsBroadcast: Boolean;
	  function IsLoopback: Boolean;
	  function IsMulticast: Boolean;
	  function IsLinkLocal: Boolean;
	  function IsSiteLocal: Boolean;
	  function IsIPv4Mapped: Boolean;
	  function IsIPv4Compatible: Boolean;
	  function IsWellKnownMC: Boolean;
	  function IsNodeLocalMC: Boolean;
	  function IsLinkLocalMC: Boolean;
	  function IsSiteLocalMC: Boolean;
	  function IsOrgLocalMC: Boolean;
	  function IsGlobalMC: Boolean;
  	function PrefixLength: Cardinal;

    class operator Equal(const A, B: TIPv6AddressImpl): Boolean;
    class operator NotEqual(const A, B: TIPv6AddressImpl): Boolean;
    class operator BitwiseAnd(const A, B: TIPv6AddressImpl): TIPv6AddressImpl;
    class operator BitwiseOr(const A, B: TIPv6AddressImpl): TIPv6AddressImpl;
    class operator BitwiseXor(const A, B: TIPv6AddressImpl): TIPv6AddressImpl;
    class operator LogicalNot(const A: TIPv6AddressImpl): TIPv6AddressImpl;
  end;

  function RtlIpv6StringToAddressExW(AddressString: PChar; Address: PIn6Addr; ScopeId: PULONG; Port: PUSHORT): LONG; stdcall; external 'ntdll.dll';

implementation

{ TIPv4AddressImpl }

class function TIPv4AddressImpl.MaskBits(AValue: Cardinal; ASize: Cardinal): Cardinal;
var
  LCount: Cardinal;
begin
	if AValue > 0 then
  begin
		AValue := (AValue xor (AValue - 1)) shr 1;
    LCount := 0;
    while AValue > 0  do
    begin
      AValue := AValue shr 1;
      inc(LCount);
    end;
	end
	else
    LCount := ASize;
	result := ASize - LCount;
end;

class function TIPv4AddressImpl.Swap32(AValue: Cardinal): Cardinal;
begin
  result := (AValue shr 24) or
            ((AValue and $00FF0000) shr 8) or
            ((AValue and $0000FF00) shl 8) or
            ((AValue and $000000FF) shl 24);
end;

procedure TIPv4AddressImpl.Create;
begin
  FAddr.S_addr := 0;
end;

constructor TIPv4AddressImpl.Create(AHostAddr: Pointer);
begin
  FAddr.S_addr := pin_addr(AHostAddr).S_addr;
end;

constructor TIPv4AddressImpl.Create(APrefix: Cardinal);
var
  LAddress: Cardinal;
begin
	LAddress := ifthen(APrefix = 32, $ffffffff, not ($ffffffff shr APrefix));
	FAddr.s_addr := swap32(LAddress);
end;

constructor TIPv4AddressImpl.Create(const AAddress: String);
begin
  Create(Utf8Encode(AAddress));
end;

constructor TIPv4AddressImpl.Create(const AAddress: RawByteString);
var
  LInAddr: in_addr;
begin
	if AAddress = '' then
  begin
    Create;
    exit;
  end;

	LInAddr.s_addr := inet_addr(@AAddress[1]);

	if (LInAddr.s_addr = INADDR_NONE) and (AAddress <> '255.255.255.255') then
		Create
	else
		Create(@LInAddr);
end;

constructor TIPv4AddressImpl.Create(const AAddress: TIPv4AddressImpl);
begin
  FAddr := AAddress.FAddr;
end;

function TIPv4AddressImpl.NativeFamily: Integer;
begin
 	result := AF_INET;
end;

function TIPv4AddressImpl.Clone: TIPv4AddressImpl;
begin
  result := TIPv4AddressImpl.Create(@FAddr);
end;

function TIPv4AddressImpl.Family: TAddressFamily;
begin
  result := TAddressFamily.IPv4;
end;

function TIPv4AddressImpl.IsBroadcast: Boolean;
begin
	result := FAddr.s_addr = INADDR_NONE;
end;

function TIPv4AddressImpl.IsGlobalMC: Boolean;
var
  addr: Cardinal;
begin
  addr := ntohl(FAddr.s_addr);
	result := (addr >= $E0000100) and (addr <= $EE000000); // 224.0.1.0 to 238.255.255.255
end;

function TIPv4AddressImpl.IsIPv4Compatible: Boolean;
begin
  result := true;
end;

function TIPv4AddressImpl.IsIPv4Mapped: Boolean;
begin
  result := true;
end;

function TIPv4AddressImpl.IsLinkLocal: Boolean;
begin
  result := (ntohl(FAddr.s_addr) and $FFFF0000) = $A9FE0000; // 169.254.0.0/16
end;

function TIPv4AddressImpl.IsLinkLocalMC: Boolean;
begin
  result := (ntohl(FAddr.s_addr) and $FF000000) = $E0000000; // 244.0.0.0/24
end;

function TIPv4AddressImpl.IsLoopback: Boolean;
begin
  result := (ntohl(FAddr.s_addr) and $FF000000) = $7F000000; // 127.0.0.1 to 127.255.255.255
end;

function TIPv4AddressImpl.IsMulticast: Boolean;
begin
  result := (ntohl(FAddr.s_addr) and $F0000000) = $E0000000; // 224.0.0.0/24 to 239.0.0.0/24
end;

function TIPv4AddressImpl.IsNodeLocalMC: Boolean;
begin
  result := false;
end;

function TIPv4AddressImpl.IsOrgLocalMC: Boolean;
begin
  result := (ntohl(FAddr.s_addr) and $FFFF0000) = $EFC00000; // 239.192.0.0/16
end;

function TIPv4AddressImpl.IsSiteLocal: Boolean;
var
  LAddr: Cardinal;
begin
  LAddr := ntohl(FAddr.s_addr);
	result := ((LAddr and $FF000000) = $0A000000) or     // 10.0.0.0/24
        		((LAddr and $FFFF0000) = $C0A80000) or        // 192.68.0.0/16
            ((LAddr >= $AC100000) and (LAddr <= $AC1FFFFF)); // 172.16.0.0 to 172.31.255.255
end;

function TIPv4AddressImpl.IsSiteLocalMC: Boolean;
begin
  result := (ntohl(FAddr.s_addr) and $FFFF0000) = $EFFF0000; // 239.255.0.0/16
end;

function TIPv4AddressImpl.IsWellKnownMC: Boolean;
begin
	result := (ntohl(FAddr.s_addr) and $FFFFFF00) = $E0000000; // 224.0.0.0/8
end;

function TIPv4AddressImpl.IsWildcard: Boolean;
begin
	result := FAddr.s_addr = INADDR_ANY;
end;

function TIPv4AddressImpl.Length: Cardinal;
begin
	result := sizeof(FAddr);
end;

procedure TIPv4AddressImpl.Mask(AMask, ASet: TIPv4AddressImpl);
begin
	FAddr.s_addr := FAddr.s_addr and TIPv4AddressImpl(AMask).FAddr.s_addr;
	FAddr.s_addr := FAddr.s_addr or TIPv4AddressImpl(ASet).FAddr.s_addr and (not TIPv4AddressImpl(AMask).FAddr.s_addr);
end;

function TIPv4AddressImpl.PrefixLength: Cardinal;
begin
	result := MaskBits(ntohl(FAddr.s_addr), 32);
end;

function TIPv4AddressImpl.Scope: Cardinal;
begin
	result := 0;
end;

function TIPv4AddressImpl.ToString: String;
var
  bytes: PByte;
begin
  bytes := @FAddr.S_addr;
  result := IntToStr(bytes[0]) + '.' + IntToStr(bytes[1]) + '.' +
      IntToStr(bytes[2]) + '.' + IntToStr(bytes[3]);
end;

function TIPv4AddressImpl.Addr: Pointer;
begin
	result := @FAddr;
end;

class operator TIPv4AddressImpl.Equal(const A, B: TIPv4AddressImpl): Boolean;
begin
  result := A.FAddr.S_addr = B.FAddr.S_addr;
end;

class operator TIPv4AddressImpl.NotEqual(const A, B: TIPv4AddressImpl): Boolean;
begin
  result := A.FAddr.S_addr <> B.FAddr.S_addr;
end;

class operator TIPv4AddressImpl.BitwiseAnd(const A, B: TIPv4AddressImpl): TIPv4AddressImpl;
begin
  result.FAddr.S_addr := A.FAddr.S_addr and B.FAddr.S_addr;
end;

class operator TIPv4AddressImpl.BitwiseOr(const A, B: TIPv4AddressImpl): TIPv4AddressImpl;
begin
  result.FAddr.S_addr := A.FAddr.S_addr or B.FAddr.S_addr;
end;

class operator TIPv4AddressImpl.BitwiseXor(const A, B: TIPv4AddressImpl): TIPv4AddressImpl;
begin
  result.FAddr.S_addr := A.FAddr.S_addr xor B.FAddr.S_addr;
end;

class operator TIPv4AddressImpl.LogicalNot(const A: TIPv4AddressImpl): TIPv4AddressImpl;
begin
  result.FAddr.S_addr := A.FAddr.S_addr xor $ffffffff;
end;

{ TIPv6AddressImpl }

class function TIPv6AddressImpl.MaskBits(AValue: Cardinal; ASize: Cardinal): Cardinal;
var
  LCount: Cardinal;
begin
	if AValue > 0 then
  begin
		AValue := (AValue xor (AValue - 1)) shr 1;
    LCount := 0;
    while AValue > 0  do
    begin
      AValue := AValue shr 1;
      inc(LCount);
    end;
	end
	else
    LCount := ASize;
	result := ASize - LCount;
end;

class function TIPv6AddressImpl.Swap16(AValue: Word): Word;
begin
  result := (AValue shr 8) or
            ((AValue and $00FF) shl 8);
end;

procedure TIPv6AddressImpl.Create;
begin
  FScope := 0;
  memset(@FAddr, 0, sizeof(FAddr));
end;

constructor TIPv6AddressImpl.Create(AHostAddr: Pointer);
begin
  FScope := 0;
  memcpy(@FAddr, AHostAddr, sizeof(FAddr));
end;

constructor TIPv6AddressImpl.Create(AHostAddr: Pointer; AScope: Cardinal);
begin
  FScope := AScope;
  memcpy(@FAddr, AHostAddr, sizeof(FAddr));
end;

constructor TIPv6AddressImpl.Create(APrefix: Cardinal);
var
  i: Cardinal;
  w: Word;
begin
  FScope := 0;
	i := 0;
  while APrefix >= 16 do
  begin
    FAddr.Word[i] := $ffff;
    APrefix := APrefix - 16;
    inc(i);
  end;

	if APrefix > 0 then
	begin
    w := $ffff shr APrefix;
		FAddr.Word[i] := swap16(not w);
    inc(i);
	end;

	while i < 8 do
  begin
		FAddr.Word[i] := 0;
    inc(i);
  end;
end;

constructor TIPv6AddressImpl.Create(const AAddress: String);
var
  LInAddrv6: TIn6Addr;
  LScope: ULONG;
  LPort: USHORT;
  LReturn: LONG;
begin
	if AAddress.IsEmpty then
  begin
    Create;
    exit;
  end;

  LReturn := RtlIpv6StringToAddressExW(@AAddress[1], @LInAddrv6, @LScope, @LPort);
	if LReturn = 0 then
    Create(@LInAddrv6, LScope)
  else
    Create;
end;

function TIPv6AddressImpl.Addr: Pointer;
begin
	result := @FAddr;
end;

function TIPv6AddressImpl.NativeFamily: Integer;
begin
 	result := AF_INET6;
end;

function TIPv6AddressImpl.Clone: TIPv6AddressImpl;
begin
  result := TIPv6AddressImpl.Create(@FAddr);
end;

function TIPv6AddressImpl.Family: TAddressFamily;
begin
  result := TAddressFamily.IPv6;
end;

function TIPv6AddressImpl.IsBroadcast: Boolean;
begin
	result := false;
end;

function TIPv6AddressImpl.IsGlobalMC: Boolean;
begin
	result := (swap16(FAddr.Word[0]) and $FFEF) = $FF0F;
end;

function TIPv6AddressImpl.IsIPv4Compatible: Boolean;
begin
  result := (FAddr.Word[0] = 0) and (FAddr.Word[1] = 0) and (FAddr.Word[2] = 0) and (FAddr.Word[3] = 0) and (FAddr.Word[4] = 0) and (FAddr.Word[5] = 0);
end;

function TIPv6AddressImpl.IsIPv4Mapped: Boolean;
begin
	result := (FAddr.Word[0] = 0) and (FAddr.Word[1] = 0) and (FAddr.Word[2] = 0) and (FAddr.Word[3] = 0) and (FAddr.Word[4] = 0) and (swap16(FAddr.Word[5]) = $FFFF);
end;

function TIPv6AddressImpl.IsLinkLocal: Boolean;
begin
	result := (swap16(FAddr.Word[0]) and $FFE0) = $FE80;
end;

function TIPv6AddressImpl.IsLinkLocalMC: Boolean;
begin
	result := (swap16(FAddr.Word[0]) and $FFEF) = $FF02;
end;

function TIPv6AddressImpl.IsLoopback: Boolean;
begin
  result := (FAddr.Word[0] = 0) and (FAddr.Word[1] = 0) and (FAddr.Word[2] = 0) and
            (FAddr.Word[3] = 0) and (FAddr.Word[4] = 0) and (FAddr.Word[5] = 0) and
            (FAddr.Word[6] = 0) and (swap16(FAddr.Word[7]) = $0001);
end;

function TIPv6AddressImpl.IsMulticast: Boolean;
begin
	result := (swap16(FAddr.Word[0]) and $FFE0) = $FF00;
end;

function TIPv6AddressImpl.IsNodeLocalMC: Boolean;
begin
	result := (swap16(FAddr.Word[0]) and $FFEF) = $FF01;
end;

function TIPv6AddressImpl.IsOrgLocalMC: Boolean;
begin
	result := (swap16(FAddr.Word[0]) and $FFEF) = $FF08;
end;

function TIPv6AddressImpl.IsSiteLocal: Boolean;
begin
	result := ((swap16(FAddr.Word[0]) and $FFE0) = $FEC0) or
            ((swap16(FAddr.Word[0]) and $FF00) = $FC00);
end;

function TIPv6AddressImpl.IsSiteLocalMC: Boolean;
begin
	result := (swap16(FAddr.Word[0]) and $FFEF) = $FF05;
end;

function TIPv6AddressImpl.IsWellKnownMC: Boolean;
begin
	result := (swap16(FAddr.Word[0]) and $FFF0) = $FF00;
end;

function TIPv6AddressImpl.IsWildcard: Boolean;
begin
  result := (FAddr.Word[0] = 0) and (FAddr.Word[1] = 0) and (FAddr.Word[2] = 0) and
            (FAddr.Word[3] = 0) and (FAddr.Word[4] = 0) and (FAddr.Word[5] = 0) and
            (FAddr.Word[6] = 0) and (FAddr.Word[7] = 0);
end;

function TIPv6AddressImpl.Length: Cardinal;
begin
	result := sizeof(FAddr);
end;

function TIPv6AddressImpl.PrefixLength: Cardinal;
var
	LBits: Cardinal;
  LBitPos: Cardinal;
  LAddr: Word;
  i: Integer;
begin
  LBitPos := 128;
  i := 7;
  while i >= 0  do
  begin
		LAddr := swap16(FAddr.Word[i]);
    LBits := maskBits(LAddr, 16);
		if LBits > 0 then
      exit(LBitPos - (16 - LBits));

		LBitPos := LBitPos - 16;
    dec(i);
  end;

  result := 0;
end;

function TIPv6AddressImpl.Scope: Cardinal;
begin
  result := FScope;
end;

function TIPv6AddressImpl.ToString: String;
var
  LZeroSequence: Boolean;
  i: Integer;
  j: Integer;
begin
  result := '';
	if (isIPv4Compatible and (not isLoopback)) or isIPv4Mapped then
  begin
		if FAddr.Word[5] = 0 then
			result := '::'
		else
			result := '::ffff:';
		if FAddr.Byte[12] <> 0 then // only 0.0.0.0 can start with zero
    begin
			result := result + IntToStr(FAddr.Byte[12]);
      result := result + '.';
			result := result + IntToStr(FAddr.Byte[13]);
      result := result + '.';
			result := result + IntToStr(FAddr.Byte[14]);
      result := result + '.';
			result := result + IntToStr(FAddr.Byte[15]);
    end;
	end
	else
  begin
		i := 0;
    LZeroSequence := false;
		while i < 8 do
    begin
			if (not LZeroSequence) and (FAddr.Word[i] = 0) then
      begin
				j := i;
				while (j < 8) and (FAddr.Word[j] = 0) do
          inc(j);
				if j > i + 1 then
        begin
					i := j;
          result := result + ':';
					LZeroSequence := true;
				end;
			end;
			if i > 0 then
        result := result + ':';
			if i < 8 then
      begin
        result := result + IntToHex(swap16(FAddr.Word[i]), 1);
        inc(i);
      end;
    end;

		if FScope > 0 then
    begin
      result := result + '%';
      result := result + IntToStr(FScope);
    end;
		result := LowerCase(result);
	end;
end;

class operator TIPv6AddressImpl.Equal(const A, B: TIPv6AddressImpl): Boolean;
begin
  result := (A.FScope  = B.FScope) and CompareMem(A.addr, B.addr, A.length);
end;

class operator TIPv6AddressImpl.NotEqual(const A, B: TIPv6AddressImpl): Boolean;
begin
  result := not (A = B);
end;

class operator TIPv6AddressImpl.BitwiseAnd(const A, B: TIPv6AddressImpl): TIPv6AddressImpl;
begin
	if A.FScope  <> B.FScope  then
		raise InvalidArgumentException.Create('Scope ID of passed IPv6 address does not match with the source one.');

  result.FAddr.Word[0] := A.FAddr.Word[0] and B.FAddr.Word[0];
  result.FAddr.Word[1] := A.FAddr.Word[1] and B.FAddr.Word[1];
  result.FAddr.Word[2] := A.FAddr.Word[2] and B.FAddr.Word[2];
  result.FAddr.Word[3] := A.FAddr.Word[3] and B.FAddr.Word[3];
  result.FAddr.Word[4] := A.FAddr.Word[4] and B.FAddr.Word[4];
  result.FAddr.Word[5] := A.FAddr.Word[5] and B.FAddr.Word[5];
  result.FAddr.Word[6] := A.FAddr.Word[6] and B.FAddr.Word[6];
  result.FAddr.Word[7] := A.FAddr.Word[7] and B.FAddr.Word[7];
end;

class operator TIPv6AddressImpl.BitwiseOr(const A, B: TIPv6AddressImpl): TIPv6AddressImpl;
begin
	if A.FScope  <> B.FScope  then
		raise InvalidArgumentException.Create('Scope ID of passed IPv6 address does not match with the source one.');

  result.FAddr.Word[0] := A.FAddr.Word[0] or B.FAddr.Word[0];
  result.FAddr.Word[1] := A.FAddr.Word[1] or B.FAddr.Word[1];
  result.FAddr.Word[2] := A.FAddr.Word[2] or B.FAddr.Word[2];
  result.FAddr.Word[3] := A.FAddr.Word[3] or B.FAddr.Word[3];
  result.FAddr.Word[4] := A.FAddr.Word[4] or B.FAddr.Word[4];
  result.FAddr.Word[5] := A.FAddr.Word[5] or B.FAddr.Word[5];
  result.FAddr.Word[6] := A.FAddr.Word[6] or B.FAddr.Word[6];
  result.FAddr.Word[7] := A.FAddr.Word[7] or B.FAddr.Word[7];
end;

class operator TIPv6AddressImpl.BitwiseXor(const A, B: TIPv6AddressImpl): TIPv6AddressImpl;
begin
	if A.FScope <> B.FScope then
		raise InvalidArgumentException.Create('Scope ID of passed IPv6 address does not match with the source one.');

  result.FAddr.Word[0] := A.FAddr.Word[0] xor B.FAddr.Word[0];
  result.FAddr.Word[1] := A.FAddr.Word[1] xor B.FAddr.Word[1];
  result.FAddr.Word[2] := A.FAddr.Word[2] xor B.FAddr.Word[2];
  result.FAddr.Word[3] := A.FAddr.Word[3] xor B.FAddr.Word[3];
  result.FAddr.Word[4] := A.FAddr.Word[4] xor B.FAddr.Word[4];
  result.FAddr.Word[5] := A.FAddr.Word[5] xor B.FAddr.Word[5];
  result.FAddr.Word[6] := A.FAddr.Word[6] xor B.FAddr.Word[6];
  result.FAddr.Word[7] := A.FAddr.Word[7] xor B.FAddr.Word[7];
end;

class operator TIPv6AddressImpl.LogicalNot(const A: TIPv6AddressImpl): TIPv6AddressImpl;
begin
  result.FAddr.Word[0] := A.FAddr.Word[0] xor $ffff;
  result.FAddr.Word[1] := A.FAddr.Word[1] xor $ffff;
  result.FAddr.Word[2] := A.FAddr.Word[2] xor $ffff;
  result.FAddr.Word[3] := A.FAddr.Word[3] xor $ffff;
  result.FAddr.Word[4] := A.FAddr.Word[4] xor $ffff;
  result.FAddr.Word[5] := A.FAddr.Word[5] xor $ffff;
  result.FAddr.Word[6] := A.FAddr.Word[6] xor $ffff;
  result.FAddr.Word[7] := A.FAddr.Word[7] xor $ffff;
end;

end.
