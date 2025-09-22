unit DialogServer;

interface

uses System.SysUtils, System.Classes, System.SyncObjs, System.Generics.Collections,
  Breeze.Net.SocketAddress, Breeze.Net.StreamSocket, Breeze.Net.SocketDefs, Breeze.Net.ServerSocket,
  Breeze.Net.DialogSocket,
  Breeze.Atomic;

type

  TDialogServer = class(TThread)
    /// A server for testing FTPClientSession and friends.
  private
    _socket: TServerSocket;
    _mutex: TCriticalSection;
    _nextResponses: TList<AnsiString>;
    _lastCommands: TList<AnsiString>;
    _acceptCommands: TAtomicBool;
    _log: TAtomicBool;
  public
    constructor Create(AAcceptCommands: Boolean = true);
    /// Creates the DialogServer.

    destructor Destroy; override;
    /// Destroys the DialogServer.

    procedure Execute; override;

    function Port: Integer;
    /// Returns the port the echo server is
    /// listening on.

    procedure Run;
    /// Does the work.

    function LastCommand: AnsiString;
    /// Returns the last command received by the server.

    function PopCommand: AnsiString;
    /// Pops the next command from the list of received commands.

    function PopCommandWait: AnsiString;
    /// Pops the next command from the list of received commands.
    /// Waits until a command is available.

    function LastCommands: TList<AnsiString>;
    /// Returns the last command received by the server.

    procedure AddResponse(const response: AnsiString);
    /// Sets the next response returned by the server.

    procedure ClearCommands;
    /// Clears all commands.

    procedure ClearResponses;
    /// Clears all responses.

    procedure Log(flag: Boolean);
    /// Enables or disables logging to stdout.
  end;

implementation

{ TDialogServer }

procedure TDialogServer.AddResponse(const response: AnsiString);
begin
  _mutex.Enter;
  try
    _nextResponses.Add(response);
  finally
    _mutex.Leave;
  end;
end;

procedure TDialogServer.ClearCommands;
begin
  _mutex.Enter;
  try
    _lastCommands.Clear;
  finally
    _mutex.Leave;
  end;
end;

procedure TDialogServer.ClearResponses;
begin
  _mutex.Enter;
  try
    _nextResponses.Clear;
  finally
    _mutex.Leave;
  end;
end;

constructor TDialogServer.Create(AAcceptCommands: Boolean);
var
  sa: TSocketAddress;
begin
  sa.Create;
  _socket := TServerSocket.Create(sa);

  _mutex := TCriticalSection.Create;

  _nextResponses := TList<AnsiString>.Create;
  _lastCommands := TList<AnsiString>.Create;

  _acceptCommands := TAtomicBool.Create(AAcceptCommands);
  _log := TAtomicBool.Create(false);

  inherited Create(false);
end;

destructor TDialogServer.Destroy;
begin
  self.Terminate;
  self.WaitFor;

  inherited;
end;

function TDialogServer.LastCommand: AnsiString;
begin
  _mutex.Enter;
  try
    if _lastCommands.IsEmpty then
      result := ''
    else
      result := _lastCommands.Last;
  finally
    _mutex.Leave;
  end;
end;

function TDialogServer.LastCommands: TList<AnsiString>;
begin
  _mutex.Enter;
  try
    result := _lastCommands;
  finally
    _mutex.Leave;
  end;
end;

procedure TDialogServer.Log(flag: Boolean);
begin
  _log.Value := flag;
end;

function TDialogServer.PopCommand: AnsiString;
begin
  result := '';
  _mutex.Enter;
  try
    if not _lastCommands.IsEmpty then
    begin
      result := _lastCommands.First;
      _lastCommands.ExtractAt(0);
    end;
  finally
    _mutex.Leave;
  end;
end;

function TDialogServer.PopCommandWait: AnsiString;
begin
  result := PopCommand;
  while result = '' do
  begin
    Sleep(100);
    result := PopCommand;
  end;
end;

function TDialogServer.Port: Integer;
begin
  result := _socket.address.Port;
end;

procedure TDialogServer.Run;
begin
  Start;
end;

procedure TDialogServer.Execute;
var
  ds: TDialogSocket;
  command: AnsiString;
begin
  inherited;

  while not Terminated do
  begin
    if _socket.poll(250, TPollMode.SELECT_READ) then
    begin
      ds := TDialogSocket(_socket.acceptConnection);
      begin
        _mutex.Enter;
        try
          if not _nextResponses.IsEmpty then
          begin
            ds.sendMessage(_nextResponses.First);
            _nextResponses.Delete(0);
          end;
        finally
          _mutex.Leave;
        end;
      end;

      if _acceptCommands.Value then
      begin
        try
          while ds.receiveMessage(command) do
          begin
            if _log.Value then
              writeln('>> ' + command);
            _mutex.Enter;
            try
              _lastCommands.Add(command);
              if not _nextResponses.IsEmpty then
              begin
                if _log.Value then
                  writeln('<< ' + _nextResponses.First);
                ds.sendMessage(_nextResponses.First);
                _nextResponses.Delete(0);
              end;
            finally
              _mutex.Leave;
            end;
          end;
        except
          on E: Exception do
            writeln('DialogServer: ' + E.Message);
        end;
      end;
    end;
  end;
end;

end.
