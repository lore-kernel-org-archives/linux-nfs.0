Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:33613 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751691AbcH2TYA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Aug 2016 15:24:00 -0400
Received: by mail-it0-f66.google.com with SMTP id n75so68059ith.0
        for <linux-nfs@vger.kernel.org>; Mon, 29 Aug 2016 12:24:00 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] pNFS/flexfiles: Fix an Oopsable condition when connection to the DS fails
Date: Mon, 29 Aug 2016 15:23:26 -0400
Message-Id: <1472498606-29926-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the attempt to connect to a DS fails inside ff_layout_pg_init_read or
ff_layout_pg_init_write, then we currently end up clearing the layout
segment carried by the struct nfs_pageio_descriptor, causing an Oops
when we later call into ff_layout_read_pagelist/ff_layout_write_pagelist.

The fix is to ensure we return the layout and then retry.

Fixes: 446ca2195303 ("pNFS/flexfiles: When initing reads or writes, we...")
Cc: stable@vger.kernel.org # v4.7+
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c    | 37 +++++++++++++++----------------
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 19 ++++++++--------
 2 files changed, 28 insertions(+), 28 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index d07e5abd07df..598f03ebb396 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -829,11 +829,14 @@ ff_layout_choose_best_ds_for_read(struct pnfs_layout_segment *lseg,
 {
 	struct nfs4_ff_layout_segment *fls = FF_LAYOUT_LSEG(lseg);
 	struct nfs4_pnfs_ds *ds;
+	bool fail_return = false;
 	int idx;
 
 	/* mirrors are sorted by efficiency */
 	for (idx = start_idx; idx < fls->mirror_array_cnt; idx++) {
-		ds = nfs4_ff_layout_prepare_ds(lseg, idx, false);
+		if (idx+1 == fls->mirror_array_cnt)
+			fail_return = true;
+		ds = nfs4_ff_layout_prepare_ds(lseg, idx, fail_return);
 		if (ds) {
 			*best_idx = idx;
 			return ds;
@@ -882,6 +885,7 @@ ff_layout_pg_init_read(struct nfs_pageio_descriptor *pgio,
 	struct nfs4_pnfs_ds *ds;
 	int ds_idx;
 
+retry:
 	/* Use full layout for now */
 	if (!pgio->pg_lseg)
 		ff_layout_pg_get_read(pgio, req, false);
@@ -894,10 +898,13 @@ ff_layout_pg_init_read(struct nfs_pageio_descriptor *pgio,
 
 	ds = ff_layout_choose_best_ds_for_read(pgio->pg_lseg, 0, &ds_idx);
 	if (!ds) {
-		if (ff_layout_no_fallback_to_mds(pgio->pg_lseg))
-			goto out_pnfs;
-		else
+		if (!ff_layout_no_fallback_to_mds(pgio->pg_lseg))
 			goto out_mds;
+		pnfs_put_lseg(pgio->pg_lseg);
+		pgio->pg_lseg = NULL;
+		/* Sleep for 1 second before retrying */
+		ssleep(1);
+		goto retry;
 	}
 
 	mirror = FF_LAYOUT_COMP(pgio->pg_lseg, ds_idx);
@@ -913,12 +920,6 @@ out_mds:
 	pnfs_put_lseg(pgio->pg_lseg);
 	pgio->pg_lseg = NULL;
 	nfs_pageio_reset_read_mds(pgio);
-	return;
-
-out_pnfs:
-	pnfs_set_lo_fail(pgio->pg_lseg);
-	pnfs_put_lseg(pgio->pg_lseg);
-	pgio->pg_lseg = NULL;
 }
 
 static void
@@ -932,6 +933,7 @@ ff_layout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 	int i;
 	int status;
 
+retry:
 	if (!pgio->pg_lseg) {
 		pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
 						   req->wb_context,
@@ -963,10 +965,13 @@ ff_layout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 	for (i = 0; i < pgio->pg_mirror_count; i++) {
 		ds = nfs4_ff_layout_prepare_ds(pgio->pg_lseg, i, true);
 		if (!ds) {
-			if (ff_layout_no_fallback_to_mds(pgio->pg_lseg))
-				goto out_pnfs;
-			else
+			if (!ff_layout_no_fallback_to_mds(pgio->pg_lseg))
 				goto out_mds;
+			pnfs_put_lseg(pgio->pg_lseg);
+			pgio->pg_lseg = NULL;
+			/* Sleep for 1 second before retrying */
+			ssleep(1);
+			goto retry;
 		}
 		pgm = &pgio->pg_mirrors[i];
 		mirror = FF_LAYOUT_COMP(pgio->pg_lseg, i);
@@ -979,12 +984,6 @@ out_mds:
 	pnfs_put_lseg(pgio->pg_lseg);
 	pgio->pg_lseg = NULL;
 	nfs_pageio_reset_write_mds(pgio);
-	return;
-
-out_pnfs:
-	pnfs_set_lo_fail(pgio->pg_lseg);
-	pnfs_put_lseg(pgio->pg_lseg);
-	pgio->pg_lseg = NULL;
 }
 
 static unsigned int
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 2dd3ead08973..360b0ff2cd75 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -418,7 +418,7 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx,
 
 	devid = &mirror->mirror_ds->id_node;
 	if (ff_layout_test_devid_unavailable(devid))
-		goto out;
+		goto out_fail;
 
 	ds = mirror->mirror_ds->ds;
 	/* matching smp_wmb() in _nfs4_pnfs_v3/4_ds_connect */
@@ -453,15 +453,16 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx,
 			mirror->mirror_ds->ds_versions[0].rsize = max_payload;
 		if (mirror->mirror_ds->ds_versions[0].wsize > max_payload)
 			mirror->mirror_ds->ds_versions[0].wsize = max_payload;
-	} else {
-		ff_layout_track_ds_error(FF_LAYOUT_FROM_HDR(lseg->pls_layout),
-					 mirror, lseg->pls_range.offset,
-					 lseg->pls_range.length, NFS4ERR_NXIO,
-					 OP_ILLEGAL, GFP_NOIO);
-		if (fail_return || !ff_layout_has_available_ds(lseg))
-			pnfs_error_mark_layout_for_return(ino, lseg);
-		ds = NULL;
+		goto out;
 	}
+	ff_layout_track_ds_error(FF_LAYOUT_FROM_HDR(lseg->pls_layout),
+				 mirror, lseg->pls_range.offset,
+				 lseg->pls_range.length, NFS4ERR_NXIO,
+				 OP_ILLEGAL, GFP_NOIO);
+out_fail:
+	if (fail_return || !ff_layout_has_available_ds(lseg))
+		pnfs_error_mark_layout_for_return(ino, lseg);
+	ds = NULL;
 out:
 	return ds;
 }
-- 
2.7.4

