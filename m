Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:33725 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752847AbdDKRXw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Apr 2017 13:23:52 -0400
Subject: [PATCH v3 11/13] xprtrdma: Squelch ENOBUFS warnings
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 11 Apr 2017 13:23:51 -0400
Message-ID: <20170411172351.11300.89160.stgit@manet.1015granger.net>
In-Reply-To: <20170411171820.11300.55637.stgit@manet.1015granger.net>
References: <20170411171820.11300.55637.stgit@manet.1015granger.net>
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
 

