From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 75/85] nfs41: Get the rpc_xprt * from the rpc_rqst instead of the rpc_clnt.
Date: Mon, 10 Nov 2008 22:31:36 +0200
Message-ID: <1226349096-9736-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:60072 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752692AbYKJUbn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:31:43 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Rahul Iyer <iyer@netapp.com>

Obtain the rpc_xprt from the rpc_rqst so that calls and callback replies
can both use the same code path.  A client needs the rpc_xprt in order
to reply to a callback.

Signed-off-by: Rahul Iyer <iyer@netapp.com>
Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 net/sunrpc/xprt.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index cc1e5f2..e71f1be 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -164,8 +164,8 @@ EXPORT_SYMBOL_GPL(xprt_unregister_transport);
  */
 int xprt_reserve_xprt(struct rpc_task *task)
 {
-	struct rpc_xprt	*xprt = task->tk_xprt;
 	struct rpc_rqst *req = task->tk_rqstp;
+	struct rpc_xprt	*xprt = req->rq_xprt;
 
 	if (test_and_set_bit(XPRT_LOCKED, &xprt->state)) {
 		if (task == xprt->snd_task)
@@ -837,7 +837,7 @@ out_unlock:
 
 void xprt_end_transmit(struct rpc_task *task)
 {
-	xprt_release_write(task->tk_xprt, task);
+	xprt_release_write(task->tk_rqstp->rq_xprt, task);
 }
 
 /**
-- 
1.6.0.2

