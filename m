Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f169.google.com ([209.85.223.169]:50274 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750931AbaFWWjL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jun 2014 18:39:11 -0400
Subject: [PATCH v1 01/13] xprtrdma: Fix panic in
 rpcrdma_register_frmr_external()
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 23 Jun 2014 18:39:09 -0400
Message-ID: <20140623223909.1634.33362.stgit@manet.1015granger.net>
In-Reply-To: <20140623223201.1634.83888.stgit@manet.1015granger.net>
References: <20140623223201.1634.83888.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

seg1->mr_nsegs is not yet initialized when it is used to unmap
segments during an error exit. Use the same unmapping logic for
all error exits.

"if (frmr_wr.wr.fast_reg.length < len) {" used to be a BUG_ON check.
The broken code should never be executed under normal operation.

Fixes: c977dea22708688eae31774f70126c97aa4dfe83
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |   12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 13dbd1c..78bd7c6 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1545,9 +1545,8 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 	frmr_wr.wr.fast_reg.page_shift = PAGE_SHIFT;
 	frmr_wr.wr.fast_reg.length = page_no << PAGE_SHIFT;
 	if (frmr_wr.wr.fast_reg.length < len) {
-		while (seg1->mr_nsegs--)
-			rpcrdma_unmap_one(ia, seg++);
-		return -EIO;
+		rc = -EIO;
+		goto out_err;
 	}
 
 	/* Bump the key */
@@ -1565,8 +1564,7 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 	if (rc) {
 		dprintk("RPC:       %s: failed ib_post_send for register,"
 			" status %i\n", __func__, rc);
-		while (i--)
-			rpcrdma_unmap_one(ia, --seg);
+		goto out_err;
 	} else {
 		seg1->mr_rkey = seg1->mr_chunk.rl_mw->r.frmr.fr_mr->rkey;
 		seg1->mr_base = seg1->mr_dma + pageoff;
@@ -1574,6 +1572,10 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 		seg1->mr_len = len;
 	}
 	*nsegs = i;
+	return 0;
+out_err:
+	while (i--)
+		rpcrdma_unmap_one(ia, --seg);
 	return rc;
 }
 

