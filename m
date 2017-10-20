Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:57858 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752817AbdJTJ4G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 20 Oct 2017 05:56:06 -0400
From: Elena Reshetova <elena.reshetova@intel.com>
To: trond.myklebust@primarydata.com
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        anna.schumaker@netapp.com, bfields@fieldses.org,
        jlayton@poochiereds.net, peterz@infradead.org,
        keescook@chromium.org, Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 10/11] fs, nfs: convert nfs_lock_context.count from atomic_t to refcount_t
Date: Fri, 20 Oct 2017 12:53:37 +0300
Message-Id: <1508493218-27760-11-git-send-email-elena.reshetova@intel.com>
In-Reply-To: <1508493218-27760-1-git-send-email-elena.reshetova@intel.com>
References: <1508493218-27760-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

atomic_t variables are currently used to implement reference
counters with the following properties:
 - counter is initialized to 1 using atomic_set()
 - a resource is freed upon counter reaching zero
 - once counter reaches zero, its further
   increments aren't allowed
 - counter schema uses basic atomic operations
   (set, inc, inc_not_zero, dec_and_test, etc.)

Such atomic variables should be converted to a newly provided
refcount_t type and API that prevents accidental counter overflows
and underflows. This is important since overflows and underflows
can lead to use-after-free situation and be exploitable.

The variable nfs_lock_context.count is used as pure reference counter.
Convert it to refcount_t and fix up the operations.

Suggested-by: Kees Cook <keescook@chromium.org>
Reviewed-by: David Windsor <dwindsor@gmail.com>
Reviewed-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
---
 fs/nfs/inode.c         | 12 ++++++------
 include/linux/nfs_fs.h |  3 ++-
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 134d9f5..52a60e3 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -783,7 +783,7 @@ EXPORT_SYMBOL_GPL(nfs_getattr);
 
 static void nfs_init_lock_context(struct nfs_lock_context *l_ctx)
 {
-	atomic_set(&l_ctx->count, 1);
+	refcount_set(&l_ctx->count, 1);
 	l_ctx->lockowner = current->files;
 	INIT_LIST_HEAD(&l_ctx->list);
 	atomic_set(&l_ctx->io_count, 0);
@@ -797,7 +797,7 @@ static struct nfs_lock_context *__nfs_find_lock_context(struct nfs_open_context
 	do {
 		if (pos->lockowner != current->files)
 			continue;
-		atomic_inc(&pos->count);
+		refcount_inc(&pos->count);
 		return pos;
 	} while ((pos = list_entry(pos->list.next, typeof(*pos), list)) != head);
 	return NULL;
@@ -836,7 +836,7 @@ void nfs_put_lock_context(struct nfs_lock_context *l_ctx)
 	struct nfs_open_context *ctx = l_ctx->open_context;
 	struct inode *inode = d_inode(ctx->dentry);
 
-	if (!atomic_dec_and_lock(&l_ctx->count, &inode->i_lock))
+	if (!refcount_dec_and_lock(&l_ctx->count, &inode->i_lock))
 		return;
 	list_del(&l_ctx->list);
 	spin_unlock(&inode->i_lock);
@@ -913,7 +913,7 @@ EXPORT_SYMBOL_GPL(alloc_nfs_open_context);
 struct nfs_open_context *get_nfs_open_context(struct nfs_open_context *ctx)
 {
 	if (ctx != NULL)
-		atomic_inc(&ctx->lock_context.count);
+		refcount_inc(&ctx->lock_context.count);
 	return ctx;
 }
 EXPORT_SYMBOL_GPL(get_nfs_open_context);
@@ -924,11 +924,11 @@ static void __put_nfs_open_context(struct nfs_open_context *ctx, int is_sync)
 	struct super_block *sb = ctx->dentry->d_sb;
 
 	if (!list_empty(&ctx->list)) {
-		if (!atomic_dec_and_lock(&ctx->lock_context.count, &inode->i_lock))
+		if (!refcount_dec_and_lock(&ctx->lock_context.count, &inode->i_lock))
 			return;
 		list_del(&ctx->list);
 		spin_unlock(&inode->i_lock);
-	} else if (!atomic_dec_and_test(&ctx->lock_context.count))
+	} else if (!refcount_dec_and_test(&ctx->lock_context.count))
 		return;
 	if (inode != NULL)
 		NFS_PROTO(inode)->close_context(ctx, is_sync);
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index a0282ce..51e9124 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -22,6 +22,7 @@
 #include <linux/mm.h>
 #include <linux/pagemap.h>
 #include <linux/rbtree.h>
+#include <linux/refcount.h>
 #include <linux/rwsem.h>
 #include <linux/wait.h>
 
@@ -55,7 +56,7 @@ struct nfs_access_entry {
 };
 
 struct nfs_lock_context {
-	atomic_t count;
+	refcount_t count;
 	struct list_head list;
 	struct nfs_open_context *open_context;
 	fl_owner_t lockowner;
-- 
2.7.4

