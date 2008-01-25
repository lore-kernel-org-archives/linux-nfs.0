From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 017/112] SUNRPC: Cleanup of rpc_task initialisation
Date: Fri, 25 Jan 2008 11:37:27 -0500
Message-ID: <20080125163727.31887.54752.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63111 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756840AbYAYRAc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:32 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH0Lmq010494
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:29 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/direct.c              |   36 +++++++++++++++++++++++-------
 fs/nfs/read.c                |   15 ++++++++----
 fs/nfs/write.c               |   30 ++++++++++++++++---------
 include/linux/sunrpc/clnt.h  |    2 +-
 include/linux/sunrpc/sched.h |   14 +++++++-----
 net/sunrpc/clnt.c            |   51 ++++++++++++++++++++++++++++++------------
 net/sunrpc/sched.c           |   27 +++++++++++-----------
 7 files changed, 117 insertions(+), 58 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 3c9d16b..f9f5fc1 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -272,6 +272,11 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
 	unsigned long user_addr = (unsigned long)iov->iov_base;
 	size_t count = iov->iov_len;
 	size_t rsize = NFS_SERVER(inode)->rsize;
+	struct rpc_task_setup task_setup_data = {
+		.rpc_client = NFS_CLIENT(inode),
+		.callback_ops = &nfs_read_direct_ops,
+		.flags = RPC_TASK_ASYNC,
+	};
 	unsigned int pgbase;
 	int result;
 	ssize_t started = 0;
@@ -322,8 +327,8 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
 		data->res.eof = 0;
 		data->res.count = bytes;
 
-		rpc_init_task(&data->task, NFS_CLIENT(inode), RPC_TASK_ASYNC,
-				&nfs_read_direct_ops, data);
+		task_setup_data.callback_data = data;
+		rpc_init_task(&data->task, &task_setup_data);
 		NFS_PROTO(inode)->read_setup(data);
 
 		data->task.tk_cookie = (unsigned long) inode;
@@ -431,6 +436,11 @@ static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 	struct inode *inode = dreq->inode;
 	struct list_head *p;
 	struct nfs_write_data *data;
+	struct rpc_task_setup task_setup_data = {
+		.rpc_client = NFS_CLIENT(inode),
+		.callback_ops = &nfs_write_direct_ops,
+		.flags = RPC_TASK_ASYNC,
+	};
 
 	dreq->count = 0;
 	get_dreq(dreq);
@@ -451,8 +461,8 @@ static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 		 * Reuse data->task; data->args should not have changed
 		 * since the original request was sent.
 		 */
-		rpc_init_task(&data->task, NFS_CLIENT(inode), RPC_TASK_ASYNC,
-				&nfs_write_direct_ops, data);
+		task_setup_data.callback_data = data;
+		rpc_init_task(&data->task, &task_setup_data);
 		NFS_PROTO(inode)->write_setup(data, FLUSH_STABLE);
 
 		data->task.tk_priority = RPC_PRIORITY_NORMAL;
@@ -504,6 +514,12 @@ static const struct rpc_call_ops nfs_commit_direct_ops = {
 static void nfs_direct_commit_schedule(struct nfs_direct_req *dreq)
 {
 	struct nfs_write_data *data = dreq->commit_data;
+	struct rpc_task_setup task_setup_data = {
+		.rpc_client = NFS_CLIENT(dreq->inode),
+		.callback_ops = &nfs_commit_direct_ops,
+		.callback_data = data,
+		.flags = RPC_TASK_ASYNC,
+	};
 
 	data->inode = dreq->inode;
 	data->cred = dreq->ctx->cred;
@@ -515,8 +531,7 @@ static void nfs_direct_commit_schedule(struct nfs_direct_req *dreq)
 	data->res.fattr = &data->fattr;
 	data->res.verf = &data->verf;
 
-	rpc_init_task(&data->task, NFS_CLIENT(dreq->inode), RPC_TASK_ASYNC,
-				&nfs_commit_direct_ops, data);
+	rpc_init_task(&data->task, &task_setup_data);
 	NFS_PROTO(data->inode)->commit_setup(data, 0);
 
 	data->task.tk_priority = RPC_PRIORITY_NORMAL;
@@ -641,6 +656,11 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
 	struct inode *inode = ctx->path.dentry->d_inode;
 	unsigned long user_addr = (unsigned long)iov->iov_base;
 	size_t count = iov->iov_len;
+	struct rpc_task_setup task_setup_data = {
+		.rpc_client = NFS_CLIENT(inode),
+		.callback_ops = &nfs_write_direct_ops,
+		.flags = RPC_TASK_ASYNC,
+	};
 	size_t wsize = NFS_SERVER(inode)->wsize;
 	unsigned int pgbase;
 	int result;
@@ -694,8 +714,8 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
 		data->res.count = bytes;
 		data->res.verf = &data->verf;
 
-		rpc_init_task(&data->task, NFS_CLIENT(inode), RPC_TASK_ASYNC,
-				&nfs_write_direct_ops, data);
+		task_setup_data.callback_data = data;
+		rpc_init_task(&data->task, &task_setup_data);
 		NFS_PROTO(inode)->write_setup(data, sync);
 
 		data->task.tk_priority = RPC_PRIORITY_NORMAL;
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 4587a86..c7f0d5e 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -160,11 +160,17 @@ static void nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
 		const struct rpc_call_ops *call_ops,
 		unsigned int count, unsigned int offset)
 {
-	struct inode		*inode;
-	int flags;
+	struct inode *inode = req->wb_context->path.dentry->d_inode;
+	int swap_flags = IS_SWAPFILE(inode) ? NFS_RPC_SWAPFLAGS : 0;
+	struct rpc_task_setup task_setup_data = {
+		.rpc_client = NFS_CLIENT(inode),
+		.callback_ops = call_ops,
+		.callback_data = data,
+		.flags = RPC_TASK_ASYNC | swap_flags,
+	};
 
 	data->req	  = req;
-	data->inode	  = inode = req->wb_context->path.dentry->d_inode;
+	data->inode	  = inode;
 	data->cred	  = req->wb_context->cred;
 
 	data->args.fh     = NFS_FH(inode);
@@ -180,8 +186,7 @@ static void nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
 	nfs_fattr_init(&data->fattr);
 
 	/* Set up the initial task struct. */
-	flags = RPC_TASK_ASYNC | (IS_SWAPFILE(inode)? NFS_RPC_SWAPFLAGS : 0);
-	rpc_init_task(&data->task, NFS_CLIENT(inode), flags, call_ops, data);
+	rpc_init_task(&data->task, &task_setup_data);
 	NFS_PROTO(inode)->read_setup(data);
 
 	data->task.tk_cookie = (unsigned long)inode;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 092e79c..c437660 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -773,8 +773,14 @@ static void nfs_write_rpcsetup(struct nfs_page *req,
 		unsigned int count, unsigned int offset,
 		int how)
 {
-	struct inode		*inode;
-	int flags;
+	struct inode *inode = req->wb_context->path.dentry->d_inode;
+	int flags = (how & FLUSH_SYNC) ? 0 : RPC_TASK_ASYNC;
+	struct rpc_task_setup task_setup_data = {
+		.rpc_client = NFS_CLIENT(inode),
+		.callback_ops = call_ops,
+		.callback_data = data,
+		.flags = flags,
+	};
 
 	/* Set up the RPC argument and reply structs
 	 * NB: take care not to mess about with data->commit et al. */
@@ -796,8 +802,7 @@ static void nfs_write_rpcsetup(struct nfs_page *req,
 	nfs_fattr_init(&data->fattr);
 
 	/* Set up the initial task struct.  */
-	flags = (how & FLUSH_SYNC) ? 0 : RPC_TASK_ASYNC;
-	rpc_init_task(&data->task, NFS_CLIENT(inode), flags, call_ops, data);
+	rpc_init_task(&data->task, &task_setup_data);
 	NFS_PROTO(inode)->write_setup(data, how);
 
 	data->task.tk_priority = flush_task_priority(how);
@@ -1144,16 +1149,20 @@ static void nfs_commit_rpcsetup(struct list_head *head,
 		struct nfs_write_data *data,
 		int how)
 {
-	struct nfs_page		*first;
-	struct inode		*inode;
-	int flags;
+	struct nfs_page *first = nfs_list_entry(head->next);
+	struct inode *inode = first->wb_context->path.dentry->d_inode;
+	int flags = (how & FLUSH_SYNC) ? 0 : RPC_TASK_ASYNC;
+	struct rpc_task_setup task_setup_data = {
+		.rpc_client = NFS_CLIENT(inode),
+		.callback_ops = &nfs_commit_ops,
+		.callback_data = data,
+		.flags = flags,
+	};
 
 	/* Set up the RPC argument and reply structs
 	 * NB: take care not to mess about with data->commit et al. */
 
 	list_splice_init(head, &data->pages);
-	first = nfs_list_entry(data->pages.next);
-	inode = first->wb_context->path.dentry->d_inode;
 
 	data->inode	  = inode;
 	data->cred	  = first->wb_context->cred;
@@ -1168,8 +1177,7 @@ static void nfs_commit_rpcsetup(struct list_head *head,
 	nfs_fattr_init(&data->fattr);
 
 	/* Set up the initial task struct.  */
-	flags = (how & FLUSH_SYNC) ? 0 : RPC_TASK_ASYNC;
-	rpc_init_task(&data->task, NFS_CLIENT(inode), flags, &nfs_commit_ops, data);
+	rpc_init_task(&data->task, &task_setup_data);
 	NFS_PROTO(inode)->commit_setup(data, how);
 
 	data->task.tk_priority = flush_task_priority(how);
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index d9d5c5a..ec97041 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -126,7 +126,7 @@ int		rpcb_register(u32, u32, int, unsigned short, int *);
 int		rpcb_getport_sync(struct sockaddr_in *, __u32, __u32, int);
 void		rpcb_getport_async(struct rpc_task *);
 
-void		rpc_call_setup(struct rpc_task *, struct rpc_message *, int);
+void		rpc_call_setup(struct rpc_task *, const struct rpc_message *, int);
 
 int		rpc_call_async(struct rpc_clnt *clnt, struct rpc_message *msg,
 			       int flags, const struct rpc_call_ops *tk_ops,
diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 8ea077d..9efe045 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -117,6 +117,13 @@ struct rpc_call_ops {
 	void (*rpc_release)(void *);
 };
 
+struct rpc_task_setup {
+	struct rpc_clnt *rpc_client;
+	const struct rpc_message *rpc_message;
+	const struct rpc_call_ops *callback_ops;
+	void *callback_data;
+	unsigned short flags;
+};
 
 /*
  * RPC task flags
@@ -236,13 +243,10 @@ struct rpc_wait_queue {
 /*
  * Function prototypes
  */
-struct rpc_task *rpc_new_task(struct rpc_clnt *, int flags,
-				const struct rpc_call_ops *ops, void *data);
+struct rpc_task *rpc_new_task(const struct rpc_task_setup *);
 struct rpc_task *rpc_run_task(struct rpc_clnt *clnt, int flags,
 				const struct rpc_call_ops *ops, void *data);
-void		rpc_init_task(struct rpc_task *task, struct rpc_clnt *clnt,
-				int flags, const struct rpc_call_ops *ops,
-				void *data);
+void		rpc_init_task(struct rpc_task *task, const struct rpc_task_setup *);
 void		rpc_put_task(struct rpc_task *);
 void		rpc_exit_task(struct rpc_task *);
 void		rpc_release_calldata(const struct rpc_call_ops *, void *);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 22092b9..7c80abd 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -524,25 +524,22 @@ void rpc_clnt_sigunmask(struct rpc_clnt *clnt, sigset_t *oldset)
 EXPORT_SYMBOL_GPL(rpc_clnt_sigunmask);
 
 static
-struct rpc_task *rpc_do_run_task(struct rpc_clnt *clnt,
-		struct rpc_message *msg,
-		int flags,
-		const struct rpc_call_ops *ops,
-		void *data)
+struct rpc_task *rpc_do_run_task(const struct rpc_task_setup *task_setup_data)
 {
 	struct rpc_task *task, *ret;
 	sigset_t oldset;
 
-	task = rpc_new_task(clnt, flags, ops, data);
+	task = rpc_new_task(task_setup_data);
 	if (task == NULL) {
-		rpc_release_calldata(ops, data);
+		rpc_release_calldata(task_setup_data->callback_ops,
+				task_setup_data->callback_data);
 		return ERR_PTR(-ENOMEM);
 	}
 
 	/* Mask signals on synchronous RPC calls and RPCSEC_GSS upcalls */
 	rpc_task_sigmask(task, &oldset);
-	if (msg != NULL) {
-		rpc_call_setup(task, msg, 0);
+	if (task_setup_data->rpc_message != NULL) {
+		rpc_call_setup(task, task_setup_data->rpc_message, 0);
 		if (task->tk_status != 0) {
 			ret = ERR_PTR(task->tk_status);
 			rpc_put_task(task);
@@ -566,11 +563,17 @@ out:
 int rpc_call_sync(struct rpc_clnt *clnt, struct rpc_message *msg, int flags)
 {
 	struct rpc_task	*task;
+	struct rpc_task_setup task_setup_data = {
+		.rpc_client = clnt,
+		.rpc_message = msg,
+		.callback_ops = &rpc_default_ops,
+		.flags = flags,
+	};
 	int status;
 
 	BUG_ON(flags & RPC_TASK_ASYNC);
 
-	task = rpc_do_run_task(clnt, msg, flags, &rpc_default_ops, NULL);
+	task = rpc_do_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
 	status = task->tk_status;
@@ -592,8 +595,15 @@ rpc_call_async(struct rpc_clnt *clnt, struct rpc_message *msg, int flags,
 	       const struct rpc_call_ops *tk_ops, void *data)
 {
 	struct rpc_task	*task;
+	struct rpc_task_setup task_setup_data = {
+		.rpc_client = clnt,
+		.rpc_message = msg,
+		.callback_ops = tk_ops,
+		.callback_data = data,
+		.flags = flags|RPC_TASK_ASYNC,
+	};
 
-	task = rpc_do_run_task(clnt, msg, flags|RPC_TASK_ASYNC, tk_ops, data);
+	task = rpc_do_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
 	rpc_put_task(task);
@@ -612,12 +622,19 @@ struct rpc_task *rpc_run_task(struct rpc_clnt *clnt, int flags,
 					const struct rpc_call_ops *tk_ops,
 					void *data)
 {
-	return rpc_do_run_task(clnt, NULL, flags, tk_ops, data);
+	struct rpc_task_setup task_setup_data = {
+		.rpc_client = clnt,
+		.callback_ops = tk_ops,
+		.callback_data = data,
+		.flags = flags,
+	};
+
+	return rpc_do_run_task(&task_setup_data);
 }
 EXPORT_SYMBOL_GPL(rpc_run_task);
 
 void
-rpc_call_setup(struct rpc_task *task, struct rpc_message *msg, int flags)
+rpc_call_setup(struct rpc_task *task, const struct rpc_message *msg, int flags)
 {
 	task->tk_msg   = *msg;
 	task->tk_flags |= flags;
@@ -1527,7 +1544,13 @@ struct rpc_task *rpc_call_null(struct rpc_clnt *clnt, struct rpc_cred *cred, int
 		.rpc_proc = &rpcproc_null,
 		.rpc_cred = cred,
 	};
-	return rpc_do_run_task(clnt, &msg, flags, &rpc_default_ops, NULL);
+	struct rpc_task_setup task_setup_data = {
+		.rpc_client = clnt,
+		.rpc_message = &msg,
+		.callback_ops = &rpc_default_ops,
+		.flags = flags,
+	};
+	return rpc_do_run_task(&task_setup_data);
 }
 EXPORT_SYMBOL_GPL(rpc_call_null);
 
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 583a78c..2bcaef5 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -815,19 +815,16 @@ EXPORT_SYMBOL_GPL(rpc_free);
 /*
  * Creation and deletion of RPC task structures
  */
-void rpc_init_task(struct rpc_task *task, struct rpc_clnt *clnt, int flags, const struct rpc_call_ops *tk_ops, void *calldata)
+void rpc_init_task(struct rpc_task *task, const struct rpc_task_setup *task_setup_data)
 {
 	memset(task, 0, sizeof(*task));
 	init_timer(&task->tk_timer);
 	task->tk_timer.data     = (unsigned long) task;
 	task->tk_timer.function = (void (*)(unsigned long)) rpc_run_timer;
 	atomic_set(&task->tk_count, 1);
-	task->tk_client = clnt;
-	task->tk_flags  = flags;
-	task->tk_ops = tk_ops;
-	if (tk_ops->rpc_call_prepare != NULL)
-		task->tk_action = rpc_prepare_task;
-	task->tk_calldata = calldata;
+	task->tk_flags  = task_setup_data->flags;
+	task->tk_ops = task_setup_data->callback_ops;
+	task->tk_calldata = task_setup_data->callback_data;
 	INIT_LIST_HEAD(&task->tk_task);
 
 	/* Initialize retry counters */
@@ -840,15 +837,17 @@ void rpc_init_task(struct rpc_task *task, struct rpc_clnt *clnt, int flags, cons
 	/* Initialize workqueue for async tasks */
 	task->tk_workqueue = rpciod_workqueue;
 
-	if (clnt) {
-		kref_get(&clnt->cl_kref);
-		if (clnt->cl_softrtry)
+	task->tk_client = task_setup_data->rpc_client;
+	if (task->tk_client != NULL) {
+		kref_get(&task->tk_client->cl_kref);
+		if (task->tk_client->cl_softrtry)
 			task->tk_flags |= RPC_TASK_SOFT;
-		if (!clnt->cl_intr)
+		if (!task->tk_client->cl_intr)
 			task->tk_flags |= RPC_TASK_NOINTR;
 	}
 
-	BUG_ON(task->tk_ops == NULL);
+	if (task->tk_ops->rpc_call_prepare != NULL)
+		task->tk_action = rpc_prepare_task;
 
 	/* starting timestamp */
 	task->tk_start = jiffies;
@@ -874,7 +873,7 @@ static void rpc_free_task(struct rcu_head *rcu)
 /*
  * Create a new task for the specified client.
  */
-struct rpc_task *rpc_new_task(struct rpc_clnt *clnt, int flags, const struct rpc_call_ops *tk_ops, void *calldata)
+struct rpc_task *rpc_new_task(const struct rpc_task_setup *setup_data)
 {
 	struct rpc_task	*task;
 
@@ -882,7 +881,7 @@ struct rpc_task *rpc_new_task(struct rpc_clnt *clnt, int flags, const struct rpc
 	if (!task)
 		goto out;
 
-	rpc_init_task(task, clnt, flags, tk_ops, calldata);
+	rpc_init_task(task, setup_data);
 
 	dprintk("RPC:       allocated task %p\n", task);
 	task->tk_flags |= RPC_TASK_DYNAMIC;
