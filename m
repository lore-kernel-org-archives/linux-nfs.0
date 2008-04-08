From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] SUNRPC: RPC client's TCP transport ignores errors during
	connect
Date: Tue, 08 Apr 2008 13:38:14 -0400
Message-ID: <20080408173602.21776.60671.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:32608 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751563AbYDHRic (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Apr 2008 13:38:32 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commits 66af1e55 through 663b8858 recently changed how
xs_tcp_state_change() awakens RPC tasks in order to address problems
with disconnection of TCP sockets that were already connected.

The generic function xprt_connect_status() is invoked during a transport
connection operation by this wake-up.  It expects a specific error value
describing the connection failure, but currently always gets ENOTCONN.

To fix this, change xprt_disconnect_done() to take an errno value
argument and pass it on to xprt_wake_pending_tasks().  Change
xs_tcp_state_change() to invoke xprt_disconnect_done() with the value
contained in the socket's sk_err field in order to report the specific
error which prevented the connect operation from completing.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

Found this while poking at the RPC server registration logic.  It appears to
fix the problem I was seeing with refused TCP connections.

Comments?

 include/linux/sunrpc/xprt.h     |    2 +-
 net/sunrpc/xprt.c               |    4 ++--
 net/sunrpc/xprtrdma/transport.c |    4 ++--
 net/sunrpc/xprtsock.c           |    9 +++++----
 4 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index b3ff9a8..a3543c8 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -239,7 +239,7 @@ void			xprt_adjust_cwnd(struct rpc_task *task, int result);
 struct rpc_rqst *	xprt_lookup_rqst(struct rpc_xprt *xprt, __be32 xid);
 void			xprt_complete_rqst(struct rpc_task *task, int copied);
 void			xprt_release_rqst_cong(struct rpc_task *task);
-void			xprt_disconnect_done(struct rpc_xprt *xprt);
+void			xprt_disconnect_done(struct rpc_xprt *xprt, int error);
 void			xprt_force_disconnect(struct rpc_xprt *xprt);
 
 /*
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index d5553b8..f61b560 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -579,12 +579,12 @@ static void xprt_autoclose(struct work_struct *work)
  * @xprt: transport to flag for disconnect
  *
  */
-void xprt_disconnect_done(struct rpc_xprt *xprt)
+void xprt_disconnect_done(struct rpc_xprt *xprt, int error)
 {
 	dprintk("RPC:       disconnected transport %p\n", xprt);
 	spin_lock_bh(&xprt->transport_lock);
 	xprt_clear_connected(xprt);
-	xprt_wake_pending_tasks(xprt, -ENOTCONN);
+	xprt_wake_pending_tasks(xprt, error);
 	spin_unlock_bh(&xprt->transport_lock);
 }
 EXPORT_SYMBOL_GPL(xprt_disconnect_done);
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index a564c1a..ac3938d 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -458,7 +458,7 @@ xprt_rdma_close(struct rpc_xprt *xprt)
 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
 
 	dprintk("RPC:       %s: closing\n", __func__);
-	xprt_disconnect_done(xprt);
+	xprt_disconnect_done(xprt, -ENOTCONN);
 	(void) rpcrdma_ep_disconnect(&r_xprt->rx_ep, &r_xprt->rx_ia);
 }
 
@@ -695,7 +695,7 @@ xprt_rdma_send_request(struct rpc_task *task)
 	}
 
 	if (rpcrdma_ep_post(&r_xprt->rx_ia, &r_xprt->rx_ep, req)) {
-		xprt_disconnect_done(xprt);
+		xprt_disconnect_done(xprt, -ENOTCONN);
 		return -ENOTCONN;	/* implies disconnect */
 	}
 
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 896aa1e..47b37ac 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -771,7 +771,7 @@ clear_close_wait:
 	clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
 	clear_bit(XPRT_CLOSING, &xprt->state);
 	smp_mb__after_clear_bit();
-	xprt_disconnect_done(xprt);
+	xprt_disconnect_done(xprt, -ENOTCONN);
 }
 
 /**
@@ -1105,8 +1105,8 @@ static void xs_tcp_state_change(struct sock *sk)
 	if (!(xprt = xprt_from_sock(sk)))
 		goto out;
 	dprintk("RPC:       xs_tcp_state_change client %p...\n", xprt);
-	dprintk("RPC:       state %x conn %d dead %d zapped %d\n",
-			sk->sk_state, xprt_connected(xprt),
+	dprintk("RPC:       state %x sk_err %d conn %d dead %d zapped %d\n",
+			sk->sk_state, sk->sk_err, xprt_connected(xprt),
 			sock_flag(sk, SOCK_DEAD),
 			sock_flag(sk, SOCK_ZAPPED));
 
@@ -1161,7 +1161,8 @@ static void xs_tcp_state_change(struct sock *sk)
 		clear_bit(XPRT_CLOSING, &xprt->state);
 		smp_mb__after_clear_bit();
 		/* Mark transport as closed and wake up all pending tasks */
-		xprt_disconnect_done(xprt);
+		xprt_disconnect_done(xprt, (sk->sk_err ?
+						-sk->sk_err : -ENOTCONN));
 	}
  out:
 	read_unlock(&sk->sk_callback_lock);

