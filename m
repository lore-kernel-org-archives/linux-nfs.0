Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:56604 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751825AbaAUUSp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Jan 2014 15:18:45 -0500
Date: Tue, 21 Jan 2014 15:18:42 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/3] SUNRPC: remove KERN_INFO from dprintk() call sites
Message-ID: <20140121151842.69a2db1f@tlielax.poochiereds.net>
In-Reply-To: <20140117193825.3452.92786.stgit@manet.1015granger.net>
References: <20140117193555.3452.31437.stgit@manet.1015granger.net>
	<20140117193825.3452.92786.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 17 Jan 2014 14:38:25 -0500
Chuck Lever <chuck.lever@oracle.com> wrote:

> The use of KERN_INFO causes garbage characters to appear
> when debugging is enabled.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  net/sunrpc/xprtrdma/transport.c |   10 +++++-----
>  1 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
> index 285dc08..1eb9c46 100644
> --- a/net/sunrpc/xprtrdma/transport.c
> +++ b/net/sunrpc/xprtrdma/transport.c
> @@ -733,7 +733,7 @@ static void __exit xprt_rdma_cleanup(void)
>  {
>  	int rc;
>  
> -	dprintk(KERN_INFO "RPCRDMA Module Removed, deregister RPC RDMA transport\n");
> +	dprintk("RPCRDMA Module Removed, deregister RPC RDMA transport\n");
>  #ifdef RPC_DEBUG
>  	if (sunrpc_table_header) {
>  		unregister_sysctl_table(sunrpc_table_header);
> @@ -755,14 +755,14 @@ static int __init xprt_rdma_init(void)
>  	if (rc)
>  		return rc;
>  
> -	dprintk(KERN_INFO "RPCRDMA Module Init, register RPC RDMA transport\n");
> +	dprintk("RPCRDMA Module Init, register RPC RDMA transport\n");
>  
> -	dprintk(KERN_INFO "Defaults:\n");
> -	dprintk(KERN_INFO "\tSlots %d\n"
> +	dprintk("Defaults:\n");
> +	dprintk("\tSlots %d\n"
>  		"\tMaxInlineRead %d\n\tMaxInlineWrite %d\n",
>  		xprt_rdma_slot_table_entries,
>  		xprt_rdma_max_inline_read, xprt_rdma_max_inline_write);
> -	dprintk(KERN_INFO "\tPadding %d\n\tMemreg %d\n",
> +	dprintk("\tPadding %d\n\tMemreg %d\n",
>  		xprt_rdma_inline_write_padding, xprt_rdma_memreg_strategy);
>  
>  #ifdef RPC_DEBUG
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Nice cleanup

Reviewed-by: Jeff Layton <jlayton@redhat.com>
