From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 16/32] SUNRPC: Clean up rpc_create_client_dir()
Date: Wed, 19 Aug 2009 19:38:39 -0400
Message-ID: <1250725135-14632-17-git-send-email-Trond.Myklebust@netapp.com>
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
Mime-Version: 1.0
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51423 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754129AbZHSXlB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Aug 2009 19:41:01 -0400
Received: from svlrsexc2-prd.hq.netapp.com (svlrsexc2-prd.hq.netapp.com [10.57.115.31])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n7JNe7YH028517
	for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2009 16:40:48 -0700 (PDT)
In-Reply-To: <1250725135-14632-16-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Factor out the code that does lookups from the code that actually creates
the directory.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/rpc_pipe.c |   83 ++++++++++++++++++++++++-------------------------
 1 files changed, 41 insertions(+), 42 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 08580be..6d152f6 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -639,26 +639,6 @@ static struct dentry *__rpc_lookup_create_exclusive(struct dentry *parent,
 	return ERR_PTR(-EEXIST);
 }
 
-static struct dentry *rpc_lookup_negative(const char *path,
-					  struct nameidata *nd)
-{
-	struct inode *dir;
-	struct dentry *dentry;
-	int error;
-
-	error = rpc_lookup_parent(path, nd);
-	if (error != 0)
-		return ERR_PTR(error);
-	dir = nd->path.dentry->d_inode;
-	mutex_lock_nested(&dir->i_mutex, I_MUTEX_PARENT);
-	dentry = __rpc_lookup_create_exclusive(nd->path.dentry, &nd->last);
-	if (IS_ERR(dentry)) {
-		mutex_unlock(&dir->i_mutex);
-		rpc_release_path(nd);
-	}
-	return dentry;
-}
-
 /*
  * FIXME: This probably has races.
  */
@@ -754,44 +734,30 @@ out_bad:
 	return err;
 }
 
-/**
- * rpc_create_client_dir - Create a new rpc_client directory in rpc_pipefs
- * @path: path from the rpc_pipefs root to the new directory
- * @rpc_client: rpc client to associate with this directory
- *
- * This creates a directory at the given @path associated with
- * @rpc_clnt, which will contain a file named "info" with some basic
- * information about the client, together with any "pipes" that may
- * later be created using rpc_mkpipe().
- */
-struct dentry *rpc_create_client_dir(const char *path,
-				     struct rpc_clnt *rpc_client)
+struct dentry *rpc_mkdir_populate(struct dentry *parent,
+		struct qstr *name, umode_t mode, void *private)
 {
-	struct nameidata nd;
 	struct dentry *dentry;
-	struct inode *dir;
+	struct inode *dir = parent->d_inode;
 	int error;
 
-	dentry = rpc_lookup_negative(path, &nd);
+	mutex_lock_nested(&dir->i_mutex, I_MUTEX_PARENT);
+	dentry = __rpc_lookup_create_exclusive(parent, name);
 	if (IS_ERR(dentry))
-		return dentry;
-	dir = nd.path.dentry->d_inode;
-	error = __rpc_mkdir(dir, dentry, S_IRUGO | S_IXUGO, NULL, rpc_client);
+		goto out;
+	error = __rpc_mkdir(dir, dentry, mode, NULL, private);
 	if (error != 0)
 		goto out_err;
 	error = rpc_populate(dentry, authfiles,
-			RPCAUTH_info, RPCAUTH_EOF, rpc_client);
+			RPCAUTH_info, RPCAUTH_EOF, private);
 	if (error)
 		goto err_rmdir;
 out:
 	mutex_unlock(&dir->i_mutex);
-	rpc_release_path(&nd);
 	return dentry;
 err_rmdir:
 	__rpc_rmdir(dir, dentry);
 out_err:
-	printk(KERN_WARNING "%s: %s() failed to create directory %s (errno = %d)\n",
-			__FILE__, __func__, path, error);
 	dentry = ERR_PTR(error);
 	goto out;
 }
@@ -913,6 +879,39 @@ rpc_unlink(struct dentry *dentry)
 }
 EXPORT_SYMBOL_GPL(rpc_unlink);
 
+/**
+ * rpc_create_client_dir - Create a new rpc_client directory in rpc_pipefs
+ * @path: path from the rpc_pipefs root to the new directory
+ * @rpc_client: rpc client to associate with this directory
+ *
+ * This creates a directory at the given @path associated with
+ * @rpc_clnt, which will contain a file named "info" with some basic
+ * information about the client, together with any "pipes" that may
+ * later be created using rpc_mkpipe().
+ */
+struct dentry *rpc_create_client_dir(const char *path,
+				     struct rpc_clnt *rpc_client)
+{
+	struct nameidata nd;
+	struct dentry *ret;
+	struct inode *dir;
+
+	ret = ERR_PTR(rpc_lookup_parent(path, &nd));
+	if (IS_ERR(ret))
+		goto out_err;
+	dir = nd.path.dentry->d_inode;
+
+	ret = rpc_mkdir_populate(nd.path.dentry, &nd.last,
+			S_IRUGO | S_IXUGO, rpc_client);
+	rpc_release_path(&nd);
+	if (!IS_ERR(ret))
+		return ret;
+out_err:
+	printk(KERN_WARNING "%s: %s() failed to create directory %s (errno = %ld)\n",
+			__FILE__, __func__, path, PTR_ERR(ret));
+	return ret;
+}
+
 /*
  * populate the filesystem
  */
-- 
1.6.0.4
