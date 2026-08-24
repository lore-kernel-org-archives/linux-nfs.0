Received: from casper.infradead.org (casper.infradead.org [90.155.50.34])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CB8E4426429;
	Mon, 24 Aug 2026 13:29:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=90.155.50.34
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787578180; cv=none; b=jS54w/L8T1A2Yeyss8uYyL4B85tZnDoeXKtDObZesObNsiLLzcstAa0pgbrZsj/V/pHLT4vv9/aBoPCZy3cjujADMn90vS41BW6dDTWxaZH9QKK4H1+lwqMmBayOdSidOUwcA0Se8KNg+0Ki58rPrj+2N/PXFAlvU2V5m+sVKsI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787578180; c=relaxed/simple;
	bh=39FjQlUMP5udyZxk+WGpe9HcVJf/vBCTJVYsMuZuSuY=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=jO4IWvN/6FJoUw73i0quGuFjAM/ZQW+oNyz3DcLyxSlWRnVxZtwhKWNI5g+rEcJPo3cg7VjSrPdleZBZYQVqtVT9YkMmLhh23hOewSprPW7asq+nOD+d5r4u+sCk9JyHe5nQR0UFBgJblWyoq2LoGtdg3+iBext2YnHi7R7ZTeU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=pass smtp.mailfrom=infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=DVpXuCgB; arc=none smtp.client-ip=90.155.50.34
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="DVpXuCgB"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=casper.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=UP1TeJcQT74aqE7HfHCPzdq0084a2GndPFA/TBwUbHY=; b=DVpXuCgBWzg4bh1HoyTUjrvA7a
	g10c2SRZCIct6G9ZFfmQ2xDtSRhzhvqg2iqKHeN34oUDs2mF8AkL4J1MbE3654XNJFqg/ZdbF4oxj
	pf2I0N7VJIOWBRcdbFZgSYn9avDzAW+Xx+qe+fjTKty5JOw0KvHc2fk4qUalN5QpwUDn9VN4e6wDh
	W29tgfU11wmdEgc6SYoRRgsdTfw38IlXNfwZYxT15ovSXkeoFOtT4JVo27hfDLiGm72vzie5Vf2fH
	ENPz5NXe8NNZi5OSbLqQgl6OKMlEWF3mvgt5/cF6qcPLFK6DFenQCIt/gE91p/L6xfUTQUq4PmRu9
	pCTg9upQ==;
Received: from willy by casper.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wyUjx-00000007HHf-3ewO;
	Mon, 24 Aug 2026 13:29:29 +0000
Date: Mon, 24 Aug 2026 14:29:29 +0100
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
Message-ID: <aoxHOSC9kTPbKeNq@casper.infradead.org>
References: <20260820193343.3852967-1-willy@infradead.org>
 <20260820193343.3852967-3-willy@infradead.org>
 <CAJfpegvP3i8ZJc2T=+f4rAhZ4E1QcT5+jC6mQPLxtB-yoK9Brw@mail.gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJfpegvP3i8ZJc2T=+f4rAhZ4E1QcT5+jC6mQPLxtB-yoK9Brw@mail.gmail.com>

On Mon, Aug 24, 2026 at 11:05:46AM +0200, Miklos Szeredi wrote:
> On Thu, 20 Aug 2026 at 21:34, Matthew Wilcox (Oracle)
> <willy@infradead.org> wrote:
> >
> > FUSE relies on invalidate_inode_pages2() / invalidate_inode_pages2_range()
> > doing writeback by calling fuse_launder_folio().  While this works, it
> > is inefficient as each page is written back and waited for individually.
> > Far better to call filemap_invalidate_pages() which will do a bulk write
> > first, then remove the page cache.
> 
> filemap_invalidate_page() suggests to use invalidate_lock to prevent
> races with pages coming back.  I'm not sure that without it the
> behavior is identical.
> 
> Maybe add a variant that takes that lock?

I don't understand what use that would be.  As soon as that function
drops the lock, the pages could be reinstated.  If the caller needs the
pages to not come back, it must need to hold the invalidate_lock across
the whole operation.

Before any filesystem people get funny ideas about closing the O_DIRECT
race, you can't do that because you'll deadlock on doing I/O to the same
file that you've mmaped.
