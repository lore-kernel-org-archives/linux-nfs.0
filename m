Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39504 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752222Ab1J0V1g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Oct 2011 17:27:36 -0400
Date: Thu, 27 Oct 2011 17:27:32 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org, xemul@parallels.com,
        neilb@suse.de, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        davem@davemloft.net, devel@openvz.org
Subject: Re: [PATCH v6 4/8] SUNRPC: setup rpcbind clients if service
 requires it
Message-ID: <20111027212732.GC31669@fieldses.org>
References: <20111025100826.12689.46944.stgit@localhost6.localdomain6>
 <20111025101705.12689.68022.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111025101705.12689.68022.stgit@localhost6.localdomain6>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 25, 2011 at 02:17:08PM +0300, Stanislav Kinsbursky wrote:
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
> 
> ---
>  net/sunrpc/svc.c |   11 +++++++++--
>  1 files changed, 9 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index d2d61bf..918edc3 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -454,8 +454,15 @@ __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
>  		spin_lock_init(&pool->sp_lock);
>  	}
>  
> -	/* Remove any stale portmap registrations */
> -	svc_unregister(serv);
> +	if (svc_uses_rpcbind(serv)) {
> +	       	if (svc_rpcb_setup(serv) < 0) {
> +			kfree(serv->sv_pools);
> +			kfree(serv);
> +			return NULL;

Nit: could we convert this (and the previous failure to allocate
sv_pools) to the usual pattern of collecting the cleanup at the end and
jumping to it with a goto?

Looks fine otherwise.

--b.

> +		}
> +		if (!serv->sv_shutdown)
> +			serv->sv_shutdown = svc_rpcb_cleanup;
> +	}
>  
>  	return serv;
>  }
> 
