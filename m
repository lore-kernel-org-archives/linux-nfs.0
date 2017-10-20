Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from gateway32.websitewelcome.com ([192.185.145.187]:46179 "EHLO
        gateway32.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753006AbdJTRJy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Oct 2017 13:09:54 -0400
Received: from cm15.websitewelcome.com (cm15.websitewelcome.com [100.42.49.9])
        by gateway32.websitewelcome.com (Postfix) with ESMTP id D35C123BDA
        for <linux-nfs@vger.kernel.org>; Fri, 20 Oct 2017 11:48:32 -0500 (CDT)
Date: Fri, 20 Oct 2017 11:48:30 -0500
From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        "David S. Miller" <davem@davemloft.net>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] net: sunrpc: mark expected switch fall-throughs
Message-ID: <20171020164830.GA8518@embeddedor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In preparation to enabling -Wimplicit-fallthrough, mark switch cases
where we are expecting to fall through.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
This code was tested by compilation only (GCC 7.2.0 was used).
Please, verify if the actual intention of the code is to fall through.

 net/sunrpc/clnt.c     | 11 +++++++++++
 net/sunrpc/xprt.c     |  1 +
 net/sunrpc/xprtsock.c |  4 ++++
 3 files changed, 16 insertions(+)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 2ad827d..d25b077 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1586,6 +1586,7 @@ call_reserveresult(struct rpc_task *task)
 	switch (status) {
 	case -ENOMEM:
 		rpc_delay(task, HZ >> 2);
+		/* fall through */
 	case -EAGAIN:	/* woken up; retry */
 		task->tk_action = call_retry_reserve;
 		return;
@@ -1647,10 +1648,13 @@ call_refreshresult(struct rpc_task *task)
 		/* Use rate-limiting and a max number of retries if refresh
 		 * had status 0 but failed to update the cred.
 		 */
+		/* fall through */
 	case -ETIMEDOUT:
 		rpc_delay(task, 3*HZ);
+		/* fall through */
 	case -EAGAIN:
 		status = -EACCES;
+		/* fall through */
 	case -EKEYEXPIRED:
 		if (!task->tk_cred_retry)
 			break;
@@ -1911,6 +1915,7 @@ call_connect_status(struct rpc_task *task)
 			task->tk_action = call_bind;
 			return;
 		}
+		/* fall through */
 	case -ECONNRESET:
 	case -ECONNABORTED:
 	case -ENETUNREACH:
@@ -1924,6 +1929,7 @@ call_connect_status(struct rpc_task *task)
 			break;
 		/* retry with existing socket, after a delay */
 		rpc_delay(task, 3*HZ);
+		/* fall through */
 	case -EAGAIN:
 		/* Check for timeouts before looping back to call_bind */
 	case -ETIMEDOUT:
@@ -2025,6 +2031,7 @@ call_transmit_status(struct rpc_task *task)
 			rpc_exit(task, task->tk_status);
 			break;
 		}
+		/* fall through */
 	case -ECONNRESET:
 	case -ECONNABORTED:
 	case -EADDRINUSE:
@@ -2145,6 +2152,7 @@ call_status(struct rpc_task *task)
 		 * were a timeout.
 		 */
 		rpc_delay(task, 3*HZ);
+		/* fall through */
 	case -ETIMEDOUT:
 		task->tk_action = call_timeout;
 		break;
@@ -2152,14 +2160,17 @@ call_status(struct rpc_task *task)
 	case -ECONNRESET:
 	case -ECONNABORTED:
 		rpc_force_rebind(clnt);
+		/* fall through */
 	case -EADDRINUSE:
 		rpc_delay(task, 3*HZ);
+		/* fall through */
 	case -EPIPE:
 	case -ENOTCONN:
 		task->tk_action = call_bind;
 		break;
 	case -ENOBUFS:
 		rpc_delay(task, HZ>>2);
+		/* fall through */
 	case -EAGAIN:
 		task->tk_action = call_transmit;
 		break;
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 1a39ad1..197883f 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1139,6 +1139,7 @@ void xprt_alloc_slot(struct rpc_xprt *xprt, struct rpc_task *task)
 	case -EAGAIN:
 		xprt_add_backlog(xprt, task);
 		dprintk("RPC:       waiting for request slot\n");
+		/* fall through */
 	default:
 		task->tk_status = -EAGAIN;
 	}
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index c1841f2..684e356 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -551,6 +551,7 @@ static int xs_local_send_request(struct rpc_task *task)
 	default:
 		dprintk("RPC:       sendmsg returned unrecognized error %d\n",
 			-status);
+		/* fall through */
 	case -EPIPE:
 		xs_close(xprt);
 		status = -ENOTCONN;
@@ -1610,6 +1611,7 @@ static void xs_tcp_state_change(struct sock *sk)
 		xprt->connect_cookie++;
 		clear_bit(XPRT_CONNECTED, &xprt->state);
 		xs_tcp_force_close(xprt);
+		/* fall through */
 	case TCP_CLOSING:
 		/*
 		 * If the server closed down the connection, make sure that
@@ -2367,6 +2369,7 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 	switch (ret) {
 	case 0:
 		xs_set_srcport(transport, sock);
+		/* fall through */
 	case -EINPROGRESS:
 		/* SYN_SENT! */
 		if (xprt->reestablish_timeout < XS_TCP_INIT_REEST_TO)
@@ -2418,6 +2421,7 @@ static void xs_tcp_setup_socket(struct work_struct *work)
 	default:
 		printk("%s: connect returned unhandled error %d\n",
 			__func__, status);
+		/* fall through */
 	case -EADDRNOTAVAIL:
 		/* We're probably in TIME_WAIT. Get rid of existing socket,
 		 * and retry
-- 
2.7.4

