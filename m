From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 2/7] sunrpc/cache: fix recent breakage of
 cache_clean_deferred
Date: Wed, 22 Sep 2010 14:27:38 -0400
Message-ID: <20100922182738.GB26903@fieldses.org>
References: <20100922025009.31745.98237.stgit@localhost.localdomain>
 <20100922025506.31745.74964.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: NeilBrown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41193 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752785Ab0IVS3H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Sep 2010 14:29:07 -0400
In-Reply-To: <20100922025506.31745.74964.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 22, 2010 at 12:55:06PM +1000, NeilBrown wrote:
> commit 6610f720e9e8103c22d1f1ccf8fbb695550a571f
> broke cache_clean_deferred as entries are no longer added to the
> pending list for subsequent revisiting.
> 
> So put those requests back on the pending list.

Whoops, clearly correct.  Thanks!

--b.

> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> ---
>  net/sunrpc/cache.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index 62078be..a9e850e 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -678,8 +678,10 @@ void cache_clean_deferred(void *owner)
>  	spin_lock(&cache_defer_lock);
>  
>  	list_for_each_entry_safe(dreq, tmp, &cache_defer_list, recent) {
> -		if (dreq->owner == owner)
> +		if (dreq->owner == owner) {
>  			__unhash_deferred_req(dreq);
> +			list_add(&dreq->recent, &pending);
> +		}
>  	}
>  	spin_unlock(&cache_defer_lock);
>  
> 
> 
