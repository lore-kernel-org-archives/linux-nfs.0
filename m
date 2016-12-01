Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:33069 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757914AbcLAWTn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2016 17:19:43 -0500
Received: by mail-io0-f196.google.com with SMTP id j92so3935892ioi.0
        for <linux-nfs@vger.kernel.org>; Thu, 01 Dec 2016 14:19:43 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 19/26] pNFS: Enable layoutreturn operation for return-on-close
Date: Thu,  1 Dec 2016 17:19:15 -0500
Message-Id: <20161201221922.15657-20-trond.myklebust@primarydata.com>
In-Reply-To: <20161201221922.15657-19-trond.myklebust@primarydata.com>
References: <20161201221922.15657-1-trond.myklebust@primarydata.com>
 <20161201221922.15657-2-trond.myklebust@primarydata.com>
 <20161201221922.15657-3-trond.myklebust@primarydata.com>
 <20161201221922.15657-4-trond.myklebust@primarydata.com>
 <20161201221922.15657-5-trond.myklebust@primarydata.com>
 <20161201221922.15657-6-trond.myklebust@primarydata.com>
 <20161201221922.15657-7-trond.myklebust@primarydata.com>
 <20161201221922.15657-8-trond.myklebust@primarydata.com>
 <20161201221922.15657-9-trond.myklebust@primarydata.com>
 <20161201221922.15657-10-trond.myklebust@primarydata.com>
 <20161201221922.15657-11-trond.myklebust@primarydata.com>
 <20161201221922.15657-12-trond.myklebust@primarydata.com>
 <20161201221922.15657-13-trond.myklebust@primarydata.com>
 <20161201221922.15657-14-trond.myklebust@primarydata.com>
 <20161201221922.15657-15-trond.myklebust@primarydata.com>
 <20161201221922.15657-16-trond.myklebust@primarydata.com>
 <20161201221922.15657-17-trond.myklebust@primarydata.com>
 <20161201221922.15657-18-trond.myklebust@primarydata.com>
 <20161201221922.15657-19-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Amend the pnfs return on close helper functions to enable sending the
layoutreturn op in CLOSE/DELEGRETURN. This closes a potential race between
CLOSE/DELEGRETURN and parallel OPEN calls to the same file, and allows the
client and the server to agree on whether or not there is an outstanding
layout.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c |  45 ++++++++----------
 fs/nfs/pnfs.c     | 139 ++++++++++++++++++++++++------------------------------
 fs/nfs/pnfs.h     |  30 ++++++------
 3 files changed, 96 insertions(+), 118 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 765af663257a..221d97de0e2c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3052,7 +3052,8 @@ static void nfs4_free_closedata(void *data)
 	struct super_block *sb = calldata->state->inode->i_sb;
 
 	if (calldata->lr.roc)
-		pnfs_roc_release(calldata->state->inode);
+		pnfs_roc_release(&calldata->lr.arg, &calldata->lr.res,
+				calldata->res.lr_ret);
 	nfs4_put_open_state(calldata->state);
 	nfs_free_seqid(calldata->arg.seqid);
 	nfs4_put_state_owner(sp);
@@ -3103,9 +3104,6 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 	switch (task->tk_status) {
 		case 0:
 			res_stateid = &calldata->res.stateid;
-			if (calldata->lr.roc)
-				pnfs_roc_set_barrier(state->inode,
-						     calldata->lr.roc_barrier);
 			renew_lease(server, calldata->timestamp);
 			break;
 		case -NFS4ERR_ADMIN_REVOKED:
@@ -3181,7 +3179,7 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 		goto out_no_action;
 	}
 
-	if (!calldata->arg.lr_args && nfs4_wait_on_layoutreturn(inode, task)) {
+	if (!calldata->lr.roc && nfs4_wait_on_layoutreturn(inode, task)) {
 		nfs_release_seqid(calldata->arg.seqid);
 		goto out_wait;
 	}
@@ -3195,8 +3193,6 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 		else
 			calldata->arg.bitmask = NULL;
 	}
-	if (calldata->lr.roc)
-		pnfs_roc_get_barrier(inode, &calldata->lr.roc_barrier);
 
 	calldata->arg.share_access =
 		nfs4_map_atomic_open_share(NFS_SERVER(inode),
@@ -3223,13 +3219,6 @@ static const struct rpc_call_ops nfs4_close_ops = {
 	.rpc_release = nfs4_free_closedata,
 };
 
-static bool nfs4_roc(struct inode *inode)
-{
-	if (!nfs_have_layout(inode))
-		return false;
-	return pnfs_roc(inode);
-}
-
 /* 
  * It is possible for data to be read/written from a mem-mapped file 
  * after the sys_close call (which hits the vfs layer as a flush).
@@ -3281,7 +3270,12 @@ int nfs4_do_close(struct nfs4_state *state, gfp_t gfp_mask, int wait)
 	calldata->res.seqid = calldata->arg.seqid;
 	calldata->res.server = server;
 	calldata->res.lr_ret = -NFS4ERR_NOMATCHING_LAYOUT;
-	calldata->lr.roc = nfs4_roc(state->inode);
+	calldata->lr.roc = pnfs_roc(state->inode,
+			&calldata->lr.arg, &calldata->lr.res, msg.rpc_cred);
+	if (calldata->lr.roc) {
+		calldata->arg.lr_args = &calldata->lr.arg;
+		calldata->res.lr_res = &calldata->lr.res;
+	}
 	nfs_sb_active(calldata->inode->i_sb);
 
 	msg.rpc_argp = &calldata->arg;
@@ -5676,8 +5670,6 @@ static void nfs4_delegreturn_done(struct rpc_task *task, void *calldata)
 		}
 	}
 	data->rpc_status = task->tk_status;
-	if (data->lr.roc && data->rpc_status == 0)
-		pnfs_roc_set_barrier(data->inode, data->lr.roc_barrier);
 }
 
 static void nfs4_delegreturn_release(void *calldata)
@@ -5687,7 +5679,8 @@ static void nfs4_delegreturn_release(void *calldata)
 
 	if (inode) {
 		if (data->lr.roc)
-			pnfs_roc_release(inode);
+			pnfs_roc_release(&data->lr.arg, &data->lr.res,
+					data->res.lr_ret);
 		nfs_iput_and_deactive(inode);
 	}
 	kfree(calldata);
@@ -5699,13 +5692,9 @@ static void nfs4_delegreturn_prepare(struct rpc_task *task, void *data)
 
 	d_data = (struct nfs4_delegreturndata *)data;
 
-	if (!d_data->args.lr_args &&
-	    nfs4_wait_on_layoutreturn(d_data->inode, task))
+	if (!d_data->lr.roc && nfs4_wait_on_layoutreturn(d_data->inode, task))
 		return;
 
-	if (d_data->lr.roc)
-		pnfs_roc_get_barrier(d_data->inode, &d_data->lr.roc_barrier);
-
 	nfs4_setup_sequence(d_data->res.server,
 			&d_data->args.seq_args,
 			&d_data->res.seq_res,
@@ -5756,8 +5745,14 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
 	data->timestamp = jiffies;
 	data->rpc_status = 0;
 	data->inode = nfs_igrab_and_active(inode);
-	if (data->inode)
-		data->lr.roc = nfs4_roc(inode);
+	if (data->inode) {
+		data->lr.roc = pnfs_roc(inode, &data->lr.arg, &data->lr.res,
+				cred);
+		if (data->lr.roc) {
+			data->args.lr_args = &data->lr.arg;
+			data->res.lr_res = &data->lr.res;
+		}
+	}
 
 	task_setup_data.callback_data = data;
 	msg.rpc_argp = &data->args;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index a93afdd37203..f61cb81eb5ab 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -984,6 +984,20 @@ void pnfs_layoutreturn_free_lsegs(struct pnfs_layout_hdr *lo,
 
 }
 
+static void
+pnfs_set_plh_return_info(struct pnfs_layout_hdr *lo, enum pnfs_iomode iomode,
+			 u32 seq)
+{
+	if (lo->plh_return_iomode != 0 && lo->plh_return_iomode != iomode)
+		iomode = IOMODE_ANY;
+	lo->plh_return_iomode = iomode;
+	set_bit(NFS_LAYOUT_RETURN_REQUESTED, &lo->plh_flags);
+	if (seq != 0) {
+		WARN_ON_ONCE(lo->plh_return_seq != 0 && lo->plh_return_seq != seq);
+		lo->plh_return_seq = seq;
+	}
+}
+
 static bool
 pnfs_prepare_layoutreturn(struct pnfs_layout_hdr *lo,
 		nfs4_stateid *stateid,
@@ -1188,17 +1202,22 @@ pnfs_commit_and_return_layout(struct inode *inode)
 	return ret;
 }
 
-bool pnfs_roc(struct inode *ino)
+bool pnfs_roc(struct inode *ino,
+		struct nfs4_layoutreturn_args *args,
+		struct nfs4_layoutreturn_res *res,
+		const struct rpc_cred *cred)
 {
 	struct nfs_inode *nfsi = NFS_I(ino);
 	struct nfs_open_context *ctx;
 	struct nfs4_state *state;
 	struct pnfs_layout_hdr *lo;
-	struct pnfs_layout_segment *lseg, *tmp;
+	struct pnfs_layout_segment *lseg, *next;
 	nfs4_stateid stateid;
-	LIST_HEAD(tmp_list);
-	bool found = false, layoutreturn = false, roc = false;
+	enum pnfs_iomode iomode = 0;
+	bool layoutreturn = false, roc = false;
 
+	if (!nfs_have_layout(ino))
+		return false;
 	spin_lock(&ino->i_lock);
 	lo = nfsi->layout;
 	if (!lo || !pnfs_layout_is_valid(lo) ||
@@ -1217,83 +1236,63 @@ bool pnfs_roc(struct inode *ino)
 	}
 
 
-	list_for_each_entry_safe(lseg, tmp, &lo->plh_segs, pls_list) {
+	list_for_each_entry_safe(lseg, next, &lo->plh_segs, pls_list) {
 		/* If we are sending layoutreturn, invalidate all valid lsegs */
-		if (test_bit(NFS_LSEG_ROC, &lseg->pls_flags)) {
-			mark_lseg_invalid(lseg, &tmp_list);
-			found = true;
-		}
+		if (!test_and_clear_bit(NFS_LSEG_ROC, &lseg->pls_flags))
+			continue;
+		/*
+		 * Note: mark lseg for return so pnfs_layout_remove_lseg
+		 * doesn't invalidate the layout for us.
+		 */
+		set_bit(NFS_LSEG_LAYOUTRETURN, &lseg->pls_flags);
+		if (!mark_lseg_invalid(lseg, &lo->plh_return_segs))
+			continue;
+		pnfs_set_plh_return_info(lo, lseg->pls_range.iomode, 0);
 	}
 
-	/* always send layoutreturn if being marked so */
-	if (test_bit(NFS_LAYOUT_RETURN_REQUESTED, &lo->plh_flags)) {
-		layoutreturn = pnfs_prepare_layoutreturn(lo,
-				&stateid, NULL);
-		if (layoutreturn)
-			goto out_noroc;
-	}
+	if (!test_bit(NFS_LAYOUT_RETURN_REQUESTED, &lo->plh_flags))
+		goto out_noroc;
 
 	/* ROC in two conditions:
 	 * 1. there are ROC lsegs
 	 * 2. we don't send layoutreturn
 	 */
-	if (found) {
-		/* lo ref dropped in pnfs_roc_release() */
-		pnfs_get_layout_hdr(lo);
-		roc = true;
-	}
+	/* lo ref dropped in pnfs_roc_release() */
+	layoutreturn = pnfs_prepare_layoutreturn(lo, &stateid, &iomode);
+	/* If the creds don't match, we can't compound the layoutreturn */
+	if (!layoutreturn || cred != lo->plh_lc_cred)
+		goto out_noroc;
+
+	roc = layoutreturn;
+	pnfs_init_layoutreturn_args(args, lo, &stateid, iomode);
+	res->lrs_present = 0;
+	layoutreturn = false;
 
 out_noroc:
 	spin_unlock(&ino->i_lock);
-	pnfs_free_lseg_list(&tmp_list);
 	pnfs_layoutcommit_inode(ino, true);
 	if (layoutreturn)
-		pnfs_send_layoutreturn(lo, &stateid, IOMODE_ANY, true);
+		pnfs_send_layoutreturn(lo, &stateid, iomode, true);
 	return roc;
 }
 
-void pnfs_roc_release(struct inode *ino)
+void pnfs_roc_release(struct nfs4_layoutreturn_args *args,
+		struct nfs4_layoutreturn_res *res,
+		int ret)
 {
-	struct pnfs_layout_hdr *lo;
+	struct pnfs_layout_hdr *lo = args->layout;
+	const nfs4_stateid *arg_stateid = NULL;
+	const nfs4_stateid *res_stateid = NULL;
 
-	spin_lock(&ino->i_lock);
-	lo = NFS_I(ino)->layout;
-	pnfs_clear_layoutreturn_waitbit(lo);
-	if (atomic_dec_and_test(&lo->plh_refcount)) {
-		pnfs_detach_layout_hdr(lo);
-		spin_unlock(&ino->i_lock);
-		pnfs_free_layout_hdr(lo);
-	} else
-		spin_unlock(&ino->i_lock);
-}
-
-void pnfs_roc_set_barrier(struct inode *ino, u32 barrier)
-{
-	struct pnfs_layout_hdr *lo;
-
-	spin_lock(&ino->i_lock);
-	lo = NFS_I(ino)->layout;
-	if (pnfs_seqid_is_newer(barrier, lo->plh_barrier))
-		lo->plh_barrier = barrier;
-	spin_unlock(&ino->i_lock);
-	trace_nfs4_layoutreturn_on_close(ino, 0);
-}
-
-void pnfs_roc_get_barrier(struct inode *ino, u32 *barrier)
-{
-	struct nfs_inode *nfsi = NFS_I(ino);
-	struct pnfs_layout_hdr *lo;
-	u32 current_seqid;
-
-	spin_lock(&ino->i_lock);
-	lo = nfsi->layout;
-	current_seqid = be32_to_cpu(lo->plh_stateid.seqid);
-
-	/* Since close does not return a layout stateid for use as
-	 * a barrier, we choose the worst-case barrier.
-	 */
-	*barrier = current_seqid + atomic_read(&lo->plh_outstanding);
-	spin_unlock(&ino->i_lock);
+	if (ret == 0) {
+		arg_stateid = &args->stateid;
+		if (res->lrs_present)
+			res_stateid = &res->stateid;
+	}
+	pnfs_layoutreturn_free_lsegs(lo, arg_stateid, &args->range,
+			res_stateid);
+	pnfs_put_layout_hdr(lo);
+	trace_nfs4_layoutreturn_on_close(args->inode, 0);
 }
 
 bool pnfs_wait_on_layoutreturn(struct inode *ino, struct rpc_task *task)
@@ -1931,20 +1930,6 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 	return ERR_PTR(-EAGAIN);
 }
 
-static void
-pnfs_set_plh_return_info(struct pnfs_layout_hdr *lo, enum pnfs_iomode iomode,
-			 u32 seq)
-{
-	if (lo->plh_return_iomode != 0 && lo->plh_return_iomode != iomode)
-		iomode = IOMODE_ANY;
-	lo->plh_return_iomode = iomode;
-	set_bit(NFS_LAYOUT_RETURN_REQUESTED, &lo->plh_flags);
-	if (seq != 0) {
-		WARN_ON_ONCE(lo->plh_return_seq != 0 && lo->plh_return_seq != seq);
-		lo->plh_return_seq = seq;
-	}
-}
-
 /**
  * pnfs_mark_matching_lsegs_return - Free or return matching layout segments
  * @lo: pointer to layout header
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 75ff9392127f..f55c065664e1 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -271,10 +271,13 @@ int pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
 				u32 seq);
 int pnfs_mark_layout_stateid_invalid(struct pnfs_layout_hdr *lo,
 		struct list_head *lseg_list);
-bool pnfs_roc(struct inode *ino);
-void pnfs_roc_release(struct inode *ino);
-void pnfs_roc_set_barrier(struct inode *ino, u32 barrier);
-void pnfs_roc_get_barrier(struct inode *ino, u32 *barrier);
+bool pnfs_roc(struct inode *ino,
+		struct nfs4_layoutreturn_args *args,
+		struct nfs4_layoutreturn_res *res,
+		const struct rpc_cred *cred);
+void pnfs_roc_release(struct nfs4_layoutreturn_args *args,
+		struct nfs4_layoutreturn_res *res,
+		int ret);
 bool pnfs_wait_on_layoutreturn(struct inode *ino, struct rpc_task *task);
 void pnfs_set_layoutcommit(struct inode *, struct pnfs_layout_segment *, loff_t);
 void pnfs_cleanup_layoutcommit(struct nfs4_layoutcommit_data *data);
@@ -666,23 +669,18 @@ pnfs_layoutcommit_outstanding(struct inode *inode)
 
 
 static inline bool
-pnfs_roc(struct inode *ino)
+pnfs_roc(struct inode *ino,
+		struct nfs4_layoutreturn_args *args,
+		struct nfs4_layoutreturn_res *res,
+		const struct rpc_cred *cred)
 {
 	return false;
 }
 
 static inline void
-pnfs_roc_release(struct inode *ino)
-{
-}
-
-static inline void
-pnfs_roc_set_barrier(struct inode *ino, u32 barrier)
-{
-}
-
-static inline void
-pnfs_roc_get_barrier(struct inode *ino, u32 *barrier)
+pnfs_roc_release(struct nfs4_layoutreturn_args *args,
+		struct nfs4_layoutreturn_res *res,
+		int ret)
 {
 }
 
-- 
2.9.3

