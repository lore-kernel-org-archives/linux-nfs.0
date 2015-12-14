Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:35663 "EHLO
	mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932080AbbLNVbQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Dec 2015 16:31:16 -0500
Subject: [PATCH v4 09/11] svcrdma: Make map_xdr non-static
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 14 Dec 2015 16:31:15 -0500
Message-ID: <20151214213115.12932.25630.stgit@klimt.1015granger.net>
In-Reply-To: <20151214211951.12932.99017.stgit@klimt.1015granger.net>
References: <20151214211951.12932.99017.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Pre-requisite to use map_xdr in the backchannel code.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc_rdma.h       |    2 ++
 net/sunrpc/xprtrdma/svc_rdma_sendto.c |   14 +++++++-------
 2 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 729ff35..aeffa30 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -213,6 +213,8 @@ extern int rdma_read_chunk_frmr(struct svcxprt_rdma *, struct svc_rqst *,
 				u32, u32, u64, bool);
 
 /* svc_rdma_sendto.c */
+extern int svc_rdma_map_xdr(struct svcxprt_rdma *, struct xdr_buf *,
+			    struct svc_rdma_req_map *);
 extern int svc_rdma_sendto(struct svc_rqst *);
 extern struct rpcrdma_read_chunk *
 	svc_rdma_get_read_chunk(struct rpcrdma_msg *);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 9221086..ced3151 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -50,9 +50,9 @@
 
 #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
 
-static int map_xdr(struct svcxprt_rdma *xprt,
-		   struct xdr_buf *xdr,
-		   struct svc_rdma_req_map *vec)
+int svc_rdma_map_xdr(struct svcxprt_rdma *xprt,
+		     struct xdr_buf *xdr,
+		     struct svc_rdma_req_map *vec)
 {
 	int sge_no;
 	u32 sge_bytes;
@@ -62,7 +62,7 @@ static int map_xdr(struct svcxprt_rdma *xprt,
 
 	if (xdr->len !=
 	    (xdr->head[0].iov_len + xdr->page_len + xdr->tail[0].iov_len)) {
-		pr_err("svcrdma: map_xdr: XDR buffer length error\n");
+		pr_err("svcrdma: %s: XDR buffer length error\n", __func__);
 		return -EIO;
 	}
 
@@ -97,9 +97,9 @@ static int map_xdr(struct svcxprt_rdma *xprt,
 		sge_no++;
 	}
 
-	dprintk("svcrdma: map_xdr: sge_no %d page_no %d "
+	dprintk("svcrdma: %s: sge_no %d page_no %d "
 		"page_base %u page_len %u head_len %zu tail_len %zu\n",
-		sge_no, page_no, xdr->page_base, xdr->page_len,
+		__func__, sge_no, page_no, xdr->page_base, xdr->page_len,
 		xdr->head[0].iov_len, xdr->tail[0].iov_len);
 
 	vec->count = sge_no;
@@ -599,7 +599,7 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
 	ctxt = svc_rdma_get_context(rdma);
 	ctxt->direction = DMA_TO_DEVICE;
 	vec = svc_rdma_get_req_map(rdma);
-	ret = map_xdr(rdma, &rqstp->rq_res, vec);
+	ret = svc_rdma_map_xdr(rdma, &rqstp->rq_res, vec);
 	if (ret)
 		goto err0;
 	inline_bytes = rqstp->rq_res.len;

