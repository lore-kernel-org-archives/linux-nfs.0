From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: PATCH - kNFSd/FAT in 2.5.14 - Add export_operations support for FAT
Date: Tue, 7 May 2002 14:52:37 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15575.23957.22455.667453@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 174wyR-0005N5-00
	for <nfs@lists.sourceforge.net>; Mon, 06 May 2002 21:53:15 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Tue, 7 May 2002 14:53:03 +1000
To: Linus Torvalds <torvalds@transmeta.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>



This actually contains a lot of code that is never used,
as we don't currently attempt to load an inode that isn't
in cache, so the fat_get_parent is never actually reached.
However it is there (and should be right) incase some brave 
soul does decide to enhance fat_get_dentry accordingly.



 ----------- Diffstat output ------------
 ./fs/fat/inode.c   |   72 ++++++++++++++++++++++++++++++++++++++++++++---------
 ./fs/msdos/namei.c |   13 ++++++++-
 ./fs/vfat/namei.c  |   18 +++++++++----
 3 files changed, 85 insertions(+), 18 deletions(-)

--- ./fs/fat/inode.c	2002/05/07 04:35:26	1.1
+++ ./fs/fat/inode.c	2002/05/07 04:35:29	1.2
@@ -438,20 +438,26 @@
  *  4/  parent->i_logstart - maybe used to hunt for the file on disc
  *
  */
-struct dentry *fat_fh_to_dentry(struct super_block *sb, __u32 *fh,
-				int len, int fhtype, int parent)
+
+struct dentry *fat_decode_fh(struct super_block *sb, __u32 *fh,
+			     int len, int fhtype, 
+			     int (*acceptable)(void *context, struct dentry *de),
+			     void *context)
 {
-	struct inode *inode = NULL;
-	struct dentry *result;
 
 	if (fhtype != 3)
 		return ERR_PTR(-ESTALE);
 	if (len < 5)
 		return ERR_PTR(-ESTALE);
-	/* We cannot find the parent,
-	   It better just *be* there */
-	if (parent)
-		return ERR_PTR(-ESTALE);
+
+	return sb->s_export_op->find_exported_dentry(sb, fh, NULL, acceptable, context);
+}
+
+struct dentry *fat_get_dentry(struct super_block *sb, void *inump)
+{
+	struct inode *inode = NULL;
+	struct dentry *result;
+	__u32 *fh = inump;
 
 	inode = iget(sb, fh[0]);
 	if (!inode || is_bad_inode(inode) ||
@@ -497,12 +503,13 @@
 		iput(inode);
 		return ERR_PTR(-ENOMEM);
 	}
+	result->d_op = sb->s_root->d_op;
 	result->d_vfs_flags |= DCACHE_REFERENCED;
 	return result;
 		
 }
 
-int fat_dentry_to_fh(struct dentry *de, __u32 *fh, int *lenp, int needparent)
+int fat_encode_fh(struct dentry *de, __u32 *fh, int *lenp, int connectable)
 {
 	int len = *lenp;
 	struct inode *inode =  de->d_inode;
@@ -520,6 +527,43 @@
 	return 3;
 }
 
+struct dentry *fat_get_parent(struct dentry *child)
+{
+	struct buffer_head *bh=NULL;
+	struct msdos_dir_entry *de = NULL;
+	struct dentry *parent = NULL;
+	int res;
+	int ino = 0;
+	struct inode *inode;
+
+	lock_kernel();
+	res = fat_scan(child->d_inode, MSDOS_DOTDOT, &bh, &de, &ino);
+
+	if (res < 0)
+		goto out;
+	inode = fat_build_inode(child->d_sb, de, ino, &res);
+	if (res)
+		goto out;
+	if (!inode)
+		res = -EACCES;
+	else {
+		parent = d_alloc_anon(inode);
+		if (!parent) {
+			iput(inode);
+			res = -ENOMEM;
+		}
+	}
+
+ out:
+	if(bh)
+		fat_brelse(child->d_sb, bh);
+	unlock_kernel();
+	if (res)
+		return ERR_PTR(res);
+	else
+		return parent;
+}
+
 static kmem_cache_t *fat_inode_cachep;
 
 static struct inode *fat_alloc_inode(struct super_block *sb)
@@ -574,8 +618,13 @@
 	clear_inode:	fat_clear_inode,
 
 	read_inode:	make_bad_inode,
-	fh_to_dentry:	fat_fh_to_dentry,
-	dentry_to_fh:	fat_dentry_to_fh,
+};
+
+static struct export_operations fat_export_ops = {
+	decode_fh:	fat_decode_fh,
+	encode_fh:	fat_encode_fh,
+	get_dentry:	fat_get_dentry,
+	get_parent:	fat_get_parent,
 };
 
 /*
@@ -609,6 +658,7 @@
 
 	sb->s_magic = MSDOS_SUPER_MAGIC;
 	sb->s_op = &fat_sops;
+	sb->s_export_op = &fat_export_ops;
 	sbi->options.isvfat = isvfat;
 	sbi->dir_ops = fs_dir_inode_ops;
 	sbi->cvf_format = &default_cvf;
--- ./fs/msdos/namei.c	2002/05/07 04:35:26	1.1
+++ ./fs/msdos/namei.c	2002/05/07 04:35:29	1.2
@@ -221,13 +221,22 @@
 	if (res)
 		goto out;
 add:
-	d_add(dentry, inode);
+	if (inode) {
+		dentry = d_splice_alias(inode, dentry);
+		dentry->d_op = &msdos_dentry_operations;
+	} else {
+		d_add(dentry, inode);
+		dentry = NULL;
+	}
 	res = 0;
 out:
 	if (bh)
 		fat_brelse(sb, bh);
 	unlock_kernel();
-	return ERR_PTR(res);
+	if (res)
+		return ERR_PTR(res);
+	else
+		return dentry;
 }
 
 /***** Creates a directory entry (name is already formatted). */
--- ./fs/vfat/namei.c	2002/05/07 04:35:26	1.1
+++ ./fs/vfat/namei.c	2002/05/07 04:35:29	1.2
@@ -1020,6 +1020,14 @@
 	unlock_kernel();
 	dentry->d_op = &vfat_dentry_ops[table];
 	dentry->d_time = dentry->d_parent->d_inode->i_version;
+	if (inode) {
+		dentry = d_splice_alias(inode, dentry);
+		if (dentry) {
+			dentry->d_op = &vfat_dentry_ops[table];
+			dentry->d_time = dentry->d_parent->d_inode->i_version;
+		}
+		return dentry;
+	}
 	d_add(dentry,inode);
 	return NULL;
 }
@@ -1305,11 +1313,11 @@
 		if (sbi->options.posixfs) {
 			sbi->options.name_check = 's';
 		}
-		if (sbi->options.name_check != 's') {
-			sb->s_root->d_op = &vfat_dentry_ops[0];
-		} else {
-			sb->s_root->d_op = &vfat_dentry_ops[2];
-		}
+	}
+	if (sbi->options.name_check != 's') {
+		sb->s_root->d_op = &vfat_dentry_ops[0];
+	} else {
+		sb->s_root->d_op = &vfat_dentry_ops[2];
 	}
 	return 0;
 }

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
