From: Andrew Ryan <andrewr@nam-shub.com>
Subject: 2.4.20-rc1 NFS/TCP client (still) hangs running dbench 2.0
Date: Wed, 30 Oct 2002 21:06:27 -0800 (PST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.BSF.4.32L2.0210302057010.12230-100000@lenny.sfrn.dnai.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from moe.sfrn.dnai.com ([208.59.199.25])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1877Yv-0003qG-00
	for <nfs@lists.sourceforge.net>; Wed, 30 Oct 2002 21:08:09 -0800
Received: from sideshow-bob.sfrn.dnai.com (sideshow-bob.sfrn.dnai.com [208.59.199.20])
	by moe.sfrn.dnai.com (8.11.2/8.11.2) with ESMTP id g9V51WZ46658
	for <nfs@lists.sourceforge.net>; Wed, 30 Oct 2002 21:01:32 -0800 (PST)
Received: from lenny (lenny.sfrn.dnai.com [208.59.199.9])
	by sideshow-bob.sfrn.dnai.com (8.11.3/8.11.3) with ESMTP id g9V55pR61289
	for <nfs@lists.sourceforge.net>; Wed, 30 Oct 2002 21:05:51 -0800 (PST)
	(envelope-from andrewr@nam-shub.com)
To: <nfs@lists.sourceforge.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

2.4.20rc1 still exhibits the same identical problem as 2.4.19+kmap1 patch
which I identified a few weeks ago. I guess that patch was applied to
2.4.20, since it doesn't appear on Trond's patch page for 2.4.20.

I am still available to help duplicate or test fixes to this problem, if
anyone has any ideas. I can still use UDP but I'd really like to start
getting the speed of TCP.


thanks,
andrew

---------- Forwarded message ----------
Date: Mon, 14 Oct 2002 16:29:55 -0700 (PDT)
From: Andrew Ryan <andrewr@nam-shub.com>
To: nfs@lists.sourceforge.net
Subject: 2.4.19+RPC_ALL hangs running dbench 2.0

I've been running tests on the 2.4.19_NFS_ALL (the one from Oct 5) kernel
and seeing an easily reproducible hang on my machine (2x1.4 GHz PIII,
Compaq DL380G2, 4GB RAM), mounting a Netapp (F820 running 6.2R2) with the
mount options:
rw,tcp,nfsvers=3,rsize=32768,wsize=32768,intr,hard

The symptom is, I start a dbench run, and it starts up and runs for a
bit...
$ ~/dbench-2.0/dbench 16
clients started
  16     23801  21.45 MB/sec

Then it gets hung up, and the dbench process is still running, and
the MB/sec number keeps dropping rapidly, approaching 0.

At this point:
* Any commands in other shells that are currently running (e.g. 'top') are
hung.
* My other shells are not hung, but if I try to execute any commands, the
commands hang forever.
* I can kill the dbench process with Ctrl-C, but that just gives me a
shell that cannot execute any commands (they all hang, like the other
shells).
* The nmi_watchdog is never triggered, even though the system is
completely unresponsive from a user level.

When I ctl-C the hung dbench process, sometimes the kernel generates
an oops, but other times not. If I have kdb on, I can get a backtrace, but
I was hoping there was an easier way to figure out what is causing this
bug. The one oops I get says something about 'kernel BUG at
highmem.c:159!'

Note I do *NOT* get this error if I run without the NFS_ALL. I also tested
this with just the RPC_ALL and I get the same error. So it definitely has
to be something in the RPC_ALL patchset. I'm confused though, bec. this is
the patchset which claims to have specific fixes for HIGHMEM.

All I really want is a fast, stable client for my 4GB, 2 CPU boxes. I'd
use the stock 2.4.19 but the RPC_ALL patchset leads me to believe that
there are HIGHMEM bugs in the stock 2.4.19 NFS client.

I'm willing to do some testing to chase this down, if it helps.


andrew




-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0004en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
