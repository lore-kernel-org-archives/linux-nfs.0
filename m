Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3FE4F27703E;
	Wed, 21 Jan 2026 08:56:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1768985807; cv=none; b=MEkELRSQuTTIFSKIln9/EOGvI/i+4ATLIQeNQolohd+aCntioqQcsFb2+fe5VIHXTGjCFTMFAqvL9v+gwMeg/5GTIQIsbamt9HmAihpFCInYF8du4MtNRZaJg4GDWf25JVSSHQxlC8gIDJqPUPNEA6bmnwQxzYuwqKsOdjO2naI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1768985807; c=relaxed/simple;
	bh=0nv5N9g9vUx4FpLhuLXuurHercBPnEbBKRE68OpdTJ8=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=qXuO+3ChX705Wa7J7FppZoQTvcxM0mxmOWMFb80rJ0CRFWeyfnQoB6r6rZQbaQ9rqqfwawZtwM4zXkRWilZwNqweGvywf3RTwlpLqY43KHBMH9lfMhuEjvqYn2z1SQ8q9CVzzvqeRK6cWTCEbE2DBr1X+reI5tU74I1YnWrdsGw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id B1D9A227AAC; Wed, 21 Jan 2026 09:56:41 +0100 (CET)
Date: Wed, 21 Jan 2026 09:56:41 +0100
From: Christoph Hellwig <hch@lst.de>
To: Chuck Lever <cel@kernel.org>
Cc: Jason Gunthorpe <jgg@nvidia.com>, Leon Romanovsky <leon@kernel.org>,
	Christoph Hellwig <hch@lst.de>, NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org,
	Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH v2 1/4] RDMA/core: add bio_vec based RDMA read/write API
Message-ID: <20260121085641.GC16458@lst.de>
References: <20260120143124.1822121-1-cel@kernel.org> <20260120143124.1822121-2-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260120143124.1822121-2-cel@kernel.org>
User-Agent: Mutt/1.5.17 (2007-11-01)

Another reply, sorry.  I noticed I skipped over the end while reviewing
the 3rd patch.

> +	u32 i, total_len = 0;
> +
> +	if (nr_bvec == 0 || offset >= bvec[0].bv_len)
> +		return -EINVAL;
> +
> +		if (check_add_overflow(total_len, bvec[i].bv_len, &total_len))
> +			return -EINVAL;
> +	}
> +	total_len -= offset;
> +
> +	iter.bi_sector = 0;
> +	iter.bi_size = total_len;
> +	iter.bi_idx = 0;
> +	iter.bi_bvec_done = offset;

I'd much rather have the callers pass in the bvec_iter, as that's
more useful.  We can probably look into factoring the quoted code
into a helper if that's useful.

