Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3A9821CF8B;
	Wed, 28 Jan 2026 03:36:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1769571410; cv=none; b=AaLn9+Kr5vcJwXh9LyK6w2aOoFp63ZNPhXt3n+mjS+St8E3UmzHxe+WpnVGFmVmYxvc6KTVGBlWAEjUDajRyECdE7A+2qlRwirFHLcrwO7wDIG13layR482SFI0OsTyDyu4GdGBqPh0ybDTMS+bVlt3Y+nwbaWRkh/wXJTx1xPs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1769571410; c=relaxed/simple;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=UPSftwfw0M/KyjSmQiLaRVhJAqxqZfAFDexWjrYsA06+gyZTtvRBVeiaSCSpPIqZpb9qfxmptqlSD0frvqrl5QeOfOnV9MdtazxPmUur02mhmiGW1FNT9Rty/kNcbJv/lVbmloK7Q2qY2Kbt0by70waV0QLz4IC1jxY/XRxqBc0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 2E2F8227A8E; Wed, 28 Jan 2026 04:36:47 +0100 (CET)
Date: Wed, 28 Jan 2026 04:36:46 +0100
From: Christoph Hellwig <hch@lst.de>
To: Chuck Lever <cel@kernel.org>
Cc: Leon Romanovsky <leon@kernel.org>, Christoph Hellwig <hch@lst.de>,
	Jason Gunthorpe <jgg@nvidia.com>, linux-rdma@vger.kernel.org,
	linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH v5 5/5] svcrdma: use bvec-based RDMA read/write API
Message-ID: <20260128033646.GB30926@lst.de>
References: <20260128005400.25147-1-cel@kernel.org> <20260128005400.25147-6-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260128005400.25147-6-cel@kernel.org>
User-Agent: Mutt/1.5.17 (2007-11-01)

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

