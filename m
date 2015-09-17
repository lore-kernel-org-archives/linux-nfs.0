Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:34190 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752043AbbIQUqQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Sep 2015 16:46:16 -0400
Subject: [PATCH v1 15/18] svcrdma: Add svc_rdma_get_context() API that is
 allowed to fail
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 17 Sep 2015 16:46:14 -0400
Message-ID: <20150917204614.19671.61606.stgit@manet.1015granger.net>
In-Reply-To: <20150917202829.19671.90044.stgit@manet.1015granger.net>
References: <20150917202829.19671.90044.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To support backward direction calls, I'm going to add an
svc_rdma_get_context() call in the client RDMA transport.

Called from ->buf_alloc(), we can't sleep waiting for memory.
So add an API that can get a server op_ctxt but won't sleep.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc_rdma.h          |    2 ++
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   28 +++++++++++++++++++++++-----
 2 files changed, 25 insertions(+), 5 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 6ce7495..2500dd1 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -224,6 +224,8 @@ extern void svc_rdma_send_error(struct svcxprt_rdma *, struct rpcrdma_msg *,
 extern int svc_rdma_post_recv(struct svcxprt_rdma *);
 extern int svc_rdma_create_listen(struct svc_serv *, int, struct sockaddr *);
 extern struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *);
+extern struct svc_rdma_op_ctxt *svc_rdma_get_context_gfp(struct svcxprt_rdma *,
+							 gfp_t);
 extern void svc_rdma_put_context(struct svc_rdma_op_ctxt *, int);
 extern void svc_rdma_unmap_dma(struct svc_rdma_op_ctxt *ctxt);
 extern struct svc_rdma_req_map *svc_rdma_get_req_map(void);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 23aba30..c4083a3 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -153,17 +153,35 @@ static void svc_rdma_bc_free(struct svc_xprt *xprt)
 }
 #endif	/* CONFIG_SUNRPC_BACKCHANNEL */
 
-struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *xprt)
+static void svc_rdma_init_context(struct svcxprt_rdma *xprt,
+				  struct svc_rdma_op_ctxt *ctxt)
 {
-	struct svc_rdma_op_ctxt *ctxt;
-
-	ctxt = kmem_cache_alloc(svc_rdma_ctxt_cachep,
-				GFP_KERNEL | __GFP_NOFAIL);
 	ctxt->xprt = xprt;
 	INIT_LIST_HEAD(&ctxt->dto_q);
 	ctxt->count = 0;
 	ctxt->frmr = NULL;
 	atomic_inc(&xprt->sc_ctxt_used);
+}
+
+struct svc_rdma_op_ctxt *svc_rdma_get_context_gfp(struct svcxprt_rdma *xprt,
+						  gfp_t flags)
+{
+	struct svc_rdma_op_ctxt *ctxt;
+
+	ctxt = kmem_cache_alloc(svc_rdma_ctxt_cachep, flags);
+	if (!ctxt)
+		return NULL;
+	svc_rdma_init_context(xprt, ctxt);
+	return ctxt;
+}
+
+struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *xprt)
+{
+	struct svc_rdma_op_ctxt *ctxt;
+
+	ctxt = kmem_cache_alloc(svc_rdma_ctxt_cachep,
+				GFP_KERNEL | __GFP_NOFAIL);
+	svc_rdma_init_context(xprt, ctxt);
 	return ctxt;
 }
 

