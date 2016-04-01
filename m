Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43537 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752218AbcDARRi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Apr 2016 13:17:38 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/3 V2] NFS: add get_nfs_lock_context, find_nfs_lock_context
Date: Fri,  1 Apr 2016 13:17:35 -0400
Message-Id: <46fdbda936966a105e4c019226a41dacb3ae7948.1459530606.git.bcodding@redhat.com>
In-Reply-To: <cover.1459530606.git.bcodding@redhat.com>
References: <cover.1459530606.git.bcodding@redhat.com>
In-Reply-To: <cover.1459530606.git.bcodding@redhat.com>
References: <cover.1459530606.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Create a method for acquiring a nfs_lock_context reference which
will be used later within fscache, and rename nfs_get_lock_context to
nfs_find_lock_context to prepare it for finding or allocating a lock
context based upon a file pointer.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/direct.c        |    4 ++--
 fs/nfs/file.c          |    2 +-
 fs/nfs/inode.c         |   11 +++++++++--
 fs/nfs/nfs42proc.c     |    8 ++++----
 fs/nfs/pagelist.c      |    2 +-
 include/linux/nfs_fs.h |    3 ++-
 6 files changed, 19 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 7a0cfd3..5f833fa 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -596,7 +596,7 @@ ssize_t nfs_file_direct_read(struct kiocb *iocb, struct iov_iter *iter,
 	dreq->bytes_left = count;
 	dreq->io_start = pos;
 	dreq->ctx = get_nfs_open_context(nfs_file_open_context(iocb->ki_filp));
-	l_ctx = nfs_get_lock_context(dreq->ctx);
+	l_ctx = nfs_find_lock_context(dreq->ctx);
 	if (IS_ERR(l_ctx)) {
 		result = PTR_ERR(l_ctx);
 		goto out_release;
@@ -1029,7 +1029,7 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter)
 	dreq->bytes_left = iov_iter_count(iter);
 	dreq->io_start = pos;
 	dreq->ctx = get_nfs_open_context(nfs_file_open_context(iocb->ki_filp));
-	l_ctx = nfs_get_lock_context(dreq->ctx);
+	l_ctx = nfs_find_lock_context(dreq->ctx);
 	if (IS_ERR(l_ctx)) {
 		result = PTR_ERR(l_ctx);
 		goto out_release;
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 89bf093..2ad3bb6 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -756,7 +756,7 @@ do_unlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
 	 */
 	vfs_fsync(filp, 0);
 
-	l_ctx = nfs_get_lock_context(nfs_file_open_context(filp));
+	l_ctx = nfs_find_lock_context(nfs_file_open_context(filp));
 	if (!IS_ERR(l_ctx)) {
 		status = nfs_iocounter_wait(l_ctx);
 		nfs_put_lock_context(l_ctx);
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 33d18c4..b3bd033 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -725,7 +725,7 @@ static struct nfs_lock_context *__nfs_find_lock_context(struct nfs_open_context
 	return NULL;
 }
 
-struct nfs_lock_context *nfs_get_lock_context(struct nfs_open_context *ctx)
+struct nfs_lock_context *nfs_find_lock_context(struct nfs_open_context *ctx)
 {
 	struct nfs_lock_context *res, *new = NULL;
 	struct inode *inode = d_inode(ctx->dentry);
@@ -751,7 +751,14 @@ struct nfs_lock_context *nfs_get_lock_context(struct nfs_open_context *ctx)
 	kfree(new);
 	return res;
 }
-EXPORT_SYMBOL_GPL(nfs_get_lock_context);
+EXPORT_SYMBOL_GPL(nfs_find_lock_context);
+
+struct nfs_lock_context *get_nfs_lock_context(struct nfs_lock_context *l_ctx)
+{
+	atomic_inc(&l_ctx->count);
+	return l_ctx;
+}
+EXPORT_SYMBOL_GPL(get_nfs_lock_context);
 
 void nfs_put_lock_context(struct nfs_lock_context *l_ctx)
 {
diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index dff8346..f9b0f25 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -61,7 +61,7 @@ static int nfs42_proc_fallocate(struct rpc_message *msg, struct file *filep,
 	struct nfs_lock_context *lock;
 	int err;
 
-	lock = nfs_get_lock_context(nfs_file_open_context(filep));
+	lock = nfs_find_lock_context(nfs_file_open_context(filep));
 	if (IS_ERR(lock))
 		return PTR_ERR(lock);
 
@@ -171,7 +171,7 @@ loff_t nfs42_proc_llseek(struct file *filep, loff_t offset, int whence)
 	struct nfs_lock_context *lock;
 	loff_t err;
 
-	lock = nfs_get_lock_context(nfs_file_open_context(filep));
+	lock = nfs_find_lock_context(nfs_file_open_context(filep));
 	if (IS_ERR(lock))
 		return PTR_ERR(lock);
 
@@ -365,14 +365,14 @@ int nfs42_proc_clone(struct file *src_f, struct file *dst_f,
 	if (!nfs_server_capable(inode, NFS_CAP_CLONE))
 		return -EOPNOTSUPP;
 
-	src_lock = nfs_get_lock_context(nfs_file_open_context(src_f));
+	src_lock = nfs_find_lock_context(nfs_file_open_context(src_f));
 	if (IS_ERR(src_lock))
 		return PTR_ERR(src_lock);
 
 	src_exception.inode = file_inode(src_f);
 	src_exception.state = src_lock->open_context->state;
 
-	dst_lock = nfs_get_lock_context(nfs_file_open_context(dst_f));
+	dst_lock = nfs_find_lock_context(nfs_file_open_context(dst_f));
 	if (IS_ERR(dst_lock)) {
 		err = PTR_ERR(dst_lock);
 		goto out_put_src_lock;
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 8ce4f61..b3e5366 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -329,7 +329,7 @@ nfs_create_request(struct nfs_open_context *ctx, struct page *page,
 		return ERR_PTR(-ENOMEM);
 
 	/* get lock context early so we can deal with alloc failures */
-	l_ctx = nfs_get_lock_context(ctx);
+	l_ctx = nfs_find_lock_context(ctx);
 	if (IS_ERR(l_ctx)) {
 		nfs_page_free(req);
 		return ERR_CAST(l_ctx);
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 67300f8..8f11e2e 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -365,7 +365,8 @@ extern struct nfs_open_context *alloc_nfs_open_context(struct dentry *dentry, fm
 extern void nfs_inode_attach_open_context(struct nfs_open_context *ctx);
 extern void nfs_file_set_open_context(struct file *filp, struct nfs_open_context *ctx);
 extern void nfs_file_clear_open_context(struct file *flip);
-extern struct nfs_lock_context *nfs_get_lock_context(struct nfs_open_context *ctx);
+extern struct nfs_lock_context *nfs_find_lock_context(struct nfs_open_context *ctx);
+extern struct nfs_lock_context *get_nfs_lock_context(struct nfs_lock_context *l_ctx);
 extern void nfs_put_lock_context(struct nfs_lock_context *l_ctx);
 extern u64 nfs_compat_user_ino64(u64 fileid);
 extern void nfs_fattr_init(struct nfs_fattr *fattr);
-- 
1.7.1

