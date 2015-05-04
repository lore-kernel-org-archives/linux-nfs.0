Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:35371 "EHLO
	mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751045AbbEDQTc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 May 2015 12:19:32 -0400
Received: by qkhg7 with SMTP id g7so88067744qkh.2
        for <linux-nfs@vger.kernel.org>; Mon, 04 May 2015 09:19:32 -0700 (PDT)
Received: from klimt.1015granger.net ([2604:8800:100:81fc:be5f:f4ff:fed6:c3ba])
        by mx.google.com with ESMTPSA id i91sm10159009qgd.46.2015.05.04.09.19.30
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 May 2015 09:19:30 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v1 6/8] svcrdma: Replace GFP_KERNEL in a loop with GFP_NOFAIL
To: linux-nfs@vger.kernel.org
Date: Mon, 04 May 2015 12:19:29 -0400
Message-ID: <20150504161929.16870.89105.stgit@klimt.1015granger.net>
In-Reply-To: <20150504160738.16870.19295.stgit@klimt.1015granger.net>
References: <20150504160738.16870.19295.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At the 2015 LSF/MM, it was requested that memory allocation
call sites that request GFP_KERNEL allocations in a loop should be
annotated with __GFP_NOFAIL.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/svc_rdma.h          |    1 -
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |    2 +-
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   32 ++++++------------------------
 3 files changed, 7 insertions(+), 28 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index c03ca0a..d26384b 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -211,7 +211,6 @@ extern int svc_rdma_sendto(struct svc_rqst *);
 extern int svc_rdma_send(struct svcxprt_rdma *, struct ib_send_wr *);
 extern void svc_rdma_send_error(struct svcxprt_rdma *, struct rpcrdma_msg *,
 				enum rpcrdma_errcode);
-struct page *svc_rdma_get_page(void);
 extern int svc_rdma_post_recv(struct svcxprt_rdma *);
 extern int svc_rdma_create_listen(struct svc_serv *, int, struct sockaddr *);
 extern struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 109e967..d25cd43 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -517,7 +517,7 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
 	inline_bytes = rqstp->rq_res.len;
 
 	/* Create the RDMA response header */
-	res_page = svc_rdma_get_page();
+	res_page = alloc_page(GFP_KERNEL | __GFP_NOFAIL);
 	rdma_resp = page_address(res_page);
 	reply_ary = svc_rdma_get_reply_array(rdma_argp);
 	if (reply_ary)
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index be08493..1ed4740 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -99,12 +99,8 @@ struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *xprt)
 {
 	struct svc_rdma_op_ctxt *ctxt;
 
-	while (1) {
-		ctxt = kmem_cache_alloc(svc_rdma_ctxt_cachep, GFP_KERNEL);
-		if (ctxt)
-			break;
-		schedule_timeout_uninterruptible(msecs_to_jiffies(500));
-	}
+	ctxt = kmem_cache_alloc(svc_rdma_ctxt_cachep,
+				GFP_KERNEL | __GFP_NOFAIL);
 	ctxt->xprt = xprt;
 	INIT_LIST_HEAD(&ctxt->dto_q);
 	ctxt->count = 0;
@@ -156,12 +152,8 @@ void svc_rdma_put_context(struct svc_rdma_op_ctxt *ctxt, int free_pages)
 struct svc_rdma_req_map *svc_rdma_get_req_map(void)
 {
 	struct svc_rdma_req_map *map;
-	while (1) {
-		map = kmem_cache_alloc(svc_rdma_map_cachep, GFP_KERNEL);
-		if (map)
-			break;
-		schedule_timeout_uninterruptible(msecs_to_jiffies(500));
-	}
+	map = kmem_cache_alloc(svc_rdma_map_cachep,
+			       GFP_KERNEL | __GFP_NOFAIL);
 	map->count = 0;
 	return map;
 }
@@ -490,18 +482,6 @@ static struct svcxprt_rdma *rdma_create_xprt(struct svc_serv *serv,
 	return cma_xprt;
 }
 
-struct page *svc_rdma_get_page(void)
-{
-	struct page *page;
-
-	while ((page = alloc_page(GFP_KERNEL)) == NULL) {
-		/* If we can't get memory, wait a bit and try again */
-		printk(KERN_INFO "svcrdma: out of memory...retrying in 1s\n");
-		schedule_timeout_uninterruptible(msecs_to_jiffies(1000));
-	}
-	return page;
-}
-
 int svc_rdma_post_recv(struct svcxprt_rdma *xprt)
 {
 	struct ib_recv_wr recv_wr, *bad_recv_wr;
@@ -520,7 +500,7 @@ int svc_rdma_post_recv(struct svcxprt_rdma *xprt)
 			pr_err("svcrdma: Too many sges (%d)\n", sge_no);
 			goto err_put_ctxt;
 		}
-		page = svc_rdma_get_page();
+		page = alloc_page(GFP_KERNEL | __GFP_NOFAIL);
 		ctxt->pages[sge_no] = page;
 		pa = ib_dma_map_page(xprt->sc_cm_id->device,
 				     page, 0, PAGE_SIZE,
@@ -1323,7 +1303,7 @@ void svc_rdma_send_error(struct svcxprt_rdma *xprt, struct rpcrdma_msg *rmsgp,
 	int length;
 	int ret;
 
-	p = svc_rdma_get_page();
+	p = alloc_page(GFP_KERNEL | __GFP_NOFAIL);
 	va = page_address(p);
 
 	/* XDR encode error */

