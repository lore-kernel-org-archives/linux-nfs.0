From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 03/15] NFSv4.1: Simplify nfs41_sequence_done()
Date: Mon, 14 Jun 2010 17:51:27 -0400
Message-ID: <1276552299-6625-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1276552299-6625-1-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-2-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:53421 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756726Ab0FNVvn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Jun 2010 17:51:43 -0400
In-Reply-To: <1276552299-6625-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Nobody uses the rpc_status parameter.

It is not obvious why we need the struct nfs_client argument either, when
we already have that information in the session.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c |   26 ++++++++++++--------------
 1 files changed, 12 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a7a2032..67b2359 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -370,12 +370,11 @@ static void nfs41_check_drain_session_complete(struct nfs4_session *ses)
 	complete(&ses->complete);
 }
 
-static void nfs41_sequence_free_slot(const struct nfs_client *clp,
-			      struct nfs4_sequence_res *res)
+static void nfs41_sequence_free_slot(struct nfs4_sequence_res *res)
 {
 	struct nfs4_slot_table *tbl;
 
-	tbl = &clp->cl_session->fc_slot_table;
+	tbl = &res->sr_session->fc_slot_table;
 	if (res->sr_slotid == NFS4_MAX_SLOT_TABLE) {
 		/* just wake up the next guy waiting since
 		 * we may have not consumed a slot after all */
@@ -385,14 +384,12 @@ static void nfs41_sequence_free_slot(const struct nfs_client *clp,
 
 	spin_lock(&tbl->slot_tbl_lock);
 	nfs4_free_slot(tbl, res->sr_slotid);
-	nfs41_check_drain_session_complete(clp->cl_session);
+	nfs41_check_drain_session_complete(res->sr_session);
 	spin_unlock(&tbl->slot_tbl_lock);
 	res->sr_slotid = NFS4_MAX_SLOT_TABLE;
 }
 
-static void nfs41_sequence_done(struct nfs_client *clp,
-				struct nfs4_sequence_res *res,
-				int rpc_status)
+static void nfs41_sequence_done(struct nfs4_sequence_res *res)
 {
 	unsigned long timestamp;
 	struct nfs4_slot_table *tbl;
@@ -413,7 +410,8 @@ static void nfs41_sequence_done(struct nfs_client *clp,
 
 	/* Check the SEQUENCE operation status */
 	if (res->sr_status == 0) {
-		tbl = &clp->cl_session->fc_slot_table;
+		struct nfs_client *clp = res->sr_session->clp;
+		tbl = &res->sr_session->fc_slot_table;
 		slot = tbl->slots + res->sr_slotid;
 		/* Update the slot's sequence and clientid lease timer */
 		++slot->seq_nr;
@@ -429,7 +427,7 @@ static void nfs41_sequence_done(struct nfs_client *clp,
 out:
 	/* The session may be reset by one of the error handlers. */
 	dprintk("%s: Error %d free the slot \n", __func__, res->sr_status);
-	nfs41_sequence_free_slot(clp, res);
+	nfs41_sequence_free_slot(res);
 }
 
 /*
@@ -582,7 +580,7 @@ static void nfs41_call_sync_done(struct rpc_task *task, void *calldata)
 {
 	struct nfs41_call_sync_data *data = calldata;
 
-	nfs41_sequence_done(data->clp, data->seq_res, task->tk_status);
+	nfs41_sequence_done(data->seq_res);
 }
 
 struct rpc_call_ops nfs41_call_sync_ops = {
@@ -662,7 +660,7 @@ static void nfs4_sequence_done(const struct nfs_server *server,
 {
 #ifdef CONFIG_NFS_V4_1
 	if (nfs4_has_session(server->nfs_client))
-		nfs41_sequence_done(server->nfs_client, res, rpc_status);
+		nfs41_sequence_done(res);
 #endif /* CONFIG_NFS_V4_1 */
 }
 
@@ -4606,7 +4604,7 @@ static void nfs4_get_lease_time_done(struct rpc_task *task, void *calldata)
 			(struct nfs4_get_lease_time_data *)calldata;
 
 	dprintk("--> %s\n", __func__);
-	nfs41_sequence_done(data->clp, &data->res->lr_seq_res, task->tk_status);
+	nfs41_sequence_done(&data->res->lr_seq_res);
 	switch (task->tk_status) {
 	case -NFS4ERR_DELAY:
 	case -NFS4ERR_GRACE:
@@ -5095,7 +5093,7 @@ static void nfs41_sequence_call_done(struct rpc_task *task, void *data)
 	struct nfs4_sequence_data *calldata = data;
 	struct nfs_client *clp = calldata->clp;
 
-	nfs41_sequence_done(clp, task->tk_msg.rpc_resp, task->tk_status);
+	nfs41_sequence_done(task->tk_msg.rpc_resp);
 
 	if (task->tk_status < 0) {
 		dprintk("%s ERROR %d\n", __func__, task->tk_status);
@@ -5183,7 +5181,7 @@ static void nfs4_reclaim_complete_done(struct rpc_task *task, void *data)
 	struct nfs4_sequence_res *res = &calldata->res.seq_res;
 
 	dprintk("--> %s\n", __func__);
-	nfs41_sequence_done(clp, res, task->tk_status);
+	nfs41_sequence_done(res);
 	switch (task->tk_status) {
 	case 0:
 	case -NFS4ERR_COMPLETE_ALREADY:
-- 
1.7.0.1

