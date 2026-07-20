Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AE56D1A0728;
	Mon, 20 Jul 2026 09:15:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784538952; cv=none; b=ShEW4gU4q6S2vZiTAAMP672VJolkTdlRLhtwgZkyEqTaBshSNzgXhC3YOXgTyaj1PJRVt+EVGj1wsxhNx6id2PpqggrH+UQex6HrjO7wxmJl1f2Ob7Op+iYkLXR+OEEE8SUALnJJKpVbl5rByBgiVEZmbCv1fZth/uM78xOJxpw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784538952; c=relaxed/simple;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=We1//CPFAztTFwvAKm4jvZHp85F+f/EtyUBXK0Mbnwu5xr9bIXDyRbKkhUqxWpAFFQBQPG/3Dgvg/3kiVMwbWsrnJBnXAleBSXX2ndBTkffPwY3OcBLMiSAiVIRH6LPlkt/F9zXmsUtXKFmZd/NB+aGBPoCpLtFsH+f52DuwwV4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 3AF9C68BEB; Mon, 20 Jul 2026 11:15:48 +0200 (CEST)
Date: Mon, 20 Jul 2026 11:15:47 +0200
From: Christoph Hellwig <hch@lst.de>
To: Pranjal Shrivastava <praan@google.com>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
	linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>, linux-kernel@vger.kernel.org,
	Christoph Hellwig <hch@lst.de>,
	Logan Gunthorpe <logang@deltatee.com>,
	Jason Gunthorpe <jgg@ziepe.ca>, linux-pci@vger.kernel.org,
	linux-rdma@vger.kernel.org, Shivaji Kant <shivajikant@google.com>
Subject: Re: [PATCH v3 5/5] nfs: introduce nfs_direct_extract_pages helper
Message-ID: <20260720091547.GE24298@lst.de>
References: <20260715143540.3597616-1-praan@google.com> <20260715143540.3597616-6-praan@google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260715143540.3597616-6-praan@google.com>
User-Agent: Mutt/1.5.17 (2007-11-01)

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>
