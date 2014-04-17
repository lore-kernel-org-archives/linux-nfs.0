Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:31635 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751200AbaDQVKL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Apr 2014 17:10:11 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 09/17] NFS: Create a common nfs_pgio_result_common function
Date: Thu, 17 Apr 2014 17:09:33 -0400
Message-ID: <1397768981-12856-10-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1397768981-12856-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1397768981-12856-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@netapp.com>

Combining these functions will let me make a single nfs_rw_common_ops
struct (see the next patch).

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/internal.h        |  1 +
 fs/nfs/pageio.c          | 23 ++++++++++++++++++++++
 fs/nfs/read.c            | 25 ++++++++----------------
 fs/nfs/write.c           | 51 +++++++++++++++++++-----------------------------
 include/linux/nfs_fs.h   |  1 -
 include/linux/nfs_page.h |  2 ++
 6 files changed, 54 insertions(+), 49 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 105e2b5..b18cca4 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -402,6 +402,7 @@ extern struct nfs_pgio_data *nfs_pgio_data_alloc(struct nfs_pgio_header *, unsig
 extern void nfs_pgio_data_release(struct nfs_pgio_data *);
 extern void nfs_pgio_prepare(struct rpc_task *, void *);
 extern void nfs_pgio_release_common(void *);
+extern void nfs_pgio_result_common(struct rpc_task *, void *);
 
 /* read.c */
 extern void nfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
diff --git a/fs/nfs/pageio.c b/fs/nfs/pageio.c
index 864d2f7..efbcc44 100644
--- a/fs/nfs/pageio.c
+++ b/fs/nfs/pageio.c
@@ -11,6 +11,7 @@
 
 #include "internal.h"
 
+#define NFSDBG_FACILITY		NFSDBG_PAGECACHE
 
 static inline struct nfs_rw_header *NFS_RW_HEADER(struct nfs_pgio_header *hdr)
 {
@@ -102,3 +103,25 @@ void nfs_pgio_release_common(void *calldata)
 		data->header->rw_ops->rw_release(data);
 	nfs_pgio_data_release(data);
 }
+
+static int nfs_pgio_result(struct rpc_task *task, struct nfs_pgio_data *data)
+{
+	struct inode *inode = data->header->inode;
+
+	dprintk("NFS: %s: %5u, (status %d)\n", __func__, task->tk_pid,
+			task->tk_status);
+
+	return data->header->rw_ops->rw_result(task, data, inode);
+}
+
+void nfs_pgio_result_common(struct rpc_task *task, void *calldata)
+{
+	struct nfs_pgio_data *data = calldata;
+
+	if (nfs_pgio_result(task, data) != 0)
+		return;
+	if (task->tk_status < 0)
+		nfs_set_pgio_error(data->header, task->tk_status, data->args.offset);
+	else
+		data->header->rw_ops->rw_result_common(task, data);
+}
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 313835b..4f49507 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -388,15 +388,10 @@ static const struct nfs_pageio_ops nfs_pageio_read_ops = {
  * This is the callback from RPC telling us whether a reply was
  * received or some error occurred (timeout or socket shutdown).
  */
-int nfs_readpage_result(struct rpc_task *task, struct nfs_pgio_data *data)
+static int nfs_readpage_result(struct rpc_task *task, struct nfs_pgio_data *data,
+			       struct inode *inode)
 {
-	struct inode *inode = data->header->inode;
-	int status;
-
-	dprintk("NFS: %s: %5u, (status %d)\n", __func__, task->tk_pid,
-			task->tk_status);
-
-	status = NFS_PROTO(inode)->read_done(task, data);
+	int status = NFS_PROTO(inode)->read_done(task, data);
 	if (status != 0)
 		return status;
 
@@ -429,17 +424,11 @@ static void nfs_readpage_retry(struct rpc_task *task, struct nfs_pgio_data *data
 	rpc_restart_call_prepare(task);
 }
 
-static void nfs_readpage_result_common(struct rpc_task *task, void *calldata)
+static void nfs_readpage_result_common(struct rpc_task *task, struct nfs_pgio_data *data)
 {
-	struct nfs_pgio_data *data = calldata;
 	struct nfs_pgio_header *hdr = data->header;
 
-	/* Note the only returns of nfs_readpage_result are 0 and -EAGAIN */
-	if (nfs_readpage_result(task, data) != 0)
-		return;
-	if (task->tk_status < 0)
-		nfs_set_pgio_error(hdr, task->tk_status, data->args.offset);
-	else if (data->res.eof) {
+	if (data->res.eof) {
 		loff_t bound;
 
 		bound = data->args.offset + data->res.count;
@@ -456,7 +445,7 @@ static void nfs_readpage_result_common(struct rpc_task *task, void *calldata)
 
 static const struct rpc_call_ops nfs_read_common_ops = {
 	.rpc_call_prepare = nfs_pgio_prepare,
-	.rpc_call_done = nfs_readpage_result_common,
+	.rpc_call_done = nfs_pgio_result_common,
 	.rpc_release = nfs_pgio_release_common,
 };
 
@@ -625,4 +614,6 @@ static const struct nfs_rw_ops nfs_rw_read_ops = {
 	.rw_mode		= FMODE_READ,
 	.rw_alloc_header	= nfs_readhdr_alloc,
 	.rw_free_header		= nfs_readhdr_free,
+	.rw_result		= nfs_readpage_result,
+	.rw_result_common	= nfs_readpage_result_common,
 };
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index b08fb7d..d2351a1 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1255,20 +1255,6 @@ void nfs_commit_prepare(struct rpc_task *task, void *calldata)
 	NFS_PROTO(data->inode)->commit_rpc_prepare(task, data);
 }
 
-/*
- * Handle a write reply that flushes a whole page.
- *
- * FIXME: There is an inherent race with invalidate_inode_pages and
- *	  writebacks since the page->count is kept > 1 for as long
- *	  as the page has a write request pending.
- */
-static void nfs_writeback_done_common(struct rpc_task *task, void *calldata)
-{
-	struct nfs_pgio_data	*data = calldata;
-
-	nfs_writeback_done(task, data);
-}
-
 static void nfs_writeback_release_common(struct nfs_pgio_data *data)
 {
 	struct nfs_pgio_header *hdr = data->header;
@@ -1288,7 +1274,7 @@ static void nfs_writeback_release_common(struct nfs_pgio_data *data)
 
 static const struct rpc_call_ops nfs_write_common_ops = {
 	.rpc_call_prepare = nfs_pgio_prepare,
-	.rpc_call_done = nfs_writeback_done_common,
+	.rpc_call_done = nfs_pgio_result_common,
 	.rpc_release = nfs_pgio_release_common,
 };
 
@@ -1320,16 +1306,11 @@ static int nfs_should_remove_suid(const struct inode *inode)
 /*
  * This function is called when the WRITE call is complete.
  */
-void nfs_writeback_done(struct rpc_task *task, struct nfs_pgio_data *data)
+static int nfs_writeback_result(struct rpc_task *task, struct nfs_pgio_data *data,
+				struct inode *inode)
 {
-	struct nfs_pgio_args	*argp = &data->args;
-	struct nfs_pgio_res	*resp = &data->res;
-	struct inode		*inode = data->header->inode;
 	int status;
 
-	dprintk("NFS: %5u nfs_writeback_done (status %d)\n",
-		task->tk_pid, task->tk_status);
-
 	/*
 	 * ->write_done will attempt to use post-op attributes to detect
 	 * conflicting writes by other clients.  A strict interpretation
@@ -1339,11 +1320,11 @@ void nfs_writeback_done(struct rpc_task *task, struct nfs_pgio_data *data)
 	 */
 	status = NFS_PROTO(inode)->write_done(task, data);
 	if (status != 0)
-		return;
-	nfs_add_stats(inode, NFSIOS_SERVERWRITTENBYTES, resp->count);
+		return status;
+	nfs_add_stats(inode, NFSIOS_SERVERWRITTENBYTES, data->res.count);
 
 #if IS_ENABLED(CONFIG_NFS_V3) || IS_ENABLED(CONFIG_NFS_V4)
-	if (resp->verf->committed < argp->stable && task->tk_status >= 0) {
+	if (data->res.verf->committed < data->args.stable && task->tk_status >= 0) {
 		/* We tried a write call, but the server did not
 		 * commit data to stable storage even though we
 		 * requested it.
@@ -1359,25 +1340,31 @@ void nfs_writeback_done(struct rpc_task *task, struct nfs_pgio_data *data)
 			dprintk("NFS:       faulty NFS server %s:"
 				" (committed = %d) != (stable = %d)\n",
 				NFS_SERVER(inode)->nfs_client->cl_hostname,
-				resp->verf->committed, argp->stable);
+				data->res.verf->committed, data->args.stable);
 			complain = jiffies + 300 * HZ;
 		}
 	}
 #endif
-	if (task->tk_status < 0) {
-		nfs_set_pgio_error(data->header, task->tk_status, argp->offset);
-		return;
-	}
 
 	/* Deal with the suid/sgid bit corner case */
 	if (nfs_should_remove_suid(inode))
 		nfs_mark_for_revalidate(inode);
+	return 0;
+}
+
+/*
+ * This function is called when the WRITE call is complete.
+ */
+static void nfs_writeback_result_common(struct rpc_task *task, struct nfs_pgio_data *data)
+{
+	struct nfs_pgio_args	*argp = &data->args;
+	struct nfs_pgio_res	*resp = &data->res;
 
 	if (resp->count < argp->count) {
 		static unsigned long    complain;
 
 		/* This a short write! */
-		nfs_inc_stats(inode, NFSIOS_SHORTWRITE);
+		nfs_inc_stats(data->header->inode, NFSIOS_SHORTWRITE);
 
 		/* Has the server at least made some progress? */
 		if (resp->count == 0) {
@@ -1911,4 +1898,6 @@ static const struct nfs_rw_ops nfs_rw_write_ops = {
 	.rw_alloc_header	= nfs_writehdr_alloc,
 	.rw_free_header		= nfs_writehdr_free,
 	.rw_release		= nfs_writeback_release_common,
+	.rw_result		= nfs_writeback_result,
+	.rw_result_common	= nfs_writeback_result_common,
 };
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 7e0db56..e12a1d6 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -553,7 +553,6 @@ nfs_have_writebacks(struct inode *inode)
 extern int  nfs_readpage(struct file *, struct page *);
 extern int  nfs_readpages(struct file *, struct address_space *,
 		struct list_head *, unsigned);
-extern int  nfs_readpage_result(struct rpc_task *, struct nfs_pgio_data *);
 extern int  nfs_readpage_async(struct nfs_open_context *, struct inode *,
 			       struct page *);
 
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index da00a4d..9477d7a 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -57,6 +57,8 @@ struct nfs_rw_ops {
 	struct nfs_rw_header *(*rw_alloc_header)(void);
 	void (*rw_free_header)(struct nfs_rw_header *);
 	void (*rw_release)(struct nfs_pgio_data *);
+	int  (*rw_result)(struct rpc_task *, struct nfs_pgio_data *, struct inode *);
+	void (*rw_result_common)(struct rpc_task *, struct nfs_pgio_data *);
 };
 
 struct nfs_pageio_descriptor {
-- 
1.9.2

