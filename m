Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:35683 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935311AbcIFPXA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Sep 2016 11:23:00 -0400
Received: by mail-oi0-f65.google.com with SMTP id 2so15184316oif.2
        for <linux-nfs@vger.kernel.org>; Tue, 06 Sep 2016 08:23:00 -0700 (PDT)
Subject: [PATCH 2/2] xprtrdma: Fix receive buffer accounting
From: Chuck Lever <chuck.lever@oracle.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 06 Sep 2016 11:22:58 -0400
Message-ID: <20160906152258.4958.37363.stgit@manet.1015granger.net>
In-Reply-To: <20160906151843.4958.84689.stgit@manet.1015granger.net>
References: <20160906151843.4958.84689.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

An RPC can terminate before its reply arrives, if a credential
problem or a soft timeout occurs. After this happens, xprtrdma
reports it is out of Receive buffers.

A Receive buffer is posted before each RPC is sent, and returned to
the buffer pool when a reply is received. If no reply is received
for an RPC, that Receive buffer remains posted. But xprtrdma tries
to post another when the next RPC is sent.

If this happens a few dozen times, there are no receive buffers left
to be posted at send time. I don't see a way for a transport
connection to recover at that point, and it will spit warnings and
unnecessarily delay RPCs on occasion for its remaining lifetime.

Commit 1e465fd4ff47 ("xprtrdma: Replace send and receive arrays")
removed a little bit of logic to detect this case and not provide
a Receive buffer so no more buffers are posted, and then transport
operation continues correctly. We didn't understand what that logic
did, and it wasn't commented, so it was removed as part of the
overhaul to support backchannel requests.

Restore it, but be wary of the need to keep extra Receives posted
to deal with backchannel requests.

Fixes: 1e465fd4ff47 ("xprtrdma: Replace send and receive arrays")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c     |   41 ++++++++++++++++++++++++++++-----------
 net/sunrpc/xprtrdma/xprt_rdma.h |    1 +
 2 files changed, 30 insertions(+), 12 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 10edfca..924972f 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -51,6 +51,7 @@
 #include <linux/slab.h>
 #include <linux/prefetch.h>
 #include <linux/sunrpc/addr.h>
+#include <linux/sunrpc/svc_rdma.h>
 #include <asm/bitops.h>
 #include <linux/module.h> /* try_module_get()/module_put() */
 
@@ -923,7 +924,7 @@ rpcrdma_buffer_create(struct rpcrdma_xprt *r_xprt)
 	}
 
 	INIT_LIST_HEAD(&buf->rb_recv_bufs);
-	for (i = 0; i < buf->rb_max_requests + 2; i++) {
+	for (i = 0; i < buf->rb_max_requests + RPCRDMA_MAX_BC_REQUESTS; i++) {
 		struct rpcrdma_rep *rep;
 
 		rep = rpcrdma_create_rep(r_xprt);
@@ -1018,6 +1019,7 @@ rpcrdma_buffer_destroy(struct rpcrdma_buffer *buf)
 		rep = rpcrdma_buffer_get_rep_locked(buf);
 		rpcrdma_destroy_rep(ia, rep);
 	}
+	buf->rb_send_count = 0;
 
 	spin_lock(&buf->rb_reqslock);
 	while (!list_empty(&buf->rb_allreqs)) {
@@ -1032,6 +1034,7 @@ rpcrdma_buffer_destroy(struct rpcrdma_buffer *buf)
 		spin_lock(&buf->rb_reqslock);
 	}
 	spin_unlock(&buf->rb_reqslock);
+	buf->rb_recv_count = 0;
 
 	rpcrdma_destroy_mrs(buf);
 }
@@ -1074,6 +1077,23 @@ rpcrdma_put_mw(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mw *mw)
 	spin_unlock(&buf->rb_mwlock);
 }
 
+static struct rpcrdma_rep *
+rpcrdma_buffer_get_rep(struct rpcrdma_buffer *buffers)
+{
+	/* If an RPC previously completed without a reply (say, a
+	 * credential problem or a soft timeout occurs) then hold off
+	 * on supplying more Receive buffers until the number of new
+	 * pending RPCs catches up to the number of posted Receives.
+	 */
+	if (unlikely(buffers->rb_send_count < buffers->rb_recv_count))
+		return NULL;
+
+	if (unlikely(list_empty(&buffers->rb_recv_bufs)))
+		return NULL;
+	buffers->rb_recv_count++;
+	return rpcrdma_buffer_get_rep_locked(buffers);
+}
+
 /*
  * Get a set of request/reply buffers.
  *
@@ -1087,10 +1107,9 @@ rpcrdma_buffer_get(struct rpcrdma_buffer *buffers)
 	spin_lock(&buffers->rb_lock);
 	if (list_empty(&buffers->rb_send_bufs))
 		goto out_reqbuf;
+	buffers->rb_send_count++;
 	req = rpcrdma_buffer_get_req_locked(buffers);
-	if (list_empty(&buffers->rb_recv_bufs))
-		goto out_repbuf;
-	req->rl_reply = rpcrdma_buffer_get_rep_locked(buffers);
+	req->rl_reply = rpcrdma_buffer_get_rep(buffers);
 	spin_unlock(&buffers->rb_lock);
 	return req;
 
@@ -1098,11 +1117,6 @@ out_reqbuf:
 	spin_unlock(&buffers->rb_lock);
 	pr_warn("RPC:       %s: out of request buffers\n", __func__);
 	return NULL;
-out_repbuf:
-	spin_unlock(&buffers->rb_lock);
-	pr_warn("RPC:       %s: out of reply buffers\n", __func__);
-	req->rl_reply = NULL;
-	return req;
 }
 
 /*
@@ -1119,9 +1133,12 @@ rpcrdma_buffer_put(struct rpcrdma_req *req)
 	req->rl_reply = NULL;
 
 	spin_lock(&buffers->rb_lock);
+	buffers->rb_send_count--;
 	list_add_tail(&req->rl_free, &buffers->rb_send_bufs);
-	if (rep)
+	if (rep) {
+		buffers->rb_recv_count--;
 		list_add_tail(&rep->rr_list, &buffers->rb_recv_bufs);
+	}
 	spin_unlock(&buffers->rb_lock);
 }
 
@@ -1135,8 +1152,7 @@ rpcrdma_recv_buffer_get(struct rpcrdma_req *req)
 	struct rpcrdma_buffer *buffers = req->rl_buffer;
 
 	spin_lock(&buffers->rb_lock);
-	if (!list_empty(&buffers->rb_recv_bufs))
-		req->rl_reply = rpcrdma_buffer_get_rep_locked(buffers);
+	req->rl_reply = rpcrdma_buffer_get_rep(buffers);
 	spin_unlock(&buffers->rb_lock);
 }
 
@@ -1150,6 +1166,7 @@ rpcrdma_recv_buffer_put(struct rpcrdma_rep *rep)
 	struct rpcrdma_buffer *buffers = &rep->rr_rxprt->rx_buf;
 
 	spin_lock(&buffers->rb_lock);
+	buffers->rb_recv_count--;
 	list_add_tail(&rep->rr_list, &buffers->rb_recv_bufs);
 	spin_unlock(&buffers->rb_lock);
 }
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 670fad5..a71b0f5 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -321,6 +321,7 @@ struct rpcrdma_buffer {
 	char			*rb_pool;
 
 	spinlock_t		rb_lock;	/* protect buf lists */
+	int			rb_send_count, rb_recv_count;
 	struct list_head	rb_send_bufs;
 	struct list_head	rb_recv_bufs;
 	u32			rb_max_requests;

