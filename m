Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f42.google.com ([209.85.192.42]:47337 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757912AbaFSOvL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:51:11 -0400
Received: by mail-qg0-f42.google.com with SMTP id e89so2252866qgf.1
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:51:11 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 009/104] locks: add file_has_lease
Date: Thu, 19 Jun 2014 10:49:15 -0400
Message-Id: <1403189450-18729-10-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a function that can tell us whether a file description has had a
lease set on it.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/locks.c         | 26 ++++++++++++++++++++++++++
 include/linux/fs.h |  6 ++++++
 2 files changed, 32 insertions(+)

diff --git a/fs/locks.c b/fs/locks.c
index da57c9b7e844..402169f95502 100644
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
index 338e6f758c6d..7937523c21ca 100644
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

