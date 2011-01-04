From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH_V6 11/11] NFS rename client back channel transport field
Date: Tue, 4 Jan 2011 12:57:10 -0500
Message-ID: <20110104175709.GF30317@fieldses.org>
References: <1294161104-4555-1-git-send-email-andros@netapp.com>
 <1294161104-4555-2-git-send-email-andros@netapp.com>
 <1294161104-4555-3-git-send-email-andros@netapp.com>
 <1294161104-4555-4-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@netapp.com, bfields@redhat.com,
	linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:47815 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750886Ab1ADR5O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jan 2011 12:57:14 -0500
In-Reply-To: <1294161104-4555-4-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 04, 2011 at 12:11:44PM -0500, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Differentiate from server backchannel
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>

Acked-by: J. Bruce Fields <bfields@redhat.com>

--b.

> ---
>  fs/nfs/callback.c              |   12 ++++++------
>  include/linux/sunrpc/bc_xprt.h |    4 ++--
>  include/linux/sunrpc/svc.h     |    2 +-
>  net/sunrpc/svc.c               |    2 +-
>  net/sunrpc/svcsock.c           |    2 +-
>  5 files changed, 11 insertions(+), 11 deletions(-)
> 
> diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
> index 6071afd..2e4ac33 100644
> --- a/fs/nfs/callback.c
> +++ b/fs/nfs/callback.c
> @@ -142,7 +142,7 @@ int nfs4_set_callback_sessionid(struct nfs_client *clp)
>  	struct svc_serv *serv = clp->cl_rpcclient->cl_xprt->bc_serv;
>  	struct nfs4_sessionid *bc_sid;
>  
> -	if (!serv->bc_xprt)
> +	if (!serv->sv_bc_xprt)
>  		return -EINVAL;
>  
>  	/* on success freed in xprt_free */
> @@ -152,12 +152,12 @@ int nfs4_set_callback_sessionid(struct nfs_client *clp)
>  	memcpy(bc_sid->data, &clp->cl_session->sess_id.data,
>  		NFS4_MAX_SESSIONID_LEN);
>  	spin_lock_bh(&serv->sv_cb_lock);
> -	serv->bc_xprt->xpt_bc_sid = bc_sid;
> +	serv->sv_bc_xprt->xpt_bc_sid = bc_sid;
>  	spin_unlock_bh(&serv->sv_cb_lock);
> -	dprintk("%s set xpt_bc_sid=%u:%u:%u:%u for bc_xprt %p\n", __func__,
> +	dprintk("%s set xpt_bc_sid=%u:%u:%u:%u for sv_bc_xprt %p\n", __func__,
>  		((u32 *)bc_sid->data)[0], ((u32 *)bc_sid->data)[1],
>  		((u32 *)bc_sid->data)[2], ((u32 *)bc_sid->data)[3],
> -		serv->bc_xprt);
> +		serv->sv_bc_xprt);
>  	return 0;
>  }
>  
> @@ -231,8 +231,8 @@ nfs41_callback_up(struct svc_serv *serv, struct rpc_xprt *xprt)
>  	init_waitqueue_head(&serv->sv_cb_waitq);
>  	rqstp = svc_prepare_thread(serv, &serv->sv_pools[0]);
>  	if (IS_ERR(rqstp)) {
> -		svc_xprt_put(serv->bc_xprt);
> -		serv->bc_xprt = NULL;
> +		svc_xprt_put(serv->sv_bc_xprt);
> +		serv->sv_bc_xprt = NULL;
>  	}
>  out:
>  	dprintk("--> %s return %ld\n", __func__,
> diff --git a/include/linux/sunrpc/bc_xprt.h b/include/linux/sunrpc/bc_xprt.h
> index 2c60e09..c50b458 100644
> --- a/include/linux/sunrpc/bc_xprt.h
> +++ b/include/linux/sunrpc/bc_xprt.h
> @@ -43,7 +43,7 @@ int bc_send(struct rpc_rqst *req);
>   */
>  static inline int svc_is_backchannel(const struct svc_rqst *rqstp)
>  {
> -	if (rqstp->rq_server->bc_xprt)
> +	if (rqstp->rq_server->sv_bc_xprt)
>  		return 1;
>  	return 0;
>  }
> @@ -51,7 +51,7 @@ static inline struct nfs4_sessionid *bc_xprt_sid(struct svc_rqst *rqstp)
>  {
>  	if (svc_is_backchannel(rqstp))
>  		return (struct nfs4_sessionid *)
> -					rqstp->rq_server->bc_xprt->xpt_bc_sid;
> +			rqstp->rq_server->sv_bc_xprt->xpt_bc_sid;
>  	return NULL;
>  }
>  
> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
> index 5a3085b..c81d4d8 100644
> --- a/include/linux/sunrpc/svc.h
> +++ b/include/linux/sunrpc/svc.h
> @@ -99,7 +99,7 @@ struct svc_serv {
>  	spinlock_t		sv_cb_lock;	/* protects the svc_cb_list */
>  	wait_queue_head_t	sv_cb_waitq;	/* sleep here if there are no
>  						 * entries in the svc_cb_list */
> -	struct svc_xprt		*bc_xprt;
> +	struct svc_xprt		*sv_bc_xprt;	/* callback on fore channel */
>  #endif /* CONFIG_NFS_V4_1 */
>  };
>  
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index 261e2d1..0e659c6 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -1262,7 +1262,7 @@ bc_svc_process(struct svc_serv *serv, struct rpc_rqst *req,
>  	struct kvec	*resv = &rqstp->rq_res.head[0];
>  
>  	/* Build the svc_rqst used by the common processing routine */
> -	rqstp->rq_xprt = serv->bc_xprt;
> +	rqstp->rq_xprt = serv->sv_bc_xprt;
>  	rqstp->rq_xid = req->rq_xid;
>  	rqstp->rq_prot = req->rq_xprt->prot;
>  	rqstp->rq_server = serv;
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index 87e6f28..697f512 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -1611,7 +1611,7 @@ static struct svc_xprt *svc_bc_create_socket(struct svc_serv *serv,
>  	xprt = &svsk->sk_xprt;
>  	svc_xprt_init(&svc_tcp_bc_class, xprt, serv);
>  
> -	serv->bc_xprt = xprt;
> +	serv->sv_bc_xprt = xprt;
>  
>  	return xprt;
>  }
> -- 
> 1.6.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
