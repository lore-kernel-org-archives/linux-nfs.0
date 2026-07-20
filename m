Received: from mail-qv1-f42.google.com (mail-qv1-f42.google.com [209.85.219.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2153C39E185
	for <linux-nfs@vger.kernel.org>; Mon, 20 Jul 2026 17:42:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.219.42
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784569341; cv=none; b=LDSF6i6A8qzCFZ1miRg8qKp8NWX5vPr1SZQZJ53CFkJttksZZv8U5nSPfiaoaSzK90/NTdJ8PpkMJTSwvOIVqjOk9VDcc19R51G//DunTuuxKFo6i4MISyss/319fHa7Xy1iLWU76Syt85T8vrU8vem31kJb7wAFRKJ2ajoVMLc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784569341; c=relaxed/simple;
	bh=3QhE2AsLZJkKzhZ4fqbxNv5piEktj9SfRnMs3xay2QA=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=oByDma6BRZBcaUMoiVGB5WivqcN879+UhMbzYwphFfQO/5a4HTKmMW+jvBdFowLtAXOUIReJ2hKvMOckjhMJfxiNwolQX6kVhO5STO0NawnVxmFPzFd8JPyzi/r9od4t8jXCrf3yTCN07djRnoq/iSkPDBVcrhlQnRGxljOMnWg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=gourry.net; spf=pass smtp.mailfrom=gourry.net; dkim=pass (2048-bit key) header.d=gourry.net header.i=@gourry.net header.b=fmuiF1cV; arc=none smtp.client-ip=209.85.219.42
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=gourry.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gourry.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gourry.net header.i=@gourry.net header.b="fmuiF1cV"
Received: by mail-qv1-f42.google.com with SMTP id 6a1803df08f44-8f23e851626so111968506d6.3
        for <linux-nfs@vger.kernel.org>; Mon, 20 Jul 2026 10:42:17 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gourry.net; s=google; t=1784569337; x=1785174137; darn=vger.kernel.org;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=FEiCtTnsRTKK1dIfrBs2bZV/1x4AsbAJwsKiFa/5Flg=;
        b=fmuiF1cVzBGLHFg/+jTHpmV30nTh9hXUTaw17dmVwtCI5UwKcWG1E5EmNsdqa4QX50
         AtdYWVg/bFD0JVgfwtUJCiCsxAMUlgSFpmXvrEqOhv1dOG72T2wM3Jfc53Arj3m5S+7e
         zIbGrQjGjARchAGelp20ENUOArztnwTPiEwk/vTkGs+arJF/c56w+gaY5j6ojjGOzpyw
         TYhTmnUs1lmj+SLTaXHaUruHyio3XhJ1ZxPZevaAKXuEm+5m9pmmOyNwv3MwPY0u5lxJ
         91IXHkroQUXG4e+XdHFe7u5UHmtUS1nfxjOJ0uJlX9tO0oU2FqCRBRsoNx6dkEU4rWLE
         MCcg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1784569337; x=1785174137;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=FEiCtTnsRTKK1dIfrBs2bZV/1x4AsbAJwsKiFa/5Flg=;
        b=ooAViof0jzwCE2YOtBOze8ONC+5nwH7smS2PXcrflojRu7432uAutWINitRxA4PGt4
         0p8ZxLlEFNJn+K5a0Ak+5Oxi11dE1WnmADwOWmFhk3hsNlGvxQiWGOUh3HBnTAhxLW6e
         Q2p5cyhJ4gm1lV1mifW+rionzjwm3ynnxWXpI7nsCVfO6Q8icVq2NQ1KOVxF4GGLObdg
         X7EdgwHSNFB5LJ0AaDbsyk9PmeCk7F2zm1tYGa7LTLW7rzzzaXvEE7RYi52NFJCCjInp
         PmdVLgofe9hZtb65gxQDOoZb/OsBVNDitcGJ+KoZvEarP6NX4OugxgQguR7n0lbnGsYY
         VEzQ==
X-Forwarded-Encrypted: i=1; AHgh+RpUbTlrWoftZ/AZkkEhNlM8vMkwelsIbt4tASRt+ZOwQk1R4Ei6Xlm84oQB0xzi2DSPNHUUG0c9Tjo=@vger.kernel.org
X-Gm-Message-State: AOJu0YwCbJzXHSTIZrW/Wa3fqZSR/zxw6I9tJvHZC9jHC3ueZvE3Cl/A
	OlW3Xmv5m/AKiDFCtrcqa9sjFp/ROniy421HThG1gOEfZHzFvu4YpK9G+z3OPtTykv8=
X-Gm-Gg: AR+sD13sjCESHJjh837TJTpA/kNo6BQ6hSeqx4fCerPwAg4DqXf+nedHqWoYgOQhj9N
	jiWk/aRO6ZYDOerHunT+ZRitySCrob8dwL0XZhmDzce4yJT/c+gTgyY04Gt23fOkTs12PbdVMWW
	/uA1M+/vGJIGbqGFlStOjIsWkFFMLyoIs8vfFBxfuw+9rLAXOJKg3+6+lMeHwm6zTq364EBacw2
	3hBYINVkX2iWKl/VG/S4swEQmJKCCiO+VrEdTt2HjafqB4HuHOgRXm1/4+U9IVtNFm16r0btFKX
	mJ6NipU0+e3MzFFvr6B/Npc1WItfdW4Z5uuc8BYNoXdURUf+HHZLsWhj2QaTfAbBDDQXBXh2AA6
	qCdfCS6WMlix/JXIsjc6eRdbT3u7iXMNHL1uO9sny5Brygz+vGdm9NqF7D8JlkobexubWKIZwCe
	hvGfEiFQ8cLnW7GVkB0KVDzpPV7Kma3IqPWW2/Yso52z3OGJYttB/IX4BkPw==
X-Received: by 2002:a05:6214:2349:b0:8ef:6b06:44c8 with SMTP id 6a1803df08f44-907783d1d3fmr150837746d6.48.1784569336788;
        Mon, 20 Jul 2026 10:42:16 -0700 (PDT)
Received: from gourry-fedora-PF4VCD3F (pool-173-79-60-52.washdc.fios.verizon.net. [173.79.60.52])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-90778567f09sm95835516d6.15.2026.07.20.10.42.15
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 20 Jul 2026 10:42:16 -0700 (PDT)
Date: Mon, 20 Jul 2026 13:42:11 -0400
From: Gregory Price <gourry@gourry.net>
To: Brendan Jackman <jackmanb@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, 
	David Hildenbrand <david@kernel.org>, Lorenzo Stoakes <ljs@kernel.org>, 
	"Liam R. Howlett" <liam@infradead.org>, Vlastimil Babka <vbabka@kernel.org>, 
	Mike Rapoport <rppt@kernel.org>, Suren Baghdasaryan <surenb@google.com>, 
	Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Zi Yan <ziy@nvidia.com>, 
	"Matthew Wilcox (Oracle)" <willy@infradead.org>, Jan Kara <jack@suse.cz>, Joshua Hahn <joshua.hahnjy@gmail.com>, 
	Byungchul Park <byungchul@sk.com>, Ying Huang <ying.huang@linux.alibaba.com>, 
	Alistair Popple <apopple@nvidia.com>, Hugh Dickins <hughd@google.com>, 
	Baolin Wang <baolin.wang@linux.alibaba.com>, Chris Li <chrisl@kernel.org>, Kairui Song <kasong@tencent.com>, 
	Kemeng Shi <shikemeng@huaweicloud.com>, Nhat Pham <nphamcs@gmail.com>, Baoquan He <baoquan.he@linux.dev>, 
	Barry Song <baohua@kernel.org>, Youngjun Park <youngjun.park@lge.com>, 
	"Joerg Roedel (AMD)" <joro@8bytes.org>, Will Deacon <will@kernel.org>, 
	Robin Murphy <robin.murphy@arm.com>, Huacai Chen <chenhuacai@kernel.org>, 
	WANG Xuerui <kernel@xen0n.name>, Thomas Gleixner <tglx@kernel.org>, Chuck Lever <cel@kernel.org>, 
	Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
	Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
	"David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, 
	Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, 
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, 
	iommu@lists.linux.dev, loongarch@lists.linux.dev, linux-nfs@vger.kernel.org, 
	netdev@vger.kernel.org
Subject: Re: [PATCH 2/3] mm, treewide: replace __folio_alloc_node() with
 folio_alloc_node()
Message-ID: <al5d1K9yHhT2-yVX@gourry-fedora-PF4VCD3F>
References: <20260716-folio-alloc-cleanups-v1-0-5363b8e92d33@google.com>
 <20260716-folio-alloc-cleanups-v1-2-5363b8e92d33@google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260716-folio-alloc-cleanups-v1-2-5363b8e92d33@google.com>

On Thu, Jul 16, 2026 at 02:30:11PM +0000, Brendan Jackman wrote:
> Commit 5b584d2d22dca ("mm: remove __alloc_pages_node()") removed the __
> variant of alloc_pages_node(), after users had been migrated off it,
> since it just complicates the API (requiring users to handle
> NUMA_NO_NODE, or risking hotplug bugs) for no real benefit.
> 
> This patch brings __folio_alloc_node() into line too for exactly the
> same reasons (including the ulterior motive of freeing up the __ variant
> for use as an internal API).
> 
> This time, it's done as a single patch because A) the users are fewer
> and B) folio_alloc_node() does not already exist like
> alloc_pages_node() did.
> 
> No functional change intended.
> 
> Suggested-by: "Vlastimil Babka (SUSE)" <vbabka@kernel.org>
> Link: https://lore.kernel.org/all/ed4572f4-0074-45c5-993d-7b6533eddc31@kernel.org/
> Signed-off-by: Brendan Jackman <jackmanb@google.com>

Reviewed-by: Gregory Price <gourry@gourry.net>

> ---
>  drivers/iommu/iommu-pages.c        |  9 +--------
>  drivers/irqchip/irq-loongarch-ir.c |  4 ++--
>  include/linux/gfp.h                | 12 +++---------
>  mm/filemap.c                       |  2 +-
>  mm/migrate.c                       |  2 +-
>  mm/page_alloc.c                    | 17 +++++++++++++++--
>  net/sunrpc/svc.c                   |  2 +-
>  7 files changed, 24 insertions(+), 24 deletions(-)
> 
> diff --git a/drivers/iommu/iommu-pages.c b/drivers/iommu/iommu-pages.c
> index 3bab175d85571..47e0759f0e0ae 100644
> --- a/drivers/iommu/iommu-pages.c
> +++ b/drivers/iommu/iommu-pages.c
> @@ -56,14 +56,7 @@ void *iommu_alloc_pages_node_sz(int nid, gfp_t gfp, size_t size)
>  	 */
>  	order = get_order(size);
>  
> -	/*
> -	 * __folio_alloc_node() does not handle NUMA_NO_NODE like
> -	 * alloc_pages_node() did.
> -	 */
> -	if (nid == NUMA_NO_NODE)
> -		nid = numa_mem_id();
> -
> -	folio = __folio_alloc_node(gfp | __GFP_ZERO, order, nid);
> +	folio = folio_alloc_node(gfp | __GFP_ZERO, order, nid);
>  	if (unlikely(!folio))
>  		return NULL;
>  
> diff --git a/drivers/irqchip/irq-loongarch-ir.c b/drivers/irqchip/irq-loongarch-ir.c
> index 21c649a89a706..427f7fd3cad42 100644
> --- a/drivers/irqchip/irq-loongarch-ir.c
> +++ b/drivers/irqchip/irq-loongarch-ir.c
> @@ -384,7 +384,7 @@ static int redirect_table_init(struct redirect_desc *irde)
>  	unsigned long *bitmap;
>  	struct folio *folio;
>  
> -	folio = __folio_alloc_node(GFP_KERNEL | __GFP_ZERO, IRD_TABLE_PAGE_ORDER, irde->node);
> +	folio = folio_alloc_node(GFP_KERNEL | __GFP_ZERO, IRD_TABLE_PAGE_ORDER, irde->node);
>  	if (!folio) {
>  		pr_err("Node [%d] redirect table alloc pages failed!\n", irde->node);
>  		return -ENOMEM;
> @@ -410,7 +410,7 @@ static int redirect_queue_init(struct redirect_desc *irde)
>  	struct redirect_queue *inv_queue = &irde->inv_queue;
>  	struct folio *folio;
>  
> -	folio = __folio_alloc_node(GFP_KERNEL | __GFP_ZERO, INV_QUEUE_PAGE_ORDER, irde->node);
> +	folio = folio_alloc_node(GFP_KERNEL | __GFP_ZERO, INV_QUEUE_PAGE_ORDER, irde->node);
>  	if (!folio) {
>  		pr_err("Node [%d] invalid queue alloc pages failed!\n", irde->node);
>  		return -ENOMEM;
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index e4e974a6e5f90..572605d84e30e 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -251,15 +251,9 @@ static inline void warn_if_node_offline(int this_node, gfp_t gfp_mask)
>  	dump_stack();
>  }
>  
> -static inline
> -struct folio *__folio_alloc_node_noprof(gfp_t gfp, unsigned int order, int nid)
> -{
> -	warn_if_node_offline(nid, gfp);
> +struct folio *folio_alloc_node_noprof(gfp_t gfp, unsigned int order, int nid);
>  
> -	return __folio_alloc_noprof(gfp, order, nid, NULL);
> -}
> -
> -#define  __folio_alloc_node(...)		alloc_hooks(__folio_alloc_node_noprof(__VA_ARGS__))
> +#define  folio_alloc_node(...)		alloc_hooks(folio_alloc_node_noprof(__VA_ARGS__))
>  
>  /*
>   * Allocate pages, preferring the node given as nid. When nid == NUMA_NO_NODE,
> @@ -282,7 +276,7 @@ static inline struct page *alloc_pages_noprof(gfp_t gfp_mask, unsigned int order
>  }
>  static inline struct folio *folio_alloc_noprof(gfp_t gfp, unsigned int order)
>  {
> -	return __folio_alloc_node_noprof(gfp, order, numa_node_id());
> +	return folio_alloc_node_noprof(gfp, order, numa_node_id());
>  }
>  static inline struct folio *vma_alloc_folio_noprof(gfp_t gfp, int order,
>  		struct vm_area_struct *vma, unsigned long addr)
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 0dd8e2a15d746..1cf91970a6850 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -1007,7 +1007,7 @@ struct folio *filemap_alloc_folio_noprof(gfp_t gfp, unsigned int order,
>  		do {
>  			cpuset_mems_cookie = read_mems_allowed_begin();
>  			n = cpuset_mem_spread_node();
> -			folio = __folio_alloc_node_noprof(gfp, order, n);
> +			folio = folio_alloc_node_noprof(gfp, order, n);
>  		} while (!folio && read_mems_allowed_retry(cpuset_mems_cookie));
>  
>  		return folio;
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 222c8c15f782f..b7836b02f32db 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -2682,7 +2682,7 @@ static struct folio *alloc_misplaced_dst_folio(struct folio *src,
>  			__GFP_NOWARN;
>  		gfp &= ~__GFP_RECLAIM;
>  	}
> -	return __folio_alloc_node(gfp, order, nid);
> +	return folio_alloc_node(gfp, order, nid);
>  }
>  
>  /*
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 37a3c1c00e169..86922270df157 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5435,12 +5435,25 @@ EXPORT_SYMBOL(alloc_pages_node_noprof);
>  struct folio *__folio_alloc_noprof(gfp_t gfp, unsigned int order, int preferred_nid,
>  		nodemask_t *nodemask)
>  {
> -	struct page *page = __alloc_pages_noprof(gfp | __GFP_COMP, order,
> -					preferred_nid, nodemask, ALLOC_DEFAULT);
> +	struct page *page;
> +
> +	if (preferred_nid == NUMA_NO_NODE)
> +		preferred_nid = numa_mem_id();
> +
> +	warn_if_node_offline(preferred_nid, gfp);
> +
> +	page = __alloc_pages_noprof(gfp | __GFP_COMP, order,
> +				    preferred_nid, nodemask, ALLOC_DEFAULT);
>  	return page_rmappable_folio(page);
>  }
>  EXPORT_SYMBOL(__folio_alloc_noprof);
>  
> +struct folio *folio_alloc_node_noprof(gfp_t gfp, unsigned int order, int nid)
> +{
> +	return __folio_alloc_noprof(gfp, order, nid, NULL);
> +}
> +EXPORT_SYMBOL(folio_alloc_node_noprof);
> +
>  /*
>   * Common helper functions. Never use with __GFP_HIGHMEM because the returned
>   * address cannot represent highmem pages. Use alloc_pages and then kmap if
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index ae9ec4bf34f72..74350a2e07036 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -711,7 +711,7 @@ svc_prepare_thread(struct svc_serv *serv, struct svc_pool *pool, int node)
>  	rqstp->rq_server = serv;
>  	rqstp->rq_pool = pool;
>  
> -	rqstp->rq_scratch_folio = __folio_alloc_node(GFP_KERNEL, 0, node);
> +	rqstp->rq_scratch_folio = folio_alloc_node(GFP_KERNEL, 0, node);
>  	if (!rqstp->rq_scratch_folio)
>  		goto out_enomem;
>  
> 
> -- 
> 2.54.0
> 
> 
