From: Christoph Hellwig <hch@infradead.org>
Subject: [PATCH 4/8] exportfs: remove CALL macro
Date: Wed, 7 Mar 2007 10:40:02 +0000
Message-ID: <20070307104002.GE22963@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HOtYx-0003FL-DZ
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 02:40:04 -0800
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HOtYy-0002gl-Kg
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 02:40:05 -0800
Received: from hch by pentafluge.infradead.org with local (Exim 4.63 #1 (Red
	Hat Linux)) id 1HOtYw-0006Va-UL
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 10:40:02 +0000
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

Currently exportfs uses a way to call methods very differently from
the rest of the kernel.  This patch changes it to the standard conventions
for method calls.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/fs/exportfs/expfs.c
===================================================================
--- linux-2.6.orig/fs/exportfs/expfs.c	2007-02-13 17:11:55.000000000 +0100
+++ linux-2.6/fs/exportfs/expfs.c	2007-02-13 17:11:58.000000000 +0100
@@ -5,13 +5,39 @@
 #include <linux/module.h>
 #include <linux/mount.h>
 #include <linux/smp_lock.h>
+#include <linux/mount.h>
 #include <linux/namei.h>
 
-struct export_operations export_op_default;
+#define dprintk(fmt, args...) do{}while(0)
 
-#define	CALL(ops,fun) ((ops->fun)?(ops->fun):export_op_default.fun)
 
-#define dprintk(fmt, args...) do{}while(0)
+static int get_name(struct dentry *dentry, char *name,
+		struct dentry *child);
+
+
+static struct dentry *exportfs_get_dentry(struct super_block *sb, void *obj)
+{
+	struct dentry *result = ERR_PTR(-ESTALE);
+
+	if (sb->s_export_op->get_dentry) {
+		result = sb->s_export_op->get_dentry(sb, obj);
+		if (!result)
+			result = ERR_PTR(-ESTALE);
+	}
+
+	return result;
+}
+
+static int exportfs_get_name(struct dentry *dir, char *name,
+		struct dentry *child)
+{
+	struct export_operations *nop = dir->d_sb->s_export_op;
+
+	if (nop->get_name)
+		return nop->get_name(dir, name, child);
+	else
+		return get_name(dir, name, child);
+}
 
 static struct dentry *
 find_acceptable_alias(struct dentry *result,
@@ -79,7 +105,7 @@
 {
 	struct dentry *result = NULL;
 	struct dentry *target_dir;
-	int err;
+	int err = -ESTALE;
 	struct export_operations *nops = sb->s_export_op;
 	struct dentry *alias;
 	int noprogress;
@@ -88,14 +114,10 @@
 	/*
 	 * Attempt to find the inode.
 	 */
-	result = CALL(sb->s_export_op,get_dentry)(sb,obj);
-	err = -ESTALE;
-	if (result == NULL)
-		goto err_out;
-	if (IS_ERR(result)) {
-		err = PTR_ERR(result);
-		goto err_out;
-	}
+	result = exportfs_get_dentry(sb, obj);
+	if (IS_ERR(result))
+		return result;
+
 	if (S_ISDIR(result->d_inode->i_mode) &&
 	    (result->d_flags & DCACHE_DISCONNECTED)) {
 		/* it is an unconnected directory, we must connect it */
@@ -123,11 +145,11 @@
 		if (parent == NULL)
 			goto err_result;
 
-		target_dir = CALL(sb->s_export_op,get_dentry)(sb,parent);
-		if (IS_ERR(target_dir))
+		target_dir = exportfs_get_dentry(sb,parent);
+		if (IS_ERR(target_dir)) {
 			err = PTR_ERR(target_dir);
-		if (target_dir == NULL || IS_ERR(target_dir))
 			goto err_result;
+		}
 	}
 	/*
 	 * Now we need to make sure that target_dir is properly connected.
@@ -178,18 +200,27 @@
 			spin_unlock(&pd->d_lock);
 			noprogress = 0;
 		} else {
-			/* we have hit the top of a disconnected path.  Try
-			 * to find parent and connect
-			 * note: racing with some other process renaming a
-			 * directory isn't much of a problem here.  If someone
-			 * renames the directory, it will end up properly
-			 * connected, which is what we want
+			/*
+			 * We have hit the top of a disconnected path, try to
+			 * find parent and connect.
+			 *
+			 * Racing with some other process renaming a directory
+			 * isn't much of a problem here.  If someone renames
+			 * the directory, it will end up properly connected,
+			 * which is what we want
+			 *
+			 * Getting the parent can't be supported generically,
+			 * the locking is too icky.
+			 *
+			 * Instead we just return EACCES.  If server reboots
+			 * or inodes get flushed, you lose
 			 */
-			struct dentry *ppd;
+			struct dentry *ppd = ERR_PTR(-EACCES);
 			struct dentry *npd;
 
 			mutex_lock(&pd->d_inode->i_mutex);
-			ppd = CALL(nops,get_parent)(pd);
+			if (nops->get_parent)
+				ppd = nops->get_parent(pd);
 			mutex_unlock(&pd->d_inode->i_mutex);
 
 			if (IS_ERR(ppd)) {
@@ -200,7 +231,7 @@
 				break;
 			}
 			dprintk("find_exported_dentry: find name of %lu in %lu\n", pd->d_inode->i_ino, ppd->d_inode->i_ino);
-			err = CALL(nops,get_name)(ppd, nbuf, pd);
+			err = exportfs_get_name(ppd, nbuf, pd);
 			if (err) {
 				dput(ppd);
 				dput(pd);
@@ -251,7 +282,7 @@
 	/* if we weren't after a directory, have one more step to go */
 	if (result != target_dir) {
 		struct dentry *nresult;
-		err = CALL(nops,get_name)(target_dir, nbuf, result);
+		err = exportfs_get_name(target_dir, nbuf, result);
 		if (!err) {
 			mutex_lock(&target_dir->d_inode->i_mutex);
 			nresult = lookup_one_len(nbuf, target_dir, strlen(nbuf));
@@ -287,23 +318,9 @@
 	dput(target_dir);
  err_result:
 	dput(result);
- err_out:
 	return ERR_PTR(err);
 }
 
-
-
-static struct dentry *get_parent(struct dentry *child)
-{
-	/* get_parent cannot be supported generically, the locking
-	 * is too icky.
-	 * instead, we just return EACCES.  If server reboots or inodes
-	 * get flushed, you lose
-	 */
-	return ERR_PTR(-EACCES);
-}
-
-
 struct getdents_callback {
 	char *name;		/* name that was found. It already points to a
 				   buffer NAME_MAX+1 is size */
@@ -393,11 +410,6 @@
 	return error;
 }
 
-static struct dentry *get_dentry(struct super_block *sb, void *vobjp)
-{
-	return ERR_PTR(-ESTALE);
-}
-
 /**
  * export_encode_fh - default export_operations->encode_fh function
  * @dentry:  the dentry to encode
@@ -473,9 +485,15 @@
 int exportfs_encode_fh(struct dentry *dentry, __u32 *fh, int *max_len,
 		int connectable)
 {
-	struct export_operations *nop = dentry->d_sb->s_export_op;
+ 	struct export_operations *nop = dentry->d_sb->s_export_op;
+	int error;
+
+	if (nop->encode_fh)
+		error = nop->encode_fh(dentry, fh, max_len, connectable);
+	else
+		error = export_encode_fh(dentry, fh, max_len, connectable);
 
-	return CALL(nop, encode_fh)(dentry, fh, max_len, connectable);
+	return error;
 }
 EXPORT_SYMBOL_GPL(exportfs_encode_fh);
 
@@ -484,21 +502,20 @@
 		void *context)
 {
 	struct export_operations *nop = mnt->mnt_sb->s_export_op;
+	struct dentry *result;
 
-	return CALL(nop, decode_fh)(mnt->mnt_sb, fh, fh_len, fileid_type,
+	if (nop->decode_fh) {
+		result = nop->decode_fh(mnt->mnt_sb, fh, fh_len, fileid_type,
+			acceptable, context);
+	} else {
+		result = export_decode_fh(mnt->mnt_sb, fh, fh_len, fileid_type,
 			acceptable, context);
+	}
+
+	return result;
 }
 EXPORT_SYMBOL_GPL(exportfs_decode_fh);
 
-struct export_operations export_op_default = {
-	.decode_fh	= export_decode_fh,
-	.encode_fh	= export_encode_fh,
-
-	.get_name	= get_name,
-	.get_parent	= get_parent,
-	.get_dentry	= get_dentry,
-};
-
 EXPORT_SYMBOL(find_exported_dentry);
 
 MODULE_LICENSE("GPL");

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
