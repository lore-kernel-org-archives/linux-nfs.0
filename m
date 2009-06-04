From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [pnfs] [RFC 04/39] nfs41: minorversion support for nfs4_{init,
 destroy}_callback
Date: Wed, 03 Jun 2009 22:39:58 -0400
Message-ID: <1244083198.5603.354.camel@heimdal.trondhjem.org>
References: <49FA3180.5030404@panasas.com>
	 <1241133576-415-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43888 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753271AbZFDCqp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Jun 2009 22:46:45 -0400
In-Reply-To: <1241133576-415-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-05-01 at 02:19 +0300, Benny Halevy wrote:
> move nfs4_init_callback into nfs4_init_client_minor_version
> and nfs4_destroy_callback into nfs4_clear_client_minor_version
> 
> as these need to happen also when auto-negotiating the minorversion
> once the callback service for nfs41 becomes different than for nfs4.0
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> [nfs41: Fix checkpatch warning]
> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfs/callback.c |   67 ++++++++++++++++++++++++++++++++++++++---------------
>  fs/nfs/callback.h |    2 +-
>  fs/nfs/client.c   |   21 +++++-----------
>  3 files changed, 56 insertions(+), 34 deletions(-)
> 
> diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
> index a886e69..3926046 100644
> --- a/fs/nfs/callback.c
> +++ b/fs/nfs/callback.c
> @@ -59,7 +59,7 @@ module_param_call(callback_tcpport, param_set_port, param_get_int,
>   * This is the callback kernel thread.
>   */
>  static int
> -nfs_callback_svc(void *vrqstp)
> +nfs4_callback_svc(void *vrqstp)
>  {
>  	int err, preverr = 0;
>  	struct svc_rqst *rqstp = vrqstp;
> @@ -97,20 +97,12 @@ nfs_callback_svc(void *vrqstp)
>  }
>  
>  /*
> - * Bring up the callback thread if it is not already up.
> + * Prepare to bring up the NFSv4 callback service
>   */
> -int nfs_callback_up(void)
> +struct svc_rqst *
> +nfs4_callback_up(struct svc_serv *serv)
>  {
> -	struct svc_serv *serv = NULL;
> -	int ret = 0;
> -
> -	mutex_lock(&nfs_callback_mutex);
> -	if (nfs_callback_info.users++ || nfs_callback_info.task != NULL)
> -		goto out;
> -	serv = svc_create(&nfs4_callback_program, NFS4_CALLBACK_BUFSIZE, NULL);
> -	ret = -ENOMEM;
> -	if (!serv)
> -		goto out_err;
> +	int ret;
>  
>  	ret = svc_create_xprt(serv, "tcp", PF_INET,
>  				nfs_callback_set_tcpport, SVC_SOCK_ANONYMOUS);
> @@ -131,18 +123,55 @@ int nfs_callback_up(void)
>  		goto out_err;
>  #endif	/* defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) */
>  
> -	nfs_callback_info.rqst = svc_prepare_thread(serv, &serv->sv_pools[0]);
> -	if (IS_ERR(nfs_callback_info.rqst)) {
> -		ret = PTR_ERR(nfs_callback_info.rqst);
> -		nfs_callback_info.rqst = NULL;
> +	return svc_prepare_thread(serv, &serv->sv_pools[0]);
> +
> +out_err:
> +	if (ret == 0)
> +		ret = -ENOMEM;
> +	return ERR_PTR(ret);
> +}
> +
> +/*
> + * Bring up the callback thread if it is not already up.
> + */
> +int nfs_callback_up(u32 minorversion, void *args)
                                         ^^^^^^^^^^
There is no reason not to type check the arguments here. Please fix...

> +{
> +	struct svc_serv *serv = NULL;
> +	struct svc_rqst *rqstp;
> +	int (*callback_svc)(void *vrqstp);
> +	char svc_name[12];
> +	int ret = 0;
> +
> +	mutex_lock(&nfs_callback_mutex);
> +	if (nfs_callback_info.users++ || nfs_callback_info.task != NULL)
> +		goto out;
> +	serv = svc_create(&nfs4_callback_program, NFS4_CALLBACK_BUFSIZE, NULL);
> +	if (!serv) {
> +		ret = -ENOMEM;
> +		goto out_err;
> +	}
> +
> +	/* FIXME: either 4.0 or 4.1 callback service can be up at a time
> +	 * need to monitor and control them both */
> +	if (!minorversion) {
> +		rqstp = nfs4_callback_up(serv);
> +		callback_svc = nfs4_callback_svc;
> +	} else {
> +		BUG();	/* for now */
> +	}
> +
> +	if (IS_ERR(rqstp)) {
> +		ret = PTR_ERR(rqstp);
>  		goto out_err;
>  	}
>  
>  	svc_sock_update_bufs(serv);
>  
> -	nfs_callback_info.task = kthread_run(nfs_callback_svc,
> +	sprintf(svc_name, "nfsv4.%u-svc", minorversion);
> +	nfs_callback_info.rqst = rqstp;
> +	nfs_callback_info.task = kthread_run(callback_svc,
>  					     nfs_callback_info.rqst,
> -					     "nfsv4-svc");
> +					     svc_name);
>  	if (IS_ERR(nfs_callback_info.task)) {
>  		ret = PTR_ERR(nfs_callback_info.task);
>  		svc_exit_thread(nfs_callback_info.rqst);
> diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
> index e110e28..7f12e65 100644
> --- a/fs/nfs/callback.h
> +++ b/fs/nfs/callback.h
> @@ -63,7 +63,7 @@ extern __be32 nfs4_callback_getattr(struct cb_getattrargs *args, struct cb_getat
>  extern __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy);
>  
>  #ifdef CONFIG_NFS_V4
> -extern int nfs_callback_up(void);
> +extern int nfs_callback_up(u32 minorversion, void *args);
>  extern void nfs_callback_down(void);
>  #else
>  #define nfs_callback_up()	(0)
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index d9657d4..df2b40d 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -47,9 +47,6 @@
>  #include "internal.h"
>  #include "fscache.h"
>  
> -static int nfs4_init_callback(struct nfs_client *);
> -static void nfs4_destroy_callback(struct nfs_client *);
> -
>  #define NFSDBG_FACILITY		NFSDBG_CLIENT
>  
>  static DEFINE_SPINLOCK(nfs_client_lock);
> @@ -124,9 +121,6 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
>  
>  	clp->rpc_ops = cl_init->rpc_ops;
>  
> -	if (nfs4_init_callback(clp) < 0)
> -		goto error_2;
> -
>  	atomic_set(&clp->cl_count, 1);
>  	clp->cl_cons_state = NFS_CS_INITING;
>  
> @@ -136,7 +130,7 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
>  	if (cl_init->hostname) {
>  		clp->cl_hostname = kstrdup(cl_init->hostname, GFP_KERNEL);
>  		if (!clp->cl_hostname)
> -			goto error_3;
> +			goto error_cleanup;
>  	}
>  
>  	INIT_LIST_HEAD(&clp->cl_superblocks);
> @@ -161,9 +155,7 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
>  
>  	return clp;
>  
> -error_3:
> -	nfs4_destroy_callback(clp);
> -error_2:
> +error_cleanup:
>  	kfree(clp);
>  error_0:
>  	return NULL;
> @@ -207,6 +199,8 @@ static void nfs4_clear_client_minor_version(struct nfs_client *clp)
>  
>  	clp->cl_call_sync = _nfs4_call_sync;
>  #endif /* CONFIG_NFS_V4_1 */
> +
> +	nfs4_destroy_callback(clp);
>  }
>  
>  /*
> @@ -225,8 +219,6 @@ static void nfs_free_client(struct nfs_client *clp)
>  	if (!IS_ERR(clp->cl_rpcclient))
>  		rpc_shutdown_client(clp->cl_rpcclient);
>  
> -	nfs4_destroy_callback(clp);
> -
>  	if (clp->cl_machine_cred != NULL)
>  		put_rpccred(clp->cl_machine_cred);
>  
> @@ -1104,7 +1096,8 @@ static int nfs4_init_callback(struct nfs_client *clp)
>  	int error;
>  
>  	if (clp->rpc_ops->version == 4) {
> -		error = nfs_callback_up();
> +		error = nfs_callback_up(clp->cl_minorversion,
> +					clp->cl_rpcclient->cl_xprt);
>  		if (error < 0) {
>  			dprintk("%s: failed to start callback. Error = %d\n",
>  				__func__, error);
> @@ -1139,7 +1132,7 @@ static int nfs4_init_client_minor_version(struct nfs_client *clp)
>  	}
>  #endif /* CONFIG_NFS_V4_1 */
>  
> -	return 0;
> +	return nfs4_init_callback(clp);
>  }
>  
>  /*



-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
