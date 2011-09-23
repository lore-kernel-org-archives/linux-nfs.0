Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:32842 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754742Ab1IWBu3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2011 21:50:29 -0400
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 07/10] pnfs: recoalesce when ld write pagelist fails
Date: Thu, 22 Sep 2011 21:50:14 -0400
Message-Id: <1316742617-14766-8-git-send-email-rees@umich.edu>
In-Reply-To: <1316742617-14766-1-git-send-email-rees@umich.edu>
References: <1316742617-14766-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Peng Tao <bergwolf@gmail.com>

For pnfs pagelist write failure, we need to pg_recoalesce and resend IO to
mds.

Signed-off-by: Peng Tao <peng_tao@emc.com>
Signed-off-by: Jim Rees <rees@umich.edu>
---
 fs/nfs/pnfs.c  |   20 +++++++-------------
 fs/nfs/pnfs.h  |    2 +-
 fs/nfs/write.c |   25 ++++++++++++++++++++++++-
 3 files changed, 32 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 6b19fff..a205c8e 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1168,23 +1168,17 @@ EXPORT_SYMBOL_GPL(pnfs_generic_pg_test);
 /*
  * Called by non rpc-based layout drivers
  */
-int
-pnfs_ld_write_done(struct nfs_write_data *data)
+void pnfs_ld_write_done(struct nfs_write_data *data)
 {
-	int status;
-
-	if (!data->pnfs_error) {
+	if (likely(!data->pnfs_error)) {
 		pnfs_set_layoutcommit(data);
 		data->mds_ops->rpc_call_done(&data->task, data);
-		data->mds_ops->rpc_release(data);
-		return 0;
+	} else {
+		put_lseg(data->lseg);
+		data->lseg = NULL;
+		dprintk("pnfs write error = %d\n", data->pnfs_error);
 	}
-
-	dprintk("%s: pnfs_error=%d, retry via MDS\n", __func__,
-		data->pnfs_error);
-	status = nfs_initiate_write(data, NFS_CLIENT(data->inode),
-				    data->mds_ops, NFS_FILE_SYNC);
-	return status ? : -EAGAIN;
+	data->mds_ops->rpc_release(data);
 }
 EXPORT_SYMBOL_GPL(pnfs_ld_write_done);
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 94e760e..71c23d4 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -201,7 +201,7 @@ void pnfs_set_layoutcommit(struct nfs_write_data *wdata);
 void pnfs_cleanup_layoutcommit(struct nfs4_layoutcommit_data *data);
 int pnfs_layoutcommit_inode(struct inode *inode, bool sync);
 int _pnfs_return_layout(struct inode *);
-int pnfs_ld_write_done(struct nfs_write_data *);
+void pnfs_ld_write_done(struct nfs_write_data *);
 int pnfs_ld_read_done(struct nfs_read_data *);
 struct pnfs_layout_segment *pnfs_update_layout(struct inode *ino,
 					       struct nfs_open_context *ctx,
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index c9bd2a6..62eb5c5 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1165,7 +1165,13 @@ static void nfs_writeback_done_full(struct rpc_task *task, void *calldata)
 static void nfs_writeback_release_full(void *calldata)
 {
 	struct nfs_write_data	*data = calldata;
-	int status = data->task.tk_status;
+	int ret, status = data->task.tk_status;
+	struct nfs_pageio_descriptor pgio;
+
+	if (data->pnfs_error) {
+		nfs_pageio_init_write_mds(&pgio, data->inode, FLUSH_STABLE);
+		pgio.pg_recoalesce = 1;
+	}
 
 	/* Update attributes as result of writeback. */
 	while (!list_empty(&data->pages)) {
@@ -1181,6 +1187,11 @@ static void nfs_writeback_release_full(void *calldata)
 			req->wb_bytes,
 			(long long)req_offset(req));
 
+		if (data->pnfs_error) {
+			dprintk(", pnfs error = %d\n", data->pnfs_error);
+			goto next;
+		}
+
 		if (status < 0) {
 			nfs_set_pageerror(page);
 			nfs_context_set_write_error(req->wb_context, status);
@@ -1200,7 +1211,19 @@ remove_request:
 	next:
 		nfs_clear_page_tag_locked(req);
 		nfs_end_page_writeback(page);
+		if (data->pnfs_error) {
+			lock_page(page);
+			nfs_pageio_cond_complete(&pgio, page->index);
+			ret = nfs_page_async_flush(&pgio, page, 0);
+			if (ret) {
+				nfs_set_pageerror(page);
+				dprintk("rewrite to MDS error = %d\n", ret);
+			}
+			unlock_page(page);
+		}
 	}
+	if (data->pnfs_error)
+		nfs_pageio_complete(&pgio);
 	nfs_writedata_release(calldata);
 }
 
-- 
1.7.4.1

