Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45656 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752377AbdF3NYV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Jun 2017 09:24:21 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Abbas Naderi <abiusx@google.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH v3 03/14] SUNRPC: abstract tcp_read_sock() in record fragment parser
Date: Fri, 30 Jun 2017 14:23:41 +0100
Message-Id: <20170630132352.32133-4-stefanha@redhat.com>
In-Reply-To: <20170630132352.32133-1-stefanha@redhat.com>
References: <20170630132352.32133-1-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use a function pointer to abstract tcp_read_sock()-like functions.  For
TCP this function will be tcp_read_sock().  For AF_VSOCK it will be
vsock_read_sock().

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 include/linux/sunrpc/xprtsock.h |  5 +++++
 net/sunrpc/xprtsock.c           | 14 ++++++++------
 2 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/include/linux/sunrpc/xprtsock.h b/include/linux/sunrpc/xprtsock.h
index 6749774..a778973 100644
--- a/include/linux/sunrpc/xprtsock.h
+++ b/include/linux/sunrpc/xprtsock.h
@@ -9,6 +9,8 @@
 
 #ifdef __KERNEL__
 
+#include <net/tcp.h> /* for sk_read_actor_t */
+
 int		init_socket_xprt(void);
 void		cleanup_socket_xprt(void);
 
@@ -39,6 +41,9 @@ struct sock_xprt {
 	unsigned long		stream_copied,
 				stream_flags;
 
+	int			(*stream_read_sock)(struct sock *,
+						    read_descriptor_t *,
+						    sk_read_actor_t);
 
 	/*
 	 * Connection of transports
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 5c21aec..184e263 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1507,7 +1507,7 @@ static int xs_stream_data_recv(read_descriptor_t *rd_desc, struct sk_buff *skb,
 	return len - desc.count;
 }
 
-static void xs_tcp_data_receive(struct sock_xprt *transport)
+static void xs_stream_data_receive(struct sock_xprt *transport)
 {
 	struct rpc_xprt *xprt = &transport->xprt;
 	struct sock *sk;
@@ -1523,10 +1523,11 @@ static void xs_tcp_data_receive(struct sock_xprt *transport)
 	if (sk == NULL)
 		goto out;
 
-	/* We use rd_desc to pass struct xprt to xs_tcp_data_recv */
+	/* We use rd_desc to pass struct xprt to xs_stream_data_recv */
 	for (;;) {
 		lock_sock(sk);
-		read = tcp_read_sock(sk, &rd_desc, xs_stream_data_recv);
+		read = transport->stream_read_sock(sk, &rd_desc,
+						   xs_stream_data_recv);
 		if (read <= 0) {
 			clear_bit(XPRT_SOCK_DATA_READY, &transport->sock_state);
 			release_sock(sk);
@@ -1543,11 +1544,11 @@ static void xs_tcp_data_receive(struct sock_xprt *transport)
 	trace_xs_tcp_data_ready(xprt, read, total);
 }
 
-static void xs_tcp_data_receive_workfn(struct work_struct *work)
+static void xs_stream_data_receive_workfn(struct work_struct *work)
 {
 	struct sock_xprt *transport =
 		container_of(work, struct sock_xprt, recv_worker);
-	xs_tcp_data_receive(transport);
+	xs_stream_data_receive(transport);
 }
 
 /**
@@ -1583,6 +1584,7 @@ static void xs_tcp_state_change(struct sock *sk)
 			transport->stream_copied = 0;
 			transport->stream_flags =
 				STREAM_RCV_COPY_FRAGHDR | STREAM_RCV_COPY_XID;
+			transport->stream_read_sock = tcp_read_sock;
 			xprt->connect_cookie++;
 			clear_bit(XPRT_SOCK_CONNECTING, &transport->sock_state);
 			xprt_clear_connecting(xprt);
@@ -3065,7 +3067,7 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
 	xprt->connect_timeout = xprt->timeout->to_initval *
 		(xprt->timeout->to_retries + 1);
 
-	INIT_WORK(&transport->recv_worker, xs_tcp_data_receive_workfn);
+	INIT_WORK(&transport->recv_worker, xs_stream_data_receive_workfn);
 	INIT_DELAYED_WORK(&transport->connect_worker, xs_tcp_setup_socket);
 
 	switch (addr->sa_family) {
-- 
2.9.4

