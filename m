Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:32796 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934086AbcK2Pwu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2016 10:52:50 -0500
Subject: [PATCH v3 06/12] xprtrdma: Avoid calls to ro_unmap_safe()
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 29 Nov 2016 10:52:48 -0500
Message-ID: <20161129155248.23061.92870.stgit@manet.1015granger.net>
In-Reply-To: <20161129154845.23061.29385.stgit@manet.1015granger.net>
References: <20161129154845.23061.29385.stgit@manet.1015granger.net>
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

