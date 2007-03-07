From: Christoph Hellwig <hch@infradead.org>
Subject: [PATCH 1/8] exportfs: add exportfs.h header
Date: Wed, 7 Mar 2007 10:39:37 +0000
Message-ID: <20070307103937.GB22963@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HOtYa-0003C5-0K
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 02:39:57 -0800
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HOtYa-0005aX-Qm
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 02:39:42 -0800
Received: from hch by pentafluge.infradead.org with local (Exim 4.63 #1 (Red
	Hat Linux)) id 1HOtYY-0006TN-08
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 10:39:38 +0000
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

currently the export_operation structure and helpers related to it
are in fs.h.  fs.h is already far too large and there are very few
places needing the export bits, so split them off into a separate
header.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/fs/efs/super.c
===================================================================
--- linux-2.6.orig/fs/efs/super.c	2007-02-18 04:41:56.000000000 +0100
+++ linux-2.6/fs/efs/super.c	2007-02-20 11:46:30.000000000 +0100
@@ -11,6 +11,7 @@
 #include <linux/efs_fs.h>
 #include <linux/efs_vh.h>
 #include <linux/efs_fs_sb.h>
+#include <linux/exportfs.h>
 #include <linux/slab.h>
 #include <linux/buffer_head.h>
 #include <linux/vfs.h>
Index: linux-2.6/fs/exportfs/expfs.c
===================================================================
--- linux-2.6.orig/fs/exportfs/expfs.c	2007-02-18 04:41:56.000000000 +0100
+++ linux-2.6/fs/exportfs/expfs.c	2007-02-20 11:46:30.000000000 +0100
@@ -1,4 +1,5 @@
 
+#include <linux/exportfs.h>
 #include <linux/fs.h>
 #include <linux/file.h>
 #include <linux/module.h>
Index: linux-2.6/fs/ext2/super.c
===================================================================
--- linux-2.6.orig/fs/ext2/super.c	2007-02-18 04:41:56.000000000 +0100
+++ linux-2.6/fs/ext2/super.c	2007-02-20 11:46:30.000000000 +0100
@@ -25,6 +25,7 @@
 #include <linux/parser.h>
 #include <linux/random.h>
 #include <linux/buffer_head.h>
+#include <linux/exportfs.h>
 #include <linux/smp_lock.h>
 #include <linux/vfs.h>
 #include <linux/seq_file.h>
Index: linux-2.6/fs/ext3/super.c
===================================================================
--- linux-2.6.orig/fs/ext3/super.c	2007-02-18 04:41:56.000000000 +0100
+++ linux-2.6/fs/ext3/super.c	2007-02-20 11:46:30.000000000 +0100
@@ -29,6 +29,7 @@
 #include <linux/parser.h>
 #include <linux/smp_lock.h>
 #include <linux/buffer_head.h>
+#include <linux/exportfs.h>
 #include <linux/vfs.h>
 #include <linux/random.h>
 #include <linux/mount.h>
Index: linux-2.6/fs/ext4/super.c
===================================================================
--- linux-2.6.orig/fs/ext4/super.c	2007-02-18 04:41:56.000000000 +0100
+++ linux-2.6/fs/ext4/super.c	2007-02-20 11:46:30.000000000 +0100
@@ -29,6 +29,7 @@
 #include <linux/parser.h>
 #include <linux/smp_lock.h>
 #include <linux/buffer_head.h>
+#include <linux/exportfs.h>
 #include <linux/vfs.h>
 #include <linux/random.h>
 #include <linux/mount.h>
Index: linux-2.6/fs/fat/inode.c
===================================================================
--- linux-2.6.orig/fs/fat/inode.c	2007-02-18 04:41:56.000000000 +0100
+++ linux-2.6/fs/fat/inode.c	2007-02-20 11:46:30.000000000 +0100
@@ -20,6 +20,7 @@
 #include <linux/pagemap.h>
 #include <linux/mpage.h>
 #include <linux/buffer_head.h>
+#include <linux/exportfs.h>
 #include <linux/mount.h>
 #include <linux/vfs.h>
 #include <linux/parser.h>
Index: linux-2.6/fs/gfs2/ops_export.c
===================================================================
--- linux-2.6.orig/fs/gfs2/ops_export.c	2007-02-18 04:43:20.000000000 +0100
+++ linux-2.6/fs/gfs2/ops_export.c	2007-02-20 11:46:30.000000000 +0100
@@ -11,6 +11,7 @@
 #include <linux/spinlock.h>
 #include <linux/completion.h>
 #include <linux/buffer_head.h>
+#include <linux/exportfs.h>
 #include <linux/gfs2_ondisk.h>
 #include <linux/crc32.h>
 #include <linux/lm_interface.h>
Index: linux-2.6/fs/gfs2/ops_export.h
===================================================================
--- linux-2.6.orig/fs/gfs2/ops_export.h	2007-02-18 04:41:56.000000000 +0100
+++ linux-2.6/fs/gfs2/ops_export.h	2007-02-20 11:46:30.000000000 +0100
@@ -10,6 +10,8 @@
 #ifndef __OPS_EXPORT_DOT_H__
 #define __OPS_EXPORT_DOT_H__
 
+#include <linux/exportfs.h>
+
 #define GFS2_SMALL_FH_SIZE 4
 #define GFS2_LARGE_FH_SIZE 10
 
Index: linux-2.6/fs/isofs/isofs.h
===================================================================
--- linux-2.6.orig/fs/isofs/isofs.h	2007-02-18 04:41:56.000000000 +0100
+++ linux-2.6/fs/isofs/isofs.h	2007-02-20 11:46:30.000000000 +0100
@@ -1,5 +1,6 @@
 #include <linux/fs.h>
 #include <linux/buffer_head.h>
+#include <linux/exportfs.h>
 #include <linux/iso_fs.h>
 #include <asm/unaligned.h>
 
Index: linux-2.6/fs/jfs/super.c
===================================================================
--- linux-2.6.orig/fs/jfs/super.c	2007-02-18 04:41:56.000000000 +0100
+++ linux-2.6/fs/jfs/super.c	2007-02-20 11:46:30.000000000 +0100
@@ -27,6 +27,7 @@
 #include <linux/kthread.h>
 #include <linux/posix_acl.h>
 #include <linux/buffer_head.h>
+#include <linux/exportfs.h>
 #include <asm/uaccess.h>
 #include <linux/seq_file.h>
 
Index: linux-2.6/fs/nfsd/nfsfh.c
===================================================================
--- linux-2.6.orig/fs/nfsd/nfsfh.c	2007-02-18 04:43:20.000000000 +0100
+++ linux-2.6/fs/nfsd/nfsfh.c	2007-02-20 11:46:30.000000000 +0100
@@ -16,6 +16,7 @@
 #include <linux/string.h>
 #include <linux/stat.h>
 #include <linux/dcache.h>
+#include <linux/exportfs.h>
 #include <linux/mount.h>
 #include <asm/pgtable.h>
 
Index: linux-2.6/fs/ntfs/namei.c
===================================================================
--- linux-2.6.orig/fs/ntfs/namei.c	2007-02-18 04:41:56.000000000 +0100
+++ linux-2.6/fs/ntfs/namei.c	2007-02-20 11:46:30.000000000 +0100
@@ -21,6 +21,7 @@
  */
 
 #include <linux/dcache.h>
+#include <linux/exportfs.h>
 #include <linux/security.h>
 
 #include "attrib.h"
Index: linux-2.6/fs/ocfs2/export.h
===================================================================
--- linux-2.6.orig/fs/ocfs2/export.h	2007-02-18 04:41:56.000000000 +0100
+++ linux-2.6/fs/ocfs2/export.h	2007-02-20 11:46:30.000000000 +0100
@@ -26,6 +26,8 @@
 #ifndef OCFS2_EXPORT_H
 #define OCFS2_EXPORT_H
 
+#include <linux/exportfs.h>
+
 extern struct export_operations ocfs2_export_ops;
 
 #endif /* OCFS2_EXPORT_H */
Index: linux-2.6/fs/reiserfs/super.c
===================================================================
--- linux-2.6.orig/fs/reiserfs/super.c	2007-02-18 04:41:56.000000000 +0100
+++ linux-2.6/fs/reiserfs/super.c	2007-02-20 11:46:30.000000000 +0100
@@ -22,6 +22,7 @@
 #include <linux/init.h>
 #include <linux/blkdev.h>
 #include <linux/buffer_head.h>
+#include <linux/exportfs.h>
 #include <linux/vfs.h>
 #include <linux/mnt_namespace.h>
 #include <linux/mount.h>
Index: linux-2.6/fs/xfs/linux-2.6/xfs_super.h
===================================================================
--- linux-2.6.orig/fs/xfs/linux-2.6/xfs_super.h	2007-02-18 04:41:56.000000000 +0100
+++ linux-2.6/fs/xfs/linux-2.6/xfs_super.h	2007-02-20 11:46:31.000000000 +0100
@@ -18,6 +18,8 @@
 #ifndef __XFS_SUPER_H__
 #define __XFS_SUPER_H__
 
+#include <linux/exportfs.h>
+
 #ifdef CONFIG_XFS_DMAPI
 # define vfs_insertdmapi(vfs)	vfs_insertops(vfsp, &xfs_dmops)
 # define vfs_initdmapi()	dmapi_init()
Index: linux-2.6/include/linux/exportfs.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/include/linux/exportfs.h	2007-02-20 11:46:31.000000000 +0100
@@ -0,0 +1,119 @@
+#ifndef LINUX_EXPORTFS_H
+#define LINUX_EXPORTFS_H 1
+
+#include <linux/types.h>
+
+struct dentry;
+struct super_block;
+
+
+/**
+ * struct export_operations - for nfsd to communicate with file systems
+ * @decode_fh:      decode a file handle fragment and return a &struct dentry
+ * @encode_fh:      encode a file handle fragment from a dentry
+ * @get_name:       find the name for a given inode in a given directory
+ * @get_parent:     find the parent of a given directory
+ * @get_dentry:     find a dentry for the inode given a file handle sub-fragment
+ * @find_exported_dentry:
+ *	set by the exporting module to a standard helper function.
+ *
+ * Description:
+ *    The export_operations structure provides a means for nfsd to communicate
+ *    with a particular exported file system  - particularly enabling nfsd and
+ *    the filesystem to co-operate when dealing with file handles.
+ *
+ *    export_operations contains two basic operation for dealing with file
+ *    handles, decode_fh() and encode_fh(), and allows for some other
+ *    operations to be defined which standard helper routines use to get
+ *    specific information from the filesystem.
+ *
+ *    nfsd encodes information use to determine which filesystem a filehandle
+ *    applies to in the initial part of the file handle.  The remainder, termed
+ *    a file handle fragment, is controlled completely by the filesystem.  The
+ *    standard helper routines assume that this fragment will contain one or
+ *    two sub-fragments, one which identifies the file, and one which may be
+ *    used to identify the (a) directory containing the file.
+ *
+ *    In some situations, nfsd needs to get a dentry which is connected into a
+ *    specific part of the file tree.  To allow for this, it passes the
+ *    function acceptable() together with a @context which can be used to see
+ *    if the dentry is acceptable.  As there can be multiple dentrys for a
+ *    given file, the filesystem should check each one for acceptability before
+ *    looking for the next.  As soon as an acceptable one is found, it should
+ *    be returned.
+ *
+ * decode_fh:
+ *    @decode_fh is given a &struct super_block (@sb), a file handle fragment
+ *    (@fh, @fh_len) and an acceptability testing function (@acceptable,
+ *    @context).  It should return a &struct dentry which refers to the same
+ *    file that the file handle fragment refers to,  and which passes the
+ *    acceptability test.  If it cannot, it should return a %NULL pointer if
+ *    the file was found but no acceptable &dentries were available, or a
+ *    %ERR_PTR error code indicating why it couldn't be found (e.g. %ENOENT or
+ *    %ENOMEM).
+ *
+ * encode_fh:
+ *    @encode_fh should store in the file handle fragment @fh (using at most
+ *    @max_len bytes) information that can be used by @decode_fh to recover the
+ *    file refered to by the &struct dentry @de.  If the @connectable flag is
+ *    set, the encode_fh() should store sufficient information so that a good
+ *    attempt can be made to find not only the file but also it's place in the
+ *    filesystem.   This typically means storing a reference to de->d_parent in
+ *    the filehandle fragment.  encode_fh() should return the number of bytes
+ *    stored or a negative error code such as %-ENOSPC
+ *
+ * get_name:
+ *    @get_name should find a name for the given @child in the given @parent
+ *    directory.  The name should be stored in the @name (with the
+ *    understanding that it is already pointing to a a %NAME_MAX+1 sized
+ *    buffer.   get_name() should return %0 on success, a negative error code
+ *    or error.  @get_name will be called without @parent->i_mutex held.
+ *
+ * get_parent:
+ *    @get_parent should find the parent directory for the given @child which
+ *    is also a directory.  In the event that it cannot be found, or storage
+ *    space cannot be allocated, a %ERR_PTR should be returned.
+ *
+ * get_dentry:
+ *    Given a &super_block (@sb) and a pointer to a file-system specific inode
+ *    identifier, possibly an inode number, (@inump) get_dentry() should find
+ *    the identified inode and return a dentry for that inode.  Any suitable
+ *    dentry can be returned including, if necessary, a new dentry created with
+ *    d_alloc_root.  The caller can then find any other extant dentrys by
+ *    following the d_alias links.  If a new dentry was created using
+ *    d_alloc_root, DCACHE_NFSD_DISCONNECTED should be set, and the dentry
+ *    should be d_rehash()ed.
+ *
+ *    If the inode cannot be found, either a %NULL pointer or an %ERR_PTR code
+ *    can be returned.  The @inump will be whatever was passed to
+ *    nfsd_find_fh_dentry() in either the @obj or @parent parameters.
+ *
+ * Locking rules:
+ *    get_parent is called with child->d_inode->i_mutex down
+ *    get_name is not (which is possibly inconsistent)
+ */
+
+struct export_operations {
+	struct dentry *(*decode_fh)(struct super_block *sb, __u32 *fh,
+			int fh_len, int fh_type,
+			int (*acceptable)(void *context, struct dentry *de),
+			void *context);
+	int (*encode_fh)(struct dentry *de, __u32 *fh, int *max_len,
+			int connectable);
+	int (*get_name)(struct dentry *parent, char *name,
+			struct dentry *child);
+	struct dentry * (*get_parent)(struct dentry *child);
+	struct dentry * (*get_dentry)(struct super_block *sb, void *inump);
+
+	/* This is set by the exporting module to a standard helper */
+	struct dentry * (*find_exported_dentry)(
+			struct super_block *sb, void *obj, void *parent,
+			int (*acceptable)(void *context, struct dentry *de),
+			void *context);
+};
+
+extern struct dentry *find_exported_dentry(struct super_block *sb, void *obj,
+	void *parent, int (*acceptable)(void *context, struct dentry *de),
+	void *context);
+
+#endif /* LINUX_EXPORTFS_H */
Index: linux-2.6/include/linux/fs.h
===================================================================
--- linux-2.6.orig/include/linux/fs.h	2007-02-18 04:41:56.000000000 +0100
+++ linux-2.6/include/linux/fs.h	2007-02-20 11:46:31.000000000 +0100
@@ -286,6 +286,7 @@
 #include <asm/semaphore.h>
 #include <asm/byteorder.h>
 
+struct export_operations;
 struct hd_geometry;
 struct iovec;
 struct nameidata;
@@ -1234,119 +1235,6 @@
 
 int sync_inode(struct inode *inode, struct writeback_control *wbc);
 
-/**
- * struct export_operations - for nfsd to communicate with file systems
- * @decode_fh:      decode a file handle fragment and return a &struct dentry
- * @encode_fh:      encode a file handle fragment from a dentry
- * @get_name:       find the name for a given inode in a given directory
- * @get_parent:     find the parent of a given directory
- * @get_dentry:     find a dentry for the inode given a file handle sub-fragment
- * @find_exported_dentry:
- *	set by the exporting module to a standard helper function.
- *
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
- *
- * decode_fh:
- *    @decode_fh is given a &struct super_block (@sb), a file handle fragment
- *    (@fh, @fh_len) and an acceptability testing function (@acceptable,
- *    @context).  It should return a &struct dentry which refers to the same
- *    file that the file handle fragment refers to,  and which passes the
- *    acceptability test.  If it cannot, it should return a %NULL pointer if
- *    the file was found but no acceptable &dentries were available, or a
- *    %ERR_PTR error code indicating why it couldn't be found (e.g. %ENOENT or
- *    %ENOMEM).
- *
- * encode_fh:
- *    @encode_fh should store in the file handle fragment @fh (using at most
- *    @max_len bytes) information that can be used by @decode_fh to recover the
- *    file refered to by the &struct dentry @de.  If the @connectable flag is
- *    set, the encode_fh() should store sufficient information so that a good
- *    attempt can be made to find not only the file but also it's place in the
- *    filesystem.   This typically means storing a reference to de->d_parent in
- *    the filehandle fragment.  encode_fh() should return the number of bytes
- *    stored or a negative error code such as %-ENOSPC
- *
- * get_name:
- *    @get_name should find a name for the given @child in the given @parent
- *    directory.  The name should be stored in the @name (with the
- *    understanding that it is already pointing to a a %NAME_MAX+1 sized
- *    buffer.   get_name() should return %0 on success, a negative error code
- *    or error.  @get_name will be called without @parent->i_mutex held.
- *
- * get_parent:
- *    @get_parent should find the parent directory for the given @child which
- *    is also a directory.  In the event that it cannot be found, or storage
- *    space cannot be allocated, a %ERR_PTR should be returned.
- *
- * get_dentry:
- *    Given a &super_block (@sb) and a pointer to a file-system specific inode
- *    identifier, possibly an inode number, (@inump) get_dentry() should find
- *    the identified inode and return a dentry for that inode.  Any suitable
- *    dentry can be returned including, if necessary, a new dentry created with
- *    d_alloc_root.  The caller can then find any other extant dentrys by
- *    following the d_alias links.  If a new dentry was created using
- *    d_alloc_root, DCACHE_NFSD_DISCONNECTED should be set, and the dentry
- *    should be d_rehash()ed.
- *
- *    If the inode cannot be found, either a %NULL pointer or an %ERR_PTR code
- *    can be returned.  The @inump will be whatever was passed to
- *    nfsd_find_fh_dentry() in either the @obj or @parent parameters.
- *
- * Locking rules:
- *    get_parent is called with child->d_inode->i_mutex down
- *    get_name is not (which is possibly inconsistent)
- */
-
-struct export_operations {
-	struct dentry *(*decode_fh)(struct super_block *sb, __u32 *fh, int fh_len, int fh_type,
-			 int (*acceptable)(void *context, struct dentry *de),
-			 void *context);
-	int (*encode_fh)(struct dentry *de, __u32 *fh, int *max_len,
-			 int connectable);
-
-	/* the following are only called from the filesystem itself */
-	int (*get_name)(struct dentry *parent, char *name,
-			struct dentry *child);
-	struct dentry * (*get_parent)(struct dentry *child);
-	struct dentry * (*get_dentry)(struct super_block *sb, void *inump);
-
-	/* This is set by the exporting module to a standard helper */
-	struct dentry * (*find_exported_dentry)(
-		struct super_block *sb, void *obj, void *parent,
-		int (*acceptable)(void *context, struct dentry *de),
-		void *context);
-
-
-};
-
-extern struct dentry *
-find_exported_dentry(struct super_block *sb, void *obj, void *parent,
-		     int (*acceptable)(void *context, struct dentry *de),
-		     void *context);
-
 struct file_system_type {
 	const char *name;
 	int fs_flags;
Index: linux-2.6/mm/shmem.c
===================================================================
--- linux-2.6.orig/mm/shmem.c	2007-02-18 04:41:56.000000000 +0100
+++ linux-2.6/mm/shmem.c	2007-02-20 11:46:31.000000000 +0100
@@ -27,6 +27,7 @@
 #include <linux/init.h>
 #include <linux/fs.h>
 #include <linux/xattr.h>
+#include <linux/exportfs.h>
 #include <linux/generic_acl.h>
 #include <linux/mm.h>
 #include <linux/mman.h>
Index: linux-2.6/fs/nfsd/export.c
===================================================================
--- linux-2.6.orig/fs/nfsd/export.c	2007-02-18 04:43:20.000000000 +0100
+++ linux-2.6/fs/nfsd/export.c	2007-02-20 11:46:31.000000000 +0100
@@ -26,6 +26,7 @@
 #include <linux/mount.h>
 #include <linux/hash.h>
 #include <linux/module.h>
+#include <linux/exportfs.h>
 
 #include <linux/sunrpc/svc.h>
 #include <linux/nfsd/nfsd.h>
Index: linux-2.6/fs/reiserfs/inode.c
===================================================================
--- linux-2.6.orig/fs/reiserfs/inode.c	2007-02-18 04:41:56.000000000 +0100
+++ linux-2.6/fs/reiserfs/inode.c	2007-02-20 11:46:31.000000000 +0100
@@ -7,6 +7,7 @@
 #include <linux/reiserfs_fs.h>
 #include <linux/reiserfs_acl.h>
 #include <linux/reiserfs_xattr.h>
+#include <linux/exportfs.h>
 #include <linux/smp_lock.h>
 #include <linux/pagemap.h>
 #include <linux/highmem.h>

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
