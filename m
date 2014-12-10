Return-Path: linux-kernel-owner@vger.kernel.org
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Tejun Heo <tj@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>,
        NeilBrown <neilb@suse.de>
Subject: [PATCH v2 12/16] nfsd: add support for workqueue based service processing
Date: Wed, 10 Dec 2014 14:07:56 -0500
Message-Id: <1418238480-18857-13-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1418238480-18857-1-git-send-email-jlayton@primarydata.com>
References: <1418238480-18857-1-git-send-email-jlayton@primarydata.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow nfsd to create a workqueue based nfsd service if the sunrpc
pool_mode is set to "workqueue".

The first iteration here is fairly simple. The xprt work simply
allocates a svc_rqst object, and then queues that work.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/fs_struct.c            |  3 ++-
 fs/nfsd/nfssvc.c          | 69 +++++++++++++++++++++++++++++++++++++++++++++--
 include/linux/fs_struct.h |  1 +
 3 files changed, 70 insertions(+), 3 deletions(-)

diff --git a/fs/fs_struct.c b/fs/fs_struct.c
index 9bc08ea2f433..68985c76cd75 100644
--- a/fs/fs_struct.c
+++ b/fs/fs_struct.c
@@ -130,7 +130,7 @@ struct fs_struct *copy_fs_struct(struct fs_struct *old)
 EXPORT_SYMBOL_GPL(copy_fs_struct);
 
 /* Replace current fs struct with one given. Return a pointer to old one. */
-static struct fs_struct *
+struct fs_struct *
 swap_fs_struct(struct fs_struct *new_fs)
 {
 	struct fs_struct *old_fs;
@@ -142,6 +142,7 @@ swap_fs_struct(struct fs_struct *new_fs)
 
 	return old_fs;
 }
+EXPORT_SYMBOL_GPL(swap_fs_struct);
 
 /* Put a reference to a fs_struct. */
 void put_fs_struct(struct fs_struct *fs)
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index f37bd7db2176..7e22068bdad4 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -28,6 +28,8 @@
 extern struct svc_program	nfsd_program;
 static int			nfsd(void *vrqstp);
 
+static struct svc_serv_ops	nfsd_wq_sv_ops;
+
 /*
  * nfsd_mutex protects nn->nfsd_serv -- both the pointer itself and the members
  * of the svc_serv struct. In particular, ->sv_nrthreads but also to some
@@ -398,10 +400,19 @@ static struct svc_serv_ops nfsd_thread_sv_ops = {
 	.svo_module		= THIS_MODULE,
 };
 
+static struct svc_serv_ops *
+select_svc_serv_ops(void)
+{
+	if (svc_pool_map.mode == SVC_POOL_WORKQUEUE)
+		return &nfsd_wq_sv_ops;
+	return &nfsd_thread_sv_ops;
+}
+
 int nfsd_create_serv(struct net *net)
 {
 	int error;
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+	struct svc_serv_ops *ops;
 
 	WARN_ON(!mutex_is_locked(&nfsd_mutex));
 	if (nn->nfsd_serv) {
@@ -411,8 +422,11 @@ int nfsd_create_serv(struct net *net)
 	if (nfsd_max_blksize == 0)
 		nfsd_max_blksize = nfsd_get_default_max_blksize();
 	nfsd_reset_versions();
-	nn->nfsd_serv = svc_create_pooled(&nfsd_program, nfsd_max_blksize,
-						&nfsd_thread_sv_ops);
+
+	svc_pool_map_get();
+	ops = select_svc_serv_ops();
+	nn->nfsd_serv = svc_create_pooled(&nfsd_program, nfsd_max_blksize, ops);
+	svc_pool_map_put();
 	if (nn->nfsd_serv == NULL)
 		return -ENOMEM;
 
@@ -643,6 +657,57 @@ nfsd(void *vrqstp)
 	return 0;
 }
 
+static void
+nfsd_rqst_work(struct work_struct *work)
+{
+	struct svc_rqst *rqstp = container_of(work, struct svc_rqst, rq_work);
+	struct svc_xprt *xprt = rqstp->rq_xprt;
+	struct net *net = xprt->xpt_net;
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+	struct fs_struct *saved_fs;
+
+	rqstp->rq_server->sv_maxconn = nn->max_connections;
+
+	if (svc_wq_recv(rqstp) < 0) {
+		svc_rqst_free(rqstp);
+		return;
+	}
+
+	saved_fs = swap_fs_struct(rqstp->rq_fs);
+	svc_process(rqstp);
+	saved_fs = swap_fs_struct(saved_fs);
+	svc_rqst_free(rqstp);
+}
+
+/* work function for workqueue-based nfsd */
+static void
+nfsd_xprt_work(struct work_struct *work)
+{
+	int node = numa_node_id();
+	struct svc_xprt *xprt = container_of(work, struct svc_xprt, xpt_work);
+	struct svc_rqst *rqstp;
+	struct svc_serv *serv = xprt->xpt_server;
+
+	rqstp = svc_rqst_alloc(serv, &serv->sv_pools[node], node);
+	if (!rqstp) {
+		/* Alloc failure. Give up for now, and requeue the work */
+		queue_work(serv->sv_wq, &xprt->xpt_work);
+		return;
+	}
+
+	rqstp->rq_xprt = xprt;
+	queue_work(serv->sv_wq, &rqstp->rq_work);
+}
+
+static struct svc_serv_ops nfsd_wq_sv_ops = {
+	.svo_shutdown		= nfsd_last_thread,
+	.svo_enqueue_xprt	= svc_wq_enqueue_xprt,
+	.svo_xprt_work		= nfsd_xprt_work,
+	.svo_rqst_work		= nfsd_rqst_work,
+	.svo_setup		= svc_wq_setup,
+	.svo_module		= THIS_MODULE,
+};
+
 static __be32 map_new_errors(u32 vers, __be32 nfserr)
 {
 	if (nfserr == nfserr_jukebox && vers == 2)
diff --git a/include/linux/fs_struct.h b/include/linux/fs_struct.h
index d2b7a1942790..671c49f13396 100644
--- a/include/linux/fs_struct.h
+++ b/include/linux/fs_struct.h
@@ -20,6 +20,7 @@ extern void exit_fs(struct task_struct *);
 extern void set_fs_root(struct fs_struct *, const struct path *);
 extern void set_fs_pwd(struct fs_struct *, const struct path *);
 extern struct fs_struct *copy_fs_struct(struct fs_struct *);
+extern struct fs_struct *swap_fs_struct(struct fs_struct *);
 extern void free_fs_struct(struct fs_struct *);
 extern void replace_fs_struct(struct fs_struct *);
 extern int unshare_fs_struct(void);
-- 
2.1.0

