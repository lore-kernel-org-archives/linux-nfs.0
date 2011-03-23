Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:19419 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932883Ab1CWN2D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Mar 2011 09:28:03 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 02/12] NFSv4.1: rearrange nfs_commit_rpcsetup
Date: Wed, 23 Mar 2011 09:27:45 -0400
Message-Id: <1300886875-5016-3-git-send-email-iisaman@netapp.com>
In-Reply-To: <1300886875-5016-1-git-send-email-iisaman@netapp.com>
References: <1300886875-5016-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Reorder nfs_commit_rpcsetup, preparing for a pnfs entry point.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/write.c |   60 ++++++++++++++++++++++++++++++-------------------------
 1 files changed, 33 insertions(+), 27 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 92b4a66..bf672fa 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1293,32 +1293,49 @@ static void nfs_commitdata_release(void *data)
 	nfs_commit_free(wdata);
 }
 
-/*
- * Set up the argument/result storage required for the RPC call.
- */
-static int nfs_commit_rpcsetup(struct list_head *head,
-		struct nfs_write_data *data,
-		int how)
+static int nfs_initiate_commit(struct nfs_write_data *data, struct rpc_clnt *clnt,
+			const struct rpc_call_ops *call_ops,
+			int how)
 {
-	struct nfs_page *first = nfs_list_entry(head->next);
-	struct inode *inode = first->wb_context->path.dentry->d_inode;
-	int priority = flush_task_priority(how);
 	struct rpc_task *task;
+	int priority = flush_task_priority(how);
 	struct rpc_message msg = {
 		.rpc_argp = &data->args,
 		.rpc_resp = &data->res,
-		.rpc_cred = first->wb_context->cred,
+		.rpc_cred = data->cred,
 	};
 	struct rpc_task_setup task_setup_data = {
 		.task = &data->task,
-		.rpc_client = NFS_CLIENT(inode),
+		.rpc_client = clnt,
 		.rpc_message = &msg,
-		.callback_ops = &nfs_commit_ops,
+		.callback_ops = call_ops,
 		.callback_data = data,
 		.workqueue = nfsiod_workqueue,
 		.flags = RPC_TASK_ASYNC,
 		.priority = priority,
 	};
+	/* Set up the initial task struct.  */
+	NFS_PROTO(data->inode)->commit_setup(data, &msg);
+
+	dprintk("NFS: %5u initiated commit call\n", data->task.tk_pid);
+
+	task = rpc_run_task(&task_setup_data);
+	if (IS_ERR(task))
+		return PTR_ERR(task);
+	if (how & FLUSH_SYNC)
+		rpc_wait_for_completion_task(task);
+	rpc_put_task(task);
+	return 0;
+}
+
+/*
+ * Set up the argument/result storage required for the RPC call.
+ */
+static void nfs_init_commit(struct nfs_write_data *data,
+			    struct list_head *head)
+{
+	struct nfs_page *first = nfs_list_entry(head->next);
+	struct inode *inode = first->wb_context->path.dentry->d_inode;
 
 	/* Set up the RPC argument and reply structs
 	 * NB: take care not to mess about with data->commit et al. */
@@ -1326,7 +1343,8 @@ static int nfs_commit_rpcsetup(struct list_head *head,
 	list_splice_init(head, &data->pages);
 
 	data->inode	  = inode;
-	data->cred	  = msg.rpc_cred;
+	data->cred	  = first->wb_context->cred;
+	data->mds_ops     = &nfs_commit_ops;
 
 	data->args.fh     = NFS_FH(data->inode);
 	/* Note: we always request a commit of the entire inode */
@@ -1337,19 +1355,6 @@ static int nfs_commit_rpcsetup(struct list_head *head,
 	data->res.fattr   = &data->fattr;
 	data->res.verf    = &data->verf;
 	nfs_fattr_init(&data->fattr);
-
-	/* Set up the initial task struct.  */
-	NFS_PROTO(inode)->commit_setup(data, &msg);
-
-	dprintk("NFS: %5u initiated commit call\n", data->task.tk_pid);
-
-	task = rpc_run_task(&task_setup_data);
-	if (IS_ERR(task))
-		return PTR_ERR(task);
-	if (how & FLUSH_SYNC)
-		rpc_wait_for_completion_task(task);
-	rpc_put_task(task);
-	return 0;
 }
 
 /*
@@ -1367,7 +1372,8 @@ nfs_commit_list(struct inode *inode, struct list_head *head, int how)
 		goto out_bad;
 
 	/* Set up the argument struct */
-	return nfs_commit_rpcsetup(head, data, how);
+	nfs_init_commit(data, head);
+	return nfs_initiate_commit(data, NFS_CLIENT(inode), data->mds_ops, how);
  out_bad:
 	while (!list_empty(head)) {
 		req = nfs_list_entry(head->next);
-- 
1.7.2.1

