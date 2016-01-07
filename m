Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:32829 "EHLO
	mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752052AbcAGTtW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jan 2016 14:49:22 -0500
Subject: [PATCH v5 04/10] svcrdma: Improve allocation of struct
 svc_rdma_req_map
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org, dledford@redhat.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 07 Jan 2016 14:49:20 -0500
Message-ID: <20160107194920.2662.11755.stgit@klimt.1015granger.net>
In-Reply-To: <20160107194251.2662.88158.stgit@klimt.1015granger.net>
References: <20160107194251.2662.88158.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To ensure this allocation cannot fail and will not sleep,
pre-allocate the req_map structures per-connection.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Acked-by: Bruce Fields <bfields@fieldses.org>
---
 include/linux/sunrpc/svc_rdma.h          |    8 ++-
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |    6 +-
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   85 ++++++++++++++++++++++++++----
 3 files changed, 84 insertions(+), 15 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index be2804b..05bf4fe 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -113,6 +113,7 @@ struct svc_rdma_fastreg_mr {
 	struct list_head frmr_list;
 };
 struct svc_rdma_req_map {
+	struct list_head free;
 	unsigned long count;
 	union {
 		struct kvec sge[RPCSVC_MAXPAGES];
@@ -145,6 +146,8 @@ struct svcxprt_rdma {
 	spinlock_t	     sc_ctxt_lock;
 	struct list_head     sc_ctxts;
 	int		     sc_ctxt_used;
+	spinlock_t	     sc_map_lock;
+	struct list_head     sc_maps;
 
 	struct list_head     sc_rq_dto_q;
 	spinlock_t	     sc_rq_dto_lock;
@@ -223,8 +226,9 @@ extern int svc_rdma_create_listen(struct svc_serv *, int, struct sockaddr *);
 extern struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *);
 extern void svc_rdma_put_context(struct svc_rdma_op_ctxt *, int);
 extern void svc_rdma_unmap_dma(struct svc_rdma_op_ctxt *ctxt);
-extern struct svc_rdma_req_map *svc_rdma_get_req_map(void);
-extern void svc_rdma_put_req_map(struct svc_rdma_req_map *);
+extern struct svc_rdma_req_map *svc_rdma_get_req_map(struct svcxprt_rdma *);
+extern void svc_rdma_put_req_map(struct svcxprt_rdma *,
+				 struct svc_rdma_req_map *);
 extern struct svc_rdma_fastreg_mr *svc_rdma_get_frmr(struct svcxprt_rdma *);
 extern void svc_rdma_put_frmr(struct svcxprt_rdma *,
 			      struct svc_rdma_fastreg_mr *);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 969a1ab..9a097f9 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -591,7 +591,7 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
 	/* Build an req vec for the XDR */
 	ctxt = svc_rdma_get_context(rdma);
 	ctxt->direction = DMA_TO_DEVICE;
-	vec = svc_rdma_get_req_map();
+	vec = svc_rdma_get_req_map(rdma);
 	ret = map_xdr(rdma, &rqstp->rq_res, vec);
 	if (ret)
 		goto err0;
@@ -630,14 +630,14 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
 
 	ret = send_reply(rdma, rqstp, res_page, rdma_resp, ctxt, vec,
 			 inline_bytes);
-	svc_rdma_put_req_map(vec);
+	svc_rdma_put_req_map(rdma, vec);
 	dprintk("svcrdma: send_reply returns %d\n", ret);
 	return ret;
 
  err1:
 	put_page(res_page);
  err0:
-	svc_rdma_put_req_map(vec);
+	svc_rdma_put_req_map(rdma, vec);
 	svc_rdma_put_context(ctxt, 0);
 	return ret;
 }
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 9801115..0b9e17e 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -273,23 +273,83 @@ static void svc_rdma_destroy_ctxts(struct svcxprt_rdma *xprt)
 	}
 }
 
-/*
- * Temporary NFS req mappings are shared across all transport
- * instances. These are short lived and should be bounded by the number
- * of concurrent server threads * depth of the SQ.
- */
-struct svc_rdma_req_map *svc_rdma_get_req_map(void)
+static struct svc_rdma_req_map *alloc_req_map(gfp_t flags)
 {
 	struct svc_rdma_req_map *map;
-	map = kmem_cache_alloc(svc_rdma_map_cachep,
-			       GFP_KERNEL | __GFP_NOFAIL);
+
+	map = kmalloc(sizeof(*map), flags);
+	if (map)
+		INIT_LIST_HEAD(&map->free);
+	return map;
+}
+
+static bool svc_rdma_prealloc_maps(struct svcxprt_rdma *xprt)
+{
+	int i;
+
+	/* One for each receive buffer on this connection. */
+	i = xprt->sc_max_requests;
+
+	while (i--) {
+		struct svc_rdma_req_map *map;
+
+		map = alloc_req_map(GFP_KERNEL);
+		if (!map) {
+			dprintk("svcrdma: No memory for request map\n");
+			return false;
+		}
+		list_add(&map->free, &xprt->sc_maps);
+	}
+	return true;
+}
+
+struct svc_rdma_req_map *svc_rdma_get_req_map(struct svcxprt_rdma *xprt)
+{
+	struct svc_rdma_req_map *map = NULL;
+
+	spin_lock(&xprt->sc_map_lock);
+	if (list_empty(&xprt->sc_maps))
+		goto out_empty;
+
+	map = list_first_entry(&xprt->sc_maps,
+			       struct svc_rdma_req_map, free);
+	list_del_init(&map->free);
+	spin_unlock(&xprt->sc_map_lock);
+
+out:
 	map->count = 0;
 	return map;
+
+out_empty:
+	spin_unlock(&xprt->sc_map_lock);
+
+	/* Pre-allocation amount was incorrect */
+	map = alloc_req_map(GFP_NOIO);
+	if (map)
+		goto out;
+
+	WARN_ONCE(1, "svcrdma: empty request map list?\n");
+	return NULL;
 }
 
-void svc_rdma_put_req_map(struct svc_rdma_req_map *map)
+void svc_rdma_put_req_map(struct svcxprt_rdma *xprt,
+			  struct svc_rdma_req_map *map)
 {
-	kmem_cache_free(svc_rdma_map_cachep, map);
+	spin_lock(&xprt->sc_map_lock);
+	list_add(&map->free, &xprt->sc_maps);
+	spin_unlock(&xprt->sc_map_lock);
+}
+
+static void svc_rdma_destroy_maps(struct svcxprt_rdma *xprt)
+{
+	while (!list_empty(&xprt->sc_maps)) {
+		struct svc_rdma_req_map *map;
+
+		map = list_first_entry(&xprt->sc_maps,
+				       struct svc_rdma_req_map, free);
+		list_del(&map->free);
+		kfree(map);
+	}
 }
 
 /* ib_cq event handler */
@@ -593,12 +653,14 @@ static struct svcxprt_rdma *rdma_create_xprt(struct svc_serv *serv,
 	INIT_LIST_HEAD(&cma_xprt->sc_read_complete_q);
 	INIT_LIST_HEAD(&cma_xprt->sc_frmr_q);
 	INIT_LIST_HEAD(&cma_xprt->sc_ctxts);
+	INIT_LIST_HEAD(&cma_xprt->sc_maps);
 	init_waitqueue_head(&cma_xprt->sc_send_wait);
 
 	spin_lock_init(&cma_xprt->sc_lock);
 	spin_lock_init(&cma_xprt->sc_rq_dto_lock);
 	spin_lock_init(&cma_xprt->sc_frmr_q_lock);
 	spin_lock_init(&cma_xprt->sc_ctxt_lock);
+	spin_lock_init(&cma_xprt->sc_map_lock);
 
 	if (listener)
 		set_bit(XPT_LISTENER, &cma_xprt->sc_xprt.xpt_flags);
@@ -988,6 +1050,8 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 
 	if (!svc_rdma_prealloc_ctxts(newxprt))
 		goto errout;
+	if (!svc_rdma_prealloc_maps(newxprt))
+		goto errout;
 
 	/*
 	 * Limit ORD based on client limit, local device limit, and
@@ -1259,6 +1323,7 @@ static void __svc_rdma_free(struct work_struct *work)
 
 	rdma_dealloc_frmr_q(rdma);
 	svc_rdma_destroy_ctxts(rdma);
+	svc_rdma_destroy_maps(rdma);
 
 	/* Destroy the QP if present (not a listener) */
 	if (rdma->sc_qp && !IS_ERR(rdma->sc_qp))

