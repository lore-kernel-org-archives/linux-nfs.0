From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/5] NFS: Enable NFSv4 callback server to listen on
	AF_INET6 sockets
Date: Fri, 22 Aug 2008 19:18:01 -0400
Message-ID: <20080822231801.GA12995@fieldses.org>
References: <20080822163939.20488.92983.stgit@manray.1015granger.net> <20080822164201.20488.61180.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:46347 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755003AbYHVXSF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Aug 2008 19:18:05 -0400
In-Reply-To: <20080822164201.20488.61180.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 22, 2008 at 12:42:02PM -0400, Chuck Lever wrote:
> Allow the NFS callback server to listen for requests via an AF_INET6
> or AF_INET socket.
> 
> The NFS callback server determines the listener's address family from
> the address the client uses to contact the server.  The server will
> always call the client back using the same address family.

Won't the server determine that from the callback address which the
client provides in the setclientid?

--b.

> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/nfs/callback.c |   11 ++++++-----
>  fs/nfs/callback.h |    4 ++--
>  fs/nfs/client.c   |    2 +-
>  3 files changed, 9 insertions(+), 8 deletions(-)
> 
> diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
> index 6a09760..59948ef 100644
> --- a/fs/nfs/callback.c
> +++ b/fs/nfs/callback.c
> @@ -97,7 +97,7 @@ nfs_callback_svc(void *vrqstp)
>  /*
>   * Bring up the callback thread if it is not already up.
>   */
> -int nfs_callback_up(void)
> +int nfs_callback_up(const sa_family_t family)
>  {
>  	struct svc_serv *serv = NULL;
>  	int ret = 0;
> @@ -106,7 +106,7 @@ int nfs_callback_up(void)
>  	if (nfs_callback_info.users++ || nfs_callback_info.task != NULL)
>  		goto out;
>  	serv = svc_create(&nfs4_callback_program, NFS4_CALLBACK_BUFSIZE,
> -				AF_INET, NULL);
> +				family, NULL);
>  	ret = -ENOMEM;
>  	if (!serv)
>  		goto out_err;
> @@ -116,7 +116,8 @@ int nfs_callback_up(void)
>  	if (ret <= 0)
>  		goto out_err;
>  	nfs_callback_tcpport = ret;
> -	dprintk("Callback port = 0x%x\n", nfs_callback_tcpport);
> +	dprintk("NFS: Callback listener port = %u (af %u)\n",
> +			nfs_callback_tcpport, family);
>  
>  	nfs_callback_info.rqst = svc_prepare_thread(serv, &serv->sv_pools[0]);
>  	if (IS_ERR(nfs_callback_info.rqst)) {
> @@ -149,8 +150,8 @@ out:
>  	mutex_unlock(&nfs_callback_mutex);
>  	return ret;
>  out_err:
> -	dprintk("Couldn't create callback socket or server thread; err = %d\n",
> -		ret);
> +	dprintk("NFS: Couldn't create callback socket or server thread; "
> +		"err = %d\n", ret);
>  	nfs_callback_info.users--;
>  	goto out;
>  }
> diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
> index bb25d21..85d8102 100644
> --- a/fs/nfs/callback.h
> +++ b/fs/nfs/callback.h
> @@ -63,10 +63,10 @@ extern __be32 nfs4_callback_getattr(struct cb_getattrargs *args, struct cb_getat
>  extern __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy);
>  
>  #ifdef CONFIG_NFS_V4
> -extern int nfs_callback_up(void);
> +extern int nfs_callback_up(const sa_family_t family);
>  extern void nfs_callback_down(void);
>  #else
> -#define nfs_callback_up()	(0)
> +#define nfs_callback_up(x)	(0)
>  #define nfs_callback_down()	do {} while(0)
>  #endif
>  
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index fc6a95d..5f8889f 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -120,7 +120,7 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
>  	clp->rpc_ops = cl_init->rpc_ops;
>  
>  	if (cl_init->rpc_ops->version == 4) {
> -		if (nfs_callback_up() < 0)
> +		if (nfs_callback_up(cl_init->addr->sa_family) < 0)
>  			goto error_2;
>  		__set_bit(NFS_CS_CALLBACK, &clp->cl_res_state);
>  	}
> 
