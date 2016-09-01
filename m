Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:5603 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752250AbcIAVPz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Sep 2016 17:15:55 -0400
Subject: Re: [PATCH] sunrpc: queue work on system_power_efficient_wq
To: Chunyan Zhang <zhang.lyra@gmail.com>,
        <trond.myklebust@primarydata.com>, <anna.schumaker@netapp.com>,
        <davem@davemloft.net>
References: <1472715026-11397-1-git-send-email-zhang.lyra@gmail.com>
CC: <linux-nfs@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <ke.wang@spreadtrum.com>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <544e309c-9893-a0ed-ab8a-ccbf5d342dc6@Netapp.com>
Date: Thu, 1 Sep 2016 14:46:35 -0400
MIME-Version: 1.0
In-Reply-To: <1472715026-11397-1-git-send-email-zhang.lyra@gmail.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/01/2016 03:30 AM, Chunyan Zhang wrote:
> From: Ke Wang <ke.wang@spreadtrum.com>
> 
> sunrpc uses workqueue to clean cache regulary. There is no real dependency
> of executing work on the cpu which queueing it.
> 
> On a idle system, especially for a heterogeneous systems like big.LITTLE,
> it is observed that the big idle cpu was woke up many times just to service
> this work, which against the principle of power saving. It would be better
> if we can schedule it on a cpu which the scheduler believes to be the most
> appropriate one.
> 
> After apply this patch, system_wq will be replaced by
> system_power_efficient_wq for sunrpc. This functionality is enabled when
> CONFIG_WQ_POWER_EFFICIENT is selected.

Makes sense to me, but I'm a little surprised that there isn't a "schedule_delayed_power_efficient_work()" function to match how the normal workqueue is used.

Thanks,
Anna

> 
> Signed-off-by: Ke Wang <ke.wang@spreadtrum.com>
> ---
>  net/sunrpc/cache.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index 4d8e11f..8aabe12 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -353,7 +353,7 @@ void sunrpc_init_cache_detail(struct cache_detail *cd)
>  	spin_unlock(&cache_list_lock);
>  
>  	/* start the cleaning process */
> -	schedule_delayed_work(&cache_cleaner, 0);
> +	queue_delayed_work(system_power_efficient_wq, &cache_cleaner, 0);
>  }
>  EXPORT_SYMBOL_GPL(sunrpc_init_cache_detail);
>  
> @@ -476,7 +476,8 @@ static void do_cache_clean(struct work_struct *work)
>  		delay = 0;
>  
>  	if (delay)
> -		schedule_delayed_work(&cache_cleaner, delay);
> +		queue_delayed_work(system_power_efficient_wq,
> +				   &cache_cleaner, delay);
>  }
>  
>  
> 

