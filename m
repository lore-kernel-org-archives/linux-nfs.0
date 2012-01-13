Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:15836 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932766Ab2AMULe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 15:11:34 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 34/44] NFS: Move v4-only functions from dir.c
Date: Fri, 13 Jan 2012 15:10:43 -0500
Message-Id: <1326485453-1350-35-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
References: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/Makefile   |    3 +-
 fs/nfs/dir.c      |  331 +----------------------------------------------------
 fs/nfs/nfs.h      |    2 +
 fs/nfs/nfs4/dir.c |  327 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 335 insertions(+), 328 deletions(-)
 create mode 100644 fs/nfs/nfs4/dir.c

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 041f947..6bb7470 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -14,7 +14,8 @@ nfs-$(CONFIG_NFS_V4)	+= nfs4/proc.o nfs4/xdr.o nfs4/state.o nfs4/renewd.o \
 			   nfs4/callback.o nfs4/callback_xdr.o \
 			   nfs4/callback_proc.o nfs4/namespace.o \
 			   nfs4/client.o nfs4/module.o nfs4/sysctl.o \
-			   nfs4/getroot.o nfs4/inode.o nfs4/file.o
+			   nfs4/getroot.o nfs4/inode.o nfs4/file.o \
+			   nfs4/dir.o
 nfs-$(CONFIG_NFS_V4_1)	+= pnfs.o pnfs_dev.o
 nfs-$(CONFIG_SYSCTL) += sysctl.o
 nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index b72aab3..210284f 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -65,31 +65,6 @@ const struct address_space_operations nfs_dir_aops = {
 	.freepage = nfs_readdir_clear_array,
 };
 
-#ifdef CONFIG_NFS_V4
-
-static struct dentry *nfs_atomic_lookup(struct inode *, struct dentry *, struct nameidata *);
-static int nfs_open_create(struct inode *dir, struct dentry *dentry, int mode, struct nameidata *nd);
-const struct inode_operations nfs4_dir_inode_operations = {
-	.create		= nfs_open_create,
-	.lookup		= nfs_atomic_lookup,
-	.link		= nfs_link,
-	.unlink		= nfs_unlink,
-	.symlink	= nfs_symlink,
-	.mkdir		= nfs_mkdir,
-	.rmdir		= nfs_rmdir,
-	.mknod		= nfs_mknod,
-	.rename		= nfs_rename,
-	.permission	= nfs_permission,
-	.getattr	= nfs_getattr,
-	.setattr	= nfs_setattr,
-	.getxattr	= generic_getxattr,
-	.setxattr	= generic_setxattr,
-	.listxattr	= generic_listxattr,
-	.removexattr	= generic_removexattr,
-};
-
-#endif /* CONFIG_NFS_V4 */
-
 static struct nfs_open_dir_context *alloc_nfs_open_dir_context(struct inode *dir, struct rpc_cred *cred)
 {
 	struct nfs_open_dir_context *ctx;
@@ -971,11 +946,12 @@ static int nfs_check_verifier(struct inode *dir, struct dentry *dentry)
  * component of the path and none of them is set before that last
  * component.
  */
-static inline unsigned int nfs_lookup_check_intent(struct nameidata *nd,
+inline unsigned int nfs_lookup_check_intent(struct nameidata *nd,
 						unsigned int mask)
 {
 	return nd->flags & mask;
 }
+EXPORT_SYMBOL_GPL(nfs_lookup_check_intent);
 
 /*
  * Use intent information to check whether or not we're going to do
@@ -1027,7 +1003,7 @@ out_force:
  * If parent mtime has changed, we revalidate, else we wait for a
  * period corresponding to the parent's attribute cache timeout value.
  */
-static inline
+inline
 int nfs_neg_need_reval(struct inode *dir, struct dentry *dentry,
 		       struct nameidata *nd)
 {
@@ -1038,6 +1014,7 @@ int nfs_neg_need_reval(struct inode *dir, struct dentry *dentry,
 		return 1;
 	return !nfs_check_verifier(dir, dentry);
 }
+EXPORT_SYMBOL_GPL(nfs_neg_need_reval);
 
 /*
  * This is called every time the dcache has a lookup hit,
@@ -1280,306 +1257,6 @@ out:
 }
 EXPORT_SYMBOL_GPL(nfs_lookup);
 
-#ifdef CONFIG_NFS_V4
-static int nfs_open_revalidate(struct dentry *, struct nameidata *);
-
-const struct dentry_operations nfs4_dentry_operations = {
-	.d_revalidate	= nfs_open_revalidate,
-	.d_delete	= nfs_dentry_delete,
-	.d_iput		= nfs_dentry_iput,
-	.d_automount	= nfs_d_automount,
-	.d_release	= nfs_d_release,
-};
-
-/*
- * Use intent information to determine whether we need to substitute
- * the NFSv4-style stateful OPEN for the LOOKUP call
- */
-static int is_atomic_open(struct nameidata *nd)
-{
-	if (nd == NULL || nfs_lookup_check_intent(nd, LOOKUP_OPEN) == 0)
-		return 0;
-	/* NFS does not (yet) have a stateful open for directories */
-	if (nd->flags & LOOKUP_DIRECTORY)
-		return 0;
-	/* Are we trying to write to a read only partition? */
-	if (__mnt_is_readonly(nd->path.mnt) &&
-	    (nd->intent.open.flags & (O_CREAT|O_TRUNC|O_ACCMODE)))
-		return 0;
-	return 1;
-}
-
-static fmode_t flags_to_mode(int flags)
-{
-	fmode_t res = (__force fmode_t)flags & FMODE_EXEC;
-	if ((flags & O_ACCMODE) != O_WRONLY)
-		res |= FMODE_READ;
-	if ((flags & O_ACCMODE) != O_RDONLY)
-		res |= FMODE_WRITE;
-	return res;
-}
-
-static struct nfs_open_context *create_nfs_open_context(struct dentry *dentry, int open_flags)
-{
-	struct nfs_open_context *ctx;
-	struct rpc_cred *cred;
-	fmode_t fmode = flags_to_mode(open_flags);
-
-	cred = rpc_lookup_cred();
-	if (IS_ERR(cred))
-		return ERR_CAST(cred);
-	ctx = alloc_nfs_open_context(dentry, cred, fmode);
-	put_rpccred(cred);
-	if (ctx == NULL)
-		return ERR_PTR(-ENOMEM);
-	return ctx;
-}
-
-static int do_open(struct inode *inode, struct file *filp)
-{
-	nfs_fscache_set_inode_cookie(inode, filp);
-	return 0;
-}
-
-static int nfs_intent_set_file(struct nameidata *nd, struct nfs_open_context *ctx)
-{
-	struct file *filp;
-	int ret = 0;
-
-	/* If the open_intent is for execute, we have an extra check to make */
-	if (ctx->mode & FMODE_EXEC) {
-		ret = nfs_may_open(ctx->dentry->d_inode,
-				ctx->cred,
-				nd->intent.open.flags);
-		if (ret < 0)
-			goto out;
-	}
-	filp = lookup_instantiate_filp(nd, ctx->dentry, do_open);
-	if (IS_ERR(filp))
-		ret = PTR_ERR(filp);
-	else
-		nfs_file_set_open_context(filp, ctx);
-out:
-	put_nfs_open_context(ctx);
-	return ret;
-}
-
-static struct dentry *nfs_atomic_lookup(struct inode *dir, struct dentry *dentry, struct nameidata *nd)
-{
-	struct nfs_open_context *ctx;
-	struct iattr attr;
-	struct dentry *res = NULL;
-	struct inode *inode;
-	int open_flags;
-	int err;
-
-	dfprintk(VFS, "NFS: atomic_lookup(%s/%ld), %s\n",
-			dir->i_sb->s_id, dir->i_ino, dentry->d_name.name);
-
-	/* Check that we are indeed trying to open this file */
-	if (!is_atomic_open(nd))
-		goto no_open;
-
-	if (dentry->d_name.len > NFS_SERVER(dir)->namelen) {
-		res = ERR_PTR(-ENAMETOOLONG);
-		goto out;
-	}
-
-	/* Let vfs_create() deal with O_EXCL. Instantiate, but don't hash
-	 * the dentry. */
-	if (nd->flags & LOOKUP_EXCL) {
-		d_instantiate(dentry, NULL);
-		goto out;
-	}
-
-	open_flags = nd->intent.open.flags;
-
-	ctx = create_nfs_open_context(dentry, open_flags);
-	res = ERR_CAST(ctx);
-	if (IS_ERR(ctx))
-		goto out;
-
-	if (nd->flags & LOOKUP_CREATE) {
-		attr.ia_mode = nd->intent.open.create_mode;
-		attr.ia_valid = ATTR_MODE;
-		attr.ia_mode &= ~current_umask();
-	} else {
-		open_flags &= ~(O_EXCL | O_CREAT);
-		attr.ia_valid = 0;
-	}
-
-	/* Open the file on the server */
-	nfs_block_sillyrename(dentry->d_parent);
-	inode = NFS_PROTO(dir)->open_context(dir, ctx, open_flags, &attr);
-	if (IS_ERR(inode)) {
-		nfs_unblock_sillyrename(dentry->d_parent);
-		put_nfs_open_context(ctx);
-		switch (PTR_ERR(inode)) {
-			/* Make a negative dentry */
-			case -ENOENT:
-				d_add(dentry, NULL);
-				res = NULL;
-				goto out;
-			/* This turned out not to be a regular file */
-			case -EISDIR:
-			case -ENOTDIR:
-				goto no_open;
-			case -ELOOP:
-				if (!(nd->intent.open.flags & O_NOFOLLOW))
-					goto no_open;
-			/* case -EINVAL: */
-			default:
-				res = ERR_CAST(inode);
-				goto out;
-		}
-	}
-	res = d_add_unique(dentry, inode);
-	nfs_unblock_sillyrename(dentry->d_parent);
-	if (res != NULL) {
-		dput(ctx->dentry);
-		ctx->dentry = dget(res);
-		dentry = res;
-	}
-	err = nfs_intent_set_file(nd, ctx);
-	if (err < 0) {
-		if (res != NULL)
-			dput(res);
-		return ERR_PTR(err);
-	}
-out:
-	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
-	return res;
-no_open:
-	return nfs_lookup(dir, dentry, nd);
-}
-
-static int nfs_open_revalidate(struct dentry *dentry, struct nameidata *nd)
-{
-	struct dentry *parent = NULL;
-	struct inode *inode;
-	struct inode *dir;
-	struct nfs_open_context *ctx;
-	int openflags, ret = 0;
-
-	if (nd->flags & LOOKUP_RCU)
-		return -ECHILD;
-
-	inode = dentry->d_inode;
-	if (!is_atomic_open(nd) || d_mountpoint(dentry))
-		goto no_open;
-
-	parent = dget_parent(dentry);
-	dir = parent->d_inode;
-
-	/* We can't create new files in nfs_open_revalidate(), so we
-	 * optimize away revalidation of negative dentries.
-	 */
-	if (inode == NULL) {
-		if (!nfs_neg_need_reval(dir, dentry, nd))
-			ret = 1;
-		goto out;
-	}
-
-	/* NFS only supports OPEN on regular files */
-	if (!S_ISREG(inode->i_mode))
-		goto no_open_dput;
-	openflags = nd->intent.open.flags;
-	/* We cannot do exclusive creation on a positive dentry */
-	if ((openflags & (O_CREAT|O_EXCL)) == (O_CREAT|O_EXCL))
-		goto no_open_dput;
-	/* We can't create new files, or truncate existing ones here */
-	openflags &= ~(O_CREAT|O_EXCL|O_TRUNC);
-
-	ctx = create_nfs_open_context(dentry, openflags);
-	ret = PTR_ERR(ctx);
-	if (IS_ERR(ctx))
-		goto out;
-	/*
-	 * Note: we're not holding inode->i_mutex and so may be racing with
-	 * operations that change the directory. We therefore save the
-	 * change attribute *before* we do the RPC call.
-	 */
-	inode = NFS_PROTO(dir)->open_context(dir, ctx, openflags, NULL);
-	if (IS_ERR(inode)) {
-		ret = PTR_ERR(inode);
-		switch (ret) {
-		case -EPERM:
-		case -EACCES:
-		case -EDQUOT:
-		case -ENOSPC:
-		case -EROFS:
-			goto out_put_ctx;
-		default:
-			goto out_drop;
-		}
-	}
-	iput(inode);
-	if (inode != dentry->d_inode)
-		goto out_drop;
-
-	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
-	ret = nfs_intent_set_file(nd, ctx);
-	if (ret >= 0)
-		ret = 1;
-out:
-	dput(parent);
-	return ret;
-out_drop:
-	d_drop(dentry);
-	ret = 0;
-out_put_ctx:
-	put_nfs_open_context(ctx);
-	goto out;
-
-no_open_dput:
-	dput(parent);
-no_open:
-	return nfs_lookup_revalidate(dentry, nd);
-}
-
-static int nfs_open_create(struct inode *dir, struct dentry *dentry, int mode,
-		struct nameidata *nd)
-{
-	struct nfs_open_context *ctx = NULL;
-	struct iattr attr;
-	int error;
-	int open_flags = O_CREAT|O_EXCL;
-
-	dfprintk(VFS, "NFS: create(%s/%ld), %s\n",
-			dir->i_sb->s_id, dir->i_ino, dentry->d_name.name);
-
-	attr.ia_mode = mode;
-	attr.ia_valid = ATTR_MODE;
-
-	if (nd)
-		open_flags = nd->intent.open.flags;
-
-	ctx = create_nfs_open_context(dentry, open_flags);
-	error = PTR_ERR(ctx);
-	if (IS_ERR(ctx))
-		goto out_err_drop;
-
-	error = NFS_PROTO(dir)->create(dir, dentry, &attr, open_flags, ctx);
-	if (error != 0)
-		goto out_put_ctx;
-	if (nd) {
-		error = nfs_intent_set_file(nd, ctx);
-		if (error < 0)
-			goto out_err;
-	} else {
-		put_nfs_open_context(ctx);
-	}
-	return 0;
-out_put_ctx:
-	put_nfs_open_context(ctx);
-out_err_drop:
-	d_drop(dentry);
-out_err:
-	return error;
-}
-
-#endif /* CONFIG_NFSV4 */
-
 /*
  * Code common to create, mkdir, and mknod.
  */
diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
index cff0f23..2cdcbcf 100644
--- a/fs/nfs/nfs.h
+++ b/fs/nfs/nfs.h
@@ -72,6 +72,8 @@ int nfs_symlink(struct inode *, struct dentry *, const char *);
 int nfs_link(struct dentry *, struct inode *, struct dentry *);
 int nfs_rename(struct inode *, struct dentry *, struct inode *, struct dentry *);
 int nfs_permission(struct inode *, int);
+unsigned int nfs_lookup_check_intent(struct nameidata *, unsigned int);
+int nfs_neg_need_reval(struct inode *, struct dentry *, struct nameidata *);
 
 /* Exported in file.c */
 int nfs_check_flags(int);
diff --git a/fs/nfs/nfs4/dir.c b/fs/nfs/nfs4/dir.c
new file mode 100644
index 0000000..2d897f5
--- /dev/null
+++ b/fs/nfs/nfs4/dir.c
@@ -0,0 +1,327 @@
+
+#include <linux/nfs_fs.h>
+#include <linux/namei.h>
+
+#include "../internal.h"
+#include "../fscache.h"
+#include "delegation.h"
+#include "../nfs.h"
+#include "nfs4.h"
+
+static struct dentry *nfs_atomic_lookup(struct inode *, struct dentry *, struct nameidata *);
+static int nfs_open_create(struct inode *, struct dentry *, int, struct nameidata *);
+static int nfs_open_revalidate(struct dentry *, struct nameidata *);
+
+const struct inode_operations nfs4_dir_inode_operations = {
+	.create		= nfs_open_create,
+	.lookup		= nfs_atomic_lookup,
+	.link		= nfs_link,
+	.unlink		= nfs_unlink,
+	.symlink	= nfs_symlink,
+	.mkdir		= nfs_mkdir,
+	.rmdir		= nfs_rmdir,
+	.mknod		= nfs_mknod,
+	.rename		= nfs_rename,
+	.permission	= nfs_permission,
+	.getattr	= nfs_getattr,
+	.setattr	= nfs_setattr,
+	.getxattr	= generic_getxattr,
+	.setxattr	= generic_setxattr,
+	.listxattr	= generic_listxattr,
+	.removexattr	= generic_removexattr,
+};
+
+const struct dentry_operations nfs4_dentry_operations = {
+	.d_revalidate	= nfs_open_revalidate,
+	.d_delete	= nfs_dentry_delete,
+	.d_iput		= nfs_dentry_iput,
+	.d_automount	= nfs_d_automount,
+	.d_release	= nfs_d_release,
+};
+
+/*
+ * Use intent information to determine whether we need to substitute
+ * the NFSv4-style stateful OPEN for the LOOKUP call
+ */
+static int is_atomic_open(struct nameidata *nd)
+{
+	if (nd == NULL || nfs_lookup_check_intent(nd, LOOKUP_OPEN) == 0)
+		return 0;
+	/* NFS does not (yet) have a stateful open for directories */
+	if (nd->flags & LOOKUP_DIRECTORY)
+		return 0;
+	/* Are we trying to write to a read only partition? */
+	if (__mnt_is_readonly(nd->path.mnt) &&
+	    (nd->intent.open.flags & (O_CREAT|O_TRUNC|O_ACCMODE)))
+		return 0;
+	return 1;
+}
+
+static fmode_t flags_to_mode(int flags)
+{
+	fmode_t res = (__force fmode_t)flags & FMODE_EXEC;
+	if ((flags & O_ACCMODE) != O_WRONLY)
+		res |= FMODE_READ;
+	if ((flags & O_ACCMODE) != O_RDONLY)
+		res |= FMODE_WRITE;
+	return res;
+}
+
+static struct nfs_open_context *create_nfs_open_context(struct dentry *dentry, int open_flags)
+{
+	struct nfs_open_context *ctx;
+	struct rpc_cred *cred;
+	fmode_t fmode = flags_to_mode(open_flags);
+
+	cred = rpc_lookup_cred();
+	if (IS_ERR(cred))
+		return ERR_CAST(cred);
+	ctx = alloc_nfs_open_context(dentry, cred, fmode);
+	put_rpccred(cred);
+	if (ctx == NULL)
+		return ERR_PTR(-ENOMEM);
+	return ctx;
+}
+
+static int do_open(struct inode *inode, struct file *filp)
+{
+	nfs_fscache_set_inode_cookie(inode, filp);
+	return 0;
+}
+
+static int nfs_intent_set_file(struct nameidata *nd, struct nfs_open_context *ctx)
+{
+	struct file *filp;
+	int ret = 0;
+
+	/* If the open_intent is for execute, we have an extra check to make */
+	if (ctx->mode & FMODE_EXEC) {
+		ret = nfs_may_open(ctx->dentry->d_inode,
+				ctx->cred,
+				nd->intent.open.flags);
+		if (ret < 0)
+			goto out;
+	}
+	filp = lookup_instantiate_filp(nd, ctx->dentry, do_open);
+	if (IS_ERR(filp))
+		ret = PTR_ERR(filp);
+	else
+		nfs_file_set_open_context(filp, ctx);
+out:
+	put_nfs_open_context(ctx);
+	return ret;
+}
+
+static struct dentry *nfs_atomic_lookup(struct inode *dir, struct dentry *dentry, struct nameidata *nd)
+{
+	struct nfs_open_context *ctx;
+	struct iattr attr;
+	struct dentry *res = NULL;
+	struct inode *inode;
+	int open_flags;
+	int err;
+
+	dfprintk(VFS, "NFS: atomic_lookup(%s/%ld), %s\n",
+			dir->i_sb->s_id, dir->i_ino, dentry->d_name.name);
+
+	/* Check that we are indeed trying to open this file */
+	if (!is_atomic_open(nd))
+		goto no_open;
+
+	if (dentry->d_name.len > NFS_SERVER(dir)->namelen) {
+		res = ERR_PTR(-ENAMETOOLONG);
+		goto out;
+	}
+
+	/* Let vfs_create() deal with O_EXCL. Instantiate, but don't hash
+	 * the dentry. */
+	if (nd->flags & LOOKUP_EXCL) {
+		d_instantiate(dentry, NULL);
+		goto out;
+	}
+
+	open_flags = nd->intent.open.flags;
+
+	ctx = create_nfs_open_context(dentry, open_flags);
+	res = ERR_CAST(ctx);
+	if (IS_ERR(ctx))
+		goto out;
+
+	if (nd->flags & LOOKUP_CREATE) {
+		attr.ia_mode = nd->intent.open.create_mode;
+		attr.ia_valid = ATTR_MODE;
+		attr.ia_mode &= ~current_umask();
+	} else {
+		open_flags &= ~(O_EXCL | O_CREAT);
+		attr.ia_valid = 0;
+	}
+
+	/* Open the file on the server */
+	nfs_block_sillyrename(dentry->d_parent);
+	inode = NFS_PROTO(dir)->open_context(dir, ctx, open_flags, &attr);
+	if (IS_ERR(inode)) {
+		nfs_unblock_sillyrename(dentry->d_parent);
+		put_nfs_open_context(ctx);
+		switch (PTR_ERR(inode)) {
+			/* Make a negative dentry */
+			case -ENOENT:
+				d_add(dentry, NULL);
+				res = NULL;
+				goto out;
+			/* This turned out not to be a regular file */
+			case -EISDIR:
+			case -ENOTDIR:
+				goto no_open;
+			case -ELOOP:
+				if (!(nd->intent.open.flags & O_NOFOLLOW))
+					goto no_open;
+			/* case -EINVAL: */
+			default:
+				res = ERR_CAST(inode);
+				goto out;
+		}
+	}
+	res = d_add_unique(dentry, inode);
+	nfs_unblock_sillyrename(dentry->d_parent);
+	if (res != NULL) {
+		dput(ctx->dentry);
+		ctx->dentry = dget(res);
+		dentry = res;
+	}
+	err = nfs_intent_set_file(nd, ctx);
+	if (err < 0) {
+		if (res != NULL)
+			dput(res);
+		return ERR_PTR(err);
+	}
+out:
+	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
+	return res;
+no_open:
+	return nfs_lookup(dir, dentry, nd);
+}
+
+static int nfs_open_revalidate(struct dentry *dentry, struct nameidata *nd)
+{
+	struct dentry *parent = NULL;
+	struct inode *inode;
+	struct inode *dir;
+	struct nfs_open_context *ctx;
+	int openflags, ret = 0;
+
+	if (nd->flags & LOOKUP_RCU)
+		return -ECHILD;
+
+	inode = dentry->d_inode;
+	if (!is_atomic_open(nd) || d_mountpoint(dentry))
+		goto no_open;
+
+	parent = dget_parent(dentry);
+	dir = parent->d_inode;
+
+	/* We can't create new files in nfs_open_revalidate(), so we
+	 * optimize away revalidation of negative dentries.
+	 */
+	if (inode == NULL) {
+		if (!nfs_neg_need_reval(dir, dentry, nd))
+			ret = 1;
+		goto out;
+	}
+
+	/* NFS only supports OPEN on regular files */
+	if (!S_ISREG(inode->i_mode))
+		goto no_open_dput;
+	openflags = nd->intent.open.flags;
+	/* We cannot do exclusive creation on a positive dentry */
+	if ((openflags & (O_CREAT|O_EXCL)) == (O_CREAT|O_EXCL))
+		goto no_open_dput;
+	/* We can't create new files, or truncate existing ones here */
+	openflags &= ~(O_CREAT|O_EXCL|O_TRUNC);
+
+	ctx = create_nfs_open_context(dentry, openflags);
+	ret = PTR_ERR(ctx);
+	if (IS_ERR(ctx))
+		goto out;
+	/*
+	 * Note: we're not holding inode->i_mutex and so may be racing with
+	 * operations that change the directory. We therefore save the
+	 * change attribute *before* we do the RPC call.
+	 */
+	inode = NFS_PROTO(dir)->open_context(dir, ctx, openflags, NULL);
+	if (IS_ERR(inode)) {
+		ret = PTR_ERR(inode);
+		switch (ret) {
+		case -EPERM:
+		case -EACCES:
+		case -EDQUOT:
+		case -ENOSPC:
+		case -EROFS:
+			goto out_put_ctx;
+		default:
+			goto out_drop;
+		}
+	}
+	iput(inode);
+	if (inode != dentry->d_inode)
+		goto out_drop;
+
+	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
+	ret = nfs_intent_set_file(nd, ctx);
+	if (ret >= 0)
+		ret = 1;
+out:
+	dput(parent);
+	return ret;
+out_drop:
+	d_drop(dentry);
+	ret = 0;
+out_put_ctx:
+	put_nfs_open_context(ctx);
+	goto out;
+
+no_open_dput:
+	dput(parent);
+no_open:
+	return nfs_lookup_revalidate(dentry, nd);
+}
+
+static int nfs_open_create(struct inode *dir, struct dentry *dentry, int mode,
+		struct nameidata *nd)
+{
+	struct nfs_open_context *ctx = NULL;
+	struct iattr attr;
+	int error;
+	int open_flags = O_CREAT|O_EXCL;
+
+	dfprintk(VFS, "NFS: create(%s/%ld), %s\n",
+			dir->i_sb->s_id, dir->i_ino, dentry->d_name.name);
+
+	attr.ia_mode = mode;
+	attr.ia_valid = ATTR_MODE;
+
+	if (nd)
+		open_flags = nd->intent.open.flags;
+
+	ctx = create_nfs_open_context(dentry, open_flags);
+	error = PTR_ERR(ctx);
+	if (IS_ERR(ctx))
+		goto out_err_drop;
+
+	error = NFS_PROTO(dir)->create(dir, dentry, &attr, open_flags, ctx);
+	if (error != 0)
+		goto out_put_ctx;
+	if (nd) {
+		error = nfs_intent_set_file(nd, ctx);
+		if (error < 0)
+			goto out_err;
+	} else {
+		put_nfs_open_context(ctx);
+	}
+	return 0;
+out_put_ctx:
+	put_nfs_open_context(ctx);
+out_err_drop:
+	d_drop(dentry);
+out_err:
+	return error;
+}
-- 
1.7.8.3

