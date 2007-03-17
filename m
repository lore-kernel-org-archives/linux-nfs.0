From: Christoph Hellwig <hch@infradead.org>
Subject: [PATCH 15/18] gfs2: new export ops
Date: Sat, 17 Mar 2007 01:12:26 +0000
Message-ID: <20070317011226.GP24947@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Convert gfs2 to the new ops.  It's a nice little cleanup that allows
to get rid of an data structure aswell.

Btw, it looks like the old code could scribble over random stack
memory for the parent case where gfs2_get_dentry access the imode
field in the gfs2_fh_obj structure but only gets a smaller 
gfs2_inum_host passed.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/fs/gfs2/ops_export.c
===================================================================
--- linux-2.6.orig/fs/gfs2/ops_export.c	2007-03-13 18:18:17.000000000 +0100
+++ linux-2.6/fs/gfs2/ops_export.c	2007-03-13 18:19:09.000000000 +0100
@@ -27,42 +27,6 @@
 #include "rgrp.h"
 #include "util.h"
 
-static struct dentry *gfs2_decode_fh(struct super_block *sb,
-				     __u32 *p,
-				     int fh_len,
-				     int fh_type,
-				     int (*acceptable)(void *context,
-						       struct dentry *dentry),
-				     void *context)
-{
-	__be32 *fh = (__force __be32 *)p;
-	struct gfs2_fh_obj fh_obj;
-	struct gfs2_inum_host *this, parent;
-
-	this 		= &fh_obj.this;
-	fh_obj.imode 	= DT_UNKNOWN;
-	memset(&parent, 0, sizeof(struct gfs2_inum));
-
-	switch (fh_len) {
-	case GFS2_LARGE_FH_SIZE:
-		parent.no_formal_ino = ((u64)be32_to_cpu(fh[4])) << 32;
-		parent.no_formal_ino |= be32_to_cpu(fh[5]);
-		parent.no_addr = ((u64)be32_to_cpu(fh[6])) << 32;
-		parent.no_addr |= be32_to_cpu(fh[7]);
-		fh_obj.imode = be32_to_cpu(fh[8]);
-	case GFS2_SMALL_FH_SIZE:
-		this->no_formal_ino = ((u64)be32_to_cpu(fh[0])) << 32;
-		this->no_formal_ino |= be32_to_cpu(fh[1]);
-		this->no_addr = ((u64)be32_to_cpu(fh[2])) << 32;
-		this->no_addr |= be32_to_cpu(fh[3]);
-		break;
-	default:
-		return NULL;
-	}
-
-	return gfs2_export_ops.find_exported_dentry(sb, &fh_obj, &parent,
-						    acceptable, context);
-}
 
 static int gfs2_encode_fh(struct dentry *dentry, __u32 *p, int *len,
 			  int connectable)
@@ -190,11 +154,10 @@ static struct dentry *gfs2_get_parent(st
 	return dentry;
 }
 
-static struct dentry *gfs2_get_dentry(struct super_block *sb, void *inum_obj)
+static struct dentry *gfs2_get_dentry(struct super_block *sb,
+		struct gfs2_inum_host *inum, u32 imode)
 {
 	struct gfs2_sbd *sdp = sb->s_fs_info;
-	struct gfs2_fh_obj *fh_obj = (struct gfs2_fh_obj *)inum_obj;
-	struct gfs2_inum_host *inum = &fh_obj->this;
 	struct gfs2_holder i_gh, ri_gh, rgd_gh;
 	struct gfs2_rgrpd *rgd;
 	struct inode *inode;
@@ -237,7 +200,7 @@ static struct dentry *gfs2_get_dentry(st
 	gfs2_glock_dq_uninit(&rgd_gh);
 	gfs2_glock_dq_uninit(&ri_gh);
 
-	inode = gfs2_inode_lookup(sb, inum, fh_obj->imode);
+	inode = gfs2_inode_lookup(sb, inum, imode);
 	if (!inode)
 		goto fail;
 	if (IS_ERR(inode)) {
@@ -280,11 +243,46 @@ fail:
 	return ERR_PTR(error);
 }
 
+static struct dentry *gfs2_fh_to_dentry(struct super_block *sb, struct fid *fid,
+		int fh_len, int fh_type)
+{
+	struct gfs2_inum_host this;
+	__be32 *fh = (__force __be32 *)fid->raw;
+
+	if (fh_type != GFS2_LARGE_FH_SIZE && fh_type != GFS2_SMALL_FH_SIZE)
+		return NULL;
+
+	this.no_formal_ino = ((u64)be32_to_cpu(fh[0])) << 32;
+	this.no_formal_ino |= be32_to_cpu(fh[1]);
+	this.no_addr = ((u64)be32_to_cpu(fh[2])) << 32;
+	this.no_addr |= be32_to_cpu(fh[3]);
+
+	return gfs2_get_dentry(sb, &this,
+		fh_type == GFS2_LARGE_FH_SIZE ? be32_to_cpu(fh[8]) : 0);
+}
+
+static struct dentry *gfs2_fh_to_parent(struct super_block *sb, struct fid *fid,
+		int fh_len, int fh_type)
+{
+	struct gfs2_inum_host parent;
+	__be32 *fh = (__force __be32 *)fid->raw;
+
+	if (fh_type != GFS2_LARGE_FH_SIZE)
+		return NULL;
+
+	parent.no_formal_ino = ((u64)be32_to_cpu(fh[4])) << 32;
+	parent.no_formal_ino |= be32_to_cpu(fh[5]);
+	parent.no_addr = ((u64)be32_to_cpu(fh[6])) << 32;
+	parent.no_addr |= be32_to_cpu(fh[7]);
+
+	return gfs2_get_dentry(sb, &parent, 0);
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
 
Index: linux-2.6/fs/gfs2/ops_export.h
===================================================================
--- linux-2.6.orig/fs/gfs2/ops_export.h	2007-03-13 18:18:17.000000000 +0100
+++ linux-2.6/fs/gfs2/ops_export.h	2007-03-13 18:18:26.000000000 +0100
@@ -16,9 +16,5 @@
 #define GFS2_LARGE_FH_SIZE 10
 
 extern struct export_operations gfs2_export_ops;
-struct gfs2_fh_obj {
-	struct gfs2_inum_host this;
-	__u32            imode;
-};
 
 #endif /* __OPS_EXPORT_DOT_H__ */
