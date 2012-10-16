Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36012 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754864Ab2JPWBn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Oct 2012 18:01:43 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        "J. Bruce Fields" <bfields@redhat.com>,
        "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>
Subject: [PATCH 01/12] vfs: pull ext4's double-i_mutex-locking into common code
Date: Tue, 16 Oct 2012 18:01:26 -0400
Message-Id: <1350424897-26894-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1350424897-26894-1-git-send-email-bfields@redhat.com>
References: <1350424897-26894-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

We want to do this elsewhere as well.

Cc: "Theodore Ts'o" <tytso@mit.edu>
Cc: Andreas Dilger <adilger.kernel@dilger.ca>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/ext4/move_extent.c |   40 ++--------------------------------------
 fs/inode.c            |   29 +++++++++++++++++++++++++++++
 include/linux/fs.h    |    3 +++
 3 files changed, 34 insertions(+), 38 deletions(-)

diff --git a/fs/ext4/move_extent.c b/fs/ext4/move_extent.c
index 292daee..ee02681 100644
--- a/fs/ext4/move_extent.c
+++ b/fs/ext4/move_extent.c
@@ -1197,42 +1197,6 @@ mext_check_arguments(struct inode *orig_inode,
 }
 
 /**
- * mext_inode_double_lock - Lock i_mutex on both @inode1 and @inode2
- *
- * @inode1:	the inode structure
- * @inode2:	the inode structure
- *
- * Lock two inodes' i_mutex
- */
-static void
-mext_inode_double_lock(struct inode *inode1, struct inode *inode2)
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
- * mext_inode_double_unlock - Release i_mutex on both @inode1 and @inode2
- *
- * @inode1:     the inode that is released first
- * @inode2:     the inode that is released second
- *
- */
-
-static void
-mext_inode_double_unlock(struct inode *inode1, struct inode *inode2)
-{
-	mutex_unlock(&inode1->i_mutex);
-	mutex_unlock(&inode2->i_mutex);
-}
-
-/**
  * ext4_move_extents - Exchange the specified range of a file
  *
  * @o_filp:		file structure of the original file
@@ -1321,7 +1285,7 @@ ext4_move_extents(struct file *o_filp, struct file *d_filp,
 		return -EINVAL;
 	}
 	/* Protect orig and donor inodes against a truncate */
-	mext_inode_double_lock(orig_inode, donor_inode);
+	lock_two_nondirectories(orig_inode, donor_inode);
 
 	/* Wait for all existing dio workers */
 	ext4_inode_block_unlocked_dio(orig_inode);
@@ -1529,7 +1493,7 @@ out:
 	double_up_write_data_sem(orig_inode, donor_inode);
 	ext4_inode_resume_unlocked_dio(orig_inode);
 	ext4_inode_resume_unlocked_dio(donor_inode);
-	mext_inode_double_unlock(orig_inode, donor_inode);
+	unlock_two_nondirectories(orig_inode, donor_inode);
 
 	return ret;
 }
diff --git a/fs/inode.c b/fs/inode.c
index b03c719..9d5b6bd 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -969,6 +969,35 @@ void unlock_new_inode(struct inode *inode)
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
index 001c7cf..83da035 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -568,6 +568,9 @@ enum inode_i_mutex_lock_class
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

