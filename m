Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f174.google.com ([209.85.213.174]:40459 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753178AbaEVA5Z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 May 2014 20:57:25 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v4 22/24] xprtrdma: Avoid deadlock when credit window is reset
To: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date: Wed, 21 May 2014 20:57:23 -0400
Message-ID: <20140522005723.27190.90796.stgit@manet.1015granger.net>
In-Reply-To: <20140522004505.27190.58897.stgit@manet.1015granger.net>
References: <20140522004505.27190.58897.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Update the cwnd from the server's reply before invoking
__xprt_put_cong(). Otherwise the next task on the xprt_sending queue
is still subject to the old credit window. Currently, no task is
awoken if the old congestion window is still exceeded, even if the
new window is larger, and a deadlock results.

This is an issue during a transport reconnect. Servers don't
normally shrink the credit window, but the client does reset it to
1 when reconnecting so the server can safely grow it again.

As a minor optimization, remove the hack of grabbing the initial
cwnd size (which happens to be RPC_CWNDSCALE) and using that value
as the congestion scaling factor. The scaling value is invariant,
and we are better off without the multiplication operation.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtrdma/rpc_rdma.c  |    3 +++
 net/sunrpc/xprtrdma/transport.c |   19 +------------------
 net/sunrpc/xprtrdma/xprt_rdma.h |    1 -
 3 files changed, 4 insertions(+), 19 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 1334646..82173c7 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -846,6 +846,9 @@ badheader:
 		break;
 	}
 
+	xprt->cwnd = atomic_read(&r_xprt->rx_buf.rb_credits) << RPC_CWNDSHIFT;
+	xprt_release_rqst_cong(rqst->rq_task);
+
 	dprintk("RPC:       %s: xprt_complete_rqst(0x%p, 0x%p, %d)\n",
 			__func__, xprt, rqst, status);
 	xprt_complete_rqst(rqst->rq_task, status);
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 04b7452..65cfaca 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -448,23 +448,6 @@ xprt_rdma_connect(struct rpc_xprt *xprt, struct rpc_task *task)
 	}
 }
 
-static int
-xprt_rdma_reserve_xprt(struct rpc_xprt *xprt, struct rpc_task *task)
-{
-	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
-	int credits = atomic_read(&r_xprt->rx_buf.rb_credits);
-
-	/* == RPC_CWNDSCALE @ init, but *after* setup */
-	if (r_xprt->rx_buf.rb_cwndscale == 0UL) {
-		r_xprt->rx_buf.rb_cwndscale = xprt->cwnd;
-		dprintk("RPC:       %s: cwndscale %lu\n", __func__,
-			r_xprt->rx_buf.rb_cwndscale);
-		BUG_ON(r_xprt->rx_buf.rb_cwndscale <= 0);
-	}
-	xprt->cwnd = credits * r_xprt->rx_buf.rb_cwndscale;
-	return xprt_reserve_xprt_cong(xprt, task);
-}
-
 /*
  * The RDMA allocate/free functions need the task structure as a place
  * to hide the struct rpcrdma_req, which is necessary for the actual send/recv
@@ -686,7 +669,7 @@ static void xprt_rdma_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
  */
 
 static struct rpc_xprt_ops xprt_rdma_procs = {
-	.reserve_xprt		= xprt_rdma_reserve_xprt,
+	.reserve_xprt		= xprt_reserve_xprt_cong,
 	.release_xprt		= xprt_release_xprt_cong, /* sunrpc/xprt.c */
 	.alloc_slot		= xprt_alloc_slot,
 	.release_request	= xprt_release_rqst_cong,       /* ditto */
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 0c3b88e..89e7cd4 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -212,7 +212,6 @@ struct rpcrdma_req {
 struct rpcrdma_buffer {
 	spinlock_t	rb_lock;	/* protects indexes */
 	atomic_t	rb_credits;	/* most recent server credits */
-	unsigned long	rb_cwndscale;	/* cached framework rpc_cwndscale */
 	int		rb_max_requests;/* client max requests */
 	struct list_head rb_mws;	/* optional memory windows/fmrs/frmrs */
 	int		rb_send_index;

