Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:36251 "EHLO
	mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751900AbcF2Rxh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Jun 2016 13:53:37 -0400
Subject: [PATCH v4 11/24] xprtrdma: Reply buffer exhaustion can be
 catastrophic
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 29 Jun 2016 13:53:35 -0400
Message-ID: <20160629175335.15094.20314.stgit@manet.1015granger.net>
In-Reply-To: <20160629173231.15094.52660.stgit@manet.1015granger.net>
References: <20160629173231.15094.52660.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Not having an rpcrdma_rep at call_allocate time can be a problem.
It means that send_request can't post a receive buffer to catch
the RPC's reply. Possible consequences are RPC timeouts or even
transport deadlock.

Instead of allowing an RPC to proceed if an rpcrdma_rep is
not available, return NULL to force call_allocate to wait and
try again.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Steve Wise <swise@opengridcomputing.com>
---
 net/sunrpc/xprtrdma/verbs.c |   12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index cd4c5f1..6fb73ff 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -871,7 +871,7 @@ rpcrdma_buffer_create(struct rpcrdma_xprt *r_xprt)
 	}
 
 	INIT_LIST_HEAD(&buf->rb_recv_bufs);
-	for (i = 0; i < buf->rb_max_requests + 2; i++) {
+	for (i = 0; i < buf->rb_max_requests; i++) {
 		struct rpcrdma_rep *rep;
 
 		rep = rpcrdma_create_rep(r_xprt);
@@ -989,8 +989,6 @@ rpcrdma_put_mw(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mw *mw)
 
 /*
  * Get a set of request/reply buffers.
- *
- * Reply buffer (if available) is attached to send buffer upon return.
  */
 struct rpcrdma_req *
 rpcrdma_buffer_get(struct rpcrdma_buffer *buffers)
@@ -1009,13 +1007,13 @@ rpcrdma_buffer_get(struct rpcrdma_buffer *buffers)
 
 out_reqbuf:
 	spin_unlock(&buffers->rb_lock);
-	pr_warn("RPC:       %s: out of request buffers\n", __func__);
+	pr_warn("rpcrdma: out of request buffers (%p)\n", buffers);
 	return NULL;
 out_repbuf:
+	list_add(&req->rl_free, &buffers->rb_send_bufs);
 	spin_unlock(&buffers->rb_lock);
-	pr_warn("RPC:       %s: out of reply buffers\n", __func__);
-	req->rl_reply = NULL;
-	return req;
+	pr_warn("rpcrdma: out of reply buffers (%p)\n", buffers);
+	return NULL;
 }
 
 /*

