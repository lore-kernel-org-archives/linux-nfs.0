From: hch@lst.de
Subject: [PATCH 04/19] ext2: new export ops
Date: Fri, 14 Sep 2007 13:48:14 +0200
Message-ID: <20070914114814.GE28282@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Trivial switch over to the new generic helpers.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/fs/ext2/super.c
===================================================================
--- linux-2.6.orig/fs/ext2/super.c	2007-09-13 15:10:46.000000000 +0200
+++ linux-2.6/fs/ext2/super.c	2007-09-13 15:16:25.000000000 +0200
@@ -248,13 +248,10 @@ static const struct super_operations ext
 #endif
 };
 
-static struct dentry *ext2_get_dentry(struct super_block *sb, void *vobjp)
+static struct inode *ext2_nfs_get_inode(struct super_block *sb,
+		u64 ino, u32 generation)
 {
-	__u32 *objp = vobjp;
-	unsigned long ino = objp[0];
-	__u32 generation = objp[1];
 	struct inode *inode;
-	struct dentry *result;
 
 	if (ino < EXT2_FIRST_INO(sb) && ino != EXT2_ROOT_INO)
 		return ERR_PTR(-ESTALE);
@@ -275,15 +272,21 @@ static struct dentry *ext2_get_dentry(st
 		iput(inode);
 		return ERR_PTR(-ESTALE);
 	}
-	/* now to find a dentry.
-	 * If possible, get a well-connected one
-	 */
-	result = d_alloc_anon(inode);
-	if (!result) {
-		iput(inode);
-		return ERR_PTR(-ENOMEM);
-	}
-	return result;
+	return inode;
+}
+
+static struct dentry *ext2_fh_to_dentry(struct super_block *sb, struct fid *fid,
+		int fh_len, int fh_type)
+{
+	return generic_fh_to_dentry(sb, fid, fh_len, fh_type,
+				    ext2_nfs_get_inode);
+}
+
+static struct dentry *ext2_fh_to_parent(struct super_block *sb, struct fid *fid,
+		int fh_len, int fh_type)
+{
+	return generic_fh_to_parent(sb, fid, fh_len, fh_type,
+				    ext2_nfs_get_inode);
 }
 
 /* Yes, most of these are left as NULL!!
@@ -292,8 +295,9 @@ static struct dentry *ext2_get_dentry(st
  * Currently only get_parent is required.
  */
 static struct export_operations ext2_export_ops = {
+	.fh_to_dentry = ext2_fh_to_dentry,
+	.fh_to_parent = ext2_fh_to_parent,
 	.get_parent = ext2_get_parent,
-	.get_dentry = ext2_get_dentry,
 };
 
 static unsigned long get_sb_block(void **data)

--
