Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:36306 "EHLO
	mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756115AbcGZNvr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Jul 2016 09:51:47 -0400
Received: by mail-it0-f66.google.com with SMTP id j124so659678ith.3
        for <linux-nfs@vger.kernel.org>; Tue, 26 Jul 2016 06:51:46 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] SUNRPC: Detect immediate closure of accepted sockets
Date: Tue, 26 Jul 2016 09:51:20 -0400
Message-Id: <1469541080-4184-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1469541080-4184-1-git-send-email-trond.myklebust@primarydata.com>
References: <1469541080-4184-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This modification is useful for debugging issues that happen while
the socket is being initialised.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/svcsock.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 38b132ff6dce..e84321a09880 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1365,8 +1365,11 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 	else
 		svc_tcp_init(svsk, serv);
 
-	dprintk("svc: svc_setup_socket created %p (inet %p)\n",
-				svsk, svsk->sk_sk);
+	dprintk("svc: svc_setup_socket created %p (inet %p), "
+			"listen %d close %d\n",
+			svsk, svsk->sk_sk,
+			test_bit(XPT_LISTENER, &svsk->sk_xprt.xpt_flags),
+			test_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags));
 
 	return svsk;
 }
-- 
2.7.4

