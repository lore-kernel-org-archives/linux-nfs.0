Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 955813CAE75;
	Fri, 18 Sep 2026 07:14:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789715649; cv=none; b=oLngFfnSY0xUVoRvD3b0+wDskuVixJR9ws0IJgd21/UR1Wq64gBW/6Csop/wjTL/4Ku8YuRdE9LdskuxVEED4BA3ah99E9mYF8OVsraeg9mOIHweRvFtjRl26VQ+LO7JCxtLC/hLS2zOampKQ6cnl+bmJ8tENCHr8MxgmKj5RvM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789715649; c=relaxed/simple;
	bh=ydmkQPxhqPwIQuxAl2L1p97L9blpffUYBII7HgSj8ug=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=D+uybpcCnVjbx26t4p1HatqwwBYEC7XsPCf06YO48NiIlbvMSL+8Bzs8orntYRJ8NuG0YANPLeOkefyMM+Xy5Pj7Y33BhiKYdB+piY4dIcDN2Snfb1Mgg0eSHyU8HI4n1hcT3k5mZEKiXrfWZRaDmul7WX4WuL0P1J0ssaKTQ7k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=VwQ9+HE4; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="VwQ9+HE4"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3B8311F00893;
	Fri, 18 Sep 2026 07:14:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789715645;
	bh=qPja/cjHElFD0uzEegkx8fIwtmRtWZZ628xauj+vnig=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=VwQ9+HE4NY0tnT9IpCZZjkrYpUgU+Q3MI0b8/kYWYNXLBz0OBgneUCZ0sypjFtJsp
	 uk8yMrodDG/EeLJ8Cw8NNo8KiwNI51f8ZD8ksE/h0ATyzWe0rOhA2zD55Bv4UGXOqW
	 XN8cdNsIiGEswI8idXhx9LsXVV8pMBpdua0A2GKBMdibbYRuZmFHYhRVj+1e05f18V
	 eH2pa2QHQGVyGAQKDpc8Rp21vRQpejf9qtKhrlKELzpduu2vOfPRzZeJau0po3nnmS
	 8o+tIVL/BCsxVeANYa0wNC3Hgxqs9ydfhcyzw7TqvV+sVHAZ3QOve+6n3SeMFjIw8i
	 5ToAQGv9yBMiQ==
Date: Fri, 18 Sep 2026 00:14:02 -0700
From: Namhyung Kim <namhyung@kernel.org>
To: Harry Yoo <harry@kernel.org>
Cc: Tim Menninger <tmenninger@everpuredata.com>, linux-mm@kvack.org,
	Chuck Lever <cel@kernel.org>, linux-nfs@vger.kernel.org,
	Jon Curley <jcurley@everpuredata.com>,
	Eric Badger <ebadger@everpuredata.com>,
	Vlastimil Babka <vbabka@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Hao Li <hao.li@linux.dev>, Christoph Lameter <cl@gentwo.org>,
	David Rientjes <rientjes@google.com>,
	Roman Gushchin <roman.gushchin@linux.dev>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Alexander Shishkin <alexander.shishkin@linux.intel.com>,
	Jiri Olsa <jolsa@kernel.org>, Ian Rogers <irogers@google.com>,
	Adrian Hunter <adrian.hunter@intel.com>,
	James Clark <james.clark@linaro.org>,
	linux-perf-users@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [SLUB] nfs_page cmpxchg_double_fail and perf lock perturbation
 on dual-socket NFS/RDMA
Message-ID: <aqzkugwB_I5X2JYx@z2>
References: <20260916232227.4098143-1-tmenninger@everpuredata.com>
 <aqvq8-6IJBDer90O@thinkstation>
 <aqvy8NqRRRmUlxjR@thinkstation>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <aqvy8NqRRRmUlxjR@thinkstation>

On Thu, Sep 17, 2026 at 03:10:47PM +0100, Harry Yoo wrote:
> ... now I realize we need to add PERFORMANCE EVENTS SUBSYSTEM folks 
> as well ;-)
> 
> Hmm, sounds like perf lock is somehow triggering slab allocations
> and interfering the workload.
> 
> It could be because SLUB is merging nfs_page cache with some other
> cache that perf uses.
> 
> Could you please check if it reproduces with slab_nomerge kernel
> parameter?
> 
> On Thu, Sep 17, 2026 at 02:46:24PM +0100, Harry Yoo wrote:
> > Hi Tim and Chuck, thanks for reporting this to linux-mm.
> > Will take a look at this but let me Cc SLAB ALLOCATOR folks here first.
> > 
> > -- 
> > Cheers,
> > Harry / Hyeonggon
> > 
[SNIP]
> > On Wed, Sep 16, 2026 at 11:22:27PM +0000, Tim Menninger wrote:
> > > My questions are:
> > > 
> > > 1. Do the uninstrumented cmpxchg_double_fail rates above look abnormal
> > >    for this workload/topology, or are they within the range one would
> > >    expect from this degree of concurrency and NUMA placement?
> > > 
> > > 2. Is there a less invasive way you would recommend measuring the
> > >    nfs_page list_lock/freelist contention? I would like to distinguish
> > >    the steady-state behavior from what is observed during the perf-lock
> > >    capture.

You can use the BPF version of perf lock to check lock contention like
below.  (it only work with 'contention' subcommand.)  It won't create
a data file and just shows the result.

  $ sudo perf lock con -ab sleep 10

or

  $ sudo perf lock con -ab -E 5 sleep 10

to see top-5 locks only.

Thanks,
Namhyung

