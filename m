Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33466 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752195AbdC0OHG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Mar 2017 10:07:06 -0400
Subject: [PATCH v2 11/13] xprtrdma: Squelch ENOBUFS warnings
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 27 Mar 2017 10:07:04 -0400
Message-ID: <20170327140704.20813.26799.stgit@manet.1015granger.net>
In-Reply-To: <20170327134847.20813.52412.stgit@manet.1015granger.net>
References: <20170327134847.20813.52412.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When ro_map is out of buffers, that's not a permanent error, so
don't report a problem.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index e68131b..694e9b1 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -781,9 +781,11 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	return 0;
 
 out_err:
-	pr_err("rpcrdma: rpcrdma_marshal_req failed, status %ld\n",
-	       PTR_ERR(iptr));
-	r_xprt->rx_stats.failed_marshal_count++;
+	if (PTR_ERR(iptr) != -ENOBUFS) {
+		pr_err("rpcrdma: rpcrdma_marshal_req failed, status %ld\n",
+		       PTR_ERR(iptr));
+		r_xprt->rx_stats.failed_marshal_count++;
+	}
 	return PTR_ERR(iptr);
 }
 

