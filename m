Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793712790;
	b=4/cckegL9WQ0M1JDz6Hc+P2d3PNDFWNpw3ojSX1fEbrrq+5Tdh4fHq8fO3UMEwbLiYFw
	 VtO/tzE0qC3FZnXFqbmGE+ZPLOBsXzps5WT8V/4zCQ+K3hMPlQNqyrkFn9SWBp6IU3c/h
	 dJNO9hyu2FyIunEDpjgcQ3tMHdl5O27wNhT9it6urxrJSxObny44Az6Fqjq+ggzOd1Auu
	 MaYWSSDKnOarh5vaGsphWLNojc57Jdl1/MdLb/AbGqDJTGvEa3SxxdQaYnaDxz9+X5hMK
	 IdRI2ft0Ffa6IzB9lMy0Zf3KjjyTrwZoOTwkxX+Kuq5gxSKrTLFegUaee+LP9dxymsg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793712790;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=RMRHszNpCciqBBPZUBDOV70emHMegVWchWySc/2suFw=;
	b=w0HlQsbSLh19Wd5eVIhb2SSan2STP4mVhLM/VFPS20i1XhH54aI8u7sHwwoagF50s2ZW
	 BdqJg9n3COeAwW+VDRkDkcZFsVdUgRoop81a1zw1GeFhgvZHjBObMar762yIR7kuRAd7k
	 bfN5k0ozBQSiYH6kZ5X4oDlJcEz5sZ5sx2fMDWLrqMy9PyYJOjXNUo0XyV2sOPvj28F24
	 QkhaYB8XBEV+eXMIJ0KHr009/dOB83nE+FbpYhK0w5znxNfH9LYpE0tPIDgQNHKsF9wbE
	 zgLC7XJSvDYEx7tNQgB9RbY8WKcy2rsQ5nofnhV2suqZ1LCJxdU87GOJfSObMyArdfg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=OMtvuhnv;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6932B608508C;
	Tue,  3 Nov 2026 13:33:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=OMtvuhnv
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5932E1F0093A;
	Tue,  3 Nov 2026 13:33:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793712790;
	bh=RMRHszNpCciqBBPZUBDOV70emHMegVWchWySc/2suFw=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=OMtvuhnv6GU7f2DlPAU0Ih/0W+Rv05MWsmj9kELv94tdKdWyovlQV5yZrexjgvhhp
	 nOznbw7Xan62brbddvdJE/5Cy0cOzAo5ZWmuMzrYzaqJoJpc0uBiV3nTLLBEUmM7Ea
	 /DNqO+EmZnKtxf849lXVc3OFBzCYxRYffpsov64fu6DJUSUjkTzXt9P3s/ew30xO3B
	 btMPRls3hbYJ216eoBXTwq0BNm9W2ll2WndqqYuaQWgWXeAmAylNwvPUE87aAKBE0X
	 DJzDihkJ8pVbEYvlBNjrIAkJzlLaNRzrvyDY/LlBCw2cf1zKxYNRTwJzHacBPaOxpl
	 pTad+vw2rb0AQ==
Date: Tue, 3 Nov 2026 15:28:00 +0200
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
Message-ID: <20261103132800.GI264423@unreal>
References: <20261006233248.705086-1-praan@google.com>
 <20261006233248.705086-5-praan@google.com>
 <20261012070134.GG27033@unreal>
 <auCRpd73dok7Yys7@google.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <auCRpd73dok7Yys7@google.com>

On Tue, Oct 27, 2026 at 11:57:25AM +0000, Pranjal Shrivastava wrote:
> On Mon, Oct 12, 2026 at 10:01:34AM +0300, Leon Romanovsky wrote:
> > On Tue, Oct 06, 2026 at 11:32:44PM +0000, Pranjal Shrivastava wrote:
> > > ib_dma_map_sg() returns 0 on any failure, so frwr_map() cannot tell
> > > why a mapping failed and reports -EIO. Use ib_dma_map_sgtable_attrs()
> > > instead, which returns the reason. Pass up -EREMOTEIO, which means
> > > the device cannot reach the P2PDMA memory, so the RPC fails with the
> > > same error as other P2PDMA refusals. Every other mapping failure
> > > still returns -EIO.
> > > 
> > > Signed-off-by: Pranjal Shrivastava <praan@google.com>
> > > ---
> > >  net/sunrpc/xprtrdma/frwr_ops.c | 15 ++++++++++-----
> > >  1 file changed, 10 insertions(+), 5 deletions(-)
> > > 
> > > diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
> > > index e83cef19e656..a55d5e11c0e2 100644
> > > --- a/net/sunrpc/xprtrdma/frwr_ops.c
> > > +++ b/net/sunrpc/xprtrdma/frwr_ops.c
> > > @@ -293,7 +293,8 @@ int frwr_map(struct rpcrdma_xprt *r_xprt,
> > >  	bool sg_gaps = ep->re_mrtype == IB_MR_TYPE_SG_GAPS;
> > >  	unsigned int max_depth = ep->re_max_fr_depth;
> > >  	struct ib_reg_wr *reg_wr;
> > > -	int i, n, dma_nents;
> > > +	struct sg_table sgt;
> > > +	int i, n, dma_nents, ret;
> > >  	struct ib_mr *ibmr;
> > >  	u8 key;
> > >  
> > > @@ -381,10 +382,13 @@ int frwr_map(struct rpcrdma_xprt *r_xprt,
> > >  	mr->mr_dir = rpcrdma_data_dir(writing);
> > >  	mr->mr_nents = i;
> > >  
> > > -	dma_nents = ib_dma_map_sg(ep->re_id->device, mr->mr_sg, mr->mr_nents,
> > > -				  mr->mr_dir);
> > > -	if (!dma_nents)
> > > +	/* Unlike ib_dma_map_sg(), this reports why a mapping failed */
> > > +	sgt.sgl = mr->mr_sg;
> > > +	sgt.orig_nents = mr->mr_nents;
> > > +	ret = ib_dma_map_sgtable_attrs(ep->re_id->device, &sgt, mr->mr_dir, 0);
> > 
> > Please avoid using this function. We are gradually moving away from SG tables
> > in the RDMA code.
> > 
> > In general, it is never good thing to built API around try-and-fail
> > approach. It will require from us to be aware of "specific" usage for
> > the return value from one subsystem by another.
> > 
> 
> Fair, I'll drop ib_dma_map_sgtable_attrs(), keep ib_dma_map_sg() as it 
> is today, and check reachability explicitly before mapping instead.
> 
> rpcrdma_p2pdma_allowed() already asks ib_dma_pci_p2p_dma_supported()
> whether the device can do P2PDMA at all. It would also run
> pci_p2pdma_state() against the device's dma_device for the payload
> pages, and refuse the RPC with -EREMOTEIO on
> PCI_P2PDMA_MAP_NOT_SUPPORTED. A mapping failure then stays a plain
> -EIO, and nothing depends on the DMA layer's return value.
> 
> xprtrdma can be built as a module, though, and pci_p2pdma_state() is
> an inline wrapper around __pci_p2pdma_update_state(), which isn't
> exported. I see two ways to handle that: export
> __pci_p2pdma_update_state() as is, or add a small exported helper in
> p2pdma.c that returns the map type for a page and a device, e.g.
> pci_p2pdma_page_map_type(). Which would you prefer?

This isn't my decision to make, but my understanding is that these functions
should not be exported. They are intended for use by subsystem core code,
which should export the processed results to its local callers.

Thanks

> 
> Thanks,
> Praan
> 
