Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59202 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753904AbdCIWVi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Mar 2017 17:21:38 -0500
Date: Thu, 9 Mar 2017 17:11:01 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: andros@netapp.com
Cc: trond.myklebust@primarydata.com, schumaker.anna@gmail.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH Version 5 02/17] SUNRPC: RPCNULL call with payload for
 GSSv3
Message-ID: <20170309221101.GD12553@fieldses.org>
References: <20170224221953.5502-1-andros@netapp.com>
 <20170224221953.5502-3-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170224221953.5502-3-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm not sure why this is really necessary.  And it does it really have
anything to do with null calls?  It seems like it could be used for any
call?

--b.

On Fri, Feb 24, 2017 at 05:19:38PM -0500, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> RPCSEC_GSS_CREATE and RPCSEC_GSS_LIST are RPCNULL calls with a payload
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  include/linux/sunrpc/clnt.h |  3 +++
>  net/sunrpc/clnt.c           | 20 ++++++++++++++++++++
>  2 files changed, 23 insertions(+)
> 
> diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
> index 333ad11..6d9e4ac 100644
> --- a/include/linux/sunrpc/clnt.h
> +++ b/include/linux/sunrpc/clnt.h
> @@ -175,6 +175,9 @@ int		rpc_call_sync(struct rpc_clnt *clnt,
>  			      const struct rpc_message *msg, int flags);
>  struct rpc_task *rpc_call_null(struct rpc_clnt *clnt, struct rpc_cred *cred,
>  			       int flags);
> +struct rpc_task *rpc_call_null_payload(struct rpc_clnt *clnt,
> +				struct rpc_cred *cred, int flags, void *argp,
> +				void *resp, struct rpc_procinfo *pinfo);
>  int		rpc_restart_call_prepare(struct rpc_task *);
>  int		rpc_restart_call(struct rpc_task *);
>  void		rpc_setbufsize(struct rpc_clnt *, unsigned int, unsigned int);
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index 1dc9f3b..c6f1d04 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -2508,6 +2508,26 @@ static int rpcproc_decode_null(void *rqstp, struct xdr_stream *xdr, void *obj)
>  	return 0;
>  }
>  
> +struct rpc_task *
> +rpc_call_null_payload(struct rpc_clnt *clnt, struct rpc_cred *cred, int flags,
> +		      void *argp, void *resp, struct rpc_procinfo *pinfo)
> +{
> +	struct rpc_message msg = {
> +		.rpc_proc = pinfo,
> +		.rpc_argp = argp,
> +		.rpc_resp = resp,
> +		.rpc_cred = cred,
> +	};
> +	struct rpc_task_setup task_setup_data = {
> +		.rpc_client = clnt,
> +		.rpc_message = &msg,
> +		.callback_ops = &rpc_default_ops,
> +		.flags = flags,
> +	};
> +	return rpc_run_task(&task_setup_data);
> +}
> +EXPORT_SYMBOL_GPL(rpc_call_null_payload);
> +
>  static struct rpc_procinfo rpcproc_null = {
>  	.p_encode = rpcproc_encode_null,
>  	.p_decode = rpcproc_decode_null,
> -- 
> 2.9.3
