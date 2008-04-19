From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 06/33] NFS: Ensure that the write code cleans up properly
	when rpc_run_task() fails
Date: Sat, 19 Apr 2008 16:40:48 -0400
Message-ID: <20080419204048.14124.39513.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080419204047.14124.49490.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:18330 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756288AbYDSUu2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 19 Apr 2008 16:50:28 -0400
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m3JKoQ8i002622
	for <linux-nfs@vger.kernel.org>; Sat, 19 Apr 2008 13:50:27 -0700 (PDT)
In-Reply-To: <20080419204047.14124.49490.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/direct.c        |   50 ++++++++++++++++++++----------------
 fs/nfs/write.c         |   67 +++++++++++++++++++++++++++++++-----------------
 include/linux/nfs_fs.h |    4 +--
 3 files changed, 73 insertions(+), 48 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 9d9085b..abf8e02 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -508,27 +508,34 @@ static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 static void nfs_direct_commit_result(struct rpc_task *task, void *calldata)
 {
 	struct nfs_write_data *data = calldata;
-	struct nfs_direct_req *dreq = (struct nfs_direct_req *) data->req;
 
 	/* Call the NFS version-specific code */
-	if (NFS_PROTO(data->inode)->commit_done(task, data) != 0)
-		return;
-	if (unlikely(task->tk_status < 0)) {
+	NFS_PROTO(data->inode)->commit_done(task, data);
+}
+
+static void nfs_direct_commit_release(void *calldata)
+{
+	struct nfs_write_data *data = calldata;
+	struct nfs_direct_req *dreq = (struct nfs_direct_req *) data->req;
+	int status = data->task.tk_status;
+
+	if (status < 0) {
 		dprintk("NFS: %5u commit failed with error %d.\n",
-				task->tk_pid, task->tk_status);
+				data->task.tk_pid, status);
 		dreq->flags = NFS_ODIRECT_RESCHED_WRITES;
 	} else if (memcmp(&dreq->verf, &data->verf, sizeof(data->verf))) {
-		dprintk("NFS: %5u commit verify failed\n", task->tk_pid);
+		dprintk("NFS: %5u commit verify failed\n", data->task.tk_pid);
 		dreq->flags = NFS_ODIRECT_RESCHED_WRITES;
 	}
 
-	dprintk("NFS: %5u commit returned %d\n", task->tk_pid, task->tk_status);
+	dprintk("NFS: %5u commit returned %d\n", data->task.tk_pid, status);
 	nfs_direct_write_complete(dreq, data->inode);
+	nfs_commitdata_release(calldata);
 }
 
 static const struct rpc_call_ops nfs_commit_direct_ops = {
 	.rpc_call_done = nfs_direct_commit_result,
-	.rpc_release = nfs_commit_release,
+	.rpc_release = nfs_direct_commit_release,
 };
 
 static void nfs_direct_commit_schedule(struct nfs_direct_req *dreq)
@@ -596,7 +603,7 @@ static void nfs_direct_write_complete(struct nfs_direct_req *dreq, struct inode
 
 static void nfs_alloc_commit_data(struct nfs_direct_req *dreq)
 {
-	dreq->commit_data = nfs_commit_alloc();
+	dreq->commit_data = nfs_commitdata_alloc();
 	if (dreq->commit_data != NULL)
 		dreq->commit_data->req = (struct nfs_page *) dreq;
 }
@@ -617,11 +624,20 @@ static void nfs_direct_write_complete(struct nfs_direct_req *dreq, struct inode
 static void nfs_direct_write_result(struct rpc_task *task, void *calldata)
 {
 	struct nfs_write_data *data = calldata;
-	struct nfs_direct_req *dreq = (struct nfs_direct_req *) data->req;
-	int status = task->tk_status;
 
 	if (nfs_writeback_done(task, data) != 0)
 		return;
+}
+
+/*
+ * NB: Return the value of the first error return code.  Subsequent
+ *     errors after the first one are ignored.
+ */
+static void nfs_direct_write_release(void *calldata)
+{
+	struct nfs_write_data *data = calldata;
+	struct nfs_direct_req *dreq = (struct nfs_direct_req *) data->req;
+	int status = data->task.tk_status;
 
 	spin_lock(&dreq->lock);
 
@@ -643,23 +659,13 @@ static void nfs_direct_write_result(struct rpc_task *task, void *calldata)
 				break;
 			case NFS_ODIRECT_DO_COMMIT:
 				if (memcmp(&dreq->verf, &data->verf, sizeof(dreq->verf))) {
-					dprintk("NFS: %5u write verify failed\n", task->tk_pid);
+					dprintk("NFS: %5u write verify failed\n", data->task.tk_pid);
 					dreq->flags = NFS_ODIRECT_RESCHED_WRITES;
 				}
 		}
 	}
 out_unlock:
 	spin_unlock(&dreq->lock);
-}
-
-/*
- * NB: Return the value of the first error return code.  Subsequent
- *     errors after the first one are ignored.
- */
-static void nfs_direct_write_release(void *calldata)
-{
-	struct nfs_write_data *data = calldata;
-	struct nfs_direct_req *dreq = (struct nfs_direct_req *) data->req;
 
 	if (put_dreq(dreq))
 		nfs_direct_write_complete(dreq, data->inode);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 997b42a..31681bb 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -48,7 +48,7 @@ static struct kmem_cache *nfs_wdata_cachep;
 static mempool_t *nfs_wdata_mempool;
 static mempool_t *nfs_commit_mempool;
 
-struct nfs_write_data *nfs_commit_alloc(void)
+struct nfs_write_data *nfs_commitdata_alloc(void)
 {
 	struct nfs_write_data *p = mempool_alloc(nfs_commit_mempool, GFP_NOFS);
 
@@ -973,7 +973,6 @@ static void nfs_writeback_done_partial(struct rpc_task *task, void *calldata)
 {
 	struct nfs_write_data	*data = calldata;
 	struct nfs_page		*req = data->req;
-	struct page		*page = req->wb_page;
 
 	dprintk("NFS: write (%s/%Ld %d@%Ld)",
 		req->wb_context->path.dentry->d_inode->i_sb->s_id,
@@ -981,13 +980,20 @@ static void nfs_writeback_done_partial(struct rpc_task *task, void *calldata)
 		req->wb_bytes,
 		(long long)req_offset(req));
 
-	if (nfs_writeback_done(task, data) != 0)
-		return;
+	nfs_writeback_done(task, data);
+}
 
-	if (task->tk_status < 0) {
+static void nfs_writeback_release_partial(void *calldata)
+{
+	struct nfs_write_data	*data = calldata;
+	struct nfs_page		*req = data->req;
+	struct page		*page = req->wb_page;
+	int status = data->task.tk_status;
+
+	if (status < 0) {
 		nfs_set_pageerror(page);
-		nfs_context_set_write_error(req->wb_context, task->tk_status);
-		dprintk(", error = %d\n", task->tk_status);
+		nfs_context_set_write_error(req->wb_context, status);
+		dprintk(", error = %d\n", status);
 		goto out;
 	}
 
@@ -1012,11 +1018,12 @@ static void nfs_writeback_done_partial(struct rpc_task *task, void *calldata)
 out:
 	if (atomic_dec_and_test(&req->wb_complete))
 		nfs_writepage_release(req);
+	nfs_writedata_release(calldata);
 }
 
 static const struct rpc_call_ops nfs_write_partial_ops = {
 	.rpc_call_done = nfs_writeback_done_partial,
-	.rpc_release = nfs_writedata_release,
+	.rpc_release = nfs_writeback_release_partial,
 };
 
 /*
@@ -1029,17 +1036,21 @@ static const struct rpc_call_ops nfs_write_partial_ops = {
 static void nfs_writeback_done_full(struct rpc_task *task, void *calldata)
 {
 	struct nfs_write_data	*data = calldata;
-	struct nfs_page		*req;
-	struct page		*page;
 
-	if (nfs_writeback_done(task, data) != 0)
-		return;
+	nfs_writeback_done(task, data);
+}
+
+static void nfs_writeback_release_full(void *calldata)
+{
+	struct nfs_write_data	*data = calldata;
+	int status = data->task.tk_status;
 
 	/* Update attributes as result of writeback. */
 	while (!list_empty(&data->pages)) {
-		req = nfs_list_entry(data->pages.next);
+		struct nfs_page *req = nfs_list_entry(data->pages.next);
+		struct page *page = req->wb_page;
+
 		nfs_list_remove_request(req);
-		page = req->wb_page;
 
 		dprintk("NFS: write (%s/%Ld %d@%Ld)",
 			req->wb_context->path.dentry->d_inode->i_sb->s_id,
@@ -1047,10 +1058,10 @@ static void nfs_writeback_done_full(struct rpc_task *task, void *calldata)
 			req->wb_bytes,
 			(long long)req_offset(req));
 
-		if (task->tk_status < 0) {
+		if (status < 0) {
 			nfs_set_pageerror(page);
-			nfs_context_set_write_error(req->wb_context, task->tk_status);
-			dprintk(", error = %d\n", task->tk_status);
+			nfs_context_set_write_error(req->wb_context, status);
+			dprintk(", error = %d\n", status);
 			goto remove_request;
 		}
 
@@ -1070,11 +1081,12 @@ remove_request:
 	next:
 		nfs_clear_page_tag_locked(req);
 	}
+	nfs_writedata_release(calldata);
 }
 
 static const struct rpc_call_ops nfs_write_full_ops = {
 	.rpc_call_done = nfs_writeback_done_full,
-	.rpc_release = nfs_writedata_release,
+	.rpc_release = nfs_writeback_release_full,
 };
 
 
@@ -1160,7 +1172,7 @@ int nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 
 
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
-void nfs_commit_release(void *data)
+void nfs_commitdata_release(void *data)
 {
 	struct nfs_write_data *wdata = data;
 
@@ -1233,7 +1245,7 @@ nfs_commit_list(struct inode *inode, struct list_head *head, int how)
 	struct nfs_write_data	*data;
 	struct nfs_page         *req;
 
-	data = nfs_commit_alloc();
+	data = nfs_commitdata_alloc();
 
 	if (!data)
 		goto out_bad;
@@ -1261,7 +1273,6 @@ nfs_commit_list(struct inode *inode, struct list_head *head, int how)
 static void nfs_commit_done(struct rpc_task *task, void *calldata)
 {
 	struct nfs_write_data	*data = calldata;
-	struct nfs_page		*req;
 
         dprintk("NFS: %5u nfs_commit_done (status %d)\n",
                                 task->tk_pid, task->tk_status);
@@ -1269,6 +1280,13 @@ static void nfs_commit_done(struct rpc_task *task, void *calldata)
 	/* Call the NFS version-specific code */
 	if (NFS_PROTO(data->inode)->commit_done(task, data) != 0)
 		return;
+}
+
+static void nfs_commit_release(void *calldata)
+{
+	struct nfs_write_data	*data = calldata;
+	struct nfs_page		*req;
+	int status = data->task.tk_status;
 
 	while (!list_empty(&data->pages)) {
 		req = nfs_list_entry(data->pages.next);
@@ -1283,10 +1301,10 @@ static void nfs_commit_done(struct rpc_task *task, void *calldata)
 			(long long)NFS_FILEID(req->wb_context->path.dentry->d_inode),
 			req->wb_bytes,
 			(long long)req_offset(req));
-		if (task->tk_status < 0) {
-			nfs_context_set_write_error(req->wb_context, task->tk_status);
+		if (status < 0) {
+			nfs_context_set_write_error(req->wb_context, status);
 			nfs_inode_remove_request(req);
-			dprintk(", error = %d\n", task->tk_status);
+			dprintk(", error = %d\n", status);
 			goto next;
 		}
 
@@ -1307,6 +1325,7 @@ static void nfs_commit_done(struct rpc_task *task, void *calldata)
 	next:
 		nfs_clear_page_tag_locked(req);
 	}
+	nfs_commitdata_release(calldata);
 }
 
 static const struct rpc_call_ops nfs_commit_ops = {
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index f4a0e4c..7f0602c 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -466,9 +466,9 @@ extern int nfs_wb_page(struct inode *inode, struct page* page);
 extern int nfs_wb_page_cancel(struct inode *inode, struct page* page);
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 extern int  nfs_commit_inode(struct inode *, int);
-extern struct nfs_write_data *nfs_commit_alloc(void);
+extern struct nfs_write_data *nfs_commitdata_alloc(void);
 extern void nfs_commit_free(struct nfs_write_data *wdata);
-extern void nfs_commit_release(void *wdata);
+extern void nfs_commitdata_release(void *wdata);
 #else
 static inline int
 nfs_commit_inode(struct inode *inode, int how)

