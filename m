From: Christoph Hellwig <hch@infradead.org>
Subject: [PATCH 6/18] ext3: new export ops
Date: Sat, 17 Mar 2007 01:10:48 +0000
Message-ID: <20070317011048.GG24947@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Trivial switch over to the new generic helpers.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/fs/ext3/super.c
===================================================================
--- linux-2.6.orig/fs/ext3/super.c	2007-03-13 18:19:43.000000000 +0100
+++ linux-2.6/fs/ext3/super.c	2007-03-13 19:08:17.000000000 +0100
@@ -556,13 +556,10 @@ static int ext3_show_options(struct seq_
 }
 
 
-static struct dentry *ext3_get_dentry(struct super_block *sb, void *vobjp)
+static struct inode *ext3_nfs_get_inode(struct super_block *sb,
+		u64 ino, u32 generation)
 {
-	__u32 *objp = vobjp;
-	unsigned long ino = objp[0];
-	__u32 generation = objp[1];
 	struct inode *inode;
-	struct dentry *result;
 
 	if (ino < EXT3_FIRST_INO(sb) && ino != EXT3_ROOT_INO)
 		return ERR_PTR(-ESTALE);
@@ -585,15 +582,20 @@ static struct dentry *ext3_get_dentry(st
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
+
+	return inode;
+}
+
+static struct dentry *ext3_fh_to_dentry(struct super_block *sb, struct fid *fid,
+		int fh_len, int fh_type)
+{
+	return generic_fh_to_dentry(sb, fid, fh_len, fh_type, ext3_nfs_get_inode);
+}
+
+static struct dentry *ext3_fh_to_parent(struct super_block *sb, struct fid *fid,
+		int fh_len, int fh_type)
+{
+	return generic_fh_to_parent(sb, fid, fh_len, fh_type, ext3_nfs_get_inode);
 }
 
 #ifdef CONFIG_QUOTA
@@ -663,8 +665,9 @@ static const struct super_operations ext
 };
 
 static struct export_operations ext3_export_ops = {
+	.fh_to_dentry = ext3_fh_to_dentry,
+	.fh_to_parent = ext3_fh_to_parent,
 	.get_parent = ext3_get_parent,
-	.get_dentry = ext3_get_dentry,
 };
 
 enum {
