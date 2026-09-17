Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 24079517BAC
	for <linux-nfs@vger.kernel.org>; Thu, 17 Sep 2026 13:46:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789652797; cv=none; b=WQE96XwmY1+US9LOzX7wYL/qJ4ef3QWsEdjdh7Tak9ZyczGXsYLxmhhzwGMAh/HYdBGO/rTUnPVvcdjf5JfUMkEyiEzpeL/iX/dbxa5sconekt0jIZZZvhlX5gc9aHUm+01eUpZkjredwT3oRvitKRoeAhIxF0N/wYzsCAE7VSs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789652797; c=relaxed/simple;
	bh=ymJVe9BZDqaNOKsjL10QkmDLGMtQNiemiz2s+FKTWoA=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=f+ZtU05xfzF0/AdaxB4vssPK9tEp2Ojf7zh1CCeoYO1nerKAkpM75yYbRapQQXO1QSzDliTbsRM5FgTTcO0Xl5CgY/DrFU2YrK1xZRvppA8o0gkeyMs3MKTj01XyBut13laeOKTG1C+22gf6btpdJegALVhdOeS9D5hoIaBRADc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Gv1S0O6W; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Gv1S0O6W"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 95EBE1F000FF;
	Thu, 17 Sep 2026 13:46:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789652784;
	bh=ZqVRP1eVd3s2Lvy2x+O8yKH+NXx/OGuZpTPn/NW1EaQ=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=Gv1S0O6WbrncsLxQ4R1fAZqSWsTVkGTvQ17oYdZIIW9eARxDN+FqIRd8XE6XPHBgQ
	 iDOxGpostgqHO4A2TaIwp3al58xaRyevwW75KLi4CtdaIR1uMh6heBxgTex8771QeI
	 4g4R6swV/772Gec7JhS5ANfHJiNg8IeOnoKxuh7ZhRbQsqQxLyTaJhTxhgRFZxZzNd
	 8S9jJCdtVtHJX++wlv4NRkvM8HySdBianS3RQmyC4aHLCS+EPeYPdgRlGKnk4Un8Tq
	 s6weSt/FaFYoJC1b2A5uUmT/+VNcaoKmkSwlozetZQSbiqC5hHXma5XDc0tdrDDTuM
	 q+p0s04LrCpNA==
Date: Thu, 17 Sep 2026 14:46:21 +0100
From: Harry Yoo <harry@kernel.org>
To: Tim Menninger <tmenninger@everpuredata.com>
Cc: linux-mm@kvack.org, Chuck Lever <cel@kernel.org>, 
	linux-nfs@vger.kernel.org, Jon Curley <jcurley@everpuredata.com>, 
	Eric Badger <ebadger@everpuredata.com>, Vlastimil Babka <vbabka@kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Hao Li <hao.li@linux.dev>, Christoph Lameter <cl@gentwo.org>, 
	David Rientjes <rientjes@google.com>, Roman Gushchin <roman.gushchin@linux.dev>
Subject: Re: [SLUB] nfs_page cmpxchg_double_fail and perf lock perturbation
 on dual-socket NFS/RDMA
Message-ID: <aqvq8-6IJBDer90O@thinkstation>
References: <20260916232227.4098143-1-tmenninger@everpuredata.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260916232227.4098143-1-tmenninger@everpuredata.com>

Hi Tim and Chuck, thanks for reporting this to linux-mm.
Will take a look at this but let me Cc SLAB ALLOCATOR folks here first.

-- 
Cheers,
Harry / Hyeonggon

On Wed, Sep 16, 2026 at 11:22:27PM +0000, Tim Menninger wrote:
> Chuck Lever suggested I bring this to linux-mm after we found some SLUB
> measurements we could not account for while investigating an NFS/RDMA
> throughput regression.
> 
> The original NFS discussion is here for context:
> 
>     https://lore.kernel.org/linux-nfs/0e2f9688-097c-4bb9-a7ec-82b41bdb3653@slotpi15m67/
> 
> The NFS regression itself has been separated from this issue. What
> remains interesting here is the behavior of the nfs_page slab cache on
> this machine, particularly the measurements with and without perf lock.
> 
> The system is:
> 
>     Intel Xeon Silver 4516Y+
>     2 sockets
>     24 cores/socket
>     2 threads/core
>     96 logical CPUs
> 
>     NUMA node0 CPUs: 0-23,48-71
>     NUMA node1 CPUs: 24-47,72-95
>
> The workload is a high-throughput NFS/RDMA direct-read workload using
> 1 MiB I/O, 160 threads, and iodepth 64.
> 
> The relevant debug options are all disabled:
> 
>     # CONFIG_KASAN is not set
>     # CONFIG_PROVE_LOCKING is not set
>     # CONFIG_LOCK_STAT is not set
>     # CONFIG_DEBUG_SPINLOCK is not set
>     # CONFIG_DEBUG_LIST is not set
> 
> All measurements below were collected on the unpatched base kernel:
> 
>     $ git rev-parse HEAD
>     940de590b839f71d6dc846160534bf202401b8b7
> 
>     $ uname -r
>     7.3.0-rc1-mainline+
> 
> The initial observation was a high apparent contention rate on the
> nfs_page slab's list_lock. In 10-second perf-lock captures I was seeing
> roughly 4.5M contended acquisitions and about 170-185 us of average
> reported wait.
> 
> Chuck reproduced a similar acquisition rate on a single-node EPYC
> system, but saw only about 7 ns average wait and fewer than 100
> cmpxchg_double_fail events over a corresponding interval. He suggested
> checking cmpxchg_double_fail because __slab_free() drops list_lock and
> retries when the freelist cmpxchg fails.
>
> I repeated the measurements in three placement configurations:
> 
>     A. workload unpinned, CQs all on node0
>     B. workload pinned to node0, CQs all on node0
>     C. workload unpinned, CQs balanced across the nodes
> 
> Without perf lock, throughput is similar in all three:
> 
>     A. unpinned / CQs node0:       ~45.5 GB/s
>     B. node0 pinned / CQs node0:   ~45.7 GB/s
>     C. unpinned / balanced CQs:    ~45.5 GB/s
> 
> During the perf-lock captures, throughput is approximately 25 GB/s.
> 
> For each instrumented 10-second window I ran:
> 
>     sudo perf lock record -a -g -o "$D/perf-locks.data" -- sleep 10
>     mpstat -P ALL 1 10
> 
> Before and after the same window I sampled the counters under:
> 
>     /sys/kernel/slab/nfs_page/
> 
> I also collected separate 10-second counter and mpstat windows under
> the same workload configurations without perf lock.
> 
> The resulting slab counter deltas were:
> 
>                             A               B                 C
>                      unpinned/node0    node0/node0   unpinned/balanced
> 
>     free_fastpath
>     instrumented        655,917,745    457,936,140       328,670,030
>     uninstrumented       34,906,233    119,984,226        59,469,931
> 
>     free_slowpath
>     instrumented        236,735,724      7,720,917       270,716,506
>     uninstrumented       85,039,753          2,814        60,145,870
> 
>     sheaf_flush
>     instrumented         39,842,700     42,706,800         8,341,440
>     uninstrumented        1,286,400     13,487,700           887,700
> 
>     barn_put_fail
>     instrumented            663,994        711,745           139,037
>     uninstrumented           21,464        224,762            14,765
> 
>     barn_get_fail
>     instrumented          4,609,925        840,344         4,651,225
>     uninstrumented        1,438,643        224,787         1,017,006
> 
>     cmpxchg_double_fail
>     instrumented             70,524          8,077            28,062
>     uninstrumented            7,471            713             1,503
> 
>     alloc_slowpath
>     all cases                     0              0                 0
> 
> The SLUB counter profile changes substantially with perf lock despite
> the lower NFS throughput, and the exact mix depends strongly on
> placement.
> 
> The uninstrumented node0/node0 run also reproduces the barn/sheaf
> relationship Chuck pointed out earlier. The nfs_page sheaf capacity is
> 60:
> 
>     sheaf_flush / 60 = 13,487,700 / 60 = 224,795
>     barn_put_fail                      = 224,762
> 
> The placement dependence of free_slowpath is also large. It falls from
> about 85M events per 10 seconds in the unpinned/node0 case to 2,814 in
> the node0/node0 case.
> 
> The reported perf-lock result, however, is similar across all three
> placements:
> 
>                          contentions    total wait    average wait
>     unpinned/node0         4,782,839      14.39 min      180.47 us
>     node0/node0            4,582,012      14.13 min      185.05 us
>     unpinned/balanced      4,572,196      12.81 min      168.14 us
> 
> I also revisited an inconsistency Chuck noticed in my earlier
> measurements. Previously I had compared aggregate perf-lock wait from
> one 10-second capture with CPU utilization measured during a different
> window.
> 
> I now have paired 10-second mpstat samples for each placement, with and
> without perf lock. The node values below are averages of the per-CPU
> %idle values for the CPUs in each NUMA node:
> 
>                                   system-wide       node0       node1
>                                   %idle             %idle       %idle
> 
>     A. unpinned / CQs node0
>        uninstrumented                 31.46           8.0        54.6
>        instrumented                    3.60           0.06        7.1
> 
>     B. node0 pinned / CQs node0
>        uninstrumented                 84.26          69.2        99.4
>        instrumented                   12.07          10.4        13.8
> 
>     C. unpinned / balanced CQs
>        uninstrumented                 66.86          66.7        66.9
>        instrumented                   14.83          19.0        10.6
> 
> This resolves the accounting inconsistency in my earlier measurements.
> The large aggregate perf-lock wait and high idle percentage had come
> from different windows. In the aligned samples, the system is much
> busier during the perf-lock capture than in the corresponding
> uninstrumented run.
> 
> I am still unsure how representative the reported ~170-185 us average
> wait is of the uninstrumented workload.
> 
> The remaining number I am less sure how to interpret is
> cmpxchg_double_fail. In the uninstrumented windows I see:
> 
>     unpinned / CQs node0:       7,471 / 10 sec
>     node0 pinned / CQs node0:     713 / 10 sec
>     unpinned / balanced CQs:    1,503 / 10 sec
> 
> compared with fewer than 100 in Chuck's test.
> 
> I understand that cmpxchg_double_fail counts failed slab freelist
> updates rather than failed logical frees, so I am not sure what the
> appropriate denominator is here. In particular, the node0/node0 case
> still has 713 failures while sustaining full throughput and only 2,814
> free_slowpath events over the interval.
> 
> My questions are:
> 
> 1. Do the uninstrumented cmpxchg_double_fail rates above look abnormal
>    for this workload/topology, or are they within the range one would
>    expect from this degree of concurrency and NUMA placement?
> 
> 2. Is there a less invasive way you would recommend measuring the
>    nfs_page list_lock/freelist contention? I would like to distinguish
>    the steady-state behavior from what is observed during the perf-lock
>    capture.
> 
> Thanks,
> Tim
