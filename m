From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 007/112] SUNRPC: Allow the client to detect if the TCP
	connection is closed
Date: Fri, 25 Jan 2008 11:37:25 -0500
Message-ID: <20080125163725.31887.47553.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14342 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752631AbYAYQ7t (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 11:59:49 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxdtA010119
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 08:59:48 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add an xprt->state bit to enable the TCP ->state_change() method to signal
whether or not the TCP connection is in the process of closing down.
This will to be used by the reconnection logic in a separate patch.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 include/linux/sunrpc/xprt.h |    1 +
 net/sunrpc/xprtsock.c       |   24 +++++++++++++++++++++---
 2 files changed, 22 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 6f524a9..afb9e6a 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -257,6 +257,7 @@ void			xprt_force_disconnect(struct rpc_xprt *xprt);
 #define XPRT_CLOSE_WAIT		(3)
 #define XPRT_BOUND		(4)
 #define XPRT_BINDING		(5)
+#define XPRT_CLOSING		(6)
 
 static inline void xprt_set_connected(struct rpc_xprt *xprt)
 {
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 45cb1dc..607f233 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -758,7 +758,9 @@ static void xs_close(struct rpc_xprt *xprt)
 	sock_release(sock);
 clear_close_wait:
 	smp_mb__before_clear_bit();
+	clear_bit(XPRT_CONNECTED, &xprt->state);
 	clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
+	clear_bit(XPRT_CLOSING, &xprt->state);
 	smp_mb__after_clear_bit();
 }
 
@@ -1114,12 +1116,28 @@ static void xs_tcp_state_change(struct sock *sk)
 		}
 		spin_unlock_bh(&xprt->transport_lock);
 		break;
-	case TCP_SYN_SENT:
-	case TCP_SYN_RECV:
+	case TCP_FIN_WAIT1:
+		/* The client initiated a shutdown of the socket */
+		set_bit(XPRT_CLOSING, &xprt->state);
+		smp_mb__before_clear_bit();
+		clear_bit(XPRT_CONNECTED, &xprt->state);
+		smp_mb__after_clear_bit();
 		break;
 	case TCP_CLOSE_WAIT:
+		/* The server initiated a shutdown of the socket */
+		set_bit(XPRT_CLOSING, &xprt->state);
 		xprt_force_disconnect(xprt);
-	default:
+		break;
+	case TCP_LAST_ACK:
+		smp_mb__before_clear_bit();
+		clear_bit(XPRT_CONNECTED, &xprt->state);
+		smp_mb__after_clear_bit();
+		break;
+	case TCP_CLOSE:
+		smp_mb__before_clear_bit();
+		clear_bit(XPRT_CLOSING, &xprt->state);
+		smp_mb__after_clear_bit();
+		/* Mark transport as closed and wake up all pending tasks */
 		xprt_disconnect(xprt);
 	}
  out:
