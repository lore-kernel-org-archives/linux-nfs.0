Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:59552 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751801Ab3LANUV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 1 Dec 2013 08:20:21 -0500
Message-Id: <20131201132010.926223786@bombadil.infradead.org>
Date: Sun, 01 Dec 2013 05:14:48 -0800
From: Christoph Hellwig <hch@infradead.org>
To: linux-nfs@vger.kernel.org, viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org
Subject: [PATCH 07/11] sunrpc: make rpc_mkdir_populate net-namespace aware
References: <20131201131441.790963326@bombadil.infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

And clean up the caller to not bother about intricate details of
rpc_pipefs internals.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/cache_lib.c                 |   38 ++++--------------------------------
 include/linux/sunrpc/cache.h       |    4 ++--
 include/linux/sunrpc/rpc_pipe_fs.h |    6 ++----
 net/sunrpc/cache.c                 |    8 ++++----
 net/sunrpc/rpc_pipe.c              |   34 +++++++++++++++-----------------
 5 files changed, 28 insertions(+), 62 deletions(-)

diff --git a/fs/nfs/cache_lib.c b/fs/nfs/cache_lib.c
index 4e9226f..bc2bfb1 100644
--- a/fs/nfs/cache_lib.c
+++ b/fs/nfs/cache_lib.c
@@ -112,49 +112,19 @@ int nfs_cache_wait_for_upcall(struct nfs_cache_defer_req *dreq)
 	return 0;
 }
 
-static int nfs_cache_register_sb(struct super_block *sb,
-		struct cache_detail *cd)
-{
-	int ret;
-	struct dentry *dir;
-
-	dir = rpc_d_lookup_sb(sb, "cache");
-	ret = sunrpc_cache_register_pipefs(dir, cd->name, 0600, cd);
-	dput(dir);
-	return ret;
-}
-
 int nfs_cache_register_net(struct net *net, struct cache_detail *cd)
 {
-	struct super_block *pipefs_sb;
 	int ret = 0;
 
 	sunrpc_init_cache_detail(cd);
-	pipefs_sb = rpc_get_sb_net(net);
-	if (pipefs_sb) {
-		ret = nfs_cache_register_sb(pipefs_sb, cd);
-		rpc_put_sb_net(net);
-		if (ret)
-			sunrpc_destroy_cache_detail(cd);
-	}
+	ret = sunrpc_cache_register_pipefs(net, cd);
+	if (ret)
+		sunrpc_destroy_cache_detail(cd);
 	return ret;
 }
 
-static void nfs_cache_unregister_sb(struct super_block *sb,
-		struct cache_detail *cd)
-{
-	if (cd->u.pipefs.dir)
-		sunrpc_cache_unregister_pipefs(cd);
-}
-
 void nfs_cache_unregister_net(struct net *net, struct cache_detail *cd)
 {
-	struct super_block *pipefs_sb;
-
-	pipefs_sb = rpc_get_sb_net(net);
-	if (pipefs_sb) {
-		nfs_cache_unregister_sb(pipefs_sb, cd);
-		rpc_put_sb_net(net);
-	}
+	sunrpc_cache_unregister_pipefs(cd);
 	sunrpc_destroy_cache_detail(cd);
 }
diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 437ddb6..db1ad29 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -220,8 +220,8 @@ extern void cache_destroy_net(struct cache_detail *cd, struct net *net);
 
 extern void sunrpc_init_cache_detail(struct cache_detail *cd);
 extern void sunrpc_destroy_cache_detail(struct cache_detail *cd);
-extern int sunrpc_cache_register_pipefs(struct dentry *parent, const char *,
-					umode_t, struct cache_detail *);
+extern int sunrpc_cache_register_pipefs(struct net *net,
+	struct cache_detail *cd);
 extern void sunrpc_cache_unregister_pipefs(struct cache_detail *);
 
 extern void qword_add(char **bpp, int *lp, char *str);
diff --git a/include/linux/sunrpc/rpc_pipe_fs.h b/include/linux/sunrpc/rpc_pipe_fs.h
index fefbfa3..ae0a109 100644
--- a/include/linux/sunrpc/rpc_pipe_fs.h
+++ b/include/linux/sunrpc/rpc_pipe_fs.h
@@ -100,10 +100,8 @@ extern struct rpc_pipe_dir_object *rpc_find_or_alloc_pipe_dir_object(
 		void *data);
 
 struct cache_detail;
-extern struct dentry *rpc_create_cache_dir(struct dentry *,
-					   const char *,
-					   umode_t umode,
-					   struct cache_detail *);
+extern struct dentry *rpc_create_cache_dir(struct net *n, const char *,
+		const char *, umode_t umode, struct cache_detail *);
 extern void rpc_remove_cache_dir(struct dentry *);
 
 extern int rpc_rmdir(struct dentry *dentry);
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index a72de07..c654377 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -1819,11 +1819,11 @@ const struct file_operations cache_flush_operations_pipefs = {
 	.llseek		= no_llseek,
 };
 
-int sunrpc_cache_register_pipefs(struct dentry *parent,
-				 const char *name, umode_t umode,
-				 struct cache_detail *cd)
+int sunrpc_cache_register_pipefs(struct net *net, struct cache_detail *cd)
 {
-	struct dentry *dir = rpc_create_cache_dir(parent, name, umode, cd);
+	struct dentry *dir;
+
+	dir = rpc_create_cache_dir(net,  "cache", cd->name, 0600, cd);
 	if (IS_ERR(dir))
 		return PTR_ERR(dir);
 	cd->u.pipefs.dir = dir;
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 751aba5..3f4905a 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -732,14 +732,20 @@ out_bad:
 	return err;
 }
 
-static struct dentry *rpc_mkdir_populate(struct dentry *parent,
+static struct dentry *rpc_mkdir_populate(struct net *net, const char *dirname,
 		const char *name, umode_t mode, void *private,
 		int (*populate)(struct dentry *, void *), void *args_populate)
 {
-	struct dentry *dentry;
-	struct inode *dir = parent->d_inode;
+	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
+	struct dentry *dentry, *parent;
+	struct inode *dir;
 	int error;
 
+	parent = rpc_d_lookup_sb(sn->pipefs_sb, dirname);
+	if (parent == NULL)
+		return ERR_PTR(-ENOENT);
+	dir = parent->d_inode;
+
 	mutex_lock_nested(&dir->i_mutex, I_MUTEX_PARENT);
 	dentry = __rpc_lookup_create_exclusive(parent, name);
 	if (IS_ERR(dentry))
@@ -754,6 +760,7 @@ static struct dentry *rpc_mkdir_populate(struct dentry *parent,
 	}
 out:
 	mutex_unlock(&dir->i_mutex);
+	dput(parent);
 	return dentry;
 err_rmdir:
 	__rpc_rmdir(dir, dentry);
@@ -1103,24 +1110,17 @@ int rpc_create_client_dir(struct rpc_clnt *clnt)
 {
 	static uint32_t clntid;
 	struct net *net = rpc_net_ns(clnt);
-	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
 	const char *dir_name = clnt->cl_program->pipe_dir_name;
-	struct dentry *dir, *dentry;
+	struct dentry *dentry;
 	char name[15];
 	int ret = 0;
 
-	dir = rpc_d_lookup_sb(sn->pipefs_sb, dir_name);
-	if (dir == NULL) {
-		pr_info("RPC: pipefs directory doesn't exist: %s\n", dir_name);
-		return -ENOENT;
-	}
-
 retry:
 	snprintf(name, sizeof(name), "clnt%x", (unsigned int)clntid++);
 	name[sizeof(name) - 1] = '\0';
 
-	dentry = rpc_mkdir_populate(dir, name, S_IRUGO | S_IXUGO, NULL,
-			rpc_clntdir_populate, clnt);
+	dentry = rpc_mkdir_populate(net, dir_name, name, S_IRUGO | S_IXUGO,
+			NULL, rpc_clntdir_populate, clnt);
 	if (IS_ERR(dentry)) {
 		if (dentry == ERR_PTR(-EEXIST))
 			goto retry;
@@ -1133,9 +1133,7 @@ retry:
 
 	clnt->cl_pipedir_objects.pdh_dentry = dentry;
 	rpc_create_pipe_dir_objects(&clnt->cl_pipedir_objects);
-
 out:
-	dput(dir);
 	return ret;
 }
 
@@ -1184,10 +1182,10 @@ static void rpc_cachedir_depopulate(struct dentry *dentry)
 	rpc_depopulate(dentry, cache_pipefs_files, 0, 3);
 }
 
-struct dentry *rpc_create_cache_dir(struct dentry *parent, const char *name,
-				    umode_t umode, struct cache_detail *cd)
+struct dentry *rpc_create_cache_dir(struct net *net, const char *dirname,
+		const char *name, umode_t umode, struct cache_detail *cd)
 {
-	return rpc_mkdir_populate(parent, name, umode, NULL,
+	return rpc_mkdir_populate(net, dirname, name, umode, NULL,
 			rpc_cachedir_populate, cd);
 }
 
-- 
1.7.10.4


