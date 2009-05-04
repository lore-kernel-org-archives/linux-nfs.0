From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 1/2] NFS: Return error code from nfs_callback_up() to
 user space
Date: Mon, 04 May 2009 13:14:13 -0400
Message-ID: <1241457253.5754.15.camel@heimdal.trondhjem.org>
References: <20090504165839.2733.50787.stgit@ingres.1015granger.net>
	 <20090504170124.2733.88314.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:18460 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753833AbZEDROa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 May 2009 13:14:30 -0400
In-Reply-To: <20090504170124.2733.88314.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-05-04 at 13:01 -0400, Chuck Lever wrote:
> If the kernel cannot start the NFSv4 callback service during a mount
> request, it returns -ENOMEM to user space, resulting in this message:
> 
>    mount.nfs4: Cannot allocate memory
> 
> Adjust nfs_alloc_client() and nfs_get_client() to pass NFSv4 callback
> start-up errors back to user space so a less mysterious error message
> can be displayed by the mount command.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/nfs/client.c |   11 +++++++----
>  1 files changed, 7 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 75c9cd2..da1e2fd 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -114,6 +114,7 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
>  {
>  	struct nfs_client *clp;
>  	struct rpc_cred *cred;
> +	int err = -ENOMEM;
>  
>  	if ((clp = kzalloc(sizeof(*clp), GFP_KERNEL)) == NULL)
>  		goto error_0;
> @@ -121,7 +122,8 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
>  	clp->rpc_ops = cl_init->rpc_ops;
>  
>  	if (cl_init->rpc_ops->version == 4) {
> -		if (nfs_callback_up() < 0)
> +		err = nfs_callback_up();
> +		if (err < 0)
>  			goto error_2;
>  		__set_bit(NFS_CS_CALLBACK, &clp->cl_res_state);
>  	}

This will break the error_3 case, since it sets err = 0.

> @@ -165,7 +167,7 @@ error_3:
>  error_2:
>  	kfree(clp);
>  error_0:
> -	return NULL;
> +	return ERR_PTR(err);
>  }
>  
>  static void nfs4_shutdown_client(struct nfs_client *clp)
> @@ -456,9 +458,10 @@ static struct nfs_client *nfs_get_client(const struct nfs_client_initdata *cl_in
>  		spin_unlock(&nfs_client_lock);
>  
>  		new = nfs_alloc_client(cl_init);
> -	} while (new);
> +	} while (!IS_ERR(new));
>  
> -	return ERR_PTR(-ENOMEM);
> +	dprintk("--> nfs_get_client() = %ld [failed]\n", PTR_ERR(new));
> +	return new;
>  
>  	/* install a new client and return with it unready */
>  install_client:
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
