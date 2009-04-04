From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: bus errors on nfs writes in latest git
Date: Sat, 4 Apr 2009 12:14:47 -0400
Message-ID: <20090404161447.GE495@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:35791 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751518AbZDDQOu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 4 Apr 2009 12:14:50 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

My regular connecthon tests are reporting bus errors on the "write/read
30 MB file" on recent upstream kernels.  I'm travelling and haven't had
a chance to do anything beyond kick off a dumb git-bisect, which pointed
the blame at the following commit.  Any ideas?

--b.


commit c2ec175c39f62949438354f603f4aa170846aabb
Author: Nick Piggin <npiggin@suse.de>
Date:   Tue Mar 31 15:23:21 2009 -0700

    mm: page_mkwrite change prototype to match fault
    
    Change the page_mkwrite prototype to take a struct vm_fault, and return
    VM_FAULT_xxx flags.  There should be no functional change.
    
    This makes it possible to return much more detailed error information to
    the VM (and also can provide more information eg.  virtual_address to the
    driver, which might be important in some special cases).
    
    This is required for a subsequent fix.  And will also make it easier to
    merge page_mkwrite() with fault() in future.
    
    Signed-off-by: Nick Piggin <npiggin@suse.de>
    Cc: Chris Mason <chris.mason@oracle.com>
    Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
    Cc: Miklos Szeredi <miklos@szeredi.hu>
    Cc: Steven Whitehouse <swhiteho@redhat.com>
    Cc: Mark Fasheh <mfasheh@suse.com>
    Cc: Joel Becker <joel.becker@oracle.com>
    Cc: Artem Bityutskiy <dedekind@infradead.org>
    Cc: Felix Blyakher <felixb@sgi.com>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
index 4e78ce6..76efe5b 100644
--- a/Documentation/filesystems/Locking
+++ b/Documentation/filesystems/Locking
@@ -505,7 +505,7 @@ prototypes:
 	void (*open)(struct vm_area_struct*);
 	void (*close)(struct vm_area_struct*);
 	int (*fault)(struct vm_area_struct*, struct vm_fault *);
-	int (*page_mkwrite)(struct vm_area_struct *, struct page *);
+	int (*page_mkwrite)(struct vm_area_struct *, struct vm_fault *);
 	int (*access)(struct vm_area_struct *, unsigned long, void*, int, int);
 
 locking rules:
diff --git a/drivers/video/fb_defio.c b/drivers/video/fb_defio.c
index 0820265..0a7a667 100644
--- a/drivers/video/fb_defio.c
+++ b/drivers/video/fb_defio.c
@@ -85,8 +85,9 @@ EXPORT_SYMBOL_GPL(fb_deferred_io_fsync);
 
 /* vm_ops->page_mkwrite handler */
 static int fb_deferred_io_mkwrite(struct vm_area_struct *vma,
-				  struct page *page)
+				  struct vm_fault *vmf)
 {
+	struct page *page = vmf->page;
 	struct fb_info *info = vma->vm_private_data;
 	struct fb_deferred_io *fbdefio = info->fbdefio;
 	struct page *cur;
diff --git a/fs/btrfs/ctree.h b/fs/btrfs/ctree.h
index 5e1d4e3..7dd1b6d 100644
--- a/fs/btrfs/ctree.h
+++ b/fs/btrfs/ctree.h
@@ -2060,7 +2060,7 @@ int btrfs_merge_bio_hook(struct page *page, unsigned long offset,
 unsigned long btrfs_force_ra(struct address_space *mapping,
 			      struct file_ra_state *ra, struct file *file,
 			      pgoff_t offset, pgoff_t last_index);
-int btrfs_page_mkwrite(struct vm_area_struct *vma, struct page *page);
+int btrfs_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf);
 int btrfs_readpage(struct file *file, struct page *page);
 void btrfs_delete_inode(struct inode *inode);
 void btrfs_put_inode(struct inode *inode);
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index 7d4f948..ec54237 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -4292,8 +4292,9 @@ static void btrfs_invalidatepage(struct page *page, unsigned long offset)
  * beyond EOF, then the page is guaranteed safe against truncation until we
  * unlock the page.
  */
-int btrfs_page_mkwrite(struct vm_area_struct *vma, struct page *page)
+int btrfs_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
+	struct page *page = vmf->page;
 	struct inode *inode = fdentry(vma->vm_file)->d_inode;
 	struct btrfs_root *root = BTRFS_I(inode)->root;
 	struct extent_io_tree *io_tree = &BTRFS_I(inode)->io_tree;
@@ -4362,6 +4363,8 @@ again:
 out_unlock:
 	unlock_page(page);
 out:
+	if (ret)
+		ret = VM_FAULT_SIGBUS;
 	return ret;
 }
 
diff --git a/fs/buffer.c b/fs/buffer.c
index 73abe6d..6d51a3d 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -2313,9 +2313,10 @@ int block_commit_write(struct page *page, unsigned from, unsigned to)
  * unlock the page.
  */
 int
-block_page_mkwrite(struct vm_area_struct *vma, struct page *page,
+block_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
 		   get_block_t get_block)
 {
+	struct page *page = vmf->page;
 	struct inode *inode = vma->vm_file->f_path.dentry->d_inode;
 	unsigned long end;
 	loff_t size;
@@ -2340,6 +2341,9 @@ block_page_mkwrite(struct vm_area_struct *vma, struct page *page,
 		ret = block_commit_write(page, 0, end);
 
 out_unlock:
+	if (ret)
+		ret = VM_FAULT_SIGBUS;
+
 	unlock_page(page);
 	return ret;
 }
diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index 6083bb3..990c940 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -1098,7 +1098,7 @@ extern int ext4_meta_trans_blocks(struct inode *, int nrblocks, int idxblocks);
 extern int ext4_chunk_trans_blocks(struct inode *, int nrblocks);
 extern int ext4_block_truncate_page(handle_t *handle,
 		struct address_space *mapping, loff_t from);
-extern int ext4_page_mkwrite(struct vm_area_struct *vma, struct page *page);
+extern int ext4_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf);
 extern qsize_t ext4_get_reserved_space(struct inode *inode);
 
 /* ioctl.c */
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 71d3ecd..dd82ff3 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -5146,8 +5146,9 @@ static int ext4_bh_unmapped(handle_t *handle, struct buffer_head *bh)
 	return !buffer_mapped(bh);
 }
 
-int ext4_page_mkwrite(struct vm_area_struct *vma, struct page *page)
+int ext4_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
+	struct page *page = vmf->page;
 	loff_t size;
 	unsigned long len;
 	int ret = -EINVAL;
@@ -5199,6 +5200,8 @@ int ext4_page_mkwrite(struct vm_area_struct *vma, struct page *page)
 		goto out_unlock;
 	ret = 0;
 out_unlock:
+	if (ret)
+		ret = VM_FAULT_SIGBUS;
 	up_read(&inode->i_alloc_sem);
 	return ret;
 }
diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index 821d10f..4e340fe 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -1234,8 +1234,9 @@ static void fuse_vma_close(struct vm_area_struct *vma)
  * - sync(2)
  * - try_to_free_pages() with order > PAGE_ALLOC_COSTLY_ORDER
  */
-static int fuse_page_mkwrite(struct vm_area_struct *vma, struct page *page)
+static int fuse_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
+	struct page *page = vmf->page;
 	/*
 	 * Don't use page->mapping as it may become NULL from a
 	 * concurrent truncate.
diff --git a/fs/gfs2/ops_file.c b/fs/gfs2/ops_file.c
index 3b9e8de..70b9b85 100644
--- a/fs/gfs2/ops_file.c
+++ b/fs/gfs2/ops_file.c
@@ -337,8 +337,9 @@ static int gfs2_allocate_page_backing(struct page *page)
  * blocks allocated on disk to back that page.
  */
 
-static int gfs2_page_mkwrite(struct vm_area_struct *vma, struct page *page)
+static int gfs2_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
+	struct page *page = vmf->page;
 	struct inode *inode = vma->vm_file->f_path.dentry->d_inode;
 	struct gfs2_inode *ip = GFS2_I(inode);
 	struct gfs2_sbd *sdp = GFS2_SB(inode);
@@ -412,6 +413,8 @@ out_unlock:
 	gfs2_glock_dq(&gh);
 out:
 	gfs2_holder_uninit(&gh);
+	if (ret)
+		ret = VM_FAULT_SIGBUS;
 	return ret;
 }
 
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 90f292b..cec7939 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -451,8 +451,9 @@ const struct address_space_operations nfs_file_aops = {
 	.launder_page = nfs_launder_page,
 };
 
-static int nfs_vm_page_mkwrite(struct vm_area_struct *vma, struct page *page)
+static int nfs_vm_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
+	struct page *page = vmf->page;
 	struct file *filp = vma->vm_file;
 	struct dentry *dentry = filp->f_path.dentry;
 	unsigned pagelen;
@@ -483,6 +484,8 @@ static int nfs_vm_page_mkwrite(struct vm_area_struct *vma, struct page *page)
 		ret = pagelen;
 out_unlock:
 	unlock_page(page);
+	if (ret)
+		ret = VM_FAULT_SIGBUS;
 	return ret;
 }
 
diff --git a/fs/ocfs2/mmap.c b/fs/ocfs2/mmap.c
index eea1d24..b606496 100644
--- a/fs/ocfs2/mmap.c
+++ b/fs/ocfs2/mmap.c
@@ -154,8 +154,9 @@ out:
 	return ret;
 }
 
-static int ocfs2_page_mkwrite(struct vm_area_struct *vma, struct page *page)
+static int ocfs2_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
+	struct page *page = vmf->page;
 	struct inode *inode = vma->vm_file->f_path.dentry->d_inode;
 	struct buffer_head *di_bh = NULL;
 	sigset_t blocked, oldset;
@@ -196,7 +197,8 @@ out:
 	ret2 = ocfs2_vm_op_unblock_sigs(&oldset);
 	if (ret2 < 0)
 		mlog_errno(ret2);
-
+	if (ret)
+		ret = VM_FAULT_SIGBUS;
 	return ret;
 }
 
diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
index 93b6de5..0ff89fe 100644
--- a/fs/ubifs/file.c
+++ b/fs/ubifs/file.c
@@ -1434,8 +1434,9 @@ static int ubifs_releasepage(struct page *page, gfp_t unused_gfp_flags)
  * mmap()d file has taken write protection fault and is being made
  * writable. UBIFS must ensure page is budgeted for.
  */
-static int ubifs_vm_page_mkwrite(struct vm_area_struct *vma, struct page *page)
+static int ubifs_vm_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
+	struct page *page = vmf->page;
 	struct inode *inode = vma->vm_file->f_path.dentry->d_inode;
 	struct ubifs_info *c = inode->i_sb->s_fs_info;
 	struct timespec now = ubifs_current_time(inode);
@@ -1447,7 +1448,7 @@ static int ubifs_vm_page_mkwrite(struct vm_area_struct *vma, struct page *page)
 	ubifs_assert(!(inode->i_sb->s_flags & MS_RDONLY));
 
 	if (unlikely(c->ro_media))
-		return -EROFS;
+		return VM_FAULT_SIGBUS; /* -EROFS */
 
 	/*
 	 * We have not locked @page so far so we may budget for changing the
@@ -1480,7 +1481,7 @@ static int ubifs_vm_page_mkwrite(struct vm_area_struct *vma, struct page *page)
 		if (err == -ENOSPC)
 			ubifs_warn("out of space for mmapped file "
 				   "(inode number %lu)", inode->i_ino);
-		return err;
+		return VM_FAULT_SIGBUS;
 	}
 
 	lock_page(page);
@@ -1520,6 +1521,8 @@ static int ubifs_vm_page_mkwrite(struct vm_area_struct *vma, struct page *page)
 out_unlock:
 	unlock_page(page);
 	ubifs_release_budget(c, &req);
+	if (err)
+		err = VM_FAULT_SIGBUS;
 	return err;
 }
 
diff --git a/fs/xfs/linux-2.6/xfs_file.c b/fs/xfs/linux-2.6/xfs_file.c
index e14c4e3..f4e2554 100644
--- a/fs/xfs/linux-2.6/xfs_file.c
+++ b/fs/xfs/linux-2.6/xfs_file.c
@@ -234,9 +234,9 @@ xfs_file_mmap(
 STATIC int
 xfs_vm_page_mkwrite(
 	struct vm_area_struct	*vma,
-	struct page		*page)
+	struct vm_fault		*vmf)
 {
-	return block_page_mkwrite(vma, page, xfs_get_blocks);
+	return block_page_mkwrite(vma, vmf, xfs_get_blocks);
 }
 
 const struct file_operations xfs_file_operations = {
diff --git a/include/linux/buffer_head.h b/include/linux/buffer_head.h
index f19fd90..3d7bcde 100644
--- a/include/linux/buffer_head.h
+++ b/include/linux/buffer_head.h
@@ -216,7 +216,7 @@ int cont_write_begin(struct file *, struct address_space *, loff_t,
 			get_block_t *, loff_t *);
 int generic_cont_expand_simple(struct inode *inode, loff_t size);
 int block_commit_write(struct page *page, unsigned from, unsigned to);
-int block_page_mkwrite(struct vm_area_struct *vma, struct page *page,
+int block_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
 				get_block_t get_block);
 void block_sync_page(struct page *);
 sector_t generic_block_bmap(struct address_space *, sector_t, get_block_t *);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 2223f8d..aeabe95 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -135,6 +135,7 @@ extern pgprot_t protection_map[16];
 
 #define FAULT_FLAG_WRITE	0x01	/* Fault was a write access */
 #define FAULT_FLAG_NONLINEAR	0x02	/* Fault was via a nonlinear mapping */
+#define FAULT_FLAG_MKWRITE	0x04	/* Fault was mkwrite of existing pte */
 
 /*
  * This interface is used by x86 PAT code to identify a pfn mapping that is
@@ -187,7 +188,7 @@ struct vm_operations_struct {
 
 	/* notification that a previously read-only page is about to become
 	 * writable, if an error is returned it will cause a SIGBUS */
-	int (*page_mkwrite)(struct vm_area_struct *vma, struct page *page);
+	int (*page_mkwrite)(struct vm_area_struct *vma, struct vm_fault *vmf);
 
 	/* called by access_process_vm when get_user_pages() fails, typically
 	 * for use by special VMAs that can switch between memory and hardware
diff --git a/mm/memory.c b/mm/memory.c
index 5b4ad5e..cf6873e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1945,6 +1945,15 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		 * get_user_pages(.write=1, .force=1).
 		 */
 		if (vma->vm_ops && vma->vm_ops->page_mkwrite) {
+			struct vm_fault vmf;
+			int tmp;
+
+			vmf.virtual_address = (void __user *)(address &
+								PAGE_MASK);
+			vmf.pgoff = old_page->index;
+			vmf.flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
+			vmf.page = old_page;
+
 			/*
 			 * Notify the address space that the page is about to
 			 * become writable so that it can prohibit this or wait
@@ -1956,8 +1965,12 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			page_cache_get(old_page);
 			pte_unmap_unlock(page_table, ptl);
 
-			if (vma->vm_ops->page_mkwrite(vma, old_page) < 0)
+			tmp = vma->vm_ops->page_mkwrite(vma, &vmf);
+			if (unlikely(tmp &
+					(VM_FAULT_ERROR | VM_FAULT_NOPAGE))) {
+				ret = tmp;
 				goto unwritable_page;
+			}
 
 			/*
 			 * Since we dropped the lock we need to revalidate
@@ -2106,7 +2119,7 @@ oom:
 
 unwritable_page:
 	page_cache_release(old_page);
-	return VM_FAULT_SIGBUS;
+	return ret;
 }
 
 /*
@@ -2648,9 +2661,14 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			 * to become writable
 			 */
 			if (vma->vm_ops->page_mkwrite) {
+				int tmp;
+
 				unlock_page(page);
-				if (vma->vm_ops->page_mkwrite(vma, page) < 0) {
-					ret = VM_FAULT_SIGBUS;
+				vmf.flags |= FAULT_FLAG_MKWRITE;
+				tmp = vma->vm_ops->page_mkwrite(vma, &vmf);
+				if (unlikely(tmp &
+					  (VM_FAULT_ERROR | VM_FAULT_NOPAGE))) {
+					ret = tmp;
 					anon = 1; /* no anon but release vmf.page */
 					goto out_unlocked;
 				}
