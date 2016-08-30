Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:34452 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755526AbcH3AEi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Aug 2016 20:04:38 -0400
Received: by mail-it0-f68.google.com with SMTP id e63so635106ith.1
        for <linux-nfs@vger.kernel.org>; Mon, 29 Aug 2016 17:04:38 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/6] SUNRPC: Initialise struct svc_serv backchannel fields during __svc_create()
Date: Mon, 29 Aug 2016 20:03:49 -0400
Message-Id: <1472515432-54202-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1472515432-54202-3-git-send-email-trond.myklebust@primarydata.com>
References: <1472515432-54202-1-git-send-email-trond.myklebust@primarydata.com>
 <1472515432-54202-2-git-send-email-trond.myklebust@primarydata.com>
 <1472515432-54202-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/callback.c |  3 ---
 net/sunrpc/svc.c  | 17 +++++++++++++++++
 2 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 478bb0a7effe..08e16f9b3333 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -147,9 +147,6 @@ nfs41_callback_up(struct svc_serv *serv)
 {
 	struct svc_rqst *rqstp;
 
-	INIT_LIST_HEAD(&serv->sv_cb_list);
-	spin_lock_init(&serv->sv_cb_lock);
-	init_waitqueue_head(&serv->sv_cb_waitq);
 	rqstp = svc_prepare_thread(serv, &serv->sv_pools[0], NUMA_NO_NODE);
 	dprintk("--> %s return %d\n", __func__, PTR_ERR_OR_ZERO(rqstp));
 	return rqstp;
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index c5b0cb4f4056..7c8070ec93c8 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -401,6 +401,21 @@ int svc_bind(struct svc_serv *serv, struct net *net)
 }
 EXPORT_SYMBOL_GPL(svc_bind);
 
+#if defined(CONFIG_SUNRPC_BACKCHANNEL)
+static void
+__svc_init_bc(struct svc_serv *serv)
+{
+	INIT_LIST_HEAD(&serv->sv_cb_list);
+	spin_lock_init(&serv->sv_cb_lock);
+	init_waitqueue_head(&serv->sv_cb_waitq);
+}
+#else
+static void
+__svc_init_bc(struct svc_serv *serv)
+{
+}
+#endif
+
 /*
  * Create an RPC service
  */
@@ -443,6 +458,8 @@ __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
 	init_timer(&serv->sv_temptimer);
 	spin_lock_init(&serv->sv_lock);
 
+	__svc_init_bc(serv);
+
 	serv->sv_nrpools = npools;
 	serv->sv_pools =
 		kcalloc(serv->sv_nrpools, sizeof(struct svc_pool),
-- 
2.7.4

