Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cdptpa-outbound-snat.email.rr.com ([107.14.166.231]:21652 "EHLO
	cdptpa-oedge-vip.email.rr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754001AbbAVObc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jan 2015 09:31:32 -0500
From: Jeff Layton <jeff.layton@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        Sasha Levin <sasha.levin@oracle.com>,
        David Howells <dhowells@redhat.com>, linux-kernel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        ceph-devel@vger.kernel.org
Subject: [PATCH v3 10/13] locks: clean up the lm_change prototype
Date: Thu, 22 Jan 2015 09:27:54 -0500
Message-Id: <1421936877-27529-11-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1421936877-27529-1-git-send-email-jeff.layton@primarydata.com>
References: <1421936877-27529-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@primarydata.com>

Now that we use standard list_heads for tracking leases, we can have
lm_change take a pointer to the lease to be modified instead of a
double pointer.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
Acked-by: Christoph Hellwig <hch@lst.de>
---
 fs/locks.c          | 13 ++++++-------
 fs/nfsd/nfs4state.c |  3 ++-
 include/linux/fs.h  |  6 +++---
 3 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index a268d959ccd6..864f2460a0ad 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1309,9 +1309,8 @@ static void lease_clear_pending(struct file_lock *fl, int arg)
 }
 
 /* We already had a lease on this file; just change its type */
-int lease_modify(struct file_lock **before, int arg, struct list_head *dispose)
+int lease_modify(struct file_lock *fl, int arg, struct list_head *dispose)
 {
-	struct file_lock *fl = *before;
 	int error = assign_type(fl, arg);
 
 	if (error)
@@ -1352,9 +1351,9 @@ static void time_out_leases(struct inode *inode, struct list_head *dispose)
 	list_for_each_entry_safe(fl, tmp, &ctx->flc_lease, fl_list) {
 		trace_time_out_leases(inode, fl);
 		if (past_time(fl->fl_downgrade_time))
-			lease_modify(&fl, F_RDLCK, dispose);
+			lease_modify(fl, F_RDLCK, dispose);
 		if (past_time(fl->fl_break_time))
-			lease_modify(&fl, F_UNLCK, dispose);
+			lease_modify(fl, F_UNLCK, dispose);
 	}
 }
 
@@ -1669,7 +1668,7 @@ generic_add_lease(struct file *filp, long arg, struct file_lock **flp, void **pr
 	}
 
 	if (my_fl != NULL) {
-		error = lease->fl_lmops->lm_change(&my_fl, arg, &dispose);
+		error = lease->fl_lmops->lm_change(my_fl, arg, &dispose);
 		if (error)
 			goto out;
 		goto out_setup;
@@ -1732,7 +1731,7 @@ static int generic_delete_lease(struct file *filp)
 	}
 	trace_generic_delete_lease(inode, fl);
 	if (victim)
-		error = fl->fl_lmops->lm_change(&victim, F_UNLCK, &dispose);
+		error = fl->fl_lmops->lm_change(victim, F_UNLCK, &dispose);
 	spin_unlock(&ctx->flc_lock);
 	locks_dispose_list(&dispose);
 	return error;
@@ -2426,7 +2425,7 @@ locks_remove_lease(struct file *filp)
 
 	spin_lock(&ctx->flc_lock);
 	list_for_each_entry_safe(fl, tmp, &ctx->flc_lease, fl_list)
-		lease_modify(&fl, F_UNLCK, &dispose);
+		lease_modify(fl, F_UNLCK, &dispose);
 	spin_unlock(&ctx->flc_lock);
 	locks_dispose_list(&dispose);
 }
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 80242f5bd621..532a60cca2fb 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3477,7 +3477,8 @@ nfsd_break_deleg_cb(struct file_lock *fl)
 }
 
 static int
-nfsd_change_deleg_cb(struct file_lock **onlist, int arg, struct list_head *dispose)
+nfsd_change_deleg_cb(struct file_lock *onlist, int arg,
+		     struct list_head *dispose)
 {
 	if (arg & F_UNLCK)
 		return lease_modify(onlist, arg, dispose);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 32eafa9b5c9f..94e706a0a408 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -900,7 +900,7 @@ struct lock_manager_operations {
 	void (*lm_notify)(struct file_lock *);	/* unblock callback */
 	int (*lm_grant)(struct file_lock *, int);
 	bool (*lm_break)(struct file_lock *);
-	int (*lm_change)(struct file_lock **, int, struct list_head *);
+	int (*lm_change)(struct file_lock *, int, struct list_head *);
 	void (*lm_setup)(struct file_lock *, void **);
 };
 
@@ -1021,7 +1021,7 @@ extern int __break_lease(struct inode *inode, unsigned int flags, unsigned int t
 extern void lease_get_mtime(struct inode *, struct timespec *time);
 extern int generic_setlease(struct file *, long, struct file_lock **, void **priv);
 extern int vfs_setlease(struct file *, long, struct file_lock **, void **);
-extern int lease_modify(struct file_lock **, int, struct list_head *);
+extern int lease_modify(struct file_lock *, int, struct list_head *);
 #else /* !CONFIG_FILE_LOCKING */
 static inline int fcntl_getlk(struct file *file, unsigned int cmd,
 			      struct flock __user *user)
@@ -1153,7 +1153,7 @@ static inline int vfs_setlease(struct file *filp, long arg,
 	return -EINVAL;
 }
 
-static inline int lease_modify(struct file_lock **before, int arg,
+static inline int lease_modify(struct file_lock *fl, int arg,
 			       struct list_head *dispose)
 {
 	return -EINVAL;
-- 
2.1.0

