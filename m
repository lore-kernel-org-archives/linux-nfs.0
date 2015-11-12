Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:36368 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751167AbbKLOoh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Nov 2015 09:44:37 -0500
Subject: [PATCH] svcrdma: Do not send XDR roundup bytes for a write chunk
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-rmda@vger.kernel.org
Date: Thu, 12 Nov 2015 09:44:33 -0500
Message-ID: <20151112144433.13507.34603.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Minor optimization: when dealing with write chunk XDR roundup, do
not post a Write WR for the zero bytes in the pad. Simply update
the write segment in the RPC-over-RDMA header to reflect the extra
pad bytes.

The Reply chunk is also a write chunk, but the server does not use
send_write_chunks() to send the Reply chunk. That's OK in this case:
the server Upper Layer typically marshals the Reply chunk contents
in a single contiguous buffer, without a separate tail for the XDR
pad.

The comments and the variable naming refer to "chunks" but what is
really meant is "segments." The existing code sends only one
xdr_write_chunk per RPC reply.

The fix assumes this as well. When the XDR pad in the first write
chunk is reached, the assumption is the Write list is complete and
send_write_chunks() returns.

That will remain a valid assumption until the server Upper Layer can
support multiple bulk payload results per RPC.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_sendto.c |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 1dfae83..6c48901 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -342,6 +342,13 @@ static int send_write_chunks(struct svcxprt_rdma *xprt,
 						arg_ch->rs_handle,
 						arg_ch->rs_offset,
 						write_len);
+
+		/* Do not send XDR pad bytes */
+		if (chunk_no && write_len < 4) {
+			chunk_no++;
+			break;
+		}
+
 		chunk_off = 0;
 		while (write_len) {
 			ret = send_write(xprt, rqstp,

