Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51079 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753864Ab0HSPLc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Aug 2010 11:11:32 -0400
Date: Thu, 19 Aug 2010 11:11:22 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Christoph Hellwig <hch@infradead.org>, fengguang.wu@gmail.com,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-mm@kvack.org
Subject: Re: why are WB_SYNC_NONE COMMITs being done with FLUSH_SYNC set ?
Message-ID: <20100819111122.562763d2@barsoom.rdu.redhat.com>
In-Reply-To: <1282229905.6199.19.camel@heimdal.trondhjem.org>
References: <20100819101525.076831ad@barsoom.rdu.redhat.com>
	<20100819143710.GA4752@infradead.org>
	<1282229905.6199.19.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 19 Aug 2010 10:58:25 -0400
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> On Thu, 2010-08-19 at 10:37 -0400, Christoph Hellwig wrote:
> > On Thu, Aug 19, 2010 at 10:15:25AM -0400, Jeff Layton wrote:
> > > I'm looking at backporting some upstream changes to earlier kernels,
> > > and ran across something I don't quite understand...
> > > 
> > > In nfs_commit_unstable_pages, we set the flags to FLUSH_SYNC. We then
> > > zero out the flags if wbc->nonblocking or wbc->for_background is set.
> > > 
> > > Shouldn't we also clear it out if wbc->sync_mode == WB_SYNC_NONE ?
> > > WB_SYNC_NONE means "don't wait on anything", so shouldn't that include
> > > not waiting on the COMMIT to complete?
> > 
> > I've been trying to figure out what the nonblocking flag is supposed
> > to mean for a while now.
> > 
> > It basically disappeared in commit 0d99519efef15fd0cf84a849492c7b1deee1e4b7
> > 
> > 	"writeback: remove unused nonblocking and congestion checks"
> > 
> > from Wu.  What's left these days is a couple of places in local copies
> > of write_cache_pages (afs, cifs), and a couple of checks in random
> > writepages instances (afs, block_write_full_page, ceph, nfs, reiserfs, xfs)
> > and the use in nfs_write_inode.  It's only actually set for memory
> > migration and pageout, that is VM writeback.
> > 
> > To me it really doesn't make much sense, but maybe someone has a better
> > idea what it is for.
> > 
> > > +	if (wbc->nonblocking || wbc->for_background ||
> > > +	    wbc->sync_mode == WB_SYNC_NONE)
> > 
> > You could remove the nonblocking and for_background checks as
> > these impliy WB_SYNC_NONE.
> 
> To me that sounds fine. I've also been trying to wrap my head around the
> differences between 'nonblocking', 'for_background', 'for_reclaim' and
> 'for_kupdate' and how the filesystem is supposed to treat them.
> 
> Aside from the above, I've used 'for_reclaim', 'for_kupdate' and
> 'for_background' in order to adjust the RPC request's queuing priority
> (high in the case of 'for_reclaim' and low for the other two).
> 

Ok, I don't really have a great way to test the above change though
aside from sticking it into the backport I'm working on for RHEL5
(2.6.18).

I suspect that the existing flag checks probably cover a lot of the
WB_SYNC_NONE cases already. Changing it to a check for WB_SYNC_NONE
would help me as RHEL5 doesn't have the for_background flag...

Cheers,
-- 
Jeff Layton <jlayton@redhat.com>
