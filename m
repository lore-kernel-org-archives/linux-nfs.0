From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 28/30] SUNRPC: Add the equivalent of the linger and linger2
 timeouts to RPC sockets
Date: Wed, 11 Mar 2009 14:41:10 -0400
Message-ID: <20090311184110.5578.14491.stgit@heimdal.trondhjem.org>
References: <20090311184105.5578.22131.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6556 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754004AbZCKSps (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2009 14:45:48 -0400
Received: from sacrsexc1-prd.hq.netapp.com (sacrsexc1-prd.hq.netapp.com [10.99.115.27])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n2BIj6iN022202
	for <linux-nfs@vger.kernel.org>; Wed, 11 Mar 2009 11:45:46 -0700 (PDT)
In-Reply-To: <20090311184105.5578.22131.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This fixes a regression against FreeBSD servers as reported by Tomas
Kasparek. Apparently when using RPC over a TCP socket, the FreeBSD servers
don't ever react to the client closing the socket, and so commit
e06799f958bf7f9f8fae15f0c6f519953fb0257c (SUNRPC: Use shutdown() instead of
close() when disconnecting a TCP socket) causes the setup to hang forever
whenever the client attempts to close and then reconnect.

We break the deadlock by adding a 'linger2' style timeout to the socket,
after which, the client will abort the connection using a TCP 'RST'.

The default timeout is set to 15 seconds. A subsequent patch will put it
under user control by means of a systctl.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 include/linux/sunrpc/xprt.h |    1 
 net/sunrpc/xprtsock.c       |   98 ++++++++++++++++++++++++++++++++++++-------
 2 files changed, 82 insertions(+), 17 deletions(-)


diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 2b0d960..1758d9f 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -260,6 +260,7 @@ void			xprt_conditional_disconnect(struct rpc_xprt *xprt, unsigned int cookie);
 #define XPRT_BOUND		(4)
 #define XPRT_BINDING		(5)
 #define XPRT_CLOSING		(6)
+#define XPRT_CONNECTION_ABORT	(7)
 
 static inline void xprt_set_connected(struct rpc_xprt *xprt)
 {
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 2e07067..b51f58b 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -49,6 +49,8 @@ unsigned int xprt_tcp_slot_table_entries = RPC_DEF_SLOT_TABLE;
 unsigned int xprt_min_resvport = RPC_DEF_MIN_RESVPORT;
 unsigned int xprt_max_resvport = RPC_DEF_MAX_RESVPORT;
 
+#define XS_TCP_LINGER_TO	(15U * HZ)
+
 /*
  * We can register our own files under /proc/sys/sunrpc by
  * calling register_sysctl_table() again.  The files in that
@@ -806,6 +808,7 @@ static void xs_close(struct rpc_xprt *xprt)
 	xs_reset_transport(transport);
 
 	smp_mb__before_clear_bit();
+	clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
 	clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
 	clear_bit(XPRT_CLOSING, &xprt->state);
 	smp_mb__after_clear_bit();
@@ -1133,6 +1136,47 @@ out:
 	read_unlock(&sk->sk_callback_lock);
 }
 
+/*
+ * Do the equivalent of linger/linger2 handling for dealing with
+ * broken servers that don't close the socket in a timely
+ * fashion
+ */
+static void xs_tcp_schedule_linger_timeout(struct rpc_xprt *xprt,
+		unsigned long timeout)
+{
+	struct sock_xprt *transport;
+
+	if (xprt_test_and_set_connecting(xprt))
+		return;
+	set_bit(XPRT_CONNECTION_ABORT, &xprt->state);
+	transport = container_of(xprt, struct sock_xprt, xprt);
+	queue_delayed_work(rpciod_workqueue, &transport->connect_worker,
+			   timeout);
+}
+
+static void xs_tcp_cancel_linger_timeout(struct rpc_xprt *xprt)
+{
+	struct sock_xprt *transport;
+
+	transport = container_of(xprt, struct sock_xprt, xprt);
+
+	if (!test_bit(XPRT_CONNECTION_ABORT, &xprt->state) ||
+	    !cancel_delayed_work(&transport->connect_worker))
+		return;
+	clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
+	xprt_clear_connecting(xprt);
+}
+
+static void xs_sock_mark_closed(struct rpc_xprt *xprt)
+{
+	smp_mb__before_clear_bit();
+	clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
+	clear_bit(XPRT_CLOSING, &xprt->state);
+	smp_mb__after_clear_bit();
+	/* Mark transport as closed and wake up all pending tasks */
+	xprt_disconnect_done(xprt);
+}
+
 /**
  * xs_tcp_state_change - callback to handle TCP socket state changes
  * @sk: socket whose state has changed
@@ -1178,6 +1222,7 @@ static void xs_tcp_state_change(struct sock *sk)
 		clear_bit(XPRT_CONNECTED, &xprt->state);
 		clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
 		smp_mb__after_clear_bit();
+		xs_tcp_schedule_linger_timeout(xprt, XS_TCP_LINGER_TO);
 		break;
 	case TCP_CLOSE_WAIT:
 		/* The server initiated a shutdown of the socket */
@@ -1194,17 +1239,14 @@ static void xs_tcp_state_change(struct sock *sk)
 		break;
 	case TCP_LAST_ACK:
 		set_bit(XPRT_CLOSING, &xprt->state);
+		xs_tcp_schedule_linger_timeout(xprt, XS_TCP_LINGER_TO);
 		smp_mb__before_clear_bit();
 		clear_bit(XPRT_CONNECTED, &xprt->state);
 		smp_mb__after_clear_bit();
 		break;
 	case TCP_CLOSE:
-		smp_mb__before_clear_bit();
-		clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
-		clear_bit(XPRT_CLOSING, &xprt->state);
-		smp_mb__after_clear_bit();
-		/* Mark transport as closed and wake up all pending tasks */
-		xprt_disconnect_done(xprt);
+		xs_tcp_cancel_linger_timeout(xprt);
+		xs_sock_mark_closed(xprt);
 	}
  out:
 	read_unlock(&sk->sk_callback_lock);
@@ -1562,8 +1604,8 @@ static void xs_udp_connect_worker4(struct work_struct *work)
 	xs_udp_finish_connecting(xprt, sock);
 	status = 0;
 out:
-	xprt_wake_pending_tasks(xprt, status);
 	xprt_clear_connecting(xprt);
+	xprt_wake_pending_tasks(xprt, status);
 }
 
 /**
@@ -1604,8 +1646,8 @@ static void xs_udp_connect_worker6(struct work_struct *work)
 	xs_udp_finish_connecting(xprt, sock);
 	status = 0;
 out:
-	xprt_wake_pending_tasks(xprt, status);
 	xprt_clear_connecting(xprt);
+	xprt_wake_pending_tasks(xprt, status);
 }
 
 /*
@@ -1626,7 +1668,9 @@ static void xs_abort_connection(struct rpc_xprt *xprt, struct sock_xprt *transpo
 	memset(&any, 0, sizeof(any));
 	any.sa_family = AF_UNSPEC;
 	result = kernel_connect(transport->sock, &any, sizeof(any), 0);
-	if (result)
+	if (!result)
+		xs_sock_mark_closed(xprt);
+	else
 		dprintk("RPC:       AF_UNSPEC connect return code %d\n",
 				result);
 }
@@ -1702,6 +1746,7 @@ static void xs_tcp_connect_worker4(struct work_struct *work)
 		goto out;
 
 	if (!sock) {
+		clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
 		/* start from scratch */
 		if ((err = sock_create_kern(PF_INET, SOCK_STREAM, IPPROTO_TCP, &sock)) < 0) {
 			dprintk("RPC:       can't create TCP transport socket (%d).\n", -err);
@@ -1713,10 +1758,18 @@ static void xs_tcp_connect_worker4(struct work_struct *work)
 			sock_release(sock);
 			goto out;
 		}
-	} else
+	} else {
+		int abort_and_exit;
+
+		abort_and_exit = test_and_clear_bit(XPRT_CONNECTION_ABORT,
+				&xprt->state);
 		/* "close" the socket, preserving the local port */
 		xs_tcp_reuse_connection(xprt, transport);
 
+		if (abort_and_exit)
+			goto out_eagain;
+	}
+
 	dprintk("RPC:       worker connecting xprt %p to address: %s\n",
 			xprt, xprt->address_strings[RPC_DISPLAY_ALL]);
 
@@ -1732,17 +1785,18 @@ static void xs_tcp_connect_worker4(struct work_struct *work)
 	case 0:
 	case -EINPROGRESS:
 	case -EALREADY:
-		goto out_clear;
+		xprt_clear_connecting(xprt);
+		return;
 	}
 	/* get rid of existing socket, and retry */
 	xs_tcp_shutdown(xprt);
 	printk("%s: connect returned unhandled error %d\n",
 			__func__, status);
+out_eagain:
 	status = -EAGAIN;
 out:
-	xprt_wake_pending_tasks(xprt, status);
-out_clear:
 	xprt_clear_connecting(xprt);
+	xprt_wake_pending_tasks(xprt, status);
 }
 
 /**
@@ -1763,6 +1817,7 @@ static void xs_tcp_connect_worker6(struct work_struct *work)
 		goto out;
 
 	if (!sock) {
+		clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
 		/* start from scratch */
 		if ((err = sock_create_kern(PF_INET6, SOCK_STREAM, IPPROTO_TCP, &sock)) < 0) {
 			dprintk("RPC:       can't create TCP transport socket (%d).\n", -err);
@@ -1774,10 +1829,18 @@ static void xs_tcp_connect_worker6(struct work_struct *work)
 			sock_release(sock);
 			goto out;
 		}
-	} else
+	} else {
+		int abort_and_exit;
+
+		abort_and_exit = test_and_clear_bit(XPRT_CONNECTION_ABORT,
+				&xprt->state);
 		/* "close" the socket, preserving the local port */
 		xs_tcp_reuse_connection(xprt, transport);
 
+		if (abort_and_exit)
+			goto out_eagain;
+	}
+
 	dprintk("RPC:       worker connecting xprt %p to address: %s\n",
 			xprt, xprt->address_strings[RPC_DISPLAY_ALL]);
 
@@ -1792,17 +1855,18 @@ static void xs_tcp_connect_worker6(struct work_struct *work)
 	case 0:
 	case -EINPROGRESS:
 	case -EALREADY:
-		goto out_clear;
+		xprt_clear_connecting(xprt);
+		return;
 	}
 	/* get rid of existing socket, and retry */
 	xs_tcp_shutdown(xprt);
 	printk("%s: connect returned unhandled error %d\n",
 			__func__, status);
+out_eagain:
 	status = -EAGAIN;
 out:
-	xprt_wake_pending_tasks(xprt, status);
-out_clear:
 	xprt_clear_connecting(xprt);
+	xprt_wake_pending_tasks(xprt, status);
 }
 
 /**

