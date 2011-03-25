Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:18955 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753006Ab1CYOWz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Mar 2011 10:22:55 -0400
Date: Fri, 25 Mar 2011 22:22:53 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: NFS page states & writeback
Message-ID: <20110325142253.GA11589@localhost>
References: <20110325012803.GA25052@quack.suse.cz>
 <20110325070054.GA5970@localhost>
 <20110325093957.GL26611@dastard>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110325093957.GL26611@dastard>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Mar 25, 2011 at 05:39:57PM +0800, Dave Chinner wrote:
> On Fri, Mar 25, 2011 at 03:00:54PM +0800, Wu Fengguang wrote:
> > Hi Jan,
> > 
> > On Fri, Mar 25, 2011 at 09:28:03AM +0800, Jan Kara wrote:
> > >   Hi,
> > > 
> > >   while working on changes to balance_dirty_pages() I was investigating why
> > > NFS writeback is *so* bumpy when I do not call writeback_inodes_wb() from
> > > balance_dirty_pages(). Take a single dd writing to NFS. What I can
> > > see is that we quickly accumulate dirty pages upto limit - ~700 MB on that
> > > machine. So flusher thread starts working and in an instant all these ~700
> > > MB transition from Dirty state to Writeback state. Then, as server acks
> > 
> > That can be fixed by the following patch:
> > 
> >         [PATCH 09/27] nfs: writeback pages wait queue
> >         https://lkml.org/lkml/2011/3/3/79
> 
> I don't think this is a good definition of write congestion for a
> NFS (or any other network fs) client. Firstly, writeback congestion
> is really dependent on the size of the network send window
> remaining. That is, if you've filled the socket buffer with writes
> and would block trying to queue more pages on the socket, then you
> are congested. i.e. the measure of congestion is the rate at which
> write request can be sent to the server and processed by the server.

You are right. The wait queue fullness does reflect the congestion in
typical setup because the queue size is typically much larger than the
network pipeline. If happens to not be the case, I don't bother much
because the patch's main goal is to avoid

- NFS client side nr_dirty being constantly exhausted

- very bursty network IO (I literally see it), such as 1Gbps for 1
  second followed by completely idle for 10 seconds. Ideally if the
  server disk can only do 10MB/s then there should be a fluent 10MB/s
  network stream.

It just happens to inherit the old *congestion* names, and the upper
layer now actually hardly care about the congestion state.

> Secondly, the big problem that causes the lumpiness is that we only
> send commits when we reach at large threshold of unstable pages.
> Because most servers tend to cache large writes in RAM,
> the server might have a long commit latency because it has to write
> hundred of MB of data to disk to complete the commit.
> 
> IOWs, the client sends the commit only when it really needs the
> pages the be cleaned, and then we have the latency of the server
> write before it responds that they are clean. Hence commits can take
> a long time to complete and mark pages clean on the client side.
 
That's the point. That's why I add the following patches to limit the
NFS commit size:

        [PATCH 10/27] nfs: limit the commit size to reduce fluctuations
        [PATCH 11/27] nfs: limit the commit range

> A solution that IRIX used for this problem was the concept of a
> background commit. While doing writeback on an inode, if it sent
> more than than a certain threshold of data (typically in the range
> of 0.5-2s worth of data) to the server without a commit being
> issued, it would send an _asynchronous_ commit with the current dirty
> range to the server. That way the server starts writing the data
> before it hits dirty thresholds (i.e. prevents GBs of dirty data
> being cached on the server so commit lantecy is kept low).
> 
> When the background commit completes the NFS client can then convert
> pages in the commit range to clean. Hence we keep the number of
> unstable pages under control without needing to wait for a certain
> number of unstable pages to build up before commits are triggered.
> This allows the process of writing dirty pages to clean
> unstable pages at roughly the same rate as the write rate without
> needing any magic thresholds to be configured....

That's a good approach. In linux, by limiting the commit size, the NFS
flusher should roughly achieve the same effect.

However there is another problem. Look at the below graph. Even though
the commits are sent to NFS server in relatively small size and evenly
distributed in time (the green points), the commit COMPLETION events
from the server are observed to be pretty bumpy over time (the blue
points sitting on the red lines). This may not be easily fixable.. So
we still have to live with bumpy NFS commit completions...

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/NFS/nfs-1dd-1M-8p-2945M-20%25-2.6.38-rc6-dt6+-2011-02-22-21-09/nfs-commit.png

Thanks,
Fengguang
