Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f41.google.com ([209.85.216.41]:60084 "EHLO
	mail-qa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751754AbaFZTOe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:14:34 -0400
Received: by mail-qa0-f41.google.com with SMTP id cm18so3214704qab.28
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:14:34 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 035/117] locks: add file_has_lease to prevent delegation break races
Date: Thu, 26 Jun 2014 15:12:15 -0400
Message-Id: <1403810017-16062-36-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Once we remove the client_mutex, we'll have a potential race between
setting a lease on a file and breaking the delegation. We may set the
lease, but by the time we go to hash it, it may have already been
broken. Currently, we know that this won't happen as the nfs4_laundromat
takes the client_mutex, but we want to remove that.

As part of that fix, add a function that can tell us whether a
particular file has a lease set on it. In a later nfsd patch, we'll use
that to close the potential race window.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/locks.c         | 26 ++++++++++++++++++++++++++
 include/linux/fs.h |  6 ++++++
 2 files changed, 32 insertions(+)

diff --git a/fs/locks.c b/fs/locks.c
index 717fbc404e6b..005cc86927e3 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1308,6 +1308,32 @@ static bool leases_conflict(struct file_lock *lease, struct file_lock *breaker)
 }
 
 /**
+ * file_has_lease - does the given file have a lease set on it?
+ * @file: struct file on which we want to check the lease
+ *
+ * Returns true if a lease was is set on the given file description,
+ * false otherwise.
+ */
+bool
+file_has_lease(struct file *file)
+{
+	bool ret = false;
+	struct inode *inode = file_inode(file);
+	struct file_lock *fl;
+
+	spin_lock(&inode->i_lock);
+	for (fl = inode->i_flock; fl && IS_LEASE(fl); fl = fl->fl_next) {
+		if (fl->fl_file == file) {
+			ret = true;
+			break;
+		}
+	}
+	spin_unlock(&inode->i_lock);
+	return ret;
+}
+EXPORT_SYMBOL(file_has_lease);
+
+/**
  *	__break_lease	-	revoke all outstanding leases on file
  *	@inode: the inode of the file to return
  *	@mode: O_RDONLY: break only write leases; O_WRONLY or O_RDWR:
diff --git a/include/linux/fs.h b/include/linux/fs.h
index e11d60cc867b..7ae6f4869669 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -953,6 +953,7 @@ extern int vfs_test_lock(struct file *, struct file_lock *);
 extern int vfs_lock_file(struct file *, unsigned int, struct file_lock *, struct file_lock *);
 extern int vfs_cancel_lock(struct file *filp, struct file_lock *fl);
 extern int flock_lock_file_wait(struct file *filp, struct file_lock *fl);
+extern bool file_has_lease(struct file *file);
 extern int __break_lease(struct inode *inode, unsigned int flags, unsigned int type);
 extern void lease_get_mtime(struct inode *, struct timespec *time);
 extern int generic_setlease(struct file *, long, struct file_lock **);
@@ -1064,6 +1065,11 @@ static inline int flock_lock_file_wait(struct file *filp,
 	return -ENOLCK;
 }
 
+static inline bool file_has_lease(struct file *file)
+{
+	return false;
+}
+
 static inline int __break_lease(struct inode *inode, unsigned int mode, unsigned int type)
 {
 	return 0;
-- 
1.9.3

