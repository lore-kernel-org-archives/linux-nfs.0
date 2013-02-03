Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46499 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753281Ab3BCQbg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 3 Feb 2013 11:31:36 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>
Subject: [PATCH 01/12] vfs: pull ext4's double-i_mutex-locking into common code
Date: Sun,  3 Feb 2013 11:31:21 -0500
Message-Id: <1359909092-24857-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1359909092-24857-1-git-send-email-bfields@redhat.com>
References: <1359909092-24857-1-git-send-email-bfields@redhat.com>
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
index d9cc5ee..3e5d117 100644
--- a/fs/ext4/move_extent.c
+++ b/fs/ext4/move_extent.c
@@ -1198,42 +1198,6 @@ mext_check_arguments(struct inode *orig_inode,
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
@@ -1322,7 +1286,7 @@ ext4_move_extents(struct file *o_filp, struct file *d_filp,
 		return -EINVAL;
 	}
 	/* Protect orig and donor inodes against a truncate */
-	mext_inode_double_lock(orig_inode, donor_inode);
+	lock_two_nondirectories(orig_inode, donor_inode);
 
 	/* Wait for all existing dio workers */
 	ext4_inode_block_unlocked_dio(orig_inode);
@@ -1530,7 +1494,7 @@ out:
 	double_up_write_data_sem(orig_inode, donor_inode);
 	ext4_inode_resume_unlocked_dio(orig_inode);
 	ext4_inode_resume_unlocked_dio(donor_inode);
-	mext_inode_double_unlock(orig_inode, donor_inode);
+	unlock_two_nondirectories(orig_inode, donor_inode);
 
 	return ret;
 }
diff --git a/fs/inode.c b/fs/inode.c
index 14084b7..6e58fb4 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -982,6 +982,35 @@ void unlock_new_inode(struct inode *inode)
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
index 7617ee0..89a66d4 100644
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

