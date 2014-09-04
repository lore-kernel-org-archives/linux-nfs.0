Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f179.google.com ([209.85.216.179]:39272 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239AbaIDMjD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2014 08:39:03 -0400
Received: by mail-qc0-f179.google.com with SMTP id l6so10442510qcy.10
        for <linux-nfs@vger.kernel.org>; Thu, 04 Sep 2014 05:39:03 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org
Subject: [PATCH v2 05/17] locks: generic_delete_lease doesn't need a file_lock at all
Date: Thu,  4 Sep 2014 08:38:31 -0400
Message-Id: <1409834323-7171-6-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
References: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that it's OK to pass in a NULL file_lock double pointer on
a F_UNLCK request and convert the vfs_setlease F_UNLCK callers to
do just that.

Finally, turn the BUG_ON in generic_setlease into a WARN_ON_ONCE
with an error return. That's a problem we can handle without
crashing the box if it occurs.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/locks.c                      | 34 ++++++++++++++--------------------
 fs/nfsd/nfs4state.c             |  2 +-
 include/trace/events/filelock.h | 14 +++++++-------
 3 files changed, 22 insertions(+), 28 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 4031324e6cca..1289b74fffbf 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1637,22 +1637,23 @@ out:
 	return error;
 }
 
-static int generic_delete_lease(struct file *filp, struct file_lock **flp)
+static int generic_delete_lease(struct file *filp)
 {
+	int error = -EAGAIN;
 	struct file_lock *fl, **before;
 	struct dentry *dentry = filp->f_path.dentry;
 	struct inode *inode = dentry->d_inode;
 
-	trace_generic_delete_lease(inode, *flp);
-
 	for (before = &inode->i_flock;
 			((fl = *before) != NULL) && IS_LEASE(fl);
 			before = &fl->fl_next) {
-		if (fl->fl_file != filp)
-			continue;
-		return (*flp)->fl_lmops->lm_change(before, F_UNLCK);
+		if (fl->fl_file == filp)
+			break;
 	}
-	return -EAGAIN;
+	trace_generic_delete_lease(inode, fl);
+	if (fl)
+		error = fl->fl_lmops->lm_change(before, F_UNLCK);
+	return error;
 }
 
 /**
@@ -1682,13 +1683,15 @@ int generic_setlease(struct file *filp, long arg, struct file_lock **flp)
 
 	time_out_leases(inode);
 
-	BUG_ON(!(*flp)->fl_lmops->lm_break);
-
 	switch (arg) {
 	case F_UNLCK:
-		return generic_delete_lease(filp, flp);
+		return generic_delete_lease(filp);
 	case F_RDLCK:
 	case F_WRLCK:
+		if (!(*flp)->fl_lmops->lm_break) {
+			WARN_ON_ONCE(1);
+			return -ENOLCK;
+		}
 		return generic_add_lease(filp, arg, flp);
 	default:
 		return -EINVAL;
@@ -1744,15 +1747,6 @@ int vfs_setlease(struct file *filp, long arg, struct file_lock **lease)
 }
 EXPORT_SYMBOL_GPL(vfs_setlease);
 
-static int do_fcntl_delete_lease(struct file *filp)
-{
-	struct file_lock fl, *flp = &fl;
-
-	lease_init(filp, F_UNLCK, flp);
-
-	return vfs_setlease(filp, F_UNLCK, &flp);
-}
-
 static int do_fcntl_add_lease(unsigned int fd, struct file *filp, long arg)
 {
 	struct file_lock *fl, *ret;
@@ -1809,7 +1803,7 @@ out_unlock:
 int fcntl_setlease(unsigned int fd, struct file *filp, long arg)
 {
 	if (arg == F_UNLCK)
-		return do_fcntl_delete_lease(filp);
+		return vfs_setlease(filp, F_UNLCK, NULL);
 	return do_fcntl_add_lease(fd, filp, arg);
 }
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 29fac18d9102..0cd252916e1a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -683,7 +683,7 @@ static void nfs4_put_deleg_lease(struct nfs4_file *fp)
 	if (!fp->fi_lease)
 		return;
 	if (atomic_dec_and_test(&fp->fi_delegees)) {
-		vfs_setlease(fp->fi_deleg_file, F_UNLCK, &fp->fi_lease);
+		vfs_setlease(fp->fi_deleg_file, F_UNLCK, NULL);
 		fp->fi_lease = NULL;
 		fput(fp->fi_deleg_file);
 		fp->fi_deleg_file = NULL;
diff --git a/include/trace/events/filelock.h b/include/trace/events/filelock.h
index 59d11c22f076..a0d008070962 100644
--- a/include/trace/events/filelock.h
+++ b/include/trace/events/filelock.h
@@ -53,15 +53,15 @@ DECLARE_EVENT_CLASS(filelock_lease,
 	),
 
 	TP_fast_assign(
-		__entry->fl = fl;
+		__entry->fl = fl ? fl : NULL;
 		__entry->s_dev = inode->i_sb->s_dev;
 		__entry->i_ino = inode->i_ino;
-		__entry->fl_next = fl->fl_next;
-		__entry->fl_owner = fl->fl_owner;
-		__entry->fl_flags = fl->fl_flags;
-		__entry->fl_type = fl->fl_type;
-		__entry->fl_break_time = fl->fl_break_time;
-		__entry->fl_downgrade_time = fl->fl_downgrade_time;
+		__entry->fl_next = fl ? fl->fl_next : NULL;
+		__entry->fl_owner = fl ? fl->fl_owner : NULL;
+		__entry->fl_flags = fl ? fl->fl_flags : 0;
+		__entry->fl_type = fl ? fl->fl_type : 0;
+		__entry->fl_break_time = fl ? fl->fl_break_time : 0;
+		__entry->fl_downgrade_time = fl ? fl->fl_downgrade_time : 0;
 	),
 
 	TP_printk("fl=0x%p dev=0x%x:0x%x ino=0x%lx fl_next=0x%p fl_owner=0x%p fl_flags=%s fl_type=%s fl_break_time=%lu fl_downgrade_time=%lu",
-- 
1.9.3

