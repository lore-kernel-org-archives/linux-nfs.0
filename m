From: Roger Leigh <roger.leigh@epictechnology.co.uk>
Subject: statd errors
Date: Tue, 14 Dec 2004 15:17:54 +0000
Message-ID: <20041214151754.GA5985@epictechnology.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CeEQ0-0002qX-Ew
	for nfs@lists.sourceforge.net; Tue, 14 Dec 2004 07:16:52 -0800
Received: from mail.metronet.co.uk ([213.162.97.75])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CeEPy-0000nm-At
	for nfs@lists.sourceforge.net; Tue, 14 Dec 2004 07:16:52 -0800
Received: from till1.lan (unknown [213.162.108.80])
	by smtp.metronet.co.uk (MetroNet Mail) with ESMTP id 17C0D466D14
	for <nfs@lists.sourceforge.net>; Tue, 14 Dec 2004 15:15:03 +0000 (GMT)
Received: from roger by till1.lan with local (Exim 4.34)
	id 1CeER0-0001a0-QQ
	for nfs@lists.sourceforge.net; Tue, 14 Dec 2004 15:17:54 +0000
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hello,

I'm running a simple NFS setup (one client, one server) using NFSv3 on
Debian sarge (nfs-utils 1.0.6, and Linux 2.4.27 and 2.6.8 Debian
kernels).  I'm seeing the same problem with both kernel versions (plus
vanilla kernel.org 2.6.[89]).

In my logs, I keep getting this message (on both the client and server):

Dec 14 11:59:54 till2 rpc.statd[2141]: Received erroneous SM_UNMON
request from till2 for 10.0.0.203

Looking through list archives with Google, it seems that this can be
caused by:

1. /var/lib/nfs/sm* not being writable (it's writable, owned by root, and
   rpc.statd runs as root)
2. Name/IP address changes.  This isn't happening either.

The file region locking works; using strace I can see that fcntl64 is
used to get and set locks, and attempts to lock the same records on both
systems give the appropriate errors in the application.  I get the
SM_UNMON error if I leave the client system alone for 5 minutes with no
activity; when I next try an operation, I get the above error in the
logs on both machines.  With continuous operation, I still get the error
periodically, but if I leave it alone for 5 minutes, it always occurs.

Please could anyone suggest how I might debug or fix this?


Many thanks,
Roger


Server Configuration (host till1, ip 10.0.0.203):
/etc/exports:
/srv/epic *(rw,sync,secure_locks,no_root_squash,no_wdelay,no_subtree_check)
[using knfsd]

Client configuration (host till2, ip 10.0.0.204):
I use autofs4, which gives this mount:
automount(pid2099) on /var/autofs/net type autofs
(rw,fd=4,pgrp=2099,minproto=2,maxproto=4)
till1:/srv/epic on /var/autofs/net/till1/srv/epic type nfs
(rw,nosuid,nodev,hard,intr,nfsvers=3,posix,udp,rsize=8192,wsize=8192,addr=10.0.0.203)

This is the log in the server (nlm_debug is 65535):

Dec 14 12:02:25 till1 kernel: lockd: request from 0a0000cc
Dec 14 12:02:25 till1 kernel: lockd: LOCK          called
Dec 14 12:02:25 till1 kernel: lockd: nlm_lookup_host(0a0000cc, p=17, v=4)
Dec 14 12:02:25 till1 kernel: lockd: host garbage collection
Dec 14 12:02:25 till1 kernel: lockd: nlmsvc_mark_resources
Dec 14 12:02:25 till1 kernel: lockd: delete host 10.0.0.204
Dec 14 12:02:25 till1 kernel: lockd: nsm_unmonitor(10.0.0.204)
Dec 14 12:02:25 till1 kernel: nsm: xdr_encode_mon(0a0000cc, -1249509120, 67108864, 268435456)
Dec 14 12:02:25 till1 rpc.statd[1421]: Received erroneous SM_UNMON request from till1 for 10.0.0.204
Dec 14 12:02:25 till1 kernel: lockd: creating host entry
Dec 14 12:02:25 till1 kernel: lockd: nsm_monitor(10.0.0.204)
Dec 14 12:02:25 till1 kernel: nsm: xdr_encode_mon(0a0000cc, -1249509120, 67108864, 268435456)
Dec 14 12:02:25 till1 kernel: nsm: xdr_decode_stat_res status 0 state 181
Dec 14 12:02:25 till1 kernel: lockd: nlm_file_lookup(01000001 0400fe00 00010001 00010804 13bb0bdb 00000000)
Dec 14 12:02:25 till1 kernel: lockd: creating file for (01000001 0400fe00 00010001 00010804 13bb0bdb
00000000)
Dec 14 12:02:25 till1 kernel: lockd: found file c51aa1d0 (count 0)
Dec 14 12:02:25 till1 kernel: lockd: nlmsvc_lock(fe04/67588, ty=1, pi=2493, 805306370-805306371, bl=0)
Dec 14 12:02:25 till1 kernel: lockd: nlmsvc_lookup_block f=c51aa1d0 pd=2493 805306370-805306371 ty=1
Dec 14 12:02:25 till1 kernel: lockd: posix_lock_file returned 0
Dec 14 12:02:25 till1 kernel: lockd: LOCK          status 0
Dec 14 12:02:25 till1 kernel: lockd: release host 10.0.0.204
Dec 14 12:02:25 till1 kernel: lockd: nlm_release_file(c51aa1d0, ct = 1)
Dec 14 12:02:25 till1 kernel: nlmsvc_retry_blocked(00000000, when=0)
Dec 14 12:02:25 till1 kernel: nlmsvc_retry_blocked(00000000, when=0)
Dec 14 12:02:25 till1 kernel: lockd: request from 0a0000cc


This is the log in the client (nlm_debug is 65535, the time is slightly
behind the server):

Dec 14 11:04:55 till2 kernel: lockd: nlm_lookup_host(0a0000cb, p=17, v=4)
Dec 14 11:04:55 till2 kernel: lockd: get host 10.0.0.203
Dec 14 11:04:55 till2 kernel: lockd: call procedure 4 on 10.0.0.203
Dec 14 11:04:55 till2 kernel: lockd: nlm_bind_host(0a0000cb)
Dec 14 11:04:55 till2 kernel: lockd: server returns status 0
Dec 14 11:04:55 till2 kernel: lockd: clnt proc returns 0
Dec 14 11:04:55 till2 kernel: lockd: release host 10.0.0.203
Dec 14 11:04:55 till2 kernel: lockd: release host 10.0.0.203
Dec 14 11:59:54 till2 kernel: lockd: nlm_lookup_host(0a0000cb, p=17, v=4)
Dec 14 11:59:54 till2 kernel: lockd: host garbage collection
Dec 14 11:59:54 till2 kernel: lockd: nlmsvc_mark_resources
Dec 14 11:59:54 till2 kernel: lockd: delete host 10.0.0.203
Dec 14 11:59:54 till2 kernel: lockd: nsm_unmonitor(10.0.0.203)
Dec 14 11:59:54 till2 rpc.statd[2141]: Received erroneous SM_UNMON request from till2 for 10.0.0.203
Dec 14 11:59:54 till2 kernel: lockd: creating host entry
Dec 14 11:59:54 till2 kernel: lockd: nlm_bind_host(0a0000cb)
Dec 14 11:59:54 till2 kernel: lockd: nsm_monitor(10.0.0.203)


-- 
Roger Leigh

                Printing on GNU/Linux?  http://gimp-print.sourceforge.net/
                GPG Public Key: 0x25BFB848.  Please sign and encrypt your mail.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
