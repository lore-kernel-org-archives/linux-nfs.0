Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E976D3CA497;
	Wed, 19 Aug 2026 05:59:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787119181; cv=none; b=HkcaqIkx5hNQO58fMSXZFJ+coyUTvLDKrzopwDB/o2j62Xud8yqEVEcP5RoNAl/gd7dp8Krm5uD6U8lO8a4Bh/xV7mCXa0Vnu/CqzxMTlhHq+oa+cNhm4W89hHJnM8H59sZElbYmQndK2+Fx5yN6FyMwkKtx3AtLeAjt2HYN1MI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787119181; c=relaxed/simple;
	bh=zImk7JyRxEsZI02lK0HI5YsjZLjwlFYZoROVY6CkpD8=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=c8fISx54B8pIrXJijTZuvFnjsAC95H5aE1r7pypuUyNBgx5ZwB9Bi9So372sAI/2Atx/AmXXDjStiTjvNe6APgTFfjH20uS0Aia2qYF4wl5iIoXvruxs+mytQ0czxDjddXeNcjQvLPc53nJ0QONjrG6+5+Ow6tigzb71ueqfsJE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=AKQoAUlp; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="AKQoAUlp"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=h1/Jq2qHgrQSYqbMlUYbjKMlu16WUscv+y1zxCO55Cw=; b=AKQoAUlp6NIKg56ZsFYR0aTyHE
	pUrkdYHpX0MNDaLeMcstq8d3LoBk95uBtLvBWIcG3cBOozMtWqGqlhBuKKLYKi/4euHB+pWkcEX5j
	uh74COjqv450qS/D381ttfcZA+Eap8MtksxK4kTEd87E/t6maLlLn4BhoDI8PkyRDUCPvYNYmyHvc
	mswrUpuY586QnTRXAH/q3kBak4rB+ux2A6U+MBGzeWT9NS/2eCgceYk/VzdnhAW/FynIjdI+hnnv+
	5PdSRuHVQ6GXrI5PNZ1m8jVE29qH1DptcodLq+aJhJguqkClN0kgu9Xn0NbdT1qbCt6/YSvuC5ZNE
	T7riaOfg==;
Received: from hch by bombadil.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wwZKl-000000093aA-3H6p;
	Wed, 19 Aug 2026 05:59:31 +0000
Date: Tue, 18 Aug 2026 22:59:31 -0700
From: Christoph Hellwig <hch@infradead.org>
To: NeilBrown <neil@brown.name>
Cc: Ameer Hamza <ameer.hamza@truenas.com>, cel@kernel.org,
	jlayton@kernel.org, okorniev@redhat.com, Dai.Ngo@oracle.com,
	tom@talpey.com, trondmy@kernel.org, anna@kernel.org,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	alexander.motin@truenas.com, caleb.stjohn@truenas.com
Subject: Re: [PATCH 1/2] NFSD: Use nfsd_iter_read() when ->splice_read is not
 zero-copy
Message-ID: <aoVGQ5a7ZhMmq2xY@infradead.org>
References: <20260817210811.3984663-1-ameer.hamza@truenas.com>
 <20260817210811.3984663-2-ameer.hamza@truenas.com>
 <178709365192.2852630.5607658976022815566@noble.neil.brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <178709365192.2852630.5607658976022815566@noble.neil.brown.name>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

On Wed, Aug 19, 2026 at 08:54:11AM +1000, NeilBrown wrote:
> I think that if we are going to do this then we should do it properly
> and make it easy to detect these cases.

That's a big IFF.  The splice fallback is a generate case.  And no,
we should not add flags and big blobs of NFSD code to work around it,
there's simply no point in optimizing for some LLM generated ext4 on
fake DAX bullshit.

