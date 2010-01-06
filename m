Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37074 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932232Ab0AFSiO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jan 2010 13:38:14 -0500
Subject: Re: [PATCH] improve the performance of large sequential write NFS
 workloads
From: Peter Zijlstra <peterz@infradead.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>,
        Steve Rago <sar@nec-labs.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "jens.axboe" <jens.axboe@oracle.com>,
        Peter Staubach <staubach@redhat.com>,
        Arjan van de Ven <arjan@infradead.org>, Ingo Molnar <mingo@elte.hu>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
In-Reply-To: <1262802387.4251.117.camel@localhost>
References: <20091222015907.GA6223@localhost>
	 <1261578107.2606.11.camel@localhost> <20091223180551.GD3159@quack.suse.cz>
	 <1261595574.6775.2.camel@localhost> <20091224025228.GA12477@localhost>
	 <1261656281.3596.1.camel@localhost> <20091225055617.GA8595@localhost>
	 <1262190168.7332.6.camel@localhost> <20091231050441.GB19627@localhost>
	 <1262286828.8151.113.camel@localhost>  <20100106030346.GA15962@localhost>
	 <1262796962.4251.91.camel@localhost>  <1262802387.4251.117.camel@localhost>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 06 Jan 2010 19:37:20 +0100
Message-ID: <1262803040.4049.62.camel@laptop>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-01-06 at 13:26 -0500, Trond Myklebust wrote:
> OK. It looks as if the only key to finding out how many unstable writes
> we have is to use global_page_state(NR_UNSTABLE_NFS), so we can't
> specifically target our own backing-dev. 

Would be a simple matter of splitting BDI_UNSTABLE out from
BDI_RECLAIMABLE, no?

Something like

---
 fs/nfs/write.c              |    6 +++---
 include/linux/backing-dev.h |    3 ++-
 mm/backing-dev.c            |    6 ++++--
 mm/filemap.c                |    2 +-
 mm/page-writeback.c         |   16 ++++++++++------
 mm/truncate.c               |    2 +-
 6 files changed, 21 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index d171696..7ba56f8 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -440,7 +440,7 @@ nfs_mark_request_commit(struct nfs_page *req)
 			NFS_PAGE_TAG_COMMIT);
 	spin_unlock(&inode->i_lock);
 	inc_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
-	inc_bdi_stat(req->wb_page->mapping->backing_dev_info, BDI_RECLAIMABLE);
+	inc_bdi_stat(req->wb_page->mapping->backing_dev_info, BDI_UNSTABLE);
 	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
 }
 
@@ -451,7 +451,7 @@ nfs_clear_request_commit(struct nfs_page *req)
 
 	if (test_and_clear_bit(PG_CLEAN, &(req)->wb_flags)) {
 		dec_zone_page_state(page, NR_UNSTABLE_NFS);
-		dec_bdi_stat(page->mapping->backing_dev_info, BDI_RECLAIMABLE);
+		dec_bdi_stat(page->mapping->backing_dev_info, BDI_UNSTABLE);
 		return 1;
 	}
 	return 0;
@@ -1322,7 +1322,7 @@ nfs_commit_list(struct inode *inode, struct list_head *head, int how)
 		nfs_mark_request_commit(req);
 		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
 		dec_bdi_stat(req->wb_page->mapping->backing_dev_info,
-				BDI_RECLAIMABLE);
+				BDI_UNSTABLE);
 		nfs_clear_page_tag_locked(req);
 	}
 	return -ENOMEM;
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index fcbc26a..1ef1e5c 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -36,7 +36,8 @@ enum bdi_state {
 typedef int (congested_fn)(void *, int);
 
 enum bdi_stat_item {
-	BDI_RECLAIMABLE,
+	BDI_DIRTY,
+	DBI_UNSTABLE,
 	BDI_WRITEBACK,
 	NR_BDI_STAT_ITEMS
 };
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 0e8ca03..88f3655 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -88,7 +88,8 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 #define K(x) ((x) << (PAGE_SHIFT - 10))
 	seq_printf(m,
 		   "BdiWriteback:     %8lu kB\n"
-		   "BdiReclaimable:   %8lu kB\n"
+		   "BdiDirty:         %8lu kB\n"
+		   "BdiUnstable:      %8lu kB\n"
 		   "BdiDirtyThresh:   %8lu kB\n"
 		   "DirtyThresh:      %8lu kB\n"
 		   "BackgroundThresh: %8lu kB\n"
@@ -102,7 +103,8 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 		   "wb_list:          %8u\n"
 		   "wb_cnt:           %8u\n",
 		   (unsigned long) K(bdi_stat(bdi, BDI_WRITEBACK)),
-		   (unsigned long) K(bdi_stat(bdi, BDI_RECLAIMABLE)),
+		   (unsigned long) K(bdi_stat(bdi, BDI_DIRTY)),
+		   (unsigned long) K(bdi_stat(bdi, BDI_UNSTABLE)),
 		   K(bdi_thresh), K(dirty_thresh),
 		   K(background_thresh), nr_wb, nr_dirty, nr_io, nr_more_io,
 		   !list_empty(&bdi->bdi_list), bdi->state, bdi->wb_mask,
diff --git a/mm/filemap.c b/mm/filemap.c
index 96ac6b0..458387d 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -136,7 +136,7 @@ void __remove_from_page_cache(struct page *page)
 	 */
 	if (PageDirty(page) && mapping_cap_account_dirty(mapping)) {
 		dec_zone_page_state(page, NR_FILE_DIRTY);
-		dec_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
+		dec_bdi_stat(mapping->backing_dev_info, BDI_DIRTY);
 	}
 }
 
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 0b19943..b1d31be 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -272,7 +272,8 @@ static void clip_bdi_dirty_limit(struct backing_dev_info *bdi,
 	else
 		avail_dirty = 0;
 
-	avail_dirty += bdi_stat(bdi, BDI_RECLAIMABLE) +
+	avail_dirty += bdi_stat(bdi, BDI_DIRTY) +
+		bdi_stat(bdi, BDI_UNSTABLE) +
 		bdi_stat(bdi, BDI_WRITEBACK);
 
 	*pbdi_dirty = min(*pbdi_dirty, avail_dirty);
@@ -509,7 +510,8 @@ static void balance_dirty_pages(struct address_space *mapping,
 					global_page_state(NR_UNSTABLE_NFS);
 		nr_writeback = global_page_state(NR_WRITEBACK);
 
-		bdi_nr_reclaimable = bdi_stat(bdi, BDI_RECLAIMABLE);
+		bdi_nr_reclaimable = bdi_stat(bdi, BDI_DIRTY) + 
+				     bdi_stat(bdi, BDI_UNSTABLE);
 		bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
 
 		if (bdi_nr_reclaimable + bdi_nr_writeback <= bdi_thresh)
@@ -554,10 +556,12 @@ static void balance_dirty_pages(struct address_space *mapping,
 		 * deltas.
 		 */
 		if (bdi_thresh < 2*bdi_stat_error(bdi)) {
-			bdi_nr_reclaimable = bdi_stat_sum(bdi, BDI_RECLAIMABLE);
+			bdi_nr_reclaimable = bdi_stat_sum(bdi, BDI_DIRTY) +
+					     bdi_stat_sum(bdi, DBI_UNSTABLE);
 			bdi_nr_writeback = bdi_stat_sum(bdi, BDI_WRITEBACK);
 		} else if (bdi_nr_reclaimable) {
-			bdi_nr_reclaimable = bdi_stat(bdi, BDI_RECLAIMABLE);
+			bdi_nr_reclaimable = bdi_stat(bdi, BDI_DIRTY) +
+					     bdi_stat(bdi, BDI_UNSTABLE);
 			bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
 		}
 
@@ -1079,7 +1083,7 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
 {
 	if (mapping_cap_account_dirty(mapping)) {
 		__inc_zone_page_state(page, NR_FILE_DIRTY);
-		__inc_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
+		__inc_bdi_stat(mapping->backing_dev_info, BDI_DIRTY);
 		task_dirty_inc(current);
 		task_io_account_write(PAGE_CACHE_SIZE);
 	}
@@ -1255,7 +1259,7 @@ int clear_page_dirty_for_io(struct page *page)
 		if (TestClearPageDirty(page)) {
 			dec_zone_page_state(page, NR_FILE_DIRTY);
 			dec_bdi_stat(mapping->backing_dev_info,
-					BDI_RECLAIMABLE);
+					BDI_DIRTY);
 			return 1;
 		}
 		return 0;
diff --git a/mm/truncate.c b/mm/truncate.c
index 342deee..b0ce8fb 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -75,7 +75,7 @@ void cancel_dirty_page(struct page *page, unsigned int account_size)
 		if (mapping && mapping_cap_account_dirty(mapping)) {
 			dec_zone_page_state(page, NR_FILE_DIRTY);
 			dec_bdi_stat(mapping->backing_dev_info,
-					BDI_RECLAIMABLE);
+					BDI_DIRTY);
 			if (account_size)
 				task_io_account_cancelled_write(account_size);
 		}


