Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53089 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759385Ab2IEUzd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Sep 2012 16:55:33 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        "J. Bruce Fields" <bfields@redhat.com>,
        "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>
Subject: [RFC PATCH 02/13] vfs: pull ext4's double-i_mutex-locking into common code
Date: Wed,  5 Sep 2012 16:55:12 -0400
Message-Id: <1346878524-10585-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1346878524-10585-1-git-send-email-bfields@redhat.com>
References: <1346878524-10585-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

We want to do this elsewhere as well.

Also, compare pointers instead of inode numbers.

Cc: "Theodore Ts'o" <tytso@mit.edu>
Cc: Andreas Dilger <adilger.kernel@dilger.ca>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/ext4/move_extent.c |   21 ++-------------------
 fs/inode.c            |   36 ++++++++++++++++++++++++++++++++++++
 include/linux/fs.h    |    3 +++
 3 files changed, 41 insertions(+), 19 deletions(-)

diff --git a/fs/ext4/move_extent.c b/fs/ext4/move_extent.c
index c5826c6..b87d94a 100644
--- a/fs/ext4/move_extent.c
+++ b/fs/ext4/move_extent.c
@@ -1086,19 +1086,7 @@ mext_inode_double_lock(struct inode *inode1, struct inode *inode2)
 	if (ret < 0)
 		goto out;
 
-	if (inode1 == inode2) {
-		mutex_lock(&inode1->i_mutex);
-		goto out;
-	}
-
-	if (inode1->i_ino < inode2->i_ino) {
-		mutex_lock_nested(&inode1->i_mutex, I_MUTEX_PARENT);
-		mutex_lock_nested(&inode2->i_mutex, I_MUTEX_CHILD);
-	} else {
-		mutex_lock_nested(&inode2->i_mutex, I_MUTEX_PARENT);
-		mutex_lock_nested(&inode1->i_mutex, I_MUTEX_CHILD);
-	}
-
+	lock_two_nondirectories(inode1, inode2);
 out:
 	return ret;
 }
@@ -1123,12 +1111,7 @@ mext_inode_double_unlock(struct inode *inode1, struct inode *inode2)
 	if (ret < 0)
 		goto out;
 
-	if (inode1)
-		mutex_unlock(&inode1->i_mutex);
-
-	if (inode2 && inode2 != inode1)
-		mutex_unlock(&inode2->i_mutex);
-
+	unlock_two_nondirectories(inode1, inode2);
 out:
 	return ret;
 }
diff --git a/fs/inode.c b/fs/inode.c
index ac8d904..582843d 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -969,6 +969,42 @@ void unlock_new_inode(struct inode *inode)
 EXPORT_SYMBOL(unlock_new_inode);
 
 /**
+ * lock_two_nondirectories - take two i_mutexes on non-directory objects
+ * @inode1: first inode to lock; must be non-NULL
+ * @inode2: second inode to lock; optional, may equal first or be NULL.
+ */
+void lock_two_nondirectories(struct inode *inode1, struct inode *inode2)
+{
+	if (inode1 == inode2 || inode2 == NULL)
+		mutex_lock(&inode1->i_mutex);
+	else if (inode1 < inode2) {
+		mutex_lock_nested(&inode1->i_mutex, I_MUTEX_PARENT);
+		mutex_lock_nested(&inode2->i_mutex, I_MUTEX_CHILD);
+
+	} else {
+		mutex_lock_nested(&inode2->i_mutex, I_MUTEX_PARENT);
+		mutex_lock_nested(&inode1->i_mutex, I_MUTEX_CHILD);
+	}
+}
+EXPORT_SYMBOL(lock_two_nondirectories);
+
+/**
+ * lock_two_nondirectories - release locks from lock_two_nondirectories()
+ * @inode1: first inode to unlock
+ * @inode2: second inode to lock
+ *
+ * Arguments must be same as those given to corresponding
+ * lock_two_nondirectories() call.
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
index aa11047..a179b69 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -895,6 +895,9 @@ enum inode_i_mutex_lock_class
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

