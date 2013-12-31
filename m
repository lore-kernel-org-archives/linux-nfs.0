Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f182.google.com ([209.85.213.182]:39266 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756509Ab3LaTkE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Dec 2013 14:40:04 -0500
Received: by mail-ig0-f182.google.com with SMTP id c10so30490018igq.3
        for <linux-nfs@vger.kernel.org>; Tue, 31 Dec 2013 11:40:04 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Kinglong Mee <kinglongmee@gmail.com>, Chuck Lever <chuck.lever@oracle.com>,
        Bruce Fields <bfields@fieldses.com>,
        Gareth Williams <gareth@garethwilliams.me.uk>
Subject: [PATCH 3/4] SUNRPC: Report connection error values to rpc_tasks on the pending queue
Date: Tue, 31 Dec 2013 14:39:40 -0500
Message-Id: <1388518781-33571-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1388518781-33571-2-git-send-email-trond.myklebust@primarydata.com>
References: <CAB6yy379-A8fgLpQo+ppx5V93P9pXcabvmBJNTZ5hXxeJMuxBg@mail.gmail.com>
 <1388518781-33571-1-git-send-email-trond.myklebust@primarydata.com>
 <1388518781-33571-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently we only report EAGAIN, which is not descriptive enough for
softconn tasks.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprtsock.c | 41 ++++++++++++++++++++++++++++++++++++-----
 1 file changed, 36 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index dd9d295813cf..ab006b7b7ab8 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -257,6 +257,7 @@ struct sock_xprt {
 	void			(*old_data_ready)(struct sock *, int);
 	void			(*old_state_change)(struct sock *);
 	void			(*old_write_space)(struct sock *);
+	void			(*old_error_report)(struct sock *);
 };
 
 /*
@@ -274,6 +275,11 @@ struct sock_xprt {
  */
 #define TCP_RPC_REPLY		(1UL << 6)
 
+static inline struct rpc_xprt *xprt_from_sock(struct sock *sk)
+{
+	return (struct rpc_xprt *) sk->sk_user_data;
+}
+
 static inline struct sockaddr *xs_addr(struct rpc_xprt *xprt)
 {
 	return (struct sockaddr *) &xprt->addr;
@@ -799,6 +805,7 @@ static void xs_save_old_callbacks(struct sock_xprt *transport, struct sock *sk)
 	transport->old_data_ready = sk->sk_data_ready;
 	transport->old_state_change = sk->sk_state_change;
 	transport->old_write_space = sk->sk_write_space;
+	transport->old_error_report = sk->sk_error_report;
 }
 
 static void xs_restore_old_callbacks(struct sock_xprt *transport, struct sock *sk)
@@ -806,6 +813,33 @@ static void xs_restore_old_callbacks(struct sock_xprt *transport, struct sock *s
 	sk->sk_data_ready = transport->old_data_ready;
 	sk->sk_state_change = transport->old_state_change;
 	sk->sk_write_space = transport->old_write_space;
+	sk->sk_error_report = transport->old_error_report;
+}
+
+/**
+ * xs_error_report - callback to handle TCP socket state errors
+ * @sk: socket
+ *
+ * Note: we don't call sock_error() since there may be a rpc_task
+ * using the socket, and so we don't want to clear sk->sk_err.
+ */
+static void xs_error_report(struct sock *sk)
+{
+	struct rpc_xprt *xprt;
+	int err;
+
+	read_lock_bh(&sk->sk_callback_lock);
+	if (!(xprt = xprt_from_sock(sk)))
+		goto out;
+
+	err = -sk->sk_err;
+	if (err == 0)
+		goto out;
+	dprintk("RPC:       xs_error_report client %p, error=%d...\n",
+			xprt, -err);
+	xprt_wake_pending_tasks(xprt, err);
+ out:
+	read_unlock_bh(&sk->sk_callback_lock);
 }
 
 static void xs_reset_transport(struct sock_xprt *transport)
@@ -885,11 +919,6 @@ static void xs_destroy(struct rpc_xprt *xprt)
 	module_put(THIS_MODULE);
 }
 
-static inline struct rpc_xprt *xprt_from_sock(struct sock *sk)
-{
-	return (struct rpc_xprt *) sk->sk_user_data;
-}
-
 static int xs_local_copy_to_xdr(struct xdr_buf *xdr, struct sk_buff *skb)
 {
 	struct xdr_skb_reader desc = {
@@ -1869,6 +1898,7 @@ static int xs_local_finish_connecting(struct rpc_xprt *xprt,
 		sk->sk_user_data = xprt;
 		sk->sk_data_ready = xs_local_data_ready;
 		sk->sk_write_space = xs_udp_write_space;
+		sk->sk_error_report = xs_error_report;
 		sk->sk_allocation = GFP_ATOMIC;
 
 		xprt_clear_connected(xprt);
@@ -2146,6 +2176,7 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 		sk->sk_data_ready = xs_tcp_data_ready;
 		sk->sk_state_change = xs_tcp_state_change;
 		sk->sk_write_space = xs_tcp_write_space;
+		sk->sk_error_report = xs_error_report;
 		sk->sk_allocation = GFP_ATOMIC;
 
 		/* socket options */
-- 
1.8.4.2

