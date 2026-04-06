Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7EA7631F982;
	Mon,  6 Apr 2026 05:44:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775454283; cv=none; b=BjE95XVMifvlbsOWaQHrlUTMNVd/6lprJIUjOPlA6Zw2oDylYHIecLkZyAw6FMlT7WKPTbf5tgQyf4rZ6Br3m1mgDpdMG6BXZKr8BvTFA/tMaMJ8Yj1KL04Ch8z3QmOEAm5K3pfKB2Ut2D2PC5zGzlDxdS7egctpdQnOljfag78=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775454283; c=relaxed/simple;
	bh=R0tmwk/2P398nPX2de9I5DOEX067PRYwRoQvfH/CW0Q=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=pMJILDT04nNNlHQBhGC0IFZVuSu7in55kAH//xSU0uW3rXf+SzYpb3SW6T8iykUmySnrLdZSqbNBk1rSV3V+UDrTUJE28mLQVQfy5eOqEHxJcjUZwfh5mS1dOEZ17uVelegs5zFyDXxxqeMtOnIKDzeSkURK9noA6kt+hWWuBQI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=ys78b5N4; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ys78b5N4"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=M5LxlInPJ7/UGCLgthuGl+ND/trl20UHwe3EP42gW3U=; b=ys78b5N4ODFhtd/VHJZKyPEIEZ
	CAcNY121v6nTNVo9GQQ+SlfrgslNKsqT2ERk4mnIwvtl7Bmx2Sl1mc5SK0TrcAEJoRBVwT/klowrG
	CFVwVrIhadbiNGNhHpGjTO8LuZ9Et76aN6pSvfxqM/eSUeFVn3llD/d7f9nUNEfykhyetHqnsVzDJ
	AE5MFa1K1MD1h6GcM2fxQDeP7Zj+RhV5rEdRbQHk+tSBNjW66F9azNPTorQCr6BzpJg/TQRa11kd4
	BPV3nVQuU7ybNBrZfv3NujPJp2MqsopoNsN9JOgGvx1z9vm5egOwOtaCC8gj++QdHNty6Plcdxesl
	DPS6KcZw==;
Received: from hch by bombadil.infradead.org with local (Exim 4.98.2 #2 (Red Hat Linux))
	id 1w9clL-00000004ozj-0Jpu;
	Mon, 06 Apr 2026 05:44:39 +0000
Date: Sun, 5 Apr 2026 22:44:39 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@kernel.org>
Cc: Christoph Hellwig <hch@infradead.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>,
	"Matthew Wilcox (Oracle)" <willy@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Hildenbrand <david@kernel.org>,
	Lorenzo Stoakes <ljs@kernel.org>,
	"Liam R. Howlett" <Liam.Howlett@oracle.com>,
	Vlastimil Babka <vbabka@kernel.org>,
	Mike Rapoport <rppt@kernel.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Michal Hocko <mhocko@suse.com>, Mike Snitzer <snitzer@kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH 1/4] mm: fix IOCB_DONTCACHE write performance with
 rate-limited writeback
Message-ID: <adNIR8atJj38IL9p@infradead.org>
References: <20260401-dontcache-v1-0-1f5746fab47a@kernel.org>
 <20260401-dontcache-v1-1-1f5746fab47a@kernel.org>
 <ac385Il8l-krKEOQ@infradead.org>
 <01dd135adf38e35492d957a35e22c4ba5c2283d1.camel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01dd135adf38e35492d957a35e22c4ba5c2283d1.camel@kernel.org>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

On Thu, Apr 02, 2026 at 08:28:42AM -0400, Jeff Layton wrote:
> > On Wed, Apr 01, 2026 at 03:10:58PM -0400, Jeff Layton wrote:
> > > IOCB_DONTCACHE calls filemap_flush_range() with nr_to_write=LONG_MAX
> > > on every write, which flushes all dirty pages in the written range.
> > > 
> > > Under concurrent writers this creates severe serialization on the
> > > writeback submission path, causing throughput to collapse to ~47% of
> > > buffered I/O with multi-second tail latency.  Even single-client
> > > sequential writes suffer: on a 512GB file with 256GB RAM, the
> > > aggressive flushing triggers dirty throttling that limits throughput
> > > to 575 MB/s vs 1442 MB/s with rate-limited writeback.
> > 
> > I'm not sure the first how you think the first paragraph relate to
> > the second.
> > 
> 
> The belief is that under heavy parallel write workload on the same
> inode, the writers all end up stacking up on the mapping's xa_lock.
> However as Ritesh points out, I should probably confirm that with perf.

But nr_to_write should not change anything.  If .range_start and
.range_end are set in a writeback_iter() loop, writeback_iter will try to
get and writeback every page in the range.  Setting nr_to_write in
addition to that could only reduce the amount written if it was less than
the size of the range, which in your patch it isn't.

In fact we should probably have a debug check to never set both a range
and nr_to_write as that combination doesn't make sense.

