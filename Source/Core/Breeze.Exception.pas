unit Breeze.Exception;

interface

uses System.SysUtils;

type
  LogicException = class(System.SysUtils.Exception)
  end;

  AssertionViolationException = class(LogicException)
  end;

  NullPointerException = class(LogicException)
  end;
  NullValueException = class(LogicException)
  end;
  BugcheckException = class(LogicException)
  end;
  InvalidArgumentException = class(LogicException)
  end;
  NotImplementedException = class(LogicException)
  end;
  RangeException = class(LogicException)
  end;
  IllegalStateException = class(LogicException)
  end;
  InvalidAccessException = class(LogicException)
  end;
  SignalException = class(LogicException)
  end;
  UnhandledException = class(LogicException)
  end;
  RuntimeException = class(System.SysUtils.Exception)
  end;
  NotFoundException = class(RuntimeException)
  end;
  ExistsException = class(RuntimeException)
  end;
  TimeoutException = class(RuntimeException)
  end;
  SystemException = class(RuntimeException)
  end;
  RegularExpressionException = class(RuntimeException)
  end;
  LibraryLoadException = class(RuntimeException)
  end;
  LibraryAlreadyLoadedException = class(RuntimeException)
  end;
  NoThreadAvailableException = class(RuntimeException)
  end;
  PropertyNotSupportedException = class(RuntimeException)
  end;
  PoolOverflowException = class(RuntimeException)
  end;
  NoPermissionException = class(RuntimeException)
  end;
  OutOfMemoryException = class(RuntimeException)
  end;
  ResourceLimitException = class(RuntimeException)
  end;
  DataException = class(RuntimeException)
  end;
  DataFormatException = class(DataException)
  end;
  SyntaxException = class(DataException)
  end;
  CircularReferenceException = class(DataException)
  end;
  PathSyntaxException = class(SyntaxException)
  end;
  IOException = class(RuntimeException)
  end;
  ProtocolException = class(IOException)
  end;
  FileException = class(IOException)
  end;
  FileExistsException = class(FileException)
  end;
  FileNotFoundException = class(FileException)
  end;
  PathNotFoundException = class(FileException)
  end;
  FileReadOnlyException = class(FileException)
  end;
  FileAccessDeniedException = class(FileException)
  end;
  CreateFileException = class(FileException)
  end;
  OpenFileException = class(FileException)
  end;
  WriteFileException = class(FileException)
  end;
  ReadFileException = class(FileException)
  end;
  ExecuteFileException = class(FileException)
  end;
  FileNotReadyException = class(FileException)
  end;
  DirectoryNotEmptyException = class(FileException)
  end;
  UnknownURISchemeException = class(RuntimeException)
  end;
  TooManyURIRedirectsException = class(RuntimeException)
  end;
  URISyntaxException = class(SyntaxException)
  end;
  ApplicationException = class(System.SysUtils.Exception)
  end;
  BadCastException = class(RuntimeException)
  end;

  NetException = class(IOException)
  end;
  InvalidAddressException = class(NetException)
  end;
  InvalidSocketException = class(NetException)
  end;
  ServiceNotFoundException = class(NetException)
  end;
  ConnectionAbortedException = class(NetException)
  end;
  ConnectionResetException = class(NetException)
  end;
  ConnectionRefusedException = class(NetException)
  end;
  DNSException = class(NetException)
  end;
  HostNotFoundException = class(DNSException)
  end;
  NoAddressFoundException = class(DNSException)
  end;
  InterfaceNotFoundException = class(NetException)
  end;
  NoMessageException = class(NetException)
  end;
  MessageException = class(NetException)
  end;
  MultipartException = class(MessageException)
  end;
  HTTPException = class(NetException)
  end;
  NotAuthenticatedException = class(HTTPException)
  end;
  UnsupportedRedirectException = class(HTTPException)
  end;
  FTPException = class(NetException)
  end;
  SMTPException = class(NetException)
  end;
  POP3Exception = class(NetException)
  end;
  ICMPException = class(NetException)
  end;
  ICMPFragmentationException = class(NetException)
  end;
  NTPException = class(NetException)
  end;
  HTMLFormException = class(NetException)
  end;
  WebSocketException = class(NetException)
  end;
  UnsupportedFamilyException = class(NetException)
  end;
  AddressFamilyMismatchException = class(NetException)
  end;

implementation

end.
