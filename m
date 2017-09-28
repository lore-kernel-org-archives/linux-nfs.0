Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:37252 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752184AbdI1R2c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 28 Sep 2017 13:28:32 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v4 10/12] NFS send OFFLOAD_CANCEL when COPY killed
Date: Thu, 28 Sep 2017 13:28:17 -0400
Message-ID: <20170928172819.50703-11-kolga@netapp.com>
In-Reply-To: <20170928172819.50703-1-kolga@netapp.com>
References: <20170928172819.50703-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When COPY is killed by the user send OFFLOAD_CANCEL to server
processing the copy.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs42proc.c | 90 +++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 89 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index d0f454e..f2ba4c4 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -16,6 +16,7 @@
 #include "internal.h"
 
 #define NFSDBG_FACILITY NFSDBG_PROC
+static int nfs42_do_offload_cancel_async(struct file *dst, nfs4_stateid *std);
 
 static int _nfs42_proc_fallocate(struct rpc_message *msg, struct file *filep,
 		struct nfs_lock_context *lock, loff_t offset, loff_t len)
@@ -166,10 +167,15 @@ static int handle_async_copy(struct nfs42_copy_res *res,
 	list_add_tail(&copy->copies, &server->ss_copies);
 	spin_unlock(&server->nfs_client->cl_lock);
 
-	wait_for_completion_interruptible(&copy->completion);
+	status = wait_for_completion_interruptible(&copy->completion);
 	spin_lock(&server->nfs_client->cl_lock);
 	list_del_init(&copy->copies);
 	spin_unlock(&server->nfs_client->cl_lock);
+	if (status == -ERESTARTSYS) {
+		nfs42_do_offload_cancel_async(dst, &copy->stateid);
+		kfree(copy);
+		return status;
+	}
 out:
 	*ret_count = copy->count;
 	memcpy(&res->write_res.verifier, &copy->verf, sizeof(copy->verf));
@@ -328,6 +334,88 @@ ssize_t nfs42_proc_copy(struct file *src, loff_t pos_src,
 	return err;
 }
 
+struct nfs42_offloadcancel_data {
+	struct nfs_server *seq_server;
+	struct nfs42_offload_status_args args;
+	struct nfs42_offload_status_res res;
+};
+
+static void nfs42_offload_cancel_prepare(struct rpc_task *task, void *calldata)
+{
+	struct nfs42_offloadcancel_data *data = calldata;
+
+	nfs4_setup_sequence(data->seq_server->nfs_client,
+				&data->args.osa_seq_args,
+				&data->res.osr_seq_res, task);
+}
+
+static void nfs42_offload_cancel_done(struct rpc_task *task, void *calldata)
+{
+	struct nfs42_offloadcancel_data *data = calldata;
+
+	nfs41_sequence_done(task, &data->res.osr_seq_res);
+	if (task->tk_status &&
+		nfs4_async_handle_error(task, data->seq_server, NULL,
+			NULL) == -EAGAIN)
+		rpc_restart_call_prepare(task);
+}
+
+static void nfs42_free_offloadcancel_data(void *data)
+{
+	kfree(data);
+}
+
+static const struct rpc_call_ops nfs42_offload_cancel_ops = {
+	.rpc_call_prepare = nfs42_offload_cancel_prepare,
+	.rpc_call_done = nfs42_offload_cancel_done,
+	.rpc_release = nfs42_free_offloadcancel_data,
+};
+
+static int nfs42_do_offload_cancel_async(struct file *dst,
+				nfs4_stateid *stateid)
+{
+	struct nfs_server *dst_server = NFS_SERVER(file_inode(dst));
+	struct nfs42_offloadcancel_data *data = NULL;
+	struct nfs_open_context *ctx = nfs_file_open_context(dst);
+	struct rpc_task *task;
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_OFFLOAD_CANCEL],
+		.rpc_cred = ctx->cred,
+	};
+	struct rpc_task_setup task_setup_data = {
+		.rpc_client = dst_server->client,
+		.rpc_message = &msg,
+		.callback_ops = &nfs42_offload_cancel_ops,
+		.workqueue = nfsiod_workqueue,
+		.flags = RPC_TASK_ASYNC,
+	};
+	int status;
+
+	if (!(dst_server->caps & NFS_CAP_OFFLOAD_CANCEL))
+		return -EOPNOTSUPP;
+
+	data = kzalloc(sizeof(struct nfs42_offloadcancel_data), GFP_NOFS);
+	if (data == NULL)
+		return -ENOMEM;
+
+	data->seq_server = dst_server;
+	data->args.osa_src_fh = NFS_FH(file_inode(dst));
+	memcpy(&data->args.osa_stateid, stateid,
+		sizeof(data->args.osa_stateid));
+	msg.rpc_argp = &data->args;
+	msg.rpc_resp = &data->res;
+	task_setup_data.callback_data = data;
+	nfs4_init_sequence(&data->args.osa_seq_args, &data->res.osr_seq_res, 1);
+	task = rpc_run_task(&task_setup_data);
+	if (IS_ERR(task))
+		return PTR_ERR(task);
+	status = rpc_wait_for_completion_task(task);
+	if (status == -ENOTSUPP)
+		dst_server->caps &= ~NFS_CAP_OFFLOAD_CANCEL;
+	rpc_put_task(task);
+	return status;
+}
+
 int _nfs42_proc_offload_status(struct file *dst, nfs4_stateid *stateid,
 				struct nfs42_offload_status_res *res)
 {
-- 
1.8.3.1

