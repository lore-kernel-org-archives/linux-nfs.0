Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f177.google.com ([209.85.213.177]:53483 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756262AbaGIQ5t (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jul 2014 12:57:49 -0400
Subject: [PATCH v2 09/21] xprtrdma: Chain together all MWs in same buffer
 pool
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 09 Jul 2014 12:57:47 -0400
Message-ID: <20140709165747.3496.70681.stgit@manet.1015granger.net>
In-Reply-To: <20140709163326.3496.37893.stgit@manet.1015granger.net>
References: <20140709163326.3496.37893.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

During connection loss recovery, need to visit every MW in a
buffer pool. Any MW that is in use by an RPC will not be on the
rb_mws list.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c     |    4 ++++
 net/sunrpc/xprtrdma/xprt_rdma.h |    4 +++-
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 14d24ec..aa14a36 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1074,6 +1074,7 @@ rpcrdma_buffer_create(struct rpcrdma_buffer *buf, struct rpcrdma_ep *ep,
 	p += cdata->padding;
 
 	INIT_LIST_HEAD(&buf->rb_mws);
+	INIT_LIST_HEAD(&buf->rb_all);
 	r = (struct rpcrdma_mw *)p;
 	switch (ia->ri_memreg_strategy) {
 	case RPCRDMA_FRMR:
@@ -1098,6 +1099,7 @@ rpcrdma_buffer_create(struct rpcrdma_buffer *buf, struct rpcrdma_ep *ep,
 				ib_dereg_mr(r->r.frmr.fr_mr);
 				goto out;
 			}
+			list_add(&r->mw_all, &buf->rb_all);
 			list_add(&r->mw_list, &buf->rb_mws);
 			++r;
 		}
@@ -1116,6 +1118,7 @@ rpcrdma_buffer_create(struct rpcrdma_buffer *buf, struct rpcrdma_ep *ep,
 					" failed %i\n", __func__, rc);
 				goto out;
 			}
+			list_add(&r->mw_all, &buf->rb_all);
 			list_add(&r->mw_list, &buf->rb_mws);
 			++r;
 		}
@@ -1225,6 +1228,7 @@ rpcrdma_buffer_destroy(struct rpcrdma_buffer *buf)
 	while (!list_empty(&buf->rb_mws)) {
 		r = list_entry(buf->rb_mws.next,
 			struct rpcrdma_mw, mw_list);
+		list_del(&r->mw_all);
 		list_del(&r->mw_list);
 		switch (ia->ri_memreg_strategy) {
 		case RPCRDMA_FRMR:
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 84c3455..c1d8652 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -151,7 +151,7 @@ struct rpcrdma_rep {
  * An external memory region is any buffer or page that is registered
  * on the fly (ie, not pre-registered).
  *
- * Each rpcrdma_buffer has a list of these anchored in rb_mws. During
+ * Each rpcrdma_buffer has a list of free MWs anchored in rb_mws. During
  * call_allocate, rpcrdma_buffer_get() assigns one to each segment in
  * an rpcrdma_req. Then rpcrdma_register_external() grabs these to keep
  * track of registration metadata while each RPC is pending.
@@ -175,6 +175,7 @@ struct rpcrdma_mw {
 		struct rpcrdma_frmr	frmr;
 	} r;
 	struct list_head	mw_list;
+	struct list_head	mw_all;
 };
 
 /*
@@ -246,6 +247,7 @@ struct rpcrdma_buffer {
 	atomic_t	rb_credits;	/* most recent server credits */
 	int		rb_max_requests;/* client max requests */
 	struct list_head rb_mws;	/* optional memory windows/fmrs/frmrs */
+	struct list_head rb_all;
 	int		rb_send_index;
 	struct rpcrdma_req	**rb_send_bufs;
 	int		rb_recv_index;

