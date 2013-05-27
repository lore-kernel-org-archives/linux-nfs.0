Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail04.adl6.internode.on.net ([150.101.137.141]:14539 "EHLO
	ipmail04.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755779Ab3E0CJy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 26 May 2013 22:09:54 -0400
Date: Mon, 27 May 2013 12:09:04 +1000
From: Dave Chinner <david@fromorbit.com>
To: Waiman Long <waiman.long@hp.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jeff Layton <jlayton@redhat.com>,
        Miklos Szeredi <mszeredi@suse.cz>, Ian Kent <raven@themaw.net>,
        Sage Weil <sage@inktank.com>, Steve French <sfrench@samba.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Eric Paris <eparis@redhat.com>, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, autofs@vger.kernel.org,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, "Chandramouleeswaran, Aswin" <aswin@hp.com>,
        "Norton, Scott J" <scott.norton@hp.com>,
        Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 0/3 v3] dcache: make it more scalable on large system
Message-ID: <20130527020903.GR29466@dastard>
References: <1369273048-60256-1-git-send-email-Waiman.Long@hp.com>
 <20130523094201.GA24543@dastard>
 <519E8B5F.3080905@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <519E8B5F.3080905@hp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 23, 2013 at 05:34:23PM -0400, Waiman Long wrote:
> On 05/23/2013 05:42 AM, Dave Chinner wrote:
> >On Wed, May 22, 2013 at 09:37:25PM -0400, Waiman Long wrote:
> >>Change log:
> >>
> >>v2->v3
> >>  - Fix the RCU lock problem found by Al Viro.
> >>  - Rebase the code to the latest v3.10-rc1 linux mainline.
> >>  - Remove patch 4 which may be problematic if the dentry is deleted.
> >>  - Rerun performance measurement using 3.10-rc1 kernel.
> >>
> >>v1->v2
> >>  - Include performance improvement in the AIM7 benchmark results because
> >>    of this patch.
> >>  - Modify dget_parent() to avoid taking the lock, if possible, to further
> >>    improve AIM7 benchmark results.
> >>
> >>During some perf-record sessions of the kernel running the high_systime
> >>workload of the AIM7 benchmark, it was found that quite a large portion
> >>of the spinlock contention was due to the perf_event_mmap_event()
> >>function itself. This perf kernel function calls d_path() which,
> >>in turn, call path_get() and dput() indirectly. These 3 functions
> >>were the hottest functions shown in the perf-report output of
> >>the _raw_spin_lock() function in an 8-socket system with 80 cores
> >>(hyperthreading off) with a 3.10-rc1 kernel:
> >What was it I said about this patchset when you posted it to speed
> >up an Oracle benchmark back in february? I'll repeat:
> >
> >"Nobody should be doing reverse dentry-to-name lookups in a quantity
> >sufficient for it to become a performance limiting factor."
> 
> Thank for the comment, but my point is that it is the d_lock
> contention is skewing the data about how much spin lock contention
> had actually happened in the workload and it makes it harder to
> pinpoint problem areas to look at. This is not about performance, it
> is about accurate representation of performance data. Ideally, we
> want the overhead of turning on perf instrumentation to be as low as
> possible.

Right. But d_path will never be "low overhead", and as such it
shouldn't be used by perf.

> >And that makes whatever that tracepoint is doing utterly stupid.
> >Dumping out full paths in a tracepoint is hardly "low overhead", and
> >that tracepoint should be stomped on from a great height. Sure,
> >print the filename straight out of the dentry into a tracepoint,
> >but repeated calculating the full path (probably for the same set of
> >dentries) is just a dumb thing to do.
> >
> >Anyway, your numbers show that a single AIM7 microbenchmark goes
> >better under tracing the specific mmap event that uses d_path(), but
> >the others are on average a little bit slower. That doesn't convince
> >me that this is worth doing. Indeed, what happens to performance
> >when you aren't tracing?
> >
> >Indeed, have you analysed what makes that
> >microbenchmark contend so much on the dentry lock while reverse
> >lookups are occuring? Dentry lock contention does not necessarily
> >indicate a problem with the dentry locks, and without knowing why
> >there is contention occuring (esp. compared to the other benchmarks)
> >we can't really determine if this is a good solution or not...
> 
> What made it contend so much was the large number of CPUs available
> in my test system which is a 8-socket Westmere EX machines with 80
> cores. As perf was collecting data from every core, the threads will
> unavoidably bump into each other to translate dentries back to the
> full paths. The current code only allows one CPU in the d_path()
> critical path. My patch will allow all of them to be in the critical
> path concurrently.

Yes, I know *how* contention occurs and what your patch does. I'm
asking you to explain *why* we need to fix this specific workload,
and why the tracepoint that calls d_path() actually needs to do
that.

Your numbers indicate that your patchset decreases peformance in the
common, non-d_path intensive workloads, so why should we add all
this complexity to optimise a slow path at the expense of
significant complexity and lower performance in the fast
path?

> The upcoming Ivy-Bridge EX can have up to 15 cores per socket. So
> even a 4-socket machine will have up to 60 cores or 120 virtual CPUs
> if hyperthreading is turned on.

I don't see why that matters. I've been dealing with systems much
larger than that since early 2002, adn the process for delaing with
lock contention hasn't changed much in the last 10 years. First we
need to determine what you are doing is something that is sane,
determining whether there's a simpler fix than changing locking, and
whether it's actually any faster in the common case we care
about....

> >IOWs, you need more than one microbenchmark that interacts with
> >some naive monitoring code to justify the complexity these locking
> >changes introduce....
> The first patch can also independently improve the performance of a
> number of AIM7 workloads including almost 7X improvement in the
> short workload. More detailed information of these types of
> performance benefit was discussed in the patch description of the
> first patch. I will try to collect more performance improvement data
> on other workloads too.
> 
> Thank for the review.

I haven't reviewed anything. All I've made comments about you
needing to justifying the complexity of the change.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
