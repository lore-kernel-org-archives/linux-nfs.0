Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795786451;
	b=qBKTFBnUrQG0N7i0fKnw+HrdP3WAAkSQwtQZGA3LBjBJfYeGukEn3UavAmyomUhTcm2h
	 ZTSfj99YMBhMEbdhoZj6hwURk/aD/7TsNpvL7t4p1COImbk1VPzRJVplOFpgT16MOAa4g
	 1k/rcGsRRCN7xolmOqlltB21H+vDm2ZMpFnLUtaiYVa7cNVDET6T+IZPCcWGXCnh4sqGL
	 EZ4yrZcidHZR3YpHrjID32QhZnwLDT0WCXJHUBecTuomespH0tB79ZCQ7x+nSPRbxuIdW
	 fXT9XEnZW6Gea/ZqSRenu5XcwR3RAyQLl5obvkgg/i3vBF0JVu+7z5NZD74lno+dYkA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795786451;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=bw7AcYTFsfZOxUWb2+TTJQRmuPhHuS1MdESo/HgQ9UM=;
	b=4Kc04hBT0tm8l2X8WRAdkdj+cMQymwMjK0cPecQ8WVkrsb43ComXwvIlPEEqra7wGfTR
	 XVDf+MrCQrVButwruIzpDBdiYCMPcV+DRve9JyZr1TZZYn95shIfYWof+5SZQmuhUv2Fb
	 kmF1qM4iFGGPU8/vWX4llcHH6A+YYZimAN9CbqVI026K1lwLLxSmOrSWI7zvx3oYedRbk
	 X9tVPo2lSFneMVXARAiFXyeG6vPsLk/gwZhSNe7Byvh7RnMsN/CEbeq4h/kj9eSXr+uCo
	 I50ESNnaAaMKBhgbrtiD5T4P42t8ZACuxxJMsO4PZyfZ7zRkUvqXSY6Me6Jjrcp1L8A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=SkMPJLiU;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8EC09606A31F;
	Fri, 27 Nov 2026 13:34:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=SkMPJLiU
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 625521F0089F;
	Fri, 27 Nov 2026 13:34:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795786450;
	bh=bw7AcYTFsfZOxUWb2+TTJQRmuPhHuS1MdESo/HgQ9UM=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=SkMPJLiU39IRzi16voxJldgz9ENeR2wqtN69W5zIWr5davJPyjjQAt27K3cZcJmwO
	 0U/ym5LMEBeq7YxcjQhB7UPsATwvDEz7DEZb02mr1XvVJj3goxAcvlOOCaomJQ+XM5
	 mPOq0IMN4CniQSJXUNTdN03yWwDz/+MFxSLBtrIUvU6YZfvimgHFrft295hvtacR0V
	 AzcSO39+KQOYyYURqnb9JSURl59wVlmLuSslUL2sqds/fHkMxaX3FzY3S9EBV5azNe
	 5ZTX7zCZl9RSZvosb9ngHNq93kXom/905HkBXZB7tqEfGO4MQiyhXNMVciFca1hVjJ
	 M8OkMdw1MT03w==
Date: Fri, 27 Nov 2026 13:33:58 +0000
From: "Lorenzo Stoakes (ARM)" <ljs@kernel.org>
To: "David Hildenbrand (Arm)" <david@kernel.org>
Cc: Pedro Falcato <pfalcato@suse.de>, Tal Zussman <tz2294@columbia.edu>, 
	Christoph Hellwig <hch@infradead.org>, Miklos Szeredi <miklos@szeredi.hu>, fuse-devel@lists.linux.dev, 
	John Hubbard <jhubbard@nvidia.com>, Jan Kara <jack@suse.cz>, 
	Andrew Morton <akpm@linux-foundation.org>, Zi Yan <ziy@nvidia.com>, 
	"Matthew Wilcox (Oracle)" <willy@infradead.org>, Peter Xu <peterx@redhat.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, linux-ext4@vger.kernel.org, linux-nfs@vger.kernel.org, 
	"Liam R. Howlett" <liam@infradead.org>, Vlastimil Babka <vbabka@kernel.org>, 
	Mike Rapoport <rppt@kernel.org>, Suren Baghdasaryan <surenb@google.com>, 
	Michal Hocko <mhocko@suse.com>, Baolin Wang <baolin.wang@linux.alibaba.com>, 
	Nico Pache <nico.pache@linux.dev>, Ryan Roberts <ryan.roberts@arm.com>, Dev Jain <dev.jain@arm.com>, 
	Barry Song <baohua@kernel.org>, Lance Yang <lance.yang@linux.dev>, 
	Usama Arif <usama.arif@linux.dev>, Kiryl Shutsemau <kas@kernel.org>, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org, Kairui Song <kasong@tencent.com>, Qi Zheng <qi.zheng@linux.dev>, 
	Shakeel Butt <shakeel.butt@linux.dev>, Axel Rasmussen <axelrasmussen@google.com>, 
	Yuanchu Xie <yuanchu@google.com>, Wei Xu <weixugc@google.com>, Baoquan He <baoquan.he@linux.dev>, 
	Michal Hocko <mhocko@kernel.org>, linux-fsdevel@vger.kernel.org, stable@vger.kernel.org
Subject: Re: [PATCH RFC 0/5] mm: GUP dirty + ->release_folio() fixes
Message-ID: <awmGjkhgfr3R7FP_@gremlin>
References: <20261119-gup-dirty-what-v1-0-236d69f25c24@suse.de>
 <4f096d70-6f94-4148-8f47-242b8551e5f9@nvidia.com>
 <awWNyDZT2SVu2Zp9@pedro-suse.tail5790ac.ts.net>
 <55114986-0ba1-4a80-8498-bf674d64e01b@kernel.org>
 <away88BuU8ibcTA5@infradead.org>
 <d088452f-1118-4a06-bc16-1942e523e0fc@kernel.org>
 <20261126022418.3620783-1-tz2294@columbia.edu>
 <50045fa1-0b46-402f-baf0-a08d05282410@kernel.org>
 <awmE8VSlF2VTHLGu@pedro-suse.tail5790ac.ts.net>
 <9c524f3b-d27a-4360-aa56-d6ca4ac1a6ed@kernel.org>
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
In-Reply-To: <9c524f3b-d27a-4360-aa56-d6ca4ac1a6ed@kernel.org>

On Fri, Nov 27, 2026 at 02:31:12PM +0100, David Hildenbrand (Arm) wrote:
> On 11/27/26 14:30, Pedro Falcato wrote:
> > On Thu, Nov 26, 2026 at 07:43:37AM +0100, David Hildenbrand (Arm) wrote:
> >> On 11/26/26 03:24, Tal Zussman wrote:
> >>> +CC Miklos
> >>>
> >>>
> >>> Coincidentally, I sent out a patch to convert fuse_copy_fill() to use
> >>> iov_iter_extract_pages() a few days ago in order to remove its usage of
> >>> set_page_dirty_lock() and address a different race. I think it should
> >>> address the fuse side of this issue as well.
> >>>
> >>> https://lore.kernel.org/all/20261120-fuse-copy-fill-pin-v1-1-72a0d888f140@columbia.edu/
> >
> > Awesome!
> >
> >>
> >> Oh, nice! I was assuming the usual "we use put_page() on some random hidden path
> >> or core code" would make that harder.
> >
> > Right.
> >
> >> I recall that's the reason why vmsplice
> >> still uses FOLL_GET years after we discussed that it should be using
> >> FOLL_PIN|FOLL_LONGTERM.
> >
> > You almost gave me a heart attack, before I remembered these vmspliced pages
> > aren't writable :) That's a battle for another day!
>
> Haha, sorry :)

Actually, because they are VM_MAYWRITE and... nah kidding ;)

--
Cheers, Lorenzo
