Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:37660 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751933AbdHCSap (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Aug 2017 14:30:45 -0400
Received: by mail-io0-f194.google.com with SMTP id c74so1814506iod.4
        for <linux-nfs@vger.kernel.org>; Thu, 03 Aug 2017 11:30:45 -0700 (PDT)
Subject: [PATCH v1 6/7] xprtrdma: Remove rpcrdma_rep::rr_len
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 03 Aug 2017 14:30:44 -0400
Message-ID: <20170803183044.14672.18047.stgit@manet.1015granger.net>
In-Reply-To: <20170803182623.14672.77636.stgit@manet.1015granger.net>
References: <20170803182623.14672.77636.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This field is no longer used outside the Receive completion handler.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c  |    2 +-
 net/sunrpc/xprtrdma/verbs.c     |   11 ++++-------
 net/sunrpc/xprtrdma/xprt_rdma.h |    3 ---
 3 files changed, 5 insertions(+), 11 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index e422c0f..6219861 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -1178,7 +1178,7 @@ static int decode_reply_chunk(struct xdr_stream *xdr, u32 *length)
 
 	dprintk("RPC:       %s: incoming rep %p\n", __func__, rep);
 
-	if (rep->rr_len == RPCRDMA_BAD_LEN)
+	if (rep->rr_hdrbuf.head[0].iov_len == 0)
 		goto out_badstatus;
 
 	xdr_init_decode(xdr, &rep->rr_hdrbuf,
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 74dbba8..5d36c06 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -143,9 +143,6 @@
 	struct rpcrdma_buffer *buffer = &rep->rr_rxprt->rx_buf;
 	u32 credits;
 
-	if (rep->rr_len < RPCRDMA_HDRLEN_ERR)
-		return;
-
 	credits = be32_to_cpu(rmsgp->rm_credit);
 	if (credits == 0)
 		credits = 1;	/* don't deadlock */
@@ -176,16 +173,16 @@
 	dprintk("RPC:       %s: rep %p opcode 'recv', length %u: success\n",
 		__func__, rep, wc->byte_len);
 
-	rep->rr_len = wc->byte_len;
 	rpcrdma_set_xdrlen(&rep->rr_hdrbuf, wc->byte_len);
 	rep->rr_wc_flags = wc->wc_flags;
 	rep->rr_inv_rkey = wc->ex.invalidate_rkey;
 
 	ib_dma_sync_single_for_cpu(rdmab_device(rep->rr_rdmabuf),
 				   rdmab_addr(rep->rr_rdmabuf),
-				   rep->rr_len, DMA_FROM_DEVICE);
+				   wc->byte_len, DMA_FROM_DEVICE);
 
-	rpcrdma_update_granted_credits(rep);
+	if (wc->byte_len >= RPCRDMA_HDRLEN_ERR)
+		rpcrdma_update_granted_credits(rep);
 
 out_schedule:
 	queue_work(rpcrdma_receive_wq, &rep->rr_work);
@@ -196,7 +193,7 @@
 		pr_err("rpcrdma: Recv: %s (%u/0x%x)\n",
 		       ib_wc_status_msg(wc->status),
 		       wc->status, wc->vendor_err);
-	rep->rr_len = RPCRDMA_BAD_LEN;
+	rpcrdma_set_xdrlen(&rep->rr_hdrbuf, 0);
 	goto out_schedule;
 }
 
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 13556ae..d4a897a 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -218,7 +218,6 @@ enum {
 
 struct rpcrdma_rep {
 	struct ib_cqe		rr_cqe;
-	unsigned int		rr_len;
 	int			rr_wc_flags;
 	u32			rr_inv_rkey;
 	struct rpcrdma_xprt	*rr_rxprt;
@@ -230,8 +229,6 @@ struct rpcrdma_rep {
 	struct rpcrdma_regbuf	*rr_rdmabuf;
 };
 
-#define RPCRDMA_BAD_LEN		(~0U)
-
 /*
  * struct rpcrdma_mw - external memory region metadata
  *

