Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay3.sgi.com ([192.48.152.1]:58505 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751026AbaLBSyA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Dec 2014 13:54:00 -0500
Date: Tue, 2 Dec 2014 12:53:58 -0600
From: Ben Myers <bpm@sgi.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Andrew Dahl <adahl@sgi.com>, Jeff Layton <jeff.layton@primarydata.com>,
        Trond Myklebust <trondmy@gmail.com>,
        Chris Worley <chris.worley@primarydata.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/4] sunrpc: convert to lockless lookup of queued
 server threads
Message-ID: <20141202185358.GH11444@sgi.com>
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

Hey Bruce,

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
> 
> > In any case, I think that doing this with RCU is still preferable.
> > We're walking a very short list, so doing it lockless is still a
> > good idea to improve performance without needing to use the percpu
> > pool_mode.
> 
> I find that entirely plausible.
> 
> Maybe it would help to ask SGI people.  Cc'ing Ben Myers in hopes he
> could point us to the right person.
>
> It'd be interesting to know:
> 
> 	- are they using the svc_pool stuff?
> 	- if not, why not?
> 	- if so:
> 		- can they explain how they configure systems to take
> 		  advantage of it?
> 		- do they have any recent results showing how it helps?
> 		- could they test Jeff's patches for performance
> 		  regressions?
> 
> Anyway, I'm off for now, back to work Thursday.
> 
> --b.

Andrew Dahl is the right person.  Cc'd. 

Regards,
	Ben
