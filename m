Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:60767 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934045AbcHDT0p (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Aug 2016 15:26:45 -0400
Subject: Re: [PATCH Version 7 6/8] SUNRPC add an RPC null call to test session
 trunking connection
To: <andros@netapp.com>, <trond.myklebust@primarydata.com>
References: <1469645000-19791-1-git-send-email-andros@netapp.com>
 <1469645000-19791-7-git-send-email-andros@netapp.com>
CC: <linux-nfs@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <c3229909-cafb-6234-df63-3a6785cf8ab2@Netapp.com>
Date: Thu, 4 Aug 2016 15:26:41 -0400
MIME-Version: 1.0
In-Reply-To: <1469645000-19791-7-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Andy,

On 07/27/2016 02:43 PM, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  include/linux/sunrpc/clnt.h |  2 ++
>  net/sunrpc/clnt.c           | 18 ++++++++++++++++++
>  2 files changed, 20 insertions(+)
> 
> diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
> index 99410bb..ebc83df 100644
> --- a/include/linux/sunrpc/clnt.h
> +++ b/include/linux/sunrpc/clnt.h
> @@ -189,6 +189,8 @@ int 		rpc_clnt_test_and_add_xprt(struct rpc_clnt *clnt,
>  			struct rpc_xprt_switch *xps,
>  			struct rpc_xprt *xprt,
>  			void *dummy);
> +int		rpc_clnt_test_xprt(struct rpc_clnt *clnt,
> +			struct rpc_xprt *xprt);
>  int		rpc_clnt_add_xprt(struct rpc_clnt *, struct xprt_create *,
>  			int (*setup)(struct rpc_clnt *,
>  				struct rpc_xprt_switch *,
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index 459f9b1..822060f 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -2614,6 +2614,24 @@ int rpc_clnt_test_and_add_xprt(struct rpc_clnt *clnt,
>  }
>  EXPORT_SYMBOL_GPL(rpc_clnt_test_and_add_xprt);
>  
> +int rpc_clnt_test_xprt(struct rpc_clnt *clnt, struct rpc_xprt *xprt)

Looks like rpc_clnt_test_and_add_xprt() runs the same testing code.  Can you swap the order of these functions in clnt.c and then have test_and_add_xprt() call test_xprt()?

Thanks,
Anna

> +{
> +	struct rpc_cred *cred;
> +	struct rpc_task *task;
> +	int status;
> +
> +	cred = authnull_ops.lookup_cred(NULL, NULL, 0);
> +	task = rpc_call_null_helper(clnt, xprt, cred,
> +				RPC_TASK_SOFT | RPC_TASK_SOFTCONN, NULL, NULL);
> +	put_rpccred(cred);
> +	if (IS_ERR(task))
> +		return PTR_ERR(task);
> +	status = task->tk_status;
> +	rpc_put_task(task);
> +	return status;
> +}
> +EXPORT_SYMBOL_GPL(rpc_clnt_test_xprt);
> +
>  /**
>   * rpc_clnt_add_xprt - Add a new transport to a rpc_clnt
>   * @clnt: pointer to struct rpc_clnt
> 

