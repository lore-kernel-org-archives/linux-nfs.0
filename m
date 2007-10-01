From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,
	PATCH 21/35] svc: Change svc_sock_received to svc_xprt_received and
	export it
Date: Mon, 01 Oct 2007 14:28:17 -0500
Message-ID: <20071001192817.3250.89116.stgit@dell3.ogc.int>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IcQwE-0005co-R6
	for nfs@lists.sourceforge.net; Mon, 01 Oct 2007 12:28:19 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IcQwI-0007Rx-Hf
	for nfs@lists.sourceforge.net; Mon, 01 Oct 2007 12:28:24 -0700
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


All fields touched by svc_sock_received are now transport independent.
Change it to use svc_xprt directly. This function is called from
transport dependent code, so export it. 

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svc_xprt.h |    2 +-
 net/sunrpc/svcsock.c            |   37 ++++++++++++++++++-------------------
 2 files changed, 19 insertions(+), 20 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index c16a2c6..103aa36 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -63,8 +63,8 @@ int	svc_unreg_xprt_class(struct svc_xprt
 void	svc_xprt_init(struct svc_xprt_class *, struct svc_xprt *,
 		      struct svc_serv *);
 int	svc_create_xprt(struct svc_serv *, char *, unsigned short, int);
+void	svc_xprt_received(struct svc_xprt *);
 void	svc_xprt_put(struct svc_xprt *xprt);
-
 static inline void svc_xprt_get(struct svc_xprt *xprt)
 {
 	kref_get(&xprt->xpt_ref);
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index eee64ce..b8d0d55 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -345,14 +345,14 @@ svc_sock_dequeue(struct svc_pool *pool)
  * Note: XPT_DATA only gets cleared when a read-attempt finds
  * no (or insufficient) data.
  */
-static inline void
-svc_sock_received(struct svc_sock *svsk)
+void
+svc_xprt_received(struct svc_xprt *xprt)
 {
-	svsk->sk_xprt.xpt_pool = NULL;
-	clear_bit(XPT_BUSY, &svsk->sk_xprt.xpt_flags);
-	svc_xprt_enqueue(&svsk->sk_xprt);
+	xprt->xpt_pool = NULL;
+	clear_bit(XPT_BUSY, &xprt->xpt_flags);
+	svc_xprt_enqueue(xprt);
 }
-
+EXPORT_SYMBOL_GPL(svc_xprt_received);
 
 /**
  * svc_reserve - change the space reserved for the reply to a request.
@@ -781,7 +781,7 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 				(serv->sv_nrthreads+3) * serv->sv_max_mesg);
 
 	if ((rqstp->rq_deferred = svc_deferred_dequeue(svsk))) {
-		svc_sock_received(svsk);
+		svc_xprt_received(&svsk->sk_xprt);
 		return svc_deferred_recv(rqstp);
 	}
 
@@ -798,7 +798,7 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 			dprintk("svc: recvfrom returned error %d\n", -err);
 			set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
 		}
-		svc_sock_received(svsk);
+		svc_xprt_received(&svsk->sk_xprt);
 		return -EAGAIN;
 	}
 	rqstp->rq_addrlen = sizeof(rqstp->rq_addr);
@@ -813,7 +813,7 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 	/*
 	 * Maybe more packets - kick another thread ASAP.
 	 */
-	svc_sock_received(svsk);
+	svc_xprt_received(&svsk->sk_xprt);
 
 	len  = skb->len - sizeof(struct udphdr);
 	rqstp->rq_arg.len = len;
@@ -1126,8 +1126,6 @@ svc_tcp_accept(struct svc_xprt *xprt)
 	}
 	memcpy(&newsvsk->sk_local, sin, slen);
 
-	svc_sock_received(newsvsk);
-
 	if (serv->sv_stats)
 		serv->sv_stats->nettcpconn++;
 
@@ -1156,7 +1154,7 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		test_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags));
 
 	if ((rqstp->rq_deferred = svc_deferred_dequeue(svsk))) {
-		svc_sock_received(svsk);
+		svc_xprt_received(&svsk->sk_xprt);
 		return svc_deferred_recv(rqstp);
 	}
 
@@ -1196,7 +1194,7 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		if (len < want) {
 			dprintk("svc: short recvfrom while reading record length (%d of %lu)\n",
 				len, want);
-			svc_sock_received(svsk);
+			svc_xprt_received(&svsk->sk_xprt);
 			return -EAGAIN; /* record header not complete */
 		}
 
@@ -1232,7 +1230,7 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	if (len < svsk->sk_reclen) {
 		dprintk("svc: incomplete TCP record (%d of %d)\n",
 			len, svsk->sk_reclen);
-		svc_sock_received(svsk);
+		svc_xprt_received(&svsk->sk_xprt);
 		return -EAGAIN;	/* record not complete */
 	}
 	len = svsk->sk_reclen;
@@ -1272,7 +1270,7 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	svsk->sk_reclen = 0;
 	svsk->sk_tcplen = 0;
 
-	svc_sock_received(svsk);
+	svc_xprt_received(&svsk->sk_xprt);
 	if (serv->sv_stats)
 		serv->sv_stats->nettcpcnt++;
 
@@ -1285,7 +1283,7 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
  error:
 	if (len == -EAGAIN) {
 		dprintk("RPC: TCP recvfrom got EAGAIN\n");
-		svc_sock_received(svsk);
+		svc_xprt_received(&svsk->sk_xprt);
 	} else {
 		printk(KERN_NOTICE "%s: recvfrom returned errno %d\n",
 		       svsk->sk_xprt.xpt_server->sv_name, -len);
@@ -1606,6 +1604,7 @@ svc_recv(struct svc_rqst *rqstp, long ti
 		struct svc_xprt *newxpt;
 		newxpt = svsk->sk_xprt.xpt_ops.xpo_accept(&svsk->sk_xprt);
 		if (newxpt) {
+			svc_xprt_received(newxpt);
 			/*
 			 * We know this module_get will succeed because the
 			 * listener holds a reference too
@@ -1613,7 +1612,7 @@ svc_recv(struct svc_rqst *rqstp, long ti
 			__module_get(newxpt->xpt_class->xcl_owner);
 			svc_check_conn_limits(svsk->sk_xprt.xpt_server);
 		}
-		svc_sock_received(svsk);
+		svc_xprt_received(&svsk->sk_xprt);
 	} else {
 		dprintk("svc: server %p, pool %u, socket %p, inuse=%d\n",
 			rqstp, pool->sp_id, svsk,
@@ -1834,7 +1833,7 @@ int svc_addsock(struct svc_serv *serv,
 	else {
 		svsk = svc_setup_socket(serv, so, &err, SVC_SOCK_DEFAULTS);
 		if (svsk) {
-			svc_sock_received(svsk);
+			svc_xprt_received(&svsk->sk_xprt);
 			err = 0;
 		}
 	}
@@ -1891,7 +1890,7 @@ svc_create_socket(struct svc_serv *serv,
 	if ((svsk = svc_setup_socket(serv, sock, &error, flags)) != NULL) {
 		if (protocol == IPPROTO_TCP)
 			set_bit(XPT_LISTENER, &svsk->sk_xprt.xpt_flags);
-		svc_sock_received(svsk);
+		svc_xprt_received(&svsk->sk_xprt);
 		return (struct svc_xprt *)svsk;
 	}
 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
