Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F3B3B261B8C;
	Wed, 28 Jan 2026 03:36:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1769571388; cv=none; b=VmgVE7stu66lbpfUxve1Hdc5nzZ3e/ha8b+4A69tILLqLwTqq8mEhPPcN+iW2bWuvo8Q/qkbRQXzxGju+k+Kl88kbdYoQztLBfOuV28wT7H2uIUUFaDGrvp4l78D9Hd4T8bfbsffVIYDWm/YAH6I5ot9Z3ef/65s7rvbkD04bI4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1769571388; c=relaxed/simple;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=YV9C7K5ysHDqcJ9ENJO91y//ePFp2f3QnAbG0WurlEwq96McMs1eP2nTteTxX6pgSGhq+vgF+rAlqWWES2cD1StzFPJ4lrFLztmOLWqz1hD1rc8Q95n1Z/U42o5edOimZ5z1pMDHkJvTQ5wJsr5FQI/poHw//7VnW6BGk/ebKVw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id CC4D5227AAA; Wed, 28 Jan 2026 04:36:24 +0100 (CET)
Date: Wed, 28 Jan 2026 04:36:24 +0100
From: Christoph Hellwig <hch@lst.de>
To: Chuck Lever <cel@kernel.org>
Cc: Leon Romanovsky <leon@kernel.org>, Christoph Hellwig <hch@lst.de>,
	Jason Gunthorpe <jgg@nvidia.com>, linux-rdma@vger.kernel.org,
	linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH v5 3/5] RDMA/core: add MR support for bvec-based RDMA
 operations
Message-ID: <20260128033624.GA30926@lst.de>
References: <20260128005400.25147-1-cel@kernel.org> <20260128005400.25147-4-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260128005400.25147-4-cel@kernel.org>
User-Agent: Mutt/1.5.17 (2007-11-01)

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

