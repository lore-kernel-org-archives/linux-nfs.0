Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33526 "EHLO
	mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967712AbcHBR5W (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Aug 2016 13:57:22 -0400
Received: by mail-it0-f65.google.com with SMTP id d65so14531547ith.0
        for <linux-nfs@vger.kernel.org>; Tue, 02 Aug 2016 10:57:09 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: Fix up socket autodisconnect
Date: Tue,  2 Aug 2016 13:56:37 -0400
Message-Id: <1470160597-14274-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that we don't forget to set up the disconnection timer for the
case when a connect request is fulfilled after the RPC request that
initiated it has timed out or been interrupted.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprt.c | 26 ++++++++++++++++++--------
 1 file changed, 18 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 8313960cac52..ea244b29138b 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -680,6 +680,20 @@ out:
 	spin_unlock_bh(&xprt->transport_lock);
 }
 
+static bool
+xprt_has_timer(const struct rpc_xprt *xprt)
+{
+	return xprt->idle_timeout != 0;
+}
+
+static void
+xprt_schedule_autodisconnect(struct rpc_xprt *xprt)
+	__must_hold(&xprt->transport_lock)
+{
+	if (list_empty(&xprt->recv) && xprt_has_timer(xprt))
+		mod_timer(&xprt->timer, xprt->last_used + xprt->idle_timeout);
+}
+
 static void
 xprt_init_autodisconnect(unsigned long data)
 {
@@ -688,6 +702,8 @@ xprt_init_autodisconnect(unsigned long data)
 	spin_lock(&xprt->transport_lock);
 	if (!list_empty(&xprt->recv))
 		goto out_abort;
+	/* Reset xprt->last_used to avoid connect/autodisconnect cycling */
+	xprt->last_used = jiffies;
 	if (test_and_set_bit(XPRT_LOCKED, &xprt->state))
 		goto out_abort;
 	spin_unlock(&xprt->transport_lock);
@@ -725,6 +741,7 @@ void xprt_unlock_connect(struct rpc_xprt *xprt, void *cookie)
 		goto out;
 	xprt->snd_task =NULL;
 	xprt->ops->release_xprt(xprt, NULL);
+	xprt_schedule_autodisconnect(xprt);
 out:
 	spin_unlock_bh(&xprt->transport_lock);
 	wake_up_bit(&xprt->state, XPRT_LOCKED);
@@ -888,11 +905,6 @@ static void xprt_timer(struct rpc_task *task)
 	spin_unlock_bh(&xprt->transport_lock);
 }
 
-static inline int xprt_has_timer(struct rpc_xprt *xprt)
-{
-	return xprt->idle_timeout != 0;
-}
-
 /**
  * xprt_prepare_transmit - reserve the transport before sending a request
  * @task: RPC task about to send a request
@@ -1280,9 +1292,7 @@ void xprt_release(struct rpc_task *task)
 	if (!list_empty(&req->rq_list))
 		list_del(&req->rq_list);
 	xprt->last_used = jiffies;
-	if (list_empty(&xprt->recv) && xprt_has_timer(xprt))
-		mod_timer(&xprt->timer,
-				xprt->last_used + xprt->idle_timeout);
+	xprt_schedule_autodisconnect(xprt);
 	spin_unlock_bh(&xprt->transport_lock);
 	if (req->rq_buffer)
 		xprt->ops->buf_free(req->rq_buffer);
-- 
2.7.4

