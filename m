Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:47811 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750886Ab1ADRzO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jan 2011 12:55:14 -0500
Date: Tue, 4 Jan 2011 12:55:03 -0500
To: andros@netapp.com
Cc: trond.myklebust@netapp.com, bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH_V6 04/11] NFS use svc_create_xprt for NFSv4.1 callback
 service
Message-ID: <20110104175503.GE30317@fieldses.org>
References: <1294161028-4499-1-git-send-email-andros@netapp.com>
 <1294161028-4499-2-git-send-email-andros@netapp.com>
 <1294161028-4499-3-git-send-email-andros@netapp.com>
 <1294161028-4499-4-git-send-email-andros@netapp.com>
 <1294161028-4499-5-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1294161028-4499-5-git-send-email-andros@netapp.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Jan 04, 2011 at 12:10:21PM -0500, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> The new back channel transport means we call the normal creation routine as
> well as svc_xprt_put.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/callback.c |   31 +++++++++++++++++++++----------
>  1 files changed, 21 insertions(+), 10 deletions(-)
> 
> diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
> index 93a8b3b..343d543 100644
> --- a/fs/nfs/callback.c
> +++ b/fs/nfs/callback.c
> @@ -177,30 +177,41 @@ nfs41_callback_svc(void *vrqstp)
>  struct svc_rqst *
>  nfs41_callback_up(struct svc_serv *serv, struct rpc_xprt *xprt)
>  {
> -	struct svc_xprt *bc_xprt;
> -	struct svc_rqst *rqstp = ERR_PTR(-ENOMEM);
> +	struct svc_rqst *rqstp;
> +	int ret;
>  
> -	dprintk("--> %s\n", __func__);
> -	/* Create a svc_sock for the service */
> -	bc_xprt = svc_sock_create(serv, xprt->prot);
> -	if (!bc_xprt)
> +	/* register the back channel transport class */
> +	svc_init_bc_xprt_sock();

We really only need to register the transport class once, not each time
we set up a new backchannel.

(OK, it's harmless to register it multiple times--the registration
detects that case and does nothing--but still I'd prefer to register
just once if possible.)

Also: I think you're forgetting to unregister the transport class?

I think the correct place to put the registration and unregistration may
be init_nfs_fs() and exit_nfs_fs().

(And define it as a no-op function depending on config options to avoid
ifdef's in init_nfs_fs/exit_nfs_fs, in the usual way.)

--b.

> +
> +	/*
> +	 * Create an svc_sock for the back channel service that shares the
> +	 * fore channel connection.
> +	 * Returns the input port (0) and sets the svc_serv bc_xprt on success
> +	 */
> +	ret = svc_create_xprt(serv, "tcp-bc", &init_net, PF_INET, 0,
> +			      SVC_SOCK_ANONYMOUS);
> +	if (ret < 0) {
> +		rqstp = ERR_PTR(ret);
>  		goto out;
> +	}
>  
>  	/*
>  	 * Save the svc_serv in the transport so that it can
>  	 * be referenced when the session backchannel is initialized
>  	 */
> -	serv->bc_xprt = bc_xprt;
>  	xprt->bc_serv = serv;
>  
>  	INIT_LIST_HEAD(&serv->sv_cb_list);
>  	spin_lock_init(&serv->sv_cb_lock);
>  	init_waitqueue_head(&serv->sv_cb_waitq);
>  	rqstp = svc_prepare_thread(serv, &serv->sv_pools[0]);
> -	if (IS_ERR(rqstp))
> -		svc_sock_destroy(bc_xprt);
> +	if (IS_ERR(rqstp)) {
> +		svc_xprt_put(serv->bc_xprt);
> +		serv->bc_xprt = NULL;
> +	}
>  out:
> -	dprintk("--> %s return %p\n", __func__, rqstp);
> +	dprintk("--> %s return %ld\n", __func__,
> +		IS_ERR(rqstp) ? PTR_ERR(rqstp) : 0);
>  	return rqstp;
>  }
>  
> -- 
> 1.6.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
