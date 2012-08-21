Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46809 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751725Ab2HUU5g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Aug 2012 16:57:36 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 11/14] svcrpc: make svc_xprt_received static
Date: Tue, 21 Aug 2012 16:57:29 -0400
Message-Id: <1345582652-18476-12-git-send-email-bfields@redhat.com>
In-Reply-To: <1345582652-18476-1-git-send-email-bfields@redhat.com>
References: <1345582652-18476-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Note this isn't used outside svc_xprt.c.

May as well move it so we don't need a declaration while we're here.

Also remove an outdated comment.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 include/linux/sunrpc/svc_xprt.h          |    1 -
 net/sunrpc/svc_xprt.c                    |   41 +++++++++++++++---------------
 net/sunrpc/xprtrdma/svc_rdma_transport.c |    4 ---
 3 files changed, 20 insertions(+), 26 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 73c7a68..e630d63 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -114,7 +114,6 @@ void	svc_xprt_init(struct net *, struct svc_xprt_class *, struct svc_xprt *,
 int	svc_create_xprt(struct svc_serv *, const char *, struct net *,
 			const int, const unsigned short, int);
 void	svc_xprt_enqueue(struct svc_xprt *xprt);
-void	svc_xprt_received(struct svc_xprt *);
 void	svc_xprt_put(struct svc_xprt *xprt);
 void	svc_xprt_copy_addrs(struct svc_rqst *rqstp, struct svc_xprt *xprt);
 void	svc_close_xprt(struct svc_xprt *xprt);
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 3e31730..295e6ed 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -208,6 +208,26 @@ static struct svc_xprt *__svc_xpo_create(struct svc_xprt_class *xcl,
 	return xcl->xcl_ops->xpo_create(serv, net, sap, len, flags);
 }
 
+/*
+ * svc_xprt_received conditionally queues the transport for processing
+ * by another thread. The caller must hold the XPT_BUSY bit and must
+ * not thereafter touch transport data.
+ *
+ * Note: XPT_DATA only gets cleared when a read-attempt finds no (or
+ * insufficient) data.
+ */
+static void svc_xprt_received(struct svc_xprt *xprt)
+{
+	BUG_ON(!test_bit(XPT_BUSY, &xprt->xpt_flags));
+	/* As soon as we clear busy, the xprt could be closed and
+	 * 'put', so we need a reference to call svc_xprt_enqueue with:
+	 */
+	svc_xprt_get(xprt);
+	clear_bit(XPT_BUSY, &xprt->xpt_flags);
+	svc_xprt_enqueue(xprt);
+	svc_xprt_put(xprt);
+}
+
 void svc_add_new_perm_xprt(struct svc_serv *serv, struct svc_xprt *new)
 {
 	clear_bit(XPT_TEMP, &new->xpt_flags);
@@ -398,27 +418,6 @@ static struct svc_xprt *svc_xprt_dequeue(struct svc_pool *pool)
 	return xprt;
 }
 
-/*
- * svc_xprt_received conditionally queues the transport for processing
- * by another thread. The caller must hold the XPT_BUSY bit and must
- * not thereafter touch transport data.
- *
- * Note: XPT_DATA only gets cleared when a read-attempt finds no (or
- * insufficient) data.
- */
-void svc_xprt_received(struct svc_xprt *xprt)
-{
-	BUG_ON(!test_bit(XPT_BUSY, &xprt->xpt_flags));
-	/* As soon as we clear busy, the xprt could be closed and
-	 * 'put', so we need a reference to call svc_xprt_enqueue with:
-	 */
-	svc_xprt_get(xprt);
-	clear_bit(XPT_BUSY, &xprt->xpt_flags);
-	svc_xprt_enqueue(xprt);
-	svc_xprt_put(xprt);
-}
-EXPORT_SYMBOL_GPL(svc_xprt_received);
-
 /**
  * svc_reserve - change the space reserved for the reply to a request.
  * @rqstp:  The request in question
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 73b428b..62e4f9b 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -578,10 +578,6 @@ static void handle_connect_req(struct rdma_cm_id *new_cma_id, size_t client_ird)
 	list_add_tail(&newxprt->sc_accept_q, &listen_xprt->sc_accept_q);
 	spin_unlock_bh(&listen_xprt->sc_lock);
 
-	/*
-	 * Can't use svc_xprt_received here because we are not on a
-	 * rqstp thread
-	*/
 	set_bit(XPT_CONN, &listen_xprt->sc_xprt.xpt_flags);
 	svc_xprt_enqueue(&listen_xprt->sc_xprt);
 }
-- 
1.7.9.5

