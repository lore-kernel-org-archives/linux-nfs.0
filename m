Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A03F92BE7AB;
	Wed,  8 Jul 2026 07:49:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783496958; cv=none; b=qbFmPqduX7OiXUzWtzUrP6hA5Bau9mmajWUg2dteQC8X7eL8k5k5CiPxYsxztyW2TnPg5KMG/uhhkdgTTqSeR58oyN8YNOIGMYGMIJtHvkSwcu6mF4rCztx+ZN7/SSTeHpAdiK4GhlCKYPv0QB+jrWoHMcXjq2A/f7ddDZGO5bc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783496958; c=relaxed/simple;
	bh=B8SlyzgEjZH7m4lf+oMNNMXCliaG5bojirIWNFy39fI=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=kEl4CAxW+9BWJ+eoN53tVe5nNfVYBnGqJhUMBpXPVVnCVZ2OK0d8RBduOI6mz82RnHqqyhsf82kLWXaDmbz9+OFY3hoS/ZrtvbnTP1Gt9ylKE4rdRS5jfGcvz+PfwyWQE3h9VWnj8mKPRFSCfLYimFNz5pdANXP3p9Jw+aTucgw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=Yf34rmEA; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Yf34rmEA"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=1GKqWLEPMpSojJNy8dWRNhk5xCmhjbzGdFpbVnUJaBw=; b=Yf34rmEAxcLNuhnC7Kq8y4edIn
	yHLw/ZngPfYN4Ht4snU+mOMkMNi/O+LHMInNR9DR+2vJR7VXHFoixo4uBSKJziJQeVDiqI/V+11Yg
	IFd68c1E3lx9cSVDK9tTEXqswI+f+n/QplUk1S0geaRP1VEq5yiPEhkapAerHAxA2VkxT2SeJ72KU
	WHzQ/+JskZTDMwYxI7N2j8N1EbWgXo1uGBe+tgI7ktqUEBtV6XkIn+UQkA7S6ZReyWLGxQCJnFDEA
	MTly9iUpoiyS95CyXfl2WbcQ+qoOXfUQ/9w9W33kJEHw8gQZaVK07G8PlP6x02jRmr9lMDeFFLGH8
	cO8aLwFw==;
Received: from hch by bombadil.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1whN1c-0000000GXRD-1kHi;
	Wed, 08 Jul 2026 07:48:56 +0000
Date: Wed, 8 Jul 2026 00:48:56 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Pranjal Shrivastava <praan@google.com>
Cc: Christoph Hellwig <hch@infradead.org>,
	Matthew Wilcox <willy@infradead.org>,
	Trond Myklebust <trondmy@kernel.org>, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, Anna Schumaker <anna@kernel.org>,
	Shivaji Kant <shivajikant@google.com>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v2 6/7] nfs: Optimize direct I/O to use folios for
 requests
Message-ID: <ak4A6IEmWNi27I2d@infradead.org>
References: <20260616134000.2733403-1-praan@google.com>
 <20260616134000.2733403-7-praan@google.com>
 <7ee3bcfdd6126c93cbb1c219bf601182b95c10d9.camel@kernel.org>
 <ajGGpDvzZdkGtSbN@google.com>
 <ajP8ZTTLYkICFTO_@infradead.org>
 <ajQ21kH1ZVajS2Y7@casper.infradead.org>
 <aj4iiD5C_yyLeb3U@infradead.org>
 <akevQfFVteCOD6LM@google.com>
 <akfAgy52s_Gch2KG@infradead.org>
 <akzsO_vmYX_7Umjd@google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <akzsO_vmYX_7Umjd@google.com>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

On Tue, Jul 07, 2026 at 12:08:27PM +0000, Pranjal Shrivastava wrote:
> Ack. I see! Thanks!
> 
> Regarding the page_folio impasse, how do you suggest we proceed? Should
> I expose and use get_contig_folio_len() from bvec? Or should I move the
> NFS helper into the iov_iter lib? (or both).

Sounds like the best way forward for now.

> Also, do you suggest sending the Folio move as a standalone patch if it
> is blocking the rest of the series or do we prefer keeping these in a
> single series?

Sorry if I'm thick, but I'm not sure what "folio" move means.  In doubt
if you think you can get a series merged quicker without a later part
I'd split it.
