Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35348 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753354Ab1AFAGW convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Jan 2011 19:06:22 -0500
Subject: Re: [PATCH_V8 08/13] NFS associate sessionid with callback
 connection
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: andros@netapp.com
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
In-Reply-To: <1294260690-3095-9-git-send-email-andros@netapp.com>
References: <1294260690-3095-1-git-send-email-andros@netapp.com>
	 <1294260690-3095-2-git-send-email-andros@netapp.com>
	 <1294260690-3095-3-git-send-email-andros@netapp.com>
	 <1294260690-3095-4-git-send-email-andros@netapp.com>
	 <1294260690-3095-5-git-send-email-andros@netapp.com>
	 <1294260690-3095-6-git-send-email-andros@netapp.com>
	 <1294260690-3095-7-git-send-email-andros@netapp.com>
	 <1294260690-3095-8-git-send-email-andros@netapp.com>
	 <1294260690-3095-9-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 05 Jan 2011 19:06:20 -0500
Message-ID: <1294272380.2952.22.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-01-05 at 15:51 -0500, andros@netapp.com wrote: 
> From: Andy Adamson <andros@netapp.com>
> 
> The sessions based callback service is started prior to the CREATE_SESSION call
> so that it can handle CB_NULL requests which can be sent before the
> CREATE_SESSION call returns and the session ID is known.
> 
> Set the callback sessionid after a sucessful CREATE_SESSION.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/callback.c               |   31 +++++++++++++++++++++++++++++++
>  fs/nfs/callback.h               |    1 +
>  fs/nfs/nfs4state.c              |    6 ++++++
>  include/linux/sunrpc/svc_xprt.h |    1 +
>  net/sunrpc/svcsock.c            |    1 +
>  5 files changed, 40 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
> index 0e9fae8..c0b0549 100644
> --- a/fs/nfs/callback.c
> +++ b/fs/nfs/callback.c
> @@ -137,6 +137,33 @@ out_err:
>  
>  #if defined(CONFIG_NFS_V4_1)
>  /*
> + *  * CB_SEQUENCE operations will fail until the callback sessionid is set.
> + *   */
> +int nfs4_set_callback_sessionid(struct nfs_client *clp)
> +{
> +	struct svc_serv *serv = clp->cl_rpcclient->cl_xprt->bc_serv;
> +	struct nfs4_sessionid *bc_sid;
> +
> +	if (!serv->bc_xprt)
> +		return -EINVAL;
> +
> +	/* on success freed in xprt_free */
> +	bc_sid = kmalloc(sizeof(struct nfs4_sessionid), GFP_KERNEL);
> +	if (!bc_sid)
> +		return -ENOMEM;
> +	memcpy(bc_sid->data, &clp->cl_session->sess_id.data,
> +		NFS4_MAX_SESSIONID_LEN);
> +	spin_lock_bh(&serv->sv_cb_lock);
> +	serv->bc_xprt->xpt_bc_sid = bc_sid;
> +	spin_unlock_bh(&serv->sv_cb_lock);
> +	dprintk("%s set xpt_bc_sid=%u:%u:%u:%u for bc_xprt %p\n", __func__,
> +		((u32 *)bc_sid->data)[0], ((u32 *)bc_sid->data)[1],
> +		((u32 *)bc_sid->data)[2], ((u32 *)bc_sid->data)[3],
> +		serv->bc_xprt);
> +	return 0;
> +}
> +
> +/*
>   * The callback service for NFSv4.1 callbacks
>   */
>  static int
> @@ -241,6 +268,10 @@ static inline void nfs_callback_bc_serv(u32 minorversion, struct rpc_xprt *xprt,
>  		struct nfs_callback_data *cb_info)
>  {
>  }
> +int nfs4_set_callback_sessionid(struct nfs_client *clp)
> +{
> +	return 0;
> +}
>  #endif /* CONFIG_NFS_V4_1 */
>  
>  /*
> diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
> index 85a7cfd..58d61a8 100644
> --- a/fs/nfs/callback.h
> +++ b/fs/nfs/callback.h
> @@ -137,6 +137,7 @@ extern int nfs_callback_up(u32 minorversion, struct rpc_xprt *xprt);
>  extern void nfs_callback_down(int minorversion);
>  extern int nfs4_validate_delegation_stateid(struct nfs_delegation *delegation,
>  					    const nfs4_stateid *stateid);
> +extern int nfs4_set_callback_sessionid(struct nfs_client *clp);
>  #endif /* CONFIG_NFS_V4 */
>  /*
>   * nfs41: Callbacks are expected to not cause substantial latency,
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index fe61422..11290de 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -193,6 +193,12 @@ int nfs41_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)
>  	status = nfs4_proc_create_session(clp);
>  	if (status != 0)
>  		goto out;
> +	status = nfs4_set_callback_sessionid(clp);
> +	if (status != 0) {
> +		printk(KERN_WARNING "Sessionid not set. No callback service\n");
> +		nfs_callback_down(1);
> +		status = 0;
> +	}
>  	nfs41_setup_state_renewal(clp);
>  	nfs_mark_client_ready(clp, NFS_CS_READY);
>  out:
> diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
> index aea0d43..357da5e 100644
> --- a/include/linux/sunrpc/svc_xprt.h
> +++ b/include/linux/sunrpc/svc_xprt.h
> @@ -78,6 +78,7 @@ struct svc_xprt {
>  	size_t			xpt_remotelen;	/* length of address */
>  	struct rpc_wait_queue	xpt_bc_pending;	/* backchannel wait queue */
>  	struct list_head	xpt_users;	/* callbacks on free */
> +	void			*xpt_bc_sid;	/* back channel session ID */
>  
>  	struct net		*xpt_net;
>  };
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index e6b66d8..9456152 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -1606,6 +1606,7 @@ static struct svc_xprt *svc_bc_create_socket(struct svc_serv *serv,
>  static void svc_bc_sock_free(struct svc_xprt *xprt)
>  {
>  	if (xprt)
> +		kfree(xprt->xpt_bc_sid);
>  		kfree(container_of(xprt, struct svc_sock, sk_xprt));

This looks dubious... Shouldn't there be braces here?

> }
>  #endif /* CONFIG_NFS_V4_1 */

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

