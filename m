From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 01/20] svc: Add svc_sock_ops
Date: Tue, 10 Jul 2007 00:34:22 -0500
Message-ID: <20070710053422.28979.37799.stgit@dell3.ogc.int>
References: <20070710052711.28979.70843.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I88Mi-00073t-RJ
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 22:34:24 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I88Mm-0003RL-8L
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 22:34:28 -0700
Received: from dell3.ogc.int (localhost [127.0.0.1])
	by smtp.opengridcomputing.com (Postfix) with ESMTP id 5A9EE7C79C
	for <nfs@lists.sourceforge.net>; Tue, 10 Jul 2007 00:34:22 -0500 (CDT)
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


Start moving to a transport switch for knfsd.  Add a svc_sock_ops
operations vector and move the sk_sendto and sk_recvfrom function
pointers into it.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
Signed-off-by: Peter Leckie <pleckie@melbourne.sgi.com>
---

 include/linux/sunrpc/svcsock.h |    9 +++++++--
 net/sunrpc/svcsock.c           |   22 ++++++++++++++++------
 2 files changed, 23 insertions(+), 8 deletions(-)

diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index e21dd93..3c926b9 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -11,6 +11,12 @@ #define SUNRPC_SVCSOCK_H
 
 #include <linux/sunrpc/svc.h>
 
+struct svc_sock_ops {
+	const char		*sko_name;
+	int			(*sko_recvfrom)(struct svc_rqst *rqstp);
+	int			(*sko_sendto)(struct svc_rqst *rqstp);
+};
+
 /*
  * RPC server socket.
  */
@@ -43,8 +49,7 @@ #define	SK_DETACHED	10			/* detached fro
 						 * be revisted */
 	struct mutex		sk_mutex;	/* to serialize sending data */
 
-	int			(*sk_recvfrom)(struct svc_rqst *rqstp);
-	int			(*sk_sendto)(struct svc_rqst *rqstp);
+	const struct svc_sock_ops *sk_ops;
 
 	/* We keep the old state_change and data_ready CB's here */
 	void			(*sk_ostate)(struct sock *);
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 5baf48d..ce325f2 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -885,6 +885,12 @@ svc_udp_sendto(struct svc_rqst *rqstp)
 	return error;
 }
 
+static const struct svc_sock_ops svc_udp_ops = {
+	.sko_name = "udp",
+	.sko_recvfrom = svc_udp_recvfrom,
+	.sko_sendto = svc_udp_sendto
+};
+
 static void
 svc_udp_init(struct svc_sock *svsk)
 {
@@ -893,8 +899,7 @@ svc_udp_init(struct svc_sock *svsk)
 
 	svsk->sk_sk->sk_data_ready = svc_udp_data_ready;
 	svsk->sk_sk->sk_write_space = svc_write_space;
-	svsk->sk_recvfrom = svc_udp_recvfrom;
-	svsk->sk_sendto = svc_udp_sendto;
+	svsk->sk_ops = &svc_udp_ops;
 
 	/* initialise setting must have enough space to
 	 * receive and respond to one request.
@@ -1322,14 +1327,19 @@ svc_tcp_sendto(struct svc_rqst *rqstp)
 	return sent;
 }
 
+static const struct svc_sock_ops svc_tcp_ops = {
+	.sko_name = "tcp",
+	.sko_recvfrom = svc_tcp_recvfrom,
+	.sko_sendto = svc_tcp_sendto
+};
+
 static void
 svc_tcp_init(struct svc_sock *svsk)
 {
 	struct sock	*sk = svsk->sk_sk;
 	struct tcp_sock *tp = tcp_sk(sk);
 
-	svsk->sk_recvfrom = svc_tcp_recvfrom;
-	svsk->sk_sendto = svc_tcp_sendto;
+	svsk->sk_ops = &svc_tcp_ops;
 
 	if (sk->sk_state == TCP_LISTEN) {
 		dprintk("setting up TCP socket for listening\n");
@@ -1477,7 +1487,7 @@ svc_recv(struct svc_rqst *rqstp, long ti
 
 	dprintk("svc: server %p, pool %u, socket %p, inuse=%d\n",
 		 rqstp, pool->sp_id, svsk, atomic_read(&svsk->sk_inuse));
-	len = svsk->sk_recvfrom(rqstp);
+	len = svsk->sk_ops->sko_recvfrom(rqstp);
 	dprintk("svc: got len=%d\n", len);
 
 	/* No data, incomplete (TCP) read, or accept() */
@@ -1537,7 +1547,7 @@ svc_send(struct svc_rqst *rqstp)
 	if (test_bit(SK_DEAD, &svsk->sk_flags))
 		len = -ENOTCONN;
 	else
-		len = svsk->sk_sendto(rqstp);
+		len = svsk->sk_ops->sko_sendto(rqstp);
 	mutex_unlock(&svsk->sk_mutex);
 	svc_sock_release(rqstp);
 

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
