Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:36025 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755316AbaEGL0d (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 May 2014 07:26:33 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <dros@primarydata.com>, <hch@infradead.org>
Subject: [PATCH v3 14/17] NFS: Create a common initiate_pgio() function
Date: Tue, 6 May 2014 09:12:37 -0400
Message-ID: <1399381960-3019-15-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1399381960-3019-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1399381960-3019-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@netapp.com>

Most of this code is the same for both the read and write paths, so
combine everything and use the rw_ops when necessary.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/internal.h        |  9 ++------
 fs/nfs/nfs4filelayout.c  |  6 +++---
 fs/nfs/pagelist.c        | 47 +++++++++++++++++++++++++++++++++++++++++
 fs/nfs/read.c            | 42 ++++++------------------------------
 fs/nfs/write.c           | 55 ++++++------------------------------------------
 include/linux/nfs_page.h |  2 ++
 6 files changed, 67 insertions(+), 94 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 365cdb1..be4f2a7 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -241,6 +241,8 @@ struct nfs_rw_header *nfs_rw_header_alloc(const struct nfs_rw_ops *);
 void nfs_rw_header_free(struct nfs_pgio_header *);
 void nfs_pgio_data_release(struct nfs_pgio_data *);
 int nfs_generic_pgio(struct nfs_pageio_descriptor *, struct nfs_pgio_header *);
+int nfs_initiate_pgio(struct rpc_clnt *, struct nfs_pgio_data *,
+		      const struct rpc_call_ops *, int, int);
 
 static inline void nfs_iocounter_init(struct nfs_io_counter *c)
 {
@@ -402,9 +404,6 @@ struct nfs_pgio_completion_ops;
 extern void nfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 			struct inode *inode, bool force_mds,
 			const struct nfs_pgio_completion_ops *compl_ops);
-extern int nfs_initiate_read(struct rpc_clnt *clnt,
-			     struct nfs_pgio_data *data,
-			     const struct rpc_call_ops *call_ops, int flags);
 extern void nfs_read_prepare(struct rpc_task *task, void *calldata);
 extern void nfs_pageio_reset_read_mds(struct nfs_pageio_descriptor *pgio);
 
@@ -425,10 +424,6 @@ extern void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
 			const struct nfs_pgio_completion_ops *compl_ops);
 extern void nfs_pageio_reset_write_mds(struct nfs_pageio_descriptor *pgio);
 extern void nfs_commit_free(struct nfs_commit_data *p);
-extern int nfs_initiate_write(struct rpc_clnt *clnt,
-			      struct nfs_pgio_data *data,
-			      const struct rpc_call_ops *call_ops,
-			      int how, int flags);
 extern void nfs_write_prepare(struct rpc_task *task, void *calldata);
 extern void nfs_commit_prepare(struct rpc_task *task, void *calldata);
 extern int nfs_initiate_commit(struct rpc_clnt *clnt,
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index e693614..7954e16 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -568,8 +568,8 @@ filelayout_read_pagelist(struct nfs_pgio_data *data)
 	data->mds_offset = offset;
 
 	/* Perform an asynchronous read to ds */
-	nfs_initiate_read(ds_clnt, data,
-				  &filelayout_read_call_ops, RPC_TASK_SOFTCONN);
+	nfs_initiate_pgio(ds_clnt, data,
+			    &filelayout_read_call_ops, 0, RPC_TASK_SOFTCONN);
 	return PNFS_ATTEMPTED;
 }
 
@@ -613,7 +613,7 @@ filelayout_write_pagelist(struct nfs_pgio_data *data, int sync)
 	data->args.offset = filelayout_get_dserver_offset(lseg, offset);
 
 	/* Perform an asynchronous write */
-	nfs_initiate_write(ds_clnt, data,
+	nfs_initiate_pgio(ds_clnt, data,
 				    &filelayout_write_call_ops, sync,
 				    RPC_TASK_SOFTCONN);
 	return PNFS_ATTEMPTED;
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index d8d25a4..55e2f90 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -447,6 +447,53 @@ static void nfs_pgio_prepare(struct rpc_task *task, void *calldata)
 		rpc_exit(task, err);
 }
 
+int nfs_initiate_pgio(struct rpc_clnt *clnt, struct nfs_pgio_data *data,
+		      const struct rpc_call_ops *call_ops, int how, int flags)
+{
+	struct inode *inode = data->header->inode;
+	struct rpc_task *task;
+	struct rpc_message msg = {
+		.rpc_argp = &data->args,
+		.rpc_resp = &data->res,
+		.rpc_cred = data->header->cred,
+	};
+	struct rpc_task_setup task_setup_data = {
+		.rpc_client = clnt,
+		.task = &data->task,
+		.rpc_message = &msg,
+		.callback_ops = call_ops,
+		.callback_data = data,
+		.workqueue = nfsiod_workqueue,
+		.flags = RPC_TASK_ASYNC | flags,
+	};
+	int ret = 0;
+
+	data->header->rw_ops->rw_initiate(data, &msg, &task_setup_data, how);
+
+	dprintk("NFS: %5u initiated pgio call "
+		"(req %s/%llu, %u bytes @ offset %llu)\n",
+		data->task.tk_pid,
+		inode->i_sb->s_id,
+		(unsigned long long)NFS_FILEID(inode),
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
+EXPORT_SYMBOL_GPL(nfs_initiate_pgio);
+
 /**
  * nfs_pgio_error - Clean up from a pageio error
  * @desc: IO descriptor
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 4fcef82..0359b0d 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -151,53 +151,22 @@ out:
 	hdr->release(hdr);
 }
 
-int nfs_initiate_read(struct rpc_clnt *clnt,
-		      struct nfs_pgio_data *data,
-		      const struct rpc_call_ops *call_ops, int flags)
+static void nfs_initiate_read(struct nfs_pgio_data *data, struct rpc_message *msg,
+			      struct rpc_task_setup *task_setup_data, int how)
 {
 	struct inode *inode = data->header->inode;
 	int swap_flags = IS_SWAPFILE(inode) ? NFS_RPC_SWAPFLAGS : 0;
-	struct rpc_task *task;
-	struct rpc_message msg = {
-		.rpc_argp = &data->args,
-		.rpc_resp = &data->res,
-		.rpc_cred = data->header->cred,
-	};
-	struct rpc_task_setup task_setup_data = {
-		.task = &data->task,
-		.rpc_client = clnt,
-		.rpc_message = &msg,
-		.callback_ops = call_ops,
-		.callback_data = data,
-		.workqueue = nfsiod_workqueue,
-		.flags = RPC_TASK_ASYNC | swap_flags | flags,
-	};
 
-	/* Set up the initial task struct. */
-	NFS_PROTO(inode)->read_setup(data, &msg);
-
-	dprintk("NFS: %5u initiated read call (req %s/%llu, %u bytes @ "
-			"offset %llu)\n",
-			data->task.tk_pid,
-			inode->i_sb->s_id,
-			(unsigned long long)NFS_FILEID(inode),
-			data->args.count,
-			(unsigned long long)data->args.offset);
-
-	task = rpc_run_task(&task_setup_data);
-	if (IS_ERR(task))
-		return PTR_ERR(task);
-	rpc_put_task(task);
-	return 0;
+	task_setup_data->flags |= swap_flags;
+	NFS_PROTO(inode)->read_setup(data, msg);
 }
-EXPORT_SYMBOL_GPL(nfs_initiate_read);
 
 static int nfs_do_read(struct nfs_pgio_data *data,
 		const struct rpc_call_ops *call_ops)
 {
 	struct inode *inode = data->header->inode;
 
-	return nfs_initiate_read(NFS_CLIENT(inode), data, call_ops, 0);
+	return nfs_initiate_pgio(NFS_CLIENT(inode), data, call_ops, 0, 0);
 }
 
 static int
@@ -491,4 +460,5 @@ static const struct nfs_rw_ops nfs_rw_read_ops = {
 	.rw_free_header		= nfs_readhdr_free,
 	.rw_done		= nfs_readpage_done,
 	.rw_result		= nfs_readpage_result,
+	.rw_initiate		= nfs_initiate_read,
 };
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 0e34c70..e46a1fc 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -932,60 +932,18 @@ static int flush_task_priority(int how)
 	return RPC_PRIORITY_NORMAL;
 }
 
-int nfs_initiate_write(struct rpc_clnt *clnt,
-		       struct nfs_pgio_data *data,
-		       const struct rpc_call_ops *call_ops,
-		       int how, int flags)
+static void nfs_initiate_write(struct nfs_pgio_data *data, struct rpc_message *msg,
+			       struct rpc_task_setup *task_setup_data, int how)
 {
 	struct inode *inode = data->header->inode;
 	int priority = flush_task_priority(how);
-	struct rpc_task *task;
-	struct rpc_message msg = {
-		.rpc_argp = &data->args,
-		.rpc_resp = &data->res,
-		.rpc_cred = data->header->cred,
-	};
-	struct rpc_task_setup task_setup_data = {
-		.rpc_client = clnt,
-		.task = &data->task,
-		.rpc_message = &msg,
-		.callback_ops = call_ops,
-		.callback_data = data,
-		.workqueue = nfsiod_workqueue,
-		.flags = RPC_TASK_ASYNC | flags,
-		.priority = priority,
-	};
-	int ret = 0;
 
-	/* Set up the initial task struct.  */
-	NFS_PROTO(inode)->write_setup(data, &msg);
-
-	dprintk("NFS: %5u initiated write call "
-		"(req %s/%llu, %u bytes @ offset %llu)\n",
-		data->task.tk_pid,
-		inode->i_sb->s_id,
-		(unsigned long long)NFS_FILEID(inode),
-		data->args.count,
-		(unsigned long long)data->args.offset);
+	task_setup_data->priority = priority;
+	NFS_PROTO(inode)->write_setup(data, msg);
 
 	nfs4_state_protect_write(NFS_SERVER(inode)->nfs_client,
-				 &task_setup_data.rpc_client, &msg, data);
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
+				 &task_setup_data->rpc_client, msg, data);
 }
-EXPORT_SYMBOL_GPL(nfs_initiate_write);
 
 static int nfs_do_write(struct nfs_pgio_data *data,
 		const struct rpc_call_ops *call_ops,
@@ -993,7 +951,7 @@ static int nfs_do_write(struct nfs_pgio_data *data,
 {
 	struct inode *inode = data->header->inode;
 
-	return nfs_initiate_write(NFS_CLIENT(inode), data, call_ops, how, 0);
+	return nfs_initiate_pgio(NFS_CLIENT(inode), data, call_ops, how, 0);
 }
 
 static int nfs_do_multiple_writes(struct list_head *head,
@@ -1743,4 +1701,5 @@ static const struct nfs_rw_ops nfs_rw_write_ops = {
 	.rw_release		= nfs_writeback_release_common,
 	.rw_done		= nfs_writeback_done,
 	.rw_result		= nfs_writeback_result,
+	.rw_initiate		= nfs_initiate_write,
 };
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 01aa29c..c6a587f 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -59,6 +59,8 @@ struct nfs_rw_ops {
 	void (*rw_release)(struct nfs_pgio_data *);
 	int  (*rw_done)(struct rpc_task *, struct nfs_pgio_data *, struct inode *);
 	void (*rw_result)(struct rpc_task *, struct nfs_pgio_data *);
+	void (*rw_initiate)(struct nfs_pgio_data *, struct rpc_message *,
+			    struct rpc_task_setup *, int);
 };
 
 struct nfs_pageio_descriptor {
-- 
1.9.2

