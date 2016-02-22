Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:35616 "EHLO
	mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753962AbcBVUlH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Feb 2016 15:41:07 -0500
Subject: [PATCH v4 02/13] svcrdma: Do not write xdr_buf::tail in a Write
 chunk
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 22 Feb 2016 15:41:02 -0500
Message-ID: <20160222204102.3274.86385.stgit@sisley.1015granger.net>
In-Reply-To: <20160222203550.3274.82777.stgit@sisley.1015granger.net>
References: <20160222203550.3274.82777.stgit@sisley.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When the Linux NFS server writes an odd-length data item into a
Write chunk, it finishes with XDR pad bytes. If the data item is
smaller than the Write chunk, the pad bytes are written at the end
of the data item, but still inside the chunk (ie, in the
application's buffer). Since this is direct data placement, that
exposes the pad bytes.

XDR pad bytes are inserted in order to preserve the XDR alignment
of the next XDR data item in an XDR stream. But Write chunks do not
appear in the payload XDR stream, and only one data item is allowed
in each chunk. Thus XDR padding is not needed in a Write chunk.

With NFSv4, the Linux NFS server places the results of any
operations that follow an NFSv4 READ or READLINK in the xdr_buf's
tail. Those results also should never be sent as a part of a Write
chunk. The current logic in send_write_chunks() appears to assume
that the xdr_buf's tail contains only pad bytes (ie, NFSv3).

The server should write only the contents of the xdr_buf's page list
in a Write chunk. If there's more than an XDR pad in the tail, that
needs to go inline or in the Reply chunk.

BugLink: https://bugzilla.linux-nfs.org/show_bug.cgi?id=294
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_sendto.c |   11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 79fa661..86fea5c 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -50,6 +50,11 @@
 
 #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
 
+static u32 xdr_padsize(u32 len)
+{
+	return (len & 3) ? (4 - (len & 3)) : 0;
+}
+
 int svc_rdma_map_xdr(struct svcxprt_rdma *xprt,
 		     struct xdr_buf *xdr,
 		     struct svc_rdma_req_map *vec)
@@ -308,7 +313,7 @@ static int send_write_chunks(struct svcxprt_rdma *xprt,
 			     struct svc_rqst *rqstp,
 			     struct svc_rdma_req_map *vec)
 {
-	u32 xfer_len = rqstp->rq_res.page_len + rqstp->rq_res.tail[0].iov_len;
+	u32 xfer_len = rqstp->rq_res.page_len;
 	int write_len;
 	u32 xdr_off;
 	int chunk_off;
@@ -357,7 +362,7 @@ static int send_write_chunks(struct svcxprt_rdma *xprt,
 	/* Update the req with the number of chunks actually used */
 	svc_rdma_xdr_encode_write_list(rdma_resp, chunk_no);
 
-	return rqstp->rq_res.page_len + rqstp->rq_res.tail[0].iov_len;
+	return rqstp->rq_res.page_len;
 
 out_err:
 	pr_err("svcrdma: failed to send write chunks, rc=%d\n", ret);
@@ -612,7 +617,7 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
 		ret = send_write_chunks(rdma, wr_ary, rdma_resp, rqstp, vec);
 		if (ret < 0)
 			goto err1;
-		inline_bytes -= ret;
+		inline_bytes -= ret + xdr_padsize(ret);
 	}
 
 	/* Send any reply-list data and update resp reply-list */

