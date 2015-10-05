Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f169.google.com ([209.85.160.169]:34027 "EHLO
	mail-yk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752153AbbJEXDe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Oct 2015 19:03:34 -0400
Received: by ykdg206 with SMTP id g206so185335006ykd.1
        for <linux-nfs@vger.kernel.org>; Mon, 05 Oct 2015 16:03:34 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC PATCH 1/3] SUNRPC: Refactor TCP receive
Date: Mon,  5 Oct 2015 19:03:29 -0400
Message-Id: <1444086211-4811-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move the TCP data receive loop out of xs_tcp_data_ready(). Doing so
will allow us to move the data receive out of the softirq context in
a set of followup patches.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprtsock.c | 44 +++++++++++++++++++++++++++++---------------
 1 file changed, 29 insertions(+), 15 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 1a85e0ed0b48..fa8d0c15c8cd 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1391,6 +1391,30 @@ static int xs_tcp_data_recv(read_descriptor_t *rd_desc, struct sk_buff *skb, uns
 	return len - desc.count;
 }
 
+static void xs_tcp_data_receive(struct sock_xprt *transport)
+{
+	struct rpc_xprt *xprt = &transport->xprt;
+	struct sock *sk;
+	read_descriptor_t rd_desc = {
+		.count = 2*1024*1024,
+		.arg.data = xprt,
+	};
+	unsigned long total = 0;
+	int read = 0;
+
+	sk = transport->inet;
+
+	/* We use rd_desc to pass struct xprt to xs_tcp_data_recv */
+	for (;;) {
+		read = tcp_read_sock(sk, &rd_desc, xs_tcp_data_recv);
+		if (read <= 0)
+			break;
+		total += read;
+		rd_desc.count = 65536;
+	}
+	trace_xs_tcp_data_ready(xprt, read, total);
+}
+
 /**
  * xs_tcp_data_ready - "data ready" callback for TCP sockets
  * @sk: socket with data to read
@@ -1398,34 +1422,24 @@ static int xs_tcp_data_recv(read_descriptor_t *rd_desc, struct sk_buff *skb, uns
  */
 static void xs_tcp_data_ready(struct sock *sk)
 {
+	struct sock_xprt *transport;
 	struct rpc_xprt *xprt;
-	read_descriptor_t rd_desc;
-	int read;
-	unsigned long total = 0;
 
 	dprintk("RPC:       xs_tcp_data_ready...\n");
 
 	read_lock_bh(&sk->sk_callback_lock);
-	if (!(xprt = xprt_from_sock(sk))) {
-		read = 0;
+	if (!(xprt = xprt_from_sock(sk)))
 		goto out;
-	}
+	transport = container_of(xprt, struct sock_xprt, xprt);
+
 	/* Any data means we had a useful conversation, so
 	 * the we don't need to delay the next reconnect
 	 */
 	if (xprt->reestablish_timeout)
 		xprt->reestablish_timeout = 0;
 
-	/* We use rd_desc to pass struct xprt to xs_tcp_data_recv */
-	rd_desc.arg.data = xprt;
-	do {
-		rd_desc.count = 65536;
-		read = tcp_read_sock(sk, &rd_desc, xs_tcp_data_recv);
-		if (read > 0)
-			total += read;
-	} while (read > 0);
+	xs_tcp_data_receive(transport);
 out:
-	trace_xs_tcp_data_ready(xprt, read, total);
 	read_unlock_bh(&sk->sk_callback_lock);
 }
 
-- 
2.4.3

