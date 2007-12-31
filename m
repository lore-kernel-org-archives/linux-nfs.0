From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 20/40] svc: Move sk_reserved to svc_xprt
Date: Sun, 30 Dec 2007 21:07:55 -0600
Message-ID: <20071231030755.8430.80661.stgit@dell3.ogc.int>
References: <20071231030712.8430.45576.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:41537 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752638AbXLaDHz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 30 Dec 2007 22:07:55 -0500
In-Reply-To: <20071231030712.8430.45576.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


This functionally trivial patch moves the sk_reserved field to the 
transport independent svc_xprt structure. 

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svc_xprt.h |    1 +
 include/linux/sunrpc/svcsock.h  |    2 --
 net/sunrpc/svcsock.c            |   10 +++++-----
 3 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 0a3e09b..0b8ee06 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -53,6 +53,7 @@ struct svc_xprt {
 
 	struct svc_pool		*xpt_pool;	/* current pool iff queued */
 	struct svc_serv		*xpt_server;	/* service for transport */
+	atomic_t    	    	xpt_reserved;	/* space on outq that is rsvd */
 };
 
 int	svc_reg_xprt_class(struct svc_xprt_class *);
diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index 060508b..ba41f11 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -20,8 +20,6 @@ struct svc_sock {
 	struct socket *		sk_sock;	/* berkeley socket layer */
 	struct sock *		sk_sk;		/* INET layer */
 
-	atomic_t    	    	sk_reserved;	/* space on outq that is reserved */
-
 	spinlock_t		sk_lock;	/* protects sk_deferred and
 						 * sk_info_authunix */
 	struct list_head	sk_deferred;	/* deferred requests that need to
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 6dffdda..ec5ad81 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -288,7 +288,7 @@ svc_sock_enqueue(struct svc_sock *svsk)
 		rqstp->rq_sock = svsk;
 		svc_xprt_get(&svsk->sk_xprt);
 		rqstp->rq_reserved = serv->sv_max_mesg;
-		atomic_add(rqstp->rq_reserved, &svsk->sk_reserved);
+		atomic_add(rqstp->rq_reserved, &svsk->sk_xprt.xpt_reserved);
 		BUG_ON(svsk->sk_xprt.xpt_pool != pool);
 		wake_up(&rqstp->rq_wait);
 	} else {
@@ -353,7 +353,7 @@ void svc_reserve(struct svc_rqst *rqstp, int space)
 
 	if (space < rqstp->rq_reserved) {
 		struct svc_sock *svsk = rqstp->rq_sock;
-		atomic_sub((rqstp->rq_reserved - space), &svsk->sk_reserved);
+		atomic_sub((rqstp->rq_reserved - space), &svsk->sk_xprt.xpt_reserved);
 		rqstp->rq_reserved = space;
 
 		svc_sock_enqueue(svsk);
@@ -881,7 +881,7 @@ static int svc_udp_has_wspace(struct svc_xprt *xprt)
 	 * sock space.
 	 */
 	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
-	required = atomic_read(&svsk->sk_reserved) + serv->sv_max_mesg;
+	required = atomic_read(&svsk->sk_xprt.xpt_reserved) + serv->sv_max_mesg;
 	if (required*2 > sock_wspace(svsk->sk_sk))
 		return 0;
 	clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
@@ -1327,7 +1327,7 @@ static int svc_tcp_has_wspace(struct svc_xprt *xprt)
 	 * sock space.
 	 */
 	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
-	required = atomic_read(&svsk->sk_reserved) + serv->sv_max_mesg;
+	required = atomic_read(&svsk->sk_xprt.xpt_reserved) + serv->sv_max_mesg;
 	wspace = sk_stream_wspace(svsk->sk_sk);
 
 	if (wspace < sk_stream_min_wspace(svsk->sk_sk))
@@ -1544,7 +1544,7 @@ svc_recv(struct svc_rqst *rqstp, long timeout)
 		rqstp->rq_sock = svsk;
 		svc_xprt_get(&svsk->sk_xprt);
 		rqstp->rq_reserved = serv->sv_max_mesg;
-		atomic_add(rqstp->rq_reserved, &svsk->sk_reserved);
+		atomic_add(rqstp->rq_reserved, &svsk->sk_xprt.xpt_reserved);
 	} else {
 		/* No data pending. Go to sleep */
 		svc_thread_enqueue(pool, rqstp);
