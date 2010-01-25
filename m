From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 10/12] NFS: Simplify nfs_wb_page()
Date: Mon, 25 Jan 2010 17:15:45 -0500
Message-ID: <20100125221545.16750.19154.stgit@localhost.localdomain>
References: <20100125221544.16750.70574.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Wu Fengguang <fengguang.wu@intel.com>,
	Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>,
	Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org>,
	Jens Axboe <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>, linux-fsdevel@vger.kernel.org,
	Christoph Hellwig <hch@lst.de>,
	Al Viro <viro@ZenIV.linux.org.uk>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17535 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754260Ab0AYWjM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Jan 2010 17:39:12 -0500
In-Reply-To: <20100125221544.16750.70574.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/write.c         |  118 +++++++++---------------------------------------
 include/linux/nfs_fs.h |    1 
 2 files changed, 22 insertions(+), 97 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 747b40e..830613d 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -501,44 +501,6 @@ int nfs_reschedule_unstable_write(struct nfs_page *req)
 }
 #endif
 
-/*
- * Wait for a request to complete.
- *
- * Interruptible by fatal signals only.
- */
-static int nfs_wait_on_requests_locked(struct inode *inode, pgoff_t idx_start, unsigned int npages)
-{
-	struct nfs_inode *nfsi = NFS_I(inode);
-	struct nfs_page *req;
-	pgoff_t idx_end, next;
-	unsigned int		res = 0;
-	int			error;
-
-	if (npages == 0)
-		idx_end = ~0;
-	else
-		idx_end = idx_start + npages - 1;
-
-	next = idx_start;
-	while (radix_tree_gang_lookup_tag(&nfsi->nfs_page_tree, (void **)&req, next, 1, NFS_PAGE_TAG_LOCKED)) {
-		if (req->wb_index > idx_end)
-			break;
-
-		next = req->wb_index + 1;
-		BUG_ON(!NFS_WBACK_BUSY(req));
-
-		kref_get(&req->wb_kref);
-		spin_unlock(&inode->i_lock);
-		error = nfs_wait_on_request(req);
-		nfs_release_request(req);
-		spin_lock(&inode->i_lock);
-		if (error < 0)
-			return error;
-		res++;
-	}
-	return res;
-}
-
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 static int
 nfs_need_commit(struct nfs_inode *nfsi)
@@ -1437,46 +1399,6 @@ int nfs_write_inode(struct inode *inode, struct writeback_control *wbc)
 	return nfs_commit_unstable_pages(inode, wbc);
 }
 
-long nfs_sync_mapping_wait(struct address_space *mapping, struct writeback_control *wbc, int how)
-{
-	struct inode *inode = mapping->host;
-	pgoff_t idx_start, idx_end;
-	unsigned int npages = 0;
-	LIST_HEAD(head);
-	long pages, ret;
-
-	/* FIXME */
-	if (wbc->range_cyclic)
-		idx_start = 0;
-	else {
-		idx_start = wbc->range_start >> PAGE_CACHE_SHIFT;
-		idx_end = wbc->range_end >> PAGE_CACHE_SHIFT;
-		if (idx_end > idx_start) {
-			pgoff_t l_npages = 1 + idx_end - idx_start;
-			npages = l_npages;
-			if (sizeof(npages) != sizeof(l_npages) &&
-					(pgoff_t)npages != l_npages)
-				npages = 0;
-		}
-	}
-	spin_lock(&inode->i_lock);
-	do {
-		ret = nfs_wait_on_requests_locked(inode, idx_start, npages);
-		if (ret != 0)
-			continue;
-		pages = nfs_scan_commit(inode, &head, idx_start, npages);
-		if (pages == 0)
-			break;
-		pages += nfs_scan_commit(inode, &head, 0, 0);
-		spin_unlock(&inode->i_lock);
-		ret = nfs_commit_list(inode, &head, how);
-		spin_lock(&inode->i_lock);
-
-	} while (ret >= 0);
-	spin_unlock(&inode->i_lock);
-	return ret;
-}
-
 /*
  * flush the inode to disk.
  */
@@ -1524,45 +1446,49 @@ int nfs_wb_page_cancel(struct inode *inode, struct page *page)
 	return ret;
 }
 
-static int nfs_wb_page_priority(struct inode *inode, struct page *page,
-				int how)
+/*
+ * Write back all requests on one page - we do this before reading it.
+ */
+int nfs_wb_page(struct inode *inode, struct page *page)
 {
 	loff_t range_start = page_offset(page);
 	loff_t range_end = range_start + (loff_t)(PAGE_CACHE_SIZE - 1);
 	struct writeback_control wbc = {
-		.bdi = page->mapping->backing_dev_info,
 		.sync_mode = WB_SYNC_ALL,
-		.nr_to_write = LONG_MAX,
+		.nr_to_write = 0,
 		.range_start = range_start,
 		.range_end = range_end,
 	};
+	struct nfs_page *req;
+	int need_commit;
 	int ret;
 
-	do {
+	while(PagePrivate(page)) {
 		if (clear_page_dirty_for_io(page)) {
 			ret = nfs_writepage_locked(page, &wbc);
 			if (ret < 0)
 				goto out_error;
-		} else if (!PagePrivate(page))
+		}
+		req = nfs_find_and_lock_request(page);
+		if (!req)
 			break;
-		ret = nfs_sync_mapping_wait(page->mapping, &wbc, how);
-		if (ret < 0)
+		if (IS_ERR(req)) {
+			ret = PTR_ERR(req);
 			goto out_error;
-	} while (PagePrivate(page));
+		}
+		need_commit = test_bit(PG_CLEAN, &req->wb_flags);
+		nfs_clear_page_tag_locked(req);
+		if (need_commit) {
+			ret = nfs_commit_inode(inode, FLUSH_SYNC);
+			if (ret < 0)
+				goto out_error;
+		}
+	}
 	return 0;
 out_error:
-	__mark_inode_dirty(inode, I_DIRTY_PAGES);
 	return ret;
 }
 
-/*
- * Write back all requests on one page - we do this before reading it.
- */
-int nfs_wb_page(struct inode *inode, struct page* page)
-{
-	return nfs_wb_page_priority(inode, page, FLUSH_STABLE);
-}
-
 #ifdef CONFIG_MIGRATION
 int nfs_migrate_page(struct address_space *mapping, struct page *newpage,
 		struct page *page)
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index c536caf..6ee74c5 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -474,7 +474,6 @@ extern int nfs_writeback_done(struct rpc_task *, struct nfs_write_data *);
  * Try to write back everything synchronously (but check the
  * return value!)
  */
-extern long nfs_sync_mapping_wait(struct address_space *, struct writeback_control *, int);
 extern int nfs_wb_all(struct inode *inode);
 extern int nfs_wb_nocommit(struct inode *inode);
 extern int nfs_wb_page(struct inode *inode, struct page* page);

