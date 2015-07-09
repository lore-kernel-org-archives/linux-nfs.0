Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:36309 "EHLO
	mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753616AbbGIUm7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jul 2015 16:42:59 -0400
Subject: [PATCH v1 08/12] xprtrdma: Fix XDR tail buffer marshalling
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 09 Jul 2015 16:42:56 -0400
Message-ID: <20150709204256.26247.14336.stgit@manet.1015granger.net>
In-Reply-To: <20150709203242.26247.4848.stgit@manet.1015granger.net>
References: <20150709203242.26247.4848.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently xprtrdma appends an extra chunk element to the RPC/RDMA
read chunk list of each NFSv4 WRITE compound. The extra element
contains the final GETATTR operation in the compound.

The result is an extra RDMA READ operation to transfer a very short
piece of each NFS WRITE compound (typically 16 bytes). This is
inefficient.

It is also incorrect. Although RFC 5667 is not precise about when
using a read list with NFSv4 COMPOUND is allowed, the intent is that
only data arguments not touched by the NFS client are to be sent
using RDMA READ or WRITE. The NFS client constructs GETATTR
arguments itself, and therefore is required to send the trailing
GETATTR operation as additional inline content, not as a data
payload.

NB: This change is not backwards compatible. Some older servers do
not accept inline content following the read list. The Linux NFS
server should handle this content correctly as of commit
a97c331f9aa9 ("svcrdma: Handle additional inline content").

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c |   43 +++++++++++++++++++++++++++++++++++++++-
 1 file changed, 42 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 8ac1448c..cb05233 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -96,6 +96,42 @@ static bool rpcrdma_results_inline(struct rpc_rqst *rqst)
 	return repsize <= RPCRDMA_INLINE_READ_THRESHOLD(rqst);
 }
 
+static int
+rpcrdma_tail_pullup(struct xdr_buf *buf)
+{
+	size_t tlen = buf->tail[0].iov_len;
+	size_t skip = tlen & 3;
+
+	/* Do not include the tail if it is only an XDR pad */
+	if (tlen < 4)
+		return 0;
+
+	/* xdr_write_pages() adds a pad at the beginning of the tail
+	 * if the content in "buf->pages" is unaligned. Force the
+	 * tail's actual content to land at the next XDR position
+	 * after the head instead.
+	 */
+	if (skip) {
+		unsigned char *src, *dst;
+		unsigned int count;
+
+		src = buf->tail[0].iov_base;
+		dst = buf->head[0].iov_base;
+		dst += buf->head[0].iov_len;
+
+		src += skip;
+		tlen -= skip;
+
+		dprintk("RPC:       %s: skip=%zu, memmove(%p, %p, %zu)\n",
+			__func__, skip, dst, src, tlen);
+
+		for (count = tlen; count; count--)
+			*dst++ = *src++;
+	}
+
+	return tlen;
+}
+
 /*
  * Chunk assembly from upper layer xdr_buf.
  *
@@ -147,6 +183,10 @@ rpcrdma_convert_iovs(struct xdr_buf *xdrbuf, unsigned int pos,
 	if (len && n == nsegs)
 		return -EIO;
 
+	/* When encoding the read list, the tail is always sent inline */
+	if (type == rpcrdma_readch)
+		return n;
+
 	if (xdrbuf->tail[0].iov_len) {
 		/* the rpcrdma protocol allows us to omit any trailing
 		 * xdr pad bytes, saving the server an RDMA operation. */
@@ -504,7 +544,8 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 			/* new length after pullup */
 			rpclen = rqst->rq_svec[0].iov_len;
 		}
-	}
+	} else if (rtype == rpcrdma_readch)
+		rpclen += rpcrdma_tail_pullup(&rqst->rq_snd_buf);
 
 	if (rtype != rpcrdma_noch) {
 		hdrlen = rpcrdma_create_chunks(rqst, &rqst->rq_snd_buf,

