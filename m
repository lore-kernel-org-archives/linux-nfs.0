Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:33718 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751860AbdHAQAI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Aug 2017 12:00:08 -0400
Received: by mail-io0-f195.google.com with SMTP id q64so1860327ioi.0
        for <linux-nfs@vger.kernel.org>; Tue, 01 Aug 2017 09:00:07 -0700 (PDT)
Subject: [PATCH v1 3/4] sunrpc: Const-ify struct sv_serv_ops
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Tue, 01 Aug 2017 12:00:06 -0400
Message-ID: <20170801160006.14944.96469.stgit@klimt.1015granger.net>
In-Reply-To: <20170801155738.14944.10842.stgit@klimt.1015granger.net>
References: <20170801155738.14944.10842.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Close an attack vector by moving the arrays of per-server methods to
read-only memory.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/lockd/svc.c             |    2 +-
 fs/nfs/callback.c          |   10 +++++-----
 fs/nfsd/nfssvc.c           |    2 +-
 include/linux/sunrpc/svc.h |    6 +++---
 net/sunrpc/svc.c           |    6 +++---
 5 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 726b6ce..b995bdc 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -396,7 +396,7 @@ static int lockd_start_svc(struct svc_serv *serv)
 	return error;
 }
 
-static struct svc_serv_ops lockd_sv_ops = {
+static const struct svc_serv_ops lockd_sv_ops = {
 	.svo_shutdown		= svc_rpcb_cleanup,
 	.svo_enqueue_xprt	= svc_xprt_do_enqueue,
 };
diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 3432387..2cddf7f 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -226,26 +226,26 @@ static int nfs_callback_up_net(int minorversion, struct svc_serv *serv,
 	return ret;
 }
 
-static struct svc_serv_ops nfs40_cb_sv_ops = {
+static const struct svc_serv_ops nfs40_cb_sv_ops = {
 	.svo_function		= nfs4_callback_svc,
 	.svo_enqueue_xprt	= svc_xprt_do_enqueue,
 	.svo_setup		= svc_set_num_threads_sync,
 	.svo_module		= THIS_MODULE,
 };
 #if defined(CONFIG_NFS_V4_1)
-static struct svc_serv_ops nfs41_cb_sv_ops = {
+static const struct svc_serv_ops nfs41_cb_sv_ops = {
 	.svo_function		= nfs41_callback_svc,
 	.svo_enqueue_xprt	= svc_xprt_do_enqueue,
 	.svo_setup		= svc_set_num_threads_sync,
 	.svo_module		= THIS_MODULE,
 };
 
-static struct svc_serv_ops *nfs4_cb_sv_ops[] = {
+static const struct svc_serv_ops *nfs4_cb_sv_ops[] = {
 	[0] = &nfs40_cb_sv_ops,
 	[1] = &nfs41_cb_sv_ops,
 };
 #else
-static struct svc_serv_ops *nfs4_cb_sv_ops[] = {
+static const struct svc_serv_ops *nfs4_cb_sv_ops[] = {
 	[0] = &nfs40_cb_sv_ops,
 	[1] = NULL,
 };
@@ -254,8 +254,8 @@ static int nfs_callback_up_net(int minorversion, struct svc_serv *serv,
 static struct svc_serv *nfs_callback_create_svc(int minorversion)
 {
 	struct nfs_callback_data *cb_info = &nfs_callback_info[minorversion];
+	const struct svc_serv_ops *sv_ops;
 	struct svc_serv *serv;
-	struct svc_serv_ops *sv_ops;
 
 	/*
 	 * Check whether we're already up and running.
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 063ae7d..7e3af3e 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -475,7 +475,7 @@ static int nfsd_get_default_max_blksize(void)
 	return ret;
 }
 
-static struct svc_serv_ops nfsd_thread_sv_ops = {
+static const struct svc_serv_ops nfsd_thread_sv_ops = {
 	.svo_shutdown		= nfsd_last_thread,
 	.svo_function		= nfsd,
 	.svo_enqueue_xprt	= svc_xprt_do_enqueue,
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index a3f8af9..38f561b 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -99,7 +99,7 @@ struct svc_serv {
 
 	unsigned int		sv_nrpools;	/* number of thread pools */
 	struct svc_pool *	sv_pools;	/* array of thread pools */
-	struct svc_serv_ops	*sv_ops;	/* server operations */
+	const struct svc_serv_ops *sv_ops;	/* server operations */
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
 	struct list_head	sv_cb_list;	/* queue for callback requests
 						 * that arrive over the same
@@ -465,7 +465,7 @@ struct svc_pool_map {
 void svc_rpcb_cleanup(struct svc_serv *serv, struct net *net);
 int svc_bind(struct svc_serv *serv, struct net *net);
 struct svc_serv *svc_create(struct svc_program *, unsigned int,
-			    struct svc_serv_ops *);
+			    const struct svc_serv_ops *);
 struct svc_rqst *svc_rqst_alloc(struct svc_serv *serv,
 					struct svc_pool *pool, int node);
 struct svc_rqst *svc_prepare_thread(struct svc_serv *serv,
@@ -475,7 +475,7 @@ struct svc_rqst *svc_prepare_thread(struct svc_serv *serv,
 unsigned int	   svc_pool_map_get(void);
 void		   svc_pool_map_put(void);
 struct svc_serv *  svc_create_pooled(struct svc_program *, unsigned int,
-			struct svc_serv_ops *);
+			const struct svc_serv_ops *);
 int		   svc_set_num_threads(struct svc_serv *, struct svc_pool *, int);
 int		   svc_set_num_threads_sync(struct svc_serv *, struct svc_pool *, int);
 int		   svc_pool_stats_open(struct svc_serv *serv, struct file *file);
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 85ce0db..aa04666 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -421,7 +421,7 @@ int svc_bind(struct svc_serv *serv, struct net *net)
  */
 static struct svc_serv *
 __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
-	     struct svc_serv_ops *ops)
+	     const struct svc_serv_ops *ops)
 {
 	struct svc_serv	*serv;
 	unsigned int vers;
@@ -486,7 +486,7 @@ int svc_bind(struct svc_serv *serv, struct net *net)
 
 struct svc_serv *
 svc_create(struct svc_program *prog, unsigned int bufsize,
-	   struct svc_serv_ops *ops)
+	   const struct svc_serv_ops *ops)
 {
 	return __svc_create(prog, bufsize, /*npools*/1, ops);
 }
@@ -494,7 +494,7 @@ struct svc_serv *
 
 struct svc_serv *
 svc_create_pooled(struct svc_program *prog, unsigned int bufsize,
-		  struct svc_serv_ops *ops)
+		  const struct svc_serv_ops *ops)
 {
 	struct svc_serv *serv;
 	unsigned int npools = svc_pool_map_get();

