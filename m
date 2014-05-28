Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f174.google.com ([209.85.213.174]:35917 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753954AbaE1OfI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 May 2014 10:35:08 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v5 23/24] xprtrdma: Remove BUG_ON() call sites
To: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Cc: Anna.Schumaker@netapp.com
Date: Wed, 28 May 2014 10:35:06 -0400
Message-ID: <20140528143506.23214.66588.stgit@manet.1015granger.net>
In-Reply-To: <20140528142521.23214.39655.stgit@manet.1015granger.net>
References: <20140528142521.23214.39655.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If an error occurs in the marshaling logic, fail the RPC request
being processed, but leave the client running.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtrdma/transport.c |    3 ++-
 net/sunrpc/xprtrdma/verbs.c     |   18 ++++++++++--------
 2 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 187894b..93fe775 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -463,7 +463,8 @@ xprt_rdma_allocate(struct rpc_task *task, size_t size)
 	struct rpcrdma_req *req, *nreq;
 
 	req = rpcrdma_buffer_get(&rpcx_to_rdmax(xprt)->rx_buf);
-	BUG_ON(NULL == req);
+	if (req == NULL)
+		return NULL;
 
 	if (size > req->rl_size) {
 		dprintk("RPC:       %s: size %zd too large for buffer[%zd]: "
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 515dfc1..13dbd1c 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1302,7 +1302,6 @@ rpcrdma_buffer_put(struct rpcrdma_req *req)
 	int i;
 	unsigned long flags;
 
-	BUG_ON(req->rl_nchunks != 0);
 	spin_lock_irqsave(&buffers->rb_lock, flags);
 	buffers->rb_send_bufs[--buffers->rb_send_index] = req;
 	req->rl_niovs = 0;
@@ -1535,10 +1534,6 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 	} else
 		post_wr = &frmr_wr;
 
-	/* Bump the key */
-	key = (u8)(seg1->mr_chunk.rl_mw->r.frmr.fr_mr->rkey & 0x000000FF);
-	ib_update_fast_reg_key(seg1->mr_chunk.rl_mw->r.frmr.fr_mr, ++key);
-
 	/* Prepare FRMR WR */
 	memset(&frmr_wr, 0, sizeof frmr_wr);
 	frmr_wr.wr_id = (unsigned long)(void *)seg1->mr_chunk.rl_mw;
@@ -1549,7 +1544,16 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 	frmr_wr.wr.fast_reg.page_list_len = page_no;
 	frmr_wr.wr.fast_reg.page_shift = PAGE_SHIFT;
 	frmr_wr.wr.fast_reg.length = page_no << PAGE_SHIFT;
-	BUG_ON(frmr_wr.wr.fast_reg.length < len);
+	if (frmr_wr.wr.fast_reg.length < len) {
+		while (seg1->mr_nsegs--)
+			rpcrdma_unmap_one(ia, seg++);
+		return -EIO;
+	}
+
+	/* Bump the key */
+	key = (u8)(seg1->mr_chunk.rl_mw->r.frmr.fr_mr->rkey & 0x000000FF);
+	ib_update_fast_reg_key(seg1->mr_chunk.rl_mw->r.frmr.fr_mr, ++key);
+
 	frmr_wr.wr.fast_reg.access_flags = (writing ?
 				IB_ACCESS_REMOTE_WRITE | IB_ACCESS_LOCAL_WRITE :
 				IB_ACCESS_REMOTE_READ);
@@ -1709,9 +1713,7 @@ rpcrdma_deregister_external(struct rpcrdma_mr_seg *seg,
 
 #if RPCRDMA_PERSISTENT_REGISTRATION
 	case RPCRDMA_ALLPHYSICAL:
-		BUG_ON(nsegs != 1);
 		rpcrdma_unmap_one(ia, seg);
-		rc = 0;
 		break;
 #endif
 

