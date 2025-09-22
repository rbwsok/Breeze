unit Breeze.Net.SocketDefs;

interface

uses Winapi.Windows, Winapi.Winsock2, Winapi.IpExport;

type
  pin_addr = ^in_addr;

  TSocketType = (
		SOCKET_TYPE_STREAM = SOCK_STREAM,
		SOCKET_TYPE_DATAGRAM = SOCK_DGRAM,
		SOCKET_TYPE_RAW = SOCK_RAW
	);

	TPollMode = (
		SELECT_READ  = 1,
		SELECT_WRITE = 2,
		SELECT_ERROR = 4
	);

  TAddressFamily = (
		UNKNOWN = AF_UNSPEC,
		IPv4 = AF_INET,
		IPv6 = AF_INET6
	);

  ADDRESS_FAMILY = USHORT; { ADDRESS_FAMILI values see in Winapi.Winsock2.pas: AF_xxx }
  {$EXTERNALSYM ADDRESS_FAMILY}

// from ws2def.h
//typedef struct {
//    union {
//        struct {
//            ULONG Zone : 28;
//            ULONG Level : 4;
//        };
//        ULONG Value;
//    };
//} SCOPE_ID, *PSCOPE_ID;
  SCOPE_ID = record
    private
      function GetULong(Index: Integer): ULong;
      procedure SetULong(Index: Integer; value1: ULong);
    public
      Value: ULONG;
      property Zone:  ULONG Index $0FFFFFFF read GetULong write SetULong; // mask $0FFFFFFF ( offset 0 )
      property Level: ULONG Index $0000000F read GetULong write SetULong; // mask $0000000F ( offset 28 )
  end;
  {$EXTERNALSYM SCOPE_ID}
  PSCOPE_ID = ^SCOPE_ID;
  {$EXTERNALSYM PSCOPE_ID}

  // from ws2ipdef.h
  // NB: The LH version of sockaddr_in6 has the struct tag sockaddr_in6 rather
  // than sockaddr_in6_lh.  This is to make sure that standard sockets apps
  // that conform to RFC 2553 (Basic Socket Interface Extensions for IPv6).
  //typedef struct sockaddr_in6 {
  //    ADDRESS_FAMILY sin6_family; // AF_INET6.
  //    USHORT sin6_port;           // Transport level port number.
  //    ULONG  sin6_flowinfo;       // IPv6 flow information.
  //    IN6_ADDR sin6_addr;         // IPv6 address.
  //    union {
  //        ULONG sin6_scope_id;     // Set of interfaces for a scope.
  //        SCOPE_ID sin6_scope_struct;
  //    };
  //} SOCKADDR_IN6_LH, *PSOCKADDR_IN6_LH, FAR *LPSOCKADDR_IN6_LH;
  psockaddr_in6 = ^sockaddr_in6;
  sockaddr_in6 = record
    private
      function GetULong(Index: Integer): ULong;
      procedure SetULong(Index: Integer; value1: ULong);
    public
      sin6_family:   ADDRESS_FAMILY; // AF_INET6. ADDRESS_FAMILY values see in Winapi.Winsock2.pas: AF_xxx }
      sin6_port:     USHORT;         // Transport level port number.
      sin6_flowinfo: ULONG;          // IPv6 flow information.
      sin6_addr: IN6_ADDR;           // IPv6 address, IN6_ADDR defined in Winapi.IpExport.pas.
      Value: ULONG;
      property sin6_scope_id: ULONG read Value write Value;
      property Zone:  ULONG Index $0FFFFFFF read GetULong write SetULong; // mask $0FFFFFFF ( offset 0 )
      property Level: ULONG Index $0000000F read GetULong write SetULong; // mask $0000000F ( offset 28 )
  end;
  {$EXTERNALSYM sockaddr_in6}
  SOCKADDR_IN6_LH = sockaddr_in6;
  {$EXTERNALSYM SOCKADDR_IN6_LH}
  PSOCKADDR_IN6_LH = ^SOCKADDR_IN6_LH;
  {$EXTERNALSYM PSOCKADDR_IN6_LH}
  LPSOCKADDR_IN6_LH = ^SOCKADDR_IN6_LH;
  {$EXTERNALSYM LPSOCKADDR_IN6_LH}

type
  ipv6_mreq = record
    ipv6mr_multiaddr: in6_addr;  // IPv6 multicast address
    ipv6mr_interface: Cardinal;  // Interface index
  end;
  {$EXTERNALSYM ipv6_mreq}
  TIpV6MReq = ipv6_mreq;
  PIpV6MReq = ^ipv6_mreq;

  ip_mreq = record
    imr_multiaddr: in_addr;  // IP multicast address of group
    imr_interface: in_addr;  // local IP address of interface
  end;
  {$EXTERNALSYM ip_mreq}
  TIPMReq = ip_mreq;
  PIPMReq = ^ip_mreq;

// Argument structure for IP_ADD_SOURCE_MEMBERSHIP, IP_DROP_SOURCE_MEMBERSHIP,
// IP_BLOCK_SOURCE, and IP_UNBLOCK_SOURCE
//

  ip_mreq_source = record
    imr_multiaddr: in_addr; // IP multicast address of group
    imr_sourceaddr: in_addr; // IP address of source
    imr_interface: in_addr; // local IP address of interface
  end;
  {$EXTERNALSYM ip_mreq_source}
  TIpMreqSource = ip_mreq_source;
  PIpMreqSource = ^ip_mreq_source;

// Argument structure for SIO_{GET,SET}_MULTICAST_FILTER

  ip_msfilter = record
    imsf_multiaddr: in_addr; // IP multicast address of group
    imsf_interface: in_addr; // local IP address of interface
    imsf_fmode: u_long; // filter mode - INCLUDE or EXCLUDE
    imsf_numsrc: u_long; // number of sources in src_list
    imsf_slist: array [0..0] of in_addr;
  end;
  {$EXTERNALSYM ip_msfilter}
  TIpMsFilter = ip_msfilter;
  PIpMsFilter = ^ip_msfilter;



  var
    m_data: WSADATA;

const
  IF_TYPE_OTHER                   = 1;   // None of the below
  IF_TYPE_REGULAR_1822            = 2;
  IF_TYPE_HDH_1822                = 3;
  IF_TYPE_DDN_X25                 = 4;
  IF_TYPE_RFC877_X25              = 5;
  IF_TYPE_ETHERNET_CSMACD         = 6;
  IF_TYPE_IS088023_CSMACD         = 7;
  IF_TYPE_ISO88024_TOKENBUS       = 8;
  IF_TYPE_ISO88025_TOKENRING      = 9;
  IF_TYPE_ISO88026_MAN            = 10;
  IF_TYPE_STARLAN                 = 11;
  IF_TYPE_PROTEON_10MBIT          = 12;
  IF_TYPE_PROTEON_80MBIT          = 13;
  IF_TYPE_HYPERCHANNEL            = 14;
  IF_TYPE_FDDI                    = 15;
  IF_TYPE_LAP_B                   = 16;
  IF_TYPE_SDLC                    = 17;
  IF_TYPE_DS1                     = 18;  // DS1-MIB
  IF_TYPE_E1                      = 19;  // Obsolete; see DS1-MIB
  IF_TYPE_BASIC_ISDN              = 20;
  IF_TYPE_PRIMARY_ISDN            = 21;
  IF_TYPE_PROP_POINT2POINT_SERIAL = 22;  // proprietary serial
  IF_TYPE_PPP                     = 23;
  IF_TYPE_SOFTWARE_LOOPBACK       = 24;
  IF_TYPE_EON                     = 25;  // CLNP over IP
  IF_TYPE_ETHERNET_3MBIT          = 26;
  IF_TYPE_NSIP                    = 27;  // XNS over IP
  IF_TYPE_SLIP                    = 28;  // Generic Slip
  IF_TYPE_ULTRA                   = 29;  // ULTRA Technologies
  IF_TYPE_DS3                     = 30;  // DS3-MIB
  IF_TYPE_SIP                     = 31;  // SMDS, coffee
  IF_TYPE_FRAMERELAY              = 32;  // DTE only
  IF_TYPE_RS232                   = 33;
  IF_TYPE_PARA                    = 34;  // Parallel port
  IF_TYPE_ARCNET                  = 35;
  IF_TYPE_ARCNET_PLUS             = 36;
  IF_TYPE_ATM                     = 37;  // ATM cells
  IF_TYPE_MIO_X25                 = 38;
  IF_TYPE_SONET                   = 39;  // SONET or SDH
  IF_TYPE_X25_PLE                 = 40;
  IF_TYPE_ISO88022_LLC            = 41;
  IF_TYPE_LOCALTALK               = 42;
  IF_TYPE_SMDS_DXI                = 43;
  IF_TYPE_FRAMERELAY_SERVICE      = 44;  // FRNETSERV-MIB
  IF_TYPE_V35                     = 45;
  IF_TYPE_HSSI                    = 46;
  IF_TYPE_HIPPI                   = 47;
  IF_TYPE_MODEM                   = 48;  // Generic Modem
  IF_TYPE_AAL5                    = 49;  // AAL5 over ATM
  IF_TYPE_SONET_PATH              = 50;
  IF_TYPE_SONET_VT                = 51;
  IF_TYPE_SMDS_ICIP               = 52;  // SMDS InterCarrier Interface
  IF_TYPE_PROP_VIRTUAL            = 53;  // Proprietary virtual/internal
  IF_TYPE_PROP_MULTIPLEXOR        = 54;  // Proprietary multiplexing
  IF_TYPE_IEEE80212               = 55;  // 100BaseVG
  IF_TYPE_FIBRECHANNEL            = 56;
  IF_TYPE_HIPPIINTERFACE          = 57;
  IF_TYPE_FRAMERELAY_INTERCONNECT = 58;  // Obsolete, use 32 or 44
  IF_TYPE_AFLANE_8023             = 59;  // ATM Emulated LAN for 802.3
  IF_TYPE_AFLANE_8025             = 60;  // ATM Emulated LAN for 802.5
  IF_TYPE_CCTEMUL                 = 61;  // ATM Emulated circuit
  IF_TYPE_FASTETHER               = 62;  // Fast Ethernet (100BaseT)
  IF_TYPE_ISDN                    = 63;  // ISDN and X.25
  IF_TYPE_V11                     = 64;  // CCITT V.11/X.21
  IF_TYPE_V36                     = 65;  // CCITT V.36
  IF_TYPE_G703_64K                = 66;  // CCITT G703 at 64Kbps
  IF_TYPE_G703_2MB                = 67;  // Obsolete; see DS1-MIB
  IF_TYPE_QLLC                    = 68;  // SNA QLLC
  IF_TYPE_FASTETHER_FX            = 69;  // Fast Ethernet (100BaseFX)
  IF_TYPE_CHANNEL                 = 70;
  IF_TYPE_IEEE80211               = 71;  // Radio spread spectrum
  IF_TYPE_IBM370PARCHAN           = 72;  // IBM System 360/370 OEMI Channel
  IF_TYPE_ESCON                   = 73;  // IBM Enterprise Systems Connection
  IF_TYPE_DLSW                    = 74;  // Data Link Switching
  IF_TYPE_ISDN_S                  = 75;  // ISDN S/T interface
  IF_TYPE_ISDN_U                  = 76;  // ISDN U interface
  IF_TYPE_LAP_D                   = 77;  // Link Access Protocol D
  IF_TYPE_IPSWITCH                = 78;  // IP Switching Objects
  IF_TYPE_RSRB                    = 79;  // Remote Source Route Bridging
  IF_TYPE_ATM_LOGICAL             = 80;  // ATM Logical Port
  IF_TYPE_DS0                     = 81;  // Digital Signal Level 0
  IF_TYPE_DS0_BUNDLE              = 82;  // Group of ds0s on the same ds1
  IF_TYPE_BSC                     = 83;  // Bisynchronous Protocol
  IF_TYPE_ASYNC                   = 84;  // Asynchronous Protocol
  IF_TYPE_CNR                     = 85;  // Combat Net Radio
  IF_TYPE_ISO88025R_DTR           = 86;  // ISO 802.5r DTR
  IF_TYPE_EPLRS                   = 87;  // Ext Pos Loc Report Sys
  IF_TYPE_ARAP                    = 88;  // Appletalk Remote Access Protocol
  IF_TYPE_PROP_CNLS               = 89;  // Proprietary Connectionless Proto
  IF_TYPE_HOSTPAD                 = 90;  // CCITT-ITU X.29 PAD Protocol
  IF_TYPE_TERMPAD                 = 91;  // CCITT-ITU X.3 PAD Facility
  IF_TYPE_FRAMERELAY_MPI          = 92;  // Multiproto Interconnect over FR
  IF_TYPE_X213                    = 93;  // CCITT-ITU X213
  IF_TYPE_ADSL                    = 94;  // Asymmetric Digital Subscrbr Loop
  IF_TYPE_RADSL                   = 95;  // Rate-Adapt Digital Subscrbr Loop
  IF_TYPE_SDSL                    = 96;  // Symmetric Digital Subscriber Loop
  IF_TYPE_VDSL                    = 97;  // Very H-Speed Digital Subscrb Loop
  IF_TYPE_ISO88025_CRFPRINT       = 98;  // ISO 802.5 CRFP
  IF_TYPE_MYRINET                 = 99;  // Myricom Myrinet
  IF_TYPE_VOICE_EM                = 100; // Voice recEive and transMit
  IF_TYPE_VOICE_FXO               = 101; // Voice Foreign Exchange Office
  IF_TYPE_VOICE_FXS               = 102; // Voice Foreign Exchange Station
  IF_TYPE_VOICE_ENCAP             = 103; // Voice encapsulation
  IF_TYPE_VOICE_OVERIP            = 104; // Voice over IP encapsulation
  IF_TYPE_ATM_DXI                 = 105; // ATM DXI
  IF_TYPE_ATM_FUNI                = 106; // ATM FUNI
  IF_TYPE_ATM_IMA                 = 107; // ATM IMA
  IF_TYPE_PPPMULTILINKBUNDLE      = 108; // PPP Multilink Bundle
  IF_TYPE_IPOVER_CDLC             = 109; // IBM ipOverCdlc
  IF_TYPE_IPOVER_CLAW             = 110; // IBM Common Link Access to Workstn
  IF_TYPE_STACKTOSTACK            = 111; // IBM stackToStack
  IF_TYPE_VIRTUALIPADDRESS        = 112; // IBM VIPA
  IF_TYPE_MPC                     = 113; // IBM multi-proto channel support
  IF_TYPE_IPOVER_ATM              = 114; // IBM ipOverAtm
  IF_TYPE_ISO88025_FIBER          = 115; // ISO 802.5j Fiber Token Ring
  IF_TYPE_TDLC                    = 116; // IBM twinaxial data link control
  IF_TYPE_GIGABITETHERNET         = 117;
  IF_TYPE_HDLC                    = 118;
  IF_TYPE_LAP_F                   = 119;
  IF_TYPE_V37                     = 120;
  IF_TYPE_X25_MLP                 = 121; // Multi-Link Protocol
  IF_TYPE_X25_HUNTGROUP           = 122; // X.25 Hunt Group
  IF_TYPE_TRANSPHDLC              = 123;
  IF_TYPE_INTERLEAVE              = 124; // Interleave channel
  IF_TYPE_FAST                    = 125; // Fast channel
  IF_TYPE_IP                      = 126; // IP (for APPN HPR in IP networks)
  IF_TYPE_DOCSCABLE_MACLAYER      = 127; // CATV Mac Layer
  IF_TYPE_DOCSCABLE_DOWNSTREAM    = 128; // CATV Downstream interface
  IF_TYPE_DOCSCABLE_UPSTREAM      = 129; // CATV Upstream interface
  IF_TYPE_A12MPPSWITCH            = 130; // Avalon Parallel Processor
  IF_TYPE_TUNNEL                  = 131; // Encapsulation interface
  IF_TYPE_COFFEE                  = 132; // Coffee pot
  IF_TYPE_CES                     = 133; // Circuit Emulation Service
  IF_TYPE_ATM_SUBINTERFACE        = 134; // ATM Sub Interface
  IF_TYPE_L2_VLAN                 = 135; // Layer 2 Virtual LAN using 802.1Q
  IF_TYPE_L3_IPVLAN               = 136; // Layer 3 Virtual LAN using IP
  IF_TYPE_L3_IPXVLAN              = 137; // Layer 3 Virtual LAN using IPX
  IF_TYPE_DIGITALPOWERLINE        = 138; // IP over Power Lines
  IF_TYPE_MEDIAMAILOVERIP         = 139; // Multimedia Mail over IP
  IF_TYPE_DTM                     = 140; // Dynamic syncronous Transfer Mode
  IF_TYPE_DCN                     = 141; // Data Communications Network
  IF_TYPE_IPFORWARD               = 142; // IP Forwarding Interface
  IF_TYPE_MSDSL                   = 143; // Multi-rate Symmetric DSL
  IF_TYPE_IEEE1394                = 144; // IEEE1394 High Perf Serial Bus
  IF_TYPE_IF_GSN                  = 145;
  IF_TYPE_DVBRCC_MACLAYER         = 146;
  IF_TYPE_DVBRCC_DOWNSTREAM       = 147;
  IF_TYPE_DVBRCC_UPSTREAM         = 148;
  IF_TYPE_ATM_VIRTUAL             = 149;
  IF_TYPE_MPLS_TUNNEL             = 150;
  IF_TYPE_SRP                     = 151;
  IF_TYPE_VOICEOVERATM            = 152;
  IF_TYPE_VOICEOVERFRAMERELAY     = 153;
  IF_TYPE_IDSL                    = 154;
  IF_TYPE_COMPOSITELINK           = 155;
  IF_TYPE_SS7_SIGLINK             = 156;
  IF_TYPE_PROP_WIRELESS_P2P       = 157;
  IF_TYPE_FR_FORWARD              = 158;
  IF_TYPE_RFC1483                 = 159;
  IF_TYPE_USB                     = 160;
  IF_TYPE_IEEE8023AD_LAG          = 161;
  IF_TYPE_BGP_POLICY_ACCOUNTING   = 162;
  IF_TYPE_FRF16_MFR_BUNDLE        = 163;
  IF_TYPE_H323_GATEKEEPER         = 164;
  IF_TYPE_H323_PROXY              = 165;
  IF_TYPE_MPLS                    = 166;
  IF_TYPE_MF_SIGLINK              = 167;
  IF_TYPE_HDSL2                   = 168;
  IF_TYPE_SHDSL                   = 169;
  IF_TYPE_DS1_FDL                 = 170;
  IF_TYPE_POS                     = 171;
  IF_TYPE_DVB_ASI_IN              = 172;
  IF_TYPE_DVB_ASI_OUT             = 173;
  IF_TYPE_PLC                     = 174;
  IF_TYPE_NFAS                    = 175;
  IF_TYPE_TR008                   = 176;
  IF_TYPE_GR303_RDT               = 177;
  IF_TYPE_GR303_IDT               = 178;
  IF_TYPE_ISUP                    = 179;
  IF_TYPE_PROP_DOCS_WIRELESS_MACLAYER      = 180;
  IF_TYPE_PROP_DOCS_WIRELESS_DOWNSTREAM    = 181;
  IF_TYPE_PROP_DOCS_WIRELESS_UPSTREAM      = 182;
  IF_TYPE_HIPERLAN2                        = 183;
  IF_TYPE_PROP_BWA_P2MP                    = 184;
  IF_TYPE_SONET_OVERHEAD_CHANNEL           = 185;
  IF_TYPE_DIGITAL_WRAPPER_OVERHEAD_CHANNEL = 186;
  IF_TYPE_AAL2                             = 187;
  IF_TYPE_RADIO_MAC                        = 188;
  IF_TYPE_ATM_RADIO                        = 189;
  IF_TYPE_IMT                              = 190;
  IF_TYPE_MVL                              = 191;
  IF_TYPE_REACH_DSL                        = 192;
  IF_TYPE_FR_DLCI_ENDPT                    = 193;
  IF_TYPE_ATM_VCI_ENDPT                    = 194;
  IF_TYPE_OPTICAL_CHANNEL                  = 195;
  IF_TYPE_OPTICAL_TRANSPORT                = 196;
  IF_TYPE_IEEE80216_WMAN                   = 237;
  IF_TYPE_WWANPP                  = 243; // WWAN devices based on GSM technology
  IF_TYPE_WWANPP2                 = 244; // WWAN devices based on CDMA technology
  IF_TYPE_IEEE802154              = 259; // IEEE 802.15.4 WPAN interface
  IF_TYPE_XBOX_WIRELESS           = 281;

  ENOERR = 0;

// Option to use with [gs]etsockopt at the IPPROTO_IP level

const
  IP_OPTIONS         = 1;  // set/get IP options
  IP_HDRINCL         = 2;  // header is included with data
  IP_TOS             = 3;  // IP type of service and preced
  IP_TTL             = 4;  // IP time to live
  IP_MULTICAST_IF    = 9;  // set/get IP multicast i/f
  IP_MULTICAST_TTL   = 10; // set/get IP multicast ttl
  IP_MULTICAST_LOOP  = 11; // set/get IP multicast loopback
  IP_ADD_MEMBERSHIP  = 12; // add an IP group membership
  IP_DROP_MEMBERSHIP = 13; // drop an IP group membership
  IP_DONTFRAGMENT    = 14; // don't fragment IP datagrams
  IP_ADD_SOURCE_MEMBERSHIP  = 15; // join IP group/source
  IP_DROP_SOURCE_MEMBERSHIP = 16; // leave IP group/source
  IP_BLOCK_SOURCE           = 17; // block IP group/source
  IP_UNBLOCK_SOURCE         = 18; // unblock IP group/source
  IP_PKTINFO                = 19; // receive packet information for ipv4

  IPV6_HOPOPTS           = 1; // Set/get IPv6 hop-by-hop options.
  IPV6_HDRINCL           = 2; // Header is included with data.
  IPV6_UNICAST_HOPS      = 4; // IP unicast hop limit.
  IPV6_MULTICAST_IF      = 9; // IP multicast interface.
  IPV6_MULTICAST_HOPS   = 10; // IP multicast hop limit.
  IPV6_MULTICAST_LOOP   = 11; // IP multicast loopback.
  IPV6_ADD_MEMBERSHIP   = 12; // Add an IP group membership.
  IPV6_JOIN_GROUP       = IPV6_ADD_MEMBERSHIP;
  IPV6_DROP_MEMBERSHIP  = 13; // Drop an IP group membership.
  IPV6_LEAVE_GROUP      = IPV6_DROP_MEMBERSHIP;
  IPV6_DONTFRAG         = 14; // Don't fragment IP datagrams.
  IPV6_PKTINFO          = 19; // Receive packet information.
  IPV6_HOPLIMIT         = 21; // Receive packet hop limit.
  IPV6_PROTECTION_LEVEL = 23; // Set/get IPv6 protection level.
  IPV6_RECVIF           = 24; // Receive arrival interface.
  IPV6_RECVDSTADDR      = 25; // Receive destination address.
  IPV6_CHECKSUM         = 26; // Offset to checksum for raw IP socket send.
  IPV6_V6ONLY           = 27; // Treat wildcard bind as AF_INET6-only.
  IPV6_IFLIST           = 28; // Enable/Disable an interface list.
  IPV6_ADD_IFLIST       = 29; // Add an interface list entry.
  IPV6_DEL_IFLIST       = 30; // Delete an interface list entry.
  IPV6_UNICAST_IF       = 31; // IP unicast interface.
  IPV6_RTHDR            = 32; // Set/get IPv6 routing header.
  IPV6_GET_IFLIST       = 33; // Get an interface list.
  IPV6_RECVRTHDR        = 38; // Receive the routing header.
  IPV6_TCLASS           = 39; // Packet traffic class.
  IPV6_RECVTCLASS       = 40; // Receive packet traffic class.
  IPV6_ECN              = 50; // IPv6 ECN codepoint.
  IPV6_RECVECN          = 50; // Receive ECN codepoints in the IPv6 header.
  IPV6_PKTINFO_EX       = 51; // Receive extended packet information.
  IPV6_WFP_REDIRECT_RECORDS   = 60; // WFP's Connection Redirect Records
  IPV6_WFP_REDIRECT_CONTEXT   = 70; // WFP's Connection Redirect Context
  IPV6_MTU_DISCOVER           = 71; // Set/get path MTU discover state.
  IPV6_MTU                    = 72; // Get path MTU.
  IPV6_NRT_INTERFACE          = 74; // Set NRT interface constraint (outbound).
  IPV6_RECVERR                = 75; // Receive ICMPv6 errors.
  IPV6_USER_MTU               = 76; // Set/get app defined upper bound IP layer MTU.

	POLL_READ  = 1;
	POLL_WRITE = 2;
  POLL_ERROR = 4;

  AI_PASSIVE            = $00000001;   // Socket address will be used in bind() call
  AI_CANONNAME          = $00000002;   // Return canonical name in first ai_canonname
  AI_NUMERICHOST        = $00000004;   // Nodename must be a numeric address string
  AI_NUMERICSERV        = $00000008;  // Servicename must be a numeric port number
  AI_ALL                = $00000100;  // Query both IP6 and IP4 with AI_V4MAPPED
  AI_ADDRCONFIG         = $00000400;  // Resolution only if global address configured
  AI_V4MAPPED           = $00000800;  // On v6 failure, query v4 and convert to V4MAPPED format (Vista or later)
  AI_NON_AUTHORITATIVE  = $00004000;  // LUP_NON_AUTHORITATIVE  (Vista or later)
  AI_SECURE             = $00008000;  // LUP_SECURE  (Vista or later and applies only to NS_EMAIL namespace.)
  AI_RETURN_PREFERRED_NAMES = $00010000;  // LUP_RETURN_PREFERRED_NAMES (Vista or later and applies only to NS_EMAIL namespace.)
  AI_FQDN                   = $00020000;  // Return the FQDN in ai_canonname  (Windows 7 or later)
  AI_FILESERVER             = $00040000;  // Resolving fileserver name resolution (Windows 7 or later)
  AI_DISABLE_IDN_ENCODING = $00080000;  // Disable Internationalized Domain Names handling


  NI_MAXHOST = 1025; // Max size of a fully-qualified domain name
  {$EXTERNALSYM NI_MAXHOST}
  NI_MAXSERV = 32; // Max size of a service name
  {$EXTERNALSYM NI_MAXSERV}

  INET_ADDRSTRLEN  = 16; // Max size of numeric form of IPv4 address
  {$EXTERNALSYM INET_ADDRSTRLEN}
  INET6_ADDRSTRLEN = 46; // Max size of numeric form of IPv6 address
  {$EXTERNALSYM INET6_ADDRSTRLEN}

// Flags for getnameinfo()

  NI_NOFQDN      = $01; // Only return nodename portion for local hosts
  {$EXTERNALSYM NI_NOFQDN}
  NI_NUMERICHOST = $02; // Return numeric form of the host's address
  {$EXTERNALSYM NI_NUMERICHOST}
  NI_NAMEREQD    = $04; // Error if the host's name not in DNS
  {$EXTERNALSYM NI_NAMEREQD}
  NI_NUMERICSERV = $08; // Return numeric form of the service (port #)
  {$EXTERNALSYM NI_NUMERICSERV}
  NI_DGRAM       = $10; // Service is a datagram service
  {$EXTERNALSYM NI_DGRAM}

  WSA_SECURE_HOST_NOT_FOUND        = 11032;
  WSA_IPSEC_NAME_POLICY_ERROR      = 11033;

  EAI_AGAIN           = WSATRY_AGAIN;
  EAI_BADFLAGS        = WSAEINVAL;
  EAI_FAIL            = WSANO_RECOVERY;
  EAI_FAMILY          = WSAEAFNOSUPPORT;
  EAI_MEMORY          = WSA_NOT_ENOUGH_MEMORY;
  EAI_NOSECURENAME    = WSA_SECURE_HOST_NOT_FOUND;
  EAI_NONAME          = WSAHOST_NOT_FOUND;
  EAI_SERVICE         = WSATYPE_NOT_FOUND;
  EAI_SOCKTYPE        = WSAESOCKTNOSUPPORT;
  EAI_IPSECPOLICY     = WSA_IPSEC_NAME_POLICY_ERROR;

  DEFAULT_TIMEOUT = 250;
  DEFAULT_SLEEP_LIMIT = 250;

  ws2tcpip = 'ws2_32.dll';

function getnameinfo(sa: PSockAddr; salen: Integer; host: PAnsiChar; hostlen: DWORD; serv: PAnsiChar; servlen: DWORD; flags: Integer): Integer; stdcall; external ws2tcpip name 'getnameinfo';
function getaddrinfo(nodename, servname: PAnsiChar; hints: PAddrInfo; var res: PAddrInfo): Integer; stdcall; external ws2tcpip name 'getaddrinfo';
procedure freeaddrinfo(ai: PAddrInfo); stdcall; external ws2tcpip name 'freeaddrinfo';

implementation

// Here Index=Mask is only $0FFFFFFF (offset=0) or $0000000F (offset=28)
function SCOPE_ID.GetULong(Index: Integer): ULONG;
begin
  if Index = $0000000F then
    Result := Value shr 28
  else
    Result := Value and Index;
end;
procedure SCOPE_ID.SetULong(Index: Integer; value1: ULong);
begin
  if Index = $0000000F then // Index=Mask=$0000000F, offset=28
    Value := (Value and $0FFFFFFF) or (value1 shl 28)
  else // Index=Mask=$0FFFFFFF, offset=0
    Value := (Value and $F0000000) or (value1 and $0FFFFFFF);
end;

// Here Index=Mask is only $0FFFFFFF (offset=0) or $0000000F (offset=28)
function sockaddr_in6.GetULong(Index: Integer): ULONG;
begin
  if Index = $0000000F then
    Result := Value shr 28
  else
    Result := Value and Index;
end;
procedure sockaddr_in6.SetULong(Index: Integer; value1: ULong);
begin
  if Index = $0000000F then // Index=Mask=$0000000F, offset=28
    Value := (Value and $0FFFFFFF) or (value1 shl 28)
  else // Index=Mask=$0FFFFFFF, offset=0
    Value := (Value and $F0000000) or (value1 and $0FFFFFFF);
end;


initialization
  WSAStartup($0202, m_data);
finalization
  WSACleanup;

end.
