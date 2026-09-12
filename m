Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AB399309F08;
	Sat, 12 Sep 2026 15:50:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789228211; cv=none; b=sftykAY9VGIIEg2ljpx5nETcRrbqXyeMUUZCEFFKrrOkMhQ2R63PX68jB3yOnP6P0K9ida4+mVNAv8U+6EIdvr5esX3w5U52mg7LdY2BzD4FAqmFAj5NN2lrP2lyrdNGu6vHLVDUmDmohPO42GiaiLl8cWNpXIt2Y99qMPltmHY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789228211; c=relaxed/simple;
	bh=SqX45cSexAwma2sfoPrWq11l59nyG2V0B5+reMu3PpI=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=GpVCqIthr6/E6EYO3YP3OCS7hoOjCBWTLS8tGOouAT2mtLhe8QgRgqRODMxV3v3T3PPIvL53hObRZ2u8Ikp95Q6910DYIOBWQvDW+z+3LinV/KmKMKBEx1svljv51ytW21DRigHpkw9TRSJS+/T/quRHwOsu837rD6AhxOzuzjU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ZHy6FG+0; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ZHy6FG+0"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 29A321F00893;
	Sat, 12 Sep 2026 15:50:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789228210;
	bh=/jXriT0LBtwCGebid8xL0Vq86DNF4IhBfxaOu4ms12I=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=ZHy6FG+0D3RiiTN34quBEaXnPhDsjAWhcGGC4gz4xAQpBtkR8JLcv8MOObe50K0EM
	 hcwoWhUzKwrdxHrT+GAdpBnMTGvlRMd6tgonKD+0akNqB+uDelwxI6NEunQQK0+KOy
	 x3oVQWYGAJyT7PlnkD70deRlTr9Y+VppggvuuKzprEMLxendYw3XHDIKCYwNzskQCt
	 AOiqkIAWMR8cdXu4fiE7BlF+ppcNfuiVpJKGH/fxNTDTNLlfIS5e2C4sv4FeFk2r/R
	 xTCOcqkZ7YlOzhDIucv8NTwlJyit8a/vdFFBJZayD8CQOOQqcbRaZSyiq3VpT9lOmJ
	 uKvTadc4prWVw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 31B7CF40066;
	Sat, 12 Sep 2026 11:50:09 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Sat, 12 Sep 2026 11:50:09 -0400
X-ME-Sender: <xms:sXSlag3tcFvmghcP65QibBbGsPDdXf1xkzm7nSaJEdqUJ-b8crBq-w>
    <xme:sXSlal5wmQ3wrTgJg3HX0QRCETODFUilRjGsi38tsBqfpwJwmaUhMcsfjOFNxYgRH
    qVbiEeBij7vScFZxH9zHVjjx430QtEVfQvIowYXyqHT_kHhBHmQVyA>
X-ME-Proxy-Cause: dmFkZTGVwn5kOo/uZq5shYrwT5pZn57c9Il78RFXvR5MxG768BWMf/RLTlbjYvwXrP8YQ/
    h6GERoCOfwWttJd5YXoYzG9wB18+8l2OESXiJuUEYWP5yyKxmC2RTfebu1tyICZVB+B4uO
    N5EReYOc7B6A4vAHr0yG8hWP521B0URtKfu9qv/7jf7wbBXr3toPZ05SmlgDPb/1KtJZbe
    W/1h0AkqQ5nZ+eMNpiEnXfvCQgPZnyy50PY0RvRmPcnUPV0gr/RUSLofw9KlG5LHmPGIbp
    PT4Do6FnynEUeUy4wcmU0FOHiIphVaR8UUSt6mPy0ltnITNASiGND7hXLJDY2I41GVpoUo
    fCU8bvYQaPiqDsyLVTJVm+QzUJQTNaUAXxPMzkv8vfgrkj3zeGWZYjAPmTz0iTKG74RMSZ
    rweK2d94PMf+pkBsH1mzrF2IuVhozxW5GSAkL0p40+DIouR+rFb9nnL4//9Og4K1pXAfcq
    jMPL9qoatgxEqDxMvYooPUG1YOHcWPyEj3YfRPWjlVrtCFFpyC2cvdWBA42j3exYJNvKgF
    pDtYLkLQw0b5i/MIxgkCMuuUR4AZ/L+WLNgD3VRSPj3JfMcJt3f0Rf3i/5x+UMceiDphdD
    hfZPrAKiL0Sqpjc2b/USuAdvz6ZV9aOmard8Oby8hTITNlxuLkf7saWzO54g
X-ME-Proxy: <xmx:sXSlalFSejhhpqfpF45vdQ6eHaBGGoQD0jXwHb7NuhaGjgG3LjarDQ>
    <xmx:sXSlaqyIVyT79WKmsSoJWxGuDX8ddmB3gCGQoj4dauZP6R3h2dZDxw>
    <xmx:sXSlan21pg2xn4juRn15Lrji9TgEGFAHxd4z54K7M8QcUCzcdnkrnQ>
    <xmx:sXSlaip7EcTNXhmnOjDj9Y6PwU6h6wZfE004m3nZ8EuhdKxeki3Lqw>
    <xmx:sXSlasVld5rwPWyBdWEphnweQ2FjPf1Ju5Qd97Vkz_biaLKV_vSTHZM7>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 05333780070; Sat, 12 Sep 2026 11:50:09 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AgpFG2YqzZmg
Date: Sat, 12 Sep 2026 11:49:44 -0400
From: "Chuck Lever" <cel@kernel.org>
To: tmenninger@purestorage.com
Cc: "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, "Tejun Heo" <tj@kernel.org>,
 "Lai Jiangshan" <jiangshanlai@gmail.com>, linux-nfs@vger.kernel.org,
 linux-kernel@vger.kernel.org, "Eric Badger" <ebadger@everpuredata.com>,
 "Jon Curley" <jcurley@everpuredata.com>
Message-Id: <e18e121c-5c05-4caa-96ea-e0886594ee07@slotpi15m67>
In-Reply-To: <20260912145926.208269-1-tmenninger@purestorage.com>
References: <48e8b6c6-dc62-4630-b7c9-19cdcc5cbf11@slotpi15m67>
 <20260912145926.208269-1-tmenninger@purestorage.com>
Subject: Re: [PATCH RFC 6/8] SUNRPC: Reduce rpciod workqueue contention
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Sat, 12 Sep 2026, Tim Menninger wrote:
> 10-second deltas:
>
>     free_fastpath:    +49,161,373
>     free_slowpath:    +70,391,872
>     sheaf_flush:       +1,582,440
>     barn_put:            +673,877
>     barn_put_fail:        +26,374
>     barn_get:            +673,860
>     barn_get_fail:     +1,199,576
>     alloc_slowpath:             0

Thanks. No worries on the delayed response, IMO there is something
here worth digging out.

Your results confirm the barn-limit theory was wrong. The frees are
bypassing the sheaves.

can_free_to_pcs() refuses any object whose slab is on a different
NUMA node than the freeing CPU. A remote free goes directly to
__slab_free and never refills a barn. With elbencho unpinned and
every CQ on node 0, rpciod on node 0 frees every nfs_page object
that a node 1 thread allocated. That is the 59% slowpath share.
Node 1's barn stays empty, so its allocators refill from partial
slabs via __refill_objects_node and get_partial_node_bulk, the
other two callers under the contended lock. The contention count
fits as well: __slab_free takes list_lock only on a full-to-partial
or partial-to-empty transition, and the bulk refills keep slabs
full.

Still unknown is whether this lock bounds throughput or only
absorbs idle CPU time. __slab_free led the lock profile in both
placements, and the split placement still ran at 46 GB/s.

To separate the two, keep the all-local CQ placement and pin the
workload to node 0:

    numactl --cpunodebind=0 --membind=0 elbencho <same args>

Sample the same nfs_page counters and perf lock -l over the same
10-second window. free_slowpath should drop toward zero.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
