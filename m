Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5472957F725;
	Wed,  9 Sep 2026 16:14:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788970476; cv=none; b=O1lJCfKUF8DrL3bnMyOIiz9aFW+nEZVdrXKvtkD9ye5+evTeuqrePY7t6QQA30VrA7EDgalWVdy3asyAsqFJXYFOXTJP5geY1wBrQyNCkd0SuH4aOWN5VYec84D8bFboCU9mqIC1F0s70Z+CQFRUMYIwshQ3XMuH/jlZ6GFQorU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788970476; c=relaxed/simple;
	bh=IXErDTOJX0z/AMq180l0c18g+M8CufxZ9WK3gzKH554=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=cdKhwSClUxt93s7TBIKbDIgKTmPxaZHj9Kw1LIB3Sh+KcJaJ0QfSLqH6RJ9rHFAUqMOYUMHp+ooW2uVmJ5A3E2VOqMihsjQPDSSG3gKXOrMHR/LiFO5Qwyx8fimVFFis7PmMDJrxp9rPRvkpvzavL0VEMdO89TzydK9ayxTk8QE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=mEox8JA4; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="mEox8JA4"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C95911F00899;
	Wed,  9 Sep 2026 16:14:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788970475;
	bh=JIKlN1u+EuU1sjWnG21tJwavPZttAEOlYhNsImizttI=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=mEox8JA4S9UJ0KZnk2buy2vrl1u9xAGy349gsGmIyt/s8Zvgq98CjxnFIGdolJTVZ
	 Zn31IsxPUpRbMSxXybdhcO3Cc8XDaI55BNxAx2JydVxgE6TTSGvX6znIe2JyGe0Yjp
	 iuEavPQFYtAK7NexCUhM4a/tU4j8D0xmf2s38ZkGQMVLwtH8vVuHjD+NB4QFEX/UjV
	 hD2ixZgse0D4fJ3wnXp5YVIyMRmvF83F7zsbFVfntANAg5L0xHU5MyIveRnrPYLnIe
	 fDEmEFPmj0ltUrXmtGjaYsV79/yTOdEIRT+uBNftMdy1S6LCl8pnrKNNuOv5EhQWl5
	 ieUGNwWChi6Eg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id F0D7BF40066;
	Wed,  9 Sep 2026 12:14:33 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Wed, 09 Sep 2026 12:14:33 -0400
X-ME-Sender: <xms:6YWhakEL7c43YIbwXjza4GNKYXb1g69n3Z-aDHEVGnXLpcUOABP8Ig>
    <xme:6YWhaoIEhayIeyR_OWaGMgN3s-srA_-Qs9lCBOBoPyGVM75oIbNYIk78s6l0Ebby3
    OkRB_j9K68nAhejfGPg1e7NrHNvY-b3xKmao5uKtsGkpZuN98uWpTbe>
X-ME-Proxy-Cause: dmFkZTGmMpjcal9FL2mtojiBdLp60Q5rxctvqWiVLQ8omWVH5OoEkL+u+vJFQ5C70v5g/S
    yF6OxH2VhvWXUuJe/kPJvFWFgHw3094AjfLrUbFGisNDnkW668nvkF8NhKCScn7J4EJh77
    ahSS5V1ETo2CzYQH+jCMmm4y1/uXBcdLDLVcijg+NXRiCjJHZEB41E1YQSe2+xQZttasxC
    qEDiFyZXjD0GpAfhLPGq94CxzTD0vLrefcy7f7W3Jo2PLM+jZnoD7430dkGV0UsLpQNqtV
    bgfk06njCCOv9aQn9MgbzNo1veUyssmjSyq4m3Myw49ygqsHNk2G6L5GO5426F7NG2SmUX
    wOmpm/tAT93UInr0UoCxyENOjkyIUfCYHrFY/3JTKSTFtB8symNH4vgTr+cppsBuohah5Q
    9N+PEiLz1TR/R6foJuSSDYvbOMvvxgV9SDHRN/Oq4zsEbU7DjnrzIQNR0xPTtqOqjSS5m+
    eg1cOI47B0jy3o1p4Ump4XAgp6mlNgQOmqMxABvASpry5wvyDNDA9cmkdDElY/VSawMiDw
    n1npDvvSL1lcnT4hrQ5LsYVhj9RhQjMOAuUE1OZtZZo/F5ozy0PlXWF3MxmntE88B/Tv5D
    2US8KQ1mhbxy9hgXrbhbzkcnq7jGnx5I/xnDRp/X4LqPUlw05RgZGIjQYUNg
X-ME-Proxy: <xmx:6YWhakXJJWibP5GdnZ9G1Rg7xZSPur7L-vyteIp3samdwy1ln0XoMA>
    <xmx:6YWhapBmKL6MTkTprNL1vVWov2Wl4E_d29_eEfRh26KVAUrUulymqA>
    <xmx:6YWhapEHIHlWB2XCrzVhC9PKe5F9RFeH7R-W1PketxpVrnlsNTEciQ>
    <xmx:6YWhaq5l54jA6UpYRvp-KbEnQihEV4C9N4VzaHFbLAX5mH6DzNNYVA>
    <xmx:6YWhavnX7kM6X_K8mdfi9xjl509ryFRu4NOdvg3xGtK0GfmWXmZ4C_iZ>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id D3F297811F4; Wed,  9 Sep 2026 12:14:33 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AgpFG2YqzZmg
Date: Wed, 09 Sep 2026 12:14:12 -0400
From: "Chuck Lever" <cel@kernel.org>
To: tmenninger@purestorage.com
Cc: "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, "Tejun Heo" <tj@kernel.org>,
 "Lai Jiangshan" <jiangshanlai@gmail.com>, linux-nfs@vger.kernel.org,
 linux-kernel@vger.kernel.org, "Eric Badger" <ebadger@everpuredata.com>,
 "Jon Curley" <jcurley@everpuredata.com>
Message-Id: <48e8b6c6-dc62-4630-b7c9-19cdcc5cbf11@slotpi15m67>
In-Reply-To: <20260908233952.983071-1-tmenninger@purestorage.com>
References: <e485f23d-896d-4c01-9d24-eb3784a10dc2@slotpi15m67>
 <20260908233952.983071-1-tmenninger@purestorage.com>
Subject: Re: [PATCH RFC 6/8] SUNRPC: Reduce rpciod workqueue contention
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Tue, 8 Sep 2026, Tim Menninger wrote:
> Strict makes it worse. Across five runs, the three all-local CQ
> placements ran at 38, 36, and 39 GB/s, while the two split placements
> both ran at 46 GB/s.
>
>     cpu:         37 GBps
>     smt:         43 GBps
>     cache:       47 GBps
>     cache_shard: 47 GBps
>     numa:        47 GBps

Thanks, that settles the scope question. Anything at LLC size or
larger is OK on your box, finer is worse, and the pool-lock cost
the series was after does not show up there at all. I'll drop the
patches that change the WQ affinity, for now.


> The lock profile is dominated by __slab_free in both cases.
> ...
>     __slab_free:
>         2.07M contentions
>         3.83 minutes aggregate wait
>         111 us average wait

That is on the order of twenty CPUs on node 0 doing nothing but
spinning on one lock, in every configuration you measured. It is a
much bigger target than the workqueue scope.

The lock is the SLUB per-node list_lock for the nfs_page cache.
Since 7.3-rc1, every ordinary kmem_cache gets per-CPU sheaves by
default (for nfs_page, 60 objects per sheaf), and a plain free
lands in the local sheaf without touching list_lock. It reaches
__slab_free only when a CPU's sheaves are full and the per-node
barn, which holds at most ten full sheaves, is full too. Then the
whole sheaf gets flushed to the slabs under list_lock.

Your workload appears to defeat that optimization: nfs_page
objects are allocated on the application CPUs across both nodes and
freed in bursts by rpciod on the CQ CPUs. The freeing CPUs never
allocate, so their sheaves stay full, and a 600-object barn is
microseconds of buffering at your free rate. If that is what is
going on, it is an allocator scaling issue rather than an NFS one,
and the right place to take it is linux-mm and Vlastimil.

Before that, I'd like to confirm this analysis. Could you:

1. Check that sheaves are actually on for that cache:

       cat /sys/kernel/slab/nfs_page/sheaf_capacity

   A zero means your kernel predates sheaves or the cache has debug
   flags, and the contention is the older remote-free slab
   transition path. That is a different report.

2. Build with CONFIG_SLUB_STATS=y and sample these before and after
   a 10-second all-local window:

       cd /sys/kernel/slab/nfs_page
       grep . free_fastpath free_slowpath sheaf_flush barn_put \
           barn_put_fail barn_get barn_get_fail alloc_slowpath

   If barn_put_fail and sheaf_flush track the contention count, the
   barn limit is the bottleneck. If free_slowpath dominates and the
   sheaf counters are quiet, the frees are bypassing sheaves
   entirely and my analysis is wrong.

3. Run perf lock contention with -l on the same window so the lock
   shows up by address, and note whether the callers under
   list_lock are sheaf_flush_unused / __kmem_cache_free_bulk or
   direct __slab_free from kmem_cache_free.

4. Tell me the I/O pattern: direct reads, I assume, but the I/O
   size, number of threads, and how they are spread across the two
   nodes. I would like to attempt to reproduce the
   alloc-here-free-there imbalance rather than speculate.

I don't have a NUMA system in my lab, so I cannot recreate the
per-node barn directly. What I do have is a 24-core/48-thread Ryzen,
which is a single node but has several CCDs. The per-CPU part of the
imbalance exists without NUMA. If barn_put_fail climbs there too, I
would have a reproducer that does not need specialist hardware.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
