Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:36564 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750922AbdE3SPA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 30 May 2017 14:15:00 -0400
Subject: [PATCH v1 07/17] svcrdma: Improve Reply chunk sanity checking
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 30 May 2017 14:14:58 -0400
Message-ID: <20170530181458.2992.89047.stgit@klimt.1015granger.net>
In-Reply-To: <20170530175808.2992.60365.stgit@klimt.1015granger.net>
References: <20170530175808.2992.60365.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Identify malformed transport headers and unsupported chunk
combinations as early as possible.

- Ensure that segment lengths are not crazy.

- Ensure that the Reply chunk's segment count is not crazy.

With a 1KB inline threshold, the largest number of Write segments
that can be conveyed is about 60 (for a RDMA_NOMSG Reply message).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |   17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index cf8be18..b480893 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -217,15 +217,20 @@ static __be32 *xdr_check_write_list(__be32 *p, const __be32 *end)
 	return p;
 }
 
-static __be32 *xdr_check_reply_chunk(__be32 *p, __be32 *end)
+/* Sanity check the Reply chunk.
+ *
+ * Sanity checks:
+ * - Reply chunk does not overflow buffer.
+ * - Segment size limited by largest NFS data payload.
+ *
+ * Returns pointer to the following RPC header.
+ */
+static __be32 *xdr_check_reply_chunk(__be32 *p, const __be32 *end)
 {
-	__be32 *next;
-
 	if (*p++ != xdr_zero) {
-		next = p + 1 + be32_to_cpup(p) * rpcrdma_segment_maxsz;
-		if (next > end)
+		p = xdr_check_write_chunk(p, end, MAX_BYTES_SPECIAL_SEG);
+		if (!p)
 			return NULL;
-		p = next;
 	}
 	return p;
 }

