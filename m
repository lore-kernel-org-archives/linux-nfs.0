Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e32.co.us.ibm.com ([32.97.110.150]:33994 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756039Ab3FRNry (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Jun 2013 09:47:54 -0400
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <cvogan@us.ibm.com>;
	Tue, 18 Jun 2013 07:47:53 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 5862519D8042
	for <linux-nfs@vger.kernel.org>; Tue, 18 Jun 2013 07:47:40 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5IDlalB130494
	for <linux-nfs@vger.kernel.org>; Tue, 18 Jun 2013 07:47:41 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5IDlaRi023651
	for <linux-nfs@vger.kernel.org>; Tue, 18 Jun 2013 07:47:36 -0600
Received: from d03nm116.boulder.ibm.com (d03nm116.boulder.ibm.com [9.63.40.222])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id r5IDlZZE023638
	for <linux-nfs@vger.kernel.org>; Tue, 18 Jun 2013 07:47:35 -0600
To: linux-nfs@vger.kernel.org
MIME-Version: 1.0
Subject: NFSERR_STALE on umount  with 3.10.0.RC5 kernel
Message-ID: <OF659496E7.43E03D23-ON87257B8E.004B852B-86257B8E.004BC3F6@us.ibm.com>
From: Christopher T Vogan <cvogan@us.ibm.com>
Date: Tue, 18 Jun 2013 07:47:34 -0600
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The new linux 3.10.0-rc5 kernel gets NFSERR_STALE on un-mount.
The reason is the Linux client is sending a GETATTR after the umnt 
call/reply.
This is a network trace of the umnt call/reply and the gettattr 
afterwords.

No.     Time        Source                Destination           Protocol 
Length Info
    753 0.476095    9.11.117.223          9.11.117.245          MOUNT 174  
 V3 UMNT Call (Reply In 754) /hfs/home/reg/dir0,binary

Frame 753: 174 bytes on wire (1392 bits), 174 bytes captured (1392 bits)
    Arrival Time: Jun 17, 2013 14:31:14.540211000 Central Daylight Time
    Epoch Time: 1371497474.540211000 seconds
    [Time delta from previous captured frame: 0.000167000 seconds]
    [Time delta from previous displayed frame: 0.000167000 seconds]
    [Time since reference or first frame: 0.476095000 seconds]
    Frame Number: 753
    Frame Length: 174 bytes (1392 bits)
    Capture Length: 174 bytes (1392 bits)
    [Frame is marked: False]
    [Frame is ignored: False]
    [Protocols in frame: eth:ip:tcp:rpc]
    [Coloring Rule Name: TCP]
    [Coloring Rule String: tcp]
Ethernet II, Src: c2:cb:c4:e4:e4:69 (c2:cb:c4:e4:e4:69), Dst: Ibm_a5:25:6a 
(00:14:5e:a5:25:6a)
    Destination: Ibm_a5:25:6a (00:14:5e:a5:25:6a)
        Address: Ibm_a5:25:6a (00:14:5e:a5:25:6a)
        .... ...0 .... .... .... .... = IG bit: Individual address 
(unicast)
        .... ..0. .... .... .... .... = LG bit: Globally unique address 
(factory default)
    Source: c2:cb:c4:e4:e4:69 (c2:cb:c4:e4:e4:69)
        Address: c2:cb:c4:e4:e4:69 (c2:cb:c4:e4:e4:69)
        .... ...0 .... .... .... .... = IG bit: Individual address 
(unicast)
        .... ..1. .... .... .... .... = LG bit: Locally administered 
address (this is NOT the factory default)
    Type: IP (0x0800)
Internet Protocol Version 4, Src: 9.11.117.223 (9.11.117.223), Dst: 
9.11.117.245 (9.11.117.245)
    Version: 4
    Header length: 20 bytes
    Differentiated Services Field: 0x00 (DSCP 0x00: Default; ECN: 0x00: 
Not-ECT (Not ECN-Capable Transport))
        0000 00.. = Differentiated Services Codepoint: Default (0x00)
        .... ..00 = Explicit Congestion Notification: Not-ECT (Not 
ECN-Capable Transport) (0x00)
    Total Length: 160
    Identification: 0x4e02 (19970)
    Flags: 0x02 (Don't Fragment)
        0... .... = Reserved bit: Not set
        .1.. .... = Don't fragment: Set
        ..0. .... = More fragments: Not set
    Fragment offset: 0
    Time to live: 64
    Protocol: TCP (6)
    Header checksum: 0xee6b [correct]
        [Good: True]
        [Bad: False]
    Source: 9.11.117.223 (9.11.117.223)
    Destination: 9.11.117.245 (9.11.117.245)
Transmission Control Protocol, Src Port: mac-srvr-admin (660), Dst Port: 
2045 (2045), Seq: 1, Ack: 1, Len: 108
    Source port: mac-srvr-admin (660)
    Destination port: 2045 (2045)
    [Stream index: 17]
    Sequence number: 1    (relative sequence number)
    [Next sequence number: 109    (relative sequence number)]
    Acknowledgement number: 1    (relative ack number)
    Header length: 32 bytes
    Flags: 0x018 (PSH, ACK)
        000. .... .... = Reserved: Not set
        ...0 .... .... = Nonce: Not set
        .... 0... .... = Congestion Window Reduced (CWR): Not set
        .... .0.. .... = ECN-Echo: Not set
        .... ..0. .... = Urgent: Not set
        .... ...1 .... = Acknowledgement: Set
        .... .... 1... = Push: Set
        .... .... .0.. = Reset: Not set
        .... .... ..0. = Syn: Not set
        .... .... ...0 = Fin: Not set
    Window size value: 115
    [Calculated window size: 14720]
    [Window size scaling factor: 128]
    Checksum: 0xfe7c [validation disabled]
        [Good Checksum: False]
        [Bad Checksum: False]
    Options: (12 bytes)
        No-Operation (NOP)
        No-Operation (NOP)
        Timestamps: TSval 42531, TSecr 465248523
            Kind: Timestamp (8)
            Length: 10
            Timestamp value: 42531
            Timestamp echo reply: 465248523
    [SEQ/ACK analysis]
        [Bytes in flight: 108]
Remote Procedure Call, Type:Call XID:0xb443a513
    Fragment header: Last fragment, 104 bytes
        1... .... .... .... .... .... .... .... = Last Fragment: Yes
        .000 0000 0000 0000 0000 0000 0110 1000 = Fragment Length: 104
    XID: 0xb443a513 (3024332051)
    Message Type: Call (0)
    RPC Version: 2
    Program: MOUNT (100005)
    Program Version: 3
    Procedure: UMNT (3)
    [The reply to this request is in frame 754]
    Credentials
        Flavor: AUTH_UNIX (1)
        Length: 32
        Stamp: 0x51bf6402
        Machine Name: reddy4
            length: 6
            contents: reddy4
            fill bytes: opaque data
        UID: 0
        GID: 0
        Auxiliary GIDs
            GID: 0
    Verifier
        Flavor: AUTH_NULL (0)
        Length: 0
Mount Service
    [Program Version: 3]
    [V3 Procedure: UMNT (3)]
    Path: /hfs/home/reg/dir0,binary
        length: 25
        contents: /hfs/home/reg/dir0,binary
        fill bytes: opaque data

0000  00 14 5e a5 25 6a c2 cb c4 e4 e4 69 08 00 45 00   ..^.%j.....i..E.
0010  00 a0 4e 02 40 00 40 06 ee 6b 09 0b 75 df 09 0b   ..N.@.@..k..u...
0020  75 f5 02 94 07 fd df fe e8 23 21 7b 67 a5 80 18   u........#!{g...
0030  00 73 fe 7c 00 00 01 01 08 0a 00 00 a6 23 1b bb   .s.|.........#..
0040  21 0b 80 00 00 68 b4 43 a5 13 00 00 00 00 00 00   !....h.C........
0050  00 02 00 01 86 a5 00 00 00 03 00 00 00 03 00 00   ................
0060  00 01 00 00 00 20 51 bf 64 02 00 00 00 06 72 65   ..... Q.d.....re
0070  64 64 79 34 00 00 00 00 00 00 00 00 00 00 00 00   ddy4............
0080  00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
0090  00 19 2f 68 66 73 2f 68 6f 6d 65 2f 72 65 67 2f   ../hfs/home/reg/
00a0  64 69 72 30 2c 62 69 6e 61 72 79 00 00 00         dir0,binary...

No.     Time        Source                Destination           Protocol 
Length Info
    754 0.476786    9.11.117.245          9.11.117.223          MOUNT 94  
V3 UMNT Reply (Call In 753)

Frame 754: 94 bytes on wire (752 bits), 94 bytes captured (752 bits)
    Arrival Time: Jun 17, 2013 14:31:14.540902000 Central Daylight Time
    Epoch Time: 1371497474.540902000 seconds
    [Time delta from previous captured frame: 0.000691000 seconds]
    [Time delta from previous displayed frame: 0.000691000 seconds]
    [Time since reference or first frame: 0.476786000 seconds]
    Frame Number: 754
    Frame Length: 94 bytes (752 bits)
    Capture Length: 94 bytes (752 bits)
    [Frame is marked: False]
    [Frame is ignored: False]
    [Protocols in frame: eth:ip:tcp:rpc]
    [Coloring Rule Name: TCP]
    [Coloring Rule String: tcp]
Ethernet II, Src: Ibm_a5:25:6a (00:14:5e:a5:25:6a), Dst: c2:cb:c4:e4:e4:69 
(c2:cb:c4:e4:e4:69)
    Destination: c2:cb:c4:e4:e4:69 (c2:cb:c4:e4:e4:69)
        Address: c2:cb:c4:e4:e4:69 (c2:cb:c4:e4:e4:69)
        .... ...0 .... .... .... .... = IG bit: Individual address 
(unicast)
        .... ..1. .... .... .... .... = LG bit: Locally administered 
address (this is NOT the factory default)
    Source: Ibm_a5:25:6a (00:14:5e:a5:25:6a)
        Address: Ibm_a5:25:6a (00:14:5e:a5:25:6a)
        .... ...0 .... .... .... .... = IG bit: Individual address 
(unicast)
        .... ..0. .... .... .... .... = LG bit: Globally unique address 
(factory default)
    Type: IP (0x0800)
Internet Protocol Version 4, Src: 9.11.117.245 (9.11.117.245), Dst: 
9.11.117.223 (9.11.117.223)
    Version: 4
    Header length: 20 bytes
    Differentiated Services Field: 0x00 (DSCP 0x00: Default; ECN: 0x00: 
Not-ECT (Not ECN-Capable Transport))
        0000 00.. = Differentiated Services Codepoint: Default (0x00)
        .... ..00 = Explicit Congestion Notification: Not-ECT (Not 
ECN-Capable Transport) (0x00)
    Total Length: 80
    Identification: 0x0664 (1636)
    Flags: 0x00
        0... .... = Reserved bit: Not set
        .0.. .... = Don't fragment: Not set
        ..0. .... = More fragments: Not set
    Fragment offset: 0
    Time to live: 64
    Protocol: TCP (6)
    Header checksum: 0x765a [correct]
        [Good: True]
        [Bad: False]
    Source: 9.11.117.245 (9.11.117.245)
    Destination: 9.11.117.223 (9.11.117.223)
Transmission Control Protocol, Src Port: 2045 (2045), Dst Port: 
mac-srvr-admin (660), Seq: 1, Ack: 109, Len: 28
    Source port: 2045 (2045)
    Destination port: mac-srvr-admin (660)
    [Stream index: 17]
    Sequence number: 1    (relative sequence number)
    [Next sequence number: 29    (relative sequence number)]
    Acknowledgement number: 109    (relative ack number)
    Header length: 32 bytes
    Flags: 0x018 (PSH, ACK)
        000. .... .... = Reserved: Not set
        ...0 .... .... = Nonce: Not set
        .... 0... .... = Congestion Window Reduced (CWR): Not set
        .... .0.. .... = ECN-Echo: Not set
        .... ..0. .... = Urgent: Not set
        .... ...1 .... = Acknowledgement: Set
        .... .... 1... = Push: Set
        .... .... .0.. = Reset: Not set
        .... .... ..0. = Syn: Not set
        .... .... ...0 = Fin: Not set
    Window size value: 8188
    [Calculated window size: 262016]
    [Window size scaling factor: 32]
    Checksum: 0x4017 [validation disabled]
        [Good Checksum: False]
        [Bad Checksum: False]
    Options: (12 bytes)
        No-Operation (NOP)
        No-Operation (NOP)
        Timestamps: TSval 465248524, TSecr 42531
            Kind: Timestamp (8)
            Length: 10
            Timestamp value: 465248524
            Timestamp echo reply: 42531
    [SEQ/ACK analysis]
        [This is an ACK to the segment in frame: 753]
        [The RTT to ACK the segment was: 0.000691000 seconds]
        [Bytes in flight: 28]
Remote Procedure Call, Type:Reply XID:0xb443a513
    Fragment header: Last fragment, 24 bytes
        1... .... .... .... .... .... .... .... = Last Fragment: Yes
        .000 0000 0000 0000 0000 0000 0001 1000 = Fragment Length: 24
    XID: 0xb443a513 (3024332051)
    Message Type: Reply (1)
    [Program: MOUNT (100005)]
    [Program Version: 3]
    [Procedure: UMNT (3)]
    Reply State: accepted (0)
    [This is a reply to a request in frame 753]
    [Time from request: 0.000691000 seconds]
    Verifier
        Flavor: AUTH_NULL (0)
        Length: 0
    Accept State: RPC executed successfully (0)
Mount Service
    [Program Version: 3]
    [V3 Procedure: UMNT (3)]

0000  c2 cb c4 e4 e4 69 00 14 5e a5 25 6a 08 00 45 00   .....i..^.%j..E.
0010  00 50 06 64 00 00 40 06 76 5a 09 0b 75 f5 09 0b   .P.d..@.vZ..u...
0020  75 df 07 fd 02 94 21 7b 67 a5 df fe e8 8f 80 18   u.....!{g.......
0030  1f fc 40 17 00 00 01 01 08 0a 1b bb 21 0c 00 00   ..@.........!...
0040  a6 23 80 00 00 18 b4 43 a5 13 00 00 00 01 00 00   .#.....C........
0050  00 00 00 00 00 00 00 00 00 00 00 00 00 00         ..............

No.     Time        Source                Destination           Protocol 
Length Info
    755 0.476811    9.11.117.223          9.11.117.245          TCP 66 
mac-srvr-admin > 2045 [ACK] Seq=109 Ack=29 Win=14720 Len=0 TSval=42532 
TSecr=465248524

Frame 755: 66 bytes on wire (528 bits), 66 bytes captured (528 bits)
    Arrival Time: Jun 17, 2013 14:31:14.540927000 Central Daylight Time
    Epoch Time: 1371497474.540927000 seconds
    [Time delta from previous captured frame: 0.000025000 seconds]
    [Time delta from previous displayed frame: 0.000025000 seconds]
    [Time since reference or first frame: 0.476811000 seconds]
    Frame Number: 755
    Frame Length: 66 bytes (528 bits)
    Capture Length: 66 bytes (528 bits)
    [Frame is marked: False]
    [Frame is ignored: False]
    [Protocols in frame: eth:ip:tcp]
    [Coloring Rule Name: TCP]
    [Coloring Rule String: tcp]
Ethernet II, Src: c2:cb:c4:e4:e4:69 (c2:cb:c4:e4:e4:69), Dst: Ibm_a5:25:6a 
(00:14:5e:a5:25:6a)
    Destination: Ibm_a5:25:6a (00:14:5e:a5:25:6a)
        Address: Ibm_a5:25:6a (00:14:5e:a5:25:6a)
        .... ...0 .... .... .... .... = IG bit: Individual address 
(unicast)
        .... ..0. .... .... .... .... = LG bit: Globally unique address 
(factory default)
    Source: c2:cb:c4:e4:e4:69 (c2:cb:c4:e4:e4:69)
        Address: c2:cb:c4:e4:e4:69 (c2:cb:c4:e4:e4:69)
        .... ...0 .... .... .... .... = IG bit: Individual address 
(unicast)
        .... ..1. .... .... .... .... = LG bit: Locally administered 
address (this is NOT the factory default)
    Type: IP (0x0800)
Internet Protocol Version 4, Src: 9.11.117.223 (9.11.117.223), Dst: 
9.11.117.245 (9.11.117.245)
    Version: 4
    Header length: 20 bytes
    Differentiated Services Field: 0x00 (DSCP 0x00: Default; ECN: 0x00: 
Not-ECT (Not ECN-Capable Transport))
        0000 00.. = Differentiated Services Codepoint: Default (0x00)
        .... ..00 = Explicit Congestion Notification: Not-ECT (Not 
ECN-Capable Transport) (0x00)
    Total Length: 52
    Identification: 0x4e03 (19971)
    Flags: 0x02 (Don't Fragment)
        0... .... = Reserved bit: Not set
        .1.. .... = Don't fragment: Set
        ..0. .... = More fragments: Not set
    Fragment offset: 0
    Time to live: 64
    Protocol: TCP (6)
    Header checksum: 0xeed6 [correct]
        [Good: True]
        [Bad: False]
    Source: 9.11.117.223 (9.11.117.223)
    Destination: 9.11.117.245 (9.11.117.245)
Transmission Control Protocol, Src Port: mac-srvr-admin (660), Dst Port: 
2045 (2045), Seq: 109, Ack: 29, Len: 0
    Source port: mac-srvr-admin (660)
    Destination port: 2045 (2045)
    [Stream index: 17]
    Sequence number: 109    (relative sequence number)
    Acknowledgement number: 29    (relative ack number)
    Header length: 32 bytes
    Flags: 0x010 (ACK)
        000. .... .... = Reserved: Not set
        ...0 .... .... = Nonce: Not set
        .... 0... .... = Congestion Window Reduced (CWR): Not set
        .... .0.. .... = ECN-Echo: Not set
        .... ..0. .... = Urgent: Not set
        .... ...1 .... = Acknowledgement: Set
        .... .... 0... = Push: Not set
        .... .... .0.. = Reset: Not set
        .... .... ..0. = Syn: Not set
        .... .... ...0 = Fin: Not set
    Window size value: 115
    [Calculated window size: 14720]
    [Window size scaling factor: 128]
    Checksum: 0xfe10 [validation disabled]
        [Good Checksum: False]
        [Bad Checksum: False]
    Options: (12 bytes)
        No-Operation (NOP)
        No-Operation (NOP)
        Timestamps: TSval 42532, TSecr 465248524
            Kind: Timestamp (8)
            Length: 10
            Timestamp value: 42532
            Timestamp echo reply: 465248524
    [SEQ/ACK analysis]
        [This is an ACK to the segment in frame: 754]
        [The RTT to ACK the segment was: 0.000025000 seconds]

0000  00 14 5e a5 25 6a c2 cb c4 e4 e4 69 08 00 45 00   ..^.%j.....i..E.
0010  00 34 4e 03 40 00 40 06 ee d6 09 0b 75 df 09 0b   .4N.@.@.....u...
0020  75 f5 02 94 07 fd df fe e8 8f 21 7b 67 c1 80 10   u.........!{g...
0030  00 73 fe 10 00 00 01 01 08 0a 00 00 a6 24 1b bb   .s...........$..
0040  21 0c                                             !.

No.     Time        Source                Destination           Protocol 
Length Info
    756 0.477033    9.11.117.223          9.11.117.245          TCP 66 
mac-srvr-admin > 2045 [FIN, ACK] Seq=109 Ack=29 Win=14720 Len=0 
TSval=42532 TSecr=465248524

Frame 756: 66 bytes on wire (528 bits), 66 bytes captured (528 bits)
    Arrival Time: Jun 17, 2013 14:31:14.541149000 Central Daylight Time
    Epoch Time: 1371497474.541149000 seconds
    [Time delta from previous captured frame: 0.000222000 seconds]
    [Time delta from previous displayed frame: 0.000222000 seconds]
    [Time since reference or first frame: 0.477033000 seconds]
    Frame Number: 756
    Frame Length: 66 bytes (528 bits)
    Capture Length: 66 bytes (528 bits)
    [Frame is marked: False]
    [Frame is ignored: False]
    [Protocols in frame: eth:ip:tcp]
    [Coloring Rule Name: TCP SYN/FIN]
    [Coloring Rule String: tcp.flags & 0x02 || tcp.flags.fin == 1]
Ethernet II, Src: c2:cb:c4:e4:e4:69 (c2:cb:c4:e4:e4:69), Dst: Ibm_a5:25:6a 
(00:14:5e:a5:25:6a)
    Destination: Ibm_a5:25:6a (00:14:5e:a5:25:6a)
        Address: Ibm_a5:25:6a (00:14:5e:a5:25:6a)
        .... ...0 .... .... .... .... = IG bit: Individual address 
(unicast)
        .... ..0. .... .... .... .... = LG bit: Globally unique address 
(factory default)
    Source: c2:cb:c4:e4:e4:69 (c2:cb:c4:e4:e4:69)
        Address: c2:cb:c4:e4:e4:69 (c2:cb:c4:e4:e4:69)
        .... ...0 .... .... .... .... = IG bit: Individual address 
(unicast)
        .... ..1. .... .... .... .... = LG bit: Locally administered 
address (this is NOT the factory default)
    Type: IP (0x0800)
Internet Protocol Version 4, Src: 9.11.117.223 (9.11.117.223), Dst: 
9.11.117.245 (9.11.117.245)
    Version: 4
    Header length: 20 bytes
    Differentiated Services Field: 0x00 (DSCP 0x00: Default; ECN: 0x00: 
Not-ECT (Not ECN-Capable Transport))
        0000 00.. = Differentiated Services Codepoint: Default (0x00)
        .... ..00 = Explicit Congestion Notification: Not-ECT (Not 
ECN-Capable Transport) (0x00)
    Total Length: 52
    Identification: 0x4e04 (19972)
    Flags: 0x02 (Don't Fragment)
        0... .... = Reserved bit: Not set
        .1.. .... = Don't fragment: Set
        ..0. .... = More fragments: Not set
    Fragment offset: 0
    Time to live: 64
    Protocol: TCP (6)
    Header checksum: 0xeed5 [correct]
        [Good: True]
        [Bad: False]
    Source: 9.11.117.223 (9.11.117.223)
    Destination: 9.11.117.245 (9.11.117.245)
Transmission Control Protocol, Src Port: mac-srvr-admin (660), Dst Port: 
2045 (2045), Seq: 109, Ack: 29, Len: 0
    Source port: mac-srvr-admin (660)
    Destination port: 2045 (2045)
    [Stream index: 17]
    Sequence number: 109    (relative sequence number)
    Acknowledgement number: 29    (relative ack number)
    Header length: 32 bytes
    Flags: 0x011 (FIN, ACK)
        000. .... .... = Reserved: Not set
        ...0 .... .... = Nonce: Not set
        .... 0... .... = Congestion Window Reduced (CWR): Not set
        .... .0.. .... = ECN-Echo: Not set
        .... ..0. .... = Urgent: Not set
        .... ...1 .... = Acknowledgement: Set
        .... .... 0... = Push: Not set
        .... .... .0.. = Reset: Not set
        .... .... ..0. = Syn: Not set
        .... .... ...1 = Fin: Set
            [Expert Info (Chat/Sequence): Connection finish (FIN)]
                [Message: Connection finish (FIN)]
                [Severity level: Chat]
                [Group: Sequence]
    Window size value: 115
    [Calculated window size: 14720]
    [Window size scaling factor: 128]
    Checksum: 0xfe10 [validation disabled]
        [Good Checksum: False]
        [Bad Checksum: False]
    Options: (12 bytes)
        No-Operation (NOP)
        No-Operation (NOP)
        Timestamps: TSval 42532, TSecr 465248524
            Kind: Timestamp (8)
            Length: 10
            Timestamp value: 42532
            Timestamp echo reply: 465248524

0000  00 14 5e a5 25 6a c2 cb c4 e4 e4 69 08 00 45 00   ..^.%j.....i..E.
0010  00 34 4e 04 40 00 40 06 ee d5 09 0b 75 df 09 0b   .4N.@.@.....u...
0020  75 f5 02 94 07 fd df fe e8 8f 21 7b 67 c1 80 11   u.........!{g...
0030  00 73 fe 10 00 00 01 01 08 0a 00 00 a6 24 1b bb   .s...........$..
0040  21 0c                                             !.

No.     Time        Source                Destination           Protocol 
Length Info
    757 0.477160    9.11.117.223          9.11.117.245          NFS 202 V3 
GETATTR Call (Reply In 760), FH:0x2039fed4

Frame 757: 202 bytes on wire (1616 bits), 202 bytes captured (1616 bits)
    Arrival Time: Jun 17, 2013 14:31:14.541276000 Central Daylight Time
    Epoch Time: 1371497474.541276000 seconds
    [Time delta from previous captured frame: 0.000127000 seconds]
    [Time delta from previous displayed frame: 0.000127000 seconds]
    [Time since reference or first frame: 0.477160000 seconds]
    Frame Number: 757
    Frame Length: 202 bytes (1616 bits)
    Capture Length: 202 bytes (1616 bits)
    [Frame is marked: False]
    [Frame is ignored: False]
    [Protocols in frame: eth:ip:tcp:rpc:nfs]
    [Coloring Rule Name: TCP]
    [Coloring Rule String: tcp]
Ethernet II, Src: c2:cb:c4:e4:e4:69 (c2:cb:c4:e4:e4:69), Dst: Ibm_a5:25:6a 
(00:14:5e:a5:25:6a)
    Destination: Ibm_a5:25:6a (00:14:5e:a5:25:6a)
        Address: Ibm_a5:25:6a (00:14:5e:a5:25:6a)
        .... ...0 .... .... .... .... = IG bit: Individual address 
(unicast)
        .... ..0. .... .... .... .... = LG bit: Globally unique address 
(factory default)
    Source: c2:cb:c4:e4:e4:69 (c2:cb:c4:e4:e4:69)
        Address: c2:cb:c4:e4:e4:69 (c2:cb:c4:e4:e4:69)
        .... ...0 .... .... .... .... = IG bit: Individual address 
(unicast)
        .... ..1. .... .... .... .... = LG bit: Locally administered 
address (this is NOT the factory default)
    Type: IP (0x0800)
Internet Protocol Version 4, Src: 9.11.117.223 (9.11.117.223), Dst: 
9.11.117.245 (9.11.117.245)
    Version: 4
    Header length: 20 bytes
    Differentiated Services Field: 0x00 (DSCP 0x00: Default; ECN: 0x00: 
Not-ECT (Not ECN-Capable Transport))
        0000 00.. = Differentiated Services Codepoint: Default (0x00)
        .... ..00 = Explicit Congestion Notification: Not-ECT (Not 
ECN-Capable Transport) (0x00)
    Total Length: 188
    Identification: 0x6542 (25922)
    Flags: 0x02 (Don't Fragment)
        0... .... = Reserved bit: Not set
        .1.. .... = Don't fragment: Set
        ..0. .... = More fragments: Not set
    Fragment offset: 0
    Time to live: 64
    Protocol: TCP (6)
    Header checksum: 0xd70f [correct]
        [Good: True]
        [Bad: False]
    Source: 9.11.117.223 (9.11.117.223)
    Destination: 9.11.117.245 (9.11.117.245)
Transmission Control Protocol, Src Port: 725 (725), Dst Port: nfs (2049), 
Seq: 42033, Ack: 42093, Len: 136
    Source port: 725 (725)
    Destination port: nfs (2049)
    [Stream index: 9]
    Sequence number: 42033    (relative sequence number)
    [Next sequence number: 42169    (relative sequence number)]
    Acknowledgement number: 42093    (relative ack number)
    Header length: 32 bytes
    Flags: 0x018 (PSH, ACK)
        000. .... .... = Reserved: Not set
        ...0 .... .... = Nonce: Not set
        .... 0... .... = Congestion Window Reduced (CWR): Not set
        .... .0.. .... = ECN-Echo: Not set
        .... ..0. .... = Urgent: Not set
        .... ...1 .... = Acknowledgement: Set
        .... .... 1... = Push: Set
        .... .... .0.. = Reset: Not set
        .... .... ..0. = Syn: Not set
        .... .... ...0 = Fin: Not set
    Window size value: 331
    [Calculated window size: 42368]
    [Window size scaling factor: 128]
    Checksum: 0xfe98 [validation disabled]
        [Good Checksum: False]
        [Bad Checksum: False]
    Options: (12 bytes)
        No-Operation (NOP)
        No-Operation (NOP)
        Timestamps: TSval 42532, TSecr 465248517
            Kind: Timestamp (8)
            Length: 10
            Timestamp value: 42532
            Timestamp echo reply: 465248517
    [SEQ/ACK analysis]
        [This is an ACK to the segment in frame: 731]
        [The RTT to ACK the segment was: 0.007990000 seconds]
        [Bytes in flight: 136]
Remote Procedure Call, Type:Call XID:0x99fe2a0b
    Fragment header: Last fragment, 132 bytes
        1... .... .... .... .... .... .... .... = Last Fragment: Yes
        .000 0000 0000 0000 0000 0000 1000 0100 = Fragment Length: 132
    XID: 0x99fe2a0b (2583570955)
    Message Type: Call (0)
    RPC Version: 2
    Program: NFS (100003)
    Program Version: 3
    Procedure: GETATTR (1)
    [The reply to this request is in frame 760]
    Credentials
        Flavor: AUTH_UNIX (1)
        Length: 56
        Stamp: 0x00418961
        Machine Name: reddy4
            length: 6
            contents: reddy4
            fill bytes: opaque data
        UID: 0
        GID: 0
        Auxiliary GIDs
            GID: 0
            GID: 1
            GID: 2
            GID: 3
            GID: 4
            GID: 6
            GID: 10
    Verifier
        Flavor: AUTH_NULL (0)
        Length: 0
Network File System, GETATTR Call FH:0x2039fed4
    [Program Version: 3]
    [V3 Procedure: GETATTR (1)]
    object
        length: 32
        [hash (CRC-32): 0x2039fed4]
        decode type as: unknown
        filehandle: 51bf60290000000000020000000000010000005100006f2e...

0000  00 14 5e a5 25 6a c2 cb c4 e4 e4 69 08 00 45 00   ..^.%j.....i..E.
0010  00 bc 65 42 40 00 40 06 d7 0f 09 0b 75 df 09 0b   ..eB@.@.....u...
0020  75 f5 02 d5 08 01 6a fa 64 ea ff 2a 56 bb 80 18   u.....j.d..*V...
0030  01 4b fe 98 00 00 01 01 08 0a 00 00 a6 24 1b bb   .K...........$..
0040  21 05 80 00 00 84 99 fe 2a 0b 00 00 00 00 00 00   !.......*.......
0050  00 02 00 01 86 a3 00 00 00 03 00 00 00 01 00 00   ................
0060  00 01 00 00 00 38 00 41 89 61 00 00 00 06 72 65   .....8.A.a....re
0070  64 64 79 34 00 00 00 00 00 00 00 00 00 00 00 00   ddy4............
0080  00 07 00 00 00 00 00 00 00 01 00 00 00 02 00 00   ................
0090  00 03 00 00 00 04 00 00 00 06 00 00 00 0a 00 00   ................
00a0  00 00 00 00 00 00 00 00 00 20 51 bf 60 29 00 00   ......... Q.`)..
00b0  00 00 00 02 00 00 00 00 00 01 00 00 00 51 00 00   .............Q..
00c0  6f 2e c0 08 00 00 00 00 00 01                     o.........

No.     Time        Source                Destination           Protocol 
Length Info
    758 0.477408    9.11.117.245          9.11.117.223          TCP 66 
2045 > mac-srvr-admin [FIN, PSH, ACK] Seq=29 Ack=110 Win=262016 Len=0 
TSval=465248525 TSecr=42532

Frame 758: 66 bytes on wire (528 bits), 66 bytes captured (528 bits)
    Arrival Time: Jun 17, 2013 14:31:14.541524000 Central Daylight Time
    Epoch Time: 1371497474.541524000 seconds
    [Time delta from previous captured frame: 0.000248000 seconds]
    [Time delta from previous displayed frame: 0.000248000 seconds]
    [Time since reference or first frame: 0.477408000 seconds]
    Frame Number: 758
    Frame Length: 66 bytes (528 bits)
    Capture Length: 66 bytes (528 bits)
    [Frame is marked: False]
    [Frame is ignored: False]
    [Protocols in frame: eth:ip:tcp]
    [Coloring Rule Name: TCP SYN/FIN]
    [Coloring Rule String: tcp.flags & 0x02 || tcp.flags.fin == 1]
Ethernet II, Src: Ibm_a5:25:6a (00:14:5e:a5:25:6a), Dst: c2:cb:c4:e4:e4:69 
(c2:cb:c4:e4:e4:69)
    Destination: c2:cb:c4:e4:e4:69 (c2:cb:c4:e4:e4:69)
        Address: c2:cb:c4:e4:e4:69 (c2:cb:c4:e4:e4:69)
        .... ...0 .... .... .... .... = IG bit: Individual address 
(unicast)
        .... ..1. .... .... .... .... = LG bit: Locally administered 
address (this is NOT the factory default)
    Source: Ibm_a5:25:6a (00:14:5e:a5:25:6a)
        Address: Ibm_a5:25:6a (00:14:5e:a5:25:6a)
        .... ...0 .... .... .... .... = IG bit: Individual address 
(unicast)
        .... ..0. .... .... .... .... = LG bit: Globally unique address 
(factory default)
    Type: IP (0x0800)
Internet Protocol Version 4, Src: 9.11.117.245 (9.11.117.245), Dst: 
9.11.117.223 (9.11.117.223)
    Version: 4
    Header length: 20 bytes
    Differentiated Services Field: 0x00 (DSCP 0x00: Default; ECN: 0x00: 
Not-ECT (Not ECN-Capable Transport))
        0000 00.. = Differentiated Services Codepoint: Default (0x00)
        .... ..00 = Explicit Congestion Notification: Not-ECT (Not 
ECN-Capable Transport) (0x00)
    Total Length: 52
    Identification: 0x0665 (1637)
    Flags: 0x00
        0... .... = Reserved bit: Not set
        .0.. .... = Don't fragment: Not set
        ..0. .... = More fragments: Not set
    Fragment offset: 0
    Time to live: 64
    Protocol: TCP (6)
    Header checksum: 0x7675 [correct]
        [Good: True]
        [Bad: False]
    Source: 9.11.117.245 (9.11.117.245)
    Destination: 9.11.117.223 (9.11.117.223)
Transmission Control Protocol, Src Port: 2045 (2045), Dst Port: 
mac-srvr-admin (660), Seq: 29, Ack: 110, Len: 0
    Source port: 2045 (2045)
    Destination port: mac-srvr-admin (660)
    [Stream index: 17]
    Sequence number: 29    (relative sequence number)
    Acknowledgement number: 110    (relative ack number)
    Header length: 32 bytes
    Flags: 0x019 (FIN, PSH, ACK)
        000. .... .... = Reserved: Not set
        ...0 .... .... = Nonce: Not set
        .... 0... .... = Congestion Window Reduced (CWR): Not set
        .... .0.. .... = ECN-Echo: Not set
        .... ..0. .... = Urgent: Not set
        .... ...1 .... = Acknowledgement: Set
        .... .... 1... = Push: Set
        .... .... .0.. = Reset: Not set
        .... .... ..0. = Syn: Not set
        .... .... ...1 = Fin: Set
            [Expert Info (Chat/Sequence): Connection finish (FIN)]
                [Message: Connection finish (FIN)]
                [Severity level: Chat]
                [Group: Sequence]
    Window size value: 8188
    [Calculated window size: 262016]
    [Window size scaling factor: 32]
    Checksum: 0x1984 [validation disabled]
        [Good Checksum: False]
        [Bad Checksum: False]
    Options: (12 bytes)
        No-Operation (NOP)
        No-Operation (NOP)
        Timestamps: TSval 465248525, TSecr 42532
            Kind: Timestamp (8)
            Length: 10
            Timestamp value: 465248525
            Timestamp echo reply: 42532
    [SEQ/ACK analysis]
        [This is an ACK to the segment in frame: 756]
        [The RTT to ACK the segment was: 0.000375000 seconds]

0000  c2 cb c4 e4 e4 69 00 14 5e a5 25 6a 08 00 45 00   .....i..^.%j..E.
0010  00 34 06 65 00 00 40 06 76 75 09 0b 75 f5 09 0b   .4.e..@.vu..u...
0020  75 df 07 fd 02 94 21 7b 67 c1 df fe e8 90 80 19   u.....!{g.......
0030  1f fc 19 84 00 00 01 01 08 0a 1b bb 21 0d 00 00   ............!...
0040  a6 24                                             .$

No.     Time        Source                Destination           Protocol 
Length Info
    759 0.477429    9.11.117.223          9.11.117.245          TCP 66 
mac-srvr-admin > 2045 [ACK] Seq=110 Ack=30 Win=14720 Len=0 TSval=42532 
TSecr=465248525

Frame 759: 66 bytes on wire (528 bits), 66 bytes captured (528 bits)
    Arrival Time: Jun 17, 2013 14:31:14.541545000 Central Daylight Time
    Epoch Time: 1371497474.541545000 seconds
    [Time delta from previous captured frame: 0.000021000 seconds]
    [Time delta from previous displayed frame: 0.000021000 seconds]
    [Time since reference or first frame: 0.477429000 seconds]
    Frame Number: 759
    Frame Length: 66 bytes (528 bits)
    Capture Length: 66 bytes (528 bits)
    [Frame is marked: False]
    [Frame is ignored: False]
    [Protocols in frame: eth:ip:tcp]
    [Coloring Rule Name: TCP]
    [Coloring Rule String: tcp]
Ethernet II, Src: c2:cb:c4:e4:e4:69 (c2:cb:c4:e4:e4:69), Dst: Ibm_a5:25:6a 
(00:14:5e:a5:25:6a)
    Destination: Ibm_a5:25:6a (00:14:5e:a5:25:6a)
        Address: Ibm_a5:25:6a (00:14:5e:a5:25:6a)
        .... ...0 .... .... .... .... = IG bit: Individual address 
(unicast)
        .... ..0. .... .... .... .... = LG bit: Globally unique address 
(factory default)
    Source: c2:cb:c4:e4:e4:69 (c2:cb:c4:e4:e4:69)
        Address: c2:cb:c4:e4:e4:69 (c2:cb:c4:e4:e4:69)
        .... ...0 .... .... .... .... = IG bit: Individual address 
(unicast)
        .... ..1. .... .... .... .... = LG bit: Locally administered 
address (this is NOT the factory default)
    Type: IP (0x0800)
Internet Protocol Version 4, Src: 9.11.117.223 (9.11.117.223), Dst: 
9.11.117.245 (9.11.117.245)
    Version: 4
    Header length: 20 bytes
    Differentiated Services Field: 0x00 (DSCP 0x00: Default; ECN: 0x00: 
Not-ECT (Not ECN-Capable Transport))
        0000 00.. = Differentiated Services Codepoint: Default (0x00)
        .... ..00 = Explicit Congestion Notification: Not-ECT (Not 
ECN-Capable Transport) (0x00)
    Total Length: 52
    Identification: 0x4e05 (19973)
    Flags: 0x02 (Don't Fragment)
        0... .... = Reserved bit: Not set
        .1.. .... = Don't fragment: Set
        ..0. .... = More fragments: Not set
    Fragment offset: 0
    Time to live: 64
    Protocol: TCP (6)
    Header checksum: 0xeed4 [correct]
        [Good: True]
        [Bad: False]
    Source: 9.11.117.223 (9.11.117.223)
    Destination: 9.11.117.245 (9.11.117.245)
Transmission Control Protocol, Src Port: mac-srvr-admin (660), Dst Port: 
2045 (2045), Seq: 110, Ack: 30, Len: 0
    Source port: mac-srvr-admin (660)
    Destination port: 2045 (2045)
    [Stream index: 17]
    Sequence number: 110    (relative sequence number)
    Acknowledgement number: 30    (relative ack number)
    Header length: 32 bytes
    Flags: 0x010 (ACK)
        000. .... .... = Reserved: Not set
        ...0 .... .... = Nonce: Not set
        .... 0... .... = Congestion Window Reduced (CWR): Not set
        .... .0.. .... = ECN-Echo: Not set
        .... ..0. .... = Urgent: Not set
        .... ...1 .... = Acknowledgement: Set
        .... .... 0... = Push: Not set
        .... .... .0.. = Reset: Not set
        .... .... ..0. = Syn: Not set
        .... .... ...0 = Fin: Not set
    Window size value: 115
    [Calculated window size: 14720]
    [Window size scaling factor: 128]
    Checksum: 0xfe10 [validation disabled]
        [Good Checksum: False]
        [Bad Checksum: False]
    Options: (12 bytes)
        No-Operation (NOP)
        No-Operation (NOP)
        Timestamps: TSval 42532, TSecr 465248525
            Kind: Timestamp (8)
            Length: 10
            Timestamp value: 42532
            Timestamp echo reply: 465248525
    [SEQ/ACK analysis]
        [This is an ACK to the segment in frame: 758]
        [The RTT to ACK the segment was: 0.000021000 seconds]

0000  00 14 5e a5 25 6a c2 cb c4 e4 e4 69 08 00 45 00   ..^.%j.....i..E.
0010  00 34 4e 05 40 00 40 06 ee d4 09 0b 75 df 09 0b   .4N.@.@.....u...
0020  75 f5 02 94 07 fd df fe e8 90 21 7b 67 c2 80 10   u.........!{g...
0030  00 73 fe 10 00 00 01 01 08 0a 00 00 a6 24 1b bb   .s...........$..
0040  21 0d                                             !.

No.     Time        Source                Destination           Protocol 
Length Info
    760 0.477809    9.11.117.245          9.11.117.223          NFS 98 V3 
GETATTR Reply (Call In 757) Error:NFS3ERR_STALE

Frame 760: 98 bytes on wire (784 bits), 98 bytes captured (784 bits)
    Arrival Time: Jun 17, 2013 14:31:14.541925000 Central Daylight Time
    Epoch Time: 1371497474.541925000 seconds
    [Time delta from previous captured frame: 0.000380000 seconds]
    [Time delta from previous displayed frame: 0.000380000 seconds]
    [Time since reference or first frame: 0.477809000 seconds]
    Frame Number: 760
    Frame Length: 98 bytes (784 bits)
    Capture Length: 98 bytes (784 bits)
    [Frame is marked: False]
    [Frame is ignored: False]
    [Protocols in frame: eth:ip:tcp:rpc]
    [Coloring Rule Name: TCP]
    [Coloring Rule String: tcp]
Ethernet II, Src: Ibm_a5:25:6a (00:14:5e:a5:25:6a), Dst: c2:cb:c4:e4:e4:69 
(c2:cb:c4:e4:e4:69)
    Destination: c2:cb:c4:e4:e4:69 (c2:cb:c4:e4:e4:69)
        Address: c2:cb:c4:e4:e4:69 (c2:cb:c4:e4:e4:69)
        .... ...0 .... .... .... .... = IG bit: Individual address 
(unicast)
        .... ..1. .... .... .... .... = LG bit: Locally administered 
address (this is NOT the factory default)
    Source: Ibm_a5:25:6a (00:14:5e:a5:25:6a)
        Address: Ibm_a5:25:6a (00:14:5e:a5:25:6a)
        .... ...0 .... .... .... .... = IG bit: Individual address 
(unicast)
        .... ..0. .... .... .... .... = LG bit: Globally unique address 
(factory default)
    Type: IP (0x0800)
Internet Protocol Version 4, Src: 9.11.117.245 (9.11.117.245), Dst: 
9.11.117.223 (9.11.117.223)
    Version: 4
    Header length: 20 bytes
    Differentiated Services Field: 0x00 (DSCP 0x00: Default; ECN: 0x00: 
Not-ECT (Not ECN-Capable Transport))
        0000 00.. = Differentiated Services Codepoint: Default (0x00)
        .... ..00 = Explicit Congestion Notification: Not-ECT (Not 
ECN-Capable Transport) (0x00)
    Total Length: 84
    Identification: 0x0666 (1638)
    Flags: 0x00
        0... .... = Reserved bit: Not set
        .0.. .... = Don't fragment: Not set
        ..0. .... = More fragments: Not set
    Fragment offset: 0
    Time to live: 64
    Protocol: TCP (6)
    Header checksum: 0x7654 [correct]
        [Good: True]
        [Bad: False]
    Source: 9.11.117.245 (9.11.117.245)
    Destination: 9.11.117.223 (9.11.117.223)
Transmission Control Protocol, Src Port: nfs (2049), Dst Port: 725 (725), 
Seq: 42093, Ack: 42169, Len: 32
    Source port: nfs (2049)
    Destination port: 725 (725)
    [Stream index: 9]
    Sequence number: 42093    (relative sequence number)
    [Next sequence number: 42125    (relative sequence number)]
    Acknowledgement number: 42169    (relative ack number)
    Header length: 32 bytes
    Flags: 0x018 (PSH, ACK)
        000. .... .... = Reserved: Not set
        ...0 .... .... = Nonce: Not set
        .... 0... .... = Congestion Window Reduced (CWR): Not set
        .... .0.. .... = ECN-Echo: Not set
        .... ..0. .... = Urgent: Not set
        .... ...1 .... = Acknowledgement: Set
        .... .... 1... = Push: Set
        .... .... .0.. = Reset: Not set
        .... .... ..0. = Syn: Not set
        .... .... ...0 = Fin: Not set
    Window size value: 8187
    [Calculated window size: 261984]
    [Window size scaling factor: 32]
    Checksum: 0x002d [validation disabled]
        [Good Checksum: False]
        [Bad Checksum: False]
    Options: (12 bytes)
        No-Operation (NOP)
        No-Operation (NOP)
        Timestamps: TSval 465248525, TSecr 42532
            Kind: Timestamp (8)
            Length: 10
            Timestamp value: 465248525
            Timestamp echo reply: 42532
    [SEQ/ACK analysis]
        [This is an ACK to the segment in frame: 757]
        [The RTT to ACK the segment was: 0.000649000 seconds]
        [Bytes in flight: 32]
Remote Procedure Call, Type:Reply XID:0x99fe2a0b
    Fragment header: Last fragment, 28 bytes
        1... .... .... .... .... .... .... .... = Last Fragment: Yes
        .000 0000 0000 0000 0000 0000 0001 1100 = Fragment Length: 28
    XID: 0x99fe2a0b (2583570955)
    Message Type: Reply (1)
    [Program: NFS (100003)]
    [Program Version: 3]
    [Procedure: GETATTR (1)]
    Reply State: accepted (0)
    [This is a reply to a request in frame 757]
    [Time from request: 0.000649000 seconds]
    Verifier
        Flavor: AUTH_NULL (0)
        Length: 0
    Accept State: RPC executed successfully (0)
Network File System, GETATTR Reply  Error:NFS3ERR_STALE
    [Program Version: 3]
    [V3 Procedure: GETATTR (1)]
    Status: NFS3ERR_STALE (70)

0000  c2 cb c4 e4 e4 69 00 14 5e a5 25 6a 08 00 45 00   .....i..^.%j..E.
0010  00 54 06 66 00 00 40 06 76 54 09 0b 75 f5 09 0b   .T.f..@.vT..u...
0020  75 df 08 01 02 d5 ff 2a 56 bb 6a fa 65 72 80 18   u......*V.j.er..
0030  1f fb 00 2d 00 00 01 01 08 0a 1b bb 21 0d 00 00   ...-........!...
0040  a6 24 80 00 00 1c 99 fe 2a 0b 00 00 00 01 00 00   .$......*.......
0050  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
0060  00 46                                             .F

No.     Time        Source                Destination           Protocol 
Length Info
    761 0.477944    9.11.117.223          9.11.117.245          NFS 202 V3 
GETATTR Call (Reply In 762), FH:0x2039fed4

Frame 761: 202 bytes on wire (1616 bits), 202 bytes captured (1616 bits)
    Arrival Time: Jun 17, 2013 14:31:14.542060000 Central Daylight Time
    Epoch Time: 1371497474.542060000 seconds
    [Time delta from previous captured frame: 0.000135000 seconds]
    [Time delta from previous displayed frame: 0.000135000 seconds]
    [Time since reference or first frame: 0.477944000 seconds]
    Frame Number: 761
    Frame Length: 202 bytes (1616 bits)
    Capture Length: 202 bytes (1616 bits)
    [Frame is marked: False]
    [Frame is ignored: False]
    [Protocols in frame: eth:ip:tcp:rpc:nfs]
    [Coloring Rule Name: TCP]
    [Coloring Rule String: tcp]
Ethernet II, Src: c2:cb:c4:e4:e4:69 (c2:cb:c4:e4:e4:69), Dst: Ibm_a5:25:6a 
(00:14:5e:a5:25:6a)
    Destination: Ibm_a5:25:6a (00:14:5e:a5:25:6a)
        Address: Ibm_a5:25:6a (00:14:5e:a5:25:6a)
        .... ...0 .... .... .... .... = IG bit: Individual address 
(unicast)
        .... ..0. .... .... .... .... = LG bit: Globally unique address 
(factory default)
    Source: c2:cb:c4:e4:e4:69 (c2:cb:c4:e4:e4:69)
        Address: c2:cb:c4:e4:e4:69 (c2:cb:c4:e4:e4:69)
        .... ...0 .... .... .... .... = IG bit: Individual address 
(unicast)
        .... ..1. .... .... .... .... = LG bit: Locally administered 
address (this is NOT the factory default)
    Type: IP (0x0800)
Internet Protocol Version 4, Src: 9.11.117.223 (9.11.117.223), Dst: 
9.11.117.245 (9.11.117.245)
    Version: 4
    Header length: 20 bytes
    Differentiated Services Field: 0x00 (DSCP 0x00: Default; ECN: 0x00: 
Not-ECT (Not ECN-Capable Transport))
        0000 00.. = Differentiated Services Codepoint: Default (0x00)
        .... ..00 = Explicit Congestion Notification: Not-ECT (Not 
ECN-Capable Transport) (0x00)
    Total Length: 188
    Identification: 0x6543 (25923)
    Flags: 0x02 (Don't Fragment)
        0... .... = Reserved bit: Not set
        .1.. .... = Don't fragment: Set
        ..0. .... = More fragments: Not set
    Fragment offset: 0
    Time to live: 64
    Protocol: TCP (6)
    Header checksum: 0xd70e [correct]
        [Good: True]
        [Bad: False]
    Source: 9.11.117.223 (9.11.117.223)
    Destination: 9.11.117.245 (9.11.117.245)
Transmission Control Protocol, Src Port: 725 (725), Dst Port: nfs (2049), 
Seq: 42169, Ack: 42125, Len: 136
    Source port: 725 (725)
    Destination port: nfs (2049)
    [Stream index: 9]
    Sequence number: 42169    (relative sequence number)
    [Next sequence number: 42305    (relative sequence number)]
    Acknowledgement number: 42125    (relative ack number)
    Header length: 32 bytes
    Flags: 0x018 (PSH, ACK)
        000. .... .... = Reserved: Not set
        ...0 .... .... = Nonce: Not set
        .... 0... .... = Congestion Window Reduced (CWR): Not set
        .... .0.. .... = ECN-Echo: Not set
        .... ..0. .... = Urgent: Not set
        .... ...1 .... = Acknowledgement: Set
        .... .... 1... = Push: Set
        .... .... .0.. = Reset: Not set
        .... .... ..0. = Syn: Not set
        .... .... ...0 = Fin: Not set
    Window size value: 331
    [Calculated window size: 42368]
    [Window size scaling factor: 128]
    Checksum: 0xfe98 [validation disabled]
        [Good Checksum: False]
        [Bad Checksum: False]
    Options: (12 bytes)
        No-Operation (NOP)
        No-Operation (NOP)
        Timestamps: TSval 42533, TSecr 465248525
            Kind: Timestamp (8)
            Length: 10
            Timestamp value: 42533
            Timestamp echo reply: 465248525
    [SEQ/ACK analysis]
        [This is an ACK to the segment in frame: 760]
        [The RTT to ACK the segment was: 0.000135000 seconds]
        [Bytes in flight: 136]
Remote Procedure Call, Type:Call XID:0x9afe2a0b
    Fragment header: Last fragment, 132 bytes
        1... .... .... .... .... .... .... .... = Last Fragment: Yes
        .000 0000 0000 0000 0000 0000 1000 0100 = Fragment Length: 132
    XID: 0x9afe2a0b (2600348171)
    Message Type: Call (0)
    RPC Version: 2
    Program: NFS (100003)
    Program Version: 3
    Procedure: GETATTR (1)
    [The reply to this request is in frame 762]
    Credentials
        Flavor: AUTH_UNIX (1)
        Length: 56
        Stamp: 0x00418961
        Machine Name: reddy4
            length: 6
            contents: reddy4
            fill bytes: opaque data
        UID: 0
        GID: 0
        Auxiliary GIDs
            GID: 0
            GID: 1
            GID: 2
            GID: 3
            GID: 4
            GID: 6
            GID: 10
    Verifier
        Flavor: AUTH_NULL (0)
        Length: 0
Network File System, GETATTR Call FH:0x2039fed4
    [Program Version: 3]
    [V3 Procedure: GETATTR (1)]
    object
        length: 32
        [hash (CRC-32): 0x2039fed4]
        decode type as: unknown
        filehandle: 51bf60290000000000020000000000010000005100006f2e...

0000  00 14 5e a5 25 6a c2 cb c4 e4 e4 69 08 00 45 00   ..^.%j.....i..E.
0010  00 bc 65 43 40 00 40 06 d7 0e 09 0b 75 df 09 0b   ..eC@.@.....u...
0020  75 f5 02 d5 08 01 6a fa 65 72 ff 2a 56 db 80 18   u.....j.er.*V...
0030  01 4b fe 98 00 00 01 01 08 0a 00 00 a6 25 1b bb   .K...........%..
0040  21 0d 80 00 00 84 9a fe 2a 0b 00 00 00 00 00 00   !.......*.......
0050  00 02 00 01 86 a3 00 00 00 03 00 00 00 01 00 00   ................
0060  00 01 00 00 00 38 00 41 89 61 00 00 00 06 72 65   .....8.A.a....re
0070  64 64 79 34 00 00 00 00 00 00 00 00 00 00 00 00   ddy4............
0080  00 07 00 00 00 00 00 00 00 01 00 00 00 02 00 00   ................
0090  00 03 00 00 00 04 00 00 00 06 00 00 00 0a 00 00   ................
00a0  00 00 00 00 00 00 00 00 00 20 51 bf 60 29 00 00   ......... Q.`)..
00b0  00 00 00 02 00 00 00 00 00 01 00 00 00 51 00 00   .............Q..
00c0  6f 2e c0 08 00 00 00 00 00 01                     o.........

No.     Time        Source                Destination           Protocol 
Length Info
    762 0.478437    9.11.117.245          9.11.117.223          NFS 98 V3 
GETATTR Reply (Call In 761) Error:NFS3ERR_STALE

Frame 762: 98 bytes on wire (784 bits), 98 bytes captured (784 bits)
    Arrival Time: Jun 17, 2013 14:31:14.542553000 Central Daylight Time
    Epoch Time: 1371497474.542553000 seconds
    [Time delta from previous captured frame: 0.000493000 seconds]
    [Time delta from previous displayed frame: 0.000493000 seconds]
    [Time since reference or first frame: 0.478437000 seconds]
    Frame Number: 762
    Frame Length: 98 bytes (784 bits)
    Capture Length: 98 bytes (784 bits)
    [Frame is marked: False]
    [Frame is ignored: False]
    [Protocols in frame: eth:ip:tcp:rpc]
    [Coloring Rule Name: TCP]
    [Coloring Rule String: tcp]
Ethernet II, Src: Ibm_a5:25:6a (00:14:5e:a5:25:6a), Dst: c2:cb:c4:e4:e4:69 
(c2:cb:c4:e4:e4:69)
    Destination: c2:cb:c4:e4:e4:69 (c2:cb:c4:e4:e4:69)
        Address: c2:cb:c4:e4:e4:69 (c2:cb:c4:e4:e4:69)
        .... ...0 .... .... .... .... = IG bit: Individual address 
(unicast)
        .... ..1. .... .... .... .... = LG bit: Locally administered 
address (this is NOT the factory default)
    Source: Ibm_a5:25:6a (00:14:5e:a5:25:6a)
        Address: Ibm_a5:25:6a (00:14:5e:a5:25:6a)
        .... ...0 .... .... .... .... = IG bit: Individual address 
(unicast)
        .... ..0. .... .... .... .... = LG bit: Globally unique address 
(factory default)
    Type: IP (0x0800)
Internet Protocol Version 4, Src: 9.11.117.245 (9.11.117.245), Dst: 
9.11.117.223 (9.11.117.223)
    Version: 4
    Header length: 20 bytes
    Differentiated Services Field: 0x00 (DSCP 0x00: Default; ECN: 0x00: 
Not-ECT (Not ECN-Capable Transport))
        0000 00.. = Differentiated Services Codepoint: Default (0x00)
        .... ..00 = Explicit Congestion Notification: Not-ECT (Not 
ECN-Capable Transport) (0x00)
    Total Length: 84
    Identification: 0x0667 (1639)
    Flags: 0x00
        0... .... = Reserved bit: Not set
        .0.. .... = Don't fragment: Not set
        ..0. .... = More fragments: Not set
    Fragment offset: 0
    Time to live: 64
    Protocol: TCP (6)
    Header checksum: 0x7653 [correct]
        [Good: True]
        [Bad: False]
    Source: 9.11.117.245 (9.11.117.245)
    Destination: 9.11.117.223 (9.11.117.223)
Transmission Control Protocol, Src Port: nfs (2049), Dst Port: 725 (725), 
Seq: 42125, Ack: 42305, Len: 32
    Source port: nfs (2049)
    Destination port: 725 (725)
    [Stream index: 9]
    Sequence number: 42125    (relative sequence number)
    [Next sequence number: 42157    (relative sequence number)]
    Acknowledgement number: 42305    (relative ack number)
    Header length: 32 bytes
    Flags: 0x018 (PSH, ACK)
        000. .... .... = Reserved: Not set
        ...0 .... .... = Nonce: Not set
        .... 0... .... = Congestion Window Reduced (CWR): Not set
        .... .0.. .... = ECN-Echo: Not set
        .... ..0. .... = Urgent: Not set
        .... ...1 .... = Acknowledgement: Set
        .... .... 1... = Push: Set
        .... .... .0.. = Reset: Not set
        .... .... ..0. = Syn: Not set
        .... .... ...0 = Fin: Not set
    Window size value: 8187
    [Calculated window size: 261984]
    [Window size scaling factor: 32]
    Checksum: 0xfe82 [validation disabled]
        [Good Checksum: False]
        [Bad Checksum: False]
    Options: (12 bytes)
        No-Operation (NOP)
        No-Operation (NOP)
        Timestamps: TSval 465248526, TSecr 42533
            Kind: Timestamp (8)
            Length: 10
            Timestamp value: 465248526
            Timestamp echo reply: 42533
    [SEQ/ACK analysis]
        [This is an ACK to the segment in frame: 761]
        [The RTT to ACK the segment was: 0.000493000 seconds]
        [Bytes in flight: 32]
Remote Procedure Call, Type:Reply XID:0x9afe2a0b
    Fragment header: Last fragment, 28 bytes
        1... .... .... .... .... .... .... .... = Last Fragment: Yes
        .000 0000 0000 0000 0000 0000 0001 1100 = Fragment Length: 28
    XID: 0x9afe2a0b (2600348171)
    Message Type: Reply (1)
    [Program: NFS (100003)]
    [Program Version: 3]
    [Procedure: GETATTR (1)]
    Reply State: accepted (0)
    [This is a reply to a request in frame 761]
    [Time from request: 0.000493000 seconds]
    Verifier
        Flavor: AUTH_NULL (0)
        Length: 0
    Accept State: RPC executed successfully (0)
Network File System, GETATTR Reply  Error:NFS3ERR_STALE
    [Program Version: 3]
    [V3 Procedure: GETATTR (1)]
    Status: NFS3ERR_STALE (70)

0000  c2 cb c4 e4 e4 69 00 14 5e a5 25 6a 08 00 45 00   .....i..^.%j..E.
0010  00 54 06 67 00 00 40 06 76 53 09 0b 75 f5 09 0b   .T.g..@.vS..u...
0020  75 df 08 01 02 d5 ff 2a 56 db 6a fa 65 fa 80 18   u......*V.j.e...
0030  1f fb fe 82 00 00 01 01 08 0a 1b bb 21 0e 00 00   ............!...
0040  a6 25 80 00 00 1c 9a fe 2a 0b 00 00 00 01 00 00   .%......*.......
0050  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
0060  00 46                                             .F


Christopher Vogan
Dept. W98 NFS Development & Test

