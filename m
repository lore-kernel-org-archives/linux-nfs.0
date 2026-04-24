Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9B9E23D6CAA
	for <linux-nfs@vger.kernel.org>; Fri, 24 Apr 2026 13:22:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777036928; cv=none; b=K0MYGhbCkrFPyTuWcMODUO73ETnTm4WFPPYhlpnCQexyuQqk5G/Ou3KdY8xbyitv1DorWfRXySt+JFj+RdF3PKAgPsiR+nrhFuMsTGRwsci+5YTWOPxvPzrizCrbc4DAeJsqh9M5QTy4yX+iovqq/dCww4rHePPFjxSeN5+DvhI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777036928; c=relaxed/simple;
	bh=geRJbqGa8ftVjxhvHhO4BIjOVzsdZvc0Fwn7WM0kFWA=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=kXnvAM3TXgQ9ASdLLc44XI3aLeLQraPwUVFnhmVvPXh0saI3d2kYdq7TeOOWB0a5msBNWWLl8d2t6C2X/Z538QuNKqbWApwCoXSFLE8EuqJ9PzeDCP8N31e3FUXbdF7eKL7Tcff+UEZbUjnawBmpEK3w/JjjgD2na2w0P0TWIAY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 2E96F68D05; Fri, 24 Apr 2026 15:22:04 +0200 (CEST)
Date: Fri, 24 Apr 2026 15:22:03 +0200
From: Christoph Hellwig <hch@lst.de>
To: Chuck Lever <cel@kernel.org>
Cc: Christian Brauner <brauner@kernel.org>, NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org, Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v3 1/4] nfsd/blocklayout: always ignore loca_time_modify
Message-ID: <20260424132203.GA15687@lst.de>
References: <20260423181854.743150-1-cel@kernel.org> <20260423181854.743150-2-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260423181854.743150-2-cel@kernel.org>
User-Agent: Mutt/1.5.17 (2007-11-01)

I got two resends of my series without cover letters in my inbox.
Was this just an accident in sending out some internal tree?

