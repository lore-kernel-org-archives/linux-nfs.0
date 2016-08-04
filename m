Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35147 "EHLO
	mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933543AbcHDNBu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Aug 2016 09:01:50 -0400
Received: by mail-it0-f66.google.com with SMTP id f6so19589352ith.2
        for <linux-nfs@vger.kernel.org>; Thu, 04 Aug 2016 06:01:50 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] SUNRPC: Limit the reconnect backoff timer to the max RPC message timeout
Date: Thu,  4 Aug 2016 09:01:00 -0400
Message-Id: <1470315660-37206-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1470315660-37206-1-git-send-email-trond.myklebust@primarydata.com>
References: <1470315660-37206-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprtsock.c | 17 ++++++++++++-----
 1 file changed, 12 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 5eebf48cffa0..b828695cc647 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2385,6 +2385,17 @@ static unsigned long xs_reconnect_delay(const struct rpc_xprt *xprt)
 	return 0;
 }
 
+static void xs_reconnect_backoff(struct rpc_xprt *xprt)
+{
+	xprt->reestablish_timeout <<= 1;
+	if (xprt->reestablish_timeout > xprt->timeout->to_maxval)
+		xprt->reestablish_timeout = xprt->timeout->to_maxval;
+	if (xprt->reestablish_timeout > XS_TCP_MAX_REEST_TO)
+		xprt->reestablish_timeout = XS_TCP_MAX_REEST_TO;
+	if (xprt->reestablish_timeout < XS_TCP_INIT_REEST_TO)
+		xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
+}
+
 /**
  * xs_connect - connect a socket to a remote endpoint
  * @xprt: pointer to transport structure
@@ -2415,12 +2426,8 @@ static void xs_connect(struct rpc_xprt *xprt, struct rpc_task *task)
 		xs_reset_transport(transport);
 
 		delay = xs_reconnect_delay(xprt);
+		xs_reconnect_backoff(xprt);
 
-		xprt->reestablish_timeout <<= 1;
-		if (xprt->reestablish_timeout < XS_TCP_INIT_REEST_TO)
-			xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
-		if (xprt->reestablish_timeout > XS_TCP_MAX_REEST_TO)
-			xprt->reestablish_timeout = XS_TCP_MAX_REEST_TO;
 	} else
 		dprintk("RPC:       xs_connect scheduled xprt %p\n", xprt);
 
-- 
2.7.4

