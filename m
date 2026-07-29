Received: from out-185.mta0.migadu.com (out-185.mta0.migadu.com [91.218.175.185])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CBE0547ACE5
	for <linux-nfs@vger.kernel.org>; Wed, 29 Jul 2026 11:50:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=91.218.175.185
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785325855; cv=none; b=J8kogMsQ4BECKGpa4JrVZOaez4L0LtLIsbm5a3xHG7uo/5XWW2OVLFVOK7Jwc8745OHdTd6DZVf+IbAHMJ/XQxKUA+Wzyemr8zcMMz6KG9t1j2jwuaHfawb9LVvMUv56FlAv2ttik9aASobP/zxE96eePtmhf0QM0zUr2YoRCG4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785325855; c=relaxed/simple;
	bh=k5Z2HfoamLNSQvohUbrABdGCh5ajWnauXreNAn0e4ig=;
	h=Mime-Version:Content-Type:Date:Message-Id:Subject:From:To:Cc:
	 References:In-Reply-To; b=Ss9MX8gonNsMcvJAyzThweYpY7eTuHMh6LmuY1P7bwVvVzS5ipYe8e96d8p6pG1ADzjG692wKvyeOHKHLz1jc0/4auxArzCT/W2GK1LKBBT/Txj978MaqN66sdmMgJ3UdnwAx7jyArUmUbpwHX8uLZ9h0avd3P/FgoSt1ymrXy4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev; spf=pass smtp.mailfrom=linux.dev; dkim=pass (1024-bit key) header.d=linux.dev header.i=@linux.dev header.b=r2lsqEoY; arc=none smtp.client-ip=91.218.175.185
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.dev
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux.dev header.i=@linux.dev header.b="r2lsqEoY"
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
Mime-Version: 1.0
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linux.dev; s=key1;
	t=1785325840;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=RW4sNREqQBsxBWcBVOxGkaAhxGnf2SK3CsBZlJEr+CI=;
	b=r2lsqEoYAQ1KGpOstBBL26uqJoRA/RKskIVz/NmP2P1yJGaJGxiK351ItTrzmwafZrTrgF
	N3Vc5HNWYU1L2pUZk/uW+BQB/+yzxmdArbOwj40bXQCJd+LfcHhw5WJrU4lzVIGwsJfnLj
	EmJU9F1CtAj8Nu+CAAOxOxo9skdsMYc=
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=UTF-8
Date: Wed, 29 Jul 2026 11:50:32 +0000
Message-Id: <DKB16T0X5I9D.2GCNPBS9VC95V@linux.dev>
Subject: Re: [PATCH 1/3] mm: move internal mempolicy APIs to new internal
 header
X-Report-Abuse: Please report any abuse attempt to abuse@migadu.com and include these headers.
From: "Brendan Jackman" <brendan.jackman@linux.dev>
To: "Brendan Jackman" <brendan.jackman@linux.dev>, "Vlastimil Babka (SUSE)"
 <vbabka@kernel.org>, "Matthew Wilcox" <willy@infradead.org>
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
References: <20260716-folio-alloc-cleanups-v1-0-5363b8e92d33@google.com>
 <20260716-folio-alloc-cleanups-v1-1-5363b8e92d33@google.com>
 <alkLSzQvzT9zJbY1@casper.infradead.org>
 <DK05KUIDJVLZ.61UIWOL0K3OT@linux.dev>
 <al5gQgnBCjNCSD_4@casper.infradead.org>
 <51810eba-2a60-49f9-b879-7f806546e600@kernel.org>
 <DK5767A146ZW.3LV5JXS7T4W1C@linux.dev>
In-Reply-To: <DK5767A146ZW.3LV5JXS7T4W1C@linux.dev>
X-Migadu-Flow: FLOW_OUT

On Wed Jul 22, 2026 at 3:15 PM UTC, Brendan Jackman wrote:
...
>>> We have a long history of people just moving stuff around in patches
>>> without knowing what the intent was if it should be moved.
>>
>> I guess this patch is not critical to the rest, if that's an issue.
>
> Well, for ALLOC_UNMAPPED we really do need an alloc_flags arg for this
> function, but we can always just go straight to what I described above.
> I.e. I can create the __ variant + wrapper from the start. It's just a
> question of whether we prefer:
>
> - "Yuck, there's a public wrapper here that we don't actually need", or
>
> - "We hid this mempolicy API and people might think we'd NACK a patch to
>   un-hide it".0
>
>   https://lore.kernel.org/all/20260703-alloc-trylock-v5-2-c87b714e19d3@go=
ogle.com/

Uh yeah so in v3 I did not depend on this patch, I just went straight to
creating __folio_alloc_mpol_noprof() here:

https://lore.kernel.org/all/20260726-page_alloc-unmapped-v3-25-6f5729aa9832=
@google.com/

So yeah I'd say we can just drop this controversial patch and move
forwards with the other two?
