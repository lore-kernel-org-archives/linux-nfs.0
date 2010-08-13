Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33152 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754330Ab0HMVch (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:32:37 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 38/50] pnfs_submit: generic write
Date: Fri, 13 Aug 2010 17:31:50 -0400
Message-Id: <1281735122-1496-39-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-38-git-send-email-andros@netapp.com>
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
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/internal.h          |    9 +++
 fs/nfs/nfs4proc.c          |   43 +++++++++++++--
 fs/nfs/pnfs.c              |   44 +++++++++++++++
 fs/nfs/pnfs.h              |    9 +++
 fs/nfs/write.c             |  125 ++++++++++++++++++++++++++++++--------------
 include/linux/nfs4_pnfs.h  |    4 ++
 include/linux/nfs_iostat.h |    1 +
 include/linux/nfs_xdr.h    |    4 ++
 8 files changed, 194 insertions(+), 45 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 37f9926..02f0da8 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -268,7 +268,16 @@ extern int pnfs_initiate_read(struct nfs_read_data *data, struct rpc_clnt *clnt,
 extern void nfs_read_prepare(struct rpc_task *task, void *calldata);
 
 /* write.c */
+extern int nfs_initiate_write(struct nfs_write_data *data,
+			      struct rpc_clnt *clnt,
+			      const struct rpc_call_ops *call_ops,
+			      int how);
+extern int pnfs_initiate_write(struct nfs_write_data *data,
+			      struct rpc_clnt *clnt,
+			      const struct rpc_call_ops *call_ops,
+			      int how);
 extern void nfs_write_prepare(struct rpc_task *task, void *calldata);
+extern void nfs_mark_list_commit(struct list_head *head);
 #ifdef CONFIG_MIGRATION
 extern int nfs_migrate_page(struct address_space *,
 		struct page *, struct page *);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4346a82..a6a0e7e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3161,20 +3161,53 @@ static void nfs4_proc_read_setup(struct nfs_read_data *data, struct rpc_message
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_READ];
 }
 
+static void pnfs4_update_write_done(struct nfs_inode *nfsi, struct nfs_write_data *data)
+{
+#ifdef CONFIG_NFS_V4_1
+	pnfs_update_last_write(nfsi, data->args.offset, data->res.count);
+	pnfs_need_layoutcommit(nfsi, data->args.context);
+#endif /* CONFIG_NFS_V4_1 */
+}
+
 static int nfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
 {
 	struct inode *inode = data->inode;
-	
+	struct nfs_server *server = NFS_SERVER(inode);
+	struct nfs_client *client = server->nfs_client;
+
 	if (!nfs4_sequence_done(task, &data->res.seq_res))
 		return -EAGAIN;
 
-	if (nfs4_async_handle_error(task, NFS_SERVER(inode), data->args.context->state, NULL) == -EAGAIN) {
-		nfs_restart_rpc(task, NFS_SERVER(inode)->nfs_client);
+#ifdef CONFIG_NFS_V4_1
+	/* restore original count after retry? */
+	if (data->pdata.orig_count) {
+		dprintk("%s: restoring original count %u\n", __func__,
+			data->pdata.orig_count);
+		data->args.count = data->pdata.orig_count;
+	}
+
+	/* Is this a DS session */
+	if (data->fldata.ds_nfs_client) {
+		dprintk("%s DS write\n", __func__);
+		client = data->fldata.ds_nfs_client;
+	}
+#endif /* CONFIG_NFS_V4_1 */
+
+	if (nfs4_async_handle_error(task, server, data->args.context->state, client) == -EAGAIN) {
+		nfs_restart_rpc(task, client);
 		return -EAGAIN;
 	}
+
+	/*
+	 * MDS write: renew lease
+	 * DS write: update lastbyte written, mark for layout commit
+	 */
 	if (task->tk_status >= 0) {
-		renew_lease(NFS_SERVER(inode), data->timestamp);
-		nfs_post_op_update_inode_force_wcc(inode, data->res.fattr);
+		if (client == server->nfs_client) {
+			renew_lease(server, data->timestamp);
+			nfs_post_op_update_inode_force_wcc(inode, data->res.fattr);
+		} else
+			pnfs4_update_write_done(NFS_I(inode), data);
 	}
 	return 0;
 }
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 6725539..424efce 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1245,6 +1245,50 @@ static void _pnfs_clear_lseg_from_pages(struct list_head *head)
 }
 
 /*
+ * Call the appropriate parallel I/O subsystem write function.
+ * If no I/O device driver exists, or one does match the returned
+ * fstype, then return a positive status for regular NFS processing.
+ *
+ * TODO: Is wdata->how and wdata->args.stable always the same value?
+ * TODO: It seems in NFS, the server may not do a stable write even
+ * though it was requested (and vice-versa?).  To check, it looks
+ * in data->res.verf->committed.  Do we need this ability
+ * for non-file layout drivers?
+ */
+enum pnfs_try_status
+pnfs_try_to_write_data(struct nfs_write_data *wdata,
+			const struct rpc_call_ops *call_ops, int how)
+{
+	struct inode *inode = wdata->inode;
+	enum pnfs_try_status trypnfs;
+	struct nfs_server *nfss = NFS_SERVER(inode);
+	struct pnfs_layout_segment *lseg = wdata->req->wb_lseg;
+
+	wdata->pdata.call_ops = call_ops;
+	wdata->pdata.how = how;
+
+	dprintk("%s: Writing ino:%lu %u@%llu (how %d)\n", __func__,
+		inode->i_ino, wdata->args.count, wdata->args.offset, how);
+
+	get_lseg(lseg);
+
+	wdata->pdata.lseg = lseg;
+	trypnfs = nfss->pnfs_curr_ld->ld_io_ops->write_pagelist(wdata,
+		nfs_page_array_len(wdata->args.pgbase, wdata->args.count),
+								how);
+
+	if (trypnfs == PNFS_NOT_ATTEMPTED) {
+		wdata->pdata.lseg = NULL;
+		put_lseg(lseg);
+		_pnfs_clear_lseg_from_pages(&wdata->pages);
+	} else {
+		nfs_inc_stats(inode, NFSIOS_PNFS_WRITE);
+	}
+	dprintk("%s End (trypnfs:%d)\n", __func__, trypnfs);
+	return trypnfs;
+}
+
+/*
  * Call the appropriate parallel I/O subsystem read function.
  * If no I/O device driver exists, or one does match the returned
  * fstype, then return a positive status for regular NFS processing.
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index b7a3769..b110f4e 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -40,6 +40,8 @@ int _pnfs_return_layout(struct inode *, struct nfs4_pnfs_layout_segment *,
 			enum pnfs_layoutreturn_type, bool wait);
 void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
 void unmount_pnfs_layoutdriver(struct nfs_server *);
+enum pnfs_try_status pnfs_try_to_write_data(struct nfs_write_data *,
+					     const struct rpc_call_ops *, int);
 enum pnfs_try_status pnfs_try_to_read_data(struct nfs_read_data *,
 					    const struct rpc_call_ops *);
 int pnfs_initialize(void);
@@ -158,6 +160,13 @@ pnfs_try_to_read_data(struct nfs_read_data *data,
 }
 
 static inline enum pnfs_try_status
+pnfs_try_to_write_data(struct nfs_write_data *data,
+		       const struct rpc_call_ops *call_ops, int how)
+{
+	return PNFS_NOT_ATTEMPTED;
+}
+
+static inline enum pnfs_try_status
 pnfs_try_to_commit(struct nfs_write_data *data,
 		   const struct rpc_call_ops *call_ops, int how)
 {
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index a1f28c5..fbc8657 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -802,25 +802,21 @@ static int flush_task_priority(int how)
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
+int nfs_initiate_write(struct nfs_write_data *data,
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
@@ -831,12 +827,62 @@ static int nfs_write_rpcsetup(struct nfs_page *req,
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
+EXPORT_SYMBOL(nfs_initiate_write);
+
+int pnfs_initiate_write(struct nfs_write_data *data,
+			struct rpc_clnt *clnt,
+			const struct rpc_call_ops *call_ops,
+			int how)
+{
+	if (data->req->wb_lseg &&
+	    (pnfs_try_to_write_data(data, call_ops, how) == PNFS_ATTEMPTED))
+		return 0;
+
+	return nfs_initiate_write(data, clnt, call_ops, how);
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
@@ -857,30 +903,7 @@ static int nfs_write_rpcsetup(struct nfs_page *req,
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
+	return pnfs_initiate_write(data, NFS_CLIENT(inode), call_ops, how);
 }
 
 /* If a nfs_flush_* function fails, it should remove reqs from @head and
@@ -1073,13 +1096,27 @@ out:
 void nfs_write_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs_write_data *data = calldata;
+	struct nfs4_session *ds_session = NULL;
+
+	if (data->fldata.ds_nfs_client) {
+		dprintk("%s DS read\n", __func__);
+		ds_session = data->fldata.ds_nfs_client->cl_session;
+	} else if (data->args.count > NFS_SERVER(data->inode)->wsize) {
+		/* retrying via MDS? */
+		data->pdata.orig_count = data->args.count;
+		data->args.count = NFS_SERVER(data->inode)->wsize;
+		dprintk("%s: trimmed count %u to wsize %u\n", __func__,
+		data->pdata.orig_count, data->args.count);
+	} else
+		data->pdata.orig_count = 0;
 
-	if (nfs4_setup_sequence(NFS_SERVER(data->inode), NULL,
+	if (nfs4_setup_sequence(NFS_SERVER(data->inode), ds_session,
 				&data->args.seq_args,
 				&data->res.seq_res, 1, task))
 		return;
 	rpc_call_start(task);
 }
+EXPORT_SYMBOL(nfs_write_prepare);
 #endif /* CONFIG_NFS_V4_1 */
 
 static const struct rpc_call_ops nfs_write_partial_ops = {
@@ -1163,10 +1200,11 @@ int nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 	struct nfs_writeargs	*argp = &data->args;
 	struct nfs_writeres	*resp = &data->res;
 	struct nfs_server	*server = NFS_SERVER(data->inode);
+	struct nfs_client	*clp = server->nfs_client;
 	int status;
 
-	dprintk("NFS: %5u nfs_writeback_done (status %d)\n",
-		task->tk_pid, task->tk_status);
+	dprintk("NFS: %5u nfs_writeback_done (status %d count %u)\n",
+		task->tk_pid, task->tk_status, resp->count);
 
 	/*
 	 * ->write_done will attempt to use post-op attributes to detect
@@ -1179,6 +1217,13 @@ int nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 	if (status != 0)
 		return status;
 	nfs_add_stats(data->inode, NFSIOS_SERVERWRITTENBYTES, resp->count);
+#ifdef CONFIG_NFS_V4_1
+	/* Is this a DS session */
+	if (data->fldata.ds_nfs_client) {
+		dprintk("%s DS write\n", __func__);
+		clp = data->fldata.ds_nfs_client;
+	}
+#endif /* CONFIG_NFS_V4_1 */
 
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 	if (resp->verf->committed < argp->stable && task->tk_status >= 0) {
@@ -1195,7 +1240,7 @@ int nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 		if (time_before(complain, jiffies)) {
 			dprintk("NFS:       faulty NFS server %s:"
 				" (committed = %d) != (stable = %d)\n",
-				server->nfs_client->cl_hostname,
+				clp->cl_hostname,
 				resp->verf->committed, argp->stable);
 			complain = jiffies + 300 * HZ;
 		}
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index 2bd068d..b010ff1 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -121,6 +121,10 @@ struct layoutdriver_io_operations {
 	 */
 	enum pnfs_try_status
 	(*read_pagelist) (struct nfs_read_data *nfs_data, unsigned nr_pages);
+	enum pnfs_try_status
+	(*write_pagelist) (struct nfs_write_data *nfs_data, unsigned nr_pages, int how);
+
+
 	/* Layout information. For each inode, alloc_layout is executed once to retrieve an
 	 * inode specific layout structure.  Each subsequent layoutget operation results in
 	 * a set_layout call to set the opaque layout in the layout driver.*/
diff --git a/include/linux/nfs_iostat.h b/include/linux/nfs_iostat.h
index 37a1437..8866bb3 100644
--- a/include/linux/nfs_iostat.h
+++ b/include/linux/nfs_iostat.h
@@ -114,6 +114,7 @@ enum nfs_stat_eventcounters {
 	NFSIOS_SHORTWRITE,
 	NFSIOS_DELAY,
 	NFSIOS_PNFS_READ,
+	NFSIOS_PNFS_WRITE,
 	__NFSIOS_COUNTSMAX,
 };
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 2de5313..544d282 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1027,6 +1027,10 @@ struct nfs_write_data {
 #ifdef CONFIG_NFS_V4
 	unsigned long		timestamp;	/* For lease renewal */
 #endif
+#if defined(CONFIG_NFS_V4_1)
+	struct pnfs_call_data	pdata;
+	struct pnfs_fl_call_data fldata;
+#endif /* CONFIG_NFS_V4_1 */
 	struct page		*page_array[NFS_PAGEVEC_SIZE];
 };
 
-- 
1.6.2.5

