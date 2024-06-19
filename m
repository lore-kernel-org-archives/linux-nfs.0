Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A602574E0A
	for <linux-nfs@vger.kernel.org>; Wed, 19 Jun 2024 07:15:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1718781323; cv=none; b=NXJfOfSPtK1/6S4ZXQJKpy9jID2WF6u+o7Cn6hwAGpj3exDeW1ZOalTJOmbDM5eQZWYRoaTb8y7115XifSxiKC58ORBor5RlfU1gw1OGfcVUMUxzP9Xb0UuI4qIxVJsA04fc4i39QQ+c6XLA92HSxCYU+ABpLhGoqIJYtGnfwGc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1718781323; c=relaxed/simple;
	bh=TgNjLZoTAa8DZllaU0YBB5WFqek3SJcGDmF7xp4rJH8=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=Ixkva11BGHrW7CeLNbjM2gr4KpI3nU0VBxDrRZ2SXJwvXR0KzRNIZun2ogb50Kars7OkgUmrx4/iAugPBtV8d2u4doyQxdQwZDQBr03PwIwmcjzYobr5DkbrquiKTRoUvN3f2oZccCmxoel9VM9R7rRyrSDCSuCnBTK1e+Dbcf8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=nCgjMeRD; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="nCgjMeRD"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=d2anFDCvIFs4/5r/7anLz2sZpOra4i5zCBMU9xnjo1A=; b=nCgjMeRDFEPEKnEVm4Qolo7QGc
	B6hVjKw/78ctAGAA+J40SlWmM/wAqPt+W/mSlMU5ewwmilK4WhWSq1Ex7H+4af5jGkRS1fVODqGaH
	QUogw33m9Tq56pUDbGSi0fBNdudqkcr3WFvSxlgags772iZVQS4OCMubaMCLLXjD66q3FDYsPpY4t
	aRgjtGDx0qyoYQlriQvmRFDK64fh9Ko7MQtcpiX7J/63+Hu0/Cn98JNYsrwJFaecOdJ3Ff/bNEJLO
	zGkBYOMa36AqJV8TBytxokZV4dY54AHC8LlEcQ8r7A4fNS9kCihCIimngEXnlEiyrUK3R+5bGuZjP
	GdpaO4ww==;
Received: from hch by bombadil.infradead.org with local (Exim 4.97.1 #2 (Red Hat Linux))
	id 1sJpXN-000000009l7-26ae;
	Wed, 19 Jun 2024 07:15:21 +0000
Date: Wed, 19 Jun 2024 00:15:21 -0700
From: Christoph Hellwig <hch@infradead.org>
To: NeilBrown <neilb@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>,
	Mike Snitzer <snitzer@kernel.org>, linux-nfs@vger.kernel.org,
	Jeff Layton <jlayton@kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	Trond Myklebust <trondmy@hammerspace.com>, snitzer@hammerspace.com
Subject: Re: [PATCH v5 00/19] nfs/nfsd: add support for localio
Message-ID: <ZnKFia78w7oQdwKi@infradead.org>
References: <20240618201949.81977-1-snitzer@kernel.org>
 <ZnJxTsUuAkenmvWP@infradead.org>
 <171878101003.14261.1089014272023335768@noble.neil.brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <171878101003.14261.1089014272023335768@noble.neil.brown.name>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

On Wed, Jun 19, 2024 at 05:10:10PM +1000, NeilBrown wrote:
> Is that requirement documented somewhere?

Trond has responded with that policy to various in progress features
in the past for the client.  I think it also is a generally very useful
policy.  (Note that we ignore it with the NFSv3 side band protocols,
but that is ancient past)

> Not that I doubt it, but it
> would be nice to know where it is explicit.  I couldn't quickly find
> anything in Documentation/

Agreed.

