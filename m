Received: from out-177.mta0.migadu.com (out-177.mta0.migadu.com [91.218.175.177])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 18540343892
	for <linux-nfs@vger.kernel.org>; Wed, 22 Jul 2026 15:16:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=91.218.175.177
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784733369; cv=none; b=HG5dlQYs+9icWQPXEMKfCC/p7RA0v3LPzPvIgxBZd8VhBSreXZWp+VrOV9OVMBgHfsrIpqr/CIf5qcXsYPAXxuoVUXW0cHDS8rMHWLBMDZU6wKpfasFGDADjsrxpfPZgXfESSkRcj6SoLg01pHxtf1CwO4ai0CYWus96r/HuUoo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784733369; c=relaxed/simple;
	bh=pZqfDNtrlt4xKRG3c0BiAsT2DXo0fiEXSQUodX9iZ3w=;
	h=Mime-Version:Content-Type:Date:Message-Id:Cc:Subject:From:To:
	 References:In-Reply-To; b=oNNj0Zb7lI9//x4QZUPBbz2q8T9AxUaFvudHKbvK0sPQMzFSV/XE0Bd6R3XR9EaChKxTgotyaHi5VllkHRo1/ujTmA3SStOfxlVPGRxoamMBvvUreJqTOjQjfNVqjYlqHKZPIVvNWVL7tnUGom7E3IhNBAo/8hHCKA0V1V/cHKs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev; spf=pass smtp.mailfrom=linux.dev; dkim=pass (1024-bit key) header.d=linux.dev header.i=@linux.dev header.b=bW3PreC0; arc=none smtp.client-ip=91.218.175.177
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.dev
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux.dev header.i=@linux.dev header.b="bW3PreC0"
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
Mime-Version: 1.0
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linux.dev; s=key1;
	t=1784733365;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=r9xnLf5kCYeKS0y9dx48KGdZi3PUN8z8TKfUOdx3pcY=;
	b=bW3PreC0YSLDGRKBpNSz9D3HV9IBx4wlSIMZcxjKlW2NgHj/d2JJNShI5MXv07j8MqQQS+
	NPjHWhOdZSBYQK8zlzTLb67RaU+lo+jSdYPczWGuvi2XKtwcuonThN72rQpi4GauyQiL7a
	183xUjaWt/QyKalqhxboM/IvbhPi1ME=
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=UTF-8
Date: Wed, 22 Jul 2026 15:15:52 +0000
Message-Id: <DK5767A146ZW.3LV5JXS7T4W1C@linux.dev>
Cc: "Brendan Jackman" <jackmanb@google.com>, "Andrew Morton"
 <akpm@linux-foundation.org>, "David Hildenbrand" <david@kernel.org>,
 "Lorenzo Stoakes" <ljs@kernel.org>, "Liam R. Howlett" <liam@infradead.org>,
 "Mike Rapoport" <rppt@kernel.org>, "Suren Baghdasaryan"
 <surenb@google.com>, "Michal Hocko" <mhocko@suse.com>, "Johannes Weiner"
 <hannes@cmpxchg.org>, "Zi Yan" <ziy@nvidia.com>, "Jan Kara" <jack@suse.cz>,
 "Joshua Hahn" <joshua.hahnjy@gmail.com>, "Byungchul Park"
 <byungchul@sk.com>, "Gregory Price" <gourry@gourry.net>, "Ying Huang"
 <ying.huang@linux.alibaba.com>, "Alistair Popple" <apopple@nvidia.com>,
 "Hugh Dickins" <hughd@google.com>, "Baolin Wang"
 <baolin.wang@linux.alibaba.com>, "Chris Li" <chrisl@kernel.org>, "Kairui
 Song" <kasong@tencent.com>, "Kemeng Shi" <shikemeng@huaweicloud.com>, "Nhat
 Pham" <nphamcs@gmail.com>, "Baoquan He" <baoquan.he@linux.dev>, "Barry
 Song" <baohua@kernel.org>, "Youngjun Park" <youngjun.park@lge.com>, "Joerg
 Roedel (AMD)" <joro@8bytes.org>, "Will Deacon" <will@kernel.org>, "Robin
 Murphy" <robin.murphy@arm.com>, "Huacai Chen" <chenhuacai@kernel.org>,
 "WANG Xuerui" <kernel@xen0n.name>, "Thomas Gleixner" <tglx@kernel.org>,
 "Chuck Lever" <cel@kernel.org>, "Jeff Layton" <jlayton@kernel.org>,
 "NeilBrown" <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>,
 "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>, "Trond
 Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>, "David
 S. Miller" <davem@davemloft.net>, "Eric Dumazet" <edumazet@google.com>,
 "Jakub Kicinski" <kuba@kernel.org>, "Paolo Abeni" <pabeni@redhat.com>,
 "Simon Horman" <horms@kernel.org>, <linux-kernel@vger.kernel.org>,
 <linux-mm@kvack.org>, <linux-fsdevel@vger.kernel.org>,
 <iommu@lists.linux.dev>, <loongarch@lists.linux.dev>,
 <linux-nfs@vger.kernel.org>, <netdev@vger.kernel.org>
Subject: Re: [PATCH 1/3] mm: move internal mempolicy APIs to new internal
 header
X-Report-Abuse: Please report any abuse attempt to abuse@migadu.com and include these headers.
From: "Brendan Jackman" <brendan.jackman@linux.dev>
To: "Vlastimil Babka (SUSE)" <vbabka@kernel.org>, "Matthew Wilcox"
 <willy@infradead.org>, "Brendan Jackman" <brendan.jackman@linux.dev>
References: <20260716-folio-alloc-cleanups-v1-0-5363b8e92d33@google.com>
 <20260716-folio-alloc-cleanups-v1-1-5363b8e92d33@google.com>
 <alkLSzQvzT9zJbY1@casper.infradead.org>
 <DK05KUIDJVLZ.61UIWOL0K3OT@linux.dev>
 <al5gQgnBCjNCSD_4@casper.infradead.org>
 <51810eba-2a60-49f9-b879-7f806546e600@kernel.org>
In-Reply-To: <51810eba-2a60-49f9-b879-7f806546e600@kernel.org>
X-Migadu-Flow: FLOW_OUT

On Mon Jul 20, 2026 at 6:34 PM UTC, Vlastimil Babka (SUSE) wrote:
> On 7/20/26 19:52, Matthew Wilcox wrote:
>> On Thu, Jul 16, 2026 at 04:57:37PM +0000, Brendan Jackman wrote:
>>> On Thu Jul 16, 2026 at 4:48 PM UTC, Matthew Wilcox wrote:
>>> > On Thu, Jul 16, 2026 at 02:30:10PM +0000, Brendan Jackman wrote:
>>> >> There are no external users for this surface, reduce the scope.
>>> >> -struct folio *folio_alloc_mpol_noprof(gfp_t gfp, unsigned int order=
,
>>> >> -		struct mempolicy *mpol, pgoff_t ilx, int nid);
>>> >
>>> > Hm.  So what we're saying is that allocations which respect mempolicy=
 are
>>> > only for core mm and not for, eg, device drivers to do.  Is that real=
ly
>>> > what we want to say?  I don't think so, because that's inconsistent
>>> > with having just widened __filemap_get_folio_mpol to allow guest_memf=
d
>>> > to specify a mempolicy.
>
> guest_memfd is practically mm internal though, IMHO.
>
>>> Yeah I agree, mempolicy definitely seems like a "public concept".=C2=A0=
 All
>>> I'm saying here is this specific function doesn't have any external
>>> users so it doesn't need to be an external header.=20
>>=20
>> I don't think that should be the metric for moving things to internal.h.
>> To me, internal.h is a signifier that these interfaces should only be
>> used by the MM.  Not that "all current users are within the MM".
>
> Perhaps. It can be also useful to move them outside only when someone ask=
s.

Yeah I can see this both ways. It makes sense to only expose functions
to the scope that currently needs them, but I think Matthew's right that
moving it to internal.h does kinda signal "this is private, don't touch
this" which isn't intended.

>>> ... With the ulterior motive that I want to add a new parameter to it
>>> that actually _is_ mm-internal. Namely, alloc_flags, so I can add
>>> ALLOC_UNMAPPED to implement AS_NO_DIRECT_MAP, i.e. the next iteration o=
f
>>> [0]. So basically this is
>>> about trying to extend the allocator without creating a GFP flag.
>>=20
>> Yeah.  I'm not sold on the whole alloc_flags thing, but I'm too busy to
>> sit down and think it through properly to get involved in a proper
>> argument about how it should work.
>
> Well it's basically a workaround for limited gfp flags space. So we can
> extend it without making that a cost for everybody, as long as those that
> need the new functionality are limited.
>
>> My entirely unresearched and ill-considered opinion is that the __GFP
>> flags should _be_ the ALLOC flags.  We shoudn't be translating GFP flags
>> into ALLOC flags that are what the allocator actually uses, the
>
> It uses both.
>
>> translation should be done at compile time.  So if GFP_KERNEL and
>
> That would assume the gfp flags are also known at compile time, which is =
not
> always the case.
>
>> GFP_ATOMIC need to be composed of different flags with different
>
> The flags we are adding/considering to add are not about GFP_KERNEL vs
> GFP_ATOMIC context, however.
>
>> semantics, then we should do that, not invent a different set of flags
>> that special people can use for special purposes.
>
> Yep it's ugly and pragmatic, as usual. At least it's not immortalized as =
an
> UAPI, so we can deal with exploring in a wrong direction and fixing it la=
ter.

FWIW I suspect the "proper" design requirements are something like:

1. We want some flags that we can happily squeeze into places like
   struct xa_node, and other flags that we can add bits to relatively
   freely.

2. We want some flags that are "public" and some that are "private",
   although this is intentionally vaguely defined.

The current ALLOC_/GFP_ flags split is something that kinda inelegantly
attempts to solve both at once even though they are actually probably
orthogonal requirements. Do we care about this inelegance? I think it's
pretty harmless.

Another thing that's pretty inelegant about it is that both sets of
flags percolate into the allocator at once. This is quite
confusing/tiresome when you are reading page_alloc.c (I tried to
ameliorate that with [0]) but I don't think it has much of an
architectural impact?

[0]: https://lore.kernel.org/all/20260703-alloc-trylock-v5-2-c87b714e19d3@g=
oogle.com/

In the back of my mind I suspect the "neat and tidy" solution would be
something like: a single flags namespace that is split into two separate
enums, one "public" and one "private", and then a separate mechanism to
"compress" these flags into a small number of bits. But yeah I'm just
not sure working on that nice elegant cleanup would really unlock
anything of practical value. Boring little cleanups like "split out this
API from internal.h into its own header" seem like more useful ways to
spend refactoring energy in this space.

Quite likely I'm missing potential unlocks though. E.g. maybe there's
some place we currently put a gfp_t that could benefit from a "separate
compression mechanism" that could usefully shrink it to 8 bits or
whatever.

>>> So I'm envisaging if an external user arises for it later, we'd slap tw=
o
>>> underscores on the beginning of the internal one, (with the alloc_flags
>>> arg), and then bring back the public one as a wrapper.
>>>=20
>>> Does that make sense?
>>=20
>> We have a long history of people just moving stuff around in patches
>> without knowing what the intent was if it should be moved.
>
> I guess this patch is not critical to the rest, if that's an issue.

Well, for ALLOC_UNMAPPED we really do need an alloc_flags arg for this
function, but we can always just go straight to what I described above.
I.e. I can create the __ variant + wrapper from the start. It's just a
question of whether we prefer:

- "Yuck, there's a public wrapper here that we don't actually need", or

- "We hid this mempolicy API and people might think we'd NACK a patch to
  un-hide it".0

  https://lore.kernel.org/all/20260703-alloc-trylock-v5-2-c87b714e19d3@goog=
le.com/
