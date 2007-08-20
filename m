From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,
	PATCH 01/20] svc: Add svc_xprt transport switch structure
Date: Mon, 20 Aug 2007 11:23:23 -0500
Message-ID: <20070820162323.15224.10640.stgit@dell3.ogc.int>
References: <20070820162000.15224.65524.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1INA2J-0006N1-Im
	for nfs@lists.sourceforge.net; Mon, 20 Aug 2007 09:23:27 -0700
Received: from smtp.opengridcomputing.com ([71.42.183.126])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1INA2M-0005H9-EW
	for nfs@lists.sourceforge.net; Mon, 20 Aug 2007 09:23:31 -0700
Received: from dell3.ogc.int (localhost [127.0.0.1])
	by smtp.opengridcomputing.com (Postfix) with ESMTP id 8B3107C79B
	for <nfs@lists.sourceforge.net>; Mon, 20 Aug 2007 11:23:23 -0500 (CDT)
In-Reply-To: <20070820162000.15224.65524.stgit@dell3.ogc.int>
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


Start moving to a transport switch for knfsd.  Add a svc_xprt
switch and move the sk_sendto and sk_recvfrom function
pointers into it.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
Signed-off-by: Peter Leckie <pleckie@melbourne.sgi.com>
Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svcsock.h |    9 +++++++--
 net/sunrpc/svcsock.c           |   22 ++++++++++++++++------
 2 files changed, 23 insertions(+), 8 deletions(-)

diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index e21dd93..4792ed6 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -11,6 +11,12 @@ #define SUNRPC_SVCSOCK_H
 
 #include <linux/sunrpc/svc.h>
 
+struct svc_xprt {
+	const char		*xpt_name;
+	int			(*xpt_recvfrom)(struct svc_rqst *rqstp);
+	int			(*xpt_sendto)(struct svc_rqst *rqstp);
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
+	const struct svc_xprt  *sk_xprt;
 
 	/* We keep the old state_change and data_ready CB's here */
 	void			(*sk_ostate)(struct sock *);
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 5baf48d..789d94a 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -885,6 +885,12 @@ svc_udp_sendto(struct svc_rqst *rqstp)
 	return error;
 }
 
+static const struct svc_xprt svc_udp_xprt = {
+	.xpt_name = "udp",
+	.xpt_recvfrom = svc_udp_recvfrom,
+	.xpt_sendto = svc_udp_sendto,
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
+	svsk->sk_xprt = &svc_udp_xprt;
 
 	/* initialise setting must have enough space to
 	 * receive and respond to one request.
@@ -1322,14 +1327,19 @@ svc_tcp_sendto(struct svc_rqst *rqstp)
 	return sent;
 }
 
+static const struct svc_xprt svc_tcp_xprt = {
+	.xpt_name = "tcp",
+	.xpt_recvfrom = svc_tcp_recvfrom,
+	.xpt_sendto = svc_tcp_sendto,
+};
+
 static void
 svc_tcp_init(struct svc_sock *svsk)
 {
 	struct sock	*sk = svsk->sk_sk;
 	struct tcp_sock *tp = tcp_sk(sk);
 
-	svsk->sk_recvfrom = svc_tcp_recvfrom;
-	svsk->sk_sendto = svc_tcp_sendto;
+	svsk->sk_xprt = &svc_tcp_xprt;
 
 	if (sk->sk_state == TCP_LISTEN) {
 		dprintk("setting up TCP socket for listening\n");
@@ -1477,7 +1487,7 @@ svc_recv(struct svc_rqst *rqstp, long ti
 
 	dprintk("svc: server %p, pool %u, socket %p, inuse=%d\n",
 		 rqstp, pool->sp_id, svsk, atomic_read(&svsk->sk_inuse));
-	len = svsk->sk_recvfrom(rqstp);
+	len = svsk->sk_xprt->xpt_recvfrom(rqstp);
 	dprintk("svc: got len=%d\n", len);
 
 	/* No data, incomplete (TCP) read, or accept() */
@@ -1537,7 +1547,7 @@ svc_send(struct svc_rqst *rqstp)
 	if (test_bit(SK_DEAD, &svsk->sk_flags))
 		len = -ENOTCONN;
 	else
-		len = svsk->sk_sendto(rqstp);
+		len = svsk->sk_xprt->xpt_sendto(rqstp);
 	mutex_unlock(&svsk->sk_mutex);
 	svc_sock_release(rqstp);
 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
