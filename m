Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=198.137.202.133
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795196354;
	b=Wz4B0a682g3t10b0BEwvZ0ilMJ0fnbC2IGQkuN2NTD6K2Db6lbSRgnzuZqnuIK/LKv1H
	 JKtLO/GGCRWFS2RN2TTCVkT/j/udjBvgjqRjFonDAgDljq9tVH7LMsgopBdWLn8b024jv
	 nRtsck7graxj5NemMwTkcAnv8OTU48o2mKLV+/BoqzeQ3g4GWjNVry3u3YnWzWktFbHfq
	 2gq7yarAKw8bzmnJwt9WQYJVNESAHli3G0PsvHJNURUqIHspt8JKOhbvpytF1QOyhK0Cv
	 CqeefKmGQB6QceH2nUYjGQ4ul8/MwzEanT1iNkrYK0CdWNXhg+rFXDUzb/D8UELgIRA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795196354;
	h=DMARC-Filter:DKIM-Signature:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-SRS-Rewrite;
	bh=zFeXigSPHuPYCYu3NW90s99hrfhUDEc9Wq95RVe4MLc=;
	b=IsfRpnuYkxc5ZMlJiLfbSqDEErQERm9XaeDzseYU1j6WVh9Nnwy7HHYHVAxy8oEA3aAg
	 3Vpz/zNgUe5j4XxvnbPGvBG8SI2FDomUP3SM8v27oAqi1O0DMMojh9QUTv6MDYTooPeXt
	 h50GG4E0FhoFcYc2+BFdKUNiVNkD4LtCn40jBiiBMffG3afLIDbOgZRG3RfThCFDx/Rn6
	 AqB2MFfCqdBTAVLUlWgvolSnTOe/+UjHxIaELHCiCuO/HMT2An40PX6Qq5dHRXM/Tsbf/
	 oNTTKojOJI22AaS8AFHHEhStyfOsz+uWMW9D/Oe3AMS6hUbG1yZfXVDMVAaaKFd3Orw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=infradead.org;
	spf=none smtp.mailfrom=bombadil.srs.infradead.org;
	dkim=pass header.d=infradead.org header.i=@infradead.org header.a=rsa-sha256 header.s=bombadil.20210309 header.b=YmdsWDPS;
	arc=none smtp.remote-ip=198.137.202.133
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 45DED606A325;
	Fri, 20 Nov 2026 17:39:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 45DED606A325
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.a=rsa-sha256 header.s=bombadil.20210309 header.b=YmdsWDPS
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=zFeXigSPHuPYCYu3NW90s99hrfhUDEc9Wq95RVe4MLc=; b=YmdsWDPSbQ/nrh388OQixpRbGu
	8q6rxrtdzP3EhpW9ey0Ljheu+QAVgtPc4qMRqrETgZ+gn6sP7cq20mYXwOqzFFoU3CfjfoMBvbQTP
	GnPbrxLY6QmwDoE3AFmkRQnF/Ml8gq3EaAU3K5Z2NxWfun3Ka8+MbPTjVB4hFGIBhflewJ8IMdGex
	V1AxHXeR4nwtsc1PqzSEfUHoNwotp2T121ayw/7rexRDi/j8FWVVbq2tDx28i3yeyJP6biY9IYGfF
	TofvKsC7OoBvMm8OZ23BEVfzWPwYBYLNnHfjf9FwrWMPx7yH8JgGmgROWTMphL8QD3kzZgaA1kcR0
	jbfodbhw==;
Received: from hch by bombadil.infradead.org with local (Exim 4.100.1 #2 (Red Hat Linux))
	id 1xUSZi-0000000FjqO-3Oxe;
	Fri, 20 Nov 2026 17:39:06 +0000
Date: Fri, 20 Nov 2026 09:39:02 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Pedro Falcato <pfalcato@suse.de>
Cc: David Hildenbrand <david@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>, Zi Yan <ziy@nvidia.com>,
	"Matthew Wilcox (Oracle)" <willy@infradead.org>,
	Jan Kara <jack@suse.cz>, Lorenzo Stoakes <ljs@kernel.org>,
	John Hubbard <jhubbard@nvidia.com>, Peter Xu <peterx@redhat.com>,
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
Message-ID: <awCFtlgTeUFaqBS-@infradead.org>
References: <20261119-gup-dirty-what-v1-0-236d69f25c24@suse.de>
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
In-Reply-To: <20261119-gup-dirty-what-v1-0-236d69f25c24@suse.de>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

On Thu, Nov 19, 2026 at 08:10:43PM +0000, Pedro Falcato wrote:
>  - there is no problem in usual IO submission, but issues start to pop
>    up with GUP, where the code flow (roughly) becomes:
>         [get_user_pages(), etc]
>            ->page_mkwrite() called here, or before
>              ->private correctly populated with whatever the filesystem
>                expects.
>              folio is marked as dirty, initially.
>        *write finishes*
>        folio_lock();
>        folio_mark_dirty();
>          ->dirty_folio()
>               dirty_folio expects ->private to be populated by
>               ->page_mkwrite(), ->write_begin().
>        folio_unlock();

Writes through GUP are known broken in this an in other ways.  The
fix is not to create band aids, but to phase out the remaining
writers through GUP.  Which is really long overdue, and I'm starting
to get really pissed at the maintainers not fixing that after years
of knowing the bugs and having the infrastructure to fix it.

