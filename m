Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34326 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755019Ab3BUQi2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Feb 2013 11:38:28 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Trond.Myklebust@netapp.com, chuck.lever@oracle.com, simo@redhat.com,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/6] SUNRPC: no idle timeout for AF_LOCAL sockets
Date: Thu, 21 Feb 2013 11:38:22 -0500
Message-Id: <1361464705-12340-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1361464705-12340-1-git-send-email-bfields@redhat.com>
References: <1361464705-12340-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

In the gss-proxy case I don't want to have to reconnect at random--I
want to connect only on gss-proxy startup when I can steal gss-proxy's
context to do the connect in the right namespace.

And surely an AF_LOCAL socket isn't a ton of state to keep around--how
about we just turn off the idle timeout for AF_LOCAL sockets.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/xprtsock.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index f2cf652..a32227e 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2635,7 +2635,7 @@ static struct rpc_xprt *xs_setup_local(struct xprt_create *args)
 
 	xprt->bind_timeout = XS_BIND_TO;
 	xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
-	xprt->idle_timeout = XS_IDLE_DISC_TO;
+	xprt->idle_timeout = 0;
 
 	xprt->ops = &xs_local_ops;
 	xprt->timeout = &xs_local_default_timeout;
-- 
1.7.9.5

