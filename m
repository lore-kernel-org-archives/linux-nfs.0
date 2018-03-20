Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34077 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751673AbeCTVFW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Mar 2018 17:05:22 -0400
Subject: [PATCH 3/3] svcrdma: Clean up rdma_build_arg_xdr
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 20 Mar 2018 17:05:20 -0400
Message-ID: <20180320210520.13273.84704.stgit@klimt.1015granger.net>
In-Reply-To: <20180320210219.13273.89049.stgit@klimt.1015granger.net>
References: <20180320210219.13273.89049.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: The value of the byte_count parameter is already passed
to rdma_build_arg_xdr as part of the svc_rdma_op_ctxt structure.

Further, without the parameter called "byte_count" there is no need
to have the abbreviated "bc" automatic variable. "bc" can now be
called something more intuitive.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |   33 +++++++++++++++----------------
 1 file changed, 16 insertions(+), 17 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index 446b9d6..20581b0 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -110,15 +110,16 @@
  * the RDMA_RECV completion. The SGL should contain full pages up until the
  * last one.
  */
-static void rdma_build_arg_xdr(struct svc_rqst *rqstp,
-			       struct svc_rdma_op_ctxt *ctxt,
-			       u32 byte_count)
+static void svc_rdma_build_arg_xdr(struct svc_rqst *rqstp,
+				   struct svc_rdma_op_ctxt *ctxt)
 {
 	struct page *page;
-	u32 bc;
 	int sge_no;
+	u32 len;
 
-	/* Swap the page in the SGE with the page in argpages */
+	/* The reply path assumes the Call's transport header resides
+	 * in rqstp->rq_pages[0].
+	 */
 	page = ctxt->pages[0];
 	put_page(rqstp->rq_pages[0]);
 	rqstp->rq_pages[0] = page;
@@ -126,35 +127,35 @@ static void rdma_build_arg_xdr(struct svc_rqst *rqstp,
 	/* Set up the XDR head */
 	rqstp->rq_arg.head[0].iov_base = page_address(page);
 	rqstp->rq_arg.head[0].iov_len =
-		min_t(size_t, byte_count, ctxt->sge[0].length);
-	rqstp->rq_arg.len = byte_count;
-	rqstp->rq_arg.buflen = byte_count;
+		min_t(size_t, ctxt->byte_len, ctxt->sge[0].length);
+	rqstp->rq_arg.len = ctxt->byte_len;
+	rqstp->rq_arg.buflen = ctxt->byte_len;
 
 	/* Compute bytes past head in the SGL */
-	bc = byte_count - rqstp->rq_arg.head[0].iov_len;
+	len = ctxt->byte_len - rqstp->rq_arg.head[0].iov_len;
 
 	/* If data remains, store it in the pagelist */
-	rqstp->rq_arg.page_len = bc;
+	rqstp->rq_arg.page_len = len;
 	rqstp->rq_arg.page_base = 0;
 
 	sge_no = 1;
-	while (bc && sge_no < ctxt->count) {
+	while (len && sge_no < ctxt->count) {
 		page = ctxt->pages[sge_no];
 		put_page(rqstp->rq_pages[sge_no]);
 		rqstp->rq_pages[sge_no] = page;
-		bc -= min_t(u32, bc, ctxt->sge[sge_no].length);
+		len -= min_t(u32, len, ctxt->sge[sge_no].length);
 		sge_no++;
 	}
 	rqstp->rq_respages = &rqstp->rq_pages[sge_no];
 	rqstp->rq_next_page = rqstp->rq_respages + 1;
 
 	/* If not all pages were used from the SGL, free the remaining ones */
-	bc = sge_no;
+	len = sge_no;
 	while (sge_no < ctxt->count) {
 		page = ctxt->pages[sge_no++];
 		put_page(page);
 	}
-	ctxt->count = bc;
+	ctxt->count = len;
 
 	/* Set up tail */
 	rqstp->rq_arg.tail[0].iov_base = NULL;
@@ -534,10 +535,8 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
 		ctxt, rdma_xprt, rqstp);
 	atomic_inc(&rdma_stat_recv);
 
-	/* Build up the XDR from the receive buffers. */
-	rdma_build_arg_xdr(rqstp, ctxt, ctxt->byte_len);
+	svc_rdma_build_arg_xdr(rqstp, ctxt);
 
-	/* Decode the RDMA header. */
 	p = (__be32 *)rqstp->rq_arg.head[0].iov_base;
 	ret = svc_rdma_xdr_decode_req(&rqstp->rq_arg);
 	if (ret < 0)

