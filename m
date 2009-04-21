From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH] SUNRPC: Fix the problem of EADDRNOTAVAIL syslog floods on
 reconnect
Date: Tue, 21 Apr 2009 17:18:20 -0400
Message-ID: <1241176603.5162.0.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	Petr Vandrovec <petr@vandrovec.name>,
	Jean Delvare <khali-PUYAD+kWke1g9hUCZPvPmw@public.gmane.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:55885 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755465AbZEALSJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 May 2009 07:18:09 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

See http://bugzilla.kernel.org/show_bug.cgi?id=13034

If the port gets into a TIME_WAIT state, then we cannot reconnect without
binding to a new port.

Tested-by: Petr Vandrovec <petr@vandrovec.name>
Tested-by: Jean Delvare <khali-PUYAD+kWke1g9hUCZPvPmw@public.gmane.org>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/sunrpc/xprt.h |    1 +
 net/sunrpc/xprt.c           |    6 ++----
 net/sunrpc/xprtsock.c       |   26 +++++++++++++++++++++-----
 3 files changed, 24 insertions(+), 9 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 1758d9f..08afe43 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -261,6 +261,7 @@ void			xprt_conditional_disconnect(struct rpc_xprt *xprt, unsigned int cookie);
 #define XPRT_BINDING		(5)
 #define XPRT_CLOSING		(6)
 #define XPRT_CONNECTION_ABORT	(7)
+#define XPRT_CONNECTION_CLOSE	(8)
 
 static inline void xprt_set_connected(struct rpc_xprt *xprt)
 {
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index a0bfe53..06ca058 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -672,10 +672,8 @@ xprt_init_autodisconnect(unsigned long data)
 	if (test_and_set_bit(XPRT_LOCKED, &xprt->state))
 		goto out_abort;
 	spin_unlock(&xprt->transport_lock);
-	if (xprt_connecting(xprt))
-		xprt_release_write(xprt, NULL);
-	else
-		queue_work(rpciod_workqueue, &xprt->task_cleanup);
+	set_bit(XPRT_CONNECTION_CLOSE, &xprt->state);
+	queue_work(rpciod_workqueue, &xprt->task_cleanup);
 	return;
 out_abort:
 	spin_unlock(&xprt->transport_lock);
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index d40ff50..e185961 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -807,6 +807,9 @@ static void xs_reset_transport(struct sock_xprt *transport)
  *
  * This is used when all requests are complete; ie, no DRC state remains
  * on the server we want to save.
+ *
+ * The caller _must_ be holding XPRT_LOCKED in order to avoid issues with
+ * xs_reset_transport() zeroing the socket from underneath a writer.
  */
 static void xs_close(struct rpc_xprt *xprt)
 {
@@ -824,6 +827,14 @@ static void xs_close(struct rpc_xprt *xprt)
 	xprt_disconnect_done(xprt);
 }
 
+static void xs_tcp_close(struct rpc_xprt *xprt)
+{
+	if (test_and_clear_bit(XPRT_CONNECTION_CLOSE, &xprt->state))
+		xs_close(xprt);
+	else
+		xs_tcp_shutdown(xprt);
+}
+
 /**
  * xs_destroy - prepare to shutdown a transport
  * @xprt: doomed transport
@@ -1772,6 +1783,15 @@ static void xs_tcp_setup_socket(struct rpc_xprt *xprt,
 			xprt, -status, xprt_connected(xprt),
 			sock->sk->sk_state);
 	switch (status) {
+	default:
+		printk("%s: connect returned unhandled error %d\n",
+			__func__, status);
+	case -EADDRNOTAVAIL:
+		/* We're probably in TIME_WAIT. Get rid of existing socket,
+		 * and retry
+		 */
+		set_bit(XPRT_CONNECTION_CLOSE, &xprt->state);
+		xprt_force_disconnect(xprt);
 	case -ECONNREFUSED:
 	case -ECONNRESET:
 	case -ENETUNREACH:
@@ -1782,10 +1802,6 @@ static void xs_tcp_setup_socket(struct rpc_xprt *xprt,
 		xprt_clear_connecting(xprt);
 		return;
 	}
-	/* get rid of existing socket, and retry */
-	xs_tcp_shutdown(xprt);
-	printk("%s: connect returned unhandled error %d\n",
-			__func__, status);
 out_eagain:
 	status = -EAGAIN;
 out:
@@ -1994,7 +2010,7 @@ static struct rpc_xprt_ops xs_tcp_ops = {
 	.buf_free		= rpc_free,
 	.send_request		= xs_tcp_send_request,
 	.set_retrans_timeout	= xprt_set_retrans_timeout_def,
-	.close			= xs_tcp_shutdown,
+	.close			= xs_tcp_close,
 	.destroy		= xs_destroy,
 	.print_stats		= xs_tcp_print_stats,
 };
-- 
1.6.0.4
