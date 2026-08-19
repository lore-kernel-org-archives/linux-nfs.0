Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B68862E888A
	for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2026 06:05:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787119560; cv=none; b=e0agFpCE96zaVhtJtcIqLHu0LkYb5c3fbv+eJNdNchX//Y9vXDdSZpagk6327VixdPHcojmA+9IIuCDzGrxGi0jwqcY/Zv0gHhujSx6496mP4lNqt5py721elounJ4dI0U95svHKRFMzdzpkzYwHZqPFrT8/snbEIc5GdicQ/lY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787119560; c=relaxed/simple;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=TPRziIigP7KjM++tsY3+D9iRUNVR/kTx2aba3PqVIUh4++PqEo0BSWbAFmickXe9hELh6fLhRnkkUQ1BaYJmgElvxNBkmieDG0U/pDP8Kbm6KJebwYQSIDIAP0JYztjGteHRtD875BGKOtK3PoEWYPeDkM4xeRH/a2hixYi8vnE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=yly2ZqT7; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="yly2ZqT7"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=; b=yly2ZqT7xKC6C/E49E95Xc7VVU
	VsLcur6JU2UGKtnZlLKRo6TsX72ll2DJRt4iIH6d0yCzyh/eYKi/60pHeOdFFOrzGR2id4Geg0YIl
	S6Ae5MiHbpnlPR8GmKEzaNuqhQXoeoNj4aG8bFD4iMgEKKD45Q1sYi4MxYRYYtl5L+z5O4FUx/s6Y
	AmUtnSApnhhKG5XcmsrAhpgqwhzWjLKtgQSG9UZDxQ+SuDQrwOvFU+Ff/kDybyFVYU9aPgoHLOmcv
	C7tUOR8Ok1RCUeyi4hS4ytcFNeX325MrB7EDPk8l7EvR/fNxKFBtriCodjbpiZLKfD6Cji8nGnaBx
	0z8cH5LQ==;
Received: from hch by bombadil.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wwZQn-000000093rL-07hg;
	Wed, 19 Aug 2026 06:05:45 +0000
Date: Tue, 18 Aug 2026 23:05:44 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <cel@kernel.org>
Cc: NeilBrown <neil@brown.name>, Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSD: Resolve the recall-any mask names in the trace
 format
Message-ID: <aoVHuK-JPLvCEOuI@infradead.org>
References: <20260818184151.31180-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260818184151.31180-1-cel@kernel.org>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

