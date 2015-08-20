Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:36818 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750874AbbHTCyN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Aug 2015 22:54:13 -0400
Received: by pawq9 with SMTP id q9so16806149paw.3
        for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2015 19:54:13 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: Allow sockets to do GFP_NOIO allocations
Date: Wed, 19 Aug 2015 21:54:10 -0500
Message-Id: <1440039250-21009-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Follow up to commit c4a7ca774949 ("SUNRPC: Allow waiting on memory
allocation"). Allows the RPC socket code to do non-IO blocking.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprtsock.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 86ed778bb18b..723df7cb096d 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1866,7 +1866,7 @@ static int xs_local_finish_connecting(struct rpc_xprt *xprt,
 		sk->sk_data_ready = xs_local_data_ready;
 		sk->sk_write_space = xs_udp_write_space;
 		sk->sk_error_report = xs_error_report;
-		sk->sk_allocation = GFP_ATOMIC;
+		sk->sk_allocation = GFP_NOIO;
 
 		xprt_clear_connected(xprt);
 
@@ -2051,7 +2051,7 @@ static void xs_udp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 		sk->sk_user_data = xprt;
 		sk->sk_data_ready = xs_udp_data_ready;
 		sk->sk_write_space = xs_udp_write_space;
-		sk->sk_allocation = GFP_ATOMIC;
+		sk->sk_allocation = GFP_NOIO;
 
 		xprt_set_connected(xprt);
 
@@ -2153,7 +2153,7 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 		sk->sk_state_change = xs_tcp_state_change;
 		sk->sk_write_space = xs_tcp_write_space;
 		sk->sk_error_report = xs_error_report;
-		sk->sk_allocation = GFP_ATOMIC;
+		sk->sk_allocation = GFP_NOIO;
 
 		/* socket options */
 		sock_reset_flag(sk, SOCK_LINGER);
-- 
2.4.3

