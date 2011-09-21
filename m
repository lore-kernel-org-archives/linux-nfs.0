Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59091 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751616Ab1IUO61 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Sep 2011 10:58:27 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-fsdevel@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        Christoph Hellwig <hch@infradead.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Mimi Zohar <zohar@linux.vnet.ibm.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/6] leases: split up generic_setlease into lock/unlock cases
Date: Wed, 21 Sep 2011 10:58:12 -0400
Message-Id: <1316617097-21384-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1316617097-21384-1-git-send-email-bfields@redhat.com>
References: <1316617097-21384-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Eventually we should probably do the same thing to the file operations
as well.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/locks.c |   98 ++++++++++++++++++++++++++++++++++++++----------------------
 1 files changed, 62 insertions(+), 36 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 9b8408e..b342902 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1352,18 +1352,7 @@ int fcntl_getlease(struct file *filp)
 	return type;
 }
 
-/**
- *	generic_setlease	-	sets a lease on an open file
- *	@filp: file pointer
- *	@arg: type of lease to obtain
- *	@flp: input - file_lock to use, output - file_lock inserted
- *
- *	The (input) flp->fl_lmops->lm_break function is required
- *	by break_lease().
- *
- *	Called with file_lock_lock held.
- */
-int generic_setlease(struct file *filp, long arg, struct file_lock **flp)
+int generic_add_lease(struct file *filp, long arg, struct file_lock **flp)
 {
 	struct file_lock *fl, **before, **my_before = NULL, *lease;
 	struct dentry *dentry = filp->f_path.dentry;
@@ -1372,30 +1361,14 @@ int generic_setlease(struct file *filp, long arg, struct file_lock **flp)
 
 	lease = *flp;
 
-	error = -EACCES;
-	if ((current_fsuid() != inode->i_uid) && !capable(CAP_LEASE))
-		goto out;
-	error = -EINVAL;
-	if (!S_ISREG(inode->i_mode))
+	error = -EAGAIN;
+	if ((arg == F_RDLCK) && (atomic_read(&inode->i_writecount) > 0))
 		goto out;
-	error = security_file_lock(filp, arg);
-	if (error)
+	if ((arg == F_WRLCK)
+	    && ((dentry->d_count > 1)
+		|| (atomic_read(&inode->i_count) > 1)))
 		goto out;
 
-	time_out_leases(inode);
-
-	BUG_ON(!(*flp)->fl_lmops->lm_break);
-
-	if (arg != F_UNLCK) {
-		error = -EAGAIN;
-		if ((arg == F_RDLCK) && (atomic_read(&inode->i_writecount) > 0))
-			goto out;
-		if ((arg == F_WRLCK)
-		    && ((dentry->d_count > 1)
-			|| (atomic_read(&inode->i_count) > 1)))
-			goto out;
-	}
-
 	/*
 	 * At this point, we know that if there is an exclusive
 	 * lease on this file, then we hold it on this filp
@@ -1433,9 +1406,6 @@ int generic_setlease(struct file *filp, long arg, struct file_lock **flp)
 		goto out;
 	}
 
-	if (arg == F_UNLCK)
-		goto out;
-
 	error = -EINVAL;
 	if (!leases_enable)
 		goto out;
@@ -1446,6 +1416,62 @@ int generic_setlease(struct file *filp, long arg, struct file_lock **flp)
 out:
 	return error;
 }
+
+int generic_delete_lease(struct file *filp, struct file_lock **flp)
+{
+	struct file_lock *fl, **before;
+	struct dentry *dentry = filp->f_path.dentry;
+	struct inode *inode = dentry->d_inode;
+
+	for (before = &inode->i_flock;
+			((fl = *before) != NULL) && IS_LEASE(fl);
+			before = &fl->fl_next) {
+		if (fl->fl_file != filp)
+			continue;
+		return (*flp)->fl_lmops->lm_change(before, F_UNLCK);
+	}
+	return -EAGAIN;
+}
+
+/**
+ *	generic_setlease	-	sets a lease on an open file
+ *	@filp: file pointer
+ *	@arg: type of lease to obtain
+ *	@flp: input - file_lock to use, output - file_lock inserted
+ *
+ *	The (input) flp->fl_lmops->lm_break function is required
+ *	by break_lease().
+ *
+ *	Called with file_lock_lock held.
+ */
+int generic_setlease(struct file *filp, long arg, struct file_lock **flp)
+{
+	struct dentry *dentry = filp->f_path.dentry;
+	struct inode *inode = dentry->d_inode;
+	int error;
+
+	if ((current_fsuid() != inode->i_uid) && !capable(CAP_LEASE))
+		return -EACCES;
+	if (!S_ISREG(inode->i_mode))
+		return -EINVAL;
+	error = security_file_lock(filp, arg);
+	if (error)
+		return error;
+
+	time_out_leases(inode);
+
+	BUG_ON(!(*flp)->fl_lmops->lm_break);
+
+	switch (arg) {
+	case F_UNLCK:
+		return generic_delete_lease(filp, flp);
+	case F_RDLCK:
+	case F_WRLCK:
+		return generic_add_lease(filp, arg, flp);
+	default:
+		BUG();
+	}
+}
 EXPORT_SYMBOL(generic_setlease);
 
 static int __vfs_setlease(struct file *filp, long arg, struct file_lock **lease)
-- 
1.7.4.1

