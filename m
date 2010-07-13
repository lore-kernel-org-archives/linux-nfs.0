From: Xiaotian Feng <dfeng@redhat.com>
Subject: [PATCH -mmotm 24/30] nfs: teach the NFS client how to treat PG_swapcache pages
Date: Tue, 13 Jul 2010 06:21:21 -0400
Message-ID: <20100713102121.2835.77887.sendpatchset@danny.redhat>
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

>From 743090cf0c129f3c83506260866f525a9f181f99 Mon Sep 17 00:00:00 2001
From: Xiaotian Feng <dfeng@redhat.com>
Date: Tue, 13 Jul 2010 13:10:26 +0800
Subject: [PATCH 24/30] nfs: teach the NFS client how to treat PG_swapcache pages

Replace all relevant occurences of page->index and page->mapping in the NFS
client with the new page_file_index() and page_file_mapping() functions.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
---
 fs/nfs/dir.c           |    4 ++--
 fs/nfs/file.c          |   14 +++++++-------
 fs/nfs/fscache-index.c |    2 +-
 fs/nfs/fscache.c       |   14 +++++++-------
 fs/nfs/internal.h      |    7 ++++---
 fs/nfs/pagelist.c      |    6 +++---
 fs/nfs/read.c          |    6 +++---
 fs/nfs/write.c         |   45 +++++++++++++++++++++++----------------------
 8 files changed, 50 insertions(+), 48 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 782b431..0305786 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -182,7 +182,7 @@ int nfs_readdir_filler(nfs_readdir_descriptor_t *desc, struct page *page)
 
 	dfprintk(DIRCACHE, "NFS: %s: reading cookie %Lu into page %lu\n",
 			__func__, (long long)desc->entry->cookie,
-			page->index);
+			page_file_index(page));
 
  again:
 	timestamp = jiffies;
@@ -207,7 +207,7 @@ int nfs_readdir_filler(nfs_readdir_descriptor_t *desc, struct page *page)
 	 * Note: assumes we have exclusive access to this mapping either
 	 *	 through inode->i_mutex or some other mechanism.
 	 */
-	if (invalidate_inode_pages2_range(inode->i_mapping, page->index + 1, -1) < 0) {
+	if (invalidate_inode_pages2_range(inode->i_mapping, page_file_index(page) + 1, -1) < 0) {
 		/* Should never happen */
 		nfs_zap_mapping(inode, inode->i_mapping);
 	}
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 36a5e74..8f066fe 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -480,9 +480,9 @@ static void nfs_invalidate_page(struct page *page, unsigned long offset)
 	if (offset != 0)
 		return;
 	/* Cancel any unstarted writes on this page */
-	nfs_wb_page_cancel(page->mapping->host, page);
+	nfs_wb_page_cancel(page_file_mapping(page)->host, page);
 
-	nfs_fscache_invalidate_page(page, page->mapping->host);
+	nfs_fscache_invalidate_page(page, page_file_mapping(page)->host);
 }
 
 /*
@@ -497,7 +497,7 @@ static int nfs_release_page(struct page *page, gfp_t gfp)
 
 	/* Only do I/O if gfp is a superset of GFP_KERNEL */
 	if ((gfp & GFP_KERNEL) == GFP_KERNEL)
-		nfs_wb_page(page->mapping->host, page);
+		nfs_wb_page(page_file_mapping(page)->host, page);
 	/* If PagePrivate() is set, then the page is not freeable */
 	if (PagePrivate(page))
 		return 0;
@@ -514,11 +514,11 @@ static int nfs_release_page(struct page *page, gfp_t gfp)
  */
 static int nfs_launder_page(struct page *page)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_file_mapping(page)->host;
 	struct nfs_inode *nfsi = NFS_I(inode);
 
 	dfprintk(PAGECACHE, "NFS: launder_page(%ld, %llu)\n",
-		inode->i_ino, (long long)page_offset(page));
+		inode->i_ino, (long long)page_file_offset(page));
 
 	nfs_fscache_wait_on_page_write(nfsi, page);
 	return nfs_wb_page(inode, page);
@@ -557,13 +557,13 @@ static int nfs_vm_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	dfprintk(PAGECACHE, "NFS: vm_page_mkwrite(%s/%s(%ld), offset %lld)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name,
 		filp->f_mapping->host->i_ino,
-		(long long)page_offset(page));
+		(long long)page_file_offset(page));
 
 	/* make sure the cache has finished storing the page */
 	nfs_fscache_wait_on_page_write(NFS_I(dentry->d_inode), page);
 
 	lock_page(page);
-	mapping = page->mapping;
+	mapping = page_file_mapping(page);
 	if (mapping != dentry->d_inode->i_mapping)
 		goto out_unlock;
 
diff --git a/fs/nfs/fscache-index.c b/fs/nfs/fscache-index.c
index 5b10064..9aa62a0 100644
--- a/fs/nfs/fscache-index.c
+++ b/fs/nfs/fscache-index.c
@@ -283,7 +283,7 @@ static void nfs_fscache_inode_now_uncached(void *cookie_netfs_data)
 		for (loop = 0; loop < nr_pages; loop++)
 			ClearPageFsCache(pvec.pages[loop]);
 
-		first = pvec.pages[nr_pages - 1]->index + 1;
+		first = page_file_index(pvec.pages[nr_pages - 1]) + 1;
 
 		pvec.nr = nr_pages;
 		pagevec_release(&pvec);
diff --git a/fs/nfs/fscache.c b/fs/nfs/fscache.c
index ce153a6..c6642ea 100644
--- a/fs/nfs/fscache.c
+++ b/fs/nfs/fscache.c
@@ -356,7 +356,7 @@ void nfs_fscache_reset_inode_cookie(struct inode *inode)
 int nfs_fscache_release_page(struct page *page, gfp_t gfp)
 {
 	if (PageFsCache(page)) {
-		struct nfs_inode *nfsi = NFS_I(page->mapping->host);
+		struct nfs_inode *nfsi = NFS_I(page_file_mapping(page)->host);
 		struct fscache_cookie *cookie = nfsi->fscache;
 
 		BUG_ON(!cookie);
@@ -366,7 +366,7 @@ int nfs_fscache_release_page(struct page *page, gfp_t gfp)
 		if (!fscache_maybe_release_page(cookie, page, gfp))
 			return 0;
 
-		nfs_add_fscache_stats(page->mapping->host,
+		nfs_add_fscache_stats(page_file_mapping(page)->host,
 				      NFSIOS_FSCACHE_PAGES_UNCACHED, 1);
 	}
 
@@ -391,7 +391,7 @@ void __nfs_fscache_invalidate_page(struct page *page, struct inode *inode)
 
 	BUG_ON(!PageLocked(page));
 	fscache_uncache_page(cookie, page);
-	nfs_add_fscache_stats(page->mapping->host,
+	nfs_add_fscache_stats(page_file_mapping(page)->host,
 			      NFSIOS_FSCACHE_PAGES_UNCACHED, 1);
 }
 
@@ -413,7 +413,7 @@ static void nfs_readpage_from_fscache_complete(struct page *page,
 		SetPageUptodate(page);
 		unlock_page(page);
 	} else {
-		error = nfs_readpage_async(context, page->mapping->host, page);
+		error = nfs_readpage_async(context, page_file_mapping(page)->host, page);
 		if (error)
 			unlock_page(page);
 	}
@@ -429,7 +429,7 @@ int __nfs_readpage_from_fscache(struct nfs_open_context *ctx,
 
 	dfprintk(FSCACHE,
 		 "NFS: readpage_from_fscache(fsc:%p/p:%p(i:%lx f:%lx)/0x%p)\n",
-		 NFS_I(inode)->fscache, page, page->index, page->flags, inode);
+		 NFS_I(inode)->fscache, page, page_file_index(page), page->flags, inode);
 
 	ret = fscache_read_or_alloc_page(NFS_I(inode)->fscache,
 					 page,
@@ -518,12 +518,12 @@ void __nfs_readpage_to_fscache(struct inode *inode, struct page *page, int sync)
 
 	dfprintk(FSCACHE,
 		 "NFS: readpage_to_fscache(fsc:%p/p:%p(i:%lx f:%lx)/%d)\n",
-		 NFS_I(inode)->fscache, page, page->index, page->flags, sync);
+		 NFS_I(inode)->fscache, page, page_file_index(page), page->flags, sync);
 
 	ret = fscache_write_page(NFS_I(inode)->fscache, page, GFP_KERNEL);
 	dfprintk(FSCACHE,
 		 "NFS:     readpage_to_fscache: p:%p(i:%lu f:%lx) ret %d\n",
-		 page, page->index, page->flags, ret);
+		 page, page_file_index(page), page->flags, ret);
 
 	if (ret != 0) {
 		fscache_uncache_page(NFS_I(inode)->fscache, page);
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index d8bd619..1110617 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -342,13 +342,14 @@ void nfs_super_set_maxbytes(struct super_block *sb, __u64 maxfilesize)
 static inline
 unsigned int nfs_page_length(struct page *page)
 {
-	loff_t i_size = i_size_read(page->mapping->host);
+	loff_t i_size = i_size_read(page_file_mapping(page)->host);
 
 	if (i_size > 0) {
+		pgoff_t page_index = page_file_index(page);
 		pgoff_t end_index = (i_size - 1) >> PAGE_CACHE_SHIFT;
-		if (page->index < end_index)
+		if (page_index < end_index)
 			return PAGE_CACHE_SIZE;
-		if (page->index == end_index)
+		if (page_index == end_index)
 			return ((i_size - 1) & ~PAGE_CACHE_MASK) + 1;
 	}
 	return 0;
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index a3654e5..2be94bb 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -70,11 +70,11 @@ nfs_create_request(struct nfs_open_context *ctx, struct inode *inode,
 	 * update_nfs_request below if the region is not locked. */
 	req->wb_page    = page;
 	atomic_set(&req->wb_complete, 0);
-	req->wb_index	= page->index;
+	req->wb_index	= page_file_index(page);
 	page_cache_get(page);
 	BUG_ON(PagePrivate(page));
 	BUG_ON(!PageLocked(page));
-	BUG_ON(page->mapping->host != inode);
+	BUG_ON(page_file_mapping(page)->host != inode);
 	req->wb_offset  = offset;
 	req->wb_pgbase	= offset;
 	req->wb_bytes   = count;
@@ -363,7 +363,7 @@ void nfs_pageio_cond_complete(struct nfs_pageio_descriptor *desc, pgoff_t index)
  * nfs_scan_list - Scan a list for matching requests
  * @nfsi: NFS inode
  * @dst: Destination list
- * @idx_start: lower bound of page->index to scan
+ * @idx_start: lower bound of page_file_index(page) to scan
  * @npages: idx_start + npages sets the upper bound to scan.
  * @tag: tag to scan for
  *
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 5a33a92..5cbae00 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -501,11 +501,11 @@ static const struct rpc_call_ops nfs_read_full_ops = {
 int nfs_readpage(struct file *file, struct page *page)
 {
 	struct nfs_open_context *ctx;
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_file_mapping(page)->host;
 	int		error;
 
 	dprintk("NFS: nfs_readpage (%p %ld@%lu)\n",
-		page, PAGE_CACHE_SIZE, page->index);
+		page, PAGE_CACHE_SIZE, page_file_index(page));
 	nfs_inc_stats(inode, NFSIOS_VFSREADPAGE);
 	nfs_add_stats(inode, NFSIOS_READPAGES, 1);
 
@@ -559,7 +559,7 @@ static int
 readpage_async_filler(void *data, struct page *page)
 {
 	struct nfs_readdesc *desc = (struct nfs_readdesc *)data;
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_file_mapping(page)->host;
 	struct nfs_page *new;
 	unsigned int len;
 	int error;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 03df228..109a970 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -123,7 +123,7 @@ static struct nfs_page *nfs_page_find_request_locked(struct page *page)
 
 static struct nfs_page *nfs_page_find_request(struct page *page)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_file_mapping(page)->host;
 	struct nfs_page *req = NULL;
 
 	spin_lock(&inode->i_lock);
@@ -135,16 +135,16 @@ static struct nfs_page *nfs_page_find_request(struct page *page)
 /* Adjust the file length if we're writing beyond the end */
 static void nfs_grow_file(struct page *page, unsigned int offset, unsigned int count)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_file_mapping(page)->host;
 	loff_t end, i_size;
 	pgoff_t end_index;
 
 	spin_lock(&inode->i_lock);
 	i_size = i_size_read(inode);
 	end_index = (i_size - 1) >> PAGE_CACHE_SHIFT;
-	if (i_size > 0 && page->index < end_index)
+	if (i_size > 0 && page_file_index(page) < end_index)
 		goto out;
-	end = ((loff_t)page->index << PAGE_CACHE_SHIFT) + ((loff_t)offset+count);
+	end = page_file_offset(page) + ((loff_t)offset+count);
 	if (i_size >= end)
 		goto out;
 	i_size_write(inode, end);
@@ -157,7 +157,7 @@ out:
 static void nfs_set_pageerror(struct page *page)
 {
 	SetPageError(page);
-	nfs_zap_mapping(page->mapping->host, page->mapping);
+	nfs_zap_mapping(page_file_mapping(page)->host, page_file_mapping(page));
 }
 
 /* We can set the PG_uptodate flag if we see that a write request
@@ -198,7 +198,7 @@ static int nfs_set_page_writeback(struct page *page)
 	int ret = test_set_page_writeback(page);
 
 	if (!ret) {
-		struct inode *inode = page->mapping->host;
+		struct inode *inode = page_file_mapping(page)->host;
 		struct nfs_server *nfss = NFS_SERVER(inode);
 
 		page_cache_get(page);
@@ -213,7 +213,7 @@ static int nfs_set_page_writeback(struct page *page)
 
 static void nfs_end_page_writeback(struct page *page)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_file_mapping(page)->host;
 	struct nfs_server *nfss = NFS_SERVER(inode);
 
 	end_page_writeback(page);
@@ -224,7 +224,7 @@ static void nfs_end_page_writeback(struct page *page)
 
 static struct nfs_page *nfs_find_and_lock_request(struct page *page)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_file_mapping(page)->host;
 	struct nfs_page *req;
 	int ret;
 
@@ -282,12 +282,12 @@ out:
 
 static int nfs_do_writepage(struct page *page, struct writeback_control *wbc, struct nfs_pageio_descriptor *pgio)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_file_mapping(page)->host;
 
 	nfs_inc_stats(inode, NFSIOS_VFSWRITEPAGE);
 	nfs_add_stats(inode, NFSIOS_WRITEPAGES, 1);
 
-	nfs_pageio_cond_complete(pgio, page->index);
+	nfs_pageio_cond_complete(pgio, page_file_index(page));
 	return nfs_page_async_flush(pgio, page);
 }
 
@@ -299,7 +299,7 @@ static int nfs_writepage_locked(struct page *page, struct writeback_control *wbc
 	struct nfs_pageio_descriptor pgio;
 	int err;
 
-	nfs_pageio_init_write(&pgio, page->mapping->host, wb_priority(wbc));
+	nfs_pageio_init_write(&pgio, page_file_mapping(page)->host, wb_priority(wbc));
 	err = nfs_do_writepage(page, wbc, &pgio);
 	nfs_pageio_complete(&pgio);
 	if (err < 0)
@@ -423,7 +423,7 @@ static void
 nfs_mark_request_dirty(struct nfs_page *req)
 {
 	__set_page_dirty_nobuffers(req->wb_page);
-	__mark_inode_dirty(req->wb_page->mapping->host, I_DIRTY_DATASYNC);
+	__mark_inode_dirty(page_file_mapping(req->wb_page)->host, I_DIRTY_DATASYNC);
 }
 
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
@@ -444,7 +444,8 @@ nfs_mark_request_commit(struct nfs_page *req)
 	nfsi->ncommit++;
 	spin_unlock(&inode->i_lock);
 	inc_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
-	inc_bdi_stat(req->wb_page->mapping->backing_dev_info, BDI_RECLAIMABLE);
+	inc_bdi_stat(page_file_mapping(req->wb_page)->backing_dev_info,
+			BDI_RECLAIMABLE);
 	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
 }
 
@@ -455,7 +456,7 @@ nfs_clear_request_commit(struct nfs_page *req)
 
 	if (test_and_clear_bit(PG_CLEAN, &(req)->wb_flags)) {
 		dec_zone_page_state(page, NR_UNSTABLE_NFS);
-		dec_bdi_stat(page->mapping->backing_dev_info, BDI_RECLAIMABLE);
+		dec_bdi_stat(page_file_mapping(page)->backing_dev_info, BDI_RECLAIMABLE);
 		return 1;
 	}
 	return 0;
@@ -516,7 +517,7 @@ nfs_need_commit(struct nfs_inode *nfsi)
  * nfs_scan_commit - Scan an inode for commit requests
  * @inode: NFS inode to scan
  * @dst: destination list
- * @idx_start: lower bound of page->index to scan.
+ * @idx_start: lower bound of page_file_index(page) to scan.
  * @npages: idx_start + npages sets the upper bound to scan.
  *
  * Moves requests from the inode's 'commit' request list.
@@ -636,7 +637,7 @@ out_err:
 static struct nfs_page * nfs_setup_write_request(struct nfs_open_context* ctx,
 		struct page *page, unsigned int offset, unsigned int bytes)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_file_mapping(page)->host;
 	struct nfs_page	*req;
 	int error;
 
@@ -693,7 +694,7 @@ int nfs_flush_incompatible(struct file *file, struct page *page)
 		nfs_release_request(req);
 		if (!do_flush)
 			return 0;
-		status = nfs_wb_page(page->mapping->host, page);
+		status = nfs_wb_page(page_file_mapping(page)->host, page);
 	} while (status == 0);
 	return status;
 }
@@ -719,7 +720,7 @@ int nfs_updatepage(struct file *file, struct page *page,
 		unsigned int offset, unsigned int count)
 {
 	struct nfs_open_context *ctx = nfs_file_open_context(file);
-	struct inode	*inode = page->mapping->host;
+	struct inode	*inode = page_file_mapping(page)->host;
 	int		status = 0;
 
 	nfs_inc_stats(inode, NFSIOS_VFSUPDATEPAGE);
@@ -727,7 +728,7 @@ int nfs_updatepage(struct file *file, struct page *page,
 	dprintk("NFS:       nfs_updatepage(%s/%s %d@%lld)\n",
 		file->f_path.dentry->d_parent->d_name.name,
 		file->f_path.dentry->d_name.name, count,
-		(long long)(page_offset(page) + offset));
+		(long long)(page_file_offset(page) + offset));
 
 	/* If we're not using byte range locks, and we know the page
 	 * is up to date, it may be more efficient to extend the write
@@ -1009,7 +1010,7 @@ static void nfs_writeback_release_partial(void *calldata)
 	}
 
 	if (nfs_write_need_commit(data)) {
-		struct inode *inode = page->mapping->host;
+		struct inode *inode = page_file_mapping(page)->host;
 
 		spin_lock(&inode->i_lock);
 		if (test_bit(PG_NEED_RESCHED, &req->wb_flags)) {
@@ -1307,7 +1308,7 @@ nfs_commit_list(struct inode *inode, struct list_head *head, int how)
 		nfs_list_remove_request(req);
 		nfs_mark_request_commit(req);
 		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
-		dec_bdi_stat(req->wb_page->mapping->backing_dev_info,
+		dec_bdi_stat(page_file_mapping(req->wb_page)->backing_dev_info,
 				BDI_RECLAIMABLE);
 		nfs_clear_page_tag_locked(req);
 	}
@@ -1508,7 +1509,7 @@ int nfs_wb_page_cancel(struct inode *inode, struct page *page)
  */
 int nfs_wb_page(struct inode *inode, struct page *page)
 {
-	loff_t range_start = page_offset(page);
+	loff_t range_start = page_file_offset(page);
 	loff_t range_end = range_start + (loff_t)(PAGE_CACHE_SIZE - 1);
 	struct writeback_control wbc = {
 		.sync_mode = WB_SYNC_ALL,
-- 
1.7.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
