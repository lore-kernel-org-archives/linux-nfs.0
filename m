Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ipmail05.adl6.internode.on.net ([150.101.137.143]:22943 "EHLO
	ipmail05.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751512Ab1CZBSP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Mar 2011 21:18:15 -0400
Date: Sat, 26 Mar 2011 12:18:06 +1100
From: Dave Chinner <david@fromorbit.com>
To: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: NFS page states & writeback
Message-ID: <20110326011806.GT26611@dastard>
References: <20110325012803.GA25052@quack.suse.cz>
 <20110325070054.GA5970@localhost>
 <20110325093957.GL26611@dastard>
 <20110325142253.GA11589@localhost>
 <20110325225558.GQ26611@dastard>
 <20110325232440.GE26932@quack.suse.cz>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110325232440.GE26932@quack.suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, Mar 26, 2011 at 12:24:40AM +0100, Jan Kara wrote:
> On Sat 26-03-11 09:55:58, Dave Chinner wrote:
> > On Fri, Mar 25, 2011 at 10:22:53PM +0800, Wu Fengguang wrote:
> > > It just happens to inherit the old *congestion* names, and the upper
> > > layer now actually hardly care about the congestion state.
> > > 
> > > > Secondly, the big problem that causes the lumpiness is that we only
> > > > send commits when we reach at large threshold of unstable pages.
> > > > Because most servers tend to cache large writes in RAM,
> > > > the server might have a long commit latency because it has to write
> > > > hundred of MB of data to disk to complete the commit.
> > > > 
> > > > IOWs, the client sends the commit only when it really needs the
> > > > pages the be cleaned, and then we have the latency of the server
> > > > write before it responds that they are clean. Hence commits can take
> > > > a long time to complete and mark pages clean on the client side.
> > >  
> > > That's the point. That's why I add the following patches to limit the
> > > NFS commit size:
> > > 
> > >         [PATCH 10/27] nfs: limit the commit size to reduce fluctuations
> > >         [PATCH 11/27] nfs: limit the commit range
> > 
> > They don't solve the exclusion problem that is the root cause of the
> > burstiness. They do reduce the impact of it, but only in cases where
> > the server isn't that busy...
>   Well, at least the first patch results in sending commits earlier for
> smaller amounts of data so that is principially what we want, isn't it?
> 
> Maybe we could make NFS client trigger the commit on it's own when enough
> stable pages accumulate (and not depend on flusher thread to call
> ->write_inode) to make things more fluent. But that's about it and Irix
> did something like that if I understood your explanation correctly.

Effectively - waiting til a threshold is reached is too late to
prevent stalls.

> 
> > > > A solution that IRIX used for this problem was the concept of a
> > > > background commit. While doing writeback on an inode, if it sent
> > > > more than than a certain threshold of data (typically in the range
> > > > of 0.5-2s worth of data) to the server without a commit being
> > > > issued, it would send an _asynchronous_ commit with the current dirty
> > > > range to the server. That way the server starts writing the data
> > > > before it hits dirty thresholds (i.e. prevents GBs of dirty data
> > > > being cached on the server so commit lantecy is kept low).
> > > > 
> > > > When the background commit completes the NFS client can then convert
> > > > pages in the commit range to clean. Hence we keep the number of
> > > > unstable pages under control without needing to wait for a certain
> > > > number of unstable pages to build up before commits are triggered.
> > > > This allows the process of writing dirty pages to clean
> > > > unstable pages at roughly the same rate as the write rate without
> > > > needing any magic thresholds to be configured....
> > > 
> > > That's a good approach. In linux, by limiting the commit size, the NFS
> > > flusher should roughly achieve the same effect.
> > 
> > Not really. It's still threshold triggered,  it's still synchronous
> > and hence will still have problems with commit latency on slow or
> > very busy servers. That is, it may work ok when you are the only
> > client writing to the server, but when 1500 other clients are also
> > writing to the server it won't have the desired effect.
>   It isn't synchronous. We don't wait for commit in WB_SYNC_NONE mode if
> I'm reading the code right.  It's only synchronous in the sense that pages
> are really clean only after the commit finishes but that's not the problem
> you are pointing to I believe.

Yeah, it's changed since last time I looked closely at the NFS
writeback path. So that's not so much the problem anymore.

> 
> > > However there is another problem. Look at the below graph. Even though
> > > the commits are sent to NFS server in relatively small size and evenly
> > > distributed in time (the green points), the commit COMPLETION events
> > > from the server are observed to be pretty bumpy over time (the blue
> > > points sitting on the red lines). This may not be easily fixable.. So
> > > we still have to live with bumpy NFS commit completions...
> > 
> > Right. The load on the server will ultimately determine the commit
> > latency, and that can _never_ be controlled by the client. We just
> > have to live with it and design the writeback path to prevent
> > commits from blocking writes in as many situations as possible.
>   The question is how hard should we try. Here I believe Fengguang's
> patches can offer more then my approach because he throttles processes
> based on estimated bandwidth so occasional hiccups of the server are more
> "smoothed out".

Right, but the problem Fengguang mentioned was that the estimated
bandwidth was badly affected by uneven commit latency. My point is
that it is something we have no control over.

> If we send commits early enough, hiccups matter less but
> still it's just a matter of how big they are...

Yes - though this only reduces the variance the client sees in
steady state operation.  Realistically, we don't care if one commit
takes 2s for 100MB and the next takes 0.2s for the next 100MB as
long as we've been able to send 50MB/s of writes over the wire
consistently. IOWs, what we need to care about is getting the data
to the server as quickly as possible and decoupling that from the
commit operation.  i.e. we need to maximise and smooth the rate at
which we send dirty pages to the server, not the rate at which we
convert unstable pages to stable. If the server can't handle the
write rate we send it, if will slow downteh rate at which it
processes writes and we get congestion feedback that way (i.e. via
the network channel).

Essentially what I'm trying to say is that I don't think
unstable->clean operations (i.e. the commit) should affect or
control  the estimated bandwidth of the channel. A commit is an
operation that can be tuned to optimise throughput, but because of
it's variance it's not really an operation that can be used to
directly measure and control that throughput.

It is also worth remembering that some NFS servers return STABLE as
the state of the data in their write response. This transitions the
pages directly from writeback to clean, so there is no unstable
state or need for a commit operation. Hence the bandwidth estimation
in these cases is directly related to the network/protocol
throughput. If we can run background commit operations triggered by
write responses, then we have the same bandwidth estimation
behaviour for writes regardless of whether they return as STABLE or
UNSTABLE on the server...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
