Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33620 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753590AbaHEUvH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Aug 2014 16:51:07 -0400
Date: Tue, 5 Aug 2014 16:51:05 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/6] NFS DRC scalability patches
Message-ID: <20140805205105.GA23341@fieldses.org>
References: <1407085564-3227-1-git-send-email-trond.myklebust@primarydata.com>
 <20140804074546.7c63e725@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140804074546.7c63e725@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 04, 2014 at 07:45:46AM -0400, Jeff Layton wrote:
> On Sun,  3 Aug 2014 13:05:58 -0400
> Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
> > Hi Bruce,
> > 
> > The following patchset is again more an FYI than a must have, but it
> > addresses a significant scalability problem for NFSv3 when running
> > over 10GigE and 40GigE networks. At one point, I was seeing >60% CPU
> > spinning on the DRC global spinlock...
> > 
> > The one thing to note is that because the statistics are moved outside
> > spinlocking, then their accuracy is slightly reduced (I do convert the
> > number of entries into an atomic, so that is still 100% correct). The
> > right thing to do there is probably to convert those into per-cpu
> > counters, however I've not had time to do so for now.
> > 
> 
> Consider adding some FIXME comments to that effect? While not terribly
> important, it would be good to fix them at some point.
> 
> > Cheers,
> >   Trond
> > 
> > Trond Myklebust (6):
> >   nfsd: Clean up drc cache in preparation for global spinlock
> >     elimination
> >   nfsd: convert the lru list into a per-bucket thing
> >   nfsd: Remove the cache_hash list
> >   nfsd: convert num_drc_entries to an atomic_t
> >   nfsd: split DRC global spinlock into per-bucket locks
> >   nfsd: Reorder nfsd_cache_match to check more powerful discriminators
> >     first
> > 
> >  fs/nfsd/cache.h    |   1 -
> >  fs/nfsd/nfscache.c | 205 +++++++++++++++++++++++++++++------------------------
> >  2 files changed, 113 insertions(+), 93 deletions(-)
> > 
> 
> Looks good. Nice work! You can add this to each since they all look
> good to me. It would be good to fix up the stats collection and the
> comments, but I wouldn't want to hold up this work for that.
> 
>     Reviewed-by: Jeff Layton <jlayton@primarydata.com>

Could you also rebase this to my for-3.17?  (Or to 3.17-rc1, whenever
that comes out.)  Not urgent, but there appear to be some minor
conflicts.

--b.
