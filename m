From: Xiaotian Feng <dfeng@redhat.com>
Subject: [PATCH -mmotm 22/30] mm: add support for non block device backed swap files
Date: Tue, 13 Jul 2010 06:20:59 -0400
Message-ID: <20100713102058.2835.10655.sendpatchset@danny.redhat>
References: <20100713101650.2835.15245.sendpatchset@danny.redhat>
Cc: riel@redhat.com, cl@linux-foundation.org, a.p.zijlstra@chello.nl,
        Xiaotian Feng <dfeng@redhat.com>, linux-kernel@vger.kernel.org,
        lwang@redhat.com, penberg@cs.helsinki.fi, akpm@linux-foundation.org,
        davem@davemloft.net
To: linux-mm@kvack.org, linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20100713101650.2835.15245.sendpatchset@danny.redhat>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-nfs.vger.kernel.org>

>From 0c3f6a5db5c61a222135286e8a6ada7411b3ac3b Mon Sep 17 00:00:00 2001
From: Xiaotian Feng <dfeng@redhat.com>
Date: Tue, 13 Jul 2010 13:08:45 +0800
Subject: [PATCH 22/30] mm: add support for non block device backed swap files

New addres_space_operations methods are added:
  int swapon(struct file *);
  int swapoff(struct file *);
  int swap_out(struct file *, struct page *, struct writeback_control *);
  int swap_in(struct file *, struct page *);

When during sys_swapon() the ->swapon() method is found and returns no error
the swapper_space.a_ops will proxy to sis->swap_file->f_mapping->a_ops, and
make use of ->swap_{out,in}() to write/read swapcache pages.

The ->swapon() method will be used to communicate to the file that the VM
relies on it, and the address_space should take adequate measures (like
reserving memory for mempools or the like). The ->swapoff() method will be
called on sys_swapoff() when ->swapon() was found and returned no error.

This new interface can be used to obviate the need for ->bmap in the swapfile
code. A filesystem would need to load (and maybe even allocate) the full block
map for a file into memory and pin it there on ->swapon() so that
->swap_{out,in}() have instant access to it. It can be released on ->swapoff().

The reason to provide ->swap_{out,in}() over using {write,read}page() is to
 1) make a distinction between swapcache and pagecache pages, and
 2) to provide a struct file * for credential context (normally not needed
    in the context of writepage, as the page content is normally dirtied
    using either of the following interfaces:
      write_{begin,end}()
      {prepare,commit}_write()
      page_mkwrite()
    which do have the file context.

[miklos@szeredi.hu: cleanups]
[dfeng@redhat.com: fix get_swap_info return value]
[dfeng@redhat.com: fix wrong SWP_FILE enum]
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
---
 Documentation/filesystems/Locking |   22 +++++++++++++++
 Documentation/filesystems/vfs.txt |   18 ++++++++++++
 include/linux/buffer_head.h       |    1 +
 include/linux/fs.h                |    9 ++++++
 include/linux/swap.h              |    5 +++-
 mm/page_io.c                      |   54 +++++++++++++++++++++++++++++++++++++
 mm/swap_state.c                   |    4 +-
 mm/swapfile.c                     |   36 +++++++++++++++++++++++-
 8 files changed, 144 insertions(+), 5 deletions(-)

diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
index 96d4293..9e221ad 100644
--- a/Documentation/filesystems/Locking
+++ b/Documentation/filesystems/Locking
@@ -174,6 +174,10 @@ prototypes:
 	int (*direct_IO)(int, struct kiocb *, const struct iovec *iov,
 			loff_t offset, unsigned long nr_segs);
 	int (*launder_page) (struct page *);
+	int (*swapon) (struct file *);
+	int (*swapoff) (struct file *);
+	int (*swap_out) (struct file *, struct page *, struct writeback_control *);
+	int (*swap_in)  (struct file *, struct page *);
 
 locking rules:
 	All except set_page_dirty may block
@@ -193,6 +197,10 @@ invalidatepage:		no	yes
 releasepage:		no	yes
 direct_IO:		no
 launder_page:		no	yes
+swapon			no
+swapoff			no
+swap_out		no	yes, unlocks
+swap_in			no	yes, unlocks
 
 	->write_begin(), ->write_end(), ->sync_page() and ->readpage()
 may be called from the request handler (/dev/loop).
@@ -292,6 +300,20 @@ cleaned, or an error value if not. Note that in order to prevent the page
 getting mapped back in and redirtied, it needs to be kept locked
 across the entire operation.
 
+	->swapon() will be called with a non-zero argument on files backing
+(non block device backed) swapfiles. A return value of zero indicates success,
+in which case this file can be used for backing swapspace. The swapspace
+operations will be proxied to the address space operations.
+
+	->swapoff() will be called in the sys_swapoff() path when ->swapon()
+returned success.
+
+	->swap_out() when swapon() returned success, this method is used to
+write the swap page.
+
+	->swap_in() when swapon() returned success, this method is used to
+read the swap page.
+
 	Note: currently almost all instances of address_space methods are
 using BKL for internal serialization and that's one of the worst sources
 of contention. Normally they are calling library functions (in fs/buffer.c)
diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
index 94677e7..209ae81 100644
--- a/Documentation/filesystems/vfs.txt
+++ b/Documentation/filesystems/vfs.txt
@@ -542,6 +542,11 @@ struct address_space_operations {
 	int (*migratepage) (struct page *, struct page *);
 	int (*launder_page) (struct page *);
 	int (*error_remove_page) (struct mapping *mapping, struct page *page);
+	int (*swapon)(struct file *);
+	int (*swapoff)(struct file *);
+	int (*swap_out)(struct file *file, struct page *page,
+			struct writeback_control *wbc);
+	int (*swap_in)(struct file *file, struct page *page);
 };
 
   writepage: called by the VM to write a dirty page to backing store.
@@ -706,6 +711,19 @@ struct address_space_operations {
 	unless you have them locked or reference counts increased.
 
 
+  swapon: Called when swapon is used on a file. A
+	return value of zero indicates success, in which case this
+	file can be used to back swapspace. The swapspace operations
+	will be proxied to this address space's ->swap_{out,in} methods.
+
+  swapoff: Called during swapoff on files where swapon was successfull.
+
+  swap_out: Called to write a swapcache page to a backing store, similar to
+	writepage.
+
+  swap_in: Called to read a swapcache page from a backing store, similar to
+	readpage.
+
 The File Object
 ===============
 
diff --git a/include/linux/buffer_head.h b/include/linux/buffer_head.h
index 5aa3850..7ec96e7 100644
--- a/include/linux/buffer_head.h
+++ b/include/linux/buffer_head.h
@@ -329,6 +329,7 @@ static inline int inode_has_buffers(struct inode *inode) { return 0; }
 static inline void invalidate_inode_buffers(struct inode *inode) {}
 static inline int remove_inode_buffers(struct inode *inode) { return 1; }
 static inline int sync_mapping_buffers(struct address_space *mapping) { return 0; }
+static inline void block_sync_page(struct page *) { }
 
 #endif /* CONFIG_BLOCK */
 #endif /* _LINUX_BUFFER_HEAD_H */
diff --git a/include/linux/fs.h b/include/linux/fs.h
index dc9d185..ef11408 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -612,6 +612,15 @@ struct address_space_operations {
 	int (*is_partially_uptodate) (struct page *, read_descriptor_t *,
 					unsigned long);
 	int (*error_remove_page)(struct address_space *, struct page *);
+
+	/*
+	 * swapfile support
+	 */
+	int (*swapon)(struct file *file);
+	int (*swapoff)(struct file *file);
+	int (*swap_out)(struct file *file, struct page *page,
+			struct writeback_control *wbc);
+	int (*swap_in)(struct file *file, struct page *page);
 };
 
 /*
diff --git a/include/linux/swap.h b/include/linux/swap.h
index ff4acea..dafea65 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -147,7 +147,7 @@ enum {
 	SWP_SOLIDSTATE	= (1 << 4),	/* blkdev seeks are cheap */
 	SWP_CONTINUED	= (1 << 5),	/* swap_map has count continuation */
 	SWP_BLKDEV	= (1 << 6),	/* its a block device */
-					/* add others here before... */
+	SWP_FILE	= (1 << 7),	/* file swap area */
 	SWP_SCANNING	= (1 << 8),	/* refcount in scan_swap_map */
 };
 
@@ -293,6 +293,8 @@ extern void swap_unplug_io_fn(struct backing_dev_info *, struct page *);
 /* linux/mm/page_io.c */
 extern int swap_readpage(struct page *);
 extern int swap_writepage(struct page *page, struct writeback_control *wbc);
+extern void swap_sync_page(struct page *page);
+extern int swap_set_page_dirty(struct page *page);
 extern void end_swap_bio_read(struct bio *bio, int err);
 
 /* linux/mm/swap_state.c */
@@ -329,6 +331,7 @@ extern int swap_type_of(dev_t, sector_t, struct block_device **);
 extern unsigned int count_swap_pages(int, int);
 extern sector_t map_swap_page(struct page *, struct block_device **);
 extern sector_t swapdev_block(int, pgoff_t);
+extern struct swap_info_struct *page_swap_info(struct page *);
 extern int reuse_swap_page(struct page *);
 extern int try_to_free_swap(struct page *);
 struct backing_dev_info;
diff --git a/mm/page_io.c b/mm/page_io.c
index 2dee975..012b9ef 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -18,6 +18,7 @@
 #include <linux/bio.h>
 #include <linux/swapops.h>
 #include <linux/writeback.h>
+#include <linux/buffer_head.h>
 #include <asm/pgtable.h>
 
 static struct bio *get_swap_bio(gfp_t gfp_flags,
@@ -98,6 +99,17 @@ int swap_writepage(struct page *page, struct writeback_control *wbc)
 		unlock_page(page);
 		goto out;
 	}
+
+	if (sis->flags & SWP_FILE) {
+		struct file *swap_file = sis->swap_file;
+		struct address_space *mapping = swap_file->f_mapping;
+
+		ret = mapping->a_ops->swap_out(swap_file, page, wbc);
+		if (!ret)
+			count_vm_event(PSWPOUT);
+		return ret;
+	}
+
 	bio = get_swap_bio(GFP_NOIO, page, end_swap_bio_write);
 	if (bio == NULL) {
 		set_page_dirty(page);
@@ -115,13 +127,55 @@ out:
 	return ret;
 }
 
+void swap_sync_page(struct page *page)
+{
+	struct swap_info_struct *sis = page_swap_info(page);
+
+	if (!sis)
+		return;
+
+	if (sis->flags & SWP_FILE) {
+		struct address_space *mapping = sis->swap_file->f_mapping;
+
+	if (mapping->a_ops->sync_page)
+		mapping->a_ops->sync_page(page);
+	} else {
+		block_sync_page(page);
+	}
+}
+
+int swap_set_page_dirty(struct page *page)
+{
+	struct swap_info_struct *sis = page_swap_info(page);
+
+	if (sis->flags & SWP_FILE) {
+		struct address_space *mapping = sis->swap_file->f_mapping;
+
+		return mapping->a_ops->set_page_dirty(page);
+	} else {
+		return __set_page_dirty_nobuffers(page);
+	}
+}
+
 int swap_readpage(struct page *page)
 {
 	struct bio *bio;
 	int ret = 0;
+	struct swap_info_struct *sis = page_swap_info(page);
 
 	VM_BUG_ON(!PageLocked(page));
 	VM_BUG_ON(PageUptodate(page));
+
+	if (sis->flags & SWP_FILE) {
+		struct file *swap_file = sis->swap_file;
+		struct address_space *mapping = swap_file->f_mapping;
+
+		ret = mapping->a_ops->swap_in(swap_file, page);
+		if (!ret)
+			count_vm_event(PSWPIN);
+		return ret;
+	}
+
 	bio = get_swap_bio(GFP_KERNEL, page, end_swap_bio_read);
 	if (bio == NULL) {
 		unlock_page(page);
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 8d5399f..041428b 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -28,8 +28,8 @@
  */
 static const struct address_space_operations swap_aops = {
 	.writepage	= swap_writepage,
-	.sync_page	= block_sync_page,
-	.set_page_dirty	= __set_page_dirty_nobuffers,
+	.sync_page	= swap_sync_page,
+	.set_page_dirty	= swap_set_page_dirty,
 	.migratepage	= migrate_page,
 };
 
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 03aa2d5..a7baef1 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1353,6 +1353,14 @@ static void destroy_swap_extents(struct swap_info_struct *sis)
 		list_del(&se->list);
 		kfree(se);
 	}
+
+	if (sis->flags & SWP_FILE) {
+		struct file *swap_file = sis->swap_file;
+		struct address_space *mapping = swap_file->f_mapping;
+
+		sis->flags &= ~SWP_FILE;
+		mapping->a_ops->swapoff(swap_file);
+	}
 }
 
 /*
@@ -1434,7 +1442,9 @@ add_swap_extent(struct swap_info_struct *sis, unsigned long start_page,
  */
 static int setup_swap_extents(struct swap_info_struct *sis, sector_t *span)
 {
-	struct inode *inode;
+	struct file *swap_file = sis->swap_file;
+	struct address_space *mapping = swap_file->f_mapping;
+	struct inode *inode = mapping->host;
 	unsigned blocks_per_page;
 	unsigned long page_no;
 	unsigned blkbits;
@@ -1445,13 +1455,22 @@ static int setup_swap_extents(struct swap_info_struct *sis, sector_t *span)
 	int nr_extents = 0;
 	int ret;
 
-	inode = sis->swap_file->f_mapping->host;
 	if (S_ISBLK(inode->i_mode)) {
 		ret = add_swap_extent(sis, 0, sis->max, 0);
 		*span = sis->pages;
 		goto out;
 	}
 
+	if (mapping->a_ops->swapon) {
+		ret = mapping->a_ops->swapon(swap_file);
+		if (!ret) {
+			sis->flags |= SWP_FILE;
+			ret = add_swap_extent(sis, 0, sis->max, 0);
+			*span = sis->pages;
+		}
+		goto out;
+	}
+
 	blkbits = inode->i_blkbits;
 	blocks_per_page = PAGE_SIZE >> blkbits;
 
@@ -2228,6 +2247,19 @@ int swapcache_prepare(swp_entry_t entry)
 	return __swap_duplicate(entry, SWAP_HAS_CACHE);
 }
 
+struct swap_info_struct *page_swap_info(struct page *page)
+{
+	swp_entry_t swap = { .val = page_private(page) };
+	if (!PageSwapCache(page) || !swap.val) {
+		/* This should only happen from sync_page.
+		 * In other cases the page should be locked and
+		 * should be in a SwapCache
+		 */
+		return NULL;
+	}
+	return swap_info[swp_type(swap)];
+}
+
 /*
  * swap_lock prevents swap_map being freed. Don't grab an extra
  * reference on the swaphandle, it doesn't matter if it becomes unused.
-- 
1.7.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
