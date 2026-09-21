Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C643A4BB28E;
	Mon, 21 Sep 2026 15:31:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790004717; cv=none; b=Q434pHUWcgvbixnQ/Zstb8DeyWnQDJOe8W0QWguuxWFBefwdvN1188SsoIklsZJsQ0UruYGF3wpdD6XlDxEfuYm9O3CtpADxypGuMPcm5X45KA1BRDO0e9Co+5yBNwqvTVYNOTNK53SK5Ju5Cb4+WKuakHkdDDLpMC8PZCspNu4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790004717; c=relaxed/simple;
	bh=Zhun9bmg0CRQi5K4hjUQKXMbPDPpc1D1fATRLPF5MqQ=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=qEY/QoV3dgJQqEnMAx0t+nMJD+T/OvXaCqlgeWtQ/ws110t4Qq4jAi72UwmnSglonPzo7s+lCQehMbdrCrBDcF7TUNQqZLZhexQ7hI0gEvtpYq7neOMYM5aglFiz5E+4+ekOIKUecnj5kLBVxBr01+laMdUkex2QNG2IN9VKfzg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=BpWnWfx2; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="BpWnWfx2"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A0C741F00898;
	Mon, 21 Sep 2026 15:31:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790004716;
	bh=FuUrqWc9bTGN2ILuKnc9hMdv0vV4JMwCLib1Eff7GPo=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=BpWnWfx2ds3Fe0emxSeG9TZPaU0fjs6BNTQP9KkoI+3KJtqZ/c53fPAcFTUWz4E1b
	 23fgyM9QIldp/Ud7j2JcDXbZR7MY3ffMBZMYTMjb7RHPDAQdV9oFWu/rPLi9x75GdW
	 wqLix0oxA7ZjiuZuAA5szff+krYbGlVAY60Gh+q5/5mdR9xpLfCA1oHMoqB6akI1o5
	 xPtXZ8W9vQG4uA61wqDz1XOlOPTV8POlHsKzV5yG8b+GNPUIXpVntti06qvivtGb+H
	 4qVvcrlSiYCVXujkEwaEmTL5GzWaUz1EzJqeRGnEicy8fFZx6Er5LvVSJrxOpJSCqA
	 krGUh0imuKFzA==
Date: Mon, 21 Sep 2026 16:31:53 +0100
From: Harry Yoo <harry@kernel.org>
To: "Vlastimil Babka (SUSE)" <vbabka@kernel.org>
Cc: Tim Menninger <tmenninger@everpuredata.com>, linux-mm@kvack.org, 
	Chuck Lever <cel@kernel.org>, linux-nfs@vger.kernel.org, Jon Curley <jcurley@everpuredata.com>, 
	Eric Badger <ebadger@everpuredata.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Hao Li <hao.li@linux.dev>, Christoph Lameter <cl@gentwo.org>, 
	David Rientjes <rientjes@google.com>, Roman Gushchin <roman.gushchin@linux.dev>, 
	Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, 
	Arnaldo Carvalho de Melo <acme@kernel.org>, Namhyung Kim <namhyung@kernel.org>, 
	Mark Rutland <mark.rutland@arm.com>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, 
	Jiri Olsa <jolsa@kernel.org>, Ian Rogers <irogers@google.com>, 
	Adrian Hunter <adrian.hunter@intel.com>, James Clark <james.clark@linaro.org>, 
	linux-perf-users@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [SLUB] nfs_page cmpxchg_double_fail and perf lock perturbation
 on dual-socket NFS/RDMA
Message-ID: <arFNKeseUHBvdRCA@thinkstation>
References: <aqvy8NqRRRmUlxjR@thinkstation>
 <20260917162533.600472-1-tmenninger@everpuredata.com>
 <8705aa4f-5e02-45e7-ad45-0baa982a8c02@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8705aa4f-5e02-45e7-ad45-0baa982a8c02@kernel.org>

On Fri, Sep 18, 2026 at 09:08:37AM +0200, Vlastimil Babka (SUSE) wrote:
> On 9/17/26 18:25, Tim Menninger wrote:
> > It reproduces with slab_nomerge.
> > 
> > I booted the same kernel with:
> > 
> >     $ cat /proc/cmdline
> >     ... slab_nomerge ...
> > 
> > Uninstrumented throughput remains in the high-45 to low-46 GB/s
> > range, as before. During perf lock it was around 30 GB/s in these
> > runs, versus roughly 25 GB/s previously.
> > 
> > The dominant lock measurements are essentially unchanged:
> > 
> >                          default             slab_nomerge
> >     unpinned/node0
> >       contentions        4,782,839             4,858,759
> >       total wait          14.39 min             14.26 min
> >       average wait       180.47 us             176.13 us
> > 
> >     node0/node0
> >       contentions        4,582,012             4,686,729
> >       total wait          14.13 min             14.34 min
> >       average wait       185.05 us             183.53 us
> > 
> >     unpinned/balanced
> >       contentions        4,572,196             4,544,677
> >       total wait          12.81 min             12.56 min
> >       average wait       168.14 us             165.84 us
> > 
> > The uninstrumented cmpxchg_double_fail deltas were:
> > 
> >                          default     slab_nomerge
> >     unpinned/node0          7,471          8,892
> >     node0/node0               713            457
> >     unpinned/balanced       1,503          1,504
> > 
> > The CPU-utilization change while perf lock is active also remains.
> > System-wide %idle for uninstrumented/instrumented windows was:
> > 
> >                            default                  slab_nomerge
> >                        uninstr.   instr.         uninstr.   instr.
> >     unpinned/node0      31.46%    3.60%           23.02%    2.15%
> >     node0/node0         84.26%   12.07%           84.62%   11.85%
> >     unpinned/balanced   66.86%   14.83%           66.58%   14.78%
> 
> I believe the weirdest part in the original report was how slub stat
> counters such as free_fastpath etc got order of magnitude higher with
> instrumented vs non-instrumented.
> Did any of that change with slab_nomerge?

If it didn't change, that'd be very surprising.
... unless perf lock was writing data to an NFS filesystem?

-- 
Cheers,
Harry / Hyeonggon
