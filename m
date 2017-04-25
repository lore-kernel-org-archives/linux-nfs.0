Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:33439 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1953563AbdDYUes (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Apr 2017 16:34:48 -0400
Received: by mail-it0-f66.google.com with SMTP id z67so23065320itb.0
        for <linux-nfs@vger.kernel.org>; Tue, 25 Apr 2017 13:34:48 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] pNFS: Ensure we check layout segment validity in the pg_init() callback
Date: Tue, 25 Apr 2017 16:34:42 -0400
Message-Id: <20170425203443.37006-2-trond.myklebust@primarydata.com>
In-Reply-To: <20170425203443.37006-1-trond.myklebust@primarydata.com>
References: <20170425203443.37006-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we have a layout segment cached in pgio->pg_lseg, we should check it
for validity before reusing it in a new RPC request. Otherwise, if we
recoalesce, we can end up looping forever.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/filelayout/filelayout.c         |  2 ++
 fs/nfs/flexfilelayout/flexfilelayout.c |  2 ++
 fs/nfs/pnfs.c                          | 13 +++++++++++++
 fs/nfs/pnfs.h                          |  1 +
 4 files changed, 18 insertions(+)

diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index acd30baca461..d4174da89302 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -933,6 +933,7 @@ static void
 filelayout_pg_init_read(struct nfs_pageio_descriptor *pgio,
 			struct nfs_page *req)
 {
+	pnfs_generic_pg_check_layout(pgio);
 	if (!pgio->pg_lseg) {
 		pgio->pg_lseg = fl_pnfs_update_layout(pgio->pg_inode,
 						      req->wb_context,
@@ -959,6 +960,7 @@ filelayout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 	struct nfs_commit_info cinfo;
 	int status;
 
+	pnfs_generic_pg_check_layout(pgio);
 	if (!pgio->pg_lseg) {
 		pgio->pg_lseg = fl_pnfs_update_layout(pgio->pg_inode,
 						      req->wb_context,
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 42dedf2d625f..f23b63eb356e 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -846,6 +846,7 @@ ff_layout_pg_init_read(struct nfs_pageio_descriptor *pgio,
 	int ds_idx;
 
 retry:
+	pnfs_generic_pg_check_layout(pgio);
 	/* Use full layout for now */
 	if (!pgio->pg_lseg)
 		ff_layout_pg_get_read(pgio, req, false);
@@ -894,6 +895,7 @@ ff_layout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 	int status;
 
 retry:
+	pnfs_generic_pg_check_layout(pgio);
 	if (!pgio->pg_lseg) {
 		pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
 						   req->wb_context,
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 3917a6272789..634adb3f8524 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2073,10 +2073,22 @@ void pnfs_error_mark_layout_for_return(struct inode *inode,
 EXPORT_SYMBOL_GPL(pnfs_error_mark_layout_for_return);
 
 void
+pnfs_generic_pg_check_layout(struct nfs_pageio_descriptor *pgio)
+{
+	if (pgio->pg_lseg == NULL ||
+	    test_bit(NFS_LSEG_VALID, &pgio->pg_lseg->pls_flags))
+		return;
+	pnfs_put_lseg(pgio->pg_lseg);
+	pgio->pg_lseg = NULL;
+}
+EXPORT_SYMBOL_GPL(pnfs_generic_pg_check_layout);
+
+void
 pnfs_generic_pg_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
 {
 	u64 rd_size = req->wb_bytes;
 
+	pnfs_generic_pg_check_layout(pgio);
 	if (pgio->pg_lseg == NULL) {
 		if (pgio->pg_dreq == NULL)
 			rd_size = i_size_read(pgio->pg_inode) - req_offset(req);
@@ -2107,6 +2119,7 @@ void
 pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio,
 			   struct nfs_page *req, u64 wb_size)
 {
+	pnfs_generic_pg_check_layout(pgio);
 	if (pgio->pg_lseg == NULL) {
 		pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
 						   req->wb_context,
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 825a1b8ddc4f..2d05b756a8d6 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -234,6 +234,7 @@ void pnfs_put_lseg_locked(struct pnfs_layout_segment *lseg);
 
 void set_pnfs_layoutdriver(struct nfs_server *, const struct nfs_fh *, struct nfs_fsinfo *);
 void unset_pnfs_layoutdriver(struct nfs_server *);
+void pnfs_generic_pg_check_layout(struct nfs_pageio_descriptor *pgio);
 void pnfs_generic_pg_init_read(struct nfs_pageio_descriptor *, struct nfs_page *);
 int pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc);
 void pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio,
-- 
2.9.3

