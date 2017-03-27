Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:36302 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753157AbdC0Ntw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Mar 2017 09:49:52 -0400
Subject: [PATCH v2 12/13] svcrdma: Remove the req_map cache
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 27 Mar 2017 09:49:32 -0400
Message-ID: <20170327134932.5585.83690.stgit@klimt.1015granger.net>
In-Reply-To: <20170327132329.5585.98465.stgit@klimt.1015granger.net>
References: <20170327132329.5585.98465.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

req_maps are no longer used by the send path and can thus be removed.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Sagi Grimberg <sagi@grimberg.me>
---
 include/linux/sunrpc/svc_rdma.h          |   34 ------------
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |   68 ------------------------
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   84 ------------------------------
 3 files changed, 1 insertion(+), 185 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 6582e2f..326703e 100644
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
@@ -160,8 +135,6 @@ struct svcxprt_rdma {
 	int		     sc_ctxt_used;
 	spinlock_t	     sc_rw_ctxt_lock;
 	struct list_head     sc_rw_ctxts;
-	spinlock_t	     sc_map_lock;
-	struct list_head     sc_maps;
 
 	struct list_head     sc_rq_dto_q;
 	spinlock_t	     sc_rq_dto_lock;
@@ -237,8 +210,6 @@ extern int svc_rdma_send_reply_chunk(struct svcxprt_rdma *rdma,
 				     struct xdr_buf *xdr);
 
 /* svc_rdma_sendto.c */
-extern int svc_rdma_map_xdr(struct svcxprt_rdma *, struct xdr_buf *,
-			    struct svc_rdma_req_map *, bool);
 extern int svc_rdma_map_reply_hdr(struct svcxprt_rdma *rdma,
 				  struct svc_rdma_op_ctxt *ctxt,
 				  __be32 *rdma_resp, unsigned int len);
@@ -258,9 +229,6 @@ extern void svc_rdma_build_send_wr(struct svc_rdma_op_ctxt *ctxt,
 extern struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *);
 extern void svc_rdma_put_context(struct svc_rdma_op_ctxt *, int);
 extern void svc_rdma_unmap_dma(struct svc_rdma_op_ctxt *ctxt);
-extern struct svc_rdma_req_map *svc_rdma_get_req_map(struct svcxprt_rdma *);
-extern void svc_rdma_put_req_map(struct svcxprt_rdma *,
-				 struct svc_rdma_req_map *);
 extern struct svc_rdma_fastreg_mr *svc_rdma_get_frmr(struct svcxprt_rdma *);
 extern void svc_rdma_put_frmr(struct svcxprt_rdma *,
 			      struct svc_rdma_fastreg_mr *);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 3886ec8..02cfe54 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -240,74 +240,6 @@ static void svc_rdma_xdr_encode_reply_chunk(__be32 *rdma_resp, __be32 *rp_ch,
 	xdr_encode_write_chunk(p, rp_ch, consumed);
 }
 
-int svc_rdma_map_xdr(struct svcxprt_rdma *xprt,
-		     struct xdr_buf *xdr,
-		     struct svc_rdma_req_map *vec,
-		     bool write_chunk_present)
-{
-	int sge_no;
-	u32 sge_bytes;
-	u32 page_bytes;
-	u32 page_off;
-	int page_no;
-
-	if (xdr->len !=
-	    (xdr->head[0].iov_len + xdr->page_len + xdr->tail[0].iov_len)) {
-		pr_err("svcrdma: %s: XDR buffer length error\n", __func__);
-		return -EIO;
-	}
-
-	/* Skip the first sge, this is for the RPCRDMA header */
-	sge_no = 1;
-
-	/* Head SGE */
-	vec->sge[sge_no].iov_base = xdr->head[0].iov_base;
-	vec->sge[sge_no].iov_len = xdr->head[0].iov_len;
-	sge_no++;
-
-	/* pages SGE */
-	page_no = 0;
-	page_bytes = xdr->page_len;
-	page_off = xdr->page_base;
-	while (page_bytes) {
-		vec->sge[sge_no].iov_base =
-			page_address(xdr->pages[page_no]) + page_off;
-		sge_bytes = min_t(u32, page_bytes, (PAGE_SIZE - page_off));
-		page_bytes -= sge_bytes;
-		vec->sge[sge_no].iov_len = sge_bytes;
-
-		sge_no++;
-		page_no++;
-		page_off = 0; /* reset for next time through loop */
-	}
-
-	/* Tail SGE */
-	if (xdr->tail[0].iov_len) {
-		unsigned char *base = xdr->tail[0].iov_base;
-		size_t len = xdr->tail[0].iov_len;
-		u32 xdr_pad = xdr_padsize(xdr->page_len);
-
-		if (write_chunk_present && xdr_pad) {
-			base += xdr_pad;
-			len -= xdr_pad;
-		}
-
-		if (len) {
-			vec->sge[sge_no].iov_base = base;
-			vec->sge[sge_no].iov_len = len;
-			sge_no++;
-		}
-	}
-
-	dprintk("svcrdma: %s: sge_no %d page_no %d "
-		"page_base %u page_len %u head_len %zu tail_len %zu\n",
-		__func__, sge_no, page_no, xdr->page_base, xdr->page_len,
-		xdr->head[0].iov_len, xdr->tail[0].iov_len);
-
-	vec->count = sge_no;
-	return 0;
-}
-
 /* Parse the RPC Call's transport header.
  */
 static void svc_rdma_get_write_arrays(__be32 *rdma_argp,
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 8ce68bf..9176a35 100644
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
 
 	/*
 	 * Note that this implies that the underlying transport support
@@ -1003,8 +922,6 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 
 	if (!svc_rdma_prealloc_ctxts(newxprt))
 		goto errout;
-	if (!svc_rdma_prealloc_maps(newxprt))
-		goto errout;
 
 	/*
 	 * Limit ORD based on client limit, local device limit, and
@@ -1236,7 +1153,6 @@ static void __svc_rdma_free(struct work_struct *work)
 	rdma_dealloc_frmr_q(rdma);
 	svc_rdma_destroy_rw_ctxts(rdma);
 	svc_rdma_destroy_ctxts(rdma);
-	svc_rdma_destroy_maps(rdma);
 
 	/* Destroy the QP if present (not a listener) */
 	if (rdma->sc_qp && !IS_ERR(rdma->sc_qp))

