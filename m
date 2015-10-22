Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36237 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757654AbbJVRiS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Oct 2015 13:38:18 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Christoph Hellwig <hch@infradead.org>, Oleg Drokin <oleg.drokin@intel.com>,
        Andreas Dilger <andreas.dilger@intel.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Eric Van Hensbergen <ericvh@gmail.com>,
        Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>,
        "Yan Zheng" <zyan@redhat.com>, Sage Weil <sage@redhat.com>,
        Ilya Dryomov <idryomov@gmail.com>, Steve French <sfrench@samba.org>,
        Christine Caulfield <ccaulfie@redhat.com>,
        David Teigland <teigland@redhat.com>,
        Miklos Szeredi <miklos@szeredi.hu>,
        Steven Whitehouse <swhiteho@redhat.com>,
        Bob Peterson <rpeterso@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>,
        aybuke ozdemir <aybuke.147@gmail.com>,
        Julia Lawall <Julia.Lawall@lip6.fr>,
        Abdul Hussain <habdul@visteon.com>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: [PATCH V2 3/3] locks: cleanup posix_lock_inode_wait and flock_lock_inode_wait
Date: Thu, 22 Oct 2015 13:38:15 -0400
Message-Id: <bbe0fbc1041e7638f3b05ee242eb2c787c8494a6.1445535305.git.bcodding@redhat.com>
In-Reply-To: <cover.1445535305.git.bcodding@redhat.com>
References: <cover.1445535305.git.bcodding@redhat.com>
In-Reply-To: <cover.1445535305.git.bcodding@redhat.com>
References: <cover.1445535305.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All callers use locks_lock_inode_wait() instead.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/locks.c         |    9 +++------
 include/linux/fs.h |   24 ------------------------
 2 files changed, 3 insertions(+), 30 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 94d50d3..4181f83 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1167,10 +1167,9 @@ EXPORT_SYMBOL(posix_lock_file);
  * @inode: inode of file to which lock request should be applied
  * @fl: The lock to be applied
  *
- * Variant of posix_lock_file_wait that does not take a filp, and so can be
- * used after the filp has already been torn down.
+ * Apply a POSIX style lock request to an inode.
  */
-int posix_lock_inode_wait(struct inode *inode, struct file_lock *fl)
+static int posix_lock_inode_wait(struct inode *inode, struct file_lock *fl)
 {
 	int error;
 	might_sleep ();
@@ -1187,7 +1186,6 @@ int posix_lock_inode_wait(struct inode *inode, struct file_lock *fl)
 	}
 	return error;
 }
-EXPORT_SYMBOL(posix_lock_inode_wait);
 
 /**
  * locks_mandatory_locked - Check for an active lock
@@ -1856,7 +1854,7 @@ int fcntl_setlease(unsigned int fd, struct file *filp, long arg)
  *
  * Apply a FLOCK style lock request to an inode.
  */
-int flock_lock_inode_wait(struct inode *inode, struct file_lock *fl)
+static int flock_lock_inode_wait(struct inode *inode, struct file_lock *fl)
 {
 	int error;
 	might_sleep();
@@ -1873,7 +1871,6 @@ int flock_lock_inode_wait(struct inode *inode, struct file_lock *fl)
 	}
 	return error;
 }
-EXPORT_SYMBOL(flock_lock_inode_wait);
 
 /**
  * locks_lock_inode_wait - Apply a lock to an inode
diff --git a/include/linux/fs.h b/include/linux/fs.h
index b064d4c..4974968 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1053,12 +1053,10 @@ extern void locks_remove_file(struct file *);
 extern void locks_release_private(struct file_lock *);
 extern void posix_test_lock(struct file *, struct file_lock *);
 extern int posix_lock_file(struct file *, struct file_lock *, struct file_lock *);
-extern int posix_lock_inode_wait(struct inode *, struct file_lock *);
 extern int posix_unblock_lock(struct file_lock *);
 extern int vfs_test_lock(struct file *, struct file_lock *);
 extern int vfs_lock_file(struct file *, unsigned int, struct file_lock *, struct file_lock *);
 extern int vfs_cancel_lock(struct file *filp, struct file_lock *fl);
-extern int flock_lock_inode_wait(struct inode *inode, struct file_lock *fl);
 extern int locks_lock_inode_wait(struct inode *inode, struct file_lock *fl);
 extern int __break_lease(struct inode *inode, unsigned int flags, unsigned int type);
 extern void lease_get_mtime(struct inode *, struct timespec *time);
@@ -1145,12 +1143,6 @@ static inline int posix_lock_file(struct file *filp, struct file_lock *fl,
 	return -ENOLCK;
 }
 
-static inline int posix_lock_inode_wait(struct inode *inode,
-					struct file_lock *fl)
-{
-	return -ENOLCK;
-}
-
 static inline int posix_unblock_lock(struct file_lock *waiter)
 {
 	return -ENOENT;
@@ -1172,12 +1164,6 @@ static inline int vfs_cancel_lock(struct file *filp, struct file_lock *fl)
 	return 0;
 }
 
-static inline int flock_lock_inode_wait(struct inode *inode,
-					struct file_lock *request)
-{
-	return -ENOLCK;
-}
-
 static inline int locks_lock_inode_wait(struct inode *inode, struct file_lock *fl)
 {
 	return -ENOLCK;
@@ -1221,16 +1207,6 @@ static inline struct inode *file_inode(const struct file *f)
 	return f->f_inode;
 }
 
-static inline int posix_lock_file_wait(struct file *filp, struct file_lock *fl)
-{
-	return posix_lock_inode_wait(file_inode(filp), fl);
-}
-
-static inline int flock_lock_file_wait(struct file *filp, struct file_lock *fl)
-{
-	return flock_lock_inode_wait(file_inode(filp), fl);
-}
-
 static inline int locks_lock_file_wait(struct file *filp, struct file_lock *fl)
 {
 	return locks_lock_inode_wait(file_inode(filp), fl);
-- 
1.7.1

