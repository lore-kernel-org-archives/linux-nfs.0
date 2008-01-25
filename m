From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 012/112] SUNRPC: Rename xprt_disconnect()
Date: Fri, 25 Jan 2008 11:37:26 -0500
Message-ID: <20080125163726.31887.78991.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14364 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755004AbYAYRAG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:06 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxses010226
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:02 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

xprt_disconnect() should really only be called when the transport shutdown
is completed, and it is time to wake up any pending tasks. Rename it to
xprt_disconnect_done() in order to reflect the semantical change.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 include/linux/sunrpc/xprt.h     |    2 +-
 net/sunrpc/xprt.c               |    6 +++---
 net/sunrpc/xprtrdma/transport.c |    4 ++--
 net/sunrpc/xprtsock.c           |    4 ++--
 4 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index afb9e6a..2554cd2 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -245,7 +245,7 @@ void			xprt_adjust_cwnd(struct rpc_task *task, int result);
 struct rpc_rqst *	xprt_lookup_rqst(struct rpc_xprt *xprt, __be32 xid);
 void			xprt_complete_rqst(struct rpc_task *task, int copied);
 void			xprt_release_rqst_cong(struct rpc_task *task);
-void			xprt_disconnect(struct rpc_xprt *xprt);
+void			xprt_disconnect_done(struct rpc_xprt *xprt);
 void			xprt_force_disconnect(struct rpc_xprt *xprt);
 
 /*
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 8799b64..a9101d4 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -574,11 +574,11 @@ static void xprt_autoclose(struct work_struct *work)
 }
 
 /**
- * xprt_disconnect - mark a transport as disconnected
+ * xprt_disconnect_done - mark a transport as disconnected
  * @xprt: transport to flag for disconnect
  *
  */
-void xprt_disconnect(struct rpc_xprt *xprt)
+void xprt_disconnect_done(struct rpc_xprt *xprt)
 {
 	dprintk("RPC:       disconnected transport %p\n", xprt);
 	spin_lock_bh(&xprt->transport_lock);
@@ -586,7 +586,7 @@ void xprt_disconnect(struct rpc_xprt *xprt)
 	xprt_wake_pending_tasks(xprt, -ENOTCONN);
 	spin_unlock_bh(&xprt->transport_lock);
 }
-EXPORT_SYMBOL_GPL(xprt_disconnect);
+EXPORT_SYMBOL_GPL(xprt_disconnect_done);
 
 /**
  * xprt_force_disconnect - force a transport to disconnect
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 6f2112d..73033d8 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -449,7 +449,7 @@ xprt_rdma_close(struct rpc_xprt *xprt)
 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
 
 	dprintk("RPC:       %s: closing\n", __func__);
-	xprt_disconnect(xprt);
+	xprt_disconnect_done(xprt);
 	(void) rpcrdma_ep_disconnect(&r_xprt->rx_ep, &r_xprt->rx_ia);
 }
 
@@ -682,7 +682,7 @@ xprt_rdma_send_request(struct rpc_task *task)
 	}
 
 	if (rpcrdma_ep_post(&r_xprt->rx_ia, &r_xprt->rx_ep, req)) {
-		xprt_disconnect(xprt);
+		xprt_disconnect_done(xprt);
 		return -ENOTCONN;	/* implies disconnect */
 	}
 
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 9b85bf4..5f2bbe6 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -777,7 +777,7 @@ clear_close_wait:
 	clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
 	clear_bit(XPRT_CLOSING, &xprt->state);
 	smp_mb__after_clear_bit();
-	xprt_disconnect(xprt);
+	xprt_disconnect_done(xprt);
 }
 
 /**
@@ -1155,7 +1155,7 @@ static void xs_tcp_state_change(struct sock *sk)
 		clear_bit(XPRT_CLOSING, &xprt->state);
 		smp_mb__after_clear_bit();
 		/* Mark transport as closed and wake up all pending tasks */
-		xprt_disconnect(xprt);
+		xprt_disconnect_done(xprt);
 	}
  out:
 	read_unlock(&sk->sk_callback_lock);
