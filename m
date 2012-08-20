Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga01.intel.com ([192.55.52.88]:25972 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756778Ab2HTOuk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Aug 2012 10:50:40 -0400
Date: Mon, 20 Aug 2012 22:50:32 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: Namjae Jeon <linkinjeon@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        Namjae Jeon <namjae.jeon@samsung.com>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 3/3] writeback: add dirty_ratio_time per bdi variable
 (NFS write performance)
Message-ID: <20120820145032.GA7469@localhost>
References: <1345283402-7889-1-git-send-email-linkinjeon@gmail.com>
 <20120819025724.GC16796@localhost>
 <CAKYAXd83r3RNi3Rn5s3DAEE=34YYbk_hUWcG6R3Zu3JwUw74aA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAKYAXd83r3RNi3Rn5s3DAEE=34YYbk_hUWcG6R3Zu3JwUw74aA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 20, 2012 at 09:48:42AM +0900, Namjae Jeon wrote:
> 2012/8/19, Fengguang Wu <fengguang.wu@intel.com>:
> > On Sat, Aug 18, 2012 at 05:50:02AM -0400, Namjae Jeon wrote:
> >> From: Namjae Jeon <namjae.jeon@samsung.com>
> >>
> >> This patch is based on suggestion by Wu Fengguang:
> >> https://lkml.org/lkml/2011/8/19/19
> >>
> >> kernel has mechanism to do writeback as per dirty_ratio and
> >> dirty_background
> >> ratio. It also maintains per task dirty rate limit to keep balance of
> >> dirty pages at any given instance by doing bdi bandwidth estimation.
> >>
> >> Kernel also has max_ratio/min_ratio tunables to specify percentage of
> >> writecache
> >> to control per bdi dirty limits and task throtelling.
> >>
> >> However, there might be a usecase where user wants a writeback tuning
> >> parameter to flush dirty data at desired/tuned time interval.
> >>
> >> dirty_background_time provides an interface where user can tune
> >> background
> >> writeback start time using /sys/block/sda/bdi/dirty_background_time
> >>
> >> dirty_background_time is used alongwith average bdi write bandwidth
> >> estimation
> >> to start background writeback.
> >
> > Here lies my major concern about dirty_background_time: the write
> > bandwidth estimation is an _estimation_ and will sure become wildly
> > wrong in some cases. So the dirty_background_time implementation based
> > on it will not always work to the user expectations.
> >
> > One important case is, some users (eg. Dave Chinner) explicitly take
> > advantage of the existing behavior to quickly create & delete a big
> > 1GB temp file without worrying about triggering unnecessary IOs.
> >
> Hi. Wu.
> Okay, I have a question.
> 
> If making dirty_writeback_interval per bdi to tune short interval
> instead of background_time, We can get similar performance
> improvement.
> /sys/block/<device>/bdi/dirty_writeback_interval
> /sys/block/<device>/bdi/dirty_expire_interval
> 
> NFS write performance improvement is just one usecase.
> 
> If we can set interval/time per bdi,  other usecases will be created
> by applying.

Per-bdi interval/time tunables, if there comes such a need, will in
essential be for data caching and safety. If turning them into some
requirement for better performance, the users will potential be
stretched on choosing the "right" value for balanced data cache,
safety and performance.  Hmm, not a comfortable prospection.

> >The numbers are impressive! FYI, I tried another NFS specific approach
> >to avoid big NFS COMMITs, which achieved similar performance gains:
> 
> >nfs: writeback pages wait queue
> >https://lkml.org/lkml/2011/10/20/235
> 
> Thanks.

The NFS write queue, on the other hand, is directly aimed for
improving NFS performance, latency and responsiveness.

In comparison to the per-bdi interval/time, it's more a guarantee of
smoother NFS writes.  As the tests show in the original email, with
the cost of a little more commits, it gains much better write
throughput and latency.

The NFS write queue is even a requirement, if we want to get
reasonable good responsiveness. Without it, the 20% dirty limit may
well be filled by NFS writeback/unstable pages. This is very bad for
responsiveness. Let me quote contents of two old emails (with small
fixes):

: PG_writeback pages have been the biggest source of
: latency issues in the various parts of the system.
: 
: It's not uncommon for me to see filesystems sleep on PG_writeback
: pages during heavy writeback, within some lock or transaction, which in
: turn stall many tasks that try to do IO or merely dirty some page in
: memory. Random writes are especially susceptible to such stalls. The
: stable page feature also vastly increase the chances of stalls by
: locking the writeback pages.
 
: When there are N seconds worth of writeback pages, it may
: take N/2 seconds on average for wait_on_page_writeback() to finish.
: So the total time cost of running into a random writeback page and
: waiting on it is also O(n^2):

:       E(PG_writeback waits) = P(hit PG_writeback) * E(wait on it)

: That means we can hardly keep more than 1-second worth of writeback
: pages w/o worrying about long waits on PG_writeback in various parts
: of the kernel.

: Page reclaim may also block on PG_writeback and/or PG_dirty pages. In
: the case of direct reclaim, it means blocking random tasks that are
: allocating memory in the system.
: 
: PG_writeback pages are much worse than PG_dirty pages in that they are
: not movable. This makes a big difference for high-order page allocations.
: To make room for a 2MB huge page, vmscan has the option to migrate
: PG_dirty pages, but for PG_writeback it has no better choices than to
: wait for IO completion.
: 
: The difficulty of THP allocation goes up *exponentially* with the
: number of PG_writeback pages. Assume PG_writeback pages are randomly
: distributed in the physical memory space. Then we have formula
: 
:         P(reclaimable for THP) = P(non-PG_writeback)^512
: 
: That's the possibly for a contiguous range of 512 pages to be free of
: PG_writeback, so that it's immediately reclaimable for use by
: transparent huge page. This ruby script shows us the concrete numbers.
: 
: irb> 1.upto(10) { |i| j=i/1000.0; printf "%.3f\t\t\t%.3f\n", j, (1-j)**512 }
: 
:         P(hit PG_writeback)     P(reclaimable for THP)
:         0.001                   0.599
:         0.002                   0.359
:         0.003                   0.215
:         0.004                   0.128
:         0.005                   0.077
:         0.006                   0.046
:         0.007                   0.027
:         0.008                   0.016
:         0.009                   0.010
:         0.010                   0.006
: 
: The numbers show that when the PG_writeback pages go up from 0.1% to
: 1% of system memory, the THP reclaim success ratio drops quickly from
: 60% to 0.6%. It indicates that in order to use THP without constantly
: running into stalls, the reasonable PG_writeback ratio is <= 0.1%.
: Going beyond that threshold, it quickly becomes intolerable.
: 
: That makes a limit of 256MB writeback pages for a mem=256GB system.
: Looking at the real vmstat:nr_writeback numbers in dd write tests:
: 
: JBOD-12SSD-thresh=8G/ext4-1dd-1-3.3.0/vmstat-end:nr_writeback 217009
: JBOD-12SSD-thresh=8G/ext4-10dd-1-3.3.0/vmstat-end:nr_writeback 198335
: JBOD-12SSD-thresh=8G/xfs-1dd-1-3.3.0/vmstat-end:nr_writeback 306026
: JBOD-12SSD-thresh=8G/xfs-10dd-1-3.3.0/vmstat-end:nr_writeback 315099
: JBOD-12SSD-thresh=8G/btrfs-1dd-1-3.3.0/vmstat-end:nr_writeback 1216058
: JBOD-12SSD-thresh=8G/btrfs-10dd-1-3.3.0/vmstat-end:nr_writeback 895335
: 
: Oops btrfs has 4GB writeback pages -- which asks for some bug fixing.
: Even ext4's 800MB still looks way too high, but that's ~1s worth of
: data per queue (or 130ms worth of data for the high performance Intel
: SSD, which is perhaps in danger of queue underruns?). So this system
: would require 512GB memory to comfortably run KVM instances with THP
: support.

The main concern on the NFS write wait queue, however, was that it
might hurt performance for long fat network pipes with large
bandwidth-delay products. If the pipe size can be properly estimated,
we'll be able to set adequate queue size and remove the last obstacle
of that patch.

Thanks,
Fengguang
