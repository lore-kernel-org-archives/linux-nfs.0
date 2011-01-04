Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52658 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751155Ab1ADDHD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Jan 2011 22:07:03 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/4] locks: eliminate fl_mylease callback
Date: Mon,  3 Jan 2011 22:06:58 -0500
Message-Id: <1294110419-3105-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1294110419-3105-1-git-send-email-bfields@redhat.com>
References: <1294110419-3105-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The nfs server only supports read delegations for now, so we don't care
how conflicts are determined.  All we care is that unlocks are
recognized as matching the leases they are meant to remove.  After the
last patch, a comparison of struct files will work for that purpose.  So
we no longer need this callback.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/locks.c          |    8 +-------
 fs/nfsd/nfs4state.c |   21 +--------------------
 include/linux/fs.h  |    1 -
 3 files changed, 2 insertions(+), 28 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 8729347..5cb6506 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -444,15 +444,9 @@ static void lease_release_private_callback(struct file_lock *fl)
 	fl->fl_file->f_owner.signum = 0;
 }
 
-static int lease_mylease_callback(struct file_lock *fl, struct file_lock *try)
-{
-	return fl->fl_file == try->fl_file;
-}
-
 static const struct lock_manager_operations lease_manager_ops = {
 	.fl_break = lease_break_callback,
 	.fl_release_private = lease_release_private_callback,
-	.fl_mylease = lease_mylease_callback,
 	.fl_change = lease_modify,
 };
 
@@ -1405,7 +1399,7 @@ int generic_setlease(struct file *filp, long arg, struct file_lock **flp)
 	for (before = &inode->i_flock;
 			((fl = *before) != NULL) && IS_LEASE(fl);
 			before = &fl->fl_next) {
-		if (lease->fl_lmops->fl_mylease(fl, lease))
+		if (fl->fl_file == lease->fl_file)
 			my_before = before;
 		else if (fl->fl_type == (F_INPROGRESS | F_UNLCK))
 			/*
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index cbe1b81..87d4c48 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2295,24 +2295,6 @@ void nfsd_break_deleg_cb(struct file_lock *fl)
 	nfsd4_cb_recall(dp);
 }
 
-/*
- * Called from setlease() with lock_flocks() held
- */
-static
-int nfsd_same_client_deleg_cb(struct file_lock *onlist, struct file_lock *try)
-{
-	struct nfs4_delegation *onlistd =
-		(struct nfs4_delegation *)onlist->fl_owner;
-	struct nfs4_delegation *tryd =
-		(struct nfs4_delegation *)try->fl_owner;
-
-	if (onlist->fl_lmops != try->fl_lmops)
-		return 0;
-
-	return onlistd->dl_client == tryd->dl_client;
-}
-
-
 static
 int nfsd_change_deleg_cb(struct file_lock **onlist, int arg)
 {
@@ -2324,7 +2306,6 @@ int nfsd_change_deleg_cb(struct file_lock **onlist, int arg)
 
 static const struct lock_manager_operations nfsd_lease_mng_ops = {
 	.fl_break = nfsd_break_deleg_cb,
-	.fl_mylease = nfsd_same_client_deleg_cb,
 	.fl_change = nfsd_change_deleg_cb,
 };
 
@@ -2630,7 +2611,7 @@ nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open, struct nfs4_sta
 	dp->dl_flock = fl;
 
 	/* vfs_setlease checks to see if delegation should be handed out.
-	 * the lock_manager callbacks fl_mylease and fl_change are used
+	 * the lock_manager callback fl_change is used
 	 */
 	if ((status = vfs_setlease(fl->fl_file, fl->fl_type, &fl))) {
 		dprintk("NFSD: setlease failed [%d], no delegation\n", status);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 090f0ea..73ce69f 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1059,7 +1059,6 @@ struct lock_manager_operations {
 	int (*fl_grant)(struct file_lock *, struct file_lock *, int);
 	void (*fl_release_private)(struct file_lock *);
 	void (*fl_break)(struct file_lock *);
-	int (*fl_mylease)(struct file_lock *, struct file_lock *);
 	int (*fl_change)(struct file_lock **, int);
 };
 
-- 
1.7.1

