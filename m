From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 10/32] SUNRPC: Clean up file creation code in rpc_pipefs
Date: Wed, 19 Aug 2009 19:38:33 -0400
Message-ID: <1250725135-14632-11-git-send-email-Trond.Myklebust@netapp.com>
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
Mime-Version: 1.0
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32245 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753380AbZHSXk4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Aug 2009 19:40:56 -0400
Received: from sacrsexc1-prd.hq.netapp.com (sacrsexc1-prd.hq.netapp.com [10.99.115.27])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n7JNehbv001920
	for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2009 16:40:44 -0700 (PDT)
In-Reply-To: <1250725135-14632-10-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/rpc_pipe.c |  120 +++++++++++++++++++++++++++++++-----------------
 1 files changed, 77 insertions(+), 43 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 2940b92..d8c7815 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -539,6 +539,68 @@ rpc_get_inode(struct super_block *sb, umode_t mode)
 	return inode;
 }
 
+static int __rpc_create_common(struct inode *dir, struct dentry *dentry,
+			       umode_t mode,
+			       const struct file_operations *i_fop,
+			       void *private)
+{
+	struct inode *inode;
+
+	BUG_ON(!d_unhashed(dentry));
+	inode = rpc_get_inode(dir->i_sb, mode);
+	if (!inode)
+		goto out_err;
+	inode->i_ino = iunique(dir->i_sb, 100);
+	if (i_fop)
+		inode->i_fop = i_fop;
+	if (private)
+		rpc_inode_setowner(inode, private);
+	d_add(dentry, inode);
+	return 0;
+out_err:
+	printk(KERN_WARNING "%s: %s failed to allocate inode for dentry %s\n",
+			__FILE__, __func__, dentry->d_name.name);
+	dput(dentry);
+	return -ENOMEM;
+}
+
+static int __rpc_mkdir(struct inode *dir, struct dentry *dentry,
+		       umode_t mode,
+		       const struct file_operations *i_fop,
+		       void *private)
+{
+	int err;
+
+	err = __rpc_create_common(dir, dentry, S_IFDIR | mode, i_fop, private);
+	if (err)
+		return err;
+	inc_nlink(dir);
+	fsnotify_mkdir(dir, dentry);
+	return 0;
+}
+
+static int __rpc_mkpipe(struct inode *dir, struct dentry *dentry,
+			umode_t mode,
+			const struct file_operations *i_fop,
+			void *private,
+			const struct rpc_pipe_ops *ops,
+			int flags)
+{
+	struct rpc_inode *rpci;
+	int err;
+
+	err = __rpc_create_common(dir, dentry, S_IFIFO | mode, i_fop, private);
+	if (err)
+		return err;
+	rpci = RPC_I(dentry->d_inode);
+	rpci->nkern_readwriters = 1;
+	rpci->private = private;
+	rpci->flags = flags;
+	rpci->ops = ops;
+	fsnotify_create(dir, dentry);
+	return 0;
+}
+
 /*
  * FIXME: This probably has races.
  */
@@ -629,25 +691,6 @@ out_bad:
 }
 
 static int
-__rpc_mkdir(struct inode *dir, struct dentry *dentry)
-{
-	struct inode *inode;
-
-	inode = rpc_get_inode(dir->i_sb, S_IFDIR | S_IRUGO | S_IXUGO);
-	if (!inode)
-		goto out_err;
-	inode->i_ino = iunique(dir->i_sb, 100);
-	d_instantiate(dentry, inode);
-	inc_nlink(dir);
-	fsnotify_mkdir(dir, dentry);
-	return 0;
-out_err:
-	printk(KERN_WARNING "%s: %s failed to allocate inode for dentry %s\n",
-			__FILE__, __func__, dentry->d_name.name);
-	return -ENOMEM;
-}
-
-static int
 __rpc_rmdir(struct inode *dir, struct dentry *dentry)
 {
 	int error;
@@ -717,9 +760,9 @@ rpc_mkdir(char *path, struct rpc_clnt *rpc_client)
 	if (IS_ERR(dentry))
 		return dentry;
 	dir = nd.path.dentry->d_inode;
-	if ((error = __rpc_mkdir(dir, dentry)) != 0)
-		goto err_dput;
-	RPC_I(dentry->d_inode)->private = rpc_client;
+	error = __rpc_mkdir(dir, dentry, S_IRUGO | S_IXUGO, NULL, rpc_client);
+	if (error != 0)
+		goto out_err;
 	error = rpc_populate(dentry, authfiles,
 			RPCAUTH_info, RPCAUTH_EOF);
 	if (error)
@@ -732,8 +775,7 @@ out:
 err_depopulate:
 	rpc_depopulate(dentry, RPCAUTH_info, RPCAUTH_EOF);
 	__rpc_rmdir(dir, dentry);
-err_dput:
-	dput(dentry);
+out_err:
 	printk(KERN_WARNING "%s: %s() failed to create directory %s (errno = %d)\n",
 			__FILE__, __func__, path, error);
 	dentry = ERR_PTR(error);
@@ -787,9 +829,9 @@ struct dentry *rpc_mkpipe(struct dentry *parent, const char *name,
 			  int flags)
 {
 	struct dentry *dentry;
-	struct inode *dir, *inode;
-	struct rpc_inode *rpci;
+	struct inode *dir = parent->d_inode;
 	umode_t umode = S_IFIFO | S_IRUSR | S_IWUSR;
+	int err;
 
 	if (ops->upcall == NULL)
 		umode &= ~S_IRUGO;
@@ -801,7 +843,7 @@ struct dentry *rpc_mkpipe(struct dentry *parent, const char *name,
 		return dentry;
 	dir = parent->d_inode;
 	if (dentry->d_inode) {
-		rpci = RPC_I(dentry->d_inode);
+		struct rpc_inode *rpci = RPC_I(dentry->d_inode);
 		if (rpci->private != private ||
 				rpci->ops != ops ||
 				rpci->flags != flags) {
@@ -811,28 +853,20 @@ struct dentry *rpc_mkpipe(struct dentry *parent, const char *name,
 		rpci->nkern_readwriters++;
 		goto out;
 	}
-	inode = rpc_get_inode(dir->i_sb, umode);
-	if (!inode)
-		goto err_dput;
-	inode->i_ino = iunique(dir->i_sb, 100);
-	inode->i_fop = &rpc_pipe_fops;
-	d_instantiate(dentry, inode);
-	rpci = RPC_I(inode);
-	rpci->private = private;
-	rpci->flags = flags;
-	rpci->ops = ops;
-	rpci->nkern_readwriters = 1;
-	fsnotify_create(dir, dentry);
+
+	err = __rpc_mkpipe(dir, dentry, umode, &rpc_pipe_fops,
+			private, ops, flags);
+	if (err)
+		goto out_err;
 	dget(dentry);
 out:
 	mutex_unlock(&dir->i_mutex);
 	return dentry;
-err_dput:
-	dput(dentry);
-	dentry = ERR_PTR(-ENOMEM);
+out_err:
+	dentry = ERR_PTR(err);
 	printk(KERN_WARNING "%s: %s() failed to create pipe %s/%s (errno = %d)\n",
 			__FILE__, __func__, parent->d_name.name, name,
-			-ENOMEM);
+			err);
 	goto out;
 }
 EXPORT_SYMBOL_GPL(rpc_mkpipe);
-- 
1.6.0.4
