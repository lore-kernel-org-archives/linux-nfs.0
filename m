From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH  1/3] svcrdma: Remove redunant call to xpo_release_rqst
	method.
Date: Tue, 6 May 2008 17:59:40 -0400
Message-ID: <20080506215940.GQ13484@fieldses.org>
References: <12097450861136-git-send-email-tom@opengridcomputing.com> <12097450861293-git-send-email-tom@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:46806 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753492AbYEFV7m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 May 2008 17:59:42 -0400
In-Reply-To: <12097450861293-git-send-email-tom@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 02, 2008 at 11:18:04AM -0500, Tom Tucker wrote:
> The xpo_release_rqst method is called from svc_xprt_release and therefore
> this direct call of the provider method is redundant. There is no bug
> here since the provider protects against multiple calls.
> 
> Originally, this code was here because the xpo_release_rqst function was
> being used by the RDMA transport to return credits to the client, i.e.
> posting a receive buffer. This had to be done before the send in order to
> avoid a race wherein the client responds immediately with a new request
> but the buffer has not yet been posted. This is a poor design point and
> the recv buffer posting has been modified in the rdma transport.

The comment there refers to the socket code, not the rdma code, and
there was a svc_release_skb() there before the rdma code came along.
I'd like to understand why.

--b.

> 
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> 
> ---
>  net/sunrpc/svc_xprt.c |    3 ---
>  1 files changed, 0 insertions(+), 3 deletions(-)
> 
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index d8e8d79..74e52d4 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -751,9 +751,6 @@ int svc_send(struct svc_rqst *rqstp)
>  	if (!xprt)
>  		return -EFAULT;
>  
> -	/* release the receive skb before sending the reply */
> -	rqstp->rq_xprt->xpt_ops->xpo_release_rqst(rqstp);
> -
>  	/* calculate over-all length */
>  	xb = &rqstp->rq_res;
>  	xb->len = xb->head[0].iov_len +
