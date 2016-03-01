Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:35023 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750997AbcCASGV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Mar 2016 13:06:21 -0500
Subject: [PATCH v5 07/14] svcrdma: svc_rdma_post_recv() should close
 connection on error
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 01 Mar 2016 13:06:20 -0500
Message-ID: <20160301180620.2492.31638.stgit@klimt.1015granger.net>
In-Reply-To: <20160301180337.2492.4255.stgit@klimt.1015granger.net>
References: <20160301180337.2492.4255.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Most svc_rdma_post_recv() call sites close the transport
connection when a receive cannot be posted. Wrap that in a common
helper.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Devesh Sharma <devesh.sharma@broadcom.com>
Tested-by: Devesh Sharma <devesh.sharma@broadcom.com>
---
 include/linux/sunrpc/svc_rdma.h            |    1 +
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |   11 ++---------
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c    |   10 +---------
 net/sunrpc/xprtrdma/svc_rdma_sendto.c      |    7 +------
 net/sunrpc/xprtrdma/svc_rdma_transport.c   |   15 +++++++++++++++
 5 files changed, 20 insertions(+), 24 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 40b6785..aef47dd 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -234,6 +234,7 @@ extern int svc_rdma_send(struct svcxprt_rdma *, struct ib_send_wr *);
 extern void svc_rdma_send_error(struct svcxprt_rdma *, struct rpcrdma_msg *,
 				enum rpcrdma_errcode);
 extern int svc_rdma_post_recv(struct svcxprt_rdma *, gfp_t);
+extern int svc_rdma_repost_recv(struct svcxprt_rdma *, gfp_t);
 extern int svc_rdma_create_listen(struct svc_serv *, int, struct sockaddr *);
 extern struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *);
 extern void svc_rdma_put_context(struct svc_rdma_op_ctxt *, int);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
index de39196..254be86 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
@@ -111,16 +111,9 @@ static int svc_rdma_bc_sendto(struct svcxprt_rdma *rdma,
 	if (ret)
 		goto out_err;
 
-	/* Post a recv buffer to handle the reply for this request. */
-	ret = svc_rdma_post_recv(rdma, GFP_NOIO);
-	if (ret) {
-		pr_err("svcrdma: Failed to post bc receive buffer, err=%d.\n",
-		       ret);
-		pr_err("svcrdma: closing transport %p.\n", rdma);
-		set_bit(XPT_CLOSE, &rdma->sc_xprt.xpt_flags);
-		ret = -ENOTCONN;
+	ret = svc_rdma_repost_recv(rdma, GFP_NOIO);
+	if (ret)
 		goto out_err;
-	}
 
 	ctxt = svc_rdma_get_context(rdma);
 	ctxt->pages[0] = virt_to_page(rqst->rq_buffer);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index c8b8a8b..acf15b8 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -711,13 +711,5 @@ defer:
 	return 0;
 
 repost:
-	ret = svc_rdma_post_recv(rdma_xprt, GFP_KERNEL);
-	if (ret) {
-		pr_err("svcrdma: could not post a receive buffer, err=%d.\n",
-		       ret);
-		pr_err("svcrdma: closing transport %p.\n", rdma_xprt);
-		set_bit(XPT_CLOSE, &rdma_xprt->sc_xprt.xpt_flags);
-		ret = -ENOTCONN;
-	}
-	return ret;
+	return svc_rdma_repost_recv(rdma_xprt, GFP_KERNEL);
 }
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 0f8798d..ace9efa 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -475,13 +475,8 @@ static int send_reply(struct svcxprt_rdma *rdma,
 	int pages;
 	int ret;
 
-	/* Post a recv buffer to handle another request. */
-	ret = svc_rdma_post_recv(rdma, GFP_KERNEL);
+	ret = svc_rdma_repost_recv(rdma, GFP_KERNEL);
 	if (ret) {
-		printk(KERN_INFO
-		       "svcrdma: could not post a receive buffer, err=%d."
-		       "Closing transport %p.\n", ret, rdma);
-		set_bit(XPT_CLOSE, &rdma->sc_xprt.xpt_flags);
 		svc_rdma_put_context(ctxt, 0);
 		return -ENOTCONN;
 	}
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 5763825..03fdfce 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -722,6 +722,21 @@ int svc_rdma_post_recv(struct svcxprt_rdma *xprt, gfp_t flags)
 	return -ENOMEM;
 }
 
+int svc_rdma_repost_recv(struct svcxprt_rdma *xprt, gfp_t flags)
+{
+	int ret = 0;
+
+	ret = svc_rdma_post_recv(xprt, flags);
+	if (ret) {
+		pr_err("svcrdma: could not post a receive buffer, err=%d.\n",
+		       ret);
+		pr_err("svcrdma: closing transport %p.\n", xprt);
+		set_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags);
+		ret = -ENOTCONN;
+	}
+	return ret;
+}
+
 /*
  * This function handles the CONNECT_REQUEST event on a listening
  * endpoint. It is passed the cma_id for the _new_ connection. The context in

