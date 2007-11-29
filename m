From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 11/38] svc: Add xpo_accept transport function
Date: Thu, 29 Nov 2007 16:40:16 -0600
Message-ID: <20071129224016.14563.67547.stgit@dell3.ogc.int>
References: <20071129223917.14563.77633.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: linux-nfs@vger.kernel.org
To: bfields-ag9A2Eb6PFsgsBAKwltoeQ@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:48901 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933986AbXK2XDi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Nov 2007 18:03:38 -0500
In-Reply-To: <20071129223917.14563.77633.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Previously, the accept logic looked into the socket state to determine
whether to call accept or recv when data-ready was indicated on an endpoint. 
Since some transports don't use sockets, this logic was changed to use a flag 
bit (SK_LISTENER) to identify listening endpoints. A transport function 
(xpo_accept) was added to allow each transport to define its own accept 
processing. A transport's initialization logic is reponsible for setting the 
SK_LISTENER bit. I didn't see any way to do this in transport independent 
logic since the passive side of a UDP connection doesn't listen and
always recv's.

In the svc_recv function, if the SK_LISTENER bit is set, the transport
xpo_accept function is called to handle accept processing.

Note that all functions are defined even if they don't make sense
for a given transport. For example, accept doesn't mean anything for
UDP. The fuction is defined anyway and bug checks if called. The
UDP transport should never set the SK_LISTENER bit.

The code that poaches connections when the connection
limit is hit was moved to a subroutine to make the accept logic path
easier to follow. Since this is in the new connection path, it should 
not be a performance issue.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svc_xprt.h |    1 
 include/linux/sunrpc/svcsock.h  |    1 
 net/sunrpc/svcsock.c            |  127 +++++++++++++++++++++------------------
 3 files changed, 72 insertions(+), 57 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 3adc8f3..1527ff1 100644
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
index 38ecdd1..661162b 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -912,6 +912,12 @@ static int svc_udp_has_wspace(struct svc_xprt *xprt)
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
@@ -920,6 +926,7 @@ static struct svc_xprt_ops svc_udp_ops = {
 	.xpo_free = svc_sock_free,
 	.xpo_prep_reply_hdr = svc_udp_prep_reply_hdr,
 	.xpo_has_wspace = svc_udp_has_wspace,
+	.xpo_accept = svc_udp_accept,
 };
 
 static struct svc_xprt_class svc_udp_class = {
@@ -1044,9 +1051,9 @@ static inline int svc_port_is_privileged(struct sockaddr *sin)
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
@@ -1058,7 +1065,7 @@ svc_tcp_accept(struct svc_sock *svsk)
 
 	dprintk("svc: tcp_accept %p sock %p\n", svsk, sock);
 	if (!sock)
-		return;
+		return NULL;
 
 	clear_bit(SK_CONN, &svsk->sk_flags);
 	err = kernel_accept(sock, &newsock, O_NONBLOCK);
@@ -1069,7 +1076,7 @@ svc_tcp_accept(struct svc_sock *svsk)
 		else if (err != -EAGAIN && net_ratelimit())
 			printk(KERN_WARNING "%s: accept failed (err %d)!\n",
 				   serv->sv_name, -err);
-		return;
+		return NULL;
 	}
 
 	set_bit(SK_CONN, &svsk->sk_flags);
@@ -1115,59 +1122,14 @@ svc_tcp_accept(struct svc_sock *svsk)
 
 	svc_sock_received(newsvsk);
 
-	/* make sure that we don't have too many active connections.
-	 * If we have, something must be dropped.
-	 *
-	 * There's no point in trying to do random drop here for
-	 * DoS prevention. The NFS clients does 1 reconnect in 15
-	 * seconds. An attacker can easily beat that.
-	 *
-	 * The only somewhat efficient mechanism would be if drop
-	 * old connections from the same IP first. But right now
-	 * we don't even record the client IP in svc_sock.
-	 */
-	if (serv->sv_tmpcnt > (serv->sv_nrthreads+3)*20) {
-		struct svc_sock *svsk = NULL;
-		spin_lock_bh(&serv->sv_lock);
-		if (!list_empty(&serv->sv_tempsocks)) {
-			if (net_ratelimit()) {
-				/* Try to help the admin */
-				printk(KERN_NOTICE "%s: too many open TCP "
-					"sockets, consider increasing the "
-					"number of nfsd threads\n",
-						   serv->sv_name);
-				printk(KERN_NOTICE
-				       "%s: last TCP connect from %s\n",
-				       serv->sv_name, __svc_print_addr(sin,
-							buf, sizeof(buf)));
-			}
-			/*
-			 * Always select the oldest socket. It's not fair,
-			 * but so is life
-			 */
-			svsk = list_entry(serv->sv_tempsocks.prev,
-					  struct svc_sock,
-					  sk_list);
-			set_bit(SK_CLOSE, &svsk->sk_flags);
-			atomic_inc(&svsk->sk_inuse);
-		}
-		spin_unlock_bh(&serv->sv_lock);
-
-		if (svsk) {
-			svc_sock_enqueue(svsk);
-			svc_sock_put(svsk);
-		}
-
-	}
-
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
@@ -1192,12 +1154,6 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
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
@@ -1403,6 +1359,7 @@ static struct svc_xprt_ops svc_tcp_ops = {
 	.xpo_free = svc_sock_free,
 	.xpo_prep_reply_hdr = svc_tcp_prep_reply_hdr,
 	.xpo_has_wspace = svc_tcp_has_wspace,
+	.xpo_accept = svc_tcp_accept,
 };
 
 static struct svc_xprt_class svc_tcp_class = {
@@ -1433,6 +1390,7 @@ svc_tcp_init(struct svc_sock *svsk)
 
 	if (sk->sk_state == TCP_LISTEN) {
 		dprintk("setting up TCP socket for listening\n");
+		set_bit(SK_LISTENER, &svsk->sk_flags);
 		sk->sk_data_ready = svc_tcp_listen_data_ready;
 		set_bit(SK_CONN, &svsk->sk_flags);
 	} else {
@@ -1484,6 +1442,55 @@ svc_sock_update_bufs(struct svc_serv *serv)
 	spin_unlock_bh(&serv->sv_lock);
 }
 
+static void
+svc_check_conn_limits(struct svc_serv *serv)
+{
+	char	buf[RPC_MAX_ADDRBUFLEN];
+
+	/* make sure that we don't have too many active connections.
+	 * If we have, something must be dropped.
+	 *
+	 * There's no point in trying to do random drop here for
+	 * DoS prevention. The NFS clients does 1 reconnect in 15
+	 * seconds. An attacker can easily beat that.
+	 *
+	 * The only somewhat efficient mechanism would be if drop
+	 * old connections from the same IP first. But right now
+	 * we don't even record the client IP in svc_sock.
+	 */
+	if (serv->sv_tmpcnt > (serv->sv_nrthreads+3)*20) {
+		struct svc_sock *svsk = NULL;
+		spin_lock_bh(&serv->sv_lock);
+		if (!list_empty(&serv->sv_tempsocks)) {
+			if (net_ratelimit()) {
+				/* Try to help the admin */
+				printk(KERN_NOTICE "%s: too many open TCP "
+					"sockets, consider increasing the "
+					"number of nfsd threads\n",
+						   serv->sv_name);
+				printk(KERN_NOTICE
+				       "%s: last TCP connect from %s\n",
+				       serv->sv_name, buf);
+			}
+			/*
+			 * Always select the oldest socket. It's not fair,
+			 * but so is life
+			 */
+			svsk = list_entry(serv->sv_tempsocks.prev,
+					  struct svc_sock,
+					  sk_list);
+			set_bit(SK_CLOSE, &svsk->sk_flags);
+			atomic_inc(&svsk->sk_inuse);
+		}
+		spin_unlock_bh(&serv->sv_lock);
+
+		if (svsk) {
+			svc_sock_enqueue(svsk);
+			svc_sock_put(svsk);
+		}
+	}
+}
+
 /*
  * Receive the next request on any socket.  This code is carefully
  * organised not to touch any cachelines in the shared svc_serv
@@ -1579,6 +1586,12 @@ svc_recv(struct svc_rqst *rqstp, long timeout)
 	if (test_bit(SK_CLOSE, &svsk->sk_flags)) {
 		dprintk("svc_recv: found SK_CLOSE\n");
 		svc_delete_socket(svsk);
+	} else if (test_bit(SK_LISTENER, &svsk->sk_flags)) {
+		struct svc_xprt *newxpt;
+		newxpt = svsk->sk_xprt.xpt_ops->xpo_accept(&svsk->sk_xprt);
+		if (newxpt)
+			svc_check_conn_limits(svsk->sk_server);
+		svc_sock_received(svsk);
 	} else {
 		dprintk("svc: server %p, pool %u, socket %p, inuse=%d\n",
 			rqstp, pool->sp_id, svsk, atomic_read(&svsk->sk_inuse));
