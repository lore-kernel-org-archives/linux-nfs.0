Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:41055 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755475Ab1EZT6W (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 May 2011 15:58:22 -0400
Message-ID: <4DDEB0DF.70409@panasas.com>
Date: Thu, 26 May 2011 22:58:23 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: Subject: [PATCH] SQUASHME: Move a check from nfs_pageio_do_add_request
 to nfs_generic_pg_test
References: <4DDD7392.6040505@panasas.com> <1306359021-17987-1-git-send-email-bhalevy@panasas.com> <4DDEA75E.2090709@panasas.com>
In-Reply-To: <4DDEA75E.2090709@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/26/2011 10:17 PM, Boaz Harrosh wrote:
> 
> desc->pg_bsize is negotiated with the MDS. But if we are doing
> pnfs-IO it is not relevant.
> 
> While at it cleanup nfs_pageio_do_add_request() in light of the
> less things it needs to do.
> 
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> ---
>  fs/nfs/pagelist.c |   28 ++++++++++++++--------------
>  1 files changed, 14 insertions(+), 14 deletions(-)
> 
> diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
> index c795660..130b683 100644
> --- a/fs/nfs/pagelist.c
> +++ b/fs/nfs/pagelist.c
> @@ -206,6 +206,16 @@ nfs_wait_on_request(struct nfs_page *req)
>  
>  static bool nfs_generic_pg_test(struct nfs_pageio_descriptor *desc, struct nfs_page *prev, struct nfs_page *req)
>  {
> +	/*
> +	* FIXME: ideally we should be able to coalesce all requests
> +	* that are not block boundary aligned, but currently this
> +	* is problematic for the case of bsize < PAGE_CACHE_SIZE,
> +	* since nfs_flush_multi and nfs_pagein_multi assume you
> +	* can have only one struct nfs_page.
> +	*/
> +	if (desc->pg_bsize < PAGE_SIZE)
> +		return 0;
> +
>  	return desc->pg_count + req->wb_bytes <= desc->pg_bsize;
>  }
>  
> @@ -278,29 +288,19 @@ static bool nfs_can_coalesce_requests(struct nfs_page *prev,
>  static int nfs_pageio_do_add_request(struct nfs_pageio_descriptor *desc,
>  				     struct nfs_page *req)
>  {
> -	size_t newlen = req->wb_bytes;
> -
>  	if (desc->pg_count != 0) {
>  		struct nfs_page *prev;
>  
> -		/*
> -		 * FIXME: ideally we should be able to coalesce all requests
> -		 * that are not block boundary aligned, but currently this
> -		 * is problematic for the case of bsize < PAGE_CACHE_SIZE,
> -		 * since nfs_flush_multi and nfs_pagein_multi assume you
> -		 * can have only one struct nfs_page.
> -		 */
> -		if (desc->pg_bsize < PAGE_SIZE)
> -			return 0;
> -		newlen += desc->pg_count;
> +		desc->pg_count += req->wb_bytes;

- 		desc->pg_count += req->wb_bytes;

>  		prev = nfs_list_entry(desc->pg_list.prev);
>  		if (!nfs_can_coalesce_requests(prev, req, desc))
>  			return 0;

+ 		desc->pg_count += req->wb_bytes;

> -	} else
> +	} else {
>  		desc->pg_base = req->wb_pgbase;
> +		desc->pg_count = req->wb_bytes;
> +	}
>  	nfs_list_remove_request(req);
>  	nfs_list_add_request(req, &desc->pg_list);
> -	desc->pg_count = newlen;
>  	return 1;
>  }
>  

Benny please move the addition to after the  nfs_can_coalesce_requests() call

Thanks
Boaz
