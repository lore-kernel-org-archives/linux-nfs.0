Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13672 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753082Ab1BDVe2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Feb 2011 16:34:28 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>,
        Andy Adamson <andros@citi.umich.edu>,
        Boaz Harrosh <bharrosh@panasas.com>,
        Dean Hildebrand <dhildeb@us.ibm.com>,
        Fred Isaman <iisaman@citi.umich.edu>, Fred Isaman <iisaman@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Mike Sager <sager@netapp.com>, Mingyang Guo <guomingyang@nrchpc.ac.cn>,
        Ricardo Labiaga <Ricardo.Labiaga@netapp.com>,
        Tao Guo <guotao@nrchpc.ac.cn>
Subject: [PATCH 09/40] pnfs_submit: wave3 generic read
Date: Fri,  4 Feb 2011 16:33:31 -0500
Message-Id: <1296855242-2592-10-git-send-email-andros@netapp.com>
In-Reply-To: <1296855242-2592-9-git-send-email-andros@netapp.com>
References: <1296855242-2592-1-git-send-email-andros@netapp.com>
 <1296855242-2592-2-git-send-email-andros@netapp.com>
 <1296855242-2592-3-git-send-email-andros@netapp.com>
 <1296855242-2592-4-git-send-email-andros@netapp.com>
 <1296855242-2592-5-git-send-email-andros@netapp.com>
 <1296855242-2592-6-git-send-email-andros@netapp.com>
 <1296855242-2592-7-git-send-email-andros@netapp.com>
 <1296855242-2592-8-git-send-email-andros@netapp.com>
 <1296855242-2592-9-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Reported-by: Alexandros Batsakis <batsakis@netapp.com>
Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Fred Isaman <iisaman@netapp.com>
Signed-off-by: J. Bruce Fields <bfields@fieldses.org>
Signed-off-by: Mike Sager <sager@netapp.com>
Signed-off-by: Mingyang Guo <guomingyang@nrchpc.ac.cn>
Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Signed-off-by: Tao Guo <guotao@nrchpc.ac.cn>
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/internal.h          |    4 ++
 fs/nfs/nfs4proc.c          |   15 ++++++-
 fs/nfs/pnfs.c              |   36 +++++++++++++++++
 fs/nfs/pnfs.h              |   24 ++++++++++++
 fs/nfs/read.c              |   90 ++++++++++++++++++++++++++++++-------------
 include/linux/nfs_iostat.h |    1 +
 include/linux/nfs_xdr.h    |   21 ++++++++++
 7 files changed, 161 insertions(+), 30 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 869b388..657b71c 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -274,6 +274,10 @@ extern int nfs4_get_rootfh(struct nfs_server *server, struct nfs_fh *mntfh);
 #endif
 
 /* read.c */
+extern int nfs_initiate_read(struct nfs_read_data *data, struct rpc_clnt *clnt,
+			     const struct rpc_call_ops *call_ops);
+extern int pnfs_initiate_read(struct nfs_read_data *data, struct rpc_clnt *clnt,
+			     const struct rpc_call_ops *call_ops);
 extern void nfs_read_prepare(struct rpc_task *task, void *calldata);
 
 /* write.c */
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4d5bd81..49e89d8 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3076,19 +3076,28 @@ static int nfs4_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle,
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
index 1811204..d06e9ea 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -30,6 +30,7 @@
 #include <linux/nfs_fs.h>
 #include "internal.h"
 #include "pnfs.h"
+#include "iostat.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PNFS
 
@@ -921,6 +922,41 @@ static void _pnfs_clear_lseg_from_pages(struct list_head *head)
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
+	trypnfs = nfss->pnfs_curr_ld->read_pagelist(rdata,
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
  * Device ID cache. Currently supports one layout type per struct nfs_client.
  * Add layout type to the lookup key to expand to support multiple types.
  */
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 7614c3b..2e231e3 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -45,6 +45,11 @@ struct pnfs_layout_segment {
 	struct pnfs_layout_hdr *pls_layout;
 };
 
+enum pnfs_try_status {
+	PNFS_ATTEMPTED     = 0,
+	PNFS_NOT_ATTEMPTED = 1,
+};
+
 #ifdef CONFIG_NFS_V4_1
 
 #define LAYOUT_NFSV4_1_MODULE_PREFIX "nfs-layouttype4"
@@ -70,6 +75,16 @@ struct pnfs_layoutdriver_type {
 
 	/* test for nfs page cache coalescing */
 	int (*pg_test)(struct nfs_pageio_descriptor *, struct nfs_page *, struct nfs_page *);
+
+	/* read and write pagelist should return just 0 (to indicate that
+	 * the layout code has taken control) or 1 (to indicate that the
+	 * layout code wishes to fall back to normal nfs.)  If 0 is returned,
+	 * information can be passed back through nfs_data->res and
+	 * nfs_data->task.tk_status, and the appropriate pnfs done function
+	 * MUST be called.
+	 */
+	enum pnfs_try_status
+	(*read_pagelist) (struct nfs_read_data *nfs_data, unsigned nr_pages);
 };
 
 struct pnfs_layout_hdr {
@@ -157,6 +172,8 @@ pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 		   enum pnfs_iomode access_type);
 void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
 void unset_pnfs_layoutdriver(struct nfs_server *);
+enum pnfs_try_status pnfs_try_to_read_data(struct nfs_read_data *,
+					    const struct rpc_call_ops *);
 void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *,
 			   struct nfs_open_context *, struct list_head *);
 int pnfs_layout_process(struct nfs4_layoutget *lgp);
@@ -222,6 +239,13 @@ pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 	return NULL;
 }
 
+static inline enum pnfs_try_status
+pnfs_try_to_read_data(struct nfs_read_data *data,
+		      const struct rpc_call_ops *call_ops)
+{
+	return PNFS_NOT_ATTEMPTED;
+}
+
 static inline bool
 pnfs_roc(struct inode *ino)
 {
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 2eac0f1..79da5cb 100644
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
@@ -157,24 +160,20 @@ static void nfs_readpage_release(struct nfs_page *req)
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
@@ -182,9 +181,46 @@ static int nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
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
@@ -199,21 +235,7 @@ static int nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
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
@@ -357,7 +379,14 @@ static void nfs_readpage_retry(struct rpc_task *task, struct nfs_read_data *data
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
 
@@ -371,7 +400,7 @@ static void nfs_readpage_retry(struct rpc_task *task, struct nfs_read_data *data
 	argp->offset += resp->count;
 	argp->pgbase += resp->count;
 	argp->count -= resp->count;
-	nfs_restart_rpc(task, NFS_SERVER(data->inode)->nfs_client);
+	nfs_restart_rpc(task, clp);
 }
 
 /*
@@ -412,13 +441,19 @@ static void nfs_readpage_release_partial(void *calldata)
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
@@ -637,6 +672,7 @@ int nfs_readpages(struct file *filp, struct address_space *mapping,
 	ret = read_cache_pages(mapping, pages, readpage_async_filler, &desc);
 
 	nfs_pageio_complete(&pgio);
+	put_lseg(pgio.pg_lseg);
 	npages = (pgio.pg_bytes_written + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
 	nfs_add_stats(inode, NFSIOS_READPAGES, npages);
 read_complete:
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
index b006857..bd84684 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1004,6 +1004,23 @@ struct nfs_page;
 
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
@@ -1019,6 +1036,10 @@ struct nfs_read_data {
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
1.6.6

