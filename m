From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH] Fix Oopsable condition in sys_close() w/ POSIX locks
Date: Wed, 19 Nov 2003 14:15:33 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16315.49493.365534.444814@charged.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
    NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AMXnh-0006m7-00
	for <nfs@lists.sourceforge.net>; Wed, 19 Nov 2003 11:15:41 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AMXnh-0003XV-7U
	for nfs@lists.sourceforge.net; Wed, 19 Nov 2003 11:15:41 -0800
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
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


Hi Marcelo,

  If 2 processes that have been created using CLONE_FILES so that they
share the same POSIX locks both call sys_close() on descriptors that
point to the same inode (but have different struct file *), they can
end up racing in the function locks_remove_posix().

  This race may cause fl->fl_file to disappear while we are flushing
out pending writes in the nfs_lock() function, and so causes Oopses
when we get to nlmclnt_call() & co.

Cheers,
  Trond

--- linux-2.4.22-up/fs/locks.c.orig	2002-05-30 14:07:49.000000000 -0400
+++ linux-2.4.22-up/fs/locks.c	2003-11-15 01:12:16.000000000 -0500
@@ -1747,7 +1747,14 @@
 	before = &inode->i_flock;
 	while ((fl = *before) != NULL) {
 		if ((fl->fl_flags & FL_POSIX) && fl->fl_owner == owner) {
+			struct file *filp = fl->fl_file;
+			/* Note: locks_unlock_delete() can sleep, and
+			 * so we may race with the call to sys_close()
+			 * by the thread that actually owns this filp.
+			 */
+			get_file(filp);
 			locks_unlock_delete(before);
+			fput(filp);
 			before = &inode->i_flock;
 			continue;
 		}


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
