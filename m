Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 25FAC3D5244;
	Thu, 10 Sep 2026 09:53:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789034016; cv=none; b=BW1UYuolTeXCa9hmPuZqVe0zBAeP1q0pLfF0Q6wU48ZfP2w4PpJ5kgUXWH2o+SqGuSW3I1WoSCsB7+m3kgJ1P8fWlzsow3U3OpVrUB0lNvb4sWSV53EzqkQQC+ZQtLa+reyQDbc1JGmtDahcpaFOAfwL3TPDen9A9Isc8pW8i7M=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789034016; c=relaxed/simple;
	bh=11/jkJK+JY/3w/Rt0fWznUZ6DzBqgpeIedZHKeL+0qU=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=HHhlfelvRsCUi9wRCvEftjh7C6cbygWus9h1n7tJCajjYHRQQ5hBtSexUUgPp9so5y/YWo1gD3+MiHOHun2vyALqL13s+HPavhBZ2kmVtt/D+fn6EtHsPYue+f0ZXVq0TWgh+3h7TgCVo/7uc7OK/kuQh2JIw33sprWHp8JbIig=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=Q/ognF2H; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Q/ognF2H"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=nG7hVY9Cs3GLSwRLL9rzd2+XNS+c829T7n2VxQwN1Ew=; b=Q/ognF2Hwav1d6YZsZcqqcPBYD
	v9JBCnNqV1a7ET/Qp43casBsubMh/toAHpvduU1NodIb5LdoyyIVixzzkWjzvZQIyLSAA14FB180M
	wHxLUg+bXpVC72JC30FSB0ubUBgZv42MMqeNp51cK/Gyb5mUPj2E0wkvv2QqRcHvgckrc/Dp5cMe/
	i4mMzkE+g0sAhCHJ2KsgS3SmtuX9jTwRHhkJfqGaf5eEfPfNOo0M/VF8TH7+9mllIrLWEUXimbhZq
	KhtUrE7mzWbJEIpf84iMXrL+rbtXtominoUKlpJnbDLYdmcHkx1EdlEx7oS7HzwX3QuYStxJroDQE
	5FdW4cLQ==;
Received: from hch by bombadil.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1x4bTB-0000000Dwjg-2RJs;
	Thu, 10 Sep 2026 09:53:25 +0000
Date: Thu, 10 Sep 2026 02:53:25 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <cel@kernel.org>
Cc: Mike Snitzer <snitzer@kernel.org>, linux-nfs@vger.kernel.org,
	linux-block@vger.kernel.org, dm-devel@lists.linux.dev,
	axboe@kernel.dk, jlayton@kernel.org, david.flynn@hammerspace.com,
	Keith Busch <kbusch@kernel.org>
Subject: Re: [PATCH 4/4] nfsd: fall back to buffered I/O when a direct write
 gets -EINVAL
Message-ID: <aqJ-FZ1IAMaRB7gP@infradead.org>
References: <20260908163232.30774-1-snitzer@kernel.org>
 <20260908163448.30841-1-snitzer@kernel.org>
 <20260908163448.30841-5-snitzer@kernel.org>
 <995a853c-2c54-4bd0-9708-f6e0c1be7fd5@slotpi15m67>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <995a853c-2c54-4bd0-9708-f6e0c1be7fd5@slotpi15m67>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

On Tue, Sep 08, 2026 at 02:25:32PM -0400, Chuck Lever wrote:
> Per our discussion last October:
> 
>   https://lore.kernel.org/linux-nfs/aPXihwGTiA7bqTsN@infradead.org/
> 
> The conclusion then was that -EINVAL from ->write_iter can come from
> a number of conditions in the filesystem, so NFSD can't treat it as
> meaning only that the I/O was misaligned. That still holds, so I'd
> rather not use -EINVAL to signal a retry. An -EINVAL that really is
> the filesystem rejecting the request would now cost a second full
> write attempt before surfacing anyway.

Exactly.

> What would help me understand the failure even better:
> 
> - Which -EINVAL in bio_split_io_at() fired: the per-bvec dma_alignment
>   test, or the zero-length result after ALIGN_DOWN()?
> 
> - On the reproducer, how does stx_dio_offset_align compare with the
>   queue's logical_block_size?
> 
> If there turn out to be cases the gate can't predict from the statx
> data, that seems like a question for the block and fs folks about
> what error the filesystem should surface, rather than something to
> work around in NFSD.

We shouldn't have such a case, but if we have we need to have a clear
API to discover it.  Note that Keith has been looking into a proper
uapi to discover all the alignment pitfalls, which I hope we can
land rather sooner or later.  nfsd could consume it the same way
as userspace, and we could write userspace reproducer for any
corner cases we need to clarify.
