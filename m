Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtpa12-03.prod.phx3.secureserver.net ([68.178.252.232]:35259
	"EHLO p3plsmtpa12-03.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753810AbbLANiW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Dec 2015 08:38:22 -0500
Subject: Re: [PATCH v2 6/7] xprtrdma: Add class for RDMA backwards direction
 transport
To: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
References: <20151130222141.13029.98664.stgit@klimt.1015granger.net>
 <20151130222513.13029.52447.stgit@klimt.1015granger.net>
From: Tom Talpey <tom@talpey.com>
Message-ID: <565DA2CA.5090507@talpey.com>
Date: Tue, 1 Dec 2015 08:38:18 -0500
MIME-Version: 1.0
In-Reply-To: <20151130222513.13029.52447.stgit@klimt.1015granger.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/30/2015 5:25 PM, Chuck Lever wrote:
> To support the server-side of an NFSv4.1 backchannel on RDMA
> connections, add a transport class that enables backward
> direction messages on an existing forward channel connection.
>

> +static void *
> +xprt_rdma_bc_allocate(struct rpc_task *task, size_t size)
> +{
> +	struct rpc_rqst *rqst = task->tk_rqstp;
> +	struct svc_rdma_op_ctxt *ctxt;
> +	struct svcxprt_rdma *rdma;
> +	struct svc_xprt *sxprt;
> +	struct page *page;
> +
> +	if (size > PAGE_SIZE) {
> +		WARN_ONCE(1, "failed to handle buffer allocation (size %zu)\n",
> +			  size);

You may want to add more context to that rather cryptic string, at
least the function name.

Also, it's not exactly "failed to handle", it's an invalid size. Why
would this ever happen? Why even log it?



> +static int
> +rpcrdma_bc_send_request(struct svcxprt_rdma *rdma, struct rpc_rqst *rqst)
> +{
...
> +
> +drop_connection:
> +	dprintk("Failed to send backchannel call\n");

Ditto on the prefix / function context.

And also...

> +	dprintk("%s: sending request with xid: %08x\n",
> +		__func__, be32_to_cpu(rqst->rq_xid));
...
> +	dprintk("RPC:       %s: xprt %p\n", __func__, xprt);

The format strings for many of the dprintk's are somewhat inconsistent.
Some start with "RPC", some with the function name, and some (in other
patches of this series) with "svcrdma". Confusing, and perhaps hard to
pick out of the log.


