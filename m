Received: from casper.infradead.org (casper.infradead.org [90.155.50.34])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3CA2B390224;
	Thu, 16 Jul 2026 16:48:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=90.155.50.34
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784220548; cv=none; b=ZacKKqFtnjSTyenYemEaC830U0U1Dop2eD8X4Ufsy6zx2gpvGygeLzAuX3w7Bh3HcClxgUm/SeDZsTTi40ghxBMSjeuxJEvQkSApwvaPINMcNjvOd+5ER0QnA1EzmJsj4ggT6DV2nPMs2T7kKGmBbMgbUsemn7PTcL6GwsibH0I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784220548; c=relaxed/simple;
	bh=aG9c/oIWcQuP25QpQba87EDxqnP1ULgL/edfYWUR0vo=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=LXfSrRuOnnWlfp26f1wbWvykoTMBUVBWxZmX8LwG/lJBRQdE2SZ1CsCTD1VWAnobgeWZkXD/TLz4lCUHxviRTiBmEC2StHDKtDdGfQtFoLPQo21vzYgpa18xIhm0m5W4NUmAUN7KkhP+DWGV/3YMnIYtHO5xXCTkiKknQybxJU8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=pass smtp.mailfrom=infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=DmRBhybb; arc=none smtp.client-ip=90.155.50.34
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="DmRBhybb"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=casper.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=YolakZC7+j4Triip+5AUHmDQgBfWSYQIrahb3DvaRqQ=; b=DmRBhybbCSzjOTtB6P0D9mXEdU
	yxc52/21jT9BQH1HCdU0Fxtxppp8xo7Cw8gmaLjV39caaOv/rod9RZJFZ47/ITb+erC8p7J00Soft
	nwMO9EJQ6eB1liCZiaSV4Jr1z/9H7SMYlyvjtqn4tRmt9MteyMbAIblO8nUf6vEA6etbdfyyaq8Zq
	39BQuu4wc7kk74TeSYD21Uw5zl0v25dRj69cW7lkeU5WtVK7wQSzBk/8wqzNKS+jgkmvKSBvcrbzM
	6Mp/lqi2xahBjs3CMQmRzrmZMSsN3onlbw2DQwijz3r5hY3Pi6bRJqBLVSU7Yp7/w6BhOXNNFaRmg
	bXiXDUiw==;
Received: from willy by casper.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wkPFr-00000002tsW-2hhO;
	Thu, 16 Jul 2026 16:48:11 +0000
Date: Thu, 16 Jul 2026 17:48:11 +0100
From: Matthew Wilcox <willy@infradead.org>
To: Brendan Jackman <jackmanb@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
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
Message-ID: <alkLSzQvzT9zJbY1@casper.infradead.org>
References: <20260716-folio-alloc-cleanups-v1-0-5363b8e92d33@google.com>
 <20260716-folio-alloc-cleanups-v1-1-5363b8e92d33@google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260716-folio-alloc-cleanups-v1-1-5363b8e92d33@google.com>

On Thu, Jul 16, 2026 at 02:30:10PM +0000, Brendan Jackman wrote:
> There are no external users for this surface, reduce the scope.
> -struct folio *folio_alloc_mpol_noprof(gfp_t gfp, unsigned int order,
> -		struct mempolicy *mpol, pgoff_t ilx, int nid);

Hm.  So what we're saying is that allocations which respect mempolicy are
only for core mm and not for, eg, device drivers to do.  Is that really
what we want to say?  I don't think so, because that's inconsistent
with having just widened __filemap_get_folio_mpol to allow guest_memfd
to specify a mempolicy.

