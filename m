From: Christoph Hellwig <hch@infradead.org>
Subject: [PATCH 10/18] xfs: new export ops
Date: Sat, 17 Mar 2007 01:11:35 +0000
Message-ID: <20070317011135.GK24947@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

This one is a lot more complicated than the previous ones.  XFS already
had a very clever scheme for supporting 64bit inode numbers in filehandles,
and I've reworked this to be some kind of a prototype for the generic
64bit inode filehandle support.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/fs/xfs/linux-2.6/xfs_export.c
===================================================================
--- linux-2.6.orig/fs/xfs/linux-2.6/xfs_export.c	2007-03-16 15:46:12.000000000 +0100
+++ linux-2.6/fs/xfs/linux-2.6/xfs_export.c	2007-03-17 01:31:39.000000000 +0100
@@ -27,62 +27,25 @@
 static struct dentry dotdot = { .d_name.name = "..", .d_name.len = 2, };
 
 /*
- * XFS encodes and decodes the fileid portion of NFS filehandles
- * itself instead of letting the generic NFS code do it.  This
- * allows filesystems with 64 bit inode numbers to be exported.
- *
- * Note that a side effect is that xfs_vget() won't be passed a
- * zero inode/generation pair under normal circumstances.  As
- * however a malicious client could send us such data, the check
- * remains in that code.
+ * Note that we only accept fileids which are long enough rather than allow
+ * the parent generation number to default to zero.  XFS considers zero a
+ * valid generation number not an invalid/wildcard value.
  */
-
-STATIC struct dentry *
-xfs_fs_decode_fh(
-	struct super_block	*sb,
-	__u32			*fh,
-	int			fh_len,
-	int			fileid_type,
-	int (*acceptable)(
-		void		*context,
-		struct dentry	*de),
-	void			*context)
-{
-	xfs_fid_t		ifid;
-	xfs_fid_t		pfid;
-	void			*parent = NULL;
-	int			is64 = 0;
-	__u32			*p = fh;
-
-#if XFS_BIG_INUMS
-	is64 = (fileid_type & XFS_FILEID_TYPE_64FLAG);
-	fileid_type &= ~XFS_FILEID_TYPE_64FLAG;
-#endif
-
-	/*
-	 * Note that we only accept fileids which are long enough
-	 * rather than allow the parent generation number to default
-	 * to zero.  XFS considers zero a valid generation number not
-	 * an invalid/wildcard value.  There's little point printk'ing
-	 * a warning here as we don't have the client information
-	 * which would make such a warning useful.
-	 */
-	if (fileid_type > 2 ||
-	    fh_len < xfs_fileid_length((fileid_type == 2), is64))
-		return NULL;
-
-	p = xfs_fileid_decode_fid2(p, &ifid, is64);
-
-	if (fileid_type == 2) {
-		p = xfs_fileid_decode_fid2(p, &pfid, is64);
-		parent = &pfid;
+static int xfs_fileid_length(int fileid_type)
+{
+	switch (fileid_type) {
+	case FILEID_INO32_GEN:
+		return 2;
+	case FILEID_INO32_GEN_PARENT:
+		return 4;
+	case FILEID_INO32_GEN | XFS_FILEID_TYPE_64FLAG:
+		return 3;
+	case FILEID_INO32_GEN_PARENT | XFS_FILEID_TYPE_64FLAG:
+		return 6;
 	}
-
-	fh = (__u32 *)&ifid;
-	return sb->s_export_op->find_exported_dentry(sb, fh, parent, acceptable, context);
+	return 255; /* invalid */
 }
 
-
 STATIC int
 xfs_fs_encode_fh(
 	struct dentry		*dentry,
@@ -90,23 +53,23 @@ xfs_fs_encode_fh(
 	int			*max_len,
 	int			connectable)
 {
+	struct fid		*fid = (struct fid *)fh;
+	struct xfs_fid64	*fid64 = (struct xfs_fid64 *)fh;
 	struct inode		*inode = dentry->d_inode;
-	int			type = 1;
-	__u32			*p = fh;
+	int			fileid_type;
 	int			len;
-	int			is64 = 0;
-#if XFS_BIG_INUMS
 	bhv_vfs_t		*vfs = vfs_from_sb(inode->i_sb);
 
-	if (!(vfs->vfs_flag & VFS_32BITINODES)) {
-		/* filesystem may contain 64bit inode numbers */
-		is64 = XFS_FILEID_TYPE_64FLAG;
-	}
-#endif
 
 	/* Directories don't need their parent encoded, they have ".." */
 	if (S_ISDIR(inode->i_mode))
-	    connectable = 0;
+		fileid_type = FILEID_INO32_GEN;
+	else
+		fileid_type = FILEID_INO32_GEN_PARENT;
+
+	/* filesystem may contain 64bit inode numbers */
+	if (!(vfs->vfs_flag & VFS_32BITINODES))
+		fileid_type |= XFS_FILEID_TYPE_64FLAG;
 
 	/*
 	 * Only encode if there is enough space given.  In practice
@@ -114,38 +77,114 @@ xfs_fs_encode_fh(
 	 * over NFSv2 with the subtree_check export option; the other
 	 * seven combinations work.  The real answer is "don't use v2".
 	 */
-	len = xfs_fileid_length(connectable, is64);
+	len = xfs_fileid_length(fileid_type);
 	if (*max_len < len)
 		return 255;
 	*max_len = len;
 
-	p = xfs_fileid_encode_inode(p, inode, is64);
-	if (connectable) {
+	switch (fileid_type) {
+	case FILEID_INO32_GEN_PARENT:
+		spin_lock(&dentry->d_lock);
+		fid->i32.parent_ino = dentry->d_parent->d_inode->i_ino;
+		fid->i32.parent_gen = dentry->d_parent->d_inode->i_generation;
+		spin_unlock(&dentry->d_lock);
+		/*FALLTHRU*/
+	case FILEID_INO32_GEN:
+		fid->i32.ino = inode->i_ino;
+		fid->i32.gen = inode->i_generation;
+		break;
+	case FILEID_INO32_GEN_PARENT | XFS_FILEID_TYPE_64FLAG:
 		spin_lock(&dentry->d_lock);
-		p = xfs_fileid_encode_inode(p, dentry->d_parent->d_inode, is64);
+		fid64->parent_ino = dentry->d_parent->d_inode->i_ino;
+		fid64->parent_gen = dentry->d_parent->d_inode->i_generation;
 		spin_unlock(&dentry->d_lock);
-		type = 2;
+		/*FALLTHRU*/
+	case FILEID_INO32_GEN | XFS_FILEID_TYPE_64FLAG:
+		fid64->ino = inode->i_ino;
+		fid64->gen = inode->i_generation;
+		break;
 	}
-	BUG_ON((p - fh) != len);
-	return type | is64;
+
+	return fileid_type;
 }
 
-STATIC struct dentry *
-xfs_fs_get_dentry(
+STATIC struct inode *
+xfs_nfs_get_inode(
 	struct super_block	*sb,
-	void			*data)
+	u64			ino,
+	u32			generation)
 {
+	xfs_fid_t		xfid;
 	bhv_vnode_t		*vp;
-	struct inode		*inode;
-	struct dentry		*result;
-	bhv_vfs_t		*vfsp = vfs_from_sb(sb);
 	int			error;
 
-	error = bhv_vfs_vget(vfsp, &vp, data);
-	if (error || vp == NULL)
-		return ERR_PTR(-ESTALE) ;
+	xfid.fid_len = sizeof(xfs_fid_t) - sizeof(xfid.fid_len);
+	xfid.fid_pad = 0;
+	xfid.fid_ino = ino;
+	xfid.fid_gen = generation;
+
+	error = bhv_vfs_vget(vfs_from_sb(sb), &vp, &xfid);
+	if (error)
+		return ERR_PTR(-error);
+
+	return vp ? vn_to_inode(vp) : NULL;
+}
 
-	inode = vn_to_inode(vp);
+STATIC struct dentry *
+xfs_fs_fh_to_dentry(struct super_block *sb, struct fid *fid,
+		 int fh_len, int fileid_type)
+{
+	struct xfs_fid64	*fid64 = (struct xfs_fid64 *)fid;
+	struct inode		*inode = NULL;
+	struct dentry		*result;
+
+	if (fh_len < xfs_fileid_length(fileid_type))
+		return NULL;
+
+	switch (fileid_type) {
+	case FILEID_INO32_GEN_PARENT:
+	case FILEID_INO32_GEN:
+		inode = xfs_nfs_get_inode(sb, fid->i32.ino, fid->i32.gen);
+		break;
+	case FILEID_INO32_GEN_PARENT | XFS_FILEID_TYPE_64FLAG:
+	case FILEID_INO32_GEN | XFS_FILEID_TYPE_64FLAG:
+		inode = xfs_nfs_get_inode(sb, fid64->ino, fid64->gen);
+		break;
+	}
+
+	if (!inode)
+		return NULL;
+	if (IS_ERR(inode))
+		return ERR_PTR(PTR_ERR(inode));
+	result = d_alloc_anon(inode);
+        if (!result) {
+		iput(inode);
+		return ERR_PTR(-ENOMEM);
+	}
+	return result;
+}
+
+STATIC struct dentry *
+xfs_fs_fh_to_parent(struct super_block *sb, struct fid *fid,
+		 int fh_len, int fileid_type)
+{
+	struct xfs_fid64	*fid64 = (struct xfs_fid64 *)fid;
+	struct inode		*inode = NULL;
+	struct dentry		*result;
+
+	switch (fileid_type) {
+	case FILEID_INO32_GEN_PARENT:
+		inode = xfs_nfs_get_inode(sb, fid->i32.parent_ino, fid->i32.parent_gen);
+		break;
+	case FILEID_INO32_GEN_PARENT | XFS_FILEID_TYPE_64FLAG:
+		inode = xfs_nfs_get_inode(sb, fid64->parent_ino, fid64->parent_gen);
+		break;
+	}
+
+	if (!inode)
+		return NULL;
+	if (IS_ERR(inode))
+		return ERR_PTR(PTR_ERR(inode));
 	result = d_alloc_anon(inode);
         if (!result) {
 		iput(inode);
@@ -177,8 +216,8 @@ xfs_fs_get_parent(
 }
 
 struct export_operations xfs_export_operations = {
-	.decode_fh		= xfs_fs_decode_fh,
 	.encode_fh		= xfs_fs_encode_fh,
+	.fh_to_dentry		= xfs_fs_fh_to_dentry,
+	.fh_to_parent		= xfs_fs_fh_to_parent,
 	.get_parent		= xfs_fs_get_parent,
-	.get_dentry		= xfs_fs_get_dentry,
 };
Index: linux-2.6/fs/xfs/linux-2.6/xfs_export.h
===================================================================
--- linux-2.6.orig/fs/xfs/linux-2.6/xfs_export.h	2007-03-16 16:10:12.000000000 +0100
+++ linux-2.6/fs/xfs/linux-2.6/xfs_export.h	2007-03-16 17:04:48.000000000 +0100
@@ -59,50 +59,14 @@
  * a subdirectory) or use the "fsid" export option.
  */
 
+struct xfs_fid64 {
+	u64 ino;
+	u32 gen;
+	u64 parent_ino;
+	u32 parent_gen;
+} __attribute__((packed));
+
 /* This flag goes on the wire.  Don't play with it. */
 #define XFS_FILEID_TYPE_64FLAG	0x80	/* NFS fileid has 64bit inodes */
 
-/* Calculate the length in u32 units of the fileid data */
-static inline int
-xfs_fileid_length(int hasparent, int is64)
-{
-	return hasparent ? (is64 ? 6 : 4) : (is64 ? 3 : 2);
-}
-
-/*
- * Decode encoded inode information (either for the inode itself
- * or the parent) into an xfs_fid_t structure.  Advances and
- * returns the new data pointer
- */
-static inline __u32 *
-xfs_fileid_decode_fid2(__u32 *p, xfs_fid_t *fid, int is64)
-{
-	fid->fid_len = sizeof(xfs_fid_t) - sizeof(fid->fid_len);
-	fid->fid_pad = 0;
-	fid->fid_ino = *p++;
-#if XFS_BIG_INUMS
-	if (is64)
-		fid->fid_ino |= (((__u64)(*p++)) << 32);
-#endif
-	fid->fid_gen = *p++;
-	return p;
-}
-
-/*
- * Encode inode information (either for the inode itself or the
- * parent) into a fileid buffer.  Advances and returns the new
- * data pointer.
- */
-static inline __u32 *
-xfs_fileid_encode_inode(__u32 *p, struct inode *inode, int is64)
-{
-	*p++ = (__u32)inode->i_ino;
-#if XFS_BIG_INUMS
-	if (is64)
-		*p++ = (__u32)(inode->i_ino >> 32);
-#endif
-	*p++ = inode->i_generation;
-	return p;
-}
-
 #endif	/* __XFS_EXPORT_H__ */
