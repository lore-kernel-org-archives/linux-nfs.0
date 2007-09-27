From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,
	PATCH 09/33] svc: Add a transport function that checks for write
	space
Date: Thu, 27 Sep 2007 00:01:53 -0500
Message-ID: <20070927050153.12677.18487.stgit@dell3.ogc.int>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IalVa-0005be-4x
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:01:56 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IalVe-0005El-QR
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:01:59 -0700
In-Reply-To: <20070927045751.12677.98896.stgit@dell3.ogc.int>
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


In order to avoid blocking a service thread, the receive side checks
to see if there is sufficient write space to reply to the request.
Each transport has a different mechanism for determining if there is
enough write space to reply.

The code that checked for white space was coupled with code that 
checked for CLOSE and CONN. These checks have been broken out into 
separate statements to make the code easier to read.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svc_xprt.h |    1 +
 net/sunrpc/svcsock.c            |   62 +++++++++++++++++++++++++++++++++------
 2 files changed, 53 insertions(+), 10 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 1cd86fe..47bedfa 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -10,6 +10,7 @@ #define SUNRPC_SVC_XPRT_H
 #include <linux/sunrpc/svc.h>
 
 struct svc_xprt_ops {
+	int		(*xpo_has_wspace)(struct svc_xprt *);
 	int		(*xpo_recvfrom)(struct svc_rqst *);
 	void		(*xpo_prep_reply_hdr)(struct svc_rqst *);
 	int		(*xpo_sendto)(struct svc_rqst *);
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 99f5faf..1df9933 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -269,22 +269,24 @@ svc_sock_enqueue(struct svc_sock *svsk)
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
+	if (!svsk->sk_xprt.xpt_ops.xpo_has_wspace(&svsk->sk_xprt)) {
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
@@ -898,6 +900,25 @@ svc_udp_prep_reply_hdr(struct svc_rqst *
 {
 }
 
+static int
+svc_udp_has_wspace(struct svc_xprt *xprt)
+{
+	struct svc_sock *svsk = (struct svc_sock*)xprt;
+	struct svc_serv	*serv = svsk->sk_server;
+	int required;
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
@@ -905,6 +926,7 @@ static struct svc_xprt_ops svc_udp_ops =
 	.xpo_detach = svc_sock_detach,
 	.xpo_free = svc_sock_free,
 	.xpo_prep_reply_hdr = svc_udp_prep_reply_hdr,
+	.xpo_has_wspace = svc_udp_has_wspace,
 };
 
 static struct svc_xprt_class svc_udp_class = {
@@ -1368,6 +1390,25 @@ svc_tcp_prep_reply_hdr(struct svc_rqst *
 	svc_putnl(resv, 0);
 }
 
+static int
+svc_tcp_has_wspace(struct svc_xprt *xprt)
+{
+	struct svc_sock *svsk = (struct svc_sock*)xprt;
+	struct svc_serv	*serv = svsk->sk_server;
+	int required;
+
+	/*
+	 * Set the SOCK_NOSPACE flag before checking the available
+	 * sock space.
+	 */
+	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
+	required = atomic_read(&svsk->sk_reserved) + serv->sv_max_mesg;
+	if (required*2 > sk_stream_wspace(svsk->sk_sk))
+		return 0;
+	clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
+	return 1;
+}
+
 static struct svc_xprt_ops svc_tcp_ops = {
 	.xpo_recvfrom = svc_tcp_recvfrom,
 	.xpo_sendto = svc_tcp_sendto,
@@ -1375,6 +1416,7 @@ static struct svc_xprt_ops svc_tcp_ops =
 	.xpo_detach = svc_sock_detach,
 	.xpo_free = svc_sock_free,
 	.xpo_prep_reply_hdr = svc_tcp_prep_reply_hdr,
+	.xpo_has_wspace = svc_tcp_has_wspace,
 };
 
 static struct svc_xprt_class svc_tcp_class = {

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
