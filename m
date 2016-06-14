Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34464 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751727AbcFNTEh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2016 15:04:37 -0400
Received: by mail-io0-f194.google.com with SMTP id d2so407299iof.1
        for <linux-nfs@vger.kernel.org>; Tue, 14 Jun 2016 12:04:37 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/5] SUNRPC: Consolidate xs_tcp_data_ready and xs_data_ready
Date: Tue, 14 Jun 2016 15:04:03 -0400
Message-Id: <1465931046-30696-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1465931046-30696-1-git-send-email-trond.myklebust@primarydata.com>
References: <1465931046-30696-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The only difference between the two at this point is the reset of
the connection timeout, and since everyone expect tcp ignore that value,
we can just throw it into the generic function.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprtsock.c | 38 +++++++-------------------------------
 1 file changed, 7 insertions(+), 31 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 2f2178027761..62b4f5a2a331 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1088,6 +1088,12 @@ static void xs_data_ready(struct sock *sk)
 	if (xprt != NULL) {
 		struct sock_xprt *transport = container_of(xprt,
 				struct sock_xprt, xprt);
+		transport->old_data_ready(sk);
+		/* Any data means we had a useful conversation, so
+		 * then we don't need to delay the next reconnect
+		 */
+		if (xprt->reestablish_timeout)
+			xprt->reestablish_timeout = 0;
 		if (!test_and_set_bit(XPRT_SOCK_DATA_READY, &transport->sock_state))
 			queue_work(rpciod_workqueue, &transport->recv_worker);
 	}
@@ -1513,36 +1519,6 @@ static void xs_tcp_data_receive_workfn(struct work_struct *work)
 }
 
 /**
- * xs_tcp_data_ready - "data ready" callback for TCP sockets
- * @sk: socket with data to read
- *
- */
-static void xs_tcp_data_ready(struct sock *sk)
-{
-	struct sock_xprt *transport;
-	struct rpc_xprt *xprt;
-
-	dprintk("RPC:       xs_tcp_data_ready...\n");
-
-	read_lock_bh(&sk->sk_callback_lock);
-	if (!(xprt = xprt_from_sock(sk)))
-		goto out;
-	transport = container_of(xprt, struct sock_xprt, xprt);
-	if (test_and_set_bit(XPRT_SOCK_DATA_READY, &transport->sock_state))
-		goto out;
-
-	/* Any data means we had a useful conversation, so
-	 * the we don't need to delay the next reconnect
-	 */
-	if (xprt->reestablish_timeout)
-		xprt->reestablish_timeout = 0;
-	queue_work(rpciod_workqueue, &transport->recv_worker);
-
-out:
-	read_unlock_bh(&sk->sk_callback_lock);
-}
-
-/**
  * xs_tcp_state_change - callback to handle TCP socket state changes
  * @sk: socket whose state has changed
  *
@@ -2263,7 +2239,7 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 		xs_save_old_callbacks(transport, sk);
 
 		sk->sk_user_data = xprt;
-		sk->sk_data_ready = xs_tcp_data_ready;
+		sk->sk_data_ready = xs_data_ready;
 		sk->sk_state_change = xs_tcp_state_change;
 		sk->sk_write_space = xs_tcp_write_space;
 		sock_set_flag(sk, SOCK_FASYNC);
-- 
2.5.5

