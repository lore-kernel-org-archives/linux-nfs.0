Received: from out-171.mta0.migadu.com (out-171.mta0.migadu.com [91.218.175.171])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C8C8F37DAA6
	for <linux-nfs@vger.kernel.org>; Wed, 22 Jul 2026 16:32:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=91.218.175.171
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784737948; cv=none; b=PuZ3ckKUeQ+8qhcXZEygGZJduQIT5cn28x8Mkoi+c04ycs4KeNF0mToTL9VYYH+bDFDgNWoq7CgpuOGrhvIdkPy8dssRsnplp6qc+ABHirepcHNlXvwVwI9/s+hLTNcf6w5KgM14+9x1DJzBc++lar2gCChVFaqWLka7cWW4lRM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784737948; c=relaxed/simple;
	bh=+Xs4Rj1CmAXrmze4cIJbNyszF+UOlvCrEcOhbbh12ag=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=i1zjzKKMSFWZal9RlSCRf/3+ytpfShYYHdTf6fFXjfM273xsUQikjZDqQ7RoR7EP5tDIO+QRn3ZzHnzSN02SyjmkT0MjWfBFQvuiRKYd2rOQ1tS38rWm3V7io9SgQMfHIR+AnEGzBGE2N71L7XABRnLes3YveYwtuYZF9tLLi8Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev; spf=pass smtp.mailfrom=linux.dev; dkim=pass (1024-bit key) header.d=linux.dev header.i=@linux.dev header.b=b0Rt1yNk; arc=none smtp.client-ip=91.218.175.171
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.dev
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux.dev header.i=@linux.dev header.b="b0Rt1yNk"
X-Report-Abuse: Please report any abuse attempt to abuse@migadu.com and include these headers.
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linux.dev; s=key1;
	t=1784737944;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=bBnIrrxiyHbn5CbW2/3RvfkB4lrliRmpnHXHN4bKIgA=;
	b=b0Rt1yNkrfg4I8fIySJ7tAmqfRb/Rv7DlSybC9R/Cxce9tKHq48cy7/r/AoabRFRXbmLoS
	GTnqjiTkp4wrI86UX+LsR+yLWAl3mRARIY31Dz4xpRbhC9PecgUBRKwJScz9DmdsKW4gq/
	l8Jv5MWPPRaQw8rpGnXT4vA8GhYeRgE=
From: Usama Arif <usama.arif@linux.dev>
To: Christoph Hellwig <hch@lst.de>
Cc: Usama Arif <usama.arif@linux.dev>,
	baoquan.he@linux.dev,
	akpm@linux-foundation.org,
	chrisl@kernel.org,
	kasong@tencent.com,
	nphamcs@gmail.com,
	shikemeng@huaweicloud.com,
	youngjun.park@lge.com,
	ryncsn@gmail.com,
	trondmy@kernel.org,
	anna@kernel.org,
	sfrench@samba.org,
	linux-mm@kvack.org,
	linux-cifs@vger.kernel.org,
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/3] mm/swap: add a new swap_ops.h header to allow for pluggable swap ops
Date: Wed, 22 Jul 2026 09:32:17 -0700
Message-ID: <20260722163218.1240273-1-usama.arif@linux.dev>
In-Reply-To: <20260722130615.3163560-3-hch@lst.de>
References: 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Migadu-Flow: FLOW_OUT

On Wed, 22 Jul 2026 15:06:08 +0200 Christoph Hellwig <hch@lst.de> wrote:

> Add a new header to declare the swap_iocb, swap_ops and swap_ctx to
> allow for swap_ops implementations outside of mm/page_io.c.  This
> will be used to remove the double indirection for file system-based
> swap.
> 
> Note that there already is a swapops.h header, which is totally
> unrelated to struct swap_ops.  The close naming is a bit unfortunate,
> but I could not think of a better name for this header.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  MAINTAINERS              |  1 +
>  include/linux/swap_ops.h | 39 +++++++++++++++++++++++++++++++++++++++
>  mm/madvise.c             |  1 +
>  mm/page_io.c             | 10 +---------
>  mm/shmem.c               |  1 +
>  mm/swap.h                | 23 +----------------------
>  mm/swap_state.c          |  1 +
>  mm/vmscan.c              |  1 +
>  8 files changed, 46 insertions(+), 31 deletions(-)
>  create mode 100644 include/linux/swap_ops.h
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 5da77924c6f0..cda42b7ed945 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -17240,6 +17240,7 @@ S:	Maintained
>  F:	Documentation/ABI/testing/sysfs-kernel-mm-swap
>  F:	Documentation/mm/swap-table.rst
>  F:	include/linux/swap.h
> +F:	include/linux/swap_ops.h
>  F:	include/linux/swapfile.h
>  F:	include/linux/swapops.h
>  F:	mm/page_io.c
> diff --git a/include/linux/swap_ops.h b/include/linux/swap_ops.h
> new file mode 100644
> index 000000000000..e92b4f532604
> --- /dev/null
> +++ b/include/linux/swap_ops.h
> @@ -0,0 +1,39 @@
> +/* SPDX-License-Identifier: GPL-2.0 */
> +#ifndef _MM_SWAP_OPS_H
> +#define _MM_SWAP_OPS_H
> +
> +#include <linux/swap.h> /* for SWAP_CLUSTER_MAX */
> +
> +struct swap_iocb {
> +	union {
> +		struct kiocb	iocb;
> +		struct bio	bio;
> +	};
> +	struct bio_vec		bvecs[SWAP_CLUSTER_MAX];
> +	int			nr_bvecs;
> +	int			len;
> +};
> +
> +struct swap_io_ctx {
> +	struct swap_iocb	*sio;
> +	struct swap_info_struct	*sis;
> +};

zswap uses this struct, I think you need to include the header in zswap.c
as well, good to check if the build is passing with CONFIG_ZSWAP=y

> +
> +/*
> + * SWAP_OPS_F_REQUIRE_NOFS:
> + *	When set, all reclaim operations must operated as GFS_NOFS and not
> + *	just GFP_NOIO, as GFP_NOIO allocations could recourse into the
> + *	file system backing this swap file.
> + */
> +#define SWAP_OPS_F_REQUIRE_NOFS		(1U << 0)
> +
> +struct swap_ops {
> +	unsigned int		flags;
> +
> +	bool (*can_merge)(struct folio *folio, struct folio *prev_folio,
> +			size_t prev_folio_size, int rw);
> +	void (*submit_write)(struct swap_io_ctx *ctx);
> +	void (*submit_read)(struct swap_io_ctx *ctx);
> +};
> +
> +#endif /* _MM_SWAP_OPS_H */
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 07a21ca31bad..c179938097bf 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -32,6 +32,7 @@
>  #include <linux/leafops.h>
>  #include <linux/shmem_fs.h>
>  #include <linux/mmu_notifier.h>
> +#include <linux/swap_ops.h>
>  
>  #include <asm/tlb.h>
>  
> diff --git a/mm/page_io.c b/mm/page_io.c
> index c984a4023a65..e741e67d6592 100644
> --- a/mm/page_io.c
> +++ b/mm/page_io.c
> @@ -25,6 +25,7 @@
>  #include <linux/sched/task.h>
>  #include <linux/delayacct.h>
>  #include <linux/zswap.h>
> +#include <linux/swap_ops.h>
>  #include "swap.h"
>  #include "swap_table.h"
>  
> @@ -300,15 +301,6 @@ static bool folio_blkg_can_merge(struct folio *folio, struct folio *prev_folio)
>  #define bio_associate_blkg_from_page(bio, folio)		do { } while (0)
>  #endif /* CONFIG_MEMCG && CONFIG_BLK_CGROUP */
>  
> -struct swap_iocb {
> -	union {
> -		struct kiocb	iocb;
> -		struct bio	bio;
> -	};
> -	struct bio_vec		bvecs[SWAP_CLUSTER_MAX];
> -	int			nr_bvecs;
> -	int			len;
> -};
>  static mempool_t *sio_pool;
>  
>  int sio_pool_init(void)
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 5071177059a9..797c42f024a0 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -41,6 +41,7 @@
>  #include <linux/swapfile.h>
>  #include <linux/iversion.h>
>  #include <linux/unicode.h>
> +#include <linux/swap_ops.h>
>  #include "swap.h"
>  
>  static struct vfsmount *shm_mnt __ro_after_init;
> diff --git a/mm/swap.h b/mm/swap.h
> index abd26588abd2..19ea61c97df2 100644
> --- a/mm/swap.h
> +++ b/mm/swap.h
> @@ -8,6 +8,7 @@
>  struct mempolicy;
>  struct swap_iocb;
>  struct swap_memcg_table;
> +struct swap_io_ctx;
>  
>  #if defined(MAX_POSSIBLE_PHYSMEM_BITS)
>  #define SWAP_CACHE_PFN_BITS (MAX_POSSIBLE_PHYSMEM_BITS - PAGE_SHIFT)
> @@ -77,28 +78,6 @@ enum swap_cluster_flags {
>  	CLUSTER_FLAG_MAX,
>  };
>  
> -struct swap_io_ctx {
> -	struct swap_iocb	*sio;
> -	struct swap_info_struct	*sis;
> -};
> -
> -/*
> - * SWAP_OPS_F_REQUIRE_NOFS:
> - *	When set, all reclaim operations must operated as GFS_NOFS and not
> - *	just GFP_NOIO, as GFP_NOIO allocations could recourse into the
> - *	file system backing this swap file.
> - */
> -#define SWAP_OPS_F_REQUIRE_NOFS		(1U << 0)
> -
> -struct swap_ops {
> -	unsigned int		flags;
> -
> -	bool (*can_merge)(struct folio *folio, struct folio *prev_folio,
> -			size_t prev_folio_size, int rw);
> -	void (*submit_write)(struct swap_io_ctx *ctx);
> -	void (*submit_read)(struct swap_io_ctx *ctx);
> -};
> -
>  #ifdef CONFIG_SWAP
>  #include <linux/swapops.h> /* for swp_offset */
>  #include <linux/blk_types.h> /* for bio_end_io_t */
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index 5be825911e64..b76eb3d876fd 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -23,6 +23,7 @@
>  #include <linux/huge_mm.h>
>  #include <linux/shmem_fs.h>
>  #include <linux/sysctl.h>
> +#include <linux/swap_ops.h>
>  #include "internal.h"
>  #include "swap_table.h"
>  #include "swap.h"
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index e26c6931f5fd..a12eb79c89c5 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -58,6 +58,7 @@
>  #include <linux/random.h>
>  #include <linux/mmu_notifier.h>
>  #include <linux/parser.h>
> +#include <linux/swap_ops.h>
>  
>  #include <asm/tlbflush.h>
>  #include <asm/div64.h>
> -- 
> 2.53.0
> 
> 
