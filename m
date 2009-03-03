From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 33/46] nfs41: nfs4_setup_sequence
Date: Wed,  4 Mar 2009 01:59:44 +0200
Message-ID: <1236124784-3889-1-git-send-email-bhalevy@panasas.com>
References: <49ADBD04.2090002@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:17670
	"EHLO natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752284AbZCCX76 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 18:59:58 -0500
In-Reply-To: <49ADBD04.2090002@panasas.com>
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
---
 fs/nfs/nfs4proc.c       |   89 +++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/nfs_xdr.h |    2 +-
 2 files changed, 88 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f5e7c72..14d77f7 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -350,14 +350,99 @@ out:
 	return ret_id;
 }
 
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
+	ret = nfs41_setup_sequence(clp->cl_session, args, res,
+				   cache_reply, task);
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
+	struct nfs_server *server;
+	struct nfs4_sequence_args *seq_args;
+	struct nfs4_sequence_res *seq_res;
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
 int _nfs4_call_sync_session(struct nfs_server *server,
 			    struct rpc_message *msg,
 			    struct nfs4_sequence_args *args,
 			    struct nfs4_sequence_res *res,
 			    int cache_reply)
 {
-	/* in preparation for setting up the sequence op */
-	return rpc_call_sync(server->client, msg, 0);
+	int ret;
+	struct rpc_task *task;
+	struct nfs41_call_sync_data data = {
+		.server = server,
+		.seq_args = args,
+		.seq_res = res,
+		.cache_reply = cache_reply,
+	};
+	struct rpc_task_setup task_setup = {
+		.rpc_client = server->client,
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
 }
 
 #endif /* CONFIG_NFS_V4_1 */
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 16bef5d..8dcf841 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -134,7 +134,7 @@ struct nfs4_sequence_args {
 };
 
 struct nfs4_sequence_res {
-	/* stub */
+	u8			sr_slotid;	/* slot used to send request */
 };
 
 struct nfs4_get_lease_time_args {
-- 
1.6.1.3

