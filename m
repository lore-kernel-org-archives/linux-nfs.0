Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34774 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752230AbdDIRGL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 9 Apr 2017 13:06:11 -0400
Subject: [PATCH v3 05/14] svcrdma: Clean up svc_rdma_get_inv_rkey()
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Sun, 09 Apr 2017 13:06:08 -0400
Message-ID: <20170409170608.15073.36554.stgit@klimt.1015granger.net>
In-Reply-To: <20170409163820.15073.43257.stgit@klimt.1015granger.net>
References: <20170409163820.15073.43257.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace C structure-based XDR decoding with more portable code that
instead uses pointer arithmetic.

This is a refactoring change only.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_sendto.c |   39 ++++++++++++++-------------------
 1 file changed, 17 insertions(+), 22 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 2798f3e..2eb3df6 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -189,32 +189,25 @@ static void svc_rdma_get_write_arrays(struct rpcrdma_msg *rmsgp,
  * Invalidate, and responder chooses one rkey to invalidate.
  *
  * Find a candidate rkey to invalidate when sending a reply.  Picks the
- * first rkey it finds in the chunks lists.
+ * first R_key it finds in the chunk lists.
  *
  * Returns zero if RPC's chunk lists are empty.
  */
-static u32 svc_rdma_get_inv_rkey(struct rpcrdma_msg *rdma_argp,
-				 struct rpcrdma_write_array *wr_ary,
-				 struct rpcrdma_write_array *rp_ary)
+static u32 svc_rdma_get_inv_rkey(__be32 *rdma_argp,
+				 __be32 *wr_lst, __be32 *rp_ch)
 {
-	struct rpcrdma_read_chunk *rd_ary;
-	struct rpcrdma_segment *arg_ch;
-
-	rd_ary = (struct rpcrdma_read_chunk *)&rdma_argp->rm_body.rm_chunks[0];
-	if (rd_ary->rc_discrim != xdr_zero)
-		return be32_to_cpu(rd_ary->rc_target.rs_handle);
-
-	if (wr_ary && be32_to_cpu(wr_ary->wc_nchunks)) {
-		arg_ch = &wr_ary->wc_array[0].wc_target;
-		return be32_to_cpu(arg_ch->rs_handle);
-	}
-
-	if (rp_ary && be32_to_cpu(rp_ary->wc_nchunks)) {
-		arg_ch = &rp_ary->wc_array[0].wc_target;
-		return be32_to_cpu(arg_ch->rs_handle);
-	}
+	__be32 *p;
 
-	return 0;
+	p = rdma_argp + rpcrdma_fixed_maxsz;
+	if (*p != xdr_zero)
+		p += 2;
+	else if (wr_lst && be32_to_cpup(wr_lst + 1))
+		p = wr_lst + 2;
+	else if (rp_ch && be32_to_cpup(rp_ch + 1))
+		p = rp_ch + 2;
+	else
+		return 0;
+	return be32_to_cpup(p);
 }
 
 static int svc_rdma_dma_map_page(struct svcxprt_rdma *rdma,
@@ -650,7 +643,9 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
 
 	inv_rkey = 0;
 	if (rdma->sc_snd_w_inv)
-		inv_rkey = svc_rdma_get_inv_rkey(rdma_argp, wr_ary, rp_ary);
+		inv_rkey = svc_rdma_get_inv_rkey(&rdma_argp->rm_xid,
+						 (__be32 *)wr_ary,
+						 (__be32 *)rp_ary);
 
 	/* Build an req vec for the XDR */
 	vec = svc_rdma_get_req_map(rdma);

