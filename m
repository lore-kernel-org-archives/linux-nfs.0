Received: from casper.infradead.org (casper.infradead.org [90.155.50.34])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6087729B77E;
	Mon, 24 Aug 2026 20:47:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=90.155.50.34
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787604464; cv=none; b=nvHliXv+jZxVYJuzK1gE9YUU4ORgbEBBX0m68gQpei4Oa+RRuJJeuidYVfqt/YVMlC5Sd5On6EQznGfEcOXNS5je+tCSgBlGs/95IJSqpqyYTejMHB5kTQcYBO0bKm8hA7ahP2/2jg/XuS4vuB3aOgpb5j4bqRUa83RSgV+KjRg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787604464; c=relaxed/simple;
	bh=yOXThapvNvCgLifu01NItCV+B87skvWglNWX1ExEEZs=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=cjnOVhVy3B0IawA7DeZs+AJQitzQWM5cqTSro6A1kxCGe0xyN+mpDpLmGMgyRd7h89sOGVm7gUxIq+ltqP2Pk8y0eUcYXaMmheawgf+WMq7GMr3/JKjMTXmi3lZgSYWpmMWg3dDKDv72hInFc2cmy2gi62xFLgZ41xze5s1IIMo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=pass smtp.mailfrom=infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=r9LfvOkj; arc=none smtp.client-ip=90.155.50.34
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="r9LfvOkj"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=casper.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=niEZYxfNIOD72gAedVquSAPl0GL96aOUAIsjWVWnyrs=; b=r9LfvOkjge2amjsBvyE5gj6qMI
	uYvVlQ3b0KYGngAv8XESPmmtwmX5YL31/ZZL/aCv3YA8HiM47NGP857BeCRMrrjzps/Ne9d2cn52v
	zqL2zGvjLLk1nv9syOdx3pvPSZ8lB4ZZOVBgqTtBiLjoK7MD80xjfIWR87mDrmvJgbQIzO6B2iuYH
	wqfSCFzLZJjECzSnGHLMWVk/RyHGkAgVmz+igPSrxnkQPu9UxG3bW9HhbNxyefBXIscvW+/Ut9PSd
	iZrPpiftS7pWBxDvgsL/MprJcvS05WbioAv/k/Wf8gVfSs67WWjwBEeQoBx+YaSMwlZC9Q0pIrjfj
	dHmqFNDQ==;
Received: from willy by casper.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wybZv-00000007nCw-0Kvv;
	Mon, 24 Aug 2026 20:47:35 +0000
Date: Mon, 24 Aug 2026 21:47:34 +0100
From: Matthew Wilcox <willy@infradead.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>,
	Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Marshall <hubcap@omnibond.com>,
	Martin Brandenburg <martin@omnibond.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
	linux-block@vger.kernel.org, linux-btrfs@vger.kernel.org,
	fuse-devel@lists.linux.dev, linux-nfs@vger.kernel.org,
	devel@lists.orangefs.org, Pavel Begunkov <asml.silence@gmail.com>
Subject: Re: [PATCH 2/7] fuse: Use filemap_invalidate_pages()
Message-ID: <aoyt5pL7mXYwSqsG@casper.infradead.org>
References: <20260820193343.3852967-1-willy@infradead.org>
 <20260820193343.3852967-3-willy@infradead.org>
 <CAJfpegvP3i8ZJc2T=+f4rAhZ4E1QcT5+jC6mQPLxtB-yoK9Brw@mail.gmail.com>
 <aoxHOSC9kTPbKeNq@casper.infradead.org>
 <CAJfpegv3Ak+qNLb=fTSCSz7-taQ3Ui-Hkmqgn4PaGPe=CR4cbQ@mail.gmail.com>
 <aoyKxvdQdeJQfPHj@casper.infradead.org>
 <CAJfpegtgenUaudDcvecJuV2_WkkVw=gdcB0Eqg=UFKPMZP1uKQ@mail.gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJfpegtgenUaudDcvecJuV2_WkkVw=gdcB0Eqg=UFKPMZP1uKQ@mail.gmail.com>

On Mon, Aug 24, 2026 at 09:33:03PM +0200, Miklos Szeredi wrote:
> On Mon, 24 Aug 2026 at 20:17, Matthew Wilcox <willy@infradead.org> wrote:
> 
> > Before:
> >
> > fuse_open()
> >         invalidate_inode_pages2()
> >                 folio_lock()
> >                 folio_unmap_invalidate()
> >                         folio_launder()
> >                 folio_unlock()
> >
> > After:
> >
> > fuse_open()
> >         filemap_invalidate_pages()
> >                 filemap_write_and_wait_range()
> >                 invalidate_inode_pages2_range()
> >                         folio_lock()
> >                         folio_unmap_invalidate()
> >                                 folio_test_dirty()
> >                         folio_unlock()
> >
> > so what's the serialisation that the filesystem can perform in the first
> > case that it can't perform in the second case?
> 
> In the second case filemap_write_and_wait_range() won't write protect
> or unmap the page, so it may become dirty after the writeback.

But that can also happen in the first case.  page_mkwrite() can be called
immediately after the folio is unlocked, for example.  Or the folio can
be evicted and replaced with a different folio which is then dirtied.

I've widened the race window, no doubt.  But it was always there.
If you want to prevent something like that from happening, you need
to be holding the invalidate_lock across the call to
filemap_invalidate_folio() and whatever other thing you're doing that
needs those pages clean.

> That can't happen in the first case, since the page is written and
> unmapped while under page lock.
> 
> > or alternatively, what's the serialisation that would be useful by
> > adding a lock/unlock of the invalidate_lock inside
> > filemap_invalidate_pages()?
> 
> Nothing.
> 
> What would prevent this if we'd have writeback + unmap + writeback.

We could do that -- but it won't solve the problem because the pages
could still be redirtied after the second writeback.
