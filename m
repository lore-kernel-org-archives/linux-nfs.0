Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:37188 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754770Ab1IWBua (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2011 21:50:30 -0400
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 08/10] pnfs: recoalesce when ld read pagelist fails
Date: Thu, 22 Sep 2011 21:50:15 -0400
Message-Id: <1316742617-14766-9-git-send-email-rees@umich.edu>
In-Reply-To: <1316742617-14766-1-git-send-email-rees@umich.edu>
References: <1316742617-14766-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Peng Tao <bergwolf@gmail.com>

For pnfs pagelist read failure, we need to pg_recoalesce and resend IO to
mds.

Signed-off-by: Peng Tao <peng_tao@emc.com>
Signed-off-by: Jim Rees <rees@umich.edu>
---
 fs/nfs/pnfs.c |   20 +++++++-------------
 fs/nfs/pnfs.h |    2 +-
 fs/nfs/read.c |   12 +++++++++++-
 3 files changed, 19 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index a205c8e..ee73d9a 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1262,23 +1262,17 @@ EXPORT_SYMBOL_GPL(pnfs_generic_pg_writepages);
 /*
  * Called by non rpc-based layout drivers
  */
-int
-pnfs_ld_read_done(struct nfs_read_data *data)
+void pnfs_ld_read_done(struct nfs_read_data *data)
 {
-	int status;
-
-	if (!data->pnfs_error) {
+	if (likely(!data->pnfs_error)) {
 		__nfs4_read_done_cb(data);
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
-	status = nfs_initiate_read(data, NFS_CLIENT(data->inode),
-				   data->mds_ops);
-	return status ? : -EAGAIN;
+	data->mds_ops->rpc_release(data);
 }
 EXPORT_SYMBOL_GPL(pnfs_ld_read_done);
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 71c23d4..1509530 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -202,7 +202,7 @@ void pnfs_cleanup_layoutcommit(struct nfs4_layoutcommit_data *data);
 int pnfs_layoutcommit_inode(struct inode *inode, bool sync);
 int _pnfs_return_layout(struct inode *);
 void pnfs_ld_write_done(struct nfs_write_data *);
-int pnfs_ld_read_done(struct nfs_read_data *);
+void pnfs_ld_read_done(struct nfs_read_data *);
 struct pnfs_layout_segment *pnfs_update_layout(struct inode *ino,
 					       struct nfs_open_context *ctx,
 					       loff_t pos,
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 2171c04..bfc20b1 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -541,13 +541,23 @@ static void nfs_readpage_result_full(struct rpc_task *task, void *calldata)
 static void nfs_readpage_release_full(void *calldata)
 {
 	struct nfs_read_data *data = calldata;
+	struct nfs_pageio_descriptor pgio;
 
+	if (data->pnfs_error) {
+		nfs_pageio_init_read_mds(&pgio, data->inode);
+		pgio.pg_recoalesce = 1;
+	}
 	while (!list_empty(&data->pages)) {
 		struct nfs_page *req = nfs_list_entry(data->pages.next);
 
 		nfs_list_remove_request(req);
-		nfs_readpage_release(req);
+		if (!data->pnfs_error)
+			nfs_readpage_release(req);
+		else
+			nfs_pageio_add_request(&pgio, req);
 	}
+	if (data->pnfs_error)
+		nfs_pageio_complete(&pgio);
 	nfs_readdata_release(calldata);
 }
 
-- 
1.7.4.1

