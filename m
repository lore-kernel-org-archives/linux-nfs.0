From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 3/5] locks: rename lease functions to reflect locks.c
	conventions
Date: Fri,  8 Jun 2007 18:14:53 -0400
Message-ID: <18949.3728139952$1181340939@news.gmane.org>
References: <20070607170557.GA14463@fieldses.org>
	<11813408953536-git-send-email-> <11813408952518-git-send-email->
	<11813408951909-git-send-email->
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>,
	Marc Eshel <eshel@almaden.ibm.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Robert Rappaport <robert.rappaport@gmail.com>,
	David Teigland <teigland@redhat.com>, nfs@lists.sourceforge.net
To: linux-fsdevel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HwmjS-0007pu-2k
	for nfs@lists.sourceforge.net; Fri, 08 Jun 2007 15:14:59 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HwmjU-0002pT-CW
	for nfs@lists.sourceforge.net; Fri, 08 Jun 2007 15:15:01 -0700
In-Reply-To: <11813408951909-git-send-email->
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

From: J. Bruce Fields <bfields@citi.umich.edu>

We've been using the convention that vfs_foo is the function that calls
a filesystem-specific foo method if it exists, or falls back on a
generic method if it doesn't.

So rename setlease to vfs_setlease, and __setlease to setlease.  Keep
setlease exported to allow filesystems to use the generic method in
addition to doing their own bookkeeping.

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
---
 fs/locks.c          |   16 ++++++++--------
 fs/nfsd/nfs4state.c |   10 +++++-----
 include/linux/fs.h  |    2 +-
 3 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 8fa4420..82ac90b 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1329,7 +1329,7 @@ int fcntl_getlease(struct file *filp)
 }
 
 /**
- *	__setlease	-	sets a lease on an open file
+ *	setlease	-	sets a lease on an open file
  *	@filp: file pointer
  *	@arg: type of lease to obtain
  *	@flp: input - file_lock to use, output - file_lock inserted
@@ -1339,7 +1339,7 @@ int fcntl_getlease(struct file *filp)
  *
  *	Called with kernel lock held.
  */
-static int __setlease(struct file *filp, long arg, struct file_lock **flp)
+static int setlease(struct file *filp, long arg, struct file_lock **flp)
 {
 	struct file_lock *fl, **before, **my_before = NULL, *lease;
 	struct dentry *dentry = filp->f_path.dentry;
@@ -1427,8 +1427,10 @@ out:
 	return error;
 }
 
+EXPORT_SYMBOL(setlease);
+
  /**
- *	setlease        -       sets a lease on an open file
+ *	vfs_setlease        -       sets a lease on an open file
  *	@filp: file pointer
  *	@arg: type of lease to obtain
  *	@lease: file_lock to use
@@ -1437,7 +1439,7 @@ out:
  *	The fl_lmops fl_break function is required by break_lease
  */
 
-int setlease(struct file *filp, long arg, struct file_lock **lease)
+int vfs_setlease(struct file *filp, long arg, struct file_lock **lease)
 {
 	int error;
 
@@ -1445,14 +1447,12 @@ int setlease(struct file *filp, long arg, struct file_lock **lease)
 	if (filp->f_op && filp->f_op->setlease)
 		error = filp->f_op->setlease(filp, arg, lease);
         else
-		error = __setlease(filp, arg, lease);
+		error = setlease(filp, arg, lease);
 	unlock_kernel();
 
 	return error;
 }
 
-EXPORT_SYMBOL(setlease);
-
 /**
  *	fcntl_setlease	-	sets a lease on an open file
  *	@fd: open file descriptor
@@ -1477,7 +1477,7 @@ int fcntl_setlease(unsigned int fd, struct file *filp, long arg)
 
 	lock_kernel();
 
-	error = setlease(filp, arg, &flp);
+	error = vfs_setlease(filp, arg, &flp);
 	if (error || arg == F_UNLCK)
 		goto out_unlock;
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3cc8ce4..ed01a77 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -251,7 +251,7 @@ nfs4_close_delegation(struct nfs4_delegation *dp)
 	/* The following nfsd_close may not actually close the file,
 	 * but we want to remove the lease in any case. */
 	if (dp->dl_flock)
-		setlease(filp, F_UNLCK, &dp->dl_flock);
+		vfs_setlease(filp, F_UNLCK, &dp->dl_flock);
 	nfsd_close(filp);
 }
 
@@ -1396,7 +1396,7 @@ void nfsd_release_deleg_cb(struct file_lock *fl)
 /*
  * Set the delegation file_lock back pointer.
  *
- * Called from __setlease() with lock_kernel() held.
+ * Called from setlease() with lock_kernel() held.
  */
 static
 void nfsd_copy_lock_deleg_cb(struct file_lock *new, struct file_lock *fl)
@@ -1410,7 +1410,7 @@ void nfsd_copy_lock_deleg_cb(struct file_lock *new, struct file_lock *fl)
 }
 
 /*
- * Called from __setlease() with lock_kernel() held
+ * Called from setlease() with lock_kernel() held
  */
 static
 int nfsd_same_client_deleg_cb(struct file_lock *onlist, struct file_lock *try)
@@ -1710,10 +1710,10 @@ nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open, struct nfs4_sta
 	fl.fl_file = stp->st_vfs_file;
 	fl.fl_pid = current->tgid;
 
-	/* setlease checks to see if delegation should be handed out.
+	/* vfs_setlease checks to see if delegation should be handed out.
 	 * the lock_manager callbacks fl_mylease and fl_change are used
 	 */
-	if ((status = setlease(stp->st_vfs_file,
+	if ((status = vfs_setlease(stp->st_vfs_file,
 		flag == NFS4_OPEN_DELEGATE_READ? F_RDLCK: F_WRLCK, &flp))) {
 		dprintk("NFSD: setlease failed [%d], no delegation\n", status);
 		unhash_delegation(dp);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 6b07c61..cc62bfb 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -865,7 +865,7 @@ extern int vfs_cancel_lock(struct file *filp, struct file_lock *fl);
 extern int flock_lock_file_wait(struct file *filp, struct file_lock *fl);
 extern int __break_lease(struct inode *inode, unsigned int flags);
 extern void lease_get_mtime(struct inode *, struct timespec *time);
-extern int setlease(struct file *, long, struct file_lock **);
+extern int vfs_setlease(struct file *, long, struct file_lock **);
 extern int lease_modify(struct file_lock **, int);
 extern int lock_may_read(struct inode *, loff_t start, unsigned long count);
 extern int lock_may_write(struct inode *, loff_t start, unsigned long count);
-- 
1.5.2


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
