Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6EDB43D1CB2;
	Mon, 20 Jul 2026 09:14:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784538846; cv=none; b=p9BVXehvMy64wQISQbueCbuYXqkzDstSV+988zvaISGF3kOyyRmbixAu+XfZYUFQHR6jNHO8lNvrcEkSm5IsL5lVRKjcR497E3RWa9Ee3KO2J3VnP4f8aqj1qQmB0AUMAfk2xVG3Q2E3lhLJbepDNXKaCjJTdrSztO8/CrQd4iA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784538846; c=relaxed/simple;
	bh=VTn51bbxQE/qwCAazxMwvs9N2K1+G5qkXX1dy3O7GF0=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=aziLazTJa1nHZa9SdV9VR61P40xithOkQfAf2uncYe1+SMw1vywfmb6NHvwPcAhflRi4TxX2UU6I3/JrnFt7NEaEj64f96/3UkvTmxT539RzPLhmbAwW0GQTzfD4nu1sD+4fxPwZ2VilOnjv5omYR/E5Iu6FDuutMNs0soZQJq8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 9D7B668BEB; Mon, 20 Jul 2026 11:14:02 +0200 (CEST)
Date: Mon, 20 Jul 2026 11:14:01 +0200
From: Christoph Hellwig <hch@lst.de>
To: Pranjal Shrivastava <praan@google.com>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
	linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>, linux-kernel@vger.kernel.org,
	Christoph Hellwig <hch@lst.de>,
	Logan Gunthorpe <logang@deltatee.com>,
	Jason Gunthorpe <jgg@ziepe.ca>, linux-pci@vger.kernel.org,
	linux-rdma@vger.kernel.org, Shivaji Kant <shivajikant@google.com>
Subject: Re: [PATCH v3 2/5] nfs: Track number of pinned pages in nfs_page
Message-ID: <20260720091401.GB24298@lst.de>
References: <20260715143540.3597616-1-praan@google.com> <20260715143540.3597616-3-praan@google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260715143540.3597616-3-praan@google.com>
User-Agent: Mutt/1.5.17 (2007-11-01)

Nit: capitalization of the patch subjects is inconsistent.  You probably
one to stick to one version or another.

Otherwise this looks good to me.

