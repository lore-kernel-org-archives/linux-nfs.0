Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 13508322B68;
	Wed, 21 Jan 2026 10:16:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1768990610; cv=none; b=V8GfSar8qvyEFjVOC+b2Dhd1+YDYzqFLJz9LRQzt4yzN7Z7GEdHwhqr275qj2p6WX7cZYIGG3b4hbnNw5Rm8/LLjfIXhAL6wpj3mLAD5NGowh/ObIqBxdYG+0DmDQ0zNIcEMLq+W3Wxx5VSzTfkjSVt+LAbCrIBsujV3oz3O6Vw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1768990610; c=relaxed/simple;
	bh=1X394+5DaFAuB45mmijcEpkVPKFGOcEF2WZBirfWfJc=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=N3rjwAJdAA0VUbr3oegAdTGTkq7CYJCq8opRQmuaQt5dC+jHIf4/paycE2LaCpf6epKFVvQK7MUOG0r+S1ZmvAHBj6uyyNlfJ5kEiBFpBd5/R/4sHpmjhzp5Tbqp5OB9RbTLWRFqg6bdB5UikXy0j2PMaJZY3ZsaHd+Yj/GGmPs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=tq7ssXr1; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="tq7ssXr1"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 05EF5C116D0;
	Wed, 21 Jan 2026 10:16:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1768990607;
	bh=1X394+5DaFAuB45mmijcEpkVPKFGOcEF2WZBirfWfJc=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=tq7ssXr13guWP/iJDhCNiCk3YVXz9PO3GDqvE87bqTFPqWYe62AK8qxTe/jUXqJoW
	 St3deIZ4Dq/e/tLQcyHosuFrXLRzzvCSsDavkFLEjxRxmDrbVqzQoMWaM+5KpiOWJu
	 TbMnGf4cQN+cm9phRXVNkKlvItb86bc1UHyNSL6GSdNjVxUAzGHSYnu+9uFiSDT5Ne
	 i7X3pocx85xDgBuEZpZOmkL+Dfq8yfVQQ8BTE663Dz108GZzKOpONbGnJRd74GUmZz
	 cxDJaOTZwSx6m0Pp1oB+Pi2VW+wg6yfFNnFxUHapgrX8CgLh0SdUQzXUq2aJOmU3Fc
	 NKph9WGH2iptg==
Date: Wed, 21 Jan 2026 12:16:39 +0200
From: Leon Romanovsky <leon@kernel.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Chuck Lever <cel@kernel.org>, Jason Gunthorpe <jgg@nvidia.com>,
	NeilBrown <neilb@ownmail.net>, Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org,
	Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH v2 1/4] RDMA/core: add bio_vec based RDMA read/write API
Message-ID: <20260121101639.GA13201@unreal>
References: <20260120143124.1822121-1-cel@kernel.org>
 <20260120143124.1822121-2-cel@kernel.org>
 <20260121084217.GA16458@lst.de>
 <20260121084840.GX13201@unreal>
 <20260121085727.GD16458@lst.de>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260121085727.GD16458@lst.de>

On Wed, Jan 21, 2026 at 09:57:27AM +0100, Christoph Hellwig wrote:
> On Wed, Jan 21, 2026 at 10:48:40AM +0200, Leon Romanovsky wrote:
> > > > +static int rdma_rw_init_map_wrs_bvec(struct rdma_rw_ctx *ctx, struct ib_qp *qp,
> > > > +		const struct bio_vec *bvec, u32 nr_bvec,
> > > > +		struct bvec_iter *iter,
> > > > +		u64 remote_addr, u32 rkey, enum dma_data_direction dir)
> > 
> > Don't you both think these functions take too many arguments? It might be
> > worth introducing something like "struct rdma_rw_init_attrs" and passing
> > that instead.
> 
> Not sure that buys us much.

Readability???

Thanks
