From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 20/38] svc: Make svc_send transport neutral
Date: Thu, 29 Nov 2007 16:56:20 -0600
Message-ID: <20071129225620.15275.18756.stgit@dell3.ogc.int>
References: <20071129225510.15275.82660.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:47412 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1763134AbXK2XUO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Nov 2007 18:20:14 -0500
In-Reply-To: <20071129225510.15275.82660.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Move the sk_mutex field to the transport independent svc_xprt structure.
Now all the fields that svc_send touches are transport neutral. Change the 
svc_send function to use the transport independent svc_xprt directly instead 
of the transport dependent svc_sock structure.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svc_xprt.h |    1 +
 include/linux/sunrpc/svcsock.h  |    1 -
 net/sunrpc/svc_xprt.c           |    1 +
 net/sunrpc/svcsock.c            |   19 ++++++++-----------
 4 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index c9892d5..d5ef902 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -54,6 +54,7 @@ struct svc_xprt {
 	struct svc_pool		*xpt_pool;	/* current pool iff queued */
 	struct svc_serv		*xpt_server;	/* service for transport */
 	atomic_t    	    	xpt_reserved;	/* space on outq that is rsvd */
+	struct mutex		xpt_mutex;	/* to serialize sending data */
 };
 
 int	svc_reg_xprt_class(struct svc_xprt_class *);
diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index ba41f11..41c2dfa 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -24,7 +24,6 @@ struct svc_sock {
 						 * sk_info_authunix */
 	struct list_head	sk_deferred;	/* deferred requests that need to
 						 * be revisted */
-	struct mutex		sk_mutex;	/* to serialize sending data */
 
 	/* We keep the old state_change and data_ready CB's here */
 	void			(*sk_ostate)(struct sock *);
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index bbdada7..7544102 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -112,6 +112,7 @@ void svc_xprt_init(struct svc_xprt_class *xcl, struct svc_xprt *xprt,
 	xprt->xpt_server = serv;
 	INIT_LIST_HEAD(&xprt->xpt_list);
 	INIT_LIST_HEAD(&xprt->xpt_ready);
+	mutex_init(&xprt->xpt_mutex);
 }
 EXPORT_SYMBOL_GPL(svc_xprt_init);
 
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 17feb4b..5666541 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1650,15 +1650,13 @@ svc_drop(struct svc_rqst *rqstp)
 int
 svc_send(struct svc_rqst *rqstp)
 {
-	struct svc_sock	*svsk;
+	struct svc_xprt	*xprt;
 	int		len;
 	struct xdr_buf	*xb;
 
-	if ((svsk = rqstp->rq_sock) == NULL) {
-		printk(KERN_WARNING "NULL socket pointer in %s:%d\n",
-				__FILE__, __LINE__);
+	xprt = rqstp->rq_xprt;
+	if (!xprt)
 		return -EFAULT;
-	}
 
 	/* release the receive skb before sending the reply */
 	rqstp->rq_xprt->xpt_ops->xpo_release_rqst(rqstp);
@@ -1669,13 +1667,13 @@ svc_send(struct svc_rqst *rqstp)
 		xb->page_len +
 		xb->tail[0].iov_len;
 
-	/* Grab svsk->sk_mutex to serialize outgoing data. */
-	mutex_lock(&svsk->sk_mutex);
-	if (test_bit(XPT_DEAD, &svsk->sk_xprt.xpt_flags))
+	/* Grab mutex to serialize outgoing data. */
+	mutex_lock(&xprt->xpt_mutex);
+	if (test_bit(XPT_DEAD, &xprt->xpt_flags))
 		len = -ENOTCONN;
 	else
-		len = svsk->sk_xprt.xpt_ops->xpo_sendto(rqstp);
-	mutex_unlock(&svsk->sk_mutex);
+		len = xprt->xpt_ops->xpo_sendto(rqstp);
+	mutex_unlock(&xprt->xpt_mutex);
 	svc_sock_release(rqstp);
 
 	if (len == -ECONNREFUSED || len == -ENOTCONN || len == -EAGAIN)
@@ -1777,7 +1775,6 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 	svsk->sk_lastrecv = get_seconds();
 	spin_lock_init(&svsk->sk_lock);
 	INIT_LIST_HEAD(&svsk->sk_deferred);
-	mutex_init(&svsk->sk_mutex);
 
 	/* Initialize the socket */
 	if (sock->type == SOCK_DGRAM)
