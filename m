Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:38632 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751941Ab1ADRgk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jan 2011 12:36:40 -0500
Date: Tue, 4 Jan 2011 12:36:37 -0500
To: andros@netapp.com
Cc: trond.myklebust@netapp.com, bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH_V6 01/11] SUNRPC move svc_drop to caller of
 svc_process_common
Message-ID: <20110104173637.GC30317@fieldses.org>
References: <1294161028-4499-1-git-send-email-andros@netapp.com>
 <1294161028-4499-2-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1294161028-4499-2-git-send-email-andros@netapp.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Jan 04, 2011 at 12:10:18PM -0500, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> The NFSv4.1 shared back channel does not need to call svc_drop because the
> callback service never outlives the single connection it services, and it
> reuses it's buffers and keeps the trasport.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>

Looks good to me.

Acked-by: J. Bruce Fields <bfields@redhat.com>

--b.

> ---
>  net/sunrpc/svc.c |   30 ++++++++++++++++--------------
>  1 files changed, 16 insertions(+), 14 deletions(-)
> 
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index 6359c42..606d182 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -1147,7 +1147,6 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
>   dropit:
>  	svc_authorise(rqstp);	/* doesn't hurt to call this twice */
>  	dprintk("svc: svc_process dropit\n");
> -	svc_drop(rqstp);
>  	return 0;
>  
>  err_short_len:
> @@ -1218,7 +1217,6 @@ svc_process(struct svc_rqst *rqstp)
>  	struct kvec		*resv = &rqstp->rq_res.head[0];
>  	struct svc_serv		*serv = rqstp->rq_server;
>  	u32			dir;
> -	int			error;
>  
>  	/*
>  	 * Setup response xdr_buf.
> @@ -1246,11 +1244,13 @@ svc_process(struct svc_rqst *rqstp)
>  		return 0;
>  	}
>  
> -	error = svc_process_common(rqstp, argv, resv);
> -	if (error <= 0)
> -		return error;
> -
> -	return svc_send(rqstp);
> +	/* Returns 1 for send, 0 for drop */
> +	if (svc_process_common(rqstp, argv, resv))
> +		return svc_send(rqstp);
> +	else {
> +		svc_drop(rqstp);
> +		return 0;
> +	}
>  }
>  
>  #if defined(CONFIG_NFS_V4_1)
> @@ -1264,7 +1264,6 @@ bc_svc_process(struct svc_serv *serv, struct rpc_rqst *req,
>  {
>  	struct kvec	*argv = &rqstp->rq_arg.head[0];
>  	struct kvec	*resv = &rqstp->rq_res.head[0];
> -	int 		error;
>  
>  	/* Build the svc_rqst used by the common processing routine */
>  	rqstp->rq_xprt = serv->bc_xprt;
> @@ -1292,12 +1291,15 @@ bc_svc_process(struct svc_serv *serv, struct rpc_rqst *req,
>  	svc_getu32(argv);	/* XID */
>  	svc_getnl(argv);	/* CALLDIR */
>  
> -	error = svc_process_common(rqstp, argv, resv);
> -	if (error <= 0)
> -		return error;
> -
> -	memcpy(&req->rq_snd_buf, &rqstp->rq_res, sizeof(req->rq_snd_buf));
> -	return bc_send(req);
> +	/* Returns 1 for send, 0 for drop */
> +	if (svc_process_common(rqstp, argv, resv)) {
> +		memcpy(&req->rq_snd_buf, &rqstp->rq_res,
> +						sizeof(req->rq_snd_buf));
> +		return bc_send(req);
> +	} else {
> +		/* Nothing to do to drop request */
> +		return 0;
> +	}
>  }
>  EXPORT_SYMBOL(bc_svc_process);
>  #endif /* CONFIG_NFS_V4_1 */
> -- 
> 1.6.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
