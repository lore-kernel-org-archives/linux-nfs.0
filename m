From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 21/38] svc: Change svc_sock_received to svc_xprt_received and export it
Date: Tue, 11 Dec 2007 17:32:41 -0600
Message-ID: <20071211233240.15718.75813.stgit@dell3.ogc.int>
References: <20071211233150.15718.40579.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:35422 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754727AbXLKXcl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Dec 2007 18:32:41 -0500
In-Reply-To: <20071211233150.15718.40579.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


All fields touched by svc_sock_received are now transport independent.
Change it to use svc_xprt directly. This function is called from
transport dependent code, so export it. 

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svc_xprt.h |    2 +-
 net/sunrpc/svcsock.c            |   35 +++++++++++++++++------------------
 2 files changed, 18 insertions(+), 19 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index d5ef902..c416d05 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -62,8 +62,8 @@ int	svc_unreg_xprt_class(struct svc_xprt_class *);
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
index d546709..d8d88c1 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -330,14 +330,13 @@ svc_sock_dequeue(struct svc_pool *pool)
  * Note: XPT_DATA only gets cleared when a read-attempt finds
  * no (or insufficient) data.
  */
-static inline void
-svc_sock_received(struct svc_sock *svsk)
+void svc_xprt_received(struct svc_xprt *xprt)
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
@@ -766,7 +765,7 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 				(serv->sv_nrthreads+3) * serv->sv_max_mesg);
 
 	if ((rqstp->rq_deferred = svc_deferred_dequeue(svsk))) {
-		svc_sock_received(svsk);
+		svc_xprt_received(&svsk->sk_xprt);
 		return svc_deferred_recv(rqstp);
 	}
 
@@ -783,7 +782,7 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 			dprintk("svc: recvfrom returned error %d\n", -err);
 			set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
 		}
-		svc_sock_received(svsk);
+		svc_xprt_received(&svsk->sk_xprt);
 		return -EAGAIN;
 	}
 	rqstp->rq_addrlen = sizeof(rqstp->rq_addr);
@@ -798,7 +797,7 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 	/*
 	 * Maybe more packets - kick another thread ASAP.
 	 */
-	svc_sock_received(svsk);
+	svc_xprt_received(&svsk->sk_xprt);
 
 	len  = skb->len - sizeof(struct udphdr);
 	rqstp->rq_arg.len = len;
@@ -1104,7 +1103,7 @@ static struct svc_xprt *svc_tcp_accept(struct svc_xprt *xprt)
 	}
 	memcpy(&newsvsk->sk_local, sin, slen);
 
-	svc_sock_received(newsvsk);
+	svc_xprt_received(&newsvsk->sk_xprt);
 
 	if (serv->sv_stats)
 		serv->sv_stats->nettcpconn++;
@@ -1134,7 +1133,7 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		test_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags));
 
 	if ((rqstp->rq_deferred = svc_deferred_dequeue(svsk))) {
-		svc_sock_received(svsk);
+		svc_xprt_received(&svsk->sk_xprt);
 		return svc_deferred_recv(rqstp);
 	}
 
@@ -1174,7 +1173,7 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		if (len < want) {
 			dprintk("svc: short recvfrom while reading record length (%d of %lu)\n",
 				len, want);
-			svc_sock_received(svsk);
+			svc_xprt_received(&svsk->sk_xprt);
 			return -EAGAIN; /* record header not complete */
 		}
 
@@ -1210,7 +1209,7 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	if (len < svsk->sk_reclen) {
 		dprintk("svc: incomplete TCP record (%d of %d)\n",
 			len, svsk->sk_reclen);
-		svc_sock_received(svsk);
+		svc_xprt_received(&svsk->sk_xprt);
 		return -EAGAIN;	/* record not complete */
 	}
 	len = svsk->sk_reclen;
@@ -1250,7 +1249,7 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	svsk->sk_reclen = 0;
 	svsk->sk_tcplen = 0;
 
-	svc_sock_received(svsk);
+	svc_xprt_received(&svsk->sk_xprt);
 	if (serv->sv_stats)
 		serv->sv_stats->nettcpcnt++;
 
@@ -1263,7 +1262,7 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
  error:
 	if (len == -EAGAIN) {
 		dprintk("RPC: TCP recvfrom got EAGAIN\n");
-		svc_sock_received(svsk);
+		svc_xprt_received(&svsk->sk_xprt);
 	} else {
 		printk(KERN_NOTICE "%s: recvfrom returned errno %d\n",
 		       svsk->sk_xprt.xpt_server->sv_name, -len);
@@ -1595,7 +1594,7 @@ svc_recv(struct svc_rqst *rqstp, long timeout)
 			__module_get(newxpt->xpt_class->xcl_owner);
 			svc_check_conn_limits(svsk->sk_xprt.xpt_server);
 		}
-		svc_sock_received(svsk);
+		svc_xprt_received(&svsk->sk_xprt);
 	} else {
 		dprintk("svc: server %p, pool %u, socket %p, inuse=%d\n",
 			rqstp, pool->sp_id, svsk,
@@ -1814,7 +1813,7 @@ int svc_addsock(struct svc_serv *serv,
 	else {
 		svsk = svc_setup_socket(serv, so, &err, SVC_SOCK_DEFAULTS);
 		if (svsk) {
-			svc_sock_received(svsk);
+			svc_xprt_received(&svsk->sk_xprt);
 			err = 0;
 		}
 	}
@@ -1870,7 +1869,7 @@ static struct svc_xprt *svc_create_socket(struct svc_serv *serv,
 	}
 
 	if ((svsk = svc_setup_socket(serv, sock, &error, flags)) != NULL) {
-		svc_sock_received(svsk);
+		svc_xprt_received(&svsk->sk_xprt);
 		return (struct svc_xprt *)svsk;
 	}
 
