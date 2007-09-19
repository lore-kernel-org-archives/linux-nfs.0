From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 07/18] jfs: new export ops
Date: Wed, 19 Sep 2007 18:30:47 +0200
Message-ID: <20070919163047.GH18952@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: akpm@osdl.org
To: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IY2Rq-0003V7-3t
	for nfs@lists.sourceforge.net; Wed, 19 Sep 2007 09:30:47 -0700
Received: from verein.lst.de ([213.95.11.210] helo=mail.lst.de)
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1IY2Ru-0000xK-HC
	for nfs@lists.sourceforge.net; Wed, 19 Sep 2007 09:30:51 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Trivial switch over to the new generic helpers.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/fs/jfs/jfs_inode.h
===================================================================
--- linux-2.6.orig/fs/jfs/jfs_inode.h	2007-09-13 15:10:46.000000000 +0200
+++ linux-2.6/fs/jfs/jfs_inode.h	2007-09-13 15:19:06.000000000 +0200
@@ -18,6 +18,8 @@
 #ifndef	_H_JFS_INODE
 #define _H_JFS_INODE
 
+struct fid;
+
 extern struct inode *ialloc(struct inode *, umode_t);
 extern int jfs_fsync(struct file *, struct dentry *, int);
 extern int jfs_ioctl(struct inode *, struct file *,
@@ -32,7 +34,10 @@ extern void jfs_truncate_nolock(struct i
 extern void jfs_free_zero_link(struct inode *);
 extern struct dentry *jfs_get_parent(struct dentry *dentry);
 extern void jfs_get_inode_flags(struct jfs_inode_info *);
-extern struct dentry *jfs_get_dentry(struct super_block *sb, void *vobjp);
+extern struct dentry *jfs_fh_to_dentry(struct super_block *sb, struct fid *fid,
+	int fh_len, int fh_type);
+extern struct dentry *jfs_fh_to_parent(struct super_block *sb, struct fid *fid,
+	int fh_len, int fh_type);
 extern void jfs_set_inode_flags(struct inode *);
 extern int jfs_get_block(struct inode *, sector_t, struct buffer_head *, int);
 
Index: linux-2.6/fs/jfs/namei.c
===================================================================
--- linux-2.6.orig/fs/jfs/namei.c	2007-09-13 15:10:46.000000000 +0200
+++ linux-2.6/fs/jfs/namei.c	2007-09-13 15:19:42.000000000 +0200
@@ -20,6 +20,7 @@
 #include <linux/fs.h>
 #include <linux/ctype.h>
 #include <linux/quotaops.h>
+#include <linux/exportfs.h>
 #include "jfs_incore.h"
 #include "jfs_superblock.h"
 #include "jfs_inode.h"
@@ -1477,13 +1478,10 @@ static struct dentry *jfs_lookup(struct 
 	return dentry;
 }
 
-struct dentry *jfs_get_dentry(struct super_block *sb, void *vobjp)
+static struct inode *jfs_nfs_get_inode(struct super_block *sb,
+		u64 ino, u32 generation)
 {
-	__u32 *objp = vobjp;
-	unsigned long ino = objp[0];
-	__u32 generation = objp[1];
 	struct inode *inode;
-	struct dentry *result;
 
 	if (ino == 0)
 		return ERR_PTR(-ESTALE);
@@ -1493,20 +1491,25 @@ struct dentry *jfs_get_dentry(struct sup
 
 	if (is_bad_inode(inode) ||
 	    (generation && inode->i_generation != generation)) {
-	    	result = ERR_PTR(-ESTALE);
-		goto out_iput;
+		iput(inode);
+		return ERR_PTR(-ESTALE);
 	}
 
-	result = d_alloc_anon(inode);
-	if (!result) {
-		result = ERR_PTR(-ENOMEM);
-		goto out_iput;
-	}
-	return result;
+	return inode;
+}
 
- out_iput:
-	iput(inode);
-	return result;
+struct dentry *jfs_fh_to_dentry(struct super_block *sb, struct fid *fid,
+		int fh_len, int fh_type)
+{
+	return generic_fh_to_dentry(sb, fid, fh_len, fh_type,
+				    jfs_nfs_get_inode);
+}
+
+struct dentry *jfs_fh_to_parent(struct super_block *sb, struct fid *fid,
+		int fh_len, int fh_type)
+{
+	return generic_fh_to_parent(sb, fid, fh_len, fh_type,
+				    jfs_nfs_get_inode);
 }
 
 struct dentry *jfs_get_parent(struct dentry *dentry)
Index: linux-2.6/fs/jfs/super.c
===================================================================
--- linux-2.6.orig/fs/jfs/super.c	2007-09-13 15:10:46.000000000 +0200
+++ linux-2.6/fs/jfs/super.c	2007-09-13 15:19:06.000000000 +0200
@@ -738,7 +738,8 @@ static const struct super_operations jfs
 };
 
 static struct export_operations jfs_export_operations = {
-	.get_dentry	= jfs_get_dentry,
+	.fh_to_dentry	= jfs_fh_to_dentry,
+	.fh_to_parent	= jfs_fh_to_parent,
 	.get_parent	= jfs_get_parent,
 };
 

--

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
