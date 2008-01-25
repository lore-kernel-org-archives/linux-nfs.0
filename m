From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 009/112] SUNRPC: Use shutdown() instead of close() when
	disconnecting a TCP socket
Date: Fri, 25 Jan 2008 11:37:25 -0500
Message-ID: <20080125163725.31887.87389.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:42798 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757112AbYAYRC3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:02:29 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH2C7a011079
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:02:15 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

By using shutdown() rather than close() we allow the RPC client to wait
for the TCP close handshake to complete before we start trying to reconnect
using the same port.
We use shutdown(SHUT_WR) only instead of shutting down both directions,
however we wait until the server has closed the connection on its side.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/xprtsock.c |   41 ++++++++++++++++++++++++++++++++++-------
 1 files changed, 34 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index e4bdf77..d2151a9 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -614,6 +614,22 @@ static int xs_udp_send_request(struct rpc_task *task)
 	return status;
 }
 
+/**
+ * xs_tcp_shutdown - gracefully shut down a TCP socket
+ * @xprt: transport
+ *
+ * Initiates a graceful shutdown of the TCP socket by calling the
+ * equivalent of shutdown(SHUT_WR);
+ */
+static void xs_tcp_shutdown(struct rpc_xprt *xprt)
+{
+	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
+	struct socket *sock = transport->sock;
+
+	if (sock != NULL)
+		kernel_sock_shutdown(sock, SHUT_WR);
+}
+
 static inline void xs_encode_tcp_record_marker(struct xdr_buf *buf)
 {
 	u32 reclen = buf->len - sizeof(rpc_fraghdr);
@@ -691,7 +707,7 @@ static int xs_tcp_send_request(struct rpc_task *task)
 	default:
 		dprintk("RPC:       sendmsg returned unrecognized error %d\n",
 			-status);
-		xprt_disconnect(xprt);
+		xs_tcp_shutdown(xprt);
 		break;
 	}
 
@@ -1633,8 +1649,7 @@ static void xs_tcp_connect_worker4(struct work_struct *work)
 				break;
 			default:
 				/* get rid of existing socket, and retry */
-				xs_close(xprt);
-				break;
+				xs_tcp_shutdown(xprt);
 		}
 	}
 out:
@@ -1693,8 +1708,7 @@ static void xs_tcp_connect_worker6(struct work_struct *work)
 				break;
 			default:
 				/* get rid of existing socket, and retry */
-				xs_close(xprt);
-				break;
+				xs_tcp_shutdown(xprt);
 		}
 	}
 out:
@@ -1741,6 +1755,19 @@ static void xs_connect(struct rpc_task *task)
 	}
 }
 
+static void xs_tcp_connect(struct rpc_task *task)
+{
+	struct rpc_xprt *xprt = task->tk_xprt;
+
+	/* Initiate graceful shutdown of the socket if not already done */
+	if (test_bit(XPRT_CONNECTED, &xprt->state))
+		xs_tcp_shutdown(xprt);
+	/* Exit if we need to wait for socket shutdown to complete */
+	if (test_bit(XPRT_CLOSING, &xprt->state))
+		return;
+	xs_connect(task);
+}
+
 /**
  * xs_udp_print_stats - display UDP socket-specifc stats
  * @xprt: rpc_xprt struct containing statistics
@@ -1811,12 +1838,12 @@ static struct rpc_xprt_ops xs_tcp_ops = {
 	.release_xprt		= xs_tcp_release_xprt,
 	.rpcbind		= rpcb_getport_async,
 	.set_port		= xs_set_port,
-	.connect		= xs_connect,
+	.connect		= xs_tcp_connect,
 	.buf_alloc		= rpc_malloc,
 	.buf_free		= rpc_free,
 	.send_request		= xs_tcp_send_request,
 	.set_retrans_timeout	= xprt_set_retrans_timeout_def,
-	.close			= xs_close,
+	.close			= xs_tcp_shutdown,
 	.destroy		= xs_destroy,
 	.print_stats		= xs_tcp_print_stats,
 };
