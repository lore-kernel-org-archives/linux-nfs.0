Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shutemov.name ([188.40.19.243]:33584 "EHLO shutemov.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752693Ab0L2NOe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Dec 2010 08:14:34 -0500
From: "Kirill A. Shutemov" <kas@openvz.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>
Cc: Pavel Emelyanov <xemul@parallels.com>, linux-nfs@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kas@openvz.org>
Subject: [PATCH v2 08/12] sunrpc: tag pipefs field of cache_detail with rpc_pipefs mount point
Date: Wed, 29 Dec 2010 15:14:26 +0200
Message-Id: <1293628470-28386-9-git-send-email-kas@openvz.org>
In-Reply-To: <1293628470-28386-1-git-send-email-kas@openvz.org>
References: <1293628470-28386-1-git-send-email-kas@openvz.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Kirill A. Shutemov <kas@openvz.org>
---
 fs/nfs/cache_lib.c           |    3 +--
 include/linux/sunrpc/cache.h |    9 +++------
 net/sunrpc/cache.c           |   16 ++++++++++------
 3 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/cache_lib.c b/fs/nfs/cache_lib.c
index dd7ca5f..0944d4e 100644
--- a/fs/nfs/cache_lib.c
+++ b/fs/nfs/cache_lib.c
@@ -123,7 +123,7 @@ int nfs_cache_register(struct cache_detail *cd)
 	ret = vfs_path_lookup(mnt->mnt_root, mnt, "/cache", 0, &nd);
 	if (ret)
 		goto err;
-	ret = sunrpc_cache_register_pipefs(nd.path.dentry,
+	ret = sunrpc_cache_register_pipefs(mnt, nd.path.dentry,
 			cd->name, 0600, cd);
 	path_put(&nd.path);
 	if (!ret)
@@ -136,6 +136,5 @@ err:
 void nfs_cache_unregister(struct cache_detail *cd)
 {
 	sunrpc_cache_unregister_pipefs(cd);
-	mntput(init_rpc_pipefs);
 }
 
diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 6950c98..d34a621 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -64,10 +64,6 @@ struct cache_detail_procfs {
 	struct proc_dir_entry   *flush_ent, *channel_ent, *content_ent;
 };
 
-struct cache_detail_pipefs {
-	struct dentry *dir;
-};
-
 struct cache_detail {
 	struct module *		owner;
 	int			hash_size;
@@ -114,7 +110,7 @@ struct cache_detail {
 
 	union {
 		struct cache_detail_procfs procfs;
-		struct cache_detail_pipefs pipefs;
+		struct path pipefs;
 	} u;
 };
 
@@ -201,7 +197,8 @@ extern int cache_register_net(struct cache_detail *cd, struct net *net);
 extern void cache_unregister(struct cache_detail *cd);
 extern void cache_unregister_net(struct cache_detail *cd, struct net *net);
 
-extern int sunrpc_cache_register_pipefs(struct dentry *parent, const char *,
+extern int sunrpc_cache_register_pipefs(struct vfsmount *rpcmount,
+					struct dentry *parent, const char *,
 					mode_t, struct cache_detail *);
 extern void sunrpc_cache_unregister_pipefs(struct cache_detail *);
 
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index e433e75..ed50d49 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -28,6 +28,7 @@
 #include <linux/workqueue.h>
 #include <linux/mutex.h>
 #include <linux/pagemap.h>
+#include <linux/mount.h>
 #include <asm/ioctls.h>
 #include <linux/sunrpc/types.h>
 #include <linux/sunrpc/cache.h>
@@ -1753,7 +1754,8 @@ const struct file_operations cache_flush_operations_pipefs = {
 	.llseek		= no_llseek,
 };
 
-int sunrpc_cache_register_pipefs(struct dentry *parent,
+int sunrpc_cache_register_pipefs(struct vfsmount *rpcmount,
+				 struct dentry *parent,
 				 const char *name, mode_t umode,
 				 struct cache_detail *cd)
 {
@@ -1766,9 +1768,10 @@ int sunrpc_cache_register_pipefs(struct dentry *parent,
 	q.len = strlen(name);
 	q.hash = full_name_hash(q.name, q.len);
 	dir = rpc_create_cache_dir(parent, &q, umode, cd);
-	if (!IS_ERR(dir))
-		cd->u.pipefs.dir = dir;
-	else {
+	if (!IS_ERR(dir)) {
+		cd->u.pipefs.mnt = mntget(rpcmount);
+		cd->u.pipefs.dentry = dir;
+	} else {
 		sunrpc_destroy_cache_detail(cd);
 		ret = PTR_ERR(dir);
 	}
@@ -1778,8 +1781,9 @@ EXPORT_SYMBOL_GPL(sunrpc_cache_register_pipefs);
 
 void sunrpc_cache_unregister_pipefs(struct cache_detail *cd)
 {
-	rpc_remove_cache_dir(cd->u.pipefs.dir);
-	cd->u.pipefs.dir = NULL;
+	rpc_remove_cache_dir(cd->u.pipefs.dentry);
+	cd->u.pipefs.dentry = NULL;
+	mntput(cd->u.pipefs.mnt);
 	sunrpc_destroy_cache_detail(cd);
 }
 EXPORT_SYMBOL_GPL(sunrpc_cache_unregister_pipefs);
-- 
1.7.3.4

