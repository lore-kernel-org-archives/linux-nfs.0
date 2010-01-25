From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 08/12] NFS: Simplify nfs_wb_page_cancel()
Date: Mon, 25 Jan 2010 17:15:45 -0500
Message-ID: <20100125221545.16750.36339.stgit@localhost.localdomain>
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
Received: from mx2.netapp.com ([216.240.18.37]:17544 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753545Ab0AYWjK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Jan 2010 17:39:10 -0500
In-Reply-To: <20100125221544.16750.70574.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In all cases we should be able to just remove the request and call
cancel_dirty_page().

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/write.c         |   39 +--------------------------------------
 include/linux/nfs_fs.h |    2 --
 2 files changed, 1 insertions(+), 40 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 2d78f08..53df027 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -539,19 +539,6 @@ static int nfs_wait_on_requests_locked(struct inode *inode, pgoff_t idx_start, u
 	return res;
 }
 
-static void nfs_cancel_commit_list(struct list_head *head)
-{
-	struct nfs_page *req;
-
-	while(!list_empty(head)) {
-		req = nfs_list_entry(head->next);
-		nfs_list_remove_request(req);
-		nfs_clear_request_commit(req);
-		nfs_inode_remove_request(req);
-		nfs_unlock_request(req);
-	}
-}
-
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 static int
 nfs_need_commit(struct nfs_inode *nfsi)
@@ -1484,13 +1471,6 @@ long nfs_sync_mapping_wait(struct address_space *mapping, struct writeback_contr
 		pages = nfs_scan_commit(inode, &head, idx_start, npages);
 		if (pages == 0)
 			break;
-		if (how & FLUSH_INVALIDATE) {
-			spin_unlock(&inode->i_lock);
-			nfs_cancel_commit_list(&head);
-			ret = pages;
-			spin_lock(&inode->i_lock);
-			continue;
-		}
 		pages += nfs_scan_commit(inode, &head, 0, 0);
 		spin_unlock(&inode->i_lock);
 		ret = nfs_commit_list(inode, &head, how);
@@ -1547,26 +1527,13 @@ int nfs_wb_nocommit(struct inode *inode)
 int nfs_wb_page_cancel(struct inode *inode, struct page *page)
 {
 	struct nfs_page *req;
-	loff_t range_start = page_offset(page);
-	loff_t range_end = range_start + (loff_t)(PAGE_CACHE_SIZE - 1);
-	struct writeback_control wbc = {
-		.bdi = page->mapping->backing_dev_info,
-		.sync_mode = WB_SYNC_ALL,
-		.nr_to_write = LONG_MAX,
-		.range_start = range_start,
-		.range_end = range_end,
-	};
 	int ret = 0;
 
 	BUG_ON(!PageLocked(page));
 	for (;;) {
 		req = nfs_page_find_request(page);
 		if (req == NULL)
-			goto out;
-		if (test_bit(PG_CLEAN, &req->wb_flags)) {
-			nfs_release_request(req);
 			break;
-		}
 		if (nfs_lock_request_dontget(req)) {
 			nfs_inode_remove_request(req);
 			/*
@@ -1579,12 +1546,8 @@ int nfs_wb_page_cancel(struct inode *inode, struct page *page)
 		}
 		ret = nfs_wait_on_request(req);
 		if (ret < 0)
-			goto out;
+			break;
 	}
-	if (!PagePrivate(page))
-		return 0;
-	ret = nfs_sync_mapping_wait(page->mapping, &wbc, FLUSH_INVALIDATE);
-out:
 	return ret;
 }
 
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 384ea3e..1eec414 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -34,8 +34,6 @@
 #define FLUSH_LOWPRI		8	/* low priority background flush */
 #define FLUSH_HIGHPRI		16	/* high priority memory reclaim flush */
 #define FLUSH_NOCOMMIT		32	/* Don't send the NFSv3/v4 COMMIT */
-#define FLUSH_INVALIDATE	64	/* Invalidate the page cache */
-#define FLUSH_NOWRITEPAGE	128	/* Don't call writepage() */
 
 #ifdef __KERNEL__
 

