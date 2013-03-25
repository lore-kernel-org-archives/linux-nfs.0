Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f44.google.com ([74.125.82.44]:47544 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755920Ab3CYJkS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Mar 2013 05:40:18 -0400
Received: by mail-wg0-f44.google.com with SMTP id dr12so2111979wgb.35
        for <linux-nfs@vger.kernel.org>; Mon, 25 Mar 2013 02:40:17 -0700 (PDT)
Message-ID: <51501B7F.6040506@tonian.com>
Date: Mon, 25 Mar 2013 11:40:15 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: fanchaoting <fanchaoting@cn.fujitsu.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH]spnfs-block: reserve space error in bl_encode_stripe
References: <513DC5BE.9000103@cn.fujitsu.com>
In-Reply-To: <513DC5BE.9000103@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-03-11 13:53, fanchaoting wrote:
>  when useing spnfs-block, reserve space error in bl_encode_stripe.
> 
>  Signed-off-by: fanchaoting<fanchaoting@cn.fujitsu.com>

Good catch!
This patch did not apply cleanly on my latest pnfsd-block branch.
Please rebase onto the newest branch and send an up-to-date patch next time.

Merged into git://linux-nfs.org/~bhalevy/linux-pnfs.git pnfsd-block

Thanks,

Benny

> ---
>  fs/exportfs/nfs4blocklayoutxdr.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/exportfs/nfs4blocklayoutxdr.c b/fs/exportfs/nfs4blocklayoutxdr.c
> index 439e647..c942d34 100644
> --- a/fs/exportfs/nfs4blocklayoutxdr.c
> +++ b/fs/exportfs/nfs4blocklayoutxdr.c
> @@ -53,7 +53,7 @@ static int
>  bl_encode_stripe(struct exp_xdr_stream *xdr, pnfs_blocklayout_devinfo_t *bld)
>  {
>         int i;
> -       __be32 *p = exp_xdr_reserve_space(xdr,
> +       __be32 *p = exp_xdr_reserve_qwords(xdr,
>                                           2 + 1 + bld->u.stripe.bld_stripes);
> 
>         p = exp_xdr_encode_u64(p, bld->u.stripe.bld_chunk_size);
> --
> 1.7.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
