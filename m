From: Jeremy Kusnetz <JKusnetz@nrtc.org>
Subject: Problem with NFSv3 in syncronous mode
Date: Mon, 21 Oct 2002 11:49:45 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <9366A6ACB518D511B54B0008C78609E0024403D7@exchange.nrtc.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from outmail.nrtc.org ([204.145.144.17] helo=exchange.nrtc.org)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 183eoO-0005vr-00
	for <nfs@lists.sourceforge.net>; Mon, 21 Oct 2002 08:49:48 -0700
To: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
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

Hello,

We have been running NFSv3 on kernel 2.4.17 both client and server, with
whatever Trond's current patches were at the time of the 2.4.17 kernel.  The
clients are connected to the server with a 100mb ethernet switch.  Both
clients and server are using the e100 drivers.

/etc/exports looks like: /export    10.75.0.1/255.255.0.0(rw,no_root_squash)

/var/lib/nfs/etab: /exports
10.75.0.1/255.255.0.0(rw,async,wdelay,hide,secure,no_root_squash,no_all_squa
sh,subtree_check,secure_locks,mapping=identity,anonuid=-2,anongid=-2)

So you can see we are running in asyncronous mode.

I tried turning on syncronous mode on the server and ran exportfs -ra.  At
first things seemed to be going okay, but in a short amount of time, load
and process levels on the clients started to skyrocket.  Doing anything on
the NFS partition was extremely slow, and dmesg on the clients were showing
lots of:

nfs: server 10.75.0.2 is not responding
nfs: server 10.75.0.2 OK

I quickly removed sync from the servers's export file and re exportfs -ra.
This didn't seem to clear the problem, I had to reboot all of the client
nodes to clear up the issue.

So right now I'm back to happily running in async mode.

I'm trying to find what is causing my problem.  Could it be lots of IO on
the NFS server, could it be a bug with some of the kernel patches in 2.4.17,
could it be the version of NFS utils?  Could it be some sort of file locking
issue?

I'm planning on upgrading to 2.4.19 + nfs-utils-1.0.1  Could this simply fix
my problems?  What else can I look at to help me solve this problem?



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
