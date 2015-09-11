Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:40656 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751352AbbIKLiu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Sep 2015 07:38:50 -0400
Date: Fri, 11 Sep 2015 12:38:39 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Subject: NFS/TCP/IPv6 acting strangely in 4.2
Message-ID: <20150911113839.GO21084@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have a recent Marvell Armada 388 board here which uses the mvneta
driver.  I'm seeing some weird effects with NFS with it acting as a
client.  Unfortunately, the board does not have a functional RTC.

The NFS server is the same NFS server that I've used for years with
multiple other clients (it's my main NFS server) and it continues to
support all other clients without any ill effect.  The NFS server
kernel is rather old now, being a 3.x kernel.

The NFS client appears to connect using TCP/IPv6 and initially is
accessible.  Everything appears to work normally, and then the NFS
server appears to stop responding.

Running tcpdump on the NFS server, and then dumping the captured packets
with tshark (because tcpdump appears not to understand IPv6 SYNs on the
NFS port) shows:

  1   0.000000 fe80::250:43ff:fe02:201 -> fe80::214:fdff:fe10:4f86 ICMPv6 Neighbor Solicitation for fe80::214:fdff:fe10:4f86 from 00:50:43:02:02:01
  2   0.000252 fe80::214:fdff:fe10:4f86 -> fe80::250:43ff:fe02:201 ICMPv6 Neighbor Advertisement fe80::214:fdff:fe10:4f86 (sol)
  3   0.030036 armada388 -> n2100 TCP 843→nfs [SYN] Seq=936803106 Win=28800 Len=0 MSS=1440 SACK_PERM=1 TSval=892366 TSecr=0 WS=128
  4   0.030409 n2100 -> armada388 TCP nfs→843 [SYN, ACK] Seq=409465870 Ack=936803107 Win=28560 Len=0 MSS=1440 SACK_PERM=1 TSval=818169117 TSecr=892366 WS=64
  5   0.030493 armada388 -> n2100 TCP [TCP Port numbers reused] 843→nfs [SYN] Seq=936803633 Win=28800 Len=0 MSS=1440 SACK_PERM=1 TSval=892366 TSecr=0 WS=128
  6   0.030699 n2100 -> armada388 TCP nfs→843 [RST, ACK] Seq=0 Ack=936803634 Win=0 Len=0
  7   0.030766 armada388 -> n2100 TCP 843→nfs [RST] Seq=936803107 Win=0 Len=0
  8   3.040150 armada388 -> n2100 TCP [TCP Port numbers reused] 843→nfs [SYN] Seq=983834371 Win=28800 Len=0 MSS=1440 SACK_PERM=1 TSval=892667 TSecr=0 WS=128
  9   3.040467 n2100 -> armada388 TCP nfs→843 [SYN, ACK] Seq=456498252 Ack=983834372 Win=28560 Len=0 MSS=1440 SACK_PERM=1 TSval=818169418 TSecr=892667 WS=64
 10   3.040552 armada388 -> n2100 TCP [TCP Port numbers reused] 843→nfs [SYN] Seq=983834922 Win=28800 Len=0 MSS=1440 SACK_PERM=1 TSval=892667 TSecr=0 WS=128
 11   3.040771 n2100 -> armada388 TCP nfs→843 [RST, ACK] Seq=0 Ack=983834923 Win=0 Len=0
 12   3.040845 armada388 -> n2100 TCP 843→nfs [RST] Seq=983834372 Win=0 Len=0
 13   6.050296 armada388 -> n2100 TCP [TCP Port numbers reused] 843→nfs [SYN] Seq=1030865629 Win=28800 Len=0 MSS=1440 SACK_PERM=1 TSval=892968 TSecr=0 WS=128
 14   6.050673 n2100 -> armada388 TCP nfs→843 [SYN, ACK] Seq=503532268 Ack=1030865630 Win=28560 Len=0 MSS=1440 SACK_PERM=1 TSval=818169719 TSecr=892968 WS=64
 15   6.050761 armada388 -> n2100 TCP [TCP Port numbers reused] 843→nfs [SYN] Seq=1030866205 Win=28800 Len=0 MSS=1440 SACK_PERM=1 TSval=892968 TSecr=0 WS=128

It seems rather strange that the Armada388 NFS client is trying to
connect _two_ TCP/IPv6 connections from the same address and the same
port but with different sequence numbers (which suggests that packet
numbers 5, 10 and 15 are the problem ones.

However, what happens with the reset packets is most interesting.
Packet 6 looks like it's resetting the duplicate connection caused by
packet 5.  Packet 7 looks like it's resetting the initial connection
from packet 4.

It seems fairly reproducable, though I haven't worked out exactly what
triggers it.

Is this a known bug?  Any ideas where to start looking?

Thanks.

-- 
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
