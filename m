Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6661 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932299Ab0AFTxi convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jan 2010 14:53:38 -0500
Subject: Re: [PATCH] improve the performance of large sequential write NFS
 workloads
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>,
        Steve Rago <sar@nec-labs.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "jens.axboe" <jens.axboe@oracle.com>,
        Peter Staubach <staubach@redhat.com>,
        Arjan van de Ven <arjan@infradead.org>, Ingo Molnar <mingo@elte.hu>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
In-Reply-To: <1262805667.4251.135.camel@localhost>
References: <20091222015907.GA6223@localhost>
	 <1261578107.2606.11.camel@localhost> <20091223180551.GD3159@quack.suse.cz>
	 <1261595574.6775.2.camel@localhost> <20091224025228.GA12477@localhost>
	 <1261656281.3596.1.camel@localhost> <20091225055617.GA8595@localhost>
	 <1262190168.7332.6.camel@localhost> <20091231050441.GB19627@localhost>
	 <1262286828.8151.113.camel@localhost>  <20100106030346.GA15962@localhost>
	 <1262796962.4251.91.camel@localhost>  <1262802387.4251.117.camel@localhost>
	 <1262803040.4049.62.camel@laptop>  <1262803927.4251.133.camel@localhost>
	 <1262804876.4049.66.camel@laptop>  <1262805667.4251.135.camel@localhost>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 06 Jan 2010 14:53:14 -0500
Message-ID: <1262807594.4251.155.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-01-06 at 14:21 -0500, Trond Myklebust wrote: 
> On Wed, 2010-01-06 at 20:07 +0100, Peter Zijlstra wrote: 
> > On Wed, 2010-01-06 at 13:52 -0500, Trond Myklebust wrote:
> > > On Wed, 2010-01-06 at 19:37 +0100, Peter Zijlstra wrote: 
> > > > On Wed, 2010-01-06 at 13:26 -0500, Trond Myklebust wrote:
> > > > > OK. It looks as if the only key to finding out how many unstable writes
> > > > > we have is to use global_page_state(NR_UNSTABLE_NFS), so we can't
> > > > > specifically target our own backing-dev. 
> > > > 
> > > > Would be a simple matter of splitting BDI_UNSTABLE out from
> > > > BDI_RECLAIMABLE, no?
> > > > 
> > > > Something like
> > > 
> > > OK. How about if we also add in a bdi->capabilities flag to tell that we
> > > might have BDI_UNSTABLE? That would allow us to avoid the potentially
> > > expensive extra calls to bdi_stat() and bdi_stat_sum() for the non-nfs
> > > case?
> > 
> > The bdi_stat_sum() in the error limit is basically the only such
> > expensive op, but I suspect we might hit that more than enough. So sure
> > that sounds like a plan.
> > 
> 
> This should apply on top of your patch....

...and finally, this should convert the previous NFS patch to use the
per-bdi accounting.

Cheers
  Trond

-------------------------------------------------------------------------------------- 
VM: Use per-bdi unstable accounting to improve use of wbc->force_commit

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
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

