From: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Subject: 2.6.0 NFS-server low to 0 performance (fwd)
Date: Wed, 7 Jan 2004 14:31:27 +0100 (CET)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.44.0401071351080.4855-100000@poirot.grange>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <linux-net@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: nfs@lists.sourceforge.net
List-ID: <nfs.lists.sourceforge.net>

Sorry for cross-posting - wasn't sure which list would give the best
chances.

I am forwarding a problem-report, sent yesterday to lkml with a bit more
data.

Short: The NFS server on a PC with a 2.6.0 (release) kernel slows down to
a crawl or stops completely.

Searched archives - nothing fits exact enough.

The server (PC1) is a 900MHz Duron with 384M RAM and a tulip 10/100
(LinkSys) network card (Linksys Network Everywhere Fast Ethernet 10/100
model NC100 (rev 17)).

Clients:
PC2 - Pentium 133MHz with 24M RAM and an onboard Lance 79C970 10mbps
network card,
a SA1100 platform (Tuxscreen / Shannon) with 16M RAM, PCMCIA Netgear
10/100mbps ne2000-compatible (pcnet_cs + 8390) card
a PXA250 platform (Inphinity / Triton starter-kit) with 64M RAM, onboard
SMC91C11xFD (smc91x driver) 10/100 chip

In the tests below I was copying a 4M file from an NFS-mounted
directory to a RAM-based fs (ramfs / tmpfs). Here are results:

server with 2.6.0 kernel:

PC2:2.6.0-test11	2m21s (*)
PC2:2.4.20		16.5s
SA1100:2.4.19-rmk7	never finishes (*)
PXA:2.4.21-rmk1-pxa1	as above
PXA:2.6.0-rmk1-pxa	as above

server: 2.4.21

PC2:2.6.0-test11	6s
PC2:2.4.20		5s
SA1100:2.4.19-rmk7	3.22s
PXA:2.4.21-rmk1-pxa1	7s
PXA:2.6.0-rmk2-pxa	1) 50s (**)
(***)			2) 27s (**)

(*) Messages "NFS server not responding" / "NFS server OK", "mount version
older than kernel" on mount

(**) Messages "NFS server not responding" / "NFS server OK", "mount version
older than kernel" on mount, trafic shows as several peaks

(***) 2.6.0-rmk2-pxa corresponds to the 2.6.0-rmk2 kernel with a PXA-patch
forward-ported from diff-2.6.0-test2-rmk1-pxa1.

The LinkSys card I bought recently, before I used a RTL (3c59x) card, only
capable of 10mbps. Here are the results of today with this card:

server: 2.6.0

PC2: 2.6.0-test11	9s
PC2: 2.4.20		4s
SA1100: 2.4.19-rmk7	never finishes

server: 2.4.21

SA1100: 2.4.19-rmk7	6s

Then I tried PC2 as a server with different kernels
PC2: 2.6.0-test11

PC1: 2.6.0		10s
SA1100: 2.4.19-rmk7	never finishes

server PC2: 2.4.20

PC1: 2.6.0		6s
SA1100: 2.4.19-rmk7	7s

It is not just a problem of 2.6 with those specific network configurations
- ftp / http / tftp transfers work fine. E.g. wget of the same file on the
PXA with 2.6.0 from the PC1 with 2.4.21 over http takes about 2s. So, it
is 2.6 + NFS. nfs-utils on both PC1 and PC2 version 1.0.6 (Debian Sarge).

Is it fixed somewhere (2.6.1-rcx?), or what should I try / what further
information is required?

Sorry, I am not subscribed to any of these lists, so, please, CC.

Thanks
Guennadi
---
Guennadi Liakhovetski






