Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35820 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755860AbcFTQZk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jun 2016 12:25:40 -0400
Subject: [PATCH v3 20/25] xprtrdma: Update only specific fields in private
 receive buffer
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 20 Jun 2016 12:11:19 -0400
Message-ID: <20160620161118.10809.42331.stgit@manet.1015granger.net>
In-Reply-To: <20160620155751.10809.22262.stgit@manet.1015granger.net>
References: <20160620155751.10809.22262.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that rpcrdma_inline_fixup() updates only two fields in
rq_rcv_buf, a full memcpy of that structure to rq_private_buf is
unwarranted. Updating rq_private_buf fields only where needed also
better documents what is going on.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c |   13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index d018eb7..a0e811d 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -750,6 +750,11 @@ rpcrdma_count_chunks(struct rpcrdma_rep *rep, int wrchunk, __be32 **iptrp)
  * The upper layer has set the maximum number of bytes it can
  * receive in each component of rq_rcv_buf. These values are set in
  * the head.iov_len, page_len, tail.iov_len, and buflen fields.
+ *
+ * Unlike the TCP equivalent (xdr_partial_copy_from_skb), in
+ * many cases this function simply updates iov_base pointers in
+ * rq_rcv_buf to point directly to the received reply data, to
+ * avoid copying reply data.
  */
 static void
 rpcrdma_inline_fixup(struct rpc_rqst *rqst, char *srcp, int copy_len, int pad)
@@ -763,6 +768,7 @@ rpcrdma_inline_fixup(struct rpc_rqst *rqst, char *srcp, int copy_len, int pad)
 	 * in the receive buffer, to avoid a memcopy.
 	 */
 	rqst->rq_rcv_buf.head[0].iov_base = srcp;
+	rqst->rq_private_buf.head[0].iov_base = srcp;
 
 	/* The contents of the receive buffer that follow
 	 * head.iov_len bytes are copied into the page list.
@@ -822,16 +828,15 @@ rpcrdma_inline_fixup(struct rpc_rqst *rqst, char *srcp, int copy_len, int pad)
 	/* The tail iovec is redirected to the remaining data
 	 * in the receive buffer, to avoid a memcopy.
 	 */
-	if (copy_len || pad)
+	if (copy_len || pad) {
 		rqst->rq_rcv_buf.tail[0].iov_base = srcp;
+		rqst->rq_private_buf.tail[0].iov_base = srcp;
+	}
 
 	if (copy_len)
 		dprintk("RPC:       %s: %d bytes in"
 			" %d extra segments (%d lost)\n",
 			__func__, olen, i, copy_len);
-
-	/* TBD avoid a warning from call_decode() */
-	rqst->rq_private_buf = rqst->rq_rcv_buf;
 }
 
 void

