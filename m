From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 18/32] SUNRPC: clean up rpc_setup_pipedir()
Date: Wed, 19 Aug 2009 19:38:41 -0400
Message-ID: <1250725135-14632-19-git-send-email-Trond.Myklebust@netapp.com>
References: <1250725135-14632-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-2-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-3-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-4-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-5-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-6-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-7-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-8-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-9-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-10-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-11-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-12-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-13-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-14-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-15-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-16-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-17-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-18-git-send-email-Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39738 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754122AbZHSXlB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Aug 2009 19:41:01 -0400
Received: from svlrsexc2-prd.hq.netapp.com (svlrsexc2-prd.hq.netapp.com [10.57.115.31])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n7JNe7YJ028517
	for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2009 16:40:48 -0700 (PDT)
In-Reply-To: <1250725135-14632-18-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is still a little wart or two there: Since we've already got a
vfsmount, we might as well pass that in to rpc_create_client_dir.
Another point is that if we open code __rpc_lookup_path() here, then we can
avoid looking up the entire parent directory path over and over again: it
doesn't change.

Also get rid of rpc_clnt->cl_pathname, since it has no users...

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/sunrpc/clnt.h        |    1 -
 include/linux/sunrpc/rpc_pipe_fs.h |    2 +-
 net/sunrpc/clnt.c                  |   48 ++++++++++++++++++++---------
 net/sunrpc/rpc_pipe.c              |   58 ++----------------------------------
 4 files changed, 37 insertions(+), 72 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 38ad162..1848d44 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -51,7 +51,6 @@ struct rpc_clnt {
 
 	int			cl_nodelen;	/* nodename length */
 	char 			cl_nodename[UNX_MAXNODENAME];
-	char			cl_pathname[30];/* Path in rpc_pipe_fs */
 	struct path		cl_path;
 	struct rpc_clnt *	cl_parent;	/* Points to parent of clones */
 	struct rpc_rtt		cl_rtt_default;
diff --git a/include/linux/sunrpc/rpc_pipe_fs.h b/include/linux/sunrpc/rpc_pipe_fs.h
index 8de0ac2..88332ef 100644
--- a/include/linux/sunrpc/rpc_pipe_fs.h
+++ b/include/linux/sunrpc/rpc_pipe_fs.h
@@ -45,7 +45,7 @@ RPC_I(struct inode *inode)
 extern int rpc_queue_upcall(struct inode *, struct rpc_pipe_msg *);
 
 struct rpc_clnt;
-extern struct dentry *rpc_create_client_dir(const char *, struct rpc_clnt *);
+extern struct dentry *rpc_create_client_dir(struct dentry *, struct qstr *, struct rpc_clnt *);
 extern int rpc_remove_client_dir(struct dentry *);
 extern struct dentry *rpc_mkpipe(struct dentry *, const char *, void *,
 				 const struct rpc_pipe_ops *, int flags);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index b3f8633..c1e467e 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -27,6 +27,8 @@
 #include <linux/types.h>
 #include <linux/kallsyms.h>
 #include <linux/mm.h>
+#include <linux/namei.h>
+#include <linux/mount.h>
 #include <linux/slab.h>
 #include <linux/utsname.h>
 #include <linux/workqueue.h>
@@ -97,6 +99,12 @@ static int
 rpc_setup_pipedir(struct rpc_clnt *clnt, char *dir_name)
 {
 	static uint32_t clntid;
+	struct nameidata nd;
+	struct path path;
+	char name[15];
+	struct qstr q = {
+		.name = name,
+	};
 	int error;
 
 	clnt->cl_path.mnt = ERR_PTR(-ENOENT);
@@ -104,26 +112,36 @@ rpc_setup_pipedir(struct rpc_clnt *clnt, char *dir_name)
 	if (dir_name == NULL)
 		return 0;
 
-	clnt->cl_path.mnt = rpc_get_mount();
-	if (IS_ERR(clnt->cl_path.mnt))
-		return PTR_ERR(clnt->cl_path.mnt);
+	path.mnt = rpc_get_mount();
+	if (IS_ERR(path.mnt))
+		return PTR_ERR(path.mnt);
+	error = vfs_path_lookup(path.mnt->mnt_root, path.mnt, dir_name, 0, &nd);
+	if (error)
+		goto err;
 
 	for (;;) {
-		snprintf(clnt->cl_pathname, sizeof(clnt->cl_pathname),
-				"%s/clnt%x", dir_name,
-				(unsigned int)clntid++);
-		clnt->cl_pathname[sizeof(clnt->cl_pathname) - 1] = '\0';
-		clnt->cl_path.dentry = rpc_create_client_dir(clnt->cl_pathname, clnt);
-		if (!IS_ERR(clnt->cl_path.dentry))
-			return 0;
-		error = PTR_ERR(clnt->cl_path.dentry);
+		q.len = snprintf(name, sizeof(name), "clnt%x", (unsigned int)clntid++);
+		name[sizeof(name) - 1] = '\0';
+		q.hash = full_name_hash(q.name, q.len);
+		path.dentry = rpc_create_client_dir(nd.path.dentry, &q, clnt);
+		if (!IS_ERR(path.dentry))
+			break;
+		error = PTR_ERR(path.dentry);
 		if (error != -EEXIST) {
-			printk(KERN_INFO "RPC: Couldn't create pipefs entry %s, error %d\n",
-					clnt->cl_pathname, error);
-			rpc_put_mount();
-			return error;
+			printk(KERN_INFO "RPC: Couldn't create pipefs entry"
+					" %s/%s, error %d\n",
+					dir_name, name, error);
+			goto err_path_put;
 		}
 	}
+	path_put(&nd.path);
+	clnt->cl_path = path;
+	return 0;
+err_path_put:
+	path_put(&nd.path);
+err:
+	rpc_put_mount();
+	return error;
 }
 
 static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, struct rpc_xprt *xprt)
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 6d152f6..1613d85 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -443,42 +443,6 @@ static const struct dentry_operations rpc_dentry_operations = {
 	.d_delete = rpc_delete_dentry,
 };
 
-static int __rpc_lookup_path(const char *pathname, unsigned flags,
-			     struct nameidata *nd)
-{
-	struct vfsmount *mnt;
-
-	if (pathname[0] == '\0')
-		return -ENOENT;
-
-	mnt = rpc_get_mount();
-	if (IS_ERR(mnt)) {
-		printk(KERN_WARNING "%s: %s failed to mount "
-			       "pseudofilesystem \n", __FILE__, __func__);
-		return PTR_ERR(mnt);
-	}
-
-	if (vfs_path_lookup(mnt->mnt_root, mnt, pathname, flags, nd)) {
-		printk(KERN_WARNING "%s: %s failed to find path %s\n",
-				__FILE__, __func__, pathname);
-		rpc_put_mount();
-		return -ENOENT;
-	}
-	return 0;
-}
-
-static int rpc_lookup_parent(const char *pathname, struct nameidata *nd)
-{
-	return __rpc_lookup_path(pathname, LOOKUP_PARENT, nd);
-}
-
-static void
-rpc_release_path(struct nameidata *nd)
-{
-	path_put(&nd->path);
-	rpc_put_mount();
-}
-
 static struct inode *
 rpc_get_inode(struct super_block *sb, umode_t mode)
 {
@@ -889,27 +853,11 @@ EXPORT_SYMBOL_GPL(rpc_unlink);
  * information about the client, together with any "pipes" that may
  * later be created using rpc_mkpipe().
  */
-struct dentry *rpc_create_client_dir(const char *path,
+struct dentry *rpc_create_client_dir(struct dentry *dentry,
+				     struct qstr *name,
 				     struct rpc_clnt *rpc_client)
 {
-	struct nameidata nd;
-	struct dentry *ret;
-	struct inode *dir;
-
-	ret = ERR_PTR(rpc_lookup_parent(path, &nd));
-	if (IS_ERR(ret))
-		goto out_err;
-	dir = nd.path.dentry->d_inode;
-
-	ret = rpc_mkdir_populate(nd.path.dentry, &nd.last,
-			S_IRUGO | S_IXUGO, rpc_client);
-	rpc_release_path(&nd);
-	if (!IS_ERR(ret))
-		return ret;
-out_err:
-	printk(KERN_WARNING "%s: %s() failed to create directory %s (errno = %ld)\n",
-			__FILE__, __func__, path, PTR_ERR(ret));
-	return ret;
+	return rpc_mkdir_populate(dentry, name, S_IRUGO | S_IXUGO, rpc_client);
 }
 
 /*
-- 
1.6.0.4
