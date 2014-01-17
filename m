Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f52.google.com ([209.85.215.52]:61006 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752383AbaAQKHn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Jan 2014 05:07:43 -0500
From: Pavel Shilovsky <piastry@etersoft.ru>
To: linux-kernel@vger.kernel.org
Cc: linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, wine-devel@winehq.org
Subject: [PATCH v7 7/7] NFSv4: Add O_DENY* open flags support
Date: Fri, 17 Jan 2014 14:07:12 +0400
Message-Id: <1389953232-9428-8-git-send-email-piastry@etersoft.ru>
In-Reply-To: <1389953232-9428-1-git-send-email-piastry@etersoft.ru>
References: <1389953232-9428-1-git-send-email-piastry@etersoft.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Pass O_DENY* flags to NFSv4 open request. Make it return
-ESHAREDENIED on share conflicts with other opens and disable
O_DENYDELETE support since NFSv4 doesn't support it.

Add extra file descriptor counters for every fmode|denymode
value into nfs4_state. Make the client not repeat the previous
open requests to the server during delegation recall because
of possible conflicts with deny modes.

Signed-off-by: Pavel Shilovsky <piastry@etersoft.ru>
---
 fs/nfs/dir.c       |   39 ++++++++++++++-
 fs/nfs/inode.c     |    3 +-
 fs/nfs/internal.h  |    3 +-
 fs/nfs/nfs4_fs.h   |   48 ++++++++++++++++--
 fs/nfs/nfs4file.c  |    8 ++-
 fs/nfs/nfs4proc.c  |  138 +++++++++++++++++++++++++++++++++++++++++++---------
 fs/nfs/nfs4state.c |   33 +++++++++++--
 fs/nfs/nfs4super.c |    9 ++--
 fs/nfs/nfs4xdr.c   |   14 +++++-
 fs/nfs/super.c     |    7 ++-
 10 files changed, 261 insertions(+), 41 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index fe0c7bb..627f9ea 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1362,7 +1362,8 @@ static fmode_t flags_to_mode(int flags)
 
 static struct nfs_open_context *create_nfs_open_context(struct dentry *dentry, int open_flags)
 {
-	return alloc_nfs_open_context(dentry, flags_to_mode(open_flags), 0);
+	return alloc_nfs_open_context(dentry, flags_to_mode(open_flags),
+				      open_flags & (O_DENYREAD|O_DENYWRITE));
 }
 
 static int do_open(struct inode *inode, struct file *filp)
@@ -1411,6 +1412,10 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
 	if (err)
 		return err;
 
+	/* No support for O_DENYDELETE */
+	if (open_flags & O_DENYDELETE)
+		return -EINVAL;
+
 	/* NFS only supports OPEN on regular files */
 	if ((open_flags & O_DIRECTORY)) {
 		if (!d_unhashed(dentry)) {
@@ -2256,7 +2261,37 @@ static int nfs_open_permission_mask(int openflags)
 
 int nfs_may_open(struct inode *inode, struct rpc_cred *cred, int openflags)
 {
-	return nfs_do_access(inode, cred, nfs_open_permission_mask(openflags));
+	int ret;
+	fmode_t mode = OPEN_FMODE(openflags);
+	struct nfs_inode *nfsi = NFS_I(inode);
+	struct nfs4_state *state;
+
+	ret = nfs_do_access(inode, cred, nfs_open_permission_mask(openflags));
+	if (ret)
+		goto out;
+
+	if (!IS_SHARELOCK(inode))
+		goto out;
+
+	spin_lock(&inode->i_lock);
+	/* Check for share reservation conflicts */
+	list_for_each_entry(state, &nfsi->open_states, inode_states) {
+		if ((state->state & FMODE_READ) && (openflags & O_DENYREAD))
+			goto out_set_err;
+		if ((state->state & FMODE_WRITE) && (openflags & O_DENYWRITE))
+			goto out_set_err;
+		if ((mode & FMODE_READ) && (state->deny_state & O_DENYREAD))
+			goto out_set_err;
+		if ((mode & FMODE_WRITE) && (state->deny_state & O_DENYWRITE))
+			goto out_set_err;
+	}
+	spin_unlock(&inode->i_lock);
+out:
+	return ret;
+out_set_err:
+	spin_unlock(&inode->i_lock);
+	ret = -ESHAREDENIED;
+	goto out;
 }
 EXPORT_SYMBOL_GPL(nfs_may_open);
 
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 82f8593..a228dda 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -846,7 +846,8 @@ int nfs_open(struct inode *inode, struct file *filp)
 {
 	struct nfs_open_context *ctx;
 
-	ctx = alloc_nfs_open_context(filp->f_path.dentry, filp->f_mode, 0);
+	ctx = alloc_nfs_open_context(filp->f_path.dentry, filp->f_mode,
+				     filp->f_flags & (O_DENYREAD|O_DENYWRITE));
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
 	nfs_file_set_open_context(filp, ctx);
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 8b5cc04..98f95fd 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -7,7 +7,8 @@
 #include <linux/security.h>
 #include <linux/crc32.h>
 
-#define NFS_MS_MASK (MS_RDONLY|MS_NOSUID|MS_NODEV|MS_NOEXEC|MS_SYNCHRONOUS)
+#define NFS_MS_MASK (MS_RDONLY | MS_NOSUID | MS_NODEV | MS_NOEXEC | \
+		     MS_SYNCHRONOUS | MS_SHARELOCK)
 
 struct nfs_string;
 
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index c455acb..ca86f66 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -164,6 +164,10 @@ enum {
 	NFS_STATE_RECLAIM_NOGRACE,	/* OPEN stateid needs to recover state */
 	NFS_STATE_POSIX_LOCKS,		/* Posix locks are supported */
 	NFS_STATE_RECOVERY_FAILED,	/* OPEN stateid state recovery failed */
+	NFS_O_DENYNONE_STATE,		/* OPEN stateid has deny none state */
+	NFS_O_DENYREAD_STATE,		/* OPEN stateid has deny read state */
+	NFS_O_DENYWRITE_STATE,		/* OPEN stateid has deny write state */
+	NFS_O_DENYRDWR_STATE,		/* OPEN stateid has deny rw state */
 };
 
 struct nfs4_state {
@@ -181,10 +185,19 @@ struct nfs4_state {
 	nfs4_stateid stateid;		/* Current stateid: may be delegation */
 	nfs4_stateid open_stateid;	/* OPEN stateid */
 
-	/* The following 3 fields are protected by owner->so_lock */
+	/* The following 12 fields are protected by owner->so_lock */
 	unsigned int n_rdonly;		/* Number of read-only references */
 	unsigned int n_wronly;		/* Number of write-only references */
 	unsigned int n_rdwr;		/* Number of read/write references */
+	unsigned int n_ro_dr;		/* Number of read/denyread refs */
+	unsigned int n_wo_dr;		/* Number of write/denyread refs */
+	unsigned int n_rw_dr;		/* Number of rw/denyread references */
+	unsigned int n_ro_dw;		/* Number of read/denywrite refs */
+	unsigned int n_wo_dw;		/* Number of write/denywrite refs */
+	unsigned int n_rw_dw;		/* Number of rw/denywrite references */
+	unsigned int n_ro_drw;		/* Number of read/denyrw references */
+	unsigned int n_wo_drw;		/* Number of write/denyrw references */
+	unsigned int n_rw_drw;		/* Number of rw/denyrw references */
 
 	fmode_t state;			/* State on the server (R,W, or RW) */
 	unsigned int deny_state;	/* Deny state on the server */
@@ -512,11 +525,38 @@ get_state_n(struct nfs4_state *state, fmode_t mode, unsigned int deny_mode)
 {
 	switch (mode & (FMODE_READ|FMODE_WRITE)) {
 	case FMODE_READ:
-		return &state->n_rdonly;
+		switch (deny_mode & (O_DENYREAD|O_DENYWRITE)) {
+		case 0:
+			return &state->n_rdonly;
+		case O_DENYREAD:
+			return &state->n_ro_dr;
+		case O_DENYWRITE:
+			return &state->n_ro_dw;
+		case O_DENYREAD|O_DENYWRITE:
+			return &state->n_ro_drw;
+		}
 	case FMODE_WRITE:
-		return &state->n_wronly;
+		switch (deny_mode & (O_DENYREAD|O_DENYWRITE)) {
+		case 0:
+			return &state->n_wronly;
+		case O_DENYREAD:
+			return &state->n_wo_dr;
+		case O_DENYWRITE:
+			return &state->n_wo_dw;
+		case O_DENYREAD|O_DENYWRITE:
+			return &state->n_wo_drw;
+		}
 	case FMODE_READ|FMODE_WRITE:
-		return &state->n_rdwr;
+		switch (deny_mode & (O_DENYREAD|O_DENYWRITE)) {
+		case 0:
+			return &state->n_rdwr;
+		case O_DENYREAD:
+			return &state->n_rw_dr;
+		case O_DENYWRITE:
+			return &state->n_rw_dw;
+		case O_DENYREAD|O_DENYWRITE:
+			return &state->n_rw_drw;
+		}
 	}
 	return NULL;
 }
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 5f444f0..bfea7fa 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -33,6 +33,10 @@ nfs4_file_open(struct inode *inode, struct file *filp)
 
 	dprintk("NFS: open file(%pd2)\n", dentry);
 
+	/* No support for O_DENYDELETE */
+	if (openflags & O_DENYDELETE)
+		return -EINVAL;
+
 	if ((openflags & O_ACCMODE) == 3)
 		openflags--;
 
@@ -42,7 +46,8 @@ nfs4_file_open(struct inode *inode, struct file *filp)
 	parent = dget_parent(dentry);
 	dir = parent->d_inode;
 
-	ctx = alloc_nfs_open_context(filp->f_path.dentry, filp->f_mode, 0);
+	ctx = alloc_nfs_open_context(filp->f_path.dentry, filp->f_mode,
+				     filp->f_flags & (O_DENYREAD|O_DENYWRITE));
 	err = PTR_ERR(ctx);
 	if (IS_ERR(ctx))
 		goto out;
@@ -63,6 +68,7 @@ nfs4_file_open(struct inode *inode, struct file *filp)
 		case -EDQUOT:
 		case -ENOSPC:
 		case -EROFS:
+		case -ESHAREDENIED:
 			goto out_put_ctx;
 		default:
 			goto out_drop;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1b6f1fe..8fafe59 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -155,7 +155,7 @@ static int nfs4_map_errors(int err)
 	case -NFS4ERR_BADNAME:
 		return -EINVAL;
 	case -NFS4ERR_SHARE_DENIED:
-		return -EACCES;
+		return -ESHAREDENIED;
 	case -NFS4ERR_MINOR_VERS_MISMATCH:
 		return -EPROTONOSUPPORT;
 	case -NFS4ERR_ACCESS:
@@ -996,6 +996,8 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
 	p->owner = sp;
 	atomic_inc(&sp->so_count);
 	p->o_arg.open_flags = flags;
+	if (!IS_SHARELOCK(dir))
+		p->o_arg.open_flags &= ~(O_DENYREAD | O_DENYWRITE);
 	p->o_arg.fmode = fmode & (FMODE_READ|FMODE_WRITE);
 	/* don't put an ACCESS op in OPEN compound if O_EXCL, because ACCESS
 	 * will return permission denied for all bits until close */
@@ -1100,6 +1102,20 @@ fmode_to_state_bit(fmode_t mode)
 	}
 }
 
+static inline unsigned int
+denymode_to_state_bit(unsigned int deny_mode)
+{
+	switch (deny_mode & (O_DENYREAD|O_DENYWRITE)) {
+	case O_DENYREAD:
+		return NFS_O_DENYREAD_STATE;
+	case O_DENYWRITE:
+		return NFS_O_DENYWRITE_STATE;
+	case O_DENYREAD|O_DENYWRITE:
+		return NFS_O_DENYRDWR_STATE;
+	}
+	return NFS_O_DENYNONE_STATE;
+}
+
 static int can_open_cached(struct nfs4_state *state, fmode_t mode, int open_mode)
 {
 	int ret = 0;
@@ -1108,6 +1124,15 @@ static int can_open_cached(struct nfs4_state *state, fmode_t mode, int open_mode
 	if (open_mode & (O_EXCL|O_TRUNC))
 		goto out;
 
+	if ((state->state & FMODE_READ) && (open_mode & O_DENYREAD))
+		goto out;
+	if ((state->state & FMODE_WRITE) && (open_mode & O_DENYWRITE))
+		goto out;
+	if ((mode & FMODE_READ) && (state->deny_state & O_DENYREAD))
+		goto out;
+	if ((mode & FMODE_WRITE) && (state->deny_state & O_DENYWRITE))
+		goto out;
+
 	state_n = get_state_n(state, mode, open_mode);
 	if (state_n == NULL)
 		goto out;
@@ -1116,17 +1141,22 @@ static int can_open_cached(struct nfs4_state *state, fmode_t mode, int open_mode
 		goto out;
 
 	ret |= test_bit(fmode_to_state_bit(mode), &state->flags) != 0 &&
-		*state_n != 0;
+		test_bit(denymode_to_state_bit(open_mode), &state->flags) != 0
+		&& *state_n != 0;
 out:
 	return ret;
 }
 
-static int can_open_delegated(struct nfs_delegation *delegation, fmode_t fmode)
+static int
+can_open_delegated(struct nfs_delegation *delegation, fmode_t fmode,
+		   unsigned int deny_mode)
 {
 	if (delegation == NULL)
 		return 0;
 	if ((delegation->type & fmode) != fmode)
 		return 0;
+	if ((deny_mode & O_DENYREAD) && (delegation->type == FMODE_READ))
+		return 0;
 	if (test_bit(NFS_DELEGATION_NEED_RECLAIM, &delegation->flags))
 		return 0;
 	if (test_bit(NFS_DELEGATION_RETURNING, &delegation->flags))
@@ -1154,6 +1184,7 @@ nfs_set_open_stateid_locked(struct nfs4_state *state, nfs4_stateid *stateid,
 	set_bit(NFS_OPEN_STATE, &state->flags);
 	if ((fmode & (FMODE_READ|FMODE_WRITE)) != 0)
 		set_bit(fmode_to_state_bit(fmode), &state->flags);
+	set_bit(denymode_to_state_bit(deny_mode), &state->flags);
 }
 
 static void
@@ -1255,7 +1286,7 @@ static struct nfs4_state *nfs4_try_open_cached(struct nfs4_opendata *opendata)
 	struct nfs_delegation *delegation;
 	int open_mode = opendata->o_arg.open_flags;
 	fmode_t fmode = opendata->o_arg.fmode;
-	unsigned int deny_mode = 0;
+	unsigned int deny_mode = open_mode & (O_DENYREAD|O_DENYWRITE);
 	nfs4_stateid stateid;
 	int ret = -EAGAIN;
 
@@ -1271,7 +1302,7 @@ static struct nfs4_state *nfs4_try_open_cached(struct nfs4_opendata *opendata)
 		}
 		rcu_read_lock();
 		delegation = rcu_dereference(nfsi->delegation);
-		if (!can_open_delegated(delegation, fmode)) {
+		if (!can_open_delegated(delegation, fmode, deny_mode)) {
 			rcu_read_unlock();
 			break;
 		}
@@ -1353,7 +1384,8 @@ _nfs4_opendata_reclaim_to_nfs4_state(struct nfs4_opendata *data)
 		nfs4_opendata_check_deleg(data, state);
 update:
 	update_open_stateid(state, &data->o_res.stateid, NULL,
-			    data->o_arg.fmode, 0);
+			    data->o_arg.fmode,
+			    data->o_arg.open_flags & (O_DENYREAD|O_DENYWRITE));
 	atomic_inc(&state->count);
 
 	return state;
@@ -1388,7 +1420,8 @@ _nfs4_opendata_to_nfs4_state(struct nfs4_opendata *data)
 	if (data->o_res.delegation_type != 0)
 		nfs4_opendata_check_deleg(data, state);
 	update_open_stateid(state, &data->o_res.stateid, NULL,
-			    data->o_arg.fmode, 0);
+			    data->o_arg.fmode,
+			    data->o_arg.open_flags & (O_DENYREAD|O_DENYWRITE));
 	iput(inode);
 out:
 	nfs_release_seqid(data->o_arg.seqid);
@@ -1461,14 +1494,20 @@ nfs4_open_recover_helper(struct nfs4_opendata *opendata, fmode_t fmode,
 	return 0;
 }
 
+/*
+ * Recover an open state on the server. @reset indicates if we need to
+ * flush all opens or just those that were cached localy.
+ */
 static int
-nfs4_open_recover(struct nfs4_opendata *opendata, struct nfs4_state *state)
+nfs4_open_recover(struct nfs4_opendata *opendata, struct nfs4_state *state,
+		  bool reset)
 {
 	struct nfs4_state *newstate = NULL;
 	int ret;
 	unsigned int fm, dm;
 	fmode_t fmodes[] = {FMODE_READ, FMODE_WRITE, FMODE_READ|FMODE_WRITE};
-	unsigned int dmodes[] = {0};
+	unsigned int dmodes[] = {0, O_DENYREAD, O_DENYWRITE,
+				 O_DENYREAD|O_DENYWRITE};
 
 	/* memory barrier prior to reading state->n_* */
 	clear_bit(NFS_DELEGATED_STATE, &state->flags);
@@ -1478,14 +1517,21 @@ nfs4_open_recover(struct nfs4_opendata *opendata, struct nfs4_state *state)
 	for (fm = 0; fm < 3; fm++) {
 		unsigned int fmode_bit = fmode_to_state_bit(fmodes[fm]);
 
-		for (dm = 0; dm < 1; dm++) {
+		for (dm = 0; dm < 4; dm++) {
 			unsigned int *state_n;
+			unsigned int deny_bit;
 
 			state_n = get_state_n(state, fmodes[fm], dmodes[dm]);
 			if (state_n == NULL || *state_n == 0)
 				continue;
 
+			deny_bit = denymode_to_state_bit(dmodes[dm]);
+			if (!reset && test_bit(fmode_bit, &state->flags) &&
+			    test_bit(deny_bit, &state->flags))
+				continue;
+
 			clear_bit(fmode_bit, &state->flags);
+			clear_bit(deny_bit, &state->flags);
 
 			ret = nfs4_open_recover_helper(opendata, fmodes[fm],
 						       dmodes[dm], &newstate);
@@ -1530,7 +1576,7 @@ static int _nfs4_do_open_reclaim(struct nfs_open_context *ctx, struct nfs4_state
 		delegation_type = delegation->type;
 	rcu_read_unlock();
 	opendata->o_arg.u.delegation_type = delegation_type;
-	status = nfs4_open_recover(opendata, state);
+	status = nfs4_open_recover(opendata, state, true);
 	nfs4_opendata_put(opendata);
 	return status;
 }
@@ -1628,7 +1674,7 @@ int nfs4_open_delegation_recall(struct nfs_open_context *ctx, struct nfs4_state
 	if (IS_ERR(opendata))
 		return PTR_ERR(opendata);
 	nfs4_stateid_copy(&opendata->o_arg.u.delegation, stateid);
-	err = nfs4_open_recover(opendata, state);
+	err = nfs4_open_recover(opendata, state, false);
 	nfs4_opendata_put(opendata);
 	return nfs4_handle_delegation_recall_error(server, state, stateid, err);
 }
@@ -1669,7 +1715,8 @@ static void nfs4_open_confirm_release(void *calldata)
 		goto out_free;
 	state = nfs4_opendata_to_nfs4_state(data);
 	if (!IS_ERR(state))
-		nfs4_close_state(state, data->o_arg.fmode, 0);
+		nfs4_close_state(state, data->o_arg.fmode,
+			data->o_arg.open_flags & (O_DENYREAD|O_DENYWRITE));
 out_free:
 	nfs4_opendata_put(data);
 }
@@ -1742,7 +1789,8 @@ static void nfs4_open_prepare(struct rpc_task *task, void *calldata)
 		delegation = rcu_dereference(NFS_I(data->state->inode)->delegation);
 		if (data->o_arg.claim != NFS4_OPEN_CLAIM_DELEGATE_CUR &&
 		    data->o_arg.claim != NFS4_OPEN_CLAIM_DELEG_CUR_FH &&
-		    can_open_delegated(delegation, data->o_arg.fmode))
+		    can_open_delegated(delegation, data->o_arg.fmode,
+			data->o_arg.open_flags & (O_DENYREAD|O_DENYWRITE)))
 			goto unlock_no_action;
 		rcu_read_unlock();
 	}
@@ -1829,7 +1877,8 @@ static void nfs4_open_release(void *calldata)
 		goto out_free;
 	state = nfs4_opendata_to_nfs4_state(data);
 	if (!IS_ERR(state))
-		nfs4_close_state(state, data->o_arg.fmode, 0);
+		nfs4_close_state(state, data->o_arg.fmode,
+			data->o_arg.open_flags & (O_DENYREAD|O_DENYWRITE));
 out_free:
 	nfs4_opendata_put(data);
 }
@@ -1941,7 +1990,7 @@ static int nfs4_opendata_access(struct rpc_cred *cred,
 		return 0;
 
 	/* even though OPEN succeeded, access is denied. Close the file */
-	nfs4_close_state(state, fmode, 0);
+	nfs4_close_state(state, fmode, openflags & (O_DENYREAD|O_DENYWRITE));
 	return -EACCES;
 }
 
@@ -2006,7 +2055,7 @@ static int _nfs4_open_expired(struct nfs_open_context *ctx, struct nfs4_state *s
 			NFS4_OPEN_CLAIM_FH);
 	if (IS_ERR(opendata))
 		return PTR_ERR(opendata);
-	ret = nfs4_open_recover(opendata, state);
+	ret = nfs4_open_recover(opendata, state, true);
 	if (ret == -ESTALE)
 		d_drop(ctx->dentry);
 	nfs4_opendata_put(opendata);
@@ -2125,6 +2174,10 @@ static int nfs41_check_open_stateid(struct nfs4_state *state)
 		clear_bit(NFS_O_WRONLY_STATE, &state->flags);
 		clear_bit(NFS_O_RDWR_STATE, &state->flags);
 		clear_bit(NFS_OPEN_STATE, &state->flags);
+		clear_bit(NFS_O_DENYNONE_STATE, &state->flags);
+		clear_bit(NFS_O_DENYREAD_STATE, &state->flags);
+		clear_bit(NFS_O_DENYWRITE_STATE, &state->flags);
+		clear_bit(NFS_O_DENYRDWR_STATE, &state->flags);
 	}
 	return status;
 }
@@ -2498,18 +2551,40 @@ nfs4_close_clear_stateid_flags(struct nfs4_state *state, fmode_t fmode,
 			       unsigned int deny_mode)
 {
 	spin_lock(&state->owner->so_lock);
-	clear_bit(NFS_O_RDWR_STATE, &state->flags);
 	switch (fmode & (FMODE_READ|FMODE_WRITE)) {
+	case FMODE_WRITE|FMODE_READ:
+		break;
 	case FMODE_WRITE:
+		clear_bit(NFS_O_RDWR_STATE, &state->flags);
 		clear_bit(NFS_O_RDONLY_STATE, &state->flags);
 		break;
 	case FMODE_READ:
+		clear_bit(NFS_O_RDWR_STATE, &state->flags);
 		clear_bit(NFS_O_WRONLY_STATE, &state->flags);
 		break;
 	case 0:
+		clear_bit(NFS_O_RDWR_STATE, &state->flags);
 		clear_bit(NFS_O_RDONLY_STATE, &state->flags);
 		clear_bit(NFS_O_WRONLY_STATE, &state->flags);
 		clear_bit(NFS_OPEN_STATE, &state->flags);
+		clear_bit(NFS_O_DENYNONE_STATE, &state->flags);
+	}
+
+	switch (deny_mode & (O_DENYREAD|O_DENYWRITE)) {
+	case O_DENYREAD|O_DENYWRITE:
+		break;
+	case O_DENYWRITE:
+		clear_bit(NFS_O_DENYRDWR_STATE, &state->flags);
+		clear_bit(NFS_O_DENYREAD_STATE, &state->flags);
+		break;
+	case O_DENYREAD:
+		clear_bit(NFS_O_DENYRDWR_STATE, &state->flags);
+		clear_bit(NFS_O_DENYWRITE_STATE, &state->flags);
+		break;
+	case 0:
+		clear_bit(NFS_O_DENYRDWR_STATE, &state->flags);
+		clear_bit(NFS_O_DENYREAD_STATE, &state->flags);
+		clear_bit(NFS_O_DENYWRITE_STATE, &state->flags);
 	}
 	spin_unlock(&state->owner->so_lock);
 }
@@ -2570,21 +2645,40 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 
 	task->tk_msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_OPEN_DOWNGRADE];
 	calldata->arg.fmode = FMODE_READ|FMODE_WRITE;
-	calldata->arg.deny_mode = 0;
+	calldata->arg.deny_mode = O_DENYREAD|O_DENYWRITE;
 	spin_lock(&state->owner->so_lock);
 	/* Calculate the change in open mode */
-	if (state->n_rdwr == 0) {
-		if (state->n_rdonly == 0) {
+	if (state->n_rdwr + state->n_rw_dr +
+	    state->n_rw_dw + state->n_rw_drw == 0) {
+		if (state->n_rdonly + state->n_ro_dr + state->n_ro_dw +
+							state->n_ro_drw == 0) {
 			call_close |= test_bit(NFS_O_RDONLY_STATE, &state->flags);
 			call_close |= test_bit(NFS_O_RDWR_STATE, &state->flags);
 			calldata->arg.fmode &= ~FMODE_READ;
 		}
-		if (state->n_wronly == 0) {
+		if (state->n_wronly + state->n_wo_dr + state->n_wo_dw +
+							state->n_wo_drw == 0) {
 			call_close |= test_bit(NFS_O_WRONLY_STATE, &state->flags);
 			call_close |= test_bit(NFS_O_RDWR_STATE, &state->flags);
 			calldata->arg.fmode &= ~FMODE_WRITE;
 		}
 	}
+	if (state->n_ro_drw + state->n_wo_drw + state->n_rw_drw == 0) {
+		if (state->n_ro_dr + state->n_wo_dr + state->n_rw_dr == 0) {
+			call_close |= test_bit(NFS_O_DENYREAD_STATE,
+					       &state->flags);
+			call_close |= test_bit(NFS_O_DENYRDWR_STATE,
+					       &state->flags);
+			calldata->arg.deny_mode &= ~O_DENYREAD;
+		}
+		if (state->n_ro_dw + state->n_wo_dw + state->n_rw_dw == 0) {
+			call_close |= test_bit(NFS_O_DENYWRITE_STATE,
+					       &state->flags);
+			call_close |= test_bit(NFS_O_DENYRDWR_STATE,
+					       &state->flags);
+			calldata->arg.deny_mode &= ~O_DENYWRITE;
+		}
+	}
 	if (!nfs4_valid_open_stateid(state))
 		call_close = 0;
 	spin_unlock(&state->owner->so_lock);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 168f868..bdd7808 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -736,19 +736,23 @@ __nfs4_close(struct nfs4_state *state, fmode_t fmode, unsigned int deny_mode,
 	struct nfs4_state_owner *owner = state->owner;
 	int call_close = 0;
 	fmode_t newstate;
+	unsigned int newdeny_mode;
 
 	atomic_inc(&owner->so_count);
 	/* Protect against nfs4_find_state() */
 	spin_lock(&owner->so_lock);
 	dec_state_n(state, fmode, deny_mode);
 	newstate = FMODE_READ|FMODE_WRITE;
-	if (state->n_rdwr == 0) {
-		if (state->n_rdonly == 0) {
+	if (state->n_rdwr + state->n_rw_dr +
+	    state->n_rw_dw + state->n_rw_drw == 0) {
+		if (state->n_rdonly + state->n_ro_dr + state->n_ro_dw +
+							state->n_ro_drw == 0) {
 			newstate &= ~FMODE_READ;
 			call_close |= test_bit(NFS_O_RDONLY_STATE, &state->flags);
 			call_close |= test_bit(NFS_O_RDWR_STATE, &state->flags);
 		}
-		if (state->n_wronly == 0) {
+		if (state->n_wronly + state->n_wo_dr + state->n_wo_dw +
+							state->n_wo_drw == 0) {
 			newstate &= ~FMODE_WRITE;
 			call_close |= test_bit(NFS_O_WRONLY_STATE, &state->flags);
 			call_close |= test_bit(NFS_O_RDWR_STATE, &state->flags);
@@ -756,7 +760,24 @@ __nfs4_close(struct nfs4_state *state, fmode_t fmode, unsigned int deny_mode,
 		if (newstate == 0)
 			clear_bit(NFS_DELEGATED_STATE, &state->flags);
 	}
-	nfs4_state_set_mode_locked(state, newstate, 0);
+	newdeny_mode = O_DENYREAD|O_DENYWRITE;
+	if (state->n_ro_drw + state->n_wo_drw + state->n_rw_drw == 0) {
+		if (state->n_ro_dr + state->n_wo_dr + state->n_rw_dr == 0) {
+			newdeny_mode &= ~O_DENYREAD;
+			call_close |= test_bit(NFS_O_DENYREAD_STATE,
+					       &state->flags);
+			call_close |= test_bit(NFS_O_DENYRDWR_STATE,
+					       &state->flags);
+		}
+		if (state->n_ro_dw + state->n_wo_dw + state->n_rw_dw == 0) {
+			newdeny_mode &= ~O_DENYWRITE;
+			call_close |= test_bit(NFS_O_DENYWRITE_STATE,
+					       &state->flags);
+			call_close |= test_bit(NFS_O_DENYRDWR_STATE,
+					       &state->flags);
+		}
+	}
+	nfs4_state_set_mode_locked(state, newstate, newdeny_mode);
 	spin_unlock(&owner->so_lock);
 
 	if (!call_close) {
@@ -1541,6 +1562,10 @@ static void nfs4_clear_open_state(struct nfs4_state *state)
 	clear_bit(NFS_O_RDONLY_STATE, &state->flags);
 	clear_bit(NFS_O_WRONLY_STATE, &state->flags);
 	clear_bit(NFS_O_RDWR_STATE, &state->flags);
+	clear_bit(NFS_O_DENYNONE_STATE, &state->flags);
+	clear_bit(NFS_O_DENYREAD_STATE, &state->flags);
+	clear_bit(NFS_O_DENYWRITE_STATE, &state->flags);
+	clear_bit(NFS_O_DENYRDWR_STATE, &state->flags);
 	spin_lock(&state->state_lock);
 	list_for_each_entry(lock, &state->lock_states, ls_locks) {
 		lock->ls_seqid.flags = 0;
diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index 65ab0a0..1f91571 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -29,7 +29,8 @@ static struct file_system_type nfs4_remote_fs_type = {
 	.name		= "nfs4",
 	.mount		= nfs4_remote_mount,
 	.kill_sb	= nfs_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_BINARY_MOUNTDATA,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE | FS_BINARY_MOUNTDATA |
+			  FS_DOES_SHARELOCK,
 };
 
 static struct file_system_type nfs4_remote_referral_fs_type = {
@@ -37,7 +38,8 @@ static struct file_system_type nfs4_remote_referral_fs_type = {
 	.name		= "nfs4",
 	.mount		= nfs4_remote_referral_mount,
 	.kill_sb	= nfs_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_BINARY_MOUNTDATA,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE | FS_BINARY_MOUNTDATA |
+			  FS_DOES_SHARELOCK,
 };
 
 struct file_system_type nfs4_referral_fs_type = {
@@ -45,7 +47,8 @@ struct file_system_type nfs4_referral_fs_type = {
 	.name		= "nfs4",
 	.mount		= nfs4_referral_mount,
 	.kill_sb	= nfs_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_BINARY_MOUNTDATA,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE | FS_BINARY_MOUNTDATA |
+			  FS_DOES_SHARELOCK,
 };
 
 static const struct super_operations nfs4_sops = {
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index ed507f4..870d297 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1377,7 +1377,19 @@ static void encode_share_access(struct xdr_stream *xdr, fmode_t fmode,
 	default:
 		*p++ = cpu_to_be32(0);
 	}
-	*p = cpu_to_be32(0);		/* for linux, share_deny = 0 always */
+	switch (open_flags & (O_DENYREAD|O_DENYWRITE)) {
+	case O_DENYREAD:
+		*p = cpu_to_be32(NFS4_SHARE_DENY_READ);
+		break;
+	case O_DENYWRITE:
+		*p = cpu_to_be32(NFS4_SHARE_DENY_WRITE);
+		break;
+	case O_DENYREAD|O_DENYWRITE:
+		*p = cpu_to_be32(NFS4_SHARE_DENY_BOTH);
+		break;
+	default:
+		*p = cpu_to_be32(0);
+	}
 }
 
 static inline void encode_openhdr(struct xdr_stream *xdr, const struct nfs_openargs *arg)
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 910ed90..73bc4d8 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -333,7 +333,8 @@ struct file_system_type nfs4_fs_type = {
 	.name		= "nfs4",
 	.mount		= nfs_fs_mount,
 	.kill_sb	= nfs_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_BINARY_MOUNTDATA,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE | FS_BINARY_MOUNTDATA |
+			  FS_DOES_SHARELOCK,
 };
 MODULE_ALIAS_FS("nfs4");
 MODULE_ALIAS("nfs4");
@@ -2699,6 +2700,8 @@ nfs_xdev_mount(struct file_system_type *fs_type, int flags,
 	struct nfs_server *server;
 	struct dentry *mntroot = ERR_PTR(-ENOMEM);
 	struct nfs_subversion *nfs_mod = NFS_SB(data->sb)->nfs_client->cl_nfs_mod;
+	/* save sharelock option */
+	int sharelock = data->sb->s_flags & MS_SHARELOCK;
 
 	dprintk("--> nfs_xdev_mount()\n");
 
@@ -2710,7 +2713,7 @@ nfs_xdev_mount(struct file_system_type *fs_type, int flags,
 	if (IS_ERR(server))
 		mntroot = ERR_CAST(server);
 	else
-		mntroot = nfs_fs_mount_common(server, flags,
+		mntroot = nfs_fs_mount_common(server, flags | sharelock,
 				dev_name, &mount_info, nfs_mod);
 
 	dprintk("<-- nfs_xdev_mount() = %ld\n",
-- 
1.7.10.4

