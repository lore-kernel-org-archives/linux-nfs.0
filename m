Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:38047 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753108AbdLURm7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Dec 2017 12:42:59 -0500
Subject: [PATCH v1 1/3] svcrdma: Post Receives in the Receive completion
 handler
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 21 Dec 2017 12:42:57 -0500
Message-ID: <20171221174257.11802.25654.stgit@klimt.1015granger.net>
In-Reply-To: <20171221174206.11802.16286.stgit@klimt.1015granger.net>
References: <20171221174206.11802.16286.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This change improves Receive efficiency by posting Receives only
on the same CPU that handles Receive completion. Improved latency
and throughput has been noted with this change.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc_rdma.h            |    2 --
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |    4 ----
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c    |   15 ++++-----------
 net/sunrpc/xprtrdma/svc_rdma_sendto.c      |    6 ------
 net/sunrpc/xprtrdma/svc_rdma_transport.c   |   25 +++++++------------------
 5 files changed, 11 insertions(+), 41 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 995c6fe..4b731b0 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -185,8 +185,6 @@ extern int svc_rdma_post_send_wr(struct svcxprt_rdma *rdma,
 extern void svc_rdma_wc_read(struct ib_cq *, struct ib_wc *);
 extern void svc_rdma_wc_inv(struct ib_cq *, struct ib_wc *);
 extern int svc_rdma_send(struct svcxprt_rdma *, struct ib_send_wr *);
-extern int svc_rdma_post_recv(struct svcxprt_rdma *, gfp_t);
-extern int svc_rdma_repost_recv(struct svcxprt_rdma *, gfp_t);
 extern int svc_rdma_create_listen(struct svc_serv *, int, struct sockaddr *);
 extern struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *);
 extern void svc_rdma_put_context(struct svc_rdma_op_ctxt *, int);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
index af78935..67b2d4f 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
@@ -129,10 +129,6 @@ static int svc_rdma_bc_sendto(struct svcxprt_rdma *rdma,
 	if (ret < 0)
 		goto out_err;
 
-	ret = svc_rdma_repost_recv(rdma, GFP_NOIO);
-	if (ret)
-		goto out_err;
-
 	/* Bump page refcnt so Send completion doesn't release
 	 * the rq_buffer before all retransmits are complete.
 	 */
diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index ad4bd62..3249f5a 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -400,10 +400,6 @@ static void svc_rdma_send_error(struct svcxprt_rdma *xprt,
 	struct page *page;
 	int ret;
 
-	ret = svc_rdma_repost_recv(xprt, GFP_KERNEL);
-	if (ret)
-		return;
-
 	page = alloc_page(GFP_KERNEL);
 	if (!page)
 		return;
@@ -551,12 +547,10 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
 	rqstp->rq_xprt_hlen = ret;
 
 	if (svc_rdma_is_backchannel_reply(xprt, p)) {
-		ret = svc_rdma_handle_bc_reply(xprt->xpt_bc_xprt, p,
-					       &rqstp->rq_arg);
+		svc_rdma_handle_bc_reply(xprt->xpt_bc_xprt, p,
+					 &rqstp->rq_arg);
 		svc_rdma_put_context(ctxt, 0);
-		if (ret)
-			goto repost;
-		return ret;
+		return 0;
 	}
 
 	p += rpcrdma_fixed_maxsz;
@@ -590,6 +584,5 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
 
 out_drop:
 	svc_rdma_put_context(ctxt, 1);
-repost:
-	return svc_rdma_repost_recv(rdma_xprt, GFP_KERNEL);
+	return 0;
 }
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 7c3a211..649441d 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -674,9 +674,6 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
 		svc_rdma_xdr_encode_reply_chunk(rdma_resp, rp_ch, ret);
 	}
 
-	ret = svc_rdma_post_recv(rdma, GFP_KERNEL);
-	if (ret)
-		goto err1;
 	ret = svc_rdma_send_reply_msg(rdma, rdma_argp, rdma_resp, rqstp,
 				      wr_lst, rp_ch);
 	if (ret < 0)
@@ -687,9 +684,6 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
 	if (ret != -E2BIG && ret != -EINVAL)
 		goto err1;
 
-	ret = svc_rdma_post_recv(rdma, GFP_KERNEL);
-	if (ret)
-		goto err1;
 	ret = svc_rdma_send_error_msg(rdma, rdma_resp, rqstp);
 	if (ret < 0)
 		goto err0;
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 46ec069..9ad12a2 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -58,6 +58,7 @@
 
 #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
 
+static int svc_rdma_post_recv(struct svcxprt_rdma *xprt);
 static struct svcxprt_rdma *rdma_create_xprt(struct svc_serv *, int);
 static struct svc_xprt *svc_rdma_create(struct svc_serv *serv,
 					struct net *net,
@@ -320,6 +321,8 @@ static void svc_rdma_wc_receive(struct ib_cq *cq, struct ib_wc *wc)
 	list_add_tail(&ctxt->list, &xprt->sc_rq_dto_q);
 	spin_unlock(&xprt->sc_rq_dto_lock);
 
+	svc_rdma_post_recv(xprt);
+
 	set_bit(XPT_DATA, &xprt->sc_xprt.xpt_flags);
 	if (test_bit(RDMAXPRT_CONN_PENDING, &xprt->sc_flags))
 		goto out;
@@ -404,7 +407,8 @@ static struct svcxprt_rdma *rdma_create_xprt(struct svc_serv *serv,
 	return cma_xprt;
 }
 
-int svc_rdma_post_recv(struct svcxprt_rdma *xprt, gfp_t flags)
+static int
+svc_rdma_post_recv(struct svcxprt_rdma *xprt)
 {
 	struct ib_recv_wr recv_wr, *bad_recv_wr;
 	struct svc_rdma_op_ctxt *ctxt;
@@ -423,7 +427,7 @@ int svc_rdma_post_recv(struct svcxprt_rdma *xprt, gfp_t flags)
 			pr_err("svcrdma: Too many sges (%d)\n", sge_no);
 			goto err_put_ctxt;
 		}
-		page = alloc_page(flags);
+		page = alloc_page(GFP_KERNEL);
 		if (!page)
 			goto err_put_ctxt;
 		ctxt->pages[sge_no] = page;
@@ -459,21 +463,6 @@ int svc_rdma_post_recv(struct svcxprt_rdma *xprt, gfp_t flags)
 	return -ENOMEM;
 }
 
-int svc_rdma_repost_recv(struct svcxprt_rdma *xprt, gfp_t flags)
-{
-	int ret = 0;
-
-	ret = svc_rdma_post_recv(xprt, flags);
-	if (ret) {
-		pr_err("svcrdma: could not post a receive buffer, err=%d.\n",
-		       ret);
-		pr_err("svcrdma: closing transport %p.\n", xprt);
-		set_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags);
-		ret = -ENOTCONN;
-	}
-	return ret;
-}
-
 static void
 svc_rdma_parse_connect_private(struct svcxprt_rdma *newxprt,
 			       struct rdma_conn_param *param)
@@ -833,7 +822,7 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 
 	/* Post receive buffers */
 	for (i = 0; i < newxprt->sc_max_requests; i++) {
-		ret = svc_rdma_post_recv(newxprt, GFP_KERNEL);
+		ret = svc_rdma_post_recv(newxprt);
 		if (ret) {
 			dprintk("svcrdma: failure posting receive buffers\n");
 			goto errout;

