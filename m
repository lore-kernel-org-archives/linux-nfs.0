Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35762 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753439AbdCPPxZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Mar 2017 11:53:25 -0400
Subject: [PATCH v1 07/14] svcrdma: Clean up RDMA_ERROR path
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 16 Mar 2017 11:53:23 -0400
Message-ID: <20170316155323.4482.8051.stgit@klimt.1015granger.net>
In-Reply-To: <20170316154132.4482.56769.stgit@klimt.1015granger.net>
References: <20170316154132.4482.56769.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that svc_rdma_sendto has been renovated, svc_rdma_send_error can
be refactored to reduce code duplication and remove C structure-
based XDR encoding. It is also relocated to the source file that
contains its only caller.

This is a refactoring change only.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/rpc_rdma.h         |    3 ++
 include/linux/sunrpc/svc_rdma.h         |    5 ---
 net/sunrpc/xprtrdma/svc_rdma_marshal.c  |   19 -----------
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |   53 ++++++++++++++++++++++++++++++-
 net/sunrpc/xprtrdma/svc_rdma_sendto.c   |   44 --------------------------
 5 files changed, 55 insertions(+), 69 deletions(-)

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
index 5fc9f6e..498a086 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -209,9 +209,6 @@ extern int svc_rdma_handle_bc_reply(struct rpc_xprt *xprt,
 
 /* svc_rdma_marshal.c */
 extern int svc_rdma_xdr_decode_req(struct xdr_buf *);
-extern int svc_rdma_xdr_encode_error(struct svcxprt_rdma *,
-				     struct rpcrdma_msg *,
-				     enum rpcrdma_errcode, __be32 *);
 extern void svc_rdma_old_encode_write_list(struct rpcrdma_msg *rmsgp,
 					   int chunks);
 extern void svc_rdma_xdr_encode_reply_array(struct rpcrdma_write_array *, int);
@@ -253,8 +250,6 @@ extern int svc_rdma_map_reply_hdr(struct svcxprt_rdma *rdma,
 extern void svc_rdma_build_send_wr(struct svc_rdma_op_ctxt *ctxt,
 				   int num_sge);
 extern int svc_rdma_sendto(struct svc_rqst *);
-extern void svc_rdma_send_error(struct svcxprt_rdma *, struct rpcrdma_msg *,
-				int);
 
 /* svc_rdma_transport.c */
 extern void svc_rdma_wc_send(struct ib_cq *, struct ib_wc *);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_marshal.c b/net/sunrpc/xprtrdma/svc_rdma_marshal.c
index bf3ca7e..24a8151 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_marshal.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_marshal.c
@@ -167,25 +167,6 @@ int svc_rdma_xdr_decode_req(struct xdr_buf *rq_arg)
 	return -EINVAL;
 }
 
-int svc_rdma_xdr_encode_error(struct svcxprt_rdma *xprt,
-			      struct rpcrdma_msg *rmsgp,
-			      enum rpcrdma_errcode err, __be32 *va)
-{
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
-	}
-
-	return (int)((unsigned long)va - (unsigned long)startp);
-}
-
 /**
  * svc_rdma_xdr_get_reply_hdr_length - Get length of Reply transport header
  * @rdma_resp: buffer containing Reply transport header
diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index f7b2daf..efa9f12 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -558,6 +558,57 @@ static void rdma_read_complete(struct svc_rqst *rqstp,
 	rqstp->rq_arg.buflen = head->arg.buflen;
 }
 
+static void svc_rdma_send_error(struct svcxprt_rdma *xprt,
+				__be32 *rdma_argp, int status)
+{
+	struct svc_rdma_op_ctxt *ctxt;
+	__be32 *p, *err_msgp;
+	unsigned int length;
+	struct page *page;
+	int ret;
+
+	ret = svc_rdma_repost_recv(xprt, GFP_KERNEL);
+	if (ret)
+		return;
+
+	page = alloc_page(GFP_KERNEL);
+	if (!page)
+		return;
+	err_msgp = page_address(page);
+
+	p = err_msgp;
+	*p++ = *rdma_argp;
+	*p++ = *(rdma_argp + 1);
+	*p++ = xprt->sc_fc_credits;
+	*p++ = rdma_error;
+	if (status == -EPROTONOSUPPORT) {
+		*p++ = err_vers;
+		*p++ = rpcrdma_version;
+		*p++ = rpcrdma_version;
+	} else {
+		*p++ = err_chunk;
+	}
+	length = (unsigned long)p - (unsigned long)err_msgp;
+
+	/* Map transport header; no RPC message payload */
+	ctxt = svc_rdma_get_context(xprt);
+	ret = svc_rdma_map_reply_hdr(xprt, ctxt, err_msgp, length);
+	if (ret) {
+		dprintk("svcrdma: Error %d mapping send for protocol error\n",
+			ret);
+		return;
+	}
+
+	svc_rdma_build_send_wr(ctxt, 1);
+	ret = svc_rdma_send(xprt, &ctxt->send_wr);
+	if (ret) {
+		dprintk("svcrdma: Error %d posting send for protocol error\n",
+			ret);
+		svc_rdma_unmap_dma(ctxt);
+		svc_rdma_put_context(ctxt, 1);
+	}
+}
+
 /* By convention, backchannel calls arrive via rdma_msg type
  * messages, and never populate the chunk lists. This makes
  * the RPC/RDMA header small and fixed in size, so it is
@@ -686,7 +737,7 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
 	return ret;
 
 out_err:
-	svc_rdma_send_error(rdma_xprt, rmsgp, ret);
+	svc_rdma_send_error(rdma_xprt, &rmsgp->rm_xid, ret);
 	svc_rdma_put_context(ctxt, 0);
 	return 0;
 
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index be6b11a..1b230dc 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -571,47 +571,3 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
 	set_bit(XPT_CLOSE, &rdma->sc_xprt.xpt_flags);
 	return -ENOTCONN;
 }
-
-void svc_rdma_send_error(struct svcxprt_rdma *xprt, struct rpcrdma_msg *rmsgp,
-			 int status)
-{
-	struct page *p;
-	struct svc_rdma_op_ctxt *ctxt;
-	enum rpcrdma_errcode err;
-	__be32 *va;
-	int length;
-	int ret;
-
-	ret = svc_rdma_repost_recv(xprt, GFP_KERNEL);
-	if (ret)
-		return;
-
-	p = alloc_page(GFP_KERNEL);
-	if (!p)
-		return;
-	va = page_address(p);
-
-	/* XDR encode an error reply */
-	err = ERR_CHUNK;
-	if (status == -EPROTONOSUPPORT)
-		err = ERR_VERS;
-	length = svc_rdma_xdr_encode_error(xprt, rmsgp, err, va);
-
-	/* Map transport header; no RPC message payload */
-	ctxt = svc_rdma_get_context(xprt);
-	ret = svc_rdma_map_reply_hdr(xprt, ctxt, &rmsgp->rm_xid, length);
-	if (ret) {
-		dprintk("svcrdma: Error %d mapping send for protocol error\n",
-			ret);
-		return;
-	}
-
-	svc_rdma_build_send_wr(ctxt, 1);
-	ret = svc_rdma_send(xprt, &ctxt->send_wr);
-	if (ret) {
-		dprintk("svcrdma: Error %d posting send for protocol error\n",
-			ret);
-		svc_rdma_unmap_dma(ctxt);
-		svc_rdma_put_context(ctxt, 1);
-	}
-}

