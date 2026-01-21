Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4CF8147B428;
	Wed, 21 Jan 2026 08:57:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1768985852; cv=none; b=GmIneNPAhsF4cI5l8MaDwcf9pnTk99HbryinGc7GRQUeDBGeELhL+zQKkNk/8b7xqifAwSaFUgJ/8z2aekjXSq5T1uBbXWYZxEjPebovIEg0yP80tWkfNWMvlSrDI59gOoVgDsf3giNRfZuHw5vfu/WmbOz8IO5QKBMPLzvegPQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1768985852; c=relaxed/simple;
	bh=+Zp5QW66yuDTlQt723imYEQ44amxK86yXzHXrI4WGh4=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=rpK9yAXhNsCPNAqvryIg2EceShRD7bgqfVwyTDz+O8JfxQ0vzxBWa8wesWrtzB6cTz18sq65sE1wJlzfospXXQ01dKl2T8XMr55w/8FEo6Pj09o5nPdDUOFy/e7fvO8Fy1bH2O9UtcuQ09D5if3N+AeG+vvDNDpNLxJs5bleguw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 4C7C1227AAA; Wed, 21 Jan 2026 09:57:27 +0100 (CET)
Date: Wed, 21 Jan 2026 09:57:27 +0100
From: Christoph Hellwig <hch@lst.de>
To: Leon Romanovsky <leon@kernel.org>
Cc: Christoph Hellwig <hch@lst.de>, Chuck Lever <cel@kernel.org>,
	Jason Gunthorpe <jgg@nvidia.com>, NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org,
	Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH v2 1/4] RDMA/core: add bio_vec based RDMA read/write API
Message-ID: <20260121085727.GD16458@lst.de>
References: <20260120143124.1822121-1-cel@kernel.org> <20260120143124.1822121-2-cel@kernel.org> <20260121084217.GA16458@lst.de> <20260121084840.GX13201@unreal>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260121084840.GX13201@unreal>
User-Agent: Mutt/1.5.17 (2007-11-01)

On Wed, Jan 21, 2026 at 10:48:40AM +0200, Leon Romanovsky wrote:
> > > +static int rdma_rw_init_map_wrs_bvec(struct rdma_rw_ctx *ctx, struct ib_qp *qp,
> > > +		const struct bio_vec *bvec, u32 nr_bvec,
> > > +		struct bvec_iter *iter,
> > > +		u64 remote_addr, u32 rkey, enum dma_data_direction dir)
> 
> Don't you both think these functions take too many arguments? It might be
> worth introducing something like "struct rdma_rw_init_attrs" and passing
> that instead.

Not sure that buys us much.  Having a {bvec_table, bvec_iter} tuple
OTOH might be a nice general data structure.  Not really for this
series, though.

