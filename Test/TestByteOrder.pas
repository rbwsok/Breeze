unit TestByteOrder;

interface

uses System.SysUtils, System.Generics.Collections, System.win.Crtl, TestUtil;

type

{.$define ARCH_BIG_ENDIAN}

  TTestByteOrder = class
    procedure testByteOrderFlip;
    procedure testByteOrderBigEndian;
    procedure testByteOrderLittleEndian;
    procedure testByteOrderNetwork;
  public
    class procedure Test;
  end;

implementation

uses Breeze.ByteOrder;

class procedure TTestByteOrder.Test;
var
  testclass: TTestByteOrder;
begin
  TRTest.Comment('=============================================');
  TRTest.Comment('= TTestByteOrder');
  TRTest.Comment('=============================================');

  testclass := TTestByteOrder.Create;
  try
    testclass.testByteOrderFlip;
    testclass.testByteOrderBigEndian;
    testclass.testByteOrderLittleEndian;
    testclass.testByteOrderNetwork;
  finally
    testclass.Free;
  end;
end;

procedure TTestByteOrder.testByteOrderBigEndian;
var
  n8, f8: Int8;
  un8, uf8: UInt8;
  n16, f16: Int16;
  un16, uf16: UInt16;
  n32, f32: Int32;
  un32, uf32: UInt32;
  n64, f64: Int64;
  un64, uf64: UInt64;
begin
	//
	// all systems
	//
  n8 := 4;
	f8 := TByteOrder.toBigEndian(n8);
	assertTrue('testByteOrderBigEndian 1', n8 = f8);

  un8 := 4;
	uf8 := TByteOrder.toBigEndian(un8);
	assertTrue('testByteOrderBigEndian 2', un8 = uf8);

  n8 := 4;
	f8 := TByteOrder.fromBigEndian(n8);
	assertTrue('testByteOrderBigEndian 3', n8 = f8);

  un8 := 4;
	uf8 := TByteOrder.fromBigEndian(un8);
	assertTrue('testByteOrderBigEndian 4', un8 = uf8);

{$ifdef ARCH_BIG_ENDIAN}
	//
	// big-endian systems
	//
  n16 := 4;
	f16 := TByteOrder.toBigEndian(n16);
	assertTrue('testByteOrderBigEndian 5', n16 = f16);

  un16 := 4;
	uf16 := TByteOrder.toBigEndian(un16);
	assertTrue('testByteOrderBigEndian 6', un16 = uf16);

  n32 := 4;
	f32 := TByteOrder.toBigEndian(n32);
	assertTrue('testByteOrderBigEndian 7', n32 = f32);

  un32 := 4;
	uf32 := TByteOrder.toBigEndian(un32);
	assertTrue('testByteOrderBigEndian 8', un32 = uf32);

  n64 := 4;
	f64 := TByteOrder.toBigEndian(n64);
	assertTrue('testByteOrderBigEndian 7', n64 = f64);

  un64 := 4;
	uf64 := TByteOrder.toBigEndian(un64);
	assertTrue('testByteOrderBigEndian 8', un64 = uf64);

  n16 := 4;
	f16 := TByteOrder.fromBigEndian(n16);
	assertTrue('testByteOrderBigEndian 9', n16 = f16);

  un16 := 4;
	uf16 := TByteOrder.fromBigEndian(un16);
	assertTrue('testByteOrderBigEndian 10', un16 = uf16);

  n32 := 4;
	f32 := TByteOrder.fromBigEndian(n32);
	assertTrue('testByteOrderBigEndian 11', n32 = f32);

  un32 := 4;
	uf32 := TByteOrder.fromBigEndian(un32);
	assertTrue('testByteOrderBigEndian 12', un32 = uf32);

  n64 := 4;
	f64 := TByteOrder.fromBigEndian(n64);
	assertTrue('testByteOrderBigEndian 13', n64 = f64);

  un64 := 4;
	uf64 := TByteOrder.fromBigEndian(un64);
	assertTrue('testByteOrderBigEndian 14', un64 = uf64);
{$else}
	//
	// little-endian systems
	//
  n16 := 4;
	f16 := TByteOrder.toBigEndian(n16);
	assertTrue('testByteOrderBigEndian 5', n16 <> f16);
	f16 := TByteOrder.toBigEndian(f16);
	assertTrue('testByteOrderBigEndian 6', n16 = f16);

  un16 := 4;
	uf16 := TByteOrder.toBigEndian(un16);
	assertTrue('testByteOrderBigEndian 7', un16 <> uf16);
	uf16 := TByteOrder.toBigEndian(uf16);
	assertTrue('testByteOrderBigEndian 8', un16 = uf16);

  n32 := 4;
	f32 := TByteOrder.toBigEndian(n32);
	assertTrue('testByteOrderBigEndian 9', n32 <> f32);
	f32 := TByteOrder.toBigEndian(f32);
	assertTrue('testByteOrderBigEndian 10', n32 = f32);

  un32 := 4;
	uf32 := TByteOrder.toBigEndian(un32);
	assertTrue('testByteOrderBigEndian 11', un32 <> uf32);
	uf32 := TByteOrder.toBigEndian(uf32);
	assertTrue('testByteOrderBigEndian 12', un32 = uf32);

  n64 := 4;
	f64 := TByteOrder.toBigEndian(n64);
	assertTrue('testByteOrderBigEndian 13', n64 <> f64);
	f64 := TByteOrder.toBigEndian(f64);
	assertTrue('testByteOrderBigEndian 14', n64 = f64);

  un64 := 4;
	uf64 := TByteOrder.toBigEndian(un64);
	assertTrue('testByteOrderBigEndian 15', un64 <> uf64);
	uf64 := TByteOrder.toBigEndian(uf64);
	assertTrue('testByteOrderBigEndian 16', un64 = uf64);

  n16 := 4;
	f16 := TByteOrder.fromBigEndian(n16);
	assertTrue('testByteOrderBigEndian 17', n16 <> f16);
	f16 := TByteOrder.fromBigEndian(f16);
	assertTrue('testByteOrderBigEndian 18', n16 = f16);

  un16 := 4;
	uf16 := TByteOrder.fromBigEndian(un16);
	assertTrue('testByteOrderBigEndian 19', un16 <> uf16);
	uf16 := TByteOrder.fromBigEndian(uf16);
	assertTrue('testByteOrderBigEndian 20', un16 = uf16);

  n32 := 4;
	f32 := TByteOrder.fromBigEndian(n32);
	assertTrue('testByteOrderBigEndian 21', n32 <> f32);
	f32 := TByteOrder.fromBigEndian(f32);
	assertTrue('testByteOrderBigEndian 22', n32 = f32);

  un32 := 4;
	uf32 := TByteOrder.fromBigEndian(un32);
	assertTrue('testByteOrderBigEndian 23', un32 <> uf32);
	uf32 := TByteOrder.fromBigEndian(uf32);
	assertTrue('testByteOrderBigEndian 24', un32 = uf32);

  n64 := 4;
	f64 := TByteOrder.fromBigEndian(n64);
	assertTrue('testByteOrderBigEndian 25', n64 <> f64);
	f64 := TByteOrder.fromBigEndian(f64);
	assertTrue('testByteOrderBigEndian 26', n64 = f64);

  un64 := 4;
	uf64 := TByteOrder.fromBigEndian(un64);
	assertTrue('testByteOrderBigEndian 27', un64 <> uf64);
	uf64 := TByteOrder.fromBigEndian(uf64);
	assertTrue('testByteOrderBigEndian 28', un64 = uf64);

{$endif}

end;

procedure TTestByteOrder.testByteOrderFlip;
var
  n8, f8: Int8;
  un8, uf8: UInt8;
  n16, f16: Int16;
  un16, uf16: UInt16;
  n32, f32: Int32;
  un32, uf32: UInt32;
  n64, f64: Int64;
  un64, uf64: UInt64;
  nf, ff: Single;
  nd, dd: Double;
begin
  n8 := -5;
	f8 := TByteOrder.FlipBytes(n8);
	assertTrue('testByteOrderFlip 1', n8 = f8);

  un8 := $ab;
	uf8 := TByteOrder.FlipBytes(un8);
	assertTrue('testByteOrderFlip 2', un8 = uf8);

  n16 := $7129;
	f16 := TByteOrder.FlipBytes(n16);
	assertTrue('testByteOrderFlip 3', f16 = $2971);
  f16 := TByteOrder.FlipBytes(f16);
	assertTrue('testByteOrderFlip 4', f16 = n16);

  un16 := $aabb;
	uf16 := TByteOrder.FlipBytes(un16);
	assertTrue('testByteOrderFlip 5', uf16 = $bbaa);
  uf16 := TByteOrder.FlipBytes(uf16);
	assertTrue('testByteOrderFlip 6', uf16 = un16);

  n32 := $0abbcc6d;
	f32 := TByteOrder.FlipBytes(n32);
	assertTrue('testByteOrderFlip 7', f32 = $6dccbb0a);
  f32 := TByteOrder.FlipBytes(f32);
	assertTrue('testByteOrderFlip 8', f32 = n32);

  un32 := $aabbccdd;
	uf32 := TByteOrder.FlipBytes(un32);
	assertTrue('testByteOrderFlip 9', uf32 = $ddccbbaa);
  uf32 := TByteOrder.FlipBytes(uf32);
	assertTrue('testByteOrderFlip 10', uf32 = un32);

  n64 := $7899AABBCCDDEE4F;
	f64 := TByteOrder.FlipBytes(n64);
	assertTrue('testByteOrderFlip 11', f64 = $4feeddccbbaa9978);
  f64 := TByteOrder.FlipBytes(f64);
	assertTrue('testByteOrderFlip 12', f64 = n64);

  un64 := $8899AABBCCDDEEFF;
	uf64 := TByteOrder.FlipBytes(un64);
	assertTrue('testByteOrderFlip 13', uf64 = $ffeeddccbbaa9988);
  uf64 := TByteOrder.FlipBytes(uf64);
	assertTrue('testByteOrderFlip 14', uf64 = un64);

  nf := 19244312.66;
	ff := TByteOrder.FlipBytes(nf);
  ff := TByteOrder.FlipBytes(ff);
	assertTrue('testByteOrderFlip 15', nf = ff);

  nd := 19244312342341232.66;
	dd := TByteOrder.FlipBytes(nd);
  dd := TByteOrder.FlipBytes(dd);
	assertTrue('testByteOrderFlip 16', nd = dd);
end;


procedure TTestByteOrder.testByteOrderLittleEndian;
var
  n8, f8: Int8;
  un8, uf8: UInt8;
  n16, f16: Int16;
  un16, uf16: UInt16;
  n32, f32: Int32;
  un32, uf32: UInt32;
  n64, f64: Int64;
  un64, uf64: UInt64;begin
	//
	// all systems
	//
  n8 := 4;
	f8 := TByteOrder.toLittleEndian(n8);
	assertTrue('testByteOrderLittleEndian 1', n8 = f8);

  un8 := 4;
	uf8 := TByteOrder.toLittleEndian(un8);
	assertTrue('testByteOrderLittleEndian 2', un8 = uf8);

  n8 := 4;
	f8 := TByteOrder.fromLittleEndian(n8);
	assertTrue('testByteOrderLittleEndian 3', n8 = f8);

  un8 := 4;
	uf8 := TByteOrder.fromLittleEndian(un8);
	assertTrue('testByteOrderLittleEndian 4', un8 = uf8);

{$ifndef ARCH_BIG_ENDIAN}
	//
	// little-endian systems
	//
  n16 := 4;
	f16 := TByteOrder.toLittleEndian(n16);
	assertTrue('testByteOrderLittleEndian 5', n16 = f16);

  un16 := 4;
	uf16 := TByteOrder.toLittleEndian(un16);
	assertTrue('testByteOrderLittleEndian 6', un16 = uf16);

  n32 := 4;
	f32 := TByteOrder.toLittleEndian(n32);
	assertTrue('testByteOrderLittleEndian 7', n32 = f32);

  un32 := 4;
	uf32 := TByteOrder.toLittleEndian(un32);
	assertTrue('testByteOrderLittleEndian 8', un32 = uf32);

  n64 := 4;
	f64 := TByteOrder.toLittleEndian(n64);
	assertTrue('testByteOrderLittleEndian 7', n64 = f64);

  un64 := 4;
	uf64 := TByteOrder.toLittleEndian(un64);
	assertTrue('testByteOrderLittleEndian 8', un64 = uf64);

  n16 := 4;
	f16 := TByteOrder.fromLittleEndian(n16);
	assertTrue('testByteOrderLittleEndian 9', n16 = f16);

  un16 := 4;
	uf16 := TByteOrder.fromLittleEndian(un16);
	assertTrue('testByteOrderLittleEndian 10', un16 = uf16);

  n32 := 4;
	f32 := TByteOrder.fromLittleEndian(n32);
	assertTrue('testByteOrderLittleEndian 11', n32 = f32);

  un32 := 4;
	uf32 := TByteOrder.fromLittleEndian(un32);
	assertTrue('testByteOrderLittleEndian 12', un32 = uf32);

  n64 := 4;
	f64 := TByteOrder.fromLittleEndian(n64);
	assertTrue('testByteOrderLittleEndian 13', n64 = f64);

  un64 := 4;
	uf64 := TByteOrder.fromLittleEndian(un64);
	assertTrue('testByteOrderLittleEndian 14', un64 = uf64);
{$else}
	//
	// big-endian systems
	//
  n16 := 4;
	f16 := TByteOrder.toLittleEndian(n16);
	assertTrue('testByteOrderLittleEndian 5', n16 <> f16);
	f16 := TByteOrder.toLittleEndian(f16);
	assertTrue('testByteOrderLittleEndian 6', n16 = f16);

  un16 := 4;
	uf16 := TByteOrder.toLittleEndian(un16);
	assertTrue('testByteOrderLittleEndian 7', un16 <> uf16);
	uf16 := TByteOrder.toLittleEndian(uf16);
	assertTrue('testByteOrderLittleEndian 8', un16 = uf16);

  n32 := 4;
	f32 := TByteOrder.toLittleEndian(n32);
	assertTrue('testByteOrderLittleEndian 9', n32 <> f32);
	f32 := TByteOrder.toLittleEndian(f32);
	assertTrue('testByteOrderLittleEndian 10', n32 = f32);

  un32 := 4;
	uf32 := TByteOrder.toLittleEndian(un32);
	assertTrue('testByteOrderLittleEndian 11', un32 <> uf32);
	uf32 := TByteOrder.toLittleEndian(uf32);
	assertTrue('testByteOrderLittleEndian 12', un32 = uf32);

  n64 := 4;
	f64 := TByteOrder.toLittleEndian(n64);
	assertTrue('testByteOrderLittleEndian 13', n64 <> f64);
	f64 := TByteOrder.toLittleEndian(f64);
	assertTrue('testByteOrderLittleEndian 14', n64 = f64);

  un64 := 4;
	uf64 := TByteOrder.toLittleEndian(un64);
	assertTrue('testByteOrderLittleEndian 15', un64 <> uf64);
	uf64 := TByteOrder.toLittleEndian(uf64);
	assertTrue('testByteOrderLittleEndian 16', un64 = uf64);

  n16 := 4;
	f16 := TByteOrder.fromLittleEndian(n16);
	assertTrue('testByteOrderLittleEndian 17', n16 <> f16);
	f16 := TByteOrder.fromLittleEndian(f16);
	assertTrue('testByteOrderLittleEndian 18', n16 = f16);

  un16 := 4;
	uf16 := TByteOrder.fromLittleEndian(un16);
	assertTrue('testByteOrderLittleEndian 19', un16 <> uf16);
	uf16 := TByteOrder.fromLittleEndian(uf16);
	assertTrue('testByteOrderLittleEndian 20', un16 = uf16);

  n32 := 4;
	f32 := TByteOrder.fromLittleEndian(n32);
	assertTrue('testByteOrderLittleEndian 21', n32 <> f32);
	f32 := TByteOrder.fromLittleEndian(f32);
	assertTrue('testByteOrderLittleEndian 22', n32 = f32);

  un32 := 4;
	uf32 := TByteOrder.fromLittleEndian(un32);
	assertTrue('testByteOrderLittleEndian 23', un32 <> uf32);
	uf32 := TByteOrder.fromLittleEndian(uf32);
	assertTrue('testByteOrderLittleEndian 24', un32 = uf32);

  n64 := 4;
	f64 := TByteOrder.fromLittleEndian(n64);
	assertTrue('testByteOrderLittleEndian 25', n64 <> f64);
	f64 := TByteOrder.fromLittleEndian(f64);
	assertTrue('testByteOrderLittleEndian 26', n64 = f64);

  un64 := 4;
	uf64 := TByteOrder.fromLittleEndian(un64);
	assertTrue('testByteOrderLittleEndian 27', un64 <> uf64);
	uf64 := TByteOrder.fromLittleEndian(uf64);
	assertTrue('testByteOrderLittleEndian 28', un64 = uf64);

{$endif}

end;

procedure TTestByteOrder.testByteOrderNetwork;
var
  n8, f8: Int8;
  un8, uf8: UInt8;
  n16, f16: Int16;
  un16, uf16: UInt16;
  n32, f32: Int32;
  un32, uf32: UInt32;
  n64, f64: Int64;
  un64, uf64: UInt64;
begin
	//
	// all systems
	//
  n8 := 4;
	f8 := TByteOrder.toBigEndian(n8);
	assertTrue('testByteOrderNetwork 1', n8 = f8);

  un8 := 4;
	uf8 := TByteOrder.toBigEndian(un8);
	assertTrue('testByteOrderNetwork 2', un8 = uf8);

  n8 := 4;
	f8 := TByteOrder.fromBigEndian(n8);
	assertTrue('testByteOrderNetwork 3', n8 = f8);

  un8 := 4;
	uf8 := TByteOrder.fromBigEndian(un8);
	assertTrue('testByteOrderNetwork 4', un8 = uf8);

{$ifdef ARCH_BIG_ENDIAN}
	//
	// big-endian systems
	//
  n16 := 4;
	f16 := TByteOrder.toBigEndian(n16);
	assertTrue('testByteOrderNetwork 5', n16 = f16);

  un16 := 4;
	uf16 := TByteOrder.toBigEndian(un16);
	assertTrue('testByteOrderNetwork 6', un16 = uf16);

  n32 := 4;
	f32 := TByteOrder.toBigEndian(n32);
	assertTrue('testByteOrderNetwork 7', n32 = f32);

  un32 := 4;
	uf32 := TByteOrder.toBigEndian(un32);
	assertTrue('testByteOrderNetwork 8', un32 = uf32);

  n64 := 4;
	f64 := TByteOrder.toBigEndian(n64);
	assertTrue('testByteOrderNetwork 7', n64 = f64);

  un64 := 4;
	uf64 := TByteOrder.toBigEndian(un64);
	assertTrue('testByteOrderNetwork 8', un64 = uf64);

  n16 := 4;
	f16 := TByteOrder.fromBigEndian(n16);
	assertTrue('testByteOrderNetwork 9', n16 = f16);

  un16 := 4;
	uf16 := TByteOrder.fromBigEndian(un16);
	assertTrue('testByteOrderNetwork 10', un16 = uf16);

  n32 := 4;
	f32 := TByteOrder.fromBigEndian(n32);
	assertTrue('testByteOrderNetwork 11', n32 = f32);

  un32 := 4;
	uf32 := TByteOrder.fromBigEndian(un32);
	assertTrue('testByteOrderNetwork 12', un32 = uf32);

  n64 := 4;
	f64 := TByteOrder.fromBigEndian(n64);
	assertTrue('testByteOrderNetwork 13', n64 = f64);

  un64 := 4;
	uf64 := TByteOrder.fromBigEndian(un64);
	assertTrue('testByteOrderNetwork 14', un64 = uf64);
{$else}
	//
	// little-endian systems
	//
  n16 := 4;
	f16 := TByteOrder.toBigEndian(n16);
	assertTrue('testByteOrderNetwork 5', n16 <> f16);
	f16 := TByteOrder.toBigEndian(f16);
	assertTrue('testByteOrderNetwork 6', n16 = f16);

  un16 := 4;
	uf16 := TByteOrder.toBigEndian(un16);
	assertTrue('testByteOrderNetwork 7', un16 <> uf16);
	uf16 := TByteOrder.toBigEndian(uf16);
	assertTrue('testByteOrderNetwork 8', un16 = uf16);

  n32 := 4;
	f32 := TByteOrder.toBigEndian(n32);
	assertTrue('testByteOrderNetwork 9', n32 <> f32);
	f32 := TByteOrder.toBigEndian(f32);
	assertTrue('testByteOrderNetwork 10', n32 = f32);

  un32 := 4;
	uf32 := TByteOrder.toBigEndian(un32);
	assertTrue('testByteOrderNetwork 11', un32 <> uf32);
	uf32 := TByteOrder.toBigEndian(uf32);
	assertTrue('testByteOrderNetwork 12', un32 = uf32);

  n64 := 4;
	f64 := TByteOrder.toBigEndian(n64);
	assertTrue('testByteOrderNetwork 13', n64 <> f64);
	f64 := TByteOrder.toBigEndian(f64);
	assertTrue('testByteOrderNetwork 14', n64 = f64);

  un64 := 4;
	uf64 := TByteOrder.toBigEndian(un64);
	assertTrue('testByteOrderNetwork 15', un64 <> uf64);
	uf64 := TByteOrder.toBigEndian(uf64);
	assertTrue('testByteOrderNetwork 16', un64 = uf64);

  n16 := 4;
	f16 := TByteOrder.fromBigEndian(n16);
	assertTrue('testByteOrderNetwork 17', n16 <> f16);
	f16 := TByteOrder.fromBigEndian(f16);
	assertTrue('testByteOrderNetwork 18', n16 = f16);

  un16 := 4;
	uf16 := TByteOrder.fromBigEndian(un16);
	assertTrue('testByteOrderNetwork 19', un16 <> uf16);
	uf16 := TByteOrder.fromBigEndian(uf16);
	assertTrue('testByteOrderNetwork 20', un16 = uf16);

  n32 := 4;
	f32 := TByteOrder.fromBigEndian(n32);
	assertTrue('testByteOrderNetwork 21', n32 <> f32);
	f32 := TByteOrder.fromBigEndian(f32);
	assertTrue('testByteOrderNetwork 22', n32 = f32);

  un32 := 4;
	uf32 := TByteOrder.fromBigEndian(un32);
	assertTrue('testByteOrderNetwork 23', un32 <> uf32);
	uf32 := TByteOrder.fromBigEndian(uf32);
	assertTrue('testByteOrderNetwork 24', un32 = uf32);

  n64 := 4;
	f64 := TByteOrder.fromBigEndian(n64);
	assertTrue('testByteOrderNetwork 25', n64 <> f64);
	f64 := TByteOrder.fromBigEndian(f64);
	assertTrue('testByteOrderNetwork 26', n64 = f64);

  un64 := 4;
	uf64 := TByteOrder.fromBigEndian(un64);
	assertTrue('testByteOrderNetwork 27', un64 <> uf64);
	uf64 := TByteOrder.fromBigEndian(uf64);
	assertTrue('testByteOrderNetwork 28', un64 = uf64);

{$endif}

end;

end.
