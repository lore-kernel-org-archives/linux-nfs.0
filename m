Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:35499 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754358AbbK3WYn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Nov 2015 17:24:43 -0500
Subject: [PATCH v2 2/7] svcrdma: Add svc_rdma_get_context() API that is
 allowed to fail
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 30 Nov 2015 17:24:41 -0500
Message-ID: <20151130222441.13029.88950.stgit@klimt.1015granger.net>
In-Reply-To: <20151130222141.13029.98664.stgit@klimt.1015granger.net>
References: <20151130222141.13029.98664.stgit@klimt.1015granger.net>
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
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   14 +++++++++++---
 2 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index f869807..cc69551 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -217,6 +217,8 @@ extern void svc_rdma_send_error(struct svcxprt_rdma *, struct rpcrdma_msg *,
 extern int svc_rdma_post_recv(struct svcxprt_rdma *);
 extern int svc_rdma_create_listen(struct svc_serv *, int, struct sockaddr *);
 extern struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *);
+extern struct svc_rdma_op_ctxt *svc_rdma_get_context_gfp(struct svcxprt_rdma *,
+							 gfp_t);
 extern void svc_rdma_put_context(struct svc_rdma_op_ctxt *, int);
 extern void svc_rdma_unmap_dma(struct svc_rdma_op_ctxt *ctxt);
 extern struct svc_rdma_req_map *svc_rdma_get_req_map(void);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index b348b4a..94b8d4c 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -153,12 +153,15 @@ static void svc_rdma_bc_free(struct svc_xprt *xprt)
 }
 #endif	/* CONFIG_SUNRPC_BACKCHANNEL */
 
-struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *xprt)
+struct svc_rdma_op_ctxt *svc_rdma_get_context_gfp(struct svcxprt_rdma *xprt,
+						  gfp_t flags)
 {
 	struct svc_rdma_op_ctxt *ctxt;
 
-	ctxt = kmem_cache_alloc(svc_rdma_ctxt_cachep,
-				GFP_KERNEL | __GFP_NOFAIL);
+	ctxt = kmem_cache_alloc(svc_rdma_ctxt_cachep, flags);
+	if (!ctxt)
+		return NULL;
+
 	ctxt->xprt = xprt;
 	INIT_LIST_HEAD(&ctxt->dto_q);
 	ctxt->count = 0;
@@ -167,6 +170,11 @@ struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *xprt)
 	return ctxt;
 }
 
+struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *xprt)
+{
+	return svc_rdma_get_context_gfp(xprt, GFP_KERNEL | __GFP_NOFAIL);
+}
+
 void svc_rdma_unmap_dma(struct svc_rdma_op_ctxt *ctxt)
 {
 	struct svcxprt_rdma *xprt = ctxt->xprt;

