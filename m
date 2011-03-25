Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:55403 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754525Ab1CYS0a (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Mar 2011 14:26:30 -0400
Date: Fri, 25 Mar 2011 19:26:26 +0100
From: Jan Kara <jack@suse.cz>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: NFS page states & writeback
Message-ID: <20110325182626.GA26932@quack.suse.cz>
References: <20110325012803.GA25052@quack.suse.cz>
 <20110325070054.GA5970@localhost>
 <20110325093957.GL26611@dastard>
 <20110325142253.GA11589@localhost>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110325142253.GA11589@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri 25-03-11 22:22:53, Wu Fengguang wrote:
> On Fri, Mar 25, 2011 at 05:39:57PM +0800, Dave Chinner wrote:
> > On Fri, Mar 25, 2011 at 03:00:54PM +0800, Wu Fengguang wrote:
> > > Hi Jan,
> > > 
> > > On Fri, Mar 25, 2011 at 09:28:03AM +0800, Jan Kara wrote:
> > > >   Hi,
> > > > 
> > > >   while working on changes to balance_dirty_pages() I was investigating why
> > > > NFS writeback is *so* bumpy when I do not call writeback_inodes_wb() from
> > > > balance_dirty_pages(). Take a single dd writing to NFS. What I can
> > > > see is that we quickly accumulate dirty pages upto limit - ~700 MB on that
> > > > machine. So flusher thread starts working and in an instant all these ~700
> > > > MB transition from Dirty state to Writeback state. Then, as server acks
> > > 
> > > That can be fixed by the following patch:
> > > 
> > >         [PATCH 09/27] nfs: writeback pages wait queue
> > >         https://lkml.org/lkml/2011/3/3/79
> > 
> > I don't think this is a good definition of write congestion for a
> > NFS (or any other network fs) client. Firstly, writeback congestion
> > is really dependent on the size of the network send window
> > remaining. That is, if you've filled the socket buffer with writes
> > and would block trying to queue more pages on the socket, then you
> > are congested. i.e. the measure of congestion is the rate at which
> > write request can be sent to the server and processed by the server.
> 
> You are right. The wait queue fullness does reflect the congestion in
> typical setup because the queue size is typically much larger than the
> network pipeline. If happens to not be the case, I don't bother much
> because the patch's main goal is to avoid
> 
> - NFS client side nr_dirty being constantly exhausted
> 
> - very bursty network IO (I literally see it), such as 1Gbps for 1
>   second followed by completely idle for 10 seconds. Ideally if the
>   server disk can only do 10MB/s then there should be a fluent 10MB/s
>   network stream.
> 
> It just happens to inherit the old *congestion* names, and the upper
> layer now actually hardly care about the congestion state.
  Fengguang, I believe that limitting amount of NFS writeback pages is the
wrong direction. I don't think that the rapid transition of Dirty pages to
Writeback pages is a problem. Limiting Writeback pages only papers-over
the problem in writeback code. So let NFS client write what we tell it to
write as fast as the network and the server can take it. I agree that
bursty sending of pages might cause problems with network congestion etc.
but that's not the problem we are trying to address now.

> > Secondly, the big problem that causes the lumpiness is that we only
> > send commits when we reach at large threshold of unstable pages.
> > Because most servers tend to cache large writes in RAM,
> > the server might have a long commit latency because it has to write
> > hundred of MB of data to disk to complete the commit.
> > 
> > IOWs, the client sends the commit only when it really needs the
> > pages the be cleaned, and then we have the latency of the server
> > write before it responds that they are clean. Hence commits can take
> > a long time to complete and mark pages clean on the client side.
>  
> That's the point. That's why I add the following patches to limit the
> NFS commit size:
> 
>         [PATCH 10/27] nfs: limit the commit size to reduce fluctuations
>         [PATCH 11/27] nfs: limit the commit range
  I agree we need something along the lines of your first patch to push
pages from Unstable state more aggressively. I was testing a patch
yesterday which was more conservative and just changed the check to:

               if (nfsi->ncommit <= (nfsi->npages >> 4) ||
                   (!exceeded && nfsi->ncommit <= (nfsi->npages >> 1)))
                        goto out_mark_dirty;
 
Where 'exceeded' is bdi->dirty_exceeded. So we are more aggresive only if
we really need the pages back (since each commit forces a server to do
fsync, it is good to avoid it if we don't really need it). And it worked
nicely in reducing the bumps as well.

I'm not entirely conviced the nfsi->ncommit <= (nfsi->npages >> 4) part of
the check is the best thing to do, maybe we could have a fixed limit (like
64 MB) there as well. So the condition could look like:

if ((exceeded && nfsi->ncommit <= (nfsi->npages >> 4) && nfsi->ncommit < 16384)
    || (!exceeded && nfsi->ncommit <= (nfsi->npages >> 1)))
	goto out_mark_dirty;

What do you think?

I'm not sure about the second patch - I didn't test a load where it would
help. It would possibly help only if several clients shared a file? How
likely is that? Or do I misread your patch?

> > A solution that IRIX used for this problem was the concept of a
> > background commit. While doing writeback on an inode, if it sent
> > more than than a certain threshold of data (typically in the range
> > of 0.5-2s worth of data) to the server without a commit being
> > issued, it would send an _asynchronous_ commit with the current dirty
> > range to the server. That way the server starts writing the data
> > before it hits dirty thresholds (i.e. prevents GBs of dirty data
> > being cached on the server so commit lantecy is kept low).
> > 
> > When the background commit completes the NFS client can then convert
> > pages in the commit range to clean. Hence we keep the number of
> > unstable pages under control without needing to wait for a certain
> > number of unstable pages to build up before commits are triggered.
> > This allows the process of writing dirty pages to clean
> > unstable pages at roughly the same rate as the write rate without
> > needing any magic thresholds to be configured....
> 
> That's a good approach. In linux, by limiting the commit size, the NFS
> flusher should roughly achieve the same effect.
> 
> However there is another problem. Look at the below graph. Even though
> the commits are sent to NFS server in relatively small size and evenly
> distributed in time (the green points), the commit COMPLETION events
> from the server are observed to be pretty bumpy over time (the blue
> points sitting on the red lines). This may not be easily fixable.. So
> we still have to live with bumpy NFS commit completions...
> 
> http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/NFS/nfs-1dd-1M-8p-2945M-20%25-2.6.38-rc6-dt6+-2011-02-22-21-09/nfs-commit.png
  Well, looking at your graph, and it also pretty well matches my tests, the
completions come in ~50 MB batches. It's not perfect but far better than
those +400 MB batches I was seeing previously - compare e.g.
http://beta.suse.com/private/jack/balance_dirty_pages-v2/graphs/dd-test-nfs_8_1024-2011-02-28-21:52:05-mm.png
and
http://beta.suse.com/private/jack/balance_dirty_pages-v2/graphs/dd-test-nfs_8_1024-2011-03-25-01:02:43-mm.png

With these smaller bumps, pauses in balance_dirty_pages() stay below 500 ms
even with 8 dds banging the NFS share with my patchset (most of them is
~30 ms in fact):
http://beta.suse.com/private/jack/balance_dirty_pages-v2/graphs/dd-test-nfs_8_1024-2011-03-25-01:02:43-mm-procs.png

So I'd say that fixing the background limit checking logic and the small
tweak to commit check should be enough to make NFS reasonably well
behaved...

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR
