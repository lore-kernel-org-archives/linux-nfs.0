Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:25852 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753067Ab0EMVIY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 May 2010 17:08:24 -0400
Received: from localhost.localdomain (heimdal.trondhjem.org [10.58.49.73] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o4DL8MCL021257
	for <linux-nfs@vger.kernel.org>; Thu, 13 May 2010 14:08:23 -0700 (PDT)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 02/15] NFSv4: Don't use GFP_KERNEL allocations in state recovery
Date: Thu, 13 May 2010 17:08:08 -0400
Message-Id: <1273784901-25599-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1273784901-25599-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1273784901-25599-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

We do not want to have the state recovery thread kick off and wait for a
memory reclaim, since that may deadlock when the writebacks end up
waiting for the state recovery thread to complete.

The safe thing is therefore to use GFP_NOFS in all open, close,
delegation return, lock, etc. operations that may be called by the
state recovery thread.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/delegation.c |    2 +-
 fs/nfs/nfs4_fs.h    |    4 ++--
 fs/nfs/nfs4proc.c   |   47 +++++++++++++++++++++++++----------------------
 fs/nfs/nfs4state.c  |   21 +++++++++++----------
 4 files changed, 39 insertions(+), 35 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index ea61d26..3016345 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -213,7 +213,7 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
 	struct nfs_delegation *freeme = NULL;
 	int status = 0;
 
-	delegation = kmalloc(sizeof(*delegation), GFP_KERNEL);
+	delegation = kmalloc(sizeof(*delegation), GFP_NOFS);
 	if (delegation == NULL)
 		return -ENOMEM;
 	memcpy(delegation->stateid.data, res->delegation.data,
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 5099306..c538c61 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -213,7 +213,7 @@ extern int nfs4_proc_async_renew(struct nfs_client *, struct rpc_cred *);
 extern int nfs4_proc_renew(struct nfs_client *, struct rpc_cred *);
 extern int nfs4_init_clientid(struct nfs_client *, struct rpc_cred *);
 extern int nfs41_init_clientid(struct nfs_client *, struct rpc_cred *);
-extern int nfs4_do_close(struct path *path, struct nfs4_state *state, int wait);
+extern int nfs4_do_close(struct path *path, struct nfs4_state *state, gfp_t gfp_mask, int wait);
 extern struct dentry *nfs4_atomic_open(struct inode *, struct dentry *, struct nameidata *);
 extern int nfs4_open_revalidate(struct inode *, struct dentry *, int, struct nameidata *);
 extern int nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fhandle);
@@ -286,7 +286,7 @@ extern void nfs4_put_lock_state(struct nfs4_lock_state *lsp);
 extern int nfs4_set_lock_state(struct nfs4_state *state, struct file_lock *fl);
 extern void nfs4_copy_stateid(nfs4_stateid *, struct nfs4_state *, fl_owner_t);
 
-extern struct nfs_seqid *nfs_alloc_seqid(struct nfs_seqid_counter *counter);
+extern struct nfs_seqid *nfs_alloc_seqid(struct nfs_seqid_counter *counter, gfp_t gfp_mask);
 extern int nfs_wait_on_sequence(struct nfs_seqid *seqid, struct rpc_task *task);
 extern void nfs_increment_open_seqid(int status, struct nfs_seqid *seqid);
 extern void nfs_increment_lock_seqid(int status, struct nfs_seqid *seqid);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9998c29..70015dd 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -717,17 +717,18 @@ static void nfs4_init_opendata_res(struct nfs4_opendata *p)
 
 static struct nfs4_opendata *nfs4_opendata_alloc(struct path *path,
 		struct nfs4_state_owner *sp, fmode_t fmode, int flags,
-		const struct iattr *attrs)
+		const struct iattr *attrs,
+		gfp_t gfp_mask)
 {
 	struct dentry *parent = dget_parent(path->dentry);
 	struct inode *dir = parent->d_inode;
 	struct nfs_server *server = NFS_SERVER(dir);
 	struct nfs4_opendata *p;
 
-	p = kzalloc(sizeof(*p), GFP_KERNEL);
+	p = kzalloc(sizeof(*p), gfp_mask);
 	if (p == NULL)
 		goto err;
-	p->o_arg.seqid = nfs_alloc_seqid(&sp->so_seqid);
+	p->o_arg.seqid = nfs_alloc_seqid(&sp->so_seqid, gfp_mask);
 	if (p->o_arg.seqid == NULL)
 		goto err_free;
 	path_get(path);
@@ -1063,7 +1064,7 @@ static struct nfs4_opendata *nfs4_open_recoverdata_alloc(struct nfs_open_context
 {
 	struct nfs4_opendata *opendata;
 
-	opendata = nfs4_opendata_alloc(&ctx->path, state->owner, 0, 0, NULL);
+	opendata = nfs4_opendata_alloc(&ctx->path, state->owner, 0, 0, NULL, GFP_NOFS);
 	if (opendata == NULL)
 		return ERR_PTR(-ENOMEM);
 	opendata->state = state;
@@ -1651,7 +1652,7 @@ static int _nfs4_do_open(struct inode *dir, struct path *path, fmode_t fmode, in
 	if (path->dentry->d_inode != NULL)
 		nfs4_return_incompatible_delegation(path->dentry->d_inode, fmode);
 	status = -ENOMEM;
-	opendata = nfs4_opendata_alloc(path, sp, fmode, flags, sattr);
+	opendata = nfs4_opendata_alloc(path, sp, fmode, flags, sattr, GFP_KERNEL);
 	if (opendata == NULL)
 		goto err_put_state_owner;
 
@@ -1926,7 +1927,7 @@ static const struct rpc_call_ops nfs4_close_ops = {
  *
  * NOTE: Caller must be holding the sp->so_owner semaphore!
  */
-int nfs4_do_close(struct path *path, struct nfs4_state *state, int wait)
+int nfs4_do_close(struct path *path, struct nfs4_state *state, gfp_t gfp_mask, int wait)
 {
 	struct nfs_server *server = NFS_SERVER(state->inode);
 	struct nfs4_closedata *calldata;
@@ -1945,7 +1946,7 @@ int nfs4_do_close(struct path *path, struct nfs4_state *state, int wait)
 	};
 	int status = -ENOMEM;
 
-	calldata = kzalloc(sizeof(*calldata), GFP_KERNEL);
+	calldata = kzalloc(sizeof(*calldata), gfp_mask);
 	if (calldata == NULL)
 		goto out;
 	calldata->inode = state->inode;
@@ -1953,7 +1954,7 @@ int nfs4_do_close(struct path *path, struct nfs4_state *state, int wait)
 	calldata->arg.fh = NFS_FH(state->inode);
 	calldata->arg.stateid = &state->open_stateid;
 	/* Serialization for the sequence id */
-	calldata->arg.seqid = nfs_alloc_seqid(&state->owner->so_seqid);
+	calldata->arg.seqid = nfs_alloc_seqid(&state->owner->so_seqid, gfp_mask);
 	if (calldata->arg.seqid == NULL)
 		goto out_free_calldata;
 	calldata->arg.fmode = 0;
@@ -3704,7 +3705,7 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
 	};
 	int status = 0;
 
-	data = kzalloc(sizeof(*data), GFP_KERNEL);
+	data = kzalloc(sizeof(*data), GFP_NOFS);
 	if (data == NULL)
 		return -ENOMEM;
 	data->args.fhandle = &data->fh;
@@ -3860,7 +3861,7 @@ static struct nfs4_unlockdata *nfs4_alloc_unlockdata(struct file_lock *fl,
 	struct nfs4_unlockdata *p;
 	struct inode *inode = lsp->ls_state->inode;
 
-	p = kzalloc(sizeof(*p), GFP_KERNEL);
+	p = kzalloc(sizeof(*p), GFP_NOFS);
 	if (p == NULL)
 		return NULL;
 	p->arg.fh = NFS_FH(inode);
@@ -3998,7 +3999,7 @@ static int nfs4_proc_unlck(struct nfs4_state *state, int cmd, struct file_lock *
 	if (test_bit(NFS_DELEGATED_STATE, &state->flags))
 		goto out;
 	lsp = request->fl_u.nfs4_fl.owner;
-	seqid = nfs_alloc_seqid(&lsp->ls_seqid);
+	seqid = nfs_alloc_seqid(&lsp->ls_seqid, GFP_KERNEL);
 	status = -ENOMEM;
 	if (seqid == NULL)
 		goto out;
@@ -4026,22 +4027,23 @@ struct nfs4_lockdata {
 };
 
 static struct nfs4_lockdata *nfs4_alloc_lockdata(struct file_lock *fl,
-		struct nfs_open_context *ctx, struct nfs4_lock_state *lsp)
+		struct nfs_open_context *ctx, struct nfs4_lock_state *lsp,
+		gfp_t gfp_mask)
 {
 	struct nfs4_lockdata *p;
 	struct inode *inode = lsp->ls_state->inode;
 	struct nfs_server *server = NFS_SERVER(inode);
 
-	p = kzalloc(sizeof(*p), GFP_KERNEL);
+	p = kzalloc(sizeof(*p), gfp_mask);
 	if (p == NULL)
 		return NULL;
 
 	p->arg.fh = NFS_FH(inode);
 	p->arg.fl = &p->fl;
-	p->arg.open_seqid = nfs_alloc_seqid(&lsp->ls_state->owner->so_seqid);
+	p->arg.open_seqid = nfs_alloc_seqid(&lsp->ls_state->owner->so_seqid, gfp_mask);
 	if (p->arg.open_seqid == NULL)
 		goto out_free;
-	p->arg.lock_seqid = nfs_alloc_seqid(&lsp->ls_seqid);
+	p->arg.lock_seqid = nfs_alloc_seqid(&lsp->ls_seqid, gfp_mask);
 	if (p->arg.lock_seqid == NULL)
 		goto out_free_seqid;
 	p->arg.lock_stateid = &lsp->ls_stateid;
@@ -4195,7 +4197,8 @@ static int _nfs4_do_setlk(struct nfs4_state *state, int cmd, struct file_lock *f
 
 	dprintk("%s: begin!\n", __func__);
 	data = nfs4_alloc_lockdata(fl, nfs_file_open_context(fl->fl_file),
-			fl->fl_u.nfs4_fl.owner);
+			fl->fl_u.nfs4_fl.owner,
+			recovery_type == NFS_LOCK_NEW ? GFP_KERNEL : GFP_NOFS);
 	if (data == NULL)
 		return -ENOMEM;
 	if (IS_SETLKW(cmd))
@@ -4684,7 +4687,7 @@ static int nfs4_reset_slot_table(struct nfs4_slot_table *tbl, u32 max_reqs,
 	if (max_reqs != tbl->max_slots) {
 		ret = -ENOMEM;
 		new = kmalloc(max_reqs * sizeof(struct nfs4_slot),
-			      GFP_KERNEL);
+			      GFP_NOFS);
 		if (!new)
 			goto out;
 		ret = 0;
@@ -4749,7 +4752,7 @@ static int nfs4_init_slot_table(struct nfs4_slot_table *tbl,
 
 	dprintk("--> %s: max_reqs=%u\n", __func__, max_slots);
 
-	slot = kcalloc(max_slots, sizeof(struct nfs4_slot), GFP_KERNEL);
+	slot = kcalloc(max_slots, sizeof(struct nfs4_slot), GFP_NOFS);
 	if (!slot)
 		goto out;
 	ret = 0;
@@ -4798,7 +4801,7 @@ struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp)
 	struct nfs4_session *session;
 	struct nfs4_slot_table *tbl;
 
-	session = kzalloc(sizeof(struct nfs4_session), GFP_KERNEL);
+	session = kzalloc(sizeof(struct nfs4_session), GFP_NOFS);
 	if (!session)
 		return NULL;
 
@@ -5142,8 +5145,8 @@ static int nfs41_proc_async_sequence(struct nfs_client *clp,
 
 	if (!atomic_inc_not_zero(&clp->cl_count))
 		return -EIO;
-	args = kzalloc(sizeof(*args), GFP_KERNEL);
-	res = kzalloc(sizeof(*res), GFP_KERNEL);
+	args = kzalloc(sizeof(*args), GFP_NOFS);
+	res = kzalloc(sizeof(*res), GFP_NOFS);
 	if (!args || !res) {
 		kfree(args);
 		kfree(res);
@@ -5244,7 +5247,7 @@ static int nfs41_proc_reclaim_complete(struct nfs_client *clp)
 	int status = -ENOMEM;
 
 	dprintk("--> %s\n", __func__);
-	calldata = kzalloc(sizeof(*calldata), GFP_KERNEL);
+	calldata = kzalloc(sizeof(*calldata), GFP_NOFS);
 	if (calldata == NULL)
 		goto out;
 	calldata->clp = clp;
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index cd2d904..34acf59 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -366,7 +366,7 @@ nfs4_alloc_state_owner(void)
 {
 	struct nfs4_state_owner *sp;
 
-	sp = kzalloc(sizeof(*sp),GFP_KERNEL);
+	sp = kzalloc(sizeof(*sp),GFP_NOFS);
 	if (!sp)
 		return NULL;
 	spin_lock_init(&sp->so_lock);
@@ -440,7 +440,7 @@ nfs4_alloc_open_state(void)
 {
 	struct nfs4_state *state;
 
-	state = kzalloc(sizeof(*state), GFP_KERNEL);
+	state = kzalloc(sizeof(*state), GFP_NOFS);
 	if (!state)
 		return NULL;
 	atomic_set(&state->count, 1);
@@ -542,7 +542,8 @@ void nfs4_put_open_state(struct nfs4_state *state)
 /*
  * Close the current file.
  */
-static void __nfs4_close(struct path *path, struct nfs4_state *state, fmode_t fmode, int wait)
+static void __nfs4_close(struct path *path, struct nfs4_state *state,
+		fmode_t fmode, gfp_t gfp_mask, int wait)
 {
 	struct nfs4_state_owner *owner = state->owner;
 	int call_close = 0;
@@ -583,17 +584,17 @@ static void __nfs4_close(struct path *path, struct nfs4_state *state, fmode_t fm
 		nfs4_put_open_state(state);
 		nfs4_put_state_owner(owner);
 	} else
-		nfs4_do_close(path, state, wait);
+		nfs4_do_close(path, state, gfp_mask, wait);
 }
 
 void nfs4_close_state(struct path *path, struct nfs4_state *state, fmode_t fmode)
 {
-	__nfs4_close(path, state, fmode, 0);
+	__nfs4_close(path, state, fmode, GFP_NOFS, 0);
 }
 
 void nfs4_close_sync(struct path *path, struct nfs4_state *state, fmode_t fmode)
 {
-	__nfs4_close(path, state, fmode, 1);
+	__nfs4_close(path, state, fmode, GFP_KERNEL, 1);
 }
 
 /*
@@ -623,7 +624,7 @@ static struct nfs4_lock_state *nfs4_alloc_lock_state(struct nfs4_state *state, f
 	struct nfs4_lock_state *lsp;
 	struct nfs_client *clp = state->owner->so_client;
 
-	lsp = kzalloc(sizeof(*lsp), GFP_KERNEL);
+	lsp = kzalloc(sizeof(*lsp), GFP_NOFS);
 	if (lsp == NULL)
 		return NULL;
 	rpc_init_wait_queue(&lsp->ls_sequence.wait, "lock_seqid_waitqueue");
@@ -759,11 +760,11 @@ void nfs4_copy_stateid(nfs4_stateid *dst, struct nfs4_state *state, fl_owner_t f
 	nfs4_put_lock_state(lsp);
 }
 
-struct nfs_seqid *nfs_alloc_seqid(struct nfs_seqid_counter *counter)
+struct nfs_seqid *nfs_alloc_seqid(struct nfs_seqid_counter *counter, gfp_t gfp_mask)
 {
 	struct nfs_seqid *new;
 
-	new = kmalloc(sizeof(*new), GFP_KERNEL);
+	new = kmalloc(sizeof(*new), gfp_mask);
 	if (new != NULL) {
 		new->sequence = counter;
 		INIT_LIST_HEAD(&new->list);
@@ -1352,7 +1353,7 @@ static int nfs4_recall_slot(struct nfs_client *clp)
 
 	nfs4_begin_drain_session(clp);
 	new = kmalloc(fc_tbl->target_max_slots * sizeof(struct nfs4_slot),
-		      GFP_KERNEL);
+		      GFP_NOFS);
         if (!new)
 		return -ENOMEM;
 
-- 
1.6.6.1

