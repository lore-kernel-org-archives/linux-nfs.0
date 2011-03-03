Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:38652 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755657Ab1CCPOp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Mar 2011 10:14:45 -0500
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 1/9] NFSv4.1: rearrange nfs_write_rpcsetup
Date: Thu,  3 Mar 2011 10:13:41 -0500
Message-Id: <1299165229-3148-2-git-send-email-iisaman@netapp.com>
In-Reply-To: <1299165229-3148-1-git-send-email-iisaman@netapp.com>
References: <1299165229-3148-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Reorder nfs_write_rpcsetup, preparing for a pnfs entry point.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/write.c |   82 +++++++++++++++++++++++++++++++------------------------
 1 files changed, 46 insertions(+), 36 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index aca0268..5604854 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -782,25 +782,21 @@ static int flush_task_priority(int how)
 	return RPC_PRIORITY_NORMAL;
 }
 
-/*
- * Set up the argument/result storage required for the RPC call.
- */
-static int nfs_write_rpcsetup(struct nfs_page *req,
-		struct nfs_write_data *data,
-		const struct rpc_call_ops *call_ops,
-		unsigned int count, unsigned int offset,
-		int how)
+static int nfs_initiate_write(struct nfs_write_data *data,
+		       struct rpc_clnt *clnt,
+		       const struct rpc_call_ops *call_ops,
+		       int how)
 {
-	struct inode *inode = req->wb_context->path.dentry->d_inode;
+	struct inode *inode = data->inode;
 	int priority = flush_task_priority(how);
 	struct rpc_task *task;
 	struct rpc_message msg = {
 		.rpc_argp = &data->args,
 		.rpc_resp = &data->res,
-		.rpc_cred = req->wb_context->cred,
+		.rpc_cred = data->cred,
 	};
 	struct rpc_task_setup task_setup_data = {
-		.rpc_client = NFS_CLIENT(inode),
+		.rpc_client = clnt,
 		.task = &data->task,
 		.rpc_message = &msg,
 		.callback_ops = call_ops,
@@ -811,12 +807,49 @@ static int nfs_write_rpcsetup(struct nfs_page *req,
 	};
 	int ret = 0;
 
+	/* Set up the initial task struct.  */
+	NFS_PROTO(inode)->write_setup(data, &msg);
+
+	dprintk("NFS: %5u initiated write call "
+		"(req %s/%lld, %u bytes @ offset %llu)\n",
+		data->task.tk_pid,
+		inode->i_sb->s_id,
+		(long long)NFS_FILEID(inode),
+		data->args.count,
+		(unsigned long long)data->args.offset);
+
+	task = rpc_run_task(&task_setup_data);
+	if (IS_ERR(task)) {
+		ret = PTR_ERR(task);
+		goto out;
+	}
+	if (how & FLUSH_SYNC) {
+		ret = rpc_wait_for_completion_task(task);
+		if (ret == 0)
+			ret = task->tk_status;
+	}
+	rpc_put_task(task);
+out:
+	return ret;
+}
+
+/*
+ * Set up the argument/result storage required for the RPC call.
+ */
+static int nfs_write_rpcsetup(struct nfs_page *req,
+		struct nfs_write_data *data,
+		const struct rpc_call_ops *call_ops,
+		unsigned int count, unsigned int offset,
+		int how)
+{
+	struct inode *inode = req->wb_context->path.dentry->d_inode;
+
 	/* Set up the RPC argument and reply structs
 	 * NB: take care not to mess about with data->commit et al. */
 
 	data->req = req;
 	data->inode = inode = req->wb_context->path.dentry->d_inode;
-	data->cred = msg.rpc_cred;
+	data->cred = req->wb_context->cred;
 
 	data->args.fh     = NFS_FH(inode);
 	data->args.offset = req_offset(req) + offset;
@@ -837,30 +870,7 @@ static int nfs_write_rpcsetup(struct nfs_page *req,
 	data->res.verf    = &data->verf;
 	nfs_fattr_init(&data->fattr);
 
-	/* Set up the initial task struct.  */
-	NFS_PROTO(inode)->write_setup(data, &msg);
-
-	dprintk("NFS: %5u initiated write call "
-		"(req %s/%lld, %u bytes @ offset %llu)\n",
-		data->task.tk_pid,
-		inode->i_sb->s_id,
-		(long long)NFS_FILEID(inode),
-		count,
-		(unsigned long long)data->args.offset);
-
-	task = rpc_run_task(&task_setup_data);
-	if (IS_ERR(task)) {
-		ret = PTR_ERR(task);
-		goto out;
-	}
-	if (how & FLUSH_SYNC) {
-		ret = rpc_wait_for_completion_task(task);
-		if (ret == 0)
-			ret = task->tk_status;
-	}
-	rpc_put_task(task);
-out:
-	return ret;
+	return nfs_initiate_write(data, NFS_CLIENT(inode), call_ops, how);
 }
 
 /* If a nfs_flush_* function fails, it should remove reqs from @head and
-- 
1.7.2.1

