From: Christoph Hellwig <hch@infradead.org>
Subject: [PATCH 3/18] exportfs: add new methods
Date: Sat, 17 Mar 2007 01:10:15 +0000
Message-ID: <20070317011015.GD24947@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Add the guts for the new filesystem API to exportfs.

There's now a fh_to_dentry method that returns a dentry for the
object looked for given a filehandle fragment, and a fh_to_parent
operation that returns the dentry for the encoded parent directory
in case the file handle contains it.

There are default implementations for these methods that only take
a callback for an nfs-enhanced iget variant and implement the
rest of the semantics.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/include/linux/exportfs.h
===================================================================
--- linux-2.6.orig/include/linux/exportfs.h	2007-03-13 19:23:03.000000000 +0100
+++ linux-2.6/include/linux/exportfs.h	2007-03-13 19:23:05.000000000 +0100
@@ -4,6 +4,7 @@
 #include <linux/types.h>
 
 struct dentry;
+struct inode;
 struct super_block;
 struct vfsmount;
 
@@ -101,6 +102,21 @@ struct fid {
  *    the filehandle fragment.  encode_fh() should return the number of bytes
  *    stored or a negative error code such as %-ENOSPC
  *
+ * fh_to_dentry:
+ *    @fh_to_dentry is given a &struct super_block (@sb) and a file handle
+ *    fragment (@fh, @fh_len). It should return a &struct dentry which refers
+ *    to the same file that the file handle fragment refers to.  If it cannot,
+ *    it should return a %NULL pointer if the file was found but no acceptable
+ *    &dentries were available, or an %ERR_PTR error code indicating why it
+ *    couldn't be found (e.g. %ENOENT or %ENOMEM).  Any suitable dentry can be
+ *    returned including, if necessary, a new dentry created with d_alloc_root.
+ *    The caller can then find any other extant dentries by following the
+ *    d_alias links.
+ *
+ * fh_to_parent:
+ *    Same as @fh_to_dentry, except that it returns a pointer to the parent
+ *    dentry if it was encoded into the filehandle fragment by @encode_fh.
+ *
  * get_name:
  *    @get_name should find a name for the given @child in the given @parent
  *    directory.  The name should be stored in the @name (with the
@@ -139,6 +155,10 @@ struct export_operations {
 			void *context);
 	int (*encode_fh)(struct dentry *de, __u32 *fh, int *max_len,
 			int connectable);
+	struct dentry * (*fh_to_dentry)(struct super_block *sb, struct fid *fid,
+			int fh_len, int fh_type);
+	struct dentry * (*fh_to_parent)(struct super_block *sb, struct fid *fid,
+			int fh_len, int fh_type);
 	int (*get_name)(struct dentry *parent, char *name,
 			struct dentry *child);
 	struct dentry * (*get_parent)(struct dentry *child);
@@ -161,4 +181,14 @@ extern struct dentry *exportfs_decode_fh
 	int fh_len, int fileid_type, int (*acceptable)(void *, struct dentry *),
 	void *context);
 
+/*
+ * Generic helpers for filesystems.
+ */
+extern struct dentry *generic_fh_to_dentry(struct super_block *sb,
+	struct fid *fid, int fh_len, int fh_type,
+	struct inode *(*get_inode) (struct super_block *sb, u64 ino, u32 gen));
+extern struct dentry *generic_fh_to_parent(struct super_block *sb,
+	struct fid *fid, int fh_len, int fh_type,
+	struct inode *(*get_inode) (struct super_block *sb, u64 ino, u32 gen));
+
 #endif /* LINUX_EXPORTFS_H */
Index: linux-2.6/fs/exportfs/expfs.c
===================================================================
--- linux-2.6.orig/fs/exportfs/expfs.c	2007-03-13 19:23:03.000000000 +0100
+++ linux-2.6/fs/exportfs/expfs.c	2007-03-13 19:23:05.000000000 +0100
@@ -496,6 +496,71 @@ static struct dentry *export_decode_fh(s
 				   acceptable, context);
 }
 
+static struct dentry *exportfs_d_alloc(struct inode *inode)
+{
+	struct dentry *dentry;
+
+	if (!inode)
+		return NULL;
+	if (IS_ERR(inode))
+		return ERR_PTR(PTR_ERR(inode));
+
+	dentry = d_alloc_anon(inode);
+	if (!dentry) {
+		iput(inode);
+		dentry = ERR_PTR(-ENOMEM);
+	}
+	return dentry;
+}
+
+/*
+ * Generic helper for the fh_to_dentry export operation.
+ * Needs a callback to get a struct inode for a [sb,ino,gen] tuple.
+ */
+struct dentry *generic_fh_to_dentry(struct super_block *sb, struct fid *fid,
+		int fh_len, int fh_type, struct inode *(*get_inode)
+			(struct super_block *sb, u64 ino, u32 gen))
+{
+	struct inode *inode = NULL;
+
+	if (fh_len < 2)
+		return NULL;
+
+	switch (fh_type) {
+	case FILEID_INO32_GEN:
+	case FILEID_INO32_GEN_PARENT:
+		inode = get_inode(sb, fid->i32.ino, fid->i32.gen);
+		break;
+	}
+
+	return exportfs_d_alloc(inode);
+}
+EXPORT_SYMBOL_GPL(generic_fh_to_dentry);
+
+/*
+ * Generic helper for the fh_to_parent export operation.
+ * Needs a callback to get a struct inode for a [sb,ino,gen] tuple.
+ */
+struct dentry *generic_fh_to_parent(struct super_block *sb, struct fid *fid,
+		int fh_len, int fh_type, struct inode *(*get_inode)
+			(struct super_block *sb, u64 ino, u32 gen))
+{
+	struct inode *inode = NULL;
+
+	if (fh_len <= 2)
+		return NULL;
+
+	switch (fh_type) {
+	case FILEID_INO32_GEN_PARENT:
+		inode = get_inode(sb, fid->i32.parent_ino,
+				  (fh_len > 3 ? fid->i32.parent_gen : 0));
+		break;
+	}
+
+	return exportfs_d_alloc(inode);
+}
+EXPORT_SYMBOL_GPL(generic_fh_to_parent);
+
 int exportfs_encode_fh(struct dentry *dentry, struct fid *fid, int *max_len,
 		int connectable)
 {
@@ -516,17 +581,138 @@ struct dentry *exportfs_decode_fh(struct
 		int (*acceptable)(void *, struct dentry *), void *context)
 {
 	struct export_operations *nop = mnt->mnt_sb->s_export_op;
-	struct dentry *result;
+	struct dentry *result, *alias;
+	int err;
+
+	/*
+	 * Old way of doing things.  Will go away soon.
+	 */
+	if (!nop->fh_to_dentry) {
+		if (nop->decode_fh) {
+			return nop->decode_fh(mnt->mnt_sb, fid->raw, fh_len,
+					fileid_type, acceptable, context);
+		} else {
+			return export_decode_fh(mnt->mnt_sb, fid->raw, fh_len,
+					fileid_type, acceptable, context);
+		}
+	}
 
-	if (nop->decode_fh) {
-		result = nop->decode_fh(mnt->mnt_sb, fid->raw, fh_len, fileid_type,
-			acceptable, context);
+	/*
+	 * Try to get any dentry for the given file handle from the filesystem.
+	 */
+	result = nop->fh_to_dentry(mnt->mnt_sb, fid, fh_len, fileid_type);
+	if (!result)
+		result = ERR_PTR(-ESTALE);
+	if (IS_ERR(result))
+		return result;
+
+	if (S_ISDIR(result->d_inode->i_mode)) {
+		/*
+		 * This request is for a directory.  That means there can't be
+		 * more than one dentry for an inode, but it also means we always
+		 * need to make sure it's connected up to the filesystem root.
+		 */
+		if (result->d_flags & DCACHE_DISCONNECTED) {
+			err = reconnect_path(mnt->mnt_sb, result);
+			if (err)
+				goto err_result;
+		}
+
+		if (!acceptable(context, result)) {
+			err = -EACCES;
+			goto err_result;
+		}
+
+		return result;
 	} else {
-		result = export_decode_fh(mnt->mnt_sb, fid->raw, fh_len, fileid_type,
-			acceptable, context);
+		/*
+		 * It's not a directory.  Life is a little more complicated.
+		 */
+		struct dentry *target_dir, *nresult;
+		char nbuf[NAME_MAX+1];
+
+		/*
+		 * See if either the dentry we just got from the filesystem
+		 * or any alias for it is acceptable.  This is always true
+		 * if this filesystem is exported without the subtreecheck
+		 * option.  If the filesystem is exported with the subtree
+		 * check option there's a fair chance we need to look at
+		 * the parent directory in the file handle and make sure
+		 * it's connected to the filesystem root.
+		 */
+		alias = find_acceptable_alias(result, acceptable, context);
+		if (alias)
+			return alias;
+
+		/*
+		 * Try to extract a dentry for the parent directory from the
+		 * file handle.  If this fails we'll have to give up.
+		 */
+		err = -ESTALE;
+		if (!nop->fh_to_parent)
+			goto err_result;
+
+		target_dir = nop->fh_to_parent(mnt->mnt_sb, fid,
+				fh_len, fileid_type);
+		if (!target_dir)
+			goto err_result;
+		err = PTR_ERR(target_dir);
+		if (IS_ERR(target_dir))
+			goto err_result;
+
+		/*
+		 * And as usual we need to make sure the parent directory is
+		 * connected to the filesystem root.  The VFS really doesn't
+		 * like disconnected directories..
+		 */
+		err = reconnect_path(mnt->mnt_sb, target_dir);
+		if (err) {
+			dput(target_dir);
+			goto err_result;
+		}
+
+		/*
+		 * Now that we've got both a well-connected parent and a
+		 * dentry for the inode we're after, make sure that our
+		 * inode is actually connected to the parent.
+		 */
+		err = exportfs_get_name(target_dir, nbuf, result);
+		if (!err) {
+			mutex_lock(&target_dir->d_inode->i_mutex);
+			nresult = lookup_one_len(nbuf, target_dir,
+						 strlen(nbuf));
+			mutex_unlock(&target_dir->d_inode->i_mutex);
+			if (!IS_ERR(nresult)) {
+				if (nresult->d_inode) {
+					dput(result);
+					result = nresult;
+				} else
+					dput(nresult);
+			}
+		}
+
+		/*
+		 * At this point we are done with the parent, but it's pinned
+		 * by the child dentry anyway.
+		 */
+		dput(target_dir);
+
+		/*
+		 * And finally make sure the dentry is actually acceptable
+		 * to NFSD.
+		 */
+		alias = find_acceptable_alias(result, acceptable, context);
+		if (!alias) {
+			err = -EACCES;
+			goto err_result;
+		}
+
+		return alias;
 	}
 
-	return result;
+ err_result:
+	dput(result);
+	return ERR_PTR(err);
 }
 EXPORT_SYMBOL_GPL(exportfs_decode_fh);
 
