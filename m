Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:33631 "EHLO
	mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754565AbbEKSDR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 May 2015 14:03:17 -0400
Subject: [PATCH v2 06/16] xprtrdma: Introduce helpers for allocating MWs
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 11 May 2015 14:03:14 -0400
Message-ID: <20150511180314.31263.46272.stgit@manet.1015granger.net>
In-Reply-To: <20150511174401.31263.79596.stgit@manet.1015granger.net>
References: <20150511174401.31263.79596.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We eventually want to handle allocating MWs one at a time, as
needed, instead of grabbing 64 and throwing them at each RPC in the
pipeline.

Add a helper for grabbing an MW off rb_mws, and a helper for
returning an MW to rb_mws. These will be used in a subsequent patch.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Steve Wise <swise@opengridcomputing.com>
Reviewed-by: Sagi Grimberg <sagig@mellanox.com>
---
 net/sunrpc/xprtrdma/verbs.c     |   31 +++++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/xprt_rdma.h |    2 ++
 2 files changed, 33 insertions(+)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index ddd5b36..b7ca73e 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1173,6 +1173,37 @@ rpcrdma_buffer_destroy(struct rpcrdma_buffer *buf)
 	kfree(buf->rb_pool);
 }
 
+struct rpcrdma_mw *
+rpcrdma_get_mw(struct rpcrdma_xprt *r_xprt)
+{
+	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
+	struct rpcrdma_mw *mw = NULL;
+	unsigned long flags;
+
+	spin_lock_irqsave(&buf->rb_lock, flags);
+	if (!list_empty(&buf->rb_mws)) {
+		mw = list_first_entry(&buf->rb_mws,
+				      struct rpcrdma_mw, mw_list);
+		list_del_init(&mw->mw_list);
+	}
+	spin_unlock_irqrestore(&buf->rb_lock, flags);
+
+	if (!mw)
+		pr_err("RPC:       %s: no MWs available\n", __func__);
+	return mw;
+}
+
+void
+rpcrdma_put_mw(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mw *mw)
+{
+	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
+	unsigned long flags;
+
+	spin_lock_irqsave(&buf->rb_lock, flags);
+	list_add_tail(&mw->mw_list, &buf->rb_mws);
+	spin_unlock_irqrestore(&buf->rb_lock, flags);
+}
+
 /* "*mw" can be NULL when rpcrdma_buffer_get_mrs() fails, leaving
  * some req segments uninitialized.
  */
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 300423d..5b801d5 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -413,6 +413,8 @@ int rpcrdma_ep_post_recv(struct rpcrdma_ia *, struct rpcrdma_ep *,
 int rpcrdma_buffer_create(struct rpcrdma_xprt *);
 void rpcrdma_buffer_destroy(struct rpcrdma_buffer *);
 
+struct rpcrdma_mw *rpcrdma_get_mw(struct rpcrdma_xprt *);
+void rpcrdma_put_mw(struct rpcrdma_xprt *, struct rpcrdma_mw *);
 struct rpcrdma_req *rpcrdma_buffer_get(struct rpcrdma_buffer *);
 void rpcrdma_buffer_put(struct rpcrdma_req *);
 void rpcrdma_recv_buffer_get(struct rpcrdma_req *);

