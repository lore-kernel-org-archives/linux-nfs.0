Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38578 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755874Ab1J1OWf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Oct 2011 10:22:35 -0400
Date: Fri, 28 Oct 2011 10:22:32 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org, xemul@parallels.com,
        neilb@suse.de, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        davem@davemloft.net, devel@openvz.org
Subject: Re: [PATCH v7 4/7] SUNRPC: setup rpcbind clients if service
 requires it
Message-ID: <20111028142232.GC5193@fieldses.org>
References: <20111028104530.24628.23631.stgit@localhost6.localdomain6>
 <20111028105307.24628.89889.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111028105307.24628.89889.stgit@localhost6.localdomain6>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 28, 2011 at 02:53:18PM +0300, Stanislav Kinsbursky wrote:
> New function ("svc_uses_rpcbind") will be used to detect, that new service will
> send portmapper register calls. For such services we will create rpcbind
> clients and remove all stale portmap registrations.
> Also, svc_rpcb_cleanup() will be set as sv_shutdown callback for such services
> in case of this field wasn't initialized earlier. This will allow to destroy
> rpcbind clients when no other users of them left.
> 
> Note: Currently, any creating service will be detected as portmap user.
> Probably, this is wrong. But now it depends on program versions "vs_hidden"
> flag.
> 
> Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

Acked-by: J. Bruce Fields <bfields@redhat.com>

> 
> ---
>  net/sunrpc/svc.c |   20 ++++++++++++++------
>  1 files changed, 14 insertions(+), 6 deletions(-)
> 
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index d2d61bf..87a67b2 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -436,10 +436,8 @@ __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
>  	serv->sv_pools =
>  		kcalloc(serv->sv_nrpools, sizeof(struct svc_pool),
>  			GFP_KERNEL);
> -	if (!serv->sv_pools) {
> -		kfree(serv);
> -		return NULL;
> -	}
> +	if (!serv->sv_pools)
> +		goto err_serv;
>  
>  	for (i = 0; i < serv->sv_nrpools; i++) {
>  		struct svc_pool *pool = &serv->sv_pools[i];
> @@ -454,10 +452,20 @@ __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
>  		spin_lock_init(&pool->sp_lock);
>  	}
>  
> -	/* Remove any stale portmap registrations */
> -	svc_unregister(serv);
> +	if (svc_uses_rpcbind(serv)) {
> +	       	if (svc_rpcb_setup(serv) < 0)
> +			goto err_rpcb;
> +		if (!serv->sv_shutdown)
> +			serv->sv_shutdown = svc_rpcb_cleanup;
> +	}
>  
>  	return serv;
> +
> +err_rpcb:
> +	kfree(serv->sv_pools);
> +err_serv:
> +	kfree(serv);
> +	return NULL;
>  }
>  
>  struct svc_serv *
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
