Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f176.google.com ([209.85.223.176]:34227 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751400AbaFWWkR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jun 2014 18:40:17 -0400
Subject: [PATCH v1 09/13] xprtrdma: Refactor rpcrdma_buffer_put()
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 23 Jun 2014 18:40:15 -0400
Message-ID: <20140623224015.1634.35375.stgit@manet.1015granger.net>
In-Reply-To: <20140623223201.1634.83888.stgit@manet.1015granger.net>
References: <20140623223201.1634.83888.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Split out the code that manages the rb_mws list.

A little extra error checking is introduced in the code path that
grabs MWs for the next RPC request. If rb_mws were ever to become
empty, the list_entry() would cause a NULL pointer dereference.

Instead, now rpcrdma_buffer_get() returns NULL, which causes
call_allocate() to delay and try again.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c     |  105 +++++++++++++++++++++++++++------------
 net/sunrpc/xprtrdma/xprt_rdma.h |    1 
 2 files changed, 74 insertions(+), 32 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 3efc007..f24f0bf 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1251,6 +1251,69 @@ rpcrdma_buffer_destroy(struct rpcrdma_buffer *buf)
 	kfree(buf->rb_pool);
 }
 
+static void
+rpcrdma_put_mw_locked(struct rpcrdma_mw *mw)
+{
+	list_add_tail(&mw->mw_list, &mw->mw_pool->rb_mws);
+}
+
+static void
+rpcrdma_buffer_put_mw(struct rpcrdma_mw **mw)
+{
+	rpcrdma_put_mw_locked(*mw);
+	*mw = NULL;
+}
+
+/* Cycle mw's back in reverse order, and "spin" them.
+ * This delays and scrambles reuse as much as possible.
+ */
+static void
+rpcrdma_buffer_put_mws(struct rpcrdma_req *req)
+{
+	struct rpcrdma_mr_seg *seg1 = req->rl_segments;
+	struct rpcrdma_mr_seg *seg = seg1;
+	int i;
+
+	for (i = 1, seg++; i < RPCRDMA_MAX_SEGS; seg++, i++)
+		rpcrdma_buffer_put_mw(&seg->mr_chunk.rl_mw);
+	rpcrdma_buffer_put_mw(&seg1->mr_chunk.rl_mw);
+}
+
+static void
+rpcrdma_send_buffer_put(struct rpcrdma_req *req, struct rpcrdma_buffer *buffers)
+{
+	buffers->rb_send_bufs[--buffers->rb_send_index] = req;
+	req->rl_niovs = 0;
+	if (req->rl_reply) {
+		buffers->rb_recv_bufs[--buffers->rb_recv_index] = req->rl_reply;
+		req->rl_reply->rr_func = NULL;
+		req->rl_reply = NULL;
+	}
+}
+
+static struct rpcrdma_req *
+rpcrdma_buffer_get_mws(struct rpcrdma_req *req, struct rpcrdma_buffer *buffers)
+{
+	struct rpcrdma_mw *r;
+	int i;
+
+	for (i = RPCRDMA_MAX_SEGS - 1; i >= 0; i--) {
+		if (list_empty(&buffers->rb_mws))
+			goto out_empty;
+
+		r = list_entry(buffers->rb_mws.next,
+				struct rpcrdma_mw, mw_list);
+		list_del(&r->mw_list);
+		r->mw_pool = buffers;
+		req->rl_segments[i].mr_chunk.rl_mw = r;
+	}
+	return req;
+out_empty:
+	rpcrdma_send_buffer_put(req, buffers);
+	rpcrdma_buffer_put_mws(req);
+	return NULL;
+}
+
 /*
  * Get a set of request/reply buffers.
  *
@@ -1263,10 +1326,9 @@ rpcrdma_buffer_destroy(struct rpcrdma_buffer *buf)
 struct rpcrdma_req *
 rpcrdma_buffer_get(struct rpcrdma_buffer *buffers)
 {
+	struct rpcrdma_ia *ia = rdmab_to_ia(buffers);
 	struct rpcrdma_req *req;
 	unsigned long flags;
-	int i;
-	struct rpcrdma_mw *r;
 
 	spin_lock_irqsave(&buffers->rb_lock, flags);
 	if (buffers->rb_send_index == buffers->rb_max_requests) {
@@ -1286,14 +1348,13 @@ rpcrdma_buffer_get(struct rpcrdma_buffer *buffers)
 		buffers->rb_recv_bufs[buffers->rb_recv_index++] = NULL;
 	}
 	buffers->rb_send_bufs[buffers->rb_send_index++] = NULL;
-	if (!list_empty(&buffers->rb_mws)) {
-		i = RPCRDMA_MAX_SEGS - 1;
-		do {
-			r = list_entry(buffers->rb_mws.next,
-					struct rpcrdma_mw, mw_list);
-			list_del(&r->mw_list);
-			req->rl_segments[i].mr_chunk.rl_mw = r;
-		} while (--i >= 0);
+	switch (ia->ri_memreg_strategy) {
+	case RPCRDMA_FRMR:
+	case RPCRDMA_MTHCAFMR:
+		req = rpcrdma_buffer_get_mws(req, buffers);
+		break;
+	default:
+		break;
 	}
 	spin_unlock_irqrestore(&buffers->rb_lock, flags);
 	return req;
@@ -1308,34 +1369,14 @@ rpcrdma_buffer_put(struct rpcrdma_req *req)
 {
 	struct rpcrdma_buffer *buffers = req->rl_buffer;
 	struct rpcrdma_ia *ia = rdmab_to_ia(buffers);
-	int i;
 	unsigned long flags;
 
 	spin_lock_irqsave(&buffers->rb_lock, flags);
-	buffers->rb_send_bufs[--buffers->rb_send_index] = req;
-	req->rl_niovs = 0;
-	if (req->rl_reply) {
-		buffers->rb_recv_bufs[--buffers->rb_recv_index] = req->rl_reply;
-		req->rl_reply->rr_func = NULL;
-		req->rl_reply = NULL;
-	}
+	rpcrdma_send_buffer_put(req, buffers);
 	switch (ia->ri_memreg_strategy) {
 	case RPCRDMA_FRMR:
 	case RPCRDMA_MTHCAFMR:
-		/*
-		 * Cycle mw's back in reverse order, and "spin" them.
-		 * This delays and scrambles reuse as much as possible.
-		 */
-		i = 1;
-		do {
-			struct rpcrdma_mw **mw;
-			mw = &req->rl_segments[i].mr_chunk.rl_mw;
-			list_add_tail(&(*mw)->mw_list, &buffers->rb_mws);
-			*mw = NULL;
-		} while (++i < RPCRDMA_MAX_SEGS);
-		list_add_tail(&req->rl_segments[0].mr_chunk.rl_mw->mw_list,
-					&buffers->rb_mws);
-		req->rl_segments[0].mr_chunk.rl_mw = NULL;
+		rpcrdma_buffer_put_mws(req);
 		break;
 	default:
 		break;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 6b5d243..b81e5b5 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -175,6 +175,7 @@ struct rpcrdma_mw {
 		struct rpcrdma_frmr	frmr;
 	} r;
 	struct list_head	mw_list;
+	struct rpcrdma_buffer	*mw_pool;
 };
 
 #define RPCRDMA_BIT_FASTREG		(0)

