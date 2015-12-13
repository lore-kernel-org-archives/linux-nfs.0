Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtpa12-05.prod.phx3.secureserver.net ([68.178.252.234]:44954
	"EHLO p3plsmtpa12-05.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751297AbbLMDYQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 12 Dec 2015 22:24:16 -0500
Subject: Re: [PATCH v3 5/6] svcrdma: Add infrastructure to receive backwards
 direction RPC/RDMA replies
To: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
References: <20151207203851.12988.97804.stgit@klimt.1015granger.net>
 <20151207204305.12988.2749.stgit@klimt.1015granger.net>
From: Tom Talpey <tom@talpey.com>
Message-ID: <566CE4E7.9050307@talpey.com>
Date: Sat, 12 Dec 2015 19:24:23 -0800
MIME-Version: 1.0
In-Reply-To: <20151207204305.12988.2749.stgit@klimt.1015granger.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Three comments.

On 12/7/2015 12:43 PM, Chuck Lever wrote:
> To support the NFSv4.1 backchannel on RDMA connections, add a
> capability for receiving an RPC/RDMA reply on a connection
> established by a client.
> (snip)

> +/* By convention, backchannel calls arrive via rdma_msg type

"By convention" is ok, but it's important to note that this is
actually not "by protocol". Therefore, the following check may
reject valid messages. Even though it is unlikely an implementation
will insert chunks, it's not illegal, and ignoring them will
be less harmful. So I'm going to remake my earlier observation
that three checks below should be removed:

> + * messages, and never populate the chunk lists. This makes
> + * the RPC/RDMA header small and fixed in size, so it is
> + * straightforward to check the RPC header's direction field.
> + */
> +static bool
> +svc_rdma_is_backchannel_reply(struct svc_xprt *xprt, struct rpcrdma_msg *rmsgp)
> +{
> +	__be32 *p = (__be32 *)rmsgp;
> +
> +	if (!xprt->xpt_bc_xprt)
> +		return false;
> +
> +	if (rmsgp->rm_type != rdma_msg)
> +		return false;

These three:

> +	if (rmsgp->rm_body.rm_chunks[0] != xdr_zero)
> +		return false;
> +	if (rmsgp->rm_body.rm_chunks[1] != xdr_zero)
> +		return false;
> +	if (rmsgp->rm_body.rm_chunks[2] != xdr_zero)
> +		return false;
> +

(snip)
> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
> index a1fd74a..3895574 100644
> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
> @@ -309,6 +309,8 @@ struct rpcrdma_buffer {
>   	u32			rb_bc_srv_max_requests;
>   	spinlock_t		rb_reqslock;	/* protect rb_allreqs */
>   	struct list_head	rb_allreqs;
> +
> +	u32			rb_bc_max_requests;

Why does this need to be u32? Shouldn't it be an int, and also the
rb_bc_srv_max_requests just above? The forward channel max_requests
are int, btw.

Tom.
