Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:32828 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752444AbeEGT1u (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 7 May 2018 15:27:50 -0400
Subject: [PATCH v1 11/19] svcrdma: Allocate recv_ctxt's on CPU handling
 Receives
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 07 May 2018 15:27:48 -0400
Message-ID: <20180507192748.4608.81602.stgit@klimt.1015granger.net>
In-Reply-To: <20180507192126.4608.63295.stgit@klimt.1015granger.net>
References: <20180507192126.4608.63295.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is a significant latency penalty when processing an ingress
Receive if the Receive buffer resides in memory that is not on the
same NUMA node as the the CPU handling completions for a CQ.

The system administrator and the device driver determine which CPU
handles completions. This CPU does not change during life of the CQ.
Further the Upper Layer does not have any visibility of which CPU it
is.

Allocating Receive buffers in the Receive completion handler
guarantees that Receive buffers are allocated on the preferred NUMA
node for that CQ.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc_rdma.h         |    1 +
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |   52 +++++++++++++++++++++----------
 2 files changed, 37 insertions(+), 16 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 01baabf..27cf59c 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -151,6 +151,7 @@ struct svc_rdma_recv_ctxt {
 	struct ib_sge		rc_recv_sge;
 	void			*rc_recv_buf;
 	struct xdr_buf		rc_arg;
+	bool			rc_temp;
 	u32			rc_byte_len;
 	unsigned int		rc_page_count;
 	unsigned int		rc_hdr_count;
diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index d4ccd1c..0445e75 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -144,6 +144,7 @@
 	ctxt->rc_recv_sge.length = rdma->sc_max_req_size;
 	ctxt->rc_recv_sge.lkey = rdma->sc_pd->local_dma_lkey;
 	ctxt->rc_recv_buf = buffer;
+	ctxt->rc_temp = false;
 	return ctxt;
 
 fail2:
@@ -154,6 +155,15 @@
 	return NULL;
 }
 
+static void svc_rdma_recv_ctxt_destroy(struct svcxprt_rdma *rdma,
+				       struct svc_rdma_recv_ctxt *ctxt)
+{
+	ib_dma_unmap_single(rdma->sc_pd->device, ctxt->rc_recv_sge.addr,
+			    ctxt->rc_recv_sge.length, DMA_FROM_DEVICE);
+	kfree(ctxt->rc_recv_buf);
+	kfree(ctxt);
+}
+
 /**
  * svc_rdma_recv_ctxts_destroy - Release all recv_ctxt's for an xprt
  * @rdma: svcxprt_rdma being torn down
@@ -165,12 +175,7 @@ void svc_rdma_recv_ctxts_destroy(struct svcxprt_rdma *rdma)
 
 	while ((ctxt = svc_rdma_next_recv_ctxt(&rdma->sc_recv_ctxts))) {
 		list_del(&ctxt->rc_list);
-		ib_dma_unmap_single(rdma->sc_pd->device,
-				    ctxt->rc_recv_sge.addr,
-				    ctxt->rc_recv_sge.length,
-				    DMA_FROM_DEVICE);
-		kfree(ctxt->rc_recv_buf);
-		kfree(ctxt);
+		svc_rdma_recv_ctxt_destroy(rdma, ctxt);
 	}
 }
 
@@ -212,21 +217,21 @@ void svc_rdma_recv_ctxt_put(struct svcxprt_rdma *rdma,
 
 	for (i = 0; i < ctxt->rc_page_count; i++)
 		put_page(ctxt->rc_pages[i]);
-	spin_lock(&rdma->sc_recv_lock);
-	list_add(&ctxt->rc_list, &rdma->sc_recv_ctxts);
-	spin_unlock(&rdma->sc_recv_lock);
+
+	if (!ctxt->rc_temp) {
+		spin_lock(&rdma->sc_recv_lock);
+		list_add(&ctxt->rc_list, &rdma->sc_recv_ctxts);
+		spin_unlock(&rdma->sc_recv_lock);
+	} else
+		svc_rdma_recv_ctxt_destroy(rdma, ctxt);
 }
 
-static int svc_rdma_post_recv(struct svcxprt_rdma *rdma)
+static int __svc_rdma_post_recv(struct svcxprt_rdma *rdma,
+				struct svc_rdma_recv_ctxt *ctxt)
 {
-	struct svc_rdma_recv_ctxt *ctxt;
 	struct ib_recv_wr *bad_recv_wr;
 	int ret;
 
-	ctxt = svc_rdma_recv_ctxt_get(rdma);
-	if (!ctxt)
-		return -ENOMEM;
-
 	svc_xprt_get(&rdma->sc_xprt);
 	ret = ib_post_recv(rdma->sc_qp, &ctxt->rc_recv_wr, &bad_recv_wr);
 	trace_svcrdma_post_recv(&ctxt->rc_recv_wr, ret);
@@ -240,6 +245,16 @@ static int svc_rdma_post_recv(struct svcxprt_rdma *rdma)
 	return ret;
 }
 
+static int svc_rdma_post_recv(struct svcxprt_rdma *rdma)
+{
+	struct svc_rdma_recv_ctxt *ctxt;
+
+	ctxt = svc_rdma_recv_ctxt_get(rdma);
+	if (!ctxt)
+		return -ENOMEM;
+	return __svc_rdma_post_recv(rdma, ctxt);
+}
+
 /**
  * svc_rdma_post_recvs - Post initial set of Recv WRs
  * @rdma: fresh svcxprt_rdma
@@ -248,11 +263,16 @@ static int svc_rdma_post_recv(struct svcxprt_rdma *rdma)
  */
 bool svc_rdma_post_recvs(struct svcxprt_rdma *rdma)
 {
+	struct svc_rdma_recv_ctxt *ctxt;
 	unsigned int i;
 	int ret;
 
 	for (i = 0; i < rdma->sc_max_requests; i++) {
-		ret = svc_rdma_post_recv(rdma);
+		ctxt = svc_rdma_recv_ctxt_get(rdma);
+		if (!ctxt)
+			return -ENOMEM;
+		ctxt->rc_temp = true;
+		ret = __svc_rdma_post_recv(rdma, ctxt);
 		if (ret) {
 			pr_err("svcrdma: failure posting recv buffers: %d\n",
 			       ret);

