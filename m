Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3EC1AC2FF;
	Thu,  9 Apr 2026 06:06:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775714813; cv=none; b=LQwFZjUu6E1copG+m4Jpd3aGHY1ViBEjfLcpzI5zj5tq9rXyWPXOwK0KiR2kN9J0H4KeIr0dM/FqIU8/TO6V6Y0jpgBY3wecFJa5akszhJLTSgaRpz4wz0ia77/y9SMA2brWcDIt6EjaKsI0jvF52JU52pXgOdl+VnVyn0NpFvg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775714813; c=relaxed/simple;
	bh=FKtcCNipVXmD2IiBtOU+LSDhnsDYL6gID3nBa9k02vA=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=J1a+fTdMPIFQkU3Eh7FPxL7QHOXycSGf4KDuvIibMvGORCiDLNSH5YRl6IVXFR2IauvWdfGl7JdyhFE9yh3TUXeVuYq0NEa3yZHzJ1gqXmogo+VIcMLfZaoEyJhL9/FmXkAK90HLkj2YImY8kh+YRvx6+yA86+qY28IJtdusPgk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=NoWQsXZR; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="NoWQsXZR"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=MoIk3QXCJ15PUs08yPqRQRJkWDOpoLHAsaU9dEoaDdI=; b=NoWQsXZRjYZWDfbKjd8x8lDS7q
	hqv81mkMVT5Nerz8ZCUOl54FlxVECej5vgAk2MjPAdNjTMin66BXINo6pKCjnKka00/CklqOr1mYb
	lKcHzntcxC6JQ25i8Dm/OLF1UgvSIw+0W2xdgeFg50wC42U8LAk2f6do6HXEFDJcASStIXjfH85Ql
	3jcHuApM1LHFVYzLrcNDBbwMi5mogSDHre1ajepfUEBlPIoJ6iyfwNvHg8J+PLxSI+lM2UExI0XTS
	eWAHEQe+vfgThTrcQCKYrrtWXGgbWh+uyvEQ+r3HKv5FZrqQQY8Il/oA099ANIZ2LhChbsp4HuuRW
	bDWKjZfg==;
Received: from hch by bombadil.infradead.org with local (Exim 4.98.2 #2 (Red Hat Linux))
	id 1wAiXR-00000009k4Z-2Duk;
	Thu, 09 Apr 2026 06:06:49 +0000
Date: Wed, 8 Apr 2026 23:06:49 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@kernel.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
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
	Jens Axboe <axboe@kernel.dk>, Chuck Lever <chuck.lever@oracle.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v2 0/3] mm: improve write performance with RWF_DONTCACHE
Message-ID: <addB-eRg5cXzZhHG@infradead.org>
References: <20260408-dontcache-v2-0-948dec1e756b@kernel.org>
 <c2351220336d0ad99396a331bad34c6177bf354e.camel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c2351220336d0ad99396a331bad34c6177bf354e.camel@kernel.org>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

On Wed, Apr 08, 2026 at 02:45:32PM -0400, Jeff Layton wrote:
> > Assuming that looks OK, I'll probably send a v3. Original cover letter
> > from v1 follows:
> > 
> 
> Actually, that version regressed performance in a couple of cases.
> I think v2 is probably the best approach, on balance.

Limiting writeback to a specific inode has many downsides as I explained
before, so this is not surprising.

> Maybe we can get this into -next so that it can make v7.2?

If you want to target 7.2 we're not in any rush.  If you were trying to
say 7.1 we're way to close too the merge window.  We also haven't
heard from Jens at all, whom I'd really like to look over this.

