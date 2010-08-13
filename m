Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7088 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754479Ab0HMVdU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:33:20 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 42/50] pnfs_submit: generic commit
Date: Fri, 13 Aug 2010 17:31:54 -0400
Message-Id: <1281735122-1496-43-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-42-git-send-email-andros@netapp.com>
References: <1281735122-1496-1-git-send-email-andros@netapp.com>
 <1281735122-1496-2-git-send-email-andros@netapp.com>
 <1281735122-1496-3-git-send-email-andros@netapp.com>
 <1281735122-1496-4-git-send-email-andros@netapp.com>
 <1281735122-1496-5-git-send-email-andros@netapp.com>
 <1281735122-1496-6-git-send-email-andros@netapp.com>
 <1281735122-1496-7-git-send-email-andros@netapp.com>
 <1281735122-1496-8-git-send-email-andros@netapp.com>
 <1281735122-1496-9-git-send-email-andros@netapp.com>
 <1281735122-1496-10-git-send-email-andros@netapp.com>
 <1281735122-1496-11-git-send-email-andros@netapp.com>
 <1281735122-1496-12-git-send-email-andros@netapp.com>
 <1281735122-1496-13-git-send-email-andros@netapp.com>
 <1281735122-1496-14-git-send-email-andros@netapp.com>
 <1281735122-1496-15-git-send-email-andros@netapp.com>
 <1281735122-1496-16-git-send-email-andros@netapp.com>
 <1281735122-1496-17-git-send-email-andros@netapp.com>
 <1281735122-1496-18-git-send-email-andros@netapp.com>
 <1281735122-1496-19-git-send-email-andros@netapp.com>
 <1281735122-1496-20-git-send-email-andros@netapp.com>
 <1281735122-1496-21-git-send-email-andros@netapp.com>
 <1281735122-1496-22-git-send-email-andros@netapp.com>
 <1281735122-1496-23-git-send-email-andros@netapp.com>
 <1281735122-1496-24-git-send-email-andros@netapp.com>
 <1281735122-1496-25-git-send-email-andros@netapp.com>
 <1281735122-1496-26-git-send-email-andros@netapp.com>
 <1281735122-1496-27-git-send-email-andros@netapp.com>
 <1281735122-1496-28-git-send-email-andros@netapp.com>
 <1281735122-1496-29-git-send-email-andros@netapp.com>
 <1281735122-1496-30-git-send-email-andros@netapp.com>
 <1281735122-1496-31-git-send-email-andros@netapp.com>
 <1281735122-1496-32-git-send-email-andros@netapp.com>
 <1281735122-1496-33-git-send-email-andros@netapp.com>
 <1281735122-1496-34-git-send-email-andros@netapp.com>
 <1281735122-1496-35-git-send-email-andros@netapp.com>
 <1281735122-1496-36-git-send-email-andros@netapp.com>
 <1281735122-1496-37-git-send-email-andros@netapp.com>
 <1281735122-1496-38-git-send-email-andros@netapp.com>
 <1281735122-1496-39-git-send-email-andros@netapp.com>
 <1281735122-1496-40-git-send-email-andros@netapp.com>
 <1281735122-1496-41-git-send-email-andros@netapp.com>
 <1281735122-1496-42-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/internal.h          |    8 ++++
 fs/nfs/nfs4proc.c          |   14 ++++++-
 fs/nfs/pnfs.c              |   37 ++++++++++++++++
 fs/nfs/pnfs.h              |    3 +
 fs/nfs/write.c             |   99 ++++++++++++++++++++++++++++++++------------
 include/linux/nfs4_pnfs.h  |    7 +++
 include/linux/nfs_iostat.h |    1 +
 7 files changed, 141 insertions(+), 28 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 02f0da8..ae8b895 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -276,6 +276,14 @@ extern int pnfs_initiate_write(struct nfs_write_data *data,
 			      struct rpc_clnt *clnt,
 			      const struct rpc_call_ops *call_ops,
 			      int how);
+extern int nfs_initiate_commit(struct nfs_write_data *data,
+			       struct rpc_clnt *clnt,
+			       const struct rpc_call_ops *call_ops,
+			       int how);
+extern int pnfs_initiate_commit(struct nfs_write_data *data,
+			       struct rpc_clnt *clnt,
+			       const struct rpc_call_ops *call_ops,
+				int how, int pnfs);
 extern void nfs_write_prepare(struct rpc_task *task, void *calldata);
 extern void nfs_mark_list_commit(struct list_head *head);
 #ifdef CONFIG_MIGRATION
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 44ffa33..55aba4c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3233,6 +3233,17 @@ static void nfs4_proc_write_setup(struct nfs_write_data *data, struct rpc_messag
 static int nfs4_commit_done(struct rpc_task *task, struct nfs_write_data *data)
 {
 	struct inode *inode = data->inode;
+	struct nfs_server *server = NFS_SERVER(data->inode);
+	struct nfs_client *client = server->nfs_client;
+
+#ifdef CONFIG_NFS_V4_1
+	/* Is this a DS session */
+	if (data->fldata.ds_nfs_client) {
+		dprintk("%s DS commit\n", __func__);
+		client = data->fldata.ds_nfs_client;
+	}
+#endif /* CONFIG_NFS_V4_1 */
+
 	if (!nfs4_sequence_done(task, &data->res.seq_res))
 		return -EAGAIN;
 
@@ -3240,7 +3251,8 @@ static int nfs4_commit_done(struct rpc_task *task, struct nfs_write_data *data)
 		nfs_restart_rpc(task, NFS_SERVER(inode)->nfs_client);
 		return -EAGAIN;
 	}
-	nfs_refresh_inode(inode, data->res.fattr);
+	if (client == server->nfs_client)
+		nfs_refresh_inode(inode, data->res.fattr);
 	return 0;
 }
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 424efce..393855e 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -260,6 +260,14 @@ pnfs_register_layoutdriver(struct pnfs_layoutdriver_type *ld_type)
 		return NULL;
 	}
 
+	if (!io_ops->read_pagelist || !io_ops->write_pagelist ||
+	    !io_ops->commit) {
+		printk(KERN_ERR "%s Layout driver must provide "
+		       "read_pagelist, write_pagelist, and commit.\n",
+		       __func__);
+		return NULL;
+	}
+
 	pnfs_mod = kmalloc(sizeof(struct pnfs_module), GFP_KERNEL);
 	if (pnfs_mod != NULL) {
 		dprintk("%s Registering id:%u name:%s\n",
@@ -1323,6 +1331,35 @@ pnfs_try_to_read_data(struct nfs_read_data *rdata,
 	return trypnfs;
 }
 
+enum pnfs_try_status
+pnfs_try_to_commit(struct nfs_write_data *data,
+		    const struct rpc_call_ops *call_ops, int sync)
+{
+	struct inode *inode = data->inode;
+	struct nfs_server *nfss = NFS_SERVER(data->inode);
+	enum pnfs_try_status trypnfs;
+
+	dprintk("%s: Begin\n", __func__);
+
+	/* We need to account for possibility that
+	 * each nfs_page can point to a different lseg (or be NULL).
+	 * For the immediate case of whole-file-only layouts, we at
+	 * least know there can be only a single lseg.
+	 * We still have to account for the possibility of some being NULL.
+	 * This will be done by passing the buck to the layout driver.
+	 */
+	data->pdata.call_ops = call_ops;
+	data->pdata.how = sync;
+	data->pdata.lseg = NULL;
+	trypnfs = nfss->pnfs_curr_ld->ld_io_ops->commit(data, sync);
+	if (trypnfs == PNFS_NOT_ATTEMPTED)
+		_pnfs_clear_lseg_from_pages(&data->pages);
+	else
+		nfs_inc_stats(inode, NFSIOS_PNFS_COMMIT);
+	dprintk("%s End (trypnfs:%d)\n", __func__, trypnfs);
+	return trypnfs;
+}
+
 /*
  * Set up the argument/result storage required for the RPC call.
  */
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index b110f4e..80f67c7 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -50,6 +50,9 @@ void pnfs_layoutcommit_free(struct pnfs_layoutcommit_data *data);
 int pnfs_layoutcommit_inode(struct inode *inode, int sync);
 void pnfs_update_last_write(struct nfs_inode *nfsi, loff_t offset, size_t extent);
 void pnfs_need_layoutcommit(struct nfs_inode *nfsi, struct nfs_open_context *ctx);
+unsigned int pnfs_getiosize(struct nfs_server *server);
+enum pnfs_try_status pnfs_try_to_commit(struct nfs_write_data *,
+					 const struct rpc_call_ops *, int);
 void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *,
 			   struct nfs_open_context *, struct list_head *);
 void pnfs_pageio_init_write(struct nfs_pageio_descriptor *, struct inode *);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 18926d3..668c4c1 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1311,40 +1311,72 @@ static void nfs_commitdata_release(void *data)
 	nfs_commit_free(wdata);
 }
 
-/*
- * Set up the argument/result storage required for the RPC call.
- */
-static int nfs_commit_rpcsetup(struct list_head *head,
-		struct nfs_write_data *data,
-		int how)
+int nfs_initiate_commit(struct nfs_write_data *data,
+			struct rpc_clnt *clnt,
+			const struct rpc_call_ops *call_ops,
+			int how)
 {
-	struct nfs_page *first = nfs_list_entry(head->next);
-	struct inode *inode = first->wb_context->path.dentry->d_inode;
+	struct inode *inode = data->inode;
 	int priority = flush_task_priority(how);
 	struct rpc_task *task;
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
+	NFS_PROTO(inode)->commit_setup(data, &msg);
+
+	dprintk("NFS: %5u initiated commit call\n", data->task.tk_pid);
+
+	task = rpc_run_task(&task_setup_data);
+	if (IS_ERR(task))
+		return PTR_ERR(task);
+	rpc_put_task(task);
+	return 0;
+}
+EXPORT_SYMBOL(nfs_initiate_commit);
+
+
+int pnfs_initiate_commit(struct nfs_write_data *data,
+			 struct rpc_clnt *clnt,
+			 const struct rpc_call_ops *call_ops,
+			 int how, int pnfs)
+{
+	if (pnfs &&
+	    (pnfs_try_to_commit(data, &nfs_commit_ops, how) == PNFS_ATTEMPTED))
+		return 0;
+	return nfs_initiate_commit(data, clnt, &nfs_commit_ops, how);
+}
+
+/*
+ * Set up the argument/result storage required for the RPC call.
+ */
+static int nfs_commit_rpcsetup(struct list_head *head,
+		struct nfs_write_data *data,
+		int how, int pnfs)
+{
+	struct nfs_page *first = nfs_list_entry(head->next);
+	struct inode *inode = first->wb_context->path.dentry->d_inode;
+
 	/* Set up the RPC argument and reply structs
 	 * NB: take care not to mess about with data->commit et al. */
 
 	list_splice_init(head, &data->pages);
 
 	data->inode	  = inode;
-	data->cred	  = msg.rpc_cred;
+	data->cred	  = first->wb_context->cred;
 
 	data->args.fh     = NFS_FH(data->inode);
 	/* Note: we always request a commit of the entire inode */
@@ -1355,24 +1387,19 @@ static int nfs_commit_rpcsetup(struct list_head *head,
 	data->res.fattr   = &data->fattr;
 	data->res.verf    = &data->verf;
 	nfs_fattr_init(&data->fattr);
+	kref_init(&data->refcount);
+	data->parent      = NULL;
+	data->args.context = first->wb_context;  /* used by commit done */
 
-	/* Set up the initial task struct.  */
-	NFS_PROTO(inode)->commit_setup(data, &msg);
-
-	dprintk("NFS: %5u initiated commit call\n", data->task.tk_pid);
-
-	task = rpc_run_task(&task_setup_data);
-	if (IS_ERR(task))
-		return PTR_ERR(task);
-	rpc_put_task(task);
-	return 0;
+	return pnfs_initiate_commit(data, NFS_CLIENT(inode), &nfs_commit_ops,
+				    how, pnfs);
 }
 
 /*
  * Commit dirty pages
  */
 static int
-nfs_commit_list(struct inode *inode, struct list_head *head, int how)
+nfs_commit_list(struct inode *inode, struct list_head *head, int how, int pnfs)
 {
 	struct nfs_write_data	*data;
 	struct nfs_page         *req;
@@ -1383,7 +1410,7 @@ nfs_commit_list(struct inode *inode, struct list_head *head, int how)
 		goto out_bad;
 
 	/* Set up the argument struct */
-	return nfs_commit_rpcsetup(head, data, how);
+	return nfs_commit_rpcsetup(head, data, how, pnfs);
  out_bad:
 	while (!list_empty(head)) {
 		req = nfs_list_entry(head->next);
@@ -1413,6 +1440,19 @@ static void nfs_commit_done(struct rpc_task *task, void *calldata)
 		return;
 }
 
+static inline void nfs_commit_cleanup(struct kref *kref)
+{
+	struct nfs_write_data *data;
+
+	data = container_of(kref, struct nfs_write_data, refcount);
+	/* Clear lock only when all cloned commits are finished */
+	if (data->parent)
+		kref_put(&data->parent->refcount, nfs_commit_cleanup);
+	else
+		nfs_commit_clear_lock(NFS_I(data->inode));
+	nfs_commitdata_release(data);
+}
+
 static void nfs_commit_release(void *calldata)
 {
 	struct nfs_write_data	*data = calldata;
@@ -1430,6 +1470,11 @@ static void nfs_commit_release(void *calldata)
 			req->wb_bytes,
 			(long long)req_offset(req));
 		if (status < 0) {
+			if (req->wb_lseg) {
+				nfs_mark_request_nopnfs(req);
+				nfs_mark_request_dirty(req);
+				goto next;
+			}
 			nfs_context_set_write_error(req->wb_context, status);
 			nfs_inode_remove_request(req);
 			dprintk(", error = %d\n", status);
@@ -1446,12 +1491,12 @@ static void nfs_commit_release(void *calldata)
 		}
 		/* We have a mismatch. Write the page again */
 		dprintk(" mismatch\n");
+		nfs_mark_request_nopnfs(req);
 		nfs_mark_request_dirty(req);
 	next:
 		nfs_clear_page_tag_locked(req);
 	}
-	nfs_commit_clear_lock(NFS_I(data->inode));
-	nfs_commitdata_release(calldata);
+	kref_put(&data->refcount, nfs_commit_cleanup);
 }
 
 static const struct rpc_call_ops nfs_commit_ops = {
@@ -1475,7 +1520,7 @@ int nfs_commit_inode(struct inode *inode, int how)
 	res = nfs_scan_commit(inode, &head, 0, 0, &use_pnfs);
 	spin_unlock(&inode->i_lock);
 	if (res) {
-		int error = nfs_commit_list(inode, &head, how);
+		int error = nfs_commit_list(inode, &head, how, use_pnfs);
 		if (error < 0)
 			return error;
 		if (may_wait) {
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index b010ff1..ef160e6 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -124,6 +124,13 @@ struct layoutdriver_io_operations {
 	enum pnfs_try_status
 	(*write_pagelist) (struct nfs_write_data *nfs_data, unsigned nr_pages, int how);
 
+	/* Consistency ops */
+	/* 2 problems:
+	 * 1) the page list contains nfs_pages, NOT pages
+	 * 2) currently the NFS code doesn't create a page array (as it does with read/write)
+	 */
+	enum pnfs_try_status
+	(*commit) (struct nfs_write_data *nfs_data, int how);
 
 	/* Layout information. For each inode, alloc_layout is executed once to retrieve an
 	 * inode specific layout structure.  Each subsequent layoutget operation results in
diff --git a/include/linux/nfs_iostat.h b/include/linux/nfs_iostat.h
index 8866bb3..f9b5f44 100644
--- a/include/linux/nfs_iostat.h
+++ b/include/linux/nfs_iostat.h
@@ -115,6 +115,7 @@ enum nfs_stat_eventcounters {
 	NFSIOS_DELAY,
 	NFSIOS_PNFS_READ,
 	NFSIOS_PNFS_WRITE,
+	NFSIOS_PNFS_COMMIT,
 	__NFSIOS_COUNTSMAX,
 };
 
-- 
1.6.2.5

