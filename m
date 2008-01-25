From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 027/112] NFS/SUNRPC: Convert users of
	rpc_init_task+rpc_execute to rpc_run_task()
Date: Fri, 25 Jan 2008 11:37:30 -0500
Message-ID: <20080125163730.31887.5287.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14342 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754909AbYAYQ7t (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 11:59:49 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxlnl019995
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 08:59:48 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/direct.c |   28 ++++++++++++++++++++--------
 fs/nfs/read.c   |   17 +++++------------
 fs/nfs/write.c  |   24 ++++++++++--------------
 3 files changed, 35 insertions(+), 34 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 244d1bd..eadd87f 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -272,6 +272,7 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
 	unsigned long user_addr = (unsigned long)iov->iov_base;
 	size_t count = iov->iov_len;
 	size_t rsize = NFS_SERVER(inode)->rsize;
+	struct rpc_task *task;
 	struct rpc_message msg = {
 		.rpc_cred = ctx->cred,
 	};
@@ -333,11 +334,13 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
 		msg.rpc_argp = &data->args;
 		msg.rpc_resp = &data->res;
 
+		task_setup_data.task = &data->task;
 		task_setup_data.callback_data = data;
 		NFS_PROTO(inode)->read_setup(data, &msg);
-		rpc_init_task(&data->task, &task_setup_data);
 
-		rpc_execute(&data->task);
+		task = rpc_run_task(&task_setup_data);
+		if (!IS_ERR(task))
+			rpc_put_task(task);
 
 		dprintk("NFS: %5u initiated direct read call "
 			"(req %s/%Ld, %zu bytes @ offset %Lu)\n",
@@ -440,6 +443,7 @@ static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 	struct inode *inode = dreq->inode;
 	struct list_head *p;
 	struct nfs_write_data *data;
+	struct rpc_task *task;
 	struct rpc_message msg = {
 		.rpc_cred = dreq->ctx->cred,
 	};
@@ -471,16 +475,18 @@ static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 		 * Reuse data->task; data->args should not have changed
 		 * since the original request was sent.
 		 */
+		task_setup_data.task = &data->task;
 		task_setup_data.callback_data = data;
 		msg.rpc_argp = &data->args;
 		msg.rpc_resp = &data->res;
 		NFS_PROTO(inode)->write_setup(data, &msg);
-		rpc_init_task(&data->task, &task_setup_data);
 
 		/*
 		 * We're called via an RPC callback, so BKL is already held.
 		 */
-		rpc_execute(&data->task);
+		task = rpc_run_task(&task_setup_data);
+		if (!IS_ERR(task))
+			rpc_put_task(task);
 
 		dprintk("NFS: %5u rescheduled direct write call (req %s/%Ld, %u bytes @ offset %Lu)\n",
 				data->task.tk_pid,
@@ -523,12 +529,14 @@ static const struct rpc_call_ops nfs_commit_direct_ops = {
 static void nfs_direct_commit_schedule(struct nfs_direct_req *dreq)
 {
 	struct nfs_write_data *data = dreq->commit_data;
+	struct rpc_task *task;
 	struct rpc_message msg = {
 		.rpc_argp = &data->args,
 		.rpc_resp = &data->res,
 		.rpc_cred = dreq->ctx->cred,
 	};
 	struct rpc_task_setup task_setup_data = {
+		.task = &data->task,
 		.rpc_client = NFS_CLIENT(dreq->inode),
 		.rpc_message = &msg,
 		.callback_ops = &nfs_commit_direct_ops,
@@ -547,14 +555,15 @@ static void nfs_direct_commit_schedule(struct nfs_direct_req *dreq)
 	data->res.verf = &data->verf;
 
 	NFS_PROTO(data->inode)->commit_setup(data, &msg);
-	rpc_init_task(&data->task, &task_setup_data);
 
 	/* Note: task.tk_ops->rpc_release will free dreq->commit_data */
 	dreq->commit_data = NULL;
 
 	dprintk("NFS: %5u initiated commit call\n", data->task.tk_pid);
 
-	rpc_execute(&data->task);
+	task = rpc_run_task(&task_setup_data);
+	if (!IS_ERR(task))
+		rpc_put_task(task);
 }
 
 static void nfs_direct_write_complete(struct nfs_direct_req *dreq, struct inode *inode)
@@ -669,6 +678,7 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
 	struct inode *inode = ctx->path.dentry->d_inode;
 	unsigned long user_addr = (unsigned long)iov->iov_base;
 	size_t count = iov->iov_len;
+	struct rpc_task *task;
 	struct rpc_message msg = {
 		.rpc_cred = ctx->cred,
 	};
@@ -732,13 +742,15 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
 		data->res.count = bytes;
 		data->res.verf = &data->verf;
 
+		task_setup_data.task = &data->task;
 		task_setup_data.callback_data = data;
 		msg.rpc_argp = &data->args;
 		msg.rpc_resp = &data->res;
 		NFS_PROTO(inode)->write_setup(data, &msg);
-		rpc_init_task(&data->task, &task_setup_data);
 
-		rpc_execute(&data->task);
+		task = rpc_run_task(&task_setup_data);
+		if (!IS_ERR(task))
+			rpc_put_task(task);
 
 		dprintk("NFS: %5u initiated direct write call "
 			"(req %s/%Ld, %zu bytes @ offset %Lu)\n",
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index e9dbdc8..efc121c 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -153,16 +153,6 @@ static void nfs_readpage_release(struct nfs_page *req)
 	nfs_release_request(req);
 }
 
-static void nfs_execute_read(struct nfs_read_data *data)
-{
-	struct rpc_clnt *clnt = NFS_CLIENT(data->inode);
-	sigset_t oldset;
-
-	rpc_clnt_sigmask(clnt, &oldset);
-	rpc_execute(&data->task);
-	rpc_clnt_sigunmask(clnt, &oldset);
-}
-
 /*
  * Set up the NFS read request struct
  */
@@ -172,12 +162,14 @@ static void nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
 {
 	struct inode *inode = req->wb_context->path.dentry->d_inode;
 	int swap_flags = IS_SWAPFILE(inode) ? NFS_RPC_SWAPFLAGS : 0;
+	struct rpc_task *task;
 	struct rpc_message msg = {
 		.rpc_argp = &data->args,
 		.rpc_resp = &data->res,
 		.rpc_cred = req->wb_context->cred,
 	};
 	struct rpc_task_setup task_setup_data = {
+		.task = &data->task,
 		.rpc_client = NFS_CLIENT(inode),
 		.rpc_message = &msg,
 		.callback_ops = call_ops,
@@ -203,7 +195,6 @@ static void nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
 
 	/* Set up the initial task struct. */
 	NFS_PROTO(inode)->read_setup(data, &msg);
-	rpc_init_task(&data->task, &task_setup_data);
 
 	dprintk("NFS: %5u initiated read call (req %s/%Ld, %u bytes @ offset %Lu)\n",
 			data->task.tk_pid,
@@ -212,7 +203,9 @@ static void nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
 			count,
 			(unsigned long long)data->args.offset);
 
-	nfs_execute_read(data);
+	task = rpc_run_task(&task_setup_data);
+	if (!IS_ERR(task))
+		rpc_put_task(task);
 }
 
 static void
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 9a69469..fbd64f2 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -764,16 +764,6 @@ static int flush_task_priority(int how)
 	return RPC_PRIORITY_NORMAL;
 }
 
-static void nfs_execute_write(struct nfs_write_data *data)
-{
-	struct rpc_clnt *clnt = NFS_CLIENT(data->inode);
-	sigset_t oldset;
-
-	rpc_clnt_sigmask(clnt, &oldset);
-	rpc_execute(&data->task);
-	rpc_clnt_sigunmask(clnt, &oldset);
-}
-
 /*
  * Set up the argument/result storage required for the RPC call.
  */
@@ -786,6 +776,7 @@ static void nfs_write_rpcsetup(struct nfs_page *req,
 	struct inode *inode = req->wb_context->path.dentry->d_inode;
 	int flags = (how & FLUSH_SYNC) ? 0 : RPC_TASK_ASYNC;
 	int priority = flush_task_priority(how);
+	struct rpc_task *task;
 	struct rpc_message msg = {
 		.rpc_argp = &data->args,
 		.rpc_resp = &data->res,
@@ -793,6 +784,7 @@ static void nfs_write_rpcsetup(struct nfs_page *req,
 	};
 	struct rpc_task_setup task_setup_data = {
 		.rpc_client = NFS_CLIENT(inode),
+		.task = &data->task,
 		.rpc_message = &msg,
 		.callback_ops = call_ops,
 		.callback_data = data,
@@ -827,7 +819,6 @@ static void nfs_write_rpcsetup(struct nfs_page *req,
 
 	/* Set up the initial task struct.  */
 	NFS_PROTO(inode)->write_setup(data, &msg);
-	rpc_init_task(&data->task, &task_setup_data);
 
 	dprintk("NFS: %5u initiated write call "
 		"(req %s/%Ld, %u bytes @ offset %Lu)\n",
@@ -837,7 +828,9 @@ static void nfs_write_rpcsetup(struct nfs_page *req,
 		count,
 		(unsigned long long)data->args.offset);
 
-	nfs_execute_write(data);
+	task = rpc_run_task(&task_setup_data);
+	if (!IS_ERR(task))
+		rpc_put_task(task);
 }
 
 /*
@@ -1164,12 +1157,14 @@ static void nfs_commit_rpcsetup(struct list_head *head,
 	struct inode *inode = first->wb_context->path.dentry->d_inode;
 	int flags = (how & FLUSH_SYNC) ? 0 : RPC_TASK_ASYNC;
 	int priority = flush_task_priority(how);
+	struct rpc_task *task;
 	struct rpc_message msg = {
 		.rpc_argp = &data->args,
 		.rpc_resp = &data->res,
 		.rpc_cred = first->wb_context->cred,
 	};
 	struct rpc_task_setup task_setup_data = {
+		.task = &data->task,
 		.rpc_client = NFS_CLIENT(inode),
 		.rpc_message = &msg,
 		.callback_ops = &nfs_commit_ops,
@@ -1197,11 +1192,12 @@ static void nfs_commit_rpcsetup(struct list_head *head,
 
 	/* Set up the initial task struct.  */
 	NFS_PROTO(inode)->commit_setup(data, &msg);
-	rpc_init_task(&data->task, &task_setup_data);
 
 	dprintk("NFS: %5u initiated commit call\n", data->task.tk_pid);
 
-	nfs_execute_write(data);
+	task = rpc_run_task(&task_setup_data);
+	if (!IS_ERR(task))
+		rpc_put_task(task);
 }
 
 /*
