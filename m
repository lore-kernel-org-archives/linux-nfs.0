Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f170.google.com ([209.85.161.170]:52079 "EHLO
	mail-gg0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932518Ab3GPNUn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Jul 2013 09:20:43 -0400
Received: by mail-gg0-f170.google.com with SMTP id s5so170911ggc.1
        for <linux-nfs@vger.kernel.org>; Tue, 16 Jul 2013 06:20:43 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: user-mode-linux-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [PATCH] libfs: export simple_dentry_operations and eliminate extra copies of it
Date: Tue, 16 Jul 2013 09:20:27 -0400
Message-Id: <1373980827-31989-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

hostfs, procfs, and rpc_pipefs all have functional copies of
simple_dentry_operations. Export simple_dentry_operations and have those
filesystems just use it instead.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/hostfs/hostfs_kern.c | 11 +----------
 fs/libfs.c              |  9 +++++----
 fs/proc/generic.c       | 18 +-----------------
 include/linux/fs.h      |  1 +
 net/sunrpc/rpc_pipe.c   | 11 +----------
 5 files changed, 9 insertions(+), 41 deletions(-)

diff --git a/fs/hostfs/hostfs_kern.c b/fs/hostfs/hostfs_kern.c
index cddb052..280b7e0 100644
--- a/fs/hostfs/hostfs_kern.c
+++ b/fs/hostfs/hostfs_kern.c
@@ -33,15 +33,6 @@ static inline struct hostfs_inode_info *HOSTFS_I(struct inode *inode)
 
 #define FILE_HOSTFS_I(file) HOSTFS_I(file_inode(file))
 
-static int hostfs_d_delete(const struct dentry *dentry)
-{
-	return 1;
-}
-
-static const struct dentry_operations hostfs_dentry_ops = {
-	.d_delete		= hostfs_d_delete,
-};
-
 /* Changed in hostfs_args before the kernel starts running */
 static char *root_ino = "";
 static int append = 0;
@@ -918,7 +909,7 @@ static int hostfs_fill_sb_common(struct super_block *sb, void *d, int silent)
 	sb->s_blocksize_bits = 10;
 	sb->s_magic = HOSTFS_SUPER_MAGIC;
 	sb->s_op = &hostfs_sbops;
-	sb->s_d_op = &hostfs_dentry_ops;
+	sb->s_d_op = &simple_dentry_operations;
 	sb->s_maxbytes = MAX_LFS_FILESIZE;
 
 	/* NULL is printed as <NULL> by sprintf: avoid that. */
diff --git a/fs/libfs.c b/fs/libfs.c
index 3a3a9b5..b87a8ba 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -49,16 +49,16 @@ static int simple_delete_dentry(const struct dentry *dentry)
 	return 1;
 }
 
+const struct dentry_operations simple_dentry_operations = {
+	.d_delete = simple_delete_dentry,
+};
+
 /*
  * Lookup the data. This is trivial - if the dentry didn't already
  * exist, we know it is negative.  Set d_op to delete negative dentries.
  */
 struct dentry *simple_lookup(struct inode *dir, struct dentry *dentry, unsigned int flags)
 {
-	static const struct dentry_operations simple_dentry_operations = {
-		.d_delete = simple_delete_dentry,
-	};
-
 	if (dentry->d_name.len > NAME_MAX)
 		return ERR_PTR(-ENAMETOOLONG);
 	if (!dentry->d_sb->s_d_op)
@@ -968,6 +968,7 @@ EXPORT_SYMBOL(simple_write_begin);
 EXPORT_SYMBOL(simple_write_end);
 EXPORT_SYMBOL(simple_dir_inode_operations);
 EXPORT_SYMBOL(simple_dir_operations);
+EXPORT_SYMBOL(simple_dentry_operations);
 EXPORT_SYMBOL(simple_empty);
 EXPORT_SYMBOL(simple_fill_super);
 EXPORT_SYMBOL(simple_getattr);
diff --git a/fs/proc/generic.c b/fs/proc/generic.c
index 94441a4..bc4aa81 100644
--- a/fs/proc/generic.c
+++ b/fs/proc/generic.c
@@ -175,22 +175,6 @@ static const struct inode_operations proc_link_inode_operations = {
 };
 
 /*
- * As some entries in /proc are volatile, we want to 
- * get rid of unused dentries.  This could be made 
- * smarter: we could keep a "volatile" flag in the 
- * inode to indicate which ones to keep.
- */
-static int proc_delete_dentry(const struct dentry * dentry)
-{
-	return 1;
-}
-
-static const struct dentry_operations proc_dentry_operations =
-{
-	.d_delete	= proc_delete_dentry,
-};
-
-/*
  * Don't create negative dentries here, return -ENOENT by hand
  * instead.
  */
@@ -209,7 +193,7 @@ struct dentry *proc_lookup_de(struct proc_dir_entry *de, struct inode *dir,
 			inode = proc_get_inode(dir->i_sb, de);
 			if (!inode)
 				return ERR_PTR(-ENOMEM);
-			d_set_d_op(dentry, &proc_dentry_operations);
+			d_set_d_op(dentry, &simple_dentry_operations);
 			d_add(dentry, inode);
 			return NULL;
 		}
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 23d770b..9ec8b4a 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2563,6 +2563,7 @@ extern int simple_write_end(struct file *file, struct address_space *mapping,
 extern struct dentry *simple_lookup(struct inode *, struct dentry *, unsigned int flags);
 extern ssize_t generic_read_dir(struct file *, char __user *, size_t, loff_t *);
 extern const struct file_operations simple_dir_operations;
+extern const struct dentry_operations simple_dentry_operations;
 extern const struct inode_operations simple_dir_inode_operations;
 struct tree_descr { char *name; const struct file_operations *ops; int mode; };
 struct dentry *d_alloc_name(struct dentry *, const char *);
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 017aedc..da7f051 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -471,15 +471,6 @@ struct rpc_filelist {
 	umode_t mode;
 };
 
-static int rpc_delete_dentry(const struct dentry *dentry)
-{
-	return 1;
-}
-
-static const struct dentry_operations rpc_dentry_operations = {
-	.d_delete = rpc_delete_dentry,
-};
-
 static struct inode *
 rpc_get_inode(struct super_block *sb, umode_t mode)
 {
@@ -1100,7 +1091,7 @@ rpc_fill_super(struct super_block *sb, void *data, int silent)
 	sb->s_blocksize_bits = PAGE_CACHE_SHIFT;
 	sb->s_magic = RPCAUTH_GSSMAGIC;
 	sb->s_op = &s_ops;
-	sb->s_d_op = &rpc_dentry_operations;
+	sb->s_d_op = &simple_dentry_operations;
 	sb->s_time_gran = 1;
 
 	inode = rpc_get_inode(sb, S_IFDIR | S_IRUGO | S_IXUGO);
-- 
1.8.3.1

