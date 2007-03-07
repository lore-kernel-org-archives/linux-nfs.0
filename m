From: Christoph Hellwig <hch@infradead.org>
Subject: [PATCH 2/8] exportfs: remove iget abuse
Date: Wed, 7 Mar 2007 10:39:44 +0000
Message-ID: <20070307103944.GC22963@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HOtYf-0003CA-3R
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 02:39:57 -0800
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HOtYf-0002WY-R6
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 02:39:47 -0800
Received: from hch by pentafluge.infradead.org with local (Exim 4.63 #1 (Red
	Hat Linux)) id 1HOtYe-0006TU-9i
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 10:39:44 +0000
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

When the exportfs interface was added the expectation was that
filesystems provide an operation to convert from a file handle
to an inode/dentry, but it kept a backwards compat option that
sill calls into iget.

Calling into iget from non-filesystem code is very bad, because
it gives to little information to filesystem, and simply crashes
if the filesystem doesn't implement the ->read_inode routine.

Fortunately ther are only two filesystems left using this fallback:
efs and jfs.  This patch moves a copy of export_iget to each
of those to implement the get_dentry method.

While this is a temporary increase of lines of code in the kernel
it allows for a much cleaner interface and important code restructuring
in later patches.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/fs/exportfs/expfs.c
===================================================================
--- linux-2.6.orig/fs/exportfs/expfs.c	2007-02-11 08:30:47.000000000 +0100
+++ linux-2.6/fs/exportfs/expfs.c	2007-02-11 08:39:47.000000000 +0100
@@ -392,61 +392,11 @@
 	return error;
 }
 
-
-static struct dentry *export_iget(struct super_block *sb, unsigned long ino, __u32 generation)
+static struct dentry *get_dentry(struct super_block *sb, void *vobjp)
 {
-
-	/* iget isn't really right if the inode is currently unallocated!!
-	 * This should really all be done inside each filesystem
-	 *
-	 * ext2fs' read_inode has been strengthed to return a bad_inode if
-	 * the inode had been deleted.
-	 *
-	 * Currently we don't know the generation for parent directory, so
-	 * a generation of 0 means "accept any"
-	 */
-	struct inode *inode;
-	struct dentry *result;
-	if (ino == 0)
-		return ERR_PTR(-ESTALE);
-	inode = iget(sb, ino);
-	if (inode == NULL)
-		return ERR_PTR(-ENOMEM);
-	if (is_bad_inode(inode)
-	    || (generation && inode->i_generation != generation)
-		) {
-		/* we didn't find the right inode.. */
-		dprintk("fh_verify: Inode %lu, Bad count: %d %d or version  %u %u\n",
-			inode->i_ino,
-			inode->i_nlink, atomic_read(&inode->i_count),
-			inode->i_generation,
-			generation);
-
-		iput(inode);
-		return ERR_PTR(-ESTALE);
-	}
-	/* now to find a dentry.
-	 * If possible, get a well-connected one
-	 */
-	result = d_alloc_anon(inode);
-	if (!result) {
-		iput(inode);
-		return ERR_PTR(-ENOMEM);
-	}
-	return result;
+	return ERR_PTR(-ESTALE);
 }
 
-
-static struct dentry *get_object(struct super_block *sb, void *vobjp)
-{
-	__u32 *objp = vobjp;
-	unsigned long ino = objp[0];
-	__u32 generation = objp[1];
-
-	return export_iget(sb, ino, generation);
-}
-
-
 /**
  * export_encode_fh - default export_operations->encode_fh function
  * @dentry:  the dentry to encode
@@ -525,7 +475,7 @@
 
 	.get_name	= get_name,
 	.get_parent	= get_parent,
-	.get_dentry	= get_object,
+	.get_dentry	= get_dentry,
 };
 
 EXPORT_SYMBOL(export_op_default);
Index: linux-2.6/fs/jfs/jfs_inode.h
===================================================================
--- linux-2.6.orig/fs/jfs/jfs_inode.h	2007-01-30 16:36:51.000000000 +0100
+++ linux-2.6/fs/jfs/jfs_inode.h	2007-02-11 08:39:47.000000000 +0100
@@ -31,6 +31,7 @@
 extern void jfs_truncate_nolock(struct inode *, loff_t);
 extern void jfs_free_zero_link(struct inode *);
 extern struct dentry *jfs_get_parent(struct dentry *dentry);
+extern struct dentry *jfs_get_dentry(struct super_block *sb, void *vobjp);
 extern void jfs_set_inode_flags(struct inode *);
 extern int jfs_get_block(struct inode *, sector_t, struct buffer_head *, int);
 
Index: linux-2.6/fs/jfs/namei.c
===================================================================
--- linux-2.6.orig/fs/jfs/namei.c	2007-02-11 08:17:31.000000000 +0100
+++ linux-2.6/fs/jfs/namei.c	2007-02-11 08:39:47.000000000 +0100
@@ -1477,6 +1477,38 @@
 	return dentry;
 }
 
+struct dentry *jfs_get_dentry(struct super_block *sb, void *vobjp)
+{
+	__u32 *objp = vobjp;
+	unsigned long ino = objp[0];
+	__u32 generation = objp[1];
+	struct inode *inode;
+	struct dentry *result;
+
+	if (ino == 0)
+		return ERR_PTR(-ESTALE);
+	inode = iget(sb, ino);
+	if (inode == NULL)
+		return ERR_PTR(-ENOMEM);
+
+	if (is_bad_inode(inode) ||
+	    (generation && inode->i_generation != generation)) {
+	    	result = ERR_PTR(-ESTALE);
+		goto out_iput;
+	}
+
+	result = d_alloc_anon(inode);
+	if (!result) {
+		result = ERR_PTR(-ENOMEM);
+		goto out_iput;
+	}
+	return result;
+
+ out_iput:
+	iput(inode);
+	return result;
+}
+
 struct dentry *jfs_get_parent(struct dentry *dentry)
 {
 	struct super_block *sb = dentry->d_inode->i_sb;
Index: linux-2.6/fs/jfs/super.c
===================================================================
--- linux-2.6.orig/fs/jfs/super.c	2007-02-11 08:30:47.000000000 +0100
+++ linux-2.6/fs/jfs/super.c	2007-02-11 08:39:47.000000000 +0100
@@ -738,6 +738,7 @@
 };
 
 static struct export_operations jfs_export_operations = {
+	.get_dentry	= jfs_get_dentry,
 	.get_parent	= jfs_get_parent,
 };
 
Index: linux-2.6/fs/efs/namei.c
===================================================================
--- linux-2.6.orig/fs/efs/namei.c	2007-02-11 08:40:07.000000000 +0100
+++ linux-2.6/fs/efs/namei.c	2007-02-11 08:40:39.000000000 +0100
@@ -75,6 +75,38 @@
 	return NULL;
 }
 
+struct dentry *efs_get_dentry(struct super_block *sb, void *vobjp)
+{
+	__u32 *objp = vobjp;
+	unsigned long ino = objp[0];
+	__u32 generation = objp[1];
+	struct inode *inode;
+	struct dentry *result;
+
+	if (ino == 0)
+		return ERR_PTR(-ESTALE);
+	inode = iget(sb, ino);
+	if (inode == NULL)
+		return ERR_PTR(-ENOMEM);
+
+	if (is_bad_inode(inode) ||
+	    (generation && inode->i_generation != generation)) {
+	    	result = ERR_PTR(-ESTALE);
+		goto out_iput;
+	}
+
+	result = d_alloc_anon(inode);
+	if (!result) {
+		result = ERR_PTR(-ENOMEM);
+		goto out_iput;
+	}
+	return result;
+
+ out_iput:
+	iput(inode);
+	return result;
+}
+
 struct dentry *efs_get_parent(struct dentry *child)
 {
 	struct dentry *parent;
Index: linux-2.6/fs/efs/super.c
===================================================================
--- linux-2.6.orig/fs/efs/super.c	2007-02-11 08:40:49.000000000 +0100
+++ linux-2.6/fs/efs/super.c	2007-02-11 08:41:03.000000000 +0100
@@ -116,6 +116,7 @@
 };
 
 static struct export_operations efs_export_ops = {
+	.get_dentry	= efs_get_dentry,
 	.get_parent	= efs_get_parent,
 };
 
Index: linux-2.6/include/linux/efs_fs.h
===================================================================
--- linux-2.6.orig/include/linux/efs_fs.h	2007-02-11 08:41:14.000000000 +0100
+++ linux-2.6/include/linux/efs_fs.h	2007-02-11 08:41:27.000000000 +0100
@@ -45,6 +45,7 @@
 extern int efs_get_block(struct inode *, sector_t, struct buffer_head *, int);
 
 extern struct dentry *efs_lookup(struct inode *, struct dentry *, struct nameidata *);
+extern struct dentry *efs_get_dentry(struct super_block *sb, void *vobjp);
 extern struct dentry *efs_get_parent(struct dentry *);
 extern int efs_bmap(struct inode *, int);
 

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
