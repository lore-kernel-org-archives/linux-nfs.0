Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:12648 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932388Ab0AFS1b convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jan 2010 13:27:31 -0500
Subject: Re: [PATCH] improve the performance of large sequential write NFS
 workloads
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, Steve Rago <sar@nec-labs.com>,
        Peter Zijlstra <peterz@infradead.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "jens.axboe" <jens.axboe@oracle.com>,
        Peter Staubach <staubach@redhat.com>,
        Arjan van de Ven <arjan@infradead.org>, Ingo Molnar <mingo@elte.hu>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
In-Reply-To: <1262796962.4251.91.camel@localhost>
References: <20091222015907.GA6223@localhost>
	 <1261578107.2606.11.camel@localhost> <20091223180551.GD3159@quack.suse.cz>
	 <1261595574.6775.2.camel@localhost> <20091224025228.GA12477@localhost>
	 <1261656281.3596.1.camel@localhost> <20091225055617.GA8595@localhost>
	 <1262190168.7332.6.camel@localhost> <20091231050441.GB19627@localhost>
	 <1262286828.8151.113.camel@localhost>  <20100106030346.GA15962@localhost>
	 <1262796962.4251.91.camel@localhost>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 06 Jan 2010 13:26:27 -0500
Message-ID: <1262802387.4251.117.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-01-06 at 11:56 -0500, Trond Myklebust wrote: 
> On Wed, 2010-01-06 at 11:03 +0800, Wu Fengguang wrote: 
> > Trond,
> > 
> > On Fri, Jan 01, 2010 at 03:13:48AM +0800, Trond Myklebust wrote:
> > > The above change improves on the existing code, but doesn't solve the
> > > problem that write_inode() isn't a good match for COMMIT. We need to
> > > wait for all the unstable WRITE rpc calls to return before we can know
> > > whether or not a COMMIT is needed (some commercial servers never require
> > > commit, even if the client requested an unstable write). That was the
> > > other reason for the change.
> > 
> > Ah good to know that reason. However we cannot wait for ongoing WRITEs
> > for unlimited time or pages, otherwise nr_unstable goes up and squeeze 
> > nr_dirty and nr_writeback to zero, and stall the cp process for a long
> > time, as demonstrated by the trace (more reasoning in previous email).
> 
> OK. I think we need a mechanism to allow balance_dirty_pages() to
> communicate to the filesystem that it really is holding too many
> unstable pages. Currently, all we do is say that 'your total is too
> big', and then let the filesystem figure out what it needs to do.
> 
> So how about if we modify your heuristic to do something like this? It
> applies on top of the previous patch.

Gah! I misread the definitions of bdi_nr_reclaimable and
bdi_nr_writeback. Please ignore the previous patch.

OK. It looks as if the only key to finding out how many unstable writes
we have is to use global_page_state(NR_UNSTABLE_NFS), so we can't
specifically target our own backing-dev.

Also, on reflection, I think it might be more helpful to use the
writeback control to signal when we want to force a commit. That makes
it a more general mechanism.

There is one thing that we might still want to do here. Currently we do
not update wbc->nr_to_write inside nfs_commit_unstable_pages(), which
again means that we don't update 'pages_written' if the only effect of
the writeback_inodes_wbc() was to commit pages. Perhaps it might not be
a bad idea to do this (but that should be in a separate patch)...

Cheers
  Trond
------------------------------------------------------------------------------------- 
VM/NFS: The VM must tell the filesystem when to free reclaimable pages

From: Trond Myklebust <Trond.Myklebust@netapp.com>

balance_dirty_pages() should really tell the filesystem whether or not it
has an excess of actual dirty pages, or whether it would be more useful to
start freeing up the unstable writes.

Assume that if the number of unstable writes is more than 1/2 the number of
reclaimable pages, then we should force NFS to free up the former.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/write.c            |    2 +-
 include/linux/writeback.h |    5 +++++
 mm/page-writeback.c       |    9 ++++++++-
 3 files changed, 14 insertions(+), 2 deletions(-)


diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 910be28..ee3daf4 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1417,7 +1417,7 @@ int nfs_commit_unstable_pages(struct address_space *mapping,
 	/* Don't commit yet if this is a non-blocking flush and there are
 	 * outstanding writes for this mapping.
 	 */
-	if (wbc->sync_mode != WB_SYNC_ALL &&
+	if (!wbc->force_commit && wbc->sync_mode != WB_SYNC_ALL &&
 	    radix_tree_tagged(&NFS_I(inode)->nfs_page_tree,
 		    NFS_PAGE_TAG_LOCKED)) {
 		mark_inode_unstable_pages(inode);
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 76e8903..3fd5c3e 100644
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
+	unsigned force_commit:1;
 };
 
 /*
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 0b19943..ede5356 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -485,6 +485,7 @@ static void balance_dirty_pages(struct address_space *mapping,
 {
 	long nr_reclaimable, bdi_nr_reclaimable;
 	long nr_writeback, bdi_nr_writeback;
+	long nr_unstable_nfs;
 	unsigned long background_thresh;
 	unsigned long dirty_thresh;
 	unsigned long bdi_thresh;
@@ -505,8 +506,9 @@ static void balance_dirty_pages(struct address_space *mapping,
 		get_dirty_limits(&background_thresh, &dirty_thresh,
 				&bdi_thresh, bdi);
 
+		nr_unstable_nfs = global_page_state(NR_UNSTABLE_NFS);
 		nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
-					global_page_state(NR_UNSTABLE_NFS);
+					nr_unstable_nfs;
 		nr_writeback = global_page_state(NR_WRITEBACK);
 
 		bdi_nr_reclaimable = bdi_stat(bdi, BDI_RECLAIMABLE);
@@ -537,6 +539,11 @@ static void balance_dirty_pages(struct address_space *mapping,
 		 * up.
 		 */
 		if (bdi_nr_reclaimable > bdi_thresh) {
+			wbc.force_commit = 0;
+			/* Force NFS to also free up unstable writes. */
+			if (nr_unstable_nfs > nr_reclaimable / 2)
+				wbc.force_commit = 1;
+
 			writeback_inodes_wbc(&wbc);
 			pages_written += write_chunk - wbc.nr_to_write;
 			get_dirty_limits(&background_thresh, &dirty_thresh,

