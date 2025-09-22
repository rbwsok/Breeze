// потокобезопасные примитивы
//
// быстрые специализации (нет наследования, нет внутренних классов)
// TAtomicInteger
// TAtomicInt64
// TAtomicBool
// TAtomicSingle
// TAtomicDouble
// TAtomicString
// TAtomicAnsiString
// TAtomicValue<T> - все остальное

unit Breeze.Atomic;

interface

uses System.SysUtils, System.SyncObjs, System.Threading, System.Classes, System.TypInfo, System.Generics.Collections, Winapi.Windows;

const
  DEFAULT_SPIN_COUNT = 4000; // рекомендация Microsoft

type
  // быстрая потокобезопасная шаблонная переменная
  TAtomicValue<T> = class
  private
    FCriticalSection: Winapi.Windows._RTL_CRITICAL_SECTION;
    FValue: T;

    procedure SetValue(AValue: T);
    function GetValue: T;
  public
    constructor Create; overload;
    constructor Create(AValue: T); overload;
    destructor Destroy; override;
    procedure Lock;
    procedure Unlock;
    property Value: T read GetValue write SetValue;
  end;

  // быстрый потокобезопасный Integer
  TAtomicInteger = class
  private
    FCriticalSection: Winapi.Windows._RTL_CRITICAL_SECTION;
    FValue: Integer;

    procedure SetValue(AValue: Integer);
    function GetValue: Integer;
  public
    constructor Create; overload;
    constructor Create(AValue: Integer); overload;
    destructor Destroy; override;
    procedure Lock;
    procedure Unlock;
    function Increment(AValue: Integer = 1): Integer;
    function Decrement(AValue: Integer = 1): Integer;
    property Value: Integer read GetValue write SetValue;
  end;

  // быстрый потокобезопасный Int64
  TAtomicInt64 = class
  private
    FCriticalSection: Winapi.Windows._RTL_CRITICAL_SECTION;
    FValue: Int64;

    procedure SetValue(AValue: Int64);
    function GetValue: Int64;
  public
    constructor Create; overload;
    constructor Create(AValue: Int64); overload;
    destructor Destroy; override;
    procedure Lock;
    procedure Unlock;
    function Increment(AValue: Int64 = 1): Int64;
    function Decrement(AValue: Int64 = 1): Int64;
    property Value: Int64 read GetValue write SetValue;
  end;

  // быстрый потокобезопасный Boolean
  TAtomicBool = class
  private
    FCriticalSection: Winapi.Windows._RTL_CRITICAL_SECTION;
    FValue: Boolean;

    procedure SetValue(AValue: Boolean);
    function GetValue: Boolean;
  public
    constructor Create; overload;
    constructor Create(AValue: Boolean); overload;
    destructor Destroy; override;
    procedure Lock;
    procedure Unlock;
    procedure SetFalse;
    procedure SetTrue;
    property Value: Boolean read GetValue write SetValue;
  end;

  // быстрый потокобезопасный Single
  TAtomicSingle = class
  private
    FCriticalSection: Winapi.Windows._RTL_CRITICAL_SECTION;
    FValue: Single;

    procedure SetValue(AValue: Single);
    function GetValue: Single;
  public
    constructor Create; overload;
    constructor Create(AValue: Single); overload;
    destructor Destroy; override;
    procedure Lock;
    procedure Unlock;
    function Increment(AValue: Single = 1): Single;
    function Decrement(AValue: Single = 1): Single;
    property Value: Single read GetValue write SetValue;
  end;

  // быстрый потокобезопасный Double
  TAtomicDouble = class
  private
    FCriticalSection: Winapi.Windows._RTL_CRITICAL_SECTION;
    FValue: Double;

    procedure SetValue(AValue: Double);
    function GetValue: Double;
  public
    constructor Create; overload;
    constructor Create(AValue: Double); overload;
    destructor Destroy; override;
    procedure Lock;
    procedure Unlock;
    function Increment(AValue: Double = 1): Double;
    function Decrement(AValue: Double = 1): Double;
    property Value: Double read GetValue write SetValue;
  end;

  // быстрый потокобезопасный String
  TAtomicString = class
  private
    FCriticalSection: Winapi.Windows._RTL_CRITICAL_SECTION;
    FValue: String;

    procedure SetValue(const AValue: String);
    function GetValue: String;
  public
    constructor Create; overload;
    constructor Create(const AValue: String); overload;
    destructor Destroy; override;
    procedure Lock;
    procedure Unlock;
    function Append(const AValue: String): String;
    property Value: String read GetValue write SetValue;
  end;

  TAtomicAnsiString = class
  private
    FCriticalSection: Winapi.Windows._RTL_CRITICAL_SECTION;
    FValue: AnsiString;

    procedure SetValue(const AValue: AnsiString);
    function GetValue: AnsiString;
  public
    constructor Create; overload;
    constructor Create(const AValue: AnsiString); overload;
    destructor Destroy; override;
    procedure Lock;
    procedure Unlock;
    function Append(const AValue: AnsiString): AnsiString;
    property Value: AnsiString read GetValue write SetValue;
  end;

implementation

{ TAtomicValue<T> }

constructor TAtomicValue<T>.Create;
begin
  inherited;
  InitializeCriticalSectionAndSpinCount(FCriticalSection, DEFAULT_SPIN_COUNT);
end;

constructor TAtomicValue<T>.Create(AValue: T);
begin
  Create;
  SetValue(AValue);
end;

destructor TAtomicValue<T>.Destroy;
begin
  DeleteCriticalSection(FCriticalSection);
  inherited;
end;

function TAtomicValue<T>.GetValue: T;
begin
  EnterCriticalSection(FCriticalSection);
  Result := FValue;
  LeaveCriticalSection(FCriticalSection);
end;

procedure TAtomicValue<T>.Lock;
begin
  EnterCriticalSection(FCriticalSection);
end;

procedure TAtomicValue<T>.SetValue(AValue: T);
begin
  EnterCriticalSection(FCriticalSection);
  FValue := AValue;
  LeaveCriticalSection(FCriticalSection);
end;

procedure TAtomicValue<T>.Unlock;
begin
  LeaveCriticalSection(FCriticalSection);
end;

{ TAtomicInteger }

constructor TAtomicInteger.Create;
begin
  inherited;
  InitializeCriticalSectionAndSpinCount(FCriticalSection, DEFAULT_SPIN_COUNT);
end;

constructor TAtomicInteger.Create(AValue: Integer);
begin
  Create;
  SetValue(AValue);
end;

function TAtomicInteger.Decrement(AValue: Integer): Integer;
begin
  EnterCriticalSection(FCriticalSection);
  Dec(FValue, AValue);
  Result := FValue;
  LeaveCriticalSection(FCriticalSection);
end;

destructor TAtomicInteger.Destroy;
begin
  DeleteCriticalSection(FCriticalSection);
  inherited;
end;

function TAtomicInteger.GetValue: Integer;
begin
  EnterCriticalSection(FCriticalSection);
  Result := FValue;
  LeaveCriticalSection(FCriticalSection);
end;

function TAtomicInteger.Increment(AValue: Integer): Integer;
begin
  EnterCriticalSection(FCriticalSection);
  Inc(FValue, AValue);
  result := FValue;
  LeaveCriticalSection(FCriticalSection);
end;

procedure TAtomicInteger.Lock;
begin
  EnterCriticalSection(FCriticalSection);
end;

procedure TAtomicInteger.SetValue(AValue: Integer);
begin
  EnterCriticalSection(FCriticalSection);
  FValue := AValue;
  LeaveCriticalSection(FCriticalSection);
end;

procedure TAtomicInteger.Unlock;
begin
  LeaveCriticalSection(FCriticalSection);
end;

{ TAtomicInt64 }

constructor TAtomicInt64.Create;
begin
  inherited;
  InitializeCriticalSectionAndSpinCount(FCriticalSection, DEFAULT_SPIN_COUNT);
end;

constructor TAtomicInt64.Create(AValue: Int64);
begin
  Create;
  SetValue(AValue);
end;

function TAtomicInt64.Decrement(AValue: Int64): Int64;
begin
  EnterCriticalSection(FCriticalSection);
  Dec(FValue, AValue);
  Result := FValue;
  LeaveCriticalSection(FCriticalSection);
end;

destructor TAtomicInt64.Destroy;
begin
  DeleteCriticalSection(FCriticalSection);
  inherited;
end;

function TAtomicInt64.GetValue: Int64;
begin
  EnterCriticalSection(FCriticalSection);
  Result := FValue;
  LeaveCriticalSection(FCriticalSection);
end;

function TAtomicInt64.Increment(AValue: Int64): Int64;
begin
  EnterCriticalSection(FCriticalSection);
  Inc(FValue, AValue);
  Result := FValue;
  LeaveCriticalSection(FCriticalSection);
end;

procedure TAtomicInt64.Lock;
begin
  EnterCriticalSection(FCriticalSection);
end;

procedure TAtomicInt64.SetValue(AValue: Int64);
begin
  EnterCriticalSection(FCriticalSection);
  FValue := AValue;
  LeaveCriticalSection(FCriticalSection);
end;

procedure TAtomicInt64.Unlock;
begin
  LeaveCriticalSection(FCriticalSection);
end;

{ TAtomicBool }

constructor TAtomicBool.Create;
begin
  inherited;
  InitializeCriticalSectionAndSpinCount(FCriticalSection, DEFAULT_SPIN_COUNT);
end;

constructor TAtomicBool.Create(AValue: Boolean);
begin
  Create;
  SetValue(AValue);
end;

destructor TAtomicBool.Destroy;
begin
  DeleteCriticalSection(FCriticalSection);
  inherited;
end;

function TAtomicBool.GetValue: Boolean;
begin
  EnterCriticalSection(FCriticalSection);
  Result := FValue;
  LeaveCriticalSection(FCriticalSection);
end;

procedure TAtomicBool.Lock;
begin
  EnterCriticalSection(FCriticalSection);
end;

procedure TAtomicBool.SetFalse;
begin
  SetValue(False);
end;

procedure TAtomicBool.SetTrue;
begin
  SetValue(True);
end;

procedure TAtomicBool.SetValue(AValue: Boolean);
begin
  EnterCriticalSection(FCriticalSection);
  FValue := AValue;
  LeaveCriticalSection(FCriticalSection);
end;

procedure TAtomicBool.Unlock;
begin
  LeaveCriticalSection(FCriticalSection);
end;

{ TAtomicSingle }

constructor TAtomicSingle.Create;
begin
  inherited;
  InitializeCriticalSectionAndSpinCount(FCriticalSection, DEFAULT_SPIN_COUNT);
end;

constructor TAtomicSingle.Create(AValue: Single);
begin
  Create;
  SetValue(AValue);
end;

function TAtomicSingle.Decrement(AValue: Single): Single;
begin
  EnterCriticalSection(FCriticalSection);
  FValue := FValue - AValue;
  Result := FValue;
  LeaveCriticalSection(FCriticalSection);
end;

destructor TAtomicSingle.Destroy;
begin
  DeleteCriticalSection(FCriticalSection);
  inherited;
end;

function TAtomicSingle.GetValue: Single;
begin
  EnterCriticalSection(FCriticalSection);
  Result := FValue;
  LeaveCriticalSection(FCriticalSection);
end;

function TAtomicSingle.Increment(AValue: Single): Single;
begin
  EnterCriticalSection(FCriticalSection);
  FValue := FValue + AValue;
  Result := FValue;
  LeaveCriticalSection(FCriticalSection);
end;

procedure TAtomicSingle.Lock;
begin
  EnterCriticalSection(FCriticalSection);
end;

procedure TAtomicSingle.SetValue(AValue: Single);
begin
  EnterCriticalSection(FCriticalSection);
  FValue := AValue;
  LeaveCriticalSection(FCriticalSection);
end;

procedure TAtomicSingle.Unlock;
begin
  LeaveCriticalSection(FCriticalSection);
end;

{ TAtomicDouble }

constructor TAtomicDouble.Create;
begin
  inherited;
  InitializeCriticalSectionAndSpinCount(FCriticalSection, DEFAULT_SPIN_COUNT);
end;

constructor TAtomicDouble.Create(AValue: Double);
begin
  Create;
  SetValue(AValue);
end;

function TAtomicDouble.Decrement(AValue: Double): Double;
begin
  EnterCriticalSection(FCriticalSection);
  FValue := FValue - AValue;
  Result := FValue;
  LeaveCriticalSection(FCriticalSection);
end;

destructor TAtomicDouble.Destroy;
begin
  DeleteCriticalSection(FCriticalSection);
  inherited;
end;

function TAtomicDouble.GetValue: Double;
begin
  EnterCriticalSection(FCriticalSection);
  Result := FValue;
  LeaveCriticalSection(FCriticalSection);
end;

function TAtomicDouble.Increment(AValue: Double): Double;
begin
  EnterCriticalSection(FCriticalSection);
  FValue := FValue + AValue;
  Result := FValue;
  LeaveCriticalSection(FCriticalSection);
end;

procedure TAtomicDouble.Lock;
begin
  EnterCriticalSection(FCriticalSection);
end;

procedure TAtomicDouble.SetValue(AValue: Double);
begin
  EnterCriticalSection(FCriticalSection);
  FValue := AValue;
  LeaveCriticalSection(FCriticalSection);
end;

procedure TAtomicDouble.Unlock;
begin
  LeaveCriticalSection(FCriticalSection);
end;

{ TAtomicString }

function TAtomicString.Append(const AValue: String): String;
begin
  EnterCriticalSection(FCriticalSection);
  FValue := FValue + AValue;
  Result := FValue;
  UniqueString(Result);
  LeaveCriticalSection(FCriticalSection);
end;

constructor TAtomicString.Create;
begin
  inherited;
  InitializeCriticalSectionAndSpinCount(FCriticalSection, DEFAULT_SPIN_COUNT);
end;

constructor TAtomicString.Create(const AValue: String);
begin
  Create;
  SetValue(AValue);
end;

destructor TAtomicString.Destroy;
begin
  DeleteCriticalSection(FCriticalSection);
  inherited;
end;

function TAtomicString.GetValue: String;
begin
  EnterCriticalSection(FCriticalSection);
  Result := FValue;
  UniqueString(Result);
  LeaveCriticalSection(FCriticalSection);
end;

procedure TAtomicString.Lock;
begin
  EnterCriticalSection(FCriticalSection);
end;

procedure TAtomicString.SetValue(const AValue: String);
begin
  EnterCriticalSection(FCriticalSection);
  FValue := AValue;
  UniqueString(FValue);
  LeaveCriticalSection(FCriticalSection);
end;

procedure TAtomicString.Unlock;
begin
  LeaveCriticalSection(FCriticalSection);
end;

{ TAtomicAnsiString }

function TAtomicAnsiString.Append(const AValue: AnsiString): AnsiString;
begin
  EnterCriticalSection(FCriticalSection);
  FValue := FValue + AValue;
  Result := FValue;
  UniqueString(Result);
  LeaveCriticalSection(FCriticalSection);
end;

constructor TAtomicAnsiString.Create;
begin
  inherited;
  InitializeCriticalSectionAndSpinCount(FCriticalSection, DEFAULT_SPIN_COUNT);
end;

constructor TAtomicAnsiString.Create(const AValue: AnsiString);
begin
  Create;
  SetValue(AValue);
end;

destructor TAtomicAnsiString.Destroy;
begin
  DeleteCriticalSection(FCriticalSection);
  inherited;
end;

function TAtomicAnsiString.GetValue: AnsiString;
begin
  EnterCriticalSection(FCriticalSection);
  Result := FValue;
  UniqueString(Result);
  LeaveCriticalSection(FCriticalSection);
end;

procedure TAtomicAnsiString.Lock;
begin
  EnterCriticalSection(FCriticalSection);
end;

procedure TAtomicAnsiString.SetValue(const AValue: AnsiString);
begin
  EnterCriticalSection(FCriticalSection);
  FValue := AValue;
  UniqueString(FValue);
  LeaveCriticalSection(FCriticalSection);
end;

procedure TAtomicAnsiString.Unlock;
begin
  LeaveCriticalSection(FCriticalSection);
end;



end.
