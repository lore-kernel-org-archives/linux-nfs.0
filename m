Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:37429 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932244AbbFTThZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 20 Jun 2015 15:37:25 -0400
Received: by igblr2 with SMTP id lr2so32352046igb.0
        for <linux-nfs@vger.kernel.org>; Sat, 20 Jun 2015 12:37:24 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: Set the TCP user timeout option on client sockets
Date: Sat, 20 Jun 2015 15:37:23 -0400
Message-Id: <1434829043-18685-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use the TCP_USER_TIMEOUT socket option to advertise to the server
how long we will keep the connection open if there is unacknowledged
data. See RFC5482.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprtsock.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index ee0715dfc3c7..ee359fc7af16 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2117,6 +2117,7 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 		unsigned int keepidle = xprt->timeout->to_initval / HZ;
 		unsigned int keepcnt = xprt->timeout->to_retries + 1;
 		unsigned int opt_on = 1;
+		unsigned int timeo;
 
 		/* TCP Keepalive options */
 		kernel_setsockopt(sock, SOL_SOCKET, SO_KEEPALIVE,
@@ -2128,6 +2129,12 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 		kernel_setsockopt(sock, SOL_TCP, TCP_KEEPCNT,
 				(char *)&keepcnt, sizeof(keepcnt));
 
+		/* TCP user timeout (see RFC5482) */
+		timeo = jiffies_to_msecs(xprt->timeout->to_initval) *
+			(xprt->timeout->to_retries + 1);
+		kernel_setsockopt(sock, SOL_TCP, TCP_USER_TIMEOUT,
+				(char *)&timeo, sizeof(timeo));
+
 		write_lock_bh(&sk->sk_callback_lock);
 
 		xs_save_old_callbacks(transport, sk);
-- 
2.4.3

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
