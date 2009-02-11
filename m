From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [patch 1/3] knfsd: remove the nfsd thread busy histogram
Date: Wed, 11 Feb 2009 16:59:47 -0500
Message-ID: <20090211215947.GH27686@fieldses.org>
References: <20090113102633.719563000@sgi.com> <20090113102653.445100000@sgi.com> <BF9EF754-76CE-41B7-B712-2E96E3D9CA9B@oracle.com> <496D1ACC.7070106@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Linux NFS ML <linux-nfs@vger.kernel.org>
To: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:55433 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755842AbZBKV7l (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Feb 2009 16:59:41 -0500
In-Reply-To: <496D1ACC.7070106-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 14, 2009 at 09:50:52AM +1100, Greg Banks wrote:
> Chuck Lever wrote:
> > On Jan 13, 2009, at Jan 13, 2009, 5:26 AM, Greg Banks wrote:
> >> Stop gathering the data that feeds the 'th' line in /proc/net/rpc/nfsd
> >> because the questionable data provided is not worth the scalability
> >> impact of calculating it.  Instead, always report zeroes.  The current
> >> approach suffers from three major issues:
> >>
> >> 1. update_thread_usage() increments buckets by call service
> >>   time or call arrival time...in jiffies.  On lightly loaded
> >>   machines, call service times are usually < 1 jiffy; on
> >>   heavily loaded machines call arrival times will be << 1 jiffy.
> >>   So a large portion of the updates to the buckets are rounded
> >>   down to zero, and the histogram is undercounting.
> >
> > Use ktime_get_real() instead.  This is what the network layer uses.
> IIRC that wasn't available when I wrote the patch (2.6.5 kernel in SLES9
> in late 2005).  I haven't looked at it again since.
> 
> Later, I looked at gathering better statistics on thread usage, and I
> investigated real time clock (more precisely, monotonic clock)
> implementations in Linux and came to the sad conclusion that there was
> no API I could call that would be both accurate and efficient on two or
> more platforms, so I gave up.  The HPET hardware timer looked promising
> for a while, but it turned out that a 32b kernel used a global spinlock
> to access the 64b HPET registers, which created the same scalability
> problem I was trying to fix.  Things may have improved since then.
> 
> If we had such a clock though, the solution is very simple.  Each nfsd
> maintains two new 64b counters of nanoseconds spent in each of two
> states "busy" and "idle", where "idle" is asleep waiting for a call and
> "busy" is everything else.  These are maintained in svc_recv(). 
> Interfaces are provided for userspace to read an aggregation of these
> counters, per-pool and globally.  Userspace rate-converts the counters;
> the rate of increase of the two counters tells you both how many threads
> there are and how much actual demand on thread time there is.  This is
> how I did it in Irix (SGI  Origin machines had a global distributed
> monotonic clock in hardware).

Is it worth looking into this again now?

> >   You could even steal the start timestamp from the first skbuff in an
> > incoming RPC request.
> 
> This would help if we had skbuffs: NFS/RDMA doesn't.
> >
> > This problem is made worse on "server" configurations and in virtual
> > guests which may still use HZ=100, though with tickless HZ this is a
> > less frequently seen configuration.
> 
> Indeed.
> >
> >> 2. As seen previously on the nfs mailing list, the format in which
> >>   the histogram is presented is cryptic, difficult to explain,
> >>   and difficult to use.
> >
> > A user space script similar to mountstats that interprets these
> > metrics might help here.
> 
> The formatting in the pseudofile isn't the entire problem.  The problem
> is translating the "thread usage histogram" information there into an
> answer to the actual question the sysadmin wants, which is "should I
> configure more nfsds?"

Agreed.

> >> 3. Updating the histogram requires taking a global spinlock and
> >>   dirtying the global variables nfsd_last_call, nfsd_busy, and
> >>   nfsdstats *twice* on every RPC call, which is a significant
> >>   scaling limitation.
> >
> > You might fix this by making the global variables into per-CPU
> > variables, then totaling the per-CPU variables only at presentation
> > time (ie when someone cats /proc/net/rpc/nfsd).  That would make the
> > collection logic lockless.
> This is how I fixed some of the other server stats in later patches. 
> IIRC that approach doesn't work for the thread usage histogram because
> it's scaled as it's gathered by a potentially time-varying global number
> so the on-demand totalling might not give correct results.

Right, so, amuse yourself watching me as I try to remember how the 'th'
line works: if it's attempting to report, e.g., what length of time 10%
of the threads are busy, it needs very local knowledge: if you know each
thread was busy 10 jiffies out of the last 100, you'd still need to know
whether they were all busy during the *same* 10-jiffy interval, or
whether that work was spread out more evenly over the 100 jiffies....

--b.

> Also, in the
> presence of multiple thread pools any thread usage information should be
> per-pool not global.  At the time I wrote this patch I concluded that I
> couldn't make the gathering scale and still preserve the exact semantics
> of the data gathered.
> 
> >
> >>
> >
> > Yeah.  The real issue here is deciding whether these stats are useful
> > or not; 
> In my experience, not.
> 
> > if not, can they be made useable?
> A different form of the data could certainly be made useful.
> 
> -- 
> Greg Banks, P.Engineer, SGI Australian Software Group.
> the brightly coloured sporks of revolution.
> I don't speak for SGI.
> 
