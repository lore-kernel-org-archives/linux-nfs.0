Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from netnation.com ([204.174.223.2]:52645 "EHLO peace.netnation.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753403Ab0KETFh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Nov 2010 15:05:37 -0400
Received: from sim by peace.netnation.com with local (Exim 4.69)
	(envelope-from <sim@netnation.com>)
	id 1PERIq-0001Kh-SE
	for linux-nfs@vger.kernel.org; Fri, 05 Nov 2010 11:46:20 -0700
Date: Fri, 5 Nov 2010 11:46:20 -0700
From: Simon Kirby <sim@hostway.ca>
To: linux-nfs@vger.kernel.org
Subject: sunrpc wedging on 2.6.35.4, 2.6.36
Message-ID: <20101105184620.GC32070@hostway.ca>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello!

We're seeing a problems with the NFSv3 client in 2.6.35 and 2.6.36, and
possibly earlier, on one of our web clusters.  This is occurring with UDP
or TCP mounts.  We were using UDP as we were still having long delays
with HA fail-over while using TCP.  Since seeing this problem, we have
tried TCP again, but the problem still occurs.  The NFS servers in this
case are a mix of mostly 2.6.30.10 (which we had to use to work around
XFS inode reclaim issues), and some 2.6.31.5, 2.6.33, 2.6.35.4 for
various reasons.

While this problem happens, load skyrockets and almost all proceses are
stuck in D state in rpc_wait_bit_killable.  I can mount and unmount
something with a UDP transport with no problem, but "df" and all the
usual TCP mounts hang.  I've lowered the slots to 8 here to try to make
the problem more clear, but there are hundreds of things backlogged.

Of interest, see this snippet from while enabling rpc_debug:

-pid- flgs status -client- --rqstp- -timeout ---ops--
31788 0681    -11 ffff88010d4f2600 ffff880114ccb000        0 ffffffff8172c530 rpcbindv2 GETPORT a:call_connect_status q:none
23736 0681    -11 ffff88007a480400 ffff880111988000        0 ffffffff8172c530 rpcbindv2 GETPORT a:call_connect_status q:none
20576 0001      0 ffff880045557400   (null)        0 ffffffff816be9c0 nfsv3 WRITE a:call_start q:none
31787 00a0      0 ffff880098e58600 ffff880098dd02d0    15000 ffffffff8172bf20 lockdv4 LOCK a:call_bind_status q:xprt_binding
32110 00a0      0 ffff880098e58600 ffff880098dd0000    15000 ffffffff8172bf20 lockdv4 LOCK a:call_bind_status q:xprt_binding
33341 00a0      0 ffff880098e58600 ffff880098dd0438    15000 ffffffff8172bf20 lockdv4 LOCK a:call_bind_status q:xprt_binding
38655 00a0      0 ffff880098e58600 ffff880098dd0168    15000 ffffffff8172bf20 lockdv4 LOCK a:call_bind_status q:xprt_binding
23735 00a1      0 ffff8800c08e6600 ffff880094ecc5a0    15000 ffffffff816c12c0 lockdv4 UNLOCK a:call_bind_status q:xprt_binding
31427 00a0      0 ffff8800c08e6600 ffff880094ecc168    15000 ffffffff8172bf20 lockdv4 LOCK a:call_bind_status q:xprt_binding
31739 00a0      0 ffff8800c08e6600 ffff880094ecc438    15000 ffffffff8172bf20 lockdv4 LOCK a:call_bind_status q:xprt_binding
16677 0081   -110 ffff88010ec5d600 ffff88012125c2d0        0 ffffffff816c12c0 lockdv4 UNLOCK a:call_bind_status q:none
23720 00a1      0 ffff88010ec5d600 ffff88012125c000    15000 ffffffff816c1330 lockdv4 CANCEL a:call_bind_status q:xprt_binding
23721 00a1      0 ffff88010ec5d600 ffff88012125c708    15000 ffffffff816c12c0 lockdv4 UNLOCK a:call_bind_status q:xprt_binding
23684 0081      0 ffff88011379da00 ffff8801130e49d8        0 ffffffff816c12c0 lockdv4 UNLOCK a:call_status q:none
20627 0081      0 ffff880122998c00 ffff88011ffa8000        0 ffffffff816c1330 lockdv4 CANCEL a:call_status q:none
16771 0001      0 ffff88012b9a2400   (null)        0 ffffffff816be870 nfsv3 READ a:call_start q:none

Seems to be "LOCK", "UNLOCK", and "CANCEL" calls stuck in there, hmm.
Meanwhile, 30 or so other nodes are working fine, while this server is
stuck for >30 minutes.  After a reboot, things work fine again for
another day or so.  How can I further debug this?

Full kern.log here: http://0x.ca/sim/ref/2.6.36-hwslots_stuck_nfs/

Thanks,

Simon-

