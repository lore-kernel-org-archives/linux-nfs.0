Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([83.163.148.79]:46139 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754944Ab1G1Sok (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Jul 2011 14:44:40 -0400
From: Frank van Maarseveen <frankvm@frankvm.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] Support a per-mount NLM grace period.
Date: Thu, 28 Jul 2011 20:44:20 +0200
Message-Id: <1311878660-24482-3-git-send-email-frankvm@frankvm.com>
In-Reply-To: <1311878660-24482-1-git-send-email-frankvm@frankvm.com>
References: <1311878660-24482-1-git-send-email-frankvm@frankvm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This implements /proc/fs/nfsd/relock_filesystem, complementing
/proc/fs/nfsd/unlock_filesystem using an identical syntax. When
a mountpoint pathname is written to the first then an NLM
grace period will start for files referring to its super block.

Signed-off-by: Frank van Maarseveen <frankvm@frankvm.com>
---
 fs/lockd/grace.c    |   86 +++++++++++++++++++++++++++++++++++++++++++++++++--
 fs/lockd/svc.c      |    1 +
 fs/lockd/svclock.c  |    8 ++--
 fs/lockd/svcshare.c |    4 +-
 fs/nfsd/nfs4proc.c  |   12 ++++---
 fs/nfsd/nfs4state.c |   14 ++++----
 fs/nfsd/nfsctl.c    |   26 +++++++++++++--
 include/linux/fs.h  |    4 ++-
 8 files changed, 130 insertions(+), 25 deletions(-)

diff --git a/fs/lockd/grace.c b/fs/lockd/grace.c
index 183cc1f..6ddb806 100644
--- a/fs/lockd/grace.c
+++ b/fs/lockd/grace.c
@@ -4,8 +4,18 @@
 
 #include <linux/module.h>
 #include <linux/lockd/bind.h>
+#include <linux/lockd/lockd.h>
+#include <linux/mount.h>
+#include <linux/slab.h>
+
+struct sb_in_grace {
+	struct list_head	sbg_link;
+	struct vfsmount		*sbg_mnt;
+	u64			sbg_timeout;
+};
 
 static LIST_HEAD(grace_list);
+static LIST_HEAD(sb_grace_list);
 static DEFINE_SPINLOCK(grace_lock);
 
 /**
@@ -46,14 +56,84 @@ void locks_end_grace(struct lock_manager *lm)
 EXPORT_SYMBOL_GPL(locks_end_grace);
 
 /**
+ * locks_start_sb_grace
+ * @path: reference to superblock of FS to enter grace.
+ *
+ * This function is a filesystem specific version of locks_start_grace()
+ */
+int locks_start_sb_grace(struct path *path)
+{
+	struct sb_in_grace *sbg;
+
+	sbg = kzalloc(sizeof(*sbg), GFP_KERNEL);
+	if (!sbg)
+		return -ENOMEM;
+	mntget(path->mnt);
+	sbg->sbg_mnt = path->mnt;
+	sbg->sbg_timeout = get_jiffies_64() + nlmsvc_grace_period();
+	spin_lock(&grace_lock);
+	list_add_tail(&sbg->sbg_link, &sb_grace_list);
+	spin_unlock(&grace_lock);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(locks_start_sb_grace);
+
+/**
+ * locks_end_sb_grace
+ * @path: reference to superblock of FS to leave grace.
+ *
+ * This function is a filesystem specific version of locks_end_grace()
+ * When @path is NULL then all filesystem specific grace periods end.
+ */
+void locks_end_sb_grace(struct path *path)
+{
+	struct sb_in_grace *sbg, *next;
+	struct super_block *sb = path ? path->mnt->mnt_sb : NULL;
+
+	spin_lock(&grace_lock);
+	list_for_each_entry_safe(sbg, next, &sb_grace_list, sbg_link) {
+		if (!sb || sb == sbg->sbg_mnt->mnt_sb) {
+			list_del(&sbg->sbg_link);
+			mntput(sbg->sbg_mnt);
+			kfree(sbg);
+		}
+	}
+	spin_unlock(&grace_lock);
+}
+EXPORT_SYMBOL_GPL(locks_end_sb_grace);
+
+/**
  * locks_in_grace
+ * @sb: super block for checking filesystem specific grace time.
  *
  * Lock managers call this function to determine when it is OK for them
  * to answer ordinary lock requests, and when they should accept only
- * lock reclaims.
+ * lock reclaims. @sb can be NULL to test for a global grace period.
  */
-int locks_in_grace(void)
+int locks_in_grace(struct super_block *sb)
 {
-	return !list_empty(&grace_list);
+	struct sb_in_grace *sbg, *next;
+	int in_grace;
+	u64 now;
+
+	if (!list_empty(&grace_list))
+		return true;
+	in_grace = false;
+	now = get_jiffies_64();
+	spin_lock(&grace_lock);
+	list_for_each_entry_safe(sbg, next, &sb_grace_list, sbg_link) {
+		if (time_after64(now, sbg->sbg_timeout)) {
+			list_del(&sbg->sbg_link);
+			mntput(sbg->sbg_mnt);
+			kfree(sbg);
+			continue;
+		}
+		if (sb == sbg->sbg_mnt->mnt_sb) {
+			in_grace = true;
+			break;
+		}
+	}
+	spin_unlock(&grace_lock);
+	return in_grace;
 }
 EXPORT_SYMBOL_GPL(locks_in_grace);
diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 0efbbfc..9c53971 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -186,6 +186,7 @@ lockd(void *vrqstp)
 	flush_signals(current);
 	cancel_delayed_work_sync(&grace_period_end);
 	locks_end_grace(&lockd_manager);
+	locks_end_sb_grace(NULL);
 	if (nlmsvc_ops)
 		nlmsvc_invalidate_all();
 	nlm_shutdown_hosts();
diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index ab62c57..95c85d7 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -419,11 +419,11 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
 		goto out;
 	}
 
-	if (locks_in_grace() && !reclaim) {
+	if (locks_in_grace(file->f_file->f_path.dentry->d_sb) && !reclaim) {
 		ret = nlm_lck_denied_grace_period;
 		goto out;
 	}
-	if (reclaim && !locks_in_grace()) {
+	if (reclaim && !locks_in_grace(file->f_file->f_path.dentry->d_sb)) {
 		ret = nlm_lck_denied_grace_period;
 		goto out;
 	}
@@ -531,7 +531,7 @@ nlmsvc_testlock(struct svc_rqst *rqstp, struct nlm_file *file,
 		goto out;
 	}
 
-	if (locks_in_grace()) {
+	if (locks_in_grace(file->f_file->f_path.dentry->d_sb)) {
 		ret = nlm_lck_denied_grace_period;
 		goto out;
 	}
@@ -617,7 +617,7 @@ nlmsvc_cancel_blocked(struct nlm_file *file, struct nlm_lock *lock)
 				(long long)lock->fl.fl_start,
 				(long long)lock->fl.fl_end);
 
-	if (locks_in_grace())
+	if (locks_in_grace(file->f_file->f_path.dentry->d_sb))
 		return nlm_lck_denied_grace_period;
 
 	mutex_lock(&file->f_mutex);
diff --git a/fs/lockd/svcshare.c b/fs/lockd/svcshare.c
index ccad267..10c7415 100644
--- a/fs/lockd/svcshare.c
+++ b/fs/lockd/svcshare.c
@@ -32,7 +32,7 @@ nlmsvc_share_file(struct nlm_host *host, struct nlm_file *file,
 	u8			*ohdata;
 
 	/* Don't accept new share requests during grace period */
-	if (locks_in_grace() && !argp->reclaim)
+	if (locks_in_grace(file->f_file->f_path.dentry->d_sb) && !argp->reclaim)
 		return nlm_lck_denied_grace_period;
 
 	for (share = file->f_shares; share; share = share->s_next) {
@@ -76,7 +76,7 @@ nlmsvc_unshare_file(struct nlm_host *host, struct nlm_file *file,
 	struct xdr_netobj	*oh = &argp->lock.oh;
 
 	/* Don't accept unshare requests during grace period */
-	if (locks_in_grace())
+	if (locks_in_grace(file->f_file->f_path.dentry->d_sb))
 		return nlm_lck_denied_grace_period;
 
 	for (shpp = &file->f_shares; (share = *shpp) != NULL;
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index e248b9e..fa325df 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -330,10 +330,12 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	/* Openowner is now set, so sequence id will get bumped.  Now we need
 	 * these checks before we do any creates: */
 	status = nfserr_grace;
-	if (locks_in_grace() && open->op_claim_type != NFS4_OPEN_CLAIM_PREVIOUS)
+	if (locks_in_grace(cstate->current_fh.fh_dentry->d_sb)
+		&& open->op_claim_type != NFS4_OPEN_CLAIM_PREVIOUS)
 		goto out;
 	status = nfserr_no_grace;
-	if (open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS && !locks_in_grace())
+	if (open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS
+		&& !locks_in_grace(cstate->current_fh.fh_dentry->d_sb))
 		goto out;
 
 	switch (open->op_claim_type) {
@@ -715,7 +717,7 @@ nfsd4_remove(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 {
 	__be32 status;
 
-	if (locks_in_grace())
+	if (locks_in_grace(cstate->current_fh.fh_dentry->d_sb))
 		return nfserr_grace;
 	status = nfsd_unlink(rqstp, &cstate->current_fh, 0,
 			     remove->rm_name, remove->rm_namelen);
@@ -736,8 +738,8 @@ nfsd4_rename(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	if (!cstate->save_fh.fh_dentry)
 		return status;
-	if (locks_in_grace() && !(cstate->save_fh.fh_export->ex_flags
-					& NFSEXP_NOSUBTREECHECK))
+	if (locks_in_grace(cstate->save_fh.fh_dentry->d_sb)
+		&& !(cstate->save_fh.fh_export->ex_flags & NFSEXP_NOSUBTREECHECK))
 		return nfserr_grace;
 	status = nfsd_rename(rqstp, &cstate->save_fh, rename->rn_sname,
 			     rename->rn_snamelen, &cstate->current_fh,
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 741e03a..5f3f3cc 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2779,7 +2779,7 @@ nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open, struct nfs4_sta
 		case NFS4_OPEN_CLAIM_NULL:
 			/* Let's not give out any delegations till everyone's
 			 * had the chance to reclaim theirs.... */
-			if (locks_in_grace())
+			if (locks_in_grace(fh->fh_dentry->d_sb))
 				goto out;
 			if (!cb_up || !sop->so_confirmed)
 				goto out;
@@ -2972,7 +2972,7 @@ nfs4_laundromat(void)
 	nfs4_lock_state();
 
 	dprintk("NFSD: laundromat service - starting\n");
-	if (locks_in_grace())
+	if (locks_in_grace(NULL))
 		nfsd4_end_grace();
 	INIT_LIST_HEAD(&reaplist);
 	spin_lock(&client_lock);
@@ -3117,7 +3117,7 @@ check_special_stateids(svc_fh *current_fh, stateid_t *stateid, int flags)
 {
 	if (ONE_STATEID(stateid) && (flags & RD_STATE))
 		return nfs_ok;
-	else if (locks_in_grace()) {
+	else if (locks_in_grace(current_fh->fh_dentry->d_sb)) {
 		/* Answer in remaining cases depends on existence of
 		 * conflicting state; so we must wait out the grace period. */
 		return nfserr_grace;
@@ -3136,7 +3136,7 @@ check_special_stateids(svc_fh *current_fh, stateid_t *stateid, int flags)
 static inline int
 grace_disallows_io(struct inode *inode)
 {
-	return locks_in_grace() && mandatory_lock(inode);
+	return locks_in_grace(inode->i_sb) && mandatory_lock(inode);
 }
 
 static int check_stateid_generation(stateid_t *in, stateid_t *ref, int flags)
@@ -4058,10 +4058,10 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	/* lock->lk_replay_owner and lock_stp have been created or found */
 
 	status = nfserr_grace;
-	if (locks_in_grace() && !lock->lk_reclaim)
+	if (locks_in_grace(cstate->current_fh.fh_dentry->d_sb) && !lock->lk_reclaim)
 		goto out;
 	status = nfserr_no_grace;
-	if (lock->lk_reclaim && !locks_in_grace())
+	if (lock->lk_reclaim && !locks_in_grace(cstate->current_fh.fh_dentry->d_sb))
 		goto out;
 
 	locks_init_lock(&file_lock);
@@ -4166,7 +4166,7 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	int error;
 	__be32 status;
 
-	if (locks_in_grace())
+	if (locks_in_grace(cstate->current_fh.fh_dentry->d_sb))
 		return nfserr_grace;
 
 	if (check_lock_length(lockt->lt_offset, lockt->lt_length))
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index c771614..af992ef 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -29,6 +29,7 @@ enum {
 	NFSD_Fh,
 	NFSD_FO_UnlockIP,
 	NFSD_FO_UnlockFS,
+	NFSD_FO_RelockFS,
 	NFSD_Threads,
 	NFSD_Pool_Threads,
 	NFSD_Pool_Stats,
@@ -53,6 +54,7 @@ enum {
 static ssize_t write_filehandle(struct file *file, char *buf, size_t size);
 static ssize_t write_unlock_ip(struct file *file, char *buf, size_t size);
 static ssize_t write_unlock_fs(struct file *file, char *buf, size_t size);
+static ssize_t write_relock_fs(struct file *file, char *buf, size_t size);
 static ssize_t write_threads(struct file *file, char *buf, size_t size);
 static ssize_t write_pool_threads(struct file *file, char *buf, size_t size);
 static ssize_t write_versions(struct file *file, char *buf, size_t size);
@@ -68,6 +70,7 @@ static ssize_t (*write_op[])(struct file *, char *, size_t) = {
 	[NFSD_Fh] = write_filehandle,
 	[NFSD_FO_UnlockIP] = write_unlock_ip,
 	[NFSD_FO_UnlockFS] = write_unlock_fs,
+	[NFSD_FO_RelockFS] = write_relock_fs,
 	[NFSD_Threads] = write_threads,
 	[NFSD_Pool_Threads] = write_pool_threads,
 	[NFSD_Versions] = write_versions,
@@ -229,7 +232,7 @@ static ssize_t write_unlock_ip(struct file *file, char *buf, size_t size)
 }
 
 /**
- * write_unlock_fs - Release all locks on a local file system
+ * start_stop_fs_locking - Drop all locks or enter grace period for a FS
  *
  * Experimental.
  *
@@ -242,7 +245,7 @@ static ssize_t write_unlock_ip(struct file *file, char *buf, size_t size)
  *			returns one if one or more locks were not released
  *	On error:	return code is negative errno value
  */
-static ssize_t write_unlock_fs(struct file *file, char *buf, size_t size)
+static ssize_t start_stop_fs_locking(struct file *file, char *buf, size_t size, int start)
 {
 	struct path path;
 	char *fo_path;
@@ -272,12 +275,27 @@ static ssize_t write_unlock_fs(struct file *file, char *buf, size_t size)
 	 * 2.  Is that directory a mount point, or
 	 * 3.  Is that directory the root of an exported file system?
 	 */
-	error = nlmsvc_unlock_all_by_sb(path.mnt->mnt_sb);
+	if (start)
+		error = locks_start_sb_grace(&path);
+	else {
+		locks_end_sb_grace(&path);	// drop sb reference
+		error = nlmsvc_unlock_all_by_sb(path.mnt->mnt_sb);
+	}
 
 	path_put(&path);
 	return error;
 }
 
+static ssize_t write_unlock_fs(struct file *file, char *buf, size_t size)
+{
+	return start_stop_fs_locking(file, buf, size, false);
+}
+
+static ssize_t write_relock_fs(struct file *file, char *buf, size_t size)
+{
+	return start_stop_fs_locking(file, buf, size, true);
+}
+
 /**
  * write_filehandle - Get a variable-length NFS file handle by path
  *
@@ -1070,6 +1088,8 @@ static int nfsd_fill_super(struct super_block * sb, void * data, int silent)
 					&transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_FO_UnlockFS] = {"unlock_filesystem",
 					&transaction_ops, S_IWUSR|S_IRUSR},
+		[NFSD_FO_RelockFS] = {"relock_filesystem",
+					&transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Fh] = {"filehandle", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Threads] = {"threads", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Pool_Threads] = {"pool_threads", &transaction_ops, S_IWUSR|S_IRUSR},
diff --git a/include/linux/fs.h b/include/linux/fs.h
index f23bcb7..752f6b8 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1086,7 +1086,9 @@ struct lock_manager {
 
 void locks_start_grace(struct lock_manager *);
 void locks_end_grace(struct lock_manager *);
-int locks_in_grace(void);
+int locks_start_sb_grace(struct path *);
+void locks_end_sb_grace(struct path *);
+int locks_in_grace(struct super_block *);
 
 /* that will die - we need it for nfs_lock_info */
 #include <linux/nfs_fs_i.h>
-- 
1.7.4.4

