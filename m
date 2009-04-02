From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 28/67] nfs41: nfs4_setup_sequence
Date: Thu,  2 Apr 2009 16:54:18 +0300
Message-ID: <1238680458-14277-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:29340 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753635AbZDBNyY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:54:24 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Perform the nfs4_setup_sequence in the rpc_call_prepare state.

If a session slot is not available, we will rpc_sleep_on the
slot wait queue leaving the tk_action as rpc_call_prepare.

Once we have a session slot, hang on to it even through rpc_restart_calls.
Ensure the nfs41_sequence_res sr_slot pointer is NULL before rpc_run_task is
called as nfs41_setup_sequence will only find a new slot if it is NULL.

A future patch will call free slot after any rpc_restart_calls, and handle the
rpc restart that result from a sequence operation error.

Signed-off-by: Rahul Iyer <iyer@netapp.com>
[nfs41: sequence res use slotid]
Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: simplify nfs4_call_sync]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: nfs4_call_sync]
[nfs41: check for session not minorversion]
[nfs41: remove rpc_message from nfs41_call_sync_args]
[moved NFS4_MAX_SLOT_TABLE logic into nfs41_setup_sequence]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: nfs41_call_sync_data use nfs_client not nfs_server]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: expose nfs4_call_sync_session for lease renewal]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: remove unnecessary return check]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |  100 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 98 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 2e70c7e..4d48bf8 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -273,14 +273,110 @@ static void renew_lease(const struct nfs_server *server, unsigned long timestamp
 
 #if defined(CONFIG_NFS_V4_1)
 
+static int nfs41_setup_sequence(struct nfs4_session *session,
+				struct nfs4_sequence_args *args,
+				struct nfs4_sequence_res *res,
+				int cache_reply,
+				struct rpc_task *task)
+{
+	/* slot already allocated? */
+	if (res->sr_slotid != NFS4_MAX_SLOT_TABLE)
+		return 0;
+
+	memset(res, 0, sizeof(*res));
+	res->sr_slotid = NFS4_MAX_SLOT_TABLE;
+	return 0;
+}
+
+int nfs4_setup_sequence(struct nfs_client *clp,
+			struct nfs4_sequence_args *args,
+			struct nfs4_sequence_res *res,
+			int cache_reply,
+			struct rpc_task *task)
+{
+	int ret = 0;
+
+	dprintk("--> %s clp %p session %p sr_slotid %d\n",
+		__func__, clp, clp->cl_session, res->sr_slotid);
+
+	if (!nfs4_has_session(clp))
+		goto out;
+	ret = nfs41_setup_sequence(clp->cl_session, args, res, cache_reply,
+				   task);
+	if (ret != -EAGAIN) {
+		/* terminate rpc task */
+		task->tk_status = ret;
+		task->tk_action = NULL;
+	}
+out:
+	dprintk("<-- %s status=%d\n", __func__, ret);
+	return ret;
+}
+
+struct nfs41_call_sync_data {
+	struct nfs_client *clp;
+	struct nfs4_sequence_args *seq_args;
+	struct nfs4_sequence_res *seq_res;
+	int cache_reply;
+};
+
+static void nfs41_call_sync_prepare(struct rpc_task *task, void *calldata)
+{
+	struct nfs41_call_sync_data *data = calldata;
+
+	dprintk("--> %s data->clp->cl_session %p\n", __func__,
+		data->clp->cl_session);
+	if (nfs4_setup_sequence(data->clp, data->seq_args,
+				data->seq_res, data->cache_reply, task))
+		return;
+	rpc_call_start(task);
+}
+
+struct rpc_call_ops nfs41_call_sync_ops = {
+	.rpc_call_prepare = nfs41_call_sync_prepare,
+};
+
+static int nfs4_call_sync_sequence(struct nfs_client *clp,
+				   struct rpc_clnt *clnt,
+				   struct rpc_message *msg,
+				   struct nfs4_sequence_args *args,
+				   struct nfs4_sequence_res *res,
+				   int cache_reply)
+{
+	int ret;
+	struct rpc_task *task;
+	struct nfs41_call_sync_data data = {
+		.clp = clp,
+		.seq_args = args,
+		.seq_res = res,
+		.cache_reply = cache_reply,
+	};
+	struct rpc_task_setup task_setup = {
+		.rpc_client = clnt,
+		.rpc_message = msg,
+		.callback_ops = &nfs41_call_sync_ops,
+		.callback_data = &data
+	};
+
+	res->sr_slotid = NFS4_MAX_SLOT_TABLE;
+	task = rpc_run_task(&task_setup);
+	if (IS_ERR(task))
+		ret = PTR_ERR(task);
+	else {
+		ret = task->tk_status;
+		rpc_put_task(task);
+	}
+	return ret;
+}
+
 int _nfs4_call_sync_session(struct nfs_server *server,
 			    struct rpc_message *msg,
 			    struct nfs4_sequence_args *args,
 			    struct nfs4_sequence_res *res,
 			    int cache_reply)
 {
-	/* in preparation for setting up the sequence op */
-	return rpc_call_sync(server->client, msg, 0);
+	return nfs4_call_sync_sequence(server->nfs_client, server->client,
+				       msg, args, res, cache_reply);
 }
 
 #endif /* CONFIG_NFS_V4_1 */
-- 
1.6.2.1

