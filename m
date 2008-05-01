From: mike <mike503@gmail.com>
Subject: [NFS] Back to basics - still having NFS issues
Date: Wed, 30 Apr 2008 22:36:00 -0700
Message-ID: <bd9320b30804302236x6895234apf836e26756755336@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:49808 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752590AbYEAFgM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 May 2008 01:36:12 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JrRSj-0002v9-4I
	for linux-nfs@vger.kernel.org; Thu, 01 May 2008 15:36:09 +1000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've switched up my setup now, thinking this would "mature" it more.
Everything is gigabit ethernet.

Server:
FreeBSD 7.0, quad-core xeon 3220, 2GB RAM, 4x750 hardware RAID10
Adaptec 3405 (so ~ 1.5TB usable)

42 processes:  1 running, 41 sleeping
CPU states:  0.0% user,  0.0% nice,  0.5% system,  0.0% interrupt, 99.5% idle
Mem: 15M Active, 1581M Inact, 325M Wired, 48M Cache, 214M Buf, 9232K Free
Swap: 2048M Total, 20K Used, 2048M Free

/etc/rc.conf:
nfs_server_flags="-u -t -n 16"

/etc/exports:
/home -maproot=root -network 10.13.5.0 -mask 255.255.255.0


Clients (3 moderate usage, 2 minimal usage):
Linux 2.6.24-16-server, quad-core xeon 3220, 4GB RAM, single SATA2
250G disk (barely used)

/etc/fstab:
raid01:/home    /home           nfs
rsize=8192,rsize=8192,tcp,rw,acregmin=30


I stuck with the 8k since it seems like FreeBSD (from what I read)
recommended it. It seems damn near rock solid but one machine
consistently flakes out (and is identical in every way - hardware,
fstab, nfs-common parameters, etc) to two other nodes that don't show
any issues (and I think are stable, for the most part...)

I get those nasty:

[26792.279141] nfs: server raid01 not responding, still trying
[26792.279172] nfs: server raid01 not responding, still trying
[26792.279201] nfs: server raid01 not responding, still trying
[26792.279231] nfs: server raid01 not responding, still trying
[26792.279261] nfs: server raid01 not responding, still trying
[26792.279293] nfs: server raid01 not responding, still trying
[26792.908086] nfs: server raid01 not responding, still trying
[26798.780814] nfs: server raid01 not responding, still trying

[27151.795931] nfs: server raid01 OK
[27151.796477] nfs: server raid01 OK
[27151.797130] nfs: server raid01 OK
[27151.797287] nfs: server raid01 OK
[27151.797382] nfs: server raid01 OK
[27151.798190] nfs: server raid01 OK
[27151.798237] nfs: server raid01 OK
[27151.798282] nfs: server raid01 OK
[27151.798484] nfs: server raid01 OK

But it takes a while for it to recover, meanwhile the client is useless...

Any thoughts?

-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Don't miss this year's exciting event. There's still time to save $100. 
Use priority code J8TL2D2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

