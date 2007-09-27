From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 11/33] svc: Add xpo_accept transport function
Date: Thu, 27 Sep 2007 00:01:57 -0500
Message-ID: <20070927050157.12677.92320.stgit@dell3.ogc.int>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IalVe-0005bo-Mm
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:01:58 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IalVj-0005G2-1V
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:02:03 -0700
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
 net/sunrpc/svcsock.c            |  130 ++++++++++++++++++++++-----------------
 3 files changed, 75 insertions(+), 57 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 47bedfa..4c1a650 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -10,6 +10,7 @@ #define SUNRPC_SVC_XPRT_H
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
@@ -36,6 +36,7 @@ #define	SK_CHNGBUF	7			/* need to change
 #define	SK_DEFERRED	8			/* request on sk_deferred */
 #define	SK_OLD		9			/* used for temp socket aging mark+sweep */
 #define	SK_DETACHED	10			/* detached from tempsocks list */
+#define SK_LISTENER	11			/* listening endpoint */
 
 	atomic_t    	    	sk_reserved;	/* space on outq that is reserved */
 
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 93c5fb6..19f7bbc 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -914,6 +914,13 @@ svc_udp_has_wspace(struct svc_xprt *xprt
 	return 1;
 }
 
+static struct svc_xprt *
+svc_udp_accept(struct svc_xprt *xprt)
+{
+	BUG();
+	return NULL;
+}
+
 static struct svc_xprt_ops svc_udp_ops = {
 	.xpo_recvfrom = svc_udp_recvfrom,
 	.xpo_sendto = svc_udp_sendto,
@@ -922,6 +929,7 @@ static struct svc_xprt_ops svc_udp_ops =
 	.xpo_free = svc_sock_free,
 	.xpo_prep_reply_hdr = svc_udp_prep_reply_hdr,
 	.xpo_has_wspace = svc_udp_has_wspace,
+	.xpo_accept = svc_udp_accept,
 };
 
 static struct svc_xprt_class svc_udp_class = {
@@ -1046,9 +1054,10 @@ static inline int svc_port_is_privileged
 /*
  * Accept a TCP connection
  */
-static void
-svc_tcp_accept(struct svc_sock *svsk)
+static struct svc_xprt *
+svc_tcp_accept(struct svc_xprt *xprt)
 {
+	struct svc_sock *svsk = (struct svc_sock *)xprt;
 	struct sockaddr_storage addr;
 	struct sockaddr	*sin = (struct sockaddr *) &addr;
 	struct svc_serv	*serv = svsk->sk_server;
@@ -1060,7 +1069,7 @@ svc_tcp_accept(struct svc_sock *svsk)
 
 	dprintk("svc: tcp_accept %p sock %p\n", svsk, sock);
 	if (!sock)
-		return;
+		return NULL;
 
 	clear_bit(SK_CONN, &svsk->sk_flags);
 	err = kernel_accept(sock, &newsock, O_NONBLOCK);
@@ -1071,7 +1080,7 @@ svc_tcp_accept(struct svc_sock *svsk)
 		else if (err != -EAGAIN && net_ratelimit())
 			printk(KERN_WARNING "%s: accept failed (err %d)!\n",
 				   serv->sv_name, -err);
-		return;
+		return NULL;
 	}
 
 	set_bit(SK_CONN, &svsk->sk_flags);
@@ -1117,59 +1126,14 @@ svc_tcp_accept(struct svc_sock *svsk)
 
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
@@ -1194,12 +1158,6 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
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
@@ -1407,6 +1365,7 @@ static struct svc_xprt_ops svc_tcp_ops =
 	.xpo_free = svc_sock_free,
 	.xpo_prep_reply_hdr = svc_tcp_prep_reply_hdr,
 	.xpo_has_wspace = svc_tcp_has_wspace,
+	.xpo_accept = svc_tcp_accept,
 };
 
 static struct svc_xprt_class svc_tcp_class = {
@@ -1488,6 +1447,55 @@ svc_sock_update_bufs(struct svc_serv *se
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
@@ -1583,6 +1591,12 @@ svc_recv(struct svc_rqst *rqstp, long ti
 	if (test_bit(SK_CLOSE, &svsk->sk_flags)) {
 		dprintk("svc_recv: found SK_CLOSE\n");
 		svc_delete_socket(svsk);
+	} else if (test_bit(SK_LISTENER, &svsk->sk_flags)) {
+		struct svc_xprt *newxpt;
+		newxpt = svsk->sk_xprt.xpt_ops.xpo_accept(&svsk->sk_xprt);
+		if (newxpt)
+			svc_check_conn_limits(svsk->sk_server);
+		svc_sock_received(svsk);
 	} else {
 		dprintk("svc: server %p, pool %u, socket %p, inuse=%d\n",
 			rqstp, pool->sp_id, svsk, atomic_read(&svsk->sk_inuse));
@@ -1859,6 +1873,8 @@ static int svc_create_socket(struct svc_
 	}
 
 	if ((svsk = svc_setup_socket(serv, sock, &error, flags)) != NULL) {
+		if (protocol == IPPROTO_TCP) 
+			set_bit(SK_LISTENER, &svsk->sk_flags);
 		svc_sock_received(svsk);
 		return ntohs(inet_sk(svsk->sk_sk)->sport);
 	}

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
