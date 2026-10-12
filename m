Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8405B43CE58;
	Mon, 12 Oct 2026 07:01:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791788499; cv=none; b=ilqnVm0xunUjEUNTg0/EtZsAGGXFbFdfdbj6U+dGKKWn3vHPE75Z+nqy9jbPOzUkLMUVbIKxjjGSCz1LdWZd6O7qJfcqK1dDhASU5d/dbgcp4GZIbrt/5E84sswWyg5ZBrB+2aB0fDzXVTJcsHp+l2kEQOWUPe7l1+4Jt3Dhsnc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791788499; c=relaxed/simple;
	bh=IsS6jlUXPTT9+nYDkYwSXZcw9krz7B74BVT1GYVLKe8=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=G7Gsr3MC9VaF7ZWVx/eUuKViUI4Hslhj72z+Zj1gWC8nowcqKnQ1rPiH+oPIbm7y7nOcYRAq0yb6EX7Mo8CJRajvRKsiKY+QIOWWeyjRc2GIDQy07C07R6GRtOk7tOjdg9D6zR7SGpZIlDan0VzdaYhj118Aia8Nf/9bBCXxJdE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=dYBvsSPp; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="dYBvsSPp"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B7AB31F0089B;
	Mon, 12 Oct 2026 07:01:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791788498;
	bh=GFhdpnnhNHq8kto2NtVcBzP+4OYlv8T7WrOl9X3C8NE=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=dYBvsSPpPy0rtJQbOBva6kehr5wr02bZg7sxUnjFGXUcRAc32MyIzZN45t1AlPjXv
	 XD9k3E1VS8lDMeRnwmLpY+OlJ8lBsu0kv8TS060NFRJkTdR1gjuyXUzWUGvS+X5FqY
	 2dE3U2+XMWlLnLe9No1jPEDKg6jBjzAB/SNDqn9L6BSQYYzUYg+rerO+YAp3JCNJEs
	 V1oxiwYnstkJYO/d/IcUehoZFpkW5i/5xVESLs0c2cOGWTf9XZSqrGjMSDkYvEToBY
	 1CWsp403rjOJlujTQ3E3tnAfGUBfioFhKXtElwTO180JkktFz5YRVCPrROgLUVtl92
	 0EeW9fV4TYM9w==
Date: Mon, 12 Oct 2026 10:01:34 +0300
From: Leon Romanovsky <leon@kernel.org>
To: Pranjal Shrivastava <praan@google.com>
Cc: linux-nfs@vger.kernel.org, Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>, Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>, linux-kernel@vger.kernel.org,
	Christoph Hellwig <hch@lst.de>,
	Logan Gunthorpe <logang@deltatee.com>,
	Jason Gunthorpe <jgg@ziepe.ca>, linux-pci@vger.kernel.org,
	linux-rdma@vger.kernel.org, Shivaji Kant <shivajikant@google.com>,
	Tom Talpey <tom@talpey.com>,
	Unnati Sachan <unnatisachan@google.com>
Subject: Re: [RFC PATCH v1 4/8] xprtrdma: return -EREMOTEIO on P2PDMA map
 failure
Message-ID: <20261012070134.GG27033@unreal>
References: <20261006233248.705086-1-praan@google.com>
 <20261006233248.705086-5-praan@google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20261006233248.705086-5-praan@google.com>

On Tue, Oct 06, 2026 at 11:32:44PM +0000, Pranjal Shrivastava wrote:
> ib_dma_map_sg() returns 0 on any failure, so frwr_map() cannot tell
> why a mapping failed and reports -EIO. Use ib_dma_map_sgtable_attrs()
> instead, which returns the reason. Pass up -EREMOTEIO, which means
> the device cannot reach the P2PDMA memory, so the RPC fails with the
> same error as other P2PDMA refusals. Every other mapping failure
> still returns -EIO.
> 
> Signed-off-by: Pranjal Shrivastava <praan@google.com>
> ---
>  net/sunrpc/xprtrdma/frwr_ops.c | 15 ++++++++++-----
>  1 file changed, 10 insertions(+), 5 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
> index e83cef19e656..a55d5e11c0e2 100644
> --- a/net/sunrpc/xprtrdma/frwr_ops.c
> +++ b/net/sunrpc/xprtrdma/frwr_ops.c
> @@ -293,7 +293,8 @@ int frwr_map(struct rpcrdma_xprt *r_xprt,
>  	bool sg_gaps = ep->re_mrtype == IB_MR_TYPE_SG_GAPS;
>  	unsigned int max_depth = ep->re_max_fr_depth;
>  	struct ib_reg_wr *reg_wr;
> -	int i, n, dma_nents;
> +	struct sg_table sgt;
> +	int i, n, dma_nents, ret;
>  	struct ib_mr *ibmr;
>  	u8 key;
>  
> @@ -381,10 +382,13 @@ int frwr_map(struct rpcrdma_xprt *r_xprt,
>  	mr->mr_dir = rpcrdma_data_dir(writing);
>  	mr->mr_nents = i;
>  
> -	dma_nents = ib_dma_map_sg(ep->re_id->device, mr->mr_sg, mr->mr_nents,
> -				  mr->mr_dir);
> -	if (!dma_nents)
> +	/* Unlike ib_dma_map_sg(), this reports why a mapping failed */
> +	sgt.sgl = mr->mr_sg;
> +	sgt.orig_nents = mr->mr_nents;
> +	ret = ib_dma_map_sgtable_attrs(ep->re_id->device, &sgt, mr->mr_dir, 0);

Please avoid using this function. We are gradually moving away from SG tables
in the RDMA code.

In general, it is never good thing to built API around try-and-fail
approach. It will require from us to be aware of "specific" usage for
the return value from one subsystem by another.

Thanks
