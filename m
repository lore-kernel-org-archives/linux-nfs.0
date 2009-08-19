From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 13/32] SUNRPC: Clean up rpc_populate/depopulate
Date: Wed, 19 Aug 2009 19:38:36 -0400
Message-ID: <1250725135-14632-14-git-send-email-Trond.Myklebust@netapp.com>
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
Mime-Version: 1.0
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32245 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754131AbZHSXlC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Aug 2009 19:41:02 -0400
Received: from svlrsexc1-prd.hq.netapp.com (svlrsexc1-prd.hq.netapp.com [10.57.115.30])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n7JNe90Z028534
	for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2009 16:40:51 -0700 (PDT)
In-Reply-To: <1250725135-14632-13-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/rpc_pipe.c |  187 ++++++++++++++++++++++++++----------------------
 1 files changed, 101 insertions(+), 86 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 3633851..e5f37de 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -401,7 +401,6 @@ static const struct file_operations rpc_info_operations = {
  * We have a single directory with 1 node in it.
  */
 enum {
-	RPCAUTH_Root = 1,
 	RPCAUTH_lockd,
 	RPCAUTH_mount,
 	RPCAUTH_nfs,
@@ -415,12 +414,12 @@ enum {
  * Description of fs contents.
  */
 struct rpc_filelist {
-	char *name;
+	const char *name;
 	const struct file_operations *i_fop;
 	umode_t mode;
 };
 
-static struct rpc_filelist files[] = {
+static const struct rpc_filelist files[] = {
 	[RPCAUTH_lockd] = {
 		.name = "lockd",
 		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
@@ -448,11 +447,11 @@ static struct rpc_filelist files[] = {
 };
 
 enum {
-	RPCAUTH_info = 2,
+	RPCAUTH_info,
 	RPCAUTH_EOF
 };
 
-static struct rpc_filelist authfiles[] = {
+static const struct rpc_filelist authfiles[] = {
 	[RPCAUTH_info] = {
 		.name = "info",
 		.i_fop = &rpc_info_operations,
@@ -564,6 +563,20 @@ out_err:
 	return -ENOMEM;
 }
 
+static int __rpc_create(struct inode *dir, struct dentry *dentry,
+			umode_t mode,
+			const struct file_operations *i_fop,
+			void *private)
+{
+	int err;
+
+	err = __rpc_create_common(dir, dentry, S_IFREG | mode, i_fop, private);
+	if (err)
+		return err;
+	fsnotify_create(dir, dentry);
+	return 0;
+}
+
 static int __rpc_mkdir(struct inode *dir, struct dentry *dentry,
 		       umode_t mode,
 		       const struct file_operations *i_fop,
@@ -601,6 +614,17 @@ static int __rpc_mkpipe(struct inode *dir, struct dentry *dentry,
 	return 0;
 }
 
+static int __rpc_rmdir(struct inode *dir, struct dentry *dentry)
+{
+	int ret;
+
+	dget(dentry);
+	ret = simple_rmdir(dir, dentry);
+	d_delete(dentry);
+	dput(dentry);
+	return ret;
+}
+
 static int __rpc_unlink(struct inode *dir, struct dentry *dentry)
 {
 	int ret;
@@ -678,100 +702,96 @@ static struct dentry *rpc_lookup_negative(const char *path,
 /*
  * FIXME: This probably has races.
  */
-static void rpc_depopulate(struct dentry *parent,
-			   unsigned long start, unsigned long eof)
+static void __rpc_depopulate(struct dentry *parent,
+			     const struct rpc_filelist *files,
+			     int start, int eof)
 {
 	struct inode *dir = parent->d_inode;
-	struct list_head *pos, *next;
-	struct dentry *dentry, *dvec[10];
-	int n = 0;
+	struct dentry *dentry;
+	struct qstr name;
+	int i;
 
-	mutex_lock_nested(&dir->i_mutex, I_MUTEX_CHILD);
-repeat:
-	spin_lock(&dcache_lock);
-	list_for_each_safe(pos, next, &parent->d_subdirs) {
-		dentry = list_entry(pos, struct dentry, d_u.d_child);
-		if (!dentry->d_inode ||
-				dentry->d_inode->i_ino < start ||
-				dentry->d_inode->i_ino >= eof)
+	for (i = start; i < eof; i++) {
+		name.name = files[i].name;
+		name.len = strlen(files[i].name);
+		name.hash = full_name_hash(name.name, name.len);
+		dentry = d_lookup(parent, &name);
+
+		if (dentry == NULL)
 			continue;
-		spin_lock(&dentry->d_lock);
-		if (!d_unhashed(dentry)) {
-			dget_locked(dentry);
-			__d_drop(dentry);
-			spin_unlock(&dentry->d_lock);
-			dvec[n++] = dentry;
-			if (n == ARRAY_SIZE(dvec))
+		if (dentry->d_inode == NULL)
+			goto next;
+		switch (dentry->d_inode->i_mode & S_IFMT) {
+			default:
+				BUG();
+			case S_IFREG:
+				__rpc_unlink(dir, dentry);
 				break;
-		} else
-			spin_unlock(&dentry->d_lock);
-	}
-	spin_unlock(&dcache_lock);
-	if (n) {
-		do {
-			dentry = dvec[--n];
-			if (S_ISREG(dentry->d_inode->i_mode))
-				simple_unlink(dir, dentry);
-			else if (S_ISDIR(dentry->d_inode->i_mode))
-				simple_rmdir(dir, dentry);
-			d_delete(dentry);
-			dput(dentry);
-		} while (n);
-		goto repeat;
+			case S_IFDIR:
+				__rpc_rmdir(dir, dentry);
+		}
+next:
+		dput(dentry);
 	}
+}
+
+static void rpc_depopulate(struct dentry *parent,
+			   const struct rpc_filelist *files,
+			   int start, int eof)
+{
+	struct inode *dir = parent->d_inode;
+
+	mutex_lock_nested(&dir->i_mutex, I_MUTEX_CHILD);
+	__rpc_depopulate(parent, files, start, eof);
 	mutex_unlock(&dir->i_mutex);
 }
 
-static int
-rpc_populate(struct dentry *parent,
-		struct rpc_filelist *files,
-		int start, int eof)
+static int rpc_populate(struct dentry *parent,
+			const struct rpc_filelist *files,
+			int start, int eof,
+			void *private)
 {
-	struct inode *inode, *dir = parent->d_inode;
-	void *private = RPC_I(dir)->private;
+	struct inode *dir = parent->d_inode;
 	struct dentry *dentry;
-	umode_t mode;
-	int i;
+	int i, err;
 
 	mutex_lock(&dir->i_mutex);
 	for (i = start; i < eof; i++) {
-		dentry = d_alloc_name(parent, files[i].name);
-		if (!dentry)
-			goto out_bad;
-		dentry->d_op = &rpc_dentry_operations;
-		mode = files[i].mode;
-		inode = rpc_get_inode(dir->i_sb, mode);
-		if (!inode) {
-			dput(dentry);
+		struct qstr q;
+
+		q.name = files[i].name;
+		q.len = strlen(files[i].name);
+		q.hash = full_name_hash(q.name, q.len);
+		dentry = __rpc_lookup_create_exclusive(parent, &q);
+		err = PTR_ERR(dentry);
+		if (IS_ERR(dentry))
 			goto out_bad;
+		switch (files[i].mode & S_IFMT) {
+			default:
+				BUG();
+			case S_IFREG:
+				err = __rpc_create(dir, dentry,
+						files[i].mode,
+						files[i].i_fop,
+						private);
+				break;
+			case S_IFDIR:
+				err = __rpc_mkdir(dir, dentry,
+						files[i].mode,
+						NULL,
+						private);
 		}
-		inode->i_ino = i;
-		if (files[i].i_fop)
-			inode->i_fop = files[i].i_fop;
-		if (private)
-			rpc_inode_setowner(inode, private);
-		if (S_ISDIR(mode))
-			inc_nlink(dir);
-		d_add(dentry, inode);
-		fsnotify_create(dir, dentry);
+		if (err != 0)
+			goto out_bad;
 	}
 	mutex_unlock(&dir->i_mutex);
 	return 0;
 out_bad:
+	__rpc_depopulate(parent, files, start, eof);
 	mutex_unlock(&dir->i_mutex);
 	printk(KERN_WARNING "%s: %s failed to populate directory %s\n",
 			__FILE__, __func__, parent->d_name.name);
-	return -ENOMEM;
-}
-
-static int
-__rpc_rmdir(struct inode *dir, struct dentry *dentry)
-{
-	int error;
-	error = simple_rmdir(dir, dentry);
-	if (!error)
-		d_delete(dentry);
-	return error;
+	return err;
 }
 
 /**
@@ -800,16 +820,14 @@ rpc_mkdir(char *path, struct rpc_clnt *rpc_client)
 	if (error != 0)
 		goto out_err;
 	error = rpc_populate(dentry, authfiles,
-			RPCAUTH_info, RPCAUTH_EOF);
+			RPCAUTH_info, RPCAUTH_EOF, rpc_client);
 	if (error)
-		goto err_depopulate;
-	dget(dentry);
+		goto err_rmdir;
 out:
 	mutex_unlock(&dir->i_mutex);
 	rpc_release_path(&nd);
 	return dentry;
-err_depopulate:
-	rpc_depopulate(dentry, RPCAUTH_info, RPCAUTH_EOF);
+err_rmdir:
 	__rpc_rmdir(dir, dentry);
 out_err:
 	printk(KERN_WARNING "%s: %s() failed to create directory %s (errno = %d)\n",
@@ -832,9 +850,8 @@ rpc_rmdir(struct dentry *dentry)
 	parent = dget_parent(dentry);
 	dir = parent->d_inode;
 	mutex_lock_nested(&dir->i_mutex, I_MUTEX_PARENT);
-	rpc_depopulate(dentry, RPCAUTH_info, RPCAUTH_EOF);
+	rpc_depopulate(dentry, authfiles, RPCAUTH_info, RPCAUTH_EOF);
 	error = __rpc_rmdir(dir, dentry);
-	dput(dentry);
 	mutex_unlock(&dir->i_mutex);
 	dput(parent);
 	return error;
@@ -900,7 +917,6 @@ struct dentry *rpc_mkpipe(struct dentry *parent, const char *name,
 			   private, ops, flags);
 	if (err)
 		goto out_err;
-	dget(dentry);
 out:
 	mutex_unlock(&dir->i_mutex);
 	return dentry;
@@ -932,7 +948,6 @@ rpc_unlink(struct dentry *dentry)
 	dir = parent->d_inode;
 	mutex_lock_nested(&dir->i_mutex, I_MUTEX_PARENT);
 	error = __rpc_rmpipe(dir, dentry);
-	dput(dentry);
 	mutex_unlock(&dir->i_mutex);
 	dput(parent);
 	return error;
@@ -970,7 +985,7 @@ rpc_fill_super(struct super_block *sb, void *data, int silent)
 		iput(inode);
 		return -ENOMEM;
 	}
-	if (rpc_populate(root, files, RPCAUTH_Root + 1, RPCAUTH_RootEOF))
+	if (rpc_populate(root, files, RPCAUTH_lockd, RPCAUTH_RootEOF, NULL))
 		goto out;
 	sb->s_root = root;
 	return 0;
-- 
1.6.0.4
