Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B7B7424BBF0;
	Wed, 19 Aug 2026 05:58:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787119096; cv=none; b=d+nJ+tCXG5nsrJzQDQ9cM64QI8RNarBlDkP95jtFE10ychuiDU7nsDxmP02vQmVVaIGe7zZvhPJ6Dw72QcxVLnolmc75CLeKKLpQTvApnOs9TWGMrIn49C14Yt7Z+uwAE27Q/8RO7bUvd6FTt2gg7d8IxD6ENBB23oXqa1WvXxc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787119096; c=relaxed/simple;
	bh=JBupKNx1pF/KI9kPR1t/83yljfTIrKeGqiO5r1BqGD4=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=LAVGD/Jskm3+aB4Uvp9Z1ZA/A36lRStvWvM7dJT2LxQxr53d5xO5b9byy8PHyO/wGpbi+I5Lfh7MlGXmhs5P/iWH7oVQIZkLJ5bxFUqbZJoO79I0+vYfUyJw3gWSi1ANhi5TM2yuXkelEODxgHiGbc2obZbl+fxBX001W9RD8Zc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=c+kXqJmu; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="c+kXqJmu"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=4f6jnBJjfk2ZY77KIS8hOYA1cH9a2FWJrLXhzovop/c=; b=c+kXqJmuWe4xE6/jYtHO2vMqvl
	1JwxP3cJ54xlMEcWwltkT3yRTVOZPZ/RGsLKb8GjwBQwiq6BHM0XwEb3NrJSflGy0XaePAqKnrbZQ
	nJ4usq8jzNivMRyGEXSqHJtdS8eBinkB6ebUJRpLNpZD/Bq+4sYHxSIELAP747QsWAi823LUr1L3A
	rDSNJCuvfn1lP4x689Ec38Tm74o1P89wMWzp+JEHNc7wHvW3IPxpQRZ2uLBL/5KQQA0vmnDRPl0UR
	uNaoMsh7VcxM4/bIh64mRosq/8pHyy9ImfYDU1dhGR1X78k2uQWxkgWumml1Nteo3zMaumaa6Z4jx
	154z4zvA==;
Received: from hch by bombadil.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wwZJS-000000093N7-2HCt;
	Wed, 19 Aug 2026 05:58:10 +0000
Date: Tue, 18 Aug 2026 22:58:10 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Ameer Hamza <ameer.hamza@truenas.com>
Cc: cel@kernel.org, jlayton@kernel.org, neil@brown.name,
	okorniev@redhat.com, Dai.Ngo@oracle.com, tom@talpey.com,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	alexander.motin@truenas.com, caleb.stjohn@truenas.com,
	stable@vger.kernel.org
Subject: Re: [PATCH 2/2] NFSD: Update the atime for iterator READs
Message-ID: <aoVF8l3E6SjXOVlD@infradead.org>
References: <20260818225715.572140-1-ameer.hamza@truenas.com>
 <20260818225715.572140-2-ameer.hamza@truenas.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260818225715.572140-2-ameer.hamza@truenas.com>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

On Wed, Aug 19, 2026 at 03:57:15AM +0500, Ameer Hamza wrote:
> A READ served by nfsd_iter_read() or nfsd_direct_read() leaves the
> atime update to the filesystem's ->read_iter, and not every
> implementation does it: fuse_dax_read_iter() carries a TODO for
> it, and kernfs_fop_read_iter() does not touch the atime at all. On
> a fuse DAX export, READs never advance the atime, no matter how
> often clients read the file. Spliced READs are not affected, since
> splice_direct_to_actor() ends with file_accessed(). nfsd serves
> whatever filesystem is exported, so it cannot rely on every
> ->read_iter keeping the convention.

Code outside of file systems and library code has absolutely no
business ever calling file_accessed.

And please stop this LLM garbage.  Your patches seem to have a pattern
of finding some unusual corner case that is broken in a file system
and than work around it in core code.  That's not how it works.
