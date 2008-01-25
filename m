From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 055/100] svc: Add a transport function that checks for write space
Date: Fri, 25 Jan 2008 18:16:35 -0500
Message-ID: <1201303040-7779-55-git-send-email-bfields@citi.umich.edu>
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
Cc: Tom Tucker <tom@opengridcomputing.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47436 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757954AbYAYXRr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:17:47 -0500
In-Reply-To: <1201303040-7779-54-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tom Tucker <tom@opengridcomputing.com>

In order to avoid blocking a service thread, the receive side checks
to see if there is sufficient write space to reply to the request.
Each transport has a different mechanism for determining if there is
enough write space to reply.

The code that checked for write space was coupled with code that
checked for CLOSE and CONN. These checks have been broken out into
separate statements to make the code easier to read.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
Acked-by: Neil Brown <neilb@suse.de>
Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Greg Banks <gnb@sgi.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 include/linux/sunrpc/svc_xprt.h |    1 +
 net/sunrpc/svcsock.c            |   82 ++++++++++++++++++++++++++------------
 2 files changed, 57 insertions(+), 26 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 199cfcb..85df97a 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -10,6 +10,7 @@
 #include <linux/sunrpc/svc.h>
 
 struct svc_xprt_ops {
+	int		(*xpo_has_wspace)(struct svc_xprt *);
 	int		(*xpo_recvfrom)(struct svc_rqst *);
 	void		(*xpo_prep_reply_hdr)(struct svc_rqst *);
 	int		(*xpo_sendto)(struct svc_rqst *);
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 492a1dc..2007881 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -205,22 +205,6 @@ static void svc_release_skb(struct svc_rqst *rqstp)
 }
 
 /*
- * Any space to write?
- */
-static inline unsigned long
-svc_sock_wspace(struct svc_sock *svsk)
-{
-	int wspace;
-
-	if (svsk->sk_sock->type == SOCK_STREAM)
-		wspace = sk_stream_wspace(svsk->sk_sk);
-	else
-		wspace = sock_wspace(svsk->sk_sk);
-
-	return wspace;
-}
-
-/*
  * Queue up a socket with data pending. If there are idle nfsd
  * processes, wake 'em up.
  *
@@ -269,22 +253,24 @@ svc_sock_enqueue(struct svc_sock *svsk)
 	BUG_ON(svsk->sk_pool != NULL);
 	svsk->sk_pool = pool;
 
-	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
-	if (((atomic_read(&svsk->sk_reserved) + serv->sv_max_mesg)*2
-	     > svc_sock_wspace(svsk))
-	    && !test_bit(SK_CLOSE, &svsk->sk_flags)
-	    && !test_bit(SK_CONN, &svsk->sk_flags)) {
+	/* Handle pending connection */
+	if (test_bit(SK_CONN, &svsk->sk_flags))
+		goto process;
+
+	/* Handle close in-progress */
+	if (test_bit(SK_CLOSE, &svsk->sk_flags))
+		goto process;
+
+	/* Check if we have space to reply to a request */
+	if (!svsk->sk_xprt.xpt_ops->xpo_has_wspace(&svsk->sk_xprt)) {
 		/* Don't enqueue while not enough space for reply */
-		dprintk("svc: socket %p  no space, %d*2 > %ld, not enqueued\n",
-			svsk->sk_sk, atomic_read(&svsk->sk_reserved)+serv->sv_max_mesg,
-			svc_sock_wspace(svsk));
+		dprintk("svc: no write space, socket %p  not enqueued\n", svsk);
 		svsk->sk_pool = NULL;
 		clear_bit(SK_BUSY, &svsk->sk_flags);
 		goto out_unlock;
 	}
-	clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
-
 
+ process:
 	if (!list_empty(&pool->sp_threads)) {
 		rqstp = list_entry(pool->sp_threads.next,
 				   struct svc_rqst,
@@ -897,6 +883,24 @@ static void svc_udp_prep_reply_hdr(struct svc_rqst *rqstp)
 {
 }
 
+static int svc_udp_has_wspace(struct svc_xprt *xprt)
+{
+	struct svc_sock *svsk = container_of(xprt, struct svc_sock, sk_xprt);
+	struct svc_serv	*serv = svsk->sk_server;
+	unsigned long required;
+
+	/*
+	 * Set the SOCK_NOSPACE flag before checking the available
+	 * sock space.
+	 */
+	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
+	required = atomic_read(&svsk->sk_reserved) + serv->sv_max_mesg;
+	if (required*2 > sock_wspace(svsk->sk_sk))
+		return 0;
+	clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
+	return 1;
+}
+
 static struct svc_xprt_ops svc_udp_ops = {
 	.xpo_recvfrom = svc_udp_recvfrom,
 	.xpo_sendto = svc_udp_sendto,
@@ -904,6 +908,7 @@ static struct svc_xprt_ops svc_udp_ops = {
 	.xpo_detach = svc_sock_detach,
 	.xpo_free = svc_sock_free,
 	.xpo_prep_reply_hdr = svc_udp_prep_reply_hdr,
+	.xpo_has_wspace = svc_udp_has_wspace,
 };
 
 static struct svc_xprt_class svc_udp_class = {
@@ -1366,6 +1371,30 @@ static void svc_tcp_prep_reply_hdr(struct svc_rqst *rqstp)
 	svc_putnl(resv, 0);
 }
 
+static int svc_tcp_has_wspace(struct svc_xprt *xprt)
+{
+	struct svc_sock *svsk = container_of(xprt, struct svc_sock, sk_xprt);
+	struct svc_serv	*serv = svsk->sk_server;
+	int required;
+	int wspace;
+
+	/*
+	 * Set the SOCK_NOSPACE flag before checking the available
+	 * sock space.
+	 */
+	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
+	required = atomic_read(&svsk->sk_reserved) + serv->sv_max_mesg;
+	wspace = sk_stream_wspace(svsk->sk_sk);
+
+	if (wspace < sk_stream_min_wspace(svsk->sk_sk))
+		return 0;
+	if (required * 2 > wspace)
+		return 0;
+
+	clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
+	return 1;
+}
+
 static struct svc_xprt_ops svc_tcp_ops = {
 	.xpo_recvfrom = svc_tcp_recvfrom,
 	.xpo_sendto = svc_tcp_sendto,
@@ -1373,6 +1402,7 @@ static struct svc_xprt_ops svc_tcp_ops = {
 	.xpo_detach = svc_sock_detach,
 	.xpo_free = svc_sock_free,
 	.xpo_prep_reply_hdr = svc_tcp_prep_reply_hdr,
+	.xpo_has_wspace = svc_tcp_has_wspace,
 };
 
 static struct svc_xprt_class svc_tcp_class = {
-- 
1.5.4.rc2.60.gb2e62

