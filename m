From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 24/38] svc: Make deferral processing xprt independent
Date: Thu, 29 Nov 2007 16:56:28 -0600
Message-ID: <20071129225628.15275.59215.stgit@dell3.ogc.int>
References: <20071129225510.15275.82660.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:47419 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1763285AbXK2XUS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Nov 2007 18:20:18 -0500
In-Reply-To: <20071129225510.15275.82660.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


This patch moves the transport independent sk_deferred list to the svc_xprt
structure and updates the svc_deferred_req structure to keep pointers to
svc_xprt's directly. The deferral processing code is also moved out of the
transport dependent recvfrom functions and into the generic svc_recv path.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svc.h      |    2 +
 include/linux/sunrpc/svc_xprt.h |    2 +
 include/linux/sunrpc/svcsock.h  |    3 --
 net/sunrpc/svc_xprt.c           |    1 +
 net/sunrpc/svcsock.c            |   58 +++++++++++++++++----------------------
 5 files changed, 29 insertions(+), 37 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index cfb2652..40adc9d 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -320,7 +320,7 @@ static inline void svc_free_res_pages(struct svc_rqst *rqstp)
 
 struct svc_deferred_req {
 	u32			prot;	/* protocol (UDP or TCP) */
-	struct svc_sock		*svsk;
+	struct svc_xprt		*xprt;
 	struct sockaddr_storage	addr;	/* where reply must go */
 	size_t			addrlen;
 	union svc_addr_u	daddr;	/* where reply must come from */
diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index dfb1d4d..d93ae27 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -59,6 +59,8 @@ struct svc_xprt {
 	spinlock_t		xpt_lock;	/* protects sk_deferred
 						 * and xpt_auth_cache */
 	void			*xpt_auth_cache;/* auth cache */
+	struct list_head	xpt_deferred;	/* deferred requests that need
+						 * to be revisted */
 };
 
 int	svc_reg_xprt_class(struct svc_xprt_class *);
diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index f2ed6a2..96a229e 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -20,9 +20,6 @@ struct svc_sock {
 	struct socket *		sk_sock;	/* berkeley socket layer */
 	struct sock *		sk_sk;		/* INET layer */
 
-	struct list_head	sk_deferred;	/* deferred requests that need to
-						 * be revisted */
-
 	/* We keep the old state_change and data_ready CB's here */
 	void			(*sk_ostate)(struct sock *);
 	void			(*sk_odata)(struct sock *, int bytes);
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 79009c2..fdf0d8c 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -115,6 +115,7 @@ void svc_xprt_init(struct svc_xprt_class *xcl, struct svc_xprt *xprt,
 	xprt->xpt_server = serv;
 	INIT_LIST_HEAD(&xprt->xpt_list);
 	INIT_LIST_HEAD(&xprt->xpt_ready);
+	INIT_LIST_HEAD(&xprt->xpt_deferred);
 	mutex_init(&xprt->xpt_mutex);
 	spin_lock_init(&xprt->xpt_lock);
 }
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index d149f4e..62b5225 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -89,7 +89,7 @@ static void		svc_close_xprt(struct svc_xprt *xprt);
 static void		svc_sock_detach(struct svc_xprt *);
 static void		svc_sock_free(struct svc_xprt *);
 
-static struct svc_deferred_req *svc_deferred_dequeue(struct svc_sock *svsk);
+static struct svc_deferred_req *svc_deferred_dequeue(struct svc_xprt *xprt);
 static int svc_deferred_recv(struct svc_rqst *rqstp);
 static struct cache_deferred_req *svc_defer(struct cache_req *req);
 static struct svc_xprt *
@@ -786,11 +786,6 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 				(serv->sv_nrthreads+3) * serv->sv_max_mesg,
 				(serv->sv_nrthreads+3) * serv->sv_max_mesg);
 
-	if ((rqstp->rq_deferred = svc_deferred_dequeue(svsk))) {
-		svc_xprt_received(&svsk->sk_xprt);
-		return svc_deferred_recv(rqstp);
-	}
-
 	clear_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
 	skb = NULL;
 	err = kernel_recvmsg(svsk->sk_sock, &msg, NULL,
@@ -1155,11 +1150,6 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		test_bit(XPT_CONN, &svsk->sk_xprt.xpt_flags),
 		test_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags));
 
-	if ((rqstp->rq_deferred = svc_deferred_dequeue(svsk))) {
-		svc_xprt_received(&svsk->sk_xprt);
-		return svc_deferred_recv(rqstp);
-	}
-
 	if (test_and_clear_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags))
 		/* sndbuf needs to have room for one request
 		 * per thread, otherwise we can stall even when the
@@ -1617,7 +1607,12 @@ svc_recv(struct svc_rqst *rqstp, long timeout)
 		dprintk("svc: server %p, pool %u, socket %p, inuse=%d\n",
 			rqstp, pool->sp_id, svsk,
 			atomic_read(&svsk->sk_xprt.xpt_ref.refcount));
-		len = svsk->sk_xprt.xpt_ops->xpo_recvfrom(rqstp);
+		rqstp->rq_deferred = svc_deferred_dequeue(&svsk->sk_xprt);
+		if (rqstp->rq_deferred) {
+			svc_xprt_received(&svsk->sk_xprt);
+			len = svc_deferred_recv(rqstp);
+		} else
+			len = svsk->sk_xprt.xpt_ops->xpo_recvfrom(rqstp);
 		dprintk("svc: got len=%d\n", len);
 	}
 
@@ -1774,7 +1769,6 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 	svsk->sk_ostate = inet->sk_state_change;
 	svsk->sk_odata = inet->sk_data_ready;
 	svsk->sk_owspace = inet->sk_write_space;
-	INIT_LIST_HEAD(&svsk->sk_deferred);
 
 	/* Initialize the socket */
 	if (sock->type == SOCK_DGRAM)
@@ -1992,22 +1986,21 @@ void svc_close_all(struct list_head *xprt_list)
 static void svc_revisit(struct cache_deferred_req *dreq, int too_many)
 {
 	struct svc_deferred_req *dr = container_of(dreq, struct svc_deferred_req, handle);
-	struct svc_sock *svsk;
+	struct svc_xprt *xprt = dr->xprt;
 
 	if (too_many) {
-		svc_xprt_put(&dr->svsk->sk_xprt);
+		svc_xprt_put(xprt);
 		kfree(dr);
 		return;
 	}
 	dprintk("revisit queued\n");
-	svsk = dr->svsk;
-	dr->svsk = NULL;
-	spin_lock(&svsk->sk_xprt.xpt_lock);
-	list_add(&dr->handle.recent, &svsk->sk_deferred);
-	spin_unlock(&svsk->sk_xprt.xpt_lock);
-	set_bit(XPT_DEFERRED, &svsk->sk_xprt.xpt_flags);
-	svc_xprt_enqueue(&svsk->sk_xprt);
-	svc_xprt_put(&svsk->sk_xprt);
+	dr->xprt = NULL;
+	spin_lock(&xprt->xpt_lock);
+	list_add(&dr->handle.recent, &xprt->xpt_deferred);
+	spin_unlock(&xprt->xpt_lock);
+	set_bit(XPT_DEFERRED, &xprt->xpt_flags);
+	svc_xprt_enqueue(xprt);
+	svc_xprt_put(xprt);
 }
 
 static struct cache_deferred_req *
@@ -2038,7 +2031,7 @@ svc_defer(struct cache_req *req)
 		memcpy(dr->args, rqstp->rq_arg.head[0].iov_base-skip, dr->argslen<<2);
 	}
 	svc_xprt_get(rqstp->rq_xprt);
-	dr->svsk = rqstp->rq_sock;
+	dr->xprt = rqstp->rq_xprt;
 
 	dr->handle.revisit = svc_revisit;
 	return &dr->handle;
@@ -2064,22 +2057,21 @@ static int svc_deferred_recv(struct svc_rqst *rqstp)
 }
 
 
-static struct svc_deferred_req *svc_deferred_dequeue(struct svc_sock *svsk)
+static struct svc_deferred_req *svc_deferred_dequeue(struct svc_xprt *xprt)
 {
 	struct svc_deferred_req *dr = NULL;
 
-	if (!test_bit(XPT_DEFERRED, &svsk->sk_xprt.xpt_flags))
+	if (!test_bit(XPT_DEFERRED, &xprt->xpt_flags))
 		return NULL;
-	spin_lock(&svsk->sk_xprt.xpt_lock);
-	clear_bit(XPT_DEFERRED, &svsk->sk_xprt.xpt_flags);
-	if (!list_empty(&svsk->sk_deferred)) {
-		dr = list_entry(svsk->sk_deferred.next,
+	spin_lock(&xprt->xpt_lock);
+	clear_bit(XPT_DEFERRED, &xprt->xpt_flags);
+	if (!list_empty(&xprt->xpt_deferred)) {
+		dr = list_entry(xprt->xpt_deferred.next,
 				struct svc_deferred_req,
 				handle.recent);
 		list_del_init(&dr->handle.recent);
-		set_bit(XPT_DEFERRED, &svsk->sk_xprt.xpt_flags);
+		set_bit(XPT_DEFERRED, &xprt->xpt_flags);
 	}
-	spin_unlock(&svsk->sk_xprt.xpt_lock);
+	spin_unlock(&xprt->xpt_lock);
 	return dr;
 }
-
