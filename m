Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39483 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753632Ab1C0P07 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Mar 2011 11:26:59 -0400
Subject: Re: NFS page states & writeback
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20110326011806.GT26611@dastard>
References: <20110325012803.GA25052@quack.suse.cz>
	 <20110325070054.GA5970@localhost> <20110325093957.GL26611@dastard>
	 <20110325142253.GA11589@localhost> <20110325225558.GQ26611@dastard>
	 <20110325232440.GE26932@quack.suse.cz>  <20110326011806.GT26611@dastard>
Content-Type: text/plain; charset="UTF-8"
Date: Sun, 27 Mar 2011 17:26:41 +0200
Message-ID: <1301239601.22136.23.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, 2011-03-26 at 12:18 +1100, Dave Chinner wrote:
> Yes - though this only reduces the variance the client sees in
> steady state operation.  Realistically, we don't care if one commit
> takes 2s for 100MB and the next takes 0.2s for the next 100MB as
> long as we've been able to send 50MB/s of writes over the wire
> consistently. IOWs, what we need to care about is getting the data
> to the server as quickly as possible and decoupling that from the
> commit operation.  i.e. we need to maximise and smooth the rate at
> which we send dirty pages to the server, not the rate at which we
> convert unstable pages to stable. If the server can't handle the
> write rate we send it, if will slow downteh rate at which it
> processes writes and we get congestion feedback that way (i.e. via
> the network channel).
> 
> Essentially what I'm trying to say is that I don't think
> unstable->clean operations (i.e. the commit) should affect or
> control  the estimated bandwidth of the channel. A commit is an
> operation that can be tuned to optimise throughput, but because of
> it's variance it's not really an operation that can be used to
> directly measure and control that throughput.

Agreed. However as I have said before, most of the problem here is that
the Linux server is assuming that it should cache the data maximally as
if this were a local process.

Once the NFS client starts flushing data to the server, it is because
the client no longer wants to cache, but rather wants to see the data
put onto stable storage as quickly as possible.
At that point, the server should be focussing doing the same. It should
not be setting the low water mark at 20% of total memory before starting
writeback, because that means that the COMMIT may have to wait for
several GB of data of data to hit the platter.
If the water mark was set at say 100MB or so, then writeback would be
much smoother...

> It is also worth remembering that some NFS servers return STABLE as
> the state of the data in their write response. This transitions the
> pages directly from writeback to clean, so there is no unstable
> state or need for a commit operation. Hence the bandwidth estimation
> in these cases is directly related to the network/protocol
> throughput. If we can run background commit operations triggered by
> write responses, then we have the same bandwidth estimation
> behaviour for writes regardless of whether they return as STABLE or
> UNSTABLE on the server...

If the server were doing its job of acting as a glorified disk instead
of trying to act as a caching device, then most of that data should
already be on disk before the client sends the COMMIT.

Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

