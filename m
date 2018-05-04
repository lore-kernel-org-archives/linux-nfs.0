Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:53176 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751747AbeEDTf7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 4 May 2018 15:35:59 -0400
Subject: [PATCH v1 17/19] xprtrdma: Wait on empty sendctx queue
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 04 May 2018 15:35:57 -0400
Message-ID: <20180504193557.31688.78933.stgit@manet.1015granger.net>
In-Reply-To: <20180504192748.31688.3678.stgit@manet.1015granger.net>
References: <20180504192748.31688.3678.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, when the sendctx queue is exhausted during marshaling, the
RPC/RDMA transport places the RPC task on the delayq, which forces a
wait for HZ >> 2 before the marshal and send is retried.

With this change, the transport now places such an RPC task on the
pending queue, and wakes it just as soon as more sendctxs become
available. This typically takes less than a millisecond, and the
write_space waking mechanism is less deadlock-prone.

Moreover, the waiting RPC task is holding the transport's write
lock, which blocks the transport from sending RPCs. Therefore faster
recovery from sendctx queue exhaustion is desirable.

Cf. commit 5804891455d5 ("xprtrdma: ->send_request returns -EAGAIN
when there are no free MRs").

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c  |    2 +-
 net/sunrpc/xprtrdma/verbs.c     |    8 +++++++-
 net/sunrpc/xprtrdma/xprt_rdma.h |    6 ++++++
 3 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index b12b044..a373d03 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -695,7 +695,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 {
 	req->rl_sendctx = rpcrdma_sendctx_get_locked(&r_xprt->rx_buf);
 	if (!req->rl_sendctx)
-		return -ENOBUFS;
+		return -EAGAIN;
 	req->rl_sendctx->sc_wr.num_sge = 0;
 	req->rl_sendctx->sc_unmap_count = 0;
 	req->rl_sendctx->sc_req = req;
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 4ccc9b2..042bb24 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -878,6 +878,7 @@ static int rpcrdma_sendctxs_create(struct rpcrdma_xprt *r_xprt)
 		sc->sc_xprt = r_xprt;
 		buf->rb_sc_ctxs[i] = sc;
 	}
+	buf->rb_flags = 0;
 
 	return 0;
 
@@ -935,7 +936,7 @@ struct rpcrdma_sendctx *rpcrdma_sendctx_get_locked(struct rpcrdma_buffer *buf)
 	 * completions recently. This is a sign the Send Queue is
 	 * backing up. Cause the caller to pause and try again.
 	 */
-	dprintk("RPC:       %s: empty sendctx queue\n", __func__);
+	set_bit(RPCRDMA_BUF_F_EMPTY_SCQ, &buf->rb_flags);
 	r_xprt = container_of(buf, struct rpcrdma_xprt, rx_buf);
 	r_xprt->rx_stats.empty_sendctx_q++;
 	return NULL;
@@ -970,6 +971,11 @@ struct rpcrdma_sendctx *rpcrdma_sendctx_get_locked(struct rpcrdma_buffer *buf)
 
 	/* Paired with READ_ONCE */
 	smp_store_release(&buf->rb_sc_tail, next_tail);
+
+	if (test_and_clear_bit(RPCRDMA_BUF_F_EMPTY_SCQ, &buf->rb_flags)) {
+		smp_mb__after_atomic();
+		xprt_write_space(&sc->sc_xprt->rx_xprt);
+	}
 }
 
 static void
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index f22bcdd..38973a9 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -400,6 +400,7 @@ struct rpcrdma_buffer {
 	spinlock_t		rb_lock;	/* protect buf lists */
 	struct list_head	rb_send_bufs;
 	struct list_head	rb_recv_bufs;
+	unsigned long		rb_flags;
 	u32			rb_max_requests;
 	u32			rb_credits;	/* most recent credit grant */
 	int			rb_posted_receives;
@@ -417,6 +418,11 @@ struct rpcrdma_buffer {
 };
 #define rdmab_to_ia(b) (&container_of((b), struct rpcrdma_xprt, rx_buf)->rx_ia)
 
+/* rb_flags */
+enum {
+	RPCRDMA_BUF_F_EMPTY_SCQ = 0,
+};
+
 /*
  * Internal structure for transport instance creation. This
  * exists primarily for modularity.

