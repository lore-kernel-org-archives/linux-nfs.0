Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:35118 "EHLO
	mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753999AbcEOBG4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 14 May 2016 21:06:56 -0400
Received: by mail-qk0-f196.google.com with SMTP id n62so5069594qkc.2
        for <linux-nfs@vger.kernel.org>; Sat, 14 May 2016 18:06:55 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: Trond Myklebust <trondmy@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH v3 03/13] pNFS/flexfiles: When initing reads or writes, we might have to retry connecting to DSes
Date: Sat, 14 May 2016 21:06:32 -0400
Message-Id: <1463274402-17746-4-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1463274402-17746-1-git-send-email-jeff.layton@primarydata.com>
References: <1463274402-17746-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tom Haynes <loghyr@primarydata.com>

If we are initializing reads or writes and can not connect to a DS, then
check whether or not IO is allowed through the MDS. If it is allowed,
reset to the MDS. Else, fail the layout segment and force a retry
of a new layout segment.

Signed-off-by: Tom Haynes <loghyr@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 29 +++++++++++++++++++++++++----
 1 file changed, 25 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index f538ca6bbe81..f58cd2a14d5e 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -847,8 +847,13 @@ ff_layout_pg_init_read(struct nfs_pageio_descriptor *pgio,
 		goto out_mds;
 
 	ds = ff_layout_choose_best_ds_for_read(pgio->pg_lseg, 0, &ds_idx);
-	if (!ds)
-		goto out_mds;
+	if (!ds) {
+		if (ff_layout_no_fallback_to_mds(pgio->pg_lseg))
+			goto out_pnfs;
+		else
+			goto out_mds;
+	}
+
 	mirror = FF_LAYOUT_COMP(pgio->pg_lseg, ds_idx);
 
 	pgio->pg_mirror_idx = ds_idx;
@@ -862,6 +867,12 @@ out_mds:
 	pnfs_put_lseg(pgio->pg_lseg);
 	pgio->pg_lseg = NULL;
 	nfs_pageio_reset_read_mds(pgio);
+	return;
+
+out_pnfs:
+	pnfs_set_lo_fail(pgio->pg_lseg);
+	pnfs_put_lseg(pgio->pg_lseg);
+	pgio->pg_lseg = NULL;
 }
 
 static void
@@ -904,8 +915,12 @@ ff_layout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 
 	for (i = 0; i < pgio->pg_mirror_count; i++) {
 		ds = nfs4_ff_layout_prepare_ds(pgio->pg_lseg, i, true);
-		if (!ds)
-			goto out_mds;
+		if (!ds) {
+			if (ff_layout_no_fallback_to_mds(pgio->pg_lseg))
+				goto out_pnfs;
+			else
+				goto out_mds;
+		}
 		pgm = &pgio->pg_mirrors[i];
 		mirror = FF_LAYOUT_COMP(pgio->pg_lseg, i);
 		pgm->pg_bsize = mirror->mirror_ds->ds_versions[0].wsize;
@@ -917,6 +932,12 @@ out_mds:
 	pnfs_put_lseg(pgio->pg_lseg);
 	pgio->pg_lseg = NULL;
 	nfs_pageio_reset_write_mds(pgio);
+	return;
+
+out_pnfs:
+	pnfs_set_lo_fail(pgio->pg_lseg);
+	pnfs_put_lseg(pgio->pg_lseg);
+	pgio->pg_lseg = NULL;
 }
 
 static unsigned int
-- 
2.5.5

