From: Christoph Hellwig <hch@lst.de>
Subject: [PATH 17/19] exportfs: make struct export_operations const
Date: Thu, 30 Aug 2007 15:17:18 +0200
Message-ID: <20070830131718.GR6834@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Now that nfsd has stopped writing to the find_exported_dentry member
we an mark the export_operations const


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/fs/efs/super.c
===================================================================
--- linux-2.6.orig/fs/efs/super.c	2007-07-20 19:52:01.000000000 +0200
+++ linux-2.6/fs/efs/super.c	2007-07-20 20:00:17.000000000 +0200
@@ -113,7 +113,7 @@ static const struct super_operations efs
 	.remount_fs	= efs_remount,
 };
 
-static struct export_operations efs_export_ops = {
+static const struct export_operations efs_export_ops = {
 	.fh_to_dentry	= efs_fh_to_dentry,
 	.fh_to_parent	= efs_fh_to_parent,
 	.get_parent	= efs_get_parent,
Index: linux-2.6/fs/ext2/super.c
===================================================================
--- linux-2.6.orig/fs/ext2/super.c	2007-07-20 19:51:59.000000000 +0200
+++ linux-2.6/fs/ext2/super.c	2007-07-20 20:00:17.000000000 +0200
@@ -292,7 +292,7 @@ static struct dentry *ext2_fh_to_parent(
  * systems, but can be improved upon.
  * Currently only get_parent is required.
  */
-static struct export_operations ext2_export_ops = {
+static const struct export_operations ext2_export_ops = {
 	.fh_to_dentry = ext2_fh_to_dentry,
 	.fh_to_parent = ext2_fh_to_parent,
 	.get_parent = ext2_get_parent,
Index: linux-2.6/fs/ext3/super.c
===================================================================
--- linux-2.6.orig/fs/ext3/super.c	2007-07-20 19:52:00.000000000 +0200
+++ linux-2.6/fs/ext3/super.c	2007-07-20 20:00:17.000000000 +0200
@@ -670,7 +670,7 @@ static const struct super_operations ext
 #endif
 };
 
-static struct export_operations ext3_export_ops = {
+static const struct export_operations ext3_export_ops = {
 	.fh_to_dentry = ext3_fh_to_dentry,
 	.fh_to_parent = ext3_fh_to_parent,
 	.get_parent = ext3_get_parent,
Index: linux-2.6/fs/ext4/super.c
===================================================================
--- linux-2.6.orig/fs/ext4/super.c	2007-07-20 19:52:01.000000000 +0200
+++ linux-2.6/fs/ext4/super.c	2007-07-20 20:00:17.000000000 +0200
@@ -721,7 +721,7 @@ static const struct super_operations ext
 #endif
 };
 
-static struct export_operations ext4_export_ops = {
+static const struct export_operations ext4_export_ops = {
 	.fh_to_dentry = ext4_fh_to_dentry,
 	.fh_to_parent = ext4_fh_to_parent,
 	.get_parent = ext4_get_parent,
Index: linux-2.6/fs/fat/inode.c
===================================================================
--- linux-2.6.orig/fs/fat/inode.c	2007-07-20 19:53:47.000000000 +0200
+++ linux-2.6/fs/fat/inode.c	2007-07-20 20:00:17.000000000 +0200
@@ -769,7 +769,7 @@ out:
 	return parent;
 }
 
-static struct export_operations fat_export_ops = {
+static const struct export_operations fat_export_ops = {
 	.encode_fh	= fat_encode_fh,
 	.fh_to_dentry	= fat_fh_to_dentry,
 	.get_parent	= fat_get_parent,
Index: linux-2.6/fs/gfs2/ops_export.c
===================================================================
--- linux-2.6.orig/fs/gfs2/ops_export.c	2007-07-20 19:58:06.000000000 +0200
+++ linux-2.6/fs/gfs2/ops_export.c	2007-07-20 20:00:17.000000000 +0200
@@ -294,7 +294,7 @@ static struct dentry *gfs2_fh_to_parent(
 	}
 }
 
-struct export_operations gfs2_export_ops = {
+const struct export_operations gfs2_export_ops = {
 	.encode_fh = gfs2_encode_fh,
 	.fh_to_dentry = gfs2_fh_to_dentry,
 	.fh_to_parent = gfs2_fh_to_parent,
Index: linux-2.6/fs/isofs/export.c
===================================================================
--- linux-2.6.orig/fs/isofs/export.c	2007-07-20 19:53:48.000000000 +0200
+++ linux-2.6/fs/isofs/export.c	2007-07-20 20:00:17.000000000 +0200
@@ -207,7 +207,7 @@ static struct dentry *isofs_fh_to_parent
 			fh_len > 4 ? ifid->parent_generation : 0);
 }
 
-struct export_operations isofs_export_ops = {
+const struct export_operations isofs_export_ops = {
 	.encode_fh	= isofs_export_encode_fh,
 	.fh_to_dentry	= isofs_fh_to_dentry,
 	.fh_to_parent	= isofs_fh_to_parent,
Index: linux-2.6/fs/isofs/isofs.h
===================================================================
--- linux-2.6.orig/fs/isofs/isofs.h	2007-07-19 15:56:46.000000000 +0200
+++ linux-2.6/fs/isofs/isofs.h	2007-07-20 20:00:17.000000000 +0200
@@ -178,4 +178,4 @@ isofs_normalize_block_and_offset(struct 
 extern const struct inode_operations isofs_dir_inode_operations;
 extern const struct file_operations isofs_dir_operations;
 extern const struct address_space_operations isofs_symlink_aops;
-extern struct export_operations isofs_export_ops;
+extern const struct export_operations isofs_export_ops;
Index: linux-2.6/fs/jfs/super.c
===================================================================
--- linux-2.6.orig/fs/jfs/super.c	2007-07-20 19:52:04.000000000 +0200
+++ linux-2.6/fs/jfs/super.c	2007-07-20 20:00:17.000000000 +0200
@@ -48,7 +48,7 @@ MODULE_LICENSE("GPL");
 static struct kmem_cache * jfs_inode_cachep;
 
 static const struct super_operations jfs_super_operations;
-static struct export_operations jfs_export_operations;
+static const struct export_operations jfs_export_operations;
 static struct file_system_type jfs_fs_type;
 
 #define MAX_COMMIT_THREADS 64
@@ -737,7 +737,7 @@ static const struct super_operations jfs
 #endif
 };
 
-static struct export_operations jfs_export_operations = {
+static const struct export_operations jfs_export_operations = {
 	.fh_to_dentry	= jfs_fh_to_dentry,
 	.fh_to_parent	= jfs_fh_to_parent,
 	.get_parent	= jfs_get_parent,
Index: linux-2.6/fs/ntfs/namei.c
===================================================================
--- linux-2.6.orig/fs/ntfs/namei.c	2007-07-20 19:52:37.000000000 +0200
+++ linux-2.6/fs/ntfs/namei.c	2007-07-20 20:00:17.000000000 +0200
@@ -497,7 +497,7 @@ static struct dentry *ntfs_fh_to_parent(
  * allowing the inode number 0 which is used in NTFS for the system file $MFT
  * and due to using iget() whereas NTFS needs ntfs_iget().
  */
-struct export_operations ntfs_export_ops = {
+const struct export_operations ntfs_export_ops = {
 	.get_parent	= ntfs_get_parent,	/* Find the parent of a given
 						   directory. */
 	.fh_to_dentry	= ntfs_fh_to_dentry,
Index: linux-2.6/fs/ntfs/ntfs.h
===================================================================
--- linux-2.6.orig/fs/ntfs/ntfs.h	2007-03-13 19:20:10.000000000 +0100
+++ linux-2.6/fs/ntfs/ntfs.h	2007-07-20 20:00:17.000000000 +0200
@@ -69,7 +69,7 @@ extern const struct inode_operations ntf
 extern const struct  file_operations ntfs_empty_file_ops;
 extern const struct inode_operations ntfs_empty_inode_ops;
 
-extern struct export_operations ntfs_export_ops;
+extern const struct export_operations ntfs_export_ops;
 
 /**
  * NTFS_SB - return the ntfs volume given a vfs super block
Index: linux-2.6/fs/ocfs2/export.c
===================================================================
--- linux-2.6.orig/fs/ocfs2/export.c	2007-07-20 19:58:11.000000000 +0200
+++ linux-2.6/fs/ocfs2/export.c	2007-07-20 20:00:17.000000000 +0200
@@ -228,7 +228,7 @@ static struct dentry *ocfs2_fh_to_parent
 	return ocfs2_get_dentry(sb, &parent);
 }
 
-struct export_operations ocfs2_export_ops = {
+const struct export_operations ocfs2_export_ops = {
 	.encode_fh	= ocfs2_encode_fh,
 	.fh_to_dentry	= ocfs2_fh_to_dentry,
 	.fh_to_parent	= ocfs2_fh_to_parent,
Index: linux-2.6/fs/ocfs2/export.h
===================================================================
--- linux-2.6.orig/fs/ocfs2/export.h	2007-07-19 15:56:46.000000000 +0200
+++ linux-2.6/fs/ocfs2/export.h	2007-07-20 20:00:17.000000000 +0200
@@ -28,6 +28,6 @@
 
 #include <linux/exportfs.h>
 
-extern struct export_operations ocfs2_export_ops;
+extern const struct export_operations ocfs2_export_ops;
 
 #endif /* OCFS2_EXPORT_H */
Index: linux-2.6/fs/reiserfs/super.c
===================================================================
--- linux-2.6.orig/fs/reiserfs/super.c	2007-07-20 19:53:49.000000000 +0200
+++ linux-2.6/fs/reiserfs/super.c	2007-07-20 20:00:17.000000000 +0200
@@ -649,7 +649,7 @@ static struct quotactl_ops reiserfs_qctl
 };
 #endif
 
-static struct export_operations reiserfs_export_ops = {
+static const struct export_operations reiserfs_export_ops = {
 	.encode_fh = reiserfs_encode_fh,
 	.fh_to_dentry = reiserfs_fh_to_dentry,
 	.fh_to_parent = reiserfs_fh_to_parent,
Index: linux-2.6/fs/xfs/linux-2.6/xfs_export.c
===================================================================
--- linux-2.6.orig/fs/xfs/linux-2.6/xfs_export.c	2007-07-20 19:52:38.000000000 +0200
+++ linux-2.6/fs/xfs/linux-2.6/xfs_export.c	2007-07-20 20:00:17.000000000 +0200
@@ -215,7 +215,7 @@ xfs_fs_get_parent(
 	return parent;
 }
 
-struct export_operations xfs_export_operations = {
+const struct export_operations xfs_export_operations = {
 	.encode_fh		= xfs_fs_encode_fh,
 	.fh_to_dentry		= xfs_fs_fh_to_dentry,
 	.fh_to_parent		= xfs_fs_fh_to_parent,
Index: linux-2.6/fs/xfs/linux-2.6/xfs_super.h
===================================================================
--- linux-2.6.orig/fs/xfs/linux-2.6/xfs_super.h	2007-07-19 15:56:46.000000000 +0200
+++ linux-2.6/fs/xfs/linux-2.6/xfs_super.h	2007-07-20 20:00:17.000000000 +0200
@@ -117,6 +117,6 @@ extern int  xfs_blkdev_get(struct xfs_mo
 extern void xfs_blkdev_put(struct block_device *);
 extern void xfs_blkdev_issue_flush(struct xfs_buftarg *);
 
-extern struct export_operations xfs_export_operations;
+extern const struct export_operations xfs_export_operations;
 
 #endif	/* __XFS_SUPER_H__ */
Index: linux-2.6/include/linux/fs.h
===================================================================
--- linux-2.6.orig/include/linux/fs.h	2007-07-20 19:50:12.000000000 +0200
+++ linux-2.6/include/linux/fs.h	2007-07-20 20:00:17.000000000 +0200
@@ -930,7 +930,7 @@ struct super_block {
 	const struct super_operations	*s_op;
 	struct dquot_operations	*dq_op;
  	struct quotactl_ops	*s_qcop;
-	struct export_operations *s_export_op;
+	const struct export_operations *s_export_op;
 	unsigned long		s_flags;
 	unsigned long		s_magic;
 	struct dentry		*s_root;
Index: linux-2.6/mm/shmem.c
===================================================================
--- linux-2.6.orig/mm/shmem.c	2007-07-20 19:53:49.000000000 +0200
+++ linux-2.6/mm/shmem.c	2007-07-20 20:00:17.000000000 +0200
@@ -2049,7 +2049,7 @@ static int shmem_encode_fh(struct dentry
 	return 1;
 }
 
-static struct export_operations shmem_export_ops = {
+static const struct export_operations shmem_export_ops = {
 	.get_parent     = shmem_get_parent,
 	.encode_fh      = shmem_encode_fh,
 	.fh_to_dentry	= shmem_fh_to_dentry,
Index: linux-2.6/fs/exportfs/expfs.c
===================================================================
--- linux-2.6.orig/fs/exportfs/expfs.c	2007-07-20 19:58:53.000000000 +0200
+++ linux-2.6/fs/exportfs/expfs.c	2007-07-20 20:00:17.000000000 +0200
@@ -16,7 +16,7 @@ static int get_name(struct dentry *dentr
 static int exportfs_get_name(struct dentry *dir, char *name,
 		struct dentry *child)
 {
-	struct export_operations *nop = dir->d_sb->s_export_op;
+	const struct export_operations *nop = dir->d_sb->s_export_op;
 
 	if (nop->get_name)
 		return nop->get_name(dir, name, child);
@@ -398,7 +398,7 @@ EXPORT_SYMBOL_GPL(generic_fh_to_parent);
 int exportfs_encode_fh(struct dentry *dentry, struct fid *fid, int *max_len,
 		int connectable)
 {
- 	struct export_operations *nop = dentry->d_sb->s_export_op;
+ 	const struct export_operations *nop = dentry->d_sb->s_export_op;
 	int error;
 
 	if (nop->encode_fh)
@@ -414,7 +414,7 @@ struct dentry *exportfs_decode_fh(struct
 		int fh_len, int fileid_type,
 		int (*acceptable)(void *, struct dentry *), void *context)
 {
-	struct export_operations *nop = mnt->mnt_sb->s_export_op;
+	const struct export_operations *nop = mnt->mnt_sb->s_export_op;
 	struct dentry *result, *alias;
 	int err;
 
Index: linux-2.6/fs/cifs/cifsfs.c
===================================================================
--- linux-2.6.orig/fs/cifs/cifsfs.c	2007-07-20 20:05:43.000000000 +0200
+++ linux-2.6/fs/cifs/cifsfs.c	2007-07-20 20:05:49.000000000 +0200
@@ -50,7 +50,7 @@ static struct quotactl_ops cifs_quotactl
 #endif /* QUOTA */
 
 #ifdef CONFIG_CIFS_EXPERIMENTAL
-extern struct export_operations cifs_export_ops;
+extern const struct export_operations cifs_export_ops;
 #endif /* EXPERIMENTAL */
 
 int cifsFYI = 0;
Index: linux-2.6/fs/cifs/export.c
===================================================================
--- linux-2.6.orig/fs/cifs/export.c	2007-07-20 20:05:51.000000000 +0200
+++ linux-2.6/fs/cifs/export.c	2007-07-20 20:06:21.000000000 +0200
@@ -52,7 +52,7 @@ static struct dentry *cifs_get_parent(st
 	return ERR_PTR(-EACCES);
 }
 
-struct export_operations cifs_export_ops = {
+const struct export_operations cifs_export_ops = {
 	.get_parent = cifs_get_parent,
 /*	Following five export operations are unneeded so far and can default:
 	.get_dentry =
Index: linux-2.6/fs/gfs2/ops_fstype.h
===================================================================
--- linux-2.6.orig/fs/gfs2/ops_fstype.h	2007-07-20 20:05:05.000000000 +0200
+++ linux-2.6/fs/gfs2/ops_fstype.h	2007-07-20 20:05:12.000000000 +0200
@@ -14,6 +14,6 @@
 
 extern struct file_system_type gfs2_fs_type;
 extern struct file_system_type gfs2meta_fs_type;
-extern struct export_operations gfs2_export_ops;
+extern const struct export_operations gfs2_export_ops;
 
 #endif /* __OPS_FSTYPE_DOT_H__ */

--
