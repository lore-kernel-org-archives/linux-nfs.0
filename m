Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:35100 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750997AbcCASM6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Mar 2016 13:12:58 -0500
From: Goldwyn Rodrigues <rgoldwyn@suse.de>
To: miklos@szeredi.hu
Cc: linux-unionfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, Goldwyn Rodrigues <rgoldwyn@suse.com>
Subject: [PATCH 3/3] nfs: Store and use inode in nfs_open_context
Date: Tue,  1 Mar 2016 12:12:08 -0600
Message-Id: <1456855928-29913-4-git-send-email-rgoldwyn@suse.de>
In-Reply-To: <1456855928-29913-1-git-send-email-rgoldwyn@suse.de>
References: <1456855928-29913-1-git-send-email-rgoldwyn@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Goldwyn Rodrigues <rgoldwyn@suse.com>

NFS translates the inode from the dentry and uses sb from the dentry
parameters. However, using NFS in conjunction with overlayfs, the inodes
associated with dentries may be associated with overlayfs as opposed
to NFS. So, store inode in nfs_open_context and use d_select_inode()
to translate dentry to inode.

Signed-off-by: Goldwyn Rodrigues <rgoldwyn@suse.com>
---
 fs/nfs/dir.c           |  2 +-
 fs/nfs/inode.c         | 21 +++++++++++----------
 fs/nfs/nfs4file.c      |  2 +-
 fs/nfs/nfs4proc.c      |  2 +-
 include/linux/nfs_fs.h |  3 ++-
 5 files changed, 16 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 9cce670..a9e0ffd 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1446,7 +1446,7 @@ static fmode_t flags_to_mode(int flags)
 
 static struct nfs_open_context *create_nfs_open_context(struct dentry *dentry, int open_flags)
 {
-	return alloc_nfs_open_context(dentry, flags_to_mode(open_flags));
+	return alloc_nfs_open_context(dentry, d_select_inode(dentry, open_flags), flags_to_mode(open_flags));
 }
 
 static int do_open(struct inode *inode, struct file *filp)
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 86faecf..64fce4b 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -728,7 +728,7 @@ static struct nfs_lock_context *__nfs_find_lock_context(struct nfs_open_context
 struct nfs_lock_context *nfs_get_lock_context(struct nfs_open_context *ctx)
 {
 	struct nfs_lock_context *res, *new = NULL;
-	struct inode *inode = d_inode(ctx->dentry);
+	struct inode *inode = ctx->inode;
 
 	spin_lock(&inode->i_lock);
 	res = __nfs_find_lock_context(ctx);
@@ -756,7 +756,7 @@ EXPORT_SYMBOL_GPL(nfs_get_lock_context);
 void nfs_put_lock_context(struct nfs_lock_context *l_ctx)
 {
 	struct nfs_open_context *ctx = l_ctx->open_context;
-	struct inode *inode = d_inode(ctx->dentry);
+	struct inode *inode = ctx->inode;
 
 	if (!atomic_dec_and_lock(&l_ctx->count, &inode->i_lock))
 		return;
@@ -785,7 +785,7 @@ void nfs_close_context(struct nfs_open_context *ctx, int is_sync)
 		return;
 	if (!is_sync)
 		return;
-	inode = d_inode(ctx->dentry);
+	inode = ctx->inode;
 	nfsi = NFS_I(inode);
 	if (inode->i_mapping->nrpages == 0)
 		return;
@@ -800,7 +800,7 @@ void nfs_close_context(struct nfs_open_context *ctx, int is_sync)
 }
 EXPORT_SYMBOL_GPL(nfs_close_context);
 
-struct nfs_open_context *alloc_nfs_open_context(struct dentry *dentry, fmode_t f_mode)
+struct nfs_open_context *alloc_nfs_open_context(struct dentry *dentry, struct inode *inode, fmode_t f_mode)
 {
 	struct nfs_open_context *ctx;
 	struct rpc_cred *cred = rpc_lookup_cred();
@@ -812,8 +812,9 @@ struct nfs_open_context *alloc_nfs_open_context(struct dentry *dentry, fmode_t f
 		put_rpccred(cred);
 		return ERR_PTR(-ENOMEM);
 	}
-	nfs_sb_active(dentry->d_sb);
+	nfs_sb_active(inode->i_sb);
 	ctx->dentry = dget(dentry);
+	ctx->inode = inode;
 	ctx->cred = cred;
 	ctx->state = NULL;
 	ctx->mode = f_mode;
@@ -837,8 +838,8 @@ EXPORT_SYMBOL_GPL(get_nfs_open_context);
 
 static void __put_nfs_open_context(struct nfs_open_context *ctx, int is_sync)
 {
-	struct inode *inode = d_inode(ctx->dentry);
-	struct super_block *sb = ctx->dentry->d_sb;
+	struct inode *inode = ctx->inode;
+	struct super_block *sb = ctx->inode->i_sb;
 
 	if (!list_empty(&ctx->list)) {
 		if (!atomic_dec_and_lock(&ctx->lock_context.count, &inode->i_lock))
@@ -874,7 +875,7 @@ static void put_nfs_open_context_sync(struct nfs_open_context *ctx)
  */
 void nfs_inode_attach_open_context(struct nfs_open_context *ctx)
 {
-	struct inode *inode = d_inode(ctx->dentry);
+	struct inode *inode = ctx->inode;
 	struct nfs_inode *nfsi = NFS_I(inode);
 
 	spin_lock(&inode->i_lock);
@@ -917,7 +918,7 @@ void nfs_file_clear_open_context(struct file *filp)
 	struct nfs_open_context *ctx = nfs_file_open_context(filp);
 
 	if (ctx) {
-		struct inode *inode = d_inode(ctx->dentry);
+		struct inode *inode = ctx->inode;
 
 		/*
 		 * We fatal error on write before. Try to writeback
@@ -940,7 +941,7 @@ int nfs_open(struct inode *inode, struct file *filp)
 {
 	struct nfs_open_context *ctx;
 
-	ctx = alloc_nfs_open_context(filp->f_path.dentry, filp->f_mode);
+	ctx = alloc_nfs_open_context(filp->f_path.dentry, inode, filp->f_mode);
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
 	nfs_file_set_open_context(filp, ctx);
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 57ca1c8..c7be33d 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -57,7 +57,7 @@ nfs4_file_open(struct inode *inode, struct file *filp)
 	parent = dget_parent(dentry);
 	dir = d_inode(parent);
 
-	ctx = alloc_nfs_open_context(filp->f_path.dentry, filp->f_mode);
+	ctx = alloc_nfs_open_context(filp->f_path.dentry, inode, filp->f_mode);
 	err = PTR_ERR(ctx);
 	if (IS_ERR(ctx))
 		goto out;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1488159..57cffb9 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3707,7 +3707,7 @@ nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 	struct nfs4_state *state;
 	int status = 0;
 
-	ctx = alloc_nfs_open_context(dentry, FMODE_READ);
+	ctx = alloc_nfs_open_context(dentry, d_select_inode(dentry, flags), FMODE_READ);
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
 
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 67300f8..1f18164 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -72,6 +72,7 @@ struct nfs4_state;
 struct nfs_open_context {
 	struct nfs_lock_context lock_context;
 	struct dentry *dentry;
+	struct inode *inode;
 	struct rpc_cred *cred;
 	struct nfs4_state *state;
 	fmode_t mode;
@@ -361,7 +362,7 @@ extern void nfs_setsecurity(struct inode *inode, struct nfs_fattr *fattr,
 extern struct nfs_open_context *get_nfs_open_context(struct nfs_open_context *ctx);
 extern void put_nfs_open_context(struct nfs_open_context *ctx);
 extern struct nfs_open_context *nfs_find_open_context(struct inode *inode, struct rpc_cred *cred, fmode_t mode);
-extern struct nfs_open_context *alloc_nfs_open_context(struct dentry *dentry, fmode_t f_mode);
+extern struct nfs_open_context *alloc_nfs_open_context(struct dentry *dentry, struct inode *inode, fmode_t f_mode);
 extern void nfs_inode_attach_open_context(struct nfs_open_context *ctx);
 extern void nfs_file_set_open_context(struct file *filp, struct nfs_open_context *ctx);
 extern void nfs_file_clear_open_context(struct file *flip);
-- 
2.6.2

