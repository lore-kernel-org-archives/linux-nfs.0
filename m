From: Andrew Ryan <andrewr@nam-shub.com>
Subject: 2.4.19+RPC_ALL hangs running dbench 2.0
Date: Mon, 14 Oct 2002 16:29:55 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.BSF.4.32L2.0210141450280.12721-100000@lenny.sfrn.dnai.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from barney.sfrn.dnai.com ([208.59.199.24])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 181Efz-00056h-00
	for <nfs@lists.sourceforge.net>; Mon, 14 Oct 2002 16:31:07 -0700
Received: from sideshow-mel.sfrn.dnai.com (sideshow-mel.sfrn.dnai.com [208.59.199.19])
	by barney.sfrn.dnai.com (8.11.2/8.11.2) with ESMTP id g9ENOmu61874
	for <nfs@lists.sourceforge.net>; Mon, 14 Oct 2002 16:24:48 -0700 (PDT)
Received: from lenny (lenny.sfrn.dnai.com [208.59.199.9])
	by sideshow-mel.sfrn.dnai.com (8.11.3/8.11.3) with ESMTP id g9ENMI778898
	for <nfs@lists.sourceforge.net>; Mon, 14 Oct 2002 16:22:18 -0700 (PDT)
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

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
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
