From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 33/39] nfs41: Rename rq_received to rq_reply_bytes_recvd
Date: Fri,  1 May 2009 02:24:52 +0300
Message-ID: <1241133892-1390-1-git-send-email-bhalevy@panasas.com>
References: <49FA3180.5030404@panasas.com>
Cc: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:4851 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758885AbZD3XZN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 19:25:13 -0400
In-Reply-To: <49FA3180.5030404@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>

The 'rq_received' member of 'struct rpc_rqst' is used to track when we
have received a reply to our request.  With v4.1, the backchannel
can now accept callback requests over the existing connection.  Rename
this field to make it clear that it is only used for tracking reply bytes
and not all bytes received on the connection.

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/sunrpc/xprt.h   |    3 ++-
 net/sunrpc/backchannel_rqst.c |    2 +-
 net/sunrpc/clnt.c             |    8 ++++----
 net/sunrpc/stats.c            |    2 +-
 net/sunrpc/xprt.c             |   15 ++++++++-------
 5 files changed, 16 insertions(+), 14 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 1531abe..3b710a7 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -67,7 +67,8 @@ struct rpc_rqst {
 	struct rpc_task *	rq_task;	/* RPC task data */
 	__be32			rq_xid;		/* request XID */
 	int			rq_cong;	/* has incremented xprt->cong */
-	int			rq_received;	/* receive completed */
+	int			rq_reply_bytes_recvd;	/* number of reply */
+							/* bytes received */
 	u32			rq_seqno;	/* gss seq no. used on req. */
 	int			rq_enc_pages_num;
 	struct page		**rq_enc_pages;	/* scratch pages for use by
diff --git a/net/sunrpc/backchannel_rqst.c b/net/sunrpc/backchannel_rqst.c
index 92fb3bd..8f177a5 100644
--- a/net/sunrpc/backchannel_rqst.c
+++ b/net/sunrpc/backchannel_rqst.c
@@ -221,7 +221,7 @@ struct rpc_rqst *xprt_alloc_bc_request(struct rpc_xprt *xprt)
 
 	if (req != NULL) {
 		set_bit(RPC_BC_PA_IN_USE, &req->rq_bc_pa_state);
-		req->rq_received = 0;
+		req->rq_reply_bytes_recvd = 0;
 		req->rq_bytes_sent = 0;
 		memcpy(&req->rq_private_buf, &req->rq_rcv_buf,
 			sizeof(req->rq_private_buf));
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 349b4d6..2a9f843 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1258,8 +1258,8 @@ call_status(struct rpc_task *task)
 	struct rpc_rqst	*req = task->tk_rqstp;
 	int		status;
 
-	if (req->rq_received > 0 && !req->rq_bytes_sent)
-		task->tk_status = req->rq_received;
+	if (req->rq_reply_bytes_recvd > 0 && !req->rq_bytes_sent)
+		task->tk_status = req->rq_reply_bytes_recvd;
 
 	dprint_status(task);
 
@@ -1376,7 +1376,7 @@ call_decode(struct rpc_task *task)
 
 	/*
 	 * Ensure that we see all writes made by xprt_complete_rqst()
-	 * before it changed req->rq_received.
+	 * before it changed req->rq_reply_bytes_recvd.
 	 */
 	smp_rmb();
 	req->rq_rcv_buf.len = req->rq_private_buf.len;
@@ -1417,7 +1417,7 @@ out_retry:
 	task->tk_status = 0;
 	/* Note: rpc_verify_header() may have freed the RPC slot */
 	if (task->tk_rqstp == req) {
-		req->rq_received = req->rq_rcv_buf.len = 0;
+		req->rq_reply_bytes_recvd = req->rq_rcv_buf.len = 0;
 		if (task->tk_client->cl_discrtry)
 			xprt_conditional_disconnect(task->tk_xprt,
 					req->rq_connect_cookie);
diff --git a/net/sunrpc/stats.c b/net/sunrpc/stats.c
index a0e3d97..c1517e2 100644
--- a/net/sunrpc/stats.c
+++ b/net/sunrpc/stats.c
@@ -156,7 +156,7 @@ void rpc_count_iostats(struct rpc_task *task)
 	op_metrics->om_timeouts += task->tk_timeouts;
 
 	op_metrics->om_bytes_sent += task->tk_bytes_sent;
-	op_metrics->om_bytes_recv += req->rq_received;
+	op_metrics->om_bytes_recv += req->rq_reply_bytes_recvd;
 
 	queue = (long)req->rq_xtime - task->tk_start;
 	if (queue < 0)
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index c73b31f..463d810 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -808,9 +808,10 @@ void xprt_complete_rqst(struct rpc_task *task, int copied)
 
 	list_del_init(&req->rq_list);
 	req->rq_private_buf.len = copied;
-	/* Ensure all writes are done before we update req->rq_received */
+	/* Ensure all writes are done before we update */
+	/* req->rq_reply_bytes_recvd */
 	smp_wmb();
-	req->rq_received = copied;
+	req->rq_reply_bytes_recvd = copied;
 	rpc_wake_up_queued_task(&xprt->pending, task);
 }
 EXPORT_SYMBOL_GPL(xprt_complete_rqst);
@@ -825,7 +826,7 @@ static void xprt_timer(struct rpc_task *task)
 	dprintk("RPC: %5u xprt_timer\n", task->tk_pid);
 
 	spin_lock_bh(&xprt->transport_lock);
-	if (!req->rq_received) {
+	if (!req->rq_reply_bytes_recvd) {
 		if (xprt->ops->timer)
 			xprt->ops->timer(task);
 	} else
@@ -847,8 +848,8 @@ int xprt_prepare_transmit(struct rpc_task *task)
 	dprintk("RPC: %5u xprt_prepare_transmit\n", task->tk_pid);
 
 	spin_lock_bh(&xprt->transport_lock);
-	if (req->rq_received && !req->rq_bytes_sent) {
-		err = req->rq_received;
+	if (req->rq_reply_bytes_recvd && !req->rq_bytes_sent) {
+		err = req->rq_reply_bytes_recvd;
 		goto out_unlock;
 	}
 	if (!xprt->ops->reserve_xprt(task))
@@ -877,7 +878,7 @@ void xprt_transmit(struct rpc_task *task)
 
 	dprintk("RPC: %5u xprt_transmit(%u)\n", task->tk_pid, req->rq_slen);
 
-	if (!req->rq_received) {
+	if (!req->rq_reply_bytes_recvd) {
 		if (list_empty(&req->rq_list) && rpc_reply_expected(task)) {
 			/*
 			 * Add to the list only if we're expecting a reply
@@ -916,7 +917,7 @@ void xprt_transmit(struct rpc_task *task)
 	/* Don't race with disconnect */
 	if (!xprt_connected(xprt))
 		task->tk_status = -ENOTCONN;
-	else if (!req->rq_received && rpc_reply_expected(task)) {
+	else if (!req->rq_reply_bytes_recvd && rpc_reply_expected(task)) {
 		/*
 		 * Sleep on the pending queue since
 		 * we're expecting a reply.
-- 
1.6.2.1

