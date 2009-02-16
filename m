Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:54671 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754954AbZBPNEZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Feb 2009 08:04:25 -0500
Subject: Re: Timeout issue (similar to bugs 11061 and 11154), bisected
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Arto Jantunen <viiru@debian.org>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <87ab8m7i22.fsf@viiru.iki.fi>
References: <87ab8m7i22.fsf@viiru.iki.fi>
Content-Type: multipart/mixed; boundary="=-Xbihqy7PiwItDS4ljDQ9"
Date: Mon, 16 Feb 2009 08:04:19 -0500
Message-Id: <1234789459.7708.47.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--=-Xbihqy7PiwItDS4ljDQ9
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Mon, 2009-02-16 at 13:11 +0200, Arto Jantunen wrote:
> (I'm not subscribed, so please CC me on any replies)
> 
> I seem to have hit a NFS bug while upgrading a machine from Debian
> Etch to Debian Lenny. I have a NFS server running FreeBSD 7.0 RC1 and
> a bunch of clients running Linux. The ones running kernel 2.6.18 work
> perfectly, as do the ones running 2.6.24. The one I upgraded to 2.6.26
> fails. After 5-15 minutes of working normally the mount dies and I get
> the usual "nfs: server <server> not responding, still trying" in
> dmesg. The only way I have found to get the mount back is umount -f &&
> mount, waiting does not bring it back.
> 
> I have tested quite a bunch of different kernel versions, and starting
> from 25 and ending at the git tree last week they all fail in the same
> way. Bisecting tracks the problem to commit
> e06799f958bf7f9f8fae15f0c6f519953fb0257c
> 
> I originally thought that it was the same as bug 11154, but the
> patches attached to that bug do not fix this issue.
> 
> Any thoughts, patches, ideas?

That looks like the known problem with the NFS server failing to close
connections in a timely manner. There is a fix for this in

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git&a=commitdiff&h=69b6ba3712b796a66595cfaf0a5ab4dfe1cf964a

There is also a client side patch that increases the robustness of the
client when it hits a buggy server, and that causes it to do the
equivalent of a linger2 timeout. That patch is as of yet not merged into
mainline, however I've attached it below together with a followup patch
that makes the timeout configurable...

Cheers
  Trond

--=-Xbihqy7PiwItDS4ljDQ9
Content-Disposition: attachment; filename="linux-2.6.28-100-add_tcp_linger.dif"
Content-Type: application/x-dif; name="linux-2.6.28-100-add_tcp_linger.dif"
Content-Transfer-Encoding: 7bit

From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Fri, 13 Feb 2009 07:55:13 -0500
SUNRPC: Add the equivalent of the linger and linger2 timeouts to RPC sockets

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
 net/sunrpc/xprtsock.c       |  136 ++++++++++++++++++++++++++++++-------------
 2 files changed, 96 insertions(+), 41 deletions(-)


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
index 5cbb404..1429987 100644
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
@@ -789,6 +791,7 @@ static void xs_close(struct rpc_xprt *xprt)
 	sock_release(sock);
 clear_close_wait:
 	smp_mb__before_clear_bit();
+	clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
 	clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
 	clear_bit(XPRT_CLOSING, &xprt->state);
 	smp_mb__after_clear_bit();
@@ -1116,6 +1119,45 @@ out:
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
+	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
+
+	if (!xprt_test_and_set_connecting(xprt)) {
+		set_bit(XPRT_CONNECTION_ABORT, &xprt->state);
+		queue_delayed_work(rpciod_workqueue,
+				&transport->connect_worker,
+				timeout);
+	}
+}
+
+static void xs_tcp_cancel_linger_timeout(struct rpc_xprt *xprt)
+{
+	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
+
+	if (delayed_work_pending(&transport->connect_worker) &&
+		cancel_delayed_work(&transport->connect_worker)) {
+		clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
+		xprt_clear_connecting(xprt);
+	}
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
@@ -1161,6 +1203,7 @@ static void xs_tcp_state_change(struct sock *sk)
 		clear_bit(XPRT_CONNECTED, &xprt->state);
 		clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
 		smp_mb__after_clear_bit();
+		xs_tcp_schedule_linger_timeout(xprt, XS_TCP_LINGER_TO);
 		break;
 	case TCP_CLOSE_WAIT:
 		/* The server initiated a shutdown of the socket */
@@ -1177,17 +1220,14 @@ static void xs_tcp_state_change(struct sock *sk)
 			xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
 		break;
 	case TCP_LAST_ACK:
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
@@ -1546,8 +1586,8 @@ static void xs_udp_connect_worker4(struct work_struct *work)
 	xs_udp_finish_connecting(xprt, sock);
 	status = 0;
 out:
-	xprt_wake_pending_tasks(xprt, status);
 	xprt_clear_connecting(xprt);
+	xprt_wake_pending_tasks(xprt, status);
 }
 
 /**
@@ -1587,8 +1627,8 @@ static void xs_udp_connect_worker6(struct work_struct *work)
 	xs_udp_finish_connecting(xprt, sock);
 	status = 0;
 out:
-	xprt_wake_pending_tasks(xprt, status);
 	xprt_clear_connecting(xprt);
+	xprt_wake_pending_tasks(xprt, status);
 }
 
 /*
@@ -1610,7 +1650,9 @@ static void xs_tcp_reuse_connection(struct rpc_xprt *xprt)
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
@@ -1672,6 +1714,7 @@ static void xs_tcp_connect_worker4(struct work_struct *work)
 		goto out;
 
 	if (!sock) {
+		clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
 		/* start from scratch */
 		if ((err = sock_create_kern(PF_INET, SOCK_STREAM, IPPROTO_TCP, &sock)) < 0) {
 			dprintk("RPC:       can't create TCP transport socket (%d).\n", -err);
@@ -1683,10 +1726,16 @@ static void xs_tcp_connect_worker4(struct work_struct *work)
 			sock_release(sock);
 			goto out;
 		}
-	} else
+	} else {
 		/* "close" the socket, preserving the local port */
 		xs_tcp_reuse_connection(xprt);
 
+		if (test_and_clear_bit(XPRT_CONNECTION_ABORT, &xprt->state)) {
+			status = 0;
+			goto out;
+		}
+	}
+
 	dprintk("RPC:       worker connecting xprt %p to address: %s\n",
 			xprt, xprt->address_strings[RPC_DISPLAY_ALL]);
 
@@ -1694,24 +1743,23 @@ static void xs_tcp_connect_worker4(struct work_struct *work)
 	dprintk("RPC:       %p connect status %d connected %d sock state %d\n",
 			xprt, -status, xprt_connected(xprt),
 			sock->sk->sk_state);
-	if (status < 0) {
-		switch (status) {
-			case -EINPROGRESS:
-			case -EALREADY:
-				goto out_clear;
-			case -ECONNREFUSED:
-			case -ECONNRESET:
-				/* retry with existing socket, after a delay */
-				break;
-			default:
-				/* get rid of existing socket, and retry */
-				xs_tcp_shutdown(xprt);
-		}
+	switch (status) {
+		case 0:
+		case -EINPROGRESS:
+		case -EALREADY:
+			xprt_clear_connecting(xprt);
+			return;
+		case -ECONNREFUSED:
+		case -ECONNRESET:
+			/* retry with existing socket, after a delay */
+			break;
+		default:
+			/* get rid of existing socket, and retry */
+			xs_tcp_shutdown(xprt);
 	}
 out:
-	xprt_wake_pending_tasks(xprt, status);
-out_clear:
 	xprt_clear_connecting(xprt);
+	xprt_wake_pending_tasks(xprt, status);
 }
 
 /**
@@ -1732,6 +1780,7 @@ static void xs_tcp_connect_worker6(struct work_struct *work)
 		goto out;
 
 	if (!sock) {
+		clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
 		/* start from scratch */
 		if ((err = sock_create_kern(PF_INET6, SOCK_STREAM, IPPROTO_TCP, &sock)) < 0) {
 			dprintk("RPC:       can't create TCP transport socket (%d).\n", -err);
@@ -1743,34 +1792,39 @@ static void xs_tcp_connect_worker6(struct work_struct *work)
 			sock_release(sock);
 			goto out;
 		}
-	} else
+	} else {
 		/* "close" the socket, preserving the local port */
 		xs_tcp_reuse_connection(xprt);
 
+		if (test_and_clear_bit(XPRT_CONNECTION_ABORT, &xprt->state)) {
+			status = 0;
+			goto out;
+		}
+	}
+
 	dprintk("RPC:       worker connecting xprt %p to address: %s\n",
 			xprt, xprt->address_strings[RPC_DISPLAY_ALL]);
 
 	status = xs_tcp_finish_connecting(xprt, sock);
 	dprintk("RPC:       %p connect status %d connected %d sock state %d\n",
 			xprt, -status, xprt_connected(xprt), sock->sk->sk_state);
-	if (status < 0) {
-		switch (status) {
-			case -EINPROGRESS:
-			case -EALREADY:
-				goto out_clear;
-			case -ECONNREFUSED:
-			case -ECONNRESET:
-				/* retry with existing socket, after a delay */
-				break;
-			default:
-				/* get rid of existing socket, and retry */
-				xs_tcp_shutdown(xprt);
-		}
+	switch (status) {
+		case 0:
+		case -EINPROGRESS:
+		case -EALREADY:
+			xprt_clear_connecting(xprt);
+			return;
+		case -ECONNREFUSED:
+		case -ECONNRESET:
+			/* retry with existing socket, after a delay */
+			break;
+		default:
+			/* get rid of existing socket, and retry */
+			xs_tcp_shutdown(xprt);
 	}
 out:
-	xprt_wake_pending_tasks(xprt, status);
-out_clear:
 	xprt_clear_connecting(xprt);
+	xprt_wake_pending_tasks(xprt, status);
 }
 
 /**

--=-Xbihqy7PiwItDS4ljDQ9
Content-Disposition: attachment; filename="linux-2.6.28-101-add_tcp_linger_sysctl.dif"
Content-Type: application/x-dif; name="linux-2.6.28-101-add_tcp_linger_sysctl.dif"
Content-Transfer-Encoding: 7bit

From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Fri, 13 Feb 2009 07:55:14 -0500
SUNRPC: Add a sysctl to control the duration of the socket linger timeout

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/xprtsock.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)


diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 1429987..2f76392 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -50,6 +50,7 @@ unsigned int xprt_min_resvport = RPC_DEF_MIN_RESVPORT;
 unsigned int xprt_max_resvport = RPC_DEF_MAX_RESVPORT;
 
 #define XS_TCP_LINGER_TO	(15U * HZ)
+static unsigned int xs_tcp_fin_timeout __read_mostly = XS_TCP_LINGER_TO;
 
 /*
  * We can register our own files under /proc/sys/sunrpc by
@@ -119,6 +120,14 @@ static ctl_table xs_tunables_table[] = {
 		.extra2		= &xprt_max_resvport_limit
 	},
 	{
+		.procname	= "tcp_fin_timeout",
+		.data		= &xs_tcp_fin_timeout,
+		.maxlen		= sizeof(xs_tcp_fin_timeout),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_jiffies,
+		.strategy	= sysctl_jiffies
+	},
+	{
 		.ctl_name = 0,
 	},
 };
@@ -1203,7 +1212,7 @@ static void xs_tcp_state_change(struct sock *sk)
 		clear_bit(XPRT_CONNECTED, &xprt->state);
 		clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
 		smp_mb__after_clear_bit();
-		xs_tcp_schedule_linger_timeout(xprt, XS_TCP_LINGER_TO);
+		xs_tcp_schedule_linger_timeout(xprt, xs_tcp_fin_timeout);
 		break;
 	case TCP_CLOSE_WAIT:
 		/* The server initiated a shutdown of the socket */
@@ -1220,7 +1229,7 @@ static void xs_tcp_state_change(struct sock *sk)
 			xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
 		break;
 	case TCP_LAST_ACK:
-		xs_tcp_schedule_linger_timeout(xprt, XS_TCP_LINGER_TO);
+		xs_tcp_schedule_linger_timeout(xprt, xs_tcp_fin_timeout);
 		smp_mb__before_clear_bit();
 		clear_bit(XPRT_CONNECTED, &xprt->state);
 		smp_mb__after_clear_bit();

--=-Xbihqy7PiwItDS4ljDQ9--
