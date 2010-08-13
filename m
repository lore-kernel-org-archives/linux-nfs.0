Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:31907 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754330Ab0HMVcf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:32:35 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 36/50] pnfs_submit: generic read
Date: Fri, 13 Aug 2010 17:31:48 -0400
Message-Id: <1281735122-1496-37-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-36-git-send-email-andros@netapp.com>
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
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/internal.h          |    4 ++
 fs/nfs/nfs4proc.c          |   15 ++++++-
 fs/nfs/pnfs.c              |   35 +++++++++++++++++
 fs/nfs/pnfs.h              |   16 ++++++++
 fs/nfs/read.c              |   90 ++++++++++++++++++++++++++++++-------------
 include/linux/nfs4_pnfs.h  |   17 ++++++++
 include/linux/nfs_iostat.h |    1 +
 include/linux/nfs_xdr.h    |   21 ++++++++++
 8 files changed, 169 insertions(+), 30 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index eba1cc0..37f9926 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -261,6 +261,10 @@ extern int nfs4_get_rootfh(struct nfs_server *server, struct nfs_fh *mntfh);
 #endif
 
 /* read.c */
+extern int nfs_initiate_read(struct nfs_read_data *data, struct rpc_clnt *clnt,
+			     const struct rpc_call_ops *call_ops);
+extern int pnfs_initiate_read(struct nfs_read_data *data, struct rpc_clnt *clnt,
+			     const struct rpc_call_ops *call_ops);
 extern void nfs_read_prepare(struct rpc_task *task, void *calldata);
 
 /* write.c */
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d7d193b..4346a82 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3129,19 +3129,28 @@ static int nfs4_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle,
 static int nfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
 {
 	struct nfs_server *server = NFS_SERVER(data->inode);
+	struct nfs_client *client = server->nfs_client;
 
 	dprintk("--> %s\n", __func__);
 
+#ifdef CONFIG_NFS_V4_1
+	/* Is this a DS session */
+	if (data->fldata.ds_nfs_client) {
+		dprintk("%s DS read\n", __func__);
+		client = data->fldata.ds_nfs_client;
+	}
+#endif /* CONFIG_NFS_V4_1 */
+
 	if (!nfs4_sequence_done(task, &data->res.seq_res))
 		return -EAGAIN;
 
-	if (nfs4_async_handle_error(task, server, data->args.context->state, NULL) == -EAGAIN) {
-		nfs_restart_rpc(task, server->nfs_client);
+	if (nfs4_async_handle_error(task, server, data->args.context->state, client) == -EAGAIN) {
+		nfs_restart_rpc(task, client);
 		return -EAGAIN;
 	}
 
 	nfs_invalidate_atime(data->inode);
-	if (task->tk_status > 0)
+	if (task->tk_status > 0 && client == server->nfs_client)
 		renew_lease(server, data->timestamp);
 	return 0;
 }
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 3ff193b..6725539 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1245,6 +1245,41 @@ static void _pnfs_clear_lseg_from_pages(struct list_head *head)
 }
 
 /*
+ * Call the appropriate parallel I/O subsystem read function.
+ * If no I/O device driver exists, or one does match the returned
+ * fstype, then return a positive status for regular NFS processing.
+ */
+enum pnfs_try_status
+pnfs_try_to_read_data(struct nfs_read_data *rdata,
+		       const struct rpc_call_ops *call_ops)
+{
+	struct inode *inode = rdata->inode;
+	struct nfs_server *nfss = NFS_SERVER(inode);
+	struct pnfs_layout_segment *lseg = rdata->req->wb_lseg;
+	enum pnfs_try_status trypnfs;
+
+	rdata->pdata.call_ops = call_ops;
+
+	dprintk("%s: Reading ino:%lu %u@%llu\n",
+		__func__, inode->i_ino, rdata->args.count, rdata->args.offset);
+
+	get_lseg(lseg);
+
+	rdata->pdata.lseg = lseg;
+	trypnfs = nfss->pnfs_curr_ld->ld_io_ops->read_pagelist(rdata,
+		nfs_page_array_len(rdata->args.pgbase, rdata->args.count));
+	if (trypnfs == PNFS_NOT_ATTEMPTED) {
+		rdata->pdata.lseg = NULL;
+		put_lseg(lseg);
+		_pnfs_clear_lseg_from_pages(&rdata->pages);
+	} else {
+		nfs_inc_stats(inode, NFSIOS_PNFS_READ);
+	}
+	dprintk("%s End (trypnfs:%d)\n", __func__, trypnfs);
+	return trypnfs;
+}
+
+/*
  * Set up the argument/result storage required for the RPC call.
  */
 static int
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 5cd00fd..b7a3769 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -40,6 +40,8 @@ int _pnfs_return_layout(struct inode *, struct nfs4_pnfs_layout_segment *,
 			enum pnfs_layoutreturn_type, bool wait);
 void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
 void unmount_pnfs_layoutdriver(struct nfs_server *);
+enum pnfs_try_status pnfs_try_to_read_data(struct nfs_read_data *,
+					    const struct rpc_call_ops *);
 int pnfs_initialize(void);
 void pnfs_uninitialize(void);
 void pnfs_layoutcommit_free(struct pnfs_layoutcommit_data *data);
@@ -148,6 +150,20 @@ pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 		*lsegpp = NULL;
 }
 
+static inline enum pnfs_try_status
+pnfs_try_to_read_data(struct nfs_read_data *data,
+		      const struct rpc_call_ops *call_ops)
+{
+	return PNFS_NOT_ATTEMPTED;
+}
+
+static inline enum pnfs_try_status
+pnfs_try_to_commit(struct nfs_write_data *data,
+		   const struct rpc_call_ops *call_ops, int how)
+{
+	return PNFS_NOT_ATTEMPTED;
+}
+
 static inline int pnfs_layoutcommit_inode(struct inode *inode, int sync)
 {
 	return 0;
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 324b577..ae3681b 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -18,8 +18,11 @@
 #include <linux/sunrpc/clnt.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfs_page.h>
+#include <linux/smp_lock.h>
+#include <linux/module.h>
 
 #include <asm/system.h>
+#include <linux/module.h>
 #include "pnfs.h"
 
 #include "nfs4_fs.h"
@@ -159,24 +162,20 @@ static void nfs_readpage_release(struct nfs_page *req)
 	nfs_release_request(req);
 }
 
-/*
- * Set up the NFS read request struct
- */
-static int nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
-		const struct rpc_call_ops *call_ops,
-		unsigned int count, unsigned int offset)
+int nfs_initiate_read(struct nfs_read_data *data, struct rpc_clnt *clnt,
+		      const struct rpc_call_ops *call_ops)
 {
-	struct inode *inode = req->wb_context->path.dentry->d_inode;
+	struct inode *inode = data->inode;
 	int swap_flags = IS_SWAPFILE(inode) ? NFS_RPC_SWAPFLAGS : 0;
 	struct rpc_task *task;
 	struct rpc_message msg = {
 		.rpc_argp = &data->args,
 		.rpc_resp = &data->res,
-		.rpc_cred = req->wb_context->cred,
+		.rpc_cred = data->cred,
 	};
 	struct rpc_task_setup task_setup_data = {
 		.task = &data->task,
-		.rpc_client = NFS_CLIENT(inode),
+		.rpc_client = clnt,
 		.rpc_message = &msg,
 		.callback_ops = call_ops,
 		.callback_data = data,
@@ -184,9 +183,46 @@ static int nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
 		.flags = RPC_TASK_ASYNC | swap_flags,
 	};
 
+	/* Set up the initial task struct. */
+	NFS_PROTO(inode)->read_setup(data, &msg);
+
+	dprintk("NFS: %5u initiated read call (req %s/%Ld, %u bytes @ offset %Lu)\n",
+			data->task.tk_pid,
+			inode->i_sb->s_id,
+			(long long)NFS_FILEID(inode),
+			data->args.count,
+			(unsigned long long)data->args.offset);
+
+	task = rpc_run_task(&task_setup_data);
+	if (IS_ERR(task))
+		return PTR_ERR(task);
+	rpc_put_task(task);
+	return 0;
+}
+EXPORT_SYMBOL(nfs_initiate_read);
+
+int pnfs_initiate_read(struct nfs_read_data *data, struct rpc_clnt *clnt,
+		       const struct rpc_call_ops *call_ops)
+{
+	if (data->req->wb_lseg &&
+	    (pnfs_try_to_read_data(data, call_ops) == PNFS_ATTEMPTED))
+		return 0;
+
+	return nfs_initiate_read(data, clnt, call_ops);
+}
+
+/*
+ * Set up the NFS read request struct
+ */
+static int nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
+		const struct rpc_call_ops *call_ops,
+		unsigned int count, unsigned int offset)
+{
+	struct inode *inode = req->wb_context->path.dentry->d_inode;
+
 	data->req	  = req;
 	data->inode	  = inode;
-	data->cred	  = msg.rpc_cred;
+	data->cred	  = req->wb_context->cred;
 
 	data->args.fh     = NFS_FH(inode);
 	data->args.offset = req_offset(req) + offset;
@@ -201,21 +237,7 @@ static int nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
 	data->res.eof     = 0;
 	nfs_fattr_init(&data->fattr);
 
-	/* Set up the initial task struct. */
-	NFS_PROTO(inode)->read_setup(data, &msg);
-
-	dprintk("NFS: %5u initiated read call (req %s/%Ld, %u bytes @ offset %Lu)\n",
-			data->task.tk_pid,
-			inode->i_sb->s_id,
-			(long long)NFS_FILEID(inode),
-			count,
-			(unsigned long long)data->args.offset);
-
-	task = rpc_run_task(&task_setup_data);
-	if (IS_ERR(task))
-		return PTR_ERR(task);
-	rpc_put_task(task);
-	return 0;
+	return pnfs_initiate_read(data, NFS_CLIENT(inode), call_ops);
 }
 
 static void
@@ -359,7 +381,14 @@ static void nfs_readpage_retry(struct rpc_task *task, struct nfs_read_data *data
 {
 	struct nfs_readargs *argp = &data->args;
 	struct nfs_readres *resp = &data->res;
+	struct nfs_client *clp = NFS_SERVER(data->inode)->nfs_client;
 
+#ifdef CONFIG_NFS_V4_1
+	if (data->fldata.ds_nfs_client) {
+		dprintk("%s DS read\n", __func__);
+		clp = data->fldata.ds_nfs_client;
+	}
+#endif /* CONFIG_NFS_V4_1 */
 	if (resp->eof || resp->count == argp->count)
 		return;
 
@@ -373,7 +402,7 @@ static void nfs_readpage_retry(struct rpc_task *task, struct nfs_read_data *data
 	argp->offset += resp->count;
 	argp->pgbase += resp->count;
 	argp->count -= resp->count;
-	nfs_restart_rpc(task, NFS_SERVER(data->inode)->nfs_client);
+	nfs_restart_rpc(task, clp);
 }
 
 /*
@@ -414,13 +443,19 @@ static void nfs_readpage_release_partial(void *calldata)
 void nfs_read_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs_read_data *data = calldata;
+	struct nfs4_session *ds_session = NULL;
 
-	if (nfs4_setup_sequence(NFS_SERVER(data->inode), NULL,
+	if (data->fldata.ds_nfs_client) {
+		dprintk("%s DS read\n", __func__);
+		ds_session = data->fldata.ds_nfs_client->cl_session;
+	}
+	if (nfs4_setup_sequence(NFS_SERVER(data->inode), ds_session,
 				&data->args.seq_args, &data->res.seq_res,
 				0, task))
 		return;
 	rpc_call_start(task);
 }
+EXPORT_SYMBOL(nfs_read_prepare);
 #endif /* CONFIG_NFS_V4_1 */
 
 static const struct rpc_call_ops nfs_read_partial_ops = {
@@ -641,6 +676,7 @@ int nfs_readpages(struct file *filp, struct address_space *mapping,
 	ret = read_cache_pages(mapping, pages, readpage_async_filler, &desc);
 
 	nfs_pageio_complete(&pgio);
+	put_lseg(pgio.pg_lseg);
 	npages = (pgio.pg_bytes_written + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
 	nfs_add_stats(inode, NFSIOS_READPAGES, npages);
 read_complete:
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index 9e3fff4..2bd068d 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -15,6 +15,11 @@
 #include <linux/pnfs_xdr.h>
 #include <linux/nfs_page.h>
 
+enum pnfs_try_status {
+	PNFS_ATTEMPTED     = 0,
+	PNFS_NOT_ATTEMPTED = 1,
+};
+
 /* Per-layout driver specific registration structure */
 struct pnfs_layoutdriver_type {
 	const u32 id;
@@ -104,6 +109,18 @@ LSEG_LD_DATA(struct pnfs_layout_segment *lseg)
  * Either the pagecache or non-pagecache read/write operations must be implemented
  */
 struct layoutdriver_io_operations {
+	/* Functions that use the pagecache.
+	 * If use_pagecache == 1, then these functions must be implemented.
+	 */
+	/* read and write pagelist should return just 0 (to indicate that
+	 * the layout code has taken control) or 1 (to indicate that the
+	 * layout code wishes to fall back to normal nfs.)  If 0 is returned,
+	 * information can be passed back through nfs_data->res and
+	 * nfs_data->task.tk_status, and the appropriate pnfs done function
+	 * MUST be called.
+	 */
+	enum pnfs_try_status
+	(*read_pagelist) (struct nfs_read_data *nfs_data, unsigned nr_pages);
 	/* Layout information. For each inode, alloc_layout is executed once to retrieve an
 	 * inode specific layout structure.  Each subsequent layoutget operation results in
 	 * a set_layout call to set the opaque layout in the layout driver.*/
diff --git a/include/linux/nfs_iostat.h b/include/linux/nfs_iostat.h
index 68b10f5..37a1437 100644
--- a/include/linux/nfs_iostat.h
+++ b/include/linux/nfs_iostat.h
@@ -113,6 +113,7 @@ enum nfs_stat_eventcounters {
 	NFSIOS_SHORTREAD,
 	NFSIOS_SHORTWRITE,
 	NFSIOS_DELAY,
+	NFSIOS_PNFS_READ,
 	__NFSIOS_COUNTSMAX,
 };
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index f1054d4..2de5313 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -972,6 +972,23 @@ struct nfs_page;
 
 #define NFS_PAGEVEC_SIZE	(8U)
 
+#if defined(CONFIG_NFS_V4_1)
+
+/* pnfs-specific data needed for read, write, and commit calls */
+struct pnfs_call_data {
+	struct pnfs_layout_segment *lseg;
+	const struct rpc_call_ops *call_ops;
+	u32			orig_count;	/* for retry via MDS */
+	u8			how;		/* for FLUSH_STABLE */
+};
+
+/* files layout-type specific data for read, write, and commit */
+struct pnfs_fl_call_data {
+	struct nfs_client	*ds_nfs_client;
+	__u64			orig_offset;
+};
+#endif /* CONFIG_NFS_V4_1 */
+
 struct nfs_read_data {
 	int			flags;
 	struct rpc_task		task;
@@ -987,6 +1004,10 @@ struct nfs_read_data {
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

