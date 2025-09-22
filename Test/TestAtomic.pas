unit TestAtomic;

interface

uses System.SysUtils, TestUtil;

type
  TTestAtomic = class
    procedure testValue;
    procedure testInteger;
    procedure testInt64;
    procedure testBoolean;
    procedure testSingle;
    procedure testDouble;
    procedure testString;
    procedure testAnsiString;
  public
    class procedure Test;
  end;

implementation

uses Breeze.Atomic;

{ TTestAtomic }

class procedure TTestAtomic.Test;
var
  testclass: TTestAtomic;
begin
  TRTest.Comment('=============================================');
  TRTest.Comment('= TestAtomic');
  TRTest.Comment('=============================================');

  testclass := TTestAtomic.Create;
  try
    testclass.testInteger;
    testclass.testInt64;
    testclass.testBoolean;
    testclass.testSingle;
    testclass.testDouble;
    testclass.testString;
    testclass.testAnsiString;
  finally
    testclass.Free;
  end;
end;

procedure TTestAtomic.testAnsiString;
var
  ai: TAtomicAnsiString;
begin
  ai := TAtomicAnsiString.Create('abc');
  try
    assertTrue('testAnsiString 1', ai.Value = 'abc');
    ai.Append('derr');
    assertTrue('testAnsiString 2', ai.Value = 'abcderr');
    ai.Value := 'ABCDEF';
    assertTrue('testAnsiString 3', ai.Value = 'ABCDEF');
  finally
    ai.Free;
  end;
end;

procedure TTestAtomic.testBoolean;
var
  ai: TAtomicBool;
begin
  ai := TAtomicBool.Create(True);
  try
    assertTrue('testBoolean 1', ai.Value);
    ai.SetFalse;
    assertTrue('testBoolean 2', not ai.Value);
    ai.SetTrue;
    assertTrue('testBoolean 3', ai.Value);
    ai.Value := False;
    assertTrue('testBoolean 4', not ai.Value);
    ai.Value := True;
    assertTrue('testBoolean 4', ai.Value);
  finally
    ai.Free;
  end;
end;

procedure TTestAtomic.testInt64;
var
  ai: TAtomicInt64;
begin
  ai := TAtomicInt64.Create(100);
  try
    assertTrue('testInt64 1', ai.Value = 100);
    ai.Increment(10);
    assertTrue('testInt64 2', ai.Value = 110);
    ai.Decrement(30);
    assertTrue('testInt64 3', ai.Value = 80);
    ai.Value := 300;
    assertTrue('testInt64 4', ai.Value = 300);
  finally
    ai.Free;
  end;
end;

procedure TTestAtomic.testInteger;
var
  ai: TAtomicInteger;
begin
  ai := TAtomicInteger.Create(100);
  try
    assertTrue('testInteger 1', ai.Value = 100);
    ai.Increment(10);
    assertTrue('testInteger 2', ai.Value = 110);
    ai.Decrement(30);
    assertTrue('testInteger 3', ai.Value = 80);
    ai.Value := 300;
    assertTrue('testInteger 4', ai.Value = 300);
  finally
    ai.Free;
  end;
end;

procedure TTestAtomic.testDouble;
var
  ai: TAtomicDouble;
begin
  ai := TAtomicDouble.Create(100);
  try
    assertTrue('testDouble 1', ai.Value = 100);
    ai.Increment(10);
    assertTrue('testDouble 2', ai.Value = 110);
    ai.Decrement(30);
    assertTrue('testDouble 3', ai.Value = 80);
    ai.Value := 300;
    assertTrue('testDouble 4', ai.Value = 300);
  finally
    ai.Free;
  end;
end;

procedure TTestAtomic.testSingle;
var
  ai: TAtomicSingle;
begin
  ai := TAtomicSingle.Create(100);
  try
    assertTrue('testSingle 1', ai.Value = 100);
    ai.Increment(10);
    assertTrue('testSingle 2', ai.Value = 110);
    ai.Decrement(30);
    assertTrue('testSingle 3', ai.Value = 80);
    ai.Value := 300;
    assertTrue('testSingle 4', ai.Value = 300);
  finally
    ai.Free;
  end;
end;

procedure TTestAtomic.testString;
var
  ai: TAtomicString;
begin
  ai := TAtomicString.Create('abc');
  try
    assertTrue('testString 1', ai.Value = 'abc');
    ai.Append('derr');
    assertTrue('testString 2', ai.Value = 'abcderr');
    ai.Value := 'ABCDEF';
    assertTrue('testString 3', ai.Value = 'ABCDEF');
  finally
    ai.Free;
  end;
end;

procedure TTestAtomic.testValue;
begin

end;

end.
