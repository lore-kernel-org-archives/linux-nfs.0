Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail07.adl2.internode.on.net ([150.101.137.131]:35114 "EHLO
	ipmail07.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752110Ab2HTCAK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 19 Aug 2012 22:00:10 -0400
Date: Mon, 20 Aug 2012 12:00:04 +1000
From: Dave Chinner <david@fromorbit.com>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Namjae Jeon <linkinjeon@gmail.com>, akpm@linux-foundation.org,
        linux-kernel@vger.kernel.org, Namjae Jeon <namjae.jeon@samsung.com>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/3] writeback: add dirty_ratio_time per bdi variable
 (NFS write performance)
Message-ID: <20120820020004.GB19235@dastard>
References: <1345283402-7889-1-git-send-email-linkinjeon@gmail.com>
 <20120819025724.GC16796@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120819025724.GC16796@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Aug 19, 2012 at 10:57:24AM +0800, Fengguang Wu wrote:
> On Sat, Aug 18, 2012 at 05:50:02AM -0400, Namjae Jeon wrote:
> > From: Namjae Jeon <namjae.jeon@samsung.com>
> > 
> > This patch is based on suggestion by Wu Fengguang:
> > https://lkml.org/lkml/2011/8/19/19
> > 
> > kernel has mechanism to do writeback as per dirty_ratio and dirty_background
> > ratio. It also maintains per task dirty rate limit to keep balance of
> > dirty pages at any given instance by doing bdi bandwidth estimation.
> > 
> > Kernel also has max_ratio/min_ratio tunables to specify percentage of writecache
> > to control per bdi dirty limits and task throtelling.
> > 
> > However, there might be a usecase where user wants a writeback tuning
> > parameter to flush dirty data at desired/tuned time interval.
> > 
> > dirty_background_time provides an interface where user can tune background
> > writeback start time using /sys/block/sda/bdi/dirty_background_time
> > 
> > dirty_background_time is used alongwith average bdi write bandwidth estimation
> > to start background writeback.
> 
> Here lies my major concern about dirty_background_time: the write
> bandwidth estimation is an _estimation_ and will sure become wildly
> wrong in some cases. So the dirty_background_time implementation based
> on it will not always work to the user expectations.
> 
> One important case is, some users (eg. Dave Chinner) explicitly take
> advantage of the existing behavior to quickly create & delete a big
> 1GB temp file without worrying about triggering unnecessary IOs.

It's a fairly common use case - short term temp files are used by
lots of applications and avoiding writing them - especially on NFS -
is a big performance win. Forcing immediate writeback will
definitely cause unprdictable changes in performance for many
people...

> > Results are:-
> > ==========================================================
> > Case:1 - Normal setup without any changes
> > ./performancetest_arm ./100MB write
> > 
> >  RecSize  WriteSpeed   RanWriteSpeed
> > 
> >  10485760  7.93MB/sec   8.11MB/sec
> >   1048576  8.21MB/sec   7.80MB/sec
> >    524288  8.71MB/sec   8.39MB/sec
> >    262144  8.91MB/sec   7.83MB/sec
> >    131072  8.91MB/sec   8.95MB/sec
> >     65536  8.95MB/sec   8.90MB/sec
> >     32768  8.76MB/sec   8.93MB/sec
> >     16384  8.78MB/sec   8.67MB/sec
> >      8192  8.90MB/sec   8.52MB/sec
> >      4096  8.89MB/sec   8.28MB/sec
> > 
> > Average speed is near 8MB/seconds.
> > 
> > Case:2 - Modified the dirty_background_time
> > ./performancetest_arm ./100MB write
> > 
> >  RecSize  WriteSpeed   RanWriteSpeed
> > 
> >  10485760  10.56MB/sec  10.37MB/sec
> >   1048576  10.43MB/sec  10.33MB/sec
> >    524288  10.32MB/sec  10.02MB/sec
> >    262144  10.52MB/sec  10.19MB/sec
> >    131072  10.34MB/sec  10.07MB/sec
> >     65536  10.31MB/sec  10.06MB/sec
> >     32768  10.27MB/sec  10.24MB/sec
> >     16384  10.54MB/sec  10.03MB/sec
> >      8192  10.41MB/sec  10.38MB/sec
> >      4096  10.34MB/sec  10.12MB/sec
> > 
> > we can see, average write speed is increased to ~10-11MB/sec.
> > ============================================================
> 
> The numbers are impressive!

All it shows is that avoiding the writeback delay writes a file a
bit faster. i.e. 5s delay + 10s @ 10MB/s vs no delay and 10s
@10MB/s. That's pretty obvious, really, and people have been trying
to make this "optimisation" for NFS clients for years in the
misguided belief that short-cutting writeback caching is beneficial
to application performance.

What these numbers don't show that is whether over-the-wire
writeback speed has improved at all. Or what happens when you have a
network that is faster than the server disk, or even faster than the
client can write into memory? What about when there are multiple
threads, or the network is congested, or the server overloaded? In
those cases the performance differential will disappear and
there's a good chance that the existing code will be significantly
faster because it places less imediate load on the server and
network.D...

If you need immediate dispatch of your data for single threaded
performance then sync_file_range() is your friend.

> FYI, I tried another NFS specific approach
> to avoid big NFS COMMITs, which achieved similar performance gains:
> 
> nfs: writeback pages wait queue
> https://lkml.org/lkml/2011/10/20/235

Which is basically controlling the server IO latency when commits
occur - smaller ranges mean the commit (fsync) is faster, and more
frequent commits mean the data goes to disk sooner. This is
something that will have a positive impact on writeback speeds
because it modifies the NFs client writeback behaviour to be more
server friendly and not stall over the wire. i.e. improving NFS
writeback performance is all about keeping the wire full and the
server happy, not about reducing the writeback delay before we start
writing over the wire.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
