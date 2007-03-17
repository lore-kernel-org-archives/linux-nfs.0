From: Christoph Hellwig <hch@infradead.org>
Subject: [PATCH 13/18] shmem: new export ops
Date: Sat, 17 Mar 2007 01:12:08 +0000
Message-ID: <20070317011208.GN24947@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

I'm not sure what people were thinking when adding support to nfs
export tmpfs, but here's the conversion anyway:


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/mm/shmem.c
===================================================================
--- linux-2.6.orig/mm/shmem.c	2007-02-11 10:46:30.000000000 +0100
+++ linux-2.6/mm/shmem.c	2007-02-11 10:53:12.000000000 +0100
@@ -1977,33 +1977,25 @@
 	return ino->i_ino == inum && fh[0] == ino->i_generation;
 }
 
-static struct dentry *shmem_get_dentry(struct super_block *sb, void *vfh)
+static struct dentry *shmem_fh_to_dentry(struct super_block *sb,
+		struct fid *fid, int fh_len, int fh_type)
 {
-	struct dentry *de = NULL;
 	struct inode *inode;
-	__u32 *fh = vfh;
-	__u64 inum = fh[2];
-	inum = (inum << 32) | fh[1];
+	struct dentry *dentry = NULL;
+	u64 inum = fid->raw[2];
+	inum = (inum << 32) | fid->raw[1];
 
-	inode = ilookup5(sb, (unsigned long)(inum+fh[0]), shmem_match, vfh);
+	if (fh_len < 3)
+		return NULL;
+
+	inode = ilookup5(sb, (unsigned long)(inum + fid->raw[0]),
+			shmem_match, fid->raw);
 	if (inode) {
-		de = d_find_alias(inode);
+		dentry = d_find_alias(inode);
 		iput(inode);
 	}
 
-	return de? de: ERR_PTR(-ESTALE);
-}
-
-static struct dentry *shmem_decode_fh(struct super_block *sb, __u32 *fh,
-		int len, int type,
-		int (*acceptable)(void *context, struct dentry *de),
-		void *context)
-{
-	if (len < 3)
-		return ERR_PTR(-ESTALE);
-
-	return sb->s_export_op->find_exported_dentry(sb, fh, NULL, acceptable,
-							context);
+	return dentry;
 }
 
 static int shmem_encode_fh(struct dentry *dentry, __u32 *fh, int *len,
@@ -2038,9 +2030,8 @@
 
 static struct export_operations shmem_export_ops = {
 	.get_parent     = shmem_get_parent,
-	.get_dentry     = shmem_get_dentry,
 	.encode_fh      = shmem_encode_fh,
-	.decode_fh      = shmem_decode_fh,
+	.fh_to_dentry	= shmem_fh_to_dentry,
 };
 
 static int shmem_parse_options(char *options, int *mode, uid_t *uid,
