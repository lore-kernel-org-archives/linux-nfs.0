From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 04/20] svc: sko_has_wspace
Date: Tue, 10 Jul 2007 00:34:28 -0500
Message-ID: <20070710053428.28979.58102.stgit@dell3.ogc.int>
References: <20070710052711.28979.70843.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I88Mo-00074A-UQ
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 22:34:31 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I88Ms-0003S1-3t
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 22:34:34 -0700
Received: from dell3.ogc.int (localhost [127.0.0.1])
	by smtp.opengridcomputing.com (Postfix) with ESMTP id A70BE7C75F
	for <nfs@lists.sourceforge.net>; Tue, 10 Jul 2007 00:34:28 -0500 (CDT)
In-Reply-To: <20070710052711.28979.70843.stgit@dell3.ogc.int>
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


Move the code in svc_sock_enqueue() that checks for available
write space on the socket, into a new sko_has_wspace method
in svc_sock_ops.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
Signed-off-by: Peter Leckie <pleckie@melbourne.sgi.com>
Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svcsock.h |    4 ++
 net/sunrpc/svcsock.c           |   79 +++++++++++++++++++++++++---------------
 2 files changed, 54 insertions(+), 29 deletions(-)

diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index fa92f3f..e4f2936 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -31,6 +31,10 @@ struct svc_sock_ops {
 	 * Prepare any transport-specific RPC header.
 	 */
 	int                     (*sko_prep_reply_hdr)(struct svc_rqst *);
+	/*
+	 * Return 1 if sufficient space to write reply to network.
+	 */
+	int			(*sko_has_wspace)(struct svc_sock *);
 };
 
 /*
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 4ff1a62..a959824 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -205,22 +205,6 @@ svc_release_skb(struct svc_rqst *rqstp)
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
@@ -269,21 +253,13 @@ svc_sock_enqueue(struct svc_sock *svsk)
 	BUG_ON(svsk->sk_pool != NULL);
 	svsk->sk_pool = pool;
 
-	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
-	if (((atomic_read(&svsk->sk_reserved) + serv->sv_max_mesg)*2
-	     > svc_sock_wspace(svsk))
-	    && !test_bit(SK_CLOSE, &svsk->sk_flags)
-	    && !test_bit(SK_CONN, &svsk->sk_flags)) {
-		/* Don't enqueue while not enough space for reply */
-		dprintk("svc: socket %p  no space, %d*2 > %ld, not enqueued\n",
-			svsk->sk_sk, atomic_read(&svsk->sk_reserved)+serv->sv_max_mesg,
-			svc_sock_wspace(svsk));
+	if (!test_bit(SK_CLOSE, &svsk->sk_flags)
+	    && !test_bit(SK_CONN, &svsk->sk_flags)
+	    && !svsk->sk_ops->sko_has_wspace(svsk)) {
 		svsk->sk_pool = NULL;
 		clear_bit(SK_BUSY, &svsk->sk_flags);
 		goto out_unlock;
 	}
-	clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
-
 
 	if (!list_empty(&pool->sp_threads)) {
 		rqstp = list_entry(pool->sp_threads.next,
@@ -882,12 +858,45 @@ svc_udp_sendto(struct svc_rqst *rqstp)
 	return error;
 }
 
+/**
+ * svc_sock_has_write_space - Checks if there is enough space
+ * to send the reply on the socket.
+ * @svsk: the svc_sock to write on
+ * @wspace: the number of bytes available for writing
+ */
+static int svc_sock_has_write_space(struct svc_sock *svsk, int wspace)
+{
+	struct svc_serv	*serv = svsk->sk_server;
+	int required = atomic_read(&svsk->sk_reserved) + serv->sv_max_mesg;
+
+	if (required*2 > wspace) {
+		/* Don't enqueue while not enough space for reply */
+		dprintk("svc: socket %p  no space, %d*2 > %d, not enqueued\n",
+			svsk->sk_sk, required, wspace);
+		return 0;
+	}
+	clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
+	return 1;
+}
+
+static int
+svc_udp_has_wspace(struct svc_sock *svsk)
+{
+	/* 
+	 * Set the SOCK_NOSPACE flag before checking the available
+	 * sock space. 
+	 */
+	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
+	return svc_sock_has_write_space(svsk, sock_wspace(svsk->sk_sk));
+}
+
 static const struct svc_sock_ops svc_udp_ops = {
 	.sko_name = "udp",
 	.sko_recvfrom = svc_udp_recvfrom,
 	.sko_sendto = svc_udp_sendto,
 	.sko_detach = svc_tcpip_detach,
-	.sko_free = svc_tcpip_free
+	.sko_free = svc_tcpip_free,
+	.sko_has_wspace = svc_udp_has_wspace
 };
 
 static void
@@ -1340,13 +1349,25 @@ svc_tcp_prep_reply_hdr(struct svc_rqst *
 	return 0;
 }
 
+static int
+svc_tcp_has_wspace(struct svc_sock *svsk)
+{
+	/* 
+	 * Set the SOCK_NOSPACE flag before checking the available
+	 * sock space. 
+	 */
+	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
+	return svc_sock_has_write_space(svsk, sk_stream_wspace(svsk->sk_sk));
+}
+
 static const struct svc_sock_ops svc_tcp_ops = {
 	.sko_name = "tcp",
 	.sko_recvfrom = svc_tcp_recvfrom,
 	.sko_sendto = svc_tcp_sendto,
 	.sko_detach = svc_tcpip_detach,
 	.sko_free = svc_tcpip_free,
-	.sko_prep_reply_hdr = svc_tcp_prep_reply_hdr
+	.sko_prep_reply_hdr = svc_tcp_prep_reply_hdr,
+	.sko_has_wspace = svc_tcp_has_wspace
 };
 
 static void

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
