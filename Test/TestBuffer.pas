unit TestBuffer;

interface

uses System.SysUtils, System.Generics.Collections, System.win.Crtl, TestUtil;

type
  TTestBuffer = class
    procedure testBuffer;
    procedure testBuffer2;
  public
    class procedure Test;
  end;

implementation

uses Breeze.Buffer;

{ TTestAtomic }

class procedure TTestBuffer.Test;
var
  testclass: TTestBuffer;
begin
  TRTest.Comment('=============================================');
  TRTest.Comment('= TestBuffer');
  TRTest.Comment('=============================================');

  testclass := TTestBuffer.Create;
  try
    testclass.testBuffer;
    testclass.testBuffer2;
  finally
    testclass.Free;
  end;
end;

procedure TTestBuffer.testBuffer;
const
  j: AnsiString = 'hello';
var
  s: NativeUInt;
  b, c, d, e, f, g, buf, k: TBuffer;
  v: TList<Byte>;
  i: Integer;
begin
  v := nil;
	b := nil;
  c := nil;
  d := nil;
  e := nil;
  f := nil;
  g := nil;
  buf := nil;
  k := nil;
  try
    v := TList<Byte>.Create;
    s := 10;
    b := TBuffer.Create(s);
    assertTrue('testBuffer_poco 1', b.size = s);
//    assertTrue('testBuffer_poco 2', b.capacity = s);

    for i := 0 to s - 1 do
      v.Add(i);

    memcpy(b.Memory, @v.List[0], v.Count);

    assertTrue('testBuffer_poco 3', b.size = s);

    for i := 0 to s - 1 do
      assertTrue('testBuffer_poco ' + IntToStr(4 + i), b[i] = i);

    b.size := s div 2;
    for i := 0 to s div 2 - 1 do
      assertTrue('testBuffer_poco ' + IntToStr(14 + i), b[i] = i);

    assertTrue('testBuffer_poco 19', b.size = s div 2);
//    assertTrue('testBuffer_poco 20', b.capacity = s);

    b.size := s * 2;
    v.clear;
    for i := 0 to s * 2 - 1 do
      v.Add(i);

    memcpy(b.Memory, @v.list[0], v.Count);

    for i := 0 to s * 2 - 1 do
      assertTrue('testBuffer_poco ' + IntToStr(21 + i), b[i] = i);

    assertTrue('testBuffer_poco 41', b.size = s * 2);
//    assertTrue('testBuffer_poco 42', b.capacity = s * 2);

    b.size := s * 4;

    assertTrue('testBuffer_poco 43', b.size = s * 4);
//    assertTrue('testBuffer_poco 44', b.capacity = s * 4);

    b.size := s;

    assertTrue('testBuffer_poco 45', b.size = s);
//    assertTrue('testBuffer_poco 46', b.capacity = s);

    c := TBuffer.Create(s);
    d := TBuffer.Create(c);
    assertTrue('testBuffer_poco 47', c.Equal(d));

    c[1] := 100;
    assertTrue('testBuffer_poco 48', c[1] = 100);
    c.clearMemory;
    assertTrue('testBuffer_poco 49', c[1] = 0);

    e := TBuffer.Create(0);
    assertTrue('testBuffer_poco 50', e.IsEmpty);

    assertTrue('testBuffer_poco 51', not c.Equal(e));

    f := TBuffer.Create(0);
    f.Assign(e);
    assertTrue('testBuffer_poco 52', f.Equal(e));

    g := TBuffer.Create(0);
    g.append('hello');
    assertTrue('testBuffer_poco 53', g.size = 5);

    g.append('hello');
    assertTrue('testBuffer_poco 54', g.size = 10);

    assertTrue('testBuffer_poco 55', memcmp(g.Memory, PAnsiChar('hellohello'), 10) = 0);
  finally
    v.Free;
	  b.Free;
	  c.Free;
	  d.Free;
	  e.Free;
	  f.Free;
	  g.Free;
    buf.Free;
    k.Free;
  end;
end;

procedure TTestBuffer.testBuffer2;
var
  a, b, c: TBuffer;
  buffer: RawByteString;
  readbuffer: RawByteString;
begin
  buffer := 'Hello world';

  a := TBuffer.Create;
  assertTrue('testBuffer 1', a.size = 0);
  assertTrue('testBuffer 2', a.Capacity = 0);
  assertTrue('testBuffer 3', a.OwnMemory);

  a.Size := 1023;
  assertTrue('testBuffer 4', a.size = 1023);
  assertTrue('testBuffer 5', a.OwnMemory);

  a.Clear;
  assertTrue('testBuffer 6', a.size = 0);
  assertTrue('testBuffer 7', a.Capacity = 0);
  assertTrue('testBuffer 8', a.OwnMemory);
  a.Free;
//////////////////
  b := TBuffer.Create(211);
  assertTrue('testBuffer 9', b.size = 211);
  assertTrue('testBuffer 10', b.OwnMemory);

  b.Size := 258;
  assertTrue('testBuffer 11', b.size = 258);
  assertTrue('testBuffer 12', b.OwnMemory);

  b.Clear;
  assertTrue('testBuffer 13', b.size = 0);
  assertTrue('testBuffer 14', b.Capacity = 0);
  assertTrue('testBuffer 15', b.OwnMemory);
  b.Free;
//////////////////
  a := TBuffer.Create(@buffer[7], 5, false);
  assertTrue('testBuffer 16', a.size = 5);
  assertTrue('testBuffer 17', not a.OwnMemory);
  assertTrue('testBuffer 18', (a[0] = Byte('w')) and (a[1] = Byte('o')) and (a[2] = Byte('r')) and (a[3] = Byte('l')) and (a[4] = Byte('d')));
  a.Free;

//////////////////
  c := TBuffer.Create(@buffer[1], 5, false);
  assertTrue('testBuffer 19', c.size = 5);
  assertTrue('testBuffer 20', not c.OwnMemory);
  assertTrue('testBuffer 21', (c[0] = Byte('H')) and (c[1] = Byte('e')) and (c[2] = Byte('l')) and (c[3] = Byte('l')) and (c[4] = Byte('o')));

  assertTrue('testBuffer 22', c.Memory = @buffer[1]);

  a := TBuffer.Create(c);
  assertTrue('testBuffer 23', a.size = 5);
  assertTrue('testBuffer 24', not a.OwnMemory);
  assertTrue('testBuffer 25', a.Memory = @buffer[1]);

  a.MakeOwn;
  assertTrue('testBuffer 26', a.size = 5);
  assertTrue('testBuffer 27', a.OwnMemory);
  assertTrue('testBuffer 28', a.Memory <> @buffer[1]);
  assertTrue('testBuffer 29', (a[0] = Byte('H')) and (a[1] = Byte('e')) and (a[2] = Byte('l')) and (a[3] = Byte('l')) and (a[4] = Byte('o')));

  assertTrue('testBuffer 30', a.Equal(c));
  a.ClearMemory;
  assertTrue('testBuffer 31', not a.Equal(c));
  assertTrue('testBuffer 32', (a[0] = 0) and (a[1] = 0) and (a[2] = 0) and (a[3] = 0) and (a[4] = 0));

  c.ClearMemory;
  assertTrue('testBuffer 33', a.Equal(c));

  assertException('testBuffer 34',
    procedure
    begin
      a[11] := 2;
    end
  );

  assertException('testBuffer 35',
    procedure
    begin
      buffer[1] := AnsiChar(a[13]);
    end
  );

  assertNoException('testBuffer 36',
    procedure
    begin
      buffer[1] := AnsiChar(a[1]);
    end
  );

  a.Free;
  c.Free;

//////////////////
  buffer := 'Hello world';
  c := TBuffer.Create(@buffer[1], 5, false);
  c.Position := 0;
  c.Write(RawByteString('qwert'), 5);

  assertTrue('testBuffer 37', buffer = 'qwert world');
  c.Free;

//////////////////
  buffer := 'Hello world';
  c := TBuffer.Create(@buffer[3], 5, false);
  c.Position := 0;
  c.Write(RawByteString('qwert'), 5);

  assertTrue('testBuffer 38', buffer = 'Heqwertorld');

  SetLength(readbuffer, 10);
  memset(@readbuffer[1], 0, Length(readbuffer));
  c.Position := 0;

  assertTrue('testBuffer 39', c.Read(readbuffer[1], 20) = 5);
  assertTrue('testBuffer 40', Trim(String(readbuffer)) = 'qwert');

  c.Free;

//////////////////
  buffer := 'Hello world';
  c := TBuffer.Create(@buffer[1], 5, false);
  a := TBuffer.Create(100);

  a.Assign(c);

  assertTrue('testBuffer 41', a.size = 5);
  assertTrue('testBuffer 42', not a.OwnMemory);
  assertTrue('testBuffer 43', (a[0] = Byte('H')) and (a[1] = Byte('e')) and (a[2] = Byte('l')) and (a[3] = Byte('l')) and (a[4] = Byte('o')));
  assertTrue('testBuffer 44', a.Memory = @buffer[1]);

  a.Free;
  c.Free;

//////////////////
  buffer := 'Hello world';
  c := TBuffer.Create(@buffer[6], 5, true);
  c.Position := 0;
  c.Append('HELLO WORLD');

  assertTrue('testBuffer 45', c.AsRawByteString = 'HELLO WORLD');
  c.Free;

//////////////////
  buffer := 'Hello world';
  c := TBuffer.Create(@buffer[6], 5, false);
  c.Position := 0;
  c.Append(' WORLD');

  assertTrue('testBuffer 46', c.AsRawByteString = ' WORLD');
  assertTrue('testBuffer 46', buffer = 'Hello WORLD');

  c.Free;

//////////////////
  buffer := 'Hello worldqq';
  c := TBuffer.Create(@buffer[6], 5, false);
  c.Position := 0;
  c.Append(Byte('T'));

  assertTrue('testBuffer 47', c.AsRawByteString = 'Tworl');
  assertTrue('testBuffer 48', buffer = 'HelloTworldqq');

  c.Append(Byte('A'));
  c.Append(Byte('Z'));
  c.Append(Byte('I'));
  c.Append(Byte('K'));
  c.Append(Byte('8'));
  c.Append(Byte('R'));

  assertTrue('testBuffer 49', c.AsRawByteString = 'TAZIK8R');
  assertTrue('testBuffer 50', buffer = 'HelloTAZIK8Rq');

  c.Free;

//////////////////
  c := TBuffer.Create('Hello world');
  a := TBuffer.Create('aabbcc');
  a.Position := a.Size;

  a.Append(c);

  assertTrue('testBuffer 51', a.AsRawByteString = 'aabbccHello world');

  a.Free;
  c.Free;
//////////////////
  c := TBuffer.Create('Hello world');
  a := TBuffer.Create('aabbcc');

  assertTrue('testBuffer 52', a.AsRawByteString = 'aabbcc');

  a.MoveTo(c);

  assertTrue('testBuffer 53', c.AsRawByteString = 'aabbcc');
  assertTrue('testBuffer 54', a.IsEmpty);

  a.Free;
  c.Free;

//////////////////
  c := TBuffer.Create('Hello world');
  a := TBuffer.Create('aabbcc');

  a.LoadFromStream(c);

  assertTrue('testBuffer 55', c.Size = 11);
  assertTrue('testBuffer 56', c.AsRawByteString = 'Hello world');

  c.Assign('kikoz');

  a.Clear;
  c.SaveToStream(a);

  assertTrue('testBuffer 57', a.Size = 5);
  assertTrue('testBuffer 58', c.AsRawByteString = 'kikoz');

  a.Free;
  c.Free;

//////////////////
  buffer := 'Hello world';
  c := TBuffer.Create(@buffer[7], 5, false);
  a := TBuffer.Create('aabb');

  a.LoadFromStream(c);

  assertTrue('testBuffer 59', c.AsRawByteString = 'world');

  c.Assign('kikoz');

  a.Clear;
  c.SaveToStream(a);

  assertTrue('testBuffer 60', a.Size = 5);
  assertTrue('testBuffer 61', c.AsRawByteString = 'kikoz');

  a.Free;
  c.Free;

//////////////////
  buffer := 'Hello world';
  a := TBuffer.Create(@buffer[7], 5, false);
  c := TBuffer.Create('aabb');

  a.LoadFromStream(c);

  assertTrue('testBuffer 62', a.AsRawByteString = 'aabb');

  c.Assign('kikoz');
  c.SaveToStream(a);

  assertTrue('testBuffer 63', a.Size = 5);
  assertTrue('testBuffer 64', c.AsRawByteString = 'kikoz');
  assertTrue('testBuffer 65', buffer = 'Hello kikoz');

  a.Free;
  c.Free;
//////////////////
  c := TBuffer.Create('aabbccddee');
  assertTrue('testBuffer 66', c.AsRawByteString(2, 4) = 'bbcc');
  c.Free;
end;

end.
