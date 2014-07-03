Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yk0-f175.google.com ([209.85.160.175]:43716 "EHLO
	mail-yk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750707AbaGCEM7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jul 2014 00:12:59 -0400
Received: by mail-yk0-f175.google.com with SMTP id 9so6989383ykp.34
        for <linux-nfs@vger.kernel.org>; Wed, 02 Jul 2014 21:12:58 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 1/2] SUNRPC: Ensure that we handle ENOBUFS errors correctly.
Date: Thu,  3 Jul 2014 00:12:50 -0400
Message-Id: <1404360771-6782-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, an ENOBUFS error will result in a fatal error for the RPC
call. Normally, we will just want to wait and then retry.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/clnt.c     | 4 ++++
 net/sunrpc/xprtsock.c | 5 +++++
 2 files changed, 9 insertions(+)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 2e6ab10734f6..575e63f6c13e 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1746,6 +1746,7 @@ call_bind_status(struct rpc_task *task)
 	case -EHOSTDOWN:
 	case -EHOSTUNREACH:
 	case -ENETUNREACH:
+	case -ENOBUFS:
 	case -EPIPE:
 		dprintk("RPC: %5u remote rpcbind unreachable: %d\n",
 				task->tk_pid, task->tk_status);
@@ -1812,6 +1813,7 @@ call_connect_status(struct rpc_task *task)
 	case -ECONNABORTED:
 	case -ENETUNREACH:
 	case -EHOSTUNREACH:
+	case -ENOBUFS:
 		if (RPC_IS_SOFTCONN(task))
 			break;
 		/* retry with existing socket, after a delay */
@@ -1918,6 +1920,7 @@ call_transmit_status(struct rpc_task *task)
 	case -ECONNRESET:
 	case -ECONNABORTED:
 	case -ENOTCONN:
+	case -ENOBUFS:
 	case -EPIPE:
 		rpc_task_force_reencode(task);
 	}
@@ -2034,6 +2037,7 @@ call_status(struct rpc_task *task)
 	case -ECONNRESET:
 	case -ECONNABORTED:
 		rpc_force_rebind(clnt);
+	case -ENOBUFS:
 		rpc_delay(task, 3*HZ);
 	case -EPIPE:
 	case -ENOTCONN:
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index be8bbd5d65ec..8f8589fedfdd 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -594,6 +594,7 @@ static int xs_local_send_request(struct rpc_task *task)
 	}
 
 	switch (status) {
+	case -ENOBUFS:
 	case -EAGAIN:
 		status = xs_nospace(task);
 		break;
@@ -661,6 +662,7 @@ static int xs_udp_send_request(struct rpc_task *task)
 		dprintk("RPC:       sendmsg returned unrecognized error %d\n",
 			-status);
 	case -ENETUNREACH:
+	case -ENOBUFS:
 	case -EPIPE:
 	case -ECONNREFUSED:
 		/* When the server has died, an ICMP port unreachable message
@@ -758,6 +760,7 @@ static int xs_tcp_send_request(struct rpc_task *task)
 		status = -ENOTCONN;
 		/* Should we call xs_close() here? */
 		break;
+	case -ENOBUFS:
 	case -EAGAIN:
 		status = xs_nospace(task);
 		break;
@@ -1946,6 +1949,7 @@ static int xs_local_setup_socket(struct sock_xprt *transport)
 		dprintk("RPC:       xprt %p connected to %s\n",
 				xprt, xprt->address_strings[RPC_DISPLAY_ADDR]);
 		xprt_set_connected(xprt);
+	case -ENOBUFS:
 		break;
 	case -ENOENT:
 		dprintk("RPC:       xprt %p: socket %s does not exist\n",
@@ -2281,6 +2285,7 @@ static void xs_tcp_setup_socket(struct work_struct *work)
 	case -ECONNREFUSED:
 	case -ECONNRESET:
 	case -ENETUNREACH:
+	case -ENOBUFS:
 		/* retry with existing socket, after a delay */
 		goto out;
 	}
-- 
1.9.3

