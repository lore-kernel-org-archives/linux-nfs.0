From: Christoph Hellwig <hch@lst.de>
Subject: [PATH 15/19] gfs2: new export ops
Date: Thu, 30 Aug 2007 15:17:08 +0200
Message-ID: <20070830131708.GP6834@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Convert gfs2 to the new ops.   Uses a similar structure to the generic
helpers, but gfs2 has it's own file handle formats.


Signed-off-by: Christoph Hellwig <hch@lst.de>


Index: linux-2.6/fs/gfs2/ops_export.c
===================================================================
--- linux-2.6.orig/fs/gfs2/ops_export.c	2007-07-19 15:56:46.000000000 +0200
+++ linux-2.6/fs/gfs2/ops_export.c	2007-07-20 19:58:06.000000000 +0200
@@ -31,40 +31,6 @@
 #define GFS2_LARGE_FH_SIZE 8
 #define GFS2_OLD_FH_SIZE 10
 
-static struct dentry *gfs2_decode_fh(struct super_block *sb,
-				     __u32 *p,
-				     int fh_len,
-				     int fh_type,
-				     int (*acceptable)(void *context,
-						       struct dentry *dentry),
-				     void *context)
-{
-	__be32 *fh = (__force __be32 *)p;
-	struct gfs2_inum_host inum, parent;
-
-	memset(&parent, 0, sizeof(struct gfs2_inum));
-
-	switch (fh_len) {
-	case GFS2_LARGE_FH_SIZE:
-	case GFS2_OLD_FH_SIZE:
-		parent.no_formal_ino = ((u64)be32_to_cpu(fh[4])) << 32;
-		parent.no_formal_ino |= be32_to_cpu(fh[5]);
-		parent.no_addr = ((u64)be32_to_cpu(fh[6])) << 32;
-		parent.no_addr |= be32_to_cpu(fh[7]);
-	case GFS2_SMALL_FH_SIZE:
-		inum.no_formal_ino = ((u64)be32_to_cpu(fh[0])) << 32;
-		inum.no_formal_ino |= be32_to_cpu(fh[1]);
-		inum.no_addr = ((u64)be32_to_cpu(fh[2])) << 32;
-		inum.no_addr |= be32_to_cpu(fh[3]);
-		break;
-	default:
-		return NULL;
-	}
-
-	return gfs2_export_ops.find_exported_dentry(sb, &inum, &parent,
-						    acceptable, context);
-}
-
 static int gfs2_encode_fh(struct dentry *dentry, __u32 *p, int *len,
 			  int connectable)
 {
@@ -189,10 +155,10 @@ static struct dentry *gfs2_get_parent(st
 	return dentry;
 }
 
-static struct dentry *gfs2_get_dentry(struct super_block *sb, void *inum_obj)
+static struct dentry *gfs2_get_dentry(struct super_block *sb,
+		struct gfs2_inum_host *inum)
 {
 	struct gfs2_sbd *sdp = sb->s_fs_info;
-	struct gfs2_inum_host *inum = inum_obj;
 	struct gfs2_holder i_gh, ri_gh, rgd_gh;
 	struct gfs2_rgrpd *rgd;
 	struct inode *inode;
@@ -289,11 +255,50 @@ fail:
 	return ERR_PTR(error);
 }
 
+static struct dentry *gfs2_fh_to_dentry(struct super_block *sb, struct fid *fid,
+		int fh_len, int fh_type)
+{
+	struct gfs2_inum_host this;
+	__be32 *fh = (__force __be32 *)fid->raw;
+
+	switch (fh_type) {
+	case GFS2_SMALL_FH_SIZE:
+	case GFS2_LARGE_FH_SIZE:
+	case GFS2_OLD_FH_SIZE:
+		this.no_formal_ino = ((u64)be32_to_cpu(fh[0])) << 32;
+		this.no_formal_ino |= be32_to_cpu(fh[1]);
+		this.no_addr = ((u64)be32_to_cpu(fh[2])) << 32;
+		this.no_addr |= be32_to_cpu(fh[3]);
+		return gfs2_get_dentry(sb, &this);
+	default:
+		return NULL;
+	}
+}
+
+static struct dentry *gfs2_fh_to_parent(struct super_block *sb, struct fid *fid,
+		int fh_len, int fh_type)
+{
+	struct gfs2_inum_host parent;
+	__be32 *fh = (__force __be32 *)fid->raw;
+
+	switch (fh_type) {
+	case GFS2_LARGE_FH_SIZE:
+	case GFS2_OLD_FH_SIZE:
+		parent.no_formal_ino = ((u64)be32_to_cpu(fh[4])) << 32;
+		parent.no_formal_ino |= be32_to_cpu(fh[5]);
+		parent.no_addr = ((u64)be32_to_cpu(fh[6])) << 32;
+		parent.no_addr |= be32_to_cpu(fh[7]);
+		return gfs2_get_dentry(sb, &parent);
+	default:
+		return NULL;
+	}
+}
+
 struct export_operations gfs2_export_ops = {
-	.decode_fh = gfs2_decode_fh,
 	.encode_fh = gfs2_encode_fh,
+	.fh_to_dentry = gfs2_fh_to_dentry,
+	.fh_to_parent = gfs2_fh_to_parent,
 	.get_name = gfs2_get_name,
 	.get_parent = gfs2_get_parent,
-	.get_dentry = gfs2_get_dentry,
 };
 

--
