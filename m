From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/6] VM/NFS: The VM must tell the filesystem when to
	free reclaimable pages
Date: Thu, 7 Jan 2010 10:29:03 +0800
Message-ID: <20100107022903.GD9475@localhost>
References: <20100106205110.22547.85345.stgit@localhost.localdomain> <20100106205110.22547.81645.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>,
	Steve Rago <sar@nec-labs.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"jens.axboe" <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20100106205110.22547.81645.stgit@localhost.localdomain>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 07, 2010 at 04:51:10AM +0800, Trond Myklebust wrote:
> balance_dirty_pages() should really tell the filesystem whether or not it
> has an excess of actual dirty pages, or whether it would be more useful to
> start freeing up the unstable writes.
> 
> Assume that if the number of unstable writes is more than 1/2 the number of
> reclaimable pages, then we should force NFS to free up the former.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> Acked-by: Jan Kara <jack@suse.cz>
> ---
> 
>  fs/nfs/write.c            |    2 +-
>  include/linux/writeback.h |    5 +++++
>  mm/page-writeback.c       |    9 ++++++++-
>  3 files changed, 14 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 910be28..ee3daf4 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -1417,7 +1417,7 @@ int nfs_commit_unstable_pages(struct address_space *mapping,
>  	/* Don't commit yet if this is a non-blocking flush and there are
>  	 * outstanding writes for this mapping.
>  	 */
> -	if (wbc->sync_mode != WB_SYNC_ALL &&
> +	if (!wbc->force_commit && wbc->sync_mode != WB_SYNC_ALL &&
>  	    radix_tree_tagged(&NFS_I(inode)->nfs_page_tree,
>  		    NFS_PAGE_TAG_LOCKED)) {
>  		mark_inode_unstable_pages(inode);
> diff --git a/include/linux/writeback.h b/include/linux/writeback.h
> index 76e8903..3fd5c3e 100644
> --- a/include/linux/writeback.h
> +++ b/include/linux/writeback.h
> @@ -62,6 +62,11 @@ struct writeback_control {
>  	 * so we use a single control to update them
>  	 */
>  	unsigned no_nrwrite_index_update:1;
> +	/*
> +	 * The following is used by balance_dirty_pages() to
> +	 * force NFS to commit unstable pages.
> +	 */

In fact it may be too late to force commit at balance_dirty_pages()
time: commit takes time and the application has already been blocked.

If not convenient for now, I can make the change -- I'll remove the
writeback_inodes_wbc() call altogether from balance_dirty_pages().

> +	unsigned force_commit:1;
>  };

nfs_commit may be a more newbie friendly name?

Thanks,
Fengguang

>  /*
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 0b19943..ede5356 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -485,6 +485,7 @@ static void balance_dirty_pages(struct address_space *mapping,
>  {
>  	long nr_reclaimable, bdi_nr_reclaimable;
>  	long nr_writeback, bdi_nr_writeback;
> +	long nr_unstable_nfs;
>  	unsigned long background_thresh;
>  	unsigned long dirty_thresh;
>  	unsigned long bdi_thresh;
> @@ -505,8 +506,9 @@ static void balance_dirty_pages(struct address_space *mapping,
>  		get_dirty_limits(&background_thresh, &dirty_thresh,
>  				&bdi_thresh, bdi);
>  
> +		nr_unstable_nfs = global_page_state(NR_UNSTABLE_NFS);
>  		nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
> -					global_page_state(NR_UNSTABLE_NFS);
> +					nr_unstable_nfs;
>  		nr_writeback = global_page_state(NR_WRITEBACK);
>  
>  		bdi_nr_reclaimable = bdi_stat(bdi, BDI_RECLAIMABLE);
> @@ -537,6 +539,11 @@ static void balance_dirty_pages(struct address_space *mapping,
>  		 * up.
>  		 */
>  		if (bdi_nr_reclaimable > bdi_thresh) {
> +			wbc.force_commit = 0;
> +			/* Force NFS to also free up unstable writes. */
> +			if (nr_unstable_nfs > nr_reclaimable / 2)
> +				wbc.force_commit = 1;
> +
>  			writeback_inodes_wbc(&wbc);
>  			pages_written += write_chunk - wbc.nr_to_write;
>  			get_dirty_limits(&background_thresh, &dirty_thresh,
> 
