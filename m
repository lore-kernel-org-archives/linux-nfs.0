Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:34025 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964931AbdAGRQs (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 7 Jan 2017 12:16:48 -0500
Subject: [PATCH v1 11/22] svcrdma: Clean up RDMA_ERROR path
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Sat, 07 Jan 2017 12:16:46 -0500
Message-ID: <20170107171646.14126.35690.stgit@klimt.1015granger.net>
In-Reply-To: <20170107170258.14126.8503.stgit@klimt.1015granger.net>
References: <20170107170258.14126.8503.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that svc_rdma_sendto has been renovated, svc_rdma_send_error can
be refactored to reduce code duplication and remove C structure-
based XDR encoding.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/rpc_rdma.h         |    3 ++
 include/linux/sunrpc/svc_rdma.h         |   11 +++---
 net/sunrpc/xprtrdma/svc_rdma_marshal.c  |   31 ++++++++++--------
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |    2 +
 net/sunrpc/xprtrdma/svc_rdma_sendto.c   |   54 ++++++++++---------------------
 5 files changed, 45 insertions(+), 56 deletions(-)

diff --git a/include/linux/sunrpc/rpc_rdma.h b/include/linux/sunrpc/rpc_rdma.h
index 245fc59..b7e85b3 100644
--- a/include/linux/sunrpc/rpc_rdma.h
+++ b/include/linux/sunrpc/rpc_rdma.h
@@ -143,6 +143,9 @@ enum rpcrdma_proc {
 #define rdma_done	cpu_to_be32(RDMA_DONE)
 #define rdma_error	cpu_to_be32(RDMA_ERROR)
 
+#define err_vers	cpu_to_be32(ERR_VERS)
+#define err_chunk	cpu_to_be32(ERR_CHUNK)
+
 /*
  * Private extension to RPC-over-RDMA Version One.
  * Message passed during RDMA-CM connection set-up.
diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index ea7867a..65c2425 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -211,9 +211,10 @@ extern int svc_rdma_handle_bc_reply(struct rpc_xprt *xprt,
 
 /* svc_rdma_marshal.c */
 extern int svc_rdma_xdr_decode_req(struct xdr_buf *);
-extern int svc_rdma_xdr_encode_error(struct svcxprt_rdma *,
-				     struct rpcrdma_msg *,
-				     enum rpcrdma_errcode, __be32 *);
+extern unsigned int svc_rdma_xdr_encode_error(struct svcxprt_rdma *rdma,
+					      __be32 *rdma_argp,
+					      __be32 *rdma_resp,
+					      __be32 errcode);
 extern void svc_rdma_xdr_encode_write_list(__be32 *rdma_resp, __be32 *wr_ch,
 					   unsigned int consumed);
 extern void svc_rdma_xdr_encode_reply_chunk(__be32 *rdma_resp, __be32 *rp_ch,
@@ -252,8 +253,8 @@ extern int svc_rdma_map_reply_hdr(struct svcxprt_rdma *rdma,
 extern void svc_rdma_build_send_wr(struct svc_rdma_op_ctxt *ctxt,
 				   int num_sge);
 extern int svc_rdma_sendto(struct svc_rqst *);
-extern void svc_rdma_send_error(struct svcxprt_rdma *, struct rpcrdma_msg *,
-				int);
+extern void svc_rdma_send_error(struct svcxprt_rdma *rdma, __be32 *rdma_argp,
+				int status);
 
 /* svc_rdma_transport.c */
 extern void svc_rdma_wc_send(struct ib_cq *, struct ib_wc *);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_marshal.c b/net/sunrpc/xprtrdma/svc_rdma_marshal.c
index 6ba2fb6..87cb8fd 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_marshal.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_marshal.c
@@ -167,23 +167,26 @@ int svc_rdma_xdr_decode_req(struct xdr_buf *rq_arg)
 	return -EINVAL;
 }
 
-int svc_rdma_xdr_encode_error(struct svcxprt_rdma *xprt,
-			      struct rpcrdma_msg *rmsgp,
-			      enum rpcrdma_errcode err, __be32 *va)
+unsigned int svc_rdma_xdr_encode_error(struct svcxprt_rdma *rdma,
+				       __be32 *rdma_argp, __be32 *rdma_resp,
+				       __be32 errcode)
 {
-	__be32 *startp = va;
-
-	*va++ = rmsgp->rm_xid;
-	*va++ = rmsgp->rm_vers;
-	*va++ = xprt->sc_fc_credits;
-	*va++ = rdma_error;
-	*va++ = cpu_to_be32(err);
-	if (err == ERR_VERS) {
-		*va++ = rpcrdma_version;
-		*va++ = rpcrdma_version;
+	__be32 *p;
+
+	p = rdma_resp;
+
+	*p++ = *rdma_argp;		/* XID */
+	*p++ = *(rdma_argp + 1);	/* vers */
+	*p++ = rdma->sc_fc_credits;
+	*p++ = rdma_error;
+
+	*p++ = errcode;
+	if (errcode == err_vers) {
+		*p++ = rpcrdma_version;
+		*p = rpcrdma_version;
 	}
 
-	return (int)((unsigned long)va - (unsigned long)startp);
+	return (unsigned long)p - (unsigned long)rdma_resp;
 }
 
 /**
diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index 776e1ed..f1b5bbf 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -688,7 +688,7 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
 	return ret;
 
 out_err:
-	svc_rdma_send_error(rdma_xprt, rmsgp, ret);
+	svc_rdma_send_error(rdma_xprt, (__be32 *)rmsgp, ret);
 	svc_rdma_put_context(ctxt, 0);
 	return 0;
 
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 5e75187..de54e97 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -487,60 +487,42 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
 	return -ENOTCONN;
 }
 
-void svc_rdma_send_error(struct svcxprt_rdma *xprt, struct rpcrdma_msg *rmsgp,
+void svc_rdma_send_error(struct svcxprt_rdma *xprt, __be32 *rdma_argp,
 			 int status)
 {
-	struct ib_send_wr err_wr;
-	struct page *p;
 	struct svc_rdma_op_ctxt *ctxt;
-	enum rpcrdma_errcode err;
-	__be32 *va;
-	int length;
+	unsigned int length;
+	struct page *page;
+	__be32 *err_msgp;
+	__be32 errcode;
 	int ret;
 
 	ret = svc_rdma_repost_recv(xprt, GFP_KERNEL);
 	if (ret)
 		return;
 
-	p = alloc_page(GFP_KERNEL);
-	if (!p)
+	page = alloc_page(GFP_KERNEL);
+	if (!page)
 		return;
-	va = page_address(p);
+	err_msgp = page_address(page);
 
 	/* XDR encode an error reply */
-	err = ERR_CHUNK;
+	errcode = err_chunk;
 	if (status == -EPROTONOSUPPORT)
-		err = ERR_VERS;
-	length = svc_rdma_xdr_encode_error(xprt, rmsgp, err, va);
+		errcode = err_vers;
+	length = svc_rdma_xdr_encode_error(xprt, rdma_argp, err_msgp, errcode);
 
+	/* Map transport header; no RPC message payload */
 	ctxt = svc_rdma_get_context(xprt);
-	ctxt->direction = DMA_TO_DEVICE;
-	ctxt->count = 1;
-	ctxt->pages[0] = p;
-
-	/* Prepare SGE for local address */
-	ctxt->sge[0].lkey = xprt->sc_pd->local_dma_lkey;
-	ctxt->sge[0].length = length;
-	ctxt->sge[0].addr = ib_dma_map_page(xprt->sc_cm_id->device,
-					    p, 0, length, DMA_TO_DEVICE);
-	if (ib_dma_mapping_error(xprt->sc_cm_id->device, ctxt->sge[0].addr)) {
-		dprintk("svcrdma: Error mapping buffer for protocol error\n");
-		svc_rdma_put_context(ctxt, 1);
+	ret = svc_rdma_map_reply_hdr(xprt, ctxt, err_msgp, length);
+	if (ret) {
+		dprintk("svcrdma: Error %d mapping send for protocol error\n",
+			ret);
 		return;
 	}
-	svc_rdma_count_mappings(xprt, ctxt);
 
-	/* Prepare SEND WR */
-	memset(&err_wr, 0, sizeof(err_wr));
-	ctxt->cqe.done = svc_rdma_wc_send;
-	err_wr.wr_cqe = &ctxt->cqe;
-	err_wr.sg_list = ctxt->sge;
-	err_wr.num_sge = 1;
-	err_wr.opcode = IB_WR_SEND;
-	err_wr.send_flags = IB_SEND_SIGNALED;
-
-	/* Post It */
-	ret = svc_rdma_send(xprt, &err_wr);
+	svc_rdma_build_send_wr(ctxt, 1);
+	ret = svc_rdma_send(xprt, &ctxt->send_wr);
 	if (ret) {
 		dprintk("svcrdma: Error %d posting send for protocol error\n",
 			ret);

