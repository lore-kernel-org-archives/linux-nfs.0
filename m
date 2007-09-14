From: hch@lst.de
Subject: [PATCH 14/19] reiserfs: new export ops
Date: Fri, 14 Sep 2007 13:49:07 +0200
Message-ID: <20070914114907.GO28282@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IW9fX-0008DZ-6i
	for nfs@lists.sourceforge.net; Fri, 14 Sep 2007 04:49:07 -0700
Received: from verein.lst.de ([213.95.11.210] helo=mail.lst.de)
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1IW9fb-0007RN-Fp
	for nfs@lists.sourceforge.net; Fri, 14 Sep 2007 04:49:12 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Another nice little cleanup by using the new methods.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/fs/reiserfs/inode.c
===================================================================
--- linux-2.6.orig/fs/reiserfs/inode.c	2007-09-13 15:10:45.000000000 +0200
+++ linux-2.6/fs/reiserfs/inode.c	2007-09-13 15:21:12.000000000 +0200
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
--- linux-2.6.orig/fs/reiserfs/super.c	2007-09-13 15:10:45.000000000 +0200
+++ linux-2.6/fs/reiserfs/super.c	2007-09-13 15:21:12.000000000 +0200
@@ -651,9 +651,9 @@ static struct quotactl_ops reiserfs_qctl
 
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
--- linux-2.6.orig/include/linux/reiserfs_fs.h	2007-09-13 15:10:45.000000000 +0200
+++ linux-2.6/include/linux/reiserfs_fs.h	2007-09-13 15:21:47.000000000 +0200
@@ -28,6 +28,8 @@
 #include <linux/reiserfs_fs_sb.h>
 #endif
 
+struct fid;
+
 /*
  *  include/linux/reiser_fs.h
  *
@@ -1869,12 +1871,10 @@ void reiserfs_delete_inode(struct inode 
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
+				     int fh_len, int fh_type);
+struct dentry *reiserfs_fh_to_parent(struct super_block *sb, struct fid *fid,
+				     int fh_len, int fh_type);
 int reiserfs_encode_fh(struct dentry *dentry, __u32 * data, int *lenp,
 		       int connectable);
 

--

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
