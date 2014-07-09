Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f178.google.com ([209.85.223.178]:47882 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755181AbaGIQ56 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jul 2014 12:57:58 -0400
Subject: [PATCH v2 10/21] xprtrdma: Properly handle exhaustion of the rb_mws
 list
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 09 Jul 2014 12:57:55 -0400
Message-ID: <20140709165755.3496.28980.stgit@manet.1015granger.net>
In-Reply-To: <20140709163326.3496.37893.stgit@manet.1015granger.net>
References: <20140709163326.3496.37893.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the rb_mws list is exhausted, clean up and return NULL so that
call_allocate() will delay and try again.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |  103 ++++++++++++++++++++++++++++++-------------
 1 file changed, 71 insertions(+), 32 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index aa14a36..5796e09 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1256,6 +1256,67 @@ rpcrdma_buffer_destroy(struct rpcrdma_buffer *buf)
 	kfree(buf->rb_pool);
 }
 
+/* "*mw" can be NULL when rpcrdma_buffer_get_mrs() fails, leaving
+ * some req segments uninitialized.
+ */
+static void
+rpcrdma_buffer_put_mr(struct rpcrdma_mw **mw, struct rpcrdma_buffer *buf)
+{
+	if (*mw) {
+		list_add_tail(&(*mw)->mw_list, &buf->rb_mws);
+		*mw = NULL;
+	}
+}
+
+/* Cycle mw's back in reverse order, and "spin" them.
+ * This delays and scrambles reuse as much as possible.
+ */
+static void
+rpcrdma_buffer_put_mrs(struct rpcrdma_req *req, struct rpcrdma_buffer *buf)
+{
+	struct rpcrdma_mr_seg *seg = req->rl_segments;
+	struct rpcrdma_mr_seg *seg1 = seg;
+	int i;
+
+	for (i = 1, seg++; i < RPCRDMA_MAX_SEGS; seg++, i++)
+		rpcrdma_buffer_put_mr(&seg->mr_chunk.rl_mw, buf);
+	rpcrdma_buffer_put_mr(&seg1->mr_chunk.rl_mw, buf);
+}
+
+static void
+rpcrdma_buffer_put_sendbuf(struct rpcrdma_req *req, struct rpcrdma_buffer *buf)
+{
+	buf->rb_send_bufs[--buf->rb_send_index] = req;
+	req->rl_niovs = 0;
+	if (req->rl_reply) {
+		buf->rb_recv_bufs[--buf->rb_recv_index] = req->rl_reply;
+		req->rl_reply->rr_func = NULL;
+		req->rl_reply = NULL;
+	}
+}
+
+static struct rpcrdma_req *
+rpcrdma_buffer_get_mrs(struct rpcrdma_req *req, struct rpcrdma_buffer *buf)
+{
+	struct rpcrdma_mw *r;
+	int i;
+
+	i = RPCRDMA_MAX_SEGS - 1;
+	while (!list_empty(&buf->rb_mws)) {
+		r = list_entry(buf->rb_mws.next,
+			       struct rpcrdma_mw, mw_list);
+		list_del(&r->mw_list);
+		req->rl_segments[i].mr_chunk.rl_mw = r;
+		if (unlikely(i-- == 0))
+			return req;	/* Success */
+	}
+
+	/* Not enough entries on rb_mws for this req */
+	rpcrdma_buffer_put_sendbuf(req, buf);
+	rpcrdma_buffer_put_mrs(req, buf);
+	return NULL;
+}
+
 /*
  * Get a set of request/reply buffers.
  *
@@ -1268,10 +1329,9 @@ rpcrdma_buffer_destroy(struct rpcrdma_buffer *buf)
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
@@ -1291,14 +1351,13 @@ rpcrdma_buffer_get(struct rpcrdma_buffer *buffers)
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
+		req = rpcrdma_buffer_get_mrs(req, buffers);
+		break;
+	default:
+		break;
 	}
 	spin_unlock_irqrestore(&buffers->rb_lock, flags);
 	return req;
@@ -1313,34 +1372,14 @@ rpcrdma_buffer_put(struct rpcrdma_req *req)
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
+	rpcrdma_buffer_put_sendbuf(req, buffers);
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
+		rpcrdma_buffer_put_mrs(req, buffers);
 		break;
 	default:
 		break;

