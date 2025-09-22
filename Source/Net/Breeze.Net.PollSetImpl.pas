unit Breeze.Net.PollSetImpl;

interface

uses Winapi.Windows, Winapi.Winsock2, System.SyncObjs, System.Generics.Collections,
Breeze.Net.SocketDefs, Breeze.Net.Socket, Breeze.Net.SocketImpl, Breeze.Net.DatagramSocket, Breeze.Net.SocketAddress, Breeze.Atomic,
wepoll_types, wepoll;

type

  TPollSetImpl = class abstract
  public
  	procedure Add(ASocket: Breeze.Net.Socket.TSocket; AMode: Integer); virtual; abstract;
  	procedure Remove(ASocket: Breeze.Net.Socket.TSocket); virtual; abstract;
	  function Has(ASocket: Breeze.Net.Socket.TSocket): Boolean; virtual; abstract;
	  function IsEmpty: Boolean; virtual; abstract;
  	procedure Update(ASocket: Breeze.Net.Socket.TSocket; AMode: Integer); virtual; abstract;
  	procedure Clear; virtual; abstract;
	  function Poll(ATimeout: Cardinal): TDictionary<Breeze.Net.Socket.TSocket, Integer>; virtual; abstract;
  	procedure WakeUp; virtual; abstract;
  	function Count: NativeInt; virtual; abstract;
  end;

  // реализаци€ пула через select
  TPollSetSelectImpl = class(TPollSetImpl)
  private
  	FMutex: TCriticalSection;
	  FMap: TDictionary<TSocket, Integer>;
  public
	  constructor Create;
    destructor Destroy; override;

  	procedure Add(ASocket: Breeze.Net.Socket.TSocket; AMode: Integer); override;
  	procedure Remove(ASocket: Breeze.Net.Socket.TSocket); override;
	  function Has(ASocket: Breeze.Net.Socket.TSocket): Boolean; override;
	  function IsEmpty: Boolean; override;
  	procedure Update(ASocket: Breeze.Net.Socket.TSocket; AMode: Integer); override;
  	procedure Clear; override;
	  function Poll(ATimeout: Cardinal): TDictionary<Breeze.Net.Socket.TSocket, Integer>; override;
  	procedure WakeUp; override;
  	function Count: NativeInt; override;
  end;

  // реализаци€ пула через эмул€цию epoll
  TPollSetEPollImpl = class(TPollSetImpl)
  private
  	FMutex: TCriticalSection;
	  FMap: TDictionary<Pointer, TPair<Breeze.Net.Socket.TSocket, Integer>>;
    FEventList: TList<epoll_event>;
    FEventFD: TAtomicInteger;
	  FEpollHandle: TAtomicValue<THandle>;
  	FEventSocket: TDatagramSocket;

    function GetNewMode(ASocketImpl: TSocketImpl; AMode: Integer): Integer;
    procedure SocketMapUpdate(ASocket: Breeze.Net.Socket.TSocket; AMode: Integer);
    function UpdateImpl(ASocket: Breeze.Net.Socket.TSocket; AMode: Integer): Integer;
    function AddImpl(ASocket: Breeze.Net.Socket.TSocket; AMode: Integer): Integer;
    function AddFD(AFd, AMode, AOp: Integer; APtr: Pointer = nil): Integer;
    class function KeepWaiting(AStartTime: Int64; var ARemainingTime: Int64): Boolean;
    function Eventfd(AParam1, AParam2: Integer): Integer;
  public
	  constructor Create;
    destructor Destroy; override;

  	procedure Add(ASocket: Breeze.Net.Socket.TSocket; AMode: Integer); override;
  	procedure Remove(ASocket: Breeze.Net.Socket.TSocket); override;
	  function Has(ASocket: Breeze.Net.Socket.TSocket): Boolean; override;
	  function IsEmpty: Boolean; override;
  	procedure Update(ASocket: Breeze.Net.Socket.TSocket; AMode: Integer); override;
  	procedure Clear; override;
	  function Poll(ATimeout: Cardinal): TDictionary<Breeze.Net.Socket.TSocket, Integer>; override;
  	procedure WakeUp; override;
  	function Count: NativeInt; override;
  end;

const
  EPOLL_NULL_EVENT: epoll_event = (events: 0; data: (ptr: nil; fd: 0; u32: 0; u64: 0; sock: 0; hnd: 0));

implementation

uses wepoll_err;

{ TPollSetSelectImpl }

procedure TPollSetSelectImpl.Add(ASocket: Breeze.Net.Socket.TSocket; AMode: Integer);
var
  LValue: Integer;
begin
	FMutex.Enter;
  try
		if FMap.TryGetValue(ASocket, LValue) then
      FMap.AddOrSetValue(ASocket, AMode or Lvalue)
    else
      FMap.Add(ASocket, AMode);
  finally
    FMutex.Leave;
  end;
end;

procedure TPollSetSelectImpl.Clear;
begin
	FMutex.Enter;
  try
		FMap.Clear;
  finally
    FMutex.Leave;
  end;
end;

function TPollSetSelectImpl.Count: NativeInt;
begin
	FMutex.Enter;
  try
		result := FMap.Count;
  finally
    FMutex.Leave;
  end;
end;

constructor TPollSetSelectImpl.Create;
begin
	FMutex := TCriticalSection.Create;
  FMap := TDictionary<Breeze.Net.Socket.TSocket, Integer>.Create;
end;

destructor TPollSetSelectImpl.Destroy;
begin
  FMutex.Free;
  FMap.Free;

  inherited;
end;

function TPollSetSelectImpl.IsEmpty: Boolean;
begin
	FMutex.Enter;
  try
		result := FMap.IsEmpty;
  finally
    FMutex.Leave;
  end;
end;

function TPollSetSelectImpl.Has(ASocket: Breeze.Net.Socket.TSocket): Boolean;
var
  LValue: Integer;
begin
	FMutex.Enter;
  try
		result := FMap.TryGetValue(ASocket, LValue);
  finally
    FMutex.Leave;
  end;
end;

function TPollSetSelectImpl.Poll(ATimeout: Cardinal): TDictionary<Breeze.Net.Socket.TSocket, Integer>;
var
	LFDRead: TFDSet;
	LFDWrite: TFDSet;
	LFDExcept: TFDSet;
	LErrorCode: Integer;
  LTimeVal: timeval;
  LItem: TPair<Breeze.Net.Socket.TSocket, Integer>;
  LRet: Integer;
  LNativeSocket: Winapi.Winsock2.TSocket;
  LValue: Integer;
begin
  if FMap.Count = 0 then
    exit(TDictionary<Breeze.Net.Socket.TSocket, Integer>.Create);

	FD_ZERO(LFDRead);
	FD_ZERO(LFDWrite);
	FD_ZERO(LFDExcept);

	FMutex.Enter;
  try
    for LItem in FMap do
    begin
      if (LItem.Value and POLL_READ) > 0 then
        _FD_SET(LItem.Key.NativeSocket, LFDRead);
      if (LItem.Value and POLL_WRITE) > 0 then
        _FD_SET(LItem.Key.NativeSocket, LFDWrite);
      if (LItem.Value and POLL_ERROR) > 0 then
        _FD_SET(LItem.Key.NativeSocket, LFDExcept);
    end;
  finally
    FMutex.Leave;
  end;

  LTimeVal.tv_sec := ATimeout div 1000;
  LTimeVal.tv_usec := (ATimeout mod 1000) * 1000000;
	while true do
  begin
    LRet := Winapi.Winsock2.select(0, @LFDRead, @LFDWrite, @LFDExcept, @LTimeVal);
    if LRet < 0 then
    begin
      // ошибка
      LErrorCode := TSocketImpl.lastError;
      if LErrorCode = WSAEINTR then
        continue;
    end
    else
    if LRet = 0 then
    begin
      // таймаут
      break;
    end
    else
    begin
      // событие
      break;
    end;
  end;

	if LRet < 0 then
    TSocketImpl.error;

  result := TDictionary<Breeze.Net.Socket.TSocket, Integer>.Create;

	FMutex.Enter;
  try
    for LItem in FMap do
    begin
      LNativeSocket := LItem.Key.NativeSocket;
		  if LNativeSocket = INVALID_SOCKET then
        continue;
      if FD_ISSET(LNativeSocket, LFDRead) then
      begin
        if result.TryGetValue(LItem.Key, LValue) then
          result[LItem.Key] := LValue or POLL_READ
        else
          result.Add(LItem.Key, POLL_READ);
      end;
      if FD_ISSET(LNativeSocket, LFDWrite) then
      begin
        if result.TryGetValue(LItem.Key, LValue) then
          result[LItem.Key] := LValue or POLL_WRITE
        else
          result.Add(LItem.Key, POLL_WRITE);
      end;
      if FD_ISSET(LNativeSocket, LFDExcept) then
      begin
        if result.TryGetValue(LItem.Key, LValue) then
          result[LItem.Key] := LValue or POLL_ERROR
        else
          result.Add(LItem.Key, POLL_ERROR);
      end;
    end;
  finally
    FMutex.Leave;
  end;
end;

procedure TPollSetSelectImpl.Remove(ASocket: Breeze.Net.Socket.TSocket);
begin
	FMutex.Enter;
  try
		FMap.Remove(ASocket);
  finally
    FMutex.Leave;
  end;
end;

procedure TPollSetSelectImpl.Update(ASocket: Breeze.Net.Socket.TSocket; AMode: Integer);
begin
	FMutex.Enter;
  try
		FMap.AddOrSetValue(ASocket, AMode);
  finally
    FMutex.Leave;
  end;
end;

procedure TPollSetSelectImpl.WakeUp;
begin

end;

{ TPollSetEPollImpl }

function close(AHandle: THandle): Integer;
begin
	result := epoll_close(AHandle);
end;

procedure TPollSetEPollImpl.Add(ASocket: Breeze.Net.Socket.TSocket; AMode: Integer);
var
  LNewMode, LError: Integer;
begin
  LNewMode := GetNewMode(ASocket.impl, AMode);
  LError := AddImpl(ASocket, LNewMode);
	if LError <> 0 then
  begin
	 	if errno = EEXIST then
      update(ASocket, LNewMode)
		else
      TSocketImpl.error;
  end;
end;

procedure TPollSetEPollImpl.Clear;
begin
	FMutex.Enter;
  try
		Close(FEpollHandle.Value);
		FMap.Clear;
		FEpollHandle.Value := epoll_create(1);
		if FEpollHandle.Value = 0 then
      TSocketImpl.error();
  finally
    FMutex.Leave;
  end;
  addFD(FEventFD.Value, POLL_READ, EPOLL_CTL_ADD);
end;

function TPollSetEPollImpl.Count: NativeInt;
begin
	FMutex.Enter;
  try
		result := FMap.Count;
  finally
    FMutex.Leave;
  end;
end;

constructor TPollSetEPollImpl.Create;
var
  LError: Integer;
  i: Integer;
begin
  FMutex := TCriticalSection.Create;
  FMap := TDictionary<Pointer, TPair<Breeze.Net.Socket.TSocket, Integer>>.Create;
  FEventList := TList<epoll_event>.Create;
  FEventFD := TAtomicInteger.Create(eventfd(0, 0));
  FEpollHandle := TAtomicValue<THandle>.Create(epoll_create(1));

  for i := 0 to FD_SETSIZE - 1 do
    FEventList.Add(EPOLL_NULL_EVENT);

  LError := addFD(FEventFD.Value, POLL_READ, EPOLL_CTL_ADD);
  if LError <> 0 then
  	TSocketImpl.error;
end;

destructor TPollSetEPollImpl.Destroy;
begin
  FEventSocket.Free;
  FMutex.Free;
  FMap.Free;
  FEventList.Free;
  FEventFD.Free;
  close(FEpollHandle.Value);
  FEpollHandle.Free;

  inherited;
end;

function TPollSetEPollImpl.IsEmpty: Boolean;
begin
	FMutex.Enter;
  try
		result := FMap.IsEmpty;
  finally
    FMutex.Leave;
  end;
end;

function TPollSetEPollImpl.has(ASocket: Breeze.Net.Socket.TSocket): Boolean;
var
  ASocketImpl: TSocketImpl;
begin
  ASocketImpl := ASocket.impl;

	FMutex.Enter;
  try
		result := (ASocketImpl <> nil) and (FMap.ContainsKey(ASocketImpl));
  finally
    FMutex.Leave;
  end;
end;

class function TPollSetEPollImpl.KeepWaiting(AStartTime: Int64; var ARemainingTime: Int64): Boolean;
var
  LEndTime: Int64;
  LWaited: Int64;
begin
  result := false;
  LEndTime := Winapi.Windows.GetTickCount64;
	LWaited := LEndTime - AStartTime;
	if LWaited < ARemainingTime then
  begin
		ARemainingTime := ARemainingTime - LWaited;
		result := true;
  end;
end;

function TPollSetEPollImpl.Poll(ATimeout: Cardinal): TDictionary<Breeze.Net.Socket.TSocket, Integer>;
var
  i: Integer;
  LRet: Integer;
  LRemainingTime: Int64;
  LStartTime: Int64;
  LValue: TPair<Breeze.Net.Socket.TSocket, Integer>;
  LReceiveValue: Byte;
  LSocketAddress: TSocketAddress;
  LResultValue: Integer;
begin
  result := TDictionary<TSocket, Integer>.Create;
  if FMap.Count = 0 then
    exit;

  LRemainingTime := ATimeout;

	while true do
  begin
    LStartTime := Winapi.Windows.GetTickCount64;
 		LRet := epoll_wait(FEpollHandle.Value, @FEventList.List[0], FEventList.Count, ATimeout);
 		if LRet = 0 then
		begin
			if keepWaiting(LStartTime, LRemainingTime) then
        continue;
      exit;
    end;

		// if we are hitting the events limit, resize it; even without resizing, the subseqent
		// calls would round-robin through the remaining ready sockets, but it's better to give
		// the call enough room once we start hitting the boundary
		if LRet >= FEventList.Count then
			FEventList.Capacity := FEventList.Count * 2
		else
    if LRet < 0 then
		begin
			// if interrupted and there's still time left, keep waiting
			if TSocketImpl.lastError = WSAEINTR then
      begin
  			if keepWaiting(LStartTime, LRemainingTime) then
          continue;
      end
  		else
        TSocketImpl.error;
    end;
		break;
  end;

	FMutex.Enter;
  try
		for i := 0 to LRet - 1 do
    begin
			if FEventList[i].data.ptr <> nil then
			begin
        if FMap.TryGetValue(FEventList[i].data.ptr, LValue) then
        begin
					if FEventList[i].events and (EPOLLIN or EPOLLRDNORM or EPOLLHUP) <> 0 then
          begin
            if not result.TryGetValue(LValue.Key, LResultValue) then
              LResultValue := 0;
            result.AddOrSetValue(LValue.Key, LResultValue or POLL_READ)
          end;
					if FEventList[i].events and (EPOLLOUT or EPOLLWRNORM) <> 0 then
          begin
            if not result.TryGetValue(LValue.Key, LResultValue) then
              LResultValue := 0;
            result.AddOrSetValue(LValue.Key, LResultValue or POLL_WRITE);
          end;
					if FEventList[i].events and EPOLLERR <> 0 then
          begin
            if not result.TryGetValue(LValue.Key, LResultValue) then
              LResultValue := 0;
            result.AddOrSetValue(LValue.Key, LResultValue or POLL_ERROR);
          end;
        end;
      end
			else
      if FEventList[i].events and EPOLLIN <> 0 then
      begin
				if FEventSocket <> nil then
				begin
					LSocketAddress.Create;
					FEventSocket.receiveFrom(@LReceiveValue, sizeof(LReceiveValue), LSocketAddress);
        end;
      end;
    end;
  finally
    FMutex.Leave;
  end;
end;

procedure TPollSetEPollImpl.remove(ASocket: Breeze.Net.Socket.TSocket);
var
  LFD: Winapi.Winsock2.TSocket;
  LEvent: epoll_event;
  LError: Integer;
begin
	LFD := ASocket.impl.NativeSocket;
	LEvent.events := 0;
	LEvent.data.ptr := nil;
	LError := epoll_ctl(FEpollHandle.Value, EPOLL_CTL_DEL, LFD, @LEvent);
	if LError <> 0 then
    TSocketImpl.error;

	FMutex.Enter;
  try
		FMap.Remove(ASocket.impl);
  finally
    FMutex.Leave;
  end;
end;

procedure TPollSetEPollImpl.Update(ASocket: Breeze.Net.Socket.TSocket; AMode: Integer);
var
  LError: Integer;
begin
	LError := updateImpl(ASocket, AMode);
	if LError <> 0 then
    TSocketImpl.error;
end;

procedure TPollSetEPollImpl.wakeUp;
var
  LValue: Byte;
begin
  LValue := 1;
  FEventSocket.sendTo(@LValue, sizeof(LValue), FEventSocket.address);
end;

function TPollSetEPollImpl.GetNewMode(ASocketImpl: TSocketImpl; AMode: Integer): Integer;
var
  LValue: TPair<Breeze.Net.Socket.TSocket, Integer>;
begin
  FMutex.Enter;
  try
    if FMap.TryGetValue(ASocketImpl, LValue) then
			AMode := AMode or LValue.Value;
		result := AMode;
  finally
    FMutex.Leave;
  end;
end;

procedure TPollSetEPollImpl.SocketMapUpdate(ASocket: Breeze.Net.Socket.TSocket; AMode: Integer);
var
  LSocketImpl: TSocketImpl;
begin
  LSocketImpl := ASocket.impl;
  FMutex.Enter;
  try
    FMap.AddOrSetValue(LSocketImpl, TPair<Breeze.Net.Socket.TSocket, Integer>.Create(ASocket, AMode));
  finally
    FMutex.Leave;
  end;
end;

function TPollSetEPollImpl.UpdateImpl(ASocket: Breeze.Net.Socket.TSocket; AMode: Integer): Integer;
var
  LSocketImpl: TSocketImpl;
begin
	LSocketImpl := ASocket.impl;
	result := AddFD(LSocketImpl.NativeSocket, AMode, EPOLL_CTL_MOD, LSocketImpl);
  if result = 0 then
    SocketMapUpdate(ASocket, AMode);
end;

function TPollSetEPollImpl.AddImpl(ASocket: Breeze.Net.Socket.TSocket; AMode: Integer): Integer;
var
  LSocketImpl: TSocketImpl;
  LNewMode: Integer;
begin
	LSocketImpl := ASocket.impl;
	LNewMode := getNewMode(LSocketImpl, AMode);
	result := AddFD(LSocketImpl.NativeSocket, LNewMode, EPOLL_CTL_ADD, LSocketImpl);
  if result = 0 then
    SocketMapUpdate(ASocket, LNewMode);
end;

function TPollSetEPollImpl.AddFD(AFd, AMode, AOp: Integer; APtr: Pointer): Integer;
var
  LEvent: epoll_event;
begin
	LEvent.events := 0;
	if (AMode and POLL_READ) <> 0 then
		LEvent.events := LEvent.events or EPOLLIN;
	if (AMode and POLL_WRITE) <> 0  then
		LEvent.events := LEvent.events or EPOLLOUT;
	if (AMode and POLL_ERROR) <> 0  then
		LEvent.events := LEvent.events or EPOLLERR;
  LEvent.data.ptr := APtr;
	result := epoll_ctl(FEpollHandle.Value, AOp, AFd, @LEvent);
end;

function TPollSetEPollImpl.Eventfd(AParam1, AParam2: Integer): Integer;
var
  LEventSA: TSocketAddress;
begin
	LEventSA := TSocketAddress.Create('127.0.0.238', 0);
	if FEventSocket = nil then
	begin
		FEventSocket := TDatagramSocket.Create(LeventSA, true);
		FEventSocket.setBlocking(false);
  end;
	result := FEventSocket.impl.NativeSocket;
end;

end.

