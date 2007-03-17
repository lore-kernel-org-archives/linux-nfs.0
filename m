From: Christoph Hellwig <hch@infradead.org>
Subject: [PATCH 7/18] ext4: new export ops
Date: Sat, 17 Mar 2007 01:11:01 +0000
Message-ID: <20070317011101.GH24947@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Trivial switch over to the new generic helpers.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/fs/ext4/super.c
===================================================================
--- linux-2.6.orig/fs/ext4/super.c	2007-03-13 18:19:43.000000000 +0100
+++ linux-2.6/fs/ext4/super.c	2007-03-13 19:09:18.000000000 +0100
@@ -607,13 +607,10 @@ static int ext4_show_options(struct seq_
 }
 
 
-static struct dentry *ext4_get_dentry(struct super_block *sb, void *vobjp)
+static struct inode *ext4_nfs_get_inode(struct super_block *sb,
+		u64 ino, u32 generation)
 {
-	__u32 *objp = vobjp;
-	unsigned long ino = objp[0];
-	__u32 generation = objp[1];
 	struct inode *inode;
-	struct dentry *result;
 
 	if (ino < EXT4_FIRST_INO(sb) && ino != EXT4_ROOT_INO)
 		return ERR_PTR(-ESTALE);
@@ -636,15 +633,20 @@ static struct dentry *ext4_get_dentry(st
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
+static struct dentry *ext4_fh_to_dentry(struct super_block *sb, struct fid *fid,
+		int fh_len, int fh_type)
+{
+	return generic_fh_to_dentry(sb, fid, fh_len, fh_type, ext4_nfs_get_inode);
+}
+
+static struct dentry *ext4_fh_to_parent(struct super_block *sb, struct fid *fid,
+		int fh_len, int fh_type)
+{
+	return generic_fh_to_parent(sb, fid, fh_len, fh_type, ext4_nfs_get_inode);
 }
 
 #ifdef CONFIG_QUOTA
@@ -714,8 +716,9 @@ static const struct super_operations ext
 };
 
 static struct export_operations ext4_export_ops = {
+	.fh_to_dentry = ext4_fh_to_dentry,
+	.fh_to_parent = ext4_fh_to_parent,
 	.get_parent = ext4_get_parent,
-	.get_dentry = ext4_get_dentry,
 };
 
 enum {
