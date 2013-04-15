Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49904 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755161Ab3DOTfK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Apr 2013 15:35:10 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/5] SUNRPC: allow disabling idle timeout
Date: Mon, 15 Apr 2013 15:35:04 -0400
Message-Id: <1366054508-27604-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1366054508-27604-1-git-send-email-bfields@redhat.com>
References: <1366054508-27604-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

In the gss-proxy case we don't want to have to reconnect at random--we
want to connect only on gss-proxy startup when we can steal gss-proxy's
context to do the connect in the right namespace.

So, provide a flag that allows the rpc_create caller to turn off the
idle timeout.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 include/linux/sunrpc/clnt.h |    1 +
 include/linux/sunrpc/xprt.h |    1 +
 net/sunrpc/clnt.c           |    1 +
 net/sunrpc/xprt.c           |    2 ++
 4 files changed, 5 insertions(+)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 2cf4ffa..8164986 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -124,6 +124,7 @@ struct rpc_create_args {
 #define RPC_CLNT_CREATE_NOPING		(1UL << 4)
 #define RPC_CLNT_CREATE_DISCRTRY	(1UL << 5)
 #define RPC_CLNT_CREATE_QUIET		(1UL << 6)
+#define RPC_CLNT_CREATE_NO_IDLE_TIMEOUT	(1UL << 7)
 
 struct rpc_clnt *rpc_create(struct rpc_create_args *args);
 struct rpc_clnt	*rpc_bind_new_program(struct rpc_clnt *,
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 30834be..df28503 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -263,6 +263,7 @@ struct xprt_create {
 	size_t			addrlen;
 	const char		*servername;
 	struct svc_xprt		*bc_xprt;	/* NFSv4.1 backchannel */
+	unsigned long		flags;
 };
 
 struct xprt_class {
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index dcc446e..a41d64a 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -411,6 +411,7 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 		.addrlen = args->addrsize,
 		.servername = args->servername,
 		.bc_xprt = args->bc_xprt,
+		.flags = args->flags,
 	};
 	char servername[48];
 
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index b7478d5..37cbc37 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1245,6 +1245,8 @@ found:
 				-PTR_ERR(xprt));
 		goto out;
 	}
+	if (args->flags & RPC_CLNT_CREATE_NO_IDLE_TIMEOUT)
+		xprt->idle_timeout = 0;
 	INIT_WORK(&xprt->task_cleanup, xprt_autoclose);
 	if (xprt_has_timer(xprt))
 		setup_timer(&xprt->timer, xprt_init_autodisconnect,
-- 
1.7.9.5

