From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 023/112] NFS: Clean up the (commit|read|write)_setup()
	callback routines
Date: Fri, 25 Jan 2008 11:37:29 -0500
Message-ID: <20080125163729.31887.55003.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:53199 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756866AbYAYRAe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:34 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH0Lmu010494
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:30 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move the common code for setting up the nfs_write_data and nfs_read_data
structures into fs/nfs/read.c, fs/nfs/write.c and fs/nfs/direct.c.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/direct.c         |   45 +++++++++++++++++++++++++++++++++--------
 fs/nfs/nfs3proc.c       |   41 ++++++--------------------------------
 fs/nfs/nfs4proc.c       |   49 +++++++--------------------------------------
 fs/nfs/proc.c           |   26 +++++-------------------
 fs/nfs/read.c           |   38 ++++++++++++++++++-----------------
 fs/nfs/write.c          |   51 ++++++++++++++++++++++++++++++++---------------
 include/linux/nfs_xdr.h |    6 +++---
 7 files changed, 113 insertions(+), 143 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 5bcc764..244d1bd 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -272,8 +272,12 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
 	unsigned long user_addr = (unsigned long)iov->iov_base;
 	size_t count = iov->iov_len;
 	size_t rsize = NFS_SERVER(inode)->rsize;
+	struct rpc_message msg = {
+		.rpc_cred = ctx->cred,
+	};
 	struct rpc_task_setup task_setup_data = {
 		.rpc_client = NFS_CLIENT(inode),
+		.rpc_message = &msg,
 		.callback_ops = &nfs_read_direct_ops,
 		.flags = RPC_TASK_ASYNC,
 	};
@@ -316,7 +320,7 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
 
 		data->req = (struct nfs_page *) dreq;
 		data->inode = inode;
-		data->cred = ctx->cred;
+		data->cred = msg.rpc_cred;
 		data->args.fh = NFS_FH(inode);
 		data->args.context = ctx;
 		data->args.offset = pos;
@@ -326,10 +330,12 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
 		data->res.fattr = &data->fattr;
 		data->res.eof = 0;
 		data->res.count = bytes;
+		msg.rpc_argp = &data->args;
+		msg.rpc_resp = &data->res;
 
 		task_setup_data.callback_data = data;
+		NFS_PROTO(inode)->read_setup(data, &msg);
 		rpc_init_task(&data->task, &task_setup_data);
-		NFS_PROTO(inode)->read_setup(data);
 
 		rpc_execute(&data->task);
 
@@ -434,6 +440,9 @@ static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 	struct inode *inode = dreq->inode;
 	struct list_head *p;
 	struct nfs_write_data *data;
+	struct rpc_message msg = {
+		.rpc_cred = dreq->ctx->cred,
+	};
 	struct rpc_task_setup task_setup_data = {
 		.rpc_client = NFS_CLIENT(inode),
 		.callback_ops = &nfs_write_direct_ops,
@@ -448,6 +457,9 @@ static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 
 		get_dreq(dreq);
 
+		/* Use stable writes */
+		data->args.stable = NFS_FILE_SYNC;
+
 		/*
 		 * Reset data->res.
 		 */
@@ -460,8 +472,10 @@ static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 		 * since the original request was sent.
 		 */
 		task_setup_data.callback_data = data;
+		msg.rpc_argp = &data->args;
+		msg.rpc_resp = &data->res;
+		NFS_PROTO(inode)->write_setup(data, &msg);
 		rpc_init_task(&data->task, &task_setup_data);
-		NFS_PROTO(inode)->write_setup(data, FLUSH_STABLE);
 
 		/*
 		 * We're called via an RPC callback, so BKL is already held.
@@ -509,15 +523,21 @@ static const struct rpc_call_ops nfs_commit_direct_ops = {
 static void nfs_direct_commit_schedule(struct nfs_direct_req *dreq)
 {
 	struct nfs_write_data *data = dreq->commit_data;
+	struct rpc_message msg = {
+		.rpc_argp = &data->args,
+		.rpc_resp = &data->res,
+		.rpc_cred = dreq->ctx->cred,
+	};
 	struct rpc_task_setup task_setup_data = {
 		.rpc_client = NFS_CLIENT(dreq->inode),
+		.rpc_message = &msg,
 		.callback_ops = &nfs_commit_direct_ops,
 		.callback_data = data,
 		.flags = RPC_TASK_ASYNC,
 	};
 
 	data->inode = dreq->inode;
-	data->cred = dreq->ctx->cred;
+	data->cred = msg.rpc_cred;
 
 	data->args.fh = NFS_FH(data->inode);
 	data->args.offset = 0;
@@ -526,8 +546,8 @@ static void nfs_direct_commit_schedule(struct nfs_direct_req *dreq)
 	data->res.fattr = &data->fattr;
 	data->res.verf = &data->verf;
 
+	NFS_PROTO(data->inode)->commit_setup(data, &msg);
 	rpc_init_task(&data->task, &task_setup_data);
-	NFS_PROTO(data->inode)->commit_setup(data, 0);
 
 	/* Note: task.tk_ops->rpc_release will free dreq->commit_data */
 	dreq->commit_data = NULL;
@@ -649,8 +669,12 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
 	struct inode *inode = ctx->path.dentry->d_inode;
 	unsigned long user_addr = (unsigned long)iov->iov_base;
 	size_t count = iov->iov_len;
+	struct rpc_message msg = {
+		.rpc_cred = ctx->cred,
+	};
 	struct rpc_task_setup task_setup_data = {
 		.rpc_client = NFS_CLIENT(inode),
+		.rpc_message = &msg,
 		.callback_ops = &nfs_write_direct_ops,
 		.flags = RPC_TASK_ASYNC,
 	};
@@ -696,20 +720,23 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
 
 		data->req = (struct nfs_page *) dreq;
 		data->inode = inode;
-		data->cred = ctx->cred;
+		data->cred = msg.rpc_cred;
 		data->args.fh = NFS_FH(inode);
 		data->args.context = ctx;
 		data->args.offset = pos;
 		data->args.pgbase = pgbase;
 		data->args.pages = data->pagevec;
 		data->args.count = bytes;
+		data->args.stable = sync;
 		data->res.fattr = &data->fattr;
 		data->res.count = bytes;
 		data->res.verf = &data->verf;
 
 		task_setup_data.callback_data = data;
+		msg.rpc_argp = &data->args;
+		msg.rpc_resp = &data->res;
+		NFS_PROTO(inode)->write_setup(data, &msg);
 		rpc_init_task(&data->task, &task_setup_data);
-		NFS_PROTO(inode)->write_setup(data, sync);
 
 		rpc_execute(&data->task);
 
@@ -782,7 +809,7 @@ static ssize_t nfs_direct_write(struct kiocb *iocb, const struct iovec *iov,
 	struct rpc_clnt *clnt = NFS_CLIENT(inode);
 	struct nfs_direct_req *dreq;
 	size_t wsize = NFS_SERVER(inode)->wsize;
-	int sync = 0;
+	int sync = NFS_UNSTABLE;
 
 	dreq = nfs_direct_req_alloc();
 	if (!dreq)
@@ -790,7 +817,7 @@ static ssize_t nfs_direct_write(struct kiocb *iocb, const struct iovec *iov,
 	nfs_alloc_commit_data(dreq);
 
 	if (dreq->commit_data == NULL || count < wsize)
-		sync = FLUSH_STABLE;
+		sync = NFS_FILE_SYNC;
 
 	dreq->inode = inode;
 	dreq->ctx = get_nfs_open_context(nfs_file_open_context(iocb->ki_filp));
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 4cdc236..e68580e 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -732,16 +732,9 @@ static int nfs3_read_done(struct rpc_task *task, struct nfs_read_data *data)
 	return 0;
 }
 
-static void nfs3_proc_read_setup(struct nfs_read_data *data)
+static void nfs3_proc_read_setup(struct nfs_read_data *data, struct rpc_message *msg)
 {
-	struct rpc_message	msg = {
-		.rpc_proc	= &nfs3_procedures[NFS3PROC_READ],
-		.rpc_argp	= &data->args,
-		.rpc_resp	= &data->res,
-		.rpc_cred	= data->cred,
-	};
-
-	rpc_call_setup(&data->task, &msg, 0);
+	msg->rpc_proc = &nfs3_procedures[NFS3PROC_READ];
 }
 
 static int nfs3_write_done(struct rpc_task *task, struct nfs_write_data *data)
@@ -753,24 +746,9 @@ static int nfs3_write_done(struct rpc_task *task, struct nfs_write_data *data)
 	return 0;
 }
 
-static void nfs3_proc_write_setup(struct nfs_write_data *data, int how)
+static void nfs3_proc_write_setup(struct nfs_write_data *data, struct rpc_message *msg)
 {
-	struct rpc_message	msg = {
-		.rpc_proc	= &nfs3_procedures[NFS3PROC_WRITE],
-		.rpc_argp	= &data->args,
-		.rpc_resp	= &data->res,
-		.rpc_cred	= data->cred,
-	};
-
-	data->args.stable = NFS_UNSTABLE;
-	if (how & FLUSH_STABLE) {
-		data->args.stable = NFS_FILE_SYNC;
-		if (NFS_I(data->inode)->ncommit)
-			data->args.stable = NFS_DATA_SYNC;
-	}
-
-	/* Finalize the task. */
-	rpc_call_setup(&data->task, &msg, 0);
+	msg->rpc_proc = &nfs3_procedures[NFS3PROC_WRITE];
 }
 
 static int nfs3_commit_done(struct rpc_task *task, struct nfs_write_data *data)
@@ -781,16 +759,9 @@ static int nfs3_commit_done(struct rpc_task *task, struct nfs_write_data *data)
 	return 0;
 }
 
-static void nfs3_proc_commit_setup(struct nfs_write_data *data, int how)
+static void nfs3_proc_commit_setup(struct nfs_write_data *data, struct rpc_message *msg)
 {
-	struct rpc_message	msg = {
-		.rpc_proc	= &nfs3_procedures[NFS3PROC_COMMIT],
-		.rpc_argp	= &data->args,
-		.rpc_resp	= &data->res,
-		.rpc_cred	= data->cred,
-	};
-
-	rpc_call_setup(&data->task, &msg, 0);
+	msg->rpc_proc = &nfs3_procedures[NFS3PROC_COMMIT];
 }
 
 static int
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ff2c5f8..7c0baf2 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2432,18 +2432,10 @@ static int nfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
 	return 0;
 }
 
-static void nfs4_proc_read_setup(struct nfs_read_data *data)
+static void nfs4_proc_read_setup(struct nfs_read_data *data, struct rpc_message *msg)
 {
-	struct rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_READ],
-		.rpc_argp = &data->args,
-		.rpc_resp = &data->res,
-		.rpc_cred = data->cred,
-	};
-
 	data->timestamp   = jiffies;
-
-	rpc_call_setup(&data->task, &msg, 0);
+	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_READ];
 }
 
 static int nfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
@@ -2461,33 +2453,15 @@ static int nfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
 	return 0;
 }
 
-static void nfs4_proc_write_setup(struct nfs_write_data *data, int how)
+static void nfs4_proc_write_setup(struct nfs_write_data *data, struct rpc_message *msg)
 {
-	struct rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_WRITE],
-		.rpc_argp = &data->args,
-		.rpc_resp = &data->res,
-		.rpc_cred = data->cred,
-	};
-	struct inode *inode = data->inode;
-	struct nfs_server *server = NFS_SERVER(inode);
-	int stable;
-	
-	if (how & FLUSH_STABLE) {
-		if (!NFS_I(inode)->ncommit)
-			stable = NFS_FILE_SYNC;
-		else
-			stable = NFS_DATA_SYNC;
-	} else
-		stable = NFS_UNSTABLE;
-	data->args.stable = stable;
+	struct nfs_server *server = NFS_SERVER(data->inode);
+
 	data->args.bitmask = server->attr_bitmask;
 	data->res.server = server;
-
 	data->timestamp   = jiffies;
 
-	/* Finalize the task. */
-	rpc_call_setup(&data->task, &msg, 0);
+	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_WRITE];
 }
 
 static int nfs4_commit_done(struct rpc_task *task, struct nfs_write_data *data)
@@ -2502,20 +2476,13 @@ static int nfs4_commit_done(struct rpc_task *task, struct nfs_write_data *data)
 	return 0;
 }
 
-static void nfs4_proc_commit_setup(struct nfs_write_data *data, int how)
+static void nfs4_proc_commit_setup(struct nfs_write_data *data, struct rpc_message *msg)
 {
-	struct rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_COMMIT],
-		.rpc_argp = &data->args,
-		.rpc_resp = &data->res,
-		.rpc_cred = data->cred,
-	};	
 	struct nfs_server *server = NFS_SERVER(data->inode);
 	
 	data->args.bitmask = server->attr_bitmask;
 	data->res.server = server;
-
-	rpc_call_setup(&data->task, &msg, 0);
+	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_COMMIT];
 }
 
 /*
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 4f80d88..c9f46a2 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -565,16 +565,9 @@ static int nfs_read_done(struct rpc_task *task, struct nfs_read_data *data)
 	return 0;
 }
 
-static void nfs_proc_read_setup(struct nfs_read_data *data)
+static void nfs_proc_read_setup(struct nfs_read_data *data, struct rpc_message *msg)
 {
-	struct rpc_message	msg = {
-		.rpc_proc	= &nfs_procedures[NFSPROC_READ],
-		.rpc_argp	= &data->args,
-		.rpc_resp	= &data->res,
-		.rpc_cred	= data->cred,
-	};
-
-	rpc_call_setup(&data->task, &msg, 0);
+	msg->rpc_proc = &nfs_procedures[NFSPROC_READ];
 }
 
 static int nfs_write_done(struct rpc_task *task, struct nfs_write_data *data)
@@ -584,24 +577,15 @@ static int nfs_write_done(struct rpc_task *task, struct nfs_write_data *data)
 	return 0;
 }
 
-static void nfs_proc_write_setup(struct nfs_write_data *data, int how)
+static void nfs_proc_write_setup(struct nfs_write_data *data, struct rpc_message *msg)
 {
-	struct rpc_message	msg = {
-		.rpc_proc	= &nfs_procedures[NFSPROC_WRITE],
-		.rpc_argp	= &data->args,
-		.rpc_resp	= &data->res,
-		.rpc_cred	= data->cred,
-	};
-
 	/* Note: NFSv2 ignores @stable and always uses NFS_FILE_SYNC */
 	data->args.stable = NFS_FILE_SYNC;
-
-	/* Finalize the task. */
-	rpc_call_setup(&data->task, &msg, 0);
+	msg->rpc_proc = &nfs_procedures[NFSPROC_WRITE];
 }
 
 static void
-nfs_proc_commit_setup(struct nfs_write_data *data, int how)
+nfs_proc_commit_setup(struct nfs_write_data *data, struct rpc_message *msg)
 {
 	BUG();
 }
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 8f1eb08..e9dbdc8 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -153,6 +153,16 @@ static void nfs_readpage_release(struct nfs_page *req)
 	nfs_release_request(req);
 }
 
+static void nfs_execute_read(struct nfs_read_data *data)
+{
+	struct rpc_clnt *clnt = NFS_CLIENT(data->inode);
+	sigset_t oldset;
+
+	rpc_clnt_sigmask(clnt, &oldset);
+	rpc_execute(&data->task);
+	rpc_clnt_sigunmask(clnt, &oldset);
+}
+
 /*
  * Set up the NFS read request struct
  */
@@ -162,8 +172,14 @@ static void nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
 {
 	struct inode *inode = req->wb_context->path.dentry->d_inode;
 	int swap_flags = IS_SWAPFILE(inode) ? NFS_RPC_SWAPFLAGS : 0;
+	struct rpc_message msg = {
+		.rpc_argp = &data->args,
+		.rpc_resp = &data->res,
+		.rpc_cred = req->wb_context->cred,
+	};
 	struct rpc_task_setup task_setup_data = {
 		.rpc_client = NFS_CLIENT(inode),
+		.rpc_message = &msg,
 		.callback_ops = call_ops,
 		.callback_data = data,
 		.flags = RPC_TASK_ASYNC | swap_flags,
@@ -171,7 +187,7 @@ static void nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
 
 	data->req	  = req;
 	data->inode	  = inode;
-	data->cred	  = req->wb_context->cred;
+	data->cred	  = msg.rpc_cred;
 
 	data->args.fh     = NFS_FH(inode);
 	data->args.offset = req_offset(req) + offset;
@@ -186,8 +202,8 @@ static void nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
 	nfs_fattr_init(&data->fattr);
 
 	/* Set up the initial task struct. */
+	NFS_PROTO(inode)->read_setup(data, &msg);
 	rpc_init_task(&data->task, &task_setup_data);
-	NFS_PROTO(inode)->read_setup(data);
 
 	dprintk("NFS: %5u initiated read call (req %s/%Ld, %u bytes @ offset %Lu)\n",
 			data->task.tk_pid,
@@ -195,6 +211,8 @@ static void nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
 			(long long)NFS_FILEID(inode),
 			count,
 			(unsigned long long)data->args.offset);
+
+	nfs_execute_read(data);
 }
 
 static void
@@ -211,19 +229,6 @@ nfs_async_read_error(struct list_head *head)
 }
 
 /*
- * Start an async read operation
- */
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
-/*
  * Generate multiple requests to fill a single page.
  *
  * We optimize to reduce the number of read operations on the wire.  If we
@@ -277,7 +282,6 @@ static int nfs_pagein_multi(struct inode *inode, struct list_head *head, unsigne
 				  rsize, offset);
 		offset += rsize;
 		nbytes -= rsize;
-		nfs_execute_read(data);
 	} while (nbytes != 0);
 
 	return 0;
@@ -315,8 +319,6 @@ static int nfs_pagein_one(struct inode *inode, struct list_head *head, unsigned
 	req = nfs_list_entry(data->pages.next);
 
 	nfs_read_rpcsetup(req, data, &nfs_read_full_ops, count, 0);
-
-	nfs_execute_read(data);
 	return 0;
 out_bad:
 	nfs_async_read_error(head);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 8d90e90..9a69469 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -764,6 +764,16 @@ static int flush_task_priority(int how)
 	return RPC_PRIORITY_NORMAL;
 }
 
+static void nfs_execute_write(struct nfs_write_data *data)
+{
+	struct rpc_clnt *clnt = NFS_CLIENT(data->inode);
+	sigset_t oldset;
+
+	rpc_clnt_sigmask(clnt, &oldset);
+	rpc_execute(&data->task);
+	rpc_clnt_sigunmask(clnt, &oldset);
+}
+
 /*
  * Set up the argument/result storage required for the RPC call.
  */
@@ -776,8 +786,14 @@ static void nfs_write_rpcsetup(struct nfs_page *req,
 	struct inode *inode = req->wb_context->path.dentry->d_inode;
 	int flags = (how & FLUSH_SYNC) ? 0 : RPC_TASK_ASYNC;
 	int priority = flush_task_priority(how);
+	struct rpc_message msg = {
+		.rpc_argp = &data->args,
+		.rpc_resp = &data->res,
+		.rpc_cred = req->wb_context->cred,
+	};
 	struct rpc_task_setup task_setup_data = {
 		.rpc_client = NFS_CLIENT(inode),
+		.rpc_message = &msg,
 		.callback_ops = call_ops,
 		.callback_data = data,
 		.flags = flags,
@@ -789,7 +805,7 @@ static void nfs_write_rpcsetup(struct nfs_page *req,
 
 	data->req = req;
 	data->inode = inode = req->wb_context->path.dentry->d_inode;
-	data->cred = req->wb_context->cred;
+	data->cred = msg.rpc_cred;
 
 	data->args.fh     = NFS_FH(inode);
 	data->args.offset = req_offset(req) + offset;
@@ -797,6 +813,12 @@ static void nfs_write_rpcsetup(struct nfs_page *req,
 	data->args.pages  = data->pagevec;
 	data->args.count  = count;
 	data->args.context = req->wb_context;
+	data->args.stable  = NFS_UNSTABLE;
+	if (how & FLUSH_STABLE) {
+		data->args.stable = NFS_DATA_SYNC;
+		if (!NFS_I(inode)->ncommit)
+			data->args.stable = NFS_FILE_SYNC;
+	}
 
 	data->res.fattr   = &data->fattr;
 	data->res.count   = count;
@@ -804,8 +826,8 @@ static void nfs_write_rpcsetup(struct nfs_page *req,
 	nfs_fattr_init(&data->fattr);
 
 	/* Set up the initial task struct.  */
+	NFS_PROTO(inode)->write_setup(data, &msg);
 	rpc_init_task(&data->task, &task_setup_data);
-	NFS_PROTO(inode)->write_setup(data, how);
 
 	dprintk("NFS: %5u initiated write call "
 		"(req %s/%Ld, %u bytes @ offset %Lu)\n",
@@ -814,16 +836,8 @@ static void nfs_write_rpcsetup(struct nfs_page *req,
 		(long long)NFS_FILEID(inode),
 		count,
 		(unsigned long long)data->args.offset);
-}
 
-static void nfs_execute_write(struct nfs_write_data *data)
-{
-	struct rpc_clnt *clnt = NFS_CLIENT(data->inode);
-	sigset_t oldset;
-
-	rpc_clnt_sigmask(clnt, &oldset);
-	rpc_execute(&data->task);
-	rpc_clnt_sigunmask(clnt, &oldset);
+	nfs_execute_write(data);
 }
 
 /*
@@ -870,7 +884,6 @@ static int nfs_flush_multi(struct inode *inode, struct list_head *head, unsigned
 				   wsize, offset, how);
 		offset += wsize;
 		nbytes -= wsize;
-		nfs_execute_write(data);
 	} while (nbytes != 0);
 
 	return 0;
@@ -918,7 +931,6 @@ static int nfs_flush_one(struct inode *inode, struct list_head *head, unsigned i
 	/* Set up the argument struct */
 	nfs_write_rpcsetup(req, data, &nfs_write_full_ops, count, 0, how);
 
-	nfs_execute_write(data);
 	return 0;
  out_bad:
 	while (!list_empty(head)) {
@@ -1152,8 +1164,14 @@ static void nfs_commit_rpcsetup(struct list_head *head,
 	struct inode *inode = first->wb_context->path.dentry->d_inode;
 	int flags = (how & FLUSH_SYNC) ? 0 : RPC_TASK_ASYNC;
 	int priority = flush_task_priority(how);
+	struct rpc_message msg = {
+		.rpc_argp = &data->args,
+		.rpc_resp = &data->res,
+		.rpc_cred = first->wb_context->cred,
+	};
 	struct rpc_task_setup task_setup_data = {
 		.rpc_client = NFS_CLIENT(inode),
+		.rpc_message = &msg,
 		.callback_ops = &nfs_commit_ops,
 		.callback_data = data,
 		.flags = flags,
@@ -1166,7 +1184,7 @@ static void nfs_commit_rpcsetup(struct list_head *head,
 	list_splice_init(head, &data->pages);
 
 	data->inode	  = inode;
-	data->cred	  = first->wb_context->cred;
+	data->cred	  = msg.rpc_cred;
 
 	data->args.fh     = NFS_FH(data->inode);
 	/* Note: we always request a commit of the entire inode */
@@ -1178,10 +1196,12 @@ static void nfs_commit_rpcsetup(struct list_head *head,
 	nfs_fattr_init(&data->fattr);
 
 	/* Set up the initial task struct.  */
+	NFS_PROTO(inode)->commit_setup(data, &msg);
 	rpc_init_task(&data->task, &task_setup_data);
-	NFS_PROTO(inode)->commit_setup(data, how);
 
 	dprintk("NFS: %5u initiated commit call\n", data->task.tk_pid);
+
+	nfs_execute_write(data);
 }
 
 /*
@@ -1201,7 +1221,6 @@ nfs_commit_list(struct inode *inode, struct list_head *head, int how)
 	/* Set up the argument struct */
 	nfs_commit_rpcsetup(head, data, how);
 
-	nfs_execute_write(data);
 	return 0;
  out_bad:
 	while (!list_empty(head)) {
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index daab252..6b213a6 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -816,11 +816,11 @@ struct nfs_rpc_ops {
 			     struct nfs_pathconf *);
 	int	(*set_capabilities)(struct nfs_server *, struct nfs_fh *);
 	__be32 *(*decode_dirent)(__be32 *, struct nfs_entry *, int plus);
-	void	(*read_setup)   (struct nfs_read_data *);
+	void	(*read_setup)   (struct nfs_read_data *, struct rpc_message *);
 	int	(*read_done)  (struct rpc_task *, struct nfs_read_data *);
-	void	(*write_setup)  (struct nfs_write_data *, int how);
+	void	(*write_setup)  (struct nfs_write_data *, struct rpc_message *);
 	int	(*write_done)  (struct rpc_task *, struct nfs_write_data *);
-	void	(*commit_setup) (struct nfs_write_data *, int how);
+	void	(*commit_setup) (struct nfs_write_data *, struct rpc_message *);
 	int	(*commit_done) (struct rpc_task *, struct nfs_write_data *);
 	int	(*file_open)   (struct inode *, struct file *);
 	int	(*file_release) (struct inode *, struct file *);
