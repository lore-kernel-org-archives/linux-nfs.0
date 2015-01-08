Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f42.google.com ([209.85.192.42]:60044 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757292AbbAHSet (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Jan 2015 13:34:49 -0500
Received: by mail-qg0-f42.google.com with SMTP id q108so3842446qgd.1
        for <linux-nfs@vger.kernel.org>; Thu, 08 Jan 2015 10:34:48 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        hch@infradead.org
Subject: [PATCH v2 03/10] locks: add a new struct file_locking_context pointer to struct inode
Date: Thu,  8 Jan 2015 10:34:18 -0800
Message-Id: <1420742065-28423-4-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1420742065-28423-1-git-send-email-jlayton@primarydata.com>
References: <1420742065-28423-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The current scheme of using the i_flock list is really difficult to
manage. There is also a legitimate desire for a per-inode spinlock to
manage these lists that isn't the i_lock.

Start conversion to a new scheme to eventually replace the old i_flock
list with a new "file_lock_context" object.

We start by adding a new i_flctx to struct inode. For now, it lives in
parallel with i_flock list, but will eventually replace it. The idea is
to allocate a structure to sit in that pointer and act as a locus for
all things file locking.

We allocate a file_lock_context for an inode when the first lock is
added to it, and it's only freed when the inode is freed. Assignment
of the pointer is done without locking using a compare and swap
operation.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/inode.c         |  3 ++-
 fs/locks.c         | 37 +++++++++++++++++++++++++++++++++++++
 include/linux/fs.h | 12 ++++++++++++
 3 files changed, 51 insertions(+), 1 deletion(-)

diff --git a/fs/inode.c b/fs/inode.c
index aa149e7262ac..f30872ade6d7 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -194,7 +194,7 @@ int inode_init_always(struct super_block *sb, struct inode *inode)
 #ifdef CONFIG_FSNOTIFY
 	inode->i_fsnotify_mask = 0;
 #endif
-
+	inode->i_flctx = NULL;
 	this_cpu_inc(nr_inodes);
 
 	return 0;
@@ -237,6 +237,7 @@ void __destroy_inode(struct inode *inode)
 	BUG_ON(inode_has_buffers(inode));
 	security_inode_free(inode);
 	fsnotify_inode_delete(inode);
+	locks_free_lock_context(inode->i_flctx);
 	if (!inode->i_nlink) {
 		WARN_ON(atomic_long_read(&inode->i_sb->s_remove_count) == 0);
 		atomic_long_dec(&inode->i_sb->s_remove_count);
diff --git a/fs/locks.c b/fs/locks.c
index cec00425bfb6..22ed77c6be4c 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -202,8 +202,42 @@ static DEFINE_HASHTABLE(blocked_hash, BLOCKED_HASH_BITS);
  */
 static DEFINE_SPINLOCK(blocked_lock_lock);
 
+static struct kmem_cache *flctx_cache __read_mostly;
 static struct kmem_cache *filelock_cache __read_mostly;
 
+static struct file_lock_context *
+locks_get_lock_context(struct inode *inode)
+{
+	struct file_lock_context *new = NULL;
+
+	if (likely(inode->i_flctx))
+		goto out;
+
+	new = kmem_cache_alloc(flctx_cache, GFP_KERNEL);
+	if (!new)
+		goto out;
+
+	INIT_LIST_HEAD(&new->flc_flock);
+
+	/*
+	 * Assign the pointer if it's not already assigned. If it is, then
+	 * free the context we just allocated.
+	 */
+	if (cmpxchg(&inode->i_flctx, NULL, new))
+		kmem_cache_free(flctx_cache, new);
+out:
+	return inode->i_flctx;
+}
+
+void
+locks_free_lock_context(struct file_lock_context *ctx)
+{
+	if (ctx) {
+		WARN_ON_ONCE(!list_empty(&ctx->flc_flock));
+		kmem_cache_free(flctx_cache, ctx);
+	}
+}
+
 static void locks_init_lock_heads(struct file_lock *fl)
 {
 	INIT_HLIST_NODE(&fl->fl_link);
@@ -2636,6 +2670,9 @@ static int __init filelock_init(void)
 {
 	int i;
 
+	flctx_cache = kmem_cache_create("file_lock_ctx",
+			sizeof(struct file_lock_context), 0, SLAB_PANIC, NULL);
+
 	filelock_cache = kmem_cache_create("file_lock_cache",
 			sizeof(struct file_lock), 0, SLAB_PANIC, NULL);
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 9eee7200cfe3..0cd1cc338e57 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -626,6 +626,7 @@ struct inode {
 #endif
 	const struct file_operations	*i_fop;	/* former ->i_op->default_file_ops */
 	struct file_lock	*i_flock;
+	struct file_lock_context	*i_flctx;
 	struct address_space	i_data;
 	struct list_head	i_devices;
 	union {
@@ -965,6 +966,10 @@ struct file_lock {
 	} fl_u;
 };
 
+struct file_lock_context {
+	struct list_head	flc_flock;
+};
+
 /* The following constant reflects the upper bound of the file/locking space */
 #ifndef OFFSET_MAX
 #define INT_LIMIT(x)	(~((x)1 << (sizeof(x)*8 - 1)))
@@ -991,6 +996,7 @@ extern int fcntl_setlease(unsigned int fd, struct file *filp, long arg);
 extern int fcntl_getlease(struct file *filp);
 
 /* fs/locks.c */
+void locks_free_lock_context(struct file_lock_context *ctx);
 void locks_free_lock(struct file_lock *fl);
 extern void locks_init_lock(struct file_lock *);
 extern struct file_lock * locks_alloc_lock(void);
@@ -1048,6 +1054,12 @@ static inline int fcntl_getlease(struct file *filp)
 	return F_UNLCK;
 }
 
+static inline void
+locks_free_lock_context(struct file_lock_context *ctx)
+{
+	return;
+}
+
 static inline void locks_init_lock(struct file_lock *fl)
 {
 	return;
-- 
2.1.0

