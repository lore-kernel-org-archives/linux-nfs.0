Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([209.166.131.148]:59175 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754382AbaDWMUZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Apr 2014 08:20:25 -0400
Message-ID: <5357AFFF.8030902@panasas.com>
Date: Wed, 23 Apr 2014 15:20:15 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Weston Andros Adamson <dros@primarydata.com>,
        <trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 11/17] nfs: chain calls to pg_test
References: <1398202165-78897-1-git-send-email-dros@primarydata.com> <1398202165-78897-12-git-send-email-dros@primarydata.com>
In-Reply-To: <1398202165-78897-12-git-send-email-dros@primarydata.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/23/2014 12:29 AM, Weston Andros Adamson wrote:
> Now that pg_test can change the size of the request (by returning a non-zero
> size smaller than the request), pg_test functions that call other
> pg_test functions must return the minimum of the result - or 0 if any fail.
> 
> Also clean up the logic of some pg_test functions so that all checks are
> for contitions where coalescing is not possible.
> 
> Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
> ---
>  fs/nfs/nfs4filelayout.c      | 27 ++++++++++++++-------------
>  fs/nfs/objlayout/objio_osd.c | 12 ++++++++----
>  fs/nfs/pnfs.c                | 15 ++++++++++-----
>  3 files changed, 32 insertions(+), 22 deletions(-)
> 
> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> index 3b32c95..cfd76bd 100644
> --- a/fs/nfs/nfs4filelayout.c
> +++ b/fs/nfs/nfs4filelayout.c
> @@ -930,26 +930,27 @@ static size_t
>  filelayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
>  		   struct nfs_page *req)
>  {
> +	unsigned int size;
>  	u64 p_stripe, r_stripe;
>  	u32 stripe_unit;
>  
> -	if (!pnfs_generic_pg_test(pgio, prev, req) ||
> -	    !nfs_generic_pg_test(pgio, prev, req))
> +	/* calls nfs_generic_pg_test */
> +	size = pnfs_generic_pg_test(pgio, prev, req);
> +	if (!size)
>  		return 0;
>  
> -	if (!prev)
> -		return req->wb_bytes;
> +	if (prev) {
> +		p_stripe = (u64)req_offset(prev);
> +		r_stripe = (u64)req_offset(req);
> +		stripe_unit = FILELAYOUT_LSEG(pgio->pg_lseg)->stripe_unit;
>  
> -	p_stripe = (u64)req_offset(prev);
> -	r_stripe = (u64)req_offset(req);
> -	stripe_unit = FILELAYOUT_LSEG(pgio->pg_lseg)->stripe_unit;
> +		do_div(p_stripe, stripe_unit);
> +		do_div(r_stripe, stripe_unit);
>  
> -	do_div(p_stripe, stripe_unit);
> -	do_div(r_stripe, stripe_unit);
> -
> -	if (p_stripe == r_stripe)
> -		return req->wb_bytes;
> -	return 0;
> +		if (p_stripe != r_stripe)
> +			return 0;
> +	}
> +	return min(size, req->wb_bytes);
>  }
>  
>  static void
> diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
> index c20352a..31de29e 100644
> --- a/fs/nfs/objlayout/objio_osd.c
> +++ b/fs/nfs/objlayout/objio_osd.c
> @@ -571,13 +571,17 @@ int objio_write_pagelist(struct nfs_write_data *wdata, int how)
>  static size_t objio_pg_test(struct nfs_pageio_descriptor *pgio,
>  			  struct nfs_page *prev, struct nfs_page *req)
>  {
> -	if (!pnfs_generic_pg_test(pgio, prev, req))
> +	unsigned int size;
> +
> +	size = pnfs_generic_pg_test(pgio, prev, req);
> +
> +	if (!size)
>  		return 0;
>  
> -	if (pgio->pg_count + req->wb_bytes <=
> +	if (pgio->pg_count + req->wb_bytes >
>  	    (unsigned long)pgio->pg_layout_private)
> -		return req->wb_bytes;
> -	return 0;
> +		return 0;

objio_osd can enjoy the new facility by returning the
remainder here:

	max_io = (unsigned long)pgio->pg_layout_private);

	wb_bytes = min(size, req->wb_bytes);

	if (pgio->pg_count + req->wb_bytes > max_io)
		wb_bytes = max_io - pgio->pg_count;

	return wb_bytes;

Which reminds me that this code sucks and I need to fix it. I will do
so after you send your changes.

[I promise to test these guys soon. Can you please put them on a public tree?]

Thanks
Boaz

> +	return min(size, req->wb_bytes);
>  }
>  
>  static void objio_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 6201bf6..7c89385 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -1469,8 +1469,12 @@ size_t
>  pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
>  		     struct nfs_page *req)
>  {
> -	if (pgio->pg_lseg == NULL)
> -		return nfs_generic_pg_test(pgio, prev, req);
> +	unsigned int size;
> +
> +	size = nfs_generic_pg_test(pgio, prev, req);
> +
> +	if (!size)
> +		return 0;
>  
>  	/*
>  	 * Test if a nfs_page is fully contained in the pnfs_layout_range.
> @@ -1486,10 +1490,11 @@ pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
>  	 * first byte that lies outside the pnfs_layout_range. FIXME?
>  	 *
>  	 */
> -	if (req_offset(req) < end_offset(pgio->pg_lseg->pls_range.offset,
> +	if (req_offset(req) >= end_offset(pgio->pg_lseg->pls_range.offset,
>  					 pgio->pg_lseg->pls_range.length))
> -		return req->wb_bytes;
> -	return 0;
> +		return 0;
> +
> +	return min(size, req->wb_bytes);
>  }
>  EXPORT_SYMBOL_GPL(pnfs_generic_pg_test);
>  
> 

