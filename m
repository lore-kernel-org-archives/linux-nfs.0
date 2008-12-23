Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:40377 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751494AbYLWWeh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 17:34:37 -0500
Subject: Re: [PATCH 0/3] NFS regression in 2.6.26?, "task blocked for more
 than 120 seconds"
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Kasparek Tomas <kasparek@fit.vutbr.cz>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20081216120547.GS47559@fit.vutbr.cz>
References: <1227621877.9425.102.camel@zakaz.uk.xensource.com>
	 <1227737539.31008.2.camel@localhost.localdomain>
	 <1228090631.7112.11.camel@heimdal.trondhjem.org>
	 <1228091380.7112.17.camel@heimdal.trondhjem.org>
	 <20081202152256.GI47559@fit.vutbr.cz>
	 <1228232222.3090.5.camel@heimdal.trondhjem.org>
	 <20081202162625.GM47559@fit.vutbr.cz>
	 <1228241407.3090.7.camel@heimdal.trondhjem.org>
	 <20081204102314.GW47559@fit.vutbr.cz>
	 <1229284201.6463.98.camel@heimdal.trondhjem.org>
	 <20081216120547.GS47559@fit.vutbr.cz>
Content-Type: text/plain
Date: Tue, 23 Dec 2008 17:34:07 -0500
Message-Id: <1230071647.17701.27.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2008-12-16 at 13:05 +0100, Kasparek Tomas wrote:
> Hm, not happy to say that but it still does not work after some time. Now
> the problem is opposite there are no connections to the server according to
> netstat on client, just time to time there is
> 
> pcnlp1.fit.vutbr.cz.15234 > kazi.fit.vutbr.cz.nfs: 40 null
> kazi.fit.vutbr.cz.nfs > pcnlp1.fit.vutbr.cz.15234: reply ok 24 null
> 
> (kazi is server). Will try to investigate more details.

OK. Here is one more try. I've tightened up some locking issues with the
previous patch.

Thanks for helping test this!

Cheers
  Trond
-----------------------------------------------------------
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Tue, 23 Dec 2008 16:21:25 -0500
SUNRPC: Add the equivalent of the linger2 timeout to RPC sockets

This avoids us getting stuck in the TCP_FIN_WAIT2 state forever.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 include/linux/sunrpc/xprt.h |    1 +
 net/sunrpc/xprtsock.c       |   63 ++++++++++++++++++++++++++++++-------------
 2 files changed, 45 insertions(+), 19 deletions(-)


diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 11fc71d..1a6ecd7 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -259,6 +259,7 @@ void			xprt_conditional_disconnect(struct rpc_xprt *xprt, unsigned int cookie);
 #define XPRT_BOUND		(4)
 #define XPRT_BINDING		(5)
 #define XPRT_CLOSING		(6)
+#define XPRT_CONNECTION_ABORT	(7)
 
 static inline void xprt_set_connected(struct rpc_xprt *xprt)
 {
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 0a50361..dfb0aeb 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -171,6 +171,7 @@ static ctl_table sunrpc_table[] = {
  */
 #define XS_TCP_INIT_REEST_TO	(3U * HZ)
 #define XS_TCP_MAX_REEST_TO	(5U * 60 * HZ)
+#define XS_TCP_LINGER2_TO	(5U * HZ)
 
 /*
  * TCP idle timeout; client drops the transport socket if it is idle
@@ -792,6 +793,7 @@ static void xs_close(struct rpc_xprt *xprt)
 	sock_release(sock);
 clear_close_wait:
 	smp_mb__before_clear_bit();
+	clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
 	clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
 	clear_bit(XPRT_CLOSING, &xprt->state);
 	smp_mb__after_clear_bit();
@@ -1126,6 +1128,7 @@ out:
  */
 static void xs_tcp_state_change(struct sock *sk)
 {
+	struct sock_xprt *transport;
 	struct rpc_xprt *xprt;
 
 	read_lock(&sk->sk_callback_lock);
@@ -1137,13 +1140,12 @@ static void xs_tcp_state_change(struct sock *sk)
 			sock_flag(sk, SOCK_DEAD),
 			sock_flag(sk, SOCK_ZAPPED));
 
+	transport = container_of(xprt, struct sock_xprt, xprt);
+
 	switch (sk->sk_state) {
 	case TCP_ESTABLISHED:
 		spin_lock_bh(&xprt->transport_lock);
 		if (!xprt_test_and_set_connected(xprt)) {
-			struct sock_xprt *transport = container_of(xprt,
-					struct sock_xprt, xprt);
-
 			/* Reset TCP record info */
 			transport->tcp_offset = 0;
 			transport->tcp_reclen = 0;
@@ -1184,7 +1186,24 @@ static void xs_tcp_state_change(struct sock *sk)
 		clear_bit(XPRT_CONNECTED, &xprt->state);
 		smp_mb__after_clear_bit();
 		break;
+	case TCP_FIN_WAIT2:
+		/* Do the equivalent of linger2 handling for dealing with
+		 * broken servers that don't close the socket in a timely
+		 * fashion
+		 */
+		if (!xprt_test_and_set_connecting(xprt)) {
+			set_bit(XPRT_CONNECTION_ABORT, &xprt->state);
+			queue_delayed_work(rpciod_workqueue,
+					&transport->connect_worker,
+					XS_TCP_LINGER2_TO);
+		}
+		break;
 	case TCP_CLOSE:
+		if (delayed_work_pending(&transport->connect_worker) &&
+			cancel_delayed_work(&transport->connect_worker)) {
+			clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
+			xprt_clear_connecting(xprt);
+		}
 		smp_mb__before_clear_bit();
 		clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
 		clear_bit(XPRT_CLOSING, &xprt->state);
@@ -1549,8 +1568,8 @@ static void xs_udp_connect_worker4(struct work_struct *work)
 	xs_udp_finish_connecting(xprt, sock);
 	status = 0;
 out:
-	xprt_wake_pending_tasks(xprt, status);
 	xprt_clear_connecting(xprt);
+	xprt_wake_pending_tasks(xprt, status);
 }
 
 /**
@@ -1590,8 +1609,8 @@ static void xs_udp_connect_worker6(struct work_struct *work)
 	xs_udp_finish_connecting(xprt, sock);
 	status = 0;
 out:
-	xprt_wake_pending_tasks(xprt, status);
 	xprt_clear_connecting(xprt);
+	xprt_wake_pending_tasks(xprt, status);
 }
 
 /*
@@ -1675,6 +1694,7 @@ static void xs_tcp_connect_worker4(struct work_struct *work)
 		goto out;
 
 	if (!sock) {
+		clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
 		/* start from scratch */
 		if ((err = sock_create_kern(PF_INET, SOCK_STREAM, IPPROTO_TCP, &sock)) < 0) {
 			dprintk("RPC:       can't create TCP transport socket (%d).\n", -err);
@@ -1686,10 +1706,14 @@ static void xs_tcp_connect_worker4(struct work_struct *work)
 			sock_release(sock);
 			goto out;
 		}
-	} else
+	} else {
 		/* "close" the socket, preserving the local port */
 		xs_tcp_reuse_connection(xprt);
 
+		if (test_and_clear_bit(XPRT_CONNECTION_ABORT, &xprt->state))
+			goto out;
+	}
+
 	dprintk("RPC:       worker connecting xprt %p to address: %s\n",
 			xprt, xprt->address_strings[RPC_DISPLAY_ALL]);
 
@@ -1701,19 +1725,17 @@ static void xs_tcp_connect_worker4(struct work_struct *work)
 		switch (status) {
 			case -EINPROGRESS:
 			case -EALREADY:
-				goto out_clear;
-			case -ECONNREFUSED:
-			case -ECONNRESET:
-				/* retry with existing socket, after a delay */
 				break;
 			default:
 				/* get rid of existing socket, and retry */
 				xs_tcp_shutdown(xprt);
+			case -ECONNREFUSED:
+			case -ECONNRESET:
+				/* retry with existing socket, after a delay */
+				xprt_wake_pending_tasks(xprt, status);
 		}
 	}
 out:
-	xprt_wake_pending_tasks(xprt, status);
-out_clear:
 	xprt_clear_connecting(xprt);
 }
 
@@ -1735,6 +1757,7 @@ static void xs_tcp_connect_worker6(struct work_struct *work)
 		goto out;
 
 	if (!sock) {
+		clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
 		/* start from scratch */
 		if ((err = sock_create_kern(PF_INET6, SOCK_STREAM, IPPROTO_TCP, &sock)) < 0) {
 			dprintk("RPC:       can't create TCP transport socket (%d).\n", -err);
@@ -1746,10 +1769,14 @@ static void xs_tcp_connect_worker6(struct work_struct *work)
 			sock_release(sock);
 			goto out;
 		}
-	} else
+	} else {
 		/* "close" the socket, preserving the local port */
 		xs_tcp_reuse_connection(xprt);
 
+		if (test_and_clear_bit(XPRT_CONNECTION_ABORT, &xprt->state))
+			goto out;
+	}
+
 	dprintk("RPC:       worker connecting xprt %p to address: %s\n",
 			xprt, xprt->address_strings[RPC_DISPLAY_ALL]);
 
@@ -1760,19 +1787,17 @@ static void xs_tcp_connect_worker6(struct work_struct *work)
 		switch (status) {
 			case -EINPROGRESS:
 			case -EALREADY:
-				goto out_clear;
-			case -ECONNREFUSED:
-			case -ECONNRESET:
-				/* retry with existing socket, after a delay */
 				break;
 			default:
 				/* get rid of existing socket, and retry */
 				xs_tcp_shutdown(xprt);
+			case -ECONNREFUSED:
+			case -ECONNRESET:
+				/* retry with existing socket, after a delay */
+				xprt_wake_pending_tasks(xprt, status);
 		}
 	}
 out:
-	xprt_wake_pending_tasks(xprt, status);
-out_clear:
 	xprt_clear_connecting(xprt);
 }
 


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
