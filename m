Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:33981 "EHLO
	mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754073AbcBARWM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Feb 2016 12:22:12 -0500
Received: by mail-io0-f175.google.com with SMTP id 9so86117844iom.1
        for <linux-nfs@vger.kernel.org>; Mon, 01 Feb 2016 09:22:11 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC PATCH v3 10/13] SUNRPC: Make NFS swap work with multipath
Date: Mon,  1 Feb 2016 12:21:14 -0500
Message-Id: <1454347277-10997-11-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1454347277-10997-10-git-send-email-trond.myklebust@primarydata.com>
References: <1454347277-10997-1-git-send-email-trond.myklebust@primarydata.com>
 <1454347277-10997-2-git-send-email-trond.myklebust@primarydata.com>
 <1454347277-10997-3-git-send-email-trond.myklebust@primarydata.com>
 <1454347277-10997-4-git-send-email-trond.myklebust@primarydata.com>
 <1454347277-10997-5-git-send-email-trond.myklebust@primarydata.com>
 <1454347277-10997-6-git-send-email-trond.myklebust@primarydata.com>
 <1454347277-10997-7-git-send-email-trond.myklebust@primarydata.com>
 <1454347277-10997-8-git-send-email-trond.myklebust@primarydata.com>
 <1454347277-10997-9-git-send-email-trond.myklebust@primarydata.com>
 <1454347277-10997-10-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/clnt.c | 66 ++++++++++++++++++++-----------------------------------
 1 file changed, 24 insertions(+), 42 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 7b4d9044cbbd..e19cac509cec 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2552,57 +2552,39 @@ void rpc_show_tasks(struct net *net)
 #endif
 
 #if IS_ENABLED(CONFIG_SUNRPC_SWAP)
+static int
+rpc_clnt_swap_activate_callback(struct rpc_clnt *clnt,
+		struct rpc_xprt *xprt,
+		void *dummy)
+{
+	return xprt_enable_swap(xprt);
+}
+
 int
 rpc_clnt_swap_activate(struct rpc_clnt *clnt)
 {
-	int ret = 0;
-	struct rpc_xprt	*xprt;
-
-	if (atomic_inc_return(&clnt->cl_swapper) == 1) {
-retry:
-		rcu_read_lock();
-		xprt = xprt_get(rcu_dereference(clnt->cl_xprt));
-		rcu_read_unlock();
-		if (!xprt) {
-			/*
-			 * If we didn't get a reference, then we likely are
-			 * racing with a migration event. Wait for a grace
-			 * period and try again.
-			 */
-			synchronize_rcu();
-			goto retry;
-		}
-
-		ret = xprt_enable_swap(xprt);
-		xprt_put(xprt);
-	}
-	return ret;
+	if (atomic_inc_return(&clnt->cl_swapper) == 1)
+		return rpc_clnt_iterate_for_each_xprt(clnt,
+				rpc_clnt_swap_activate_callback, NULL);
+	return 0;
 }
 EXPORT_SYMBOL_GPL(rpc_clnt_swap_activate);
 
+static int
+rpc_clnt_swap_deactivate_callback(struct rpc_clnt *clnt,
+		struct rpc_xprt *xprt,
+		void *dummy)
+{
+	xprt_disable_swap(xprt);
+	return 0;
+}
+
 void
 rpc_clnt_swap_deactivate(struct rpc_clnt *clnt)
 {
-	struct rpc_xprt	*xprt;
-
-	if (atomic_dec_if_positive(&clnt->cl_swapper) == 0) {
-retry:
-		rcu_read_lock();
-		xprt = xprt_get(rcu_dereference(clnt->cl_xprt));
-		rcu_read_unlock();
-		if (!xprt) {
-			/*
-			 * If we didn't get a reference, then we likely are
-			 * racing with a migration event. Wait for a grace
-			 * period and try again.
-			 */
-			synchronize_rcu();
-			goto retry;
-		}
-
-		xprt_disable_swap(xprt);
-		xprt_put(xprt);
-	}
+	if (atomic_dec_if_positive(&clnt->cl_swapper) == 0)
+		rpc_clnt_iterate_for_each_xprt(clnt,
+				rpc_clnt_swap_deactivate_callback, NULL);
 }
 EXPORT_SYMBOL_GPL(rpc_clnt_swap_deactivate);
 #endif /* CONFIG_SUNRPC_SWAP */
-- 
2.5.0

