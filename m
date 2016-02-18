Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:37358 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753617AbcBRRnz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Feb 2016 12:43:55 -0500
Subject: [PATCH v3 01/10] svcrdma: Do not write xdr_buf::tail in a Write
 chunk
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 18 Feb 2016 12:43:53 -0500
Message-ID: <20160218174353.12825.14732.stgit@klimt.1015granger.net>
In-Reply-To: <20160218173840.12825.26769.stgit@klimt.1015granger.net>
References: <20160218173840.12825.26769.stgit@klimt.1015granger.net>
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
in each chunk. So XDR padding is not needed in a Write chunk.

Thus the server should not write XDR pad bytes in Write chunks.

With NFSv4, the Linux NFS server places the results of any
operations that follow an NFSv4 READ or READLINK in the xdr_buf's
tail. Those results also should never be sent as a part of a Write
chunk. The current logic in send_write_chunks() appears to assume
that the xdr_buf's tail contains only pad bytes (ie, NFSv3).

I believe this is not currently an operational problem, however.

Short NFS READs that are returned in a Write chunk could be affected
by the pad exposure issue. But such READs happen only when the read
request goes past the EOF. Those are zero bytes anyway, and there's
no file data in the client's buffer past EOF.

Current NFSv4 clients don't append extra operations to NFSv4 READ
COMPOUNDs. This issue would be exposed if they were to start doing
so.

The fix is to send only the contents of the xdr_buf's page list in
a Write chunk.

When there is more than an XDR pad in the tail buffer, the server
still places the page list's XDR pad in subsequent inline content,
which is incorrect behavior. This patch does not address that issue.
But as far as I can tell, current clients do not place operations in
NFSv4 COMPOUNDs subsequent to READ or READLINK. I will continue to
pursue a fix for that issue.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_sendto.c |   11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index df57f3c..832eb54 100644
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
@@ -308,9 +313,8 @@ static int send_write_chunks(struct svcxprt_rdma *xprt,
 			     struct svc_rqst *rqstp,
 			     struct svc_rdma_req_map *vec)
 {
-	u32 xfer_len = rqstp->rq_res.page_len + rqstp->rq_res.tail[0].iov_len;
+	u32 xfer_len, xdr_off;
 	int write_len;
-	u32 xdr_off;
 	int chunk_off;
 	int chunk_no;
 	int nchunks;
@@ -325,6 +329,7 @@ static int send_write_chunks(struct svcxprt_rdma *xprt,
 		&rdma_resp->rm_body.rm_chunks[1];
 
 	/* Write chunks start at the pagelist */
+	xfer_len = rqstp->rq_res.page_len;
 	nchunks = be32_to_cpu(arg_ary->wc_nchunks);
 	for (xdr_off = rqstp->rq_res.head[0].iov_len, chunk_no = 0;
 	     xfer_len && chunk_no < nchunks;
@@ -364,7 +369,7 @@ static int send_write_chunks(struct svcxprt_rdma *xprt,
 	/* Update the req with the number of chunks actually used */
 	svc_rdma_xdr_encode_write_list(rdma_resp, chunk_no);
 
-	return rqstp->rq_res.page_len + rqstp->rq_res.tail[0].iov_len;
+	return rqstp->rq_res.page_len + xdr_padsize(rqstp->rq_res.page_len);
 }
 
 static int send_reply_chunks(struct svcxprt_rdma *xprt,

