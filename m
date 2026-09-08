Received: from mail-wm1-f100.google.com (mail-wm1-f100.google.com [209.85.128.100])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ACB09491585
	for <linux-nfs@vger.kernel.org>; Tue,  8 Sep 2026 23:39:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.100
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788910797; cv=none; b=gsu/lfeCmCGauCZEBt6CdqoNLuj15GqkQuhIInG1qWW7mbb6FR4dFMBPFDmJNdsD7ZzIuQRGb1SSG77BRxgwwIZ8BO0m4CEGawH86Jrx2yGhRtl0bGALYgLCatkcmQSNMJLAbrdQRBaHqGlnAITfskWh4STbYqGAqpPha5aHmWE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788910797; c=relaxed/simple;
	bh=D2jVhLlEbn2PMCzZGGIgLkw/AOLFI2NnZhJjVP1yeSg=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version; b=MRiviYTFlnGo/BM4juDxBwiMTgNQ2hhHuz+MySmyRu3xI+OKFG5kVmkrxTXtHTQl8OuKNUwDk2bOk18jLhGY1ZqiEWJpvSQ6CysAgWsmTlSOI2sKlDJp/p+hIuIrzG+n/cdjWgsUAPCcORMxe8DXjpaS0sW2k1HQugP2q1GGoM0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=purestorage.com; spf=pass smtp.mailfrom=purestorage.com; dkim=pass (2048-bit key) header.d=purestorage.com header.i=@purestorage.com header.b=BIDw4oIN; arc=none smtp.client-ip=209.85.128.100
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=purestorage.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=purestorage.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=purestorage.com header.i=@purestorage.com header.b="BIDw4oIN"
Received: by mail-wm1-f100.google.com with SMTP id 5b1f17b1804b1-499ae1c6471so47242265e9.3
        for <linux-nfs@vger.kernel.org>; Tue, 08 Sep 2026 16:39:55 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=purestorage.com; s=google2022; t=1788910794; x=1789515594; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=X0rqYShxThXy3CC0bg0RAJQ9TU0wa85XEHflEV7UeZ4=;
        b=BIDw4oIN9+FDfKC3h9WqFKxbtOmiAzZWLViSwmElf5hhnicDvJg0Q1ZGCuV8SdAAdT
         u2jz6LKxWV83ttE5r6WI6cmWW24vKGWTzlHOY3OhR6zHF7ABkieyrrtE3jWwK5A9DAlC
         pIy0PSJSTHsS58AvCUMWlMEtQUcMoNydT7+1Or6z3WlUsQiQeFo/i7ZzIGctsw9dfKZH
         W8L0K/O4pqdc+mwIoiLNEPUfi/tDZpJeMXra/k1+VjxwZnJrx4BS9PRQPfdY4y+FCZzp
         0w4vD4r8NYpwovxQWH+dxv93gNipNQ3t1YX2Urq5bOrjlG0Ue3QlAntRk6vv/Oe2QFYR
         4xmQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788910794; x=1789515594;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=X0rqYShxThXy3CC0bg0RAJQ9TU0wa85XEHflEV7UeZ4=;
        b=Vo0XW5i/Fe4W9UXzUtTJyPAi6T44hu+H5I9a0vPA8EEjD9X+eZy4EWwWo57/LaZPsX
         PWbsW4jyj0Uq5nGR57JpCBrX0kN3Zl7wy0eaPp64mvNZZRSB2OOYsDQNxE7dkwqwls30
         e4UAoL6IPABERGuo+H5NpsUMQeOoiFH+xGy/Vme2s6QGohhz30e6F6t7rVm/y9P4TpMG
         UczGEfX59Zg0VWucAjY0KxfIPD92tF2DC14EF1jqmYyUFIifGfdj+XimbQdRY7psevGo
         vW9qVZxfYemF0V+9ph+roRsZvG7GPpStEZVwDOjb+SGecL8CTGq9QYonpgLAbPcEHv+0
         n5qg==
X-Forwarded-Encrypted: i=1; AKwUvBxdiCbJAwRiqfu8reG6qgv8mPFjRVdG3b/JEFmtusIOVf9Kc/wcWT72hrkIlVW2RLSQWYdOYwOUOtA=@vger.kernel.org
X-Gm-Message-State: AFuF++lnsEGTUdKUgpvCfQMnPWOVd58gMpVf0vQz07r+vJ8GapvFqrGb
	6KSXYqBFxH10+iFqHQ2dAA+7ocGQTwckS9aPzsX2P3Tq/3PMI31OAaQ2Ro0cW+odl4TnTI9jwl/
	sDLx+SCtibvSH5l6Ne5pSJ6pFdgI1MbyTcP0q
X-Gm-Gg: AYBFou0pRHB5ZZYfMoNaOe5lNSL0tLDTcGqFOE/hYbVI07V8J0fidRGo0NT3/JWWVty
	u3mBm3sZKhkJfDGybZ6nazcSztqUwmsqXXfGFII8C0qfctvH09ukQptYYQuP13AGQqOcoeU4PEp
	59tJJNx1Ae4PFd/eMuoIkpnkCKa0rZYVJZWA4fBb4okUp2vjoe1wG7UrzI+RkJa7AUx8Uvkt9em
	aSo4i711+ZkmzH/QXcBY+AXt8W9/FqnDmb1vC/SwAmtjIEbpqpZyYMulX2w97isX3Y3/k3osiLA
	PTS10woPgCAWHGWqcwaLUZoTPaHfGJ9nqJHzzojNmEaQYTVlHS2WHh8+iSVZkrO49f5C1TAwaZK
	a7d3VGVjQXOkoWCSny1jMOOaC2OmSfe88Wn+bPg==
X-Received: by 2002:a05:600c:a08e:b0:49c:f7c4:dc54 with SMTP id 5b1f17b1804b1-49d1f36c5ccmr51259115e9.14.1788910793881;
        Tue, 08 Sep 2026 16:39:53 -0700 (PDT)
Received: from c14-smtp-2023.dev.purestorage.com ([208.88.158.129])
        by smtp-relay.gmail.com with ESMTPS id 5b1f17b1804b1-49cf7707de9sm70874045e9.8.2026.09.08.16.39.53
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 08 Sep 2026 16:39:53 -0700 (PDT)
X-Relaying-Domain: purestorage.com
Received: from irdv-tmenninger.dev.purestorage.com (irdv-tmenninger.dev.purestorage.com [10.32.149.15])
	by c14-smtp-2023.dev.purestorage.com (Postfix) with ESMTPS id 4D55634029B;
	Tue,  8 Sep 2026 16:39:52 -0700 (PDT)
From: tmenninger@purestorage.com
To: Chuck Lever <cel@kernel.org>
Cc: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Tejun Heo <tj@kernel.org>,
	Lai Jiangshan <jiangshanlai@gmail.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Eric Badger <ebadger@everpuredata.com>,
	Jon Curley <jcurley@everpuredata.com>
Subject: Re: [PATCH RFC 6/8] SUNRPC: Reduce rpciod workqueue contention
Date: Tue,  8 Sep 2026 23:39:52 +0000
Message-Id: <20260908233952.983071-1-tmenninger@purestorage.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <e485f23d-896d-4c01-9d24-eb3784a10dc2@slotpi15m67>
References: <e485f23d-896d-4c01-9d24-eb3784a10dc2@slotpi15m67>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

> cache_shard is the system default, and that is what the workqueue
> used before this series

Right, bummer, I was thinking default was WQ_AFFN_CACHE.

> 1. Toggle affinity_strict under smt:
> 
>        echo 1 > /sys/bus/workqueue/devices/rpciod/affinity_strict
> 
>    Strict pins each pool's kworkers to its SMT pair. If strict
>    recovers throughput, the loss comes from non-strict workers
>    being wake-affined or migrated onto the saturated node. If
>    strict makes it worse, node 0's pools are starved and the fix
>    is to let work spill to node 1. Either result cuts the
>    hypothesis space in half, so if you have time for only one of
>    these, this is the one.

Strict makes it worse. Across five runs, the three all-local CQ
placements ran at 38, 36, and 39 GB/s, while the two split placements
both ran at 46 GB/s.

> 2. Walk the scope ladder: cpu, smt, cache, cache_shard, numa, and
>    report throughput for each. If cpu is as bad as smt, pool
>    granularity itself is the problem. If cache already recovers,
>    the threshold sits between 2-thread and 16-thread pods.

    cpu:         37 GBps
    smt:         43 GBps
    cache:       47 GBps
    cache_shard: 47 GBps
    numa:        47 GBps

> 3. Profile the smt and cache_shard windows of one run, node 0 CPUs
>    only, so the two captures differ in nothing but the scope:
> 
>        perf record -a -g -C 0-23,48-71 -- sleep 10
>        perf lock contention -a -C 0-23,48-71 -- sleep 10
>        perf stat -a -C 0-23,48-71 \
>            -e context-switches,cpu-migrations,sched:sched_wakeup \
>            -- sleep 10

The lock profile is dominated by __slab_free in both cases.

For smt, perf report shows:

    native_queued_spin_lock_slowpath     87.07% self

and its callchain is almost entirely:

    rpc_async_release
      -> rpc_free_task
      -> ff_layout_read_release
      -> pnfs_generic_rw_release
      -> nfs_pgio_release
      -> nfs_direct_read_completion
      -> nfs_release_request
      -> nfs_free_request
      -> kmem_cache_free
      -> __slab_free
      -> _raw_spin_lock_irqsave
      -> native_queued_spin_lock_slowpath

cache_shard looks surprisingly similar:

    native_queued_spin_lock_slowpath     85.84% self

with the same nfs_release_request -> nfs_free_request ->
kmem_cache_free -> __slab_free path dominating the profile.

perf lock reports the same general picture. For smt:

    __slab_free:
        2.07M contentions
        3.83 minutes aggregate wait
        111 us average wait

and for cache_shard:

    __slab_free:
        2.27M contentions
        3.65 minutes aggregate wait
        96 us average wait

process_one_work itself is much smaller:

                        smt             cache_shard
    contentions         34              2087
    total wait          91 us           7.13 ms

Scheduler counters:

                        smt             cache_shard
    context switches    2,184,584       3,107,991
    CPU migrations        129,706         499,400
    sched_wakeup        1,176,787       1,776,031

>    The two candidates I have in mind are a downstream lock, such as
>    the transport's queue_lock or recv_lock, contended by 24 small
>    pools running completions in parallel; or scheduler overhead
>    from each pool waking its own kworkers. The %sys, %irq, and
>    %soft columns from the same mpstat runs would help too, since
>    idle alone does not say what the busy CPUs are doing.

For the all-local case, essentially all of the busy time on that node
is %sys. %irq and %soft are both approximately zero. A few CPUs have
low-single-digit %usr.

For the 17/15 split, CPUs 0-2 have low-single-digit %soft, but aggregate
%soft is only about 0.10%. Otherwise it looks the same: the busy time
is overwhelmingly %sys, with a few CPUs showing low-single-digit %usr.

> 4. With the even 17/15 CQ split and rpciod at cache_shard, a perf
>    profile shows whether the pool-lock slowpath the series targets
>    appears on your box at all. If it does not, cache_shard is
>    correct for your system, and the series needs a way to express
>    that rather than one hardcoded scope.

It is present, but it does not appear significant compared with the
slab contention.

With the 17/15 split and cache_shard:

    process_one_work:
        5,598 contentions
        29.33 ms aggregate wait
        5.24 us average wait

In the same 5-second capture, __slab_free has about 1.61M contentions
and 2.66 minutes aggregate wait. get_partial_node_bulk and
__refill_objects_node are both around 19K contentions and ~200 ms total
wait.
