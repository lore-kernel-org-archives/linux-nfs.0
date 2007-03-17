From: Christoph Hellwig <hch@infradead.org>
Subject: [PATCH 12/18] isofs: new export ops
Date: Sat, 17 Mar 2007 01:11:58 +0000
Message-ID: <20070317011158.GM24947@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Nice little cleanup by consolidating things a little and using
a structure for the special file handle format.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/fs/isofs/export.c
===================================================================
--- linux-2.6.orig/fs/isofs/export.c	2007-02-11 10:31:19.000000000 +0100
+++ linux-2.6/fs/isofs/export.c	2007-02-11 10:45:25.000000000 +0100
@@ -42,16 +42,6 @@
 	return result;
 }
 
-static struct dentry *
-isofs_export_get_dentry(struct super_block *sb, void *vobjp)
-{
-	__u32 *objp = vobjp;
-	unsigned long block = objp[0];
-	unsigned long offset = objp[1];
-	__u32 generation = objp[2];
-	return isofs_export_iget(sb, block, offset, generation);
-}
-
 /* This function is surprisingly simple.  The trick is understanding
  * that "child" is always a directory. So, to find its parent, you
  * simply need to find its ".." entry, normalize its block and offset,
@@ -182,43 +172,44 @@
 	return type;
 }
 
+struct isofs_fid {
+	u32 block;
+	u16 offset;
+	u16 parent_offset;
+	u32 generation;
+	u32 parent_block;
+	u32 parent_generation;
+};
 
-static struct dentry *
-isofs_export_decode_fh(struct super_block *sb,
-		       __u32 *fh32,
-		       int fh_len,
-		       int fileid_type,
-		       int (*acceptable)(void *context, struct dentry *de),
-		       void *context)
+static struct dentry *isofs_fh_to_dentry(struct super_block *sb,
+	struct fid *fid, int fh_len, int fh_type)
 {
-	__u16 *fh16 = (__u16*)fh32;
-	__u32 child[3];   /* The child is what triggered all this. */
-	__u32 parent[3];  /* The parent is just along for the ride. */
+	struct isofs_fid *ifid = (struct isofs_fid *)fid;
 
-	if (fh_len < 3 || fileid_type > 2)
+	if (fh_len < 3 || fh_type > 2)
 		return NULL;
 
-	child[0] = fh32[0];
-	child[1] = fh16[2];  /* fh16 [sic] */
-	child[2] = fh32[2];
-
-	parent[0] = 0;
-	parent[1] = 0;
-	parent[2] = 0;
-	if (fileid_type == 2) {
-		if (fh_len > 2) parent[0] = fh32[3];
-		parent[1] = fh16[3];  /* fh16 [sic] */
-		if (fh_len > 4) parent[2] = fh32[4];
-	}
-
-	return sb->s_export_op->find_exported_dentry(sb, child, parent,
-						     acceptable, context);
+	return isofs_export_iget(sb, ifid->block, ifid->offset,
+			ifid->generation);
 }
 
+static struct dentry *isofs_fh_to_parent(struct super_block *sb,
+		struct fid *fid, int fh_len, int fh_type)
+{
+	struct isofs_fid *ifid = (struct isofs_fid *)fid;
+
+	if (fh_type != 2)
+		return NULL;
+
+	return isofs_export_iget(sb,
+			fh_len > 2 ? ifid->parent_block : 0,
+			ifid->parent_offset,
+			fh_len > 4 ? ifid->parent_generation : 0);
+}
 
 struct export_operations isofs_export_ops = {
-	.decode_fh	= isofs_export_decode_fh,
 	.encode_fh	= isofs_export_encode_fh,
-	.get_dentry	= isofs_export_get_dentry,
+	.fh_to_dentry	= isofs_fh_to_dentry,
+	.fh_to_parent	= isofs_fh_to_parent,
 	.get_parent     = isofs_export_get_parent,
 };
