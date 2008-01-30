From: Rasmus Rohde <rohde-3mLe3WyXyAE@public.gmane.org>
Subject: [NFS] [PATCH] Make UDF exportable
Date: Wed, 30 Jan 2008 21:53:24 +0100
Message-ID: <1201726404.2976.8.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:46027 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751646AbYA3UyM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Jan 2008 15:54:12 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JKJwZ-0008UC-Fs
	for linux-nfs@vger.kernel.org; Thu, 31 Jan 2008 07:54:03 +1100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've cooked together a patch for making UDF exportable.

It is based on the code found in ISO fs. Since I am far from an expert
in this area bugs may be present.

--- fs/udf/namei.c.orig	2007-10-10 16:22:30.000000000 +0200
+++ fs/udf/namei.c	2008-01-30 21:39:00.000000000 +0100
@@ -31,6 +31,7 @@
 #include <linux/smp_lock.h>
 #include <linux/buffer_head.h>
 #include <linux/sched.h>
+#include <linux/exportfs.h>
 
 static inline int udf_match(int len1, const char *name1, int len2,
 			    const char *name2)
@@ -315,9 +316,8 @@ static struct dentry *udf_lookup(struct 
 		}
 	}
 	unlock_kernel();
-	d_add(dentry, inode);
 
-	return NULL;
+	return d_splice_alias(inode, dentry);
 }
 
 static struct fileIdentDesc *udf_add_entry(struct inode *dir,
@@ -1231,6 +1231,151 @@ end_rename:
 	return retval;
 }
 
+static struct dentry *udf_export_get_parent(struct dentry *child)
+{
+	struct dentry *parent;
+	struct inode *inode = NULL;
+	struct dentry dotdot;
+	struct fileIdentDesc cfi;
+	struct udf_fileident_bh fibh;
+
+	dotdot.d_name.name = "..";
+	dotdot.d_name.len = 2;
+
+	lock_kernel();
+	if (udf_find_entry(child->d_inode, &dotdot, &fibh, &cfi)) {
+		if (fibh.sbh != fibh.ebh)
+			brelse(fibh.ebh);
+		brelse(fibh.sbh);
+		
+		inode = udf_iget(child->d_inode->i_sb,
+				 lelb_to_cpu(cfi.icb.extLocation));
+		if (!inode) {
+			unlock_kernel();
+			return ERR_PTR(-EACCES);
+		}
+	} else {
+		unlock_kernel();
+		return ERR_PTR(-EACCES);
+	}
+	unlock_kernel();
+
+	parent = d_alloc_anon(inode);
+	if (!parent) {
+		iput(inode);
+		parent = ERR_PTR(-ENOMEM);
+	}
+
+	return parent;
+}
+
+
+static struct dentry *
+udf_export_iget(struct super_block *sb, u32 block,
+		u16 offset, __u32 generation)
+{
+	struct inode *inode;
+	struct dentry *result;
+	kernel_lb_addr loc;
+
+	if (block == 0)
+		return ERR_PTR(-ESTALE);
+
+	loc.logicalBlockNum = block;
+	loc.partitionReferenceNum = offset;
+	inode = udf_iget(sb, loc);
+
+	if (inode == NULL)
+		return ERR_PTR(-ENOMEM);
+
+	if (is_bad_inode(inode)
+	    || (generation && inode->i_generation != generation))
+	{
+		iput(inode);
+		return ERR_PTR(-ESTALE);
+	}
+	result = d_alloc_anon(inode);
+	if (!result) {
+		iput(inode);
+		return ERR_PTR(-ENOMEM);
+	}
+	return result;
+}
+
+
+struct udf_fid {
+	u32 block;
+	u16 partref;
+	u16 parent_partref;
+	u32 generation;
+	u32 parent_block;
+	u32 parent_generation;
+};
+
+static struct dentry *udf_fh_to_dentry(struct super_block *sb,
+	struct fid *fid, int fh_len, int fh_type)
+{
+	struct udf_fid *ufid = (struct udf_fid *)fid;
+
+	if (fh_len < 3 || fh_type > 2)
+		return NULL;
+
+	return udf_export_iget(sb, ufid->block, ufid->partref,
+			ufid->generation);
+}
+
+static struct dentry *udf_fh_to_parent(struct super_block *sb,
+		struct fid *fid, int fh_len, int fh_type)
+{
+	struct udf_fid *ufid = (struct udf_fid *)fid;
+
+	if (fh_type != 2)
+		return NULL;
+
+	return udf_export_iget(sb,
+			fh_len > 2 ? ufid->parent_block : 0,
+			ufid->parent_partref,
+			fh_len > 4 ? ufid->parent_generation : 0);
+}
+static int
+udf_encode_fh(struct dentry *de, __u32 *fh, int *lenp, int connectable)
+{
+	int len = *lenp;
+	struct inode *inode =  de->d_inode;
+	kernel_lb_addr location = UDF_I_LOCATION(inode);
+	struct udf_fid *ufid = (struct udf_fid *)fh;
+	int type = 1;
+
+	if (len < 3 || (connectable && len < 5))
+		return 255;
+
+	*lenp = 3;
+	ufid->block = location.logicalBlockNum;
+	ufid->partref = location.partitionReferenceNum;
+	ufid->generation = inode->i_generation;
+
+	if (connectable && !S_ISDIR(inode->i_mode)) {
+		spin_lock(&de->d_lock);
+		inode = de->d_parent->d_inode;
+		location = UDF_I_LOCATION(inode);
+		ufid->parent_block = location.logicalBlockNum;
+		ufid->parent_partref = location.partitionReferenceNum;	
+		ufid->parent_generation = inode->i_generation;
+		spin_unlock(&de->d_lock);
+		*lenp = 5;
+		type = 2;
+	}
+
+	return type;
+}
+
+struct export_operations udf_export_ops = {
+	.encode_fh	= udf_encode_fh,
+	.fh_to_dentry   = udf_fh_to_dentry,
+	.fh_to_parent   = udf_fh_to_parent,
+	.get_parent     = udf_export_get_parent,
+};
+
 const struct inode_operations udf_dir_inode_operations = {
 	.lookup				= udf_lookup,
 	.create				= udf_create,

--- fs/udf/super.c.orig	2008-01-30 17:57:23.000000000 +0100
+++ fs/udf/super.c	2008-01-30 21:38:10.000000000 +0100
@@ -71,7 +71,7 @@
 #define VDS_POS_LENGTH			7
 
 static char error_buf[1024];
-
+extern struct export_operations udf_export_ops;
 /* These are the "meat" - everything else is stuffing */
 static int udf_fill_super(struct super_block *, void *, int);
 static void udf_put_super(struct super_block *);
@@ -1490,6 +1490,7 @@ static int udf_fill_super(struct super_b
 
 	/* Fill in the rest of the superblock */
 	sb->s_op = &udf_sb_ops;
+	sb->s_export_op = &udf_export_ops;
 	sb->dq_op = NULL;
 	sb->s_dirt = 0;
 	sb->s_magic = UDF_SUPER_MAGIC;



-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

