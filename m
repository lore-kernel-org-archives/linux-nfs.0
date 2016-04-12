Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:26033 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965083AbcDLSFD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Apr 2016 14:05:03 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH v1 02/18] xprtrdma: Bound the inline threshold values
To: Chuck Lever <chuck.lever@oracle.com>, <linux-rdma@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>
References: <20160411200323.20531.8893.stgit@manet.1015granger.net>
 <20160411201024.20531.77252.stgit@manet.1015granger.net>
Message-ID: <570D38B6.30005@Netapp.com>
Date: Tue, 12 Apr 2016 14:04:38 -0400
MIME-Version: 1.0
In-Reply-To: <20160411201024.20531.77252.stgit@manet.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/11/2016 04:10 PM, Chuck Lever wrote:
> Currently the sysctls that allow setting the inline threshold allow
> any value to be set.
> 
> Small values only make the transport run slower. The default 1KB
> setting is as low as is reasonable. And the logic that decides how
> to divide a Send buffer buffer between RPC-over-RDMA header and RPC
                   ^^^^^^^^^^^^^
I'm guessing you don't mean a buffer of buffers? :)

> message assumes (but does not check) that the lower bound is not
> crazy (say, 57 bytes).
> 
> Send and receive buffers share a page with some control information.
> Values larger than about 3KB can't be supported, currently.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  include/linux/sunrpc/xprtrdma.h |    4 +++-
>  net/sunrpc/xprtrdma/transport.c |    6 ++++++
>  2 files changed, 9 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/sunrpc/xprtrdma.h b/include/linux/sunrpc/xprtrdma.h
> index 767190b..39267dc 100644
> --- a/include/linux/sunrpc/xprtrdma.h
> +++ b/include/linux/sunrpc/xprtrdma.h
> @@ -52,7 +52,9 @@
>  #define RPCRDMA_DEF_SLOT_TABLE	(128U)
>  #define RPCRDMA_MAX_SLOT_TABLE	(256U)
>  
> -#define RPCRDMA_DEF_INLINE  (1024)	/* default inline max */
> +#define RPCRDMA_MIN_INLINE  (1024)	/* min inline thresh */
> +#define RPCRDMA_DEF_INLINE  (1024)	/* default inline thresh */
> +#define RPCRDMA_MAX_INLINE  (3068)	/* max inline thresh */

It looks like RPCRDMA_DEF_INLINE is used to set xprt_rdma_max_inline_{read,write}. Are we keeping DEF_INLINE around so we can set these values separately from the minimum and maximum amounts?

Thanks,
Anna

>  
>  /* Memory registration strategies, by number.
>   * This is part of a kernel / user space API. Do not remove. */
> diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
> index 9954342..16595ff 100644
> --- a/net/sunrpc/xprtrdma/transport.c
> +++ b/net/sunrpc/xprtrdma/transport.c
> @@ -73,6 +73,8 @@ static unsigned int xprt_rdma_memreg_strategy = RPCRDMA_FRMR;
>  
>  static unsigned int min_slot_table_size = RPCRDMA_MIN_SLOT_TABLE;
>  static unsigned int max_slot_table_size = RPCRDMA_MAX_SLOT_TABLE;
> +static unsigned int min_inline_size = RPCRDMA_MIN_INLINE;
> +static unsigned int max_inline_size = RPCRDMA_MAX_INLINE;
>  static unsigned int zero;
>  static unsigned int max_padding = PAGE_SIZE;
>  static unsigned int min_memreg = RPCRDMA_BOUNCEBUFFERS;
> @@ -96,6 +98,8 @@ static struct ctl_table xr_tunables_table[] = {
>  		.maxlen		= sizeof(unsigned int),
>  		.mode		= 0644,
>  		.proc_handler	= proc_dointvec,
> +		.extra1		= &min_inline_size,
> +		.extra2		= &max_inline_size,
>  	},
>  	{
>  		.procname	= "rdma_max_inline_write",
> @@ -103,6 +107,8 @@ static struct ctl_table xr_tunables_table[] = {
>  		.maxlen		= sizeof(unsigned int),
>  		.mode		= 0644,
>  		.proc_handler	= proc_dointvec,
> +		.extra1		= &min_inline_size,
> +		.extra2		= &max_inline_size,
>  	},
>  	{
>  		.procname	= "rdma_inline_write_padding",
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

