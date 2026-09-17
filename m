Received: from casper.infradead.org (casper.infradead.org [90.155.50.34])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4A6F159E35E;
	Thu, 17 Sep 2026 15:30:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=90.155.50.34
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789659037; cv=none; b=ip4VNdZF+xsjeECkdsGGqd1remR7/I0RvHmlIjtZ08FKp1MJ9YiOGXzEhhYcj3QaCza7o9PnnfyAO9YrV7/u+o5neHPEeZtsVroYwbAz9Jhhh12QaiSsNonDf/l+lWkAsmoSTnUUbJcRu6JsQ0Oqw4yY358jdOd04NhbaGzRb1k=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789659037; c=relaxed/simple;
	bh=k4aRaW8Rin+eJ9oRbixnfh27smnELwPdMm0CF6snSFY=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=Z048z2l/e91ACWK98RbgxMKIb3m21/4OIJYrzHZcRIRFtl9F7Wwg5sBa1xSw/fTMtTBcMsOY9iKpoxoKBkpdiklBhk6Il5ribB3XPFwq+TnN1vbgC/8dNpqrRRkl61w3RoowJrsQokunsMF73ks8clEIGtImKKTG9mCSU69TuVQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=pass smtp.mailfrom=infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=Y2TFScVh; arc=none smtp.client-ip=90.155.50.34
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Y2TFScVh"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=casper.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=sTfUOkKMGqgqjaFCBY9cwK+mhbSSBWEoZUq8zIqkfmI=; b=Y2TFScVhT4tsYVFry161EhyqSe
	Hme1WS9xN6vaajiMtnqa0tFXEm1VBXMSwUSWcpD+j0aqgz0+QUKwAyIo7MXChWqf3W2CHRSrffvvb
	//7bKSIw49o1liqfVlDMtnAYLUgjPQttyP0fUR0ScQuGI7pcM9Fp3ERmddTFgQjCr13Nzyt+nmcRa
	kMhoTMoPaqTHevxxcKSO7KhMg6C/tb41LnyNRKzv3YyNuyFLXhhgVFM3nvx+DD5qt24MBlKS/srQV
	nOIRvdgTvv9mLRHYvhjmW3aqR+S9kJozLTRLtmcX2c5GWRK2+C9ANaRh5iedx6gLVDIgNlYNCYcYx
	jpUAYrlA==;
Received: from 77-249-17-252.cable.dynamic.v4.ziggo.nl ([77.249.17.252] helo=noisy.programming.kicks-ass.net)
	by casper.infradead.org with esmtpsa (Exim 4.99.1 #2 (Red Hat Linux))
	id 1x7E3k-0000000Alj8-3tlT;
	Thu, 17 Sep 2026 15:30:01 +0000
Received: by noisy.programming.kicks-ass.net (Postfix, from userid 1000)
	id 058C1301BD5; Thu, 17 Sep 2026 17:30:00 +0200 (CEST)
Date: Thu, 17 Sep 2026 17:29:59 +0200
From: Peter Zijlstra <peterz@infradead.org>
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
	Ingo Molnar <mingo@redhat.com>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	Namhyung Kim <namhyung@kernel.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Alexander Shishkin <alexander.shishkin@linux.intel.com>,
	Jiri Olsa <jolsa@kernel.org>, Ian Rogers <irogers@google.com>,
	Adrian Hunter <adrian.hunter@intel.com>,
	James Clark <james.clark@linaro.org>,
	linux-perf-users@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [SLUB] nfs_page cmpxchg_double_fail and perf lock perturbation
 on dual-socket NFS/RDMA
Message-ID: <20260917152959.GI4121339@noisy.programming.kicks-ass.net>
References: <20260916232227.4098143-1-tmenninger@everpuredata.com>
 <aqvq8-6IJBDer90O@thinkstation>
 <aqvy8NqRRRmUlxjR@thinkstation>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <aqvy8NqRRRmUlxjR@thinkstation>

On Thu, Sep 17, 2026 at 03:10:47PM +0100, Harry Yoo wrote:
> ... now I realize we need to add PERFORMANCE EVENTS SUBSYSTEM folks 
> as well ;-)
> 
> Hmm, sounds like perf lock is somehow triggering slab allocations
> and interfering the workload.

perf should not have runtime memory allocation, its build to run from
NMI context. It can allocate some memory on event creation and the like,
but once its on, there should be no more allocations happening.
