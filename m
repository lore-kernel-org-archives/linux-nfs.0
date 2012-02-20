Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([209.198.142.2]:41270 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751574Ab2BTTH6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Feb 2012 14:07:58 -0500
From: Tom Tucker <tom@ogc.us>
Subject: [PATCH] xprtrdma: Remove assumption that each segment is <= PAGE_SIZE
To: trond.myklebust@netapp.com
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Date: Mon, 20 Feb 2012 13:07:57 -0600
Message-ID: <20120220190757.8014.81176.stgit@build.ogc.int>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The xprtrdma FRMR mapping logic assumes that a segment is <= PAGE_SIZE.
This is not true for NFS4.

Signed-off-by: Tom Tucker <tom@ogc.us>
---

 net/sunrpc/xprtrdma/verbs.c |   17 ++++++++++++-----
 1 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 28236ba..745973b 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1490,6 +1490,9 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 	u8 key;
 	int len, pageoff;
 	int i, rc;
+	int seg_len;
+	u64 pa;
+	int page_no;
 
 	pageoff = offset_in_page(seg1->mr_offset);
 	seg1->mr_offset -= pageoff;	/* start of page */
@@ -1497,11 +1500,15 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 	len = -pageoff;
 	if (*nsegs > RPCRDMA_MAX_DATA_SEGS)
 		*nsegs = RPCRDMA_MAX_DATA_SEGS;
-	for (i = 0; i < *nsegs;) {
+	for (page_no = i = 0; i < *nsegs;) {
 		rpcrdma_map_one(ia, seg, writing);
-		seg1->mr_chunk.rl_mw->r.frmr.fr_pgl->page_list[i] = seg->mr_dma;
+		pa = seg->mr_dma;
+		for (seg_len = seg->mr_len; seg_len > 0; seg_len -= PAGE_SIZE) {
+			seg1->mr_chunk.rl_mw->r.frmr.fr_pgl->
+				page_list[page_no++] = pa;
+			pa += PAGE_SIZE;
+		}
 		len += seg->mr_len;
-		BUG_ON(seg->mr_len > PAGE_SIZE);
 		++seg;
 		++i;
 		/* Check for holes */
@@ -1540,9 +1547,9 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 	frmr_wr.send_flags = IB_SEND_SIGNALED;
 	frmr_wr.wr.fast_reg.iova_start = seg1->mr_dma;
 	frmr_wr.wr.fast_reg.page_list = seg1->mr_chunk.rl_mw->r.frmr.fr_pgl;
-	frmr_wr.wr.fast_reg.page_list_len = i;
+	frmr_wr.wr.fast_reg.page_list_len = page_no;
 	frmr_wr.wr.fast_reg.page_shift = PAGE_SHIFT;
-	frmr_wr.wr.fast_reg.length = i << PAGE_SHIFT;
+	frmr_wr.wr.fast_reg.length = page_no << PAGE_SHIFT;
 	BUG_ON(frmr_wr.wr.fast_reg.length < len);
 	frmr_wr.wr.fast_reg.access_flags = (writing ?
 				IB_ACCESS_REMOTE_WRITE | IB_ACCESS_LOCAL_WRITE :

