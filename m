From: Christoph Hellwig <hch@infradead.org>
Subject: [PATCH 8/18] jfs: new export ops
Date: Sat, 17 Mar 2007 01:11:12 +0000
Message-ID: <20070317011112.GI24947@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Trivial switch over to the new generic helpers.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/fs/jfs/jfs_inode.h
===================================================================
--- linux-2.6.orig/fs/jfs/jfs_inode.h	2007-03-13 18:19:44.000000000 +0100
+++ linux-2.6/fs/jfs/jfs_inode.h	2007-03-13 19:11:13.000000000 +0100
@@ -18,6 +18,8 @@
 #ifndef	_H_JFS_INODE
 #define _H_JFS_INODE
 
+struct fid;
+
 extern struct inode *ialloc(struct inode *, umode_t);
 extern int jfs_fsync(struct file *, struct dentry *, int);
 extern int jfs_ioctl(struct inode *, struct file *,
@@ -30,8 +32,11 @@ extern void jfs_dirty_inode(struct inode
 extern void jfs_truncate(struct inode *);
 extern void jfs_truncate_nolock(struct inode *, loff_t);
 extern void jfs_free_zero_link(struct inode *);
+extern struct dentry *jfs_fh_to_dentry(struct super_block *sb, struct fid *fid,
+	int fh_len, int fh_type);
+extern struct dentry *jfs_fh_to_parent(struct super_block *sb, struct fid *fid,
+	int fh_len, int fh_type);
 extern struct dentry *jfs_get_parent(struct dentry *dentry);
-extern struct dentry *jfs_get_dentry(struct super_block *sb, void *vobjp);
 extern void jfs_set_inode_flags(struct inode *);
 extern int jfs_get_block(struct inode *, sector_t, struct buffer_head *, int);
 
Index: linux-2.6/fs/jfs/namei.c
===================================================================
--- linux-2.6.orig/fs/jfs/namei.c	2007-03-13 18:19:44.000000000 +0100
+++ linux-2.6/fs/jfs/namei.c	2007-03-13 19:13:14.000000000 +0100
@@ -20,6 +20,7 @@
 #include <linux/fs.h>
 #include <linux/ctype.h>
 #include <linux/quotaops.h>
+#include <linux/exportfs.h>
 #include "jfs_incore.h"
 #include "jfs_superblock.h"
 #include "jfs_inode.h"
@@ -1477,13 +1478,10 @@ static struct dentry *jfs_lookup(struct 
 	return dentry;
 }
 
-struct dentry *jfs_get_dentry(struct super_block *sb, void *vobjp)
+static struct inode *jfs_nfs_get_inode(struct super_block *sb,
+		u64 ino, u32 generation)
 {
-	__u32 *objp = vobjp;
-	unsigned long ino = objp[0];
-	__u32 generation = objp[1];
 	struct inode *inode;
-	struct dentry *result;
 
 	if (ino == 0)
 		return ERR_PTR(-ESTALE);
@@ -1493,20 +1491,23 @@ struct dentry *jfs_get_dentry(struct sup
 
 	if (is_bad_inode(inode) ||
 	    (generation && inode->i_generation != generation)) {
-	    	result = ERR_PTR(-ESTALE);
-		goto out_iput;
+		iput(inode);
+	    	return ERR_PTR(-ESTALE);
 	}
 
-	result = d_alloc_anon(inode);
-	if (!result) {
-		result = ERR_PTR(-ENOMEM);
-		goto out_iput;
-	}
-	return result;
+	return inode;
+}
 
- out_iput:
-	iput(inode);
-	return result;
+struct dentry *jfs_fh_to_dentry(struct super_block *sb, struct fid *fid,
+		int fh_len, int fh_type)
+{
+	return generic_fh_to_dentry(sb, fid, fh_len, fh_type, jfs_nfs_get_inode);
+}
+
+struct dentry *jfs_fh_to_parent(struct super_block *sb, struct fid *fid,
+		int fh_len, int fh_type)
+{
+	return generic_fh_to_parent(sb, fid, fh_len, fh_type, jfs_nfs_get_inode);
 }
 
 struct dentry *jfs_get_parent(struct dentry *dentry)
Index: linux-2.6/fs/jfs/super.c
===================================================================
--- linux-2.6.orig/fs/jfs/super.c	2007-03-13 18:19:44.000000000 +0100
+++ linux-2.6/fs/jfs/super.c	2007-03-13 19:11:13.000000000 +0100
@@ -738,7 +738,8 @@ static const struct super_operations jfs
 };
 
 static struct export_operations jfs_export_operations = {
-	.get_dentry	= jfs_get_dentry,
+	.fh_to_dentry	= jfs_fh_to_dentry,
+	.fh_to_parent	= jfs_fh_to_parent,
 	.get_parent	= jfs_get_parent,
 };
 
