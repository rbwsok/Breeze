unit Breeze.Buffer;

interface

uses System.Win.Crtl, System.Math, System.Classes, System.SysUtils, Breeze.Exception;

type
  // буфер пам€ти. реализует интерфейс потока, инкапсулирует TMemoryStream
  // отличи€:
  // - возможность отсутстви€ владени€ пам€тью
  // - передача владени€ пам€тью путем копировани€ только одного указател€
  TBuffer = class(TCustomMemoryStream)
  const
    MemoryDelta = 512; // Must be a power of 2
  private
    FCapacity: NativeInt;

    FOwnMemory: Boolean;

    function GetItem(AIndex: NativeUInt): Byte;
    procedure SetItem(AIndex: NativeUInt; AValue: Byte);
  protected
    procedure SetCapacity(NewCapacity: NativeInt);
    function Realloc(var NewCapacity: NativeInt): Pointer;

    procedure SetSize(const NewSize: Int64); override;
    procedure SetSize(NewSize: Longint); override;
  public
    constructor Create; overload;
    constructor Create(ALength: NativeUInt); overload;
    constructor Create(APtr: Pointer; ASize: NativeUInt; AOwn: Boolean = true); overload;
    constructor Create(const AValue: TBuffer); overload;
    constructor Create(const AValue: RawByteString; AOwn: Boolean = true); overload;

    destructor Destroy; override;

    procedure Assign(const AValue: TBuffer); overload;
    procedure Assign(APtr: Pointer; ASize: NativeUInt; AOwn: Boolean = true); overload;
    procedure Assign(const AValue: RawByteString); overload;

    procedure Clear;
    procedure LoadFromStream(Stream: TStream);
    procedure LoadFromFile(const FileName: string);

{$IF Sizeof(LongInt) <> Sizeof(NativeInt)}
    // дл€ отличи€ x64
    function Write(const Buffer; Count: Longint): Longint; override;
{$ENDIF Sizeof(LongInt) <> Sizeof(NativeInt)}
    function Write(const Buffer; Count: TNativeCount): TNativeCount; override;

    procedure Append(APtr: Pointer; ASize: NativeUInt); overload;
    procedure Append(const ABuffer: TBuffer); overload;
    procedure Append(const AValue: RawByteString); overload;
    procedure Append(AValue: Byte); overload;

    procedure ClearMemory;

    function IsEmpty: Boolean;

    procedure MakeOwn;

    function Equal(const AValue: TBuffer): Boolean;

    function AsRawByteString(AOffset: Integer = 0; ASize: Integer = -1): RawByteString;
    procedure FromRawByteString(const AValue: RawByteString);

    procedure MoveTo(AValue: TBuffer);

    property Capacity: NativeInt read FCapacity write SetCapacity;
    property Items[Index: NativeUInt]: Byte read GetItem write SetItem; default;
    property OwnMemory: Boolean read FOwnMemory;
  end;

implementation

uses System.RTLConsts;

{ Buffer }

constructor TBuffer.Create;
begin
  Create(0);
end;

constructor TBuffer.Create(ALength: NativeUInt);
begin
  inherited Create;

  FOwnMemory := true;

  SetSize(ALength);
end;

constructor TBuffer.Create(APtr: Pointer; ASize: NativeUInt; AOwn: Boolean);
begin
  inherited Create;

  FOwnMemory := AOwn;

  if FOwnMemory then
  begin
    SetSize(ASize);
    memcpy(Memory, APtr, ASize);
  end
  else
    SetPointer(APtr, ASize);
end;

procedure TBuffer.ClearMemory;
begin
  memset(Memory, 0, Size);
end;

constructor TBuffer.Create(const AValue: RawByteString; AOwn: Boolean = true);
begin
  Create(@AValue[1], Length(AValue), AOwn);
end;

constructor TBuffer.Create(const AValue: TBuffer);
begin
  Create(AValue.Memory, AValue.Size, AValue.FOwnMemory);
end;

destructor TBuffer.Destroy;
begin
  Clear;

  inherited
end;

procedure TBuffer.Assign(const AValue: TBuffer);
begin
  Assign(AValue.Memory, AValue.Size, AValue.FOwnMemory);
end;

procedure TBuffer.Assign(APtr: Pointer; ASize: NativeUInt; AOwn: Boolean);
begin
  Clear;

  FOwnMemory := AOwn;

  if FOwnMemory then
  begin
    SetSize(ASize);
    memcpy(Memory, APtr, ASize);
  end
  else
    SetPointer(APtr, ASize);
end;

procedure TBuffer.Clear;
begin
  if FOwnMemory then
    SetCapacity(0);
  SetPointer(nil, 0);
  Seek(0, soBeginning);
end;

function TBuffer.GetItem(AIndex: NativeUInt): Byte;
begin
  if AIndex >= Size then
    raise InvalidArgumentException.Create('index is out of range');

  result := PByte(Memory)[AIndex];
end;

function TBuffer.IsEmpty: Boolean;
begin
  result := GetSize = 0;
end;

procedure TBuffer.LoadFromFile(const FileName: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TBuffer.LoadFromStream(Stream: TStream);
var
  Count: Int64;
begin
  Stream.Position := 0;
  Count := Stream.Size;
  if FOwnMemory then
    SetSize(Count)
  else
    SetPointer(Memory, Count);
  if Count <> 0 then
    Stream.ReadBuffer(Memory^, Count);
end;

function TBuffer.Equal(const AValue: TBuffer): Boolean;
begin
  if self <> AValue then
  begin
    if Size = AValue.Size then
    begin
      if (Memory <> nil) and (AValue.Memory <> nil) and (memcmp(Memory, AValue.Memory, Size) = 0) then
        exit(true)
      else
        exit(Size = 0);
    end;
    exit(false);
  end;

  result := true;
end;

procedure TBuffer.MakeOwn;
var
  LPtr: Pointer;
  LSIze: Int64;
begin
  if FOwnMemory then
    exit;

  LPtr := Memory;
  LSIze := Size;

  SetPointer(nil, 0);
  FOwnMemory := true;
  SetSize(LSIze);

  memcpy(Memory, LPtr, LSIze);
end;

procedure TBuffer.MoveTo(AValue: TBuffer);
begin
  AValue.Clear;

  AValue.FCapacity := FCapacity;
  AValue.FOwnMemory := FOwnMemory;
  AValue.SetPointer(Memory, Size);
  AValue.Position := Position;

  SetPointer(nil, 0);
end;

function TBuffer.Realloc(var NewCapacity: NativeInt): Pointer;
begin
  if (NewCapacity > 0) and (NewCapacity <> Size) then
    NewCapacity := (NewCapacity + (MemoryDelta - 1)) and not(MemoryDelta - 1);
  result := Memory;
  if NewCapacity <> FCapacity then
  begin
    if NewCapacity = 0 then
    begin
      FreeMem(Memory);
      result := nil;
    end
    else
    begin
      if Capacity = 0 then
        GetMem(result, NewCapacity)
      else
        ReallocMem(result, NewCapacity);
      if result = nil then
        raise EStreamError.CreateRes(@SMemoryStreamError);
    end;
  end;
end;

procedure TBuffer.SetCapacity(NewCapacity: NativeInt);
begin
  SetPointer(Realloc(NewCapacity), Size);
  FCapacity := NewCapacity;
end;

procedure TBuffer.SetItem(AIndex: NativeUInt; AValue: Byte);
begin
  if AIndex >= Size then
    raise InvalidArgumentException.Create('index is out of range');

  PByte(Memory)[AIndex] := AValue;
end;

procedure TBuffer.SetSize(NewSize: Longint);
begin
  SetSize(Int64(NewSize));
end;

procedure TBuffer.SetSize(const NewSize: Int64);
var
  OldPosition: NativeInt;
begin
  OldPosition := Position;
  if FOwnMemory then
    SetCapacity(NewSize);
  SetPointer(Memory, NewSize);
  if OldPosition > NewSize then
    Seek(0, soEnd);
end;

function TBuffer.Write(const Buffer; Count: TNativeCount): TNativeCount;
var
  Pos: Int64;
begin
  if (Position >= 0) and (Count >= 0) then
  begin
    Pos := Position + Count;
    if Pos > 0 then
    begin
      if Pos > Size then
      begin
        if FOwnMemory then
        begin
          if Pos > FCapacity then
            SetCapacity(Pos);
        end;
        SetPointer(Memory, Pos);
      end;
      System.Move(Buffer, (PByte(Memory) + Position)^, Count);
      Position := Pos;
      result := Count;
      exit;
    end;
  end;
  result := 0;
end;

{$IF Sizeof(LongInt) <> Sizeof(NativeInt)}
function TBuffer.Write(const Buffer; Count: Longint): Longint;
begin
  Result := Longint(Write(Buffer, NativeInt(Count)));
end;
{$ENDIF Sizeof(LongInt) <> Sizeof(NativeInt)}

function TBuffer.AsRawByteString(AOffset: Integer; ASize: Integer): RawByteString;
begin
  if ASize < 0 then
    ASize := Size;

  SetLength(result, ASize);
  System.Move((PByte(Memory) + AOffset)^, result[1], ASize);
end;

procedure TBuffer.FromRawByteString(const AValue: RawByteString);
begin
  Position := 0;
  Assign(@AValue[1], Length(AValue), true);
end;

procedure TBuffer.Append(APtr: Pointer; ASize: NativeUInt);
begin
  Write(APtr, ASize);
end;

procedure TBuffer.Append(const ABuffer: TBuffer);
begin
  Write(ABuffer.Memory^, ABuffer.Size);
end;

procedure TBuffer.Append(const AValue: RawByteString);
begin
  Write(AValue[1], Length(AValue));
end;

procedure TBuffer.Append(AValue: Byte);
begin
  Write(AValue, 1);
end;

procedure TBuffer.Assign(const AValue: RawByteString);
begin
  Assign(@AValue[1], Length(AValue), true);
end;

end.
