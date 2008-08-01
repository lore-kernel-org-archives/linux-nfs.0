From: Dave Chinner <david@fromorbit.com>
Subject: Re: high latency NFS
Date: Fri, 1 Aug 2008 17:23:20 +1000
Message-ID: <20080801072320.GE6201@disturbed>
References: <200807241311.31457.shuey@purdue.edu> <20080730192110.GA17061@fieldses.org> <4890DFC7.3020309@cse.unsw.edu.au> <200807302235.50068.shuey@purdue.edu> <20080731031512.GA26203@fieldses.org> <18577.25513.494821.481623@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Michael Shuey <shuey-olO2ZdjDehc3uPMLIKxrzw@public.gmane.org>,
	Shehjar Tikoo <shehjart-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	rees@citi.umich.edu, aglo@citi.umich.edu
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ipmail01.adl6.internode.on.net ([203.16.214.146]:31198 "EHLO
	ipmail01.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753042AbYHAHX1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Aug 2008 03:23:27 -0400
In-Reply-To: <18577.25513.494821.481623-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 31, 2008 at 05:03:05PM +1000, Neil Brown wrote:
> On Wednesday July 30, bfields@fieldses.org wrote:
> > > 
> > > I was only using the default 8 nfsd threads on the server.  When I raised 
> > > this to 256, the read bandwidth went from about 6 MB/sec to about 95 
> > > MB/sec, at 100ms of netem-induced latency.
> > 
> > So this is yet another reminder that someone needs to implement some
> > kind of automatic tuning of the number of threads.
> > 
> > I guess the first question is what exactly the policy for that should
> > be?  How do we decide when to add another thread?  How do we decide when
> > there are too many?
> 
> Or should the first question be "what are we trying to achieve?"?
> 
> Do we want to:
>     Automatically choose a number of threads that would match what a
>       well informed sysadmin might choose
> or
>     regularly adjust the number of threads to find an optimal balance
>       between prompt request processing (minimal queue length),
>       minimal resource usage (idle threads waste memory)
>     and not overloading the filesystem (how much concurrency does the
>         filesystem/storage subsystem realistically support.
> 
> And then we need to think about how this relates to NUMA situations
> where we have different numbers of threads on each node.
> 
> 
> I think we really want to aim for the first of the above options, but
> that the result will end up looking a bit like a very simplistic
> attempt at the second.  "simplicitic" is key - we don't want
> "complex".

Having implemented the second option on a different NUMA aware
OS and NFS server, I can say that it isn't that complex, nor that
hard to screw up.

	1. spawn a new thread only if all NFSDs are busy and there
	   are still requests queued to be serviced.
	2. rate limit the speed at which you spawn new NFSD threads.
	   About 5/s per node was about right.
	3. define an idle time for each thread before they
	   terminate. That is, is a thread has not been asked to
	   do any work for 30s, exit.
	4. use the NFSD thread pools to allow per-pool independence.

> I think that in the NUMA case we probably want to balance each node
> independently.
> 
> The difficulties - I think - are:
>   - make sure we can handle a sudden surge of requests, certainly a
>     surge up to levels that we have previously seen.
>     I think the means we either don't kill excess threads, or
>     only kill them up to a limit: e.g. never fewer than 50% of
>     the maximum number of threads

You only want to increase the number of threads for sustained
loads or regular peaks of load. You don't want simple transients
to cause massive numbers of threads to spawn so rate limiting
the spawning rate is needed.

>   - make sure we don't create too many threads if something clags up
>     and nothing is getting through.  This means we need to monitor the
>     number of requests dequeued and not make new threads when that is
>     zero.

That second case is easy - only allow a new thread to be spawned when a
request is dequeued. Hence if all the NFSDs are clagged, then we
won't waste resources clagging more of them.

> So how about:
>   For each node we watch the length of the queue of
>   requests-awaiting-threads and the queue of threads
>   awaiting requests and maintain these values:
>     - max number of threads ever concurrently running
>     - number of requests dequeued
>     - min length request queue
>     - min length of thread queue
> 
>   Then every few (5?) seconds we sample these numbers and reset them
>      (except the first).
>      If 
>         the min request queue length is non-zero and 
>         the number of requests dequeued is non-zero
>      Then
>         start a new thread
>      If
>         the number of threads exceeds half the maximum and
>         the min length of the thread queue exceeds 0
>      Then
>         stop one (idle) thread

The period of adjustment is really too low to be useful - a single
extra thread is meaningless if you go from 8 to 9 when you really need
30 or 40 nfsds. Taking minutes to get to the required number is
really too slow. You want to go from 8 to 40 within a few seconds of
that load starting....

> You might want to track the max length of the request queue too and
> start more threads if the queue is long, to allow a quick ramp-up.

Right, but even request queue depth is not a good indicator. You
need to leep track of how many NFSDs are actually doing useful
work. That is, if you've got an NFSD on the CPU that is hitting
the cache and not blocking, you don't need more NFSDs to handle
that load because they can't do any more work than the NFSD
that is currently running is. 

i.e. take the solution that Greg banks used for the CPU scheduler
overload issue (limiting the number of nfsds woken but not yet on
the CPU), and apply that criteria to spawning new threads.  i.e.
we've tried to wake an NFSD, but there are none available so that
means more NFSDs are needed for the given load. If we've already
tried to wake one and it hasn't run yet, then we've got enough
NFSDs....

Also, NFSD scheduling needs to be LIFO so that unused NFSDs
accumulate idle time and so can be culled easily. If you RR the
nfsds, they'll all appear to be doing useful work so it's hard to
tell if you've got any idle at all.

HTH.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
