Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7608 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753844Ab0LIQ60 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Dec 2010 11:58:26 -0500
Subject: Re: [PATCH 03/11] lockd: Add nlm_alloc_host()
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20101209164838.4513.72502.stgit@matisse.1015granger.net>
References: <20101209163555.4513.94435.stgit@matisse.1015granger.net>
	 <20101209164838.4513.72502.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 09 Dec 2010 11:58:07 -0500
Message-ID: <1291913887.2931.1.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-12-09 at 11:48 -0500, Chuck Lever wrote:
> Refactor nlm_host allocation and initialization to a separate function.
> This will be the common piece of server and client nlm_host lookup
> logic after the nlm_host cache is split.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/lockd/host.c |  106 ++++++++++++++++++++++++++++++++-----------------------
>  1 files changed, 61 insertions(+), 45 deletions(-)
> 
> diff --git a/fs/lockd/host.c b/fs/lockd/host.c
> index 2dbf139..ed1895a 100644
> --- a/fs/lockd/host.c
> +++ b/fs/lockd/host.c
> @@ -100,6 +100,64 @@ static unsigned int nlm_hash_address(const struct sockaddr *sap)
>  }
>  
>  /*
> + * Allocate and initialize an nlm_host.  Common to both client and server.
> + */
> +static struct nlm_host *nlm_alloc_host(struct nlm_lookup_host_info *ni,
> +				       struct nsm_handle *nsm)
> +{
> +	struct nlm_host *host = NULL;
> +	unsigned long now = jiffies;
> +
> +	if (nsm != NULL)
> +		atomic_inc(&nsm->sm_count);
> +	else {
> +		host = NULL;
> +		nsm = nsm_get_handle(ni->sap, ni->salen,
> +					ni->hostname, ni->hostname_len);
> +		if (unlikely(nsm == NULL)) {
> +			dprintk("lockd: %s failed; no nsm handle\n",
> +				__func__);
> +			goto out;
> +		}
> +	}
> +
> +	host = kzalloc(sizeof(*host), GFP_KERNEL);
> +	if (unlikely(host == NULL)) {
> +		dprintk("lockd: %s failed; no memory\n", __func__);
> +		nsm_release(nsm);
> +		goto out;
> +	}
> +
> +	memcpy(nlm_addr(host), ni->sap, ni->salen);
> +	host->h_addrlen    = ni->salen;
> +	rpc_set_port(nlm_addr(host), 0);
> +
> +	host->h_rpcclnt    = NULL;

OK. I'm at a complete loss to explain why you would want to kzalloc()
the storage, and then afterwards explicitly initialise these fields to
zero.

Please choose to do one or the other, but not both...

> +	host->h_name	   = nsm->sm_name;
> +	host->h_version    = ni->version;
> +	host->h_proto      = ni->protocol;
> +	host->h_server     = ni->server;
> +	host->h_noresvport = ni->noresvport;
> +	init_waitqueue_head(&host->h_gracewait);
> +	init_rwsem(&host->h_rwsem);
> +	host->h_state      = 0;
> +	host->h_nsmstate   = 0;
> +	atomic_set(&host->h_count, 1);
> +	mutex_init(&host->h_mutex);
> +	host->h_nextrebind = now + NLM_HOST_REBIND;
> +	host->h_expires    = now + NLM_HOST_EXPIRE;
> +	INIT_LIST_HEAD(&host->h_lockowners);
> +	spin_lock_init(&host->h_lock);
> +	INIT_LIST_HEAD(&host->h_granted);
> +	INIT_LIST_HEAD(&host->h_reclaim);
> +	host->h_nsmhandle  = nsm;
> +	host->h_addrbuf    = nsm->sm_addrbuf;
> +
> +out:
> +	return host;
> +}
> +
> +/*
>   * Common host lookup routine for server & client
>   */
>  static struct nlm_host *nlm_lookup_host(struct nlm_lookup_host_info *ni)
> @@ -150,55 +208,13 @@ static struct nlm_host *nlm_lookup_host(struct nlm_lookup_host_info *ni)
>  		goto out;
>  	}
>  
> -	/*
> -	 * The host wasn't in our hash table.  If we don't
> -	 * have an NSM handle for it yet, create one.
> -	 */
> -	if (nsm)
> -		atomic_inc(&nsm->sm_count);
> -	else {
> -		host = NULL;
> -		nsm = nsm_get_handle(ni->sap, ni->salen,
> -					ni->hostname, ni->hostname_len);
> -		if (!nsm) {
> -			dprintk("lockd: nlm_lookup_host failed; "
> -				"no nsm handle\n");
> -			goto out;
> -		}
> -	}
> -
> -	host = kzalloc(sizeof(*host), GFP_KERNEL);
> -	if (!host) {
> -		nsm_release(nsm);
> -		dprintk("lockd: nlm_lookup_host failed; no memory\n");
> +	host = nlm_alloc_host(ni, nsm);
> +	if (unlikely(host == NULL))
>  		goto out;
> -	}
> -	host->h_name	   = nsm->sm_name;
> -	host->h_addrbuf    = nsm->sm_addrbuf;
> -	memcpy(nlm_addr(host), ni->sap, ni->salen);
> -	host->h_addrlen = ni->salen;
> -	rpc_set_port(nlm_addr(host), 0);
> +
>  	memcpy(nlm_srcaddr(host), ni->src_sap, ni->src_len);
>  	host->h_srcaddrlen = ni->src_len;
> -	host->h_version    = ni->version;
> -	host->h_proto      = ni->protocol;
> -	host->h_rpcclnt    = NULL;
> -	mutex_init(&host->h_mutex);
> -	host->h_nextrebind = jiffies + NLM_HOST_REBIND;
> -	host->h_expires    = jiffies + NLM_HOST_EXPIRE;
> -	atomic_set(&host->h_count, 1);
> -	init_waitqueue_head(&host->h_gracewait);
> -	init_rwsem(&host->h_rwsem);
> -	host->h_state      = 0;			/* pseudo NSM state */
> -	host->h_nsmstate   = 0;			/* real NSM state */
> -	host->h_nsmhandle  = nsm;
> -	host->h_server	   = ni->server;
> -	host->h_noresvport = ni->noresvport;
>  	hlist_add_head(&host->h_hash, chain);
> -	INIT_LIST_HEAD(&host->h_lockowners);
> -	spin_lock_init(&host->h_lock);
> -	INIT_LIST_HEAD(&host->h_granted);
> -	INIT_LIST_HEAD(&host->h_reclaim);
>  
>  	nrhosts++;
>  
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

