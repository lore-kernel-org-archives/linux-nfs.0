Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=198.137.202.133
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795601147;
	b=PcCZR6gKcYu+Ha5QUA2x7oqYjfrwHBExYD/Gv8Vju9lE7NkHmPC40P1/DZSIZsurXUPT
	 j26bee/Zz2MP83K34bP0gFEAJkPZAN3hCOiYINEEdVmPdfX/8ekN/GTM229T0Zz1JZIg6
	 hWgnbVrCIUHBwnjTo9lmx8j0mEq35VC7EepeIFFnsQWY0yUbC78PCqWDE868esV5JKonB
	 d33lIK57H5h1C9Fc7hynw94iGJi7IvrZMAh8/ZYOHdoc6uu2jS0MJ2GCjBGw9yHj+l/KL
	 ztaoAVsYsi/u/IQVHGUxaSkqPuyV01EA/ICutd8lVscGU0xxpfSqXsjNd6X8n89oyWg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795601147;
	h=DMARC-Filter:DKIM-Signature:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-SRS-Rewrite;
	bh=lVzOnSLOiNwp7oTUU4Cf9rSv1I0m0hohY9lma3fv+uA=;
	b=ViFPaPURfZpxkPWhPbJMt0VYxM6BPRLNG/YWJQNNYyvToPzlDcIW2xVWCt4f60IdoAhp
	 0Yc3MBT89PV5+49bl5saXjHA+L2h7tH+eeCVeIA004Kl6Ct9WQurFLy+qtyNQoiwgeDIv
	 tCBC0CxRZPF6WqA1tZYa6s+suP8pzmF+4il04/MabwRwBI15rXicNf4PkI9gkscd98gQQ
	 2lBAaU4Knt9AHyp6g791r6tdYxpIYiEwe1VItGYMG3CS6qDR4KLhT1J4VuTNv+fREBAdX
	 vKaVDVUP+/gV8u9WCSH4GlddgjDCU5itgurwXoUivCpOYCe8oeqVB08IhyD/RElkHQw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=infradead.org;
	spf=none smtp.mailfrom=bombadil.srs.infradead.org;
	dkim=pass header.d=infradead.org header.i=@infradead.org header.a=rsa-sha256 header.s=bombadil.20210309 header.b=DK7Z9izk;
	arc=none smtp.remote-ip=198.137.202.133
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 51E92606A323;
	Wed, 25 Nov 2026 10:05:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 51E92606A323
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.a=rsa-sha256 header.s=bombadil.20210309 header.b=DK7Z9izk
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=lVzOnSLOiNwp7oTUU4Cf9rSv1I0m0hohY9lma3fv+uA=; b=DK7Z9izk01BpR7A/zkj0WwMYoA
	CoXufy7m7SRtXrx5IULq0pQpJnIW8G6faQ9ewDcD82OXfTdNIePjZvz+VxYCrF5csf0R2efUoiFiJ
	sozucpD6cRGf1qTCeHiT18MUWVZQHoZrXlWetQ9sztRVHA924bPfv+IHyEk1pHuDSgvhZfklkwvAt
	Fny0Oz4fK12vr40pmyJyxdVEAFy4L6hJopNcjPngsA1YgMc4VpSCAU+dlYyWzBXkXag0WLO7DQ72X
	L3kfXB5i9W0Bk1KTGrtW9ZQGkcwHGA4dF0Bops+aJlS0LY3HYwIwKJyv8CHoYsFe6H7idIQ09tp1a
	4zfVHw2Q==;
Received: from hch by bombadil.infradead.org with local (Exim 4.100.1 #2 (Red Hat Linux))
	id 1xW9sh-00000009PVf-08Ll;
	Wed, 25 Nov 2026 10:05:39 +0000
Date: Wed, 25 Nov 2026 02:05:39 -0800
From: Christoph Hellwig <hch@infradead.org>
To: "David Hildenbrand (Arm)" <david@kernel.org>
Cc: Pedro Falcato <pfalcato@suse.de>, John Hubbard <jhubbard@nvidia.com>,
	Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>,
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
Message-ID: <away88BuU8ibcTA5@infradead.org>
References: <20261119-gup-dirty-what-v1-0-236d69f25c24@suse.de>
 <4f096d70-6f94-4148-8f47-242b8551e5f9@nvidia.com>
 <awWNyDZT2SVu2Zp9@pedro-suse.tail5790ac.ts.net>
 <55114986-0ba1-4a80-8498-bf674d64e01b@kernel.org>
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
In-Reply-To: <55114986-0ba1-4a80-8498-bf674d64e01b@kernel.org>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

On Wed, Nov 25, 2026 at 10:50:42AM +0100, David Hildenbrand (Arm) wrote:
> When I looked into this issue, there were some problematic things.
> 
> We have some odd drivers that use FOLL_GET|FOLL_WRITE, but I am not too
> concerned about them.
> 
> But are ways where unprivileged users can mess with  FOLL_GET|FOLL_WRITE
> references to trigger this.
> 
> I think the two that stand out are:
> 
> 1) /proc/self/mem access using mem_rw() -> access_remote_vm()
> 
> User can write to a writable-mapped page-cache PTE. Then we can race with
> removal of folio metadta, to then set the folio dirty afterwards.
> 
> I remember a good reason to not convert these paths in the past (we are not
> performing DMA).

I don't think that is a good reason.  For file system backed VMAs we
really need the pin to be able to do someting sane, DMA or not.

> 1) We fix all such cases now where unprivileged users can trigger this,
>    converting to FOLL_PIN.

We need to, if not for this series then for all the other outstanding
issues with GUP writes.

