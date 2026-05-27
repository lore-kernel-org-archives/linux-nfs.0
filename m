Received: from casper.infradead.org (casper.infradead.org [90.155.50.34])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C709F18A6A8;
	Wed, 27 May 2026 13:23:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=90.155.50.34
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779888231; cv=none; b=mWzNHg/kmOQBa9noNziMY9lBt6z7g+Y2/sG1zGLSB5bsIRejMLl/R95qOwiB1DbK7s8p9IxNj8RMrLuphhKf6BF/6OZRsBywsEkC0we4wnMx9gKvgxcShZ3vE8HY//8jHwxtyj0GIFA8OfKENkSvwPfnAFnhvFQ0oWVtymAuVuw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779888231; c=relaxed/simple;
	bh=cX+yhv2hWGVJnITebWYVRIa2g5aY4JYGptq92Ncv80c=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=Q4OQ7XWNAZ7Xi1Bqz9CAorWkG7ZJ8AtZ9zJE6S1MTDyS1a7sCCiIwzmbsUKZm/cSN2u1rYAwPFECmFuEusuZmBtLIBZLbEyaKihvy3tNYaQV+mz2mWb/Uf2HVu2HwOQhJipUuGH8NUn1ygjgxGmdpm0g4u2Jv+QnooMSQAtDOUE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=JsSjYe+F; arc=none smtp.client-ip=90.155.50.34
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="JsSjYe+F"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=casper.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=/ZB3jLeDuyVXGOta57KrwjfIcilXpPZhg+DcknzsLGU=; b=JsSjYe+FKilmfc4e0GANX0IaDV
	duXqcHYHtaDGAcpe1DKPgPqDOZbE+oDMS8c191PnezqEiKTuAl+Z9cdodL2/anK2W5wxP4BFIOc7r
	U1tuX5lppW3v64EwMa4T3JBvS5FxLpkesMYQGVYlsVFpzxBTDoc1MlRCfTYX/KWy7v6OoyXfKQFas
	WyJsi1J4Z9u3n58uHy7iCCfC21aOcrzvGtysPyqwNrUsKJzgF0ddZmyscOAAp8h/pLTkZPHIPw1AF
	dEXQkgM8Vd7IKhFVDnL7oJ1cRbOCM74tKbKZIZ8xgbJ+vM5EkWa75bNZ11teqv8Ep7Q7bIPNIY5I+
	+5vQOUxg==;
Received: from willy by casper.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wSEEZ-00000002aQd-2xdg;
	Wed, 27 May 2026 13:23:43 +0000
Date: Wed, 27 May 2026 14:23:43 +0100
From: Matthew Wilcox <willy@infradead.org>
To: Christoph Hellwig <hch@lst.de>
Cc: "Vlastimil Babka (SUSE)" <vbabka@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Michal Hocko <mhocko@suse.com>,
	Brendan Jackman <jackmanb@google.com>,
	Johannes Weiner <hannes@cmpxchg.org>, Zi Yan <ziy@nvidia.com>,
	Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: revisiting alloc_pages_bulks semantics?
Message-ID: <ahbwX_AdOrtCXS6-@casper.infradead.org>
References: <20260527071816.GA17632@lst.de>
 <df21e8b0-a67b-4b71-8178-91221b596949@kernel.org>
 <20260527121920.GB6079@lst.de>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260527121920.GB6079@lst.de>

On Wed, May 27, 2026 at 02:19:20PM +0200, Christoph Hellwig wrote:
> > > There is one single user (svc_fill_pages in sunrpc) that relies on it.
> > > For everyone else it creates extra burden and is very error prone
> > > (speaking from experience).
> > 
> > Sounds good to me. Will sunrpc be easy to convert, or should it be another
> > flag to opt-in to the current behavior, that it would use?
> 
> I've added Chuck to the Cc list, but from memory sunrpc actually does
> make use of this feature and he objected to previous attempts to
> change it.  So a first step would be to have a lower-level helper
> that works as-is and a wrapper that zeroes the array, even if that
> doesn't feel as efficient as it could be.

I think the problem is that sunrpc uses the pages as a queue instead of
a stack.  If it consumed pages from the end instead of the beginning,
it could just refill the entire tail of the array.
