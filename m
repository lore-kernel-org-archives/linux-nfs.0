Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35690 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752003AbdBHQrZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Feb 2017 11:47:25 -0500
Received: by mail-io0-f194.google.com with SMTP id m98so16377855iod.2
        for <linux-nfs@vger.kernel.org>; Wed, 08 Feb 2017 08:47:24 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/4] SUNRPC: Refactor TCP socket timeout code into a helper function
Date: Wed,  8 Feb 2017 11:17:53 -0500
Message-Id: <20170208161755.3614-3-trond.myklebust@primarydata.com>
In-Reply-To: <20170208161755.3614-2-trond.myklebust@primarydata.com>
References: <20170208161755.3614-1-trond.myklebust@primarydata.com>
 <20170208161755.3614-2-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprtsock.c | 45 ++++++++++++++++++++++++++-------------------
 1 file changed, 26 insertions(+), 19 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index af392d9b9cec..c8ac649a51cb 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2235,6 +2235,31 @@ static void xs_tcp_shutdown(struct rpc_xprt *xprt)
 		xs_reset_transport(transport);
 }
 
+static void xs_tcp_set_socket_timeouts(struct rpc_xprt *xprt,
+		struct socket *sock)
+{
+	unsigned int keepidle = DIV_ROUND_UP(xprt->timeout->to_initval, HZ);
+	unsigned int keepcnt = xprt->timeout->to_retries + 1;
+	unsigned int opt_on = 1;
+	unsigned int timeo;
+
+	/* TCP Keepalive options */
+	kernel_setsockopt(sock, SOL_SOCKET, SO_KEEPALIVE,
+			(char *)&opt_on, sizeof(opt_on));
+	kernel_setsockopt(sock, SOL_TCP, TCP_KEEPIDLE,
+			(char *)&keepidle, sizeof(keepidle));
+	kernel_setsockopt(sock, SOL_TCP, TCP_KEEPINTVL,
+			(char *)&keepidle, sizeof(keepidle));
+	kernel_setsockopt(sock, SOL_TCP, TCP_KEEPCNT,
+			(char *)&keepcnt, sizeof(keepcnt));
+
+	/* TCP user timeout (see RFC5482) */
+	timeo = jiffies_to_msecs(xprt->timeout->to_initval) *
+		(xprt->timeout->to_retries + 1);
+	kernel_setsockopt(sock, SOL_TCP, TCP_USER_TIMEOUT,
+			(char *)&timeo, sizeof(timeo));
+}
+
 static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 {
 	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
@@ -2242,22 +2267,8 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 
 	if (!transport->inet) {
 		struct sock *sk = sock->sk;
-		unsigned int keepidle = xprt->timeout->to_initval / HZ;
-		unsigned int keepcnt = xprt->timeout->to_retries + 1;
-		unsigned int opt_on = 1;
-		unsigned int timeo;
 		unsigned int addr_pref = IPV6_PREFER_SRC_PUBLIC;
 
-		/* TCP Keepalive options */
-		kernel_setsockopt(sock, SOL_SOCKET, SO_KEEPALIVE,
-				(char *)&opt_on, sizeof(opt_on));
-		kernel_setsockopt(sock, SOL_TCP, TCP_KEEPIDLE,
-				(char *)&keepidle, sizeof(keepidle));
-		kernel_setsockopt(sock, SOL_TCP, TCP_KEEPINTVL,
-				(char *)&keepidle, sizeof(keepidle));
-		kernel_setsockopt(sock, SOL_TCP, TCP_KEEPCNT,
-				(char *)&keepcnt, sizeof(keepcnt));
-
 		/* Avoid temporary address, they are bad for long-lived
 		 * connections such as NFS mounts.
 		 * RFC4941, section 3.6 suggests that:
@@ -2268,11 +2279,7 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 		kernel_setsockopt(sock, SOL_IPV6, IPV6_ADDR_PREFERENCES,
 				(char *)&addr_pref, sizeof(addr_pref));
 
-		/* TCP user timeout (see RFC5482) */
-		timeo = jiffies_to_msecs(xprt->timeout->to_initval) *
-			(xprt->timeout->to_retries + 1);
-		kernel_setsockopt(sock, SOL_TCP, TCP_USER_TIMEOUT,
-				(char *)&timeo, sizeof(timeo));
+		xs_tcp_set_socket_timeouts(xprt, sock);
 
 		write_lock_bh(&sk->sk_callback_lock);
 
-- 
2.9.3

