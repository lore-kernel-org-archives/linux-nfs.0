Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:33106 "EHLO
	mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754104AbbJPNYn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Oct 2015 09:24:43 -0400
Subject: [PATCH v3 05/16] xprtrdma: Replace send and receive arrays
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 16 Oct 2015 09:24:41 -0400
Message-ID: <20151016132441.6819.84180.stgit@oracle-122.nfsv4bat.org>
In-Reply-To: <20151016131958.6819.98407.stgit@oracle-122.nfsv4bat.org>
References: <20151016131958.6819.98407.stgit@oracle-122.nfsv4bat.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The rb_send_bufs and rb_recv_bufs arrays are used to implement a
pair of stacks for keeping track of free rpcrdma_req and rpcrdma_rep
structs. Replace those arrays with free lists.

To allow more than 512 RPCs in-flight at once, each of these arrays
would be larger than a page (assuming 8-byte addresses and 4KB
pages). Allowing up to 64K in-flight RPCs (as TCP now does), each
buffer array would have to be 128 pages. That's an order-6
allocation. (Not that we're going there.)

A list is easier to expand dynamically. Instead of allocating a
larger array of pointers and copying the existing pointers to the
new array, simply append more buffers to each list.

This also makes it simpler to manage receive buffers that might
catch backwards-direction calls, or to post receive buffers in
bulk to amortize the overhead of ib_post_recv.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Sagi Grimberg <sagig@mellanox.com>
Reviewed-by: Devesh Sharma <devesh.sharma@avagotech.com>
Tested-By: Devesh Sharma <devesh.sharma@avagotech.com>
---
 net/sunrpc/xprtrdma/verbs.c     |  155 +++++++++++++++++----------------------
 net/sunrpc/xprtrdma/xprt_rdma.h |    9 +-
 2 files changed, 73 insertions(+), 91 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 0076129..ab26392 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -928,44 +928,18 @@ rpcrdma_buffer_create(struct rpcrdma_xprt *r_xprt)
 {
 	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
-	struct rpcrdma_create_data_internal *cdata = &r_xprt->rx_data;
-	char *p;
-	size_t len;
 	int i, rc;
 
-	buf->rb_max_requests = cdata->max_requests;
+	buf->rb_max_requests = r_xprt->rx_data.max_requests;
 	spin_lock_init(&buf->rb_lock);
 
-	/* Need to allocate:
-	 *   1.  arrays for send and recv pointers
-	 *   2.  arrays of struct rpcrdma_req to fill in pointers
-	 *   3.  array of struct rpcrdma_rep for replies
-	 * Send/recv buffers in req/rep need to be registered
-	 */
-	len = buf->rb_max_requests *
-		(sizeof(struct rpcrdma_req *) + sizeof(struct rpcrdma_rep *));
-
-	p = kzalloc(len, GFP_KERNEL);
-	if (p == NULL) {
-		dprintk("RPC:       %s: req_t/rep_t/pad kzalloc(%zd) failed\n",
-			__func__, len);
-		rc = -ENOMEM;
-		goto out;
-	}
-	buf->rb_pool = p;	/* for freeing it later */
-
-	buf->rb_send_bufs = (struct rpcrdma_req **) p;
-	p = (char *) &buf->rb_send_bufs[buf->rb_max_requests];
-	buf->rb_recv_bufs = (struct rpcrdma_rep **) p;
-	p = (char *) &buf->rb_recv_bufs[buf->rb_max_requests];
-
 	rc = ia->ri_ops->ro_init(r_xprt);
 	if (rc)
 		goto out;
 
+	INIT_LIST_HEAD(&buf->rb_send_bufs);
 	for (i = 0; i < buf->rb_max_requests; i++) {
 		struct rpcrdma_req *req;
-		struct rpcrdma_rep *rep;
 
 		req = rpcrdma_create_req(r_xprt);
 		if (IS_ERR(req)) {
@@ -974,7 +948,12 @@ rpcrdma_buffer_create(struct rpcrdma_xprt *r_xprt)
 			rc = PTR_ERR(req);
 			goto out;
 		}
-		buf->rb_send_bufs[i] = req;
+		list_add(&req->rl_free, &buf->rb_send_bufs);
+	}
+
+	INIT_LIST_HEAD(&buf->rb_recv_bufs);
+	for (i = 0; i < buf->rb_max_requests + 2; i++) {
+		struct rpcrdma_rep *rep;
 
 		rep = rpcrdma_create_rep(r_xprt);
 		if (IS_ERR(rep)) {
@@ -983,7 +962,7 @@ rpcrdma_buffer_create(struct rpcrdma_xprt *r_xprt)
 			rc = PTR_ERR(rep);
 			goto out;
 		}
-		buf->rb_recv_bufs[i] = rep;
+		list_add(&rep->rr_list, &buf->rb_recv_bufs);
 	}
 
 	return 0;
@@ -992,6 +971,28 @@ out:
 	return rc;
 }
 
+static struct rpcrdma_req *
+rpcrdma_buffer_get_req_locked(struct rpcrdma_buffer *buf)
+{
+	struct rpcrdma_req *req;
+
+	req = list_first_entry(&buf->rb_send_bufs,
+			       struct rpcrdma_req, rl_free);
+	list_del(&req->rl_free);
+	return req;
+}
+
+static struct rpcrdma_rep *
+rpcrdma_buffer_get_rep_locked(struct rpcrdma_buffer *buf)
+{
+	struct rpcrdma_rep *rep;
+
+	rep = list_first_entry(&buf->rb_recv_bufs,
+			       struct rpcrdma_rep, rr_list);
+	list_del(&rep->rr_list);
+	return rep;
+}
+
 static void
 rpcrdma_destroy_rep(struct rpcrdma_ia *ia, struct rpcrdma_rep *rep)
 {
@@ -1017,25 +1018,22 @@ void
 rpcrdma_buffer_destroy(struct rpcrdma_buffer *buf)
 {
 	struct rpcrdma_ia *ia = rdmab_to_ia(buf);
-	int i;
 
-	/* clean up in reverse order from create
-	 *   1.  recv mr memory (mr free, then kfree)
-	 *   2.  send mr memory (mr free, then kfree)
-	 *   3.  MWs
-	 */
-	dprintk("RPC:       %s: entering\n", __func__);
+	while (!list_empty(&buf->rb_recv_bufs)) {
+		struct rpcrdma_rep *rep;
 
-	for (i = 0; i < buf->rb_max_requests; i++) {
-		if (buf->rb_recv_bufs)
-			rpcrdma_destroy_rep(ia, buf->rb_recv_bufs[i]);
-		if (buf->rb_send_bufs)
-			rpcrdma_destroy_req(ia, buf->rb_send_bufs[i]);
+		rep = rpcrdma_buffer_get_rep_locked(buf);
+		rpcrdma_destroy_rep(ia, rep);
 	}
 
-	ia->ri_ops->ro_destroy(buf);
+	while (!list_empty(&buf->rb_send_bufs)) {
+		struct rpcrdma_req *req;
 
-	kfree(buf->rb_pool);
+		req = rpcrdma_buffer_get_req_locked(buf);
+		rpcrdma_destroy_req(ia, req);
+	}
+
+	ia->ri_ops->ro_destroy(buf);
 }
 
 struct rpcrdma_mw *
@@ -1067,25 +1065,10 @@ rpcrdma_put_mw(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mw *mw)
 	spin_unlock(&buf->rb_mwlock);
 }
 
-static void
-rpcrdma_buffer_put_sendbuf(struct rpcrdma_req *req, struct rpcrdma_buffer *buf)
-{
-	buf->rb_send_bufs[--buf->rb_send_index] = req;
-	req->rl_niovs = 0;
-	if (req->rl_reply) {
-		buf->rb_recv_bufs[--buf->rb_recv_index] = req->rl_reply;
-		req->rl_reply = NULL;
-	}
-}
-
 /*
  * Get a set of request/reply buffers.
  *
- * Reply buffer (if needed) is attached to send buffer upon return.
- * Rule:
- *    rb_send_index and rb_recv_index MUST always be pointing to the
- *    *next* available buffer (non-NULL). They are incremented after
- *    removing buffers, and decremented *before* returning them.
+ * Reply buffer (if available) is attached to send buffer upon return.
  */
 struct rpcrdma_req *
 rpcrdma_buffer_get(struct rpcrdma_buffer *buffers)
@@ -1094,26 +1077,23 @@ rpcrdma_buffer_get(struct rpcrdma_buffer *buffers)
 	unsigned long flags;
 
 	spin_lock_irqsave(&buffers->rb_lock, flags);
+	if (list_empty(&buffers->rb_send_bufs))
+		goto out_reqbuf;
+	req = rpcrdma_buffer_get_req_locked(buffers);
+	if (list_empty(&buffers->rb_recv_bufs))
+		goto out_repbuf;
+	req->rl_reply = rpcrdma_buffer_get_rep_locked(buffers);
+	spin_unlock_irqrestore(&buffers->rb_lock, flags);
+	return req;
 
-	if (buffers->rb_send_index == buffers->rb_max_requests) {
-		spin_unlock_irqrestore(&buffers->rb_lock, flags);
-		dprintk("RPC:       %s: out of request buffers\n", __func__);
-		return ((struct rpcrdma_req *)NULL);
-	}
-
-	req = buffers->rb_send_bufs[buffers->rb_send_index];
-	if (buffers->rb_send_index < buffers->rb_recv_index) {
-		dprintk("RPC:       %s: %d extra receives outstanding (ok)\n",
-			__func__,
-			buffers->rb_recv_index - buffers->rb_send_index);
-		req->rl_reply = NULL;
-	} else {
-		req->rl_reply = buffers->rb_recv_bufs[buffers->rb_recv_index];
-		buffers->rb_recv_bufs[buffers->rb_recv_index++] = NULL;
-	}
-	buffers->rb_send_bufs[buffers->rb_send_index++] = NULL;
-
+out_reqbuf:
+	spin_unlock_irqrestore(&buffers->rb_lock, flags);
+	pr_warn("RPC:       %s: out of request buffers\n", __func__);
+	return NULL;
+out_repbuf:
 	spin_unlock_irqrestore(&buffers->rb_lock, flags);
+	pr_warn("RPC:       %s: out of reply buffers\n", __func__);
+	req->rl_reply = NULL;
 	return req;
 }
 
@@ -1125,17 +1105,22 @@ void
 rpcrdma_buffer_put(struct rpcrdma_req *req)
 {
 	struct rpcrdma_buffer *buffers = req->rl_buffer;
+	struct rpcrdma_rep *rep = req->rl_reply;
 	unsigned long flags;
 
+	req->rl_niovs = 0;
+	req->rl_reply = NULL;
+
 	spin_lock_irqsave(&buffers->rb_lock, flags);
-	rpcrdma_buffer_put_sendbuf(req, buffers);
+	list_add_tail(&req->rl_free, &buffers->rb_send_bufs);
+	if (rep)
+		list_add_tail(&rep->rr_list, &buffers->rb_recv_bufs);
 	spin_unlock_irqrestore(&buffers->rb_lock, flags);
 }
 
 /*
  * Recover reply buffers from pool.
- * This happens when recovering from error conditions.
- * Post-increment counter/array index.
+ * This happens when recovering from disconnect.
  */
 void
 rpcrdma_recv_buffer_get(struct rpcrdma_req *req)
@@ -1144,10 +1129,8 @@ rpcrdma_recv_buffer_get(struct rpcrdma_req *req)
 	unsigned long flags;
 
 	spin_lock_irqsave(&buffers->rb_lock, flags);
-	if (buffers->rb_recv_index < buffers->rb_max_requests) {
-		req->rl_reply = buffers->rb_recv_bufs[buffers->rb_recv_index];
-		buffers->rb_recv_bufs[buffers->rb_recv_index++] = NULL;
-	}
+	if (!list_empty(&buffers->rb_recv_bufs))
+		req->rl_reply = rpcrdma_buffer_get_rep_locked(buffers);
 	spin_unlock_irqrestore(&buffers->rb_lock, flags);
 }
 
@@ -1162,7 +1145,7 @@ rpcrdma_recv_buffer_put(struct rpcrdma_rep *rep)
 	unsigned long flags;
 
 	spin_lock_irqsave(&buffers->rb_lock, flags);
-	buffers->rb_recv_bufs[--buffers->rb_recv_index] = rep;
+	list_add_tail(&rep->rr_list, &buffers->rb_recv_bufs);
 	spin_unlock_irqrestore(&buffers->rb_lock, flags);
 }
 
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index a13508b..e6a358f 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -252,6 +252,7 @@ struct rpcrdma_mr_seg {		/* chunk descriptors */
 #define RPCRDMA_MAX_IOVS	(2)
 
 struct rpcrdma_req {
+	struct list_head	rl_free;
 	unsigned int		rl_niovs;
 	unsigned int		rl_nchunks;
 	unsigned int		rl_connect_cookie;
@@ -285,12 +286,10 @@ struct rpcrdma_buffer {
 	struct list_head	rb_all;
 	char			*rb_pool;
 
-	spinlock_t		rb_lock;	/* protect buf arrays */
+	spinlock_t		rb_lock;	/* protect buf lists */
+	struct list_head	rb_send_bufs;
+	struct list_head	rb_recv_bufs;
 	u32			rb_max_requests;
-	int			rb_send_index;
-	int			rb_recv_index;
-	struct rpcrdma_req	**rb_send_bufs;
-	struct rpcrdma_rep	**rb_recv_bufs;
 };
 #define rdmab_to_ia(b) (&container_of((b), struct rpcrdma_xprt, rx_buf)->rx_ia)
 

