Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f179.google.com ([209.85.223.179]:52670 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752726AbbAMQ1W (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Jan 2015 11:27:22 -0500
Subject: [PATCH v2 19/20] xprtrdma: Allocate zero pad separately from
 rpcrdma_buffer
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 13 Jan 2015 11:27:20 -0500
Message-ID: <20150113162720.14086.46651.stgit@manet.1015granger.net>
In-Reply-To: <20150113161440.14086.24801.stgit@manet.1015granger.net>
References: <20150113161440.14086.24801.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use the new rpcrdma_alloc_regbuf() API to shrink the amount of
contiguous memory needed for a buffer pool by moving the zero
pad buffer into a regbuf.

This is for consistency with the other uses of internally
registered memory.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c  |    4 ++--
 net/sunrpc/xprtrdma/verbs.c     |   29 ++++++++++-------------------
 net/sunrpc/xprtrdma/xprt_rdma.h |    3 +--
 3 files changed, 13 insertions(+), 23 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 02efcaa..7e9acd9 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -549,9 +549,9 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 	if (padlen) {
 		struct rpcrdma_ep *ep = &r_xprt->rx_ep;
 
-		req->rl_send_iov[2].addr = ep->rep_pad.addr;
+		req->rl_send_iov[2].addr = rdmab_addr(ep->rep_padbuf);
 		req->rl_send_iov[2].length = padlen;
-		req->rl_send_iov[2].lkey = ep->rep_pad.lkey;
+		req->rl_send_iov[2].lkey = rdmab_lkey(ep->rep_padbuf);
 
 		req->rl_send_iov[3].addr = req->rl_send_iov[1].addr + rpclen;
 		req->rl_send_iov[3].length = rqst->rq_slen - rpclen;
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 7aac422..669f68a 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -794,6 +794,14 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
 	ep->rep_attr.qp_type = IB_QPT_RC;
 	ep->rep_attr.port_num = ~0;
 
+	if (cdata->padding) {
+		ep->rep_padbuf = rpcrdma_alloc_regbuf(ia, cdata->padding,
+						      GFP_KERNEL);
+		if (IS_ERR(ep->rep_padbuf))
+			return PTR_ERR(ep->rep_padbuf);
+	} else
+		ep->rep_padbuf = NULL;
+
 	dprintk("RPC:       %s: requested max: dtos: send %d recv %d; "
 		"iovs: send %d recv %d\n",
 		__func__,
@@ -876,6 +884,7 @@ out2:
 		dprintk("RPC:       %s: ib_destroy_cq returned %i\n",
 			__func__, err);
 out1:
+	rpcrdma_free_regbuf(ia, ep->rep_padbuf);
 	return rc;
 }
 
@@ -902,11 +911,7 @@ rpcrdma_ep_destroy(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia)
 		ia->ri_id->qp = NULL;
 	}
 
-	/* padding - could be done in rpcrdma_buffer_destroy... */
-	if (ep->rep_pad_mr) {
-		rpcrdma_deregister_internal(ia, ep->rep_pad_mr, &ep->rep_pad);
-		ep->rep_pad_mr = NULL;
-	}
+	rpcrdma_free_regbuf(ia, ep->rep_padbuf);
 
 	rpcrdma_clean_cq(ep->rep_attr.recv_cq);
 	rc = ib_destroy_cq(ep->rep_attr.recv_cq);
@@ -1220,12 +1225,10 @@ rpcrdma_buffer_create(struct rpcrdma_xprt *r_xprt)
 	 *   1.  arrays for send and recv pointers
 	 *   2.  arrays of struct rpcrdma_req to fill in pointers
 	 *   3.  array of struct rpcrdma_rep for replies
-	 *   4.  padding, if any
 	 * Send/recv buffers in req/rep need to be registered
 	 */
 	len = buf->rb_max_requests *
 		(sizeof(struct rpcrdma_req *) + sizeof(struct rpcrdma_rep *));
-	len += cdata->padding;
 
 	p = kzalloc(len, GFP_KERNEL);
 	if (p == NULL) {
@@ -1241,18 +1244,6 @@ rpcrdma_buffer_create(struct rpcrdma_xprt *r_xprt)
 	buf->rb_recv_bufs = (struct rpcrdma_rep **) p;
 	p = (char *) &buf->rb_recv_bufs[buf->rb_max_requests];
 
-	/*
-	 * Register the zeroed pad buffer, if any.
-	 */
-	if (cdata->padding) {
-		struct rpcrdma_ep *ep = &r_xprt->rx_ep;
-		rc = rpcrdma_register_internal(ia, p, cdata->padding,
-					    &ep->rep_pad_mr, &ep->rep_pad);
-		if (rc)
-			goto out;
-	}
-	p += cdata->padding;
-
 	INIT_LIST_HEAD(&buf->rb_mws);
 	INIT_LIST_HEAD(&buf->rb_all);
 	switch (ia->ri_memreg_strategy) {
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 2b69316..5630353 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -88,8 +88,7 @@ struct rpcrdma_ep {
 	int			rep_connected;
 	struct ib_qp_init_attr	rep_attr;
 	wait_queue_head_t 	rep_connect_wait;
-	struct ib_sge		rep_pad;	/* holds zeroed pad */
-	struct ib_mr		*rep_pad_mr;	/* holds zeroed pad */
+	struct rpcrdma_regbuf	*rep_padbuf;
 	struct rdma_conn_param	rep_remote_cma;
 	struct sockaddr_storage	rep_remote_addr;
 	struct delayed_work	rep_connect_worker;

