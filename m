Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f171.google.com ([209.85.216.171]:60193 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752825AbaIDMjM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2014 08:39:12 -0400
Received: by mail-qc0-f171.google.com with SMTP id x3so10152490qcv.2
        for <linux-nfs@vger.kernel.org>; Thu, 04 Sep 2014 05:39:12 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org
Subject: [PATCH v2 10/17] locks: move i_lock acquisition into generic_*_lease handlers
Date: Thu,  4 Sep 2014 08:38:36 -0400
Message-Id: <1409834323-7171-11-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
References: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that we have a saner internal API for managing leases, we no longer
need to mandate that the inode->i_lock be held over most of the lease
code. Push it down into generic_add_lease and generic_delete_lease.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/locks.c | 21 +++++++++------------
 1 file changed, 9 insertions(+), 12 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index a5ed4a1f73ca..5bc61091263f 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1330,6 +1330,8 @@ static void time_out_leases(struct inode *inode)
 	struct file_lock **before;
 	struct file_lock *fl;
 
+	lockdep_assert_held(&inode->i_lock);
+
 	before = &inode->i_flock;
 	while ((fl = *before) && IS_LEASE(fl) && lease_breaking(fl)) {
 		trace_time_out_leases(inode, fl);
@@ -1590,6 +1592,8 @@ generic_add_lease(struct file *filp, long arg, struct file_lock **flp, void **pr
 		return -EINVAL;
 	}
 
+	spin_lock(&inode->i_lock);
+	time_out_leases(inode);
 	error = check_conflicting_open(dentry, arg);
 	if (error)
 		goto out;
@@ -1655,6 +1659,7 @@ out_setup:
 	if (lease->fl_lmops->lm_setup)
 		lease->fl_lmops->lm_setup(lease, priv);
 out:
+	spin_unlock(&inode->i_lock);
 	if (is_deleg)
 		mutex_unlock(&inode->i_mutex);
 	if (!error && !my_before)
@@ -1672,6 +1677,7 @@ static int generic_delete_lease(struct file *filp)
 	struct dentry *dentry = filp->f_path.dentry;
 	struct inode *inode = dentry->d_inode;
 
+	spin_lock(&inode->i_lock);
 	for (before = &inode->i_flock;
 			((fl = *before) != NULL) && IS_LEASE(fl);
 			before = &fl->fl_next) {
@@ -1681,6 +1687,7 @@ static int generic_delete_lease(struct file *filp)
 	trace_generic_delete_lease(inode, fl);
 	if (fl)
 		error = fl->fl_lmops->lm_change(before, F_UNLCK);
+	spin_unlock(&inode->i_lock);
 	return error;
 }
 
@@ -1694,8 +1701,6 @@ static int generic_delete_lease(struct file *filp)
  *
  *	The (input) flp->fl_lmops->lm_break function is required
  *	by break_lease().
- *
- *	Called with inode->i_lock held.
  */
 int generic_setlease(struct file *filp, long arg, struct file_lock **flp,
 			void **priv)
@@ -1712,8 +1717,6 @@ int generic_setlease(struct file *filp, long arg, struct file_lock **flp,
 	if (error)
 		return error;
 
-	time_out_leases(inode);
-
 	switch (arg) {
 	case F_UNLCK:
 		return generic_delete_lease(filp);
@@ -1750,16 +1753,10 @@ EXPORT_SYMBOL(generic_setlease);
 int
 vfs_setlease(struct file *filp, long arg, struct file_lock **lease, void **priv)
 {
-	struct inode *inode = file_inode(filp);
-	int error;
-
-	spin_lock(&inode->i_lock);
 	if (filp->f_op->setlease)
-		error = filp->f_op->setlease(filp, arg, lease, priv);
+		return filp->f_op->setlease(filp, arg, lease, priv);
 	else
-		error = generic_setlease(filp, arg, lease, priv);
-	spin_unlock(&inode->i_lock);
-	return error;
+		return generic_setlease(filp, arg, lease, priv);
 }
 EXPORT_SYMBOL_GPL(vfs_setlease);
 
-- 
1.9.3

