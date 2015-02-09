Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f178.google.com ([209.85.223.178]:37199 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759245AbbBIDHs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 8 Feb 2015 22:07:48 -0500
Received: by iebtr6 with SMTP id tr6so13506488ieb.4
        for <linux-nfs@vger.kernel.org>; Sun, 08 Feb 2015 19:07:47 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 02/11] SUNRPC: Handle EADDRINUSE on connect
Date: Sun,  8 Feb 2015 22:07:33 -0500
Message-Id: <1423451262-84493-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1423451262-84493-2-git-send-email-trond.myklebust@primarydata.com>
References: <1423451262-84493-1-git-send-email-trond.myklebust@primarydata.com>
 <1423451262-84493-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that we're setting SO_REUSEPORT, we still need to handle the
case where a connect() is attempted, but the old socket is still
lingering.
Essentially, all we want to do here is handle the error by waiting
a few seconds and then retrying.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/clnt.c     | 3 +++
 net/sunrpc/xprtsock.c | 2 ++
 2 files changed, 5 insertions(+)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 3f5d4d48f0cb..612aa73bbc60 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1826,6 +1826,7 @@ call_connect_status(struct rpc_task *task)
 	case -ECONNABORTED:
 	case -ENETUNREACH:
 	case -EHOSTUNREACH:
+	case -EADDRINUSE:
 	case -ENOBUFS:
 	case -EPIPE:
 		if (RPC_IS_SOFTCONN(task))
@@ -1934,6 +1935,7 @@ call_transmit_status(struct rpc_task *task)
 		}
 	case -ECONNRESET:
 	case -ECONNABORTED:
+	case -EADDRINUSE:
 	case -ENOTCONN:
 	case -ENOBUFS:
 	case -EPIPE:
@@ -2053,6 +2055,7 @@ call_status(struct rpc_task *task)
 	case -ECONNRESET:
 	case -ECONNABORTED:
 		rpc_force_rebind(clnt);
+	case -EADDRINUSE:
 	case -ENOBUFS:
 		rpc_delay(task, 3*HZ);
 	case -EPIPE:
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 484c5040436a..20f25a837e06 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -721,6 +721,7 @@ static int xs_tcp_send_request(struct rpc_task *task)
 		xs_tcp_shutdown(xprt);
 	case -ECONNREFUSED:
 	case -ENOTCONN:
+	case -EADDRINUSE:
 	case -EPIPE:
 		clear_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags);
 	}
@@ -2299,6 +2300,7 @@ static void xs_tcp_setup_socket(struct work_struct *work)
 	case -ECONNREFUSED:
 	case -ECONNRESET:
 	case -ENETUNREACH:
+	case -EADDRINUSE:
 	case -ENOBUFS:
 		/* retry with existing socket, after a delay */
 		goto out;
-- 
2.1.0

