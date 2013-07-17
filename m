Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53625 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756149Ab3GQUuU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Jul 2013 16:50:20 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        jlayton@redhat.com, Dave Chinner <david@fromorbit.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 03/16] vfs: rename I_MUTEX_QUOTA now that it's not used for quotas
Date: Wed, 17 Jul 2013 16:50:04 -0400
Message-Id: <1374094217-31493-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1374094217-31493-1-git-send-email-bfields@redhat.com>
References: <1374094217-31493-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

I_MUTEX_QUOTA is now just being used whenever we want to lock two
non-directories.  So the name isn't right.  I_MUTEX_NONDIR2 isn't
especially elegant but it's the best I could think of.

Also fix some outdated documentation.

Acked-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/inode.c         |    4 ++--
 include/linux/fs.h |    9 ++++++---
 2 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index f642102..4178e91 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -996,10 +996,10 @@ void lock_two_nondirectories(struct inode *inode1, struct inode *inode2)
 	WARN_ON_ONCE(S_ISDIR(inode2->i_mode));
 	if (inode1 < inode2) {
 		mutex_lock(&inode1->i_mutex);
-		mutex_lock_nested(&inode2->i_mutex, I_MUTEX_QUOTA);
+		mutex_lock_nested(&inode2->i_mutex, I_MUTEX_NONDIR2);
 	} else {
 		mutex_lock(&inode2->i_mutex);
-		mutex_lock_nested(&inode1->i_mutex, I_MUTEX_QUOTA);
+		mutex_lock_nested(&inode1->i_mutex, I_MUTEX_NONDIR2);
 	}
 }
 EXPORT_SYMBOL(lock_two_nondirectories);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 431427a..edca504 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -622,10 +622,13 @@ static inline int inode_unhashed(struct inode *inode)
  * 0: the object of the current VFS operation
  * 1: parent
  * 2: child/target
- * 3: quota file
+ * 3: xattr
+ * 4: second non-directory
+ * The last is for certain operations (such as rename) which lock two
+ * non-directories at once.
  *
  * The locking order between these classes is
- * parent -> child -> normal -> xattr -> quota
+ * parent -> child -> normal -> xattr -> second non-directory
  */
 enum inode_i_mutex_lock_class
 {
@@ -633,7 +636,7 @@ enum inode_i_mutex_lock_class
 	I_MUTEX_PARENT,
 	I_MUTEX_CHILD,
 	I_MUTEX_XATTR,
-	I_MUTEX_QUOTA
+	I_MUTEX_NONDIR2
 };
 
 void lock_two_nondirectories(struct inode *, struct inode*);
-- 
1.7.9.5

