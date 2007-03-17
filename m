From: Christoph Hellwig <hch@infradead.org>
Subject: [PATCH 11/18] fat: new export ops
Date: Sat, 17 Mar 2007 01:11:46 +0000
Message-ID: <20070317011146.GL24947@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Very little changes here, fat had a mostly no op decode_fh before
and does not store any parent information.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/fs/fat/inode.c
===================================================================
--- linux-2.6.orig/fs/fat/inode.c	2007-03-13 19:22:40.000000000 +0100
+++ linux-2.6/fs/fat/inode.c	2007-03-13 19:23:13.000000000 +0100
@@ -651,24 +651,15 @@ static const struct super_operations fat
  * of i_logstart is used to store the directory entry offset.
  */
 
-static struct dentry *
-fat_decode_fh(struct super_block *sb, __u32 *fh, int len, int fhtype,
-	      int (*acceptable)(void *context, struct dentry *de),
-	      void *context)
-{
-	if (fhtype != 3)
-		return ERR_PTR(-ESTALE);
-	if (len < 5)
-		return ERR_PTR(-ESTALE);
-
-	return sb->s_export_op->find_exported_dentry(sb, fh, NULL, acceptable, context);
-}
-
-static struct dentry *fat_get_dentry(struct super_block *sb, void *inump)
+static struct dentry *fat_fh_to_dentry(struct super_block *sb,
+		struct fid *fid, int fh_len, int fh_type)
 {
 	struct inode *inode = NULL;
 	struct dentry *result;
-	__u32 *fh = inump;
+	u32 *fh = fid->raw;
+
+	if (fh_len < 5 || fh_type != 3)
+		return NULL;
 
 	inode = iget(sb, fh[0]);
 	if (!inode || is_bad_inode(inode) || inode->i_generation != fh[1]) {
@@ -782,9 +773,8 @@ out:
 }
 
 static struct export_operations fat_export_ops = {
-	.decode_fh	= fat_decode_fh,
 	.encode_fh	= fat_encode_fh,
-	.get_dentry	= fat_get_dentry,
+	.fh_to_dentry	= fat_fh_to_dentry,
 	.get_parent	= fat_get_parent,
 };
 
