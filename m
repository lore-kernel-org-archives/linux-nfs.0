Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f52.google.com ([209.85.192.52]:33770 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751509AbbJPNaR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Oct 2015 09:30:17 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] svcrdma: Do not send XDR roundup bytes for a write chunk
To: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date: Fri, 16 Oct 2015 09:30:15 -0400
Message-ID: <20151016132938.8597.65237.stgit@oracle-120.nfsv4bat.org>
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
 1 files changed, 7 insertions(+), 0 deletions(-)

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

