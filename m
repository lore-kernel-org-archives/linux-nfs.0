From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] improve the performance of large sequential write NFS
 workloads
Date: Wed, 06 Jan 2010 11:56:02 -0500
Message-ID: <1262796962.4251.91.camel@localhost>
References: <20091222015907.GA6223@localhost>
	 <1261578107.2606.11.camel@localhost> <20091223180551.GD3159@quack.suse.cz>
	 <1261595574.6775.2.camel@localhost> <20091224025228.GA12477@localhost>
	 <1261656281.3596.1.camel@localhost> <20091225055617.GA8595@localhost>
	 <1262190168.7332.6.camel@localhost> <20091231050441.GB19627@localhost>
	 <1262286828.8151.113.camel@localhost>  <20100106030346.GA15962@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jan Kara <jack@suse.cz>, Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org>,
	Peter Zijlstra <peterz@infradead.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"jens.axboe" <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:55246 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932306Ab0AFQ5M convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jan 2010 11:57:12 -0500
In-Reply-To: <20100106030346.GA15962@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2010-01-06 at 11:03 +0800, Wu Fengguang wrote: 
> Trond,
> 
> On Fri, Jan 01, 2010 at 03:13:48AM +0800, Trond Myklebust wrote:
> > The above change improves on the existing code, but doesn't solve the
> > problem that write_inode() isn't a good match for COMMIT. We need to
> > wait for all the unstable WRITE rpc calls to return before we can know
> > whether or not a COMMIT is needed (some commercial servers never require
> > commit, even if the client requested an unstable write). That was the
> > other reason for the change.
> 
> Ah good to know that reason. However we cannot wait for ongoing WRITEs
> for unlimited time or pages, otherwise nr_unstable goes up and squeeze 
> nr_dirty and nr_writeback to zero, and stall the cp process for a long
> time, as demonstrated by the trace (more reasoning in previous email).

OK. I think we need a mechanism to allow balance_dirty_pages() to
communicate to the filesystem that it really is holding too many
unstable pages. Currently, all we do is say that 'your total is too
big', and then let the filesystem figure out what it needs to do.

So how about if we modify your heuristic to do something like this? It
applies on top of the previous patch.

Cheers
  Trond
--------------------------------------------------------------------------------------------------------- 
VM/NFS: The VM must tell the filesystem when to free reclaimable pages

From: Trond Myklebust <Trond.Myklebust@netapp.com>

balance_dirty_pages() should really tell the filesystem whether or not it
has an excess of actual dirty pages, or whether it would be more useful to
start freeing up the reclaimable pages.

Assume that if the number of dirty pages associated with this backing-dev
is less than 1/2 the number of reclaimable pages, then we should
concentrate on freeing up the latter.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/write.c              |    9 +++++++--
 include/linux/backing-dev.h |    6 ++++++
 mm/page-writeback.c         |    7 +++++--
 3 files changed, 18 insertions(+), 4 deletions(-)


diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 910be28..36113e6 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1420,8 +1420,10 @@ int nfs_commit_unstable_pages(struct address_space *mapping,
 	if (wbc->sync_mode != WB_SYNC_ALL &&
 	    radix_tree_tagged(&NFS_I(inode)->nfs_page_tree,
 		    NFS_PAGE_TAG_LOCKED)) {
-		mark_inode_unstable_pages(inode);
-		return 0;
+		if (wbc->bdi == NULL)
+			goto out_nocommit;
+		if (wbc->bdi->dirty_exceeded != BDI_RECLAIMABLE_EXCEEDED)
+			goto out_nocommit;
 	}
 	if (wbc->nonblocking)
 		flags = 0;
@@ -1429,6 +1431,9 @@ int nfs_commit_unstable_pages(struct address_space *mapping,
 	if (ret > 0)
 		ret = 0;
 	return ret;
+out_nocommit:
+	mark_inode_unstable_pages(inode);
+	return 0;
 }
 
 #else
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index fcbc26a..cd1645e 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -94,6 +94,12 @@ struct backing_dev_info {
 #endif
 };
 
+enum bdi_dirty_exceeded_state {
+	BDI_NO_DIRTY_EXCESS = 0,
+	BDI_DIRTY_EXCEEDED,
+	BDI_RECLAIMABLE_EXCEEDED,
+};
+
 int bdi_init(struct backing_dev_info *bdi);
 void bdi_destroy(struct backing_dev_info *bdi);
 
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 0b19943..0133c8f 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -524,8 +524,11 @@ static void balance_dirty_pages(struct address_space *mapping,
 				(background_thresh + dirty_thresh) / 2)
 			break;
 
-		if (!bdi->dirty_exceeded)
-			bdi->dirty_exceeded = 1;
+		if (bdi_nr_writeback > bdi_nr_reclaimable / 2) {
+			if (bdi->dirty_exceeded != BDI_DIRTY_EXCEEDED)
+				bdi->dirty_exceeded = BDI_DIRTY_EXCEEDED;
+		} else if (bdi->dirty_exceeded != BDI_RECLAIMABLE_EXCEEDED)
+				bdi->dirty_exceeded = BDI_RECLAIMABLE_EXCEEDED;
 
 		/* Note: nr_reclaimable denotes nr_dirty + nr_unstable.
 		 * Unstable writes are a feature of certain networked

