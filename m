From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 1/6] VFS: Ensure that writeback_single_inode() commits
	unstable writes
Date: Fri, 8 Jan 2010 09:53:19 +0800
Message-ID: <20100108015319.GA9216@localhost>
References: <20100106205110.22547.85345.stgit@localhost.localdomain> <20100106205110.22547.17971.stgit@localhost.localdomain> <20100107021849.GC9475@localhost> <1262839082.2185.15.camel@localhost> <20100107145635.GB20300@localhost> <1262877022.3309.11.camel@localhost> <20100108011718.GA8228@localhost> <1262914651.2659.110.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>,
	Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"jens.axboe" <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:14994 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751970Ab0AHBxW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Jan 2010 20:53:22 -0500
In-Reply-To: <1262914651.2659.110.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 08, 2010 at 09:37:31AM +0800, Trond Myklebust wrote:
> On Fri, 2010-01-08 at 09:17 +0800, Wu Fengguang wrote: 
> > On Thu, Jan 07, 2010 at 11:10:22PM +0800, Trond Myklebust wrote:
> > > On Thu, 2010-01-07 at 22:56 +0800, Wu Fengguang wrote: 
> > > > On Thu, Jan 07, 2010 at 12:38:02PM +0800, Myklebust, Trond wrote:
> > > > 
> > > > > > > diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> > > > > > > index d171696..910be28 100644
> > > > > > > --- a/fs/nfs/write.c
> > > > > > > +++ b/fs/nfs/write.c
> > > > > > > @@ -441,7 +441,7 @@ nfs_mark_request_commit(struct nfs_page *req)
> > > > > > >     spin_unlock(&inode->i_lock);
> > > > > > >     inc_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
> > > > > > >     inc_bdi_stat(req->wb_page->mapping->backing_dev_info, BDI_RECLAIMABLE);
> > > > > > > -   __mark_inode_dirty(inode, I_DIRTY_DATASYNC);
> > > > > > > +   mark_inode_unstable_pages(inode);
> > > > > >
> > > > > > Then we shall mark I_DIRTY_DATASYNC on other places that extend i_size.
> > > > > 
> > > > > Why? The NFS client itself shouldn't ever set I_DIRTY_DATASYNC after
> > > > > this patch is applied. We won't ever need it.
> > > > > 
> > > > > If the VM or VFS is doing it, then they ought to be fixed: there is no
> > > > > reason to assume that all filesystems need to sync their inodes on
> > > > > i_size changes.
> > > > 
> > > > Sorry, one more question.
> > > > 
> > > > It seems to me that you are replacing
> > > > 
> > > >         I_DIRTY_DATASYNC => write_inode()
> > > > with
> > > >         I_UNSTABLE_PAGES => commit_unstable_pages()
> > > > 
> > > > Is that change for the sake of clarity? Or to fix some problem?
> > > > (This patch does fix some problems, but do they inherently require
> > > > the above change?)
> > > 
> > > As I said previously, the write_inode() call is done _before_ you sync
> > > the dirty pages to the server, whereas commit_unstable_pages() wants to
> > > be done _after_ syncing. So the two are not the same, and we cannot
> > > replace commit_unstable_pages() with write_inode().
> > 
> > This is the ordering:
> > 
> > 0       do_writepages()
> > 1       if (I_DIRTY_SYNC | I_DIRTY_DATASYNC)
> > 2               write_inode()
> > 3       if (wait)
> > 4               filemap_fdatawait()
> > 5       if (I_UNSTABLE_PAGES)
> > 6               commit_unstable_pages()
> > 
> > The page is synced to NFS server in line 0.
> > 
> > The only difference is write_inode() is called before filemap_fdatawait(),
> > while commit_unstable_pages() is called after it.
> > 
> > Note that filemap_fdatawait() will only be called on WB_SYNC_ALL, so I
> > still cannot understand the difference..
> 
> The difference is precisely that...

Thanks, I got it.

> In the case of WB_SYNC_ALL we want the call to filemap_fdatawait() to
> occur before we call commit_unstable_pages(), so that we know that all
> the in-flight write rpc calls are done before we ask that they be
> committed to stable storage.

That's good order for WB_SYNC_ALL. However this is optimizing a minor
case, and what I cared is WB_SYNC_NONE :)

> In the case of WB_SYNC_NONE, there is no wait, and so we are forced to
> play games with heuristics and/or add the force_commit_unstable flag
> because we don't wait for the dirty pages to be cleaned. I don't like
> this, but those are the semantics that we've defined for WB_SYNC_NONE.

For WB_SYNC_NONE we will now also wait for WRITE completion with the
combination of NFS_PAGE_TAG_LOCKED-based-bail-out and redirty_tail().
This is retry based, so less elegant.

But that's not the whole story. The
I_UNSTABLE_PAGES+commit_unstable_pages() scheme seems elegant for
WB_SYNC_ALL, however it may break the pipeline for big files in a
perfect loop:
        loop {
                WRITE 4MB
                COMMIT 4MB
        }
While the retry based WB_SYNC_ALL will keep back-off COMMITs because
do_writepages() keep submit new WRITEs. So its loop would be
        loop {
                WRITE 4MB
                <skip COMMIT>
                WRITE 4MB
                <skip COMMIT>
                WRITE 4MB
                <skip COMMIT>
                WRITE 4MB
                <skip COMMIT>
                ...
                <redirty_tail timeout>
                COMMIT 400MB
        }

That can be improved by lifting the writeback chunk size from 4MB to >=128MB.


Thanks,
Fengguang
