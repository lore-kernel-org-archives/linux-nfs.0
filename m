Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:36854 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752438AbbJXV12 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Oct 2015 17:27:28 -0400
Subject: [PATCH v4 08/16] xprtrdma: Saving IRQs no longer needed for rb_lock
From: Chuck Lever <chuck.lever@oracle.com>
To: Anna.Schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Sat, 24 Oct 2015 17:27:27 -0400
Message-ID: <20151024212727.4715.18805.stgit@manet.1015granger.net>
In-Reply-To: <20151024211707.4715.61650.stgit@manet.1015granger.net>
References: <20151024211707.4715.61650.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that RPC replies are processed in a workqueue, there's no need
to disable IRQs when managing send and receive buffers. This saves
noticeable overhead per RPC.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Sagi Grimberg <sagig@mellanox.com>
Tested-By: Devesh Sharma <devesh.sharma@avagotech.com>
---
 net/sunrpc/xprtrdma/verbs.c |   24 ++++++++++--------------
 1 file changed, 10 insertions(+), 14 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 3dd5a7c..baa0523 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1063,24 +1063,23 @@ struct rpcrdma_req *
 rpcrdma_buffer_get(struct rpcrdma_buffer *buffers)
 {
 	struct rpcrdma_req *req;
-	unsigned long flags;
 
-	spin_lock_irqsave(&buffers->rb_lock, flags);
+	spin_lock(&buffers->rb_lock);
 	if (list_empty(&buffers->rb_send_bufs))
 		goto out_reqbuf;
 	req = rpcrdma_buffer_get_req_locked(buffers);
 	if (list_empty(&buffers->rb_recv_bufs))
 		goto out_repbuf;
 	req->rl_reply = rpcrdma_buffer_get_rep_locked(buffers);
-	spin_unlock_irqrestore(&buffers->rb_lock, flags);
+	spin_unlock(&buffers->rb_lock);
 	return req;
 
 out_reqbuf:
-	spin_unlock_irqrestore(&buffers->rb_lock, flags);
+	spin_unlock(&buffers->rb_lock);
 	pr_warn("RPC:       %s: out of request buffers\n", __func__);
 	return NULL;
 out_repbuf:
-	spin_unlock_irqrestore(&buffers->rb_lock, flags);
+	spin_unlock(&buffers->rb_lock);
 	pr_warn("RPC:       %s: out of reply buffers\n", __func__);
 	req->rl_reply = NULL;
 	return req;
@@ -1095,16 +1094,15 @@ rpcrdma_buffer_put(struct rpcrdma_req *req)
 {
 	struct rpcrdma_buffer *buffers = req->rl_buffer;
 	struct rpcrdma_rep *rep = req->rl_reply;
-	unsigned long flags;
 
 	req->rl_niovs = 0;
 	req->rl_reply = NULL;
 
-	spin_lock_irqsave(&buffers->rb_lock, flags);
+	spin_lock(&buffers->rb_lock);
 	list_add_tail(&req->rl_free, &buffers->rb_send_bufs);
 	if (rep)
 		list_add_tail(&rep->rr_list, &buffers->rb_recv_bufs);
-	spin_unlock_irqrestore(&buffers->rb_lock, flags);
+	spin_unlock(&buffers->rb_lock);
 }
 
 /*
@@ -1115,12 +1113,11 @@ void
 rpcrdma_recv_buffer_get(struct rpcrdma_req *req)
 {
 	struct rpcrdma_buffer *buffers = req->rl_buffer;
-	unsigned long flags;
 
-	spin_lock_irqsave(&buffers->rb_lock, flags);
+	spin_lock(&buffers->rb_lock);
 	if (!list_empty(&buffers->rb_recv_bufs))
 		req->rl_reply = rpcrdma_buffer_get_rep_locked(buffers);
-	spin_unlock_irqrestore(&buffers->rb_lock, flags);
+	spin_unlock(&buffers->rb_lock);
 }
 
 /*
@@ -1131,11 +1128,10 @@ void
 rpcrdma_recv_buffer_put(struct rpcrdma_rep *rep)
 {
 	struct rpcrdma_buffer *buffers = &rep->rr_rxprt->rx_buf;
-	unsigned long flags;
 
-	spin_lock_irqsave(&buffers->rb_lock, flags);
+	spin_lock(&buffers->rb_lock);
 	list_add_tail(&rep->rr_list, &buffers->rb_recv_bufs);
-	spin_unlock_irqrestore(&buffers->rb_lock, flags);
+	spin_unlock(&buffers->rb_lock);
 }
 
 /*

