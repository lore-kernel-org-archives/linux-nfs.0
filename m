From: Joel Votaw <jovotaw@cs.nmsu.edu>
Subject: Stale file handle, kernel 2.4.7, RedHat 7.2
Date: Thu, 19 Sep 2002 09:31:03 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0209190916140.2466-100000@quito>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.cs.nmsu.edu ([128.123.64.3])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17s3Gj-0003Tb-00
	for <nfs@lists.sourceforge.net>; Thu, 19 Sep 2002 08:31:05 -0700
Received: from quito (IDENT:1628@quito [128.123.64.162])
	by mail.cs.nmsu.edu (8.11.6/8.11.5) with ESMTP id g8JFV3s17513
	for <nfs@lists.sourceforge.net.>; Thu, 19 Sep 2002 09:31:03 -0600 (MDT)
To: nfs@lists.sourceforge.net
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


Hello NFS hackers,

I'm running into a problem with NFS stale file handles... I seem to get
them even after just stopping and restarting NFS services on our file
server.

The server is running RedHat 7.2 and kernel 2.4.7-10 (no SMP support).
Clients include some RedHat 7.1 through 7.3 machines, and Solaris 2.6
through 8 machines.

My first suspect is the fairly ancient kernel.  Are there known issues
with kernels from that era?  I'd like to upgrade kernels but am kind of
stuck -- this is a Dell server, we like being able to monitor the
hardware, and last I heard they didn't support OpenManage on newer
kernels.

If there aren't problems with these kernels and there is a possible
work-around ... am I doing something wrong?  My /etc/exports contains only

	/export *(rw,sync,wdelay,no_subtree_check)

I'm not exporting anything else (especially subdirectories), but clients
may mount subdirectories (for example /export/home as /home).  I set
no_subtree_check in the hopes that it would eliminate any state from the
file handles.

Thanks in advance for any info,

	-Joel



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
