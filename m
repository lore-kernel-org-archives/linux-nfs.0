Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail06.adl2.internode.on.net ([150.101.137.129]:61993 "EHLO
	ipmail06.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757714Ab3EWJrM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 May 2013 05:47:12 -0400
Date: Thu, 23 May 2013 19:42:01 +1000
From: Dave Chinner <david@fromorbit.com>
To: Waiman Long <Waiman.Long@hp.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jeff Layton <jlayton@redhat.com>,
        Miklos Szeredi <mszeredi@suse.cz>, Ian Kent <raven@themaw.net>,
        Sage Weil <sage@inktank.com>, Steve French <sfrench@samba.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Eric Paris <eparis@redhat.com>, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, autofs@vger.kernel.org,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-nfs@vger.kernel.org,
        "Chandramouleeswaran, Aswin" <aswin@hp.com>,
        "Norton, Scott J" <scott.norton@hp.com>,
        Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 0/3 v3] dcache: make it more scalable on large system
Message-ID: <20130523094201.GA24543@dastard>
References: <1369273048-60256-1-git-send-email-Waiman.Long@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1369273048-60256-1-git-send-email-Waiman.Long@hp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 22, 2013 at 09:37:25PM -0400, Waiman Long wrote:
> Change log:
> 
> v2->v3
>  - Fix the RCU lock problem found by Al Viro.
>  - Rebase the code to the latest v3.10-rc1 linux mainline.
>  - Remove patch 4 which may be problematic if the dentry is deleted.
>  - Rerun performance measurement using 3.10-rc1 kernel.
> 
> v1->v2
>  - Include performance improvement in the AIM7 benchmark results because
>    of this patch.
>  - Modify dget_parent() to avoid taking the lock, if possible, to further
>    improve AIM7 benchmark results.
> 
> During some perf-record sessions of the kernel running the high_systime
> workload of the AIM7 benchmark, it was found that quite a large portion
> of the spinlock contention was due to the perf_event_mmap_event()
> function itself. This perf kernel function calls d_path() which,
> in turn, call path_get() and dput() indirectly. These 3 functions
> were the hottest functions shown in the perf-report output of
> the _raw_spin_lock() function in an 8-socket system with 80 cores
> (hyperthreading off) with a 3.10-rc1 kernel:

<sigh>

What was it I said about this patchset when you posted it to speed
up an Oracle benchmark back in february? I'll repeat:

"Nobody should be doing reverse dentry-to-name lookups in a quantity
sufficient for it to become a performance limiting factor."

And that makes whatever that tracepoint is doing utterly stupid.
Dumping out full paths in a tracepoint is hardly "low overhead", and
that tracepoint should be stomped on from a great height. Sure,
print the filename straight out of the dentry into a tracepoint,
but repeated calculating the full path (probably for the same set of
dentries) is just a dumb thing to do.

Anyway, your numbers show that a single AIM7 microbenchmark goes
better under tracing the specific mmap event that uses d_path(), but
the others are on average a little bit slower. That doesn't convince
me that this is worth doing. Indeed, what happens to performance
when you aren't tracing?

Indeed, have you analysed what makes that
microbenchmark contend so much on the dentry lock while reverse
lookups are occuring? Dentry lock contention does not necessarily
indicate a problem with the dentry locks, and without knowing why
there is contention occuring (esp. compared to the other benchmarks)
we can't really determine if this is a good solution or not...

IOWs, you need more than one microbenchmark that interacts with
some naive monitoring code to justify the complexity these locking
changes introduce....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
