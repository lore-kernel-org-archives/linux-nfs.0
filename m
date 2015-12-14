Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:38885 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753570AbbLNVRs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Dec 2015 16:17:48 -0500
Subject: [PATCH v3 01/11] xprtrdma: Fix additional uses of
 spin_lock_irqsave(rb_lock)
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 14 Dec 2015 16:17:46 -0500
Message-ID: <20151214211746.16295.38958.stgit@manet.1015granger.net>
In-Reply-To: <20151214211317.16295.70115.stgit@manet.1015granger.net>
References: <20151214211317.16295.70115.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.

rb_lock critical sections added in rpcrdma_ep_post_extra_recv()
should have first been converted to use normal spin_lock now that
the reply handler is a work queue.

The backchannel set up code should use the appropriate helper
instead of open-coding a rb_recv_bufs list add.

Problem introduced by glib patch re-ordering on my part.

Fixes: f531a5dbc451 ('xprtrdma: Pre-allocate backward rpc_rqst')
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/backchannel.c |    6 +-----
 net/sunrpc/xprtrdma/verbs.c       |    7 +++----
 2 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index 2dcb44f..11d2cfb 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -84,9 +84,7 @@ out_fail:
 static int rpcrdma_bc_setup_reps(struct rpcrdma_xprt *r_xprt,
 				 unsigned int count)
 {
-	struct rpcrdma_buffer *buffers = &r_xprt->rx_buf;
 	struct rpcrdma_rep *rep;
-	unsigned long flags;
 	int rc = 0;
 
 	while (count--) {
@@ -98,9 +96,7 @@ static int rpcrdma_bc_setup_reps(struct rpcrdma_xprt *r_xprt,
 			break;
 		}
 
-		spin_lock_irqsave(&buffers->rb_lock, flags);
-		list_add(&rep->rr_list, &buffers->rb_recv_bufs);
-		spin_unlock_irqrestore(&buffers->rb_lock, flags);
+		rpcrdma_recv_buffer_put(rep);
 	}
 
 	return rc;
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 650034b..f23f3d6 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1329,15 +1329,14 @@ rpcrdma_ep_post_extra_recv(struct rpcrdma_xprt *r_xprt, unsigned int count)
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 	struct rpcrdma_ep *ep = &r_xprt->rx_ep;
 	struct rpcrdma_rep *rep;
-	unsigned long flags;
 	int rc;
 
 	while (count--) {
-		spin_lock_irqsave(&buffers->rb_lock, flags);
+		spin_lock(&buffers->rb_lock);
 		if (list_empty(&buffers->rb_recv_bufs))
 			goto out_reqbuf;
 		rep = rpcrdma_buffer_get_rep_locked(buffers);
-		spin_unlock_irqrestore(&buffers->rb_lock, flags);
+		spin_unlock(&buffers->rb_lock);
 
 		rc = rpcrdma_ep_post_recv(ia, ep, rep);
 		if (rc)
@@ -1347,7 +1346,7 @@ rpcrdma_ep_post_extra_recv(struct rpcrdma_xprt *r_xprt, unsigned int count)
 	return 0;
 
 out_reqbuf:
-	spin_unlock_irqrestore(&buffers->rb_lock, flags);
+	spin_unlock(&buffers->rb_lock);
 	pr_warn("%s: no extra receive buffers\n", __func__);
 	return -ENOMEM;
 

