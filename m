Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33790 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752189AbcLLV6G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 12 Dec 2016 16:58:06 -0500
Date: Mon, 12 Dec 2016 16:58:04 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: andros@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH Version 2] SVCAUTH update the rsc cache on
 RPC_GSS_PROC_DESTROY
Message-ID: <20161212215804.GB6002@fieldses.org>
References: <1481562529-4488-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1481562529-4488-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 12, 2016 at 12:08:49PM -0500, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> The current code sets the expiry_time on the local copy of the rsc
> cache entry - but not on the actual cache entry.

I'm not following.  It looks to me like "rsci" in the below was returned
from gss_svc_searchbyctx(), which was returned in turn from
sunrpc_cache_lookup(), which is returning an item from the rsc cache--I
don't see any copying.

> Note that currently, the rsc cache entries are not cleaned up even
> when nfsd is stopped.

So, that sounds like a bug, but I don't understand this explanation yet.

> Update the cache with the new expiry_time of now so that cache_clean will
> clean up (free) the context to be destroyed.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  net/sunrpc/auth_gss/svcauth_gss.c | 32 ++++++++++++++++++++++++++++++--
>  1 file changed, 30 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
> index 45662d7..6033389 100644
> --- a/net/sunrpc/auth_gss/svcauth_gss.c
> +++ b/net/sunrpc/auth_gss/svcauth_gss.c
> @@ -1393,6 +1393,26 @@ static void destroy_use_gss_proxy_proc_entry(struct net *net) {}
>  
>  #endif /* CONFIG_PROC_FS */
>  
> +static int rsc_destroy(struct sunrpc_net *sn, struct rsc *rscp)
> +{
> +	struct rsc new;
> +	int ret = -ENOMEM;
> +
> +	memset(&new, 0, sizeof(struct rsc));
> +	if (dup_netobj(&new.handle, &rscp->handle))
> +		goto out;
> +	new.h.expiry_time = get_seconds();
> +	set_bit(CACHE_NEGATIVE, &new.h.flags);
> +
> +	rscp = rsc_update(sn->rsc_cache, &new, rscp);
> +	if (!rscp)
> +		goto out;
> +	ret = 0;
> +out:
> +	rsc_free(&new);
> +	return ret;
> +}
> +
>  /*
>   * Accept an rpcsec packet.
>   * If context establishment, punt to user space
> @@ -1489,10 +1509,18 @@ static void destroy_use_gss_proxy_proc_entry(struct net *net) {}
>  	case RPC_GSS_PROC_DESTROY:
>  		if (gss_write_verf(rqstp, rsci->mechctx, gc->gc_seq))
>  			goto auth_err;
> -		rsci->h.expiry_time = get_seconds();
> -		set_bit(CACHE_NEGATIVE, &rsci->h.flags);
> +		if (rsc_destroy(sn, rsci))
> +			goto drop;
> +		/**
> +		 * Balance the cache_put at the end of svcauth_gss_accept.This
> +		 * will leave the refcount = 1 so that the cache_clean cache_put
> +		 * will call rsc_put.
> +		 */

I'm confused by that comment.  If it's right, then it means the refcount
is currently zero, in which case the following line is unsafe.

--b.

> +		cache_get(&rsci->h);
> +
>  		if (resv->iov_len + 4 > PAGE_SIZE)
>  			goto drop;
> +
>  		svc_putnl(resv, RPC_SUCCESS);
>  		goto complete;
>  	case RPC_GSS_PROC_DATA:
> -- 
> 1.8.3.1
