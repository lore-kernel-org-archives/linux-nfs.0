Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52992 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757626AbbJVRiS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
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
Subject: [PATCH V2 1/3] locks: introduce locks_lock_inode_wait()
Date: Thu, 22 Oct 2015 13:38:13 -0400
Message-Id: <187138bf0228db4873cec0dc8ed100d110e9c0b2.1445535305.git.bcodding@redhat.com>
In-Reply-To: <cover.1445535305.git.bcodding@redhat.com>
References: <cover.1445535305.git.bcodding@redhat.com>
In-Reply-To: <cover.1445535305.git.bcodding@redhat.com>
References: <cover.1445535305.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Users of the locks API commonly call either posix_lock_file_wait() or
flock_lock_file_wait() depending upon the lock type.  Add a new function
locks_lock_inode_wait() which will check and call the correct function for
the type of lock passed in.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/locks.c         |   24 ++++++++++++++++++++++++
 include/linux/fs.h |   11 +++++++++++
 2 files changed, 35 insertions(+), 0 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 2a54c80..68b1784 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1876,6 +1876,30 @@ int flock_lock_inode_wait(struct inode *inode, struct file_lock *fl)
 EXPORT_SYMBOL(flock_lock_inode_wait);
 
 /**
+ * locks_lock_inode_wait - Apply a lock to an inode
+ * @inode: inode of the file to apply to
+ * @fl: The lock to be applied
+ *
+ * Apply a POSIX or FLOCK style lock request to an inode.
+ */
+int locks_lock_inode_wait(struct inode *inode, struct file_lock *fl)
+{
+	int res = 0;
+	switch (fl->fl_flags & (FL_POSIX|FL_FLOCK)) {
+		case FL_POSIX:
+			res = posix_lock_inode_wait(inode, fl);
+			break;
+		case FL_FLOCK:
+			res = flock_lock_inode_wait(inode, fl);
+			break;
+		default:
+			BUG();
+	}
+	return res;
+}
+EXPORT_SYMBOL(locks_lock_inode_wait);
+
+/**
  *	sys_flock: - flock() system call.
  *	@fd: the file descriptor to lock.
  *	@cmd: the type of lock to apply.
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 72d8a84..b064d4c 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1059,6 +1059,7 @@ extern int vfs_test_lock(struct file *, struct file_lock *);
 extern int vfs_lock_file(struct file *, unsigned int, struct file_lock *, struct file_lock *);
 extern int vfs_cancel_lock(struct file *filp, struct file_lock *fl);
 extern int flock_lock_inode_wait(struct inode *inode, struct file_lock *fl);
+extern int locks_lock_inode_wait(struct inode *inode, struct file_lock *fl);
 extern int __break_lease(struct inode *inode, unsigned int flags, unsigned int type);
 extern void lease_get_mtime(struct inode *, struct timespec *time);
 extern int generic_setlease(struct file *, long, struct file_lock **, void **priv);
@@ -1177,6 +1178,11 @@ static inline int flock_lock_inode_wait(struct inode *inode,
 	return -ENOLCK;
 }
 
+static inline int locks_lock_inode_wait(struct inode *inode, struct file_lock *fl)
+{
+	return -ENOLCK;
+}
+
 static inline int __break_lease(struct inode *inode, unsigned int mode, unsigned int type)
 {
 	return 0;
@@ -1225,6 +1231,11 @@ static inline int flock_lock_file_wait(struct file *filp, struct file_lock *fl)
 	return flock_lock_inode_wait(file_inode(filp), fl);
 }
 
+static inline int locks_lock_file_wait(struct file *filp, struct file_lock *fl)
+{
+	return locks_lock_inode_wait(file_inode(filp), fl);
+}
+
 struct fasync_struct {
 	spinlock_t		fa_lock;
 	int			magic;
-- 
1.7.1

