Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([72.48.136.20]:55623 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751778AbaGIStP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jul 2014 14:49:15 -0400
From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH] svcrdma: send_write() must not overflow the device's max sge
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org, tom@ogc.us
Date: Wed, 09 Jul 2014 13:49:15 -0500
Message-ID: <20140709184914.22217.59770.stgit@build.ogc.int>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Function send_write() must stop creating sges when it reaches the device
max and return the amount sent in the RDMA Write to the caller.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 net/sunrpc/xprtrdma/svc_rdma_sendto.c |   39 +++++++++++++--------------------
 1 files changed, 15 insertions(+), 24 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 49fd21a..9f1b506 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -192,6 +192,8 @@ static int send_write(struct svcxprt_rdma *xprt, struct svc_rqst *rqstp,
 		xdr_sge_no++;
 		BUG_ON(xdr_sge_no > vec->count);
 		bc -= sge_bytes;
+		if (sge_no == xprt->sc_max_sge)
+			break;
 	}
 
 	/* Prepare WRITE WR */
@@ -209,7 +211,7 @@ static int send_write(struct svcxprt_rdma *xprt, struct svc_rqst *rqstp,
 	atomic_inc(&rdma_stat_write);
 	if (svc_rdma_send(xprt, &write_wr))
 		goto err;
-	return 0;
+	return write_len - bc;
  err:
 	svc_rdma_unmap_dma(ctxt);
 	svc_rdma_put_context(ctxt, 0);
@@ -225,7 +227,6 @@ static int send_write_chunks(struct svcxprt_rdma *xprt,
 {
 	u32 xfer_len = rqstp->rq_res.page_len + rqstp->rq_res.tail[0].iov_len;
 	int write_len;
-	int max_write;
 	u32 xdr_off;
 	int chunk_off;
 	int chunk_no;
@@ -239,8 +240,6 @@ static int send_write_chunks(struct svcxprt_rdma *xprt,
 	res_ary = (struct rpcrdma_write_array *)
 		&rdma_resp->rm_body.rm_chunks[1];
 
-	max_write = xprt->sc_max_sge * PAGE_SIZE;
-
 	/* Write chunks start at the pagelist */
 	for (xdr_off = rqstp->rq_res.head[0].iov_len, chunk_no = 0;
 	     xfer_len && chunk_no < arg_ary->wc_nchunks;
@@ -260,23 +259,21 @@ static int send_write_chunks(struct svcxprt_rdma *xprt,
 						write_len);
 		chunk_off = 0;
 		while (write_len) {
-			int this_write;
-			this_write = min(write_len, max_write);
 			ret = send_write(xprt, rqstp,
 					 ntohl(arg_ch->rs_handle),
 					 rs_offset + chunk_off,
 					 xdr_off,
-					 this_write,
+					 write_len,
 					 vec);
-			if (ret) {
+			if (ret <= 0) {
 				dprintk("svcrdma: RDMA_WRITE failed, ret=%d\n",
 					ret);
 				return -EIO;
 			}
-			chunk_off += this_write;
-			xdr_off += this_write;
-			xfer_len -= this_write;
-			write_len -= this_write;
+			chunk_off += ret;
+			xdr_off += ret;
+			xfer_len -= ret;
+			write_len -= ret;
 		}
 	}
 	/* Update the req with the number of chunks actually used */
@@ -293,7 +290,6 @@ static int send_reply_chunks(struct svcxprt_rdma *xprt,
 {
 	u32 xfer_len = rqstp->rq_res.len;
 	int write_len;
-	int max_write;
 	u32 xdr_off;
 	int chunk_no;
 	int chunk_off;
@@ -311,8 +307,6 @@ static int send_reply_chunks(struct svcxprt_rdma *xprt,
 	res_ary = (struct rpcrdma_write_array *)
 		&rdma_resp->rm_body.rm_chunks[2];
 
-	max_write = xprt->sc_max_sge * PAGE_SIZE;
-
 	/* xdr offset starts at RPC message */
 	nchunks = ntohl(arg_ary->wc_nchunks);
 	for (xdr_off = 0, chunk_no = 0;
@@ -330,24 +324,21 @@ static int send_reply_chunks(struct svcxprt_rdma *xprt,
 						write_len);
 		chunk_off = 0;
 		while (write_len) {
-			int this_write;
-
-			this_write = min(write_len, max_write);
 			ret = send_write(xprt, rqstp,
 					 ntohl(ch->rs_handle),
 					 rs_offset + chunk_off,
 					 xdr_off,
-					 this_write,
+					 write_len,
 					 vec);
-			if (ret) {
+			if (ret <= 0) {
 				dprintk("svcrdma: RDMA_WRITE failed, ret=%d\n",
 					ret);
 				return -EIO;
 			}
-			chunk_off += this_write;
-			xdr_off += this_write;
-			xfer_len -= this_write;
-			write_len -= this_write;
+			chunk_off += ret;
+			xdr_off += ret;
+			xfer_len -= ret;
+			write_len -= ret;
 		}
 	}
 	/* Update the req with the number of chunks actually used */

