Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f181.google.com ([209.85.217.181]:64858 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752377AbaAQKHl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Jan 2014 05:07:41 -0500
From: Pavel Shilovsky <piastry@etersoft.ru>
To: linux-kernel@vger.kernel.org
Cc: linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, wine-devel@winehq.org
Subject: [PATCH v7 6/7] NFSv4: Add deny state handling for nfs4_state struct
Date: Fri, 17 Jan 2014 14:07:11 +0400
Message-Id: <1389953232-9428-7-git-send-email-piastry@etersoft.ru>
In-Reply-To: <1389953232-9428-1-git-send-email-piastry@etersoft.ru>
References: <1389953232-9428-1-git-send-email-piastry@etersoft.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

and prepare code intrastructure to handle O_DENY* flags.

Signed-off-by: Pavel Shilovsky <piastry@etersoft.ru>
---
 fs/nfs/dir.c            |    2 +-
 fs/nfs/inode.c          |    7 +-
 fs/nfs/nfs4_fs.h        |   41 +++++++++-
 fs/nfs/nfs4file.c       |    2 +-
 fs/nfs/nfs4proc.c       |  194 ++++++++++++++++++++++++++---------------------
 fs/nfs/nfs4state.c      |   34 ++++-----
 fs/nfs/nfs4xdr.c        |    7 +-
 include/linux/nfs_fs.h  |    5 +-
 include/linux/nfs_xdr.h |    1 +
 9 files changed, 177 insertions(+), 116 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 812154a..fe0c7bb 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1362,7 +1362,7 @@ static fmode_t flags_to_mode(int flags)
 
 static struct nfs_open_context *create_nfs_open_context(struct dentry *dentry, int open_flags)
 {
-	return alloc_nfs_open_context(dentry, flags_to_mode(open_flags));
+	return alloc_nfs_open_context(dentry, flags_to_mode(open_flags), 0);
 }
 
 static int do_open(struct inode *inode, struct file *filp)
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 00ad1c2..82f8593 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -714,7 +714,9 @@ void nfs_close_context(struct nfs_open_context *ctx, int is_sync)
 }
 EXPORT_SYMBOL_GPL(nfs_close_context);
 
-struct nfs_open_context *alloc_nfs_open_context(struct dentry *dentry, fmode_t f_mode)
+struct nfs_open_context *
+alloc_nfs_open_context(struct dentry *dentry, fmode_t f_mode,
+		       unsigned int deny_mode)
 {
 	struct nfs_open_context *ctx;
 	struct rpc_cred *cred = rpc_lookup_cred();
@@ -731,6 +733,7 @@ struct nfs_open_context *alloc_nfs_open_context(struct dentry *dentry, fmode_t f
 	ctx->cred = cred;
 	ctx->state = NULL;
 	ctx->mode = f_mode;
+	ctx->deny_mode = deny_mode;
 	ctx->flags = 0;
 	ctx->error = 0;
 	nfs_init_lock_context(&ctx->lock_context);
@@ -843,7 +846,7 @@ int nfs_open(struct inode *inode, struct file *filp)
 {
 	struct nfs_open_context *ctx;
 
-	ctx = alloc_nfs_open_context(filp->f_path.dentry, filp->f_mode);
+	ctx = alloc_nfs_open_context(filp->f_path.dentry, filp->f_mode, 0);
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
 	nfs_file_set_open_context(filp, ctx);
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 5609edc..c455acb 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -185,7 +185,9 @@ struct nfs4_state {
 	unsigned int n_rdonly;		/* Number of read-only references */
 	unsigned int n_wronly;		/* Number of write-only references */
 	unsigned int n_rdwr;		/* Number of read/write references */
+
 	fmode_t state;			/* State on the server (R,W, or RW) */
+	unsigned int deny_state;	/* Deny state on the server */
 	atomic_t count;
 };
 
@@ -421,9 +423,10 @@ extern void nfs4_put_state_owner(struct nfs4_state_owner *);
 extern void nfs4_purge_state_owners(struct nfs_server *);
 extern struct nfs4_state * nfs4_get_open_state(struct inode *, struct nfs4_state_owner *);
 extern void nfs4_put_open_state(struct nfs4_state *);
-extern void nfs4_close_state(struct nfs4_state *, fmode_t);
-extern void nfs4_close_sync(struct nfs4_state *, fmode_t);
-extern void nfs4_state_set_mode_locked(struct nfs4_state *, fmode_t);
+extern void nfs4_close_state(struct nfs4_state *, fmode_t, unsigned int);
+extern void nfs4_close_sync(struct nfs4_state *, fmode_t, unsigned int);
+extern void nfs4_state_set_mode_locked(struct nfs4_state *, fmode_t,
+				       unsigned int);
 extern void nfs_inode_find_state_and_recover(struct inode *inode,
 		const nfs4_stateid *stateid);
 extern void nfs4_schedule_lease_recovery(struct nfs_client *);
@@ -504,6 +507,38 @@ static inline bool nfs4_valid_open_stateid(const struct nfs4_state *state)
 	return test_bit(NFS_STATE_RECOVERY_FAILED, &state->flags) == 0;
 }
 
+static inline unsigned int *
+get_state_n(struct nfs4_state *state, fmode_t mode, unsigned int deny_mode)
+{
+	switch (mode & (FMODE_READ|FMODE_WRITE)) {
+	case FMODE_READ:
+		return &state->n_rdonly;
+	case FMODE_WRITE:
+		return &state->n_wronly;
+	case FMODE_READ|FMODE_WRITE:
+		return &state->n_rdwr;
+	}
+	return NULL;
+}
+
+static inline void
+inc_state_n(struct nfs4_state *state, fmode_t mode, unsigned int deny_mode)
+{
+	unsigned int *state_n = get_state_n(state, mode, deny_mode);
+
+	if (state_n)
+		(*state_n)++;
+}
+
+static inline void
+dec_state_n(struct nfs4_state *state, fmode_t mode, unsigned int deny_mode)
+{
+	unsigned int *state_n = get_state_n(state, mode, deny_mode);
+
+	if (state_n)
+		(*state_n)--;
+}
+
 #else
 
 #define nfs4_close_state(a, b) do { } while (0)
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 8de3407..5f444f0 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -42,7 +42,7 @@ nfs4_file_open(struct inode *inode, struct file *filp)
 	parent = dget_parent(dentry);
 	dir = parent->d_inode;
 
-	ctx = alloc_nfs_open_context(filp->f_path.dentry, filp->f_mode);
+	ctx = alloc_nfs_open_context(filp->f_path.dentry, filp->f_mode, 0);
 	err = PTR_ERR(ctx);
 	if (IS_ERR(ctx))
 		goto out;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 15052b8..1b6f1fe 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1087,25 +1087,36 @@ static int nfs4_wait_for_completion_rpc_task(struct rpc_task *task)
 	return ret;
 }
 
+static inline unsigned int
+fmode_to_state_bit(fmode_t mode)
+{
+	switch (mode & (FMODE_READ|FMODE_WRITE)) {
+	case FMODE_READ:
+		return NFS_O_RDONLY_STATE;
+	case FMODE_WRITE:
+		return NFS_O_WRONLY_STATE;
+	default:
+		return NFS_O_RDWR_STATE;
+	}
+}
+
 static int can_open_cached(struct nfs4_state *state, fmode_t mode, int open_mode)
 {
 	int ret = 0;
+	unsigned int *state_n;
 
 	if (open_mode & (O_EXCL|O_TRUNC))
 		goto out;
-	switch (mode & (FMODE_READ|FMODE_WRITE)) {
-		case FMODE_READ:
-			ret |= test_bit(NFS_O_RDONLY_STATE, &state->flags) != 0
-				&& state->n_rdonly != 0;
-			break;
-		case FMODE_WRITE:
-			ret |= test_bit(NFS_O_WRONLY_STATE, &state->flags) != 0
-				&& state->n_wronly != 0;
-			break;
-		case FMODE_READ|FMODE_WRITE:
-			ret |= test_bit(NFS_O_RDWR_STATE, &state->flags) != 0
-				&& state->n_rdwr != 0;
-	}
+
+	state_n = get_state_n(state, mode, open_mode);
+	if (state_n == NULL)
+		goto out;
+
+	if ((mode & (FMODE_READ|FMODE_WRITE)) == 0)
+		goto out;
+
+	ret |= test_bit(fmode_to_state_bit(mode), &state->flags) != 0 &&
+		*state_n != 0;
 out:
 	return ret;
 }
@@ -1124,47 +1135,40 @@ static int can_open_delegated(struct nfs_delegation *delegation, fmode_t fmode)
 	return 1;
 }
 
-static void update_open_stateflags(struct nfs4_state *state, fmode_t fmode)
+static void
+update_open_stateflags(struct nfs4_state *state, fmode_t fmode,
+		       unsigned int deny_mode)
 {
-	switch (fmode) {
-		case FMODE_WRITE:
-			state->n_wronly++;
-			break;
-		case FMODE_READ:
-			state->n_rdonly++;
-			break;
-		case FMODE_READ|FMODE_WRITE:
-			state->n_rdwr++;
-	}
-	nfs4_state_set_mode_locked(state, state->state | fmode);
+	inc_state_n(state, fmode, deny_mode);
+	nfs4_state_set_mode_locked(state, state->state | fmode,
+				   state->deny_state | deny_mode);
 }
 
-static void nfs_set_open_stateid_locked(struct nfs4_state *state, nfs4_stateid *stateid, fmode_t fmode)
+static void
+nfs_set_open_stateid_locked(struct nfs4_state *state, nfs4_stateid *stateid,
+			    fmode_t fmode, unsigned int deny_mode)
 {
 	if (test_bit(NFS_DELEGATED_STATE, &state->flags) == 0)
 		nfs4_stateid_copy(&state->stateid, stateid);
 	nfs4_stateid_copy(&state->open_stateid, stateid);
 	set_bit(NFS_OPEN_STATE, &state->flags);
-	switch (fmode) {
-		case FMODE_READ:
-			set_bit(NFS_O_RDONLY_STATE, &state->flags);
-			break;
-		case FMODE_WRITE:
-			set_bit(NFS_O_WRONLY_STATE, &state->flags);
-			break;
-		case FMODE_READ|FMODE_WRITE:
-			set_bit(NFS_O_RDWR_STATE, &state->flags);
-	}
+	if ((fmode & (FMODE_READ|FMODE_WRITE)) != 0)
+		set_bit(fmode_to_state_bit(fmode), &state->flags);
 }
 
-static void nfs_set_open_stateid(struct nfs4_state *state, nfs4_stateid *stateid, fmode_t fmode)
+static void
+nfs_set_open_stateid(struct nfs4_state *state, nfs4_stateid *stateid,
+		     fmode_t fmode, unsigned int deny_mode)
 {
 	write_seqlock(&state->seqlock);
-	nfs_set_open_stateid_locked(state, stateid, fmode);
+	nfs_set_open_stateid_locked(state, stateid, fmode, deny_mode);
 	write_sequnlock(&state->seqlock);
 }
 
-static void __update_open_stateid(struct nfs4_state *state, nfs4_stateid *open_stateid, const nfs4_stateid *deleg_stateid, fmode_t fmode)
+static void
+__update_open_stateid(struct nfs4_state *state, nfs4_stateid *open_stateid,
+		      const nfs4_stateid *deleg_stateid, fmode_t fmode,
+		      unsigned int deny_mode)
 {
 	/*
 	 * Protect the call to nfs4_state_set_mode_locked and
@@ -1176,14 +1180,18 @@ static void __update_open_stateid(struct nfs4_state *state, nfs4_stateid *open_s
 		set_bit(NFS_DELEGATED_STATE, &state->flags);
 	}
 	if (open_stateid != NULL)
-		nfs_set_open_stateid_locked(state, open_stateid, fmode);
+		nfs_set_open_stateid_locked(state, open_stateid, fmode,
+					    deny_mode);
 	write_sequnlock(&state->seqlock);
 	spin_lock(&state->owner->so_lock);
-	update_open_stateflags(state, fmode);
+	update_open_stateflags(state, fmode, deny_mode);
 	spin_unlock(&state->owner->so_lock);
 }
 
-static int update_open_stateid(struct nfs4_state *state, nfs4_stateid *open_stateid, nfs4_stateid *delegation, fmode_t fmode)
+static int
+update_open_stateid(struct nfs4_state *state, nfs4_stateid *open_stateid,
+		    nfs4_stateid *delegation, fmode_t fmode,
+		    unsigned int deny_mode)
 {
 	struct nfs_inode *nfsi = NFS_I(state->inode);
 	struct nfs_delegation *deleg_cur;
@@ -1208,7 +1216,8 @@ static int update_open_stateid(struct nfs4_state *state, nfs4_stateid *open_stat
 		goto no_delegation_unlock;
 
 	nfs_mark_delegation_referenced(deleg_cur);
-	__update_open_stateid(state, open_stateid, &deleg_cur->stateid, fmode);
+	__update_open_stateid(state, open_stateid, &deleg_cur->stateid, fmode,
+			      deny_mode);
 	ret = 1;
 no_delegation_unlock:
 	spin_unlock(&deleg_cur->lock);
@@ -1216,7 +1225,8 @@ no_delegation:
 	rcu_read_unlock();
 
 	if (!ret && open_stateid != NULL) {
-		__update_open_stateid(state, open_stateid, NULL, fmode);
+		__update_open_stateid(state, open_stateid, NULL, fmode,
+				      deny_mode);
 		ret = 1;
 	}
 
@@ -1245,6 +1255,7 @@ static struct nfs4_state *nfs4_try_open_cached(struct nfs4_opendata *opendata)
 	struct nfs_delegation *delegation;
 	int open_mode = opendata->o_arg.open_flags;
 	fmode_t fmode = opendata->o_arg.fmode;
+	unsigned int deny_mode = 0;
 	nfs4_stateid stateid;
 	int ret = -EAGAIN;
 
@@ -1252,7 +1263,7 @@ static struct nfs4_state *nfs4_try_open_cached(struct nfs4_opendata *opendata)
 		if (can_open_cached(state, fmode, open_mode)) {
 			spin_lock(&state->owner->so_lock);
 			if (can_open_cached(state, fmode, open_mode)) {
-				update_open_stateflags(state, fmode);
+				update_open_stateflags(state, fmode, deny_mode);
 				spin_unlock(&state->owner->so_lock);
 				goto out_return_state;
 			}
@@ -1276,7 +1287,8 @@ static struct nfs4_state *nfs4_try_open_cached(struct nfs4_opendata *opendata)
 		ret = -EAGAIN;
 
 		/* Try to update the stateid using the delegation */
-		if (update_open_stateid(state, NULL, &stateid, fmode))
+		if (update_open_stateid(state, NULL, &stateid, fmode,
+					deny_mode))
 			goto out_return_state;
 	}
 out:
@@ -1341,7 +1353,7 @@ _nfs4_opendata_reclaim_to_nfs4_state(struct nfs4_opendata *data)
 		nfs4_opendata_check_deleg(data, state);
 update:
 	update_open_stateid(state, &data->o_res.stateid, NULL,
-			    data->o_arg.fmode);
+			    data->o_arg.fmode, 0);
 	atomic_inc(&state->count);
 
 	return state;
@@ -1376,7 +1388,7 @@ _nfs4_opendata_to_nfs4_state(struct nfs4_opendata *data)
 	if (data->o_res.delegation_type != 0)
 		nfs4_opendata_check_deleg(data, state);
 	update_open_stateid(state, &data->o_res.stateid, NULL,
-			data->o_arg.fmode);
+			    data->o_arg.fmode, 0);
 	iput(inode);
 out:
 	nfs_release_seqid(data->o_arg.seqid);
@@ -1426,59 +1438,62 @@ static struct nfs4_opendata *nfs4_open_recoverdata_alloc(struct nfs_open_context
 	return opendata;
 }
 
-static int nfs4_open_recover_helper(struct nfs4_opendata *opendata, fmode_t fmode, struct nfs4_state **res)
+static int
+nfs4_open_recover_helper(struct nfs4_opendata *opendata, fmode_t fmode,
+			 unsigned int deny_mode, struct nfs4_state **res)
 {
 	struct nfs4_state *newstate;
 	int ret;
 
-	opendata->o_arg.open_flags = 0;
+	opendata->o_arg.open_flags = deny_mode;
 	opendata->o_arg.fmode = fmode;
 	memset(&opendata->o_res, 0, sizeof(opendata->o_res));
 	memset(&opendata->c_res, 0, sizeof(opendata->c_res));
 	nfs4_init_opendata_res(opendata);
 	ret = _nfs4_recover_proc_open(opendata);
 	if (ret != 0)
-		return ret; 
+		return ret;
 	newstate = nfs4_opendata_to_nfs4_state(opendata);
 	if (IS_ERR(newstate))
 		return PTR_ERR(newstate);
-	nfs4_close_state(newstate, fmode);
+	nfs4_close_state(newstate, fmode, deny_mode);
 	*res = newstate;
 	return 0;
 }
 
-static int nfs4_open_recover(struct nfs4_opendata *opendata, struct nfs4_state *state)
+static int
+nfs4_open_recover(struct nfs4_opendata *opendata, struct nfs4_state *state)
 {
-	struct nfs4_state *newstate;
+	struct nfs4_state *newstate = NULL;
 	int ret;
+	unsigned int fm, dm;
+	fmode_t fmodes[] = {FMODE_READ, FMODE_WRITE, FMODE_READ|FMODE_WRITE};
+	unsigned int dmodes[] = {0};
 
 	/* memory barrier prior to reading state->n_* */
 	clear_bit(NFS_DELEGATED_STATE, &state->flags);
 	clear_bit(NFS_OPEN_STATE, &state->flags);
 	smp_rmb();
-	if (state->n_rdwr != 0) {
-		clear_bit(NFS_O_RDWR_STATE, &state->flags);
-		ret = nfs4_open_recover_helper(opendata, FMODE_READ|FMODE_WRITE, &newstate);
-		if (ret != 0)
-			return ret;
-		if (newstate != state)
-			return -ESTALE;
-	}
-	if (state->n_wronly != 0) {
-		clear_bit(NFS_O_WRONLY_STATE, &state->flags);
-		ret = nfs4_open_recover_helper(opendata, FMODE_WRITE, &newstate);
-		if (ret != 0)
-			return ret;
-		if (newstate != state)
-			return -ESTALE;
-	}
-	if (state->n_rdonly != 0) {
-		clear_bit(NFS_O_RDONLY_STATE, &state->flags);
-		ret = nfs4_open_recover_helper(opendata, FMODE_READ, &newstate);
-		if (ret != 0)
-			return ret;
-		if (newstate != state)
-			return -ESTALE;
+	/* walk through all possible fmode|denymode values */
+	for (fm = 0; fm < 3; fm++) {
+		unsigned int fmode_bit = fmode_to_state_bit(fmodes[fm]);
+
+		for (dm = 0; dm < 1; dm++) {
+			unsigned int *state_n;
+
+			state_n = get_state_n(state, fmodes[fm], dmodes[dm]);
+			if (state_n == NULL || *state_n == 0)
+				continue;
+
+			clear_bit(fmode_bit, &state->flags);
+
+			ret = nfs4_open_recover_helper(opendata, fmodes[fm],
+						       dmodes[dm], &newstate);
+			if (ret != 0)
+				return ret;
+			if (newstate != state)
+				return -ESTALE;
+		}
 	}
 	/*
 	 * We may have performed cached opens for all three recoveries.
@@ -1654,7 +1669,7 @@ static void nfs4_open_confirm_release(void *calldata)
 		goto out_free;
 	state = nfs4_opendata_to_nfs4_state(data);
 	if (!IS_ERR(state))
-		nfs4_close_state(state, data->o_arg.fmode);
+		nfs4_close_state(state, data->o_arg.fmode, 0);
 out_free:
 	nfs4_opendata_put(data);
 }
@@ -1814,7 +1829,7 @@ static void nfs4_open_release(void *calldata)
 		goto out_free;
 	state = nfs4_opendata_to_nfs4_state(data);
 	if (!IS_ERR(state))
-		nfs4_close_state(state, data->o_arg.fmode);
+		nfs4_close_state(state, data->o_arg.fmode, 0);
 out_free:
 	nfs4_opendata_put(data);
 }
@@ -1926,7 +1941,7 @@ static int nfs4_opendata_access(struct rpc_cred *cred,
 		return 0;
 
 	/* even though OPEN succeeded, access is denied. Close the file */
-	nfs4_close_state(state, fmode);
+	nfs4_close_state(state, fmode, 0);
 	return -EACCES;
 }
 
@@ -2478,8 +2493,9 @@ static void nfs4_free_closedata(void *data)
 	kfree(calldata);
 }
 
-static void nfs4_close_clear_stateid_flags(struct nfs4_state *state,
-		fmode_t fmode)
+static void
+nfs4_close_clear_stateid_flags(struct nfs4_state *state, fmode_t fmode,
+			       unsigned int deny_mode)
 {
 	spin_lock(&state->owner->so_lock);
 	clear_bit(NFS_O_RDWR_STATE, &state->flags);
@@ -2516,7 +2532,8 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 			if (calldata->roc)
 				pnfs_roc_set_barrier(state->inode,
 						     calldata->roc_barrier);
-			nfs_set_open_stateid(state, &calldata->res.stateid, 0);
+			nfs_set_open_stateid(state, &calldata->res.stateid, 0,
+					     0);
 			renew_lease(server, calldata->timestamp);
 			break;
 		case -NFS4ERR_ADMIN_REVOKED:
@@ -2532,7 +2549,8 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 				goto out_release;
 			}
 	}
-	nfs4_close_clear_stateid_flags(state, calldata->arg.fmode);
+	nfs4_close_clear_stateid_flags(state, calldata->arg.fmode,
+				       calldata->arg.deny_mode);
 out_release:
 	nfs_release_seqid(calldata->arg.seqid);
 	nfs_refresh_inode(calldata->inode, calldata->res.fattr);
@@ -2552,6 +2570,7 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 
 	task->tk_msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_OPEN_DOWNGRADE];
 	calldata->arg.fmode = FMODE_READ|FMODE_WRITE;
+	calldata->arg.deny_mode = 0;
 	spin_lock(&state->owner->so_lock);
 	/* Calculate the change in open mode */
 	if (state->n_rdwr == 0) {
@@ -2651,6 +2670,7 @@ int nfs4_do_close(struct nfs4_state *state, gfp_t gfp_mask, int wait)
 	if (calldata->arg.seqid == NULL)
 		goto out_free_calldata;
 	calldata->arg.fmode = 0;
+	calldata->arg.deny_mode = 0;
 	calldata->arg.bitmask = server->cache_consistency_bitmask;
 	calldata->res.fattr = &calldata->fattr;
 	calldata->res.seqid = calldata->arg.seqid;
@@ -2701,9 +2721,9 @@ static void nfs4_close_context(struct nfs_open_context *ctx, int is_sync)
 	if (ctx->state == NULL)
 		return;
 	if (is_sync)
-		nfs4_close_sync(ctx->state, ctx->mode);
+		nfs4_close_sync(ctx->state, ctx->mode, ctx->deny_mode);
 	else
-		nfs4_close_state(ctx->state, ctx->mode);
+		nfs4_close_state(ctx->state, ctx->mode, ctx->deny_mode);
 }
 
 #define FATTR4_WORD1_NFS40_MASK (2*FATTR4_WORD1_MOUNTED_ON_FILEID - 1UL)
@@ -3382,7 +3402,7 @@ nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 	int opened = 0;
 	int status = 0;
 
-	ctx = alloc_nfs_open_context(dentry, FMODE_READ);
+	ctx = alloc_nfs_open_context(dentry, FMODE_READ, 0);
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
 
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 059c01b..168f868 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -633,8 +633,10 @@ nfs4_alloc_open_state(void)
 }
 
 void
-nfs4_state_set_mode_locked(struct nfs4_state *state, fmode_t fmode)
+nfs4_state_set_mode_locked(struct nfs4_state *state, fmode_t fmode,
+			   unsigned int deny_mode)
 {
+	state->deny_state = deny_mode;
 	if (state->state == fmode)
 		return;
 	/* NB! List reordering - see the reclaim code for why.  */
@@ -727,8 +729,9 @@ void nfs4_put_open_state(struct nfs4_state *state)
 /*
  * Close the current file.
  */
-static void __nfs4_close(struct nfs4_state *state,
-		fmode_t fmode, gfp_t gfp_mask, int wait)
+static void
+__nfs4_close(struct nfs4_state *state, fmode_t fmode, unsigned int deny_mode,
+	     gfp_t gfp_mask, int wait)
 {
 	struct nfs4_state_owner *owner = state->owner;
 	int call_close = 0;
@@ -737,16 +740,7 @@ static void __nfs4_close(struct nfs4_state *state,
 	atomic_inc(&owner->so_count);
 	/* Protect against nfs4_find_state() */
 	spin_lock(&owner->so_lock);
-	switch (fmode & (FMODE_READ | FMODE_WRITE)) {
-		case FMODE_READ:
-			state->n_rdonly--;
-			break;
-		case FMODE_WRITE:
-			state->n_wronly--;
-			break;
-		case FMODE_READ|FMODE_WRITE:
-			state->n_rdwr--;
-	}
+	dec_state_n(state, fmode, deny_mode);
 	newstate = FMODE_READ|FMODE_WRITE;
 	if (state->n_rdwr == 0) {
 		if (state->n_rdonly == 0) {
@@ -762,7 +756,7 @@ static void __nfs4_close(struct nfs4_state *state,
 		if (newstate == 0)
 			clear_bit(NFS_DELEGATED_STATE, &state->flags);
 	}
-	nfs4_state_set_mode_locked(state, newstate);
+	nfs4_state_set_mode_locked(state, newstate, 0);
 	spin_unlock(&owner->so_lock);
 
 	if (!call_close) {
@@ -772,14 +766,18 @@ static void __nfs4_close(struct nfs4_state *state,
 		nfs4_do_close(state, gfp_mask, wait);
 }
 
-void nfs4_close_state(struct nfs4_state *state, fmode_t fmode)
+void
+nfs4_close_state(struct nfs4_state *state, fmode_t fmode,
+		 unsigned int deny_mode)
 {
-	__nfs4_close(state, fmode, GFP_NOFS, 0);
+	__nfs4_close(state, fmode, deny_mode, GFP_NOFS, 0);
 }
 
-void nfs4_close_sync(struct nfs4_state *state, fmode_t fmode)
+void
+nfs4_close_sync(struct nfs4_state *state, fmode_t fmode,
+		unsigned int deny_mode)
 {
-	__nfs4_close(state, fmode, GFP_KERNEL, 1);
+	__nfs4_close(state, fmode, deny_mode, GFP_KERNEL, 1);
 }
 
 /*
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 5be2868..ed507f4 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1358,7 +1358,8 @@ static void encode_lookup(struct xdr_stream *xdr, const struct qstr *name, struc
 	encode_string(xdr, name->len, name->name);
 }
 
-static void encode_share_access(struct xdr_stream *xdr, fmode_t fmode)
+static void encode_share_access(struct xdr_stream *xdr, fmode_t fmode,
+				int open_flags)
 {
 	__be32 *p;
 
@@ -1387,7 +1388,7 @@ static inline void encode_openhdr(struct xdr_stream *xdr, const struct nfs_opena
  * owner 4 = 32
  */
 	encode_nfs4_seqid(xdr, arg->seqid);
-	encode_share_access(xdr, arg->fmode);
+	encode_share_access(xdr, arg->fmode, arg->open_flags);
 	p = reserve_space(xdr, 36);
 	p = xdr_encode_hyper(p, arg->clientid);
 	*p++ = cpu_to_be32(24);
@@ -1542,7 +1543,7 @@ static void encode_open_downgrade(struct xdr_stream *xdr, const struct nfs_close
 	encode_op_hdr(xdr, OP_OPEN_DOWNGRADE, decode_open_downgrade_maxsz, hdr);
 	encode_nfs4_stateid(xdr, arg->stateid);
 	encode_nfs4_seqid(xdr, arg->seqid);
-	encode_share_access(xdr, arg->fmode);
+	encode_share_access(xdr, arg->fmode, arg->deny_mode);
 }
 
 static void
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 4899737..a6e1579 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -80,6 +80,7 @@ struct nfs_open_context {
 	struct rpc_cred *cred;
 	struct nfs4_state *state;
 	fmode_t mode;
+	unsigned int deny_mode;
 
 	unsigned long flags;
 #define NFS_CONTEXT_ERROR_WRITE		(0)
@@ -363,7 +364,9 @@ extern void nfs_setsecurity(struct inode *inode, struct nfs_fattr *fattr,
 extern struct nfs_open_context *get_nfs_open_context(struct nfs_open_context *ctx);
 extern void put_nfs_open_context(struct nfs_open_context *ctx);
 extern struct nfs_open_context *nfs_find_open_context(struct inode *inode, struct rpc_cred *cred, fmode_t mode);
-extern struct nfs_open_context *alloc_nfs_open_context(struct dentry *dentry, fmode_t f_mode);
+extern struct nfs_open_context *alloc_nfs_open_context(struct dentry *dentry,
+						       fmode_t f_mode,
+						       unsigned int deny_mode);
 extern void nfs_inode_attach_open_context(struct nfs_open_context *ctx);
 extern void nfs_file_set_open_context(struct file *filp, struct nfs_open_context *ctx);
 extern struct nfs_lock_context *nfs_get_lock_context(struct nfs_open_context *ctx);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 3ccfcec..000c47f 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -398,6 +398,7 @@ struct nfs_closeargs {
 	nfs4_stateid *		stateid;
 	struct nfs_seqid *	seqid;
 	fmode_t			fmode;
+	unsigned int		deny_mode;
 	const u32 *		bitmask;
 };
 
-- 
1.7.10.4

