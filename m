Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f182.google.com ([209.85.160.182]:34962 "EHLO
	mail-yk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752153AbbJEXDh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Oct 2015 19:03:37 -0400
Received: by ykdz138 with SMTP id z138so186606968ykd.2
        for <linux-nfs@vger.kernel.org>; Mon, 05 Oct 2015 16:03:36 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC PATCH 3/3] SUNRPC: Allow TCP to replace the bh-safe lock in receive path
Date: Mon,  5 Oct 2015 19:03:31 -0400
Message-Id: <1444086211-4811-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1444086211-4811-2-git-send-email-trond.myklebust@primarydata.com>
References: <1444086211-4811-1-git-send-email-trond.myklebust@primarydata.com>
 <1444086211-4811-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch attempts to eke out a couple more iops by allowing the TCP code
to replace bh-safe spinlock with an ordinary one while receiving data. We
still need to use the bh-safe spinlock when completing.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprt.c     |  4 ++++
 net/sunrpc/xprtsock.c | 17 ++++++++++-------
 2 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 2e98f4a243e5..e604bb680bcf 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -951,6 +951,7 @@ void xprt_transmit(struct rpc_task *task)
 			/*
 			 * Add to the list only if we're expecting a reply
 			 */
+			spin_lock(&xprt->reserve_lock);
 			spin_lock_bh(&xprt->transport_lock);
 			/* Update the softirq receive buffer */
 			memcpy(&req->rq_private_buf, &req->rq_rcv_buf,
@@ -958,6 +959,7 @@ void xprt_transmit(struct rpc_task *task)
 			/* Add request to the receive list */
 			list_add_tail(&req->rq_list, &xprt->recv);
 			spin_unlock_bh(&xprt->transport_lock);
+			spin_unlock(&xprt->reserve_lock);
 			xprt_reset_majortimeo(req);
 			/* Turn off autodisconnect */
 			del_singleshot_timer_sync(&xprt->timer);
@@ -1278,6 +1280,7 @@ void xprt_release(struct rpc_task *task)
 		task->tk_ops->rpc_count_stats(task, task->tk_calldata);
 	else if (task->tk_client)
 		rpc_count_iostats(task, task->tk_client->cl_metrics);
+	spin_lock(&xprt->reserve_lock);
 	spin_lock_bh(&xprt->transport_lock);
 	xprt->ops->release_xprt(xprt, task);
 	if (xprt->ops->release_request)
@@ -1289,6 +1292,7 @@ void xprt_release(struct rpc_task *task)
 		mod_timer(&xprt->timer,
 				xprt->last_used + xprt->idle_timeout);
 	spin_unlock_bh(&xprt->transport_lock);
+	spin_unlock(&xprt->reserve_lock);
 	if (req->rq_buffer)
 		xprt->ops->buf_free(req->rq_buffer);
 	xprt_inject_disconnect(xprt);
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 58dc90ccebb6..063d2eb20d8e 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1246,21 +1246,24 @@ static inline int xs_tcp_read_reply(struct rpc_xprt *xprt,
 	dprintk("RPC:       read reply XID %08x\n", ntohl(transport->tcp_xid));
 
 	/* Find and lock the request corresponding to this xid */
-	spin_lock_bh(&xprt->transport_lock);
+	spin_lock(&xprt->reserve_lock);
 	req = xprt_lookup_rqst(xprt, transport->tcp_xid);
 	if (!req) {
 		dprintk("RPC:       XID %08x request not found!\n",
 				ntohl(transport->tcp_xid));
-		spin_unlock_bh(&xprt->transport_lock);
+		spin_unlock(&xprt->reserve_lock);
 		return -1;
 	}
 
 	xs_tcp_read_common(xprt, desc, req);
 
-	if (!(transport->tcp_flags & TCP_RCV_COPY_DATA))
+	if (!(transport->tcp_flags & TCP_RCV_COPY_DATA)) {
+		spin_lock_bh(&xprt->transport_lock);
 		xprt_complete_rqst(req->rq_task, transport->tcp_copied);
+		spin_unlock_bh(&xprt->transport_lock);
+	}
 
-	spin_unlock_bh(&xprt->transport_lock);
+	spin_unlock(&xprt->reserve_lock);
 	return 0;
 }
 
@@ -1280,10 +1283,10 @@ static int xs_tcp_read_callback(struct rpc_xprt *xprt,
 	struct rpc_rqst *req;
 
 	/* Look up and lock the request corresponding to the given XID */
-	spin_lock_bh(&xprt->transport_lock);
+	spin_lock(&xprt->reserve_lock);
 	req = xprt_lookup_bc_request(xprt, transport->tcp_xid);
 	if (req == NULL) {
-		spin_unlock_bh(&xprt->transport_lock);
+		spin_unlock(&xprt->reserve_lock);
 		printk(KERN_WARNING "Callback slot table overflowed\n");
 		xprt_force_disconnect(xprt);
 		return -1;
@@ -1294,7 +1297,7 @@ static int xs_tcp_read_callback(struct rpc_xprt *xprt,
 
 	if (!(transport->tcp_flags & TCP_RCV_COPY_DATA))
 		xprt_complete_bc_request(req, transport->tcp_copied);
-	spin_unlock_bh(&xprt->transport_lock);
+	spin_unlock(&xprt->reserve_lock);
 
 	return 0;
 }
-- 
2.4.3

