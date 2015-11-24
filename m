Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:60671 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752410AbbKXGzX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Nov 2015 01:55:23 -0500
Date: Mon, 23 Nov 2015 22:55:22 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 3/8] svcrdma: Add svc_rdma_get_context() API that is
 allowed to fail
Message-ID: <20151124065522.GC29141@infradead.org>
References: <20151123221738.13040.26277.stgit@klimt.1015granger.net>
 <20151123222038.13040.61285.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151123222038.13040.61285.stgit@klimt.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> +struct svc_rdma_op_ctxt *svc_rdma_get_context_gfp(struct svcxprt_rdma *xprt,
> +						  gfp_t flags)
> +{
> +	struct svc_rdma_op_ctxt *ctxt;
> +
> +	ctxt = kmem_cache_alloc(svc_rdma_ctxt_cachep, flags);
> +	if (!ctxt)
> +		return NULL;
> +	svc_rdma_init_context(xprt, ctxt);
> +	return ctxt;
> +}
> +
> +struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *xprt)
> +{
> +	struct svc_rdma_op_ctxt *ctxt;
> +
> +	ctxt = kmem_cache_alloc(svc_rdma_ctxt_cachep,
> +				GFP_KERNEL | __GFP_NOFAIL);
> +	svc_rdma_init_context(xprt, ctxt);
>  	return ctxt;

Sounds like you should have just added a gfp_t argument to
svc_rdma_get_context.  And if we have any way to avoid the __GFP_NOFAIL
I'd really appreciate if we could give that a try.
