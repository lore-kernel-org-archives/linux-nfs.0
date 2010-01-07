From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 4/5] VM/NFS: The VM must tell the filesystem when to free
 reclaimable pages
Date: Thu, 07 Jan 2010 09:41:43 -0500
Message-ID: <20100107144143.17158.53629.stgit@localhost.localdomain>
References: <20100107144137.17158.53673.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>,
	Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"jens.axboe" <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:20685 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752430Ab0AGOol (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Jan 2010 09:44:41 -0500
In-Reply-To: <20100107144137.17158.53673.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

balance_dirty_pages() should really tell the filesystem whether or not it
has an excess of actual dirty pages, or whether it would be more useful to
start freeing up the unstable writes.

Assume that if the number of unstable writes is more than 1/2 the number of
reclaimable pages, then we should force NFS to free up the former.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Acked-by: Jan Kara <jack@suse.cz>
Acked-by: Peter Zijlstra <peterz@infradead.org>
---

 fs/nfs/write.c            |    2 +-
 include/linux/writeback.h |    5 +++++
 mm/page-writeback.c       |   12 ++++++++++--
 3 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 36549b1..43e47b4 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1417,7 +1417,7 @@ int nfs_commit_unstable_pages(struct address_space *mapping,
 	/* Don't commit yet if this is a non-blocking flush and there are
 	 * outstanding writes for this mapping.
 	 */
-	if (wbc->sync_mode != WB_SYNC_ALL &&
+	if (!wbc->force_commit_unstable && wbc->sync_mode != WB_SYNC_ALL &&
 	    radix_tree_tagged(&NFS_I(inode)->nfs_page_tree,
 		    NFS_PAGE_TAG_LOCKED)) {
 		mark_inode_unstable_pages(inode);
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 76e8903..8229139 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -62,6 +62,11 @@ struct writeback_control {
 	 * so we use a single control to update them
 	 */
 	unsigned no_nrwrite_index_update:1;
+	/*
+	 * The following is used by balance_dirty_pages() to
+	 * force NFS to commit unstable pages.
+	 */
+	unsigned force_commit_unstable:1;
 };
 
 /*
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index c06739b..6a0aec7 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -503,6 +503,7 @@ static void balance_dirty_pages(struct address_space *mapping,
 			.nr_to_write	= write_chunk,
 			.range_cyclic	= 1,
 		};
+		long bdi_nr_unstable = 0;
 
 		get_dirty_limits(&background_thresh, &dirty_thresh,
 				&bdi_thresh, bdi);
@@ -512,8 +513,10 @@ static void balance_dirty_pages(struct address_space *mapping,
 		nr_writeback = global_page_state(NR_WRITEBACK);
 
 		bdi_nr_reclaimable = bdi_stat(bdi, BDI_DIRTY);
-		if (bdi_cap_account_unstable(bdi))
-			bdi_nr_reclaimable += bdi_stat(bdi, BDI_UNSTABLE);
+		if (bdi_cap_account_unstable(bdi)) {
+			bdi_nr_unstable = bdi_stat(bdi, BDI_UNSTABLE);
+			bdi_nr_reclaimable += bdi_nr_unstable;
+		}
 		bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
 
 		if (bdi_nr_reclaimable + bdi_nr_writeback <= bdi_thresh)
@@ -541,6 +544,11 @@ static void balance_dirty_pages(struct address_space *mapping,
 		 * up.
 		 */
 		if (bdi_nr_reclaimable > bdi_thresh) {
+			wbc.force_commit_unstable = 0;
+			/* Force NFS to also free up unstable writes. */
+			if (bdi_nr_unstable > bdi_nr_reclaimable / 2)
+				wbc.force_commit_unstable = 1;
+
 			writeback_inodes_wbc(&wbc);
 			pages_written += write_chunk - wbc.nr_to_write;
 			get_dirty_limits(&background_thresh, &dirty_thresh,

