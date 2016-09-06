Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:33920 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935259AbcIFPW5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Sep 2016 11:22:57 -0400
Received: by mail-oi0-f67.google.com with SMTP id v82so8461451oie.1
        for <linux-nfs@vger.kernel.org>; Tue, 06 Sep 2016 08:22:56 -0700 (PDT)
Subject: [PATCH 1/2] xprtrdma: Revert 3d4cf35bd4fa ("xprtrdma: Reply buffer
 exhaustion...")
From: Chuck Lever <chuck.lever@oracle.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 06 Sep 2016 11:22:49 -0400
Message-ID: <20160906152249.4958.55165.stgit@manet.1015granger.net>
In-Reply-To: <20160906151843.4958.84689.stgit@manet.1015granger.net>
References: <20160906151843.4958.84689.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Receive buffer exhaustion, if it were to actually occur, would be
catastrophic. However, when there are no reply buffers to post, that
means all of them have already been posted and are waiting for
incoming replies. By design, there can never be more RPCs in flight
than there are available receive buffers.

A receive buffer can be left posted after an RPC exits without a
received reply; say, due to a credential problem or a soft timeout.
This does not result in fewer posted receive buffers than there are
pending RPCs, and there is already logic in xprtrdma to deal
appropriately with this case.

It also looks like the "+ 2" that was removed was accidentally
accommodating the number of extra receive buffers needed for
receiving backchannel requests. That will need to be addressed by
another patch.

Fixes: 3d4cf35bd4fa ("xprtrdma: Reply buffer exhaustion can be...")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |   12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index a74d79d..10edfca 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -923,7 +923,7 @@ rpcrdma_buffer_create(struct rpcrdma_xprt *r_xprt)
 	}
 
 	INIT_LIST_HEAD(&buf->rb_recv_bufs);
-	for (i = 0; i < buf->rb_max_requests; i++) {
+	for (i = 0; i < buf->rb_max_requests + 2; i++) {
 		struct rpcrdma_rep *rep;
 
 		rep = rpcrdma_create_rep(r_xprt);
@@ -1076,6 +1076,8 @@ rpcrdma_put_mw(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mw *mw)
 
 /*
  * Get a set of request/reply buffers.
+ *
+ * Reply buffer (if available) is attached to send buffer upon return.
  */
 struct rpcrdma_req *
 rpcrdma_buffer_get(struct rpcrdma_buffer *buffers)
@@ -1094,13 +1096,13 @@ rpcrdma_buffer_get(struct rpcrdma_buffer *buffers)
 
 out_reqbuf:
 	spin_unlock(&buffers->rb_lock);
-	pr_warn("rpcrdma: out of request buffers (%p)\n", buffers);
+	pr_warn("RPC:       %s: out of request buffers\n", __func__);
 	return NULL;
 out_repbuf:
-	list_add(&req->rl_free, &buffers->rb_send_bufs);
 	spin_unlock(&buffers->rb_lock);
-	pr_warn("rpcrdma: out of reply buffers (%p)\n", buffers);
-	return NULL;
+	pr_warn("RPC:       %s: out of reply buffers\n", __func__);
+	req->rl_reply = NULL;
+	return req;
 }
 
 /*

