Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:54201 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752383AbbC3VoE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2015 17:44:04 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id E4E8320AF2
	for <linux-nfs@vger.kernel.org>; Mon, 30 Mar 2015 17:44:00 -0400 (EDT)
Message-Id: <1427751843.1013981.247256753.2BA43388@webmail.messagingengine.com>
From: lyndat3@your-mail.com
To: linux-nfs@vger.kernel.org
MIME-Version: 1.0
Content-Type: text/plain
Subject: large data transfer rate slowdows over NFSv4 local lan with kernel 3.19x
 & 3.16x ?
Date: Mon, 30 Mar 2015 14:44:03 -0700
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I was just pinged on this by a client; I can reproduce it here.

I have two opensuse 13.2 machines.  NFS xfers -- cp & rsync -- between them slow to a crawl: < 1 MB/sec in the worst case, over a 1Gb local lan.

Chats @ #networking/#nfs suggest this is a kernel+NFS issue.  So checking here 1st.

Both machines run kernel

	uname -rm
		3.19.3-1.gf10e7fc-default x86_64

Both have NFS installed.  Packages include

	nfs-client-1.3.0-4.2.1.x86_64
	nfs-kernel-server-1.3.0-4.2.1.x86_64

The server's store is at

	/NAS/NAS1

it's on a LV on a software (mdadm v3.3.1) RAID-10 array.

The client's mounted it at

	/mnt/NFS4/NAS1

	mount | egrep "NFS|NAS1"
		/etc/auto.nfs4 on /mnt/NFS4 type autofs (rw,relatime,fd=6,pgrp=2619,timeout=10,minproto=5,maxproto=5,indirect)
		xen01.loc:/ on /mnt/NFS4/NAS1 type nfs4 (rw,nosuid,nodev,relatime,sync,vers=4.0,rsize=1048576,wsize=1048576,namlen=255,soft,nosharecache,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=10.0.0.101,fsc,local_lock=none,addr=10.0.0.1)

The diagnostics I can think to do follow.

creating test files @ both machines

@ server
dd if=/dev/zero of=/NAS/NAS1/dump-server-file bs=1024 count=1000000
	1000000+0 records in
	1000000+0 records out
	1024000000 bytes (1.0 GB) copied, 1.37631 s, 744 MB/s

@ client
dd if=/dev/zero of=~/dump-client-file bs=1024 count=1000000
	1000000+0 records in
	1000000+0 records out
	1024000000 bytes (1.0 GB) copied, 1.988 s, 515 MB/s


TESTS

(1) server -> server, local cp
	rm -f /tmp/dump-server-file
	time /bin/cp /NAS/NAS1/dump-server-file /tmp/
		real    0m0.486s
		user    0m0.004s
		sys     0m0.480s
~= 2100MB/s (real)
~= 2100MB/s (sys)

(2) server -> server, local rsync
	rm -f /tmp/dump-server-file
	time /usr/bin/rsync /NAS/NAS1/dump-server-file /tmp/
		real    0m2.491s
		user    0m3.344s
		sys     0m1.264s
~= 411 MB/s (real)
~= 810 MB/s (sys)

(3) client -> server, PING

	ping -c 10 10.0.0.1
		PING 10.0.0.1 (10.0.0.1) 56(84) bytes of data.
		64 bytes from 10.0.0.1: icmp_seq=1 ttl=64 time=0.307 ms
		64 bytes from 10.0.0.1: icmp_seq=2 ttl=64 time=0.280 ms
		64 bytes from 10.0.0.1: icmp_seq=3 ttl=64 time=0.303 ms
		64 bytes from 10.0.0.1: icmp_seq=4 ttl=64 time=0.280 ms
		64 bytes from 10.0.0.1: icmp_seq=5 ttl=64 time=0.262 ms
		64 bytes from 10.0.0.1: icmp_seq=6 ttl=64 time=0.290 ms
		64 bytes from 10.0.0.1: icmp_seq=7 ttl=64 time=0.281 ms
		64 bytes from 10.0.0.1: icmp_seq=8 ttl=64 time=0.286 ms
		64 bytes from 10.0.0.1: icmp_seq=9 ttl=64 time=0.287 ms
		64 bytes from 10.0.0.1: icmp_seq=10 ttl=64 time=0.291 ms

		--- 10.0.0.1 ping statistics ---
		10 packets transmitted, 10 received, 0% packet loss, time 8999ms
		rtt min/avg/max/mdev = 0.262/0.286/0.307/0.023 ms

(4) client -> `iperf3 -s`@server: TCP, one thread

	iperf3 -c 10.0.0.1 -t 60 -i 15 -F ~/dump-client-file -f M
		[ ID] Interval           Transfer     Bandwidth       Retr
		[  5]   0.00-3.08   sec   337 MBytes   918 Mbits/sec   10             sender
		[  5]   0.00-3.08   sec   336 MBytes   915 Mbits/sec                  receiver

(5) client -> `iperf3 -s`@server: TCP, 100 threads

	iperf3 -c 10.0.0.1 -t 60 -i 15 -F ~/dump-client-file -f M -P100
		[ ID] Interval           Transfer     Bandwidth       Retr
		...
		[SUM]   0.00-31.08  sec  3.40 GBytes   940 Mbits/sec  121             sender
		[SUM]   0.00-31.08  sec  3.39 GBytes   937 Mbits/sec                  receiver

(6) client -> `iperf3 -s`@server: UDP, one thread

	iperf3 -c 10.0.0.1 -t 60 -i 15 -F ~/dump-client-file -f M -b 1G -P 1
		[ ID] Interval           Transfer     Bandwidth       Retr
		...
		[  5]   0.00-8.97   sec   977 MBytes   913 Mbits/sec   25             sender
		[  5]   0.00-8.97   sec   976 MBytes   912 Mbits/sec                  receiver

(7) client -> `iperf3 -s`@server: UDP, 100 threads

	iperf3 -c 10.0.0.1 -t 60 -i 15 -F ~/dump-client-file -f M -b 1G -P 100
		[ ID] Interval           Transfer     Bandwidth       Retr
		...
		[SUM]   0.00-60.01  sec  6.56 GBytes   939 Mbits/sec  180             sender
		[SUM]   0.00-60.01  sec  6.55 GBytes   937 Mbits/sec                  receiver

(8) client -> server, cp over NFS

	rm -f /mnt/NFS4/NAS1/dump-client-file
	time /bin/cp ~/dump-client-file /mnt/NFS4/NAS1/
		real    0m54.589s
		user    0m0.005s
		sys     0m1.225s
~= 18.75 MB/s (real)
~= 810 MB/s (sys)

(9) client -> server, rsync over NFS

	rm -f /mnt/NFS4/NAS1/dump-client-file
	time /usr/bin/rsync ~/dump-client-file /mnt/NFS4/NAS1/
		real    18m13.408s
		user    0m4.642s
		sys     0m2.627s
~= 0.937 MB/s (real)
~= 390 MB/s (sys)


EDIT:

ruling out rsync alone


(10) rsync, no NFS

	time /usr/bin/rsync ~/dump-client-file root@xen01.loc:/NAS/NAS1
		real    0m19.179s
		user    0m16.505s
		sys     0m4.135s

(11) rsync, over NFS

	time /usr/bin/rsync ~/dump-client-file /mnt/NFS4/NAS1/
		real    18m25.726s
		user    0m4.647s
		sys     0m2.912s


and

Testing for a kernel dependency, downgrading kernel-default to

	uname -rm
		3.16.7-7-default x86_64

and retesting the slow cases, there's still no significant change

(12) client -> server, cp over NFS

	rm -f /mnt/NFS4/NAS1/dump-client-file
	time /bin/cp ~/dump-client-file /mnt/NFS4/NAS1/
		real    0m56.064s
		user    0m0.003s
		sys     0m1.266s
~= 18.26 MB/s (real)
~= 809 MB/s (sys)

(13) client -> server, rsync over NFS

	rm -f /mnt/NFS4/NAS1/dump-client-file
	time /usr/bin/rsync ~/dump-client-file /mnt/NFS4/NAS1/
		real    17m59.312s
		user    0m4.116s
		sys     0m2.226s
~= 0.949 MB/s (real)
~= 460 MB/s (sys)


If there's additional diagnostic info, I can provide it.


LT

