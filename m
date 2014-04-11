Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-o-3.desy.de ([131.169.56.156]:60638 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754278AbaDKLMR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Apr 2014 07:12:17 -0400
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 44C7A2800E4
	for <linux-nfs@vger.kernel.org>; Fri, 11 Apr 2014 13:12:14 +0200 (CEST)
Received: from ZITSWEEP1.win.desy.de (zitsweep1.win.desy.de [131.169.97.95])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id 076EF13EE3
	for <linux-nfs@vger.kernel.org>; Fri, 11 Apr 2014 13:12:13 +0200 (MEST)
Date: Fri, 11 Apr 2014 13:12:12 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: open-osd <osd-dev@open-osd.org>, NFS list <linux-nfs@vger.kernel.org>,
        Daniel Gryniewicz <dang@linuxbox.com>,
        Elizabeth Ellenbogen Ziph <elizabeth@linuxbox.com>,
        Santosh Pathak <santoshp@panasas.com>,
        Benny Halevy <bhalevy@primarydata.com>,
        Sachin bhamare <sachin.bhamare@gmail.com>
Message-ID: <148968805.223876.1397214732949.JavaMail.zimbra@desy.de>
In-Reply-To: <53467757.40909@panasas.com>
References: <53467667.3010304@panasas.com> <53467757.40909@panasas.com>
Subject: Re: [PATCH 1/3] ore: (trivial) reformat some code
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



----- Original Message -----
> From: "Boaz Harrosh" <bharrosh@panasas.com>
> To: "open-osd" <osd-dev@open-osd.org>, "NFS list" <linux-nfs@vger.kernel.org>, "Daniel Gryniewicz"
> <dang@linuxbox.com>, "Elizabeth Ellenbogen Ziph" <elizabeth@linuxbox.com>, "Santosh Pathak" <santoshp@panasas.com>
> Cc: "Benny Halevy" <bhalevy@primarydata.com>, "Sachin bhamare" <sachin.bhamare@gmail.com>
> Sent: Thursday, April 10, 2014 12:49:59 PM
> Subject: [PATCH 1/3] ore: (trivial) reformat some code
> 
> 
> rearrange some source lines. Nothing changed.
> 
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> ---
>  fs/exofs/ore.c      | 19 ++++++++-----------
>  fs/exofs/ore_raid.c |  4 +---
>  2 files changed, 9 insertions(+), 14 deletions(-)
> 
> diff --git a/fs/exofs/ore.c b/fs/exofs/ore.c
> index dae8846..98f2137 100644
> --- a/fs/exofs/ore.c
> +++ b/fs/exofs/ore.c
> @@ -675,8 +675,8 @@ static int _prepare_for_striping(struct ore_io_state
> *ios)
>  	si->cur_pg = si->unit_off / PAGE_SIZE;
>  
>  	while (length) {
> -		unsigned comp = dev - first_dev;
> -		struct ore_per_dev_state *per_dev = &ios->per_dev[comp];
> +		struct ore_per_dev_state *per_dev =
> +						&ios->per_dev[dev - first_dev];
>  		unsigned cur_len, page_off = 0;
>  
>  		if (!per_dev->length) {
> @@ -708,11 +708,9 @@ static int _prepare_for_striping(struct ore_io_state
> *ios)
>  		if (unlikely(ret))
>  			goto out;
>  
> -		dev += mirrors_p1;
> -		dev = (dev % devs_in_group) + first_dev;
> -
>  		length -= cur_len;
>  
> +		dev = ((dev + mirrors_p1) % devs_in_group) + first_dev;
>  		si->cur_comp = (si->cur_comp + 1) % group_width;
>  		if (unlikely((dev == si->par_dev) || (!length && ios->sp2d))) {
>  			if (!length && ios->sp2d) {
> @@ -721,11 +719,6 @@ static int _prepare_for_striping(struct ore_io_state
> *ios)
>  				 */
>  				dev = si->par_dev;
>  			}
> -			if (ios->sp2d)
> -				/* In writes cur_len just means if it's the
> -				 * last one. See _ore_add_parity_unit.
> -				 */
> -				cur_len = length;
>  			per_dev = &ios->per_dev[dev - first_dev];
>  			if (!per_dev->length) {
>  				/* Only/always the parity unit of the first
> @@ -736,7 +729,11 @@ static int _prepare_for_striping(struct ore_io_state
> *ios)
>  				per_dev->offset = si->obj_offset - si->unit_off;
>  			}
>  
> -			ret = _ore_add_parity_unit(ios, si, per_dev, cur_len);
> +			/* In writes cur_len just means if it's the
> +			 * last one. See _ore_add_parity_unit.
> +			 */
> +			ret = _ore_add_parity_unit(ios, si, per_dev,
> +						   ios->sp2d : length : cur_len);

Hi Boaz, 

did you meant
 
     ios->sp2d ? length : cur_len);

Tigran.
>  			if (unlikely(ret))
>  					goto out;
>  
> diff --git a/fs/exofs/ore_raid.c b/fs/exofs/ore_raid.c
> index 4e2c032..af417d3 100644
> --- a/fs/exofs/ore_raid.c
> +++ b/fs/exofs/ore_raid.c
> @@ -226,9 +226,7 @@ static void _gen_xor_unit(struct __stripe_pages_2d *sp2d)
>  
>  		init_async_submit(&_1ps->submit,
>  			ASYNC_TX_XOR_ZERO_DST | ASYNC_TX_ACK,
> -			NULL,
> -			NULL, NULL,
> -			(addr_conv_t *)_1ps->scribble);
> +			NULL, NULL, NULL, (addr_conv_t *)_1ps->scribble);
>  
>  		/* TODO: raid6 */
>  		_1ps->tx = async_xor(_1ps->pages[sp2d->data_devs], _1ps->pages,
> --
> 1.9.0
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
