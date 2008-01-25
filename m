From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 066/100] svc: Move sk_reserved to svc_xprt
Date: Fri, 25 Jan 2008 18:16:46 -0500
Message-ID: <1201303040-7779-66-git-send-email-bfields@citi.umich.edu>
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
Cc: Tom Tucker <tom@opengridcomputing.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47487 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761979AbYAYXSF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:18:05 -0500
In-Reply-To: <1201303040-7779-65-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tom Tucker <tom@opengridcomputing.com>

This functionally trivial patch moves the sk_reserved field to the
transport independent svc_xprt structure.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
Acked-by: Neil Brown <neilb@suse.de>
Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Greg Banks <gnb@sgi.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
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
-- 
1.5.4.rc2.60.gb2e62

