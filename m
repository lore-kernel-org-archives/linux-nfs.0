Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:26841 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752468AbaJTN13 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Oct 2014 09:27:29 -0400
Message-ID: <54450DBE.6020604@Netapp.com>
Date: Mon, 20 Oct 2014 09:27:26 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 02/16] xprtrdma: Cap req_cqinit
References: <20141016192919.13414.3151.stgit@manet.1015granger.net> <20141016193829.13414.57075.stgit@manet.1015granger.net>
In-Reply-To: <20141016193829.13414.57075.stgit@manet.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Chuck,

On 10/16/14 15:38, Chuck Lever wrote:
> Recent work made FRMR registration and invalidation completions
> unsignaled. This greatly reduces the adapter interrupt rate.
>
> Every so often, however, a posted send Work Request is allowed to
> signal. Otherwise, the provider's Work Queue will wrap and the
> workload will hang.
>
> The number of Work Requests that are allowed to remain unsignaled is
> determined by the value of req_cqinit. Currently, this is set to the
> size of the send Work Queue divided by two, minus 1.
>
> For FRMR, the send Work Queue is the maximum number of concurrent
> RPCs (currently 32) times the maximum number of Work Requests an
> RPC might use (currently 7, though some adapters may need more).
>
> For mlx4, this is 224 entries. This leaves completion signaling
> disabled for 111 send Work Requests.
>
> Some providers hold back dispatching Work Requests until a CQE is
> generated.  If completions are disabled, then no CQEs are generated
> for quite some time, and that can stall the Work Queue.
>
> I've seen this occur running xfstests generic/113 over NFSv4, where
> eventually, posting a FAST_REG_MR Work Request fails with -ENOMEM
> because the Work Queue has overflowed. The connection is dropped
> and re-established.
>
> Cap the rep_cqinit setting so completions are not left turned off
> for too long.
>
> BugLink: https://bugzilla.linux-nfs.org/show_bug.cgi?id=269
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  net/sunrpc/xprtrdma/verbs.c |    2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index 6ea2942..5c0c7a5 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -733,6 +733,8 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
>  
>  	/* set trigger for requesting send completion */
>  	ep->rep_cqinit = ep->rep_attr.cap.max_send_wr/2 - 1;
> +	if (ep->rep_cqinit > 20)
> +		ep->rep_cqinit = 20;
>  	if (ep->rep_cqinit <= 2)

Can you change the ep->rep_cqinit <= 2 check into an else-if?

Thanks!
Anna

>  		ep->rep_cqinit = 0;
>  	INIT_CQCOUNT(ep);
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

