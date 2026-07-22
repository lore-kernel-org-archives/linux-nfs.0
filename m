Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 622AE36CDF3;
	Wed, 22 Jul 2026 12:23:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784723032; cv=none; b=k3Ovr2crM3Bd6pgEhGzDFhC2ee0xKw7cvqgau4C/fu7w5QGOTjrZ2j8aGVbfxyF59rCIPTK9G6hbcwTERtgXL7+gAkXcPS9CaLnbAhYxycm8euqOUM8aUvcIYIllsPQ+ehEKeY4vA6LirSi1vKXQQh5fZLX8TNUmNzUFYuGas/w=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784723032; c=relaxed/simple;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=rZMBmngP6oiF77n52MOx6ZLmBTw2kAdDb72WwOJyrKDGPYGpulZpEa09l1aQTCWW6wvD7iNaqqqUhHCKMpNf3AcdALuHcdDcHMY0ZNud35K7A911dMsfI0Y91Q5O2YM/c8kugBKzlEcTHqLmrIDcWTYdWmsKCePu2sITzpM8Cao=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id D852668D32; Wed, 22 Jul 2026 14:23:32 +0200 (CEST)
Date: Wed, 22 Jul 2026 14:23:32 +0200
From: Christoph Hellwig <hch@lst.de>
To: Pranjal Shrivastava <praan@google.com>
Cc: linux-nfs@vger.kernel.org, Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>, Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>, linux-kernel@vger.kernel.org,
	Christoph Hellwig <hch@lst.de>,
	Logan Gunthorpe <logang@deltatee.com>,
	Jason Gunthorpe <jgg@ziepe.ca>, linux-pci@vger.kernel.org,
	linux-rdma@vger.kernel.org, Shivaji Kant <shivajikant@google.com>
Subject: Re: [PATCH v4 2/5] nfs: track number of pinned pages in nfs_page
Message-ID: <20260722122332.GC13416@lst.de>
References: <20260720150601.2702700-1-praan@google.com> <20260720150601.2702700-3-praan@google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260720150601.2702700-3-praan@google.com>
User-Agent: Mutt/1.5.17 (2007-11-01)

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

