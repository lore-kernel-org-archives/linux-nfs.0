Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35860 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757097AbcH3AEi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Aug 2016 20:04:38 -0400
Received: by mail-it0-f65.google.com with SMTP id x131so619544ite.3
        for <linux-nfs@vger.kernel.org>; Mon, 29 Aug 2016 17:04:37 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/6] NFSv4.x: Set up struct svc_serv_ops for the callback channel
Date: Mon, 29 Aug 2016 20:03:48 -0400
Message-Id: <1472515432-54202-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1472515432-54202-2-git-send-email-trond.myklebust@primarydata.com>
References: <1472515432-54202-1-git-send-email-trond.myklebust@primarydata.com>
 <1472515432-54202-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In order to manage the threads using svc_set_num_threads, we need to
fill in a few extra fields.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/callback.c | 57 +++++++++++++++++++++++++++++++++++++------------------
 1 file changed, 39 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 52a28311e2a4..478bb0a7effe 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -155,13 +155,6 @@ nfs41_callback_up(struct svc_serv *serv)
 	return rqstp;
 }
 
-static void nfs_minorversion_callback_svc_setup(struct svc_serv *serv,
-		struct svc_rqst **rqstpp, int (**callback_svc)(void *vrqstp))
-{
-	*rqstpp = nfs41_callback_up(serv);
-	*callback_svc = nfs41_callback_svc;
-}
-
 static inline void nfs_callback_bc_serv(u32 minorversion, struct rpc_xprt *xprt,
 		struct svc_serv *serv)
 {
@@ -173,11 +166,10 @@ static inline void nfs_callback_bc_serv(u32 minorversion, struct rpc_xprt *xprt,
 		xprt->bc_serv = serv;
 }
 #else
-static void nfs_minorversion_callback_svc_setup(struct svc_serv *serv,
-		struct svc_rqst **rqstpp, int (**callback_svc)(void *vrqstp))
+static struct svc_rqst *
+nfs41_callback_up(struct svc_serv *serv)
 {
-	*rqstpp = ERR_PTR(-ENOTSUPP);
-	*callback_svc = ERR_PTR(-ENOTSUPP);
+	return ERR_PTR(-ENOTSUPP);
 }
 
 static inline void nfs_callback_bc_serv(u32 minorversion, struct rpc_xprt *xprt,
@@ -190,7 +182,6 @@ static int nfs_callback_start_svc(int minorversion, struct rpc_xprt *xprt,
 				  struct svc_serv *serv)
 {
 	struct svc_rqst *rqstp;
-	int (*callback_svc)(void *vrqstp);
 	struct nfs_callback_data *cb_info = &nfs_callback_info[minorversion];
 	int ret;
 
@@ -203,11 +194,9 @@ static int nfs_callback_start_svc(int minorversion, struct rpc_xprt *xprt,
 	case 0:
 		/* v4.0 callback setup */
 		rqstp = nfs4_callback_up(serv);
-		callback_svc = nfs4_callback_svc;
 		break;
 	default:
-		nfs_minorversion_callback_svc_setup(serv,
-				&rqstp, &callback_svc);
+		rqstp = nfs41_callback_up(serv);
 	}
 
 	if (IS_ERR(rqstp))
@@ -217,7 +206,8 @@ static int nfs_callback_start_svc(int minorversion, struct rpc_xprt *xprt,
 
 	cb_info->serv = serv;
 	cb_info->rqst = rqstp;
-	cb_info->task = kthread_create(callback_svc, cb_info->rqst,
+	cb_info->task = kthread_create(serv->sv_ops->svo_function,
+				    cb_info->rqst,
 				    "nfsv4.%u-svc", minorversion);
 	if (IS_ERR(cb_info->task)) {
 		ret = PTR_ERR(cb_info->task);
@@ -281,14 +271,34 @@ err_bind:
 	return ret;
 }
 
-static struct svc_serv_ops nfs_cb_sv_ops = {
+static struct svc_serv_ops nfs40_cb_sv_ops = {
+	.svo_function		= nfs4_callback_svc,
 	.svo_enqueue_xprt	= svc_xprt_do_enqueue,
+	.svo_module		= THIS_MODULE,
+};
+#if defined(CONFIG_NFS_V4_1)
+static struct svc_serv_ops nfs41_cb_sv_ops = {
+	.svo_function		= nfs41_callback_svc,
+	.svo_enqueue_xprt	= svc_xprt_do_enqueue,
+	.svo_module		= THIS_MODULE,
 };
 
+struct svc_serv_ops *nfs4_cb_sv_ops[] = {
+	[0] = &nfs40_cb_sv_ops,
+	[1] = &nfs41_cb_sv_ops,
+};
+#else
+struct svc_serv_ops *nfs4_cb_sv_ops[] = {
+	[0] = &nfs40_cb_sv_ops,
+	[1] = NULL,
+};
+#endif
+
 static struct svc_serv *nfs_callback_create_svc(int minorversion)
 {
 	struct nfs_callback_data *cb_info = &nfs_callback_info[minorversion];
 	struct svc_serv *serv;
+	struct svc_serv_ops *sv_ops;
 
 	/*
 	 * Check whether we're already up and running.
@@ -302,6 +312,17 @@ static struct svc_serv *nfs_callback_create_svc(int minorversion)
 		return cb_info->serv;
 	}
 
+	switch (minorversion) {
+	case 0:
+		sv_ops = nfs4_cb_sv_ops[0];
+		break;
+	default:
+		sv_ops = nfs4_cb_sv_ops[1];
+	}
+
+	if (sv_ops == NULL)
+		return ERR_PTR(-ENOTSUPP);
+
 	/*
 	 * Sanity check: if there's no task,
 	 * we should be the first user ...
@@ -310,7 +331,7 @@ static struct svc_serv *nfs_callback_create_svc(int minorversion)
 		printk(KERN_WARNING "nfs_callback_create_svc: no kthread, %d users??\n",
 			cb_info->users);
 
-	serv = svc_create(&nfs4_callback_program, NFS4_CALLBACK_BUFSIZE, &nfs_cb_sv_ops);
+	serv = svc_create(&nfs4_callback_program, NFS4_CALLBACK_BUFSIZE, sv_ops);
 	if (!serv) {
 		printk(KERN_ERR "nfs_callback_create_svc: create service failed\n");
 		return ERR_PTR(-ENOMEM);
-- 
2.7.4

