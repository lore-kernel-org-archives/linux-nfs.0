Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.math.uh.edu ([129.7.128.32]:54510 "EHLO mx1.math.uh.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750956AbcB2XGi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Feb 2016 18:06:38 -0500
From: Jason L Tibbitts III <tibbs@math.uh.edu>
To: bfields@fieldses.org (J. Bruce Fields)
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS: nfs4_reclaim_open_state: Lock reclaim failed! log spew
References: <ufafuwhlr72.fsf@epithumia.math.uh.edu>
	<20160225195827.GC23315@fieldses.org>
Date: Mon, 29 Feb 2016 17:06:35 -0600
In-Reply-To: <20160225195827.GC23315@fieldses.org> (J. Bruce Fields's message
	of "Thu, 25 Feb 2016 14:58:27 -0500")
Message-ID: <ufaegbvdslg.fsf@epithumia.math.uh.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>>>>> "JBF" == J Bruce Fields <bfields@fieldses.org> writes:

>> Unfortunately I did not grab any of that traffic (I just wanted it to
>> stop).  This happens to me periodically so I'll be sure to do that
>> when it hits again.

JBF> OK, that'd be helpful.

I waited a bit and it's happened again from a few clients.  I captured
some traffic from one of them and it's just an endless stream of
Call/Reply:

  8 0.002842000 172.21.86.135 -> 172.21.86.78 NFS 406 V4 Call
  9 0.003493000 172.21.86.78 -> 172.21.86.135 NFS 518 V4 Reply (Call In  8)
 10 0.003536000 172.21.86.135 -> 172.21.86.78 NFS 406 V4 Call
 11 0.004168000 172.21.86.78 -> 172.21.86.135 NFS 518 V4 Reply (Call In 10)
 12 0.004252000 172.21.86.135 -> 172.21.86.78 NFS 406 V4 Call
 13 0.004854000 172.21.86.78 -> 172.21.86.135 NFS 518 V4 Reply (Call In 12)
 14 0.004931000 172.21.86.135 -> 172.21.86.78 NFS 406 V4 Call
 15 0.005613000 172.21.86.78 -> 172.21.86.135 NFS 518 V4 Reply (Call In 14)


Here's a call:

Frame 8: 406 bytes on wire (3248 bits), 406 bytes captured (3248 bits) on interface 0
    Interface id: 0 (eno1)
    Encapsulation type: Ethernet (1)
    Arrival Time: Feb 29, 2016 16:48:17.376573000 CST
    [Time shift for this packet: 0.000000000 seconds]
    Epoch Time: 1456786097.376573000 seconds
    [Time delta from previous captured frame: 0.000049000 seconds]
    [Time delta from previous displayed frame: 0.000000000 seconds]
    [Time since reference or first frame: 0.002842000 seconds]
    Frame Number: 8
    Frame Length: 406 bytes (3248 bits)
    Capture Length: 406 bytes (3248 bits)
    [Frame is marked: False]
    [Frame is ignored: False]
    [Protocols in frame: eth:ethertype:ip:tcp:rpc:gss-api:spnego-krb5:spnego-krb5]
Ethernet II, Src: AsustekC_6d:f1:7e (f0:79:59:6d:f1:7e), Dst: SuperMic_19:86:94 (00:25:90:19:86:94)
    Destination: SuperMic_19:86:94 (00:25:90:19:86:94)
        Address: SuperMic_19:86:94 (00:25:90:19:86:94)
        .... ..0. .... .... .... .... = LG bit: Globally unique address (factory default)
        .... ...0 .... .... .... .... = IG bit: Individual address (unicast)
    Source: AsustekC_6d:f1:7e (f0:79:59:6d:f1:7e)
        Address: AsustekC_6d:f1:7e (f0:79:59:6d:f1:7e)
        .... ..0. .... .... .... .... = LG bit: Globally unique address (factory default)
        .... ...0 .... .... .... .... = IG bit: Individual address (unicast)
    Type: IP (0x0800)
Internet Protocol Version 4, Src: 172.21.86.135 (172.21.86.135), Dst: 172.21.86.78 (172.21.86.78)
    Version: 4
    Header Length: 20 bytes
    Differentiated Services Field: 0x00 (DSCP 0x00: Default; ECN: 0x00: Not-ECT (Not ECN-Capable Transport))
        0000 00.. = Differentiated Services Codepoint: Default (0x00)
        .... ..00 = Explicit Congestion Notification: Not-ECT (Not ECN-Capable Transport) (0x00)
    Total Length: 392
    Identification: 0x79da (31194)
    Flags: 0x02 (Don't Fragment)
        0... .... = Reserved bit: Not set
        .1.. .... = Don't fragment: Set
        ..0. .... = More fragments: Not set
    Fragment offset: 0
    Time to live: 64
    Protocol: TCP (6)
    Header checksum: 0xba95 [validation disabled]
        [Good: False]
        [Bad: False]
    Source: 172.21.86.135 (172.21.86.135)
    Destination: 172.21.86.78 (172.21.86.78)
    [Source GeoIP: Unknown]
    [Destination GeoIP: Unknown]
Transmission Control Protocol, Src Port: 863 (863), Dst Port: 2049 (2049), Seq: 1361, Ack: 2261, Len: 340
    Source Port: 863 (863)
    Destination Port: 2049 (2049)
    [Stream index: 0]
    [TCP Segment Len: 340]
    Sequence number: 1361    (relative sequence number)
    [Next sequence number: 1701    (relative sequence number)]
    Acknowledgment number: 2261    (relative ack number)
    Header Length: 32 bytes
    .... 0000 0001 1000 = Flags: 0x018 (PSH, ACK)
        000. .... .... = Reserved: Not set
        ...0 .... .... = Nonce: Not set
        .... 0... .... = Congestion Window Reduced (CWR): Not set
        .... .0.. .... = ECN-Echo: Not set
        .... ..0. .... = Urgent: Not set
        .... ...1 .... = Acknowledgment: Set
        .... .... 1... = Push: Set
        .... .... .0.. = Reset: Not set
        .... .... ..0. = Syn: Not set
        .... .... ...0 = Fin: Not set
    Window size value: 24576
    [Calculated window size: 24576]
    [Window size scaling factor: -1 (unknown)]
    Checksum: 0x067b [validation disabled]
        [Good Checksum: False]
        [Bad Checksum: False]
    Urgent pointer: 0
    Options: (12 bytes), No-Operation (NOP), No-Operation (NOP), Timestamps
        No-Operation (NOP)
            Type: 1
                0... .... = Copy on fragmentation: No
                .00. .... = Class: Control (0)
                ...0 0001 = Number: No-Operation (NOP) (1)
        No-Operation (NOP)
            Type: 1
                0... .... = Copy on fragmentation: No
                .00. .... = Class: Control (0)
                ...0 0001 = Number: No-Operation (NOP) (1)
        Timestamps: TSval 1220154220, TSecr 882989725
            Kind: Time Stamp Option (8)
            Length: 10
            Timestamp value: 1220154220
            Timestamp echo reply: 882989725
    [SEQ/ACK analysis]
        [This is an ACK to the segment in frame: 7]
        [The RTT to ACK the segment was: 0.000049000 seconds]
        [Bytes in flight: 340]
Remote Procedure Call, Type:Call XID:0xffb2b86a
    Fragment header: Last fragment, 336 bytes
        1... .... .... .... .... .... .... .... = Last Fragment: Yes
        .000 0000 0000 0000 0000 0001 0101 0000 = Fragment Length: 336
    XID: 0xffb2b86a (4289902698)
    Message Type: Call (0)
    RPC Version: 2
    Program: NFS (100003)
    Program Version: 4
    Procedure: COMPOUND (1)
    Credentials
        Flavor: RPCSEC_GSS (6)
        Length: 28
        GSS Version: 1
        GSS Procedure: RPCSEC_GSS_DATA (0)
        GSS Sequence Number: 59958333
        GSS Service: rpcsec_gss_svc_privacy (3)
        GSS Context
            GSS Context Length: 8
            GSS Context: 6d35000000000000
    Verifier
        Flavor: RPCSEC_GSS (6)
        GSS Token: 0000001c040404ffffffffff000000001bb5b424f2b2f47f...
            GSS Token Length: 28
            GSS-API Generic Security Service Application Program Interface
                krb5_blob: 040404ffffffffff000000001bb5b424f2b2f47fb068d17e...
                    krb5_tok_id: KRB_TOKEN_CFX_GetMic (0x0404)
                    krb5_cfx_flags: 0x04
                        .... .1.. = AcceptorSubkey: Set
                        .... ..0. = Sealed: Not set
                        .... ...0 = SendByAcceptor: Not set
                    krb5_filler: ffffffffff
                    krb5_cfx_seq: 464892964
                    krb5_sgn_cksum: f2b2f47fb068d17e40fca641
GSS-Wrap
    Length: 236
    GSS Data: 050406ff00000000000000001bb5b425d745e53e92ca2305...
    krb5_blob: 050406ff00000000000000001bb5b425d745e53e92ca2305...
        krb5_tok_id: KRB_TOKEN_CFX_WRAP (0x0405)
        krb5_cfx_flags: 0x06
            .... .1.. = AcceptorSubkey: Set
            .... ..1. = Sealed: Set
            .... ...0 = SendByAcceptor: Not set
        krb5_filler: ff
        krb5_cfx_ec: 0
        krb5_cfx_rrc: 0
        krb5_cfx_seq: 464892965
        krb5_sgn_cksum: d745e53e92ca2305e3b1f3bdbb6c710bd731fcc684b8dba8...
Network File System
    [Program Version: 4]
    [V4 Procedure: COMPOUND (1)]


And here's a reply:

Frame 9: 518 bytes on wire (4144 bits), 518 bytes captured (4144 bits) on interface 0
    Interface id: 0 (eno1)
    Encapsulation type: Ethernet (1)
    Arrival Time: Feb 29, 2016 16:48:17.377224000 CST
    [Time shift for this packet: 0.000000000 seconds]
    Epoch Time: 1456786097.377224000 seconds
    [Time delta from previous captured frame: 0.000651000 seconds]
    [Time delta from previous displayed frame: 0.000000000 seconds]
    [Time since reference or first frame: 0.003493000 seconds]
    Frame Number: 9
    Frame Length: 518 bytes (4144 bits)
    Capture Length: 518 bytes (4144 bits)
    [Frame is marked: False]
    [Frame is ignored: False]
    [Protocols in frame: eth:ethertype:ip:tcp:rpc:gss-api:spnego-krb5:spnego-krb5]
Ethernet II, Src: SuperMic_19:86:94 (00:25:90:19:86:94), Dst: AsustekC_6d:f1:7e (f0:79:59:6d:f1:7e)
    Destination: AsustekC_6d:f1:7e (f0:79:59:6d:f1:7e)
        Address: AsustekC_6d:f1:7e (f0:79:59:6d:f1:7e)
        .... ..0. .... .... .... .... = LG bit: Globally unique address (factory default)
        .... ...0 .... .... .... .... = IG bit: Individual address (unicast)
    Source: SuperMic_19:86:94 (00:25:90:19:86:94)
        Address: SuperMic_19:86:94 (00:25:90:19:86:94)
        .... ..0. .... .... .... .... = LG bit: Globally unique address (factory default)
        .... ...0 .... .... .... .... = IG bit: Individual address (unicast)
    Type: IP (0x0800)
Internet Protocol Version 4, Src: 172.21.86.78 (172.21.86.78), Dst: 172.21.86.135 (172.21.86.135)
    Version: 4
    Header Length: 20 bytes
    Differentiated Services Field: 0x00 (DSCP 0x00: Default; ECN: 0x00: Not-ECT (Not ECN-Capable Transport))
        0000 00.. = Differentiated Services Codepoint: Default (0x00)
        .... ..00 = Explicit Congestion Notification: Not-ECT (Not ECN-Capable Transport) (0x00)
    Total Length: 504
    Identification: 0x2bf6 (11254)
    Flags: 0x02 (Don't Fragment)
        0... .... = Reserved bit: Not set
        .1.. .... = Don't fragment: Set
        ..0. .... = More fragments: Not set
    Fragment offset: 0
    Time to live: 64
    Protocol: TCP (6)
    Header checksum: 0x080a [validation disabled]
        [Good: False]
        [Bad: False]
    Source: 172.21.86.78 (172.21.86.78)
    Destination: 172.21.86.135 (172.21.86.135)
    [Source GeoIP: Unknown]
    [Destination GeoIP: Unknown]
Transmission Control Protocol, Src Port: 2049 (2049), Dst Port: 863 (863), Seq: 2261, Ack: 1701, Len: 452
    Source Port: 2049 (2049)
    Destination Port: 863 (863)
    [Stream index: 0]
    [TCP Segment Len: 452]
    Sequence number: 2261    (relative sequence number)
    [Next sequence number: 2713    (relative sequence number)]
    Acknowledgment number: 1701    (relative ack number)
    Header Length: 32 bytes
    .... 0000 0001 1000 = Flags: 0x018 (PSH, ACK)
        000. .... .... = Reserved: Not set
        ...0 .... .... = Nonce: Not set
        .... 0... .... = Congestion Window Reduced (CWR): Not set
        .... .0.. .... = ECN-Echo: Not set
        .... ..0. .... = Urgent: Not set
        .... ...1 .... = Acknowledgment: Set
        .... .... 1... = Push: Set
        .... .... .0.. = Reset: Not set
        .... .... ..0. = Syn: Not set
        .... .... ...0 = Fin: Not set
    Window size value: 32885
    [Calculated window size: 32885]
    [Window size scaling factor: -1 (unknown)]
    Checksum: 0x8ac4 [validation disabled]
        [Good Checksum: False]
        [Bad Checksum: False]
    Urgent pointer: 0
    Options: (12 bytes), No-Operation (NOP), No-Operation (NOP), Timestamps
        No-Operation (NOP)
            Type: 1
                0... .... = Copy on fragmentation: No
                .00. .... = Class: Control (0)
                ...0 0001 = Number: No-Operation (NOP) (1)
        No-Operation (NOP)
            Type: 1
                0... .... = Copy on fragmentation: No
                .00. .... = Class: Control (0)
                ...0 0001 = Number: No-Operation (NOP) (1)
        Timestamps: TSval 882989725, TSecr 1220154220
            Kind: Time Stamp Option (8)
            Length: 10
            Timestamp value: 882989725
            Timestamp echo reply: 1220154220
    [SEQ/ACK analysis]
        [This is an ACK to the segment in frame: 8]
        [The RTT to ACK the segment was: 0.000651000 seconds]
        [Bytes in flight: 452]
Remote Procedure Call, Type:Reply XID:0xffb2b86a
    Fragment header: Last fragment, 448 bytes
        1... .... .... .... .... .... .... .... = Last Fragment: Yes
        .000 0000 0000 0000 0000 0001 1100 0000 = Fragment Length: 448
    XID: 0xffb2b86a (4289902698)
    Message Type: Reply (1)
    [Program: NFS (100003)]
    [Program Version: 4]
    [Procedure: COMPOUND (1)]
    Reply State: accepted (0)
    [This is a reply to a request in frame 8]
    [Time from request: 0.000651000 seconds]
    Verifier
        Flavor: RPCSEC_GSS (6)
        GSS Token: 0000001c040405ffffffffff000000003480887866d9d129...
            GSS Token Length: 28
            GSS-API Generic Security Service Application Program Interface
                krb5_blob: 040405ffffffffff000000003480887866d9d129415f2ea7...
                    krb5_tok_id: KRB_TOKEN_CFX_GetMic (0x0404)
                    krb5_cfx_flags: 0x05
                        .... .1.. = AcceptorSubkey: Set
                        .... ..0. = Sealed: Not set
                        .... ...1 = SendByAcceptor: Set
                    krb5_filler: ffffffffff
                    krb5_cfx_seq: 880838776
                    krb5_sgn_cksum: 66d9d129415f2ea76c509189
    Accept State: RPC executed successfully (0)
GSS-Wrap
    Length: 392
    GSS Data: 050407ff000000000000000034808879d55c1d7af7af82f5...
    krb5_blob: 050407ff000000000000000034808879d55c1d7af7af82f5...
        krb5_tok_id: KRB_TOKEN_CFX_WRAP (0x0405)
        krb5_cfx_flags: 0x07
            .... .1.. = AcceptorSubkey: Set
            .... ..1. = Sealed: Set
            .... ...1 = SendByAcceptor: Set
        krb5_filler: ff
        krb5_cfx_ec: 0
        krb5_cfx_rrc: 0
        krb5_cfx_seq: 880838777
        krb5_sgn_cksum: d55c1d7af7af82f5384db9579420a0e8eb2bf20013a66022...
Network File System
    [Program Version: 4]
    [V4 Procedure: COMPOUND (1)]

The calls and replies all appear to be identical.  Sorry for the length
of those but I wouldn't want to trim anything that might be important.

JBF> Unfortunately what would probably be *most* helpful would be the
JBF> traffic that lead up to this--by the time the client and server get
JBF> into this loop the interesting problem may have already
JBF> happened--but just seeing the loop may be useful too.

Yeah, there's basically no chance of capturing that, and I have no way
to make it happen.  I can't just snarf all of the NFS traffic, and once
this starts it generates so many packets....

Note that this doesn't appear to be caused by something like a kerberos
ticket; the user last logged in well under the maximum ticket renewal
time, and SSSD has been dutifully renewing them.

 - J<
