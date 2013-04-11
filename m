Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f180.google.com ([209.85.212.180]:33931 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934043Ab3DKKXy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Apr 2013 06:23:54 -0400
Received: by mail-wi0-f180.google.com with SMTP id c10so375677wiw.13
        for <linux-nfs@vger.kernel.org>; Thu, 11 Apr 2013 03:23:53 -0700 (PDT)
Message-ID: <51668F2A.5060301@tonian.com>
Date: Thu, 11 Apr 2013 13:23:38 +0300
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: fanchaoting <fanchaoting@cn.fujitsu.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] pnfsd-block: cause oops when alloc pnfs_blocklayout_layout_t
 fail
References: <51517A15.3010805@cn.fujitsu.com>
In-Reply-To: <51517A15.3010805@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-03-26 12:36, fanchaoting wrote:
> if using dprintk and alloc pnfs_blocklayout_layout_t fail, it
> maybe cause oops. we should assert the new pnfs_blocklayout_layout_t
> is not null first.
> 
>  Signed-off-by: fanchaoting <fanchaoting@cn.fujitsu.com>
>  Reviewed-by: chendt.fnst <chendt.fnst@cn.fujitsu.com>

Merged into the pnfsd-block branch.

Thanks,

Benny


> ---
>  fs/nfsd/bl_ops.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfsd/bl_ops.c b/fs/nfsd/bl_ops.c
> index fa129e8..a7046c6 100644
> --- a/fs/nfsd/bl_ops.c
> +++ b/fs/nfsd/bl_ops.c
> @@ -1210,14 +1210,14 @@ layout_cache_fill_from_list(bl_layout_rec_t *r, struct list_head *h,
>  			n = bll_alloc(seg->offset,
>  			    MIN(seg->length, BLL_F_END(b) - seg->offset),
>  			    BLOCK_LAYOUT_CACHE, h);
> +			if (!n)
> +				return False;
> +
>  			dprintk("  CACHE hit: Found %Lu(f):%Lu(l): "
>  			    "in %Lu(f):%Lu(l):%Lu(s):%d\n",
>  			    _2SECTS(n->bll_foff), _2SECTS(n->bll_len),
>  			    _2SECTS(b->bll_foff), _2SECTS(b->bll_len),
>  			    _2SECTS(b->bll_soff), b->bll_es);
> -			if (!n)
> -				return False;
> -			
>  			n->bll_soff = b->bll_soff + seg->offset - b->bll_foff;
>  			n->bll_vol_id.sbid = sbid;
>  			n->bll_vol_id.devid = b->bll_vol_id.devid;
> 
