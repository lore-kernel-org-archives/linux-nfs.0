From: Christoph Hellwig <hch@infradead.org>
Subject: [PATCH 14/18] reiserfs: new export ops
Date: Sat, 17 Mar 2007 01:12:16 +0000
Message-ID: <20070317011216.GO24947@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Another nice little cleanup by using the new methods.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/fs/reiserfs/inode.c
===================================================================
--- linux-2.6.orig/fs/reiserfs/inode.c	2007-03-16 15:43:55.000000000 +0100
+++ linux-2.6/fs/reiserfs/inode.c	2007-03-17 01:30:45.000000000 +0100
@@ -1514,19 +1514,20 @@ struct inode *reiserfs_iget(struct super
 	return inode;
 }
 
-struct dentry *reiserfs_get_dentry(struct super_block *sb, void *vobjp)
+static struct dentry *reiserfs_get_dentry(struct super_block *sb,
+	u32 objectid, u32 dir_id, u32 generation)
+
 {
-	__u32 *data = vobjp;
 	struct cpu_key key;
 	struct dentry *result;
 	struct inode *inode;
 
-	key.on_disk_key.k_objectid = data[0];
-	key.on_disk_key.k_dir_id = data[1];
+	key.on_disk_key.k_objectid = objectid;
+	key.on_disk_key.k_dir_id = dir_id;
 	reiserfs_write_lock(sb);
 	inode = reiserfs_iget(sb, &key);
-	if (inode && !IS_ERR(inode) && data[2] != 0 &&
-	    data[2] != inode->i_generation) {
+	if (inode && !IS_ERR(inode) && generation != 0 &&
+	    generation != inode->i_generation) {
 		iput(inode);
 		inode = NULL;
 	}
@@ -1543,14 +1544,9 @@ struct dentry *reiserfs_get_dentry(struc
 	return result;
 }
 
-struct dentry *reiserfs_decode_fh(struct super_block *sb, __u32 * data,
-				  int len, int fhtype,
-				  int (*acceptable) (void *contect,
-						     struct dentry * de),
-				  void *context)
+struct dentry *reiserfs_fh_to_dentry(struct super_block *sb, struct fid *fid,
+		int fh_len, int fh_type)
 {
-	__u32 obj[3], parent[3];
-
 	/* fhtype happens to reflect the number of u32s encoded.
 	 * due to a bug in earlier code, fhtype might indicate there
 	 * are more u32s then actually fitted.
@@ -1563,32 +1559,28 @@ struct dentry *reiserfs_decode_fh(struct
 	 *   6 - as above plus generation of directory
 	 * 6 does not fit in NFSv2 handles
 	 */
-	if (fhtype > len) {
-		if (fhtype != 6 || len != 5)
+	if (fh_type > fh_len) {
+		if (fh_type != 6 || fh_len != 5)
 			reiserfs_warning(sb,
-					 "nfsd/reiserfs, fhtype=%d, len=%d - odd",
-					 fhtype, len);
-		fhtype = 5;
+				"nfsd/reiserfs, fhtype=%d, len=%d - odd",
+				fh_type, fh_len);
+		fh_type = 5;
 	}
 
-	obj[0] = data[0];
-	obj[1] = data[1];
-	if (fhtype == 3 || fhtype >= 5)
-		obj[2] = data[2];
-	else
-		obj[2] = 0;	/* generation number */
+	return reiserfs_get_dentry(sb, fid->raw[0], fid->raw[1],
+		(fh_type == 3 || fh_type >= 5) ? fid->raw[2] : 0);
+}
 
-	if (fhtype >= 4) {
-		parent[0] = data[fhtype >= 5 ? 3 : 2];
-		parent[1] = data[fhtype >= 5 ? 4 : 3];
-		if (fhtype == 6)
-			parent[2] = data[5];
-		else
-			parent[2] = 0;
-	}
-	return sb->s_export_op->find_exported_dentry(sb, obj,
-						     fhtype < 4 ? NULL : parent,
-						     acceptable, context);
+struct dentry *reiserfs_fh_to_parent(struct super_block *sb, struct fid *fid,
+		int fh_len, int fh_type)
+{
+	if (fh_type < 4)
+		return NULL;
+
+	return reiserfs_get_dentry(sb,
+		(fh_type >= 5) ? fid->raw[3] : fid->raw[2],
+		(fh_type >= 5) ? fid->raw[4] : fid->raw[3],
+		(fh_type == 6) ? fid->raw[5] : 0);
 }
 
 int reiserfs_encode_fh(struct dentry *dentry, __u32 * data, int *lenp,
Index: linux-2.6/fs/reiserfs/super.c
===================================================================
--- linux-2.6.orig/fs/reiserfs/super.c	2007-03-16 15:43:55.000000000 +0100
+++ linux-2.6/fs/reiserfs/super.c	2007-03-17 01:30:13.000000000 +0100
@@ -654,9 +654,9 @@ static struct quotactl_ops reiserfs_qctl
 
 static struct export_operations reiserfs_export_ops = {
 	.encode_fh = reiserfs_encode_fh,
-	.decode_fh = reiserfs_decode_fh,
+	.fh_to_dentry = reiserfs_fh_to_dentry,
+	.fh_to_parent = reiserfs_fh_to_parent,
 	.get_parent = reiserfs_get_parent,
-	.get_dentry = reiserfs_get_dentry,
 };
 
 /* this struct is used in reiserfs_getopt () for containing the value for those
Index: linux-2.6/include/linux/reiserfs_fs.h
===================================================================
--- linux-2.6.orig/include/linux/reiserfs_fs.h	2007-03-16 15:10:59.000000000 +0100
+++ linux-2.6/include/linux/reiserfs_fs.h	2007-03-16 17:06:08.000000000 +0100
@@ -28,6 +28,8 @@
 #include <linux/reiserfs_fs_sb.h>
 #endif
 
+struct fid;
+
 /*
  *  include/linux/reiser_fs.h
  *
@@ -1867,12 +1869,10 @@ void reiserfs_delete_inode(struct inode 
 int reiserfs_write_inode(struct inode *inode, int);
 int reiserfs_get_block(struct inode *inode, sector_t block,
 		       struct buffer_head *bh_result, int create);
-struct dentry *reiserfs_get_dentry(struct super_block *, void *);
-struct dentry *reiserfs_decode_fh(struct super_block *sb, __u32 * data,
-				  int len, int fhtype,
-				  int (*acceptable) (void *contect,
-						     struct dentry * de),
-				  void *context);
+struct dentry *reiserfs_fh_to_dentry(struct super_block *sb, struct fid *fid,
+                int fh_len, int fh_type);
+struct dentry *reiserfs_fh_to_parent(struct super_block *sb, struct fid *fid,
+                int fh_len, int fh_type);
 int reiserfs_encode_fh(struct dentry *dentry, __u32 * data, int *lenp,
 		       int connectable);
 
