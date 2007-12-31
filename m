From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 13/40] svc: Move connection limit checking to its own function
Date: Sun, 30 Dec 2007 21:07:40 -0600
Message-ID: <20071231030740.8430.49290.stgit@dell3.ogc.int>
References: <20071231030712.8430.45576.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:41510 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752527AbXLaDHk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 30 Dec 2007 22:07:40 -0500
In-Reply-To: <20071231030712.8430.45576.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Move the code that poaches connections when the connection limit is hit
to a subroutine to make the accept logic path easier to follow. Since this
is in the new connection path, it should not be a performance issue.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 net/sunrpc/svcsock.c |   57 +++++++++++++++++++++++++-------------------------
 1 files changed, 29 insertions(+), 28 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 962dbf4..6e9dc8f 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1105,17 +1105,30 @@ static struct svc_xprt *svc_tcp_accept(struct svc_xprt *xprt)
 
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
+	if (serv->sv_stats)
+		serv->sv_stats->nettcpconn++;
+
+	return &newsvsk->sk_xprt;
+
+failed:
+	sock_release(newsock);
+	return NULL;
+}
+
+/*
+ * Make sure that we don't have too many active connections.  If we
+ * have, something must be dropped.
+ *
+ * There's no point in trying to do random drop here for DoS
+ * prevention. The NFS clients does 1 reconnect in 15 seconds. An
+ * attacker can easily beat that.
+ *
+ * The only somewhat efficient mechanism would be if drop old
+ * connections from the same IP first. But right now we don't even
+ * record the client IP in svc_sock.
+ */
+static void svc_check_conn_limits(struct svc_serv *serv)
+{
 	if (serv->sv_tmpcnt > (serv->sv_nrthreads+3)*20) {
 		struct svc_sock *svsk = NULL;
 		spin_lock_bh(&serv->sv_lock);
@@ -1123,13 +1136,9 @@ static struct svc_xprt *svc_tcp_accept(struct svc_xprt *xprt)
 			if (net_ratelimit()) {
 				/* Try to help the admin */
 				printk(KERN_NOTICE "%s: too many open TCP "
-					"sockets, consider increasing the "
-					"number of nfsd threads\n",
-						   serv->sv_name);
-				printk(KERN_NOTICE
-				       "%s: last TCP connect from %s\n",
-				       serv->sv_name, __svc_print_addr(sin,
-							buf, sizeof(buf)));
+				       "sockets, consider increasing the "
+				       "number of nfsd threads\n",
+				       serv->sv_name);
 			}
 			/*
 			 * Always select the oldest socket. It's not fair,
@@ -1147,17 +1156,7 @@ static struct svc_xprt *svc_tcp_accept(struct svc_xprt *xprt)
 			svc_sock_enqueue(svsk);
 			svc_sock_put(svsk);
 		}
-
 	}
-
-	if (serv->sv_stats)
-		serv->sv_stats->nettcpconn++;
-
-	return &newsvsk->sk_xprt;
-
-failed:
-	sock_release(newsock);
-	return NULL;
 }
 
 /*
@@ -1574,6 +1573,8 @@ svc_recv(struct svc_rqst *rqstp, long timeout)
 	} else if (test_bit(SK_LISTENER, &svsk->sk_flags)) {
 		struct svc_xprt *newxpt;
 		newxpt = svsk->sk_xprt.xpt_ops->xpo_accept(&svsk->sk_xprt);
+		if (newxpt)
+			svc_check_conn_limits(svsk->sk_server);
 		svc_sock_received(svsk);
 	} else {
 		dprintk("svc: server %p, pool %u, socket %p, inuse=%d\n",
