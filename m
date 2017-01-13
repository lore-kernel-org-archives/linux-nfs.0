Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:32807 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750923AbdAMRm7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Jan 2017 12:42:59 -0500
Subject: [PATCH v1 1/5] xprtrdma: Fix Read chunk padding
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 13 Jan 2017 12:42:57 -0500
Message-ID: <20170113174257.32692.37552.stgit@manet.1015granger.net>
In-Reply-To: <20170113173023.32692.30661.stgit@manet.1015granger.net>
References: <20170113173023.32692.30661.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When pad optimization is disabled, rpcrdma_convert_iovs still
does not add explicit XDR padding to a Read chunk.

Commit 677eb17e94ed ("xprtrdma: Fix XDR tail buffer marshalling")
incorrectly short-circuited the test for whether padding is needed,
which appears later in rpcrdma_convert_iovs.

However, if this is indeed a Read chunk (and not a Position-Zero
Read chunk), the tail iovec _always_ contains the chunk's padding,
and never anything else.

So, it's easy to just skip the tail when padding optimization is
enabled, and add the tail in a subsequent Read chunk segment, if
disabled.

Fixes: 677eb17e94ed ("xprtrdma: Fix XDR tail buffer marshalling")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index c52e0f2..a524d3c 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -226,8 +226,10 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	if (len && n == RPCRDMA_MAX_SEGS)
 		goto out_overflow;
 
-	/* When encoding the read list, the tail is always sent inline */
-	if (type == rpcrdma_readch)
+	/* When encoding a Read chunk, the tail iovec contains an
+	 * XDR pad and may be omitted.
+	 */
+	if (type == rpcrdma_readch && xprt_rdma_pad_optimize)
 		return n;
 
 	/* When encoding the Write list, some servers need to see an extra
@@ -238,10 +240,6 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 		return n;
 
 	if (xdrbuf->tail[0].iov_len) {
-		/* the rpcrdma protocol allows us to omit any trailing
-		 * xdr pad bytes, saving the server an RDMA operation. */
-		if (xdrbuf->tail[0].iov_len < 4 && xprt_rdma_pad_optimize)
-			return n;
 		n = rpcrdma_convert_kvec(&xdrbuf->tail[0], seg, n);
 		if (n == RPCRDMA_MAX_SEGS)
 			goto out_overflow;

