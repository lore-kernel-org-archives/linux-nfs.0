Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 573D7246782
	for <linux-nfs@vger.kernel.org>; Thu,  5 Mar 2026 14:17:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1772720240; cv=none; b=a2BNGBLmRi66WUTWbzyqJDKdeahxVgto8De8Ek0UGLnJ3qo1YFrFq+QS8ce0tYFnZY0Tqna1y/U/I21kj6aQESUar/BDedAErWFDAIn6Fqgv325KD2ags7S9PLmO/qIu3BjWzQV+HcWZezLv1u9eZW5n2mhAEXFY6jTqf62bepY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1772720240; c=relaxed/simple;
	bh=HgfFtoqK3MkgmLqD02rK+nUDhnw2+dq7UVAT/tJ+nBw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=iIA+naBci4f+zX2M7hoIUOF+8hR1AUIrFhVQ6Ulikt7PQ0CZA/ANxuYD4/ZMJ3UiQ8Che+GSbYkN/lwO4Jeum6lX4zHYGF6/FCzaJiM7JFit7wXO8KFHRjou0NjBhnccD87ZzYPP3MlmqHGQcSqpyQIGB8L/zGu8Fn+1NBIFmcA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=yK735osm; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="yK735osm"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=HgfFtoqK3MkgmLqD02rK+nUDhnw2+dq7UVAT/tJ+nBw=; b=yK735osm2sWvNDAuaRh6pdczAp
	RQ16csXV8E54AO8P/imgdN1hlBpyS5aJkyCiQh7XipLIOpAnZmKovpStZilY5ySHd/oRdOS4EB7mT
	IAaq7nECAoZCrh2YJ4sKMOP8JfAxqDVIebLxciooPQggkiVwZao/hWeFz5khcx2pNF5Su7jyi1E/X
	PM/Er5b9iIwiZjXzBNLI7HK6KWoYYrnYI6XHOdmQ6h8Vbthe4XcH29xt6C1OinKnWGRBEY4O7973m
	ojvyYRmN2JtTLbO/HyySitgNTTUSSVkVtt2VJfyiGF8DeOIgdvy0/fSXf7tu8xi9keou4eygG3o6g
	/Ui7n8mA==;
Received: from hch by bombadil.infradead.org with local (Exim 4.98.2 #2 (Red Hat Linux))
	id 1vy9Vt-00000001vwH-2d7N;
	Thu, 05 Mar 2026 14:17:17 +0000
Date: Thu, 5 Mar 2026 06:17:17 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Revert "nfsrahead: enable event-driven mountinfo
 monitoring"
Message-ID: <aamQbSl40bG5pjD5@infradead.org>
References: <20260305124221.55407-1-steved@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260305124221.55407-1-steved@redhat.com>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

On Thu, Mar 05, 2026 at 07:42:21AM -0500, Steve Dickson wrote:
> This reverts commit 2b62ac4c273a647df07400dc1126fceb76ad96c0.

Why?

