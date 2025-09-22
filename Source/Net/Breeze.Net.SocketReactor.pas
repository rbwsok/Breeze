unit Breeze.Net.SocketReactor;

interface

uses
  System.Generics.Collections, System.Classes,
  Breeze.Net.SocketDefs, Breeze.Net.Socket, Breeze.Net.PollSet, Breeze.Net.SocketAddress;

type

  TSocketReactor = class(TThread)
  public
    type
      TRSocketReactorEventCallback = procedure(AReactor: TSocketReactor) of object;

      TRSocketEventCallback = procedure(ASocket: Breeze.Net.Socket.TSocket; AUserData: Pointer) of object;

      TSocketReactorItem = class
      public
        FSocket: TSocket;
        FOnReadCallback: TRSocketEventCallback;
        FOnWriteCallback: TRSocketEventCallback;
        FOnExceptionCallback: TRSocketEventCallback;
        FUserData: Pointer;
      end;

      TRectorItemCallback = reference to function (item: TSocketReactorItem): Boolean;
  private
    FPollSet: TPollSet;

    FPollTimeout: Integer;

    FItems: TDictionary<Breeze.Net.Socket.TSocket, TSocketReactorItem>;

    FOnTimeout: TRSocketReactorEventCallback;
    FOnShutdown: TRSocketReactorEventCallback;

    function GetItem(ASocket: Breeze.Net.Socket.TSocket): TSocketReactorItem;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Execute; override;

    procedure Run;

    procedure Stop;
    procedure StopAndWait;

  	function Has(ASocket: Breeze.Net.Socket.TSocket): Boolean;

    procedure Add(ASocket: Breeze.Net.Socket.TSocket; AOnReadCallback, AOnWriteCallback, AOnExceptionCallback: TRSocketEventCallback; AUserData: Pointer);

    procedure Remove(ASocket: Breeze.Net.Socket.TSocket);

    function Count: Integer;

    function Process: Integer;

    procedure Clear;

    procedure ProcessItems(callback: TRectorItemCallback);

    procedure SetTimeout(AValue: Integer);
    function GetTimeout: Integer;

    property OnTimeout: TRSocketReactorEventCallback read FOnTimeout write FOnTimeout;
    property OnShutdown: TRSocketReactorEventCallback read FOnShutdown write FOnShutdown;
  end;

implementation

{ TSocketReactor }

procedure TSocketReactor.Add(ASocket: Breeze.Net.Socket.TSocket; AOnReadCallback, AOnWriteCallback, AOnExceptionCallback: TRSocketEventCallback; AUserData: Pointer);
var
  LItem: TSocketReactorItem;
  LMode: Integer;
begin
  LItem := TSocketReactorItem.Create;
  LItem.FSocket := ASocket;
  LItem.FOnReadCallback := AOnReadCallback;
  LItem.FOnWriteCallback := AOnWriteCallback;
  LItem.FOnExceptionCallback := AOnExceptionCallback;
  LItem.FUserData := AUserData;

  if FItems.ContainsKey(ASocket) then
    FItems.AddOrSetValue(ASocket, LItem)
  else
    FItems.Add(ASocket, LItem);

  LMode := 0;
  if @AOnReadCallback <> nil then
    LMode := LMode or POLL_READ;
  if @AOnWriteCallback <> nil then
    LMode := LMode or POLL_WRITE;
  if @AOnExceptionCallback <> nil then
    LMode := LMode or POLL_ERROR;

  FPollSet.Add(ASocket, LMode);
end;

procedure TSocketReactor.Clear;
var
  LSocketKey: Breeze.Net.Socket.TSocket;
  LItem: TSocketReactorItem;
begin
  for LSocketKey in FItems.Keys do
  begin
    LItem := GetItem(LSocketKey);
    if LItem <> nil then
      LItem.Free;
  end;

  FItems.Clear;
end;

function TSocketReactor.Count: Integer;
begin
  result := FItems.Count;
end;

constructor TSocketReactor.Create;
begin
  inherited Create(true);

  FItems := TDictionary<Breeze.Net.Socket.TSocket, TSocketReactorItem>.Create;

  FPollSet := TPollSet.Create;

  FPollTimeout := 1000;
end;

destructor TSocketReactor.Destroy;
begin
  Stop;

  if not self.Suspended then
    WaitFor;

  FPollSet.Free;

  Clear;
  FItems.Free;

  inherited;
end;

procedure TSocketReactor.Execute;
begin
  inherited;

  while not Terminated do
  begin
    if Process = 0 then
      Sleep(1);
  end;

  if @FOnShutdown <> nil then
    FOnShutdown(self);
end;

function TSocketReactor.GetItem(ASocket: Breeze.Net.Socket.TSocket): TSocketReactorItem;
begin
  FItems.TryGetValue(ASocket, result);
end;

function TSocketReactor.GetTimeout: Integer;
begin
  result := FPollTimeout;
end;

function TSocketReactor.Has(ASocket: Breeze.Net.Socket.TSocket): Boolean;
begin
  result := FItems.ContainsKey(ASocket);
end;

function TSocketReactor.Process: Integer;
var
  LSocketMap: TDictionary<TSocket, Integer>;
  LSocketMapItem: TPair<TSocket, Integer>;
  LItem: TSocketReactorItem;
begin
  LSocketMap := FPollSet.Poll(FPollTimeout);
  result := LSocketMap.Count;

  if result > 0 then
  begin
    for LSocketMapItem in LSocketMap do
    begin
      LItem := GetItem(LSocketMapItem.Key);
      if LItem <> nil then
      begin
        if ((LSocketMapItem.Value and POLL_READ) > 0) and (@LItem.FOnReadCallback <> nil) then
          LItem.FOnReadCallback(LSocketMapItem.Key, LItem.FUserData);
        if ((LSocketMapItem.Value and POLL_WRITE) > 0) and (@LItem.FOnWriteCallback <> nil) then
          LItem.FOnWriteCallback(LSocketMapItem.Key, LItem.FUserData);
        if ((LSocketMapItem.Value and POLL_ERROR) > 0) and (@LItem.FOnExceptionCallback <> nil) then
          LItem.FOnExceptionCallback(LSocketMapItem.Key, LItem.FUserData);
      end;
    end;
  end
  else
  begin
    if @FOnTimeout <> nil then
      FOnTimeout(self);
  end;

  LSocketMap.Free;
end;

procedure TSocketReactor.ProcessItems(callback: TRectorItemCallback);
var
  LItem: TSocketReactorItem;
  LSocket: TSocket;
begin
  if self = nil then
    exit;

  if FItems = nil then
    exit;
  for LSocket in FItems.Keys do
  begin
    LItem := FItems[LSocket];
    if @callback <> nil then
    begin
      if callback(LItem) = true then
        exit;
    end;
  end;
end;

procedure TSocketReactor.Remove(ASocket: Breeze.Net.Socket.TSocket);
var
  LItem: TSocketReactorItem;
begin
  LItem := GetItem(ASocket);
  if LItem <> nil then
    LItem.Free;

  FItems.Remove(ASocket);
  FPollSet.Remove(ASocket);
end;

procedure TSocketReactor.Run;
begin
  self.Start;
end;

procedure TSocketReactor.SetTimeout(AValue: Integer);
begin
  FPollTimeout := AValue;
end;

procedure TSocketReactor.Stop;
begin
  self.Terminate;
end;

procedure TSocketReactor.StopAndWait;
begin
  Stop;
  if not self.Suspended then
    WaitFor;
end;

end.
