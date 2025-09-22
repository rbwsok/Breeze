unit Breeze.StringTokenizer;

interface

uses System.Generics.Collections, System.SysUtils, System.TypInfo;

type

  TStringTokenizer = class
  const
    TOK_IGNORE_EMPTY = 1;     /// ignore empty tokens
    TOK_TRIM = 2;    /// remove leading and trailing whitespace from tokens
  private
    class function Trim(const AValue: String): String;
  public
    class function Tokenize(const AString, ASeparators: String; AOptions: Integer = 0): TList<String>;
  end;

  TRawByteStringTokenizer = class
  const
    TOK_IGNORE_EMPTY = 1;     /// ignore empty tokens
    TOK_TRIM = 2;    /// remove leading and trailing whitespace from tokens
  private
    class function Trim(const AValue: RawByteString): RawByteString;
  public
    class function Tokenize(const AString, ASeparators: RawByteString; AOptions: Integer = 0): TList<RawByteString>;
  end;

implementation

{ TStringTokenizer }

class function TStringTokenizer.Tokenize(const AString, ASeparators: String; AOptions: Integer): TList<String>;
var
  LDoTrim: Boolean;
  LIgnoreEmpty: Boolean;
  i: Integer;
  LToken: String;
  LPrevSeparatorIndex: Integer;
begin
  result := TList<String>.Create;

  if Length(AString) = 0 then
    exit;

  LDoTrim := (AOptions and TOK_TRIM) <> 0;
  LIgnoreEmpty := (AOptions and TOK_IGNORE_EMPTY) <> 0;
  LPrevSeparatorIndex := 0;

  for i := 1 to Length(AString) do
  begin
    if pos(AString[i], ASeparators) > 0 then
    begin
      LToken := copy(AString, LPrevSeparatorIndex + 1, i - LPrevSeparatorIndex - 1);

      if LDoTrim then
        LToken := Trim(LToken);
      if (not LIgnoreEmpty) or (Length(LToken) <> 0) then
        result.Add(LToken);
      LPrevSeparatorIndex := i;
    end;
  end;

  LToken := copy(AString, LPrevSeparatorIndex + 1, Length(AString) - LPrevSeparatorIndex + 1);
  if LDoTrim then
    LToken := Trim(LToken);
  if (not LIgnoreEmpty) or (Length(LToken) <> 0) then
    result.Add(LToken);
end;

class function TStringTokenizer.Trim(const AValue: String): String;
var
  i, L: Integer;
begin
  L := Length(AValue);
  if L = 0 then
    exit('');
  i := 1;
  if (L > -1) and (AValue[i] > ' ') and (AValue[L] > ' ') then
    Exit(AValue);
  while (i <= L) and (AValue[i] <= ' ') do
    Inc(i);
  if i > L then
    Exit('');
  while AValue[L] <= ' ' do
    Dec(L);
  result := copy(AValue, i, L - i + 1);
end;

{ TRawByteStringTokenizer }

class function TRawByteStringTokenizer.Tokenize(const AString, ASeparators: RawByteString; AOptions: Integer): TList<RawByteString>;
var
  LDoTrim: Boolean;
  LIgnoreEmpty: Boolean;
  i: Integer;
  LToken: RawByteString;
  LPrevSeparatorIndex: Integer;
begin
  result := TList<RawByteString>.Create;

  if Length(AString) = 0 then
    exit;

  LDoTrim := (AOptions and TOK_TRIM) <> 0;
  LIgnoreEmpty := (AOptions and TOK_IGNORE_EMPTY) <> 0;
  LPrevSeparatorIndex := 0;

  for i := 1 to Length(AString) do
  begin
    if pos(AString[i], ASeparators) > 0 then
    begin
      LToken := copy(AString, LPrevSeparatorIndex + 1, i - LPrevSeparatorIndex - 1);

      if LDoTrim then
        LToken := Trim(LToken);
      if (not LIgnoreEmpty) or (Length(LToken) <> 0) then
        result.Add(LToken);
      LPrevSeparatorIndex := i;
    end;
  end;

  LToken := copy(AString, LPrevSeparatorIndex + 1, Length(AString) - LPrevSeparatorIndex + 1);
  if LDoTrim then
    LToken := Trim(LToken);
  if (not LIgnoreEmpty) or (Length(LToken) <> 0) then
    result.Add(LToken);
end;

class function TRawByteStringTokenizer.Trim(const AValue: RawByteString): RawByteString;
var
  i, L: Integer;
begin
  L := Length(AValue);
  if L = 0 then
    exit('');
  i := 1;
  if (L > -1) and (AValue[i] > ' ') and (AValue[L] > ' ') then
    Exit(AValue);
  while (i <= L) and (AValue[i] <= ' ') do
    Inc(i);
  if i > L then
    Exit('');
  while AValue[L] <= ' ' do
    Dec(L);
  result := copy(AValue, i, L - i + 1);
end;

end.

