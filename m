From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 19/32] SUNRPC: One more clean up for rpc_create_client_dir()
Date: Wed, 19 Aug 2009 19:38:42 -0400
Message-ID: <1250725135-14632-20-git-send-email-Trond.Myklebust@netapp.com>
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
	 <1250725135-14632-19-git-send-email-Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39738 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754060AbZHSXky (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Aug 2009 19:40:54 -0400
Received: from sacrsexc2-prd.hq.netapp.com (sacrsexc2-prd.hq.netapp.com [10.99.115.28])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n7JNePRL001724
	for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2009 16:40:42 -0700 (PDT)
In-Reply-To: <1250725135-14632-19-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In order to allow rpc_pipefs to create directories with different types of
subtrees, it is useful to allow the caller to customise the subtree filling
process.
In order to do so, we separate out the parts which are specific to making
an RPC client directory, and put them in a separate helper, then we convert
the process of filling the directory contents into a callback.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/rpc_pipe.c |   78 +++++++++++++++++++++++++++++++-----------------
 1 files changed, 50 insertions(+), 28 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 1613d85..57e9cd3 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -406,19 +406,6 @@ struct rpc_filelist {
 	umode_t mode;
 };
 
-enum {
-	RPCAUTH_info,
-	RPCAUTH_EOF
-};
-
-static const struct rpc_filelist authfiles[] = {
-	[RPCAUTH_info] = {
-		.name = "info",
-		.i_fop = &rpc_info_operations,
-		.mode = S_IFREG | S_IRUSR,
-	},
-};
-
 struct vfsmount *rpc_get_mount(void)
 {
 	int err;
@@ -698,8 +685,9 @@ out_bad:
 	return err;
 }
 
-struct dentry *rpc_mkdir_populate(struct dentry *parent,
-		struct qstr *name, umode_t mode, void *private)
+static struct dentry *rpc_mkdir_populate(struct dentry *parent,
+		struct qstr *name, umode_t mode, void *private,
+		int (*populate)(struct dentry *, void *), void *args_populate)
 {
 	struct dentry *dentry;
 	struct inode *dir = parent->d_inode;
@@ -712,10 +700,11 @@ struct dentry *rpc_mkdir_populate(struct dentry *parent,
 	error = __rpc_mkdir(dir, dentry, mode, NULL, private);
 	if (error != 0)
 		goto out_err;
-	error = rpc_populate(dentry, authfiles,
-			RPCAUTH_info, RPCAUTH_EOF, private);
-	if (error)
-		goto err_rmdir;
+	if (populate != NULL) {
+		error = populate(dentry, args_populate);
+		if (error)
+			goto err_rmdir;
+	}
 out:
 	mutex_unlock(&dir->i_mutex);
 	return dentry;
@@ -726,11 +715,8 @@ out_err:
 	goto out;
 }
 
-/**
- * rpc_remove_client_dir - Remove a directory created with rpc_create_client_dir()
- * @dentry: directory to remove
- */
-int rpc_remove_client_dir(struct dentry *dentry)
+static int rpc_rmdir_depopulate(struct dentry *dentry,
+		void (*depopulate)(struct dentry *))
 {
 	struct dentry *parent;
 	struct inode *dir;
@@ -739,7 +725,8 @@ int rpc_remove_client_dir(struct dentry *dentry)
 	parent = dget_parent(dentry);
 	dir = parent->d_inode;
 	mutex_lock_nested(&dir->i_mutex, I_MUTEX_PARENT);
-	rpc_depopulate(dentry, authfiles, RPCAUTH_info, RPCAUTH_EOF);
+	if (depopulate != NULL)
+		depopulate(dentry);
 	error = __rpc_rmdir(dir, dentry);
 	mutex_unlock(&dir->i_mutex);
 	dput(parent);
@@ -843,6 +830,31 @@ rpc_unlink(struct dentry *dentry)
 }
 EXPORT_SYMBOL_GPL(rpc_unlink);
 
+enum {
+	RPCAUTH_info,
+	RPCAUTH_EOF
+};
+
+static const struct rpc_filelist authfiles[] = {
+	[RPCAUTH_info] = {
+		.name = "info",
+		.i_fop = &rpc_info_operations,
+		.mode = S_IFREG | S_IRUSR,
+	},
+};
+
+static int rpc_clntdir_populate(struct dentry *dentry, void *private)
+{
+	return rpc_populate(dentry,
+			    authfiles, RPCAUTH_info, RPCAUTH_EOF,
+			    private);
+}
+
+static void rpc_clntdir_depopulate(struct dentry *dentry)
+{
+	rpc_depopulate(dentry, authfiles, RPCAUTH_info, RPCAUTH_EOF);
+}
+
 /**
  * rpc_create_client_dir - Create a new rpc_client directory in rpc_pipefs
  * @path: path from the rpc_pipefs root to the new directory
@@ -854,10 +866,20 @@ EXPORT_SYMBOL_GPL(rpc_unlink);
  * later be created using rpc_mkpipe().
  */
 struct dentry *rpc_create_client_dir(struct dentry *dentry,
-				     struct qstr *name,
-				     struct rpc_clnt *rpc_client)
+				   struct qstr *name,
+				   struct rpc_clnt *rpc_client)
+{
+	return rpc_mkdir_populate(dentry, name, S_IRUGO | S_IXUGO, NULL,
+			rpc_clntdir_populate, rpc_client);
+}
+
+/**
+ * rpc_remove_client_dir - Remove a directory created with rpc_create_client_dir()
+ * @dentry: directory to remove
+ */
+int rpc_remove_client_dir(struct dentry *dentry)
 {
-	return rpc_mkdir_populate(dentry, name, S_IRUGO | S_IXUGO, rpc_client);
+	return rpc_rmdir_depopulate(dentry, rpc_clntdir_depopulate);
 }
 
 /*
-- 
1.6.0.4
