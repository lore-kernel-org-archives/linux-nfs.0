From: Christoph Hellwig <hch@infradead.org>
Subject: [PATCH 8/8] exportfs: split out reconnecting a dentry from
	find_exported_dentry
Date: Wed, 7 Mar 2007 10:40:18 +0000
Message-ID: <20070307104018.GH22963@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HOtZD-0003J2-DB
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 02:40:19 -0800
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HOtZE-0002ls-LJ
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 02:40:21 -0800
Received: from hch by pentafluge.infradead.org with local (Exim 4.63 #1 (Red
	Hat Linux)) id 1HOtZC-0006bh-V6
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 10:40:18 +0000
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

There's a clear subfunctionality of reconnecting a given dentry to
the main dentry tree in find_exported_dentry, that can be called
both for the dentry we're looking for or it's parent directory.

This patch splits the subfunctionality out into a separate helper to
make the code more readable and document it's intent.  As a nice
side-optimization we can avoid getting a superflous dentry reference
count in the case we need to reconnect a directory on it's own.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/fs/exportfs/expfs.c
===================================================================
--- linux-2.6.orig/fs/exportfs/expfs.c	2007-03-05 15:39:40.000000000 +0100
+++ linux-2.6/fs/exportfs/expfs.c	2007-03-05 15:41:12.000000000 +0100
@@ -93,101 +93,27 @@
 	return dentry;
 }
 
-/**
- * find_exported_dentry - helper routine to implement export_operations->decode_fh
- * @sb:		The &super_block identifying the filesystem
- * @obj:	An opaque identifier of the object to be found - passed to
- *		get_inode
- * @parent:	An optional opqaue identifier of the parent of the object.
- * @acceptable:	A function used to test possible &dentries to see if they are
- *		acceptable
- * @context:	A parameter to @acceptable so that it knows on what basis to
- *		judge.
- *
- * find_exported_dentry is the central helper routine to enable file systems
- * to provide the decode_fh() export_operation.  It's main task is to take
- * an &inode, find or create an appropriate &dentry structure, and possibly
- * splice this into the dcache in the correct place.
- *
- * The decode_fh() operation provided by the filesystem should call
- * find_exported_dentry() with the same parameters that it received except
- * that instead of the file handle fragment, pointers to opaque identifiers
- * for the object and optionally its parent are passed.  The default decode_fh
- * routine passes one pointer to the start of the filehandle fragment, and
- * one 8 bytes into the fragment.  It is expected that most filesystems will
- * take this approach, though the offset to the parent identifier may well be
- * different.
+
+/*
+ * Make sure target_dir is fully connected to the dentry tree.
  *
- * find_exported_dentry() will call get_dentry to get an dentry pointer from
- * the file system.  If any &dentry in the d_alias list is acceptable, it will
- * be returned.  Otherwise find_exported_dentry() will attempt to splice a new
- * &dentry into the dcache using get_name() and get_parent() to find the
- * appropriate place.
+ * It may already be, as the flag isn't always updated when connection happens.
  */
-
-struct dentry *
-find_exported_dentry(struct super_block *sb, void *obj, void *parent,
-		     int (*acceptable)(void *context, struct dentry *de),
-		     void *context)
+static int
+reconnect_path(struct super_block *sb, struct dentry *target_dir)
 {
-	struct dentry *result = NULL;
-	struct dentry *target_dir;
-	int err = -ESTALE;
-	struct export_operations *nops = sb->s_export_op;
-	struct dentry *alias;
-	int noprogress;
 	char nbuf[NAME_MAX+1];
+	int noprogress = 0;
+	int err = -ESTALE;
 
 	/*
-	 * Attempt to find the inode.
-	 */
-	result = exportfs_get_dentry(sb, obj);
-	if (IS_ERR(result))
-		return result;
-
-	if (S_ISDIR(result->d_inode->i_mode)) {
-		if (!(result->d_flags & DCACHE_DISCONNECTED)) {
-			if (acceptable(context, result))
-				return result;
-			err = -EACCES;
-			goto err_result;
-		}
-
-		target_dir = dget(result);
-	} else {
-		alias = find_acceptable_alias(result, acceptable, context);
-		if (alias)
-			return alias;
-
-		if (parent == NULL)
-			goto err_result;
-
-		target_dir = exportfs_get_dentry(sb,parent);
-		if (IS_ERR(target_dir)) {
-			err = PTR_ERR(target_dir);
-			goto err_result;
-		}
-	}
-
-	/*
-	 * Now we need to make sure that target_dir is properly connected.
-	 * It may already be, as the flag isn't always updated when connection
-	 * happens.
-	 * So, we walk up parent links until we find a connected directory,
-	 * or we run out of directories.  Then we find the parent, find
-	 * the name of the child in that parent, and do a lookup.
-	 * This should connect the child into the parent
-	 * We then repeat.
-	 */
-
-	/* it is possible that a confused file system might not let us complete 
+	 * It is possible that a confused file system might not let us complete
 	 * the path to the root.  For example, if get_parent returns a directory
 	 * in which we cannot find a name for the child.  While this implies a
 	 * very sick filesystem we don't want it to cause knfsd to spin.  Hence
 	 * the noprogress counter.  If we go through the loop 10 times (2 is
 	 * probably enough) without getting anywhere, we just give up
 	 */
-	noprogress = 0;
 	while (target_dir->d_flags & DCACHE_DISCONNECTED && noprogress++ < 10) {
 		struct dentry *pd = find_disconnected_root(target_dir);
 
@@ -223,18 +149,20 @@
 			struct dentry *npd;
 
 			mutex_lock(&pd->d_inode->i_mutex);
-			if (nops->get_parent)
-				ppd = nops->get_parent(pd);
+			if (sb->s_export_op->get_parent)
+				ppd = sb->s_export_op->get_parent(pd);
 			mutex_unlock(&pd->d_inode->i_mutex);
 
 			if (IS_ERR(ppd)) {
 				err = PTR_ERR(ppd);
-				dprintk("find_exported_dentry: get_parent of %ld failed, err %d\n",
-					pd->d_inode->i_ino, err);
+				dprintk("%s: get_parent of %ld failed, err %d\n",
+					__FUNCTION__, pd->d_inode->i_ino, err);
 				dput(pd);
 				break;
 			}
-			dprintk("find_exported_dentry: find name of %lu in %lu\n", pd->d_inode->i_ino, ppd->d_inode->i_ino);
+
+			dprintk("%s: find name of %lu in %lu\n", __FUNCTION__,
+				pd->d_inode->i_ino, ppd->d_inode->i_ino);
 			err = exportfs_get_name(ppd, nbuf, pd);
 			if (err) {
 				dput(ppd);
@@ -246,13 +174,14 @@
 					continue;
 				break;
 			}
-			dprintk("find_exported_dentry: found name: %s\n", nbuf);
+			dprintk("%s: found name: %s\n", __FUNCTION__, nbuf);
 			mutex_lock(&ppd->d_inode->i_mutex);
 			npd = lookup_one_len(nbuf, ppd, strlen(nbuf));
 			mutex_unlock(&ppd->d_inode->i_mutex);
 			if (IS_ERR(npd)) {
 				err = PTR_ERR(npd);
-				dprintk("find_exported_dentry: lookup failed: %d\n", err);
+				dprintk("%s: lookup failed: %d\n",
+					__FUNCTION__, err);
 				dput(ppd);
 				dput(pd);
 				break;
@@ -265,7 +194,7 @@
 			if (npd == pd)
 				noprogress = 0;
 			else
-				printk("find_exported_dentry: npd != pd\n");
+				printk("%s: npd != pd\n", __FUNCTION__);
 			dput(npd);
 			dput(ppd);
 			if (IS_ROOT(pd)) {
@@ -281,15 +210,101 @@
 		/* something went wrong - oh-well */
 		if (!err)
 			err = -ESTALE;
-		goto err_target;
+		return err;
 	}
-	/* if we weren't after a directory, have one more step to go */
-	if (result != target_dir) {
-		struct dentry *nresult;
+
+	return 0;
+}
+
+/**
+ * find_exported_dentry - helper routine to implement export_operations->decode_fh
+ * @sb:		The &super_block identifying the filesystem
+ * @obj:	An opaque identifier of the object to be found - passed to
+ *		get_inode
+ * @parent:	An optional opqaue identifier of the parent of the object.
+ * @acceptable:	A function used to test possible &dentries to see if they are
+ *		acceptable
+ * @context:	A parameter to @acceptable so that it knows on what basis to
+ *		judge.
+ *
+ * find_exported_dentry is the central helper routine to enable file systems
+ * to provide the decode_fh() export_operation.  It's main task is to take
+ * an &inode, find or create an appropriate &dentry structure, and possibly
+ * splice this into the dcache in the correct place.
+ *
+ * The decode_fh() operation provided by the filesystem should call
+ * find_exported_dentry() with the same parameters that it received except
+ * that instead of the file handle fragment, pointers to opaque identifiers
+ * for the object and optionally its parent are passed.  The default decode_fh
+ * routine passes one pointer to the start of the filehandle fragment, and
+ * one 8 bytes into the fragment.  It is expected that most filesystems will
+ * take this approach, though the offset to the parent identifier may well be
+ * different.
+ *
+ * find_exported_dentry() will call get_dentry to get an dentry pointer from
+ * the file system.  If any &dentry in the d_alias list is acceptable, it will
+ * be returned.  Otherwise find_exported_dentry() will attempt to splice a new
+ * &dentry into the dcache using get_name() and get_parent() to find the
+ * appropriate place.
+ */
+
+struct dentry *
+find_exported_dentry(struct super_block *sb, void *obj, void *parent,
+		     int (*acceptable)(void *context, struct dentry *de),
+		     void *context)
+{
+	struct dentry *result, *alias;
+	int err = -ESTALE;
+
+	/*
+	 * Attempt to find the inode.
+	 */
+	result = exportfs_get_dentry(sb, obj);
+	if (IS_ERR(result))
+		return result;
+
+	if (S_ISDIR(result->d_inode->i_mode)) {
+		if (!(result->d_flags & DCACHE_DISCONNECTED)) {
+			if (acceptable(context, result))
+				return result;
+			err = -EACCES;
+			goto err_result;
+		}
+
+		err = reconnect_path(sb, result);
+		if (err)
+			goto err_result;
+	} else {
+		struct dentry *target_dir, *nresult;
+		char nbuf[NAME_MAX+1];
+
+		alias = find_acceptable_alias(result, acceptable, context);
+		if (alias)
+			return alias;
+
+		if (parent == NULL)
+			goto err_result;
+
+		target_dir = exportfs_get_dentry(sb,parent);
+		if (IS_ERR(target_dir)) {
+			err = PTR_ERR(target_dir);
+			goto err_result;
+		}
+
+		err = reconnect_path(sb, target_dir);
+		if (err) {
+			dput(target_dir);
+			goto err_result;
+		}
+
+		/*
+		 * If we weren't after a directory, have one more step to go.
+		 */
 		err = exportfs_get_name(target_dir, nbuf, result);
 		if (!err) {
 			mutex_lock(&target_dir->d_inode->i_mutex);
-			nresult = lookup_one_len(nbuf, target_dir, strlen(nbuf));
+			nresult = lookup_one_len(nbuf, target_dir,
+						 strlen(nbuf));
 			mutex_unlock(&target_dir->d_inode->i_mutex);
 			if (!IS_ERR(nresult)) {
 				if (nresult->d_inode) {
@@ -299,8 +314,8 @@
 					dput(nresult);
 			}
 		}
+		dput(target_dir);
 	}
-	dput(target_dir);
 
 	alias = find_acceptable_alias(result, acceptable, context);
 	if (alias)
@@ -315,8 +330,6 @@
 	 */
 	return ERR_PTR(-EACCES);
 
- err_target:
-	dput(target_dir);
  err_result:
 	dput(result);
 	return ERR_PTR(err);

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
