Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:18904 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756788Ab2CEQue (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Mar 2012 11:50:34 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 08/16] NFSv4: Add helpers for basic copying of stateids
Date: Mon,  5 Mar 2012 11:50:13 -0500
Message-Id: <1330966221-17164-8-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1330966221-17164-7-git-send-email-Trond.Myklebust@netapp.com>
References: <1330966221-17164-1-git-send-email-Trond.Myklebust@netapp.com>
 <1330966221-17164-2-git-send-email-Trond.Myklebust@netapp.com>
 <1330966221-17164-3-git-send-email-Trond.Myklebust@netapp.com>
 <1330966221-17164-4-git-send-email-Trond.Myklebust@netapp.com>
 <1330966221-17164-5-git-send-email-Trond.Myklebust@netapp.com>
 <1330966221-17164-6-git-send-email-Trond.Myklebust@netapp.com>
 <1330966221-17164-7-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/delegation.c |   10 ++++------
 fs/nfs/nfs4_fs.h    |   10 ++++++++++
 fs/nfs/nfs4proc.c   |   34 +++++++++++++++-------------------
 fs/nfs/nfs4state.c  |    4 ++--
 fs/nfs/pnfs.c       |   10 ++++------
 5 files changed, 35 insertions(+), 33 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 9722e15..6502e59 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -105,7 +105,7 @@ again:
 			continue;
 		if (!test_bit(NFS_DELEGATED_STATE, &state->flags))
 			continue;
-		if (memcmp(state->stateid.data, stateid->data, sizeof(state->stateid.data)) != 0)
+		if (!nfs4_stateid_match(&state->stateid, stateid))
 			continue;
 		get_nfs_open_context(ctx);
 		spin_unlock(&inode->i_lock);
@@ -139,8 +139,7 @@ void nfs_inode_reclaim_delegation(struct inode *inode, struct rpc_cred *cred,
 	if (delegation != NULL) {
 		spin_lock(&delegation->lock);
 		if (delegation->inode != NULL) {
-			memcpy(delegation->stateid.data, res->delegation.data,
-			       sizeof(delegation->stateid.data));
+			nfs4_stateid_copy(&delegation->stateid, &res->delegation);
 			delegation->type = res->delegation_type;
 			delegation->maxsize = res->maxsize;
 			oldcred = delegation->cred;
@@ -236,8 +235,7 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
 	delegation = kmalloc(sizeof(*delegation), GFP_NOFS);
 	if (delegation == NULL)
 		return -ENOMEM;
-	memcpy(delegation->stateid.data, res->delegation.data,
-			sizeof(delegation->stateid.data));
+	nfs4_stateid_copy(&delegation->stateid, &res->delegation);
 	delegation->type = res->delegation_type;
 	delegation->maxsize = res->maxsize;
 	delegation->change_attr = inode->i_version;
@@ -697,7 +695,7 @@ int nfs4_copy_delegation_stateid(nfs4_stateid *dst, struct inode *inode)
 	rcu_read_lock();
 	delegation = rcu_dereference(nfsi->delegation);
 	if (delegation != NULL) {
-		memcpy(dst->data, delegation->stateid.data, sizeof(dst->data));
+		nfs4_stateid_copy(dst, &delegation->stateid);
 		ret = 1;
 	}
 	rcu_read_unlock();
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index e76f17c..f4cafab 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -347,6 +347,16 @@ struct nfs4_mount_data;
 extern struct svc_version nfs4_callback_version1;
 extern struct svc_version nfs4_callback_version4;
 
+static inline void nfs4_stateid_copy(nfs4_stateid *dst, const nfs4_stateid *src)
+{
+	memcpy(dst->data, src->data, sizeof(dst->data));
+}
+
+static inline bool nfs4_stateid_match(const nfs4_stateid *dst, const nfs4_stateid *src)
+{
+	return memcmp(dst->data, src->data, sizeof(dst->data)) == 0;
+}
+
 #else
 
 #define nfs4_close_state(a, b) do { } while (0)
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9200327..3e65766 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -938,8 +938,8 @@ static void update_open_stateflags(struct nfs4_state *state, fmode_t fmode)
 static void nfs_set_open_stateid_locked(struct nfs4_state *state, nfs4_stateid *stateid, fmode_t fmode)
 {
 	if (test_bit(NFS_DELEGATED_STATE, &state->flags) == 0)
-		memcpy(state->stateid.data, stateid->data, sizeof(state->stateid.data));
-	memcpy(state->open_stateid.data, stateid->data, sizeof(state->open_stateid.data));
+		nfs4_stateid_copy(&state->stateid, stateid);
+	nfs4_stateid_copy(&state->open_stateid, stateid);
 	switch (fmode) {
 		case FMODE_READ:
 			set_bit(NFS_O_RDONLY_STATE, &state->flags);
@@ -967,7 +967,7 @@ static void __update_open_stateid(struct nfs4_state *state, nfs4_stateid *open_s
 	 */
 	write_seqlock(&state->seqlock);
 	if (deleg_stateid != NULL) {
-		memcpy(state->stateid.data, deleg_stateid->data, sizeof(state->stateid.data));
+		nfs4_stateid_copy(&state->stateid, deleg_stateid);
 		set_bit(NFS_DELEGATED_STATE, &state->flags);
 	}
 	if (open_stateid != NULL)
@@ -998,7 +998,7 @@ static int update_open_stateid(struct nfs4_state *state, nfs4_stateid *open_stat
 
 	if (delegation == NULL)
 		delegation = &deleg_cur->stateid;
-	else if (memcmp(deleg_cur->stateid.data, delegation->data, NFS4_STATEID_SIZE) != 0)
+	else if (!nfs4_stateid_match(&deleg_cur->stateid, delegation))
 		goto no_delegation_unlock;
 
 	nfs_mark_delegation_referenced(deleg_cur);
@@ -1059,7 +1059,7 @@ static struct nfs4_state *nfs4_try_open_cached(struct nfs4_opendata *opendata)
 			break;
 		}
 		/* Save the delegation */
-		memcpy(stateid.data, delegation->stateid.data, sizeof(stateid.data));
+		nfs4_stateid_copy(&stateid, &delegation->stateid);
 		rcu_read_unlock();
 		ret = nfs_may_open(state->inode, state->owner->so_cred, open_mode);
 		if (ret != 0)
@@ -1222,10 +1222,10 @@ static int nfs4_open_recover(struct nfs4_opendata *opendata, struct nfs4_state *
 	 * Check if we need to update the current stateid.
 	 */
 	if (test_bit(NFS_DELEGATED_STATE, &state->flags) == 0 &&
-	    memcmp(state->stateid.data, state->open_stateid.data, sizeof(state->stateid.data)) != 0) {
+	    !nfs4_stateid_match(&state->stateid, &state->open_stateid)) {
 		write_seqlock(&state->seqlock);
 		if (test_bit(NFS_DELEGATED_STATE, &state->flags) == 0)
-			memcpy(state->stateid.data, state->open_stateid.data, sizeof(state->stateid.data));
+			nfs4_stateid_copy(&state->stateid, &state->open_stateid);
 		write_sequnlock(&state->seqlock);
 	}
 	return 0;
@@ -1294,8 +1294,7 @@ static int _nfs4_open_delegation_recall(struct nfs_open_context *ctx, struct nfs
 	if (IS_ERR(opendata))
 		return PTR_ERR(opendata);
 	opendata->o_arg.claim = NFS4_OPEN_CLAIM_DELEGATE_CUR;
-	memcpy(opendata->o_arg.u.delegation.data, stateid->data,
-			sizeof(opendata->o_arg.u.delegation.data));
+	nfs4_stateid_copy(&opendata->o_arg.u.delegation, stateid);
 	ret = nfs4_open_recover(opendata, state);
 	nfs4_opendata_put(opendata);
 	return ret;
@@ -1357,8 +1356,7 @@ static void nfs4_open_confirm_done(struct rpc_task *task, void *calldata)
 
 	data->rpc_status = task->tk_status;
 	if (data->rpc_status == 0) {
-		memcpy(data->o_res.stateid.data, data->c_res.stateid.data,
-				sizeof(data->o_res.stateid.data));
+		nfs4_stateid_copy(&data->o_res.stateid, &data->c_res.stateid);
 		nfs_confirm_seqid(&data->owner->so_seqid, 0);
 		renew_lease(data->o_res.server, data->timestamp);
 		data->rpc_done = 1;
@@ -1918,7 +1916,7 @@ static int _nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 	} else if (state != NULL) {
 		nfs4_select_rw_stateid(&arg.stateid, state, current->files, current->tgid);
 	} else
-		memcpy(&arg.stateid, &zero_stateid, sizeof(arg.stateid));
+		nfs4_stateid_copy(&arg.stateid, &zero_stateid);
 
 	status = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
 	if (status == 0 && state != NULL)
@@ -3978,7 +3976,7 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
 	data->args.stateid = &data->stateid;
 	data->args.bitmask = server->attr_bitmask;
 	nfs_copy_fh(&data->fh, NFS_FH(inode));
-	memcpy(&data->stateid, stateid, sizeof(data->stateid));
+	nfs4_stateid_copy(&data->stateid, stateid);
 	data->res.fattr = &data->fattr;
 	data->res.server = server;
 	nfs_fattr_init(data->res.fattr);
@@ -4161,9 +4159,8 @@ static void nfs4_locku_done(struct rpc_task *task, void *data)
 		return;
 	switch (task->tk_status) {
 		case 0:
-			memcpy(calldata->lsp->ls_stateid.data,
-					calldata->res.stateid.data,
-					sizeof(calldata->lsp->ls_stateid.data));
+			nfs4_stateid_copy(&calldata->lsp->ls_stateid,
+					&calldata->res.stateid);
 			renew_lease(calldata->server, calldata->timestamp);
 			break;
 		case -NFS4ERR_BAD_STATEID:
@@ -4376,8 +4373,7 @@ static void nfs4_lock_done(struct rpc_task *task, void *calldata)
 			goto out;
 	}
 	if (data->rpc_status == 0) {
-		memcpy(data->lsp->ls_stateid.data, data->res.stateid.data,
-					sizeof(data->lsp->ls_stateid.data));
+		nfs4_stateid_copy(&data->lsp->ls_stateid, &data->res.stateid);
 		data->lsp->ls_flags |= NFS_LOCK_INITIALIZED;
 		renew_lease(NFS_SERVER(data->ctx->dentry->d_inode), data->timestamp);
 	}
@@ -6278,7 +6274,7 @@ static bool nfs41_match_stateid(const nfs4_stateid *s1,
 static bool nfs4_match_stateid(const nfs4_stateid *s1,
 		const nfs4_stateid *s2)
 {
-	return memcmp(s1->data, s2->data, sizeof(s1->data)) == 0;
+	return nfs4_stateid_match(s1, s2);
 }
 
 
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index b59b39e..41e2b44 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -895,7 +895,7 @@ void nfs4_select_rw_stateid(nfs4_stateid *dst, struct nfs4_state *state, fl_owne
 
 	do {
 		seq = read_seqbegin(&state->seqlock);
-		memcpy(dst, &state->stateid, sizeof(*dst));
+		nfs4_stateid_copy(dst, &state->stateid);
 	} while (read_seqretry(&state->seqlock, seq));
 	if (test_bit(LK_STATE_IN_USE, &state->flags) == 0)
 		return;
@@ -903,7 +903,7 @@ void nfs4_select_rw_stateid(nfs4_stateid *dst, struct nfs4_state *state, fl_owne
 	spin_lock(&state->state_lock);
 	lsp = __nfs4_find_lock_state(state, fl_owner, fl_pid, NFS4_ANY_LOCK_TYPE);
 	if (lsp != NULL && (lsp->ls_flags & NFS_LOCK_INITIALIZED) != 0)
-		memcpy(dst, &lsp->ls_stateid, sizeof(*dst));
+		nfs4_stateid_copy(dst, &lsp->ls_stateid);
 	spin_unlock(&state->state_lock);
 	nfs4_put_lock_state(lsp);
 }
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 402efc2..c190e9c 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -499,7 +499,7 @@ pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo, const nfs4_stateid *new,
 	oldseq = be32_to_cpu(lo->plh_stateid.stateid.seqid);
 	newseq = be32_to_cpu(new->stateid.seqid);
 	if ((int)(newseq - oldseq) > 0) {
-		memcpy(&lo->plh_stateid, &new->stateid, sizeof(new->stateid));
+		nfs4_stateid_copy(&lo->plh_stateid, new);
 		if (update_barrier) {
 			u32 new_barrier = be32_to_cpu(new->stateid.seqid);
 
@@ -549,11 +549,10 @@ pnfs_choose_layoutget_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
 
 		do {
 			seq = read_seqbegin(&open_state->seqlock);
-			memcpy(dst->data, open_state->stateid.data,
-			       sizeof(open_state->stateid.data));
+			nfs4_stateid_copy(dst, &open_state->stateid);
 		} while (read_seqretry(&open_state->seqlock, seq));
 	} else
-		memcpy(dst->data, lo->plh_stateid.data, sizeof(lo->plh_stateid.data));
+		nfs4_stateid_copy(dst, &lo->plh_stateid);
 	spin_unlock(&lo->plh_inode->i_lock);
 	dprintk("<-- %s\n", __func__);
 	return status;
@@ -1527,8 +1526,7 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 	end_pos = nfsi->layout->plh_lwb;
 	nfsi->layout->plh_lwb = 0;
 
-	memcpy(&data->args.stateid.data, nfsi->layout->plh_stateid.data,
-		sizeof(nfsi->layout->plh_stateid.data));
+	nfs4_stateid_copy(&data->args.stateid, &nfsi->layout->plh_stateid);
 	spin_unlock(&inode->i_lock);
 
 	data->args.inode = inode;
-- 
1.7.7.6

