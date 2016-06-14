Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:33154 "EHLO
	mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752934AbcFNTFk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2016 15:05:40 -0400
Received: by mail-it0-f66.google.com with SMTP id i6so432646ith.0
        for <linux-nfs@vger.kernel.org>; Tue, 14 Jun 2016 12:05:39 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 03/12] NFS: Cache aggressively when file is open for writing
Date: Tue, 14 Jun 2016 15:05:06 -0400
Message-Id: <1465931115-30784-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1465931115-30784-2-git-send-email-trond.myklebust@primarydata.com>
References: <1465931115-30784-1-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Unless the user is using file locking, we must assume close-to-open
cache consistency when the file is open for writing. Adjust the
caching algorithm so that it does not clear the cache on out-of-order
writes and/or attribute revalidations.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/file.c  | 13 ++-----------
 fs/nfs/inode.c | 56 +++++++++++++++++++++++++++++++++++++++-----------------
 2 files changed, 41 insertions(+), 28 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 717a8d6af52d..2d39d9f9da7d 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -780,11 +780,6 @@ do_unlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
 }
 
 static int
-is_time_granular(struct timespec *ts) {
-	return ((ts->tv_sec == 0) && (ts->tv_nsec <= 1000));
-}
-
-static int
 do_setlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
 {
 	struct inode *inode = filp->f_mapping->host;
@@ -817,12 +812,8 @@ do_setlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
 	 * This makes locking act as a cache coherency point.
 	 */
 	nfs_sync_mapping(filp->f_mapping);
-	if (!NFS_PROTO(inode)->have_delegation(inode, FMODE_READ)) {
-		if (is_time_granular(&NFS_SERVER(inode)->time_delta))
-			__nfs_revalidate_inode(NFS_SERVER(inode), inode);
-		else
-			nfs_zap_caches(inode);
-	}
+	if (!NFS_PROTO(inode)->have_delegation(inode, FMODE_READ))
+		nfs_zap_mapping(inode, filp->f_mapping);
 out:
 	return status;
 }
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 60051e62d3f1..8a808d25dbc8 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -878,7 +878,10 @@ void nfs_inode_attach_open_context(struct nfs_open_context *ctx)
 	struct nfs_inode *nfsi = NFS_I(inode);
 
 	spin_lock(&inode->i_lock);
-	list_add(&ctx->list, &nfsi->open_files);
+	if (ctx->mode & FMODE_WRITE)
+		list_add(&ctx->list, &nfsi->open_files);
+	else
+		list_add_tail(&ctx->list, &nfsi->open_files);
 	spin_unlock(&inode->i_lock);
 }
 EXPORT_SYMBOL_GPL(nfs_inode_attach_open_context);
@@ -1215,6 +1218,21 @@ int nfs_revalidate_mapping_protected(struct inode *inode, struct address_space *
 	return __nfs_revalidate_mapping(inode, mapping, true);
 }
 
+static bool nfs_file_has_writers(struct nfs_inode *nfsi)
+{
+	assert_spin_locked(&nfsi->vfs_inode.i_lock);
+
+	if (list_empty(&nfsi->open_files))
+		return false;
+	/* Note: This relies on nfsi->open_files being ordered with writers
+	 *       being placed at the head of the list.
+	 *       See nfs_inode_attach_open_context()
+	 */
+	return (list_first_entry(&nfsi->open_files,
+			struct nfs_open_context,
+			list)->mode & FMODE_WRITE) == FMODE_WRITE;
+}
+
 static unsigned long nfs_wcc_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
@@ -1279,22 +1297,24 @@ static int nfs_check_inode_attributes(struct inode *inode, struct nfs_fattr *fat
 	if ((fattr->valid & NFS_ATTR_FATTR_TYPE) && (inode->i_mode & S_IFMT) != (fattr->mode & S_IFMT))
 		return -EIO;
 
-	if ((fattr->valid & NFS_ATTR_FATTR_CHANGE) != 0 &&
-			inode->i_version != fattr->change_attr)
-		invalid |= NFS_INO_INVALID_ATTR|NFS_INO_REVAL_PAGECACHE;
+	if (!nfs_file_has_writers(nfsi)) {
+		/* Verify a few of the more important attributes */
+		if ((fattr->valid & NFS_ATTR_FATTR_CHANGE) != 0 && inode->i_version != fattr->change_attr)
+			invalid |= NFS_INO_INVALID_ATTR | NFS_INO_REVAL_PAGECACHE;
 
-	/* Verify a few of the more important attributes */
-	if ((fattr->valid & NFS_ATTR_FATTR_MTIME) && !timespec_equal(&inode->i_mtime, &fattr->mtime))
-		invalid |= NFS_INO_INVALID_ATTR;
+		if ((fattr->valid & NFS_ATTR_FATTR_MTIME) && !timespec_equal(&inode->i_mtime, &fattr->mtime))
+			invalid |= NFS_INO_INVALID_ATTR;
 
-	if (fattr->valid & NFS_ATTR_FATTR_SIZE) {
-		cur_size = i_size_read(inode);
-		new_isize = nfs_size_to_loff_t(fattr->size);
-		if (cur_size != new_isize)
-			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_REVAL_PAGECACHE;
+		if ((fattr->valid & NFS_ATTR_FATTR_CTIME) && !timespec_equal(&inode->i_ctime, &fattr->ctime))
+			invalid |= NFS_INO_INVALID_ATTR;
+
+		if (fattr->valid & NFS_ATTR_FATTR_SIZE) {
+			cur_size = i_size_read(inode);
+			new_isize = nfs_size_to_loff_t(fattr->size);
+			if (cur_size != new_isize)
+				invalid |= NFS_INO_INVALID_ATTR|NFS_INO_REVAL_PAGECACHE;
+		}
 	}
-	if (nfsi->nrequests != 0)
-		invalid &= ~NFS_INO_REVAL_PAGECACHE;
 
 	/* Have any file permissions changed? */
 	if ((fattr->valid & NFS_ATTR_FATTR_MODE) && (inode->i_mode & S_IALLUGO) != (fattr->mode & S_IALLUGO))
@@ -1675,6 +1695,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 	unsigned long invalid = 0;
 	unsigned long now = jiffies;
 	unsigned long save_cache_validity;
+	bool have_writers = nfs_file_has_writers(nfsi);
 	bool cache_revalidated = true;
 
 	dfprintk(VFS, "NFS: %s(%s/%lu fh_crc=0x%08x ct=%d info=0x%x)\n",
@@ -1730,7 +1751,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 			dprintk("NFS: change_attr change on server for file %s/%ld\n",
 					inode->i_sb->s_id, inode->i_ino);
 			/* Could it be a race with writeback? */
-			if (nfsi->nrequests == 0) {
+			if (!have_writers) {
 				invalid |= NFS_INO_INVALID_ATTR
 					| NFS_INO_INVALID_DATA
 					| NFS_INO_INVALID_ACCESS
@@ -1770,9 +1791,10 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 		if (new_isize != cur_isize) {
 			/* Do we perhaps have any outstanding writes, or has
 			 * the file grown beyond our last write? */
-			if ((nfsi->nrequests == 0) || new_isize > cur_isize) {
+			if (nfsi->nrequests == 0 || new_isize > cur_isize) {
 				i_size_write(inode, new_isize);
-				invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA;
+				if (!have_writers)
+					invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA;
 			}
 			dprintk("NFS: isize change on server for file %s/%ld "
 					"(%Ld to %Ld)\n",
-- 
2.5.5

