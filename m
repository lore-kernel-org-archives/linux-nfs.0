Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 86B7C2DC77B;
	Tue, 27 Jan 2026 05:42:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1769492560; cv=none; b=RnCt6HlzXq31X4dgWOmU8QioNejmCd2DPpzHMOMAP61RZDnWHMCqxbF3ItgI4tt0DduaJ2nMiWynJt71g2sLe2PTheDgbdzWXaLYlhDuOYPLzPvXwGht+gIputfZPaEqsd+uNgT68MRzLUzA/yHalU6DP3+FxpX8g8xk7bedHhg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1769492560; c=relaxed/simple;
	bh=HTxesvmW3c3OqXkag0HEXuCFk6DGEWTrTMgYKzuvZp8=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=DawsNPkzv7gQ8v3ktnMPmkqZOEERmMQeWNcMHjWMMCpIexkycTPJ+820nbmEoZ3vlWD76nnRlGKTIivNLnoimyfFYetcPCQsbqjx1PeLtNkSfBZOswqHRPOOroH14HFAGM4e1PK6/JxU4AKL00Y3hsoLRl8rdKKXq4wCY2xYit4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 2B62B227AAE; Tue, 27 Jan 2026 06:42:36 +0100 (CET)
Date: Tue, 27 Jan 2026 06:42:35 +0100
From: Christoph Hellwig <hch@lst.de>
To: Chuck Lever <cel@kernel.org>
Cc: Leon Romanovsky <leon@kernel.org>, Christoph Hellwig <hch@lst.de>,
	Jason Gunthorpe <jgg@nvidia.com>, linux-rdma@vger.kernel.org,
	linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH v4 3/5] RDMA/core: add MR support for bvec-based RDMA
 operations
Message-ID: <20260127054235.GB24998@lst.de>
References: <20260126181414.105062-1-cel@kernel.org> <20260126181414.105062-4-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260126181414.105062-4-cel@kernel.org>
User-Agent: Mutt/1.5.17 (2007-11-01)

> +		struct {
> +			struct rdma_rw_reg_ctx {
> +				struct ib_sge		sge;
> +				struct ib_rdma_wr	wr;
> +				struct ib_reg_wr	reg_wr;
> +				struct ib_send_wr	inv_wr;
> +				struct ib_mr		*mr;
> +			}			*ctx;
> +			struct sg_table		sgt;
> +		} reg;

I still don't understand why the sgt is not in
struct rdma_rw_reg_ctx.  Right now that is allocate a little bit
later than the sgt initialization and freed a tiny bit to early,
but that seems to be easy to fix.

Doing so would reduce the memory usage for the common non-registration
path, and significantly reduce the churn in the patch.

