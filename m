Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 67E60372B2B;
	Fri, 23 Jan 2026 06:26:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1769149614; cv=none; b=mrRuh4evJUnPhLcdwpz+u8nt/zVX+5DWRh44/QLf7hy4WjuqSd7YPjLyiLbjGD4T+w7zAQOxf0awbX40+Er0HmqIYuxbRH7TSIdFlRubHyCIxJ8Yxp6bm1W7jZ9TsVGxXxFFnfvZdcws8OUf8kTgSt2c3jFuqhrI+4PMUUR44xQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1769149614; c=relaxed/simple;
	bh=ha5r56NONz9VxwrkiMiirGlp/ijqyd0w2Ea6ge8gBSw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=O2X8gPjHaKeONcyiiDeS3cAe2cb4oKkDE8WDkCviLgvFQsnfEcMakJpleFJvOzEzcZ7M/3CzeISdkN8l3gv6ZajzVnpTZi0WRzMt5QtUQQZgobOI4EAf1x+CVOfyDApQAKbgtZv/n4iFhbNPCqY1eR1pD1bjLMWNRX1SZ636Zic=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 2B90E227AAE; Fri, 23 Jan 2026 07:26:43 +0100 (CET)
Date: Fri, 23 Jan 2026 07:26:43 +0100
From: Christoph Hellwig <hch@lst.de>
To: Chuck Lever <cel@kernel.org>
Cc: Jason Gunthorpe <jgg@nvidia.com>, Leon Romanovsky <leon@kernel.org>,
	Christoph Hellwig <hch@lst.de>, NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org,
	Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH v3 1/5] RDMA/core: add bio_vec based RDMA read/write API
Message-ID: <20260123062643.GA25786@lst.de>
References: <20260122220401.1143331-1-cel@kernel.org> <20260122220401.1143331-2-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260122220401.1143331-2-cel@kernel.org>
User-Agent: Mutt/1.5.17 (2007-11-01)

> +static int rdma_rw_init_map_wrs_bvec(struct rdma_rw_ctx *ctx, struct ib_qp *qp,
> +		const struct bio_vec *bvecs, u32 nr_bvec, struct bvec_iter *iter,

Overly long line here.

> +		for (j = 0; j < nr_sge; j++) {
> +			const struct bio_vec *base = __bvec_iter_bvec(bvecs, *iter);

Overly long line.

> +			unsigned int offset = iter->bi_bvec_done;
> +			unsigned int len = min(iter->bi_size,
> +					       base->bv_len - offset);
> +			struct bio_vec bv = {
> +				.bv_page = base->bv_page,
> +				.bv_len = len,
> +				.bv_offset = base->bv_offset + offset,
> +			};

Why is this open coding mp_bvec_iter_bvec?

> +static inline u64 ib_dma_map_bvec(struct ib_device *dev,
> +				  const struct bio_vec *bvec,
> +				  enum dma_data_direction direction)
> +{
> +	if (ib_uses_virt_dma(dev))
> +		return (uintptr_t)(page_address(bvec->bv_page) + bvec->bv_offset);

Overly long line here, which could be fixed by just using bvec_virt().

