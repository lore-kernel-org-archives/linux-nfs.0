From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 18/18] exportfs: update documentation
Date: Wed, 19 Sep 2007 18:31:38 +0200
Message-ID: <20070919163138.GS18952@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org
To: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Update deocumentation to the current state of affairs.  Remove duplicated
method descruptions in exportfs.h and point to Documentation/filesystems/
Exporting instead.  Add a little file header comment in expfs.c describing
what's going on and mentioning Neils and my copyright [1].

[1] Neil, in case you want a different/additional attribution just change
    the patch in your queue to reflect the preferred version.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6-xfs/Documentation/filesystems/Exporting
===================================================================
--- linux-2.6-xfs.orig/Documentation/filesystems/Exporting	2007-09-17 14:35:01.000000000 +0200
+++ linux-2.6-xfs/Documentation/filesystems/Exporting	2007-09-17 14:37:19.000000000 +0200
@@ -2,9 +2,12 @@
 Making Filesystems Exportable
 =============================
 
-Most filesystem operations require a dentry (or two) as a starting
+Overview
+--------
+
+All filesystem operations require a dentry (or two) as a starting
 point.  Local applications have a reference-counted hold on suitable
-dentrys via open file descriptors or cwd/root.  However remote
+dentries via open file descriptors or cwd/root.  However remote
 applications that access a filesystem via a remote filesystem protocol
 such as NFS may not be able to hold such a reference, and so need a
 different way to refer to a particular dentry.  As the alternative
@@ -13,14 +16,14 @@ server-reboot (among other things, thoug
 problematic), there is no simple answer like 'filename'.
 
 The mechanism discussed here allows each filesystem implementation to
-specify how to generate an opaque (out side of the filesystem) byte
+specify how to generate an opaque (outside of the filesystem) byte
 string for any dentry, and how to find an appropriate dentry for any
 given opaque byte string.
 This byte string will be called a "filehandle fragment" as it
 corresponds to part of an NFS filehandle.
 
 A filesystem which supports the mapping between filehandle fragments
-and dentrys will be termed "exportable".
+and dentries will be termed "exportable".
 
 
 
@@ -89,11 +92,9 @@ For a filesystem to be exportable it mus
    1/ provide the filehandle fragment routines described below.
    2/ make sure that d_splice_alias is used rather than d_add
       when ->lookup finds an inode for a given parent and name.
-      Typically the ->lookup routine will end:
-		if (inode)
-			return d_splice(inode, dentry);
-		d_add(dentry, inode);
-		return NULL;
+      Typically the ->lookup routine will end with a:
+
+		return d_splice_alias(inode, dentry);
 	}
 
 
@@ -101,67 +102,39 @@ For a filesystem to be exportable it mus
   A file system implementation declares that instances of the filesystem
 are exportable by setting the s_export_op field in the struct
 super_block.  This field must point to a "struct export_operations"
-struct which could potentially be full of NULLs, though normally at
-least get_parent will be set.
+struct which has the following members:
 
- The primary operations are decode_fh and encode_fh.  
-decode_fh takes a filehandle fragment and tries to find or create a
-dentry for the object referred to by the filehandle.
-encode_fh takes a dentry and creates a filehandle fragment which can
-later be used to find/create a dentry for the same object.
-
-decode_fh will probably make use of "find_exported_dentry".
-This function lives in the "exportfs" module which a filesystem does
-not need unless it is being exported.  So rather that calling
-find_exported_dentry directly, each filesystem should call it through
-the find_exported_dentry pointer in it's export_operations table.
-This field is set correctly by the exporting agent (e.g. nfsd) when a
-filesystem is exported, and before any export operations are called.
-
-find_exported_dentry needs three support functions from the
-filesystem:
-  get_name.  When given a parent dentry and a child dentry, this
-    should find a name in the directory identified by the parent
-    dentry, which leads to the object identified by the child dentry.
-    If no get_name function is supplied, a default implementation is
-    provided which uses vfs_readdir to find potential names, and
-    matches inode numbers to find the correct match.
-
-  get_parent.  When given a dentry for a directory, this should return 
-    a dentry for the parent.  Quite possibly the parent dentry will
-    have been allocated by d_alloc_anon.  
-    The default get_parent function just returns an error so any
-    filehandle lookup that requires finding a parent will fail.
-    ->lookup("..") is *not* used as a default as it can leave ".."
-    entries in the dcache which are too messy to work with.
-
-  get_dentry.  When given an opaque datum, this should find the
-    implied object and create a dentry for it (possibly with
-    d_alloc_anon). 
-    The opaque datum is whatever is passed down by the decode_fh
-    function, and is often simply a fragment of the filehandle
-    fragment.
-    decode_fh passes two datums through find_exported_dentry.  One that 
-    should be used to identify the target object, and one that can be
-    used to identify the object's parent, should that be necessary.
-    The default get_dentry function assumes that the datum contains an
-    inode number and a generation number, and it attempts to get the
-    inode using "iget" and check it's validity by matching the
-    generation number.  A filesystem should only depend on the default
-    if iget can safely be used this way.
-
-If decode_fh and/or encode_fh are left as NULL, then default
-implementations are used.  These defaults are suitable for ext2 and 
-extremely similar filesystems (like ext3).
-
-The default encode_fh creates a filehandle fragment from the inode
-number and generation number of the target together with the inode
-number and generation number of the parent (if the parent is
-required).
-
-The default decode_fh extract the target and parent datums from the
-filehandle assuming the format used by the default encode_fh and
-passed them to find_exported_dentry.
+ encode_fh  (optional)
+    Takes a dentry and creates a filehandle fragment which can later be used
+    to find or create a dentry for the same object.  The default
+    implementation creates a filehandle fragment that encodes a 32bit inode
+    and generation number for the inode encoded, and if necessary the
+    same information for the parent.
+
+  fh_to_dentry (mandatory)
+    Given a filehandle fragment, this should find the implied object and
+    create a dentry for it (possibly with d_alloc_anon).
+
+  fh_to_parent (optional but strongly recommended)
+    Given a filehandle fragment, this should find the parent of the
+    implied object and create a dentry for it (possibly with d_alloc_anon).
+    May fail if the filehandle fragment is too small.
+
+  get_parent (optional but strongly recommended)
+    When given a dentry for a directory, this should return  a dentry for
+    the parent.  Quite possibly the parent dentry will have been allocated
+    by d_alloc_anon.  The default get_parent function just returns an error
+    so any filehandle lookup that requires finding a parent will fail.
+    ->lookup("..") is *not* used as a default as it can leave ".." entries
+    in the dcache which are too messy to work with.
+
+  get_name (optional)
+    When given a parent dentry and a child dentry, this should find a name
+    in the directory identified by the parent dentry, which leads to the
+    object identified by the child dentry.  If no get_name function is
+    supplied, a default implementation is provided which uses vfs_readdir
+    to find potential names, and matches inode numbers to find the correct
+    match.
 
 
 A filehandle fragment consists of an array of 1 or more 4byte words,
@@ -172,5 +145,3 @@ generated by encode_fh, in which case it
 nuls.  Rather, the encode_fh routine should choose a "type" which
 indicates the decode_fh how much of the filehandle is valid, and how
 it should be interpreted.
-
- 
Index: linux-2.6-xfs/include/linux/exportfs.h
===================================================================
--- linux-2.6-xfs.orig/include/linux/exportfs.h	2007-09-17 14:35:01.000000000 +0200
+++ linux-2.6-xfs/include/linux/exportfs.h	2007-09-17 14:35:49.000000000 +0200
@@ -55,30 +55,8 @@ struct fid {
  * @get_parent:     find the parent of a given directory
  * @get_dentry:     find a dentry for the inode given a file handle sub-fragment
  *
- * Description:
- *    The export_operations structure provides a means for nfsd to communicate
- *    with a particular exported file system  - particularly enabling nfsd and
- *    the filesystem to co-operate when dealing with file handles.
- *
- *    export_operations contains two basic operation for dealing with file
- *    handles, decode_fh() and encode_fh(), and allows for some other
- *    operations to be defined which standard helper routines use to get
- *    specific information from the filesystem.
- *
- *    nfsd encodes information use to determine which filesystem a filehandle
- *    applies to in the initial part of the file handle.  The remainder, termed
- *    a file handle fragment, is controlled completely by the filesystem.  The
- *    standard helper routines assume that this fragment will contain one or
- *    two sub-fragments, one which identifies the file, and one which may be
- *    used to identify the (a) directory containing the file.
- *
- *    In some situations, nfsd needs to get a dentry which is connected into a
- *    specific part of the file tree.  To allow for this, it passes the
- *    function acceptable() together with a @context which can be used to see
- *    if the dentry is acceptable.  As there can be multiple dentrys for a
- *    given file, the filesystem should check each one for acceptability before
- *    looking for the next.  As soon as an acceptable one is found, it should
- *    be returned.
+ * See Documentation/filesystems/Exporting for details on how to use
+ * this interface correctly.
  *
  * encode_fh:
  *    @encode_fh should store in the file handle fragment @fh (using at most
Index: linux-2.6-xfs/fs/exportfs/expfs.c
===================================================================
--- linux-2.6-xfs.orig/fs/exportfs/expfs.c	2007-09-17 14:35:01.000000000 +0200
+++ linux-2.6-xfs/fs/exportfs/expfs.c	2007-09-17 14:36:04.000000000 +0200
@@ -1,4 +1,13 @@
-
+/*
+ * Copyright (C) Neil Brown 2002
+ * Copyright (C) Christoph Hellwig 2007
+ *
+ * This file contains the code mapping from inodes to NFS file handles,
+ * and for mapping back from file handles to dentries.
+ *
+ * For details on why we do all the strange and hairy things in here
+ * take a look at Documentation/filesystems/Exporting.
+ */
 #include <linux/exportfs.h>
 #include <linux/fs.h>
 #include <linux/file.h>
@@ -9,19 +18,19 @@
 #define dprintk(fmt, args...) do{}while(0)
 
 
-static int get_name(struct dentry *dentry, char *name,
+static int get_name(struct vfsmount *mnt, struct dentry *dentry, char *name,
 		struct dentry *child);
 
 
-static int exportfs_get_name(struct dentry *dir, char *name,
-		struct dentry *child)
+static int exportfs_get_name(struct vfsmount *mnt, struct dentry *dir,
+		char *name, struct dentry *child)
 {
 	const struct export_operations *nop = dir->d_sb->s_export_op;
 
 	if (nop->get_name)
 		return nop->get_name(dir, name, child);
 	else
-		return get_name(dir, name, child);
+		return get_name(mnt, dir, name, child);
 }
 
 /*
@@ -85,7 +94,7 @@ find_disconnected_root(struct dentry *de
  * It may already be, as the flag isn't always updated when connection happens.
  */
 static int
-reconnect_path(struct super_block *sb, struct dentry *target_dir)
+reconnect_path(struct vfsmount *mnt, struct dentry *target_dir)
 {
 	char nbuf[NAME_MAX+1];
 	int noprogress = 0;
@@ -108,7 +117,7 @@ reconnect_path(struct super_block *sb, s
 			pd->d_flags &= ~DCACHE_DISCONNECTED;
 			spin_unlock(&pd->d_lock);
 			noprogress = 0;
-		} else if (pd == sb->s_root) {
+		} else if (pd == mnt->mnt_sb->s_root) {
 			printk(KERN_ERR "export: Eeek filesystem root is not connected, impossible\n");
 			spin_lock(&pd->d_lock);
 			pd->d_flags &= ~DCACHE_DISCONNECTED;
@@ -134,8 +143,8 @@ reconnect_path(struct super_block *sb, s
 			struct dentry *npd;
 
 			mutex_lock(&pd->d_inode->i_mutex);
-			if (sb->s_export_op->get_parent)
-				ppd = sb->s_export_op->get_parent(pd);
+			if (mnt->mnt_sb->s_export_op->get_parent)
+				ppd = mnt->mnt_sb->s_export_op->get_parent(pd);
 			mutex_unlock(&pd->d_inode->i_mutex);
 
 			if (IS_ERR(ppd)) {
@@ -148,7 +157,7 @@ reconnect_path(struct super_block *sb, s
 
 			dprintk("%s: find name of %lu in %lu\n", __FUNCTION__,
 				pd->d_inode->i_ino, ppd->d_inode->i_ino);
-			err = exportfs_get_name(ppd, nbuf, pd);
+			err = exportfs_get_name(mnt, ppd, nbuf, pd);
 			if (err) {
 				dput(ppd);
 				dput(pd);
@@ -238,8 +247,8 @@ static int filldir_one(void * __buf, con
  * calls readdir on the parent until it finds an entry with
  * the same inode number as the child, and returns that.
  */
-static int get_name(struct dentry *dentry, char *name,
-			struct dentry *child)
+static int get_name(struct vfsmount *mnt, struct dentry *dentry,
+		char *name, struct dentry *child)
 {
 	struct inode *dir = dentry->d_inode;
 	int error;
@@ -255,7 +264,7 @@ static int get_name(struct dentry *dentr
 	/*
 	 * Open the directory ...
 	 */
-	file = dentry_open(dget(dentry), NULL, O_RDONLY);
+	file = dentry_open(dget(dentry), mntget(mnt), O_RDONLY);
 	error = PTR_ERR(file);
 	if (IS_ERR(file))
 		goto out;
@@ -372,7 +381,7 @@ struct dentry *exportfs_decode_fh(struct
 		 * filesystem root.
 		 */
 		if (result->d_flags & DCACHE_DISCONNECTED) {
-			err = reconnect_path(mnt->mnt_sb, result);
+			err = reconnect_path(mnt, result);
 			if (err)
 				goto err_result;
 		}
@@ -424,7 +433,7 @@ struct dentry *exportfs_decode_fh(struct
 		 * connected to the filesystem root.  The VFS really doesn't
 		 * like disconnected directories..
 		 */
-		err = reconnect_path(mnt->mnt_sb, target_dir);
+		err = reconnect_path(mnt, target_dir);
 		if (err) {
 			dput(target_dir);
 			goto err_result;
@@ -435,7 +444,7 @@ struct dentry *exportfs_decode_fh(struct
 		 * dentry for the inode we're after, make sure that our
 		 * inode is actually connected to the parent.
 		 */
-		err = exportfs_get_name(target_dir, nbuf, result);
+		err = exportfs_get_name(mnt, target_dir, nbuf, result);
 		if (!err) {
 			mutex_lock(&target_dir->d_inode->i_mutex);
 			nresult = lookup_one_len(nbuf, target_dir,

--
