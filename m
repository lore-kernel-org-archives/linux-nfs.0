Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f177.google.com ([209.85.213.177]:44063 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752024AbaGOOVY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2014 10:21:24 -0400
Subject: [PATCH v3 08/21] xprtrdma: Back off rkey when FAST_REG_MR fails
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 15 Jul 2014 10:21:21 -0400
Message-ID: <20140715142121.8908.39182.stgit@manet.1015granger.net>
In-Reply-To: <20140715142020.8908.80969.stgit@manet.1015granger.net>
References: <20140715142020.8908.80969.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If posting a FAST_REG_MR Work Reqeust fails, revert the rkey update
to avoid subsequent IB_WC_MW_BIND_ERR completions.

Suggested-by: Steve Wise <swise@opengridcomputing.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/rdma/ib_verbs.h     |   11 +++++++++++
 net/sunrpc/xprtrdma/verbs.c |   12 +++++-------
 2 files changed, 16 insertions(+), 7 deletions(-)

diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index 7ccef34..c5c7ec6 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -2479,6 +2479,17 @@ static inline u32 ib_inc_rkey(u32 rkey)
 }
 
 /**
+ * ib_dec_rkey - decrements the key portion of the given rkey. Can be used
+ * when recovering from a local immediate error.
+ * @rkey - the rkey to decrement.
+ */
+static inline u32 ib_dec_rkey(u32 rkey)
+{
+	const u32 mask = 0x000000ff;
+	return ((rkey - 1) & mask) | (rkey & ~mask);
+}
+
+/**
  * ib_alloc_mw - Allocates a memory window.
  * @pd: The protection domain associated with the memory window.
  * @type: The type of the memory window (1 or 2).
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 8bb7945..394b13f 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1497,13 +1497,12 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 	struct rpcrdma_frmr *frmr = &mw->r.frmr;
 	struct ib_mr *mr = frmr->fr_mr;
 	struct ib_send_wr invalidate_wr, frmr_wr, *bad_wr, *post_wr;
-
-	u8 key;
 	int len, pageoff;
 	int i, rc;
 	int seg_len;
 	u64 pa;
 	int page_no;
+	u32 rkey;
 
 	pageoff = offset_in_page(seg1->mr_offset);
 	seg1->mr_offset -= pageoff;	/* start of page */
@@ -1558,14 +1557,11 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 		rc = -EIO;
 		goto out_err;
 	}
-
-	/* Bump the key */
-	key = (u8)(mr->rkey & 0x000000FF);
-	ib_update_fast_reg_key(mr, ++key);
-
 	frmr_wr.wr.fast_reg.access_flags = (writing ?
 				IB_ACCESS_REMOTE_WRITE | IB_ACCESS_LOCAL_WRITE :
 				IB_ACCESS_REMOTE_READ);
+	rkey = ib_inc_rkey(mr->rkey);
+	ib_update_fast_reg_key(mr, rkey);
 	frmr_wr.wr.fast_reg.rkey = mr->rkey;
 	DECR_CQCOUNT(&r_xprt->rx_ep);
 
@@ -1574,6 +1570,8 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 	if (rc) {
 		dprintk("RPC:       %s: failed ib_post_send for register,"
 			" status %i\n", __func__, rc);
+		rkey = ib_dec_rkey(mr->rkey);
+		ib_update_fast_reg_key(mr, rkey);
 		goto out_err;
 	} else {
 		seg1->mr_rkey = mr->rkey;

