Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:15949 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753184Ab1KJTiW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Nov 2011 14:38:22 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Revert pnfs ugliness from the generic NFS read code path
Date: Thu, 10 Nov 2011 14:38:16 -0500
Message-Id: <1320953896-20898-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

pNFS-specific code belongs in the pnfs layer. It should not be
hijacking generic NFS read or write code paths.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/internal.h |    2 ++
 fs/nfs/pnfs.c     |   26 +++++++++++++++++++++-----
 fs/nfs/read.c     |   14 ++------------
 3 files changed, 25 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index c1a1bd8..3f4d957 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -299,6 +299,8 @@ extern void nfs_read_prepare(struct rpc_task *task, void *calldata);
 extern int nfs_generic_pagein(struct nfs_pageio_descriptor *desc,
 		struct list_head *head);
 
+extern void nfs_pageio_init_read_mds(struct nfs_pageio_descriptor *pgio,
+		struct inode *inode);
 extern void nfs_pageio_reset_read_mds(struct nfs_pageio_descriptor *pgio);
 extern void nfs_readdata_release(struct nfs_read_data *rdata);
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index baf7353..8e672a2 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1260,6 +1260,25 @@ pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_pg_writepages);
 
+static void pnfs_ld_handle_read_error(struct nfs_read_data *data)
+{
+	struct nfs_pageio_descriptor pgio;
+
+	put_lseg(data->lseg);
+	data->lseg = NULL;
+	dprintk("pnfs write error = %d\n", data->pnfs_error);
+
+	nfs_pageio_init_read_mds(&pgio, data->inode);
+
+	while (!list_empty(&data->pages)) {
+		struct nfs_page *req = nfs_list_entry(data->pages.next);
+
+		nfs_list_remove_request(req);
+		nfs_pageio_add_request(&pgio, req);
+	}
+	nfs_pageio_complete(&pgio);
+}
+
 /*
  * Called by non rpc-based layout drivers
  */
@@ -1268,11 +1287,8 @@ void pnfs_ld_read_done(struct nfs_read_data *data)
 	if (likely(!data->pnfs_error)) {
 		__nfs4_read_done_cb(data);
 		data->mds_ops->rpc_call_done(&data->task, data);
-	} else {
-		put_lseg(data->lseg);
-		data->lseg = NULL;
-		dprintk("pnfs write error = %d\n", data->pnfs_error);
-	}
+	} else
+		pnfs_ld_handle_read_error(data);
 	data->mds_ops->rpc_release(data);
 }
 EXPORT_SYMBOL_GPL(pnfs_ld_read_done);
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 8b48ec6..cfa175c 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -109,7 +109,7 @@ static void nfs_readpage_truncate_uninitialised_page(struct nfs_read_data *data)
 	}
 }
 
-static void nfs_pageio_init_read_mds(struct nfs_pageio_descriptor *pgio,
+void nfs_pageio_init_read_mds(struct nfs_pageio_descriptor *pgio,
 		struct inode *inode)
 {
 	nfs_pageio_init(pgio, inode, &nfs_pageio_read_ops,
@@ -534,23 +534,13 @@ static void nfs_readpage_result_full(struct rpc_task *task, void *calldata)
 static void nfs_readpage_release_full(void *calldata)
 {
 	struct nfs_read_data *data = calldata;
-	struct nfs_pageio_descriptor pgio;
 
-	if (data->pnfs_error) {
-		nfs_pageio_init_read_mds(&pgio, data->inode);
-		pgio.pg_recoalesce = 1;
-	}
 	while (!list_empty(&data->pages)) {
 		struct nfs_page *req = nfs_list_entry(data->pages.next);
 
 		nfs_list_remove_request(req);
-		if (!data->pnfs_error)
-			nfs_readpage_release(req);
-		else
-			nfs_pageio_add_request(&pgio, req);
+		nfs_readpage_release(req);
 	}
-	if (data->pnfs_error)
-		nfs_pageio_complete(&pgio);
 	nfs_readdata_release(calldata);
 }
 
-- 
1.7.7

