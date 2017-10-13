Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:55046 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751617AbdJMVsB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Oct 2017 17:48:01 -0400
Subject: [PATCH] xprtrdma: Use generic asynchronous MR disposal in
 send_request
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 13 Oct 2017 17:47:58 -0400
Message-ID: <20171013214509.14446.81979.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: The asynchronous path of ro_unmap_safe is the same for all
registration modes, so just move it into the only function that
calls it.

"Safe" disposal is done because attempting to invalidate an MR with
a memory key from the previous connection epoch can result in a
memory management operation error for some registration modes, and
that will kill the current connection.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/transport.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

Hi Anna-

This patch replaces 2/3 in the for-4.15 series I sent a few days
ago.

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 8cf5ccf..aa5cab2 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -727,8 +727,12 @@
 		goto drop_connection;
 
 	/* On retransmit, remove any previously registered chunks */
-	if (unlikely(!list_empty(&req->rl_registered)))
-		r_xprt->rx_ia.ri_ops->ro_unmap_safe(r_xprt, req, false);
+	while (unlikely(!list_empty(&req->rl_registered))) {
+		struct rpcrdma_mw *mw;
+
+		mw = rpcrdma_pop_mw(&req->rl_registered);
+		rpcrdma_defer_mr_recovery(mw);
+	}
 
 	rc = rpcrdma_marshal_req(r_xprt, rqst);
 	if (rc < 0)

