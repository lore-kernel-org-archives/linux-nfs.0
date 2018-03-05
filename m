Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:38336 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752920AbeCEUNl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Mar 2018 15:13:41 -0500
Subject: [PATCH 9/9] xprtrdma: Allocate rpcrdma_reps during Receive
 completion
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 05 Mar 2018 15:13:39 -0500
Message-ID: <20180305201339.10904.10673.stgit@manet.1015granger.net>
In-Reply-To: <20180305200825.10904.40829.stgit@manet.1015granger.net>
References: <20180305200825.10904.40829.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Receive completion for a CQ runs on one CPU core only. Ensure that
Receive buffers are allocated on the same CPU core where Receive
completions are handled. This guarantees that a transport's Receive
buffers are on the NUMA node that is local to the device no matter
where the transport was created.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/backchannel.c |   21 ---------------------
 net/sunrpc/xprtrdma/rpc_rdma.c    |    8 ++++++++
 net/sunrpc/xprtrdma/verbs.c       |   35 ++++++++++++++++++++++++++---------
 net/sunrpc/xprtrdma/xprt_rdma.h   |    4 +++-
 4 files changed, 37 insertions(+), 31 deletions(-)

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index 4034788..6b21fb8 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -71,23 +71,6 @@ static int rpcrdma_bc_setup_reqs(struct rpcrdma_xprt *r_xprt,
 	return -ENOMEM;
 }
 
-/* Allocate and add receive buffers to the rpcrdma_buffer's
- * existing list of rep's. These are released when the
- * transport is destroyed.
- */
-static int rpcrdma_bc_setup_reps(struct rpcrdma_xprt *r_xprt,
-				 unsigned int count)
-{
-	int rc = 0;
-
-	while (count--) {
-		rc = rpcrdma_create_rep(r_xprt);
-		if (rc)
-			break;
-	}
-	return rc;
-}
-
 /**
  * xprt_rdma_bc_setup - Pre-allocate resources for handling backchannel requests
  * @xprt: transport associated with these backchannel resources
@@ -116,10 +99,6 @@ int xprt_rdma_bc_setup(struct rpc_xprt *xprt, unsigned int reqs)
 	if (rc)
 		goto out_free;
 
-	rc = rpcrdma_bc_setup_reps(r_xprt, reqs);
-	if (rc)
-		goto out_free;
-
 	rc = rpcrdma_ep_post_extra_recv(r_xprt, reqs);
 	if (rc)
 		goto out_free;
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index e8adad3..d15aa27 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -1331,8 +1331,16 @@ void rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 	struct rpcrdma_req *req;
 	struct rpc_rqst *rqst;
 	u32 credits;
+	int total;
 	__be32 *p;
 
+	total = buf->rb_max_requests + (buf->rb_bc_srv_max_requests << 1);
+	total -= buf->rb_reps;
+	if (total > 0)
+		while (total--)
+			if (!rpcrdma_create_rep(r_xprt, false))
+				break;
+
 	if (rep->rr_hdrbuf.head[0].iov_len == 0)
 		goto out_badstatus;
 
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 6a7a5a2..af74953 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1095,11 +1095,12 @@ struct rpcrdma_req *
 /**
  * rpcrdma_create_rep - Allocate an rpcrdma_rep object
  * @r_xprt: controlling transport
+ * @temp: destroy rep upon release
  *
  * Returns 0 on success or a negative errno on failure.
  */
 int
-rpcrdma_create_rep(struct rpcrdma_xprt *r_xprt)
+rpcrdma_create_rep(struct rpcrdma_xprt *r_xprt, bool temp)
 {
 	struct rpcrdma_create_data_internal *cdata = &r_xprt->rx_data;
 	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
@@ -1127,9 +1128,11 @@ struct rpcrdma_req *
 	rep->rr_recv_wr.wr_cqe = &rep->rr_cqe;
 	rep->rr_recv_wr.sg_list = &rep->rr_rdmabuf->rg_iov;
 	rep->rr_recv_wr.num_sge = 1;
+	rep->rr_temp = temp;
 
 	spin_lock(&buf->rb_lock);
 	list_add(&rep->rr_list, &buf->rb_recv_bufs);
+	++buf->rb_reps;
 	spin_unlock(&buf->rb_lock);
 	return 0;
 
@@ -1179,11 +1182,9 @@ struct rpcrdma_req *
 	}
 
 	INIT_LIST_HEAD(&buf->rb_recv_bufs);
-	for (i = 0; i <= buf->rb_max_requests; i++) {
-		rc = rpcrdma_create_rep(r_xprt);
-		if (rc)
-			goto out;
-	}
+	rc = rpcrdma_create_rep(r_xprt, true);
+	if (rc)
+		goto out;
 
 	rc = rpcrdma_sendctxs_create(r_xprt);
 	if (rc)
@@ -1220,8 +1221,14 @@ struct rpcrdma_req *
 static void
 rpcrdma_destroy_rep(struct rpcrdma_rep *rep)
 {
+	struct rpcrdma_buffer *buf = &rep->rr_rxprt->rx_buf;
+
 	rpcrdma_free_regbuf(rep->rr_rdmabuf);
 	kfree(rep);
+
+	spin_lock(&buf->rb_lock);
+	--buf->rb_reps;
+	spin_unlock(&buf->rb_lock);
 }
 
 void
@@ -1417,12 +1424,17 @@ struct rpcrdma_req *
 
 	spin_lock(&buffers->rb_lock);
 	buffers->rb_send_count--;
-	list_add_tail(&req->rl_list, &buffers->rb_send_bufs);
+	list_add(&req->rl_list, &buffers->rb_send_bufs);
 	if (rep) {
 		buffers->rb_recv_count--;
-		list_add_tail(&rep->rr_list, &buffers->rb_recv_bufs);
+		if (!rep->rr_temp) {
+			list_add(&rep->rr_list, &buffers->rb_recv_bufs);
+			rep = NULL;
+		}
 	}
 	spin_unlock(&buffers->rb_lock);
+	if (rep)
+		rpcrdma_destroy_rep(rep);
 }
 
 /*
@@ -1450,8 +1462,13 @@ struct rpcrdma_req *
 
 	spin_lock(&buffers->rb_lock);
 	buffers->rb_recv_count--;
-	list_add_tail(&rep->rr_list, &buffers->rb_recv_bufs);
+	if (!rep->rr_temp) {
+		list_add(&rep->rr_list, &buffers->rb_recv_bufs);
+		rep = NULL;
+	}
 	spin_unlock(&buffers->rb_lock);
+	if (rep)
+		rpcrdma_destroy_rep(rep);
 }
 
 /**
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index b35d80b..5f069c7 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -196,6 +196,7 @@ struct rpcrdma_rep {
 	__be32			rr_proc;
 	int			rr_wc_flags;
 	u32			rr_inv_rkey;
+	bool			rr_temp;
 	struct rpcrdma_regbuf	*rr_rdmabuf;
 	struct rpcrdma_xprt	*rr_rxprt;
 	struct work_struct	rr_work;
@@ -401,6 +402,7 @@ struct rpcrdma_buffer {
 	struct list_head	rb_recv_bufs;
 	u32			rb_max_requests;
 	u32			rb_credits;	/* most recent credit grant */
+	unsigned int		rb_reps;
 
 	u32			rb_bc_srv_max_requests;
 	spinlock_t		rb_reqslock;	/* protect rb_allreqs */
@@ -563,7 +565,7 @@ int rpcrdma_ep_post(struct rpcrdma_ia *, struct rpcrdma_ep *,
  */
 struct rpcrdma_req *rpcrdma_create_req(struct rpcrdma_xprt *);
 void rpcrdma_destroy_req(struct rpcrdma_req *);
-int rpcrdma_create_rep(struct rpcrdma_xprt *r_xprt);
+int rpcrdma_create_rep(struct rpcrdma_xprt *r_xprt, bool temp);
 int rpcrdma_buffer_create(struct rpcrdma_xprt *);
 void rpcrdma_buffer_destroy(struct rpcrdma_buffer *);
 struct rpcrdma_sendctx *rpcrdma_sendctx_get_locked(struct rpcrdma_buffer *buf);

