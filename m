Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-fw-4101.amazon.com ([72.21.198.25]:49001 "EHLO
        smtp-fw-4101.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752419AbeEJVSh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 10 May 2018 17:18:37 -0400
Date: Thu, 10 May 2018 21:18:32 +0000
From: Vallish Vaidyeshwara <vallish@amazon.com>
To: <trond.myklebust@primarydata.com>, <anna.schumaker@netapp.com>,
        <jlayton@kernel.org>, <bfields@fieldses.org>,
        <linux-nfs@vger.kernel.org>
CC: <jsstraus@amazon.com>
Subject: Re: [PATCH 1/2] SUNRPC: Need to reuse non-reserved port for reconnect
Message-ID: <20180510211832.GC50901@amazon.com>
References: <1525932774-98736-1-git-send-email-vallish@amazon.com>
 <1525932774-98736-2-git-send-email-vallish@amazon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
In-Reply-To: <1525932774-98736-2-git-send-email-vallish@amazon.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 10, 2018 at 06:12:53AM +0000, Vallish Vaidyeshwara wrote:
> Seemingly innocent optimization related to xs_bind() broke TCP port
> reuse by making non-reserved ephermal socket port to not be saved
> in "struct sock_xprt (srcport)". In case of non-reserved port,
> allocation happens as part of kernel_connect() inside of
> xs_tcp_finish_connecting(). kernel_connect() returns EINPROGRESS
> and the code skips stashing srcport in sock_xprt for reconnects.
> This affects servers DRC in case of network partition where client's
> RPC recovery would try reconnecting with a different port.
> 
> Reported-by: Alexey Kuznetsov <alexeyk@amazon.com>
> Reviewed-by: Jacob Strauss <jsstraus@amazon.com>
> Reviewed-by: Alakesh Haloi <alakeshh@amazon.com>
> Signed-off-by: Vallish Vaidyeshwara <vallish@amazon.com>
> Fixes: 0f7a622c ("rpc: xs_bind - do not bind when requesting a random ephemeral port")
> ---
>  net/sunrpc/xprtsock.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index c8902f1..5bf75b3 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -2393,9 +2393,11 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
>  	ret = kernel_connect(sock, xs_addr(xprt), xprt->addrlen, O_NONBLOCK);
>  	switch (ret) {
>  	case 0:
> -		xs_set_srcport(transport, sock);
>  		/* fall through */
>  	case -EINPROGRESS:
> +		/* Allocated port saved for reconnect */
> +		xs_set_srcport(transport, sock);
> +
>  		/* SYN_SENT! */
>  		if (xprt->reestablish_timeout < XS_TCP_INIT_REEST_TO)
>  			xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
> -- 
> 2.7.3.AMZN
>

Hello Trond and Bruce,

This patch is actually restoring existing broken DRC behavior. Can you folks
let me know your feedback on this patch as well.

Thanks.
-Vallish
