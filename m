From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 4/4] [JFFS2] Reinstate NFS exportability
Date: Thu, 31 Jul 2008 22:55:11 +0100
Message-ID: <1217541311.1126.20.camel@shinybook.infradead.org>
References: <1209670979.25560.587.camel@pmac.infradead.org>
	 <20080501204820.GA5951@infradead.org>
	 <1209681898.25560.613.camel@pmac.infradead.org>
	 <18458.28833.539314.455215@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-mtd@lists.infradead.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:54661 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758164AbYGaVzZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Jul 2008 17:55:25 -0400
In-Reply-To: <18458.28833.539314.455215-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that the readdir/lookup deadlock issues have been dealt with, we can
export JFFS2 file systems again.

(For now, you have to specify fsid manually; we should add a method to
the export_ops to handle that too.)

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 fs/jffs2/super.c |   61 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 61 insertions(+), 0 deletions(-)

diff --git a/fs/jffs2/super.c b/fs/jffs2/super.c
index efd4012..2138b26 100644
--- a/fs/jffs2/super.c
+++ b/fs/jffs2/super.c
@@ -22,6 +22,7 @@
 #include <linux/mtd/super.h>
 #include <linux/ctype.h>
 #include <linux/namei.h>
+#include <linux/exportfs.h>
 #include "compr.h"
 #include "nodelist.h"
 
@@ -62,6 +63,64 @@ static int jffs2_sync_fs(struct super_block *sb, int wait)
 	return 0;
 }
 
+static struct inode *jffs2_nfs_get_inode(struct super_block *sb, uint64_t ino,
+					 uint32_t generation)
+{
+	return jffs2_iget(sb, ino);
+}
+
+static struct dentry *jffs2_fh_to_dentry(struct super_block *sb, struct fid *fid,
+					 int fh_len, int fh_type)
+{
+        return generic_fh_to_dentry(sb, fid, fh_len, fh_type,
+                                    jffs2_nfs_get_inode);
+}
+
+static struct dentry *jffs2_fh_to_parent(struct super_block *sb, struct fid *fid,
+					 int fh_len, int fh_type)
+{
+        return generic_fh_to_parent(sb, fid, fh_len, fh_type,
+                                    jffs2_nfs_get_inode);
+}
+
+static struct dentry *jffs2_get_parent(struct dentry *child)
+{
+	struct jffs2_inode_info *f;
+	struct dentry *parent;
+	struct inode *inode;
+	uint32_t pino;
+
+	if (!S_ISDIR(child->d_inode->i_mode))
+		return ERR_PTR(-EACCES);
+
+	f = JFFS2_INODE_INFO(child->d_inode);
+
+	pino = f->inocache->pino_nlink;
+
+	JFFS2_DEBUG("Parent of directory ino #%u is #%u\n",
+		    f->inocache->ino, pino);
+
+	inode = jffs2_iget(child->d_inode->i_sb, pino);
+	if (IS_ERR(inode)) {
+		JFFS2_ERROR("Failed to get inode #%u: %ld\n", pino,
+			    PTR_ERR(inode));
+		return ERR_CAST(inode);
+	}
+
+	parent = d_alloc_anon(inode);
+	if (!parent) {
+		iput(inode);
+		parent = ERR_PTR(-ENOMEM);
+	}
+	return parent;
+}
+
+static struct export_operations jffs2_export_ops = {
+	.get_parent = jffs2_get_parent,
+	.fh_to_dentry = jffs2_fh_to_dentry,
+	.fh_to_parent = jffs2_fh_to_parent,
+};
+
 static const struct super_operations jffs2_super_operations =
 {
 	.alloc_inode =	jffs2_alloc_inode,
@@ -104,6 +163,7 @@ static int jffs2_fill_super(struct super_block *sb, void *data, int silent)
 	spin_lock_init(&c->inocache_lock);
 
 	sb->s_op = &jffs2_super_operations;
+ 	sb->s_export_op = &jffs2_export_ops;
 	sb->s_flags = sb->s_flags | MS_NOATIME;
 	sb->s_xattr = jffs2_xattr_handlers;
 #ifdef CONFIG_JFFS2_FS_POSIX_ACL
@@ -161,6 +221,7 @@ static struct file_system_type jffs2_fs_type = {
 	.name =		"jffs2",
 	.get_sb =	jffs2_get_sb,
 	.kill_sb =	jffs2_kill_sb,
+	.fs_flags =	FS_NO_LOOKUP_IN_READDIR,
 };
 
 static int __init init_jffs2_fs(void)
-- 
1.5.5.1


-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

