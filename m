Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:5931 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932583Ab1CWSsc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Mar 2011 14:48:32 -0400
Message-ID: <4D8A407D.7060307@netapp.com>
Date: Wed, 23 Mar 2011 14:48:29 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 2/3] NFS: Create nfs_open_dir_context
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

nfs_opendir() created a context that held much more information than we
need for a readdir.  This patch introduces a slimmed-down
nfs_open_dir_context that contains only the cookie and the cred used for
RPC operations.  The new context will eventually be used to help detect
readdir loops.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/dir.c           |   54 +++++++++++++++++++++++++++++++++++++++++------
 fs/nfs/inode.c         |    1 -
 include/linux/nfs_fs.h |    3 ++
 3 files changed, 50 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index e9fa2c8..112494a 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -44,6 +44,7 @@
 /* #define NFS_DEBUG_VERBOSE 1 */
 
 static int nfs_opendir(struct inode *, struct file *);
+static int nfs_closedir(struct inode *, struct file *);
 static int nfs_readdir(struct file *, void *, filldir_t);
 static struct dentry *nfs_lookup(struct inode *, struct dentry *, struct nameidata *);
 static int nfs_create(struct inode *, struct dentry *, int, struct nameidata *);
@@ -64,7 +65,7 @@ const struct file_operations nfs_dir_operations = {
 	.read		= generic_read_dir,
 	.readdir	= nfs_readdir,
 	.open		= nfs_opendir,
-	.release	= nfs_release,
+	.release	= nfs_closedir,
 	.fsync		= nfs_fsync_dir,
 };
 
@@ -133,13 +134,33 @@ const struct inode_operations nfs4_dir_inode_operations = {
 
 #endif /* CONFIG_NFS_V4 */
 
+static struct nfs_open_dir_context *alloc_nfs_open_dir_context(struct rpc_cred *cred)
+{
+	struct nfs_open_dir_context *ctx;
+	ctx = kmalloc(sizeof(*ctx), GFP_KERNEL);
+	if (ctx != NULL) {
+		ctx->dir_cookie = 0;
+		ctx->cred = get_rpccred(cred);
+	} else
+		ctx = ERR_PTR(-ENOMEM);
+	return ctx;
+}
+
+static void put_nfs_open_dir_context(struct nfs_open_dir_context *ctx)
+{
+	put_rpccred(ctx->cred);
+	kfree(ctx);
+}
+
 /*
  * Open file
  */
 static int
 nfs_opendir(struct inode *inode, struct file *filp)
 {
-	int res;
+	int res = 0;
+	struct nfs_open_dir_context *ctx;
+	struct rpc_cred *cred;
 
 	dfprintk(FILE, "NFS: open dir(%s/%s)\n",
 			filp->f_path.dentry->d_parent->d_name.name,
@@ -147,8 +168,15 @@ nfs_opendir(struct inode *inode, struct file *filp)
 
 	nfs_inc_stats(inode, NFSIOS_VFSOPEN);
 
-	/* Call generic open code in order to cache credentials */
-	res = nfs_open(inode, filp);
+	cred = rpc_lookup_cred();
+	if (IS_ERR(cred))
+		return PTR_ERR(cred);
+	ctx = alloc_nfs_open_dir_context(cred);
+	if (IS_ERR(ctx)) {
+		res = PTR_ERR(ctx);
+		goto out;
+	}
+	filp->private_data = ctx;
 	if (filp->f_path.dentry == filp->f_path.mnt->mnt_root) {
 		/* This is a mountpoint, so d_revalidate will never
 		 * have been called, so we need to refresh the
@@ -156,9 +184,18 @@ nfs_opendir(struct inode *inode, struct file *filp)
 		 */
 		__nfs_revalidate_inode(NFS_SERVER(inode), inode);
 	}
+out:
+	put_rpccred(cred);
 	return res;
 }
 
+static int
+nfs_closedir(struct inode *inode, struct file *filp)
+{
+	put_nfs_open_dir_context(filp->private_data);
+	return 0;
+}
+
 struct nfs_cache_array_entry {
 	u64 cookie;
 	u64 ino;
@@ -355,7 +392,8 @@ static
 int nfs_readdir_xdr_filler(struct page **pages, nfs_readdir_descriptor_t *desc,
 			struct nfs_entry *entry, struct file *file, struct inode *inode)
 {
-	struct rpc_cred	*cred = nfs_file_cred(file);
+	struct nfs_open_dir_context *ctx = file->private_data;
+	struct rpc_cred	*cred = ctx->cred;
 	unsigned long	timestamp, gencount;
 	int		error;
 
@@ -786,6 +824,7 @@ static int nfs_readdir(struct file *filp, void *dirent, filldir_t filldir)
 	struct inode	*inode = dentry->d_inode;
 	nfs_readdir_descriptor_t my_desc,
 			*desc = &my_desc;
+	struct nfs_open_dir_context *dir_ctx = filp->private_data;
 	int res;
 
 	dfprintk(FILE, "NFS: readdir(%s/%s) starting at cookie %llu\n",
@@ -802,7 +841,7 @@ static int nfs_readdir(struct file *filp, void *dirent, filldir_t filldir)
 	memset(desc, 0, sizeof(*desc));
 
 	desc->file = filp;
-	desc->dir_cookie = &nfs_file_open_context(filp)->dir_cookie;
+	desc->dir_cookie = &dir_ctx->dir_cookie;
 	desc->decode = NFS_PROTO(inode)->decode_dirent;
 	desc->plus = NFS_USE_READDIRPLUS(inode);
 
@@ -854,6 +893,7 @@ static loff_t nfs_llseek_dir(struct file *filp, loff_t offset, int origin)
 {
 	struct dentry *dentry = filp->f_path.dentry;
 	struct inode *inode = dentry->d_inode;
+	struct nfs_open_dir_context *dir_ctx = filp->private_data;
 
 	dfprintk(FILE, "NFS: llseek dir(%s/%s, %lld, %d)\n",
 			dentry->d_parent->d_name.name,
@@ -873,7 +913,7 @@ static loff_t nfs_llseek_dir(struct file *filp, loff_t offset, int origin)
 	}
 	if (offset != filp->f_pos) {
 		filp->f_pos = offset;
-		nfs_file_open_context(filp)->dir_cookie = 0;
+		dir_ctx->dir_cookie = 0;
 	}
 out:
 	mutex_unlock(&inode->i_mutex);
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 01768e5..366f5f7 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -639,7 +639,6 @@ struct nfs_open_context *alloc_nfs_open_context(struct path *path, struct rpc_cr
 		ctx->mode = f_mode;
 		ctx->flags = 0;
 		ctx->error = 0;
-		ctx->dir_cookie = 0;
 		nfs_init_lock_context(&ctx->lock_context);
 		ctx->lock_context.open_context = ctx;
 		INIT_LIST_HEAD(&ctx->list);
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index f88522b..4b87c00 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -93,7 +93,10 @@ struct nfs_open_context {
 	int error;
 
 	struct list_head list;
+};
 
+struct nfs_open_dir_context {
+	struct rpc_cred *cred;
 	__u64 dir_cookie;
 };
 
-- 
1.7.4.1

