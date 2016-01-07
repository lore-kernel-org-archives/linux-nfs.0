Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:35171 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751920AbcAGTtj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jan 2016 14:49:39 -0500
Subject: [PATCH v5 06/10] svcrdma: Add gfp flags to svc_rdma_post_recv()
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org, dledford@redhat.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 07 Jan 2016 14:49:37 -0500
Message-ID: <20160107194936.2662.41890.stgit@klimt.1015granger.net>
In-Reply-To: <20160107194251.2662.88158.stgit@klimt.1015granger.net>
References: <20160107194251.2662.88158.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

svc_rdma_post_recv() allocates pages for receive buffers on-demand.
It uses GFP_KERNEL so the allocator tries hard, and may sleep. But
I'm about to add a call to svc_rdma_post_recv() from a function
that may not sleep.

Since all svc_rdma_post_recv() call sites can tolerate its failure,
allow it to fail if the page allocator returns nothing. Longer term,
receive buffers, being a finite resource per-connection, should be
pre-allocated and re-used.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Acked-by: Bruce Fields <bfields@fieldses.org>
---
 include/linux/sunrpc/svc_rdma.h          |    2 +-
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |    2 +-
 net/sunrpc/xprtrdma/svc_rdma_transport.c |    8 +++++---
 3 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 141edbb..729ff35 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -221,7 +221,7 @@ extern struct rpcrdma_read_chunk *
 extern int svc_rdma_send(struct svcxprt_rdma *, struct ib_send_wr *);
 extern void svc_rdma_send_error(struct svcxprt_rdma *, struct rpcrdma_msg *,
 				enum rpcrdma_errcode);
-extern int svc_rdma_post_recv(struct svcxprt_rdma *);
+extern int svc_rdma_post_recv(struct svcxprt_rdma *, gfp_t);
 extern int svc_rdma_create_listen(struct svc_serv *, int, struct sockaddr *);
 extern struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *);
 extern void svc_rdma_put_context(struct svc_rdma_op_ctxt *, int);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 9a097f9..aeaec7a 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -465,7 +465,7 @@ static int send_reply(struct svcxprt_rdma *rdma,
 	int ret;
 
 	/* Post a recv buffer to handle another request. */
-	ret = svc_rdma_post_recv(rdma);
+	ret = svc_rdma_post_recv(rdma, GFP_KERNEL);
 	if (ret) {
 		printk(KERN_INFO
 		       "svcrdma: could not post a receive buffer, err=%d."
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 0b9e17e..20fc095 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -668,7 +668,7 @@ static struct svcxprt_rdma *rdma_create_xprt(struct svc_serv *serv,
 	return cma_xprt;
 }
 
-int svc_rdma_post_recv(struct svcxprt_rdma *xprt)
+int svc_rdma_post_recv(struct svcxprt_rdma *xprt, gfp_t flags)
 {
 	struct ib_recv_wr recv_wr, *bad_recv_wr;
 	struct svc_rdma_op_ctxt *ctxt;
@@ -686,7 +686,9 @@ int svc_rdma_post_recv(struct svcxprt_rdma *xprt)
 			pr_err("svcrdma: Too many sges (%d)\n", sge_no);
 			goto err_put_ctxt;
 		}
-		page = alloc_page(GFP_KERNEL | __GFP_NOFAIL);
+		page = alloc_page(flags);
+		if (!page)
+			goto err_put_ctxt;
 		ctxt->pages[sge_no] = page;
 		pa = ib_dma_map_page(xprt->sc_cm_id->device,
 				     page, 0, PAGE_SIZE,
@@ -1182,7 +1184,7 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 
 	/* Post receive buffers */
 	for (i = 0; i < newxprt->sc_max_requests; i++) {
-		ret = svc_rdma_post_recv(newxprt);
+		ret = svc_rdma_post_recv(newxprt, GFP_KERNEL);
 		if (ret) {
 			dprintk("svcrdma: failure posting receive buffers\n");
 			goto errout;

