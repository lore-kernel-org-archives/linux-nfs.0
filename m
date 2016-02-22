Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:34338 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753962AbcBVUlO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Feb 2016 15:41:14 -0500
Subject: [PATCH v4 03/13] svcrdma: Do not send Write chunk XDR pad with
 inline content
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 22 Feb 2016 15:41:12 -0500
Message-ID: <20160222204112.3274.32393.stgit@sisley.1015granger.net>
In-Reply-To: <20160222203550.3274.82777.stgit@sisley.1015granger.net>
References: <20160222203550.3274.82777.stgit@sisley.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The NFS server's XDR encoders adds an XDR pad for content in the
xdr_buf page list at the beginning of the xdr_buf's tail buffer.

On RDMA transports, Write chunks are sent separately and without an
XDR pad.

If a Write chunk is being sent, strip off the pad in the tail buffer
so that inline content following the Write chunk remains XDR-aligned
when it is sent to the client.

BugLink: https://bugzilla.linux-nfs.org/show_bug.cgi?id=294
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc_rdma.h            |    2 +-
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |    2 +-
 net/sunrpc/xprtrdma/svc_rdma_sendto.c      |   22 +++++++++++++++++-----
 3 files changed, 19 insertions(+), 7 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 5322fea..40b6785 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -224,7 +224,7 @@ extern int rdma_read_chunk_frmr(struct svcxprt_rdma *, struct svc_rqst *,
 
 /* svc_rdma_sendto.c */
 extern int svc_rdma_map_xdr(struct svcxprt_rdma *, struct xdr_buf *,
-			    struct svc_rdma_req_map *);
+			    struct svc_rdma_req_map *, bool);
 extern int svc_rdma_sendto(struct svc_rqst *);
 extern struct rpcrdma_read_chunk *
 	svc_rdma_get_read_chunk(struct rpcrdma_msg *);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
index 65a7c23..de39196 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
@@ -107,7 +107,7 @@ static int svc_rdma_bc_sendto(struct svcxprt_rdma *rdma,
 	int ret;
 
 	vec = svc_rdma_get_req_map(rdma);
-	ret = svc_rdma_map_xdr(rdma, sndbuf, vec);
+	ret = svc_rdma_map_xdr(rdma, sndbuf, vec, false);
 	if (ret)
 		goto out_err;
 
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 86fea5c..a8fab99 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -57,7 +57,8 @@ static u32 xdr_padsize(u32 len)
 
 int svc_rdma_map_xdr(struct svcxprt_rdma *xprt,
 		     struct xdr_buf *xdr,
-		     struct svc_rdma_req_map *vec)
+		     struct svc_rdma_req_map *vec,
+		     bool write_chunk_present)
 {
 	int sge_no;
 	u32 sge_bytes;
@@ -97,9 +98,20 @@ int svc_rdma_map_xdr(struct svcxprt_rdma *xprt,
 
 	/* Tail SGE */
 	if (xdr->tail[0].iov_len) {
-		vec->sge[sge_no].iov_base = xdr->tail[0].iov_base;
-		vec->sge[sge_no].iov_len = xdr->tail[0].iov_len;
-		sge_no++;
+		unsigned char *base = xdr->tail[0].iov_base;
+		size_t len = xdr->tail[0].iov_len;
+		u32 xdr_pad = xdr_padsize(xdr->page_len);
+
+		if (write_chunk_present && xdr_pad) {
+			base += xdr_pad;
+			len -= xdr_pad;
+		}
+
+		if (len) {
+			vec->sge[sge_no].iov_base = base;
+			vec->sge[sge_no].iov_len = len;
+			sge_no++;
+		}
 	}
 
 	dprintk("svcrdma: %s: sge_no %d page_no %d "
@@ -594,7 +606,7 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
 	ctxt = svc_rdma_get_context(rdma);
 	ctxt->direction = DMA_TO_DEVICE;
 	vec = svc_rdma_get_req_map(rdma);
-	ret = svc_rdma_map_xdr(rdma, &rqstp->rq_res, vec);
+	ret = svc_rdma_map_xdr(rdma, &rqstp->rq_res, vec, wr_ary != NULL);
 	if (ret)
 		goto err0;
 	inline_bytes = rqstp->rq_res.len;

