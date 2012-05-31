Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40028 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964807Ab2EaUOI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 May 2012 16:14:08 -0400
Date: Thu, 31 May 2012 16:14:02 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jan Kara <jack@suse.cz>
Cc: "J. Bruce Fields" <bfields@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: [PATCH 6/6 (v2)] vfs: rename I_MUTEX_QUOTA now that it's not used
 for quotas
Message-ID: <20120531201402.GF25955@fieldses.org>
References: <1338429016-20119-1-git-send-email-bfields@redhat.com>
 <1338429016-20119-3-git-send-email-bfields@redhat.com>
 <20120531185111.GA13647@quack.suse.cz>
 <20120531185439.GB13647@quack.suse.cz>
 <20120531201150.GE25955@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120531201150.GE25955@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

I_MUTEX_QUOTA is now just being used whenever we want to lock two
non-directories.  So the name isn't right.  I_MUTEX_NONDIR2 isn't
especially elegant but it's the best I could think of.

Also fix some outdated documentation.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/inode.c         |    4 ++--
 include/linux/fs.h |    9 ++++++---
 2 files changed, 8 insertions(+), 5 deletions(-)

On Thu, May 31, 2012 at 04:11:50PM -0400, bfields wrote:
> On Thu, May 31, 2012 at 08:54:39PM +0200, Jan Kara wrote:
> >   Oh, now I've noticed patch 6/6. Maybe this patch and 6/6 should be just
> > joined into one?
> 
> Sure.--b.

So, we'd omit patch 2 and replace the previous patch 6 by this.  The
other patches are unchanged.

diff --git a/fs/inode.c b/fs/inode.c
index 0272ac3..9c828ab 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -979,11 +979,11 @@ void lock_two_nondirectories(struct inode *inode1, struct inode *inode2)
 		mutex_lock(&inode1->i_mutex);
 	else if (inode1 < inode2) {
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
index 09434db..f0b5a5d 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -861,10 +861,13 @@ static inline int inode_unhashed(struct inode *inode)
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
@@ -872,7 +875,7 @@ enum inode_i_mutex_lock_class
 	I_MUTEX_PARENT,
 	I_MUTEX_CHILD,
 	I_MUTEX_XATTR,
-	I_MUTEX_QUOTA
+	I_MUTEX_NONDIR2
 };
 
 void lock_two_nondirectories(struct inode *, struct inode*);
-- 
1.7.9.5

