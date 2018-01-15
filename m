Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:45104 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752150AbeAOEFO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 14 Jan 2018 23:05:14 -0500
Received: by mail-io0-f195.google.com with SMTP id e20so11728889iof.12
        for <linux-nfs@vger.kernel.org>; Sun, 14 Jan 2018 20:05:14 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] SUNRPC: Chunk reading of replies from the server
Date: Sun, 14 Jan 2018 23:05:07 -0500
Message-Id: <20180115040508.100921-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Read the TCP data in chunks of max 2MB so that we do not hog the
socket lock.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprtsock.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 6d0cc3b8f932..620be573d78b 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -52,6 +52,8 @@
 
 #include "sunrpc.h"
 
+#define RPC_TCP_READ_CHUNK_SZ	(3*512*1024)
+
 static void xs_close(struct rpc_xprt *xprt);
 static void xs_tcp_set_socket_timeouts(struct rpc_xprt *xprt,
 		struct socket *sock);
@@ -1479,6 +1481,7 @@ static int xs_tcp_data_recv(read_descriptor_t *rd_desc, struct sk_buff *skb, uns
 		.offset	= offset,
 		.count	= len,
 	};
+	size_t ret;
 
 	dprintk("RPC:       xs_tcp_data_recv started\n");
 	do {
@@ -1507,9 +1510,14 @@ static int xs_tcp_data_recv(read_descriptor_t *rd_desc, struct sk_buff *skb, uns
 		/* Skip over any trailing bytes on short reads */
 		xs_tcp_read_discard(transport, &desc);
 	} while (desc.count);
+	ret = len - desc.count;
+	if (ret < rd_desc->count)
+		rd_desc->count -= ret;
+	else
+		rd_desc->count = 0;
 	trace_xs_tcp_data_recv(transport);
 	dprintk("RPC:       xs_tcp_data_recv done\n");
-	return len - desc.count;
+	return ret;
 }
 
 static void xs_tcp_data_receive(struct sock_xprt *transport)
@@ -1517,7 +1525,6 @@ static void xs_tcp_data_receive(struct sock_xprt *transport)
 	struct rpc_xprt *xprt = &transport->xprt;
 	struct sock *sk;
 	read_descriptor_t rd_desc = {
-		.count = 2*1024*1024,
 		.arg.data = xprt,
 	};
 	unsigned long total = 0;
@@ -1531,16 +1538,16 @@ static void xs_tcp_data_receive(struct sock_xprt *transport)
 
 	/* We use rd_desc to pass struct xprt to xs_tcp_data_recv */
 	for (loop = 0; loop < 64; loop++) {
+		rd_desc.count = RPC_TCP_READ_CHUNK_SZ;
 		lock_sock(sk);
 		read = tcp_read_sock(sk, &rd_desc, xs_tcp_data_recv);
-		if (read <= 0) {
+		if (rd_desc.count != 0 || read < 0) {
 			clear_bit(XPRT_SOCK_DATA_READY, &transport->sock_state);
 			release_sock(sk);
 			break;
 		}
 		release_sock(sk);
 		total += read;
-		rd_desc.count = 65536;
 	}
 	if (test_bit(XPRT_SOCK_DATA_READY, &transport->sock_state))
 		queue_work(xprtiod_workqueue, &transport->recv_worker);
-- 
2.14.3

