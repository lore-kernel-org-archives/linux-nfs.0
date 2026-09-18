Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 95CAE399000;
	Fri, 18 Sep 2026 07:08:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789715325; cv=none; b=lxt6/v1JNFZpu9GirATi3bCCovltAGM3kxxSDwIYlEZ5EnQ1waolka/LdHRQ0/HxKDEkbPKIYp0paK2lAf7A8WshkraqcAjG9p6SH9qHm1UwfBML6XySr6Agk6OV9enGnQ4Zw8fJoybDKjxhq2/YO/nbwpZ7Ulz1IdfMrk9Wbvc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789715325; c=relaxed/simple;
	bh=X2eUEqkirypJ4tNw27O3rKlkmu6pev06r3OHZ0yobOM=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=eidJsPbsmfHQEu2mawFpDfaddX1xNO2CM8y5aIuZce38s3bG6X2dKe2ZDY++u0oY4LWs5MT2w9AQ5c37tta3ngF51ltWb5ElNi0s4eSyEJFyp9zp6CsKd7K4NOnCh6Nrj8iBjD+4lgHQS4Mp1yw8oLWX7LKQrGb4+6TqKKbAL4c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Awku+uV8; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Awku+uV8"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B3E9E1F000FF;
	Fri, 18 Sep 2026 07:08:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789715324;
	bh=WCL4dePjhuTX+CGE5tvS1dbBZl4n5dA5dLQyhLK3zT8=;
	h=Date:Subject:To:Cc:References:From:In-Reply-To;
	b=Awku+uV8pxJg2xgDDCtl5/l75ccjfY+SVllzMvrfHWYiQtLqHtEiXmIY92vIOOLqA
	 sw+p8lDtPlpSpOCo6STc40T4j4ymvTQ8miSZNMQeBBBm5EA7WucrIMgYeH8wuuM/DG
	 +BfgFttLkbWWOmkrZgLyIIMf/YZnzRxDgoxY8eXn76fo0NBew4JbrSvc+cRNfaFiAl
	 QkEWcPh0v2r3CBUEUYOst7UeoaOyYdLc4pb1uRmVVT2l0puoiHyRr+BB00fdwvDOte
	 zMTrahakOeCUcuHDF8D2CjLZFngzAzI+3HVShn15UKErn1OlTsiT38Xn3cVrzIAtYv
	 8z5PR0qB8xmPA==
Message-ID: <8705aa4f-5e02-45e7-ad45-0baa982a8c02@kernel.org>
Date: Fri, 18 Sep 2026 09:08:37 +0200
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [SLUB] nfs_page cmpxchg_double_fail and perf lock perturbation on
 dual-socket NFS/RDMA
Content-Language: en-US
To: Tim Menninger <tmenninger@everpuredata.com>, Harry Yoo <harry@kernel.org>
Cc: linux-mm@kvack.org, Chuck Lever <cel@kernel.org>,
 linux-nfs@vger.kernel.org, Jon Curley <jcurley@everpuredata.com>,
 Eric Badger <ebadger@everpuredata.com>,
 Andrew Morton <akpm@linux-foundation.org>, Hao Li <hao.li@linux.dev>,
 Christoph Lameter <cl@gentwo.org>, David Rientjes <rientjes@google.com>,
 Roman Gushchin <roman.gushchin@linux.dev>,
 Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>,
 Arnaldo Carvalho de Melo <acme@kernel.org>,
 Namhyung Kim <namhyung@kernel.org>, Mark Rutland <mark.rutland@arm.com>,
 Alexander Shishkin <alexander.shishkin@linux.intel.com>,
 Jiri Olsa <jolsa@kernel.org>, Ian Rogers <irogers@google.com>,
 Adrian Hunter <adrian.hunter@intel.com>, James Clark
 <james.clark@linaro.org>, linux-perf-users@vger.kernel.org,
 linux-kernel@vger.kernel.org
References: <aqvy8NqRRRmUlxjR@thinkstation>
 <20260917162533.600472-1-tmenninger@everpuredata.com>
From: "Vlastimil Babka (SUSE)" <vbabka@kernel.org>
Autocrypt: addr=vbabka@kernel.org; keydata=
 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
In-Reply-To: <20260917162533.600472-1-tmenninger@everpuredata.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

On 9/17/26 18:25, Tim Menninger wrote:
> It reproduces with slab_nomerge.
> 
> I booted the same kernel with:
> 
>     $ cat /proc/cmdline
>     ... slab_nomerge ...
> 
> Uninstrumented throughput remains in the high-45 to low-46 GB/s
> range, as before. During perf lock it was around 30 GB/s in these
> runs, versus roughly 25 GB/s previously.
> 
> The dominant lock measurements are essentially unchanged:
> 
>                          default             slab_nomerge
>     unpinned/node0
>       contentions        4,782,839             4,858,759
>       total wait          14.39 min             14.26 min
>       average wait       180.47 us             176.13 us
> 
>     node0/node0
>       contentions        4,582,012             4,686,729
>       total wait          14.13 min             14.34 min
>       average wait       185.05 us             183.53 us
> 
>     unpinned/balanced
>       contentions        4,572,196             4,544,677
>       total wait          12.81 min             12.56 min
>       average wait       168.14 us             165.84 us
> 
> The uninstrumented cmpxchg_double_fail deltas were:
> 
>                          default     slab_nomerge
>     unpinned/node0          7,471          8,892
>     node0/node0               713            457
>     unpinned/balanced       1,503          1,504
> 
> The CPU-utilization change while perf lock is active also remains.
> System-wide %idle for uninstrumented/instrumented windows was:
> 
>                            default                  slab_nomerge
>                        uninstr.   instr.         uninstr.   instr.
>     unpinned/node0      31.46%    3.60%           23.02%    2.15%
>     node0/node0         84.26%   12.07%           84.62%   11.85%
>     unpinned/balanced   66.86%   14.83%           66.58%   14.78%

I believe the weirdest part in the original report was how slub stat
counters such as free_fastpath etc got order of magnitude higher with
instrumented vs non-instrumented.
Did any of that change with slab_nomerge?

> Thanks,
> Tim

