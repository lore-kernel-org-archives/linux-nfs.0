Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f180.google.com ([209.85.213.180]:37479 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753277AbbAUQDF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Jan 2015 11:03:05 -0500
Subject: [PATCH v3 08/20] xprtrdma: Move credit update to RPC reply handler
From: Chuck Lever <chuck.lever@oracle.com>
To: Anna.Schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 21 Jan 2015 11:03:02 -0500
Message-ID: <20150121160302.17297.85205.stgit@manet.1015granger.net>
In-Reply-To: <20150121155303.17297.47423.stgit@manet.1015granger.net>
References: <20150121155303.17297.47423.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Reduce work in the receive CQ handler, which can be run at hardware
interrupt level, by moving the RPC/RDMA credit update logic to the
RPC reply handler.

This has some additional benefits: More header sanity checking is
done before trusting the incoming credit value, and the receive CQ
handler no longer touches the RPC/RDMA header (the CPU stalls while
waiting for the header contents to be brought into the cache).

This further extends work begun by commit e7ce710a8802 ("xprtrdma:
Avoid deadlock when credit window is reset").

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Steve Wise <swise@opengridcomputing.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c  |   10 ++++++++--
 net/sunrpc/xprtrdma/verbs.c     |   15 ++-------------
 net/sunrpc/xprtrdma/xprt_rdma.h |    1 -
 3 files changed, 10 insertions(+), 16 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index dcf5ebc..d731010 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -736,7 +736,7 @@ rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 	struct rpc_xprt *xprt = rep->rr_xprt;
 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
 	__be32 *iptr;
-	int rdmalen, status;
+	int credits, rdmalen, status;
 	unsigned long cwnd;
 
 	/* Check status. If bad, signal disconnect and return rep to pool */
@@ -871,8 +871,14 @@ badheader:
 		break;
 	}
 
+	credits = be32_to_cpu(headerp->rm_credit);
+	if (credits == 0)
+		credits = 1;	/* don't deadlock */
+	else if (credits > r_xprt->rx_buf.rb_max_requests)
+		credits = r_xprt->rx_buf.rb_max_requests;
+
 	cwnd = xprt->cwnd;
-	xprt->cwnd = atomic_read(&r_xprt->rx_buf.rb_credits) << RPC_CWNDSHIFT;
+	xprt->cwnd = credits << RPC_CWNDSHIFT;
 	if (xprt->cwnd > cwnd)
 		xprt_release_rqst_cong(rqst->rq_task);
 
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 1000f63..71a071a 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -49,6 +49,7 @@
 
 #include <linux/interrupt.h>
 #include <linux/slab.h>
+#include <linux/prefetch.h>
 #include <asm/bitops.h>
 
 #include "xprt_rdma.h"
@@ -298,17 +299,7 @@ rpcrdma_recvcq_process_wc(struct ib_wc *wc, struct list_head *sched_list)
 	rep->rr_len = wc->byte_len;
 	ib_dma_sync_single_for_cpu(rdmab_to_ia(rep->rr_buffer)->ri_id->device,
 			rep->rr_iov.addr, rep->rr_len, DMA_FROM_DEVICE);
-
-	if (rep->rr_len >= 16) {
-		struct rpcrdma_msg *p = (struct rpcrdma_msg *)rep->rr_base;
-		unsigned int credits = ntohl(p->rm_credit);
-
-		if (credits == 0)
-			credits = 1;	/* don't deadlock */
-		else if (credits > rep->rr_buffer->rb_max_requests)
-			credits = rep->rr_buffer->rb_max_requests;
-		atomic_set(&rep->rr_buffer->rb_credits, credits);
-	}
+	prefetch(rep->rr_base);
 
 out_schedule:
 	list_add_tail(&rep->rr_list, sched_list);
@@ -480,7 +471,6 @@ rpcrdma_conn_upcall(struct rdma_cm_id *id, struct rdma_cm_event *event)
 	case RDMA_CM_EVENT_DEVICE_REMOVAL:
 		connstate = -ENODEV;
 connected:
-		atomic_set(&rpcx_to_rdmax(ep->rep_xprt)->rx_buf.rb_credits, 1);
 		dprintk("RPC:       %s: %sconnected\n",
 					__func__, connstate > 0 ? "" : "dis");
 		ep->rep_connected = connstate;
@@ -1186,7 +1176,6 @@ rpcrdma_buffer_create(struct rpcrdma_buffer *buf, struct rpcrdma_ep *ep,
 
 	buf->rb_max_requests = cdata->max_requests;
 	spin_lock_init(&buf->rb_lock);
-	atomic_set(&buf->rb_credits, 1);
 
 	/* Need to allocate:
 	 *   1.  arrays for send and recv pointers
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 532d586..3fcc92b 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -248,7 +248,6 @@ struct rpcrdma_req {
  */
 struct rpcrdma_buffer {
 	spinlock_t	rb_lock;	/* protects indexes */
-	atomic_t	rb_credits;	/* most recent server credits */
 	int		rb_max_requests;/* client max requests */
 	struct list_head rb_mws;	/* optional memory windows/fmrs/frmrs */
 	struct list_head rb_all;

