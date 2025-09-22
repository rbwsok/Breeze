unit TestTokenizer;

interface

uses Winapi.Windows, System.Generics.Collections, TestUtil;

type
  TTestTokenizer = class
	  procedure testStringTokenizer;
	  procedure testRawByteStringTokenizer;
  public
    class procedure Test;
  end;

implementation

uses Breeze.StringTokenizer;

{ TTestDatagramSocket }

class procedure TTestTokenizer.Test;
var
  testclass: TTestTokenizer;
begin
  TRTest.Comment('=============================================');
  TRTest.Comment('= TestTokenizer');
  TRTest.Comment('=============================================');

  testclass := TTestTokenizer.Create;
  try
    testclass.testStringTokenizer;
    testclass.testRawByteStringTokenizer;
  finally
    testclass.Free;
  end;
end;

procedure TTestTokenizer.testRawByteStringTokenizer;
var
  st: TList<RawByteString>;
begin
	st := TRawByteStringTokenizer.Tokenize('', '');
	assertTrue('testRawByteStringTokenizer 1', st.Count = 0);
  st.Free;

	st := TRawByteStringTokenizer.Tokenize('', '', TRawByteStringTokenizer.TOK_IGNORE_EMPTY);
	assertTrue('testRawByteStringTokenizer 2', st.Count = 0);
  st.Free;

	st := TRawByteStringTokenizer.Tokenize('', '', TRawByteStringTokenizer.TOK_TRIM);
	assertTrue('testRawByteStringTokenizer 3', st.Count = 0);
  st.Free;

	st := TRawByteStringTokenizer.Tokenize('', '', TRawByteStringTokenizer.TOK_IGNORE_EMPTY or TRawByteStringTokenizer.TOK_TRIM);
	assertTrue('testRawByteStringTokenizer 4', st.Count = 0);
  st.Free;

	st := TRawByteStringTokenizer.Tokenize('abc', '');
	assertTrue('testRawByteStringTokenizer 5', st.Count = 1);
	assertTrue('testRawByteStringTokenizer 6', st[0] = 'abc');
  st.Free;

	st := TRawByteStringTokenizer.Tokenize('abc ', '', TRawByteStringTokenizer.TOK_TRIM);
	assertTrue('testRawByteStringTokenizer 7', st.Count = 1);
	assertTrue('testRawByteStringTokenizer 8', st[0] = 'abc');
  st.Free;

	st := TRawByteStringTokenizer.Tokenize('  abc ', '', TRawByteStringTokenizer.TOK_TRIM);
	assertTrue('testRawByteStringTokenizer 9', st.Count = 1);
	assertTrue('testRawByteStringTokenizer 10', st[0] = 'abc');
  st.Free;

	st := TRawByteStringTokenizer.Tokenize('  abc', '', TRawByteStringTokenizer.TOK_TRIM);
	assertTrue('testRawByteStringTokenizer 11', st.Count = 1);
	assertTrue('testRawByteStringTokenizer 12', st[0] = 'abc');
  st.Free;

	st := TRawByteStringTokenizer.Tokenize('abc', 'b');
	assertTrue('testRawByteStringTokenizer 13', st.Count = 2);
	assertTrue('testRawByteStringTokenizer 14', st[0] = 'a');
	assertTrue('testRawByteStringTokenizer 15', st[1] = 'c');
  st.Free;

	st := TRawByteStringTokenizer.Tokenize('abc', 'b', TRawByteStringTokenizer.TOK_IGNORE_EMPTY or TRawByteStringTokenizer.TOK_TRIM);
	assertTrue('testRawByteStringTokenizer 16', st.Count = 2);
	assertTrue('testRawByteStringTokenizer 17', st[0] = 'a');
	assertTrue('testRawByteStringTokenizer 18', st[1] = 'c');
  st.Free;

	st := TRawByteStringTokenizer.Tokenize('abc', 'bc');
	assertTrue('testRawByteStringTokenizer 19', st.Count = 3);
	assertTrue('testRawByteStringTokenizer 20', st[0] = 'a');
	assertTrue('testRawByteStringTokenizer 21', st[1] = '');
	assertTrue('testRawByteStringTokenizer 22', st[2] = '');
  st.Free;

	st := TRawByteStringTokenizer.Tokenize('abc', 'bc', TRawByteStringTokenizer.TOK_TRIM);
	assertTrue('testRawByteStringTokenizer 23', st.Count = 3);
	assertTrue('testRawByteStringTokenizer 24', st[0] = 'a');
	assertTrue('testRawByteStringTokenizer 25', st[1] = '');
	assertTrue('testRawByteStringTokenizer 26', st[2] = '');
  st.Free;

	st := TRawByteStringTokenizer.Tokenize('abc', 'bc', TRawByteStringTokenizer.TOK_IGNORE_EMPTY);
	assertTrue('testRawByteStringTokenizer 27', st.Count = 1);
	assertTrue('testRawByteStringTokenizer 28', st[0] = 'a');
  st.Free;

	st := TRawByteStringTokenizer.Tokenize('abc', 'bc', TRawByteStringTokenizer.TOK_IGNORE_EMPTY or TRawByteStringTokenizer.TOK_TRIM);
	assertTrue('testRawByteStringTokenizer 29', st.Count = 1);
	assertTrue('testRawByteStringTokenizer 30', st[0] = 'a');
  st.Free;

	st := TRawByteStringTokenizer.Tokenize('a a,c c', ',');
	assertTrue('testRawByteStringTokenizer 31', st.Count = 2);
	assertTrue('testRawByteStringTokenizer 32', st[0] = 'a a');
	assertTrue('testRawByteStringTokenizer 33', st[1] = 'c c');
  st.Free;

	st := TRawByteStringTokenizer.Tokenize('a a,c c', ',', TRawByteStringTokenizer.TOK_IGNORE_EMPTY or TRawByteStringTokenizer.TOK_TRIM);
	assertTrue('testRawByteStringTokenizer 34', st.Count = 2);
	assertTrue('testRawByteStringTokenizer 35', st[0] = 'a a');
	assertTrue('testRawByteStringTokenizer 36', st[1] = 'c c');
  st.Free;

	st := TRawByteStringTokenizer.Tokenize(' a a , , c c ', ',');
	assertTrue('testRawByteStringTokenizer 37', st.Count = 3);
	assertTrue('testRawByteStringTokenizer 38', st[0] = ' a a ');
	assertTrue('testRawByteStringTokenizer 39', st[1] = ' ');
	assertTrue('testRawByteStringTokenizer 40', st[2] = ' c c ');
  st.Free;

	st := TRawByteStringTokenizer.Tokenize(' a a , , c c ', ',', TRawByteStringTokenizer.TOK_TRIM);
	assertTrue('testRawByteStringTokenizer 41', st.Count = 3);
	assertTrue('testRawByteStringTokenizer 42', st[0] = 'a a');
	assertTrue('testRawByteStringTokenizer 43', st[1] = '');
	assertTrue('testRawByteStringTokenizer 44', st[2] = 'c c');
  st.Free;

	st := TRawByteStringTokenizer.Tokenize(' a a , , c c ', ',', TRawByteStringTokenizer.TOK_IGNORE_EMPTY or TRawByteStringTokenizer.TOK_TRIM);
	assertTrue('testRawByteStringTokenizer 45', st.Count = 2);
	assertTrue('testRawByteStringTokenizer 46', st[0] = 'a a');
	assertTrue('testRawByteStringTokenizer 47', st[1] = 'c c');
  st.Free;

	st := TRawByteStringTokenizer.Tokenize('abc,def,,ghi , jk,  l ', ',', TRawByteStringTokenizer.TOK_IGNORE_EMPTY or TRawByteStringTokenizer.TOK_TRIM);
	assertTrue('testRawByteStringTokenizer 48', st.Count = 5);
	assertTrue('testRawByteStringTokenizer 49', st[0] = 'abc');
	assertTrue('testRawByteStringTokenizer 50', st[1] = 'def');
	assertTrue('testRawByteStringTokenizer 51', st[2] = 'ghi');
	assertTrue('testRawByteStringTokenizer 52', st[3] = 'jk');
	assertTrue('testRawByteStringTokenizer 53', st[4] = 'l');
  st.Free;

	st := TRawByteStringTokenizer.Tokenize('abc,def,,ghi // jk,  l ', ',/', TRawByteStringTokenizer.TOK_IGNORE_EMPTY or TRawByteStringTokenizer.TOK_TRIM);
	assertTrue('testRawByteStringTokenizer 54', st.Count = 5);
	assertTrue('testRawByteStringTokenizer 55', st[0] = 'abc');
	assertTrue('testRawByteStringTokenizer 56', st[1] = 'def');
	assertTrue('testRawByteStringTokenizer 57', st[2] = 'ghi');
	assertTrue('testRawByteStringTokenizer 58', st[3] = 'jk');
	assertTrue('testRawByteStringTokenizer 59', st[4] = 'l');
  st.Free;

	st := TRawByteStringTokenizer.Tokenize('a/bc,def,,ghi // jk,  l ', ',/', TRawByteStringTokenizer.TOK_IGNORE_EMPTY or TRawByteStringTokenizer.TOK_TRIM);
	assertTrue('testRawByteStringTokenizer 60', st.Count = 6);
	assertTrue('testRawByteStringTokenizer 61', st[0] = 'a');
	assertTrue('testRawByteStringTokenizer 62', st[1] = 'bc');
	assertTrue('testRawByteStringTokenizer 63', st[2] = 'def');
	assertTrue('testRawByteStringTokenizer 64', st[3] = 'ghi');
	assertTrue('testRawByteStringTokenizer 65', st[4] = 'jk');
	assertTrue('testRawByteStringTokenizer 66', st[5] = 'l');
  st.Free;

	st := TRawByteStringTokenizer.Tokenize(',ab,cd,', ',');
	assertTrue('testRawByteStringTokenizer 67', st.Count = 4);
	assertTrue('testRawByteStringTokenizer 68', st[0] = '');
	assertTrue('testRawByteStringTokenizer 69', st[1] = 'ab');
	assertTrue('testRawByteStringTokenizer 70', st[2] = 'cd');
	assertTrue('testRawByteStringTokenizer 71', st[3] = '');
  st.Free;

	st := TRawByteStringTokenizer.Tokenize(',ab,cd,', ',', TRawByteStringTokenizer.TOK_IGNORE_EMPTY);
	assertTrue('testRawByteStringTokenizer 72', st.Count = 2);
	assertTrue('testRawByteStringTokenizer 73', st[0] = 'ab');
	assertTrue('testRawByteStringTokenizer 74', st[1] = 'cd');
  st.Free;

	st := TRawByteStringTokenizer.Tokenize(' , ab , cd, ', ',', TRawByteStringTokenizer.TOK_IGNORE_EMPTY or TRawByteStringTokenizer.TOK_TRIM);
	assertTrue('testRawByteStringTokenizer 75', st.Count = 2);
	assertTrue('testRawByteStringTokenizer 76', st[0] = 'ab');
	assertTrue('testRawByteStringTokenizer 77', st[1] = 'cd');
  st.Free;

	st := TRawByteStringTokenizer.Tokenize('1 : 2 , : 3 ', ':,', TRawByteStringTokenizer.TOK_IGNORE_EMPTY or TRawByteStringTokenizer.TOK_TRIM);
	assertTrue('testRawByteStringTokenizer 78', st.Count = 3);
	assertTrue('testRawByteStringTokenizer 79', st[0] = '1');
	assertTrue('testRawByteStringTokenizer 80', st[1] = '2');
	assertTrue('testRawByteStringTokenizer 81', st[2] = '3');
  st.Free;

	st := TRawByteStringTokenizer.Tokenize(' 2- ', '-', TRawByteStringTokenizer.TOK_TRIM);
	assertTrue('testRawByteStringTokenizer 82', st.Count = 2);
	assertTrue('testRawByteStringTokenizer 83', st[0] = '2');
	assertTrue('testRawByteStringTokenizer 84', st[1] = '');
  st.Free;

	st := TRawByteStringTokenizer.Tokenize('white; black; magenta, blue, green; yellow', ';,', TRawByteStringTokenizer.TOK_TRIM);
	assertTrue('testRawByteStringTokenizer 85', st.Count = 6);
	assertTrue('testRawByteStringTokenizer 86', st[0] = 'white');
	assertTrue('testRawByteStringTokenizer 87', st[1] = 'black');
	assertTrue('testRawByteStringTokenizer 88', st[2] = 'magenta');
	assertTrue('testRawByteStringTokenizer 89', st[3] = 'blue');
	assertTrue('testRawByteStringTokenizer 90', st[4] = 'green');
	assertTrue('testRawByteStringTokenizer 91', st[5] = 'yellow');
  st.Free;
end;

procedure TTestTokenizer.testStringTokenizer;
var
  st: TList<String>;
begin
	st := TStringTokenizer.Tokenize('', '');
	assertTrue('testStringTokenizer 1', st.Count = 0);
  st.Free;

	st := TStringTokenizer.Tokenize('', '', TStringTokenizer.TOK_IGNORE_EMPTY);
	assertTrue('testStringTokenizer 2', st.Count = 0);
  st.Free;

	st := TStringTokenizer.Tokenize('', '', TStringTokenizer.TOK_TRIM);
	assertTrue('testStringTokenizer 3', st.Count = 0);
  st.Free;

	st := TStringTokenizer.Tokenize('', '', TStringTokenizer.TOK_IGNORE_EMPTY or TStringTokenizer.TOK_TRIM);
	assertTrue('testStringTokenizer 4', st.Count = 0);
  st.Free;

	st := TStringTokenizer.Tokenize('abc', '');
	assertTrue('testStringTokenizer 5', st.Count = 1);
	assertTrue('testStringTokenizer 6', st[0] = 'abc');
  st.Free;

	st := TStringTokenizer.Tokenize('abc ', '', TStringTokenizer.TOK_TRIM);
	assertTrue('testStringTokenizer 7', st.Count = 1);
	assertTrue('testStringTokenizer 8', st[0] = 'abc');
  st.Free;

	st := TStringTokenizer.Tokenize('  abc ', '', TStringTokenizer.TOK_TRIM);
	assertTrue('testStringTokenizer 9', st.Count = 1);
	assertTrue('testStringTokenizer 10', st[0] = 'abc');
  st.Free;

	st := TStringTokenizer.Tokenize('  abc', '', TStringTokenizer.TOK_TRIM);
	assertTrue('testStringTokenizer 11', st.Count = 1);
	assertTrue('testStringTokenizer 12', st[0] = 'abc');
  st.Free;

	st := TStringTokenizer.Tokenize('abc', 'b');
	assertTrue('testStringTokenizer 13', st.Count = 2);
	assertTrue('testStringTokenizer 14', st[0] = 'a');
	assertTrue('testStringTokenizer 15', st[1] = 'c');
  st.Free;

	st := TStringTokenizer.Tokenize('abc', 'b', TStringTokenizer.TOK_IGNORE_EMPTY or TStringTokenizer.TOK_TRIM);
	assertTrue('testStringTokenizer 16', st.Count = 2);
	assertTrue('testStringTokenizer 17', st[0] = 'a');
	assertTrue('testStringTokenizer 18', st[1] = 'c');
  st.Free;

	st := TStringTokenizer.Tokenize('abc', 'bc');
	assertTrue('testStringTokenizer 19', st.Count = 3);
	assertTrue('testStringTokenizer 20', st[0] = 'a');
	assertTrue('testStringTokenizer 21', st[1] = '');
	assertTrue('testStringTokenizer 22', st[2] = '');
  st.Free;

	st := TStringTokenizer.Tokenize('abc', 'bc', TStringTokenizer.TOK_TRIM);
	assertTrue('testStringTokenizer 23', st.Count = 3);
	assertTrue('testStringTokenizer 24', st[0] = 'a');
	assertTrue('testStringTokenizer 25', st[1] = '');
	assertTrue('testStringTokenizer 26', st[2] = '');
  st.Free;

	st := TStringTokenizer.Tokenize('abc', 'bc', TStringTokenizer.TOK_IGNORE_EMPTY);
	assertTrue('testStringTokenizer 27', st.Count = 1);
	assertTrue('testStringTokenizer 28', st[0] = 'a');
  st.Free;

	st := TStringTokenizer.Tokenize('abc', 'bc', TStringTokenizer.TOK_IGNORE_EMPTY or TStringTokenizer.TOK_TRIM);
	assertTrue('testStringTokenizer 29', st.Count = 1);
	assertTrue('testStringTokenizer 30', st[0] = 'a');
  st.Free;

	st := TStringTokenizer.Tokenize('a a,c c', ',');
	assertTrue('testStringTokenizer 31', st.Count = 2);
	assertTrue('testStringTokenizer 32', st[0] = 'a a');
	assertTrue('testStringTokenizer 33', st[1] = 'c c');
  st.Free;

	st := TStringTokenizer.Tokenize('a a,c c', ',', TStringTokenizer.TOK_IGNORE_EMPTY or TStringTokenizer.TOK_TRIM);
	assertTrue('testStringTokenizer 34', st.Count = 2);
	assertTrue('testStringTokenizer 35', st[0] = 'a a');
	assertTrue('testStringTokenizer 36', st[1] = 'c c');
  st.Free;

	st := TStringTokenizer.Tokenize(' a a , , c c ', ',');
	assertTrue('testStringTokenizer 37', st.Count = 3);
	assertTrue('testStringTokenizer 38', st[0] = ' a a ');
	assertTrue('testStringTokenizer 39', st[1] = ' ');
	assertTrue('testStringTokenizer 40', st[2] = ' c c ');
  st.Free;

	st := TStringTokenizer.Tokenize(' a a , , c c ', ',', TStringTokenizer.TOK_TRIM);
	assertTrue('testStringTokenizer 41', st.Count = 3);
	assertTrue('testStringTokenizer 42', st[0] = 'a a');
	assertTrue('testStringTokenizer 43', st[1] = '');
	assertTrue('testStringTokenizer 44', st[2] = 'c c');
  st.Free;

	st := TStringTokenizer.Tokenize(' a a , , c c ', ',', TStringTokenizer.TOK_IGNORE_EMPTY or TStringTokenizer.TOK_TRIM);
	assertTrue('testStringTokenizer 45', st.Count = 2);
	assertTrue('testStringTokenizer 46', st[0] = 'a a');
	assertTrue('testStringTokenizer 47', st[1] = 'c c');
  st.Free;

	st := TStringTokenizer.Tokenize('abc,def,,ghi , jk,  l ', ',', TStringTokenizer.TOK_IGNORE_EMPTY or TStringTokenizer.TOK_TRIM);
	assertTrue('testStringTokenizer 48', st.Count = 5);
	assertTrue('testStringTokenizer 49', st[0] = 'abc');
	assertTrue('testStringTokenizer 50', st[1] = 'def');
	assertTrue('testStringTokenizer 51', st[2] = 'ghi');
	assertTrue('testStringTokenizer 52', st[3] = 'jk');
	assertTrue('testStringTokenizer 53', st[4] = 'l');
  st.Free;

	st := TStringTokenizer.Tokenize('abc,def,,ghi // jk,  l ', ',/', TStringTokenizer.TOK_IGNORE_EMPTY or TStringTokenizer.TOK_TRIM);
	assertTrue('testStringTokenizer 54', st.Count = 5);
	assertTrue('testStringTokenizer 55', st[0] = 'abc');
	assertTrue('testStringTokenizer 56', st[1] = 'def');
	assertTrue('testStringTokenizer 57', st[2] = 'ghi');
	assertTrue('testStringTokenizer 58', st[3] = 'jk');
	assertTrue('testStringTokenizer 59', st[4] = 'l');
  st.Free;

	st := TStringTokenizer.Tokenize('a/bc,def,,ghi // jk,  l ', ',/', TStringTokenizer.TOK_IGNORE_EMPTY or TStringTokenizer.TOK_TRIM);
	assertTrue('testStringTokenizer 60', st.Count = 6);
	assertTrue('testStringTokenizer 61', st[0] = 'a');
	assertTrue('testStringTokenizer 62', st[1] = 'bc');
	assertTrue('testStringTokenizer 63', st[2] = 'def');
	assertTrue('testStringTokenizer 64', st[3] = 'ghi');
	assertTrue('testStringTokenizer 65', st[4] = 'jk');
	assertTrue('testStringTokenizer 66', st[5] = 'l');
  st.Free;

	st := TStringTokenizer.Tokenize(',ab,cd,', ',');
	assertTrue('testStringTokenizer 67', st.Count = 4);
	assertTrue('testStringTokenizer 68', st[0] = '');
	assertTrue('testStringTokenizer 69', st[1] = 'ab');
	assertTrue('testStringTokenizer 70', st[2] = 'cd');
	assertTrue('testStringTokenizer 71', st[3] = '');
  st.Free;

	st := TStringTokenizer.Tokenize(',ab,cd,', ',', TStringTokenizer.TOK_IGNORE_EMPTY);
	assertTrue('testStringTokenizer 72', st.Count = 2);
	assertTrue('testStringTokenizer 73', st[0] = 'ab');
	assertTrue('testStringTokenizer 74', st[1] = 'cd');
  st.Free;

	st := TStringTokenizer.Tokenize(' , ab , cd, ', ',', TStringTokenizer.TOK_IGNORE_EMPTY or TStringTokenizer.TOK_TRIM);
	assertTrue('testStringTokenizer 75', st.Count = 2);
	assertTrue('testStringTokenizer 76', st[0] = 'ab');
	assertTrue('testStringTokenizer 77', st[1] = 'cd');
  st.Free;

	st := TStringTokenizer.Tokenize('1 : 2 , : 3 ', ':,', TStringTokenizer.TOK_IGNORE_EMPTY or TStringTokenizer.TOK_TRIM);
	assertTrue('testStringTokenizer 78', st.Count = 3);
	assertTrue('testStringTokenizer 79', st[0] = '1');
	assertTrue('testStringTokenizer 80', st[1] = '2');
	assertTrue('testStringTokenizer 81', st[2] = '3');
  st.Free;

	st := TStringTokenizer.Tokenize(' 2- ', '-', TStringTokenizer.TOK_TRIM);
	assertTrue('testStringTokenizer 82', st.Count = 2);
	assertTrue('testStringTokenizer 83', st[0] = '2');
	assertTrue('testStringTokenizer 84', st[1] = '');
  st.Free;

	st := TStringTokenizer.Tokenize('white; black; magenta, blue, green; yellow', ';,', TStringTokenizer.TOK_TRIM);
	assertTrue('testStringTokenizer 85', st.Count = 6);
	assertTrue('testStringTokenizer 86', st[0] = 'white');
	assertTrue('testStringTokenizer 87', st[1] = 'black');
	assertTrue('testStringTokenizer 88', st[2] = 'magenta');
	assertTrue('testStringTokenizer 89', st[3] = 'blue');
	assertTrue('testStringTokenizer 90', st[4] = 'green');
	assertTrue('testStringTokenizer 91', st[5] = 'yellow');
  st.Free;
end;

end.
