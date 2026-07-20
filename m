Received: from casper.infradead.org (casper.infradead.org [90.155.50.34])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E1FED44685F;
	Mon, 20 Jul 2026 17:52:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=90.155.50.34
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784569978; cv=none; b=YC973FxtKzlOO5La4ctJgk4IbyRl9Fy8sSzBvXaO9x6hen/shL+mbC9XG9dzuA3D0tceLK9oEiosiBjGc9D4jqB4Tl2AYuaKiT1CCxbEYL2Ja0tiQa+/afdNJpbktN3AEesRBvFXLhEkFpxWsEK/nS7iRQZr6xolrey0H8uJ0NY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784569978; c=relaxed/simple;
	bh=Esr8WG2LCuWfYVYOsVSLvqLeRBiwB1g1s9ZX6Ca23tk=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=o/1D3xosIH7AbDU4J/ucSDbGokqFLh2aePdJVMerlSn1fLHIa/ZOMAIZerBOWVq8FhInDwX9EZNhB2xpiHKn4JY7PCy4oA986MU9tSVm69EST6RXoR5Uz0fpWOqb2mpRgtac6y1aQ+8IyZaKwc6KJZVzAKHS2RYHy3TJtMaguJs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=pass smtp.mailfrom=infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=Pgyz1YhP; arc=none smtp.client-ip=90.155.50.34
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Pgyz1YhP"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=casper.20170209; h=In-Reply-To:Content-Transfer-Encoding:
	Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description;
	bh=TR847jKAnLLFsDzkJBbc4JtjIxFdfXosjkxGIzB/344=; b=Pgyz1YhP+1QCN+yvoqIhCvJsgZ
	Vku7FPO3C6ENm6LxLklvHlmnCqXx5TX224a51MBQhn10peY7b5XcCjBunFF2K6rETht6B+bsYqB4Y
	5RiaVNBDazOw+qf5wwC/dxGyQuO6wG5lyfPYgPF5sXVHpOBTfnpwtl5j8RxvCPdVfaQ5hIno5b5eX
	x/aXvnXXmHZ3Rx59JGcV0J+APS8gIb8dAGwuclvNrsFEgeoIqSv1Rb5fjskHhI/LlPQIOH2jf3K6a
	1uLdDaYaZnMoJoL0qgpL8UH4jF6WLgzXcg2x9KtFJWkm0H1jOwgdWXm4Hua4YKVKC361UVC7KzTSa
	PMo1oXxg==;
Received: from willy by casper.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wls9r-0000000BRPP-0YTi;
	Mon, 20 Jul 2026 17:52:03 +0000
Date: Mon, 20 Jul 2026 18:52:02 +0100
From: Matthew Wilcox <willy@infradead.org>
To: Brendan Jackman <brendan.jackman@linux.dev>
Cc: Brendan Jackman <jackmanb@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Hildenbrand <david@kernel.org>,
	Lorenzo Stoakes <ljs@kernel.org>,
	"Liam R. Howlett" <liam@infradead.org>,
	Vlastimil Babka <vbabka@kernel.org>,
	Mike Rapoport <rppt@kernel.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>, Zi Yan <ziy@nvidia.com>,
	Jan Kara <jack@suse.cz>, Joshua Hahn <joshua.hahnjy@gmail.com>,
	Byungchul Park <byungchul@sk.com>,
	Gregory Price <gourry@gourry.net>,
	Ying Huang <ying.huang@linux.alibaba.com>,
	Alistair Popple <apopple@nvidia.com>,
	Hugh Dickins <hughd@google.com>,
	Baolin Wang <baolin.wang@linux.alibaba.com>,
	Chris Li <chrisl@kernel.org>, Kairui Song <kasong@tencent.com>,
	Kemeng Shi <shikemeng@huaweicloud.com>,
	Nhat Pham <nphamcs@gmail.com>, Baoquan He <baoquan.he@linux.dev>,
	Barry Song <baohua@kernel.org>,
	Youngjun Park <youngjun.park@lge.com>,
	"Joerg Roedel (AMD)" <joro@8bytes.org>,
	Will Deacon <will@kernel.org>, Robin Murphy <robin.murphy@arm.com>,
	Huacai Chen <chenhuacai@kernel.org>,
	WANG Xuerui <kernel@xen0n.name>, Thomas Gleixner <tglx@kernel.org>,
	Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>,
	Simon Horman <horms@kernel.org>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	iommu@lists.linux.dev, loongarch@lists.linux.dev,
	linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Subject: Re: [PATCH 1/3] mm: move internal mempolicy APIs to new internal
 header
Message-ID: <al5gQgnBCjNCSD_4@casper.infradead.org>
References: <20260716-folio-alloc-cleanups-v1-0-5363b8e92d33@google.com>
 <20260716-folio-alloc-cleanups-v1-1-5363b8e92d33@google.com>
 <alkLSzQvzT9zJbY1@casper.infradead.org>
 <DK05KUIDJVLZ.61UIWOL0K3OT@linux.dev>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <DK05KUIDJVLZ.61UIWOL0K3OT@linux.dev>

On Thu, Jul 16, 2026 at 04:57:37PM +0000, Brendan Jackman wrote:
> On Thu Jul 16, 2026 at 4:48 PM UTC, Matthew Wilcox wrote:
> > On Thu, Jul 16, 2026 at 02:30:10PM +0000, Brendan Jackman wrote:
> >> There are no external users for this surface, reduce the scope.
> >> -struct folio *folio_alloc_mpol_noprof(gfp_t gfp, unsigned int order,
> >> -		struct mempolicy *mpol, pgoff_t ilx, int nid);
> >
> > Hm.  So what we're saying is that allocations which respect mempolicy are
> > only for core mm and not for, eg, device drivers to do.  Is that really
> > what we want to say?  I don't think so, because that's inconsistent
> > with having just widened __filemap_get_folio_mpol to allow guest_memfd
> > to specify a mempolicy.
> 
> Yeah I agree, mempolicy definitely seems like a "public concept".  All
> I'm saying here is this specific function doesn't have any external
> users so it doesn't need to be an external header. 

I don't think that should be the metric for moving things to internal.h.
To me, internal.h is a signifier that these interfaces should only be
used by the MM.  Not that "all current users are within the MM".

> ... With the ulterior motive that I want to add a new parameter to it
> that actually _is_ mm-internal. Namely, alloc_flags, so I can add
> ALLOC_UNMAPPED to implement AS_NO_DIRECT_MAP, i.e. the next iteration of
> [0]. So basically this is
> about trying to extend the allocator without creating a GFP flag.

Yeah.  I'm not sold on the whole alloc_flags thing, but I'm too busy to
sit down and think it through properly to get involved in a proper
argument about how it should work.

My entirely unresearched and ill-considered opinion is that the __GFP
flags should _be_ the ALLOC flags.  We shoudn't be translating GFP flags
into ALLOC flags that are what the allocator actually uses, the
translation should be done at compile time.  So if GFP_KERNEL and
GFP_ATOMIC need to be composed of different flags with different
semantics, then we should do that, not invent a different set of flags
that special people can use for special purposes.

> So I'm envisaging if an external user arises for it later, we'd slap two
> underscores on the beginning of the internal one, (with the alloc_flags
> arg), and then bring back the public one as a wrapper.
> 
> Does that make sense?

We have a long history of people just moving stuff around in patches
without knowing what the intent was if it should be moved.
