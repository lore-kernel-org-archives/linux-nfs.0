From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 2/6] VM/NFS: The VM must tell the filesystem when to
 free reclaimable pages
Date: Wed, 06 Jan 2010 23:49:23 -0500
Message-ID: <1262839763.2185.25.camel@localhost>
References: <20100106205110.22547.85345.stgit@localhost.localdomain>
	 <20100106205110.22547.81645.stgit@localhost.localdomain>
	 <20100107022903.GD9475@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
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
Received: from mx2.netapp.com ([216.240.18.37]:51312 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932535Ab0AGEtl convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jan 2010 23:49:41 -0500
In-Reply-To: <20100107022903.GD9475@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2010-01-07 at 10:29 +0800, Wu Fengguang wrote: 
> On Thu, Jan 07, 2010 at 04:51:10AM +0800, Trond Myklebust wrote:
> > balance_dirty_pages() should really tell the filesystem whether or not it
> > has an excess of actual dirty pages, or whether it would be more useful to
> > start freeing up the unstable writes.
> > 
> > Assume that if the number of unstable writes is more than 1/2 the number of
> > reclaimable pages, then we should force NFS to free up the former.
> > 
> > Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> > Acked-by: Jan Kara <jack@suse.cz>
> > ---
> > 
> >  fs/nfs/write.c            |    2 +-
> >  include/linux/writeback.h |    5 +++++
> >  mm/page-writeback.c       |    9 ++++++++-
> >  3 files changed, 14 insertions(+), 2 deletions(-)
> > 
> > diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> > index 910be28..ee3daf4 100644
> > --- a/fs/nfs/write.c
> > +++ b/fs/nfs/write.c
> > @@ -1417,7 +1417,7 @@ int nfs_commit_unstable_pages(struct address_space *mapping,
> >  	/* Don't commit yet if this is a non-blocking flush and there are
> >  	 * outstanding writes for this mapping.
> >  	 */
> > -	if (wbc->sync_mode != WB_SYNC_ALL &&
> > +	if (!wbc->force_commit && wbc->sync_mode != WB_SYNC_ALL &&
> >  	    radix_tree_tagged(&NFS_I(inode)->nfs_page_tree,
> >  		    NFS_PAGE_TAG_LOCKED)) {
> >  		mark_inode_unstable_pages(inode);
> > diff --git a/include/linux/writeback.h b/include/linux/writeback.h
> > index 76e8903..3fd5c3e 100644
> > --- a/include/linux/writeback.h
> > +++ b/include/linux/writeback.h
> > @@ -62,6 +62,11 @@ struct writeback_control {
> >  	 * so we use a single control to update them
> >  	 */
> >  	unsigned no_nrwrite_index_update:1;
> > +	/*
> > +	 * The following is used by balance_dirty_pages() to
> > +	 * force NFS to commit unstable pages.
> > +	 */
> 
> In fact it may be too late to force commit at balance_dirty_pages()
> time: commit takes time and the application has already been blocked.
> 
> If not convenient for now, I can make the change -- I'll remove the
> writeback_inodes_wbc() call altogether from balance_dirty_pages().

You could always set the 'for_background' flag instead. 

> > +	unsigned force_commit:1;
> >  };
> 
> nfs_commit may be a more newbie friendly name?

We could possibly rename it to something like 'force_nfs_commit', but
the comment above the declaration should really be sufficient.

Trond
