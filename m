Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailrelay108.isp.belgacom.be ([195.238.20.135]:2260 "EHLO
	mailrelay108.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753544AbbLITrq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Dec 2015 14:47:46 -0500
From: Fabian Frederick <fabf@skynet.be>
To: linux-kernel@vger.kernel.org
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
        Fabian Frederick <fabf@skynet.be>, Joel Becker <jlbec@evilplan.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Joern Engel <joern@logfs.org>,
        Prasad Joshi <prasadjoshi.linux@gmail.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        linux-fsdevel@vger.kernel.org, logfs@logfs.org,
        linux-nfs@vger.kernel.org
Subject: [PATCH 1/1] fs.h: import umode to DT conversion
Date: Wed,  9 Dec 2015 20:47:28 +0100
Message-Id: <1449690448-18021-1-git-send-email-fabf@skynet.be>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The same umode -> DT calculation existed in different
filesystems.

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 fs/configfs/dir.c  | 8 +-------
 fs/kernfs/dir.c    | 8 +-------
 fs/libfs.c         | 9 ++-------
 fs/logfs/dir.c     | 4 ++--
 fs/logfs/logfs.h   | 5 -----
 fs/nfs/internal.h  | 9 ---------
 fs/nfs/nfs3xdr.c   | 2 +-
 fs/nfs/nfs4xdr.c   | 2 +-
 fs/nfs/nfstrace.h  | 2 +-
 include/linux/fs.h | 2 ++
 10 files changed, 11 insertions(+), 40 deletions(-)

diff --git a/fs/configfs/dir.c b/fs/configfs/dir.c
index a7a1b21..ea23f8d 100644
--- a/fs/configfs/dir.c
+++ b/fs/configfs/dir.c
@@ -1516,12 +1516,6 @@ static int configfs_dir_close(struct inode *inode, struct file *file)
 	return 0;
 }
 
-/* Relationship between s_mode and the DT_xxx types */
-static inline unsigned char dt_type(struct configfs_dirent *sd)
-{
-	return (sd->s_mode >> 12) & 15;
-}
-
 static int configfs_readdir(struct file *file, struct dir_context *ctx)
 {
 	struct dentry *dentry = file->f_path.dentry;
@@ -1574,7 +1568,7 @@ static int configfs_readdir(struct file *file, struct dir_context *ctx)
 		if (!inode)
 			ino = iunique(sb, 2);
 
-		if (!dir_emit(ctx, name, len, ino, dt_type(next)))
+		if (!dir_emit(ctx, name, len, ino, DT_TYPE(next->s_mode)))
 			return 0;
 
 		spin_lock(&configfs_dirent_lock);
diff --git a/fs/kernfs/dir.c b/fs/kernfs/dir.c
index 91e0045..f66a5fe 100644
--- a/fs/kernfs/dir.c
+++ b/fs/kernfs/dir.c
@@ -1367,12 +1367,6 @@ int kernfs_rename_ns(struct kernfs_node *kn, struct kernfs_node *new_parent,
 	return error;
 }
 
-/* Relationship between s_mode and the DT_xxx types */
-static inline unsigned char dt_type(struct kernfs_node *kn)
-{
-	return (kn->mode >> 12) & 15;
-}
-
 static int kernfs_dir_fop_release(struct inode *inode, struct file *filp)
 {
 	kernfs_put(filp->private_data);
@@ -1447,7 +1441,7 @@ static int kernfs_fop_readdir(struct file *file, struct dir_context *ctx)
 	     pos;
 	     pos = kernfs_dir_next_pos(ns, parent, ctx->pos, pos)) {
 		const char *name = pos->name;
-		unsigned int type = dt_type(pos);
+		unsigned int type = DT_TYPE(pos->mode);
 		int len = strlen(name);
 		ino_t ino = pos->ino;
 
diff --git a/fs/libfs.c b/fs/libfs.c
index c7cbfb0..3d88b5d 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -129,12 +129,6 @@ loff_t dcache_dir_lseek(struct file *file, loff_t offset, int whence)
 }
 EXPORT_SYMBOL(dcache_dir_lseek);
 
-/* Relationship between i_mode and the DT_xxx types */
-static inline unsigned char dt_type(struct inode *inode)
-{
-	return (inode->i_mode >> 12) & 15;
-}
-
 /*
  * Directory is locked and all positive dentries in it are safe, since
  * for ramfs-type trees they can't go away without unlink() or rmdir(),
@@ -164,7 +158,8 @@ int dcache_readdir(struct file *file, struct dir_context *ctx)
 		spin_unlock(&next->d_lock);
 		spin_unlock(&dentry->d_lock);
 		if (!dir_emit(ctx, next->d_name.name, next->d_name.len,
-			      d_inode(next)->i_ino, dt_type(d_inode(next))))
+			      d_inode(next)->i_ino,
+			      DT_TYPE(d_inode(next)->i_mode)))
 			return 0;
 		spin_lock(&dentry->d_lock);
 		spin_lock_nested(&next->d_lock, DENTRY_D_LOCK_NESTED);
diff --git a/fs/logfs/dir.c b/fs/logfs/dir.c
index f9b45d4..42e73a5 100644
--- a/fs/logfs/dir.c
+++ b/fs/logfs/dir.c
@@ -386,7 +386,7 @@ static int logfs_write_dir(struct inode *dir, struct dentry *dentry,
 		dd = kmap_atomic(page);
 		memset(dd, 0, sizeof(*dd));
 		dd->ino = cpu_to_be64(inode->i_ino);
-		dd->type = logfs_type(inode);
+		dd->type = DT_TYPE(inode->i_mode);
 		logfs_set_name(dd, &dentry->d_name);
 		kunmap_atomic(dd);
 
@@ -640,7 +640,7 @@ static int logfs_replace_inode(struct inode *dir, struct dentry *dentry,
 	if (err)
 		return err;
 	dd->ino = cpu_to_be64(inode->i_ino);
-	dd->type = logfs_type(inode);
+	dd->type = DT_TYPE(inode->i_mode);
 
 	err = write_dir(dir, dd, pos);
 	if (err)
diff --git a/fs/logfs/logfs.h b/fs/logfs/logfs.h
index 5f09376..75acc7b 100644
--- a/fs/logfs/logfs.h
+++ b/fs/logfs/logfs.h
@@ -655,11 +655,6 @@ static inline __be32 logfs_crc32(void *data, size_t len, size_t skip)
 	return cpu_to_be32(crc32(~0, data+skip, len-skip));
 }
 
-static inline u8 logfs_type(struct inode *inode)
-{
-	return (inode->i_mode >> 12) & 15;
-}
-
 static inline pgoff_t logfs_index(struct super_block *sb, u64 pos)
 {
 	return pos >> sb->s_blocksize_bits;
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 56cfde2..82dd650 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -652,15 +652,6 @@ unsigned int nfs_page_length(struct page *page)
 }
 
 /*
- * Convert a umode to a dirent->d_type
- */
-static inline
-unsigned char nfs_umode_to_dtype(umode_t mode)
-{
-	return (mode >> 12) & 15;
-}
-
-/*
  * Determine the number of pages in an array of length 'len' and
  * with a base offset of 'base'
  */
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 267126d..ed86e29 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -1986,7 +1986,7 @@ int nfs3_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 		if (unlikely(error))
 			return error;
 		if (entry->fattr->valid & NFS_ATTR_FATTR_V3)
-			entry->d_type = nfs_umode_to_dtype(entry->fattr->mode);
+			entry->d_type = DT_TYPE(entry->fattr->mode);
 
 		if (entry->fattr->fileid != entry->ino) {
 			entry->fattr->mounted_on_fileid = entry->ino;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 4e44412..1a398e9 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -7359,7 +7359,7 @@ int nfs4_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 
 	entry->d_type = DT_UNKNOWN;
 	if (entry->fattr->valid & NFS_ATTR_FATTR_TYPE)
-		entry->d_type = nfs_umode_to_dtype(entry->fattr->mode);
+		entry->d_type = DT_TYPE(entry->fattr->mode);
 
 	return 0;
 
diff --git a/fs/nfs/nfstrace.h b/fs/nfs/nfstrace.h
index 59f838c..1b9f6ec 100644
--- a/fs/nfs/nfstrace.h
+++ b/fs/nfs/nfstrace.h
@@ -100,7 +100,7 @@ DECLARE_EVENT_CLASS(nfs_inode_event_done,
 			__entry->dev = inode->i_sb->s_dev;
 			__entry->fileid = nfsi->fileid;
 			__entry->fhandle = nfs_fhandle_hash(&nfsi->fh);
-			__entry->type = nfs_umode_to_dtype(inode->i_mode);
+			__entry->type = DT_TYPE(inode->i_mode);
 			__entry->version = inode->i_version;
 			__entry->size = i_size_read(inode);
 			__entry->nfsi_flags = nfsi->flags;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 3aa5142..23bfd36 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1552,6 +1552,8 @@ int fiemap_check_flags(struct fiemap_extent_info *fieinfo, u32 fs_flags);
 #define DT_SOCK		12
 #define DT_WHT		14
 
+#define DT_TYPE(i_mode)	((unsigned char)(i_mode >> 12) & 15)
+
 /*
  * This is the "filldir" function type, used by readdir() to let
  * the kernel specify what kind of dirent layout it wants to have.
-- 
2.1.4

