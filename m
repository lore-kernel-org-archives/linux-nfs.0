Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:43027 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756048Ab0AGEsX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Jan 2010 23:48:23 -0500
Date: Thu, 7 Jan 2010 12:48:17 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>,
        Steve Rago <sar@nec-labs.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "jens.axboe" <jens.axboe@oracle.com>,
        Peter Staubach <staubach@redhat.com>,
        Arjan van de Ven <arjan@infradead.org>, Ingo Molnar <mingo@elte.hu>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH 1/6] VFS: Ensure that writeback_single_inode() commits
	unstable writes
Message-ID: <20100107044817.GA18996@localhost>
References: <20100106205110.22547.85345.stgit@localhost.localdomain> <20100106205110.22547.17971.stgit@localhost.localdomain> <20100107021849.GC9475@localhost> <1262839082.2185.15.camel@localhost>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1262839082.2185.15.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jan 07, 2010 at 12:38:02PM +0800, Myklebust, Trond wrote:
> On Thu, 2010-01-07 at 10:18 +0800, Wu Fengguang wrote:
> > On Thu, Jan 07, 2010 at 04:51:10AM +0800, Trond Myklebust wrote:
> > > @@ -533,6 +556,12 @@ select_queue:
> > >                             inode->i_state |= I_DIRTY_PAGES;
> > >                             redirty_tail(inode);
> > >                     }
> > > +           } else if (inode->i_state & I_UNSTABLE_PAGES) {
> > > +                   /*
> > > +                    * The inode has got yet more unstable pages to
> > > +                    * commit. Requeue on b_more_io
> > > +                    */
> > > +                   requeue_io(inode);
> >
> > This risks "busy retrying" inodes with unstable pages, when
> >
> > - nfs_commit_unstable_pages() don't think it's time to commit
> > - NFS server somehow response slowly
> >
> > The workaround is to use redirty_tail() for now. But that risks delay
> > the COMMIT for up to 30s, which obviously might stuck applications in
> > balance_dirty_pages() for too long.
> >
> > I have a patch to shorten the retry time to 1s (or other constant)
> > by introducing b_more_io_wait. It currently sits in my writeback queue
> > series whose main blocking issue is the constantly broken NFS pipeline..
> 
> 
> OK. Should I use redirty_tail() for the moment then, and assume you will
> fix when you introduce the new state?

OK, I'll change your redirty_tail() then :)

> > > diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> > > index d171696..910be28 100644
> > > --- a/fs/nfs/write.c
> > > +++ b/fs/nfs/write.c
> > > @@ -441,7 +441,7 @@ nfs_mark_request_commit(struct nfs_page *req)
> > >     spin_unlock(&inode->i_lock);
> > >     inc_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
> > >     inc_bdi_stat(req->wb_page->mapping->backing_dev_info, BDI_RECLAIMABLE);
> > > -   __mark_inode_dirty(inode, I_DIRTY_DATASYNC);
> > > +   mark_inode_unstable_pages(inode);
> >
> > Then we shall mark I_DIRTY_DATASYNC on other places that extend i_size.
> 
> Why? The NFS client itself shouldn't ever set I_DIRTY_DATASYNC after
> this patch is applied. We won't ever need it.
> 
> If the VM or VFS is doing it, then they ought to be fixed: there is no
> reason to assume that all filesystems need to sync their inodes on
> i_size changes.

Ah OK, I took it for certain..

> > > +   /* Don't commit yet if this is a non-blocking flush and there are
> > > +    * outstanding writes for this mapping.
> > > +    */
> > > +   if (wbc->sync_mode != WB_SYNC_ALL &&
> > > +       radix_tree_tagged(&NFS_I(inode)->nfs_page_tree,
> > > +               NFS_PAGE_TAG_LOCKED)) {
> > > +           mark_inode_unstable_pages(inode);
> > > +           return 0;
> > > +   }
> >
> > A dumb question: does NFS_PAGE_TAG_LOCKED means either flying COMMITs
> > or WRITEs? As an NFS newbie, I'm only confident on the COMMIT part :)
> 
> Both writebacks and commits will cause NFS_PAGE_TAG_LOCKED to be set, as
> will attempts to change the page contents. See the calls to
> nfs_set_page_tag_locked()...

Thanks for the tip!

> IOW: the above code will fail to trigger if there are outstanding WRITE
> RPC calls, or if there is a second process that happens to be writing to
> this inode's page cache...

IOW: for a busy "cp", the commit of inode may be delayed until
"nr_unstable > nr_dirty / 2"?  OK that's what we want.

Thanks,
Fengguang
