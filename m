From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 073/100] svc: Make deferral processing xprt independent
Date: Fri, 25 Jan 2008 18:16:53 -0500
Message-ID: <1201303040-7779-73-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-5-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-6-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-7-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-8-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-9-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-10-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-11-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-12-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-13-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-14-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-15-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-16-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-17-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-18-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-19-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-20-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-21-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-22-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-23-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-24-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-25-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-26-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-27-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-28-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-29-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-30-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-31-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-32-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-33-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-34-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-35-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-36-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-37-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-38-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-39-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-40-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-41-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-42-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-43-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-44-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-45-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-46-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-47-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-48-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-49-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-50-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-51-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-52-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-53-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-54-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-55-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-56-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-57-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-58-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-59-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-60-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-61-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-62-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-63-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-64-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-65-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-66-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-67-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-68-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-69-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-70-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-71-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-72-git-send-email-bfields@citi.umich.edu>
Cc: Tom Tucker <tom@opengridcomputing.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47508 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762170AbYAYXSN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:18:13 -0500
In-Reply-To: <1201303040-7779-72-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tom Tucker <tom@opengridcomputing.com>

This patch moves the transport independent sk_deferred list to the svc_xprt
structure and updates the svc_deferred_req structure to keep pointers to
svc_xprt's directly. The deferral processing code is also moved out of the
transport dependent recvfrom functions and into the generic svc_recv path.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
Acked-by: Neil Brown <neilb@suse.de>
Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Greg Banks <gnb@sgi.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 include/linux/sunrpc/svc.h      |    2 +-
 include/linux/sunrpc/svc_xprt.h |    2 +
 include/linux/sunrpc/svcsock.h  |    3 --
 net/sunrpc/svc_xprt.c           |    1 +
 net/sunrpc/svcsock.c            |   57 +++++++++++++++++----------------------
 5 files changed, 29 insertions(+), 36 deletions(-)

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
index 1b5da39..6a8445b 100644
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
index d2ac130..023aeb0 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -102,6 +102,7 @@ void svc_xprt_init(struct svc_xprt_class *xcl, struct svc_xprt *xprt,
 	xprt->xpt_server = serv;
 	INIT_LIST_HEAD(&xprt->xpt_list);
 	INIT_LIST_HEAD(&xprt->xpt_ready);
+	INIT_LIST_HEAD(&xprt->xpt_deferred);
 	mutex_init(&xprt->xpt_mutex);
 	spin_lock_init(&xprt->xpt_lock);
 }
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 073e832..4d51098 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -89,7 +89,7 @@ static void		svc_close_xprt(struct svc_xprt *xprt);
 static void		svc_sock_detach(struct svc_xprt *);
 static void		svc_sock_free(struct svc_xprt *);
 
-static struct svc_deferred_req *svc_deferred_dequeue(struct svc_sock *svsk);
+static struct svc_deferred_req *svc_deferred_dequeue(struct svc_xprt *xprt);
 static int svc_deferred_recv(struct svc_rqst *rqstp);
 static struct cache_deferred_req *svc_defer(struct cache_req *req);
 static struct svc_xprt *svc_create_socket(struct svc_serv *, int,
@@ -771,11 +771,6 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
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
@@ -1138,11 +1133,6 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
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
@@ -1601,7 +1591,12 @@ svc_recv(struct svc_rqst *rqstp, long timeout)
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
 
@@ -1758,7 +1753,6 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 	svsk->sk_ostate = inet->sk_state_change;
 	svsk->sk_odata = inet->sk_data_ready;
 	svsk->sk_owspace = inet->sk_write_space;
-	INIT_LIST_HEAD(&svsk->sk_deferred);
 
 	/* Initialize the socket */
 	if (sock->type == SOCK_DGRAM)
@@ -1976,22 +1970,21 @@ void svc_close_all(struct list_head *xprt_list)
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
@@ -2022,7 +2015,7 @@ svc_defer(struct cache_req *req)
 		memcpy(dr->args, rqstp->rq_arg.head[0].iov_base-skip, dr->argslen<<2);
 	}
 	svc_xprt_get(rqstp->rq_xprt);
-	dr->svsk = rqstp->rq_sock;
+	dr->xprt = rqstp->rq_xprt;
 
 	dr->handle.revisit = svc_revisit;
 	return &dr->handle;
@@ -2048,21 +2041,21 @@ static int svc_deferred_recv(struct svc_rqst *rqstp)
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
-- 
1.5.4.rc2.60.gb2e62

