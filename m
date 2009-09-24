From: akpm@linux-foundation.org
Subject: [merged] fs-use-new-truncate-helpers.patch removed from -mm tree
Date: Thu, 24 Sep 2009 12:38:32 -0700
Message-ID: <200909241938.n8OJcWBa006805__19089.9240122691$1253821229$gmane$org@imap1.linux-foundation.org>
To: npiggin@suse.de, chris.mason@oracle.com, hch@lst.de,
	hirofumi@mail.parknet.co.jp, hugh.dickins-IWqWACnzNjwqdlJmJB21zg@public.gmane.org,
	jack@suse.cz, linux-cifs-client@lists.samba.org,
	linux-nfs@vger.kernel.or
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54629 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754567AbZIXTjc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Sep 2009 15:39:32 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


The patch titled
     fs: use new truncate helpers
has been removed from the -mm tree.  Its filename was
     fs-use-new-truncate-helpers.patch

This patch was dropped because it was merged into mainline or a subsystem tree

The current -mm tree may be found at http://userweb.kernel.org/~akpm/mmotm/

------------------------------------------------------
Subject: fs: use new truncate helpers
From: Nick Piggin <npiggin@suse.de>

Update some fs code to make use of new helper functions introduced in the
previous patch.  Should be no significant change in behaviour (except CIFS
now calls send_sig under i_lock, via inode_newsize_ok).

Signed-off-by: Nick Piggin <npiggin@suse.de>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Acked-by: Miklos Szeredi <miklos@szeredi.hu>
Cc: <linux-nfs@vger.kernel.org>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: <linux-cifs-client@lists.samba.org>
Cc: Steven French <sfrench@us.ibm.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Cc: Chris Mason <chris.mason@oracle.com>
Cc: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Cc: Hugh Dickins <hugh.dickins-IWqWACnzNjwqdlJmJB21zg@public.gmane.org>
Cc: Steven French <sfrench@us.ibm.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 fs/buffer.c           |   10 +------
 fs/cifs/inode.c       |   53 +++++++---------------------------------
 fs/fuse/dir.c         |   14 +++-------
 fs/fuse/fuse_i.h      |    2 -
 fs/fuse/inode.c       |   11 --------
 fs/nfs/inode.c        |   52 +++++++++------------------------------
 fs/ramfs/file-nommu.c |   18 +++----------
 7 files changed, 34 insertions(+), 126 deletions(-)

diff -puN fs/buffer.c~fs-use-new-truncate-helpers fs/buffer.c
--- a/fs/buffer.c~fs-use-new-truncate-helpers
+++ a/fs/buffer.c
@@ -2228,16 +2228,10 @@ int generic_cont_expand_simple(struct in
 	struct address_space *mapping = inode->i_mapping;
 	struct page *page;
 	void *fsdata;
-	unsigned long limit;
 	int err;
 
-	err = -EFBIG;
-        limit = current->signal->rlim[RLIMIT_FSIZE].rlim_cur;
-	if (limit != RLIM_INFINITY && size > (loff_t)limit) {
-		send_sig(SIGXFSZ, current, 0);
-		goto out;
-	}
-	if (size > inode->i_sb->s_maxbytes)
+	err = inode_newsize_ok(inode, size);
+	if (err)
 		goto out;
 
 	err = pagecache_write_begin(NULL, mapping, size, 0,
diff -puN fs/cifs/inode.c~fs-use-new-truncate-helpers fs/cifs/inode.c
--- a/fs/cifs/inode.c~fs-use-new-truncate-helpers
+++ a/fs/cifs/inode.c
@@ -1557,57 +1557,24 @@ static int cifs_truncate_page(struct add
 
 static int cifs_vmtruncate(struct inode *inode, loff_t offset)
 {
-	struct address_space *mapping = inode->i_mapping;
-	unsigned long limit;
+	loff_t oldsize;
+	int err;
 
 	spin_lock(&inode->i_lock);
-	if (inode->i_size < offset)
-		goto do_expand;
-	/*
-	 * truncation of in-use swapfiles is disallowed - it would cause
-	 * subsequent swapout to scribble on the now-freed blocks.
-	 */
-	if (IS_SWAPFILE(inode)) {
+	err = inode_newsize_ok(inode, offset);
+	if (err) {
 		spin_unlock(&inode->i_lock);
-		goto out_busy;
-	}
-	i_size_write(inode, offset);
-	spin_unlock(&inode->i_lock);
-	/*
-	 * unmap_mapping_range is called twice, first simply for efficiency
-	 * so that truncate_inode_pages does fewer single-page unmaps. However
-	 * after this first call, and before truncate_inode_pages finishes,
-	 * it is possible for private pages to be COWed, which remain after
-	 * truncate_inode_pages finishes, hence the second unmap_mapping_range
-	 * call must be made for correctness.
-	 */
-	unmap_mapping_range(mapping, offset + PAGE_SIZE - 1, 0, 1);
-	truncate_inode_pages(mapping, offset);
-	unmap_mapping_range(mapping, offset + PAGE_SIZE - 1, 0, 1);
-	goto out_truncate;
-
-do_expand:
-	limit = current->signal->rlim[RLIMIT_FSIZE].rlim_cur;
-	if (limit != RLIM_INFINITY && offset > limit) {
-		spin_unlock(&inode->i_lock);
-		goto out_sig;
-	}
-	if (offset > inode->i_sb->s_maxbytes) {
-		spin_unlock(&inode->i_lock);
-		goto out_big;
+		goto out;
 	}
+
+	oldsize = inode->i_size;
 	i_size_write(inode, offset);
 	spin_unlock(&inode->i_lock);
-out_truncate:
+	truncate_pagecache(inode, oldsize, offset);
 	if (inode->i_op->truncate)
 		inode->i_op->truncate(inode);
-	return 0;
-out_sig:
-	send_sig(SIGXFSZ, current, 0);
-out_big:
-	return -EFBIG;
-out_busy:
-	return -ETXTBSY;
+out:
+	return err;
 }
 
 static int
diff -puN fs/fuse/dir.c~fs-use-new-truncate-helpers fs/fuse/dir.c
--- a/fs/fuse/dir.c~fs-use-new-truncate-helpers
+++ a/fs/fuse/dir.c
@@ -1276,14 +1276,9 @@ static int fuse_do_setattr(struct dentry
 		return 0;
 
 	if (attr->ia_valid & ATTR_SIZE) {
-		unsigned long limit;
-		if (IS_SWAPFILE(inode))
-			return -ETXTBSY;
-		limit = current->signal->rlim[RLIMIT_FSIZE].rlim_cur;
-		if (limit != RLIM_INFINITY && attr->ia_size > (loff_t) limit) {
-			send_sig(SIGXFSZ, current, 0);
-			return -EFBIG;
-		}
+		err = inode_newsize_ok(inode, attr->ia_size);
+		if (err)
+			return err;
 		is_truncate = true;
 	}
 
@@ -1350,8 +1345,7 @@ static int fuse_do_setattr(struct dentry
 	 * FUSE_NOWRITE, otherwise fuse_launder_page() would deadlock.
 	 */
 	if (S_ISREG(inode->i_mode) && oldsize != outarg.attr.size) {
-		if (outarg.attr.size < oldsize)
-			fuse_truncate(inode->i_mapping, outarg.attr.size);
+		truncate_pagecache(inode, oldsize, outarg.attr.size);
 		invalidate_inode_pages2(inode->i_mapping);
 	}
 
diff -puN fs/fuse/fuse_i.h~fs-use-new-truncate-helpers fs/fuse/fuse_i.h
--- a/fs/fuse/fuse_i.h~fs-use-new-truncate-helpers
+++ a/fs/fuse/fuse_i.h
@@ -606,8 +606,6 @@ void fuse_change_attributes(struct inode
 void fuse_change_attributes_common(struct inode *inode, struct fuse_attr *attr,
 				   u64 attr_valid);
 
-void fuse_truncate(struct address_space *mapping, loff_t offset);
-
 /**
  * Initialize the client device
  */
diff -puN fs/fuse/inode.c~fs-use-new-truncate-helpers fs/fuse/inode.c
--- a/fs/fuse/inode.c~fs-use-new-truncate-helpers
+++ a/fs/fuse/inode.c
@@ -140,14 +140,6 @@ static int fuse_remount_fs(struct super_
 	return 0;
 }
 
-void fuse_truncate(struct address_space *mapping, loff_t offset)
-{
-	/* See vmtruncate() */
-	unmap_mapping_range(mapping, offset + PAGE_SIZE - 1, 0, 1);
-	truncate_inode_pages(mapping, offset);
-	unmap_mapping_range(mapping, offset + PAGE_SIZE - 1, 0, 1);
-}
-
 void fuse_change_attributes_common(struct inode *inode, struct fuse_attr *attr,
 				   u64 attr_valid)
 {
@@ -205,8 +197,7 @@ void fuse_change_attributes(struct inode
 	spin_unlock(&fc->lock);
 
 	if (S_ISREG(inode->i_mode) && oldsize != attr->size) {
-		if (attr->size < oldsize)
-			fuse_truncate(inode->i_mapping, attr->size);
+		truncate_pagecache(inode, oldsize, attr->size);
 		invalidate_inode_pages2(inode->i_mapping);
 	}
 }
diff -puN fs/nfs/inode.c~fs-use-new-truncate-helpers fs/nfs/inode.c
--- a/fs/nfs/inode.c~fs-use-new-truncate-helpers
+++ a/fs/nfs/inode.c
@@ -458,49 +458,21 @@ nfs_setattr(struct dentry *dentry, struc
  */
 static int nfs_vmtruncate(struct inode * inode, loff_t offset)
 {
-	if (i_size_read(inode) < offset) {
-		unsigned long limit;
+	loff_t oldsize;
+	int err;
 
-		limit = current->signal->rlim[RLIMIT_FSIZE].rlim_cur;
-		if (limit != RLIM_INFINITY && offset > limit)
-			goto out_sig;
-		if (offset > inode->i_sb->s_maxbytes)
-			goto out_big;
-		spin_lock(&inode->i_lock);
-		i_size_write(inode, offset);
-		spin_unlock(&inode->i_lock);
-	} else {
-		struct address_space *mapping = inode->i_mapping;
+	err = inode_newsize_ok(inode, offset);
+	if (err)
+		goto out;
 
-		/*
-		 * truncation of in-use swapfiles is disallowed - it would
-		 * cause subsequent swapout to scribble on the now-freed
-		 * blocks.
-		 */
-		if (IS_SWAPFILE(inode))
-			return -ETXTBSY;
-		spin_lock(&inode->i_lock);
-		i_size_write(inode, offset);
-		spin_unlock(&inode->i_lock);
+	spin_lock(&inode->i_lock);
+	oldsize = inode->i_size;
+	i_size_write(inode, offset);
+	spin_unlock(&inode->i_lock);
 
-		/*
-		 * unmap_mapping_range is called twice, first simply for
-		 * efficiency so that truncate_inode_pages does fewer
-		 * single-page unmaps.  However after this first call, and
-		 * before truncate_inode_pages finishes, it is possible for
-		 * private pages to be COWed, which remain after
-		 * truncate_inode_pages finishes, hence the second
-		 * unmap_mapping_range call must be made for correctness.
-		 */
-		unmap_mapping_range(mapping, offset + PAGE_SIZE - 1, 0, 1);
-		truncate_inode_pages(mapping, offset);
-		unmap_mapping_range(mapping, offset + PAGE_SIZE - 1, 0, 1);
-	}
-	return 0;
-out_sig:
-	send_sig(SIGXFSZ, current, 0);
-out_big:
-	return -EFBIG;
+	truncate_pagecache(inode, oldsize, offset);
+out:
+	return err;
 }
 
 /**
diff -puN fs/ramfs/file-nommu.c~fs-use-new-truncate-helpers fs/ramfs/file-nommu.c
--- a/fs/ramfs/file-nommu.c~fs-use-new-truncate-helpers
+++ a/fs/ramfs/file-nommu.c
@@ -69,14 +69,11 @@ int ramfs_nommu_expand_for_mapping(struc
 	/* make various checks */
 	order = get_order(newsize);
 	if (unlikely(order >= MAX_ORDER))
-		goto too_big;
+		return -EFBIG;
 
-	limit = current->signal->rlim[RLIMIT_FSIZE].rlim_cur;
-	if (limit != RLIM_INFINITY && newsize > limit)
-		goto fsize_exceeded;
-
-	if (newsize > inode->i_sb->s_maxbytes)
-		goto too_big;
+	ret = inode_newsize_ok(inode, newsize);
+	if (ret)
+		return ret;
 
 	i_size_write(inode, newsize);
 
@@ -118,12 +115,7 @@ int ramfs_nommu_expand_for_mapping(struc
 
 	return 0;
 
- fsize_exceeded:
-	send_sig(SIGXFSZ, current, 0);
- too_big:
-	return -EFBIG;
-
- add_error:
+add_error:
 	while (loop < npages)
 		__free_page(pages + loop++);
 	return ret;
_

Patches currently in -mm which might be from npiggin@suse.de are

origin.patch
linux-next.patch
fs-remove-unneeded-dcache_unhashed-tricks.patch
fs-improve-remountro-vs-buffercache-coherency.patch
reiser4.patch
fs-symlink-write_begin-allocation-context-fix-reiser4-fix.patch

