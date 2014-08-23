Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f179.google.com ([209.85.216.179]:62369 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751477AbaHWOld (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 23 Aug 2014 10:41:33 -0400
Received: by mail-qc0-f179.google.com with SMTP id m20so11975377qcx.38
        for <linux-nfs@vger.kernel.org>; Sat, 23 Aug 2014 07:41:32 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: bfields@fieldses.org, hch@infradead.org, cluster-devel@redhat.com,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [PATCH 03/10] locks: generic_delete_lease doesn't need a file_lock at all
Date: Sat, 23 Aug 2014 10:41:11 -0400
Message-Id: <1408804878-1331-4-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1408804878-1331-1-git-send-email-jlayton@primarydata.com>
References: <1408804878-1331-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that it's OK to pass in a NULL file_lock double pointer on
a F_UNLCK request and convert the vfs_setlease F_UNLCK callers to
do just that.

Finally, turn the BUG_ON in generic_setlease into a WARN_ON_ONCE
with an error return. That's a problem we can handle without
crashing the box if it occurs.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/locks.c          | 25 ++++++++-----------------
 fs/nfsd/nfs4state.c |  2 +-
 2 files changed, 9 insertions(+), 18 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 58ce8897f2e4..bedb817a5cc4 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1637,20 +1637,18 @@ out:
 	return error;
 }
 
-static int generic_delete_lease(struct file *filp, struct file_lock **flp)
+static int generic_delete_lease(struct file *filp)
 {
 	struct file_lock *fl, **before;
 	struct dentry *dentry = filp->f_path.dentry;
 	struct inode *inode = dentry->d_inode;
 
-	trace_generic_delete_lease(inode, *flp);
-
 	for (before = &inode->i_flock;
 			((fl = *before) != NULL) && IS_LEASE(fl);
 			before = &fl->fl_next) {
 		if (fl->fl_file != filp)
 			continue;
-		return (*flp)->fl_lmops->lm_change(before, F_UNLCK);
+		return fl->fl_lmops->lm_change(before, F_UNLCK);
 	}
 	return -EAGAIN;
 }
@@ -1682,13 +1680,15 @@ int generic_setlease(struct file *filp, long arg, struct file_lock **flp)
 
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
@@ -1744,15 +1744,6 @@ int vfs_setlease(struct file *filp, long arg, struct file_lock **lease)
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
@@ -1809,7 +1800,7 @@ out_unlock:
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
-- 
1.9.3

