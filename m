Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A6F6F3E1212;
	Tue, 17 Mar 2026 14:25:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1773757545; cv=none; b=d6Objr4WND2lYeyypdAVIM3K/dnFo+MqwmglAhuIX701y42xM79YwBhN7GTMXTgmmFkFel/GpeRyHzPL6TAp8cRiwhc5Bqy3NSphVmpQEVBb5Unr+N4IN0nCGm/16nBQ1m+joKxd/92KJ4cRnmMiy472Se4z7KPA+cBgHI3nmX8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1773757545; c=relaxed/simple;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=Q78JYrpXEevSAYGXAyWzgsfGUPPsEcbZqIXr5AJI4QpJg0b0VNfioeighO+zb+zdMQ/Qz2A2uMrpSIUTmx/G+skyEBwOml3jVo39fmDeoqlImfWLgIOYkutAaekIHtkZ2Ln8HPdcjVsRm0lWukNQEz/Fx4AbP4XMF0VnYa8mxDY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 4CF3E68BEB; Tue, 17 Mar 2026 15:25:42 +0100 (CET)
Date: Tue, 17 Mar 2026 15:25:42 +0100
From: Christoph Hellwig <hch@lst.de>
To: Chuck Lever <cel@kernel.org>
Cc: Leon Romanovsky <leon@kernel.org>, Christoph Hellwig <hch@lst.de>,
	NeilBrown <neilb@ownmail.net>, Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org,
	Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH v3 2/4] RDMA/rw: Fix MR pool exhaustion in bvec RDMA
 READ path
Message-ID: <20260317142542.GB4367@lst.de>
References: <20260313194201.5818-1-cel@kernel.org> <20260313194201.5818-3-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260313194201.5818-3-cel@kernel.org>
User-Agent: Mutt/1.5.17 (2007-11-01)

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

