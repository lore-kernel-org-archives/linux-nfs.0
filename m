Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shutemov.name ([188.40.19.243]:33557 "EHLO shutemov.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752437Ab0L2NOc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Dec 2010 08:14:32 -0500
From: "Kirill A. Shutemov" <kas@openvz.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>
Cc: Pavel Emelyanov <xemul@parallels.com>, linux-nfs@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kas@openvz.org>
Subject: [PATCH v2 02/12] sunrpc: introduce init_rpc_pipefs
Date: Wed, 29 Dec 2010 15:14:20 +0200
Message-Id: <1293628470-28386-3-git-send-email-kas@openvz.org>
In-Reply-To: <1293628470-28386-1-git-send-email-kas@openvz.org>
References: <1293628470-28386-1-git-send-email-kas@openvz.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Introduce global variable init_rpc_pipefs and use it instead of
rpc_get_mount()/rpc_put_mount().

Signed-off-by: Kirill A. Shutemov <kas@openvz.org>
---
 fs/nfs/cache_lib.c                 |    6 +++---
 include/linux/sunrpc/rpc_pipe_fs.h |    4 ++--
 net/sunrpc/clnt.c                  |   10 ++++------
 net/sunrpc/rpc_pipe.c              |   23 ++++++-----------------
 4 files changed, 15 insertions(+), 28 deletions(-)

diff --git a/fs/nfs/cache_lib.c b/fs/nfs/cache_lib.c
index 8469031..dd7ca5f 100644
--- a/fs/nfs/cache_lib.c
+++ b/fs/nfs/cache_lib.c
@@ -117,7 +117,7 @@ int nfs_cache_register(struct cache_detail *cd)
 	struct vfsmount *mnt;
 	int ret;
 
-	mnt = rpc_get_mount();
+	mnt = mntget(init_rpc_pipefs);
 	if (IS_ERR(mnt))
 		return PTR_ERR(mnt);
 	ret = vfs_path_lookup(mnt->mnt_root, mnt, "/cache", 0, &nd);
@@ -129,13 +129,13 @@ int nfs_cache_register(struct cache_detail *cd)
 	if (!ret)
 		return ret;
 err:
-	rpc_put_mount();
+	mntput(mnt);
 	return ret;
 }
 
 void nfs_cache_unregister(struct cache_detail *cd)
 {
 	sunrpc_cache_unregister_pipefs(cd);
-	rpc_put_mount();
+	mntput(init_rpc_pipefs);
 }
 
diff --git a/include/linux/sunrpc/rpc_pipe_fs.h b/include/linux/sunrpc/rpc_pipe_fs.h
index cf14db9..b09bfa5 100644
--- a/include/linux/sunrpc/rpc_pipe_fs.h
+++ b/include/linux/sunrpc/rpc_pipe_fs.h
@@ -44,6 +44,8 @@ RPC_I(struct inode *inode)
 	return container_of(inode, struct rpc_inode, vfs_inode);
 }
 
+extern struct vfsmount *init_rpc_pipefs;
+
 extern int rpc_queue_upcall(struct inode *, struct rpc_pipe_msg *);
 
 struct rpc_clnt;
@@ -60,8 +62,6 @@ extern void rpc_remove_cache_dir(struct dentry *);
 extern struct dentry *rpc_mkpipe(struct dentry *, const char *, void *,
 				 const struct rpc_pipe_ops *, int flags);
 extern int rpc_unlink(struct dentry *);
-extern struct vfsmount *rpc_get_mount(void);
-extern void rpc_put_mount(void);
 extern int register_rpc_pipefs(void);
 extern void unregister_rpc_pipefs(void);
 
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 92ce94f..da2507a 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -112,9 +112,7 @@ rpc_setup_pipedir(struct rpc_clnt *clnt, char *dir_name)
 	if (dir_name == NULL)
 		return 0;
 
-	path.mnt = rpc_get_mount();
-	if (IS_ERR(path.mnt))
-		return PTR_ERR(path.mnt);
+	path.mnt = mntget(init_rpc_pipefs);
 	error = vfs_path_lookup(path.mnt->mnt_root, path.mnt, dir_name, 0, &nd);
 	if (error)
 		goto err;
@@ -140,7 +138,7 @@ rpc_setup_pipedir(struct rpc_clnt *clnt, char *dir_name)
 err_path_put:
 	path_put(&nd.path);
 err:
-	rpc_put_mount();
+	mntput(path.mnt);
 	return error;
 }
 
@@ -251,7 +249,7 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
 out_no_auth:
 	if (!IS_ERR(clnt->cl_path.dentry)) {
 		rpc_remove_client_dir(clnt->cl_path.dentry);
-		rpc_put_mount();
+		mntput(clnt->cl_path.mnt);
 	}
 out_no_path:
 	kfree(clnt->cl_principal);
@@ -472,7 +470,7 @@ rpc_free_client(struct rpc_clnt *clnt)
 			clnt->cl_protname, clnt->cl_server);
 	if (!IS_ERR(clnt->cl_path.dentry)) {
 		rpc_remove_client_dir(clnt->cl_path.dentry);
-		rpc_put_mount();
+		mntput(clnt->cl_path.mnt);
 	}
 	if (clnt->cl_parent != clnt) {
 		rpc_release_client(clnt->cl_parent);
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 7f3fbdd..b1e299b 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -28,9 +28,10 @@
 #include <linux/sunrpc/rpc_pipe_fs.h>
 #include <linux/sunrpc/cache.h>
 
-static struct vfsmount *rpc_mnt __read_mostly;
+struct vfsmount *init_rpc_pipefs __read_mostly;
 
 static struct file_system_type rpc_pipe_fs_type;
+EXPORT_SYMBOL_GPL(init_rpc_pipefs);
 
 
 static struct kmem_cache *rpc_inode_cachep __read_mostly;
@@ -412,18 +413,6 @@ struct rpc_filelist {
 	umode_t mode;
 };
 
-struct vfsmount *rpc_get_mount(void)
-{
-	return mntget(rpc_mnt);
-}
-EXPORT_SYMBOL_GPL(rpc_get_mount);
-
-void rpc_put_mount(void)
-{
-	mntput(rpc_mnt);
-}
-EXPORT_SYMBOL_GPL(rpc_put_mount);
-
 static int rpc_delete_dentry(struct dentry *dentry)
 {
 	return 1;
@@ -1060,9 +1049,9 @@ int register_rpc_pipefs(void)
 	if (err)
 		goto destroy_cache;
 
-	rpc_mnt = kern_mount(&rpc_pipe_fs_type);
-	if (IS_ERR(rpc_mnt)) {
-		err = PTR_ERR(rpc_mnt);
+	init_rpc_pipefs = kern_mount(&rpc_pipe_fs_type);
+	if (IS_ERR(init_rpc_pipefs)) {
+		err = PTR_ERR(init_rpc_pipefs);
 		goto unregister_fs;
 	}
 
@@ -1077,7 +1066,7 @@ destroy_cache:
 
 void unregister_rpc_pipefs(void)
 {
-	mntput(rpc_mnt);
+	mntput(init_rpc_pipefs);
 	kmem_cache_destroy(rpc_inode_cachep);
 	unregister_filesystem(&rpc_pipe_fs_type);
 }
-- 
1.7.3.4

