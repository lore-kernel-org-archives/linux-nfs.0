Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:51677 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755428Ab0JaMfO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 31 Oct 2010 08:35:14 -0400
Date: Sun, 31 Oct 2010 08:35:10 -0400
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Bryan Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH 1/2] locks: let the caller free file_lock on ->setlease
 failure
Message-ID: <20101031123510.GA4520@infradead.org>
References: <20101026164549.GD19445@fieldses.org>
 <20101027083924.GA28129@infradead.org>
 <20101027133924.GB6328@fieldses.org>
 <201010271546.09036.arnd@arndb.de>
 <20101027145538.GC6328@fieldses.org>
 <20101027145929.GA5788@infradead.org>
 <20101030212500.GE480@fieldses.org>
 <20101031123419.GA4491@infradead.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101031123419.GA4491@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The caller allocated it, the caller should free it.  The only issue so
far is that we could change the flp pointer even on an error return if
the fl_change callback failed.  But we can simply move the flp assignment
after the fl_change invocation, as the callers don't care about the
flp return value if the setlease call failed.

Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/fs/cifs/cifsfs.c
===================================================================
--- linux-2.6.orig/fs/cifs/cifsfs.c	2010-10-31 07:10:07.636004223 -0400
+++ linux-2.6/fs/cifs/cifsfs.c	2010-10-31 07:10:10.922004154 -0400
@@ -625,11 +625,8 @@ static int cifs_setlease(struct file *fi
 		   knows that the file won't be changed on the server
 		   by anyone else */
 		return generic_setlease(file, arg, lease);
-	else {
-		if (arg != F_UNLCK)
-			locks_free_lock(*lease);
+	else
 		return -EAGAIN;
-	}
 }
 
 struct file_system_type cifs_fs_type = {
Index: linux-2.6/fs/gfs2/file.c
===================================================================
--- linux-2.6.orig/fs/gfs2/file.c	2010-10-31 07:10:07.643004363 -0400
+++ linux-2.6/fs/gfs2/file.c	2010-10-31 07:10:10.923003665 -0400
@@ -629,8 +629,6 @@ static ssize_t gfs2_file_aio_write(struc
 
 static int gfs2_setlease(struct file *file, long arg, struct file_lock **fl)
 {
-	if (arg != F_UNLCK)
-		locks_free_lock(*fl);
 	return -EINVAL;
 }
 
Index: linux-2.6/fs/locks.c
===================================================================
--- linux-2.6.orig/fs/locks.c	2010-10-31 07:10:07.649004084 -0400
+++ linux-2.6/fs/locks.c	2010-10-31 07:34:10.102255587 -0400
@@ -1428,8 +1425,9 @@ int generic_setlease(struct file *filp,
 		goto out;
 
 	if (my_before != NULL) {
-		*flp = *my_before;
 		error = lease->fl_lmops->fl_change(my_before, arg);
+		if (!error)
+			*flp = *my_before;
 		goto out;
 	}
 
@@ -1444,8 +1442,6 @@ int generic_setlease(struct file *filp,
 	return 0;
 
 out:
-	if (arg != F_UNLCK)
-		locks_free_lock(lease);
 	return error;
 }
 EXPORT_SYMBOL(generic_setlease);
@@ -1524,8 +1520,11 @@ static int do_fcntl_add_lease(unsigned i
 	}
 	lock_flocks();
 	error = __vfs_setlease(filp, arg, &fl);
-	if (error)
-		goto out_unlock;
+	if (error) {
+		unlock_flocks();
+		locks_free_lock(fl);
+		goto out_free_fasync;
+	}
 
 	/*
 	 * fasync_insert_entry() returns the old entry if any.
@@ -1541,12 +1540,12 @@ static int do_fcntl_add_lease(unsigned i
 		fl->fl_type = F_UNLCK | F_INPROGRESS;
 		fl->fl_break_time = jiffies - 10;
 		time_out_leases(inode);
-		goto out_unlock;
+	} else {
+		error = __f_setown(filp, task_pid(current), PIDTYPE_PID, 0);
 	}
-
-	error = __f_setown(filp, task_pid(current), PIDTYPE_PID, 0);
-out_unlock:
 	unlock_flocks();
+
+out_free_fasync:
 	if (new)
 		fasync_free(new);
 	return error;
Index: linux-2.6/fs/nfs/file.c
===================================================================
--- linux-2.6.orig/fs/nfs/file.c	2010-10-31 07:10:07.658003804 -0400
+++ linux-2.6/fs/nfs/file.c	2010-10-31 07:10:10.936003734 -0400
@@ -884,7 +884,5 @@ static int nfs_setlease(struct file *fil
 	dprintk("NFS: setlease(%s/%s, arg=%ld)\n",
 			file->f_path.dentry->d_parent->d_name.name,
 			file->f_path.dentry->d_name.name, arg);
-	if (arg != F_UNLCK)
-		locks_free_lock(*fl);
 	return -EINVAL;
 }
Index: linux-2.6/fs/nfsd/nfs4state.c
===================================================================
--- linux-2.6.orig/fs/nfsd/nfs4state.c	2010-10-31 07:10:07.666004084 -0400
+++ linux-2.6/fs/nfsd/nfs4state.c	2010-10-31 07:32:56.906254608 -0400
@@ -2652,6 +2652,7 @@ nfs4_open_delegation(struct svc_fh *fh,
 	if ((status = vfs_setlease(fl->fl_file, fl->fl_type, &fl))) {
 		dprintk("NFSD: setlease failed [%d], no delegation\n", status);
 		dp->dl_flock = NULL;
+		locks_free_lock(fl);
 		unhash_delegation(dp);
 		flag = NFS4_OPEN_DELEGATE_NONE;
 		goto out;
