Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:59486 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757178Ab3IDQjE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Sep 2013 12:39:04 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH] SUNRPC: Add tracepoints to help debug socket connection issues
Date: Wed, 4 Sep 2013 12:35:46 -0400
Message-ID: <1378312546-34073-1-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add client side debugging to help trace socket connection/disconnection
and unexpected state change issues.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/trace/events/sunrpc.h | 131 ++++++++++++++++++++++++++++++++++++++++++
 net/sunrpc/xprtsock.c         |  13 ++++-
 2 files changed, 143 insertions(+), 1 deletion(-)

diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 43be87d..b74a8ac 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -6,6 +6,8 @@
 
 #include <linux/sunrpc/sched.h>
 #include <linux/sunrpc/clnt.h>
+#include <net/tcp_states.h>
+#include <linux/net.h>
 #include <linux/tracepoint.h>
 
 DECLARE_EVENT_CLASS(rpc_task_status,
@@ -172,6 +174,135 @@ DEFINE_EVENT(rpc_task_queued, rpc_task_wakeup,
 
 );
 
+#define rpc_show_socket_state(state) \
+	__print_symbolic(state, \
+		{ SS_FREE, "FREE" }, \
+		{ SS_UNCONNECTED, "UNCONNECTED" }, \
+		{ SS_CONNECTING, "CONNECTING," }, \
+		{ SS_CONNECTED, "CONNECTED," }, \
+		{ SS_DISCONNECTING, "DISCONNECTING" })
+
+#define rpc_show_sock_state(state) \
+	__print_symbolic(state, \
+		{ TCP_ESTABLISHED, "ESTABLISHED" }, \
+		{ TCP_SYN_SENT, "SYN_SENT" }, \
+		{ TCP_SYN_RECV, "SYN_RECV" }, \
+		{ TCP_FIN_WAIT1, "FIN_WAIT1" }, \
+		{ TCP_FIN_WAIT2, "FIN_WAIT2" }, \
+		{ TCP_TIME_WAIT, "TIME_WAIT" }, \
+		{ TCP_CLOSE, "CLOSE" }, \
+		{ TCP_CLOSE_WAIT, "CLOSE_WAIT" }, \
+		{ TCP_LAST_ACK, "LAST_ACK" }, \
+		{ TCP_LISTEN, "LISTEN" }, \
+		{ TCP_CLOSING, "CLOSING" })
+
+DECLARE_EVENT_CLASS(xs_socket_event,
+
+		TP_PROTO(
+			struct rpc_xprt *xprt,
+			struct socket *socket
+		),
+
+		TP_ARGS(xprt, socket),
+
+		TP_STRUCT__entry(
+			__field(unsigned int, socket_state)
+			__field(unsigned int, sock_state)
+			__field(unsigned long long, ino)
+			__string(dstaddr,
+				xprt->address_strings[RPC_DISPLAY_ADDR])
+			__string(dstport,
+				xprt->address_strings[RPC_DISPLAY_PORT])
+		),
+
+		TP_fast_assign(
+			struct inode *inode = SOCK_INODE(socket);
+			__entry->socket_state = socket->state;
+			__entry->sock_state = socket->sk->sk_state;
+			__entry->ino = (unsigned long long)inode->i_ino;
+			__assign_str(dstaddr,
+				xprt->address_strings[RPC_DISPLAY_ADDR]);
+			__assign_str(dstport,
+				xprt->address_strings[RPC_DISPLAY_PORT]);
+		),
+
+		TP_printk(
+			"socket:[%llu] dstaddr=%s/%s "
+			"state=%u (%s) sk_state=%u (%s)",
+			__entry->ino, __get_str(dstaddr), __get_str(dstport),
+			__entry->socket_state,
+			rpc_show_socket_state(__entry->socket_state),
+			__entry->sock_state,
+			rpc_show_sock_state(__entry->sock_state)
+		)
+);
+#define DEFINE_RPC_SOCKET_EVENT(name) \
+	DEFINE_EVENT(xs_socket_event, name, \
+			TP_PROTO( \
+				struct rpc_xprt *xprt, \
+				struct socket *socket \
+			), \
+			TP_ARGS(xprt, socket))
+
+DECLARE_EVENT_CLASS(xs_socket_event_done,
+
+		TP_PROTO(
+			struct rpc_xprt *xprt,
+			struct socket *socket,
+			int error
+		),
+
+		TP_ARGS(xprt, socket, error),
+
+		TP_STRUCT__entry(
+			__field(int, error)
+			__field(unsigned int, socket_state)
+			__field(unsigned int, sock_state)
+			__field(unsigned long long, ino)
+			__string(dstaddr,
+				xprt->address_strings[RPC_DISPLAY_ADDR])
+			__string(dstport,
+				xprt->address_strings[RPC_DISPLAY_PORT])
+		),
+
+		TP_fast_assign(
+			struct inode *inode = SOCK_INODE(socket);
+			__entry->socket_state = socket->state;
+			__entry->sock_state = socket->sk->sk_state;
+			__entry->ino = (unsigned long long)inode->i_ino;
+			__entry->error = error;
+			__assign_str(dstaddr,
+				xprt->address_strings[RPC_DISPLAY_ADDR]);
+			__assign_str(dstport,
+				xprt->address_strings[RPC_DISPLAY_PORT]);
+		),
+
+		TP_printk(
+			"error=%d socket:[%llu] dstaddr=%s/%s "
+			"state=%u (%s) sk_state=%u (%s)",
+			__entry->error,
+			__entry->ino, __get_str(dstaddr), __get_str(dstport),
+			__entry->socket_state,
+			rpc_show_socket_state(__entry->socket_state),
+			__entry->sock_state,
+			rpc_show_sock_state(__entry->sock_state)
+		)
+);
+#define DEFINE_RPC_SOCKET_EVENT_DONE(name) \
+	DEFINE_EVENT(xs_socket_event_done, name, \
+			TP_PROTO( \
+				struct rpc_xprt *xprt, \
+				struct socket *socket, \
+				int error \
+			), \
+			TP_ARGS(xprt, socket, error))
+
+DEFINE_RPC_SOCKET_EVENT(rpc_socket_state_change);
+DEFINE_RPC_SOCKET_EVENT_DONE(rpc_socket_connect);
+DEFINE_RPC_SOCKET_EVENT_DONE(rpc_socket_reset_connection);
+DEFINE_RPC_SOCKET_EVENT(rpc_socket_close);
+DEFINE_RPC_SOCKET_EVENT(rpc_socket_shutdown);
+
 #endif /* _TRACE_SUNRPC_H */
 
 #include <trace/define_trace.h>
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index ddf0602..b98bce5 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -47,6 +47,8 @@
 #include <net/udp.h>
 #include <net/tcp.h>
 
+#include <trace/events/sunrpc.h>
+
 #include "sunrpc.h"
 
 static void xs_close(struct rpc_xprt *xprt);
@@ -665,8 +667,10 @@ static void xs_tcp_shutdown(struct rpc_xprt *xprt)
 	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
 	struct socket *sock = transport->sock;
 
-	if (sock != NULL)
+	if (sock != NULL) {
 		kernel_sock_shutdown(sock, SHUT_WR);
+		trace_rpc_socket_shutdown(xprt, sock);
+	}
 }
 
 /**
@@ -811,6 +815,7 @@ static void xs_reset_transport(struct sock_xprt *transport)
 
 	sk->sk_no_check = 0;
 
+	trace_rpc_socket_close(&transport->xprt, sock);
 	sock_release(sock);
 }
 
@@ -1492,6 +1497,7 @@ static void xs_tcp_state_change(struct sock *sk)
 			sock_flag(sk, SOCK_ZAPPED),
 			sk->sk_shutdown);
 
+	trace_rpc_socket_state_change(xprt, sk->sk_socket);
 	switch (sk->sk_state) {
 	case TCP_ESTABLISHED:
 		spin_lock(&xprt->transport_lock);
@@ -1896,6 +1902,7 @@ static int xs_local_setup_socket(struct sock_xprt *transport)
 			xprt, xprt->address_strings[RPC_DISPLAY_ADDR]);
 
 	status = xs_local_finish_connecting(xprt, sock);
+	trace_rpc_socket_connect(xprt, sock, status);
 	switch (status) {
 	case 0:
 		dprintk("RPC:       xprt %p connected to %s\n",
@@ -2039,6 +2046,7 @@ static void xs_udp_setup_socket(struct work_struct *work)
 			xprt->address_strings[RPC_DISPLAY_PORT]);
 
 	xs_udp_finish_connecting(xprt, sock);
+	trace_rpc_socket_connect(xprt, sock, 0);
 	status = 0;
 out:
 	xprt_clear_connecting(xprt);
@@ -2064,6 +2072,8 @@ static void xs_abort_connection(struct sock_xprt *transport)
 	memset(&any, 0, sizeof(any));
 	any.sa_family = AF_UNSPEC;
 	result = kernel_connect(transport->sock, &any, sizeof(any), 0);
+	trace_rpc_socket_reset_connection(&transport->xprt,
+			transport->sock, result);
 	if (!result)
 		xs_sock_reset_connection_flags(&transport->xprt);
 	dprintk("RPC:       AF_UNSPEC connect return code %d\n", result);
@@ -2194,6 +2204,7 @@ static void xs_tcp_setup_socket(struct work_struct *work)
 			xprt->address_strings[RPC_DISPLAY_PORT]);
 
 	status = xs_tcp_finish_connecting(xprt, sock);
+	trace_rpc_socket_connect(xprt, sock, status);
 	dprintk("RPC:       %p connect status %d connected %d sock state %d\n",
 			xprt, -status, xprt_connected(xprt),
 			sock->sk->sk_state);
-- 
1.8.3.1

