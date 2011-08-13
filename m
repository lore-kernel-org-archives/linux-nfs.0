Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:39636 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752619Ab1HPNon (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Aug 2011 09:44:43 -0400
Received: by mail-pz0-f42.google.com with SMTP id 37so4658643pzk.1
        for <linux-nfs@vger.kernel.org>; Tue, 16 Aug 2011 06:44:43 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: benny@tonian.com
Cc: bharrosh@panasas.com, linux-nfs@vger.kernel.org,
        Peng Tao <peng_tao@emc.com>
Subject: [PATCH v2 2/3] pNFS: recoalesce when ld read pagelist fails
Date: Fri, 12 Aug 2011 18:00:12 -0700
Message-Id: <1313197213-1651-3-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1313197213-1651-1-git-send-email-bergwolf@gmail.com>
References: <1313197213-1651-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

For pnfs pagelist read failure, we need to pg_recoalesce and resend
IO to mds.

Signed-off-by: Peng Tao <peng_tao@emc.com>
---
 fs/nfs/pnfs.c |   20 +++++++-------------
 fs/nfs/pnfs.h |    2 +-
 fs/nfs/read.c |   13 ++++++++++++-
 3 files changed, 20 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index ad0579a..84ecd41 100644
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
index 0fb0a41..506f67c 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -201,7 +201,7 @@ void pnfs_cleanup_layoutcommit(struct nfs4_layoutcommit_data *data);
 int pnfs_layoutcommit_inode(struct inode *inode, bool sync);
 int _pnfs_return_layout(struct inode *);
 void pnfs_ld_write_done(struct nfs_write_data *);
-int pnfs_ld_read_done(struct nfs_read_data *);
+void pnfs_ld_read_done(struct nfs_read_data *);
 struct pnfs_layout_segment *pnfs_update_layout(struct inode *ino,
 					       struct nfs_open_context *ctx,
 					       loff_t pos,
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 2171c04..2a46aaa 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -541,13 +541,24 @@ static void nfs_readpage_result_full(struct rpc_task *task, void *calldata)
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
+		if (!data->pnfs_error) {
+			nfs_readpage_release(req);
+		} else {
+			nfs_pageio_add_request(&pgio, req);
+		}
 	}
+	if (data->pnfs_error)
+		nfs_pageio_complete(&pgio);
 	nfs_readdata_release(calldata);
 }
 
-- 
1.7.1.262.g5ef3d

