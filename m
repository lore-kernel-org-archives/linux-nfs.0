Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:23111 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751102Ab0HTFkU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Aug 2010 01:40:20 -0400
Date: Fri, 20 Aug 2010 13:40:16 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] VM: kswapd should not do blocking memory allocations
Message-ID: <20100820054016.GA11847@localhost>
References: <1282158241.8540.85.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1282158241.8540.85.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Aug 18, 2010 at 03:04:01PM -0400, Trond Myklebust wrote:
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> Allowing kswapd to do GFP_KERNEL memory allocations (or any blocking memory
> allocations) is wrong and can cause deadlocks in try_to_release_page(), as
> the filesystem believes it is safe to allocate new memory and block,
> whereas kswapd is there specifically to clear a low-memory situation...
> 
> Set the gfp_mask to GFP_IOFS instead.

It would be more descriptive to say "remove the __GFP_WAIT bit".

The change looks reasonable _in itself_, since we always prefer to
avoid unnecessary waits for kswapd. So

Acked-by: Wu Fengguang <fengguang.wu@intel.com>

> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> 
>  mm/vmscan.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index ec5ddcc..716dd16 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2095,7 +2095,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order)
>  	unsigned long total_scanned;
>  	struct reclaim_state *reclaim_state = current->reclaim_state;
>  	struct scan_control sc = {
> -		.gfp_mask = GFP_KERNEL,
> +		.gfp_mask = GFP_IOFS,
>  		.may_unmap = 1,
>  		.may_swap = 1,
>  		/*
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
