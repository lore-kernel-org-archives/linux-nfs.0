From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: PATCH - kNFSd in 2.5.14 - Tidy up comments in expfs.c
Date: Tue, 7 May 2002 14:39:29 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15575.23169.298124.934056@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 174wlf-0004fH-00
	for <nfs@lists.sourceforge.net>; Mon, 06 May 2002 21:40:04 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Tue, 7 May 2002 14:39:55 +1000
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



Chris Wright <chris@wirex.com>  suggested these to limit to 80 
columns and such.

 ----------- Diffstat output ------------
 ./fs/exportfs/expfs.c |  104 ++++++++++++++++++++++++++------------------------
 1 files changed, 55 insertions(+), 49 deletions(-)

--- ./fs/exportfs/expfs.c	2002/05/07 04:28:35	1.1
+++ ./fs/exportfs/expfs.c	2002/05/07 04:28:38	1.2
@@ -3,39 +3,44 @@
 #include <linux/module.h>
 #include <linux/smp_lock.h>
 
+struct export_operations export_op_default;
+
+#define	CALL(ops,fun) ((ops->fun)?(ops->fun):export_op_default.fun)
+
+#define dprintk(fmt, args...) do{}while(0)
+
 /**
  * find_exported_dentry - helper routine to implement export_operations->decode_fh
  * @sb:		The &super_block identifying the filesystem
- * @obj:	An opaque identifier of the object to be found - passed to get_inode
+ * @obj:	An opaque identifier of the object to be found - passed to
+ *		get_inode
  * @parent:	An optional opqaue identifier of the parent of the object.
- * @acceptable:	A function used to test possible &dentries to see of they are acceptable
- * @context:	A parameter to @acceptable so that it knows on what basis to judge.
- *
- * find_exported_dentry is the central helper routine to enable file systems to provide
- * the decode_fh() export_operation.  It's main task is to take an &inode, find or create an
- * appropriate &dentry structure, and possibly splice this into the dcache in the
- * correct place.
+ * @acceptable:	A function used to test possible &dentries to see if they are
+ *		acceptable
+ * @context:	A parameter to @acceptable so that it knows on what basis to
+ *		judge.
  *
- * The decode_fh() operation provided by the filesystem should call find_exported_dentry()
- * with the same parameters that it received except that instead of the file handle fragment,
- * pointers to opaque identifiers for the object and optionally its parent are passed.
- * The default decode_fh routine passes one pointer to the start of the filehandle fragment, and
- * one 8 bytes into the fragment.  It is expected that most filesystems will take this
- * approach, though the offset to the parent identifier may well be different.
+ * find_exported_dentry is the central helper routine to enable file systems
+ * to provide the decode_fh() export_operation.  It's main task is to take
+ * an &inode, find or create an appropriate &dentry structure, and possibly
+ * splice this into the dcache in the correct place.
  *
- * find_exported_dentry() will call get_dentry to get an dentry pointer from the file system.  If
- * any &dentry in the d_alias list is acceptable, it will be returned.  Otherwise
- * find_exported_dentry() will attempt to splice a new &dentry into the dcache using get_name() and
- * get_parent() to find the appropriate place.
+ * The decode_fh() operation provided by the filesystem should call
+ * find_exported_dentry() with the same parameters that it received except
+ * that instead of the file handle fragment, pointers to opaque identifiers
+ * for the object and optionally its parent are passed.  The default decode_fh
+ * routine passes one pointer to the start of the filehandle fragment, and
+ * one 8 bytes into the fragment.  It is expected that most filesystems will
+ * take this approach, though the offset to the parent identifier may well be
+ * different.
  *
+ * find_exported_dentry() will call get_dentry to get an dentry pointer from
+ * the file system.  If any &dentry in the d_alias list is acceptable, it will
+ * be returned.  Otherwise find_exported_dentry() will attempt to splice a new
+ * &dentry into the dcache using get_name() and get_parent() to find the
+ * appropriate place.
  */
 
-struct export_operations export_op_default;
-
-#define	CALL(ops,fun) ((ops->fun)?(ops->fun):export_op_default.fun)
-
-#define dprintk(x, a...) do{}while(0)
-
 struct dentry *
 find_exported_dentry(struct super_block *sb, void *obj, void *parent,
 		     int (*acceptable)(void *context, struct dentry *de),
@@ -123,12 +128,12 @@
 	 * We then repeat.
 	 */
 
-	/* it is possible that a confused file system might not let us complete the
-	 * path to the root.  For example, if get_parent returns a directory
-	 * in which we cannot find a name for the child.  While this implies a very
-	 * sick filesystem we don't want it to cause knfsd to spin.  Hence the noprogress
-	 * counter.  If we go through the loop 10 times (2 is probably enough) without
-	 * getting anywhere, we just give up
+	/* it is possible that a confused file system might not let us complete 
+	 * the path to the root.  For example, if get_parent returns a directory
+	 * in which we cannot find a name for the child.  While this implies a
+	 * very sick filesystem we don't want it to cause knfsd to spin.  Hence
+	 * the noprogress counter.  If we go through the loop 10 times (2 is
+	 * probably enough) without getting anywhere, we just give up
 	 */
 	lock_kernel();
 	noprogress= 0;
@@ -155,8 +160,8 @@
 			 * to find parent and connect
 			 * note: racing with some other process renaming a
 			 * directory isn't much of a problem here.  If someone
-			 * renames the directory, it will end up properly connected,
-			 * which is what we want
+			 * renames the directory, it will end up properly
+			 * connected, which is what we want
 			 */
 			struct dentry *ppd;
 			struct dentry *npd;
@@ -178,8 +183,8 @@
 			if (err) {
 				dput(ppd);
 				if (err == -ENOENT)
-					/* some race between get_parent and get_name?
-					 * just try again
+					/* some race between get_parent and
+					 * get_name?  just try again
 					 */
 					continue;
 				dput(pd);
@@ -208,7 +213,7 @@
 			dput(npd);
 			dput(ppd);
 			if (IS_ROOT(pd)) {
-				/* something went wrong, we will have to give up */
+				/* something went wrong, we have to give up */
 				dput(pd);
 				break;
 			}
@@ -293,7 +298,8 @@
 
 
 struct getdents_callback {
-	char *name;		/* name that was found. It already points to a buffer NAME_MAX+1 is size */
+	char *name;		/* name that was found. It already points to a
+				   buffer NAME_MAX+1 is size */
 	unsigned long ino;	/* the inum we are looking for */
 	int found;		/* inode matched? */
 	int sequence;		/* sequence counter */
@@ -386,11 +392,11 @@
 	/* iget isn't really right if the inode is currently unallocated!!
 	 * This should really all be done inside each filesystem
 	 *
-	 * ext2fs' read_inode has been strengthed to return a bad_inode if the inode
-	 *   had been deleted.
+	 * ext2fs' read_inode has been strengthed to return a bad_inode if
+	 * the inode had been deleted.
 	 *
-	 * Currently we don't know the generation for parent directory, so a generation
-	 * of 0 means "accept any"
+	 * Currently we don't know the generation for parent directory, so
+	 * a generation of 0 means "accept any"
 	 */
 	struct inode *inode;
 	struct dentry *result;
@@ -437,10 +443,10 @@
 
 /**
  * export_encode_fh - default export_operations->encode_fh function
- * dentry:  the dentry to encode
- * fh:      where to store the file handle fragment
- * max_len: maximum length to store there
- * connectable: whether to store parent infomation
+ * @dentry:  the dentry to encode
+ * @fh:      where to store the file handle fragment
+ * @max_len: maximum length to store there
+ * @connectable: whether to store parent infomation
  *
  * This default encode_fh function assumes that the 32 inode number
  * is suitable for locating an inode, and that the generation number
@@ -474,11 +480,11 @@
 
 /**
  * export_decode_fh - default export_operations->decode_fh function
- * sb:  The superblock
- * fh:  pointer to the file handle fragment
- * fh_len: length of file handle fragment
- * acceptable: function for testing acceptability of dentrys
- * context:   context for @acceptable
+ * @sb:  The superblock
+ * @fh:  pointer to the file handle fragment
+ * @fh_len: length of file handle fragment
+ * @acceptable: function for testing acceptability of dentrys
+ * @context:   context for @acceptable
  *
  * This is the default decode_fh() function.
  * a fileid_type of 1 indicates that the filehandlefragment

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
