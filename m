Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:38853 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933641Ab1ERTTv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 May 2011 15:19:51 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [RFC PATCH 1/2] locks: introduce i_blockleases to close lease races
Date: Wed, 18 May 2011 15:19:47 -0400
Message-Id: <1305746388-18241-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1305746388-18241-1-git-send-email-bfields@redhat.com>
References: <1305746388-18241-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Since break_lease is called before i_writecount is incremented, there's
a window between the two where a setlease call would have no way to know
that an open is about to happen.

We fix this by adding a new inode field, i_blockleases, that is
incremented while a lease-breaking operation is in progress.

We will later reuse i_blockleases to enforce lease-breaking for rename,
unlink, etc.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/inode.c         |    1 +
 fs/locks.c         |   28 ++++++++++++++++++++++++++++
 fs/namei.c         |    6 +++++-
 include/linux/fs.h |    3 +++
 4 files changed, 37 insertions(+), 1 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index 33c963d..4f253a2 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -198,6 +198,7 @@ int inode_init_always(struct super_block *sb, struct inode *inode)
 	inode->i_uid = 0;
 	inode->i_gid = 0;
 	atomic_set(&inode->i_writecount, 0);
+	atomic_set(&inode->i_blockleases, 0);
 	inode->i_size = 0;
 	inode->i_blocks = 0;
 	inode->i_bytes = 0;
diff --git a/fs/locks.c b/fs/locks.c
index 0a4f50d..7699b1b 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1164,6 +1164,32 @@ static void time_out_leases(struct inode *inode)
 	}
 }
 
+/* Disallow all leases (read or write): */
+void disallow_leases(struct inode *inode, int flags)
+{
+	if (!inode)
+		return;
+	if (!S_ISREG(inode->i_mode))
+		return;
+	if ((flags & O_ACCMODE) == O_RDONLY)
+		return;
+	atomic_inc(&inode->i_blockleases);
+}
+EXPORT_SYMBOL_GPL(disallow_leases);
+
+void reallow_leases(struct inode *inode, int flags)
+{
+	if (!inode)
+		return;
+	if (!S_ISREG(inode->i_mode))
+		return;
+	if ((flags & O_ACCMODE) == O_RDONLY)
+		return;
+	BUG_ON(atomic_read(&inode->i_blockleases) <= 0);
+	atomic_dec(&inode->i_blockleases);
+}
+EXPORT_SYMBOL_GPL(reallow_leases);
+
 /**
  *	__break_lease	-	revoke all outstanding leases on file
  *	@inode: the inode of the file to return
@@ -1369,6 +1395,8 @@ int generic_setlease(struct file *filp, long arg, struct file_lock **flp)
 
 	if (arg != F_UNLCK) {
 		error = -EAGAIN;
+		if (atomic_read(&inode->i_blockleases))
+			goto out;
 		if ((arg == F_RDLCK) && (atomic_read(&inode->i_writecount) > 0))
 			goto out;
 		if ((arg == F_WRLCK)
diff --git a/fs/namei.c b/fs/namei.c
index 3cb616d..079e68c 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2277,10 +2277,14 @@ ok:
 		want_write = 1;
 	}
 common:
+	disallow_leases(nd->path.dentry->d_inode, open_flag);
 	error = may_open(&nd->path, acc_mode, open_flag);
-	if (error)
+	if (error) {
+		reallow_leases(nd->path.dentry->d_inode, open_flag);
 		goto exit;
+	}
 	filp = nameidata_to_filp(nd);
+	reallow_leases(nd->path.dentry->d_inode, open_flag);
 	if (!IS_ERR(filp)) {
 		error = ima_file_check(filp, op->acc_mode);
 		if (error) {
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 1b95af3..daf8443 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -796,6 +796,7 @@ struct inode {
 #ifdef CONFIG_IMA
 	atomic_t		i_readcount; /* struct files open RO */
 #endif
+	atomic_t		i_blockleases; /* setlease fails when >0 */
 	atomic_t		i_writecount;
 #ifdef CONFIG_SECURITY
 	void			*i_security;
@@ -1161,6 +1162,8 @@ extern void lease_get_mtime(struct inode *, struct timespec *time);
 extern int generic_setlease(struct file *, long, struct file_lock **);
 extern int vfs_setlease(struct file *, long, struct file_lock **);
 extern int lease_modify(struct file_lock **, int);
+extern void disallow_leases(struct inode *, int flags);
+extern void reallow_leases(struct inode *, int flags);
 extern int lock_may_read(struct inode *, loff_t start, unsigned long count);
 extern int lock_may_write(struct inode *, loff_t start, unsigned long count);
 extern void lock_flocks(void);
-- 
1.7.4.1

