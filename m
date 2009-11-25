From: "Stephen R. van den Berg" <srb-PCMv+cxZuL0@public.gmane.org>
Subject: Re: Fw: Deadlock regression in v2.6.31.6
Date: Thu, 26 Nov 2009 00:11:55 +0100
Message-ID: <64b4daae0911251511q7a070b0aj1c07cdc5d6719b41@mail.gmail.com>
References: <20091124233555.da6439c4.akpm@linux-foundation.org>
	 <64b4daae0911250056g3364d24l98850a272dcfe483@mail.gmail.com>
	 <1259159512.3314.12.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:33118 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753678AbZKYXLu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Nov 2009 18:11:50 -0500
Received: by fg-out-1718.google.com with SMTP id e12so124414fga.1
        for <linux-nfs@vger.kernel.org>; Wed, 25 Nov 2009 15:11:56 -0800 (PST)
In-Reply-To: <1259159512.3314.12.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 25, 2009 at 15:31, Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:
> On Wed, 2009-11-25 at 09:56 +0100, Stephen R. van den Berg wrote:
>> RPC: =A09697 setting alarm for 60000 ms
>> RPC: =A09697 __rpc_wake_up_task (now 7827)
>> RPC: =A09697 disabling timer
>> RPC: =A09697 removed from queue cfa72d88 "xprt_pending"
>> RPC: =A0 =A0 =A0 __rpc_wake_up_task done
>> RPC: =A09697 __rpc_execute flags=3D0x1 cf849c44

>> The kernel hangs at this point, the only way to get out of there is
>> using SysBreak.

> This just means that the RPC client is waiting for a reply from the N=
=46S
> server.

> Does 'netstat -t' show that there is an active TCP connection to the
> server's nfs port?
> Does wireshark show that the client should have received a reply?

Got a pcap file captured by tcpdump on a Linux router in between the tw=
o.
The NFS server is a unfs3 0.9.22+dfsg-2 (Debian) running in 32-bit
userspace on a server using a 2.6.31.5 Linux kernel in 64-bit
kernelspace on HP hardware using a hardware accellerated network card
which splits up TCP packets by itself before putting them on the wire.
The pcap is the result that is found on the wire by capturing it on an
intermediate machine.
The nfs daemon doesn't show any log messages.

The pcap file can (temporarily) be found at:
  http://master.icecube.cuci.nl/linuxkerntcpnfs-linuxclient.pcap.gz

A sneak preview of the last remaining packets is:
----------------------------------------------
23:53:47.028266 IP (tos 0x0, ttl 64, id 14117, offset 0, flags [DF],
proto TCP (6), length 168)
    1.2.3.167.1912647778 > 1.2.3.151.2049: 124 lookup fh
Unknown/00090000824B680000000000824B68000000000007E00F0CAF49AAA10000000=
=46
"netkit-rsh.1.gz"
23:53:47.028642 IP (tos 0x0, ttl 63, id 29190, offset 0, flags [DF],
proto TCP (6), length 284)
    1.2.3.151.2049 > 1.2.3.167.1912647778: reply ok 240 lookup fh
Unknown/00090000514A680000000000514A68000000000008E00F0CAF49AAA17300000=
0
REG 1 ids 1/0 sz 0 nlink 33188 rdev 4096/0 fsid 0 fileid 90000000000
a/m/ctime 6834769.1254731170 0.1187257038 0.1254731185 post dattr:
23:53:47.029104 IP (tos 0x0, ttl 64, id 14118, offset 0, flags [DF],
proto TCP (6), length 164)
    1.2.3.167.1929424994 > 1.2.3.151.2049: 120 lookup fh
Unknown/00090000824B680000000000824B68000000000007E00F0CAF49AAA10000000=
B
"wbinfo.1.gz"
23:53:47.029502 IP (tos 0x0, ttl 63, id 29191, offset 0, flags [DF],
proto TCP (6), length 284)
    1.2.3.151.2049 > 1.2.3.167.1929424994: reply ok 240 lookup fh
Unknown/00090000C2D9650000000000C2D965000000000008E00F0CAF49AAA17E00000=
0
REG 1 ids 1/0 sz 0 nlink 33188 rdev 4096/0 fsid 0 fileid 90000000000
a/m/ctime 6674882.1259187953 0.1254554345 0.1257462034 post dattr:
23:53:47.029946 IP (tos 0x0, ttl 64, id 14119, offset 0, flags [DF],
proto TCP (6), length 152)
    1.2.3.167.1946202210 > 1.2.3.151.2049: 108 getattr fh
Unknown/00090000C2D9650000000000C2D965000000000008E00F0CAF49AAA17E00000=
0
23:53:47.030258 IP (tos 0x0, ttl 63, id 29192, offset 0, flags [DF],
proto TCP (6), length 156)
    1.2.3.151.2049 > 1.2.3.167.1946202210: reply ok 112 getattr REG
100644 ids 0/0 sz 3872
23:53:47.030537 IP (tos 0x0, ttl 64, id 14120, offset 0, flags [DF],
proto TCP (6), length 156)
    1.2.3.167.1962979426 > 1.2.3.151.2049: 112 access fh
Unknown/00090000C2D9650000000000C2D965000000000008E00F0CAF49AAA17E00000=
0
7e000000
23:53:47.030853 IP (tos 0x0, ttl 63, id 29193, offset 0, flags [DF],
proto TCP (6), length 164)
    1.2.3.151.2049 > 1.2.3.167.1962979426: reply ok 120 access attr:
REG 100644 ids 0/0 sz 3872 nlink 1 rdev 0/0 fsid 900 fileid 65d9c2
a/m/ctime 1259187953.000000 1254554345.000000 1257462034.000000 c 0001
23:53:47.032528 IP (tos 0x0, ttl 64, id 14121, offset 0, flags [DF],
proto TCP (6), length 164)
    1.2.3.167.1979756642 > 1.2.3.151.2049: 120 read fh
Unknown/00090000C2D9650000000000C2D965000000000008E00F0CAF49AAA17E00000=
0
0 bytes @ 9079256848778919936
23:53:47.033322 IP (tos 0x0, ttl 63, id 29194, offset 0, flags [DF],
proto TCP (6), length 1500)
    1.2.3.151.2049 > 1.2.3.167.1979756642: reply ok 1456 read REG
100644 ids 0/0 sz 3872 nlink 1 rdev 0/0 fsid 900 fileid 65d9c2
a/m/ctime 1259187953.000000 1254554345.000000 1257462034.000000 3872
bytes EOF
23:53:47.033447 IP (tos 0x0, ttl 63, id 29195, offset 0, flags [DF],
proto TCP (6), length 1500)
    1.2.3.151.2049 > 1.2.3.167.739: Flags [.], cksum 0x3c5c (correct),
seq 40440:41900, ack 305937, win 65535, length 1460
23:53:47.033540 IP (tos 0x0, ttl 63, id 29196, offset 0, flags [DF],
proto TCP (6), length 1120)
    1.2.3.151.2049 > 1.2.3.167.739: Flags [P.], cksum 0x75cc
(correct), seq 41900:42980, ack 305937, win 65535, length 1080
23:53:47.034112 IP (tos 0x0, ttl 64, id 14122, offset 0, flags [DF],
proto TCP (6), length 40)
    1.2.3.167.739 > 1.2.3.151.2049: Flags [.], cksum 0x0c81 (correct),
seq 305937, ack 41900, win 65535, length 0
23:53:47.068991 IP (tos 0x0, ttl 64, id 14123, offset 0, flags [DF],
proto TCP (6), length 40)
    1.2.3.167.739 > 1.2.3.151.2049: Flags [.], cksum 0x0849 (correct),
seq 305937, ack 42980, win 65535, length 0
23:53:47.069180 IP (tos 0x0, ttl 63, id 29197, offset 0, flags [DF],
proto TCP (6), length 48)
    1.2.3.151.2049 > 1.2.3.167.739: Flags [P.], cksum 0xd905
(correct), seq 42980:42988, ack 305937, win 65535, length 8
23:53:47.069335 IP (tos 0x0, ttl 64, id 14124, offset 0, flags [DF],
proto TCP (6), length 40)
    1.2.3.167.739 > 1.2.3.151.2049: Flags [.], cksum 0x0841 (correct),
seq 305937, ack 42988, win 65535, length 0
23:53:47.069393 IP (tos 0x0, ttl 64, id 14125, offset 0, flags [DF],
proto TCP (6), length 40)
    1.2.3.167.739 > 1.2.3.151.2049: Flags [F.], cksum 0x0840
(correct), seq 305937, ack 42988, win 65535, length 0
23:53:47.069589 IP (tos 0x0, ttl 63, id 29198, offset 0, flags [DF],
proto TCP (6), length 40)
    1.2.3.151.2049 > 1.2.3.167.739: Flags [F.], cksum 0x083f
(correct), seq 42988, ack 305938, win 65535, length 0
23:53:47.069747 IP (tos 0x0, ttl 64, id 14126, offset 0, flags [DF],
proto TCP (6), length 40)
    1.2.3.167.739 > 1.2.3.151.2049: Flags [.], cksum 0x083f (correct),
seq 305938, ack 42989, win 65535, length 0
---------------------------------------------------

1.2.3.167 is the Linux client kernel which locks up, 1.2.3.151 is the
unfs server.
It looks like the client terminates the TCP connection.  The server
confirms it, the client then sends a final acknowledge.  At that point
the client kernel locks up in the infinite loop.
--=20
Sincerely,
                Stephen R. van den Berg.
