From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 059/100] svc: Move connection limit checking to its own function
Date: Fri, 25 Jan 2008 18:16:39 -0500
Message-ID: <1201303040-7779-59-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-5-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-6-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-7-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-8-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-9-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-10-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-11-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-12-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-13-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-14-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-15-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-16-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-17-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-18-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-19-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-20-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-21-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-22-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-23-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-24-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-25-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-26-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-27-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-28-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-29-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-30-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-31-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-32-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-33-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-34-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-35-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-36-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-37-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-38-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-39-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-40-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-41-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-42-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-43-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-44-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-45-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-46-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-47-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-48-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-49-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-50-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-51-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-52-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-53-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-54-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-55-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-56-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-57-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-58-git-send-email-bfields@citi.umich.edu>
Cc: Tom Tucker <tom@opengridcomputing.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47453 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932121AbYAYXRu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:17:50 -0500
In-Reply-To: <1201303040-7779-58-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tom Tucker <tom@opengridcomputing.com>

Move the code that poaches connections when the connection limit is hit
to a subroutine to make the accept logic path easier to follow. Since this
is in the new connection path, it should not be a performance issue.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
Acked-by: Neil Brown <neilb@suse.de>
Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Greg Banks <gnb@sgi.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 net/sunrpc/svcsock.c |   57 +++++++++++++++++++++++++------------------------
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
-- 
1.5.4.rc2.60.gb2e62

