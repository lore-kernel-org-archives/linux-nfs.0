Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:44066 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751521Ab1HKPR0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Aug 2011 11:17:26 -0400
In-Reply-To: <201108101803.p7AI36eV008484@farm-0023.internal.tilera.com>
References: <201108101803.p7AI36eV008484@farm-0023.internal.tilera.com>
From: Peng Tao <bergwolf@gmail.com>
Date: Thu, 11 Aug 2011 23:17:06 +0800
Message-ID: <CA+a=Yy4PorPNqiBqakmHL2s5rWNR7nKN3mf5BbV++eXsBbL9Ow@mail.gmail.com>
Subject: Re: [PATCH] nfs: fix a couple of minor portability issues
To: Chris Metcalf <cmetcalf@tilera.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Aug 11, 2011 at 1:56 AM, Chris Metcalf <cmetcalf@tilera.com> wrote:
> Building on tilepro revealed two minor portability issues: the
> blocklayout.c file used prefetchw() without #include <linux/prefetch.h>,
> and the nfs4filelayout.c file used do_div() on an s64 not a u64.
> This change fixes those two issues so the NFS code builds on tilepro.
>
> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
> ---
>  fs/nfs/blocklayout/blocklayout.c |    1 +
>  fs/nfs/nfs4filelayout.c          |    6 +++---
>  2 files changed, 4 insertions(+), 3 deletions(-)
>
> diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
> index e56564d..9561c8f 100644
> --- a/fs/nfs/blocklayout/blocklayout.c
> +++ b/fs/nfs/blocklayout/blocklayout.c
> @@ -36,6 +36,7 @@
>  #include <linux/namei.h>
>  #include <linux/bio.h>         /* struct bio */
>  #include <linux/buffer_head.h> /* various write calls */
> +#include <linux/prefetch.h>
This is already fixed in Trond's nfs-for-next branch by commit 88c9e4219.

>
>  #include "blocklayout.h"
>
> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> index e8915d4..6976a72 100644
> --- a/fs/nfs/nfs4filelayout.c
> +++ b/fs/nfs/nfs4filelayout.c
> @@ -48,13 +48,13 @@ filelayout_get_dense_offset(struct nfs4_filelayout_segment *flseg,
>                            loff_t offset)
>  {
>        u32 stripe_width = flseg->stripe_unit * flseg->dsaddr->stripe_count;
> -       u64 tmp;
> +       u64 tmp, uoff;
>
>        offset -= flseg->pattern_offset;
> -       tmp = offset;
> +       tmp = uoff = offset;
>        do_div(tmp, stripe_width);
>
> -       return tmp * flseg->stripe_unit + do_div(offset, flseg->stripe_unit);
> +       return tmp * flseg->stripe_unit + do_div(uoff, flseg->stripe_unit);
>  }
>
>  /* This function is used by the layout driver to calculate the
> --
> 1.6.5.2
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>



-- 
Thanks,
-Bergwolf
