From: Christoph Hellwig <hch@infradead.org>
Subject: [PATCH 4/18] efs: new export ops
Date: Sat, 17 Mar 2007 01:10:26 +0000
Message-ID: <20070317011026.GE24947@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Trivial switch over to the new generic helpers.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/fs/efs/namei.c
===================================================================
--- linux-2.6.orig/fs/efs/namei.c	2007-03-13 18:19:44.000000000 +0100
+++ linux-2.6/fs/efs/namei.c	2007-03-13 19:11:09.000000000 +0100
@@ -10,6 +10,8 @@
 #include <linux/string.h>
 #include <linux/efs_fs.h>
 #include <linux/smp_lock.h>
+#include <linux/exportfs.h>
+
 
 static efs_ino_t efs_find_entry(struct inode *inode, const char *name, int len) {
 	struct buffer_head *bh;
@@ -75,13 +77,10 @@ struct dentry *efs_lookup(struct inode *
 	return NULL;
 }
 
-struct dentry *efs_get_dentry(struct super_block *sb, void *vobjp)
+static struct inode *efs_nfs_get_inode(struct super_block *sb, u64 ino,
+		u32 generation)
 {
-	__u32 *objp = vobjp;
-	unsigned long ino = objp[0];
-	__u32 generation = objp[1];
 	struct inode *inode;
-	struct dentry *result;
 
 	if (ino == 0)
 		return ERR_PTR(-ESTALE);
@@ -91,22 +90,26 @@ struct dentry *efs_get_dentry(struct sup
 
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
+struct dentry *efs_fh_to_dentry(struct super_block *sb, struct fid *fid,
+		int fh_len, int fh_type)
+{
+	return generic_fh_to_dentry(sb, fid, fh_len, fh_type, efs_nfs_get_inode);
 }
 
+struct dentry *efs_fh_to_parent(struct super_block *sb, struct fid *fid,
+		int fh_len, int fh_type)
+{
+	return generic_fh_to_parent(sb, fid, fh_len, fh_type, efs_nfs_get_inode);
+}
+
+
 struct dentry *efs_get_parent(struct dentry *child)
 {
 	struct dentry *parent;
Index: linux-2.6/fs/efs/super.c
===================================================================
--- linux-2.6.orig/fs/efs/super.c	2007-03-13 18:19:44.000000000 +0100
+++ linux-2.6/fs/efs/super.c	2007-03-13 19:09:33.000000000 +0100
@@ -116,7 +116,8 @@ static const struct super_operations efs
 };
 
 static struct export_operations efs_export_ops = {
-	.get_dentry	= efs_get_dentry,
+	.fh_to_dentry	= efs_fh_to_dentry,
+	.fh_to_parent	= efs_fh_to_parent,
 	.get_parent	= efs_get_parent,
 };
 
Index: linux-2.6/include/linux/efs_fs.h
===================================================================
--- linux-2.6.orig/include/linux/efs_fs.h	2007-03-13 18:19:44.000000000 +0100
+++ linux-2.6/include/linux/efs_fs.h	2007-03-13 19:09:33.000000000 +0100
@@ -35,6 +35,7 @@ static inline struct efs_sb_info *SUPER_
 }
 
 struct statfs;
+struct fid;
 
 extern const struct inode_operations efs_dir_inode_operations;
 extern const struct file_operations efs_dir_operations;
@@ -45,7 +46,10 @@ extern efs_block_t efs_map_block(struct 
 extern int efs_get_block(struct inode *, sector_t, struct buffer_head *, int);
 
 extern struct dentry *efs_lookup(struct inode *, struct dentry *, struct nameidata *);
-extern struct dentry *efs_get_dentry(struct super_block *sb, void *vobjp);
+extern struct dentry *efs_fh_to_dentry(struct super_block *sb, struct fid *fid,
+		int fh_len, int fh_type);
+extern struct dentry *efs_fh_to_parent(struct super_block *sb, struct fid *fid,
+		int fh_len, int fh_type);
 extern struct dentry *efs_get_parent(struct dentry *);
 extern int efs_bmap(struct inode *, int);
 
