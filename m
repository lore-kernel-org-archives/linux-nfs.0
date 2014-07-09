Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f182.google.com ([209.85.213.182]:61540 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756044AbaGIQ6O (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jul 2014 12:58:14 -0400
Subject: [PATCH v2 12/21] xprtrdma: Reset FRMRs after a flushed LOCAL_INV
 Work Request
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 09 Jul 2014 12:58:12 -0400
Message-ID: <20140709165812.3496.93326.stgit@manet.1015granger.net>
In-Reply-To: <20140709163326.3496.37893.stgit@manet.1015granger.net>
References: <20140709163326.3496.37893.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When a LOCAL_INV Work Request is flushed, it leaves an FRMR in the
VALID state. This FRMR can be returned by rpcrdma_buffer_get(), and
must be knocked down in rpcrdma_register_frmr_external() before it
can be re-used.

Instead, capture these in rpcrdma_buffer_get(), and reset them.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |   94 ++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 92 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 56b7979..877c928 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1358,8 +1358,91 @@ rpcrdma_buffer_put_sendbuf(struct rpcrdma_req *req, struct rpcrdma_buffer *buf)
 	}
 }
 
+/* rpcrdma_unmap_one() was already done by rpcrdma_deregister_frmr_external().
+ * Redo only the ib_post_send().
+ */
+static void
+rpcrdma_retry_local_inv(struct rpcrdma_mw *r, struct rpcrdma_ia *ia)
+{
+	struct rpcrdma_xprt *r_xprt =
+				container_of(ia, struct rpcrdma_xprt, rx_ia);
+	struct ib_send_wr invalidate_wr, *bad_wr;
+	int rc;
+
+	dprintk("RPC:       %s: FRMR %p is stale\n", __func__, r);
+
+	/* When this FRMR is re-inserted into rb_mws, it is no longer stale */
+	r->r.frmr.fr_state = FRMR_IS_VALID;
+
+	memset(&invalidate_wr, 0, sizeof(invalidate_wr));
+	invalidate_wr.wr_id = (unsigned long)(void *)r;
+	invalidate_wr.opcode = IB_WR_LOCAL_INV;
+	invalidate_wr.send_flags = IB_SEND_SIGNALED;
+	invalidate_wr.ex.invalidate_rkey = r->r.frmr.fr_mr->rkey;
+	DECR_CQCOUNT(&r_xprt->rx_ep);
+
+	dprintk("RPC:       %s: frmr %p invalidating rkey %08x\n",
+		__func__, r, r->r.frmr.fr_mr->rkey);
+
+	read_lock(&ia->ri_qplock);
+	rc = ib_post_send(ia->ri_id->qp, &invalidate_wr, &bad_wr);
+	read_unlock(&ia->ri_qplock);
+	if (rc) {
+		/* Force rpcrdma_buffer_get() to retry */
+		r->r.frmr.fr_state = FRMR_IS_STALE;
+		dprintk("RPC:       %s: ib_post_send failed, %i\n",
+			__func__, rc);
+	}
+}
+
+static void
+rpcrdma_retry_flushed_linv(struct list_head *stale,
+			   struct rpcrdma_buffer *buf)
+{
+	struct rpcrdma_ia *ia = rdmab_to_ia(buf);
+	struct list_head *pos;
+	struct rpcrdma_mw *r;
+	unsigned long flags;
+
+	list_for_each(pos, stale) {
+		r = list_entry(pos, struct rpcrdma_mw, mw_list);
+		rpcrdma_retry_local_inv(r, ia);
+	}
+
+	spin_lock_irqsave(&buf->rb_lock, flags);
+	list_splice_tail(stale, &buf->rb_mws);
+	spin_unlock_irqrestore(&buf->rb_lock, flags);
+}
+
 static struct rpcrdma_req *
-rpcrdma_buffer_get_mrs(struct rpcrdma_req *req, struct rpcrdma_buffer *buf)
+rpcrdma_buffer_get_frmrs(struct rpcrdma_req *req, struct rpcrdma_buffer *buf,
+			 struct list_head *stale)
+{
+	struct rpcrdma_mw *r;
+	int i;
+
+	i = RPCRDMA_MAX_SEGS - 1;
+	while (!list_empty(&buf->rb_mws)) {
+		r = list_entry(buf->rb_mws.next,
+			       struct rpcrdma_mw, mw_list);
+		list_del(&r->mw_list);
+		if (r->r.frmr.fr_state == FRMR_IS_STALE) {
+			list_add(&r->mw_list, stale);
+			continue;
+		}
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
+static struct rpcrdma_req *
+rpcrdma_buffer_get_fmrs(struct rpcrdma_req *req, struct rpcrdma_buffer *buf)
 {
 	struct rpcrdma_mw *r;
 	int i;
@@ -1393,6 +1476,7 @@ struct rpcrdma_req *
 rpcrdma_buffer_get(struct rpcrdma_buffer *buffers)
 {
 	struct rpcrdma_ia *ia = rdmab_to_ia(buffers);
+	struct list_head stale;
 	struct rpcrdma_req *req;
 	unsigned long flags;
 
@@ -1414,15 +1498,21 @@ rpcrdma_buffer_get(struct rpcrdma_buffer *buffers)
 		buffers->rb_recv_bufs[buffers->rb_recv_index++] = NULL;
 	}
 	buffers->rb_send_bufs[buffers->rb_send_index++] = NULL;
+
+	INIT_LIST_HEAD(&stale);
 	switch (ia->ri_memreg_strategy) {
 	case RPCRDMA_FRMR:
+		req = rpcrdma_buffer_get_frmrs(req, buffers, &stale);
+		break;
 	case RPCRDMA_MTHCAFMR:
-		req = rpcrdma_buffer_get_mrs(req, buffers);
+		req = rpcrdma_buffer_get_fmrs(req, buffers);
 		break;
 	default:
 		break;
 	}
 	spin_unlock_irqrestore(&buffers->rb_lock, flags);
+	if (!list_empty(&stale))
+		rpcrdma_retry_flushed_linv(&stale, buffers);
 	return req;
 }
 

