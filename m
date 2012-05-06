Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail1.trendhosting.net ([195.8.117.5]:34870 "EHLO
	mail1.trendhosting.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753112Ab2EFDIH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 5 May 2012 23:08:07 -0400
Received: from localhost (localhost [127.0.0.1])
	by mail1.trendhosting.net (Postfix) with ESMTP id C71D815828
	for <linux-nfs@vger.kernel.org>; Sun,  6 May 2012 04:00:48 +0100 (BST)
Received: from mail1.trendhosting.net ([127.0.0.1])
	by localhost (thp003.trendhosting.net [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id nsRC9OlJD9AN for <linux-nfs@vger.kernel.org>;
	Sun,  6 May 2012 04:00:37 +0100 (BST)
Message-ID: <4FA5E950.5080304@pocock.com.au>
Date: Sun, 06 May 2012 03:00:32 +0000
From: Daniel Pocock <daniel@pocock.com.au>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: extremely slow nfs when sync enabled
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



I've been observing some very slow nfs write performance when the server
has `sync' in /etc/exports

I want to avoid using async, but I have tested it and on my gigabit
network, it gives almost the same speed as if I was on the server
itself. (e.g. 30MB/sec to one disk, or less than 1MB/sec to the same
disk over NFS with `sync')

I'm using Debian 6 with 2.6.38 kernels on client and server, NFSv3

I've also tried a client running Debian 7/Linux 3.2.0 with both NFSv3
and NFSv4, speed is still slow

Looking at iostat on the server, I notice that avgrq-sz = 8 sectors
(4096 bytes) throughout the write operations

I've tried various tests, e.g. dd a large file, or unpack a tarball with
many small files, the iostat output is always the same

Looking at /proc/mounts on the clients, everything looks good, large
wsize, tcp:

rw,relatime,vers=3,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=192.x.x.x,mountvers=3,mountport=58727,mountproto=udp,local_lock=none,addr=192.x.x.x
0 0

and
 rw,relatime,vers=4,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=192.x.x.x.,minorversion=0,local_lock=none,addr=192.x.x.x 0 0

and in /proc/fs/nfs/exports on the server, I have sync and wdelay:

/nfs4/daniel
192.168.1.0/24,192.x.x.x(rw,insecure,root_squash,sync,wdelay,no_subtree_check,uuid=aa2a6f37:9cc94eeb:bcbf983c:d6e041d9,sec=1)
/home/daniel
192.168.1.0/24,192.x.x.x(rw,root_squash,sync,wdelay,no_subtree_check,uuid=aa2a6f37:9cc94eeb:bcbf983c:d6e041d9)

Can anyone suggest anything else?  Or is this really the performance hit
of `sync'?


