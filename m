Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59646 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756318AbaLHS5d (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Dec 2014 13:57:33 -0500
Date: Mon, 8 Dec 2014 13:57:31 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Trond Myklebust <trondmy@gmail.com>,
        Chris Worley <chris.worley@primarydata.com>, linux-nfs@vger.kernel.org,
        Ben Myers <bpm@sgi.com>
Subject: Re: [PATCH 3/4] sunrpc: convert to lockless lookup of queued server
 threads
Message-ID: <20141208185730.GB16612@fieldses.org>
References: <1416597571-4265-1-git-send-email-jlayton@primarydata.com>
 <1416597571-4265-4-git-send-email-jlayton@primarydata.com>
 <20141201234759.GF30749@fieldses.org>
 <CAABAsM6cikgA-gJZUNHzoqZCGxQaS9hagy9vcY4yfOzaqi4QyQ@mail.gmail.com>
 <20141202065750.283704a7@tlielax.poochiereds.net>
 <20141202071422.5b01585d@tlielax.poochiereds.net>
 <20141202165023.GA9195@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141202165023.GA9195@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 02, 2014 at 11:50:24AM -0500, J. Bruce Fields wrote:
> On Tue, Dec 02, 2014 at 07:14:22AM -0500, Jeff Layton wrote:
> > On Tue, 2 Dec 2014 06:57:50 -0500
> > Jeff Layton <jeff.layton@primarydata.com> wrote:
> > 
> > > On Mon, 1 Dec 2014 19:38:19 -0500
> > > Trond Myklebust <trondmy@gmail.com> wrote:
> > > 
> > > > On Mon, Dec 1, 2014 at 6:47 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > > > > I find it hard to think about how we expect this to affect performance.
> > > > > So it comes down to the observed results, I guess, but just trying to
> > > > > get an idea:
> > > > >
> > > > >         - this eliminates sp_lock.  I think the original idea here was
> > > > >           that if interrupts could be routed correctly then there
> > > > >           shouldn't normally be cross-cpu contention on this lock.  Do
> > > > >           we understand why that didn't pan out?  Is hardware capable of
> > > > >           doing this really rare, or is it just too hard to configure it
> > > > >           correctly?
> > > > 
> > > > One problem is that a 1MB incoming write will generate a lot of
> > > > interrupts. While that is not so noticeable on a 1GigE network, it is
> > > > on a 40GigE network. The other thing you should note is that this
> > > > workload was generated with ~100 clients pounding on that server, so
> > > > there are a fair amount of TCP connections to service in parallel.
> > > > Playing with the interrupt routing doesn't necessarily help you so
> > > > much when all those connections are hot.
> > > > 
> > 
> > In principle though, the percpu pool_mode should have alleviated the
> > contention on the sp_lock. When an interrupt comes in, the xprt gets
> > queued to its pool. If there is a pool for each cpu then there should
> > be no sp_lock contention. The pernode pool mode might also have
> > alleviated the lock contention to a lesser degree in a NUMA
> > configuration.
> > 
> > Do we understand why that didn't help?
> 
> Yes, the lots-of-interrupts-per-rpc problem strikes me as a separate if
> not entirely orthogonal problem.
> 
> (And I thought it should be addressable separately; Trond and I talked
> about this in Westford.  I think it currently wakes a thread to handle
> each individual tcp segment--but shouldn't it be able to do all the data
> copying in the interrupt and wait to wake up a thread until it's got the
> entire rpc?)

By the way, Jeff, isn't this part of what's complicating the workqueue
change?  That would seem simpler if we didn't need to queue work until
we had the full rpc.

--b.
