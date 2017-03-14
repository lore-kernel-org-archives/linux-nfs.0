Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:47136 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751129AbdCNHHy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 14 Mar 2017 03:07:54 -0400
From: Elena Reshetova <elena.reshetova@intel.com>
To: trond.myklebust@primarydata.com
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        anna.schumaker@netapp.com, peterz@infradead.org, keescook@chromium.org,
        Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
Subject: [PATCH 10/12] fs, nfs: convert nfs_lock_context.count from atomic_t to refcount_t
Date: Tue, 14 Mar 2017 09:07:18 +0200
Message-Id: <1489475240-6594-11-git-send-email-elena.reshetova@intel.com>
In-Reply-To: <1489475240-6594-1-git-send-email-elena.reshetova@intel.com>
References: <1489475240-6594-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

refcount_t type and corresponding API should be
used instead of atomic_t when the variable is used as
a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free
situations.

Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: David Windsor <dwindsor@gmail.com>
---
 fs/nfs/inode.c         | 12 ++++++------
 include/linux/nfs_fs.h |  3 ++-
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index b542531..c88c784 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -752,7 +752,7 @@ EXPORT_SYMBOL_GPL(nfs_getattr);
 
 static void nfs_init_lock_context(struct nfs_lock_context *l_ctx)
 {
-	atomic_set(&l_ctx->count, 1);
+	refcount_set(&l_ctx->count, 1);
 	l_ctx->lockowner = current->files;
 	INIT_LIST_HEAD(&l_ctx->list);
 	atomic_set(&l_ctx->io_count, 0);
@@ -766,7 +766,7 @@ static struct nfs_lock_context *__nfs_find_lock_context(struct nfs_open_context
 	do {
 		if (pos->lockowner != current->files)
 			continue;
-		atomic_inc(&pos->count);
+		refcount_inc(&pos->count);
 		return pos;
 	} while ((pos = list_entry(pos->list.next, typeof(*pos), list)) != head);
 	return NULL;
@@ -805,7 +805,7 @@ void nfs_put_lock_context(struct nfs_lock_context *l_ctx)
 	struct nfs_open_context *ctx = l_ctx->open_context;
 	struct inode *inode = d_inode(ctx->dentry);
 
-	if (!atomic_dec_and_lock(&l_ctx->count, &inode->i_lock))
+	if (!refcount_dec_and_lock(&l_ctx->count, &inode->i_lock))
 		return;
 	list_del(&l_ctx->list);
 	spin_unlock(&inode->i_lock);
@@ -882,7 +882,7 @@ EXPORT_SYMBOL_GPL(alloc_nfs_open_context);
 struct nfs_open_context *get_nfs_open_context(struct nfs_open_context *ctx)
 {
 	if (ctx != NULL)
-		atomic_inc(&ctx->lock_context.count);
+		refcount_inc(&ctx->lock_context.count);
 	return ctx;
 }
 EXPORT_SYMBOL_GPL(get_nfs_open_context);
@@ -893,11 +893,11 @@ static void __put_nfs_open_context(struct nfs_open_context *ctx, int is_sync)
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
index 287f341..0c5b89a 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -22,6 +22,7 @@
 #include <linux/mm.h>
 #include <linux/pagemap.h>
 #include <linux/rbtree.h>
+#include <linux/refcount.h>
 #include <linux/rwsem.h>
 #include <linux/wait.h>
 
@@ -56,7 +57,7 @@ struct nfs_access_entry {
 };
 
 struct nfs_lock_context {
-	atomic_t count;
+	refcount_t count;
 	struct list_head list;
 	struct nfs_open_context *open_context;
 	fl_owner_t lockowner;
-- 
2.7.4

