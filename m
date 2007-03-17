From: Christoph Hellwig <hch@infradead.org>
Subject: [PATCH 5/18] ext2: new export ops
Date: Sat, 17 Mar 2007 01:10:37 +0000
Message-ID: <20070317011037.GF24947@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Trivial switch over to the new generic helpers.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/fs/ext2/super.c
===================================================================
--- linux-2.6.orig/fs/ext2/super.c	2007-03-13 18:19:43.000000000 +0100
+++ linux-2.6/fs/ext2/super.c	2007-03-13 19:06:57.000000000 +0100
@@ -251,13 +251,10 @@ static const struct super_operations ext
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
@@ -278,15 +275,19 @@ static struct dentry *ext2_get_dentry(st
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
+	return generic_fh_to_dentry(sb, fid, fh_len, fh_type, ext2_nfs_get_inode);
+}
+
+static struct dentry *ext2_fh_to_parent(struct super_block *sb, struct fid *fid,
+		int fh_len, int fh_type)
+{
+	return generic_fh_to_parent(sb, fid, fh_len, fh_type, ext2_nfs_get_inode);
 }
 
 /* Yes, most of these are left as NULL!!
@@ -295,8 +296,9 @@ static struct dentry *ext2_get_dentry(st
  * Currently only get_parent is required.
  */
 static struct export_operations ext2_export_ops = {
+	.fh_to_dentry = ext2_fh_to_dentry,
+	.fh_to_parent = ext2_fh_to_parent,
 	.get_parent = ext2_get_parent,
-	.get_dentry = ext2_get_dentry,
 };
 
 static unsigned long get_sb_block(void **data)
