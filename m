Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:34937 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757154AbcH3AEk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Aug 2016 20:04:40 -0400
Received: by mail-it0-f68.google.com with SMTP id f128so631313ith.2
        for <linux-nfs@vger.kernel.org>; Mon, 29 Aug 2016 17:04:40 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 5/6] NFSv4.x: Switch to using svc_set_num_threads() to manage the callback threads
Date: Mon, 29 Aug 2016 20:03:51 -0400
Message-Id: <1472515432-54202-6-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1472515432-54202-5-git-send-email-trond.myklebust@primarydata.com>
References: <1472515432-54202-1-git-send-email-trond.myklebust@primarydata.com>
 <1472515432-54202-2-git-send-email-trond.myklebust@primarydata.com>
 <1472515432-54202-3-git-send-email-trond.myklebust@primarydata.com>
 <1472515432-54202-4-git-send-email-trond.myklebust@primarydata.com>
 <1472515432-54202-5-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This will allow us to bump the number of callback threads at will.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/callback.c | 79 +++++++++----------------------------------------------
 fs/nfs/callback.h |  2 ++
 2 files changed, 15 insertions(+), 66 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index b125f02ddf8b..b91c49f4670b 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -31,8 +31,6 @@
 struct nfs_callback_data {
 	unsigned int users;
 	struct svc_serv *serv;
-	struct svc_rqst *rqst;
-	struct task_struct *task;
 };
 
 static struct nfs_callback_data nfs_callback_info[NFS4_MAX_MINOR_VERSION + 1];
@@ -89,15 +87,6 @@ nfs4_callback_svc(void *vrqstp)
 	return 0;
 }
 
-/*
- * Prepare to bring up the NFSv4 callback service
- */
-static struct svc_rqst *
-nfs4_callback_up(struct svc_serv *serv)
-{
-	return svc_prepare_thread(serv, &serv->sv_pools[0], NUMA_NO_NODE);
-}
-
 #if defined(CONFIG_NFS_V4_1)
 /*
  * The callback service for NFSv4.1 callbacks
@@ -139,19 +128,6 @@ nfs41_callback_svc(void *vrqstp)
 	return 0;
 }
 
-/*
- * Bring up the NFSv4.1 callback service
- */
-static struct svc_rqst *
-nfs41_callback_up(struct svc_serv *serv)
-{
-	struct svc_rqst *rqstp;
-
-	rqstp = svc_prepare_thread(serv, &serv->sv_pools[0], NUMA_NO_NODE);
-	dprintk("--> %s return %d\n", __func__, PTR_ERR_OR_ZERO(rqstp));
-	return rqstp;
-}
-
 static inline void nfs_callback_bc_serv(u32 minorversion, struct rpc_xprt *xprt,
 		struct svc_serv *serv)
 {
@@ -163,12 +139,6 @@ static inline void nfs_callback_bc_serv(u32 minorversion, struct rpc_xprt *xprt,
 		xprt->bc_serv = serv;
 }
 #else
-static struct svc_rqst *
-nfs41_callback_up(struct svc_serv *serv)
-{
-	return ERR_PTR(-ENOTSUPP);
-}
-
 static inline void nfs_callback_bc_serv(u32 minorversion, struct rpc_xprt *xprt,
 		struct svc_serv *serv)
 {
@@ -178,42 +148,19 @@ static inline void nfs_callback_bc_serv(u32 minorversion, struct rpc_xprt *xprt,
 static int nfs_callback_start_svc(int minorversion, struct rpc_xprt *xprt,
 				  struct svc_serv *serv)
 {
-	struct svc_rqst *rqstp;
-	struct nfs_callback_data *cb_info = &nfs_callback_info[minorversion];
+	const int nrservs = NFS4_NR_CALLBACK_THREADS;
 	int ret;
 
 	nfs_callback_bc_serv(minorversion, xprt, serv);
 
-	if (cb_info->task)
+	if (serv->sv_nrthreads-1 == nrservs)
 		return 0;
 
-	switch (minorversion) {
-	case 0:
-		/* v4.0 callback setup */
-		rqstp = nfs4_callback_up(serv);
-		break;
-	default:
-		rqstp = nfs41_callback_up(serv);
-	}
-
-	if (IS_ERR(rqstp))
-		return PTR_ERR(rqstp);
-
-	svc_sock_update_bufs(serv);
-
-	cb_info->rqst = rqstp;
-	cb_info->task = kthread_create(serv->sv_ops->svo_function,
-				    cb_info->rqst,
-				    "nfsv4.%u-svc", minorversion);
-	if (IS_ERR(cb_info->task)) {
-		ret = PTR_ERR(cb_info->task);
-		svc_exit_thread(cb_info->rqst);
-		cb_info->rqst = NULL;
-		cb_info->task = NULL;
+	ret = serv->sv_ops->svo_setup(serv, NULL, nrservs);
+	if (ret) {
+		serv->sv_ops->svo_setup(serv, NULL, 0);
 		return ret;
 	}
-	rqstp->rq_task = cb_info->task;
-	wake_up_process(cb_info->task);
 	dprintk("nfs_callback_up: service started\n");
 	return 0;
 }
@@ -270,12 +217,14 @@ err_bind:
 static struct svc_serv_ops nfs40_cb_sv_ops = {
 	.svo_function		= nfs4_callback_svc,
 	.svo_enqueue_xprt	= svc_xprt_do_enqueue,
+	.svo_setup		= svc_set_num_threads,
 	.svo_module		= THIS_MODULE,
 };
 #if defined(CONFIG_NFS_V4_1)
 static struct svc_serv_ops nfs41_cb_sv_ops = {
 	.svo_function		= nfs41_callback_svc,
 	.svo_enqueue_xprt	= svc_xprt_do_enqueue,
+	.svo_setup		= svc_set_num_threads,
 	.svo_module		= THIS_MODULE,
 };
 
@@ -394,20 +343,18 @@ err_start:
 void nfs_callback_down(int minorversion, struct net *net)
 {
 	struct nfs_callback_data *cb_info = &nfs_callback_info[minorversion];
+	struct svc_serv *serv;
 
 	mutex_lock(&nfs_callback_mutex);
-	nfs_callback_down_net(minorversion, cb_info->serv, net);
+	serv = cb_info->serv;
+	nfs_callback_down_net(minorversion, serv, net);
 	cb_info->users--;
 	if (cb_info->users == 0) {
-		if (cb_info->task != NULL) {
-			kthread_stop(cb_info->task);
-			dprintk("nfs_callback_down: service stopped\n");
-		}
-		svc_exit_thread(cb_info->rqst);
+		svc_get(serv);
+		serv->sv_ops->svo_setup(serv, NULL, 0);
+		svc_destroy(serv);
 		dprintk("nfs_callback_down: service destroyed\n");
 		cb_info->serv = NULL;
-		cb_info->rqst = NULL;
-		cb_info->task = NULL;
 	}
 	mutex_unlock(&nfs_callback_mutex);
 }
diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index 5fe1cecbf9f0..14bd863495db 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -198,6 +198,8 @@ extern void nfs_callback_down(int minorversion, struct net *net);
 #define NFS41_BC_MIN_CALLBACKS 1
 #define NFS41_BC_MAX_CALLBACKS 1
 
+#define NFS4_NR_CALLBACK_THREADS 1
+
 extern unsigned int nfs_callback_set_tcpport;
 
 #endif /* __LINUX_FS_NFS_CALLBACK_H */
-- 
2.7.4

