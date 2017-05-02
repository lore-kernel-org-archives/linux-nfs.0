Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:33047 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750854AbdEBQiQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 2 May 2017 12:38:16 -0400
Received: by mail-it0-f66.google.com with SMTP id v135so3026109itv.0
        for <linux-nfs@vger.kernel.org>; Tue, 02 May 2017 09:38:16 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC PATCH 1/5] SUNRPC: Allow creation of RPC clients with multiple connections
Date: Tue,  2 May 2017 12:38:05 -0400
Message-Id: <20170502163812.6211-2-trond.myklebust@primarydata.com>
In-Reply-To: <20170502163812.6211-1-trond.myklebust@primarydata.com>
References: <20170502163812.6211-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add an argument to struct rpc_create_args that allows the specification
of how many transport connections you want to set up to the server.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 include/linux/sunrpc/clnt.h |  1 +
 net/sunrpc/clnt.c           | 17 ++++++++++++++++-
 net/sunrpc/xprtmultipath.c  |  3 +--
 3 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 6095ecba0dde..8c3cb38a385b 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -120,6 +120,7 @@ struct rpc_create_args {
 	u32			prognumber;	/* overrides program->number */
 	u32			version;
 	rpc_authflavor_t	authflavor;
+	u32			nconnect;
 	unsigned long		flags;
 	char			*client_name;
 	struct svc_xprt		*bc_xprt;	/* NFSv4.1 backchannel */
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 673046c64e48..0ff97288b43f 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -522,6 +522,8 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 		.bc_xprt = args->bc_xprt,
 	};
 	char servername[48];
+	struct rpc_clnt *clnt;
+	int i;
 
 	if (args->bc_xprt) {
 		WARN_ON_ONCE(!(args->protocol & XPRT_TRANSPORT_BC));
@@ -584,7 +586,15 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 	if (args->flags & RPC_CLNT_CREATE_NONPRIVPORT)
 		xprt->resvport = 0;
 
-	return rpc_create_xprt(args, xprt);
+	clnt = rpc_create_xprt(args, xprt);
+	if (IS_ERR(clnt) || args->nconnect <= 1)
+		return clnt;
+
+	for (i = 0; i < args->nconnect - 1; i++) {
+		if (rpc_clnt_add_xprt(clnt, &xprtargs, NULL, NULL) < 0)
+			break;
+	}
+	return clnt;
 }
 EXPORT_SYMBOL_GPL(rpc_create);
 
@@ -2605,6 +2615,10 @@ int rpc_clnt_test_and_add_xprt(struct rpc_clnt *clnt,
 		return -ENOMEM;
 	data->xps = xprt_switch_get(xps);
 	data->xprt = xprt_get(xprt);
+	if (rpc_xprt_switch_has_addr(data->xps, (struct sockaddr *)&xprt->addr)) {
+		rpc_cb_add_xprt_release(data);
+		goto success;
+	}
 
 	cred = authnull_ops.lookup_cred(NULL, NULL, 0);
 	task = rpc_call_null_helper(clnt, xprt, cred,
@@ -2614,6 +2628,7 @@ int rpc_clnt_test_and_add_xprt(struct rpc_clnt *clnt,
 	if (IS_ERR(task))
 		return PTR_ERR(task);
 	rpc_put_task(task);
+success:
 	return 1;
 }
 EXPORT_SYMBOL_GPL(rpc_clnt_test_and_add_xprt);
diff --git a/net/sunrpc/xprtmultipath.c b/net/sunrpc/xprtmultipath.c
index 95064d510ce6..486819d0c58b 100644
--- a/net/sunrpc/xprtmultipath.c
+++ b/net/sunrpc/xprtmultipath.c
@@ -51,8 +51,7 @@ void rpc_xprt_switch_add_xprt(struct rpc_xprt_switch *xps,
 	if (xprt == NULL)
 		return;
 	spin_lock(&xps->xps_lock);
-	if ((xps->xps_net == xprt->xprt_net || xps->xps_net == NULL) &&
-	    !rpc_xprt_switch_has_addr(xps, (struct sockaddr *)&xprt->addr))
+	if (xps->xps_net == xprt->xprt_net || xps->xps_net == NULL)
 		xprt_switch_add_xprt_locked(xps, xprt);
 	spin_unlock(&xps->xps_lock);
 }
-- 
2.9.3

