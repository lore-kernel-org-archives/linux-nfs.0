Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9DE9947D240
	for <linux-nfs@vger.kernel.org>; Thu, 23 Jul 2026 17:12:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784826727; cv=none; b=qwdfdv62pQSU15njaJkBWNZPigl5nNApB1IR6S7VkDUsCZXH3UqBKoBqhTEgIS42A01Rxpc0OxASHCHf9xllXJ1k6z3O1Iofm38E/W5mVuIApNQyJoEzcJwoD+QMHJWVP6taVkWghXpZU63DqqKZUS6aF1dgU8lXIi0Nqcev6J0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784826727; c=relaxed/simple;
	bh=xk/5Z0Nhw7TT5BrgFNXgOQo2v8+pC3agv8kHIRqwwE8=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=Ca52W3diDT+WNXLEqq4fN8nIrXSMcUtnT/DqlsGJfwOHHeB0RXX/+vGjdsOXk0no6UM4wskUrKeRgrzT5yih9tPoOlsspqWjb/LuF2rGxkUpeP4Yg3HCno/onahUWY4H++cZnO5lZpHcFUxERGiXzDllidc7zWjOVLoWhbj9rPk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=gUQrHFl/; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="gUQrHFl/"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 94A311F000E9
	for <linux-nfs@vger.kernel.org>; Thu, 23 Jul 2026 17:12:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784826723;
	bh=Vy3lpdlZhVoJO12cvkXIy0QiQ7yg4bA2Tl2yEbGhkSo=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc;
	b=gUQrHFl/HMsNSF5sBdkiQYARNZ33bPUR+THER9cNhlKgxEXp5bM+17F9zQC4e3tLo
	 e+q7PdRbDIjiQia+2Q8AKTB2FQfobU3BzhZi006IAViBbz68pq8DR8OgwMat226x79
	 LdfZSdksTLRJkTKZbZQ+wHabI3KdVQ7QFr+Y5UfmGI+pDJF5EZfLigl3/NPb6H74JH
	 BTCx6xqO4vGrDXw+35ZFGLL5enshahaYzsfj+nJFnKmV69d8+FHo9Vxww1Q21K+FXi
	 s0u0pXRJFxMbrFjfNIC3Vk90bSEGIJzqijL8y7iAoeDxYFYxn9nakWzjhWtLqvF2TH
	 4EpKnHOLZH3hQ==
Received: by mail-yx1-f42.google.com with SMTP id 956f58d0204a3-66807ba2f0fso870076d50.3
        for <linux-nfs@vger.kernel.org>; Thu, 23 Jul 2026 10:12:03 -0700 (PDT)
X-Forwarded-Encrypted: i=1; AHgh+Ro12hJqhRn8oBY36Ypo4Q+eBppDIdvje/+1hnuDD5Pk9ge65VTtYXzFoWHuuDfxjLwh3uGUWVXNOV0=@vger.kernel.org
X-Gm-Message-State: AOJu0YwWeLtv6Bx3E6zyTipbcs59zIxB/80lY2PTUiKx9jtldh3LVGZm
	lX9Iz4C3Ynse32VcwMUXHGmPT+X1qQxhfNgfDDLIhKfVwqgAiHpUF0/V6ACg4+c23Sl8TF0qeMs
	NafgGkzJIm8Pl4ic4Tt4dE9AS+4C3/j84PXqBwsWspQ==
X-Received: by 2002:a53:ca4c:0:b0:667:8b9c:e6c4 with SMTP id
 956f58d0204a3-668a500cae8mr796538d50.104.1784826714641; Thu, 23 Jul 2026
 10:11:54 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260723054622.3460249-1-hch@lst.de> <20260723054622.3460249-3-hch@lst.de>
In-Reply-To: <20260723054622.3460249-3-hch@lst.de>
From: Chris Li <chrisl@kernel.org>
Date: Thu, 23 Jul 2026 10:11:43 -0700
X-Gmail-Original-Message-ID: <CACePvbUTUXPR6JQhBEnsOT2qwhpeyb8ycXkAaSj=DT=T+KDDtA@mail.gmail.com>
X-Gm-Features: AUfX_myqyuT5hBkyXIBFLmZ_g9vicrtyLEsDrAbfU8CZGQvWhiy3AApog2t068c
Message-ID: <CACePvbUTUXPR6JQhBEnsOT2qwhpeyb8ycXkAaSj=DT=T+KDDtA@mail.gmail.com>
Subject: Re: [PATCH 2/3] mm/swap: add a new swap_ops.h header to allow for
 pluggable swap ops
To: Christoph Hellwig <hch@lst.de>
Cc: baoquan.he@linux.dev, akpm@linux-foundation.org, usama.arif@linux.dev, 
	kasong@tencent.com, nphamcs@gmail.com, shikemeng@huaweicloud.com, 
	youngjun.park@lge.com, ryncsn@gmail.com, trondmy@kernel.org, anna@kernel.org, 
	sfrench@samba.org, linux-mm@kvack.org, linux-cifs@vger.kernel.org, 
	linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, Jul 22, 2026 at 10:47=E2=80=AFPM Christoph Hellwig <hch@lst.de> wro=
te:
>
> Add a new header to declare the swap_iocb, swap_ops and swap_ctx to
> allow for swap_ops implementations outside of mm/page_io.c.  This
> will be used to remove the double indirection for file system-based
> swap.  There is no functional change, just a move of the declarations.
>
> Note that there already is a swapops.h header, which is totally
> unrelated to struct swap_ops.  The close naming is a bit unfortunate,
> but I could not think of a better name for this header.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Acked-by: Chris Li <chrisl@kernel.org>

Chris

> ---
>  MAINTAINERS              |  1 +
>  include/linux/swap_ops.h | 39 +++++++++++++++++++++++++++++++++++++++
>  mm/madvise.c             |  1 +
>  mm/page_io.c             | 10 +---------
>  mm/shmem.c               |  1 +
>  mm/swap.h                | 23 +----------------------
>  mm/swap_state.c          |  1 +
>  mm/vmscan.c              |  1 +
>  mm/zswap.c               |  2 +-
>  9 files changed, 47 insertions(+), 32 deletions(-)
>  create mode 100644 include/linux/swap_ops.h
>
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 15dd00c7ffec..713275f62ec4 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -17240,6 +17240,7 @@ S:      Maintained
>  F:     Documentation/ABI/testing/sysfs-kernel-mm-swap
>  F:     Documentation/mm/swap-table.rst
>  F:     include/linux/swap.h
> +F:     include/linux/swap_ops.h
>  F:     include/linux/swapfile.h
>  F:     include/linux/swapops.h
>  F:     mm/page_io.c
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
> +       union {
> +               struct kiocb    iocb;
> +               struct bio      bio;
> +       };
> +       struct bio_vec          bvecs[SWAP_CLUSTER_MAX];
> +       int                     nr_bvecs;
> +       int                     len;
> +};
> +
> +struct swap_io_ctx {
> +       struct swap_iocb        *sio;
> +       struct swap_info_struct *sis;
> +};
> +
> +/*
> + * SWAP_OPS_F_REQUIRE_NOFS:
> + *     When set, all reclaim operations must operated as GFS_NOFS and no=
t
> + *     just GFP_NOIO, as GFP_NOIO allocations could recourse into the
> + *     file system backing this swap file.
> + */
> +#define SWAP_OPS_F_REQUIRE_NOFS                (1U << 0)
> +
> +struct swap_ops {
> +       unsigned int            flags;
> +
> +       bool (*can_merge)(struct folio *folio, struct folio *prev_folio,
> +                       size_t prev_folio_size, int rw);
> +       void (*submit_write)(struct swap_io_ctx *ctx);
> +       void (*submit_read)(struct swap_io_ctx *ctx);
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
> @@ -300,15 +301,6 @@ static bool folio_blkg_can_merge(struct folio *folio=
, struct folio *prev_folio)
>  #define bio_associate_blkg_from_page(bio, folio)               do { } wh=
ile (0)
>  #endif /* CONFIG_MEMCG && CONFIG_BLK_CGROUP */
>
> -struct swap_iocb {
> -       union {
> -               struct kiocb    iocb;
> -               struct bio      bio;
> -       };
> -       struct bio_vec          bvecs[SWAP_CLUSTER_MAX];
> -       int                     nr_bvecs;
> -       int                     len;
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
>         CLUSTER_FLAG_MAX,
>  };
>
> -struct swap_io_ctx {
> -       struct swap_iocb        *sio;
> -       struct swap_info_struct *sis;
> -};
> -
> -/*
> - * SWAP_OPS_F_REQUIRE_NOFS:
> - *     When set, all reclaim operations must operated as GFS_NOFS and no=
t
> - *     just GFP_NOIO, as GFP_NOIO allocations could recourse into the
> - *     file system backing this swap file.
> - */
> -#define SWAP_OPS_F_REQUIRE_NOFS                (1U << 0)
> -
> -struct swap_ops {
> -       unsigned int            flags;
> -
> -       bool (*can_merge)(struct folio *folio, struct folio *prev_folio,
> -                       size_t prev_folio_size, int rw);
> -       void (*submit_write)(struct swap_io_ctx *ctx);
> -       void (*submit_read)(struct swap_io_ctx *ctx);
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
> index 9b8ee902f972..efe24bb36ce1 100644
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
> diff --git a/mm/zswap.c b/mm/zswap.c
> index 4e76a4a87cdc..9c4c337790fd 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -20,7 +20,7 @@
>  #include <linux/spinlock.h>
>  #include <linux/types.h>
>  #include <linux/atomic.h>
> -#include <linux/swap.h>
> +#include <linux/swap_ops.h>
>  #include <linux/crypto.h>
>  #include <linux/scatterlist.h>
>  #include <linux/mempolicy.h>
> --
> 2.53.0
>
