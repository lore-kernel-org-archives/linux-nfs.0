Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E385D329E7E;
	Thu, 16 Jul 2026 15:22:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784215339; cv=none; b=V1JvYbPlcn8mLPqXfTBBB+rdmp+g5LxOWj7VryoDVegC2H3SiAVQ1/D+lUYdnaXFO3Ht5RsC3ZCBC5Kn0re71OneGlFQMtamKaGLpELEn+b7T9BsA9HHqxJOIEuVQcntmdBuqh0NhrE7X2ax8RaKabFY+MSVsvhJd8lTAR5EsB0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784215339; c=relaxed/simple;
	bh=rxpuCNuKpyTBiIKuxYfszGMJHS6b0plXNAx2ALfLmhg=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=lobKjzxDpltL3ftPO+/8Kg/PhD+xCW12Fd/yBypuST0ZqvyCoPZxyk9wfcBwEwqcc0Rg3b4pSOx9qRfAIzyGIf7E9KlVon4WXkG9yVWNID4vQb/AQXCjFoPksWNsH9AdIY4p4nQoBKHvoXOEuT/naW7UAP/OPdZwYZ2Cz7MVmLg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=MhItb7t5; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="MhItb7t5"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 11FB81F000E9;
	Thu, 16 Jul 2026 15:22:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784215337;
	bh=9iUKaKWQgUmhoByo8PPUUf8IwOUE3JnNHfIAyoMta5w=;
	h=Date:Subject:To:Cc:References:From:In-Reply-To;
	b=MhItb7t5ytZUlRsU1B0Bk/pzL+kLJfVLF6hJZHugPO4vEngLOFShgLkBy/n1TDXIA
	 g3DCLjmgWeIMhcCrnZDrYeVh15CoaJkgIurVoX/7Ndo4WFvwiPdBsCI3kFYEqh/Uia
	 AW6egms8Hv2+ShjUIBdIlEqqE8XCMI+i6sWcZxUQ2F7LUStZf6VS0goN+HF3ZrnFjv
	 KdZ7ZpMBP1f1MaT1ZUC4eBJwAiKmIXWgxG+2KDB6u0kA6Q5Zp+eEczO2IX7LF3Ip2x
	 SqMIe+3nvJwy6/gpWEFiicWbPp4qM0Pm7tPHhRZB0+cNw8v6QrWUUAjWtsMX7KtBOk
	 /LtacDoJduqww==
Message-ID: <73d3c545-dd8a-4131-9826-1a7096dd619a@kernel.org>
Date: Thu, 16 Jul 2026 17:22:06 +0200
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 1/3] mm: move internal mempolicy APIs to new internal
 header
Content-Language: en-US
To: Brendan Jackman <jackmanb@google.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 David Hildenbrand <david@kernel.org>, Lorenzo Stoakes <ljs@kernel.org>,
 "Liam R. Howlett" <liam@infradead.org>, Mike Rapoport <rppt@kernel.org>,
 Suren Baghdasaryan <surenb@google.com>, Michal Hocko <mhocko@suse.com>,
 Johannes Weiner <hannes@cmpxchg.org>, Zi Yan <ziy@nvidia.com>,
 "Matthew Wilcox (Oracle)" <willy@infradead.org>, Jan Kara <jack@suse.cz>,
 Joshua Hahn <joshua.hahnjy@gmail.com>, Byungchul Park <byungchul@sk.com>,
 Gregory Price <gourry@gourry.net>, Ying Huang
 <ying.huang@linux.alibaba.com>, Alistair Popple <apopple@nvidia.com>,
 Hugh Dickins <hughd@google.com>, Baolin Wang
 <baolin.wang@linux.alibaba.com>, Chris Li <chrisl@kernel.org>,
 Kairui Song <kasong@tencent.com>, Kemeng Shi <shikemeng@huaweicloud.com>,
 Nhat Pham <nphamcs@gmail.com>, Baoquan He <baoquan.he@linux.dev>,
 Barry Song <baohua@kernel.org>, Youngjun Park <youngjun.park@lge.com>,
 "Joerg Roedel (AMD)" <joro@8bytes.org>, Will Deacon <will@kernel.org>,
 Robin Murphy <robin.murphy@arm.com>, Huacai Chen <chenhuacai@kernel.org>,
 WANG Xuerui <kernel@xen0n.name>, Thomas Gleixner <tglx@kernel.org>,
 Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>,
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>,
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
 "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>,
 Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>,
 Simon Horman <horms@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-fsdevel@vger.kernel.org, iommu@lists.linux.dev,
 loongarch@lists.linux.dev, linux-nfs@vger.kernel.org, netdev@vger.kernel.org
References: <20260716-folio-alloc-cleanups-v1-0-5363b8e92d33@google.com>
 <20260716-folio-alloc-cleanups-v1-1-5363b8e92d33@google.com>
From: "Vlastimil Babka (SUSE)" <vbabka@kernel.org>
Autocrypt: addr=vbabka@kernel.org; keydata=
 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
In-Reply-To: <20260716-folio-alloc-cleanups-v1-1-5363b8e92d33@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

On 7/16/26 16:30, Brendan Jackman wrote:
> There are no external users for this surface, reduce the scope.
> 
> Ulterior motive: a later patch will add an alloc_flags arg to some parts
> of this.
> 
> Note it might seem like this could just go in internal.h, since it's
> pretty small, but actually it will eventually need to import
> page_alloc.h, we don't want to import that from internal.h so best to
> proactively created this header now.

Hmm, maybe it could just go to page_alloc.h then? After all this is just
bunch of internal page allocation functions, which just take the mempolicy
pointer?

> Signed-off-by: Brendan Jackman <jackmanb@google.com>
> ---
>  MAINTAINERS         |  1 +
>  include/linux/gfp.h |  9 ---------
>  mm/filemap.c        |  2 ++
>  mm/mempolicy.c      |  1 +
>  mm/mempolicy.h      | 31 +++++++++++++++++++++++++++++++
>  mm/shmem.c          |  1 +
>  mm/swap_state.c     |  1 +
>  7 files changed, 37 insertions(+), 9 deletions(-)
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 8813d5d7eb0c1..9cde99c259639 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -17068,6 +17068,7 @@ F:	include/uapi/linux/mempolicy.h
>  F:	include/linux/migrate.h
>  F:	include/linux/migrate_mode.h
>  F:	mm/mempolicy.c
> +F:	mm/mempolicy.h
>  F:	mm/migrate.c
>  F:	mm/migrate_device.c
>  
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 872bc53f32ec8..e4e974a6e5f90 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -11,7 +11,6 @@
>  #include <linux/sched.h>
>  
>  struct vm_area_struct;
> -struct mempolicy;
>  
>  /* Helper macro to avoid gfp flags if they are the default one */
>  #define __default_gfp(a,b,...) b
> @@ -274,8 +273,6 @@ struct page *alloc_pages_node_noprof(int nid, gfp_t gfp_mask, unsigned int order
>  #ifdef CONFIG_NUMA
>  struct page *alloc_pages_noprof(gfp_t gfp, unsigned int order);
>  struct folio *folio_alloc_noprof(gfp_t gfp, unsigned int order);
> -struct folio *folio_alloc_mpol_noprof(gfp_t gfp, unsigned int order,
> -		struct mempolicy *mpol, pgoff_t ilx, int nid);
>  struct folio *vma_alloc_folio_noprof(gfp_t gfp, int order, struct vm_area_struct *vma,
>  		unsigned long addr);
>  #else
> @@ -287,11 +284,6 @@ static inline struct folio *folio_alloc_noprof(gfp_t gfp, unsigned int order)
>  {
>  	return __folio_alloc_node_noprof(gfp, order, numa_node_id());
>  }
> -static inline struct folio *folio_alloc_mpol_noprof(gfp_t gfp, unsigned int order,
> -		struct mempolicy *mpol, pgoff_t ilx, int nid)
> -{
> -	return folio_alloc_noprof(gfp, order);
> -}
>  static inline struct folio *vma_alloc_folio_noprof(gfp_t gfp, int order,
>  		struct vm_area_struct *vma, unsigned long addr)
>  {
> @@ -301,7 +293,6 @@ static inline struct folio *vma_alloc_folio_noprof(gfp_t gfp, int order,
>  
>  #define alloc_pages(...)			alloc_hooks(alloc_pages_noprof(__VA_ARGS__))
>  #define folio_alloc(...)			alloc_hooks(folio_alloc_noprof(__VA_ARGS__))
> -#define folio_alloc_mpol(...)			alloc_hooks(folio_alloc_mpol_noprof(__VA_ARGS__))
>  #define vma_alloc_folio(...)			alloc_hooks(vma_alloc_folio_noprof(__VA_ARGS__))
>  
>  #define alloc_page(gfp_mask) alloc_pages(gfp_mask, 0)
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 1dbb4c6f824e9..0dd8e2a15d746 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -52,6 +52,7 @@
>  
>  #include <asm/tlbflush.h>
>  #include "internal.h"
> +#include "mempolicy.h"
>  
>  #define CREATE_TRACE_POINTS
>  #include <trace/events/filemap.h>
> @@ -63,6 +64,7 @@
>  
>  #include <asm/mman.h>
>  
> +#include "mempolicy.h"
>  #include "swap.h"
>  
>  /*
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 5720f7f54d942..31c4e9f49b5e9 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -119,6 +119,7 @@
>  #include <linux/memory.h>
>  
>  #include "internal.h"
> +#include "mempolicy.h"
>  #include "page_alloc.h"
>  
>  /* Internal flags */
> diff --git a/mm/mempolicy.h b/mm/mempolicy.h
> new file mode 100644
> index 0000000000000..d80fe4c559786
> --- /dev/null
> +++ b/mm/mempolicy.h
> @@ -0,0 +1,31 @@
> +/* SPDX-License-Identifier: GPL-2.0-or-later */
> +/*
> + * mm-internal API for mempolicy.c. Public API lives in
> + * include/linux/mempolicy.h.
> + */
> +#ifndef __MM_MEMPOLICY_H
> +#define __MM_MEMPOLICY_H
> +
> +#include <linux/gfp.h>
> +#include <linux/mempolicy.h>
> +
> +#ifdef CONFIG_NUMA
> +struct folio *folio_alloc_mpol_noprof(gfp_t gfp, unsigned int order,
> +		struct mempolicy *mpol, pgoff_t ilx, int nid);
> +#else
> +static inline struct folio *folio_alloc_mpol_noprof(gfp_t gfp, unsigned int order,
> +		struct mempolicy *mpol, pgoff_t ilx, int nid)
> +{
> +	return folio_alloc_noprof(gfp, order);
> +}
> +#endif
> +
> +#define folio_alloc_mpol(...)			alloc_hooks(folio_alloc_mpol_noprof(__VA_ARGS__))
> +
> +unsigned long alloc_pages_bulk_mempolicy_noprof(gfp_t gfp,
> +				unsigned long nr_pages,
> +				struct page **page_array);
> +#define  alloc_pages_bulk_mempolicy(...)				\
> +	alloc_hooks(alloc_pages_bulk_mempolicy_noprof(__VA_ARGS__))
> +
> +#endif /* __MM_MEMPOLICY_H */
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 5071177059a96..69f561332bb93 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -41,6 +41,7 @@
>  #include <linux/swapfile.h>
>  #include <linux/iversion.h>
>  #include <linux/unicode.h>
> +#include "mempolicy.h"
>  #include "swap.h"
>  
>  static struct vfsmount *shm_mnt __ro_after_init;
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index 5be825911e645..8ccd03c39a407 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -24,6 +24,7 @@
>  #include <linux/shmem_fs.h>
>  #include <linux/sysctl.h>
>  #include "internal.h"
> +#include "mempolicy.h"
>  #include "swap_table.h"
>  #include "swap.h"
>  
> 

