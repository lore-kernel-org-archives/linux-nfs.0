Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:33589 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752789AbbFDV1B (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Jun 2015 17:27:01 -0400
Received: by igbpi8 with SMTP id pi8so1762165igb.0
        for <linux-nfs@vger.kernel.org>; Thu, 04 Jun 2015 14:27:00 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 5/6] SUNRPC: Clean up allocation and freeing of back channel requests
Date: Thu,  4 Jun 2015 17:26:52 -0400
Message-Id: <1433453213-13466-5-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1433453213-13466-4-git-send-email-trond.myklebust@primarydata.com>
References: <1433453213-13466-1-git-send-email-trond.myklebust@primarydata.com>
 <1433453213-13466-2-git-send-email-trond.myklebust@primarydata.com>
 <1433453213-13466-3-git-send-email-trond.myklebust@primarydata.com>
 <1433453213-13466-4-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/backchannel_rqst.c | 95 +++++++++++++++++++++++++------------------
 1 file changed, 55 insertions(+), 40 deletions(-)

diff --git a/net/sunrpc/backchannel_rqst.c b/net/sunrpc/backchannel_rqst.c
index 28504dfd3dad..1baa41099469 100644
--- a/net/sunrpc/backchannel_rqst.c
+++ b/net/sunrpc/backchannel_rqst.c
@@ -67,6 +67,55 @@ static void xprt_free_allocation(struct rpc_rqst *req)
 	kfree(req);
 }
 
+static int xprt_alloc_xdr_buf(struct xdr_buf *buf, gfp_t gfp_flags)
+{
+	struct page *page;
+	/* Preallocate one XDR receive buffer */
+	page = alloc_page(gfp_flags);
+	if (page == NULL)
+		return -ENOMEM;
+	buf->head[0].iov_base = page_address(page);
+	buf->head[0].iov_len = PAGE_SIZE;
+	buf->tail[0].iov_base = NULL;
+	buf->tail[0].iov_len = 0;
+	buf->page_len = 0;
+	buf->len = 0;
+	buf->buflen = PAGE_SIZE;
+	return 0;
+}
+
+static
+struct rpc_rqst *xprt_alloc_bc_req(struct rpc_xprt *xprt, gfp_t gfp_flags)
+{
+	struct rpc_rqst *req;
+
+	/* Pre-allocate one backchannel rpc_rqst */
+	req = kzalloc(sizeof(*req), gfp_flags);
+	if (req == NULL)
+		return NULL;
+
+	req->rq_xprt = xprt;
+	INIT_LIST_HEAD(&req->rq_list);
+	INIT_LIST_HEAD(&req->rq_bc_list);
+
+	/* Preallocate one XDR receive buffer */
+	if (xprt_alloc_xdr_buf(&req->rq_rcv_buf, gfp_flags) < 0) {
+		printk(KERN_ERR "Failed to create bc receive xbuf\n");
+		goto out_free;
+	}
+	req->rq_rcv_buf.len = PAGE_SIZE;
+
+	/* Preallocate one XDR send buffer */
+	if (xprt_alloc_xdr_buf(&req->rq_snd_buf, gfp_flags) < 0) {
+		printk(KERN_ERR "Failed to create bc snd xbuf\n");
+		goto out_free;
+	}
+	return req;
+out_free:
+	xprt_free_allocation(req);
+	return NULL;
+}
+
 /*
  * Preallocate up to min_reqs structures and related buffers for use
  * by the backchannel.  This function can be called multiple times
@@ -87,9 +136,7 @@ static void xprt_free_allocation(struct rpc_rqst *req)
  */
 int xprt_setup_backchannel(struct rpc_xprt *xprt, unsigned int min_reqs)
 {
-	struct page *page_rcv = NULL, *page_snd = NULL;
-	struct xdr_buf *xbufp = NULL;
-	struct rpc_rqst *req, *tmp;
+	struct rpc_rqst *req;
 	struct list_head tmp_list;
 	int i;
 
@@ -106,7 +153,7 @@ int xprt_setup_backchannel(struct rpc_xprt *xprt, unsigned int min_reqs)
 	INIT_LIST_HEAD(&tmp_list);
 	for (i = 0; i < min_reqs; i++) {
 		/* Pre-allocate one backchannel rpc_rqst */
-		req = kzalloc(sizeof(struct rpc_rqst), GFP_KERNEL);
+		req = xprt_alloc_bc_req(xprt, GFP_KERNEL);
 		if (req == NULL) {
 			printk(KERN_ERR "Failed to create bc rpc_rqst\n");
 			goto out_free;
@@ -115,41 +162,6 @@ int xprt_setup_backchannel(struct rpc_xprt *xprt, unsigned int min_reqs)
 		/* Add the allocated buffer to the tmp list */
 		dprintk("RPC:       adding req= %p\n", req);
 		list_add(&req->rq_bc_pa_list, &tmp_list);
-
-		req->rq_xprt = xprt;
-		INIT_LIST_HEAD(&req->rq_list);
-		INIT_LIST_HEAD(&req->rq_bc_list);
-
-		/* Preallocate one XDR receive buffer */
-		page_rcv = alloc_page(GFP_KERNEL);
-		if (page_rcv == NULL) {
-			printk(KERN_ERR "Failed to create bc receive xbuf\n");
-			goto out_free;
-		}
-		xbufp = &req->rq_rcv_buf;
-		xbufp->head[0].iov_base = page_address(page_rcv);
-		xbufp->head[0].iov_len = PAGE_SIZE;
-		xbufp->tail[0].iov_base = NULL;
-		xbufp->tail[0].iov_len = 0;
-		xbufp->page_len = 0;
-		xbufp->len = PAGE_SIZE;
-		xbufp->buflen = PAGE_SIZE;
-
-		/* Preallocate one XDR send buffer */
-		page_snd = alloc_page(GFP_KERNEL);
-		if (page_snd == NULL) {
-			printk(KERN_ERR "Failed to create bc snd xbuf\n");
-			goto out_free;
-		}
-
-		xbufp = &req->rq_snd_buf;
-		xbufp->head[0].iov_base = page_address(page_snd);
-		xbufp->head[0].iov_len = 0;
-		xbufp->tail[0].iov_base = NULL;
-		xbufp->tail[0].iov_len = 0;
-		xbufp->page_len = 0;
-		xbufp->len = 0;
-		xbufp->buflen = PAGE_SIZE;
 	}
 
 	/*
@@ -167,7 +179,10 @@ out_free:
 	/*
 	 * Memory allocation failed, free the temporary list
 	 */
-	list_for_each_entry_safe(req, tmp, &tmp_list, rq_bc_pa_list) {
+	while (!list_empty(&tmp_list)) {
+		req = list_first_entry(&tmp_list,
+				struct rpc_rqst,
+				rq_bc_pa_list);
 		list_del(&req->rq_bc_pa_list);
 		xprt_free_allocation(req);
 	}
-- 
2.4.2

