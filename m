Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40815 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752241Ab3IEQaZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Sep 2013 12:30:25 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        jlayton@redhat.com, Dave Chinner <david@fromorbit.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Andreas Dilger <adilger.kernel@dilger.ca>
Subject: [PATCH 01/12] vfs: pull ext4's double-i_mutex-locking into common code
Date: Thu,  5 Sep 2013 12:30:06 -0400
Message-Id: <1378398620-23018-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1378398620-23018-1-git-send-email-bfields@redhat.com>
References: <1378398620-23018-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

We want to do this elsewhere as well.

Also catch any attempts to use it for directories (where this ordering
would conflict with ancestor-first directory ordering in lock_rename).

Cc: Andreas Dilger <adilger.kernel@dilger.ca>
Cc: Dave Chinner <david@fromorbit.com>
Acked-by: Jeff Layton <jlayton@redhat.com>
Acked-by: "Theodore Ts'o" <tytso@mit.edu>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/ext4/ext4.h        |    2 --
 fs/ext4/ioctl.c       |    4 ++--
 fs/ext4/move_extent.c |   40 ++--------------------------------------
 fs/inode.c            |   36 ++++++++++++++++++++++++++++++++++++
 include/linux/fs.h    |    3 +++
 5 files changed, 43 insertions(+), 42 deletions(-)

diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index 0ab26fb..85998bc 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -2700,8 +2700,6 @@ extern void ext4_double_down_write_data_sem(struct inode *first,
 					    struct inode *second);
 extern void ext4_double_up_write_data_sem(struct inode *orig_inode,
 					  struct inode *donor_inode);
-void ext4_inode_double_lock(struct inode *inode1, struct inode *inode2);
-void ext4_inode_double_unlock(struct inode *inode1, struct inode *inode2);
 extern int ext4_move_extents(struct file *o_filp, struct file *d_filp,
 			     __u64 start_orig, __u64 start_donor,
 			     __u64 len, __u64 *moved_len);
diff --git a/fs/ext4/ioctl.c b/fs/ext4/ioctl.c
index c0427e2..d865b25 100644
--- a/fs/ext4/ioctl.c
+++ b/fs/ext4/ioctl.c
@@ -131,7 +131,7 @@ static long swap_inode_boot_loader(struct super_block *sb,
 
 	/* Protect orig inodes against a truncate and make sure,
 	 * that only 1 swap_inode_boot_loader is running. */
-	ext4_inode_double_lock(inode, inode_bl);
+	lock_two_nondirectories(inode, inode_bl);
 
 	truncate_inode_pages(&inode->i_data, 0);
 	truncate_inode_pages(&inode_bl->i_data, 0);
@@ -206,7 +206,7 @@ static long swap_inode_boot_loader(struct super_block *sb,
 	ext4_inode_resume_unlocked_dio(inode);
 	ext4_inode_resume_unlocked_dio(inode_bl);
 
-	ext4_inode_double_unlock(inode, inode_bl);
+	unlock_two_nondirectories(inode, inode_bl);
 
 	iput(inode_bl);
 
diff --git a/fs/ext4/move_extent.c b/fs/ext4/move_extent.c
index e86dddb..f591a75 100644
--- a/fs/ext4/move_extent.c
+++ b/fs/ext4/move_extent.c
@@ -1203,42 +1203,6 @@ mext_check_arguments(struct inode *orig_inode,
 }
 
 /**
- * ext4_inode_double_lock - Lock i_mutex on both @inode1 and @inode2
- *
- * @inode1:	the inode structure
- * @inode2:	the inode structure
- *
- * Lock two inodes' i_mutex
- */
-void
-ext4_inode_double_lock(struct inode *inode1, struct inode *inode2)
-{
-	BUG_ON(inode1 == inode2);
-	if (inode1 < inode2) {
-		mutex_lock_nested(&inode1->i_mutex, I_MUTEX_PARENT);
-		mutex_lock_nested(&inode2->i_mutex, I_MUTEX_CHILD);
-	} else {
-		mutex_lock_nested(&inode2->i_mutex, I_MUTEX_PARENT);
-		mutex_lock_nested(&inode1->i_mutex, I_MUTEX_CHILD);
-	}
-}
-
-/**
- * ext4_inode_double_unlock - Release i_mutex on both @inode1 and @inode2
- *
- * @inode1:     the inode that is released first
- * @inode2:     the inode that is released second
- *
- */
-
-void
-ext4_inode_double_unlock(struct inode *inode1, struct inode *inode2)
-{
-	mutex_unlock(&inode1->i_mutex);
-	mutex_unlock(&inode2->i_mutex);
-}
-
-/**
  * ext4_move_extents - Exchange the specified range of a file
  *
  * @o_filp:		file structure of the original file
@@ -1327,7 +1291,7 @@ ext4_move_extents(struct file *o_filp, struct file *d_filp,
 		return -EINVAL;
 	}
 	/* Protect orig and donor inodes against a truncate */
-	ext4_inode_double_lock(orig_inode, donor_inode);
+	lock_two_nondirectories(orig_inode, donor_inode);
 
 	/* Wait for all existing dio workers */
 	ext4_inode_block_unlocked_dio(orig_inode);
@@ -1535,7 +1499,7 @@ out:
 	ext4_double_up_write_data_sem(orig_inode, donor_inode);
 	ext4_inode_resume_unlocked_dio(orig_inode);
 	ext4_inode_resume_unlocked_dio(donor_inode);
-	ext4_inode_double_unlock(orig_inode, donor_inode);
+	unlock_two_nondirectories(orig_inode, donor_inode);
 
 	return ret;
 }
diff --git a/fs/inode.c b/fs/inode.c
index d6dfb09..57d273e 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -982,6 +982,42 @@ void unlock_new_inode(struct inode *inode)
 EXPORT_SYMBOL(unlock_new_inode);
 
 /**
+ * lock_two_nondirectories - take two i_mutexes on non-directory objects
+ * @inode1: first inode to lock
+ * @inode2: second inode to lock
+ */
+void lock_two_nondirectories(struct inode *inode1, struct inode *inode2)
+{
+	WARN_ON_ONCE(S_ISDIR(inode1->i_mode));
+	if (inode1 == inode2 || !inode2) {
+		mutex_lock_nested(&inode1->i_mutex, I_MUTEX_PARENT);
+		return;
+	}
+	WARN_ON_ONCE(S_ISDIR(inode2->i_mode));
+	if (inode1 < inode2) {
+		mutex_lock_nested(&inode1->i_mutex, I_MUTEX_PARENT);
+		mutex_lock_nested(&inode2->i_mutex, I_MUTEX_CHILD);
+	} else {
+		mutex_lock_nested(&inode2->i_mutex, I_MUTEX_PARENT);
+		mutex_lock_nested(&inode1->i_mutex, I_MUTEX_CHILD);
+	}
+}
+EXPORT_SYMBOL(lock_two_nondirectories);
+
+/**
+ * unlock_two_nondirectories - release locks from lock_two_nondirectories()
+ * @inode1: first inode to unlock
+ * @inode2: second inode to unlock
+ */
+void unlock_two_nondirectories(struct inode *inode1, struct inode *inode2)
+{
+	mutex_unlock(&inode1->i_mutex);
+	if (inode2 && inode2 != inode1)
+		mutex_unlock(&inode2->i_mutex);
+}
+EXPORT_SYMBOL(unlock_two_nondirectories);
+
+/**
  * iget5_locked - obtain an inode from a mounted file system
  * @sb:		super block of file system
  * @hashval:	hash value (usually inode number) to get
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 9818747..431427a 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -636,6 +636,9 @@ enum inode_i_mutex_lock_class
 	I_MUTEX_QUOTA
 };
 
+void lock_two_nondirectories(struct inode *, struct inode*);
+void unlock_two_nondirectories(struct inode *, struct inode*);
+
 /*
  * NOTE: in a 32bit arch with a preemptable kernel and
  * an UP compile the i_size_read/write must be atomic
-- 
1.7.9.5

