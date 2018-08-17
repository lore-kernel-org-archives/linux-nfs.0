Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:50678 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726377AbeHQRfG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Aug 2018 13:35:06 -0400
Received: by mail-it0-f65.google.com with SMTP id j81-v6so11514634ite.0
        for <linux-nfs@vger.kernel.org>; Fri, 17 Aug 2018 07:31:31 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] pNFS/flexfiles: ff_layout_pg_init_read should exit on error
Date: Fri, 17 Aug 2018 10:31:08 -0400
Message-Id: <20180817143108.6504-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

If we get an error while retrieving the layout, then we should
report it rather than falling back to I/O through the MDS.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 28 ++++++++++----------------
 1 file changed, 11 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 280b6b060d53..cae43333ef16 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -812,7 +812,6 @@ ff_layout_pg_get_read(struct nfs_pageio_descriptor *pgio,
 		      struct nfs_page *req,
 		      bool strict_iomode)
 {
-retry_strict:
 	pnfs_put_lseg(pgio->pg_lseg);
 	pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
 					   req->wb_context,
@@ -825,16 +824,6 @@ ff_layout_pg_get_read(struct nfs_pageio_descriptor *pgio,
 		pgio->pg_error = PTR_ERR(pgio->pg_lseg);
 		pgio->pg_lseg = NULL;
 	}
-
-	/* If we don't have checking, do get a IOMODE_RW
-	 * segment, and the server wants to avoid READs
-	 * there, then retry!
-	 */
-	if (pgio->pg_lseg && !strict_iomode &&
-	    ff_layout_avoid_read_on_rw(pgio->pg_lseg)) {
-		strict_iomode = true;
-		goto retry_strict;
-	}
 }
 
 static void
@@ -849,14 +838,16 @@ ff_layout_pg_init_read(struct nfs_pageio_descriptor *pgio,
 retry:
 	pnfs_generic_pg_check_layout(pgio);
 	/* Use full layout for now */
-	if (!pgio->pg_lseg)
+	if (!pgio->pg_lseg) {
 		ff_layout_pg_get_read(pgio, req, false);
-	else if (ff_layout_avoid_read_on_rw(pgio->pg_lseg))
+		if (!pgio->pg_lseg)
+			goto out_nolseg;
+	}
+	if (ff_layout_avoid_read_on_rw(pgio->pg_lseg)) {
 		ff_layout_pg_get_read(pgio, req, true);
-
-	/* If no lseg, fall back to read through mds */
-	if (pgio->pg_lseg == NULL)
-		goto out_mds;
+		if (!pgio->pg_lseg)
+			goto out_nolseg;
+	}
 
 	ds = ff_layout_choose_best_ds_for_read(pgio->pg_lseg, 0, &ds_idx);
 	if (!ds) {
@@ -878,6 +869,9 @@ ff_layout_pg_init_read(struct nfs_pageio_descriptor *pgio,
 	pgm->pg_bsize = mirror->mirror_ds->ds_versions[0].rsize;
 
 	return;
+out_nolseg:
+	if (pgio->pg_error < 0)
+		return;
 out_mds:
 	pnfs_put_lseg(pgio->pg_lseg);
 	pgio->pg_lseg = NULL;
-- 
2.17.1
