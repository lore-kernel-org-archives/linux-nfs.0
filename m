Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:26944 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754514AbdCBQDy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 2 Mar 2017 11:03:54 -0500
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC v1 14/19] NFS send OFFLOAD_CANCEL when COPY killed
Date: Thu, 2 Mar 2017 11:01:18 -0500
Message-ID: <20170302160123.30375-15-kolga@netapp.com>
In-Reply-To: <20170302160123.30375-1-kolga@netapp.com>
References: <20170302160123.30375-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When COPY is killed send OFFLOAD_CANCEL to both destination and
source servers.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs42proc.c | 95 ++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 93 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index cd9d955..7a1b2ae 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -19,6 +19,8 @@
 
 #define NFSDBG_FACILITY NFSDBG_PROC
 
+static int nfs42_do_offload_cancel_async(struct file *dst,
+				nfs4_stateid *stateid);
 static int nfs42_set_open_stateid(nfs4_stateid *dst, struct file *file)
 {
 	struct nfs_open_context *ctx;
@@ -206,10 +208,16 @@ static int handle_async_copy(struct nfs42_copy_res *res,
 	list_add_tail(&copy->copies, &server->ss_copies);
 	spin_unlock(&server->nfs_client->cl_lock);
 
-	wait_for_completion_interruptible(&copy->completion);
+	status = wait_for_completion_interruptible(&copy->completion);
 	spin_lock(&server->nfs_client->cl_lock);
 	list_del_init(&copy->copies);
 	spin_unlock(&server->nfs_client->cl_lock);
+	if (status == -ERESTARTSYS) {
+		nfs42_do_offload_cancel_async(dst, &copy->stateid);
+		nfs42_do_offload_cancel_async(src, src_stateid);
+		kfree(copy);
+		return status;
+	}
 out:
 	*ret_count = copy->count;
 	status = -copy->error;
@@ -266,8 +274,13 @@ static ssize_t _nfs42_proc_copy(struct file *src,
 
 	status = nfs4_call_sync(server->client, server, &msg,
 				&args->seq_args, &res->seq_res, 0);
-	if (status == -ENOTSUPP)
+	switch (status) {
+	case -ENOTSUPP:
 		server->caps &= ~NFS_CAP_COPY;
+		break;
+	case -ERESTARTSYS:
+		nfs42_do_offload_cancel_async(src, &args->src_stateid);
+	}
 	if (status)
 		return status;
 
@@ -419,6 +432,84 @@ int nfs42_proc_copy_notify(struct file *src, struct file *dst,
 	return status;
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
+	struct nfs4_session *session = nfs4_get_session(data->seq_server);
+
+	nfs41_setup_sequence(session, &data->args.osa_seq_args,
+				&data->res.osr_seq_res, task);
+}
+
+static void nfs42_offload_cancel_done(struct rpc_task *task, void *calldata)
+{
+	struct nfs42_offloadcancel_data *data = calldata;
+
+	nfs41_sequence_done(task, &data->res.osr_seq_res);
+	kfree(data);
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

