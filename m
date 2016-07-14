Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35096 "EHLO
	mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751051AbcGNXDZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jul 2016 19:03:25 -0400
Received: by mail-it0-f65.google.com with SMTP id f6so306790ith.2
        for <linux-nfs@vger.kernel.org>; Thu, 14 Jul 2016 16:03:24 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: Force a close when a socket keepalive timeout occurs
Date: Thu, 14 Jul 2016 19:03:00 -0400
Message-Id: <1468537380-66033-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1468537380-66033-1-git-send-email-trond.myklebust@primarydata.com>
References: <1468537380-66033-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprtsock.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 7e2b2fa189c3..19a44d844078 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -787,11 +787,17 @@ static void xs_error_report(struct sock *sk)
 		goto out;
 
 	err = -sk->sk_err;
-	if (err == 0)
+	switch (err) {
+	case 0:
 		goto out;
-	/* Is this a reset event? */
-	if (sk->sk_state == TCP_CLOSE)
-		xs_sock_mark_closed(xprt);
+	case -ETIMEDOUT:
+		xprt_force_disconnect(xprt);
+		break;
+	default:
+		/* Is this a reset event? */
+		if (sk->sk_state == TCP_CLOSE)
+			xs_sock_mark_closed(xprt);
+	}
 	dprintk("RPC:       xs_error_report client %p, error=%d...\n",
 			xprt, -err);
 	trace_rpc_socket_error(xprt, sk->sk_socket, err);
-- 
2.7.4

