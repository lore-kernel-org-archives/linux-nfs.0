Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 41D7E3CD8AB
	for <linux-nfs@vger.kernel.org>; Thu,  5 Mar 2026 16:11:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1772727097; cv=none; b=ZcLbsdfs9oyHrX5Gqw3ELQjErPVxC3qYC57K9BCv8+F6/uvqI540+0TCOMMpJj6U4uldkH7e5JUKhaLmUwYQwY2f0/xQ/8T9BaxlYErSsdQaE7nvZEM1M/2kMuDgjlSPR+84iwS/h6c8eykUC40WnS1h9HEz47cS4qyF0IRUspM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1772727097; c=relaxed/simple;
	bh=Ts6fNhijqZfQz3V062BDqiSFWtlLLJxI0Pzd3DGnXd0=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=fVSWJafxHi2CAWsEUUv25Hhmmwfe5aWjXPp/c5ePX6Q4hbZU1NeCQBcP07Wh69fqiZ7qPfUWihe4WRz4IdbMW7JZFyd9LG2FZ+Tx8066vc9lcSh8dTMda6icdsVfABIZ9kpvH7DXGHzZ3hAi9W3N2yQfuHyRqD7r9+5GpadWtdQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=bpp7wEEs; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="bpp7wEEs"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=TgelaKl1bISnNs3LcVKWpS+noQ/NTNKwTOIqdcL4gw0=; b=bpp7wEEs06TBEy9BiIqF66fU7g
	x5DYbz0aV0w5Fater3ABSf5Hnwrfdx0VSXdE+K5pKozrLVQa3T0Vbqmlzl9tUoJ4sQVqi+YGuTJ3Z
	eUJbDIYxkJEFsQgNDOhxi+n0Za8CeAlYnhvvTYuV5iYL9zsA1jzOATIxX4mWiktM64aCyYDXmB/Z/
	Cs2GmMxIf7Y9eAVdczkL5QEDUdUAcTBhF6QXYYJaK0j3mn3Fi9eK5TstMqyR6JO30/DD6Rbl+7hZW
	PXW7LJmX/sUBI4wUXhqfW+mcv7IR8ys+1hSaLkLoqbo2sCeZCYQgkmpNbZjbb1VDEUba7ZIXtSetb
	OLDxe5nQ==;
Received: from hch by bombadil.infradead.org with local (Exim 4.98.2 #2 (Red Hat Linux))
	id 1vyBIV-00000002Bfx-2sdG;
	Thu, 05 Mar 2026 16:11:35 +0000
Date: Thu, 5 Mar 2026 08:11:35 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Steve Dickson <steved@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Revert "nfsrahead: enable event-driven mountinfo
 monitoring"
Message-ID: <aamrN6RV9_8RJDuU@infradead.org>
References: <20260305124221.55407-1-steved@redhat.com>
 <aamQbSl40bG5pjD5@infradead.org>
 <6a213da9-7c4f-4912-8ba4-80104a34ddcf@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6a213da9-7c4f-4912-8ba4-80104a34ddcf@redhat.com>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

On Thu, Mar 05, 2026 at 10:31:14AM -0500, Steve Dickson wrote:
> 
> 
> On 3/5/26 9:17 AM, Christoph Hellwig wrote:
> > On Thu, Mar 05, 2026 at 07:42:21AM -0500, Steve Dickson wrote:
> > > This reverts commit 2b62ac4c273a647df07400dc1126fceb76ad96c0.
> > 
> > Why?
> > 
> > 
> https://lore.kernel.org/linux-block/CAHj4cs8URj2fJ7KyP9ViAm6npVOaMiAErnw2uFyPYEU2wb7G_w@mail.gmail.com/T/#t

Please put the reason into the commit log.

