unit Breeze.Net.DialogSocket;

interface

uses System.Character, System.Win.Crtl,
  Breeze.Net.SocketAddress, Breeze.Net.Socket, Breeze.Net.StreamSocket;

type

  TDialogSocket = class(TStreamSocket)
	/// DialogSocket is a subclass of StreamSocket that
	/// can be used for implementing request-response
	/// based client server connections.
	///
	/// A request is always a single-line command terminated
	/// by CR-LF.
	///
	/// A response can either be a single line of text terminated
	/// by CR-LF, or multiple lines of text in the format used
	/// by the FTP and SMTP protocols.
	///
	/// Limited support for the TELNET protocol (RFC 854) is
	/// available.
	///
	/// Warning: Do not call receiveBytes() on a DialogSocket.
	/// Due to internal buffering in DialogSocket, receiveBytes()
	/// may return an unexpected result and interfere with
	/// DialogSocket's buffering. Use receiveRawBytes() instead.

  type
  	TelnetCodes = (
      TELNET_SE   = 240,
      TELNET_NOP  = 241,
      TELNET_DM   = 242,
      TELNET_BRK  = 243,
      TELNET_IP   = 244,
      TELNET_AO   = 245,
      TELNET_AYT  = 246,
      TELNET_EC   = 247,
      TELNET_EL   = 248,
      TELNET_GA   = 249,
      TELNET_SB   = 250,
      TELNET_WILL = 251,
      TELNET_WONT = 252,
      TELNET_DO   = 253,
      TELNET_DONT = 254,
      TELNET_IAC  = 255
    );
  const
 		RECEIVE_BUFFER_SIZE = 1024;
  	MAX_LINE_LENGTH     = 4096;
	  EOF_CHAR            = -1;
  private
	  FBuffer: PAnsiChar;
  	FNext: PAnsiChar;
	  FEnd: PAnsiChar;
  protected
	  procedure AllocBuffer;
	  procedure Refill;
    function ReceiveLine(var ALine: AnsiString; lineLengthLimit: Integer = 0): Boolean;
    function ReceiveStatusLine(var ALine: AnsiString; lineLengthLimit: Integer = 0): Integer;
  public
	  constructor Create; overload;
		/// Creates an unconnected stream socket.
		///
		/// Before sending or receiving data, the socket
		/// must be connected with a call to connect().

//	  constructor Create(const AAddress: TSocketAddress); overload;
		/// Creates a stream socket and connects it to
		/// the socket specified by address.

	  constructor Create(const ASocket: Breeze.Net.Socket.TSocket); overload;
		/// Creates the DialogSocket with the SocketImpl
		/// from another socket. The SocketImpl must be
		/// a StreamSocketImpl, otherwise an InvalidArgumentException
		/// will be thrown.

    destructor Destroy; override;
		/// Destroys the DialogSocket.

    procedure Assign(const ASocket: Breeze.Net.Socket.TSocket); overload; override;
		/// Assignment operator.
		///
		/// Releases the socket's SocketImpl and
		/// attaches the SocketImpl from the other socket and
		/// increments the reference count of the SocketImpl.

	  procedure SendByte(AValue: Byte);
		/// Sends a single byte over the socket connection.

	  procedure SendString(AValue: PAnsiChar); overload;
		/// Sends the given null-terminated string over
		/// the socket connection.

	  procedure SendString(const AValue: AnsiString); overload;
		/// Sends the given string over the socket connection.

	  procedure SendMessage(const AMessage: AnsiString); overload;
		/// Appends a CR-LF sequence to the message and sends it
		/// over the socket connection.

	  procedure SendMessage(const AMessage: AnsiString; const AArg: AnsiString); overload;
		/// Concatenates message and arg, separated by a space, appends a
		/// CR-LF sequence, and sends the result over the socket connection.

	  procedure SendMessage(const AMessage: AnsiString; const AArg1: AnsiString; const AArg2: AnsiString); overload;
		/// Concatenates message and args, separated by a space, appends a
		/// CR-LF sequence, and sends the result over the socket connection.

    function ReceiveMessage(var AMessage: AnsiString): Boolean;
		/// Receives a single-line message, terminated by CR-LF,
		/// from the socket connection and appends it to response.
		///
		/// Returns true if a message has been read or false if
		/// the connection has been closed by the peer.

	  function receiveStatusMessage(var AMessage: AnsiString): Integer;
		/// Receives a single-line or multi-line response from
		/// the socket connection. The format must be according to
		/// one of the response formats specified in the FTP (RFC 959)
		/// or SMTP (RFC 2821) specifications.
		///
		/// The first line starts with a 3-digit status code.
		/// Following the status code is either a space character (' ' )
		/// (in case of a single-line response) or a minus character ('-')
		/// in case of a multi-line response. The following lines can have
		/// a three-digit status code followed by a minus-sign and some
		/// text, or some arbitrary text only. The last line again begins
		/// with a three-digit status code (which must be the same as the
		/// one in the first line), followed by a space and some arbitrary
		/// text. All lines must be terminated by a CR-LF sequence.
		///
		/// The response contains all response lines, separated by a newline
		/// character, including the status code. The status code is returned.
		/// If the response line does not contain a status code, 0 is returned.

	  function Get: Integer;
		/// Reads one character from the connection.
		///
		/// Returns -1 (EOF_CHAR) if no more characters are available.

	  function Peek: Integer;
		/// Returns the character that would be returned by the next call
		/// to get(), without actually extracting the character from the
		/// buffer.
		///
		/// Returns -1 (EOF_CHAR) if no more characters are available.

	  function ReceiveRawBytes(ABuffer: Pointer; ALength: Integer): Integer;
		/// Read up to length bytes from the connection and place
		/// them into buffer. If there are data bytes in the internal
		/// buffer, these bytes are returned first.
		///
		/// Use this member function instead of receiveBytes().
		///
		/// Returns the number of bytes read, which may be
		/// less than requested.

    procedure Synch;
		/// Sends a TELNET SYNCH signal over the connection.
		///
		/// According to RFC 854, a TELNET_DM char is sent
		/// via sendUrgent().

    procedure SendTelnetCommand(ACommand: Byte); overload;
		/// Sends a TELNET command sequence (TELNET_IAC followed
		/// by the given command) over the connection.

    procedure SendTelnetCommand(ACommand: Byte; AArg: Byte); overload;
		/// Sends a TELNET command sequence (TELNET_IAC followed
		/// by the given command, followed by arg) over the connection.
  end;

implementation

uses Breeze.Exception;

{ TDialogSocket }

procedure TDialogSocket.AllocBuffer;
begin
	GetMem(FBuffer, RECEIVE_BUFFER_SIZE);
	FNext := FBuffer;
	FEnd := FBuffer;
end;

procedure TDialogSocket.Assign(const ASocket: Breeze.Net.Socket.TSocket);
begin
	inherited Assign(ASocket);
	FNext := FBuffer;
	FEnd  := FBuffer;
end;

constructor TDialogSocket.Create;
begin
  inherited;
  AllocBuffer;
end;

{constructor TDialogSocket.Create(const AAddress: TSocketAddress);
begin
	inherited Create(AAddress);
	AllocBuffer;
end;}

constructor TDialogSocket.Create(const ASocket: Breeze.Net.Socket.TSocket);
begin
	inherited Create(ASocket);
	AllocBuffer;
end;

destructor TDialogSocket.Destroy;
begin
  FreeMem(FBuffer);
  inherited;
end;

function TDialogSocket.Get: Integer;
begin
  Refill;

  result := EOF_CHAR;
	if FNext <> FEnd then
  begin
    result := Integer(FNext^);
    inc(FNext)
  end;
end;

function TDialogSocket.Peek: Integer;
begin
  Refill;

  result := EOF_CHAR;
	if FNext <> FEnd then
    result := Integer(FNext^);
end;

function TDialogSocket.ReceiveLine(var ALine: AnsiString; lineLengthLimit: Integer): Boolean;
var
  ch: Integer;
begin
	// An old wisdom goes: be strict in what you emit
	// and generous in what you accept.
	ch := Get;
	while (ch <> EOF_CHAR) and (ch <> 13) and (ch <> 10) do
  begin
		if (lineLengthLimit = 0) or (Length(ALine) < lineLengthLimit) then
			ALine := ALine + AnsiChar(ch)
		else
			raise IOException.Create('Line too long');
		ch := get();
	end;

	if (ch = 13) and (peek = 10) then
		Get
	else
  if ch = EOF_CHAR then
		exit(false);

	result := true;
end;

function TDialogSocket.ReceiveMessage(var AMessage: AnsiString): Boolean;
begin
  AMessage := '';
	result := ReceiveLine(AMessage, MAX_LINE_LENGTH);
end;

function TDialogSocket.ReceiveRawBytes(ABuffer: Pointer; ALength: Integer): Integer;
var
  n: Integer;
begin
	Refill;
	n := FEnd - FNext;
	if n > ALength then
    n := ALength;
	memcpy(ABuffer, FNext, n);
	FNext := FNext + n;
	result := n;
end;

function TDialogSocket.ReceiveStatusLine(var ALine: AnsiString; lineLengthLimit: Integer): Integer;
var
  LStatus: Integer;
  ch, n: Integer;
begin
	LStatus := 0;
	ch := Get;
	if ch <> EOF_CHAR then
    ALine := ALine + AnsiChar(ch);

	n := 0;
	while (Char(ch).IsDigit) and (n < 3) do
	begin
		LStatus := LStatus * 10;
		LStatus := LStatus + ch - ord('0');
		inc(n);
		ch := Get;
		if ch <> EOF_CHAR then
      ALine := ALine + AnsiChar(ch);
	end;

	if n = 3 then
	begin
		if ch = ord('-') then
			LStatus := -LStatus;
	end
	else
    LStatus := 0;

	if ch <> EOF_CHAR then
    receiveLine(ALine, lineLengthLimit);

	result := LStatus;
end;

function TDialogSocket.ReceiveStatusMessage(var AMessage: AnsiString): Integer;
var
  LStatus: Integer;
begin
	AMessage := '';
	LStatus := ReceiveStatusLine(AMessage, MAX_LINE_LENGTH);
	if LStatus < 0 then
	begin
		while LStatus <= 0 do
    begin
			AMessage := AMessage + #10;
			LStatus := ReceiveStatusLine(AMessage, Length(AMessage) + MAX_LINE_LENGTH);
		end;
  end;
	result := LStatus;
end;

procedure TDialogSocket.Refill;
var
  LReadBytes: Integer;
begin
	if FNext = FEnd then
  begin
		LReadBytes := ReceiveBytes(FBuffer, RECEIVE_BUFFER_SIZE);
		if LReadBytes > 0 then
		begin
			FNext := FBuffer;
			FEnd  := FBuffer + LReadBytes;
		end;
  end;
end;

procedure TDialogSocket.SendByte(AValue: Byte);
begin
	SendBytes(@AValue, 1);
end;

procedure TDialogSocket.SendMessage(const AMessage: AnsiString);
begin
	sendString(AMessage + #13#10);
end;

procedure TDialogSocket.SendMessage(const AMessage, AArg1, AArg2: AnsiString);
var
  LLine: AnsiString;
begin
  LLine := AMessage + ' ' + AArg1;
	if Length(AArg2) <> 0 then
		LLine := LLine + ' ' + AArg2;
  LLine := LLine + #13#10;
	sendString(LLine);
end;

procedure TDialogSocket.SendMessage(const AMessage, AArg: AnsiString);
var
  LLine: AnsiString;
begin
  LLine := AMessage;
	if Length(AArg) <> 0 then
		LLine := LLine + ' ' + AArg;
  LLine := LLine + #13#10;
	sendString(LLine);
end;

procedure TDialogSocket.SendString(const AValue: AnsiString);
begin
	sendBytes(@AValue[1], Length(AValue));
end;

procedure TDialogSocket.SendString(AValue: PAnsiChar);
var
  LStr: AnsiString;
begin
  LStr := AValue;
	sendBytes(@LStr[1], Length(LStr));
end;

procedure TDialogSocket.SendTelnetCommand(ACommand, AArg: Byte);
var
  LBuffer: RawByteString;
begin
  LBuffer := AnsiChar(TELNET_IAC) + AnsiChar(ACommand) + AnsiChar(AArg);
	sendBytes(@LBuffer[1], 2);
end;

procedure TDialogSocket.SendTelnetCommand(ACommand: Byte);
var
  LBuffer: RawByteString;
begin
  LBuffer := AnsiChar(TELNET_IAC) + AnsiChar(ACommand);
	sendBytes(@LBuffer[1], 2);
end;

procedure TDialogSocket.Synch;
begin
	SendUrgent(AnsiChar(TELNET_DM));
end;

end.

