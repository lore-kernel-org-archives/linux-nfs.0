Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ipmail06.adl6.internode.on.net ([150.101.137.145]:19658 "EHLO
	ipmail06.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751695Ab1C1AXf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Mar 2011 20:23:35 -0400
Date: Mon, 28 Mar 2011 11:23:29 +1100
From: Dave Chinner <david@fromorbit.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: NFS page states & writeback
Message-ID: <20110328002329.GW26611@dastard>
References: <20110325012803.GA25052@quack.suse.cz>
 <20110325070054.GA5970@localhost>
 <20110325093957.GL26611@dastard>
 <20110325142253.GA11589@localhost>
 <20110325225558.GQ26611@dastard>
 <20110325232440.GE26932@quack.suse.cz>
 <20110326011806.GT26611@dastard>
 <1301239601.22136.23.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1301239601.22136.23.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, Mar 27, 2011 at 05:26:41PM +0200, Trond Myklebust wrote:
> On Sat, 2011-03-26 at 12:18 +1100, Dave Chinner wrote:
> > Yes - though this only reduces the variance the client sees in
> > steady state operation.  Realistically, we don't care if one commit
> > takes 2s for 100MB and the next takes 0.2s for the next 100MB as
> > long as we've been able to send 50MB/s of writes over the wire
> > consistently. IOWs, what we need to care about is getting the data
> > to the server as quickly as possible and decoupling that from the
> > commit operation.  i.e. we need to maximise and smooth the rate at
> > which we send dirty pages to the server, not the rate at which we
> > convert unstable pages to stable. If the server can't handle the
> > write rate we send it, if will slow downteh rate at which it
> > processes writes and we get congestion feedback that way (i.e. via
> > the network channel).
> > 
> > Essentially what I'm trying to say is that I don't think
> > unstable->clean operations (i.e. the commit) should affect or
> > control  the estimated bandwidth of the channel. A commit is an
> > operation that can be tuned to optimise throughput, but because of
> > it's variance it's not really an operation that can be used to
> > directly measure and control that throughput.
> 
> Agreed. However as I have said before, most of the problem here is that
> the Linux server is assuming that it should cache the data maximally as
> if this were a local process.

Yes, that's part of the problem, but it is not limited to Linux NFS
servers. Pretty much any general purpose machine that acts as a NFS
server has this problem to some extent.

> Once the NFS client starts flushing data to the server, it is because
> the client no longer wants to cache, but rather wants to see the data
> put onto stable storage as quickly as possible.

*nod*

> At that point, the server should be focussing doing the same. It should
> not be setting the low water mark at 20% of total memory before starting
> writeback, because that means that the COMMIT may have to wait for
> several GB of data of data to hit the platter.
> If the water mark was set at say 100MB or so, then writeback would be
> much smoother...

Right, but that's not as easy to do at the NFS server as it ѕounds.
Besides:

> If the server were doing its job of acting as a glorified disk instead
> of trying to act as a caching device, then most of that data should
> already be on disk before the client sends the COMMIT.

We can't make this assumption about the NFS server's behaviour.
Yes, if the server is optimal, the COMMIT will either be a no-op or
not necessary in the first place. However, there are many servers
out there that are not optimal (and never will be) and so we are
left with attempting to optimise flushing to stable storage from the
client side...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
