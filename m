Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:41287 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752507Ab1BNTSz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Feb 2011 14:18:55 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>,
        Andy Adamson <andros@citi.umich.edu>,
        Boaz Harrosh <bharrosh@panasas.com>,
        Dean Hildebrand <dhildeb@us.ibm.com>,
        Fred Isaman <iisaman@citi.umich.edu>, Fred Isaman <iisaman@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Mike Sager <sager@netapp.com>, Mingyang Guo <guomingyang@nrchpc.ac.cn>,
        Ricardo Labiaga <Ricardo.Labiaga@netapp.com>,
        Tao Guo <guotao@nrchpc.ac.cn>, Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 11/16] pnfs: wave 3: generic read
Date: Mon, 14 Feb 2011 14:18:31 -0500
Message-Id: <1297711116-3139-12-git-send-email-andros@netapp.com>
In-Reply-To: <1297711116-3139-1-git-send-email-andros@netapp.com>
References: <1297711116-3139-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Separate the rpc run portion of nfs_read_rpcsetup into a new function
nfs_initiate_read that is called for normal NFS I/O.

Add a pNFS read_pagelist function that is called instead of nfs_intitate_read
for pNFS reads.

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
 fs/nfs/internal.h          |    2 +
 fs/nfs/pnfs.c              |   28 ++++++++++++++++++
 fs/nfs/pnfs.h              |   20 +++++++++++++
 fs/nfs/read.c              |   66 +++++++++++++++++++++++++++----------------
 include/linux/nfs_iostat.h |    1 +
 include/linux/nfs_xdr.h    |    1 +
 6 files changed, 93 insertions(+), 25 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index cf9fdbd..335755d 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -262,6 +262,8 @@ extern int nfs4_get_rootfh(struct nfs_server *server, struct nfs_fh *mntfh);
 #endif
 
 /* read.c */
+extern int nfs_initiate_read(struct nfs_read_data *data, struct rpc_clnt *clnt,
+			     const struct rpc_call_ops *call_ops);
 extern void nfs_read_prepare(struct rpc_task *task, void *calldata);
 
 /* write.c */
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index f200e34..6f4a5ab 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -30,6 +30,7 @@
 #include <linux/nfs_fs.h>
 #include "internal.h"
 #include "pnfs.h"
+#include "iostat.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PNFS
 
@@ -891,6 +892,33 @@ pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 }
 
 /*
+ * Call the appropriate parallel I/O subsystem read function.
+ */
+enum pnfs_try_status
+pnfs_try_to_read_data(struct nfs_read_data *rdata,
+		       const struct rpc_call_ops *call_ops)
+{
+	struct inode *inode = rdata->inode;
+	struct nfs_server *nfss = NFS_SERVER(inode);
+	enum pnfs_try_status trypnfs;
+
+	rdata->mds_ops = call_ops;
+
+	dprintk("%s: Reading ino:%lu %u@%llu\n",
+		__func__, inode->i_ino, rdata->args.count, rdata->args.offset);
+
+	trypnfs = nfss->pnfs_curr_ld->read_pagelist(rdata);
+	if (trypnfs == PNFS_NOT_ATTEMPTED) {
+		put_lseg(rdata->lseg);
+		rdata->lseg = NULL;
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
index 5107d14..585023f 100644
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
@@ -70,6 +75,12 @@ struct pnfs_layoutdriver_type {
 
 	/* test for nfs page cache coalescing */
 	int (*pg_test)(struct nfs_pageio_descriptor *, struct nfs_page *, struct nfs_page *);
+
+	/*
+	 * Return PNFS_ATTEMPTED to indicate the layout code has attempted
+	 * I/O, else return PNFS_NOT_ATTEMPTED to fall back to normal NFS
+	 */
+	enum pnfs_try_status (*read_pagelist) (struct nfs_read_data *nfs_data);
 };
 
 struct pnfs_layout_hdr {
@@ -157,6 +168,8 @@ pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 		   enum pnfs_iomode access_type);
 void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
 void unset_pnfs_layoutdriver(struct nfs_server *);
+enum pnfs_try_status pnfs_try_to_read_data(struct nfs_read_data *,
+					    const struct rpc_call_ops *);
 void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *);
 int pnfs_layout_process(struct nfs4_layoutget *lgp);
 void pnfs_free_lseg_list(struct list_head *tmp_list);
@@ -227,6 +240,13 @@ pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
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
index 20cc936..5c09d72 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -18,6 +18,8 @@
 #include <linux/sunrpc/clnt.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfs_page.h>
+#include <linux/smp_lock.h>
+#include <linux/module.h>
 
 #include <asm/system.h>
 #include "pnfs.h"
@@ -158,25 +160,20 @@ static void nfs_readpage_release(struct nfs_page *req)
 	nfs_release_request(req);
 }
 
-/*
- * Set up the NFS read request struct
- */
-static int nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
-		const struct rpc_call_ops *call_ops,
-		unsigned int count, unsigned int offset,
-		struct pnfs_layout_segment *lseg)
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
@@ -184,9 +181,38 @@ static int nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
 		.flags = RPC_TASK_ASYNC | swap_flags,
 	};
 
+	/* Set up the initial task struct. */
+	NFS_PROTO(inode)->read_setup(data, &msg);
+
+	dprintk("NFS: %5u initiated read call (req %s/%lld, %u bytes @ "
+			"offset %llu)\n",
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
+/*
+ * Set up the NFS read request struct
+ */
+static int nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
+		const struct rpc_call_ops *call_ops,
+		unsigned int count, unsigned int offset,
+		struct pnfs_layout_segment *lseg)
+{
+	struct inode *inode = req->wb_context->path.dentry->d_inode;
+
 	data->req	  = req;
 	data->inode	  = inode;
-	data->cred	  = msg.rpc_cred;
+	data->cred	  = req->wb_context->cred;
 	data->lseg	  = get_lseg(lseg);
 
 	data->args.fh     = NFS_FH(inode);
@@ -202,21 +228,11 @@ static int nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
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
+	if (data->lseg &&
+	    (pnfs_try_to_read_data(data, call_ops) == PNFS_ATTEMPTED))
+		return 0;
 
-	task = rpc_run_task(&task_setup_data);
-	if (IS_ERR(task))
-		return PTR_ERR(task);
-	rpc_put_task(task);
-	return 0;
+	return nfs_initiate_read(data, NFS_CLIENT(inode), call_ops);
 }
 
 static void
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
index 37e91c3..4591075 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1018,6 +1018,7 @@ struct nfs_read_data {
 	struct nfs_readres  res;
 	unsigned long		timestamp;	/* For lease renewal */
 	struct pnfs_layout_segment *lseg;
+	const struct rpc_call_ops *mds_ops;
 	struct page		*page_array[NFS_PAGEVEC_SIZE];
 };
 
-- 
1.7.2.3

