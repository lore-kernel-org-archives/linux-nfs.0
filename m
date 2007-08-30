From: Christoph Hellwig <hch@lst.de>
Subject: [PATH 16/19] ocfs2: new export ops
Date: Thu, 30 Aug 2007 15:17:14 +0200
Message-ID: <20070830131714.GQ6834@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

OCFS2 has it's own 64bit-firendly filehandle format so we can't use
the generic helpers here.  I'll add a struct for the types later.


Signed-off-by: Christoph Hellwig <hch@lst.de>


Index: linux-2.6/fs/ocfs2/export.c
===================================================================
--- linux-2.6.orig/fs/ocfs2/export.c	2007-05-06 13:51:17.000000000 +0200
+++ linux-2.6/fs/ocfs2/export.c	2007-06-12 15:54:44.000000000 +0200
@@ -45,9 +45,9 @@ struct ocfs2_inode_handle
 	u32 ih_generation;
 };
 
-static struct dentry *ocfs2_get_dentry(struct super_block *sb, void *vobjp)
+static struct dentry *ocfs2_get_dentry(struct super_block *sb,
+		struct ocfs2_inode_handle *handle)
 {
-	struct ocfs2_inode_handle *handle = vobjp;
 	struct inode *inode;
 	struct dentry *result;
 
@@ -200,54 +200,37 @@ bail:
 	return type;
 }
 
-static struct dentry *ocfs2_decode_fh(struct super_block *sb, u32 *fh_in,
-				      int fh_len, int fileid_type,
-				      int (*acceptable)(void *context,
-						        struct dentry *de),
-				      void *context)
+static struct dentry *ocfs2_fh_to_dentry(struct super_block *sb,
+		struct fid *fid, int fh_len, int fh_type)
 {
-	struct ocfs2_inode_handle handle, parent;
-	struct dentry *ret = NULL;
-	__le32 *fh = (__force __le32 *) fh_in;
-
-	mlog_entry("(0x%p, 0x%p, %d, %d, 0x%p, 0x%p)\n",
-		   sb, fh, fh_len, fileid_type, acceptable, context);
+	struct ocfs2_inode_handle handle;
 
-	if (fh_len < 3 || fileid_type > 2)
-		goto bail;
+	if (fh_len < 3 || fh_type > 2)
+		return NULL;
 
-	if (fileid_type == 2) {
-		if (fh_len < 6)
-			goto bail;
-
-		parent.ih_blkno = (u64)le32_to_cpu(fh[3]) << 32;
-		parent.ih_blkno |= (u64)le32_to_cpu(fh[4]);
-		parent.ih_generation = le32_to_cpu(fh[5]);
-
-		mlog(0, "Decoding parent: blkno: %llu, generation: %u\n",
-		     (unsigned long long)parent.ih_blkno,
-		     parent.ih_generation);
-	}
-
-	handle.ih_blkno = (u64)le32_to_cpu(fh[0]) << 32;
-	handle.ih_blkno |= (u64)le32_to_cpu(fh[1]);
-	handle.ih_generation = le32_to_cpu(fh[2]);
+	handle.ih_blkno = (u64)le32_to_cpu(fid->raw[0]) << 32;
+	handle.ih_blkno |= (u64)le32_to_cpu(fid->raw[1]);
+	handle.ih_generation = le32_to_cpu(fid->raw[2]);
+	return ocfs2_get_dentry(sb, &handle);
+}
 
-	mlog(0, "Encoding fh: blkno: %llu, generation: %u\n",
-	     (unsigned long long)handle.ih_blkno, handle.ih_generation);
+static struct dentry *ocfs2_fh_to_parent(struct super_block *sb,
+		struct fid *fid, int fh_len, int fh_type)
+{
+	struct ocfs2_inode_handle parent;
 
-	ret = ocfs2_export_ops.find_exported_dentry(sb, &handle, &parent,
-						    acceptable, context);
+	if (fh_type != 2 || fh_len < 6)
+		return NULL;
 
-bail:
-	mlog_exit_ptr(ret);
-	return ret;
+	parent.ih_blkno = (u64)le32_to_cpu(fid->raw[3]) << 32;
+	parent.ih_blkno |= (u64)le32_to_cpu(fid->raw[4]);
+	parent.ih_generation = le32_to_cpu(fid->raw[5]);
+	return ocfs2_get_dentry(sb, &parent);
 }
 
 struct export_operations ocfs2_export_ops = {
-	.decode_fh	= ocfs2_decode_fh,
 	.encode_fh	= ocfs2_encode_fh,
-
+	.fh_to_dentry	= ocfs2_fh_to_dentry,
+	.fh_to_parent	= ocfs2_fh_to_parent,
 	.get_parent	= ocfs2_get_parent,
-	.get_dentry	= ocfs2_get_dentry,
 };

--
