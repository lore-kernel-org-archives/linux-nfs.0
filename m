From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [RFC 64/85] nfs41: Refactor svc_process()
Date: Mon, 17 Nov 2008 15:54:37 +0200
Message-ID: <4921779D.1060000@panasas.com>
References: <4918920E.3030301@panasas.com> <1226348979-9366-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:13263 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751793AbYKQNyl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2008 08:54:41 -0500
In-Reply-To: <1226348979-9366-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov. 10, 2008, 22:29 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
> From: Ricardo Labiaga <ricardo.labiaga@netapp.com>
> 
> net/sunrpc/svc.c:svc_process() is used by the NFSv4 callback service
> to process RPC requests arriving over connections initiated by the
> server.  NFSv4.1 supports callbacks over the backchannel on connections
> initiated by the client.  This patch refactors svc_process() so that
> common code can also be used by the backchannel.
> 
> Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfs/callback.c |   10 +++---
>  net/sunrpc/svc.c  |   80 +++++++++++++++++++++++++++++++++--------------------
>  2 files changed, 55 insertions(+), 35 deletions(-)
> 
> diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
> index e792706..2f5acd3 100644
> --- a/fs/nfs/callback.c
> +++ b/fs/nfs/callback.c
> @@ -132,7 +132,7 @@ nfs4_callback_up(struct svc_serv *serv)
>  int nfs_callback_up(u32 minorversion, void *args)
>  {
>  	struct svc_serv *serv = NULL;
> -	struct svc_rqst *rqstp;
> +	struct svc_rqst *rqst;
>  	int (* callback_svc)(void *vrqstp);
>  	char svc_name[12];
>  	int ret = 0;
> @@ -150,20 +150,20 @@ int nfs_callback_up(u32 minorversion, void *args)
>  	/* FIXME: either 4.0 or 4.1 callback service can be up at a time
>  	 * need to monitor and control them both */
>  	if (!minorversion) {
> -		rqstp = nfs4_callback_up(serv);
> +		rqst = nfs4_callback_up(serv);
>  		callback_svc = nfs4_callback_svc;
>  	} else {
>  		BUG();	/* for now */
>  	}
> -	if (IS_ERR(rqstp)) {
> -		ret = PTR_ERR(rqstp);
> +	if (IS_ERR(rqst)) {
> +		ret = PTR_ERR(rqst);
>  		goto out_err;
>  	}
>  
>  	svc_sock_update_bufs(serv);
>  
>  	sprintf(svc_name, "nfsv4.%u-svc", minorversion);
> -	nfs_callback_info.rqst = rqstp;
> +	nfs_callback_info.rqst = rqst;
>  	nfs_callback_info.task = kthread_run(callback_svc,
>  					     nfs_callback_info.rqst,
>  					     svc_name);
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index 54c98d8..e4efeeb 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -985,20 +985,18 @@ svc_printk(struct svc_rqst *rqstp, const char *fmt, ...)
>  }
>  
>  /*
> - * Process the RPC request.
> + * Common routine for processing the RPC request.
>   */
> -int
> -svc_process(struct svc_rqst *rqstp)
> +static int
> +svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)

review 11-14: we have a problem with authenticating here over gss.
to support gss we need to factor out (everything but authentication?)
we need to keep the header part and processing part.

>  {
>  	struct svc_program	*progp;
>  	struct svc_version	*versp = NULL;	/* compiler food */
>  	struct svc_procedure	*procp = NULL;
> -	struct kvec *		argv = &rqstp->rq_arg.head[0];
> -	struct kvec *		resv = &rqstp->rq_res.head[0];
>  	struct svc_serv		*serv = rqstp->rq_server;
>  	kxdrproc_t		xdr;
>  	__be32			*statp;
> -	u32			dir, prog, vers, proc;
> +	u32			prog, vers, proc;
>  	__be32			auth_stat, rpc_stat;
>  	int			auth_res;
>  	__be32			*reply_statp;
> @@ -1008,36 +1006,19 @@ svc_process(struct svc_rqst *rqstp)
>  	if (argv->iov_len < 6*4)
>  		goto err_short_len;
>  
> -	/* setup response xdr_buf.
> -	 * Initially it has just one page
> -	 */
> -	rqstp->rq_resused = 1;
> -	resv->iov_base = page_address(rqstp->rq_respages[0]);
> -	resv->iov_len = 0;
> -	rqstp->rq_res.pages = rqstp->rq_respages + 1;
> -	rqstp->rq_res.len = 0;
> -	rqstp->rq_res.page_base = 0;
> -	rqstp->rq_res.page_len = 0;
> -	rqstp->rq_res.buflen = PAGE_SIZE;
> -	rqstp->rq_res.tail[0].iov_base = NULL;
> -	rqstp->rq_res.tail[0].iov_len = 0;
>  	/* Will be turned off only in gss privacy case: */
>  	rqstp->rq_splice_ok = 1;
>  
>  	/* Setup reply header */
>  	rqstp->rq_xprt->xpt_ops->xpo_prep_reply_hdr(rqstp);
>  
> -	rqstp->rq_xid = svc_getu32(argv);
>  	svc_putu32(resv, rqstp->rq_xid);
>  
> -	dir  = svc_getnl(argv);
>  	vers = svc_getnl(argv);
>  
>  	/* First words of reply: */
>  	svc_putnl(resv, 1);		/* REPLY */
>  
> -	if (dir != 0)		/* direction != CALL */
> -		goto err_bad_dir;
>  	if (vers != 2)		/* RPC version number */
>  		goto err_bad_rpc;
>  
> @@ -1161,7 +1142,7 @@ svc_process(struct svc_rqst *rqstp)
>   sendit:
>  	if (svc_authorise(rqstp))
>  		goto dropit;
> -	return svc_send(rqstp);
> +	return 1;		/* Caller can now send it */
>  
>   dropit:
>  	svc_authorise(rqstp);	/* doesn't hurt to call this twice */
> @@ -1175,12 +1156,6 @@ err_short_len:
>  
>  	goto dropit;			/* drop request */
>  
> -err_bad_dir:
> -	svc_printk(rqstp, "bad direction %d, dropping request\n", dir);
> -
> -	serv->sv_stats->rpcbadfmt++;
> -	goto dropit;			/* drop request */
> -
>  err_bad_rpc:
>  	serv->sv_stats->rpcbadfmt++;
>  	svc_putnl(resv, 1);	/* REJECT */
> @@ -1234,6 +1209,51 @@ err_bad:
>  EXPORT_SYMBOL(svc_process);
>  
>  /*
> + * Process the RPC request.
> + */
> +int
> +svc_process(struct svc_rqst *rqstp)
> +{
> +	struct kvec		*argv = &rqstp->rq_arg.head[0];
> +	struct kvec		*resv = &rqstp->rq_res.head[0];
> +	struct svc_serv		*serv = rqstp->rq_server;
> +	u32			dir;
> +	int			error;
> +
> +	/*
> +	 * Setup response xdr_buf.
> +	 * Initially it has just one page
> +	 */
> +	rqstp->rq_resused = 1;
> +	resv->iov_base = page_address(rqstp->rq_respages[0]);
> +	resv->iov_len = 0;
> +	rqstp->rq_res.pages = rqstp->rq_respages + 1;
> +	rqstp->rq_res.len = 0;
> +	rqstp->rq_res.page_base = 0;
> +	rqstp->rq_res.page_len = 0;
> +	rqstp->rq_res.buflen = PAGE_SIZE;
> +	rqstp->rq_res.tail[0].iov_base = NULL;
> +	rqstp->rq_res.tail[0].iov_len = 0;
> +
> +	rqstp->rq_xid = svc_getu32(argv);
> +
> +	dir  = svc_getnl(argv);
> +	if (dir != 0) {
> +		/* direction != CALL */
> +		svc_printk(rqstp, "bad direction %d, dropping request\n", dir);
> +		serv->sv_stats->rpcbadfmt++;
> +		svc_drop(rqstp);
> +		return 0;
> +	}
> +
> +	error = svc_process_common(rqstp, argv, resv);
> +	if (error <= 0)
> +		return error;
> +
> +	return svc_send(rqstp);
> +}
> +
> +/*
>   * Return (transport-specific) limit on the rpc payload.
>   */
>  u32 svc_max_payload(const struct svc_rqst *rqstp)
