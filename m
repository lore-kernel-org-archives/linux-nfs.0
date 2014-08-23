Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f49.google.com ([209.85.216.49]:37798 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751758AbaHWOlk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 23 Aug 2014 10:41:40 -0400
Received: by mail-qa0-f49.google.com with SMTP id dc16so10756265qab.22
        for <linux-nfs@vger.kernel.org>; Sat, 23 Aug 2014 07:41:39 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: bfields@fieldses.org, hch@infradead.org, cluster-devel@redhat.com,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [PATCH 08/10] locks: move i_lock acquisition into generic_*_lease handlers
Date: Sat, 23 Aug 2014 10:41:16 -0400
Message-Id: <1408804878-1331-9-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1408804878-1331-1-git-send-email-jlayton@primarydata.com>
References: <1408804878-1331-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that we have a saner internal API for managing leases, we no longer
need to mandate that the inode->i_lock be held over most of the lease
code. Push it down into generic_add_lease and generic_delete_lease.

With this change ->setlease calls can now block, which is a necessary
(but not sufficient!) step toward allowing leases to work with
distributed filesystems.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/locks.c | 29 +++++++++++++++--------------
 1 file changed, 15 insertions(+), 14 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index b35b706c05fe..49210d5cbf41 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1335,6 +1335,8 @@ static void time_out_leases(struct inode *inode)
 	struct file_lock **before;
 	struct file_lock *fl;
 
+	lockdep_assert_held(&inode->i_lock);
+
 	before = &inode->i_flock;
 	while ((fl = *before) && IS_LEASE(fl) && lease_breaking(fl)) {
 		trace_time_out_leases(inode, fl);
@@ -1595,6 +1597,9 @@ generic_add_lease(struct file *filp, long arg, struct file_lock **flp, void **au
 		return -EINVAL;
 	}
 
+	spin_lock(&inode->i_lock);
+	time_out_leases(inode);
+
 	error = check_conflicting_open(dentry, arg);
 	if (error)
 		goto out;
@@ -1660,6 +1665,7 @@ out_setup:
 	if (lease->fl_lmops->lm_setup)
 		lease->fl_lmops->lm_setup(lease, aux);
 out:
+	spin_unlock(&inode->i_lock);
 	if (is_deleg)
 		mutex_unlock(&inode->i_mutex);
 	if (!error && !my_before)
@@ -1672,18 +1678,22 @@ out_unlink:
 
 static int generic_delete_lease(struct file *filp)
 {
+	int error = -EAGAIN;
 	struct file_lock *fl, **before;
 	struct dentry *dentry = filp->f_path.dentry;
 	struct inode *inode = dentry->d_inode;
 
+	spin_lock(&inode->i_lock);
+	time_out_leases(inode);
 	for (before = &inode->i_flock;
 			((fl = *before) != NULL) && IS_LEASE(fl);
 			before = &fl->fl_next) {
 		if (fl->fl_file != filp)
 			continue;
-		return fl->fl_lmops->lm_change(before, F_UNLCK);
+		error = fl->fl_lmops->lm_change(before, F_UNLCK);
 	}
-	return -EAGAIN;
+	spin_unlock(&inode->i_lock);
+	return error;
 }
 
 /**
@@ -1702,8 +1712,7 @@ static int generic_delete_lease(struct file *filp)
 int generic_setlease(struct file *filp, long arg, struct file_lock **flp,
 			void **aux)
 {
-	struct dentry *dentry = filp->f_path.dentry;
-	struct inode *inode = dentry->d_inode;
+	struct inode *inode = file_inode(filp);
 	int error;
 
 	if ((!uid_eq(current_fsuid(), inode->i_uid)) && !capable(CAP_LEASE))
@@ -1714,8 +1723,6 @@ int generic_setlease(struct file *filp, long arg, struct file_lock **flp,
 	if (error)
 		return error;
 
-	time_out_leases(inode);
-
 	switch (arg) {
 	case F_UNLCK:
 		return generic_delete_lease(filp);
@@ -1759,16 +1766,10 @@ EXPORT_SYMBOL(generic_setlease);
 int
 vfs_setlease(struct file *filp, long arg, struct file_lock **lease, void **aux)
 {
-	struct inode *inode = file_inode(filp);
-	int error;
-
-	spin_lock(&inode->i_lock);
 	if (filp->f_op->setlease)
-		error = filp->f_op->setlease(filp, arg, lease, aux);
+		return filp->f_op->setlease(filp, arg, lease, aux);
 	else
-		error = generic_setlease(filp, arg, lease, aux);
-	spin_unlock(&inode->i_lock);
-	return error;
+		return generic_setlease(filp, arg, lease, aux);
 }
 EXPORT_SYMBOL_GPL(vfs_setlease);
 
-- 
1.9.3

