From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 11/40] svc: Add xpo_accept transport function
Date: Sun, 30 Dec 2007 21:07:36 -0600
Message-ID: <20071231030736.8430.21269.stgit@dell3.ogc.int>
References: <20071231030712.8430.45576.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:41503 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752500AbXLaDHg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 30 Dec 2007 22:07:36 -0500
In-Reply-To: <20071231030712.8430.45576.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Previously, the accept logic looked into the socket state to determine
whether to call accept or recv when data-ready was indicated on an endpoint. 
Since some transports don't use sockets, this logic now uses a flag 
bit (SK_LISTENER) to identify listening endpoints. A transport function 
(xpo_accept) allows each transport to define its own accept processing.
A transport's initialization logic is reponsible for setting the 
SK_LISTENER bit. I didn't see any way to do this in transport independent 
logic since the passive side of a UDP connection doesn't listen and
always recv's.

In the svc_recv function, if the SK_LISTENER bit is set, the transport
xpo_accept function is called to handle accept processing.

Note that all functions are defined even if they don't make sense
for a given transport. For example, accept doesn't mean anything for
UDP. The function is defined anyway and bug checks if called. The
UDP transport should never set the SK_LISTENER bit.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svc_xprt.h |    1 +
 include/linux/sunrpc/svcsock.h  |    1 +
 net/sunrpc/svcsock.c            |   31 +++++++++++++++++++------------
 3 files changed, 21 insertions(+), 12 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 85df97a..31a44f4 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -10,6 +10,7 @@
 #include <linux/sunrpc/svc.h>
 
 struct svc_xprt_ops {
+	struct svc_xprt	*(*xpo_accept)(struct svc_xprt *);
 	int		(*xpo_has_wspace)(struct svc_xprt *);
 	int		(*xpo_recvfrom)(struct svc_rqst *);
 	void		(*xpo_prep_reply_hdr)(struct svc_rqst *);
diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index 08e78d0..9882ce0 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -36,6 +36,7 @@ struct svc_sock {
 #define	SK_DEFERRED	8			/* request on sk_deferred */
 #define	SK_OLD		9			/* used for temp socket aging mark+sweep */
 #define	SK_DETACHED	10			/* detached from tempsocks list */
+#define SK_LISTENER	11			/* listening endpoint */
 
 	atomic_t    	    	sk_reserved;	/* space on outq that is reserved */
 
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 603db98..41d1f81 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -896,6 +896,12 @@ static int svc_udp_has_wspace(struct svc_xprt *xprt)
 	return 1;
 }
 
+static struct svc_xprt *svc_udp_accept(struct svc_xprt *xprt)
+{
+	BUG();
+	return NULL;
+}
+
 static struct svc_xprt_ops svc_udp_ops = {
 	.xpo_recvfrom = svc_udp_recvfrom,
 	.xpo_sendto = svc_udp_sendto,
@@ -904,6 +910,7 @@ static struct svc_xprt_ops svc_udp_ops = {
 	.xpo_free = svc_sock_free,
 	.xpo_prep_reply_hdr = svc_udp_prep_reply_hdr,
 	.xpo_has_wspace = svc_udp_has_wspace,
+	.xpo_accept = svc_udp_accept,
 };
 
 static struct svc_xprt_class svc_udp_class = {
@@ -1028,9 +1035,9 @@ static inline int svc_port_is_privileged(struct sockaddr *sin)
 /*
  * Accept a TCP connection
  */
-static void
-svc_tcp_accept(struct svc_sock *svsk)
+static struct svc_xprt *svc_tcp_accept(struct svc_xprt *xprt)
 {
+	struct svc_sock *svsk = container_of(xprt, struct svc_sock, sk_xprt);
 	struct sockaddr_storage addr;
 	struct sockaddr	*sin = (struct sockaddr *) &addr;
 	struct svc_serv	*serv = svsk->sk_server;
@@ -1042,7 +1049,7 @@ svc_tcp_accept(struct svc_sock *svsk)
 
 	dprintk("svc: tcp_accept %p sock %p\n", svsk, sock);
 	if (!sock)
-		return;
+		return NULL;
 
 	clear_bit(SK_CONN, &svsk->sk_flags);
 	err = kernel_accept(sock, &newsock, O_NONBLOCK);
@@ -1053,7 +1060,7 @@ svc_tcp_accept(struct svc_sock *svsk)
 		else if (err != -EAGAIN && net_ratelimit())
 			printk(KERN_WARNING "%s: accept failed (err %d)!\n",
 				   serv->sv_name, -err);
-		return;
+		return NULL;
 	}
 
 	set_bit(SK_CONN, &svsk->sk_flags);
@@ -1147,11 +1154,11 @@ svc_tcp_accept(struct svc_sock *svsk)
 	if (serv->sv_stats)
 		serv->sv_stats->nettcpconn++;
 
-	return;
+	return &newsvsk->sk_xprt;
 
 failed:
 	sock_release(newsock);
-	return;
+	return NULL;
 }
 
 /*
@@ -1176,12 +1183,6 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		return svc_deferred_recv(rqstp);
 	}
 
-	if (svsk->sk_sk->sk_state == TCP_LISTEN) {
-		svc_tcp_accept(svsk);
-		svc_sock_received(svsk);
-		return 0;
-	}
-
 	if (test_and_clear_bit(SK_CHNGBUF, &svsk->sk_flags))
 		/* sndbuf needs to have room for one request
 		 * per thread, otherwise we can stall even when the
@@ -1393,6 +1394,7 @@ static struct svc_xprt_ops svc_tcp_ops = {
 	.xpo_free = svc_sock_free,
 	.xpo_prep_reply_hdr = svc_tcp_prep_reply_hdr,
 	.xpo_has_wspace = svc_tcp_has_wspace,
+	.xpo_accept = svc_tcp_accept,
 };
 
 static struct svc_xprt_class svc_tcp_class = {
@@ -1423,6 +1425,7 @@ svc_tcp_init(struct svc_sock *svsk)
 
 	if (sk->sk_state == TCP_LISTEN) {
 		dprintk("setting up TCP socket for listening\n");
+		set_bit(SK_LISTENER, &svsk->sk_flags);
 		sk->sk_data_ready = svc_tcp_listen_data_ready;
 		set_bit(SK_CONN, &svsk->sk_flags);
 	} else {
@@ -1569,6 +1572,10 @@ svc_recv(struct svc_rqst *rqstp, long timeout)
 	if (test_bit(SK_CLOSE, &svsk->sk_flags)) {
 		dprintk("svc_recv: found SK_CLOSE\n");
 		svc_delete_socket(svsk);
+	} else if (test_bit(SK_LISTENER, &svsk->sk_flags)) {
+		struct svc_xprt *newxpt;
+		newxpt = svsk->sk_xprt.xpt_ops->xpo_accept(&svsk->sk_xprt);
+		svc_sock_received(svsk);
 	} else {
 		dprintk("svc: server %p, pool %u, socket %p, inuse=%d\n",
 			rqstp, pool->sp_id, svsk, atomic_read(&svsk->sk_inuse));
