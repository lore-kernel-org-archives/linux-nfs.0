Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.214.174
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793102254;
	b=q8Gq1f1LqtV5KWW8yBm+NKvj8V/vgFM/RFOBIVLU73ItvWSz7lTjzJDAwB37KuFm41eT
	 bHJHOmq5jjMspqQAFC95KvTh5l/GfoTTWELAIAUT9Yygn6s7XhikYU7Dgq75OCG/z7jEP
	 89Ftb+HaJxjdy6fip+2ixErNlgevGmXYHHW6DHEbt32aDw4pWBb7nnt61JUpWYvX39ZWo
	 OeoYmJ6tuc5HTiHAB8ToQ0BLhyLcb+ye0mNUdXGegNAAkxD0MyHK7YM8ZIjGQOY6r3AWl
	 lgHn1mRnvgOmoAEwMxN4PxUmxvZ/u93Mme48o10k23SlN5GnewLfkK44znql2NGYeZw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793102254;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:Date:From:To:Cc:
	 Subject:Message-ID:References:MIME-Version:Content-Type:
	 Content-Disposition:In-Reply-To;
	bh=U88qweYnCYrU71r8T0Ehm+T7NZ7CYd13glJQesIl94g=;
	b=2u7MJp3dgsmER/r5+Xt9HYii9sR+tbMUuZBlooECfLnuOE58elsgGdycovajLFNsxyHQ
	 s/4sRmItkqSSlFnERKQ/TY+43+nP5Odj9PY/wSPbDzXKylGMvrvLqE3HT3Hw1xQ3tXJic
	 slDnDC7TLRDSI7h9B2ufpLMjHUITe1k1anGiilG3US+tuUQuQDy/599A5RTUj4noE/4CQ
	 Vd+q+4Yf0FHPSVCvG2X8k5rtg5i9rok+LIlbzWueP8AaJIqJ/XCSmOUnmfvK/Ay7qx0fO
	 i/fSIHz4ppeTZn3yUhV+qSPQjrH7cwZVl9dEWSU1oXn6DcmsV4KFkh6G8QxGsJKP2hQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=google.com;
	spf=pass smtp.mailfrom=google.com;
	dkim=pass header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20251104 header.b=MWn5tv2T;
	arc=none smtp.remote-ip=209.85.214.174
Received: from mail-pl1-f174.google.com (mail-pl1-f174.google.com [209.85.214.174])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9BE70606A31D
	for <linux-nfs@vger.kernel.org>; Tue, 27 Oct 2026 11:57:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 9BE70606A31D
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20251104 header.b=MWn5tv2T
Received: by mail-pl1-f174.google.com with SMTP id d9443c01a7336-2ea7f9c11e6so52765ad.0
        for <linux-nfs@vger.kernel.org>; Tue, 27 Oct 2026 04:57:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20251104; t=1793102253; x=1793707053; darn=vger.kernel.org;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=U88qweYnCYrU71r8T0Ehm+T7NZ7CYd13glJQesIl94g=;
        b=MWn5tv2T6nORDeJlQMGcbmz+uBELnLCHME98VH01oxejJGbCyGKqQvoYP7SB7tNzfD
         fM4lpxigjR4nEWb1/NfNxyRTHKIZxjM1brk43cS15K37TfS0M/0TtT8OVt2e89FNfSSX
         eFBXqk2qG8sUrc9fZejphgPPjd28UAjshJjh77JTbgNUuodEUxyOPogHGFzQCTkUEGXi
         ZFIJ1BdAI0mp8oz39hADY8jXtwzx4I1GjJek5MAhLC9sbrr22nx+2UnNndl4rJRyIPtQ
         tKu3VdgEgnf/C6kPIuhNkEVZYiT7zhQ0v8l78a+igWsJLKXYfGFRUltlbMJoh2Pj7wGQ
         QRGg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793102253; x=1793707053;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=U88qweYnCYrU71r8T0Ehm+T7NZ7CYd13glJQesIl94g=;
        b=UVCzyxvizAhr5gW/FbCjOrdXnq/s6bFaLUgEqN/t8jECnkWKCCN5cmMm0fGfvsZuy2
         JtS2F2QNn09EhyR9BU61zIWMGx8cBwCr4co+8XsU4wprKsV1HUhx+i5mJtmbTA4eELfh
         z7ZsmMQMcxbnebq1n01wpFuz+srRigT3Ap8IH3rwwCdq+WiRZR0BjKGa7bdFWU0GWqfG
         ayP+4q4rEsX/9R6qedKf05NO11nBlKhroznqNsJw5Bd7rUhC1YERzjcAdmdBVYYisspP
         fE4yj75r/RYkdarUJZzm+VYsdjg/4R29V1uu1IyfgbwKZq/vnPEf5ELpD3GhR/DRs0Yx
         5GGw==
X-Gm-Message-State: AFq9FYJAS7YLZbEU+WJnpjyEYZ6XAKxlsfVCvhiZOJ6JEIzlLavxI0Dc
	gUgktuamDtvvnwSY5/QVxm0TbuxI/iUOV7E+u5d+tv4HXYNA6AzBejl1qFuYAZTEaw==
X-Gm-Gg: AYBFou31IdREssUB6pT0i1T6PkIPVkK8HLLCMltVQkNSe98BbgPgC02Vx3hm5Kga4Mc
	h6eVPSHuqyA9YQ6kXmgydRUAZsuD3XhDKhgXQ7c8JR+jaTvpyY/iSB1HCohTbL22aP0oLx2x2U5
	TRTeqmleCR7ral9qY5zrCKOplsiMP6+qIG4KPArDnIdF/ZiKTVBwrrE9z7FaQ0kJQywU2f59pDj
	1tau2Q9dvO9LartE8FaQmtHRZsrFqHWRw+KElNfRmRIz+5PAmlyha3AT1Goy71T652ELLwQDhxT
	UODeoyo5sRd4B5cAktvm5Utx1ejapV8g87ZpgE6/2Ghsik+8/9q7szKA1n8AsL5Vm6mPtry7SgF
	Tq+PWnE4TJXRlgcRM9Y3IliudnsmWya/C8NOJ8wroR+WLJQ+2vgafQN5b/8f4rnwAxuRsjEfo/4
	o7BpzCM8Lir/ropVhMHFKSVPFP6uwwN+X10jWsIwgVkN7nY9jyfWrMAB+aUPU7a6jaIyltbUEsR
	d8KEFc3biKcobRL/3yARPm94XBkXIQyPh09cIcS9NUiIAP4Xyo++yht/TwtjPPjeAuGMQ+Arg06
	jZl/FLO358W7W5pHYdOfIjgStybTw0G8M7ybh0E=
X-Received: by 2002:a17:902:fc87:b0:2ea:1fa0:8068 with SMTP id d9443c01a7336-2eae7be30b6mr4320395ad.16.1793102252395;
        Tue, 27 Oct 2026 04:57:32 -0700 (PDT)
Received: from google.com (105.211.142.34.bc.googleusercontent.com. [34.142.211.105])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-3ae4064f4bdsm3633646a91.11.2026.10.27.04.57.28
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 27 Oct 2026 04:57:31 -0700 (PDT)
Date: Tue, 27 Oct 2026 11:57:25 +0000
From: Pranjal Shrivastava <praan@google.com>
To: Leon Romanovsky <leon@kernel.org>
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
Message-ID: <auCRpd73dok7Yys7@google.com>
References: <20261006233248.705086-1-praan@google.com>
 <20261006233248.705086-5-praan@google.com>
 <20261012070134.GG27033@unreal>
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
In-Reply-To: <20261012070134.GG27033@unreal>

On Mon, Oct 12, 2026 at 10:01:34AM +0300, Leon Romanovsky wrote:
> On Tue, Oct 06, 2026 at 11:32:44PM +0000, Pranjal Shrivastava wrote:
> > ib_dma_map_sg() returns 0 on any failure, so frwr_map() cannot tell
> > why a mapping failed and reports -EIO. Use ib_dma_map_sgtable_attrs()
> > instead, which returns the reason. Pass up -EREMOTEIO, which means
> > the device cannot reach the P2PDMA memory, so the RPC fails with the
> > same error as other P2PDMA refusals. Every other mapping failure
> > still returns -EIO.
> > 
> > Signed-off-by: Pranjal Shrivastava <praan@google.com>
> > ---
> >  net/sunrpc/xprtrdma/frwr_ops.c | 15 ++++++++++-----
> >  1 file changed, 10 insertions(+), 5 deletions(-)
> > 
> > diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
> > index e83cef19e656..a55d5e11c0e2 100644
> > --- a/net/sunrpc/xprtrdma/frwr_ops.c
> > +++ b/net/sunrpc/xprtrdma/frwr_ops.c
> > @@ -293,7 +293,8 @@ int frwr_map(struct rpcrdma_xprt *r_xprt,
> >  	bool sg_gaps = ep->re_mrtype == IB_MR_TYPE_SG_GAPS;
> >  	unsigned int max_depth = ep->re_max_fr_depth;
> >  	struct ib_reg_wr *reg_wr;
> > -	int i, n, dma_nents;
> > +	struct sg_table sgt;
> > +	int i, n, dma_nents, ret;
> >  	struct ib_mr *ibmr;
> >  	u8 key;
> >  
> > @@ -381,10 +382,13 @@ int frwr_map(struct rpcrdma_xprt *r_xprt,
> >  	mr->mr_dir = rpcrdma_data_dir(writing);
> >  	mr->mr_nents = i;
> >  
> > -	dma_nents = ib_dma_map_sg(ep->re_id->device, mr->mr_sg, mr->mr_nents,
> > -				  mr->mr_dir);
> > -	if (!dma_nents)
> > +	/* Unlike ib_dma_map_sg(), this reports why a mapping failed */
> > +	sgt.sgl = mr->mr_sg;
> > +	sgt.orig_nents = mr->mr_nents;
> > +	ret = ib_dma_map_sgtable_attrs(ep->re_id->device, &sgt, mr->mr_dir, 0);
> 
> Please avoid using this function. We are gradually moving away from SG tables
> in the RDMA code.
> 
> In general, it is never good thing to built API around try-and-fail
> approach. It will require from us to be aware of "specific" usage for
> the return value from one subsystem by another.
> 

Fair, I'll drop ib_dma_map_sgtable_attrs(), keep ib_dma_map_sg() as it 
is today, and check reachability explicitly before mapping instead.

rpcrdma_p2pdma_allowed() already asks ib_dma_pci_p2p_dma_supported()
whether the device can do P2PDMA at all. It would also run
pci_p2pdma_state() against the device's dma_device for the payload
pages, and refuse the RPC with -EREMOTEIO on
PCI_P2PDMA_MAP_NOT_SUPPORTED. A mapping failure then stays a plain
-EIO, and nothing depends on the DMA layer's return value.

xprtrdma can be built as a module, though, and pci_p2pdma_state() is
an inline wrapper around __pci_p2pdma_update_state(), which isn't
exported. I see two ways to handle that: export
__pci_p2pdma_update_state() as is, or add a small exported helper in
p2pdma.c that returns the map type for a page and a device, e.g.
pci_p2pdma_page_map_type(). Which would you prefer?

Thanks,
Praan
