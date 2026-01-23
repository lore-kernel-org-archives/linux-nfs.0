Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9AAE8396D0D;
	Fri, 23 Jan 2026 06:28:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1769149732; cv=none; b=buWmaR60wTTnkGU0jYjdvyD9gJlHp7tYf4KY00F7RNguo2DKBSTvHwPltT6FXZX+HqlNbqne7q4/XhJzl9NQuYpColMurCcIynM8q8z7M2Km8tYGmZ6HbiRyNqDBBCcAPZ+rreFrm3FsU8HA9/l2s0aRAubyat4ijzfKvY0W7Vo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1769149732; c=relaxed/simple;
	bh=OIG2nCIeWyTdRMrHZpwAE2vDjz51LVQLo7BGgjDROj0=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=XDUELfpUCumhFljw3Z8hmx4J3aeTDMnYabPCQyXL84ieMF2IjME888HD8pabzcG/s8kE37sR9QD0OVUytoZovCz0DZYID0FhduIJsUChNC4I3/nwWMvtbKhFp46paeu5RBP3uYXMHD+6U+PQMDse60twXU9KnnFje5yfPohEzIU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 10703227AAE; Fri, 23 Jan 2026 07:28:45 +0100 (CET)
Date: Fri, 23 Jan 2026 07:28:44 +0100
From: Christoph Hellwig <hch@lst.de>
To: Chuck Lever <cel@kernel.org>
Cc: Jason Gunthorpe <jgg@nvidia.com>, Leon Romanovsky <leon@kernel.org>,
	Christoph Hellwig <hch@lst.de>, NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org,
	Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH v3 2/5] RDMA/core: use IOVA-based DMA mapping for bvec
 RDMA operations
Message-ID: <20260123062844.GB25786@lst.de>
References: <20260122220401.1143331-1-cel@kernel.org> <20260122220401.1143331-3-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260122220401.1143331-3-cel@kernel.org>
User-Agent: Mutt/1.5.17 (2007-11-01)

> +	/* Link all bvecs into the IOVA space */
> +	link_iter = *iter;
> +	while (link_iter.bi_size) {
> +		struct bio_vec bv = mp_bvec_iter_bvec(bvec, link_iter);
> +
> +		ret = dma_iova_link(dma_dev, &ctx->iova.state, bvec_phys(&bv),
> +				    mapped_len, bv.bv_len, dir, 0);
> +		if (ret)
> +			goto out_destroy;
> +
> +		mapped_len += bv.bv_len;
> +		bvec_iter_advance(bvec, &link_iter, bv.bv_len);
> +	}

Why is this using a local link_iter?  We're not using iter later.

