Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AED9A3D3305;
	Mon, 20 Jul 2026 09:13:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784538808; cv=none; b=NBxbpHBwZ0TxBlf2BDJ/TuuvsRI1W78sNrd7npp9i/opTB6salaGZP8X95juQ1YQsiVHgj9OIo8pD6QQi3aCQEMY8M1N5hODrJZ8KylFTh2mRtv6bE6IjvWBxNZ9Ve6BfeBLEMMCCUoaYrPR7E8R+n4FCPzb1D4kkix2RDfjS0A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784538808; c=relaxed/simple;
	bh=SF+HRtCd6E4/b0uLMC537XuZmM4UnjFeQY49cgJ9ABk=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=MmEOm6Rj494LzOlb1kUqEBePSMuABq0MIiD4DjYFGMpT7/amEfhXZ6xha8lFKWe94kguZp4RVl7AXZFGs3hju8nXbdKa4cw0YtUsl9QcLtCMKDjU3v8EB2oCL06W/+qOShhWz7TFamShCLbLjK4OplAKHJHpPaI0ul3FJmdNlzg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 3932E68BEB; Mon, 20 Jul 2026 11:13:23 +0200 (CEST)
Date: Mon, 20 Jul 2026 11:13:22 +0200
From: Christoph Hellwig <hch@lst.de>
To: Pranjal Shrivastava <praan@google.com>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
	linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>, linux-kernel@vger.kernel.org,
	Christoph Hellwig <hch@lst.de>,
	Logan Gunthorpe <logang@deltatee.com>,
	Jason Gunthorpe <jgg@ziepe.ca>, linux-pci@vger.kernel.org,
	linux-rdma@vger.kernel.org, Shivaji Kant <shivajikant@google.com>
Subject: Re: [PATCH v3 1/5] nfs: make nfs_page pin-aware
Message-ID: <20260720091322.GA24298@lst.de>
References: <20260715143540.3597616-1-praan@google.com> <20260715143540.3597616-2-praan@google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260715143540.3597616-2-praan@google.com>
User-Agent: Mutt/1.5.17 (2007-11-01)

It would be nice to avoid the overly long lines, but otherwise this
looks good.

