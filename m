Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:49817 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754365AbdJIQDh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Oct 2017 12:03:37 -0400
Subject: [PATCH v1 2/3] xprtrdma: Use ro_unmap_sync in xprt_rdma_send_request
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 09 Oct 2017 12:03:34 -0400
Message-ID: <20171009160334.18726.33163.stgit@manet.1015granger.net>
In-Reply-To: <20171009155524.18726.32086.stgit@manet.1015granger.net>
References: <20171009155524.18726.32086.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The "safe" version of ro_unmap is used here to avoid waiting
unnecessarily. However:

 - It is safe to wait. After all, we have to wait anyway when using
   FMR to register memory.

 - This case is rare: it occurs only after a reconnect.

By switching this call site to ro_unmap_sync, the final use of
ro_unmap_safe is removed.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/transport.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 8cf5ccf..eb46d24 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -728,7 +728,8 @@
 
 	/* On retransmit, remove any previously registered chunks */
 	if (unlikely(!list_empty(&req->rl_registered)))
-		r_xprt->rx_ia.ri_ops->ro_unmap_safe(r_xprt, req, false);
+		r_xprt->rx_ia.ri_ops->ro_unmap_sync(r_xprt,
+						    &req->rl_registered);
 
 	rc = rpcrdma_marshal_req(r_xprt, rqst);
 	if (rc < 0)

