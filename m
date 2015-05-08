Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:34068 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932083AbbEHTM0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 May 2015 15:12:26 -0400
Date: Fri, 8 May 2015 12:12:23 -0700
From: Shaohua Li <shli@kernel.org>
To: NeilBrown <neilb@suse.de>
Cc: linux-raid@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 7/7] md/raid5: fix handling of degraded stripes in
 batches.
Message-ID: <20150508191223.GA116778@kernel.org>
References: <20150508085345.19179.8866.stgit@notabene.brown>
 <20150508085612.19179.92120.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150508085612.19179.92120.stgit@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 08, 2015 at 06:56:12PM +1000, NeilBrown wrote:
> There is no need for special handling of stripe-batches when the array
> is degraded.
> 
> There may be if there is a failure in the batch, but STRIPE_DEGRADED
> does not imply an error.
> 
> So don't set STRIPE_BATCH_ERR in ops_run_io just because the array is
> degraded.
> This actually causes a bug: the STRIPE_DEGRADED flag gets cleared in
> check_break_stripe_batch_list() and so the bitmap bit gets cleared
> when it shouldn't.
> 
> So in check_break_stripe_batch_list(), split the batch up completely -
> again STRIPE_DEGRADED isn't meaningful.
> 
> Also don't set STRIPE_BATCH_ERR when there is a write error to a
> replacement device.  This simply removes the replacement device and
> requires no extra handling.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> ---
>  drivers/md/raid5.c |   17 +++--------------
>  1 file changed, 3 insertions(+), 14 deletions(-)
> 
> diff --git a/drivers/md/raid5.c b/drivers/md/raid5.c
> index 3873eaa6fa2e..1ba97fdc6df1 100644
> --- a/drivers/md/raid5.c
> +++ b/drivers/md/raid5.c
> @@ -1078,9 +1078,6 @@ again:
>  			pr_debug("skip op %ld on disc %d for sector %llu\n",
>  				bi->bi_rw, i, (unsigned long long)sh->sector);
>  			clear_bit(R5_LOCKED, &sh->dev[i].flags);
> -			if (sh->batch_head)
> -				set_bit(STRIPE_BATCH_ERR,
> -					&sh->batch_head->state);
>  			set_bit(STRIPE_HANDLE, &sh->state);
>  		}

Patches look good to me. I had a question here. Is it possible some stripes in
a batch become degraded here but some not? Seems possible, then the batch
should be splitted too.

Thanks,
Shaohua
