From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH] SGI 882960: Busy inodes after unmount, oops
Date: Wed, 04 Feb 2004 18:12:45 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40209B6D.56ED461E@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AoHET-0000MB-AQ
	for nfs@lists.sourceforge.net; Tue, 03 Feb 2004 23:13:57 -0800
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=rj.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AoHES-0004h5-9n
	for nfs@lists.sourceforge.net; Tue, 03 Feb 2004 23:13:56 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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

G'day,

This patch fixes a bug where the forced killing of pending asynchronous
unlink rpc_tasks during unmount leaks inode reference counts for the
parent of the silly-renamed file and all its ancestor directories,
resulting in the message 

VFS: Busy inodes after unmount. Self-destruct in 5 seconds.  Have a nice day...

and a few seconds later an oops with a stack trace ending in
prune_dcache -> nfs_dentry_iput -> iput.

This is probably also the bug discussed last September on the autofs
mailing list.  The patch posted by Olaf Hering then has no effect
at all, but it did put me on the right track (thanks Olaf).


The first part makes sure that dput() will unhash and kill dentries
and their parents if called while the unmount is underway.

The second part moves the dput() call from the tk_exit callback of
the async unlink rpc_task to the tk_release callback so that it
will be called if the rpc_task is killed by rpc_killall_tasks()
instead of completing normally.

===========================================================================
linux/linux/fs/nfs/dir.c
===========================================================================

--- /usr/tmp/TmpDir.27555-0/linux/linux/fs/nfs/dir.c_1.32	Wed Feb  4 17:57:23 2004
+++ linux/linux/fs/nfs/dir.c	Wed Feb  4 17:52:20 2004
@@ -551,6 +551,11 @@ static int nfs_dentry_delete(struct dent
 		/* Unhash it, so that ->d_iput() would be called */
 		return 1;
 	}
+	if (!(dentry->d_sb->s_flags & MS_ACTIVE)) {
+		/* Unhash it, so that ancestors of killed async unlink
+		 * files will be cleaned up during umount */
+		return 1;
+	}
 	return 0;
 
 }

===========================================================================
linux/linux/fs/nfs/unlink.c
===========================================================================

--- /usr/tmp/TmpDir.27555-0/linux/linux/fs/nfs/unlink.c_1.6	Wed Feb  4 17:57:23 2004
+++ linux/linux/fs/nfs/unlink.c	Wed Feb  4 17:56:57 2004
@@ -51,6 +51,7 @@ static void
 nfs_put_unlinkdata(struct nfs_unlinkdata *data)
 {
 	if (--data->count == 0) {
+		dput(data->dir);
 		nfs_detach_unlinkdata(data);
 		if (data->name.name != NULL)
 			kfree(data->name.name);
@@ -132,7 +133,6 @@ nfs_async_unlink_done(struct rpc_task *t
 	NFS_PROTO(dir_i)->unlink_done(dir, &task->tk_msg);
 	put_rpccred(data->cred);
 	data->cred = NULL;
-	dput(dir);
 }
 
 /**


Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
