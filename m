From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 07/24] SUNRPC:  Update RPC server's TCP record marker
	decoder
Date: Mon, 14 Apr 2008 14:49:59 -0400
Message-ID: <20080414184959.GJ15950@fieldses.org>
References: <20080414162108.12741.73233.stgit@manray.1015granger.net> <20080414162730.12741.97124.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:49673 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935001AbYDNSuS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Apr 2008 14:50:18 -0400
In-Reply-To: <20080414162730.12741.97124.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 14, 2008 at 12:27:30PM -0400, Chuck Lever wrote:
> Clean up: Update the RPC server's TCP record marker decoder to match the
> constructs used by the RPC client's TCP socket transport.

Looks good to me.

> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  include/linux/sunrpc/svcsock.h |    4 ++--
>  net/sunrpc/svcsock.c           |   24 ++++++++++++------------
>  2 files changed, 14 insertions(+), 14 deletions(-)
> 
> diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
> index 206f092..8cff696 100644
> --- a/include/linux/sunrpc/svcsock.h
> +++ b/include/linux/sunrpc/svcsock.h
> @@ -26,8 +26,8 @@ struct svc_sock {
>  	void			(*sk_owspace)(struct sock *);
>  
>  	/* private TCP part */
> -	int			sk_reclen;	/* length of record */
> -	int			sk_tcplen;	/* current read length */
> +	u32			sk_reclen;	/* length of record */
> +	u32			sk_tcplen;	/* current read length */
>  };
>  
>  /*
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index de29e7f..51357a3 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -46,6 +46,7 @@
>  #include <linux/sunrpc/types.h>
>  #include <linux/sunrpc/clnt.h>
>  #include <linux/sunrpc/xdr.h>
> +#include <linux/sunrpc/msg_prot.h>
>  #include <linux/sunrpc/svcsock.h>
>  #include <linux/sunrpc/stats.h>
>  
> @@ -829,8 +830,8 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
>  	 * the next four bytes. Otherwise try to gobble up as much as
>  	 * possible up to the complete record length.
>  	 */
> -	if (svsk->sk_tcplen < 4) {
> -		unsigned long	want = 4 - svsk->sk_tcplen;
> +	if (svsk->sk_tcplen < sizeof(rpc_fraghdr)) {
> +		int		want = sizeof(rpc_fraghdr) - svsk->sk_tcplen;
>  		struct kvec	iov;
>  
>  		iov.iov_base = ((char *) &svsk->sk_reclen) + svsk->sk_tcplen;
> @@ -840,32 +841,31 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
>  		svsk->sk_tcplen += len;
>  
>  		if (len < want) {
> -			dprintk("svc: short recvfrom while reading record length (%d of %lu)\n",
> -				len, want);
> +			dprintk("svc: short recvfrom while reading record "
> +				"length (%d of %d)\n", len, want);
>  			svc_xprt_received(&svsk->sk_xprt);
>  			return -EAGAIN; /* record header not complete */
>  		}
>  
>  		svsk->sk_reclen = ntohl(svsk->sk_reclen);
> -		if (!(svsk->sk_reclen & 0x80000000)) {
> +		if (!(svsk->sk_reclen & RPC_LAST_STREAM_FRAGMENT)) {
>  			/* FIXME: technically, a record can be fragmented,
>  			 *  and non-terminal fragments will not have the top
>  			 *  bit set in the fragment length header.
>  			 *  But apparently no known nfs clients send fragmented
>  			 *  records. */
>  			if (net_ratelimit())
> -				printk(KERN_NOTICE "RPC: bad TCP reclen 0x%08lx"
> -				       " (non-terminal)\n",
> -				       (unsigned long) svsk->sk_reclen);
> +				printk(KERN_NOTICE "RPC: multiple fragments "
> +					"per record not supported\n");

Yep, that's helpful documentation, thanks.--b.

>  			goto err_delete;
>  		}
> -		svsk->sk_reclen &= 0x7fffffff;
> +		svsk->sk_reclen &= RPC_FRAGMENT_SIZE_MASK;
>  		dprintk("svc: TCP record, %d bytes\n", svsk->sk_reclen);
>  		if (svsk->sk_reclen > serv->sv_max_mesg) {
>  			if (net_ratelimit())
> -				printk(KERN_NOTICE "RPC: bad TCP reclen 0x%08lx"
> -				       " (large)\n",
> -				       (unsigned long) svsk->sk_reclen);
> +				printk(KERN_NOTICE "RPC: "
> +					"fragment too large: 0x%08lx\n",
> +					(unsigned long)svsk->sk_reclen);
>  			goto err_delete;
>  		}
>  	}
> 
