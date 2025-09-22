unit Breeze.ByteOrder;

interface

type

{.$define ARCH_BIG_ENDIAN}

  TByteOrder = class
  public
	  class function FlipBytes(AValue: Int8): Int8; overload; inline;
	  class function FlipBytes(AValue: UInt8): UInt8; overload; inline;
	  class function FlipBytes(AValue: Int16): Int16; overload; inline;
	  class function FlipBytes(AValue: UInt16): UInt16; overload; inline;
	  class function FlipBytes(AValue: Int32): Int32; overload; inline;
	  class function FlipBytes(AValue: UInt32): UInt32; overload; inline;
	  class function FlipBytes(AValue: Int64): Int64; overload; inline;
	  class function FlipBytes(AValue: UInt64): UInt64; overload; inline;
	  class function FlipBytes(AValue: Single): Single; overload; inline;
	  class function FlipBytes(AValue: Double): Double; overload; inline;

	  class function toBigEndian(AValue: Int8): Int8; overload; inline;
	  class function toBigEndian(AValue: UInt8): UInt8; overload; inline;
	  class function toBigEndian(AValue: Int16): Int16; overload; inline;
	  class function toBigEndian(AValue: UInt16): UInt16; overload; inline;
	  class function toBigEndian(AValue: Int32): Int32; overload; inline;
	  class function toBigEndian(AValue: UInt32): UInt32; overload; inline;
	  class function toBigEndian(AValue: Int64): Int64; overload; inline;
	  class function toBigEndian(AValue: UInt64): UInt64; overload; inline;
	  class function toBigEndian(AValue: Single): Single; overload; inline;
	  class function toBigEndian(AValue: Double): Double; overload; inline;

	  class function fromBigEndian(AValue: Int8): Int8; overload; inline;
	  class function fromBigEndian(AValue: UInt8): UInt8; overload; inline;
	  class function fromBigEndian(AValue: Int16): Int16; overload; inline;
	  class function fromBigEndian(AValue: UInt16): UInt16; overload; inline;
	  class function fromBigEndian(AValue: Int32): Int32; overload; inline;
	  class function fromBigEndian(AValue: UInt32): UInt32; overload; inline;
	  class function fromBigEndian(AValue: Int64): Int64; overload; inline;
	  class function fromBigEndian(AValue: UInt64): UInt64; overload; inline;
	  class function fromBigEndian(AValue: Single): Single; overload; inline;
	  class function fromBigEndian(AValue: Double): Double; overload; inline;

	  class function toLittleEndian(AValue: Int8): Int8; overload; inline;
	  class function toLittleEndian(AValue: UInt8): UInt8; overload; inline;
	  class function toLittleEndian(AValue: Int16): Int16; overload; inline;
	  class function toLittleEndian(AValue: UInt16): UInt16; overload; inline;
	  class function toLittleEndian(AValue: Int32): Int32; overload; inline;
	  class function toLittleEndian(AValue: UInt32): UInt32; overload; inline;
	  class function toLittleEndian(AValue: Int64): Int64; overload; inline;
	  class function toLittleEndian(AValue: UInt64): UInt64; overload; inline;
	  class function toLittleEndian(AValue: Single): Single; overload; inline;
	  class function toLittleEndian(AValue: Double): Double; overload; inline;

	  class function fromLittleEndian(AValue: Int8): Int8; overload; inline;
	  class function fromLittleEndian(AValue: UInt8): UInt8; overload; inline;
	  class function fromLittleEndian(AValue: Int16): Int16; overload; inline;
	  class function fromLittleEndian(AValue: UInt16): UInt16; overload; inline;
	  class function fromLittleEndian(AValue: Int32): Int32; overload; inline;
	  class function fromLittleEndian(AValue: UInt32): UInt32; overload; inline;
	  class function fromLittleEndian(AValue: Int64): Int64; overload; inline;
	  class function fromLittleEndian(AValue: UInt64): UInt64; overload; inline;
	  class function fromLittleEndian(AValue: Single): Single; overload; inline;
	  class function fromLittleEndian(AValue: Double): Double; overload; inline;

	  class function toNetwork(AValue: Int8): Int8; overload; inline;
	  class function toNetwork(AValue: UInt8): UInt8; overload; inline;
	  class function toNetwork(AValue: Int16): Int16; overload; inline;
	  class function toNetwork(AValue: UInt16): UInt16; overload; inline;
	  class function toNetwork(AValue: Int32): Int32; overload; inline;
	  class function toNetwork(AValue: UInt32): UInt32; overload; inline;
	  class function toNetwork(AValue: Int64): Int64; overload; inline;
	  class function toNetwork(AValue: UInt64): UInt64; overload; inline;
	  class function toNetwork(AValue: Single): Single; overload; inline;
	  class function toNetwork(AValue: Double): Double; overload; inline;

	  class function fromNetwork(AValue: Int8): Int8; overload; inline;
	  class function fromNetwork(AValue: UInt8): UInt8; overload; inline;
	  class function fromNetwork(AValue: Int16): Int16; overload; inline;
	  class function fromNetwork(AValue: UInt16): UInt16; overload; inline;
	  class function fromNetwork(AValue: Int32): Int32; overload; inline;
	  class function fromNetwork(AValue: UInt32): UInt32; overload; inline;
	  class function fromNetwork(AValue: Int64): Int64; overload; inline;
	  class function fromNetwork(AValue: UInt64): UInt64; overload; inline;
	  class function fromNetwork(AValue: Single): Single; overload; inline;
	  class function fromNetwork(AValue: Double): Double; overload; inline;
  end;

implementation

{ TByteOrder }

class function TByteOrder.FlipBytes(AValue: Int32): Int32;
begin
	result := Int32(flipBytes(UInt32(AValue)));
end;

class function TByteOrder.FlipBytes(AValue: UInt16): UInt16;
begin
  result := ((AValue shr 8) and $00FF) or ((AValue shl 8) and $FF00);
end;

class function TByteOrder.FlipBytes(AValue: Int16): Int16;
begin
	result := Int16(flipBytes(UInt16(AValue)));
end;

class function TByteOrder.FlipBytes(AValue: UInt8): UInt8;
begin
  result := AValue;
end;

class function TByteOrder.FlipBytes(AValue: Int8): Int8;
begin
  result := AValue;
end;

class function TByteOrder.FlipBytes(AValue: Double): Double;
var
  LPtr: ^UInt64;
  LPtrResult: ^UInt64;
begin
  LPtr := @AValue;
  LPtrResult := @result;
  LPtrResult^ := FlipBytes(LPtr^);
end;

class function TByteOrder.FlipBytes(AValue: Single): Single;
var
  LPtr: ^UInt32;
  LPtrResult: ^UInt32;
begin
  LPtr := @AValue;
  LPtrResult := @result;
  LPtrResult^ := FlipBytes(LPtr^);
end;

class function TByteOrder.FlipBytes(AValue: UInt64): UInt64;
var
  LHi: UInt32;
  LLo: UInt32;
begin
	LHi := UInt32(AValue shr 32);
  LLo := UInt32(AValue and $FFFFFFFF);
	result := UInt64(flipBytes(LHi)) or (UInt64(flipBytes(LLo)) shl 32);
end;

class function TByteOrder.FlipBytes(AValue: Int64): Int64;
begin
	result := Int64(flipBytes(UInt64(AValue)));
end;

class function TByteOrder.FlipBytes(AValue: UInt32): UInt32;
begin
	result := ((AValue shr 24) and $000000FF) or ((AValue shr 8) and $0000FF00)
	     or ((AValue shl 8) and $00FF0000) or ((AValue shl 24) and $FF000000);
end;

class function TByteOrder.toBigEndian(AValue: Int32): Int32;
begin
{$ifdef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.toBigEndian(AValue: UInt16): UInt16;
begin
{$ifdef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.toBigEndian(AValue: Int16): Int16;
begin
{$ifdef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.toBigEndian(AValue: UInt8): UInt8;
begin
{$ifdef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.toBigEndian(AValue: Int8): Int8;
begin
{$ifdef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.toBigEndian(AValue: Double): Double;
begin
{$ifdef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.toBigEndian(AValue: Single): Single;
begin
{$ifdef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.toBigEndian(AValue: UInt64): UInt64;
begin
{$ifdef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.toBigEndian(AValue: Int64): Int64;
begin
{$ifdef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.toBigEndian(AValue: UInt32): UInt32;
begin
{$ifdef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.fromBigEndian(AValue: Int32): Int32;
begin
{$ifdef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.fromBigEndian(AValue: UInt16): UInt16;
begin
{$ifdef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.fromBigEndian(AValue: Int16): Int16;
begin
{$ifdef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.fromBigEndian(AValue: UInt8): UInt8;
begin
{$ifdef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.fromBigEndian(AValue: Int8): Int8;
begin
{$ifdef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.fromBigEndian(AValue: Double): Double;
begin
{$ifdef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.fromBigEndian(AValue: Single): Single;
begin
{$ifdef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.fromBigEndian(AValue: UInt64): UInt64;
begin
{$ifdef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.fromBigEndian(AValue: Int64): Int64;
begin
{$ifdef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.fromBigEndian(AValue: UInt32): UInt32;
begin
{$ifdef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.toLittleEndian(AValue: Int32): Int32;
begin
{$ifndef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.toLittleEndian(AValue: UInt16): UInt16;
begin
{$ifndef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.toLittleEndian(AValue: Int16): Int16;
begin
{$ifndef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.toLittleEndian(AValue: UInt8): UInt8;
begin
{$ifndef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.toLittleEndian(AValue: Int8): Int8;
begin
{$ifndef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.toLittleEndian(AValue: Double): Double;
begin
{$ifndef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.toLittleEndian(AValue: Single): Single;
begin
{$ifndef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.toLittleEndian(AValue: UInt64): UInt64;
begin
{$ifndef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.toLittleEndian(AValue: Int64): Int64;
begin
{$ifndef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.toLittleEndian(AValue: UInt32): UInt32;
begin
{$ifndef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.fromLittleEndian(AValue: Int32): Int32;
begin
{$ifndef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.fromLittleEndian(AValue: UInt16): UInt16;
begin
{$ifndef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.fromLittleEndian(AValue: Int16): Int16;
begin
{$ifndef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.fromLittleEndian(AValue: UInt8): UInt8;
begin
{$ifndef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.fromLittleEndian(AValue: Int8): Int8;
begin
{$ifndef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.fromLittleEndian(AValue: Double): Double;
begin
{$ifndef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.fromLittleEndian(AValue: Single): Single;
begin
{$ifndef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.fromLittleEndian(AValue: UInt64): UInt64;
begin
{$ifndef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.fromLittleEndian(AValue: Int64): Int64;
begin
{$ifndef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.fromLittleEndian(AValue: UInt32): UInt32;
begin
{$ifndef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.toNetwork(AValue: Int32): Int32;
begin
{$ifdef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.toNetwork(AValue: UInt16): UInt16;
begin
{$ifdef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.toNetwork(AValue: Int16): Int16;
begin
{$ifdef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.toNetwork(AValue: UInt8): UInt8;
begin
{$ifdef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.toNetwork(AValue: Int8): Int8;
begin
{$ifdef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.toNetwork(AValue: Double): Double;
begin
{$ifdef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.toNetwork(AValue: Single): Single;
begin
{$ifdef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.toNetwork(AValue: UInt64): UInt64;
begin
{$ifdef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.toNetwork(AValue: Int64): Int64;
begin
{$ifdef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.toNetwork(AValue: UInt32): UInt32;
begin
{$ifdef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.fromNetwork(AValue: Int32): Int32;
begin
{$ifdef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.fromNetwork(AValue: UInt16): UInt16;
begin
{$ifdef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.fromNetwork(AValue: Int16): Int16;
begin
{$ifdef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.fromNetwork(AValue: UInt8): UInt8;
begin
{$ifdef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.fromNetwork(AValue: Int8): Int8;
begin
{$ifdef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.fromNetwork(AValue: Double): Double;
begin
{$ifdef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.fromNetwork(AValue: Single): Single;
begin
{$ifdef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.fromNetwork(AValue: UInt64): UInt64;
begin
{$ifdef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.fromNetwork(AValue: Int64): Int64;
begin
{$ifdef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

class function TByteOrder.fromNetwork(AValue: UInt32): UInt32;
begin
{$ifdef ARCH_BIG_ENDIAN}
  result := AValue;
{$else}
  result := FlipBytes(AValue);
{$endif}
end;

end.

