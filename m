Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f176.google.com ([209.85.223.176]:62600 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932329AbaDXSQD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Apr 2014 14:16:03 -0400
Received: by mail-ie0-f176.google.com with SMTP id rd18so2679361iec.7
        for <linux-nfs@vger.kernel.org>; Thu, 24 Apr 2014 11:16:03 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 17/18 v2] pnfs: filelayout: support non page aligned layouts
Date: Thu, 24 Apr 2014 14:15:27 -0400
Message-Id: <1398363328-7100-18-git-send-email-dros@primarydata.com>
In-Reply-To: <1398363328-7100-1-git-send-email-dros@primarydata.com>
References: <1398363328-7100-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use the new pg_test interface to adjust requests to fit in the current
stripe / segment.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/nfs4filelayout.c | 50 ++++++++++++++++++-------------------------------
 1 file changed, 18 insertions(+), 32 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 0ebc521..9419061 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -639,7 +639,6 @@ filelayout_check_layout(struct pnfs_layout_hdr *lo,
 	struct nfs4_deviceid_node *d;
 	struct nfs4_file_layout_dsaddr *dsaddr;
 	int status = -EINVAL;
-	struct nfs_server *nfss = NFS_SERVER(lo->plh_inode);
 
 	dprintk("--> %s\n", __func__);
 
@@ -657,7 +656,7 @@ filelayout_check_layout(struct pnfs_layout_hdr *lo,
 		goto out;
 	}
 
-	if (!fl->stripe_unit || fl->stripe_unit % PAGE_SIZE) {
+	if (!fl->stripe_unit) {
 		dprintk("%s Invalid stripe unit (%u)\n",
 			__func__, fl->stripe_unit);
 		goto out;
@@ -694,12 +693,6 @@ filelayout_check_layout(struct pnfs_layout_hdr *lo,
 		goto out_put;
 	}
 
-	if (fl->stripe_unit % nfss->rsize || fl->stripe_unit % nfss->wsize) {
-		dprintk("%s Stripe unit (%u) not aligned with rsize %u "
-			"wsize %u\n", __func__, fl->stripe_unit, nfss->rsize,
-			nfss->wsize);
-	}
-
 	status = 0;
 out:
 	dprintk("--> %s returns %d\n", __func__, status);
@@ -936,44 +929,40 @@ filelayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 {
 	unsigned int size;
 	u64 p_stripe, r_stripe;
-	u32 stripe_unit;
+	u32 stripe_offset;
+	u64 segment_offset = pgio->pg_lseg->pls_range.offset;
+	u32 stripe_unit = FILELAYOUT_LSEG(pgio->pg_lseg)->stripe_unit;
 
 	/* calls nfs_generic_pg_test */
 	size = pnfs_generic_pg_test(pgio, prev, req);
 	if (!size)
 		return 0;
 
+	/* see if req and prev are in the same stripe */
 	if (prev) {
-		p_stripe = (u64)req_offset(prev);
-		r_stripe = (u64)req_offset(req);
-		stripe_unit = FILELAYOUT_LSEG(pgio->pg_lseg)->stripe_unit;
-
+		p_stripe = (u64)req_offset(prev) - segment_offset;
+		r_stripe = (u64)req_offset(req) - segment_offset;
 		do_div(p_stripe, stripe_unit);
 		do_div(r_stripe, stripe_unit);
 
 		if (p_stripe != r_stripe)
 			return 0;
 	}
-	return min(size, req->wb_bytes);
+
+	/* calculate remaining bytes in the current stripe */
+	stripe_offset = ((u64)req_offset(req) - segment_offset) % stripe_unit;
+	WARN_ON_ONCE(stripe_offset > stripe_unit);
+	if (stripe_offset >= stripe_unit)
+		return 0;
+	return min(stripe_unit - (unsigned int)stripe_offset, size);
 }
 
 static void
 filelayout_pg_init_read(struct nfs_pageio_descriptor *pgio,
 			struct nfs_page *req)
 {
-	WARN_ON_ONCE(pgio->pg_lseg != NULL);
-
-	if (req->wb_offset != req->wb_pgbase) {
-		/*
-		 * Handling unaligned pages is difficult, because have to
-		 * somehow split a req in two in certain cases in the
-		 * pg.test code.  Avoid this by just not using pnfs
-		 * in this case.
-		 */
-		nfs_pageio_reset_read_mds(pgio);
-		return;
-	}
-	pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
+	if (!pgio->pg_lseg)
+		pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
 					   req->wb_context,
 					   0,
 					   NFS4_MAX_UINT64,
@@ -991,11 +980,8 @@ filelayout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 	struct nfs_commit_info cinfo;
 	int status;
 
-	WARN_ON_ONCE(pgio->pg_lseg != NULL);
-
-	if (req->wb_offset != req->wb_pgbase)
-		goto out_mds;
-	pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
+	if (!pgio->pg_lseg)
+		pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
 					   req->wb_context,
 					   0,
 					   NFS4_MAX_UINT64,
-- 
1.8.5.2 (Apple Git-48)

