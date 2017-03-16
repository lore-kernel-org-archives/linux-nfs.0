Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:32999 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754987AbdCPPyO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Mar 2017 11:54:14 -0400
Subject: [PATCH v1 13/14] svcrdma: Clean out old XDR encoders
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 16 Mar 2017 11:54:11 -0400
Message-ID: <20170316155411.4482.37224.stgit@klimt.1015granger.net>
In-Reply-To: <20170316154132.4482.56769.stgit@klimt.1015granger.net>
References: <20170316154132.4482.56769.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: These have been replaced and are no longer used.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc_rdma.h        |    5 ----
 net/sunrpc/xprtrdma/svc_rdma_marshal.c |   39 --------------------------------
 2 files changed, 44 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 7b1f886..f88f6b0 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -187,11 +187,6 @@ extern int svc_rdma_handle_bc_reply(struct rpc_xprt *xprt,
 
 /* svc_rdma_marshal.c */
 extern int svc_rdma_xdr_decode_req(struct xdr_buf *);
-extern void svc_rdma_old_encode_write_list(struct rpcrdma_msg *rmsgp,
-					   int chunks);
-extern void svc_rdma_xdr_encode_reply_array(struct rpcrdma_write_array *, int);
-extern void svc_rdma_xdr_encode_array_chunk(struct rpcrdma_write_array *, int,
-					    __be32, __be64, u32);
 extern void svc_rdma_xdr_encode_write_list(__be32 *rdma_resp, __be32 *wr_ch,
 					   unsigned int consumed);
 extern void svc_rdma_xdr_encode_reply_chunk(__be32 *rdma_resp, __be32 *rp_ch,
diff --git a/net/sunrpc/xprtrdma/svc_rdma_marshal.c b/net/sunrpc/xprtrdma/svc_rdma_marshal.c
index 24a8151..658337e 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_marshal.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_marshal.c
@@ -198,45 +198,6 @@ unsigned int svc_rdma_xdr_get_reply_hdr_len(__be32 *rdma_resp)
 	return (unsigned long)p - (unsigned long)rdma_resp;
 }
 
-void svc_rdma_old_encode_write_list(struct rpcrdma_msg *rmsgp, int chunks)
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
-
 /* One Write chunk is copied from Call transport header to Reply
  * transport header. Each segment's length field is updated to
  * reflect number of bytes consumed in the segment.

