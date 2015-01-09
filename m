Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f182.google.com ([209.85.213.182]:49652 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752227AbbAITWi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Jan 2015 14:22:38 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v1 05/10] svcrdma: Find rmsgp more reliably
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 09 Jan 2015 14:22:37 -0500
Message-ID: <20150109192237.4901.92644.stgit@klimt.1015granger.net>
In-Reply-To: <20150109191910.4901.29548.stgit@klimt.1015granger.net>
References: <20150109191910.4901.29548.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

xdr_start() can return the wrong rmsgp address if an assumption
about how the xdr_buf was constructed changes.  When it gets it
wrong, the client receives a reply that has gibberish in the
RPC/RDMA header, preventing it from matching a waiting RPC request.

Instead, make (and document) just one assumption: that the RDMA
header for the client's RPC call is at the start of the first page
in rq_pages.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtrdma/svc_rdma_sendto.c |   18 ++++--------------
 1 files changed, 4 insertions(+), 14 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 7d79897..7de33d1 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -483,18 +483,6 @@ void svc_rdma_prep_reply_hdr(struct svc_rqst *rqstp)
 {
 }
 
-/*
- * Return the start of an xdr buffer.
- */
-static void *xdr_start(struct xdr_buf *xdr)
-{
-	return xdr->head[0].iov_base -
-		(xdr->len -
-		 xdr->page_len -
-		 xdr->tail[0].iov_len -
-		 xdr->head[0].iov_len);
-}
-
 int svc_rdma_sendto(struct svc_rqst *rqstp)
 {
 	struct svc_xprt *xprt = rqstp->rq_xprt;
@@ -512,8 +500,10 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
 
 	dprintk("svcrdma: sending response for rqstp=%p\n", rqstp);
 
-	/* Get the RDMA request header. */
-	rdma_argp = xdr_start(&rqstp->rq_arg);
+	/* Get the RDMA request header. The receive logic always
+	 * places this at the start of page 0.
+	 */
+	rdma_argp = page_address(rqstp->rq_pages[0]);
 
 	/* Build an req vec for the XDR */
 	ctxt = svc_rdma_get_context(rdma);

