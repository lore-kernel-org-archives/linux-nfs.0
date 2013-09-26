Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:18807 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754480Ab3IZVpU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Sep 2013 17:45:20 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/7] SUNRPC: Enable the keepalive option for TCP sockets
Date: Thu, 26 Sep 2013 17:45:00 -0400
Message-ID: <1380231907-13733-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1380231907-13733-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1380231907-13733-1-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For NFSv4 we want to avoid retransmitting RPC calls unless the TCP
connection breaks. However we still want to detect TCP connection
breakage as soon as possible. Do this by setting the keepalive option
with the idle timeout and count set to the 'timeo' and 'retrans' mount
options.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/xprtsock.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index ee03d35..208a763 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2112,6 +2112,19 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 
 	if (!transport->inet) {
 		struct sock *sk = sock->sk;
+		unsigned int keepidle = xprt->timeout->to_initval / HZ;
+		unsigned int keepcnt = xprt->timeout->to_retries + 1;
+		unsigned int opt_on = 1;
+
+		/* TCP Keepalive options */
+		kernel_setsockopt(sock, SOL_SOCKET, SO_KEEPALIVE,
+				(char *)&opt_on, sizeof(opt_on));
+		kernel_setsockopt(sock, SOL_TCP, TCP_KEEPIDLE,
+				(char *)&keepidle, sizeof(keepidle));
+		kernel_setsockopt(sock, SOL_TCP, TCP_KEEPINTVL,
+				(char *)&keepidle, sizeof(keepidle));
+		kernel_setsockopt(sock, SOL_TCP, TCP_KEEPCNT,
+				(char *)&keepcnt, sizeof(keepcnt));
 
 		write_lock_bh(&sk->sk_callback_lock);
 
-- 
1.8.3.1

