Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:36400 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751124AbdC0NuH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Mar 2017 09:50:07 -0400
Subject: [PATCH v2 13/13] svcrdma: Clean out old XDR encoders
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 27 Mar 2017 09:49:40 -0400
Message-ID: <20170327134940.5585.19495.stgit@klimt.1015granger.net>
In-Reply-To: <20170327132329.5585.98465.stgit@klimt.1015granger.net>
References: <20170327132329.5585.98465.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: These have been replaced and are no longer used.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Sagi Grimberg <sagi@grimberg.me>
---
 include/linux/sunrpc/svc_rdma.h        |    4 --
 net/sunrpc/xprtrdma/svc_rdma_marshal.c |   70 --------------------------------
 2 files changed, 74 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 326703e..3ff4209 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -187,10 +187,6 @@ extern int svc_rdma_handle_bc_reply(struct rpc_xprt *xprt,
 
 /* svc_rdma_marshal.c */
 extern int svc_rdma_xdr_decode_req(struct xdr_buf *);
-extern void svc_rdma_xdr_encode_reply_array(struct rpcrdma_write_array *, int);
-extern void svc_rdma_xdr_encode_array_chunk(struct rpcrdma_write_array *, int,
-					    __be32, __be64, u32);
-extern unsigned int svc_rdma_xdr_get_reply_hdr_len(__be32 *rdma_resp);
 
 /* svc_rdma_recvfrom.c */
 extern int svc_rdma_recvfrom(struct svc_rqst *);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_marshal.c b/net/sunrpc/xprtrdma/svc_rdma_marshal.c
index ae58a89..bdcf7d8 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_marshal.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_marshal.c
@@ -166,73 +166,3 @@ int svc_rdma_xdr_decode_req(struct xdr_buf *rq_arg)
 	dprintk("svcrdma: failed to parse transport header\n");
 	return -EINVAL;
 }
-
-/**
- * svc_rdma_xdr_get_reply_hdr_length - Get length of Reply transport header
- * @rdma_resp: buffer containing Reply transport header
- *
- * Returns length of transport header, in bytes.
- */
-unsigned int svc_rdma_xdr_get_reply_hdr_len(__be32 *rdma_resp)
-{
-	unsigned int nsegs;
-	__be32 *p;
-
-	p = rdma_resp;
-
-	/* RPC-over-RDMA V1 replies never have a Read list. */
-	p += rpcrdma_fixed_maxsz + 1;
-
-	/* Skip Write list. */
-	while (*p++ != xdr_zero) {
-		nsegs = be32_to_cpup(p++);
-		p += nsegs * rpcrdma_segment_maxsz;
-	}
-
-	/* Skip Reply chunk. */
-	if (*p++ != xdr_zero) {
-		nsegs = be32_to_cpup(p++);
-		p += nsegs * rpcrdma_segment_maxsz;
-	}
-
-	return (unsigned long)p - (unsigned long)rdma_resp;
-}
-
-void svc_rdma_xdr_encode_write_list(struct rpcrdma_msg *rmsgp, int chunks)
-{
-	struct rpcrdma_write_array *ary;
-
-	/* no read-list */
-	rmsgp->rm_body.rm_chunks[0] = xdr_zero;
-
-	/* write-array discrim */
-	ary = (struct rpcrdma_write_array *)
-		&rmsgp->rm_body.rm_chunks[1];
-	ary->wc_discrim = xdr_one;
-	ary->wc_nchunks = cpu_to_be32(chunks);
-
-	/* write-list terminator */
-	ary->wc_array[chunks].wc_target.rs_handle = xdr_zero;
-
-	/* reply-array discriminator */
-	ary->wc_array[chunks].wc_target.rs_length = xdr_zero;
-}
-
-void svc_rdma_xdr_encode_reply_array(struct rpcrdma_write_array *ary,
-				 int chunks)
-{
-	ary->wc_discrim = xdr_one;
-	ary->wc_nchunks = cpu_to_be32(chunks);
-}
-
-void svc_rdma_xdr_encode_array_chunk(struct rpcrdma_write_array *ary,
-				     int chunk_no,
-				     __be32 rs_handle,
-				     __be64 rs_offset,
-				     u32 write_len)
-{
-	struct rpcrdma_segment *seg = &ary->wc_array[chunk_no].wc_target;
-	seg->rs_handle = rs_handle;
-	seg->rs_offset = rs_offset;
-	seg->rs_length = cpu_to_be32(write_len);
-}

