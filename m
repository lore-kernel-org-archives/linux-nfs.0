Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:32999 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753104AbdBMQ5D (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Feb 2017 11:57:03 -0500
Subject: [PATCH v4 5/9] xprtrdma: Shrink send SGEs array
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 13 Feb 2017 11:57:01 -0500
Message-ID: <20170213165701.15801.89447.stgit@manet.1015granger.net>
In-Reply-To: <20170213163936.15801.31225.stgit@manet.1015granger.net>
References: <20170213163936.15801.31225.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We no longer need to accommodate an xdr_buf whose pages start at an
offset and cross extra page boundaries. If there are more partial or
whole pages to send than there are available SGEs, the marshaling
logic is now smart enough to use a Read chunk instead of failing.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/xprt_rdma.h |   11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 3d7e9c9..852dd0a 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -305,16 +305,19 @@ struct rpcrdma_mr_seg {		/* chunk descriptors */
 	char		*mr_offset;	/* kva if no page, else offset */
 };
 
-/* Reserve enough Send SGEs to send a maximum size inline request:
+/* The Send SGE array is provisioned to send a maximum size
+ * inline request:
  * - RPC-over-RDMA header
  * - xdr_buf head iovec
- * - RPCRDMA_MAX_INLINE bytes, possibly unaligned, in pages
+ * - RPCRDMA_MAX_INLINE bytes, in pages
  * - xdr_buf tail iovec
+ *
+ * The actual number of array elements consumed by each RPC
+ * depends on the device's max_sge limit.
  */
 enum {
 	RPCRDMA_MIN_SEND_SGES = 3,
-	RPCRDMA_MAX_SEND_PAGES = PAGE_SIZE + RPCRDMA_MAX_INLINE - 1,
-	RPCRDMA_MAX_PAGE_SGES = (RPCRDMA_MAX_SEND_PAGES >> PAGE_SHIFT) + 1,
+	RPCRDMA_MAX_PAGE_SGES = RPCRDMA_MAX_INLINE >> PAGE_SHIFT,
 	RPCRDMA_MAX_SEND_SGES = 1 + 1 + RPCRDMA_MAX_PAGE_SGES + 1,
 };
 

