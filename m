Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0EF043B27EA;
	Tue, 15 Sep 2026 14:42:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789483355; cv=none; b=qHh1KdDbiLFf0xUdmSysSLVeQe2TGm+LIXParwDEtp3pgfsNqdR7ZgpxL7vxt4LDsh5Iq7iTnc8Hjeg2XoEWbLLVyGnTFi8qtym1mn5/CYEZytft8Mtv3kDdMIMJRB7vIyRjzXzGtoFUkdDNXx5emdE17mqtj3gH44Ub5YzJWcI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789483355; c=relaxed/simple;
	bh=ickl+2zDfTQbjyaPL4Rh/8CQDgE18ecbV/IT3WBI/i0=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=W/tGK5dhcRN5KTQM9JPMjqp7wwJ6uV7+eIZYhMYeNL8gNigzAYfOSdIrlJCyuS2imDFx2lY4/MFgt3Je2JSLH86X/15ph3GrigcZRsKl0WW/GkPB2mFy3x3CBzRG2w3t2tGShdOgZpq+t9Qg91xOHvY2jpz9csOiVFOH87C12Hk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=T3ZYfESF; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="T3ZYfESF"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 89A101F000FF;
	Tue, 15 Sep 2026 14:42:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789483354;
	bh=R6Sn9tHS94dBebsyQrNShHgYeNRxf1P570SRdVTEfsA=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=T3ZYfESFeN2nLeIfXS8QQoEGhu2itZJHHviQfmFLOXArzRHVflQCcNG1RXNRs8K7m
	 jgNQpwgB+QpzhfAelVIxIA0NkOqP20iXKw5g8+VlBLKmOhPo+qV1FuC6s+bZZG9jBG
	 gR4bjplbawqiFTimJTng0MVzCzE6kgA9Athf9/gb48y307UbzbGFqWycl4HN5wxDdb
	 vboQUJ2Y4prtV0I0k17184QFMFmMzjT6WB+rgAVdiU8dI7LY2a2XPpBfWpwcSe98D4
	 cJVr+69wbgqhEFkfDIetrAR55X10XCK04DLIrrBRC7Juy2xQcMBtdOlaqF89wRSbpH
	 TctXK19IueJ5Q==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id A7D72F40067;
	Tue, 15 Sep 2026 10:42:32 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 15 Sep 2026 10:42:32 -0400
X-ME-Sender: <xms:WFmpapq-fTX069gJK3zZD5sx2V8KfEoFKNRSzWSAXlpZst3k2F74tA>
    <xme:WFmpamdXT92d_jcCAIewSWQOtS7BqnBJAz5rHcr4iJ0prWCbifJ7vX1_fASlTuUIz
    B4nwTUaDA_NKEAAoJfHFkWByeGH8lNofSORZLvxsOsnsCh5pnOhqi2E>
X-ME-Proxy-Cause: dmFkZTFnQKWruoqqk1Bu2jqcyymJE52r+NTfuwTFKG9wmdAefwZ9tdYJWthsdezA2zXjdR
    OUp48kSA6gqHI4cH2fJttWlxE44bW1k3jMj8YW7+h+6Pc+ebDHVTxjvf2QIlrKQmBOM2as
    B1sfAA1OUJ8RWS8+wK+7GC3g5u9XLJ3Ek1vgugYzWxMVMAoISMxZAdj08CcR42qMbCQi/u
    Z/VMDmpsPvmKRgOCYtXVLpRw5Cr3+rsEkMmgk812uRzxvplzr8W+ZcBKZanhN2ZoZT1WIa
    hvEYoXMCxLzWgM/Q5daeLVqN8/VOyfHFtVtKpkkOQbQd20Av5rOZ1d0V7bcAD19sMwR3Zf
    NME+qQIe2JpqbZq7VCLxNymNDM94nEFSRiFeu3gHE8QC9aSaP96cvQhBAhBT6S/6/m+izS
    2agdldUlMFpY3Kcia4NRlVWkEMXQDjIw762y9lAm4x5K8nsC2xhO8y9EUWn7fLwgnx0ZWv
    OpraxYvSIU3UZfQxQ7DaHRR89mqElQZiahMMOXHVDE1IS0RpoLL4q11jXVX8tXIGaHuxsh
    TUfAOOkSxymxXzSWtvHsqhQNE1j7e/5OfISOfEtN5CgKBs8gnlqzWIzRR/2C2Ju61bBGze
    TdyYoJLCwSTZT1PSj0dUwlWOS8p/6HpguVUanzB+FJ8aGT17tN6li4EfVytA
X-ME-Proxy: <xmx:WFmpag5a5ETMFasqV-whpO_--49bSM9UwOX8rqKxb0qPbJMA4GstfA>
    <xmx:WFmpaiWirLiQK3N4tUauf_PkE8qyDUS72K1EZ36goNynVH6EqdKJjg>
    <xmx:WFmpagJEURR9eInt93df1ehLo4iSj83tXTu6O3J3K7tAtktykWZsOQ>
    <xmx:WFmpasunV48NH90HhZhEoFFlYURwAmoXlxHmZbaWdiUqdQnDZat3YQ>
    <xmx:WFmpalIM3fUMmxhmVV5TkAqntIfMltPV-XRveh7yAkWTdLD97sSZ_6JI>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 7C712780070; Tue, 15 Sep 2026 10:42:32 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AgpFG2YqzZmg
Date: Tue, 15 Sep 2026 10:42:07 -0400
From: "Chuck Lever" <cel@kernel.org>
To: tmenninger@purestorage.com
Cc: "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, "Tejun Heo" <tj@kernel.org>,
 "Lai Jiangshan" <jiangshanlai@gmail.com>, linux-nfs@vger.kernel.org,
 linux-kernel@vger.kernel.org, "Eric Badger" <ebadger@everpuredata.com>,
 "Jon Curley" <jcurley@everpuredata.com>
Message-Id: <0e2f9688-097c-4bb9-a7ec-82b41bdb3653@slotpi15m67>
In-Reply-To: <20260914173958.2045683-1-tmenninger@purestorage.com>
References: <611738b5-e115-4531-8d08-62607dc7f8ff@slotpi15m67>
 <20260914173958.2045683-1-tmenninger@purestorage.com>
Subject: Re: [PATCH RFC 6/8] SUNRPC: Reduce rpciod workqueue contention
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Mon, 14 Sep 2026, Tim Menninger wrote:
> If I am understanding correctly, the SLUB/barn/sheaf behavior we are
> looking at here is pre-existing rather than introduced by this series.
> The SMT affinity change is what changes the placement enough to expose
> the remote-free cost on this workload.

That is the basic idea, but there are nuances. Split it into
three pieces with different owners:

1. The list_lock contention is pre-existing and does not bound
throughput. Your numbers show it directly:

                            unpinned    node0 pinned
    contentions             3.346M         3.353M
    aggregate wait          5.05 min       4.01 min
    node 0 idle             0-2%           66%
    throughput              43.4 GB/s      46.5 GB/s

The lock is taken just as often in the run that has full
throughput and two thirds of node 0 idle.

I have since reproduced the acquisition rate here, on a single-node
EPYC 8224P (24c/48t) reading direct 1M blocks over NFS/RDMA at
12 GB/s, with the barn depth made a runtime knob and
CONFIG_SLUB_STATS on. At depth 1, 28% of barn puts fail and
free_add_partial takes list_lock 5.0M times per 10 seconds, the
same order as your 3.35M contended acquisitions. Total wait on the
lock in that window was 36 ms, and throughput did not change at any
depth from 1 to 64, nor with the work spread across all 48 CPUs,
nor with 16x the in-flight population at iodepth 256.

So the acquisition rate is ordinary. What is not ordinary is your
72 us average wait, against about 7 ns here. That is an allocator
question, and I'd like to take it to linux-mm with your numbers.
More on that below.

2. The throughput loss in the all-local placement comes from the
70M remote frees per 10 seconds, not from the lock. Pinning the
workload to node 0 removed the remote frees, returned 3 GB/s, and
left node 0 two thirds idle with the lock profile unchanged. That
cost is a function of where the CQs land relative to the
application threads, which the RDMA core decides at connect time,
and it exists with or without this series.

3. The smt scope costs a further 4 GB/s in that same placement
(43 vs 47 on your scope ladder), and nothing in the slab data
explains it: the frees stay on node 0 under both smt and
cache_shard, so the scope is not what moves them across nodes. I
don't have an explanation.

Since you have a robust reproducer, can you take this to the
linux-mm list (cc me) with the following three items (no new runs
needed for the first two):

- The debug config. Any of these lengthens every list_lock hold
  without disabling sheaves:

      zcat /proc/config.gz | grep -E \
          'DEBUG_SPINLOCK|DEBUG_LIST|PROVE_LOCKING|LOCK_STAT|KASAN'

- The CPU model and socket count.

- A cmpxchg_double_fail delta from /sys/kernel/slab/nfs_page over
  the same 10-second window as your other counters. __slab_free
  drops list_lock and retries when the freelist cmpxchg fails, so
  a large number there means each logical free costs several lock
  acquisitions. Mine was under a hundred.

One more thing I can't reconcile: 4.01 minutes of wait inside a
10-second window is 240 CPU-seconds, half of node 0's 48 threads
for the whole window, which does not fit 66% idle. Were the perf
lock capture and the mpstat sample the same 10 seconds, and did
perf lock cover all 96 CPUs or only node 0? If the wait is real,
node 0 spends half its time spinning even in the good run, and
the lock is where the headroom goes once the remote frees load
the node. If it is an artifact of the window, the lock costs less
than the profile says, and the report to linux-mm is a simpler
one.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
