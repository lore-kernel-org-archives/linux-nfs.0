Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1D51249739B;
	Fri, 18 Sep 2026 07:04:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789715068; cv=none; b=aJrcKYM93JwrYg89MLN14SJfmTGtAqtdagl7HQdL+ELv0jDp9WLmpWsWTPrUDhAUFmRN5lhfatRXfxK9M81Pz4o+5MT/04Ydij9P3XM2OEIK5gcrsddiwlHO/FUj2pPuuNzMAclKagUdkhunzEcNISAsh/HKW+17zsRo4IAGs5g=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789715068; c=relaxed/simple;
	bh=LjBulbBPS4HQ+2+ENfpTJJe7kppwctse0hq8ahYzkC0=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=l1/PAnBDhBxN5PCTSVLL4qNBBpjGFiZngwOUewlZ5CtOn4dxeM1sQQJQgWbmnpn7RCs/7zHst63gzwywCee5GpfRLlztQWbiEm1LIRqJaXwSdmeRS+Ymq7rV+cMaeI+fBwyhZASBIH5mMOHhFRPmNrVG30o13S54gxG2hwzuJ9Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=P/LKqi2L; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="P/LKqi2L"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BDFB51F000FF;
	Fri, 18 Sep 2026 07:04:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789715066;
	bh=h7MrO5kHfs9s9gpQkpstdAXZ31bb0e2lmCQcEqPnDlQ=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=P/LKqi2LqAKG2z2uozCnUWME8OGZ9RbIIELAHHwTXvdmqJNNhcB+P6+T4o1eQ8bff
	 emGEtPWT0PNKHunU+e67JP0rY4/3Tgr8kyp6GDWN5FCOr2JHeXpqhM1RzrzJHkb9Ew
	 brC89Jmwg9/AeYM1XEAol1WvLn6e+jB9Z2r8WtID8EVVzKhebhWUcARXEcnzhnt6y3
	 r34S5YxuU4zLWiUFw7Zf3wQagohKhQK4vsCUZTFh3QOxASwCM3MANSEXJOLdQMuvVu
	 1hUCQ3DHh2wB0WW/fnGCHvw1eL+/L2pnuOVar83DD1+R3aG+zlkAmPp42idM32aMKO
	 /aI0Z7fDCQizQ==
Date: Fri, 18 Sep 2026 00:04:24 -0700
From: Namhyung Kim <namhyung@kernel.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Harry Yoo <harry@kernel.org>,
	Tim Menninger <tmenninger@everpuredata.com>, linux-mm@kvack.org,
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
	Mark Rutland <mark.rutland@arm.com>,
	Alexander Shishkin <alexander.shishkin@linux.intel.com>,
	Jiri Olsa <jolsa@kernel.org>, Ian Rogers <irogers@google.com>,
	Adrian Hunter <adrian.hunter@intel.com>,
	James Clark <james.clark@linaro.org>,
	linux-perf-users@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [SLUB] nfs_page cmpxchg_double_fail and perf lock perturbation
 on dual-socket NFS/RDMA
Message-ID: <aqzieNW5GmhnU_EJ@z2>
References: <20260916232227.4098143-1-tmenninger@everpuredata.com>
 <aqvq8-6IJBDer90O@thinkstation>
 <aqvy8NqRRRmUlxjR@thinkstation>
 <20260917152959.GI4121339@noisy.programming.kicks-ass.net>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20260917152959.GI4121339@noisy.programming.kicks-ass.net>

Hello,

On Thu, Sep 17, 2026 at 05:29:59PM +0200, Peter Zijlstra wrote:
> On Thu, Sep 17, 2026 at 03:10:47PM +0100, Harry Yoo wrote:
> > ... now I realize we need to add PERFORMANCE EVENTS SUBSYSTEM folks 
> > as well ;-)
> > 
> > Hmm, sounds like perf lock is somehow triggering slab allocations
> > and interfering the workload.
> 
> perf should not have runtime memory allocation, its build to run from
> NMI context. It can allocate some memory on event creation and the like,
> but once its on, there should be no more allocations happening.

Right, perf lock record command will save the event info to a ring
buffer without allocation.  It may lose some events when the buffer is
full though.

Thanks,
Namhyung

