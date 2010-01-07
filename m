From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 1/6] VFS: Ensure that writeback_single_inode() commits
	unstable writes
Date: Thu, 7 Jan 2010 22:56:35 +0800
Message-ID: <20100107145635.GB20300@localhost>
References: <20100106205110.22547.85345.stgit@localhost.localdomain> <20100106205110.22547.17971.stgit@localhost.localdomain> <20100107021849.GC9475@localhost> <1262839082.2185.15.camel@localhost>
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
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:50519 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752216Ab0AGO5I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Jan 2010 09:57:08 -0500
In-Reply-To: <1262839082.2185.15.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 07, 2010 at 12:38:02PM +0800, Myklebust, Trond wrote:

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

Sorry, one more question.

It seems to me that you are replacing

        I_DIRTY_DATASYNC => write_inode()
with
        I_UNSTABLE_PAGES => commit_unstable_pages()

Is that change for the sake of clarity? Or to fix some problem?
(This patch does fix some problems, but do they inherently require
the above change?)

Thanks,
Fengguang
