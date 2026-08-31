Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4E9BF2941A
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 07:03:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788159816; cv=none; b=N9NtJwUCsrulJ/Sj+lcGDQyxWLOfaz0xpR6Xpt2JYX/qtNPZ/paLBNbRf5GUzrZd7HFtP5Xed+4z8IQbNTLewSJQzger/+fkmJVyQFzN5gNmPHQSZkriEUNWjms8Hj2e/sEZJaFY9pekdPOtX8eJbcVTc1Fk4OJ+y5R205mVH0E=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788159816; c=relaxed/simple;
	bh=3ooWAWZmLHUaRDHTJTv6UzHMMOu81bynrPS16SBr6pQ=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=fO3e3yvPS0vgtkfC8heM9nIDJH1OGt03xFG25zlgNarJtzyd/+AgpF/be4f2v666iLchaMIvc54ss6LeWHqAM/oz9NPUXeSyGXBGEXTFi9R8UODj4MNGd5PHRuVjQHwkq6Cwr6T4foAovB7IYa51xnW8F/FInofF8WKE3sfrtks=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=SsjEchZJ; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="SsjEchZJ"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=3ooWAWZmLHUaRDHTJTv6UzHMMOu81bynrPS16SBr6pQ=; b=SsjEchZJpfAyLaIXHuobNEaSbG
	VIrXM2t8gglHOANcNWkgv1L69P4YwW6jZ5uahj8o2stfdQT23r0LwrGUOFDCXP4xssBb86EzgEOzq
	hK6aRRWYaNvIVEw903bQApr042tLd/1B2vBCpHuBYTTia1sIZsNZdYPQupTsHef3tGQmWde/mx4oj
	4V0uakEay9IQpwXMQDpNX/CDKIQ0BzdEAlT4VjNPDNNQUnCn3CytUcY+Eu+2UEZOsZ9RcQ7TnGuXl
	DArD76zPJvgMr9J7OZnItq1qIVbKQvWq4Qrg78fq2zCHlwQUfLeMSYk+9voIhcMjlSYtsn3SjpKX8
	HdJ3BCmg==;
Received: from hch by bombadil.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1x0w3K-00000008g5C-3WRh;
	Mon, 31 Aug 2026 07:03:34 +0000
Date: Mon, 31 Aug 2026 00:03:34 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Scott Mayhew <smayhew@redhat.com>
Cc: trondmy@kernel.org, anna@kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs/blocklayout: allow pNFS SCSI layout without pNFS
 block layout
Message-ID: <apUnRjIOZ-zV8NIi@infradead.org>
References: <20260827194544.459315-1-smayhew@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260827194544.459315-1-smayhew@redhat.com>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

Supporting SCSI layout with block layout makes totaly sense, but please
do it without all the gracious renaming and annoying AI slop commit log.
Take a look at show nfsd handled this with CONFIG_NFSD_BLOCKLAYOUT and
CONFIG_NFSD_SCSILAYOUT as that is the model that applies here as well.

