unit Breeze.Net.ServerSocketImpl;

interface

uses Breeze.Net.SocketImpl;

type

  TServerSocketImpl = class(TSocketImpl)
	/// This class implements a TCP server socket.
  public
  	constructor Create;
		/// Creates the ServerSocketImpl.
    destructor Destroy; override;
		/// Destroys the ServerSocketImpl.
  end;

implementation

{ TServerSocketImpl }

constructor TServerSocketImpl.Create;
begin
  inherited;
end;

destructor TServerSocketImpl.Destroy;
begin

  inherited;
end;

end.
