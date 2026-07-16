Received: from out-177.mta0.migadu.com (out-177.mta0.migadu.com [91.218.175.177])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C05043191C8
	for <linux-nfs@vger.kernel.org>; Thu, 16 Jul 2026 16:04:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=91.218.175.177
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784217898; cv=none; b=i6AzC3vMQKIUxorou6poviqyjLYGD4xzdw7/+Kvb3BKJhrDbNKEzS7vcsMCTtNy5nh7QUX8t3vBqy0tSV7pGLOhu0brE5CqKnEn0UVQ/PouB1aicypL488Slm+mAfAeBzFzhO8zfvgXjOaGh7VbfVIih7YkJVpBJxt1gdlTIQA4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784217898; c=relaxed/simple;
	bh=Tz9IYBII36hEmZ8WCkdw0Poo/VwDhmKC5JCuOyne4eQ=;
	h=Mime-Version:Content-Type:Date:Message-Id:Cc:Subject:From:To:
	 References:In-Reply-To; b=ffHfqG/fTbLciggd6tXHk7ZSxwbhteUNN83YV7HV4EUg9GJNX5/eM/YoHYqIRKKNkoKwOK8ZwjTQcAIHuNUE+J+xDooD3/2El5u6sO5UzHODO1TjxuwIxxzt0oRtNgAc4mp/nKztSj6fKfDESkdNUICPWMHf2CBA1pTtNpIG1W0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev; spf=pass smtp.mailfrom=linux.dev; dkim=pass (1024-bit key) header.d=linux.dev header.i=@linux.dev header.b=Xsgwr6/T; arc=none smtp.client-ip=91.218.175.177
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.dev
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux.dev header.i=@linux.dev header.b="Xsgwr6/T"
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
Mime-Version: 1.0
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linux.dev; s=key1;
	t=1784217878;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=Tz9IYBII36hEmZ8WCkdw0Poo/VwDhmKC5JCuOyne4eQ=;
	b=Xsgwr6/T1iv1KWaE1PuNvf4s/O+/mxi0r+dxIsV2UrtO3cqwbAo/F13cifsh5A4y30WL0M
	OAfBvENtdO2+WNOtB8b1YZ9VkWLo9N61R3G0xE+YVfNijzJSDAweY+G+J3yVeHK+S33Z3J
	u3V4cUBGDVOKcydQVkb+bPN6FkiL5cw=
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=UTF-8
Date: Thu, 16 Jul 2026 16:04:30 +0000
Message-Id: <DK04G61IJ7OP.6MAP7T3WSU2C@linux.dev>
Cc: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>,
 <linux-fsdevel@vger.kernel.org>, <iommu@lists.linux.dev>,
 <loongarch@lists.linux.dev>, <linux-nfs@vger.kernel.org>,
 <netdev@vger.kernel.org>
Subject: Re: [PATCH 1/3] mm: move internal mempolicy APIs to new internal
 header
X-Report-Abuse: Please report any abuse attempt to abuse@migadu.com and include these headers.
From: "Brendan Jackman" <brendan.jackman@linux.dev>
To: "Vlastimil Babka (SUSE)" <vbabka@kernel.org>, "Brendan Jackman"
 <jackmanb@google.com>, "Andrew Morton" <akpm@linux-foundation.org>, "David
 Hildenbrand" <david@kernel.org>, "Lorenzo Stoakes" <ljs@kernel.org>, "Liam
 R. Howlett" <liam@infradead.org>, "Mike Rapoport" <rppt@kernel.org>, "Suren
 Baghdasaryan" <surenb@google.com>, "Michal Hocko" <mhocko@suse.com>,
 "Johannes Weiner" <hannes@cmpxchg.org>, "Zi Yan" <ziy@nvidia.com>, "Matthew
 Wilcox (Oracle)" <willy@infradead.org>, "Jan Kara" <jack@suse.cz>, "Joshua
 Hahn" <joshua.hahnjy@gmail.com>, "Byungchul Park" <byungchul@sk.com>,
 "Gregory Price" <gourry@gourry.net>, "Ying Huang"
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
 "Simon Horman" <horms@kernel.org>
References: <20260716-folio-alloc-cleanups-v1-0-5363b8e92d33@google.com>
 <20260716-folio-alloc-cleanups-v1-1-5363b8e92d33@google.com>
 <73d3c545-dd8a-4131-9826-1a7096dd619a@kernel.org>
In-Reply-To: <73d3c545-dd8a-4131-9826-1a7096dd619a@kernel.org>
X-Migadu-Flow: FLOW_OUT

On Thu Jul 16, 2026 at 3:22 PM UTC, Vlastimil Babka (SUSE) wrote:
> On 7/16/26 16:30, Brendan Jackman wrote:
>> There are no external users for this surface, reduce the scope.
>>=20
>> Ulterior motive: a later patch will add an alloc_flags arg to some parts
>> of this.
>>=20
>> Note it might seem like this could just go in internal.h, since it's
>> pretty small, but actually it will eventually need to import
>> page_alloc.h, we don't want to import that from internal.h so best to
>> proactively created this header now.
>
> Hmm, maybe it could just go to page_alloc.h then? After all this is just
> bunch of internal page allocation functions, which just take the mempolic=
y
> pointer?

That would work AFAICS, but I think it's quite tidy that, currently, all
functions declared in page_alloc.h are defined in page_alloc.c. This
would break that.

If you're certain you don't care about that then I could live with using
page_alloc.h.
