From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 4/4] Reinstate NFS exportability
Date: Sat, 09 Aug 2008 21:03:33 +0100
Message-ID: <1218312213.5063.9.camel@pmac.infradead.org>
References: <1217607571.3454.417.camel@pmac.infradead.org>
	 <76bd70e30808011047u3cd0a56cg3b2d62e01afed014@mail.gmail.com>
	 <20080802182644.GE30454@fieldses.org>
	 <18581.40178.976747.769343@notabene.brown>
	 <76bd70e30808031015l36db41bexf319e85ba7acc4e9@mail.gmail.com>
	 <18582.21855.2092.903688@notabene.brown>
	 <76bd70e30808032319u65e35dbdj9cc5be07e1aef829@mail.gmail.com>
	 <20080805085157.GG21635@disturbed>
	 <18584.56584.98868.881298@notabene.brown>
	 <20080806000805.GJ21635@disturbed>  <20080806195635.GA31126@fieldses.org>
	 <1218053443.5111.148.camel@pmac.infradead.org>
	 <1218300478.26926.114.camel@pmac.infradead.org>
	 <1218311710.26926.125.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Neil Brown <neilb@suse.de>, chucklever@gmail.com,
	viro@zeniv.linux.org.uk, Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-mtd@lists.infradead.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:51404 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751774AbYHIUDq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 9 Aug 2008 16:03:46 -0400
In-Reply-To: <1218311710.26926.125.camel-ZP4jZrcIevRpWr+L1FloEB2eb7JE58TQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that the readdir/lookup deadlock issues have been dealt with, we can
export JFFS2 file systems again.

(For now, you have to specify fsid manually; we should add a method to
the export_ops to handle that too.)

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 fs/jffs2/super.c |   59 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 59 insertions(+), 0 deletions(-)

diff --git a/fs/jffs2/super.c b/fs/jffs2/super.c
index efd4012..7f03a28 100644
--- a/fs/jffs2/super.c
+++ b/fs/jffs2/super.c
@@ -22,6 +22,7 @@
 #include <linux/mtd/super.h>
 #include <linux/ctype.h>
 #include <linux/namei.h>
+#include <linux/exportfs.h>
 #include "compr.h"
 #include "nodelist.h"
 
@@ -62,6 +63,63 @@ static int jffs2_sync_fs(struct super_block *sb, int wait)
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
+	BUG_ON(!S_ISDIR(child->d_inode->i_mode));
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
@@ -104,6 +162,7 @@ static int jffs2_fill_super(struct super_block *sb, void *data, int silent)
 	spin_lock_init(&c->inocache_lock);
 
 	sb->s_op = &jffs2_super_operations;
+ 	sb->s_export_op = &jffs2_export_ops;
 	sb->s_flags = sb->s_flags | MS_NOATIME;
 	sb->s_xattr = jffs2_xattr_handlers;
 #ifdef CONFIG_JFFS2_FS_POSIX_ACL
-- 
1.5.5.1



-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation



