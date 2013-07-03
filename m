Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39206 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933171Ab3GCUMp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Jul 2013 16:12:45 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        "J. Bruce Fields" <bfields@redhat.com>,
        "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>
Subject: [PATCH 01/12] vfs: pull ext4's double-i_mutex-locking into common code
Date: Wed,  3 Jul 2013 16:12:25 -0400
Message-Id: <1372882356-14168-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1372882356-14168-1-git-send-email-bfields@redhat.com>
References: <1372882356-14168-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

We want to do this elsewhere as well.

Cc: "Theodore Ts'o" <tytso@mit.edu>
Cc: Andreas Dilger <adilger.kernel@dilger.ca>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/ext4/ext4.h        |    2 --
 fs/ext4/ioctl.c       |    4 ++--
 fs/ext4/move_extent.c |   40 ++--------------------------------------
 fs/inode.c            |   29 +++++++++++++++++++++++++++++
 include/linux/fs.h    |    3 +++
 5 files changed, 36 insertions(+), 42 deletions(-)

diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index 5aae3d1..3590abe 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -2642,8 +2642,6 @@ extern void ext4_double_down_write_data_sem(struct inode *first,
 					    struct inode *second);
 extern void ext4_double_up_write_data_sem(struct inode *orig_inode,
 					  struct inode *donor_inode);
-void ext4_inode_double_lock(struct inode *inode1, struct inode *inode2);
-void ext4_inode_double_unlock(struct inode *inode1, struct inode *inode2);
 extern int ext4_move_extents(struct file *o_filp, struct file *d_filp,
 			     __u64 start_orig, __u64 start_donor,
 			     __u64 len, __u64 *moved_len);
diff --git a/fs/ext4/ioctl.c b/fs/ext4/ioctl.c
index 9491ac0..12048f7 100644
--- a/fs/ext4/ioctl.c
+++ b/fs/ext4/ioctl.c
@@ -129,7 +129,7 @@ static long swap_inode_boot_loader(struct super_block *sb,
 
 	/* Protect orig inodes against a truncate and make sure,
 	 * that only 1 swap_inode_boot_loader is running. */
-	ext4_inode_double_lock(inode, inode_bl);
+	lock_two_nondirectories(inode, inode_bl);
 
 	truncate_inode_pages(&inode->i_data, 0);
 	truncate_inode_pages(&inode_bl->i_data, 0);
@@ -204,7 +204,7 @@ static long swap_inode_boot_loader(struct super_block *sb,
 	ext4_inode_resume_unlocked_dio(inode);
 	ext4_inode_resume_unlocked_dio(inode_bl);
 
-	ext4_inode_double_unlock(inode, inode_bl);
+	unlock_two_nondirectories(inode, inode_bl);
 
 	iput(inode_bl);
 
diff --git a/fs/ext4/move_extent.c b/fs/ext4/move_extent.c
index 3dcbf36..986a838 100644
--- a/fs/ext4/move_extent.c
+++ b/fs/ext4/move_extent.c
@@ -1206,42 +1206,6 @@ mext_check_arguments(struct inode *orig_inode,
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
@@ -1330,7 +1294,7 @@ ext4_move_extents(struct file *o_filp, struct file *d_filp,
 		return -EINVAL;
 	}
 	/* Protect orig and donor inodes against a truncate */
-	ext4_inode_double_lock(orig_inode, donor_inode);
+	lock_two_nondirectories(orig_inode, donor_inode);
 
 	/* Wait for all existing dio workers */
 	ext4_inode_block_unlocked_dio(orig_inode);
@@ -1538,7 +1502,7 @@ out:
 	ext4_double_up_write_data_sem(orig_inode, donor_inode);
 	ext4_inode_resume_unlocked_dio(orig_inode);
 	ext4_inode_resume_unlocked_dio(donor_inode);
-	ext4_inode_double_unlock(orig_inode, donor_inode);
+	unlock_two_nondirectories(orig_inode, donor_inode);
 
 	return ret;
 }
diff --git a/fs/inode.c b/fs/inode.c
index 00d5fc3..b8afbc7 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -980,6 +980,35 @@ void unlock_new_inode(struct inode *inode)
 EXPORT_SYMBOL(unlock_new_inode);
 
 /**
+ * lock_two_nondirectories - take two i_mutexes on non-directory objects
+ * @inode1: first inode to lock
+ * @inode2: second inode to lock
+ */
+void lock_two_nondirectories(struct inode *inode1, struct inode *inode2)
+{
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
+	mutex_unlock(&inode2->i_mutex);
+}
+EXPORT_SYMBOL(unlock_two_nondirectories);
+
+/**
  * iget5_locked - obtain an inode from a mounted file system
  * @sb:		super block of file system
  * @hashval:	hash value (usually inode number) to get
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 65c2be2..3258761 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -634,6 +634,9 @@ enum inode_i_mutex_lock_class
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

