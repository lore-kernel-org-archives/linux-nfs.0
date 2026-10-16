Received: from casper.infradead.org (casper.infradead.org [90.155.50.34])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BEBCC38C406
	for <linux-nfs@vger.kernel.org>; Fri, 16 Oct 2026 11:55:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=90.155.50.34
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792151710; cv=none; b=ErLN6LgCuAxa+TmxbZoL2MMDhUjhPgYeCuL/9D62k122FyPvtoF81oWg8/fjZRfZIffp7ITtiHAT0XSEF1B/3tGLQh0Fq0IcvwKxDea81afBEUCV3qzvH8azV3I8LiU0qJ9lqPJ6W3sj07P5iHES82+AKDXSuFWROeNEsJljtw4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792151710; c=relaxed/simple;
	bh=3OPYvk7hnU/aVH7fHcxffkjZ1fvpOQTxe3B+xRpZY/Q=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=HIB/W/Hs6pbwf8fmAGqJVLjE+QYXoJyQBQUiIm6xdlWn2Dpu0uGZGyeFaFmng2fj86iY32rB2MWsOVd6ZiwBd3laxNclRyfxee7VHoh5EUh+hPWvvNITWOZw8SepZgNEQN8lysORhJiK10TzYKPUeCpFEO6Fi6e8t67BuycWWIs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=pass smtp.mailfrom=infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=FUmK5vIJ; arc=none smtp.client-ip=90.155.50.34
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="FUmK5vIJ"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=casper.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=3OPYvk7hnU/aVH7fHcxffkjZ1fvpOQTxe3B+xRpZY/Q=; b=FUmK5vIJ1XaOAXqCip22POSGd5
	DPbYeJwNMDFcX3y1eXUbFs9mQKr+MrZOgj3i+/IMSTOjMzcrDApFOmBkoriIw8aN5haFKwIL7GM7T
	My+dtDTKIE4eDOO/QrHjjoE6rJTjkW+OMWzFbS/W2G+8LnCVFLe4OXtseu2m8g3MUZ11vKcxz1oV0
	wptolF3bozjXDPd+KJi4YZgQxfd8h7PS0tqmXNoElH5Lwvj0eP+yv7I0tsCyU4V+SnsK395qh8ayA
	GiZNDqvhjJ/awd39DZM74T6YJzhVRaRcB3eBuyngBj0u1fVfuUM9BgzvoLEe+c/V2pR08rGt/zGT5
	OATBlweA==;
Received: from willy by casper.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1xHgWX-00000003MMv-2dyK;
	Fri, 16 Oct 2026 11:54:57 +0000
Date: Fri, 16 Oct 2026 12:54:57 +0100
From: Matthew Wilcox <willy@infradead.org>
To: Jeff Layton <jlayton@kernel.org>
Cc: Mike Snitzer <snitzer@kernel.org>, Chuck Lever <cel@kernel.org>,
	linux-nfs@vger.kernel.org, NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>,
	linux-mm@kvack.org
Subject: Re: [PATCH v4 07/10] mm: add folio_mark_dropbehind() to mark a folio
 dropbehind and account it
Message-ID: <atIQkYA0AZg_z53_@casper.infradead.org>
References: <20261015233309.42999-1-snitzer@kernel.org>
 <20261015233309.42999-8-snitzer@kernel.org>
 <1299ad92163f2eb8fecc06165b3b52f7904f09e9.camel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1299ad92163f2eb8fecc06165b3b52f7904f09e9.camel@kernel.org>

On Fri, Oct 16, 2026 at 07:08:41AM -0400, Jeff Layton wrote:
> This patch and #8 need to be split out and merged via the mm tree.
> They're related but the rest of the series doesn't specifically depend
> on them, and I doubt Chuck wants to carry them.

Patch 9 calls folio_mark_dropbehind()
