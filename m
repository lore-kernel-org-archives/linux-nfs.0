Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:36376 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756059AbcH1WZH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 28 Aug 2016 18:25:07 -0400
Received: by mail-it0-f68.google.com with SMTP id x131so5030018ite.3
        for <linux-nfs@vger.kernel.org>; Sun, 28 Aug 2016 15:25:06 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/5] NFSv4.1: Close callback races for OPEN, LAYOUTGET and LAYOUTRETURN
Date: Sun, 28 Aug 2016 18:21:04 -0400
Message-Id: <1472422865-28698-5-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1472422865-28698-4-git-send-email-trond.myklebust@primarydata.com>
References: <1472422865-28698-1-git-send-email-trond.myklebust@primarydata.com>
 <1472422865-28698-2-git-send-email-trond.myklebust@primarydata.com>
 <1472422865-28698-3-git-send-email-trond.myklebust@primarydata.com>
 <1472422865-28698-4-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Defer freeing the slot until after we have processed the results from
OPEN and LAYOUTGET. This means that the server can rely on the
mechanism in RFC5661 Section 2.10.6.3 to ensure that replies to an
OPEN or LAYOUTGET/RETURN RPC call don't race with the callbacks that
apply to them.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 78 +++++++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 65 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index de4a89d3d740..f5aecaabcb7c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -634,15 +634,11 @@ out_sleep:
 }
 EXPORT_SYMBOL_GPL(nfs40_setup_sequence);
 
-static int nfs40_sequence_done(struct rpc_task *task,
-			       struct nfs4_sequence_res *res)
+static void nfs40_sequence_free_slot(struct nfs4_sequence_res *res)
 {
 	struct nfs4_slot *slot = res->sr_slot;
 	struct nfs4_slot_table *tbl;
 
-	if (slot == NULL)
-		goto out;
-
 	tbl = slot->table;
 	spin_lock(&tbl->slot_tbl_lock);
 	if (!nfs41_wake_and_assign_slot(tbl, slot))
@@ -650,7 +646,13 @@ static int nfs40_sequence_done(struct rpc_task *task,
 	spin_unlock(&tbl->slot_tbl_lock);
 
 	res->sr_slot = NULL;
-out:
+}
+
+static int nfs40_sequence_done(struct rpc_task *task,
+			       struct nfs4_sequence_res *res)
+{
+	if (res->sr_slot != NULL)
+		nfs40_sequence_free_slot(res);
 	return 1;
 }
 
@@ -695,7 +697,8 @@ out_unlock:
 		wake_up_all(&tbl->slot_waitq);
 }
 
-int nfs41_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *res)
+static int nfs41_sequence_process(struct rpc_task *task,
+		struct nfs4_sequence_res *res)
 {
 	struct nfs4_session *session;
 	struct nfs4_slot *slot = res->sr_slot;
@@ -781,11 +784,11 @@ int nfs41_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *res)
 out:
 	/* The session may be reset by one of the error handlers. */
 	dprintk("%s: Error %d free the slot \n", __func__, res->sr_status);
-	nfs41_sequence_free_slot(res);
 out_noaction:
 	return ret;
 retry_nowait:
 	if (rpc_restart_call_prepare(task)) {
+		nfs41_sequence_free_slot(res);
 		task->tk_status = 0;
 		ret = 0;
 	}
@@ -796,8 +799,37 @@ out_retry:
 	rpc_delay(task, NFS4_POLL_RETRY_MAX);
 	return 0;
 }
+
+int nfs41_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *res)
+{
+	if (!nfs41_sequence_process(task, res))
+		return 0;
+	if (res->sr_slot != NULL)
+		nfs41_sequence_free_slot(res);
+	return 1;
+
+}
 EXPORT_SYMBOL_GPL(nfs41_sequence_done);
 
+static int nfs4_sequence_process(struct rpc_task *task, struct nfs4_sequence_res *res)
+{
+	if (res->sr_slot == NULL)
+		return 1;
+	if (res->sr_slot->table->session != NULL)
+		return nfs41_sequence_process(task, res);
+	return nfs40_sequence_done(task, res);
+}
+
+static void nfs4_sequence_free_slot(struct nfs4_sequence_res *res)
+{
+	if (res->sr_slot != NULL) {
+		if (res->sr_slot->table->session != NULL)
+			nfs41_sequence_free_slot(res);
+		else
+			nfs40_sequence_free_slot(res);
+	}
+}
+
 int nfs4_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *res)
 {
 	if (res->sr_slot == NULL)
@@ -927,6 +959,17 @@ static int nfs4_setup_sequence(const struct nfs_server *server,
 				    args, res, task);
 }
 
+static int nfs4_sequence_process(struct rpc_task *task, struct nfs4_sequence_res *res)
+{
+	return nfs40_sequence_done(task, res);
+}
+
+static void nfs4_sequence_free_slot(struct nfs4_sequence_res *res)
+{
+	if (res->sr_slot != NULL)
+		nfs40_sequence_free_slot(res);
+}
+
 int nfs4_sequence_done(struct rpc_task *task,
 		       struct nfs4_sequence_res *res)
 {
@@ -1204,6 +1247,7 @@ static void nfs4_opendata_free(struct kref *kref)
 	struct super_block *sb = p->dentry->d_sb;
 
 	nfs_free_seqid(p->o_arg.seqid);
+	nfs4_sequence_free_slot(&p->o_res.seq_res);
 	if (p->state != NULL)
 		nfs4_put_open_state(p->state);
 	nfs4_put_state_owner(p->owner);
@@ -1663,9 +1707,14 @@ err:
 static struct nfs4_state *
 nfs4_opendata_to_nfs4_state(struct nfs4_opendata *data)
 {
+	struct nfs4_state *ret;
+
 	if (data->o_arg.claim == NFS4_OPEN_CLAIM_PREVIOUS)
-		return _nfs4_opendata_reclaim_to_nfs4_state(data);
-	return _nfs4_opendata_to_nfs4_state(data);
+		ret =_nfs4_opendata_reclaim_to_nfs4_state(data);
+	else
+		ret = _nfs4_opendata_to_nfs4_state(data);
+	nfs4_sequence_free_slot(&data->o_res.seq_res);
+	return ret;
 }
 
 static struct nfs_open_context *nfs4_state_find_open_context(struct nfs4_state *state)
@@ -2063,7 +2112,7 @@ static void nfs4_open_done(struct rpc_task *task, void *calldata)
 
 	data->rpc_status = task->tk_status;
 
-	if (!nfs4_sequence_done(task, &data->o_res.seq_res))
+	if (!nfs4_sequence_process(task, &data->o_res.seq_res))
 		return;
 
 	if (task->tk_status == 0) {
@@ -7871,7 +7920,7 @@ static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
 	struct nfs4_layoutget *lgp = calldata;
 
 	dprintk("--> %s\n", __func__);
-	nfs41_sequence_done(task, &lgp->res.seq_res);
+	nfs41_sequence_process(task, &lgp->res.seq_res);
 	dprintk("<-- %s\n", __func__);
 }
 
@@ -8087,6 +8136,7 @@ nfs4_proc_layoutget(struct nfs4_layoutget *lgp, long *timeout, gfp_t gfp_flags)
 	/* if layoutp->len is 0, nfs4_layoutget_prepare called rpc_exit */
 	if (status == 0 && lgp->res.layoutp->len)
 		lseg = pnfs_layout_process(lgp);
+	nfs4_sequence_free_slot(&lgp->res.seq_res);
 	rpc_put_task(task);
 	dprintk("<-- %s status=%d\n", __func__, status);
 	if (status)
@@ -8113,7 +8163,7 @@ static void nfs4_layoutreturn_done(struct rpc_task *task, void *calldata)
 
 	dprintk("--> %s\n", __func__);
 
-	if (!nfs41_sequence_done(task, &lrp->res.seq_res))
+	if (!nfs41_sequence_process(task, &lrp->res.seq_res))
 		return;
 
 	server = NFS_SERVER(lrp->args.inode);
@@ -8125,6 +8175,7 @@ static void nfs4_layoutreturn_done(struct rpc_task *task, void *calldata)
 	case -NFS4ERR_DELAY:
 		if (nfs4_async_handle_error(task, server, NULL, NULL) != -EAGAIN)
 			break;
+		nfs4_sequence_free_slot(&lrp->res.seq_res);
 		rpc_restart_call_prepare(task);
 		return;
 	}
@@ -8145,6 +8196,7 @@ static void nfs4_layoutreturn_release(void *calldata)
 		pnfs_set_layout_stateid(lo, &lrp->res.stateid, true);
 	pnfs_clear_layoutreturn_waitbit(lo);
 	spin_unlock(&lo->plh_inode->i_lock);
+	nfs4_sequence_free_slot(&lrp->res.seq_res);
 	pnfs_free_lseg_list(&freeme);
 	pnfs_put_layout_hdr(lrp->args.layout);
 	nfs_iput_and_deactive(lrp->inode);
-- 
2.7.4

