From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] SUNRPC: Avoid spurious wake-up during UDP connect processing
Date: Thu, 13 Nov 2008 16:14:47 -0500
Message-ID: <20081113211309.7976.24058.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:45396 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751192AbYKMVO4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Nov 2008 16:14:56 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To clear out old state, the UDP connect workers unconditionally invoke
xs_close() before proceeding with a new connect.  Nowadays this causes
a spurious wake-up of the task waiting for the connect to complete.

This is a little racey, but usually harmless.  The waiting task
immediately retries the connect via a call_bind/call_connect sequence,
which usually finds the transport already in the connected state
because the connect worker has finished in the background.

To avoid a spurious wake-up, factor the xs_close() logic that resets
the underlying socket into a helper, and have the UDP connect workers
call that helper instead of xs_close().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtsock.c |   44 ++++++++++++++++++++++++++------------------
 1 files changed, 26 insertions(+), 18 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 0a50361..883dc2f 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -760,23 +760,13 @@ static void xs_restore_old_callbacks(struct sock_xprt *transport, struct sock *s
 	sk->sk_error_report = transport->old_error_report;
 }
 
-/**
- * xs_close - close a socket
- * @xprt: transport
- *
- * This is used when all requests are complete; ie, no DRC state remains
- * on the server we want to save.
- */
-static void xs_close(struct rpc_xprt *xprt)
+static void xs_reset_transport(struct sock_xprt *transport)
 {
-	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
 	struct socket *sock = transport->sock;
 	struct sock *sk = transport->inet;
 
-	if (!sk)
-		goto clear_close_wait;
-
-	dprintk("RPC:       xs_close xprt %p\n", xprt);
+	if (sk == NULL)
+		return;
 
 	write_lock_bh(&sk->sk_callback_lock);
 	transport->inet = NULL;
@@ -790,7 +780,23 @@ static void xs_close(struct rpc_xprt *xprt)
 	sk->sk_no_check = 0;
 
 	sock_release(sock);
-clear_close_wait:
+}
+
+/**
+ * xs_close - close a socket
+ * @xprt: transport
+ *
+ * This is used when all requests are complete; ie, no DRC state remains
+ * on the server we want to save.
+ */
+static void xs_close(struct rpc_xprt *xprt)
+{
+	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
+
+	dprintk("RPC:       xs_close xprt %p\n", xprt);
+
+	xs_reset_transport(transport);
+
 	smp_mb__before_clear_bit();
 	clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
 	clear_bit(XPRT_CLOSING, &xprt->state);
@@ -1530,9 +1536,10 @@ static void xs_udp_connect_worker4(struct work_struct *work)
 		goto out;
 
 	/* Start by resetting any existing state */
-	xs_close(xprt);
+	xs_reset_transport(transport);
 
-	if ((err = sock_create_kern(PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock)) < 0) {
+	err = sock_create_kern(PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock);
+	if (err < 0) {
 		dprintk("RPC:       can't create UDP transport socket (%d).\n", -err);
 		goto out;
 	}
@@ -1571,9 +1578,10 @@ static void xs_udp_connect_worker6(struct work_struct *work)
 		goto out;
 
 	/* Start by resetting any existing state */
-	xs_close(xprt);
+	xs_reset_transport(transport);
 
-	if ((err = sock_create_kern(PF_INET6, SOCK_DGRAM, IPPROTO_UDP, &sock)) < 0) {
+	err = sock_create_kern(PF_INET6, SOCK_DGRAM, IPPROTO_UDP, &sock);
+	if (err < 0) {
 		dprintk("RPC:       can't create UDP transport socket (%d).\n", -err);
 		goto out;
 	}

