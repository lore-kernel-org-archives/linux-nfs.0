From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] xprtsock.c: make bc_{malloc/free} static
Date: Thu, 14 Jan 2010 17:42:36 -0500
Message-ID: <1263508956.2724.1.camel@localhost>
References: <201001141538.31496.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, linux-nfs@vger.kernel.org,
	bfields@fieldses.org, neilb@suse.de, davem@davemloft.net
To: H Hartley Sweeten <hartleys-3FF4nKcrg1dE2c76skzGb0EOCMrvLtNR@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:45125 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756144Ab0ANWmm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Jan 2010 17:42:42 -0500
In-Reply-To: <201001141538.31496.hartleys-3FF4nKcrg1dE2c76skzGb0EOCMrvLtNR@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2010-01-14 at 15:38 -0700, H Hartley Sweeten wrote: 
> xprtsock.c: make bc_{malloc/free} static
> 
> The server backchannel buf_alloc and buf_free methods should
> be static since they are not used outside this file.
> 
> Signed-off-by: H Hartley Sweeten <hsweeten-3FF4nKcrg1dE2c76skzGb0EOCMrvLtNR@public.gmane.org>
> Cc: J. Bruce Fields <bfields@fieldses.org>
> Cc: Neil Brown <neilb@suse.de>
> Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: David S. Miller <davem@davemloft.net>
> 
> ---
> 
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 3d739e5..721bafd 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -2100,7 +2100,7 @@ static void xs_tcp_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
>   * we allocate pages instead doing a kmalloc like rpc_malloc is because we want
>   * to use the server side send routines.
>   */
> -void *bc_malloc(struct rpc_task *task, size_t size)
> +static void *bc_malloc(struct rpc_task *task, size_t size)
>  {
>  	struct page *page;
>  	struct rpc_buffer *buf;
> @@ -2120,7 +2120,7 @@ void *bc_malloc(struct rpc_task *task, size_t size)
>  /*
>   * Free the space allocated in the bc_alloc routine
>   */
> -void bc_free(void *buffer)
> +static void bc_free(void *buffer)
>  {
>  	struct rpc_buffer *buf;
>  

Thanks! I'll put this in the sunrpc-for-next branch.

Trond

