Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:19473 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753382AbdAKSzL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 11 Jan 2017 13:55:11 -0500
From: <Anna.Schumaker@Netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH 05/11] NFS: Create a single nfs4_setup_sequence() function
Date: Wed, 11 Jan 2017 13:54:48 -0500
Message-ID: <20170111185454.9315-6-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170111185454.9315-1-Anna.Schumaker@Netapp.com>
References: <20170111185454.9315-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

The inline ifdef lets us put everything in a single place, rather than
having two (very similar) versions of this function.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4proc.c | 76 +++++++++++++++++++++----------------------------------
 1 file changed, 29 insertions(+), 47 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3f7199a0b784..132d73435b8f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -946,37 +946,14 @@ static int nfs41_setup_sequence(struct nfs4_session *session,
 	return -EAGAIN;
 }
 
-int nfs4_setup_sequence(const struct nfs_client *client,
-			struct nfs4_sequence_args *args,
-			struct nfs4_sequence_res *res,
-			struct rpc_task *task)
-{
-	struct nfs4_session *session = nfs4_get_session(client);
-	int ret = 0;
-
-	if (!session)
-		return nfs40_setup_sequence(client->cl_slot_tbl,
-					    args, res, task);
-
-	dprintk("--> %s clp %p session %p sr_slot %u\n",
-		__func__, session->clp, session, res->sr_slot ?
-			res->sr_slot->slot_nr : NFS4_NO_SLOT);
-
-	ret = nfs41_setup_sequence(session, args, res, task);
-
-	dprintk("<-- %s status=%d\n", __func__, ret);
-	return ret;
-}
-EXPORT_SYMBOL_GPL(nfs4_setup_sequence);
-
 static void nfs41_call_sync_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_call_sync_data *data = calldata;
-	struct nfs4_session *session = nfs4_get_session(data->seq_server->nfs_client);
 
 	dprintk("--> %s data->seq_server %p\n", __func__, data->seq_server);
 
-	nfs41_setup_sequence(session, data->seq_args, data->seq_res, task);
+	nfs4_setup_sequence(data->seq_server->nfs_client,
+			    data->seq_args, data->seq_res, task);
 }
 
 static void nfs41_call_sync_done(struct rpc_task *task, void *calldata)
@@ -993,15 +970,6 @@ static const struct rpc_call_ops nfs41_call_sync_ops = {
 
 #else	/* !CONFIG_NFS_V4_1 */
 
-int nfs4_setup_sequence(const struct nfs_client *client,
-			struct nfs4_sequence_args *args,
-			struct nfs4_sequence_res *res,
-			struct rpc_task *task)
-{
-	return nfs40_setup_sequence(client->cl_slot_tbl, args, res, task);
-}
-EXPORT_SYMBOL_GPL(nfs4_setup_sequence);
-
 static int nfs4_sequence_process(struct rpc_task *task, struct nfs4_sequence_res *res)
 {
 	return nfs40_sequence_done(task, res);
@@ -1022,6 +990,22 @@ EXPORT_SYMBOL_GPL(nfs4_sequence_done);
 
 #endif	/* !CONFIG_NFS_V4_1 */
 
+int nfs4_setup_sequence(const struct nfs_client *client,
+			struct nfs4_sequence_args *args,
+			struct nfs4_sequence_res *res,
+			struct rpc_task *task)
+{
+#if defined(CONFIG_NFS_V4_1)
+	struct nfs4_session *session = nfs4_get_session(client);
+
+	if (session)
+		return nfs41_setup_sequence(session, args, res, task);
+#endif /* CONFIG_NFS_V4_1 */
+	return nfs40_setup_sequence(client->cl_slot_tbl, args, res, task);
+
+}
+EXPORT_SYMBOL_GPL(nfs4_setup_sequence);
+
 static void nfs40_call_sync_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_call_sync_data *data = calldata;
@@ -2046,8 +2030,8 @@ static void nfs4_open_confirm_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_opendata *data = calldata;
 
-	nfs40_setup_sequence(data->o_arg.server->nfs_client->cl_slot_tbl,
-			     &data->c_arg.seq_args, &data->c_res.seq_res, task);
+	nfs4_setup_sequence(data->o_arg.server->nfs_client,
+			   &data->c_arg.seq_args, &data->c_res.seq_res, task);
 }
 
 static void nfs4_open_confirm_done(struct rpc_task *task, void *calldata)
@@ -6631,8 +6615,8 @@ static void nfs4_release_lockowner_prepare(struct rpc_task *task, void *calldata
 {
 	struct nfs_release_lockowner_data *data = calldata;
 	struct nfs_server *server = data->server;
-	nfs40_setup_sequence(server->nfs_client->cl_slot_tbl,
-			     &data->args.seq_args, &data->res.seq_res, task);
+	nfs4_setup_sequence(server->nfs_client, &data->args.seq_args,
+			   &data->res.seq_res, task);
 	data->args.lock_owner.clientid = server->nfs_client->cl_clientid;
 	data->timestamp = jiffies;
 }
@@ -7822,7 +7806,7 @@ static void nfs4_get_lease_time_prepare(struct rpc_task *task,
 	dprintk("--> %s\n", __func__);
 	/* just setup sequence, do not trigger session recovery
 	   since we're invoked within one */
-	nfs41_setup_sequence(data->clp->cl_session,
+	nfs4_setup_sequence(data->clp,
 			&data->args->la_seq_args,
 			&data->res->lr_seq_res,
 			task);
@@ -8193,7 +8177,7 @@ static void nfs41_sequence_prepare(struct rpc_task *task, void *data)
 	args = task->tk_msg.rpc_argp;
 	res = task->tk_msg.rpc_resp;
 
-	nfs41_setup_sequence(clp->cl_session, args, res, task);
+	nfs4_setup_sequence(clp, args, res, task);
 }
 
 static const struct rpc_call_ops nfs41_sequence_ops = {
@@ -8281,7 +8265,7 @@ static void nfs4_reclaim_complete_prepare(struct rpc_task *task, void *data)
 {
 	struct nfs4_reclaim_complete_data *calldata = data;
 
-	nfs41_setup_sequence(calldata->clp->cl_session,
+	nfs4_setup_sequence(calldata->clp,
 			&calldata->arg.seq_args,
 			&calldata->res.seq_res,
 			task);
@@ -8388,10 +8372,9 @@ nfs4_layoutget_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_layoutget *lgp = calldata;
 	struct nfs_server *server = NFS_SERVER(lgp->args.inode);
-	struct nfs4_session *session = nfs4_get_session(server->nfs_client);
 
 	dprintk("--> %s\n", __func__);
-	nfs41_setup_sequence(session, &lgp->args.seq_args,
+	nfs4_setup_sequence(server->nfs_client, &lgp->args.seq_args,
 				&lgp->res.seq_res, task);
 	dprintk("<-- %s\n", __func__);
 }
@@ -8634,7 +8617,7 @@ nfs4_layoutreturn_prepare(struct rpc_task *task, void *calldata)
 	struct nfs4_layoutreturn *lrp = calldata;
 
 	dprintk("--> %s\n", __func__);
-	nfs41_setup_sequence(lrp->clp->cl_session,
+	nfs4_setup_sequence(lrp->clp,
 			&lrp->args.seq_args,
 			&lrp->res.seq_res,
 			task);
@@ -8784,9 +8767,8 @@ static void nfs4_layoutcommit_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_layoutcommit_data *data = calldata;
 	struct nfs_server *server = NFS_SERVER(data->args.inode);
-	struct nfs4_session *session = nfs4_get_session(server->nfs_client);
 
-	nfs41_setup_sequence(session,
+	nfs4_setup_sequence(server->nfs_client,
 			&data->args.seq_args,
 			&data->res.seq_res,
 			task);
@@ -9110,7 +9092,7 @@ struct nfs_free_stateid_data {
 static void nfs41_free_stateid_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs_free_stateid_data *data = calldata;
-	nfs41_setup_sequence(nfs4_get_session(data->server->nfs_client),
+	nfs4_setup_sequence(data->server->nfs_client,
 			&data->args.seq_args,
 			&data->res.seq_res,
 			task);
-- 
2.11.0

