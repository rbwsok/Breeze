unit Breeze.Net.HostEntry;

interface

uses Winapi.Winsock2, Winapi.IpExport, System.Classes, System.Generics.Collections,
Breeze.Net.IPAddress, Breeze.Net.SocketDefs;

type
  THostEntry = class
	/// This class stores information about a host
	/// such as host name, alias names and a list
	/// of IP addresses.
  private
	  FName: AnsiString;
	  FAliases: TList<AnsiString>;
	  FAddresses: TList<TIPAddress>;

    class procedure SwapValue<T>(var X1, X2: T);
  public
	//using AliasList = std::vector<std::string>;
	//using AddressList = std::vector<IPAddress>;

  	constructor Create; overload;
		/// Creates an empty HostEntry.

	  constructor Create(AEntry: PHostEnt); overload;
		/// Creates the HostEntry from the data in a hostent structure.

	  constructor Create(AAddrInfo: Paddrinfo); overload;
		/// Creates the HostEntry from the data in an addrinfo structure.

	  constructor Create(const AEntry: THostEntry); overload;
		/// Creates the HostEntry by copying another one.

	  procedure Assign(const AEntry: THostEntry); overload;

	  procedure Assign(AAddrInfo: Paddrinfo); overload;

//	HostEntry& operator = (const HostEntry& entry);
		/// Assigns another HostEntry.

	  procedure swap(hostEntry: THostEntry);
		/// Swaps the HostEntry with another one.

	  destructor Destroy; override;
		/// Destroys the HostEntry.

    property Name: AnsiString read FName;
    property Addresses: TList<TIPAddress> read FAddresses;
    property Aliases: TList<AnsiString> read FAliases;
  end;

implementation

{ THostEntry }

constructor THostEntry.Create;
begin
  FAliases := TList<AnsiString>.Create;
  FAddresses := TList<TIPAddress>.Create;
end;

constructor THostEntry.Create(AEntry: PHostEnt);
var
  LAlias: MarshaledAStringList;
  LAddress: MarshaledAStringList;
begin
  Create;

	FName := AEntry.h_name;
	LAlias := AEntry.h_aliases;
	if LAlias^ <> nil then
  begin
		while LAlias <> nil do
    begin
			FAliases.Add(LAlias^);
			inc(LAlias);
		end;
	end;
 //	removeDuplicates(_aliases);

	LAddress := AEntry.h_addr_list;
	if LAddress^ <> nil then
  begin
		while LAddress <> nil do
    begin
			FAddresses.Add(TIPAddress.Create(LAddress, AEntry.h_length));
			inc(LAddress);
		end;
	end;
//	removeDuplicates(_addresses);
end;

procedure THostEntry.Assign(const AEntry: THostEntry);
begin
	FName := AEntry.FName;
  FAliases.Clear;
	FAliases.AddRange(AEntry.FAliases);
  FAddresses.Clear;
	FAddresses.AddRange(AEntry.FAddresses);
end;

procedure THostEntry.Assign(AAddrInfo: Paddrinfo);
var
  LAddrInfo: Paddrinfo;
begin
  FAliases.Clear;
  FAddresses.Clear;

  LAddrInfo := AAddrInfo;
  while LAddrInfo <> nil do
  begin
    if LAddrInfo.ai_canonname <> '' then
      FName := LAddrInfo.ai_canonname;

    if (LAddrInfo.ai_addrlen <> 0) and (LAddrInfo.ai_addr <> nil) then
    begin
      case LAddrInfo.ai_addr.sa_family of
        AF_INET:
          FAddresses.Add(TIPAddress.Create(@PSockAddrIn(LAddrInfo.ai_addr).sin_addr, sizeof(in_addr)));
        AF_INET6:
          FAddresses.Add(TIPAddress.Create(@psockaddr_in6(LAddrInfo.ai_addr).sin6_addr, sizeof(IN6_ADDR), psockaddr_in6(LAddrInfo.ai_addr).sin6_scope_id));
      end;
    end;

    LAddrInfo := LAddrInfo.ai_next;
  end;
end;

constructor THostEntry.Create(const AEntry: THostEntry);
begin
  Create;

	FName := AEntry.FName;
	FAliases.AddRange(AEntry.FAliases);
	FAddresses.AddRange(AEntry.FAddresses);
end;

constructor THostEntry.Create(AAddrInfo: Paddrinfo);
var
  LAddrInfo: Paddrinfo;
begin
  Create;

  LAddrInfo := AAddrInfo;
  while LAddrInfo <> nil do
  begin
    if LAddrInfo.ai_canonname <> '' then
      FName := LAddrInfo.ai_canonname;

    if (LAddrInfo.ai_addrlen <> 0) and (LAddrInfo.ai_addr <> nil) then
    begin
      case LAddrInfo.ai_addr.sa_family of
        AF_INET:
          FAddresses.Add(TIPAddress.Create(@PSockAddrIn(LAddrInfo.ai_addr).sin_addr, sizeof(in_addr)));
        AF_INET6:
          FAddresses.Add(TIPAddress.Create(@psockaddr_in6(LAddrInfo.ai_addr).sin6_addr, sizeof(IN6_ADDR), psockaddr_in6(LAddrInfo.ai_addr).sin6_scope_id));
      end;
    end;

    LAddrInfo := LAddrInfo.ai_next;
  end;

 //	removeDuplicates(_addresses);
end;

destructor THostEntry.Destroy;
begin
  FAliases.Free;
  FAddresses.Free;

  inherited;
end;

class procedure THostEntry.SwapValue<T>(var X1, X2: T);
var
  X : T;
begin
  X := X2;
  X2 := X1;
  X1 := X;
end;

procedure THostEntry.swap(hostEntry: THostEntry);
begin
	SwapValue<AnsiString>(FName, hostEntry.FName);
	SwapValue<TList<AnsiString>>(FAliases, hostEntry.FAliases);
	SwapValue<TList<TIPAddress>>(FAddresses, hostEntry.FAddresses);
end;

end.
