Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:48249 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754461Ab2DCMOo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Apr 2012 08:14:44 -0400
Received: by yenl12 with SMTP id l12so1675978yen.19
        for <linux-nfs@vger.kernel.org>; Tue, 03 Apr 2012 05:14:43 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH][RFC] nfsd/lockd: have locks_in_grace take a sb arg
Date: Tue,  3 Apr 2012 08:14:39 -0400
Message-Id: <1333455279-11200-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The main reason for the grace period is to prevent the server from
allowing an operation that might otherwise be denied once the client has
reclaimed all of its stateful objects.

Currently, the grace period handling in the nfsd/lockd server code is
very simple. When the lock managers start, they stick an entry on a list
and set a timer. When the timers pop, then they remove the entry from
the list. The locks_in_grace check just looks to see if the list is
empty. If it is, then the grace period is considered to be over.

This is insufficient for a clustered filesystem that is being served
from multiple nodes at the same time. In such a configuration, the grace
period must be coordinated in some fashion, or else one node might hand
out stateful objects that conflict with those that have not yet been
reclaimed.

This patch paves the way for fixing this by adding a new export
operation called locks_in_grace that takes a superblock argument. The
existing locks_in_grace function is renamed to generic_locks_in_grace,
and a new locks_in_grace function that takes a superblock arg is added.
If a filesystem does not have a locks_in_grace export operation then the
generic version will be used.

Care has also been taken to reorder calls such that locks_in_grace is
called last in compound conditional statements. Handling this for
clustered filesystems may involve upcalls, so we don't want to call it
unnecessarily.

For now, this patch is just an RFC as I do not yet have any code that
overrides this function and am still specing out what that code should
look like.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/lockd/grace.c         |   23 +++++++++++++++++++++--
 fs/lockd/svc4proc.c      |   43 +++++++++++++++++++++----------------------
 fs/lockd/svclock.c       |    8 ++++----
 fs/lockd/svcproc.c       |   44 ++++++++++++++++++++++----------------------
 fs/nfsd/nfs4proc.c       |   12 +++++++-----
 fs/nfsd/nfs4state.c      |   32 ++++++++++++++++++--------------
 include/linux/exportfs.h |    6 ++++++
 include/linux/fs.h       |    3 ++-
 8 files changed, 101 insertions(+), 70 deletions(-)

diff --git a/fs/lockd/grace.c b/fs/lockd/grace.c
index 183cc1f..9faa613 100644
--- a/fs/lockd/grace.c
+++ b/fs/lockd/grace.c
@@ -4,6 +4,8 @@
 
 #include <linux/module.h>
 #include <linux/lockd/bind.h>
+#include <linux/fs.h>
+#include <linux/exportfs.h>
 
 static LIST_HEAD(grace_list);
 static DEFINE_SPINLOCK(grace_lock);
@@ -46,14 +48,31 @@ void locks_end_grace(struct lock_manager *lm)
 EXPORT_SYMBOL_GPL(locks_end_grace);
 
 /**
+ * generic_locks_in_grace
+ *
+ * Most filesystems don't require special handling for the grace period
+ * and just use this standard one.
+ */
+bool generic_locks_in_grace(void)
+{
+	return !list_empty(&grace_list);
+}
+EXPORT_SYMBOL_GPL(generic_locks_in_grace);
+
+/**
  * locks_in_grace
  *
  * Lock managers call this function to determine when it is OK for them
  * to answer ordinary lock requests, and when they should accept only
  * lock reclaims.
+ *
+ * Most filesystems won't define a locks_in_grace export op, but those
+ * that need special handling can.
  */
-int locks_in_grace(void)
+bool locks_in_grace(struct super_block *sb)
 {
-	return !list_empty(&grace_list);
+	if (sb->s_export_op && sb->s_export_op->locks_in_grace)
+		return sb->s_export_op->locks_in_grace(sb);
+	return generic_locks_in_grace();
 }
 EXPORT_SYMBOL_GPL(locks_in_grace);
diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index 9a41fdc..6fe6fb7 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -150,16 +150,16 @@ nlm4svc_proc_cancel(struct svc_rqst *rqstp, struct nlm_args *argp,
 
 	resp->cookie = argp->cookie;
 
+	/* Obtain client and file */
+	if ((resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file)))
+		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
+
 	/* Don't accept requests during grace period */
-	if (locks_in_grace()) {
+	if (locks_in_grace(file->f_file->f_path.dentry->d_sb)) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rpc_success;
 	}
 
-	/* Obtain client and file */
-	if ((resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file)))
-		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
-
 	/* Try to cancel request. */
 	resp->status = nlmsvc_cancel_blocked(file, &argp->lock);
 
@@ -183,16 +183,16 @@ nlm4svc_proc_unlock(struct svc_rqst *rqstp, struct nlm_args *argp,
 
 	resp->cookie = argp->cookie;
 
-	/* Don't accept new lock requests during grace period */
-	if (locks_in_grace()) {
-		resp->status = nlm_lck_denied_grace_period;
-		return rpc_success;
-	}
-
 	/* Obtain client and file */
 	if ((resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file)))
 		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
 
+	/* Don't accept requests during grace period */
+	if (locks_in_grace(file->f_file->f_path.dentry->d_sb)) {
+		resp->status = nlm_lck_denied_grace_period;
+		return rpc_success;
+	}
+
 	/* Now try to remove the lock */
 	resp->status = nlmsvc_unlock(file, &argp->lock);
 
@@ -320,16 +320,15 @@ nlm4svc_proc_share(struct svc_rqst *rqstp, struct nlm_args *argp,
 
 	resp->cookie = argp->cookie;
 
-	/* Don't accept new lock requests during grace period */
-	if (locks_in_grace() && !argp->reclaim) {
-		resp->status = nlm_lck_denied_grace_period;
-		return rpc_success;
-	}
-
 	/* Obtain client and file */
 	if ((resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file)))
 		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
 
+	if (!argp->reclaim && locks_in_grace(file->f_file->f_path.dentry->d_sb)) {
+		resp->status = nlm_lck_denied_grace_period;
+		return rpc_success;
+	}
+
 	/* Now try to create the share */
 	resp->status = nlmsvc_share_file(host, file, argp);
 
@@ -353,16 +352,16 @@ nlm4svc_proc_unshare(struct svc_rqst *rqstp, struct nlm_args *argp,
 
 	resp->cookie = argp->cookie;
 
+	/* Obtain client and file */
+	if ((resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file)))
+		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
+
 	/* Don't accept requests during grace period */
-	if (locks_in_grace()) {
+	if (locks_in_grace(file->f_file->f_path.dentry->d_sb)) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rpc_success;
 	}
 
-	/* Obtain client and file */
-	if ((resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file)))
-		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
-
 	/* Now try to lock the file */
 	resp->status = nlmsvc_unshare_file(host, file, argp);
 
diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index e46353f..64d6c80 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -447,11 +447,11 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
 		goto out;
 	}
 
-	if (locks_in_grace() && !reclaim) {
+	if (!reclaim && locks_in_grace(file->f_file->f_path.dentry->d_sb)) {
 		ret = nlm_lck_denied_grace_period;
 		goto out;
 	}
-	if (reclaim && !locks_in_grace()) {
+	if (reclaim && !locks_in_grace(file->f_file->f_path.dentry->d_sb)) {
 		ret = nlm_lck_denied_grace_period;
 		goto out;
 	}
@@ -559,7 +559,7 @@ nlmsvc_testlock(struct svc_rqst *rqstp, struct nlm_file *file,
 		goto out;
 	}
 
-	if (locks_in_grace()) {
+	if (locks_in_grace(file->f_file->f_path.dentry->d_sb)) {
 		ret = nlm_lck_denied_grace_period;
 		goto out;
 	}
@@ -643,7 +643,7 @@ nlmsvc_cancel_blocked(struct nlm_file *file, struct nlm_lock *lock)
 				(long long)lock->fl.fl_start,
 				(long long)lock->fl.fl_end);
 
-	if (locks_in_grace())
+	if (locks_in_grace(file->f_file->f_path.dentry->d_sb))
 		return nlm_lck_denied_grace_period;
 
 	mutex_lock(&file->f_mutex);
diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
index d27aab1..17e03c5 100644
--- a/fs/lockd/svcproc.c
+++ b/fs/lockd/svcproc.c
@@ -180,16 +180,16 @@ nlmsvc_proc_cancel(struct svc_rqst *rqstp, struct nlm_args *argp,
 
 	resp->cookie = argp->cookie;
 
+	/* Obtain client and file */
+	if ((resp->status = nlmsvc_retrieve_args(rqstp, argp, &host, &file)))
+		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
+
 	/* Don't accept requests during grace period */
-	if (locks_in_grace()) {
+	if (locks_in_grace(file->f_file->f_path.dentry->d_sb)) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rpc_success;
 	}
 
-	/* Obtain client and file */
-	if ((resp->status = nlmsvc_retrieve_args(rqstp, argp, &host, &file)))
-		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
-
 	/* Try to cancel request. */
 	resp->status = cast_status(nlmsvc_cancel_blocked(file, &argp->lock));
 
@@ -213,16 +213,16 @@ nlmsvc_proc_unlock(struct svc_rqst *rqstp, struct nlm_args *argp,
 
 	resp->cookie = argp->cookie;
 
-	/* Don't accept new lock requests during grace period */
-	if (locks_in_grace()) {
-		resp->status = nlm_lck_denied_grace_period;
-		return rpc_success;
-	}
-
 	/* Obtain client and file */
 	if ((resp->status = nlmsvc_retrieve_args(rqstp, argp, &host, &file)))
 		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
 
+	/* Don't accept requests during grace period */
+	if (locks_in_grace(file->f_file->f_path.dentry->d_sb)) {
+		resp->status = nlm_lck_denied_grace_period;
+		return rpc_success;
+	}
+
 	/* Now try to remove the lock */
 	resp->status = cast_status(nlmsvc_unlock(file, &argp->lock));
 
@@ -360,16 +360,16 @@ nlmsvc_proc_share(struct svc_rqst *rqstp, struct nlm_args *argp,
 
 	resp->cookie = argp->cookie;
 
-	/* Don't accept new lock requests during grace period */
-	if (locks_in_grace() && !argp->reclaim) {
-		resp->status = nlm_lck_denied_grace_period;
-		return rpc_success;
-	}
-
 	/* Obtain client and file */
 	if ((resp->status = nlmsvc_retrieve_args(rqstp, argp, &host, &file)))
 		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
 
+	/* Don't accept requests during grace period */
+	if (locks_in_grace(file->f_file->f_path.dentry->d_sb)) {
+		resp->status = nlm_lck_denied_grace_period;
+		return rpc_success;
+	}
+
 	/* Now try to create the share */
 	resp->status = cast_status(nlmsvc_share_file(host, file, argp));
 
@@ -393,16 +393,16 @@ nlmsvc_proc_unshare(struct svc_rqst *rqstp, struct nlm_args *argp,
 
 	resp->cookie = argp->cookie;
 
+	/* Obtain client and file */
+	if ((resp->status = nlmsvc_retrieve_args(rqstp, argp, &host, &file)))
+		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
+
 	/* Don't accept requests during grace period */
-	if (locks_in_grace()) {
+	if (locks_in_grace(file->f_file->f_path.dentry->d_sb)) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rpc_success;
 	}
 
-	/* Obtain client and file */
-	if ((resp->status = nlmsvc_retrieve_args(rqstp, argp, &host, &file)))
-		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
-
 	/* Now try to unshare the file */
 	resp->status = cast_status(nlmsvc_unshare_file(host, file, argp));
 
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 2ed14df..351f7e3 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -354,10 +354,12 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	/* Openowner is now set, so sequence id will get bumped.  Now we need
 	 * these checks before we do any creates: */
 	status = nfserr_grace;
-	if (locks_in_grace() && open->op_claim_type != NFS4_OPEN_CLAIM_PREVIOUS)
+	if (open->op_claim_type != NFS4_OPEN_CLAIM_PREVIOUS &&
+	    locks_in_grace(cstate->current_fh.fh_dentry->d_sb))
 		goto out;
 	status = nfserr_no_grace;
-	if (!locks_in_grace() && open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS)
+	if (open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS &&
+	    !locks_in_grace(cstate->current_fh.fh_dentry->d_sb))
 		goto out;
 
 	switch (open->op_claim_type) {
@@ -741,7 +743,7 @@ nfsd4_remove(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 {
 	__be32 status;
 
-	if (locks_in_grace())
+	if (locks_in_grace(cstate->current_fh.fh_dentry->d_sb))
 		return nfserr_grace;
 	status = nfsd_unlink(rqstp, &cstate->current_fh, 0,
 			     remove->rm_name, remove->rm_namelen);
@@ -760,8 +762,8 @@ nfsd4_rename(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	if (!cstate->save_fh.fh_dentry)
 		return status;
-	if (locks_in_grace() && !(cstate->save_fh.fh_export->ex_flags
-					& NFSEXP_NOSUBTREECHECK))
+	if (!(cstate->save_fh.fh_export->ex_flags & NFSEXP_NOSUBTREECHECK) &&
+	    locks_in_grace(cstate->save_fh.fh_dentry->d_sb))
 		return nfserr_grace;
 	status = nfsd_rename(rqstp, &cstate->save_fh, rename->rn_sname,
 			     rename->rn_snamelen, &cstate->current_fh,
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a822e31..3f3d9f0 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2938,7 +2938,7 @@ nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open, struct nfs4_ol_
 		case NFS4_OPEN_CLAIM_NULL:
 			/* Let's not give out any delegations till everyone's
 			 * had the chance to reclaim theirs.... */
-			if (locks_in_grace())
+			if (locks_in_grace(fh->fh_dentry->d_sb))
 				goto out;
 			if (!cb_up || !(oo->oo_flags & NFS4_OO_CONFIRMED))
 				goto out;
@@ -3183,7 +3183,7 @@ nfs4_laundromat(void)
 	nfs4_lock_state();
 
 	dprintk("NFSD: laundromat service - starting\n");
-	if (locks_in_grace())
+	if (generic_locks_in_grace())
 		nfsd4_end_grace();
 	INIT_LIST_HEAD(&reaplist);
 	spin_lock(&client_lock);
@@ -3312,7 +3312,7 @@ check_special_stateids(svc_fh *current_fh, stateid_t *stateid, int flags)
 {
 	if (ONE_STATEID(stateid) && (flags & RD_STATE))
 		return nfs_ok;
-	else if (locks_in_grace()) {
+	else if (locks_in_grace(current_fh->fh_dentry->d_sb)) {
 		/* Answer in remaining cases depends on existence of
 		 * conflicting state; so we must wait out the grace period. */
 		return nfserr_grace;
@@ -3331,7 +3331,7 @@ check_special_stateids(svc_fh *current_fh, stateid_t *stateid, int flags)
 static inline int
 grace_disallows_io(struct inode *inode)
 {
-	return locks_in_grace() && mandatory_lock(inode);
+	return mandatory_lock(inode) && locks_in_grace(inode->i_sb);
 }
 
 /* Returns true iff a is later than b: */
@@ -4128,13 +4128,6 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (status)
 		goto out;
 
-	status = nfserr_grace;
-	if (locks_in_grace() && !lock->lk_reclaim)
-		goto out;
-	status = nfserr_no_grace;
-	if (!locks_in_grace() && lock->lk_reclaim)
-		goto out;
-
 	locks_init_lock(&file_lock);
 	switch (lock->lk_type) {
 		case NFS4_READ_LT:
@@ -4159,6 +4152,14 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		status = nfserr_openmode;
 		goto out;
 	}
+
+	status = nfserr_grace;
+	if (!lock->lk_reclaim && locks_in_grace(filp->f_path.dentry->d_sb))
+		goto out;
+	status = nfserr_no_grace;
+	if (lock->lk_reclaim && !locks_in_grace(filp->f_path.dentry->d_sb))
+		goto out;
+
 	file_lock.fl_owner = (fl_owner_t)lock_sop;
 	file_lock.fl_pid = current->tgid;
 	file_lock.fl_file = filp;
@@ -4235,9 +4236,6 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	int error;
 	__be32 status;
 
-	if (locks_in_grace())
-		return nfserr_grace;
-
 	if (check_lock_length(lockt->lt_offset, lockt->lt_length))
 		 return nfserr_inval;
 
@@ -4251,6 +4249,12 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		goto out;
 
 	inode = cstate->current_fh.fh_dentry->d_inode;
+
+	if (locks_in_grace(inode->i_sb)) {
+		status = nfserr_grace;
+		goto out;
+	}
+
 	locks_init_lock(&file_lock);
 	switch (lockt->lt_type) {
 		case NFS4_READ_LT:
diff --git a/include/linux/exportfs.h b/include/linux/exportfs.h
index 3a4cef5..05c29b5 100644
--- a/include/linux/exportfs.h
+++ b/include/linux/exportfs.h
@@ -159,6 +159,11 @@ struct fid {
  * commit_metadata:
  *    @commit_metadata should commit metadata changes to stable storage.
  *
+ * locks_in_grace:
+ *    @locks_in_grace should return whether the grace period is active for the
+ *    given super_block. This function is optional and if not provided then
+ *    generic_locks_in_grace will be used.
+ *
  * Locking rules:
  *    get_parent is called with child->d_inode->i_mutex down
  *    get_name is not (which is possibly inconsistent)
@@ -175,6 +180,7 @@ struct export_operations {
 			struct dentry *child);
 	struct dentry * (*get_parent)(struct dentry *child);
 	int (*commit_metadata)(struct inode *inode);
+	bool (*locks_in_grace)(struct super_block *sb);
 };
 
 extern int exportfs_encode_fh(struct dentry *dentry, struct fid *fid,
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 135693e..fcfa51a 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1130,7 +1130,8 @@ struct lock_manager {
 
 void locks_start_grace(struct lock_manager *);
 void locks_end_grace(struct lock_manager *);
-int locks_in_grace(void);
+bool generic_locks_in_grace(void);
+bool locks_in_grace(struct super_block *sb);
 
 /* that will die - we need it for nfs_lock_info */
 #include <linux/nfs_fs_i.h>
-- 
1.7.7.6

