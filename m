Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:34533 "EHLO
	mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754486AbbKWWUk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Nov 2015 17:20:40 -0500
Subject: [PATCH v1 3/8] svcrdma: Add svc_rdma_get_context() API that is
 allowed to fail
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 23 Nov 2015 17:20:38 -0500
Message-ID: <20151123222038.13040.61285.stgit@klimt.1015granger.net>
In-Reply-To: <20151123221738.13040.26277.stgit@klimt.1015granger.net>
References: <20151123221738.13040.26277.stgit@klimt.1015granger.net>
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
index 478aa30..0355067 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -222,6 +222,8 @@ extern void svc_rdma_send_error(struct svcxprt_rdma *, struct rpcrdma_msg *,
 extern int svc_rdma_post_recv(struct svcxprt_rdma *);
 extern int svc_rdma_create_listen(struct svc_serv *, int, struct sockaddr *);
 extern struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *);
+extern struct svc_rdma_op_ctxt *svc_rdma_get_context_gfp(struct svcxprt_rdma *,
+							 gfp_t);
 extern void svc_rdma_put_context(struct svc_rdma_op_ctxt *, int);
 extern void svc_rdma_unmap_dma(struct svc_rdma_op_ctxt *ctxt);
 extern struct svc_rdma_req_map *svc_rdma_get_req_map(void);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 01c7b36..58ec362 100644
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
 

