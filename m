From: Chris Adams <chris@improbable.org>
Subject: Re: nfsroot clients hang while mounting second NFS server
Date: Fri, 11 Jul 2003 12:07:34 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <EDE12792-B3D2-11D7-A405-000A95703418@improbable.org>
References: <shsvfu976gd.fsf@charged.uio.no>
Mime-Version: 1.0 (Apple Message framework v552)
Content-Type: multipart/mixed; boundary=Apple-Mail-4-186359679
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [64.21.166.2] (helo=mail1.qwknetllc.com)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19b3F4-0001tb-00
	for <nfs@lists.sourceforge.net>; Fri, 11 Jul 2003 12:07:38 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shsvfu976gd.fsf@charged.uio.no>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


--Apple-Mail-4-186359679
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=US-ASCII;
	format=flowed

On Friday, July 11, 2003, at 02:34  AM, Trond Myklebust wrote:
> Looks like it hangs just after a GETPORT call. Any info on what that
> GETPORT call is for (i.e. what the arguments are)? Ethereal should be
> able to decode that information for you...

I've attached the full output - here's the request info & response:

Request:
Portmap
     Program Version: 2
     V2 Procedure: GETPORT (3)
     Program: NFS (100003)
     Version: 3
     Proto: UDP (17)
     Port: 0

Reply:
Portmap
     Program Version: 2
     V2 Procedure: GETPORT (3)
     Port: 2049



--Apple-Mail-4-186359679
Content-Disposition: attachment;
	filename=portmap-traffic.txt
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	x-unix-mode=0644;
	name="portmap-traffic.txt"

Frame 20 (110 bytes on wire, 110 bytes captured)
    Arrival Time: Jul  8, 2003 18:24:11.858187000
    Time delta from previous packet: 7.187190000 seconds
    Time relative to first packet: 7.187190000 seconds
    Frame Number: 20
    Packet Length: 110 bytes
    Capture Length: 110 bytes
Ethernet II, Src: 00:09:b6:11:cd:fc, Dst: 00:04:76:3b:63:a6
    Destination: 00:04:76:3b:63:a6 (00:04:76:3b:63:a6)
    Source: 00:09:b6:11:cd:fc (00:09:b6:11:cd:fc)
    Type: IP (0x0800)
Internet Protocol, Src Addr: 10.0.73.29 (10.0.73.29), Dst Addr: 192.168.1.20 (198.202.70.20)
    Version: 4
    Header length: 20 bytes
    Differentiated Services Field: 0x00 (DSCP 0x00: Default; ECN: 0x00)
        0000 00.. = Differentiated Services Codepoint: Default (0x00)
        .... ..0. = ECN-Capable Transport (ECT): 0
        .... ...0 = ECN-CE: 0
    Total Length: 96
    Identification: 0x574f
    Flags: 0x04
        .1.. = Don't fragment: Set
        ..0. = More fragments: Not set
    Fragment offset: 0
    Time to live: 63
    Protocol: TCP (0x06)
    Header checksum: 0x844d (correct)
    Source: 10.0.73.29 (10.0.73.29)
    Destination: 192.168.1.20 (198.202.70.20)
Transmission Control Protocol, Src Port: 722 (722), Dst Port: sunrpc (111), Seq: 2685755182, Ack: 2199399551, Len: 44
    Source port: 722 (722)
    Destination port: sunrpc (111)
    Sequence number: 2685755182
    Next sequence number: 2685755226
    Acknowledgement number: 2199399551
    Header length: 32 bytes
    Flags: 0x0018 (PSH, ACK)
        0... .... = Congestion Window Reduced (CWR): Not set
        .0.. .... = ECN-Echo: Not set
        ..0. .... = Urgent: Not set
        ...1 .... = Acknowledgment: Set
        .... 1... = Push: Set
        .... .0.. = Reset: Not set
        .... ..0. = Syn: Not set
        .... ...0 = Fin: Not set
    Window size: 5840
    Checksum: 0xbf86 (correct)
    Options: (12 bytes)
        NOP
        NOP
        Time stamp: tsval 133216, tsecr 131447901
Remote Procedure Call
    Fragment header: Last fragment, 40 bytes
        1... .... .... .... .... .... .... .... = Last Fragment: Yes
        .000 0000 0000 0000 0000 0000 0010 1000 = Fragment Length: 40
    XID: 0x524a6869 (1380608105)
    Message Type: Call (0)
    RPC Version: 2
    Program: Portmap (100000)
    Program Version: 2
    Procedure: DUMP (4)
    Credentials
        Flavor: AUTH_NULL (0)
        Length: 0
    Verifier
        Flavor: AUTH_NULL (0)
        Length: 0
Portmap
    Program Version: 2
    V2 Procedure: DUMP (4)

0000  00 04 76 3b 63 a6 00 09 b6 11 cd fc 08 00 45 00   ..v;c.........E.
0010  00 60 57 4f 40 00 3f 06 84 4d 0a 00 49 1d c6 ca   .`WO@.?..M..I...
0020  46 14 02 d2 00 6f a0 15 5f 2e 83 18 2c 7f 80 18   F....o.._...,...
0030  16 d0 bf 86 00 00 01 01 08 0a 00 02 08 60 07 d5   .............`..
0040  bc 5d 80 00 00 28 52 4a 68 69 00 00 00 00 00 00   .]...(RJhi......
0050  00 02 00 01 86 a0 00 00 00 02 00 00 00 04 00 00   ................
0060  00 00 00 00 00 00 00 00 00 00 00 00 00 00         ..............

Frame 27 (98 bytes on wire, 98 bytes captured)
    Arrival Time: Jul  8, 2003 18:24:11.870822000
    Time delta from previous packet: 0.012635000 seconds
    Time relative to first packet: 7.199825000 seconds
    Frame Number: 27
    Packet Length: 98 bytes
    Capture Length: 98 bytes
Ethernet II, Src: 00:09:b6:11:cd:fc, Dst: 00:04:76:3b:63:a6
    Destination: 00:04:76:3b:63:a6 (00:04:76:3b:63:a6)
    Source: 00:09:b6:11:cd:fc (00:09:b6:11:cd:fc)
    Type: IP (0x0800)
Internet Protocol, Src Addr: 10.0.73.29 (10.0.73.29), Dst Addr: 192.168.1.20 (198.202.70.20)
    Version: 4
    Header length: 20 bytes
    Differentiated Services Field: 0x00 (DSCP 0x00: Default; ECN: 0x00)
        0000 00.. = Differentiated Services Codepoint: Default (0x00)
        .... ..0. = ECN-Capable Transport (ECT): 0
        .... ...0 = ECN-CE: 0
    Total Length: 84
    Identification: 0x0000
    Flags: 0x04
        .1.. = Don't fragment: Set
        ..0. = More fragments: Not set
    Fragment offset: 0
    Time to live: 63
    Protocol: UDP (0x11)
    Header checksum: 0xdb9d (correct)
    Source: 10.0.73.29 (10.0.73.29)
    Destination: 192.168.1.20 (198.202.70.20)
User Datagram Protocol, Src Port: 725 (725), Dst Port: sunrpc (111)
    Source port: 725 (725)
    Destination port: sunrpc (111)
    Length: 64
    Checksum: 0xb39d (correct)
Remote Procedure Call
    XID: 0x1832c2fd (405979901)
    Message Type: Call (0)
    RPC Version: 2
    Program: Portmap (100000)
    Program Version: 2
    Procedure: GETPORT (3)
    The reply to this request is in frame 30
    Credentials
        Flavor: AUTH_NULL (0)
        Length: 0
    Verifier
        Flavor: AUTH_NULL (0)
        Length: 0
Portmap
    Program Version: 2
    V2 Procedure: GETPORT (3)
    Program: NFS (100003)
    Version: 3
    Proto: UDP (17)
    Port: 0

0000  00 04 76 3b 63 a6 00 09 b6 11 cd fc 08 00 45 00   ..v;c.........E.
0010  00 54 00 00 40 00 3f 11 db 9d 0a 00 49 1d c6 ca   .T..@.?.....I...
0020  46 14 02 d5 00 6f 00 40 b3 9d 18 32 c2 fd 00 00   F....o.@...2....
0030  00 00 00 00 00 02 00 01 86 a0 00 00 00 02 00 00   ................
0040  00 03 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
0050  00 00 00 01 86 a3 00 00 00 03 00 00 00 11 00 00   ................
0060  00 00                                             ..

Frame 30 (70 bytes on wire, 70 bytes captured)
    Arrival Time: Jul  8, 2003 18:24:11.871200000
    Time delta from previous packet: 0.000378000 seconds
    Time relative to first packet: 7.200203000 seconds
    Frame Number: 30
    Packet Length: 70 bytes
    Capture Length: 70 bytes
Ethernet II, Src: 00:04:76:3b:63:a6, Dst: 00:e0:81:20:3d:a4
    Destination: 00:e0:81:20:3d:a4 (00:e0:81:20:3d:a4)
    Source: 00:04:76:3b:63:a6 (00:04:76:3b:63:a6)
    Type: IP (0x0800)
Internet Protocol, Src Addr: 192.168.1.20 (198.202.70.20), Dst Addr: 10.0.73.29 (10.0.73.29)
    Version: 4
    Header length: 20 bytes
    Differentiated Services Field: 0x00 (DSCP 0x00: Default; ECN: 0x00)
        0000 00.. = Differentiated Services Codepoint: Default (0x00)
        .... ..0. = ECN-Capable Transport (ECT): 0
        .... ...0 = ECN-CE: 0
    Total Length: 56
    Identification: 0x4658
    Flags: 0x00
        .0.. = Don't fragment: Not set
        ..0. = More fragments: Not set
    Fragment offset: 0
    Time to live: 64
    Protocol: UDP (0x11)
    Header checksum: 0xd461 (correct)
    Source: 192.168.1.20 (198.202.70.20)
    Destination: 10.0.73.29 (10.0.73.29)
User Datagram Protocol, Src Port: sunrpc (111), Dst Port: 725 (725)
    Source port: sunrpc (111)
    Destination port: 725 (725)
    Length: 36
    Checksum: 0xb934 (correct)
Remote Procedure Call
    XID: 0x1832c2fd (405979901)
    Message Type: Reply (1)
    Program: Portmap (100000)
    Program Version: 2
    Procedure: GETPORT (3)
    Reply State: accepted (0)
    This is a reply to a request in frame 27
    Time from request: 0.000378000 seconds
    Verifier
        Flavor: AUTH_NULL (0)
        Length: 0
    Accept State: RPC executed successfully (0)
Portmap
    Program Version: 2
    V2 Procedure: GETPORT (3)
    Port: 2049

0000  00 e0 81 20 3d a4 00 04 76 3b 63 a6 08 00 45 00   ... =...v;c...E.
0010  00 38 46 58 00 00 40 11 d4 61 c6 ca 46 14 0a 00   .8FX..@..a..F...
0020  49 1d 00 6f 02 d5 00 24 b9 34 18 32 c2 fd 00 00   I..o...$.4.2....
0030  00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
0040  00 00 00 00 08 01                                 ......

--Apple-Mail-4-186359679--



-------------------------------------------------------
This SF.Net email sponsored by: Parasoft
Error proof Web apps, automate testing & more.
Download & eval WebKing and get a free book.
www.parasoft.com/bulletproofapps1
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
