Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:19618 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753588Ab2IFNtz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Sep 2012 09:49:55 -0400
Date: Thu, 6 Sep 2012 09:49:48 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Guo Chao <yan@linux.vnet.ibm.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>
Subject: Re: [RFC PATCH 02/13] vfs: pull ext4's double-i_mutex-locking into
 common code
Message-ID: <20120906134947.GA13533@pad.fieldses.org>
References: <1346878524-10585-1-git-send-email-bfields@redhat.com>
 <1346878524-10585-3-git-send-email-bfields@redhat.com>
 <20120906025358.GA6679@yanx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120906025358.GA6679@yanx>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 06, 2012 at 10:53:58AM +0800, Guo Chao wrote:
> On Wed, Sep 05, 2012 at 04:55:12PM -0400, J. Bruce Fields wrote:
> > +/**
> > + * lock_two_nondirectories - release locks from lock_two_nondirectories()
>     unlock_two_nondirectories
> 
> > + * @inode1: first inode to unlock
> > + * @inode2: second inode to lock
>                              unlock
> 

Both fixed, thanks!

--b.

commit d190216f0b6c4623f9c23e2c7fb2e2fa9009891f
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Wed Apr 18 15:16:33 2012 -0400

    vfs: pull ext4's double-i_mutex-locking into common code
    
    We want to do this elsewhere as well.
    
    Also, compare pointers instead of inode numbers.
    
    Cc: "Theodore Ts'o" <tytso@mit.edu>
    Cc: Andreas Dilger <adilger.kernel@dilger.ca>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

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
index ac8d904..275f571 100644
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
+ * unlock_two_nondirectories - release locks from lock_two_nondirectories()
+ * @inode1: first inode to unlock
+ * @inode2: second inode to unlock
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
