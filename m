Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:13901 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757273Ab2DIUxN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Apr 2012 16:53:13 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 25/26] NFS: move allocation of nfs4_fl_commit_info to write's pg_init
Date: Mon,  9 Apr 2012 16:52:23 -0400
Message-Id: <1334004744-31842-26-git-send-email-iisaman@netapp.com>
In-Reply-To: <1334004744-31842-1-git-send-email-iisaman@netapp.com>
References: <1334004744-31842-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This allows directio to have private copies of the commit_info,
instead of relying on a global layout-wide one, just like for the
inode itself.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4filelayout.c |   87 ++++++++++++++++++++++++++++++-----------------
 1 files changed, 56 insertions(+), 31 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 96a6141..9bbc798 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -691,6 +691,52 @@ filelayout_free_lseg(struct pnfs_layout_segment *lseg)
 	_filelayout_free_lseg(fl);
 }
 
+static int
+filelayout_alloc_commit_info(struct pnfs_layout_segment *lseg,
+			     struct nfs_commit_info *cinfo,
+			     gfp_t gfp_flags)
+{
+	struct nfs4_filelayout_segment *fl = FILELAYOUT_LSEG(lseg);
+	struct pnfs_commit_bucket *buckets;
+	int size;
+
+	/* This assumes there is only one IOMODE_RW lseg.  What
+	 * we really want to do is have a layout_hdr level
+	 * dictionary of <multipath_list4, fh> keys, each
+	 * associated with a struct list_head, populated by calls
+	 * to filelayout_write_pagelist().
+	 * */
+	if (fl->commit_through_mds)
+		return 0;
+	if (cinfo->ds->nbuckets != 0)
+		return 0;
+
+	size = (fl->stripe_type == STRIPE_SPARSE) ?
+		fl->dsaddr->ds_num : fl->dsaddr->stripe_count;
+
+	buckets = kcalloc(size, sizeof(struct pnfs_commit_bucket),
+			  gfp_flags);
+	if (!buckets)
+		return -ENOMEM;
+	else {
+		int i;
+
+		spin_lock(cinfo->lock);
+		if (cinfo->ds->nbuckets != 0)
+			kfree(buckets);
+		else {
+			cinfo->ds->buckets = buckets;
+			cinfo->ds->nbuckets = size;
+			for (i = 0; i < size; i++) {
+				INIT_LIST_HEAD(&buckets[i].written);
+				INIT_LIST_HEAD(&buckets[i].committing);
+			}
+		}
+		spin_unlock(cinfo->lock);
+		return 0;
+	}
+}
+
 static struct pnfs_layout_segment *
 filelayout_alloc_lseg(struct pnfs_layout_hdr *layoutid,
 		      struct nfs4_layoutget_res *lgr,
@@ -710,37 +756,6 @@ filelayout_alloc_lseg(struct pnfs_layout_hdr *layoutid,
 		_filelayout_free_lseg(fl);
 		return NULL;
 	}
-
-	/* This assumes there is only one IOMODE_RW lseg.  What
-	 * we really want to do is have a layout_hdr level
-	 * dictionary of <multipath_list4, fh> keys, each
-	 * associated with a struct list_head, populated by calls
-	 * to filelayout_write_pagelist().
-	 * */
-	if ((!fl->commit_through_mds) && (lgr->range.iomode == IOMODE_RW)) {
-		struct nfs4_filelayout *flo = FILELAYOUT_FROM_HDR(layoutid);
-		int i;
-		int size = (fl->stripe_type == STRIPE_SPARSE) ?
-			fl->dsaddr->ds_num : fl->dsaddr->stripe_count;
-
-		if (flo->commit_info.nbuckets != 0) {
-			/* Shouldn't happen if only one IOMODE_RW lseg */
-			filelayout_free_lseg(&fl->generic_hdr);
-			return NULL;
-		}
-		flo->commit_info.buckets = kcalloc(size,
-						   sizeof(struct pnfs_commit_bucket),
-						   gfp_flags);
-		if (!flo->commit_info.buckets) {
-			filelayout_free_lseg(&fl->generic_hdr);
-			return NULL;
-		}
-		flo->commit_info.nbuckets = size;
-		for (i = 0; i < size; i++) {
-			INIT_LIST_HEAD(&flo->commit_info.buckets[i].written);
-			INIT_LIST_HEAD(&flo->commit_info.buckets[i].committing);
-		}
-	}
 	return &fl->generic_hdr;
 }
 
@@ -802,6 +817,9 @@ static void
 filelayout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 			 struct nfs_page *req)
 {
+	struct nfs_commit_info cinfo;
+	int status;
+
 	BUG_ON(pgio->pg_lseg != NULL);
 
 	if (req->wb_offset != req->wb_pgbase)
@@ -815,6 +833,13 @@ filelayout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 	/* If no lseg, fall back to write through mds */
 	if (pgio->pg_lseg == NULL)
 		goto out_mds;
+	nfs_init_cinfo(&cinfo, pgio->pg_inode, pgio->pg_dreq);
+	status = filelayout_alloc_commit_info(pgio->pg_lseg, &cinfo, GFP_NOFS);
+	if (status < 0) {
+		put_lseg(pgio->pg_lseg);
+		pgio->pg_lseg = NULL;
+		goto out_mds;
+	}
 	return;
 out_mds:
 	nfs_pageio_reset_write_mds(pgio);
-- 
1.7.2.1

