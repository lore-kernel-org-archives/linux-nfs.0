From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 27/85] nfs41: nfs4_setup_sequence
Date: Mon, 10 Nov 2008 22:22:45 +0200
Message-ID: <1226348565-8091-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:48771 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751557AbYKJUWv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:22:51 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Perform the nfs4_setup_sequence in the rpc_call_prepare state.

If a session slot is not available, we will rpc_sleep_on the
slot wait queue leaving the tk_action as rpc_call_prepare.

Once we have a session slot, hang on to it even through rpc_restart_calls.
Ensure the nfs41_sequence_res sr_slot pointer is NULL before rpc_run_task is
called as nfs41_setup_sequence will only find a new slot if it is NULL.

A future patch will call free slot after any rpc_restart_calls, and handle the
rpc restart that result from a sequence operation error.

Signed-off-by: Rahul Iyer <iyer@netapp.com>
Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>

nfs41: simplify nfs4_call_sync

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c       |   93 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs_xdr.h |    2 +-
 2 files changed, 94 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3b7c7fa..30f76e7 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -347,6 +347,70 @@ nfs4_find_slot(struct nfs4_slot_table *tbl, struct rpc_task *task)
 	return slot;
 }
 
+static int nfs41_setup_sequence(struct nfs4_session *session,
+				struct nfs41_sequence_args *args,
+				struct nfs41_sequence_res *res,
+				int cache_reply,
+				struct rpc_task *task)
+{
+	/* stub */
+	return 0;
+}
+
+int nfs4_setup_sequence(struct nfs_client *clp,
+			struct nfs41_sequence_args *args,
+			struct nfs41_sequence_res *res,
+			int cache_reply,
+			struct rpc_task *task)
+{
+	int ret = 0;
+
+	dprintk("--> %s clp %p session %p cl_minorversion %d res->sr_slot %p\n",
+		__func__, clp, clp->cl_session, clp->cl_minorversion,
+		res->sr_slot);
+
+	if (clp->cl_minorversion == 0 || res->sr_slot)
+		goto out;
+	BUG_ON(clp->cl_minorversion != 1);
+	ret = nfs41_setup_sequence(clp->cl_session, args, res,
+				   cache_reply, task);
+	if (ret) {
+		memset(res, 0, sizeof(*res));
+		if (ret != -EAGAIN) {
+			/* terminate rpc task */
+			task->tk_status = ret;
+			task->tk_action = NULL;
+		}
+	}
+out:
+	dprintk("<-- %s status=%d\n", __func__, ret);
+	return ret;
+}
+
+struct nfs41_call_sync_data {
+	struct nfs_server *server;
+	struct rpc_message *msg;
+	struct nfs41_sequence_args *seq_args;
+	struct nfs41_sequence_res *seq_res;
+	int cache_reply;
+};
+
+static void nfs41_call_sync_prepare(struct rpc_task *task, void *calldata)
+{
+	struct nfs41_call_sync_data *data = calldata;
+
+	dprintk("--> %s data->server->session %p\n", __func__,
+		data->server->nfs_client->cl_session);
+	if (nfs4_setup_sequence(data->server->nfs_client, data->seq_args,
+				data->seq_res, data->cache_reply, task))
+		return;
+	rpc_call_start(task);
+}
+
+struct rpc_call_ops nfs41_call_sync_ops = {
+	.rpc_call_prepare = nfs41_call_sync_prepare,
+};
+
 #endif /* CONFIG_NFS_V4_1 */
 
 static int _nfs4_call_sync(struct nfs_server *server,
@@ -355,6 +419,35 @@ static int _nfs4_call_sync(struct nfs_server *server,
 			   struct nfs41_sequence_res *res,
 			   int cache_reply)
 {
+#ifdef CONFIG_NFS_V4_1
+	if (server->nfs_client->cl_minorversion) {
+		int ret;
+		struct rpc_task *task;
+		struct nfs41_call_sync_data data = {
+			.server = server,
+			.msg = msg,
+			.seq_args = args,
+			.seq_res = res,
+			.cache_reply = cache_reply,
+		};
+		struct rpc_task_setup task_setup = {
+			.rpc_client = server->client,
+			.rpc_message = msg,
+			.callback_ops = &nfs41_call_sync_ops,
+			.callback_data = &data
+		};
+
+		res->sr_slot = NULL;
+		task = rpc_run_task(&task_setup);
+		if (IS_ERR(task))
+			ret = PTR_ERR(task);
+		else {
+			ret = task->tk_status;
+			rpc_put_task(task);
+		}
+		return ret;
+	}
+#endif /* CONFIG_NFS_V4_1 */
 	return rpc_call_sync(server->client, msg, 0);
 }
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index b401477..1ec56e5 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -134,7 +134,7 @@ struct nfs41_sequence_args {
 #define SEQ4_STATUS_RESTART_RECLAIM_NEEDED	0x00000100
 
 struct nfs41_sequence_res {
-	/* stub */
+	struct nfs4_slot	*sr_slot;	/* slot used to send request */
 };
 
 #if defined(CONFIG_NFS_V4_1)
-- 
1.6.0.2

