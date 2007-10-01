From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 18/35] svc: Move sk_reserved to svc_xprt
Date: Mon, 01 Oct 2007 14:28:10 -0500
Message-ID: <20071001192810.3250.79815.stgit@dell3.ogc.int>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IcQw2-0005bC-7f
	for nfs@lists.sourceforge.net; Mon, 01 Oct 2007 12:28:06 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IcQw6-0000yE-Ny
	for nfs@lists.sourceforge.net; Mon, 01 Oct 2007 12:28:11 -0700
In-Reply-To: <20071001191426.3250.15371.stgit@dell3.ogc.int>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


This functionally trivial patch moves the sk_reserved field to the 
transport independent svc_xprt structure. 

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svc_xprt.h |    1 +
 include/linux/sunrpc/svcsock.h  |    2 --
 net/sunrpc/svcsock.c            |   10 +++++-----
 3 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 6064bc3..e8be38f 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -54,6 +54,7 @@ #define XPT_LISTENER	11		/* listening en
 
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
index 2ed64fd..8178e65 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -304,7 +304,7 @@ svc_sock_enqueue(struct svc_sock *svsk)
 		rqstp->rq_sock = svsk;
 		svc_xprt_get(&svsk->sk_xprt);
 		rqstp->rq_reserved = serv->sv_max_mesg;
-		atomic_add(rqstp->rq_reserved, &svsk->sk_reserved);
+		atomic_add(rqstp->rq_reserved, &svsk->sk_xprt.xpt_reserved);
 		BUG_ON(svsk->sk_xprt.xpt_pool != pool);
 		wake_up(&rqstp->rq_wait);
 	} else {
@@ -369,7 +369,7 @@ void svc_reserve(struct svc_rqst *rqstp,
 
 	if (space < rqstp->rq_reserved) {
 		struct svc_sock *svsk = rqstp->rq_sock;
-		atomic_sub((rqstp->rq_reserved - space), &svsk->sk_reserved);
+		atomic_sub((rqstp->rq_reserved - space), &svsk->sk_xprt.xpt_reserved);
 		rqstp->rq_reserved = space;
 
 		svc_sock_enqueue(svsk);
@@ -899,7 +899,7 @@ svc_udp_has_wspace(struct svc_xprt *xprt
 	 * sock space.
 	 */
 	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
-	required = atomic_read(&svsk->sk_reserved) + serv->sv_max_mesg;
+	required = atomic_read(&svsk->sk_xprt.xpt_reserved) + serv->sv_max_mesg;
 	if (required*2 > sock_wspace(svsk->sk_sk))
 		return 0;
 	clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
@@ -1351,7 +1351,7 @@ svc_tcp_has_wspace(struct svc_xprt *xprt
 	 * sock space.
 	 */
 	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
-	required = atomic_read(&svsk->sk_reserved) + serv->sv_max_mesg;
+	required = atomic_read(&svsk->sk_xprt.xpt_reserved) + serv->sv_max_mesg;
 	if (required*2 > sk_stream_wspace(svsk->sk_sk))
 		return 0;
 	clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
@@ -1568,7 +1568,7 @@ svc_recv(struct svc_rqst *rqstp, long ti
 		rqstp->rq_sock = svsk;
 		svc_xprt_get(&svsk->sk_xprt);
 		rqstp->rq_reserved = serv->sv_max_mesg;
-		atomic_add(rqstp->rq_reserved, &svsk->sk_reserved);
+		atomic_add(rqstp->rq_reserved, &svsk->sk_xprt.xpt_reserved);
 	} else {
 		/* No data pending. Go to sleep */
 		svc_thread_enqueue(pool, rqstp);

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
