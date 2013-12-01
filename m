Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:59557 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751865Ab3LANUV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 1 Dec 2013 08:20:21 -0500
Message-Id: <20131201132011.555195253@bombadil.infradead.org>
Date: Sun, 01 Dec 2013 05:14:51 -0800
From: Christoph Hellwig <hch@infradead.org>
To: linux-nfs@vger.kernel.org, viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org
Subject: [PATCH 10/11] auth_gss: convert to rpc_mkpipe_clnt
References: <20131201131441.790963326@bombadil.infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a bit more elaborate as auth_gcc offloaded it's own little
list of pipes to rpc_pipes.  Fixed by rewriting the ovely generic
code into self-contained variants and removing the superflous
infrastructure.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/sunrpc/clnt.h        |    4 +-
 include/linux/sunrpc/rpc_pipe_fs.h |   37 --------
 net/sunrpc/auth_gss/auth_gss.c     |  146 ++++++++---------------------
 net/sunrpc/clnt.c                  |    4 +-
 net/sunrpc/netns.h                 |    1 -
 net/sunrpc/rpc_pipe.c              |  177 +-----------------------------------
 6 files changed, 49 insertions(+), 320 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 8af2804..a78bc9a 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -58,11 +58,13 @@ struct rpc_clnt {
 
 	int			cl_nodelen;	/* nodename length */
 	char 			cl_nodename[UNX_MAXNODENAME];
-	struct rpc_pipe_dir_head cl_pipedir_objects;
+	struct dentry		*cl_dentry;
 	struct rpc_clnt *	cl_parent;	/* Points to parent of clones */
 	struct rpc_rtt		cl_rtt_default;
 	struct rpc_timeout	cl_timeout_default;
 	const struct rpc_program *cl_program;
+	struct list_head	cl_gss_pipes;
+	struct mutex		cl_gss_pipe_mutex;
 };
 
 /*
diff --git a/include/linux/sunrpc/rpc_pipe_fs.h b/include/linux/sunrpc/rpc_pipe_fs.h
index 29c66f9..d37a1e2 100644
--- a/include/linux/sunrpc/rpc_pipe_fs.h
+++ b/include/linux/sunrpc/rpc_pipe_fs.h
@@ -5,26 +5,6 @@
 
 #include <linux/workqueue.h>
 
-struct rpc_pipe_dir_head {
-	struct list_head pdh_entries;
-	struct dentry *pdh_dentry;
-};
-
-struct rpc_pipe_dir_object_ops;
-struct rpc_pipe_dir_object {
-	struct list_head pdo_head;
-	const struct rpc_pipe_dir_object_ops *pdo_ops;
-
-	void *pdo_data;
-};
-
-struct rpc_pipe_dir_object_ops {
-	int (*create)(struct dentry *dir,
-			struct rpc_pipe_dir_object *pdo);
-	void (*destroy)(struct dentry *dir,
-			struct rpc_pipe_dir_object *pdo);
-};
-
 struct rpc_pipe_msg {
 	struct list_head list;
 	void *data;
@@ -77,23 +57,6 @@ struct rpc_clnt;
 extern int rpc_create_client_dir(struct rpc_clnt *);
 extern int rpc_remove_client_dir(struct rpc_clnt *);
 
-extern void rpc_init_pipe_dir_head(struct rpc_pipe_dir_head *pdh);
-extern void rpc_init_pipe_dir_object(struct rpc_pipe_dir_object *pdo,
-		const struct rpc_pipe_dir_object_ops *pdo_ops,
-		void *pdo_data);
-extern int rpc_add_pipe_dir_object(struct net *net,
-		struct rpc_pipe_dir_head *pdh,
-		struct rpc_pipe_dir_object *pdo);
-extern void rpc_remove_pipe_dir_object(struct net *net,
-		struct rpc_pipe_dir_head *pdh,
-		struct rpc_pipe_dir_object *pdo);
-extern struct rpc_pipe_dir_object *rpc_find_or_alloc_pipe_dir_object(
-		struct net *net,
-		struct rpc_pipe_dir_head *pdh,
-		int (*match)(struct rpc_pipe_dir_object *, void *),
-		struct rpc_pipe_dir_object *(*alloc)(void *),
-		void *data);
-
 struct cache_detail;
 extern struct dentry *rpc_create_cache_dir(struct net *n, const char *,
 		const char *, umode_t umode, struct cache_detail *);
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 97912b4..b67f8d4 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -79,7 +79,7 @@ static DEFINE_HASHTABLE(gss_auth_hash_table, 4);
 static DEFINE_SPINLOCK(gss_auth_hash_lock);
 
 struct gss_pipe {
-	struct rpc_pipe_dir_object pdo;
+	struct list_head list;
 	struct rpc_pipe *pipe;
 	struct rpc_clnt *clnt;
 	const char *name;
@@ -826,141 +826,71 @@ gss_pipe_destroy_msg(struct rpc_pipe_msg *msg)
 	}
 }
 
-static void gss_pipe_dentry_destroy(struct dentry *dir,
-		struct rpc_pipe_dir_object *pdo)
+static struct gss_pipe *
+__gss_pipe_find(struct rpc_clnt *clnt, const char *name)
 {
-	struct gss_pipe *gss_pipe = pdo->pdo_data;
-	struct rpc_pipe *pipe = gss_pipe->pipe;
+	struct gss_pipe *p;
 
-	if (pipe->dentry != NULL) {
-		rpc_unlink(pipe->dentry);
-		pipe->dentry = NULL;
+	list_for_each_entry(p, &clnt->cl_gss_pipes, list) {
+		if (strcmp(p->name, name) != 0)
+			continue;
+		if (!kref_get_unless_zero(&p->kref))
+			continue;
+		return p;
 	}
-}
-
-static int gss_pipe_dentry_create(struct dentry *dir,
-		struct rpc_pipe_dir_object *pdo)
-{
-	struct gss_pipe *p = pdo->pdo_data;
-	struct dentry *dentry;
 
-	dentry = rpc_mkpipe_dentry(dir, p->name, p->clnt, p->pipe);
-	if (IS_ERR(dentry))
-		return PTR_ERR(dentry);
-	p->pipe->dentry = dentry;
-	return 0;
+	return NULL;
 }
 
-static const struct rpc_pipe_dir_object_ops gss_pipe_dir_object_ops = {
-	.create = gss_pipe_dentry_create,
-	.destroy = gss_pipe_dentry_destroy,
-};
-
-static struct gss_pipe *gss_pipe_alloc(struct rpc_clnt *clnt,
+static struct gss_pipe *gss_pipe_get(struct rpc_clnt *clnt,
 		const char *name,
 		const struct rpc_pipe_ops *upcall_ops)
 {
 	struct gss_pipe *p;
-	int err = -ENOMEM;
+
+	mutex_lock(&clnt->cl_gss_pipe_mutex);
+	p = __gss_pipe_find(clnt, name);
+	if (p)
+		goto out;
 
 	p = kmalloc(sizeof(*p), GFP_KERNEL);
-	if (p == NULL)
-		goto err;
-	p->pipe = rpc_mkpipe_data(upcall_ops, RPC_PIPE_WAIT_FOR_OPEN);
-	if (IS_ERR(p->pipe)) {
-		err = PTR_ERR(p->pipe);
-		goto err_free_gss_pipe;
+	if (p == NULL) {
+		p = ERR_PTR(-ENOMEM);
+		goto out;
 	}
+
 	p->name = name;
 	p->clnt = clnt;
 	kref_init(&p->kref);
-	rpc_init_pipe_dir_object(&p->pdo,
-			&gss_pipe_dir_object_ops,
-			p);
-	return p;
-err_free_gss_pipe:
-	kfree(p);
-err:
-	return ERR_PTR(err);
-}
-
-struct gss_alloc_pdo {
-	struct rpc_clnt *clnt;
-	const char *name;
-	const struct rpc_pipe_ops *upcall_ops;
-};
-
-static int gss_pipe_match_pdo(struct rpc_pipe_dir_object *pdo, void *data)
-{
-	struct gss_pipe *gss_pipe;
-	struct gss_alloc_pdo *args = data;
-
-	if (pdo->pdo_ops != &gss_pipe_dir_object_ops)
-		return 0;
-	gss_pipe = container_of(pdo, struct gss_pipe, pdo);
-	if (strcmp(gss_pipe->name, args->name) != 0)
-		return 0;
-	if (!kref_get_unless_zero(&gss_pipe->kref))
-		return 0;
-	return 1;
-}
-
-static struct rpc_pipe_dir_object *gss_pipe_alloc_pdo(void *data)
-{
-	struct gss_pipe *gss_pipe;
-	struct gss_alloc_pdo *args = data;
-
-	gss_pipe = gss_pipe_alloc(args->clnt, args->name, args->upcall_ops);
-	if (!IS_ERR(gss_pipe))
-		return &gss_pipe->pdo;
-	return NULL;
-}
-
-static struct gss_pipe *gss_pipe_get(struct rpc_clnt *clnt,
-		const char *name,
-		const struct rpc_pipe_ops *upcall_ops)
-{
-	struct net *net = rpc_net_ns(clnt);
-	struct rpc_pipe_dir_object *pdo;
-	struct gss_alloc_pdo args = {
-		.clnt = clnt,
-		.name = name,
-		.upcall_ops = upcall_ops,
-	};
-
-	pdo = rpc_find_or_alloc_pipe_dir_object(net,
-			&clnt->cl_pipedir_objects,
-			gss_pipe_match_pdo,
-			gss_pipe_alloc_pdo,
-			&args);
-	if (pdo != NULL)
-		return container_of(pdo, struct gss_pipe, pdo);
-	return ERR_PTR(-ENOMEM);
-}
+	p->pipe = rpc_mkpipe_clnt(clnt, name, upcall_ops, clnt,
+			RPC_PIPE_WAIT_FOR_OPEN);
+	if (IS_ERR(p->pipe)) {
+		kfree(p);
+		return ERR_CAST(p->pipe);
+	}
 
-static void __gss_pipe_free(struct gss_pipe *p)
-{
-	struct rpc_clnt *clnt = p->clnt;
-	struct net *net = rpc_net_ns(clnt);
+	list_add_tail(&p->list, &clnt->cl_gss_pipes);
 
-	rpc_remove_pipe_dir_object(net,
-			&clnt->cl_pipedir_objects,
-			&p->pdo);
-	rpc_destroy_pipe_data(p->pipe);
-	kfree(p);
+out:
+	mutex_unlock(&clnt->cl_gss_pipe_mutex);
+	return p;
 }
 
-static void __gss_pipe_release(struct kref *kref)
+static void __gss_pipe_free(struct kref *kref)
 {
 	struct gss_pipe *p = container_of(kref, struct gss_pipe, kref);
 
-	__gss_pipe_free(p);
+	mutex_lock(&p->clnt->cl_gss_pipe_mutex);
+	list_del(&p->list);
+	mutex_unlock(&p->clnt->cl_gss_pipe_mutex);
+	rpc_rmpipe(p->pipe);
+	kfree(p);
 }
 
 static void gss_pipe_free(struct gss_pipe *p)
 {
 	if (p != NULL)
-		kref_put(&p->kref, __gss_pipe_release);
+		kref_put(&p->kref, __gss_pipe_free);
 }
 
 /*
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index ae57193..029f468 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -221,7 +221,6 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args,
 	clnt->cl_vers     = version->number;
 	clnt->cl_stats    = program->stats;
 	clnt->cl_metrics  = rpc_alloc_iostats(clnt);
-	rpc_init_pipe_dir_head(&clnt->cl_pipedir_objects);
 	err = -ENOMEM;
 	if (clnt->cl_metrics == NULL)
 		goto out_no_stats;
@@ -229,6 +228,9 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args,
 	INIT_LIST_HEAD(&clnt->cl_tasks);
 	spin_lock_init(&clnt->cl_lock);
 
+	INIT_LIST_HEAD(&clnt->cl_gss_pipes);
+	mutex_init(&clnt->cl_gss_pipe_mutex);
+
 	timeout = xprt->timeout;
 	if (args->timeout != NULL) {
 		memcpy(&clnt->cl_timeout_default, args->timeout,
diff --git a/net/sunrpc/netns.h b/net/sunrpc/netns.h
index a80b069..0773142 100644
--- a/net/sunrpc/netns.h
+++ b/net/sunrpc/netns.h
@@ -15,7 +15,6 @@ struct sunrpc_net {
 
 	struct vfsmount *pipefs_mnt;
 	struct super_block *pipefs_sb;
-	struct mutex pipefs_sb_lock;
 
 	struct list_head all_clients;
 	spinlock_t rpc_client_lock;
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 0485796..6bce5f6 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -889,8 +889,7 @@ struct rpc_pipe *
 rpc_mkpipe_clnt(struct rpc_clnt *clnt, const char *name,
 		const struct rpc_pipe_ops *ops, void *private, int flags)
 {
-	return __rpc_mkpipe(clnt->cl_pipedir_objects.pdh_dentry, name,
-			    ops, private, flags);
+	return __rpc_mkpipe(clnt->cl_dentry, name, ops, private, flags);
 }
 EXPORT_SYMBOL_GPL(rpc_mkpipe_clnt);
 
@@ -927,159 +926,6 @@ void rpc_rmpipe(struct rpc_pipe *pipe)
 }
 EXPORT_SYMBOL_GPL(rpc_rmpipe);
 
-/**
- * rpc_init_pipe_dir_head - initialise a struct rpc_pipe_dir_head
- * @pdh: pointer to struct rpc_pipe_dir_head
- */
-void rpc_init_pipe_dir_head(struct rpc_pipe_dir_head *pdh)
-{
-	INIT_LIST_HEAD(&pdh->pdh_entries);
-	pdh->pdh_dentry = NULL;
-}
-EXPORT_SYMBOL_GPL(rpc_init_pipe_dir_head);
-
-/**
- * rpc_init_pipe_dir_object - initialise a struct rpc_pipe_dir_object
- * @pdo: pointer to struct rpc_pipe_dir_object
- * @pdo_ops: pointer to const struct rpc_pipe_dir_object_ops
- * @pdo_data: pointer to caller-defined data
- */
-void rpc_init_pipe_dir_object(struct rpc_pipe_dir_object *pdo,
-		const struct rpc_pipe_dir_object_ops *pdo_ops,
-		void *pdo_data)
-{
-	INIT_LIST_HEAD(&pdo->pdo_head);
-	pdo->pdo_ops = pdo_ops;
-	pdo->pdo_data = pdo_data;
-}
-EXPORT_SYMBOL_GPL(rpc_init_pipe_dir_object);
-
-static int
-rpc_add_pipe_dir_object_locked(struct net *net,
-		struct rpc_pipe_dir_head *pdh,
-		struct rpc_pipe_dir_object *pdo)
-{
-	int ret = 0;
-
-	if (pdh->pdh_dentry)
-		ret = pdo->pdo_ops->create(pdh->pdh_dentry, pdo);
-	if (ret == 0)
-		list_add_tail(&pdo->pdo_head, &pdh->pdh_entries);
-	return ret;
-}
-
-static void
-rpc_remove_pipe_dir_object_locked(struct net *net,
-		struct rpc_pipe_dir_head *pdh,
-		struct rpc_pipe_dir_object *pdo)
-{
-	if (pdh->pdh_dentry)
-		pdo->pdo_ops->destroy(pdh->pdh_dentry, pdo);
-	list_del_init(&pdo->pdo_head);
-}
-
-/**
- * rpc_add_pipe_dir_object - associate a rpc_pipe_dir_object to a directory
- * @net: pointer to struct net
- * @pdh: pointer to struct rpc_pipe_dir_head
- * @pdo: pointer to struct rpc_pipe_dir_object
- *
- */
-int
-rpc_add_pipe_dir_object(struct net *net,
-		struct rpc_pipe_dir_head *pdh,
-		struct rpc_pipe_dir_object *pdo)
-{
-	int ret = 0;
-
-	if (list_empty(&pdo->pdo_head)) {
-		struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
-
-		mutex_lock(&sn->pipefs_sb_lock);
-		ret = rpc_add_pipe_dir_object_locked(net, pdh, pdo);
-		mutex_unlock(&sn->pipefs_sb_lock);
-	}
-	return ret;
-}
-EXPORT_SYMBOL_GPL(rpc_add_pipe_dir_object);
-
-/**
- * rpc_remove_pipe_dir_object - remove a rpc_pipe_dir_object from a directory
- * @net: pointer to struct net
- * @pdh: pointer to struct rpc_pipe_dir_head
- * @pdo: pointer to struct rpc_pipe_dir_object
- *
- */
-void
-rpc_remove_pipe_dir_object(struct net *net,
-		struct rpc_pipe_dir_head *pdh,
-		struct rpc_pipe_dir_object *pdo)
-{
-	if (!list_empty(&pdo->pdo_head)) {
-		struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
-
-		mutex_lock(&sn->pipefs_sb_lock);
-		rpc_remove_pipe_dir_object_locked(net, pdh, pdo);
-		mutex_unlock(&sn->pipefs_sb_lock);
-	}
-}
-EXPORT_SYMBOL_GPL(rpc_remove_pipe_dir_object);
-
-/**
- * rpc_find_or_alloc_pipe_dir_object
- * @net: pointer to struct net
- * @pdh: pointer to struct rpc_pipe_dir_head
- * @match: match struct rpc_pipe_dir_object to data
- * @alloc: allocate a new struct rpc_pipe_dir_object
- * @data: user defined data for match() and alloc()
- *
- */
-struct rpc_pipe_dir_object *
-rpc_find_or_alloc_pipe_dir_object(struct net *net,
-		struct rpc_pipe_dir_head *pdh,
-		int (*match)(struct rpc_pipe_dir_object *, void *),
-		struct rpc_pipe_dir_object *(*alloc)(void *),
-		void *data)
-{
-	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
-	struct rpc_pipe_dir_object *pdo;
-
-	mutex_lock(&sn->pipefs_sb_lock);
-	list_for_each_entry(pdo, &pdh->pdh_entries, pdo_head) {
-		if (!match(pdo, data))
-			continue;
-		goto out;
-	}
-	pdo = alloc(data);
-	if (!pdo)
-		goto out;
-	rpc_add_pipe_dir_object_locked(net, pdh, pdo);
-out:
-	mutex_unlock(&sn->pipefs_sb_lock);
-	return pdo;
-}
-EXPORT_SYMBOL_GPL(rpc_find_or_alloc_pipe_dir_object);
-
-static void
-rpc_create_pipe_dir_objects(struct rpc_pipe_dir_head *pdh)
-{
-	struct rpc_pipe_dir_object *pdo;
-	struct dentry *dir = pdh->pdh_dentry;
-
-	list_for_each_entry(pdo, &pdh->pdh_entries, pdo_head)
-		pdo->pdo_ops->create(dir, pdo);
-}
-
-static void
-rpc_destroy_pipe_dir_objects(struct rpc_pipe_dir_head *pdh)
-{
-	struct rpc_pipe_dir_object *pdo;
-	struct dentry *dir = pdh->pdh_dentry;
-
-	list_for_each_entry(pdo, &pdh->pdh_entries, pdo_head)
-		pdo->pdo_ops->destroy(dir, pdo);
-}
-
 enum {
 	RPCAUTH_info,
 	RPCAUTH_EOF
@@ -1138,8 +984,7 @@ retry:
 		goto out;
 	}
 
-	clnt->cl_pipedir_objects.pdh_dentry = dentry;
-	rpc_create_pipe_dir_objects(&clnt->cl_pipedir_objects);
+	clnt->cl_dentry = dentry;
 out:
 	return ret;
 }
@@ -1150,12 +995,12 @@ out:
  */
 int rpc_remove_client_dir(struct rpc_clnt *rpc_client)
 {
-	struct dentry *dentry = rpc_client->cl_pipedir_objects.pdh_dentry;
+	struct dentry *dentry = rpc_client->cl_dentry;
 
 	if (dentry == NULL)
 		return 0;
-	rpc_destroy_pipe_dir_objects(&rpc_client->cl_pipedir_objects);
-	rpc_client->cl_pipedir_objects.pdh_dentry = NULL;
+
+	rpc_client->cl_dentry = NULL;
 	return rpc_rmdir_depopulate(dentry, rpc_clntdir_depopulate);
 }
 
@@ -1266,7 +1111,6 @@ int rpc_pipefs_init_net(struct net *net)
 {
 	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
 
-	mutex_init(&sn->pipefs_sb_lock);
 	sn->gssd_running = 1;
 	sn->pipe_version = -1;
 
@@ -1306,10 +1150,8 @@ rpc_fill_super(struct super_block *sb, void *data, int silent)
 		return -ENOMEM;
 	dprintk("RPC:       sending pipefs MOUNT notification for net %p%s\n",
 		net, NET_NAME(net));
-	mutex_lock(&sn->pipefs_sb_lock);
 	sn->pipefs_sb = sb;
 	sb->s_fs_info = get_net(net);
-	mutex_unlock(&sn->pipefs_sb_lock);
 	return 0;
 }
 
@@ -1323,19 +1165,10 @@ rpc_mount(struct file_system_type *fs_type,
 static void rpc_kill_sb(struct super_block *sb)
 {
 	struct net *net = sb->s_fs_info;
-	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
 
-	mutex_lock(&sn->pipefs_sb_lock);
-	if (sn->pipefs_sb != sb) {
-		mutex_unlock(&sn->pipefs_sb_lock);
-		goto out;
-	}
-	sn->pipefs_sb = NULL;
 	dprintk("RPC:       sending pipefs UMOUNT notification for net %p%s\n",
 		net, NET_NAME(net));
-	mutex_unlock(&sn->pipefs_sb_lock);
 	put_net(net);
-out:
 	kill_litter_super(sb);
 }
 
-- 
1.7.10.4


