From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Killed process on NFS client can result in lost lock on server
Date: 30 Sep 2003 16:52:11 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shspthi0zk4.fsf@charged.uio.no>
References: <87r81y11og.fsf@ceramic.fifi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A4RTn-0006eT-00
	for <nfs@lists.sourceforge.net>; Tue, 30 Sep 2003 13:52:19 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A4RTm-000085-Id
	for nfs@lists.sourceforge.net; Tue, 30 Sep 2003 13:52:18 -0700
Received: from mail-mx3.uio.no ([129.240.10.44])
	by pat.uio.no with esmtp (Exim 4.20)
	id 1A4RTi-000156-K7
	for nfs@lists.sourceforge.net; Tue, 30 Sep 2003 22:52:14 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <87r81y11og.fsf@ceramic.fifi.org>
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

>>>>> " " == Philippe Troin <phil@fifi.org> writes:

     > While trying to make this test program, I've noticed that the
     > problem only occurs while I/O is done on the locked file. Note
     > the write() in a while loop in the test program. I could not
     > get the bad behavior to show up if no I/O is going on.

Yep. It's the same problem as in nlmclnt_proc(): we have to clean up
all locks come rain or shine when the process exits.

Cheers,
  Trond

--- linux-2.4.23-pre5/fs/nfs/file.c.orig	2003-07-09 14:10:21.000000000 -0400
+++ linux-2.4.23-pre5/fs/nfs/file.c	2003-09-30 16:48:52.000000000 -0400
@@ -293,7 +293,8 @@
 	status2 = filemap_fdatawait(inode->i_mapping);
 	if (status2 && !status)
 		status = status2;
-	if (status < 0)
+	/* Note: Ignore status if we're cleaning up locks on process exit */
+	if (status < 0 && !(current->flags & PF_EXITING))
 		return status;
 
 	lock_kernel();




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
