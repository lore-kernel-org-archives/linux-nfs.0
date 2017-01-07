Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:33220 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964931AbdAGRRN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 7 Jan 2017 12:17:13 -0500
Subject: [PATCH v1 14/22] svcrdma: Remove the req_map cache
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Sat, 07 Jan 2017 12:17:11 -0500
Message-ID: <20170107171710.14126.27400.stgit@klimt.1015granger.net>
In-Reply-To: <20170107170258.14126.8503.stgit@klimt.1015granger.net>
References: <20170107170258.14126.8503.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

req_maps are no longer used by the send path and can thus be removed.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc_rdma.h          |   32 -----------
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   84 ------------------------------
 2 files changed, 1 insertion(+), 115 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 0e681b1..531980b 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -96,23 +96,6 @@ struct svc_rdma_op_ctxt {
 	struct page *pages[RPCSVC_MAXPAGES];
 };
 
-/*
- * NFS_ requests are mapped on the client side by the chunk lists in
- * the RPCRDMA header. During the fetching of the RPC from the client
- * and the writing of the reply to the client, the memory in the
- * client and the memory in the server must be mapped as contiguous
- * vaddr/len for access by the hardware. These data strucures keep
- * these mappings.
- *
- * For an RDMA_WRITE, the 'sge' maps the RPC REPLY. For RDMA_READ, the
- * 'sge' in the svc_rdma_req_map maps the server side RPC reply and the
- * 'ch' field maps the read-list of the RPCRDMA header to the 'sge'
- * mapping of the reply.
- */
-struct svc_rdma_chunk_sge {
-	int start;		/* sge no for this chunk */
-	int count;		/* sge count for this chunk */
-};
 struct svc_rdma_fastreg_mr {
 	struct ib_mr *mr;
 	struct scatterlist *sg;
@@ -121,15 +104,7 @@ struct svc_rdma_fastreg_mr {
 	enum dma_data_direction direction;
 	struct list_head frmr_list;
 };
-struct svc_rdma_req_map {
-	struct list_head free;
-	unsigned long count;
-	union {
-		struct kvec sge[RPCSVC_MAXPAGES];
-		struct svc_rdma_chunk_sge ch[RPCSVC_MAXPAGES];
-		unsigned long lkey[RPCSVC_MAXPAGES];
-	};
-};
+
 #define RDMACTXT_F_LAST_CTXT	2
 
 #define	SVCRDMA_DEVCAP_FAST_REG		1	/* fast mr registration */
@@ -162,8 +137,6 @@ struct svcxprt_rdma {
 	int		     sc_ctxt_used;
 	spinlock_t	     sc_rw_ctxt_lock;
 	struct list_head     sc_rw_ctxts;
-	spinlock_t	     sc_map_lock;
-	struct list_head     sc_maps;
 
 	struct list_head     sc_rq_dto_q;
 	spinlock_t	     sc_rq_dto_lock;
@@ -275,9 +248,6 @@ extern int svc_rdma_post_send(struct svcxprt_rdma *rdma,
 extern struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *);
 extern void svc_rdma_put_context(struct svc_rdma_op_ctxt *, int);
 extern void svc_rdma_unmap_dma(struct svc_rdma_op_ctxt *ctxt);
-extern struct svc_rdma_req_map *svc_rdma_get_req_map(struct svcxprt_rdma *);
-extern void svc_rdma_put_req_map(struct svcxprt_rdma *,
-				 struct svc_rdma_req_map *);
 extern struct svc_rdma_fastreg_mr *svc_rdma_get_frmr(struct svcxprt_rdma *);
 extern void svc_rdma_put_frmr(struct svcxprt_rdma *,
 			      struct svc_rdma_fastreg_mr *);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index d930f70..01119ba 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -271,85 +271,6 @@ static void svc_rdma_destroy_ctxts(struct svcxprt_rdma *xprt)
 	}
 }
 
-static struct svc_rdma_req_map *alloc_req_map(gfp_t flags)
-{
-	struct svc_rdma_req_map *map;
-
-	map = kmalloc(sizeof(*map), flags);
-	if (map)
-		INIT_LIST_HEAD(&map->free);
-	return map;
-}
-
-static bool svc_rdma_prealloc_maps(struct svcxprt_rdma *xprt)
-{
-	unsigned int i;
-
-	/* One for each receive buffer on this connection. */
-	i = xprt->sc_max_requests;
-
-	while (i--) {
-		struct svc_rdma_req_map *map;
-
-		map = alloc_req_map(GFP_KERNEL);
-		if (!map) {
-			dprintk("svcrdma: No memory for request map\n");
-			return false;
-		}
-		list_add(&map->free, &xprt->sc_maps);
-	}
-	return true;
-}
-
-struct svc_rdma_req_map *svc_rdma_get_req_map(struct svcxprt_rdma *xprt)
-{
-	struct svc_rdma_req_map *map = NULL;
-
-	spin_lock(&xprt->sc_map_lock);
-	if (list_empty(&xprt->sc_maps))
-		goto out_empty;
-
-	map = list_first_entry(&xprt->sc_maps,
-			       struct svc_rdma_req_map, free);
-	list_del_init(&map->free);
-	spin_unlock(&xprt->sc_map_lock);
-
-out:
-	map->count = 0;
-	return map;
-
-out_empty:
-	spin_unlock(&xprt->sc_map_lock);
-
-	/* Pre-allocation amount was incorrect */
-	map = alloc_req_map(GFP_NOIO);
-	if (map)
-		goto out;
-
-	WARN_ONCE(1, "svcrdma: empty request map list?\n");
-	return NULL;
-}
-
-void svc_rdma_put_req_map(struct svcxprt_rdma *xprt,
-			  struct svc_rdma_req_map *map)
-{
-	spin_lock(&xprt->sc_map_lock);
-	list_add(&map->free, &xprt->sc_maps);
-	spin_unlock(&xprt->sc_map_lock);
-}
-
-static void svc_rdma_destroy_maps(struct svcxprt_rdma *xprt)
-{
-	while (!list_empty(&xprt->sc_maps)) {
-		struct svc_rdma_req_map *map;
-
-		map = list_first_entry(&xprt->sc_maps,
-				       struct svc_rdma_req_map, free);
-		list_del(&map->free);
-		kfree(map);
-	}
-}
-
 /* QP event handler */
 static void qp_event_handler(struct ib_event *event, void *context)
 {
@@ -543,7 +464,6 @@ static struct svcxprt_rdma *rdma_create_xprt(struct svc_serv *serv,
 	INIT_LIST_HEAD(&cma_xprt->sc_frmr_q);
 	INIT_LIST_HEAD(&cma_xprt->sc_ctxts);
 	INIT_LIST_HEAD(&cma_xprt->sc_rw_ctxts);
-	INIT_LIST_HEAD(&cma_xprt->sc_maps);
 	init_waitqueue_head(&cma_xprt->sc_send_wait);
 
 	spin_lock_init(&cma_xprt->sc_lock);
@@ -551,7 +471,6 @@ static struct svcxprt_rdma *rdma_create_xprt(struct svc_serv *serv,
 	spin_lock_init(&cma_xprt->sc_frmr_q_lock);
 	spin_lock_init(&cma_xprt->sc_ctxt_lock);
 	spin_lock_init(&cma_xprt->sc_rw_ctxt_lock);
-	spin_lock_init(&cma_xprt->sc_map_lock);
 
 	if (listener)
 		set_bit(XPT_LISTENER, &cma_xprt->sc_xprt.xpt_flags);
@@ -1047,8 +966,6 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 
 	if (!svc_rdma_prealloc_ctxts(newxprt))
 		goto errout;
-	if (!svc_rdma_prealloc_maps(newxprt))
-		goto errout;
 
 	/*
 	 * Limit ORD based on client limit, local device limit, and
@@ -1282,7 +1199,6 @@ static void __svc_rdma_free(struct work_struct *work)
 	rdma_dealloc_frmr_q(rdma);
 	svc_rdma_destroy_rw_ctxts(rdma);
 	svc_rdma_destroy_ctxts(rdma);
-	svc_rdma_destroy_maps(rdma);
 
 	/* Destroy the QP if present (not a listener) */
 	if (rdma->sc_qp && !IS_ERR(rdma->sc_qp))

