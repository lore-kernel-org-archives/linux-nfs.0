Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:44854 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934569AbeB1Uak (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Feb 2018 15:30:40 -0500
Subject: [PATCH 3/8] xprtrdma: Remove xprt-specific connect cookie
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 28 Feb 2018 15:30:38 -0500
Message-ID: <20180228203038.25968.98317.stgit@manet.1015granger.net>
In-Reply-To: <20180228202916.25968.21750.stgit@manet.1015granger.net>
References: <20180228202916.25968.21750.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: The generic rq_connect_cookie is sufficient to detect RPC
Call retransmission.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/transport.c |    6 +-----
 net/sunrpc/xprtrdma/verbs.c     |    2 ++
 net/sunrpc/xprtrdma/xprt_rdma.h |    1 -
 3 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index f86021e..47b4604 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -236,8 +236,6 @@
 	struct rpc_xprt *xprt = &r_xprt->rx_xprt;
 
 	spin_lock_bh(&xprt->transport_lock);
-	if (++xprt->connect_cookie == 0)	/* maintain a reserved value */
-		++xprt->connect_cookie;
 	if (ep->rep_connected > 0) {
 		if (!xprt_test_and_set_connected(xprt))
 			xprt_wake_pending_tasks(xprt, 0);
@@ -650,7 +648,6 @@
 	if (!rpcrdma_get_recvbuf(r_xprt, req, rqst->rq_rcvsize, flags))
 		goto out_fail;
 
-	req->rl_connect_cookie = 0;	/* our reserved value */
 	rpcrdma_set_xprtdata(rqst, req);
 	rqst->rq_buffer = req->rl_sendbuf->rg_base;
 	rqst->rq_rbuffer = req->rl_recvbuf->rg_base;
@@ -721,9 +718,8 @@
 		rpcrdma_recv_buffer_get(req);
 
 	/* Must suppress retransmit to maintain credits */
-	if (req->rl_connect_cookie == xprt->connect_cookie)
+	if (rqst->rq_connect_cookie == xprt->connect_cookie)
 		goto drop_connection;
-	req->rl_connect_cookie = xprt->connect_cookie;
 
 	__set_bit(RPCRDMA_REQ_F_PENDING, &req->rl_flags);
 	if (rpcrdma_ep_post(&r_xprt->rx_ia, &r_xprt->rx_ep, req))
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 7cc3465..520e7e4 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -255,6 +255,7 @@
 		/* Return 1 to ensure the core destroys the id. */
 		return 1;
 	case RDMA_CM_EVENT_ESTABLISHED:
+		++xprt->rx_xprt.connect_cookie;
 		connstate = 1;
 		rpcrdma_update_connect_private(xprt, &event->param.conn);
 		goto connected;
@@ -273,6 +274,7 @@
 			connstate = -EAGAIN;
 		goto connected;
 	case RDMA_CM_EVENT_DISCONNECTED:
+		++xprt->rx_xprt.connect_cookie;
 		connstate = -ECONNABORTED;
 connected:
 		xprt->rx_buf.rb_credits = 1;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 430a6de..29ea0b4 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -334,7 +334,6 @@ enum {
 struct rpcrdma_buffer;
 struct rpcrdma_req {
 	struct list_head	rl_list;
-	unsigned int		rl_connect_cookie;
 	struct rpcrdma_buffer	*rl_buffer;
 	struct rpcrdma_rep	*rl_reply;
 	struct xdr_stream	rl_stream;

