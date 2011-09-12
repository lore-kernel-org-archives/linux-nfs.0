Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:39482 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755025Ab1ILOUM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Sep 2011 10:20:12 -0400
Subject: [PATCH 2/2] SUNRPC: RPC pipefs virtualization
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        bfields@fieldses.org, davem@davemloft.net
Date: Mon, 12 Sep 2011 18:19:50 +0400
Message-ID: <20110912141950.6261.9291.stgit@localhost6.localdomain6>
In-Reply-To: <20110912141633.6261.72180.stgit@localhost6.localdomain6>
References: <20110912141633.6261.72180.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Parametrize rpc_mount_get() and rpc_mount_put() with network namespace pointer.
Currently init_net is used, but later proper network context will be used
instead.
It actually means, that in future NFS cache have to be virtualied as well.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/nfs/blocklayout/blocklayout.c |    2 +-
 fs/nfs/cache_lib.c               |    7 ++++---
 net/sunrpc/clnt.c                |    8 ++++----
 3 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 9561c8f..9904e70 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -979,7 +979,7 @@ static int __init nfs4blocklayout_init(void)
 
 	init_waitqueue_head(&bl_wq);
 
-	mnt = rpc_get_mount();
+	mnt = rpc_get_mount(&init_net);
 	if (IS_ERR(mnt)) {
 		ret = PTR_ERR(mnt);
 		goto out_remove;
diff --git a/fs/nfs/cache_lib.c b/fs/nfs/cache_lib.c
index c98b439..777514b 100644
--- a/fs/nfs/cache_lib.c
+++ b/fs/nfs/cache_lib.c
@@ -11,6 +11,7 @@
 #include <linux/mount.h>
 #include <linux/namei.h>
 #include <linux/slab.h>
+#include <net/net_namespace.h>
 #include <linux/sunrpc/cache.h>
 #include <linux/sunrpc/rpc_pipe_fs.h>
 
@@ -117,7 +118,7 @@ int nfs_cache_register(struct cache_detail *cd)
 	struct path path;
 	int ret;
 
-	mnt = rpc_get_mount();
+	mnt = rpc_get_mount(&init_net);
 	if (IS_ERR(mnt))
 		return PTR_ERR(mnt);
 	ret = vfs_path_lookup(mnt->mnt_root, mnt, "/cache", 0, &path);
@@ -128,13 +129,13 @@ int nfs_cache_register(struct cache_detail *cd)
 	if (!ret)
 		return ret;
 err:
-	rpc_put_mount();
+	rpc_put_mount(&init_net);
 	return ret;
 }
 
 void nfs_cache_unregister(struct cache_detail *cd)
 {
 	sunrpc_cache_unregister_pipefs(cd);
-	rpc_put_mount();
+	rpc_put_mount(&init_net);
 }
 
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index c5347d2..4bebcc0 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -109,7 +109,7 @@ rpc_setup_pipedir(struct rpc_clnt *clnt, char *dir_name)
 	if (dir_name == NULL)
 		return 0;
 
-	path.mnt = rpc_get_mount();
+	path.mnt = rpc_get_mount(clnt->cl_xprt->xprt_net);
 	if (IS_ERR(path.mnt))
 		return PTR_ERR(path.mnt);
 	error = vfs_path_lookup(path.mnt->mnt_root, path.mnt, dir_name, 0, &dir);
@@ -137,7 +137,7 @@ rpc_setup_pipedir(struct rpc_clnt *clnt, char *dir_name)
 err_path_put:
 	path_put(&dir);
 err:
-	rpc_put_mount();
+	rpc_put_mount(clnt->cl_xprt->xprt_net);
 	return error;
 }
 
@@ -248,7 +248,7 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
 out_no_auth:
 	if (!IS_ERR(clnt->cl_path.dentry)) {
 		rpc_remove_client_dir(clnt->cl_path.dentry);
-		rpc_put_mount();
+		rpc_put_mount(clnt->cl_xprt->xprt_net);
 	}
 out_no_path:
 	kfree(clnt->cl_principal);
@@ -476,7 +476,7 @@ rpc_free_client(struct rpc_clnt *clnt)
 			clnt->cl_protname, clnt->cl_server);
 	if (!IS_ERR(clnt->cl_path.dentry)) {
 		rpc_remove_client_dir(clnt->cl_path.dentry);
-		rpc_put_mount();
+		rpc_put_mount(clnt->cl_xprt->xprt_net);
 	}
 	if (clnt->cl_parent != clnt) {
 		rpc_release_client(clnt->cl_parent);

