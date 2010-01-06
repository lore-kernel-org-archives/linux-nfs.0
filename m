From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 5/6] VM: Use per-bdi unstable accounting to improve use of
 wbc->force_commit
Date: Wed, 06 Jan 2010 15:51:10 -0500
Message-ID: <20100106205110.22547.32584.stgit@localhost.localdomain>
References: <20100106205110.22547.85345.stgit@localhost.localdomain>
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
Received: from mx2.netapp.com ([216.240.18.37]:46744 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932826Ab0AFU7c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Jan 2010 15:59:32 -0500
In-Reply-To: <20100106205110.22547.85345.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Acked-by: Jan Kara <jack@suse.cz>
---

 mm/page-writeback.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index d90a0db..c537543 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -487,7 +487,6 @@ static void balance_dirty_pages(struct address_space *mapping,
 {
 	long nr_reclaimable, bdi_nr_reclaimable;
 	long nr_writeback, bdi_nr_writeback;
-	long nr_unstable_nfs;
 	unsigned long background_thresh;
 	unsigned long dirty_thresh;
 	unsigned long bdi_thresh;
@@ -504,18 +503,20 @@ static void balance_dirty_pages(struct address_space *mapping,
 			.nr_to_write	= write_chunk,
 			.range_cyclic	= 1,
 		};
+		long bdi_nr_unstable = 0;
 
 		get_dirty_limits(&background_thresh, &dirty_thresh,
 				&bdi_thresh, bdi);
 
-		nr_unstable_nfs = global_page_state(NR_UNSTABLE_NFS);
 		nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
-					nr_unstable_nfs;
+					global_page_state(NR_UNSTABLE_NFS);
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
@@ -545,7 +546,7 @@ static void balance_dirty_pages(struct address_space *mapping,
 		if (bdi_nr_reclaimable > bdi_thresh) {
 			wbc.force_commit = 0;
 			/* Force NFS to also free up unstable writes. */
-			if (nr_unstable_nfs > nr_reclaimable / 2)
+			if (bdi_nr_unstable > bdi_nr_reclaimable / 2)
 				wbc.force_commit = 1;
 
 			writeback_inodes_wbc(&wbc);

