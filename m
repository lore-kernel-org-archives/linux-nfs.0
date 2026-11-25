Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=198.137.202.133
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795616754;
	b=SoYCvC2nV8I1dUVpPsR6CbwXxAptjtW88PcK+wvty8DfE2FDutjJztQsxguFh1HkV2nM
	 8zx4sKVCRK/0SCb+U1Ox1JY1ycMlMMPSGoL9lH53/a77PFq05lfv0dSqWbxVOltg0Sa4j
	 E/mQw+zSUWu/nDSCseImgYVNtBzXdQGCw5zCYuMtm2AUsY9GdbioQIb8UxFfEoPhYo4Dt
	 xSCPnnrFCFs+hdOOOaMcomZriUafzMNyvjxuQ3QJOkLBe2+MnXBVXPzHZsQJme/QsLAaN
	 YGtXvgOyYlHnxQxm/KQ1y/tXcvob21GETij23XFdDGwPFhzY9ExGbOBh6TcDVy3bRIw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795616754;
	h=DMARC-Filter:DKIM-Signature:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-SRS-Rewrite;
	bh=qUuiYfPMGF1dYU/3s8nfXtw2BbGEHy61uU94+Ks01XY=;
	b=PLbIAzGUZi42jPvsvl2u3BYEn2f3GTv5PxSaqJMsWIdUOqp5Hwo6P37BqVVs3Icw8aFJ
	 uVk2DbqJadiFMGwDSJJGX6QtQpd6XOzOboWeAxBQEWxBBHqCNnnOMTIhqvcrcYTPumIGj
	 FmyduXM+i1KHHAyTodGiRTK1B014aZeCsoznnou7c/6eSs57n4dGwTO70bvBgUPqQh40V
	 Hyc6fQwk1v01l1EVL3eZwJrBE3D1TwZb1toH8ezwzdgE5ZPDKZ3i2hdCvupL+cHcta8Jj
	 Bzhg9Ntys4RGXnE4WVjdOPnZ6pCQeTmJsoN1BN5W26Rwwn6H1brr47ekEhBRXFM2oyg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=infradead.org;
	spf=none smtp.mailfrom=bombadil.srs.infradead.org;
	dkim=pass header.d=infradead.org header.i=@infradead.org header.a=rsa-sha256 header.s=bombadil.20210309 header.b=SPVQka5q;
	arc=none smtp.remote-ip=198.137.202.133
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 21955606A31E;
	Wed, 25 Nov 2026 14:25:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 21955606A31E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.a=rsa-sha256 header.s=bombadil.20210309 header.b=SPVQka5q
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=qUuiYfPMGF1dYU/3s8nfXtw2BbGEHy61uU94+Ks01XY=; b=SPVQka5q6b+Q1YM0gqBdrJp3y3
	UUUokphX0g5eOWTiYvKvIDnraP8DhH9YtPY1ZVZmsYKhEi7+gXw3fYCn4rPNoFx2DLd55U804oNgy
	BpAC/5lODMecYTLyeGz5nCdxDEtSTYfIvUTVe8FbTHsbr0cIOgfgv0jPn+sHtL6DMlT8tuSRuUd6v
	32FH4VYNd9i9qBT2ZAx4KCl5vVK5/EmscHlH4AaNOdMwQCsBZIDp6aSZpqVQ4A5WpNM8a/Uxl+XzR
	DKPxKHf0vYby5fO+XwYhJ+FBMHHCrLpsCuR4fOwgm09h/UIcEa50ozW2eGgy3J1Rf3BkAR21O08IJ
	cQO/zxyw==;
Received: from hch by bombadil.infradead.org with local (Exim 4.100.1 #2 (Red Hat Linux))
	id 1xWDwO-0000000A9gO-01yg;
	Wed, 25 Nov 2026 14:25:44 +0000
Date: Wed, 25 Nov 2026 06:25:43 -0800
From: Christoph Hellwig <hch@infradead.org>
To: "David Hildenbrand (Arm)" <david@kernel.org>
Cc: Christoph Hellwig <hch@infradead.org>, Pedro Falcato <pfalcato@suse.de>,
	John Hubbard <jhubbard@nvidia.com>, Jan Kara <jack@suse.cz>,
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
Message-ID: <awbv55FryMamHvVP@infradead.org>
References: <20261119-gup-dirty-what-v1-0-236d69f25c24@suse.de>
 <4f096d70-6f94-4148-8f47-242b8551e5f9@nvidia.com>
 <awWNyDZT2SVu2Zp9@pedro-suse.tail5790ac.ts.net>
 <55114986-0ba1-4a80-8498-bf674d64e01b@kernel.org>
 <away88BuU8ibcTA5@infradead.org>
 <d088452f-1118-4a06-bc16-1942e523e0fc@kernel.org>
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
In-Reply-To: <d088452f-1118-4a06-bc16-1942e523e0fc@kernel.org>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

On Wed, Nov 25, 2026 at 11:19:18AM +0100, David Hildenbrand (Arm) wrote:
> > I don't think that is a good reason.  For file system backed VMAs we
> > really need the pin to be able to do someting sane, DMA or not.
> > 
> >> 1) We fix all such cases now where unprivileged users can trigger this,
> >>    converting to FOLL_PIN.
> > 
> > We need to, if not for this series then for all the other outstanding
> > issues with GUP writes.
> 
> Cool, and I agree (that's why I placed it at 1).
> 
> But who is "we"? Because I recall that "we" wanted to do that a while ago.
> 
> (I won't be "we" ;) Pedro, can you take a look? I'm afraid the fuse thing might
> be the harder nut to crack)

The collective of MM/FS integrity interested people (for which the
recipient list is a good proxy) plus the maintainers of the code
still writing through FOLL_GET.

