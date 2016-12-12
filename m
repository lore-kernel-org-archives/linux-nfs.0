Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35220 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752088AbcLLVEi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Dec 2016 16:04:38 -0500
Received: by mail-io0-f195.google.com with SMTP id f73so24226526ioe.2
        for <linux-nfs@vger.kernel.org>; Mon, 12 Dec 2016 13:04:38 -0800 (PST)
Subject: Re: [PATCH Version 2] SVCAUTH update the rsc cache on
 RPC_GSS_PROC_DESTROY
To: andros@netapp.com, bfields@fieldses.org
References: <1481562529-4488-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org
From: Anna Schumaker <schumaker.anna@gmail.com>
Message-ID: <f3136408-1f0f-11b2-7040-97aa81e000ae@gmail.com>
Date: Mon, 12 Dec 2016 16:04:36 -0500
MIME-Version: 1.0
In-Reply-To: <1481562529-4488-1-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Andy,

On 12/12/2016 12:08 PM, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> The current code sets the expiry_time on the local copy of the rsc
> cache entry - but not on the actual cache entry.
> Note that currently, the rsc cache entries are not cleaned up even
> when nfsd is stopped.
> 
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

Can you avoid the memset by initializing new to 0 directly?
	struct rsc new = {0};

> +	int ret = -ENOMEM;
> +
> +	memset(&new, 0, sizeof(struct rsc));
> +	if (dup_netobj(&new.handle, &rscp->handle))
> +		goto out;
> +	new.h.expiry_time = get_seconds();
> +	set_bit(CACHE_NEGATIVE, &new.h.flags);

Alternatively, would it make sense to initialize new with these values directly, rather than setting them afterwards?

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

If you're just checking success / failure here, would it make sense to have rsc_destroy() return a boolean value rather than an error code?  Do you expect it could be used anywhere that the error code would make a difference?

Thanks,
Anna

> +			goto drop;
> +		/**
> +		 * Balance the cache_put at the end of svcauth_gss_accept.This
> +		 * will leave the refcount = 1 so that the cache_clean cache_put
> +		 * will call rsc_put.
> +		 */
> +		cache_get(&rsci->h);
> +
>  		if (resv->iov_len + 4 > PAGE_SIZE)
>  			goto drop;
> +
>  		svc_putnl(resv, RPC_SUCCESS);
>  		goto complete;
>  	case RPC_GSS_PROC_DATA:
> 
