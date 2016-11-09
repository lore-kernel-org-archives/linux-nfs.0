Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:33023 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752259AbcKITFs (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Nov 2016 14:05:48 -0500
Subject: [PATCH v1 07/14] xprtrdma: Avoid calls to ro_unmap_safe()
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 09 Nov 2016 14:05:46 -0500
Message-ID: <20161109190546.15007.28710.stgit@manet.1015granger.net>
In-Reply-To: <20161109184735.15007.96507.stgit@manet.1015granger.net>
References: <20161109184735.15007.96507.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Micro-optimization: Most of the time, calls to ro_unmap_safe are
expensive no-ops. Call only when there is work to do.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/transport.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index ed5e285..545d3fc 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -621,7 +621,8 @@
 
 	dprintk("RPC:       %s: called on 0x%p\n", __func__, req->rl_reply);
 
-	ia->ri_ops->ro_unmap_safe(r_xprt, req, !RPC_IS_ASYNC(task));
+	if (unlikely(!list_empty(&req->rl_registered)))
+		ia->ri_ops->ro_unmap_safe(r_xprt, req, !RPC_IS_ASYNC(task));
 	rpcrdma_unmap_sges(ia, req);
 	rpcrdma_buffer_put(req);
 }
@@ -657,7 +658,8 @@
 	int rc = 0;
 
 	/* On retransmit, remove any previously registered chunks */
-	r_xprt->rx_ia.ri_ops->ro_unmap_safe(r_xprt, req, false);
+	if (unlikely(!list_empty(&req->rl_registered)))
+		r_xprt->rx_ia.ri_ops->ro_unmap_safe(r_xprt, req, false);
 
 	rc = rpcrdma_marshal_req(rqst);
 	if (rc < 0)

