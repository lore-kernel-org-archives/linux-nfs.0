From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 15/20] SUNRPC: Refactor a part of socket connect logic
	into a	helper function
Date: Mon, 06 Aug 2007 11:57:38 -0400
Message-ID: <20070806155738.31233.34930.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1II4xk-00012e-LU
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 08:57:44 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1II4xl-0006DF-Mf
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 08:57:48 -0700
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

Finishing a socket connect is the same for IPv4 and IPv6, so split it out
into a helper.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
---

 net/sunrpc/xprtsock.c |  131 +++++++++++++++++++++++++++----------------------
 1 files changed, 72 insertions(+), 59 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index df14360..3bd80e1 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1333,6 +1333,35 @@ static inline void xs_reclassify_socket(struct socket *sock)
 }
 #endif
 
+static void xs_udp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
+{
+	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
+
+	if (!transport->inet) {
+		struct sock *sk = sock->sk;
+
+		write_lock_bh(&sk->sk_callback_lock);
+
+		sk->sk_user_data = xprt;
+		transport->old_data_ready = sk->sk_data_ready;
+		transport->old_state_change = sk->sk_state_change;
+		transport->old_write_space = sk->sk_write_space;
+		sk->sk_data_ready = xs_udp_data_ready;
+		sk->sk_write_space = xs_udp_write_space;
+		sk->sk_no_check = UDP_CSUM_NORCV;
+		sk->sk_allocation = GFP_ATOMIC;
+
+		xprt_set_connected(xprt);
+
+		/* Reset to new socket */
+		transport->sock = sock;
+		transport->inet = sk;
+
+		write_unlock_bh(&sk->sk_callback_lock);
+	}
+	xs_udp_do_set_buffer_size(xprt);
+}
+
 /**
  * xs_udp_connect_worker - set up a UDP socket
  * @work: RPC transport to connect
@@ -1367,29 +1396,7 @@ static void xs_udp_connect_worker(struct work_struct *work)
 	dprintk("RPC:       worker connecting xprt %p to address: %s\n",
 			xprt, xprt->address_strings[RPC_DISPLAY_ALL]);
 
-	if (!transport->inet) {
-		struct sock *sk = sock->sk;
-
-		write_lock_bh(&sk->sk_callback_lock);
-
-		sk->sk_user_data = xprt;
-		transport->old_data_ready = sk->sk_data_ready;
-		transport->old_state_change = sk->sk_state_change;
-		transport->old_write_space = sk->sk_write_space;
-		sk->sk_data_ready = xs_udp_data_ready;
-		sk->sk_write_space = xs_udp_write_space;
-		sk->sk_no_check = UDP_CSUM_NORCV;
-		sk->sk_allocation = GFP_ATOMIC;
-
-		xprt_set_connected(xprt);
-
-		/* Reset to new socket */
-		transport->sock = sock;
-		transport->inet = sk;
-
-		write_unlock_bh(&sk->sk_callback_lock);
-	}
-	xs_udp_do_set_buffer_size(xprt);
+	xs_udp_finish_connecting(xprt, sock);
 	status = 0;
 out:
 	xprt_wake_pending_tasks(xprt, status);
@@ -1420,42 +1427,9 @@ static void xs_tcp_reuse_connection(struct rpc_xprt *xprt)
 				result);
 }
 
-/**
- * xs_tcp_connect_worker - connect a TCP socket to a remote endpoint
- * @work: RPC transport to connect
- *
- * Invoked by a work queue tasklet.
- */
-static void xs_tcp_connect_worker(struct work_struct *work)
+static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 {
-	struct sock_xprt *transport =
-		container_of(work, struct sock_xprt, connect_worker.work);
-	struct rpc_xprt *xprt = &transport->xprt;
-	struct socket *sock = transport->sock;
-	int err, status = -EIO;
-
-	if (xprt->shutdown || !xprt_bound(xprt))
-		goto out;
-
-	if (!sock) {
-		/* start from scratch */
-		if ((err = sock_create_kern(PF_INET, SOCK_STREAM, IPPROTO_TCP, &sock)) < 0) {
-			dprintk("RPC:       can't create TCP transport "
-					"socket (%d).\n", -err);
-			goto out;
-		}
-		xs_reclassify_socket(sock);
-
-		if (xs_bind4(transport, sock)) {
-			sock_release(sock);
-			goto out;
-		}
-	} else
-		/* "close" the socket, preserving the local port */
-		xs_tcp_reuse_connection(xprt);
-
-	dprintk("RPC:       worker connecting xprt %p to address: %s\n",
-			xprt, xprt->address_strings[RPC_DISPLAY_ALL]);
+	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
 
 	if (!transport->inet) {
 		struct sock *sk = sock->sk;
@@ -1489,8 +1463,47 @@ static void xs_tcp_connect_worker(struct work_struct *work)
 	/* Tell the socket layer to start connecting... */
 	xprt->stat.connect_count++;
 	xprt->stat.connect_start = jiffies;
-	status = kernel_connect(sock, (struct sockaddr *) &xprt->addr,
+	return kernel_connect(sock, (struct sockaddr *) &xprt->addr,
 			xprt->addrlen, O_NONBLOCK);
+}
+
+/**
+ * xs_tcp_connect_worker - connect a TCP socket to a remote endpoint
+ * @work: RPC transport to connect
+ *
+ * Invoked by a work queue tasklet.
+ */
+static void xs_tcp_connect_worker(struct work_struct *work)
+{
+	struct sock_xprt *transport =
+		container_of(work, struct sock_xprt, connect_worker.work);
+	struct rpc_xprt *xprt = &transport->xprt;
+	struct socket *sock = transport->sock;
+	int err, status = -EIO;
+
+	if (xprt->shutdown || !xprt_bound(xprt))
+		goto out;
+
+	if (!sock) {
+		/* start from scratch */
+		if ((err = sock_create_kern(PF_INET, SOCK_STREAM, IPPROTO_TCP, &sock)) < 0) {
+			dprintk("RPC:       can't create TCP transport socket (%d).\n", -err);
+			goto out;
+		}
+		xs_reclassify_socket(sock);
+
+		if (xs_bind4(transport, sock) < 0) {
+			sock_release(sock);
+			goto out;
+		}
+	} else
+		/* "close" the socket, preserving the local port */
+		xs_tcp_reuse_connection(xprt);
+
+	dprintk("RPC:       worker connecting xprt %p to address: %s\n",
+			xprt, xprt->address_strings[RPC_DISPLAY_ALL]);
+
+	status = xs_tcp_finish_connecting(xprt, sock);
 	dprintk("RPC:       %p connect status %d connected %d sock state %d\n",
 			xprt, -status, xprt_connected(xprt),
 			sock->sk->sk_state);


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
