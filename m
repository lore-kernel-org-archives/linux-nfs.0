From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 08/14] SQUASHME: Removal of ugly #ifdefs
Date: Sun, 14 Jun 2009 10:30:19 -0400
Message-ID: <4A35097B.70605@panasas.com>
References: <> <1244786060-2200-1-git-send-email-Ricardo.Labiaga@netapp.com> <1244786060-2200-2-git-send-email-Ricardo.Labiaga@netapp.com> <1244786060-2200-3-git-send-email-Ricardo.Labiaga@netapp.com> <1244786060-2200-4-git-send-email-Ricardo.Labiaga@netapp.com> <1244786060-2200-5-git-send-email-Ricardo.Labiaga@netapp.com> <1244786060-2200-6-git-send-email-Ricardo.Labiaga@netapp.com> <1244786060-2200-7-git-send-email-Ricardo.Labiaga@netapp.com> <1244786060-2200-8-git-send-email-Ricardo.Labiaga@netapp.com> <1244786060-2200-9-git-send-email-Ricardo.Labiaga@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: trond.myklebust@netapp.com, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org
To: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:8560
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755051AbZFNOaW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 14 Jun 2009 10:30:22 -0400
In-Reply-To: <1244786060-2200-9-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun. 12, 2009, 1:54 -0400, Ricardo Labiaga <Ricardo.Labiaga@netapp.com> wrote:
> [squash with: nfs41: Implement NFSv4.1 callback service process]
> 
> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> ---
>  fs/nfs/callback.c |   50 +++++++++++++++++++++++++++++++++++---------------
>  1 files changed, 35 insertions(+), 15 deletions(-)
> 
> diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
> index 4395c96..116424e 100644
> --- a/fs/nfs/callback.c
> +++ b/fs/nfs/callback.c
> @@ -209,6 +209,39 @@ out:
>  	dprintk("--> %s return %p\n", __func__, rqstp);
>  	return rqstp;
>  }
> +
> +static inline void nfs_callback_svc_setup(u32 minorversion,
> +		struct svc_serv *serv, struct rpc_xprt *xprt,
> +		struct svc_rqst **rqstpp, int (**callback_svc)(void *vrqstp))
> +{
> +	if (minorversion) {
> +		*rqstpp = nfs41_callback_up(serv, xprt);
> +		*callback_svc = nfs41_callback_svc;
> +	} else {
> +		*rqstpp = nfs4_callback_up(serv);
> +		*callback_svc = nfs4_callback_svc;
> +	}
> +}
> +
> +static inline void nfs_callback_bc_serv(u32 minorversion, struct rpc_xprt *xprt,
> +		struct nfs_callback_data *cb_info)
> +{
> +	if (minorversion)
> +		xprt->bc_serv = cb_info->serv;
> +}
> +#else
> +static inline void nfs_callback_svc_setup(u32 minorversion,
> +		struct svc_serv *serv, struct rpc_xprt *xprt,
> +		struct svc_rqst **rqstpp, int (**callback_svc)(void *vrqstp))
> +{
> +	*rqstpp = nfs4_callback_up(serv);
> +	*callback_svc = nfs4_callback_svc;
> +}
> +
> +static inline void nfs_callback_bc_serv(u32 minorversion, struct rpc_xprt *xprt,
> +		struct nfs_callback_data *cb_info)
> +{
> +}
>  #endif /* CONFIG_NFS_V4_1 */

Although this removes the ungly #ifdefs from inside nfs_callback_up
it just introduces them elsewhere and what's worse, it adds code
duplication which is even more unreadable and harder to maintain.

How about something along these line?

static inline void nfs_callback_svc_setup(u32 minorversion,
		struct svc_serv *serv, struct rpc_xprt *xprt,
		struct svc_rqst **rqstpp, int (**callback_svc)(void *vrqstp))
{
#ifdef CONFIG_NFS_V4_1
	if (minorversion) {
		*rqstpp = nfs41_callback_up(serv, xprt);
		*callback_svc = nfs41_callback_svc;
		return;
	}
#endif /* CONFIG_NFS_V4_1 */
	*rqstpp = nfs4_callback_up(serv);
	*callback_svc = nfs4_callback_svc;
}

static inline void nfs_callback_bc_serv(u32 minorversion, struct rpc_xprt *xprt,
		struct nfs_callback_data *cb_info)
{
#ifdef CONFIG_NFS_V4_1
	if (minorversion)
		xprt->bc_serv = cb_info->serv;
#endif /* CONFIG_NFS_V4_1 */
}

Benny

>  
>  /*
> @@ -225,10 +258,7 @@ int nfs_callback_up(u32 minorversion, struct rpc_xprt *xprt)
>  
>  	mutex_lock(&nfs_callback_mutex);
>  	if (cb_info->users++ || cb_info->task != NULL) {
> -#if defined(CONFIG_NFS_V4_1)
> -		if (minorversion)
> -			xprt->bc_serv = cb_info->serv;
> -#endif /* CONFIG_NFS_V4_1 */
> +		nfs_callback_bc_serv(minorversion, xprt, cb_info);
>  		goto out;
>  	}
>  	serv = svc_create(&nfs4_callback_program, NFS4_CALLBACK_BUFSIZE, NULL);
> @@ -239,17 +269,7 @@ int nfs_callback_up(u32 minorversion, struct rpc_xprt *xprt)
>  
>  	/* FIXME: either 4.0 or 4.1 callback service can be up at a time
>  	 * need to monitor and control them both */
> -	if (!minorversion) {
> -		rqstp = nfs4_callback_up(serv);
> -		callback_svc = nfs4_callback_svc;
> -	} else {
> -#if defined(CONFIG_NFS_V4_1)
> -		rqstp = nfs41_callback_up(serv, xprt);
> -		callback_svc = nfs41_callback_svc;
> -#else  /* CONFIG_NFS_V4_1 */
> -		BUG();
> -#endif /* CONFIG_NFS_V4_1 */
> -	}
> +	nfs_callback_svc_setup(minorversion, serv, xprt, &rqstp, &callback_svc);
>  
>  	if (IS_ERR(rqstp)) {
>  		ret = PTR_ERR(rqstp);

