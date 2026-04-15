Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1DE1131AA87;
	Wed, 15 Apr 2026 05:29:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776230997; cv=none; b=WvJfik2FYx2SlzkWzbwgsXKiuai2/UvqcgtHwDZX+TWwJt2z+8P/2DQRTQzG+WMX/LsgACY47qG47mCEHQq/dGVsIeDjzhNPhbE1/rlSQ4FasiPjim52ihKNIyGYHQGbuTyR+i4o/UkeTIhQ26OLlCbRhaiY5huwHXO0Smf7JPQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776230997; c=relaxed/simple;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=gmZtFSu702OKbnbrEtHPlii055l5rGDKKlIzyob7p07SoIrb4MQfcwKAXY0mUvDM2pbB5Ra8jvtPPQp6ZSXy+uyW84U9qm4hPfRdezMMJk/+xwNs4rkZjNw2YDnLiessPLyDbi41z6C9F7HpV9dU2zg6+pBPFLwpBFJefuB8D3g=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id CCAD968BFE; Wed, 15 Apr 2026 07:29:53 +0200 (CEST)
Date: Wed, 15 Apr 2026 07:29:53 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jeff Layton <jlayton@kernel.org>
Cc: Chuck Lever <chuck.lever@oracle.com>, NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] nfsd: fix handling of NFSEXP_PNFS in the netlink
 codepath
Message-ID: <20260415052953.GA26693@lst.de>
References: <20260414-pnfs-exp-fix-v1-1-9face14c16c2@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260414-pnfs-exp-fix-v1-1-9face14c16c2@kernel.org>
User-Agent: Mutt/1.5.17 (2007-11-01)

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

