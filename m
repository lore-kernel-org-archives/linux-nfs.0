Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:36152 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752714AbbHaJJU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Aug 2015 05:09:20 -0400
Received: by pabpg12 with SMTP id pg12so375559pab.3
        for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2015 02:09:20 -0700 (PDT)
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH] nfs: Get lock context by fl_owner/fl_pid when unlocking file
Message-ID: <55E419B9.50905@gmail.com>
Date: Mon, 31 Aug 2015 17:09:13 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Whan a file unlocking is cuased by 'Ctrl + C', the current->files is NULL,
so that, nfs_get_lock_context always create a new lock context in do_unlk().

A new helper nfs_get_lock_context_by_owner requests the owner and pid
for searching and creating lock context.

Ps: I'm not sure it's needed in ->flush logical.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/file.c          |  3 ++-
 fs/nfs/inode.c         | 37 ++++++++++++++++++++++++++-----------
 include/linux/nfs_fs.h |  2 ++
 3 files changed, 30 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index cc4fa1e..85e01c7 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -774,7 +774,8 @@ do_unlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
 	 */
 	vfs_fsync(filp, 0);
 
-	l_ctx = nfs_get_lock_context(nfs_file_open_context(filp));
+	l_ctx = nfs_get_lock_context_by_owner(nfs_file_open_context(filp),
+					      fl->fl_owner, fl->fl_pid);
 	if (!IS_ERR(l_ctx)) {
 		status = nfs_iocounter_wait(&l_ctx->io_count);
 		nfs_put_lock_context(l_ctx);
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 0adc7d2..cbc1256 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -688,24 +688,26 @@ out:
 }
 EXPORT_SYMBOL_GPL(nfs_getattr);
 
-static void nfs_init_lock_context(struct nfs_lock_context *l_ctx)
+static void nfs_init_lock_context(struct nfs_lock_context *l_ctx,
+				  fl_owner_t owner, pid_t pid)
 {
 	atomic_set(&l_ctx->count, 1);
-	l_ctx->lockowner.l_owner = current->files;
-	l_ctx->lockowner.l_pid = current->tgid;
+	l_ctx->lockowner.l_owner = owner;
+	l_ctx->lockowner.l_pid = pid;
 	INIT_LIST_HEAD(&l_ctx->list);
 	nfs_iocounter_init(&l_ctx->io_count);
 }
 
-static struct nfs_lock_context *__nfs_find_lock_context(struct nfs_open_context *ctx)
+static struct nfs_lock_context *
+__nfs_find_lock_context(struct nfs_open_context *ctx, fl_owner_t owner, pid_t pid)
 {
 	struct nfs_lock_context *head = &ctx->lock_context;
 	struct nfs_lock_context *pos = head;
 
 	do {
-		if (pos->lockowner.l_owner != current->files)
+		if (pos->lockowner.l_owner != owner)
 			continue;
-		if (pos->lockowner.l_pid != current->tgid)
+		if (pos->lockowner.l_pid != pid)
 			continue;
 		atomic_inc(&pos->count);
 		return pos;
@@ -713,21 +715,22 @@ static struct nfs_lock_context *__nfs_find_lock_context(struct nfs_open_context
 	return NULL;
 }
 
-struct nfs_lock_context *nfs_get_lock_context(struct nfs_open_context *ctx)
+static struct nfs_lock_context *
+__nfs_get_lock_context(struct nfs_open_context *ctx, fl_owner_t owner, pid_t pid)
 {
 	struct nfs_lock_context *res, *new = NULL;
 	struct inode *inode = d_inode(ctx->dentry);
 
 	spin_lock(&inode->i_lock);
-	res = __nfs_find_lock_context(ctx);
+	res = __nfs_find_lock_context(ctx, owner, pid);
 	if (res == NULL) {
 		spin_unlock(&inode->i_lock);
 		new = kmalloc(sizeof(*new), GFP_KERNEL);
 		if (new == NULL)
 			return ERR_PTR(-ENOMEM);
-		nfs_init_lock_context(new);
+		nfs_init_lock_context(new, owner, pid);
 		spin_lock(&inode->i_lock);
-		res = __nfs_find_lock_context(ctx);
+		res = __nfs_find_lock_context(ctx, owner, pid);
 		if (res == NULL) {
 			list_add_tail(&new->list, &ctx->lock_context.list);
 			new->open_context = ctx;
@@ -739,8 +742,20 @@ struct nfs_lock_context *nfs_get_lock_context(struct nfs_open_context *ctx)
 	kfree(new);
 	return res;
 }
+
+struct nfs_lock_context *nfs_get_lock_context(struct nfs_open_context *ctx)
+{
+	return __nfs_get_lock_context(ctx, current->files, current->tgid);
+}
 EXPORT_SYMBOL_GPL(nfs_get_lock_context);
 
+struct nfs_lock_context *
+nfs_get_lock_context_by_owner(struct nfs_open_context *ctx, fl_owner_t owner, pid_t pid)
+{
+	return __nfs_get_lock_context(ctx, owner, pid);
+}
+EXPORT_SYMBOL_GPL(nfs_get_lock_context_by_owner);
+
 void nfs_put_lock_context(struct nfs_lock_context *l_ctx)
 {
 	struct nfs_open_context *ctx = l_ctx->open_context;
@@ -800,7 +815,7 @@ struct nfs_open_context *alloc_nfs_open_context(struct dentry *dentry, fmode_t f
 	ctx->mode = f_mode;
 	ctx->flags = 0;
 	ctx->error = 0;
-	nfs_init_lock_context(&ctx->lock_context);
+	nfs_init_lock_context(&ctx->lock_context, current->files, current->tgid);
 	ctx->lock_context.open_context = ctx;
 	INIT_LIST_HEAD(&ctx->list);
 	ctx->mdsthreshold = NULL;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 874b772..a13c16e5 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -372,6 +372,8 @@ extern struct nfs_open_context *alloc_nfs_open_context(struct dentry *dentry, fm
 extern void nfs_inode_attach_open_context(struct nfs_open_context *ctx);
 extern void nfs_file_set_open_context(struct file *filp, struct nfs_open_context *ctx);
 extern struct nfs_lock_context *nfs_get_lock_context(struct nfs_open_context *ctx);
+extern struct nfs_lock_context *nfs_get_lock_context_by_owner(
+		struct nfs_open_context *ctx, fl_owner_t owner, pid_t pid);
 extern void nfs_put_lock_context(struct nfs_lock_context *l_ctx);
 extern u64 nfs_compat_user_ino64(u64 fileid);
 extern void nfs_fattr_init(struct nfs_fattr *fattr);
-- 
2.4.3

