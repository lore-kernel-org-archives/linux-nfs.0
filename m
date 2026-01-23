Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0DE6327E07A;
	Fri, 23 Jan 2026 06:36:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1769150216; cv=none; b=SChBrOyqeEsdDu9FNMKAsGGLLhfzvu+bVMgr9tNuwJFAdmQ1z+Ep0kJRxslDZEi5ZzBUyvuLJ67xYgK8YXcKQTJvXgGluWd3Pg7tnAWNdnM4MjGPXz8RZW5OvzMzVfLPxVS0RCwr4JDxUR12MYsEBP16TI1qLMwxSAEjlHfGxkc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1769150216; c=relaxed/simple;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=sLIfJQGolDfibkqvpFJ9c7ob6hUwWobmSemQOckphATZLaAFxZIJGYTR5larBnjAdLlRa1g+TfbwcCvyv30ACEOzUgkkaQUo+PYkdbf9fsI0vfvM4cISktQUJ+udv/rjA+6DR0ywfVNWeTyf9qTZ4J5elnZ495sJf+mmvL+PSRs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 08A19227AAE; Fri, 23 Jan 2026 07:36:53 +0100 (CET)
Date: Fri, 23 Jan 2026 07:36:52 +0100
From: Christoph Hellwig <hch@lst.de>
To: Chuck Lever <cel@kernel.org>
Cc: Jason Gunthorpe <jgg@nvidia.com>, Leon Romanovsky <leon@kernel.org>,
	Christoph Hellwig <hch@lst.de>, NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org,
	Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH v3 4/5] RDMA/core: add rdma_rw_max_sge() helper for SQ
 sizing
Message-ID: <20260123063652.GB26025@lst.de>
References: <20260122220401.1143331-1-cel@kernel.org> <20260122220401.1143331-5-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260122220401.1143331-5-cel@kernel.org>
User-Agent: Mutt/1.5.17 (2007-11-01)

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>
