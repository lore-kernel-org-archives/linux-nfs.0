Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59256 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751545AbcEXVQU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 May 2016 17:16:20 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>
Cc: linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/3] rpc: share one xps between all backchannels
Date: Tue, 24 May 2016 17:16:16 -0400
Message-Id: <1464124576-27467-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1464124576-27467-1-git-send-email-bfields@redhat.com>
References: <1464124576-27467-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

The spec allows backchannels for multiple clients to share the same tcp
connection.  When that happens, we need to use the same xprt for all of
them.  Similarly, we need the same xps.

This fixes list corruption introduced by the multipath code.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 include/linux/sunrpc/svc_xprt.h |  1 +
 include/linux/sunrpc/xprt.h     |  1 +
 net/sunrpc/clnt.c               | 18 ++++++++++++++----
 net/sunrpc/svc_xprt.c           |  2 ++
 net/sunrpc/xprtsock.c           |  1 +
 5 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index b7dabc4baafd..79ba50856707 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -84,6 +84,7 @@ struct svc_xprt {
 
 	struct net		*xpt_net;
 	struct rpc_xprt		*xpt_bc_xprt;	/* NFSv4.1 backchannel */
+	struct rpc_xprt_switch	*xpt_bc_xps;	/* NFSv4.1 backchannel */
 };
 
 static inline void unregister_xpt_user(struct svc_xprt *xpt, struct svc_xpt_user *u)
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index fb0d212e0d3a..9f51e1df3023 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -296,6 +296,7 @@ struct xprt_create {
 	size_t			addrlen;
 	const char		*servername;
 	struct svc_xprt		*bc_xprt;	/* NFSv4.1 backchannel */
+	struct rpc_xprt_switch	*bc_xps;
 	unsigned int		flags;
 };
 
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index ad3f5ebec2d1..837dd910a252 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -452,10 +452,20 @@ static struct rpc_clnt *rpc_create_xprt(struct rpc_create_args *args,
 	struct rpc_clnt *clnt = NULL;
 	struct rpc_xprt_switch *xps;
 
-	xps = xprt_switch_alloc(xprt, GFP_KERNEL);
-	if (xps == NULL) {
-		xprt_put(xprt);
-		return ERR_PTR(-ENOMEM);
+	if (args->bc_xprt && args->bc_xprt->xpt_bc_xps) {
+		WARN_ON(args->protocol != XPRT_TRANSPORT_BC_TCP);
+		xps = args->bc_xprt->xpt_bc_xps;
+		xprt_switch_get(xps);
+	} else {
+		xps = xprt_switch_alloc(xprt, GFP_KERNEL);
+		if (xps == NULL) {
+			xprt_put(xprt);
+			return ERR_PTR(-ENOMEM);
+		}
+		if (xprt->bc_xprt) {
+			xprt_switch_get(xps);
+			xprt->bc_xprt->xpt_bc_xps = xps;
+		}
 	}
 	clnt = rpc_new_client(args, xps, xprt, NULL);
 	if (IS_ERR(clnt))
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index f5572e31d518..4f01f63102ee 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -136,6 +136,8 @@ static void svc_xprt_free(struct kref *kref)
 	/* See comment on corresponding get in xs_setup_bc_tcp(): */
 	if (xprt->xpt_bc_xprt)
 		xprt_put(xprt->xpt_bc_xprt);
+	if (xprt->xpt_bc_xps)
+		xprt_switch_put(xprt->xpt_bc_xps);
 	xprt->xpt_ops->xpo_free(xprt);
 	module_put(owner);
 }
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 65e759569e48..e9e5dd0dc8f4 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -3050,6 +3050,7 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
 		return xprt;
 
 	args->bc_xprt->xpt_bc_xprt = NULL;
+	args->bc_xprt->xpt_bc_xps = NULL;
 	xprt_put(xprt);
 	ret = ERR_PTR(-EINVAL);
 out_err:
-- 
2.5.5

