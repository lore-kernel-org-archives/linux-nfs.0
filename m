Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=198.137.202.133
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795592184;
	b=KCemE8Hyda2j6K90El/OsuIcMveR78lEOybRe2iAR8fdaYSGWa1IVvonu2RRLr2Tb2F3
	 WYfRdYceYRAP1y2wYtvDcsfnfW0IhPNV7sUaxFZkkWVSNAXKZzGbYa5J6Ib6OcNOYYXHt
	 nDb83vbBD6AnKuePXLGKQJp8P4hLCa3zSdr9tKXN6FFDYGc69jRHlg00uwYJHuHPi6lwK
	 R7YFx+u5hckzNhdnhIK65xIp55ijXgwOsP7ClfCeIjnDzQ14pDpUXw7pDS6uTCd6KyVI6
	 pEm5oY1mhPsIg1aaX6VNCuRZ3c4P6K5lYu8ccoG6XoyMZlXTOXRrUw1xwQk4JPXwDZA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795592184;
	h=DMARC-Filter:DKIM-Signature:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-SRS-Rewrite;
	bh=NqNmpPsXgETS8dZeuiCyJlLE3rCmwYk+XFbPXhBfg4U=;
	b=TfaJxgyHtTH0UCdjE2SsFapAUQpeiBt/ymZgUU8lV50hdt43KxkN4i/yjUpK75x9IcLW
	 KZF0yLt5I68jxgO2NWPhBfbg8ud3wTwf4901qgWZnHxeUpRFABAYnvkpNHOxevugg8CM8
	 n1hNEVgZJv8omrqc97YFkoB/k18+5hB99VmlaL5MFCe6e0Wbbrlr+4CV59+LW5n1jO3G7
	 q25kt23kvIKBigRxv+xT/8TuGvquTy/U+Q7c6uX49dWmYwPaGdkn/AMCvLYhcYwP+YQzd
	 SjRM15G+8MkEul1qB1DMWps7q/m2w6dgM2zvucth8CET+fSZDuWcM7VxpCklhb6c2NQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=infradead.org;
	spf=none smtp.mailfrom=bombadil.srs.infradead.org;
	dkim=pass header.d=infradead.org header.i=@infradead.org header.a=rsa-sha256 header.s=bombadil.20210309 header.b=v8EOTEaR;
	arc=none smtp.remote-ip=198.137.202.133
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 27F8B606A332;
	Wed, 25 Nov 2026 07:36:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 27F8B606A332
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.a=rsa-sha256 header.s=bombadil.20210309 header.b=v8EOTEaR
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=NqNmpPsXgETS8dZeuiCyJlLE3rCmwYk+XFbPXhBfg4U=; b=v8EOTEaRlkbw5Q1MD4ATdrS8Du
	2wLhbbgEsGmVs2gzSbe0zfglIVkfdWxz0ovS9CWjZwEl1CGJ2/C7bDC7X3WguhCzxTmDvhE7lnkdB
	2PdOthUl8XjMxaiLMQS4DnMzgiwDG9gkZMZ/MgOxviFcgX11LYqlvEvZ9qIHOuMPnlfD6S7+/WcLZ
	x78t4cRSYCT/NuBnjkRcOSbjdyN8MJavl4xXiAweXPTJalZVcgJgOIkJh5lrxmc7BwYeSj0BK7DW3
	D5sQTHw1xvNoOL5nVGPUXJgyiWNirG1cAYedkL4VUTnWGojZcvbrSgdl0Tsg5R6yhsibfI/6ruAfJ
	7f0262bg==;
Received: from hch by bombadil.infradead.org with local (Exim 4.100.1 #2 (Red Hat Linux))
	id 1xW7Y9-00000008uf8-3ovC;
	Wed, 25 Nov 2026 07:36:17 +0000
Date: Tue, 24 Nov 2026 23:36:17 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Pedro Falcato <pfalcato@suse.de>
Cc: John Hubbard <jhubbard@nvidia.com>,
	Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>,
	David Hildenbrand <david@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>, Zi Yan <ziy@nvidia.com>,
	"Matthew Wilcox (Oracle)" <willy@infradead.org>,
	Lorenzo Stoakes <ljs@kernel.org>, Peter Xu <peterx@redhat.com>,
	Johannes Weiner <hannes@cmpxchg.org>, linux-ext4@vger.kernel.org,
	linux-nfs@vger.kernel.org, "Liam R. Howlett" <liam@infradead.org>,
	Vlastimil Babka <vbabka@kernel.org>,
	Mike Rapoport <rppt@kernel.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Michal Hocko <mhocko@suse.com>,
	Baolin Wang <baolin.wang@linux.alibaba.com>,
	Nico Pache <nico.pache@linux.dev>,
	Ryan Roberts <ryan.roberts@arm.com>, Dev Jain <dev.jain@arm.com>,
	Barry Song <baohua@kernel.org>, Lance Yang <lance.yang@linux.dev>,
	Usama Arif <usama.arif@linux.dev>, Kiryl Shutsemau <kas@kernel.org>,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Kairui Song <kasong@tencent.com>, Qi Zheng <qi.zheng@linux.dev>,
	Shakeel Butt <shakeel.butt@linux.dev>,
	Axel Rasmussen <axelrasmussen@google.com>,
	Yuanchu Xie <yuanchu@google.com>, Wei Xu <weixugc@google.com>,
	Baoquan He <baoquan.he@linux.dev>, Michal Hocko <mhocko@kernel.org>,
	linux-fsdevel@vger.kernel.org, stable@vger.kernel.org
Subject: Re: [PATCH RFC 0/5] mm: GUP dirty + ->release_folio() fixes
Message-ID: <awaP8a3GaI3LCcuw@infradead.org>
References: <20261119-gup-dirty-what-v1-0-236d69f25c24@suse.de>
 <4f096d70-6f94-4148-8f47-242b8551e5f9@nvidia.com>
 <awWNyDZT2SVu2Zp9@pedro-suse.tail5790ac.ts.net>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <awWNyDZT2SVu2Zp9@pedro-suse.tail5790ac.ts.net>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

On Tue, Nov 24, 2026 at 01:37:43PM +0000, Pedro Falcato wrote:
> > pin_user_pages() was specifically introduced for this exact class of
> > problem. get_user_pages() is now meant for other, much more limited cases.
> > I've attempted to document that, here:
> > 
> >     https://docs.kernel.org/core-api/pin_user_pages.html
> 
> Ok, so I guess you want me to drop the hacks to make GUP FOLL_WRITE not
> screw itself over? To be clear, the rest is still broken, even with pin_user_pages().
> It just means we get nicer looking fixes, and I can drop patch 3.

Yes.  And maybe start looking into fixing GUP FOLL_WRITE users if there
are any that you ran into or which are relevant to your workload.

> It's unclear (to me) whether we care about any straggling get_user_pages
> FOLL_WRITE users. A quick look around doesn't find me many; most seem to have
> been converted to pin_user_pages() (though, admittedly, I don't know how many
> of these are converted in stable; do we care?). Perhaps piling on a patch
> to simply disallow get_user_pages(FOLL_WRITE) is ok? Giving Lorenzo's idea
> a go again :)

I fear this is going to to break quite a lot of things.  Although given
how long we've asked about this maybe we should at least send a patch
to it with all relevant maintainers Cced and queue it up in -next for
a while.

