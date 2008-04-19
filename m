From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 05/33] NFS: Ensure that the read code cleans up properly
	when rpc_run_task() fails
Date: Sat, 19 Apr 2008 16:40:48 -0400
Message-ID: <20080419204048.14124.9380.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080419204047.14124.49490.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:61904 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756918AbYDSUue (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 19 Apr 2008 16:50:34 -0400
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m3JKoWcK026103
	for <linux-nfs@vger.kernel.org>; Sat, 19 Apr 2008 13:50:32 -0700 (PDT)
In-Reply-To: <20080419204047.14124.49490.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In the case of readpage() we need to ensure that the pages get unlocked,
and that the error is flagged.

In the case of O_DIRECT, we need to ensure that the pages are all released.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/direct.c |   19 +++++++++++++------
 fs/nfs/read.c   |   53 +++++++++++++++++++++++++++++++++--------------------
 2 files changed, 46 insertions(+), 26 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index e442005..9d9085b 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -229,14 +229,20 @@ static void nfs_direct_complete(struct nfs_direct_req *dreq)
 static void nfs_direct_read_result(struct rpc_task *task, void *calldata)
 {
 	struct nfs_read_data *data = calldata;
-	struct nfs_direct_req *dreq = (struct nfs_direct_req *) data->req;
 
-	if (nfs_readpage_result(task, data) != 0)
-		return;
+	nfs_readpage_result(task, data);
+}
+
+static void nfs_direct_read_release(void *calldata)
+{
+
+	struct nfs_read_data *data = calldata;
+	struct nfs_direct_req *dreq = (struct nfs_direct_req *) data->req;
+	int status = data->task.tk_status;
 
 	spin_lock(&dreq->lock);
-	if (unlikely(task->tk_status < 0)) {
-		dreq->error = task->tk_status;
+	if (unlikely(status < 0)) {
+		dreq->error = status;
 		spin_unlock(&dreq->lock);
 	} else {
 		dreq->count += data->res.count;
@@ -249,11 +255,12 @@ static void nfs_direct_read_result(struct rpc_task *task, void *calldata)
 
 	if (put_dreq(dreq))
 		nfs_direct_complete(dreq);
+	nfs_readdata_release(calldata);
 }
 
 static const struct rpc_call_ops nfs_read_direct_ops = {
 	.rpc_call_done = nfs_direct_read_result,
-	.rpc_release = nfs_readdata_release,
+	.rpc_release = nfs_direct_read_release,
 };
 
 /*
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index d333f5f..6f9208a 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -338,26 +338,25 @@ int nfs_readpage_result(struct rpc_task *task, struct nfs_read_data *data)
 	return 0;
 }
 
-static int nfs_readpage_retry(struct rpc_task *task, struct nfs_read_data *data)
+static void nfs_readpage_retry(struct rpc_task *task, struct nfs_read_data *data)
 {
 	struct nfs_readargs *argp = &data->args;
 	struct nfs_readres *resp = &data->res;
 
 	if (resp->eof || resp->count == argp->count)
-		return 0;
+		return;
 
 	/* This is a short read! */
 	nfs_inc_stats(data->inode, NFSIOS_SHORTREAD);
 	/* Has the server at least made some progress? */
 	if (resp->count == 0)
-		return 0;
+		return;
 
 	/* Yes, so retry the read at the end of the data */
 	argp->offset += resp->count;
 	argp->pgbase += resp->count;
 	argp->count -= resp->count;
 	rpc_restart_call(task);
-	return -EAGAIN;
 }
 
 /*
@@ -366,29 +365,37 @@ static int nfs_readpage_retry(struct rpc_task *task, struct nfs_read_data *data)
 static void nfs_readpage_result_partial(struct rpc_task *task, void *calldata)
 {
 	struct nfs_read_data *data = calldata;
-	struct nfs_page *req = data->req;
-	struct page *page = req->wb_page;
  
 	if (nfs_readpage_result(task, data) != 0)
 		return;
+	if (task->tk_status < 0)
+		return;
 
-	if (likely(task->tk_status >= 0)) {
-		nfs_readpage_truncate_uninitialised_page(data);
-		if (nfs_readpage_retry(task, data) != 0)
-			return;
-	}
-	if (unlikely(task->tk_status < 0))
+	nfs_readpage_truncate_uninitialised_page(data);
+	nfs_readpage_retry(task, data);
+}
+
+static void nfs_readpage_release_partial(void *calldata)
+{
+	struct nfs_read_data *data = calldata;
+	struct nfs_page *req = data->req;
+	struct page *page = req->wb_page;
+	int status = data->task.tk_status;
+
+	if (status < 0)
 		SetPageError(page);
+
 	if (atomic_dec_and_test(&req->wb_complete)) {
 		if (!PageError(page))
 			SetPageUptodate(page);
 		nfs_readpage_release(req);
 	}
+	nfs_readdata_release(calldata);
 }
 
 static const struct rpc_call_ops nfs_read_partial_ops = {
 	.rpc_call_done = nfs_readpage_result_partial,
-	.rpc_release = nfs_readdata_release,
+	.rpc_release = nfs_readpage_release_partial,
 };
 
 static void nfs_readpage_set_pages_uptodate(struct nfs_read_data *data)
@@ -423,29 +430,35 @@ static void nfs_readpage_result_full(struct rpc_task *task, void *calldata)
 
 	if (nfs_readpage_result(task, data) != 0)
 		return;
+	if (task->tk_status < 0)
+		return;
 	/*
 	 * Note: nfs_readpage_retry may change the values of
 	 * data->args. In the multi-page case, we therefore need
 	 * to ensure that we call nfs_readpage_set_pages_uptodate()
 	 * first.
 	 */
-	if (likely(task->tk_status >= 0)) {
-		nfs_readpage_truncate_uninitialised_page(data);
-		nfs_readpage_set_pages_uptodate(data);
-		if (nfs_readpage_retry(task, data) != 0)
-			return;
-	}
+	nfs_readpage_truncate_uninitialised_page(data);
+	nfs_readpage_set_pages_uptodate(data);
+	nfs_readpage_retry(task, data);
+}
+
+static void nfs_readpage_release_full(void *calldata)
+{
+	struct nfs_read_data *data = calldata;
+
 	while (!list_empty(&data->pages)) {
 		struct nfs_page *req = nfs_list_entry(data->pages.next);
 
 		nfs_list_remove_request(req);
 		nfs_readpage_release(req);
 	}
+	nfs_readdata_release(calldata);
 }
 
 static const struct rpc_call_ops nfs_read_full_ops = {
 	.rpc_call_done = nfs_readpage_result_full,
-	.rpc_release = nfs_readdata_release,
+	.rpc_release = nfs_readpage_release_full,
 };
 
 /*

