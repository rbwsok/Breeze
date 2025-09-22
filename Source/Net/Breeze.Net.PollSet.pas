unit Breeze.Net.PollSet;

interface

uses
  System.Generics.Collections,
  Breeze.Net.Socket, Breeze.Net.SocketDefs, Breeze.Net.PollSetImpl;

type
  TPollSet = class
  private
	  FImpl: TPollSetImpl;
  public
	  constructor Create;
    destructor Destroy; override;

	  procedure Add(const ASocket: Breeze.Net.Socket.TSocket; AMode: Integer);
		/// Adds the given socket to the set, for polling with
		/// the given mode, which can be an OR'd combination of
		/// POLL_READ, POLL_WRITE and POLL_ERROR.
		/// Subsequent socket additions to the PollSet are mode-cumulative,
		/// so the following code:
		///
		/// StreamSocket ss;
		/// PollSet ps;
		/// ps.add(ss, PollSet::POLL_READ);
		/// ps.add(ss, PollSet::POLL_WRITE);
		///
		/// shall result in the socket being monitored for read and write,
		/// equivalent to this:
		///
		/// ps.update(ss, PollSet::POLL_READ | PollSet::POLL_WRITE);

  	procedure Remove(const ASocket: Breeze.Net.Socket.TSocket);
		/// Removes the given socket from the set.

  	procedure Update(const ASocket: TSocket; AMode: Integer);
		/// Updates the mode of the given socket. If socket does
		/// not exist in the PollSet, it is silently added. For
		/// an existing socket, any prior mode is overwritten.
		/// Updating socket is non-mode-cumulative.
		///
		/// The following code:
		///
		/// StreamSocket ss;
		/// PollSet ps;
		/// ps.update(ss, PollSet::POLL_READ);
		/// ps.update(ss, PollSet::POLL_WRITE);
		///
		/// shall result in the socket being monitored for write only.

  	function Has(const ASocket: Breeze.Net.Socket.TSocket): Boolean;
		/// Returns true if socket is registered for polling.

   	function IsEmpty: Boolean;
		/// Returns true if no socket is registered for polling.

	  function Count: Integer;
		/// Returns the number of sockets monitored.

	  procedure Clear;
		/// Removes all sockets from the PollSet.

  	function Poll(ATimeout: Cardinal): TDictionary<TSocket, Integer>;
		/// Waits until the state of at least one of the PollSet's sockets
		/// changes accordingly to its mode, or the timeout expires.
		/// Returns a PollMap containing the sockets that have had
		/// their state changed.

	  procedure WakeUp;
		/// Wakes up a waiting PollSet.
		/// Any errors that occur during this call are ignored.
		/// On platforms/implementations where this functionality
		/// is not available, it does nothing.
  end;

implementation

{ TPollSet }

procedure TPollSet.Add(const ASocket: Breeze.Net.Socket.TSocket; AMode: Integer);
begin
  FImpl.Add(ASocket, AMode);
end;

procedure TPollSet.Clear;
begin
  FImpl.Clear;
end;

function TPollSet.Count: Integer;
begin
  result := FImpl.Count;
end;

constructor TPollSet.Create;
begin
//	FImpl := TPollSetSelectImpl.Create;
	FImpl := TPollSetEPollImpl.Create;
end;

destructor TPollSet.Destroy;
begin
  FImpl.Free;
  inherited;
end;

function TPollSet.IsEmpty: Boolean;
begin
  result := FImpl.IsEmpty;
end;

function TPollSet.Has(const ASocket: Breeze.Net.Socket.TSocket): Boolean;
begin
  result := FImpl.Has(ASocket);
end;

function TPollSet.Poll(ATimeout: Cardinal): TDictionary<TSocket, Integer>;
begin
  result := FImpl.Poll(ATimeout);
end;

procedure TPollSet.Remove(const ASocket: Breeze.Net.Socket.TSocket);
begin
  FImpl.Remove(ASocket);
end;

procedure TPollSet.Update(const ASocket: Breeze.Net.Socket.TSocket; AMode: Integer);
begin
  FImpl.Update(ASocket, AMode);
end;

procedure TPollSet.WakeUp;
begin
  FImpl.WakeUp;
end;

end.
