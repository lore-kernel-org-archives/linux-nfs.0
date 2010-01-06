From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] improve the performance of large sequential write NFS
 workloads
Date: Wed, 06 Jan 2010 14:21:07 -0500
Message-ID: <1262805667.4251.135.camel@localhost>
References: <20091222015907.GA6223@localhost>
	 <1261578107.2606.11.camel@localhost> <20091223180551.GD3159@quack.suse.cz>
	 <1261595574.6775.2.camel@localhost> <20091224025228.GA12477@localhost>
	 <1261656281.3596.1.camel@localhost> <20091225055617.GA8595@localhost>
	 <1262190168.7332.6.camel@localhost> <20091231050441.GB19627@localhost>
	 <1262286828.8151.113.camel@localhost>  <20100106030346.GA15962@localhost>
	 <1262796962.4251.91.camel@localhost>  <1262802387.4251.117.camel@localhost>
	 <1262803040.4049.62.camel@laptop>  <1262803927.4251.133.camel@localhost>
	 <1262804876.4049.66.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>,
	Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"jens.axboe" <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:21484 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755997Ab0AFTWB convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jan 2010 14:22:01 -0500
In-Reply-To: <1262804876.4049.66.camel@laptop>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2010-01-06 at 20:07 +0100, Peter Zijlstra wrote: 
> On Wed, 2010-01-06 at 13:52 -0500, Trond Myklebust wrote:
> > On Wed, 2010-01-06 at 19:37 +0100, Peter Zijlstra wrote: 
> > > On Wed, 2010-01-06 at 13:26 -0500, Trond Myklebust wrote:
> > > > OK. It looks as if the only key to finding out how many unstable writes
> > > > we have is to use global_page_state(NR_UNSTABLE_NFS), so we can't
> > > > specifically target our own backing-dev. 
> > > 
> > > Would be a simple matter of splitting BDI_UNSTABLE out from
> > > BDI_RECLAIMABLE, no?
> > > 
> > > Something like
> > 
> > OK. How about if we also add in a bdi->capabilities flag to tell that we
> > might have BDI_UNSTABLE? That would allow us to avoid the potentially
> > expensive extra calls to bdi_stat() and bdi_stat_sum() for the non-nfs
> > case?
> 
> The bdi_stat_sum() in the error limit is basically the only such
> expensive op, but I suspect we might hit that more than enough. So sure
> that sounds like a plan.
> 

This should apply on top of your patch....

Cheers
  Trond
------------------------------------------------------------------------------------------------ 
VM: Don't call bdi_stat(BDI_UNSTABLE) on non-nfs backing-devices

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Speeds up the accounting in balance_dirty_pages() for non-nfs devices.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/client.c             |    1 +
 include/linux/backing-dev.h |    6 ++++++
 mm/page-writeback.c         |   16 +++++++++++-----
 3 files changed, 18 insertions(+), 5 deletions(-)


diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index ee77713..d0b060a 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -890,6 +890,7 @@ static void nfs_server_set_fsinfo(struct nfs_server *server, struct nfs_fsinfo *
 
 	server->backing_dev_info.name = "nfs";
 	server->backing_dev_info.ra_pages = server->rpages * NFS_MAX_READAHEAD;
+	server->backing_dev_info.capabilities |= BDI_CAP_ACCT_UNSTABLE;
 
 	if (server->wsize > max_rpc_payload)
 		server->wsize = max_rpc_payload;
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 42c3e2a..8b45166 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -232,6 +232,7 @@ int bdi_set_max_ratio(struct backing_dev_info *bdi, unsigned int max_ratio);
 #define BDI_CAP_EXEC_MAP	0x00000040
 #define BDI_CAP_NO_ACCT_WB	0x00000080
 #define BDI_CAP_SWAP_BACKED	0x00000100
+#define BDI_CAP_ACCT_UNSTABLE	0x00000200
 
 #define BDI_CAP_VMFLAGS \
 	(BDI_CAP_READ_MAP | BDI_CAP_WRITE_MAP | BDI_CAP_EXEC_MAP)
@@ -311,6 +312,11 @@ static inline bool bdi_cap_flush_forker(struct backing_dev_info *bdi)
 	return bdi == &default_backing_dev_info;
 }
 
+static inline bool bdi_cap_account_unstable(struct backing_dev_info *bdi)
+{
+	return bdi->capabilities & BDI_CAP_ACCT_UNSTABLE;
+}
+
 static inline bool mapping_cap_writeback_dirty(struct address_space *mapping)
 {
 	return bdi_cap_writeback_dirty(mapping->backing_dev_info);
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index aa26b0f..d90a0db 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -273,8 +273,9 @@ static void clip_bdi_dirty_limit(struct backing_dev_info *bdi,
 		avail_dirty = 0;
 
 	avail_dirty += bdi_stat(bdi, BDI_DIRTY) +
-		bdi_stat(bdi, BDI_UNSTABLE) +
 		bdi_stat(bdi, BDI_WRITEBACK);
+	if (bdi_cap_account_unstable(bdi))
+		avail_dirty += bdi_stat(bdi, BDI_UNSTABLE);
 
 	*pbdi_dirty = min(*pbdi_dirty, avail_dirty);
 }
@@ -512,8 +513,9 @@ static void balance_dirty_pages(struct address_space *mapping,
 					nr_unstable_nfs;
 		nr_writeback = global_page_state(NR_WRITEBACK);
 
-		bdi_nr_reclaimable = bdi_stat(bdi, BDI_DIRTY) +
-				     bdi_stat(bdi, BDI_UNSTABLE);
+		bdi_nr_reclaimable = bdi_stat(bdi, BDI_DIRTY);
+		if (bdi_cap_account_unstable(bdi))
+			bdi_nr_reclaimable += bdi_stat(bdi, BDI_UNSTABLE);
 		bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
 
 		if (bdi_nr_reclaimable + bdi_nr_writeback <= bdi_thresh)
@@ -563,11 +565,15 @@ static void balance_dirty_pages(struct address_space *mapping,
 		 * deltas.
 		 */
 		if (bdi_thresh < 2*bdi_stat_error(bdi)) {
-			bdi_nr_reclaimable = bdi_stat_sum(bdi, BDI_DIRTY) +
+			bdi_nr_reclaimable = bdi_stat_sum(bdi, BDI_DIRTY);
+			if (bdi_cap_account_unstable(bdi))
+				bdi_nr_reclaimable +=
 					     bdi_stat_sum(bdi, BDI_UNSTABLE);
 			bdi_nr_writeback = bdi_stat_sum(bdi, BDI_WRITEBACK);
 		} else if (bdi_nr_reclaimable) {
-			bdi_nr_reclaimable = bdi_stat(bdi, BDI_DIRTY) +
+			bdi_nr_reclaimable = bdi_stat(bdi, BDI_DIRTY);
+			if (bdi_cap_account_unstable(bdi))
+				bdi_nr_reclaimable +=
 					     bdi_stat(bdi, BDI_UNSTABLE);
 			bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
 		}

