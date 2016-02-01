Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:37891 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933001AbcBAPXO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Feb 2016 10:23:14 -0500
Received: by mail-ig0-f177.google.com with SMTP id mw1so35266430igb.1
        for <linux-nfs@vger.kernel.org>; Mon, 01 Feb 2016 07:23:14 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC PATCH v2 04/13] SUNRPC: Make freeing of struct xprt rcu-safe
Date: Mon,  1 Feb 2016 10:22:26 -0500
Message-Id: <1454340155-7670-5-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1454340155-7670-4-git-send-email-trond.myklebust@primarydata.com>
References: <1454340155-7670-1-git-send-email-trond.myklebust@primarydata.com>
 <1454340155-7670-2-git-send-email-trond.myklebust@primarydata.com>
 <1454340155-7670-3-git-send-email-trond.myklebust@primarydata.com>
 <1454340155-7670-4-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Have it call kfree_rcu() to ensure that we can use it on rcu-protected
lists.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 include/linux/sunrpc/xprt.h | 1 +
 net/sunrpc/xprt.c           | 3 ++-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 1bdb59a2efe8..83218129ff28 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -257,6 +257,7 @@ struct rpc_xprt {
 	struct dentry		*debugfs;		/* debugfs directory */
 	atomic_t		inject_disconnect;
 #endif
+	struct rcu_head		rcu;
 };
 
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index d8fd84c0cbba..605858699f6c 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -48,6 +48,7 @@
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/metrics.h>
 #include <linux/sunrpc/bc_xprt.h>
+#include <linux/rcupdate.h>
 
 #include <trace/events/sunrpc.h>
 
@@ -1166,7 +1167,7 @@ void xprt_free(struct rpc_xprt *xprt)
 {
 	put_net(xprt->xprt_net);
 	xprt_free_all_slots(xprt);
-	kfree(xprt);
+	kfree_rcu(xprt, rcu);
 }
 EXPORT_SYMBOL_GPL(xprt_free);
 
-- 
2.5.0

