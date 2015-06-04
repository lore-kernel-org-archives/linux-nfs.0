Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40368 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753546AbbFDQqD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Jun 2015 12:46:03 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        asias.hejun@gmail.com, netdev@vger.kernel.org,
        Daniel Berrange <berrange@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [RFC 03/10] SUNRPC: abstract tcp_read_sock() in record fragment parser
Date: Thu,  4 Jun 2015 17:45:46 +0100
Message-Id: <1433436353-6761-4-git-send-email-stefanha@redhat.com>
In-Reply-To: <1433436353-6761-1-git-send-email-stefanha@redhat.com>
References: <1433436353-6761-1-git-send-email-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use a function pointer to abstract tcp_read_sock()-like functions.  For
TCP this function will be tcp_read_sock().  For AF_VSOCK it will be
vsock_read_sock().

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 include/linux/sunrpc/xprtsock.h | 6 ++++++
 net/sunrpc/xprtsock.c           | 8 +++++++-
 2 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/include/linux/sunrpc/xprtsock.h b/include/linux/sunrpc/xprtsock.h
index e3de7bf..3b4cd4c 100644
--- a/include/linux/sunrpc/xprtsock.h
+++ b/include/linux/sunrpc/xprtsock.h
@@ -9,6 +9,9 @@
 
 #ifdef __KERNEL__
 
+/* TODO why does this header have no includes? */
+#include <net/tcp.h> /* for sk_read_actor_t */
+
 int		init_socket_xprt(void);
 void		cleanup_socket_xprt(void);
 
@@ -39,6 +42,9 @@ struct sock_xprt {
 	unsigned long		stream_copied,
 				stream_flags;
 
+	int			(*stream_read_sock)(struct sock *,
+						    read_descriptor_t *,
+						    sk_read_actor_t);
 
 	/*
 	 * Connection of transports
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index c84d45e..06fde0e 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1395,6 +1395,7 @@ static int xs_stream_data_recv(read_descriptor_t *rd_desc, struct sk_buff *skb,
 static void xs_stream_data_ready(struct sock *sk)
 {
 	struct rpc_xprt *xprt;
+	struct sock_xprt *transport;
 	read_descriptor_t rd_desc;
 	int read;
 	unsigned long total = 0;
@@ -1406,6 +1407,9 @@ static void xs_stream_data_ready(struct sock *sk)
 		read = 0;
 		goto out;
 	}
+
+	transport = container_of(xprt, struct sock_xprt, xprt);
+
 	/* Any data means we had a useful conversation, so
 	 * the we don't need to delay the next reconnect
 	 */
@@ -1416,7 +1420,8 @@ static void xs_stream_data_ready(struct sock *sk)
 	rd_desc.arg.data = xprt;
 	do {
 		rd_desc.count = 65536;
-		read = tcp_read_sock(sk, &rd_desc, xs_stream_data_recv);
+		read = transport->stream_read_sock(sk, &rd_desc,
+						   xs_stream_data_recv);
 		if (read > 0)
 			total += read;
 	} while (read > 0);
@@ -1458,6 +1463,7 @@ static void xs_tcp_state_change(struct sock *sk)
 			transport->stream_copied = 0;
 			transport->stream_flags =
 				STREAM_RCV_COPY_FRAGHDR | STREAM_RCV_COPY_XID;
+			transport->stream_read_sock = tcp_read_sock;
 			xprt->connect_cookie++;
 
 			xprt_wake_pending_tasks(xprt, -EAGAIN);
-- 
2.4.2

