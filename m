Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:19807 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755067Ab3CSNHu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Mar 2013 09:07:50 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 05/11] NFSv4: Resend the READ/WRITE RPC call if a stateid change causes an error
Date: Tue, 19 Mar 2013 09:07:37 -0400
Message-Id: <1363698463-3681-5-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1363698463-3681-4-git-send-email-Trond.Myklebust@netapp.com>
References: <1363698463-3681-1-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-2-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-3-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-4-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Adds logic to ensure that if the server returns a BAD_STATEID,
or other state related error, then we check if the stateid has
already changed. If it has, then rather than start state recovery,
we should just resend the failed RPC call with the new stateid.

Allow nfs4_select_rw_stateid to notify that the stateid is unstable by
having it return -EWOULDBLOCK if an RPC is underway that might change the
stateid.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4_fs.h   |  4 ++--
 fs/nfs/nfs4proc.c  | 64 +++++++++++++++++++++++++++++++++++++++++++++++++++---
 fs/nfs/nfs4state.c | 32 +++++++++++++++++++--------
 3 files changed, 86 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 8309e98..627a74f 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -234,7 +234,7 @@ extern struct rpc_clnt *nfs4_proc_lookup_mountpoint(struct inode *, struct qstr
 extern int nfs4_proc_secinfo(struct inode *, const struct qstr *, struct nfs4_secinfo_flavors *);
 extern int nfs4_release_lockowner(struct nfs4_lock_state *);
 extern const struct xattr_handler *nfs4_xattr_handlers[];
-extern void nfs4_set_rw_stateid(nfs4_stateid *stateid,
+extern int nfs4_set_rw_stateid(nfs4_stateid *stateid,
 		const struct nfs_open_context *ctx,
 		const struct nfs_lock_context *l_ctx,
 		fmode_t fmode);
@@ -358,7 +358,7 @@ extern void nfs41_handle_server_scope(struct nfs_client *,
 				      struct nfs41_server_scope **);
 extern void nfs4_put_lock_state(struct nfs4_lock_state *lsp);
 extern int nfs4_set_lock_state(struct nfs4_state *state, struct file_lock *fl);
-extern void nfs4_select_rw_stateid(nfs4_stateid *, struct nfs4_state *,
+extern int nfs4_select_rw_stateid(nfs4_stateid *, struct nfs4_state *,
 		fmode_t, const struct nfs_lockowner *);
 
 extern struct nfs_seqid *nfs_alloc_seqid(struct nfs_seqid_counter *counter, gfp_t gfp_mask);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index aaf935b..028bd52 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3454,7 +3454,7 @@ static int nfs4_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle,
 	return err;
 }
 
-void nfs4_set_rw_stateid(nfs4_stateid *stateid,
+int nfs4_set_rw_stateid(nfs4_stateid *stateid,
 		const struct nfs_open_context *ctx,
 		const struct nfs_lock_context *l_ctx,
 		fmode_t fmode)
@@ -3463,10 +3463,37 @@ void nfs4_set_rw_stateid(nfs4_stateid *stateid,
 
 	if (l_ctx != NULL)
 		lockowner = &l_ctx->lockowner;
-	nfs4_select_rw_stateid(stateid, ctx->state, fmode, lockowner);
+	return nfs4_select_rw_stateid(stateid, ctx->state, fmode, lockowner);
 }
 EXPORT_SYMBOL_GPL(nfs4_set_rw_stateid);
 
+static bool nfs4_stateid_is_current(nfs4_stateid *stateid,
+		const struct nfs_open_context *ctx,
+		const struct nfs_lock_context *l_ctx,
+		fmode_t fmode)
+{
+	nfs4_stateid current_stateid;
+
+	if (nfs4_set_rw_stateid(&current_stateid, ctx, l_ctx, fmode))
+		return false;
+	return nfs4_stateid_match(stateid, &current_stateid);
+}
+
+static bool nfs4_error_stateid_expired(int err)
+{
+	switch (err) {
+	case -NFS4ERR_DELEG_REVOKED:
+	case -NFS4ERR_ADMIN_REVOKED:
+	case -NFS4ERR_BAD_STATEID:
+	case -NFS4ERR_STALE_STATEID:
+	case -NFS4ERR_OLD_STATEID:
+	case -NFS4ERR_OPENMODE:
+	case -NFS4ERR_EXPIRED:
+		return true;
+	}
+	return false;
+}
+
 void __nfs4_read_done_cb(struct nfs_read_data *data)
 {
 	nfs_invalidate_atime(data->header->inode);
@@ -3487,6 +3514,20 @@ static int nfs4_read_done_cb(struct rpc_task *task, struct nfs_read_data *data)
 	return 0;
 }
 
+static bool nfs4_read_stateid_changed(struct rpc_task *task,
+		struct nfs_readargs *args)
+{
+
+	if (!nfs4_error_stateid_expired(task->tk_status) ||
+		nfs4_stateid_is_current(&args->stateid,
+				args->context,
+				args->lock_context,
+				FMODE_READ))
+		return false;
+	rpc_restart_call_prepare(task);
+	return true;
+}
+
 static int nfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
 {
 
@@ -3494,7 +3535,8 @@ static int nfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
 
 	if (!nfs4_sequence_done(task, &data->res.seq_res))
 		return -EAGAIN;
-
+	if (nfs4_read_stateid_changed(task, &data->args))
+		return -EAGAIN;
 	return data->read_done_cb ? data->read_done_cb(task, data) :
 				    nfs4_read_done_cb(task, data);
 }
@@ -3533,10 +3575,26 @@ static int nfs4_write_done_cb(struct rpc_task *task, struct nfs_write_data *data
 	return 0;
 }
 
+static bool nfs4_write_stateid_changed(struct rpc_task *task,
+		struct nfs_writeargs *args)
+{
+
+	if (!nfs4_error_stateid_expired(task->tk_status) ||
+		nfs4_stateid_is_current(&args->stateid,
+				args->context,
+				args->lock_context,
+				FMODE_WRITE))
+		return false;
+	rpc_restart_call_prepare(task);
+	return true;
+}
+
 static int nfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
 {
 	if (!nfs4_sequence_done(task, &data->res.seq_res))
 		return -EAGAIN;
+	if (nfs4_write_stateid_changed(task, &data->args))
+		return -EAGAIN;
 	return data->write_done_cb ? data->write_done_cb(task, data) :
 		nfs4_write_done_cb(task, data);
 }
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 8db102c..4e95bd7 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -989,13 +989,14 @@ int nfs4_set_lock_state(struct nfs4_state *state, struct file_lock *fl)
 	return 0;
 }
 
-static bool nfs4_copy_lock_stateid(nfs4_stateid *dst, struct nfs4_state *state,
+static int nfs4_copy_lock_stateid(nfs4_stateid *dst,
+		struct nfs4_state *state,
 		const struct nfs_lockowner *lockowner)
 {
 	struct nfs4_lock_state *lsp;
 	fl_owner_t fl_owner;
 	pid_t fl_pid;
-	bool ret = false;
+	int ret = -ENOENT;
 
 
 	if (lockowner == NULL)
@@ -1010,7 +1011,10 @@ static bool nfs4_copy_lock_stateid(nfs4_stateid *dst, struct nfs4_state *state,
 	lsp = __nfs4_find_lock_state(state, fl_owner, fl_pid, NFS4_ANY_LOCK_TYPE);
 	if (lsp != NULL && test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags) != 0) {
 		nfs4_stateid_copy(dst, &lsp->ls_stateid);
-		ret = true;
+		ret = 0;
+		smp_rmb();
+		if (!list_empty(&lsp->ls_seqid.list))
+			ret = -EWOULDBLOCK;
 	}
 	spin_unlock(&state->state_lock);
 	nfs4_put_lock_state(lsp);
@@ -1018,28 +1022,38 @@ out:
 	return ret;
 }
 
-static void nfs4_copy_open_stateid(nfs4_stateid *dst, struct nfs4_state *state)
+static int nfs4_copy_open_stateid(nfs4_stateid *dst, struct nfs4_state *state)
 {
+	int ret;
 	int seq;
 
 	do {
 		seq = read_seqbegin(&state->seqlock);
 		nfs4_stateid_copy(dst, &state->stateid);
+		ret = 0;
+		smp_rmb();
+		if (!list_empty(&state->owner->so_seqid.list))
+			ret = -EWOULDBLOCK;
 	} while (read_seqretry(&state->seqlock, seq));
+	return ret;
 }
 
 /*
  * Byte-range lock aware utility to initialize the stateid of read/write
  * requests.
  */
-void nfs4_select_rw_stateid(nfs4_stateid *dst, struct nfs4_state *state,
+int nfs4_select_rw_stateid(nfs4_stateid *dst, struct nfs4_state *state,
 		fmode_t fmode, const struct nfs_lockowner *lockowner)
 {
+	int ret = 0;
 	if (nfs4_copy_delegation_stateid(dst, state->inode, fmode))
-		return;
-	if (nfs4_copy_lock_stateid(dst, state, lockowner))
-		return;
-	nfs4_copy_open_stateid(dst, state);
+		goto out;
+	ret = nfs4_copy_lock_stateid(dst, state, lockowner);
+	if (ret != -ENOENT)
+		goto out;
+	ret = nfs4_copy_open_stateid(dst, state);
+out:
+	return ret;
 }
 
 struct nfs_seqid *nfs_alloc_seqid(struct nfs_seqid_counter *counter, gfp_t gfp_mask)
-- 
1.8.1.4

