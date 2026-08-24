Received: from casper.infradead.org (casper.infradead.org [90.155.50.34])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C26B42DB7BF;
	Mon, 24 Aug 2026 18:17:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=90.155.50.34
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787595474; cv=none; b=K3pLwtHarosZMf1hodBQyGKIuqZp9Eo/zyLwTEOuBR7d+ssIR6Ju7sM4S0e1hRnXjCajHkpO/I0p+ohsj/xOBwKUqarTrAMLT4SsNLpbLCN2sTfNLgcfpZxvYz1Wg3UYDnNL5wp82w8M3N44BNZyjTq9Qa6ORQQ905JVmTx9T/8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787595474; c=relaxed/simple;
	bh=J9/ahY7R5EohyAVPNxeiuF4/j5YfK9eMKYGHxfeTyq4=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=Z84JSQZbnaG0q7ucqvYK7qAE7v+UtelNbPFTGkMnKffclY0MyL16HhZEiNdBX1Lhi2KuyMbGg7QsJK69NZcaeKSWj/Q169Fh2MQ3jBQpcDSYHJEFKTvy45NgKbF+8yPD3DZ67lk8qYH5zROxYJm3H96qI9OJou/kC8qUlWOfWUw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=pass smtp.mailfrom=infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=dMs5oldf; arc=none smtp.client-ip=90.155.50.34
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="dMs5oldf"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=casper.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=YD1GqD83PyV7F9VPUwj4kbqvO6zzJjBsM9hK49aM5to=; b=dMs5oldf5sHbEk2paBx+Aa2NKq
	82ylPnE2ou4HUkWlhpD10V9ADVyG/bIO7FB5Sq1/Fhc2DQGF75Pb6ZrXK6b3mPl7IRsPuUYmHySNI
	uJMfQYkdjUgPh+34yr5oVvFSoGff/wGmCHgyEj2sIX41qWyhBM4EiS3OprdAmjGN9Laickcfd7eHx
	TXCkA49n4cRIQUJ4iC6U+QSZ+AakS//MT84dLtYeRPAm2oD+vNfuG605EQW02X3s6+HSyCSrDhWjo
	M818Izcz1Tsg2Lvfvo0AxZD8zJaRob2LLnnuAuGEuAOX0kTsRTZTUZjzqwcv5rHLMk1hXHQ+I8inD
	VYqGCIGg==;
Received: from willy by casper.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wyZEs-00000007d09-1LER;
	Mon, 24 Aug 2026 18:17:42 +0000
Date: Mon, 24 Aug 2026 19:17:42 +0100
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
Message-ID: <aoyKxvdQdeJQfPHj@casper.infradead.org>
References: <20260820193343.3852967-1-willy@infradead.org>
 <20260820193343.3852967-3-willy@infradead.org>
 <CAJfpegvP3i8ZJc2T=+f4rAhZ4E1QcT5+jC6mQPLxtB-yoK9Brw@mail.gmail.com>
 <aoxHOSC9kTPbKeNq@casper.infradead.org>
 <CAJfpegv3Ak+qNLb=fTSCSz7-taQ3Ui-Hkmqgn4PaGPe=CR4cbQ@mail.gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJfpegv3Ak+qNLb=fTSCSz7-taQ3Ui-Hkmqgn4PaGPe=CR4cbQ@mail.gmail.com>

On Mon, Aug 24, 2026 at 03:49:37PM +0200, Miklos Szeredi wrote:
> On Mon, 24 Aug 2026 at 15:29, Matthew Wilcox <willy@infradead.org> wrote:
> >
> > On Mon, Aug 24, 2026 at 11:05:46AM +0200, Miklos Szeredi wrote:
> 
> > > Maybe add a variant that takes that lock?
> >
> > I don't understand what use that would be.  As soon as that function
> > drops the lock, the pages could be reinstated.  If the caller needs the
> > pages to not come back, it must need to hold the invalidate_lock across
> > the whole operation.
> 
> invalidate_inode_pages2_range() together with launder_page guaranteed
> that no dirty data remained in the cache after that call.   Yes, the
> pages can be reinstated after that but those need faults and the
> server can then serialize those against the invalidation.
> 
> I don't see that guarantee with the filemap_write_and_wait_range()
> (with or without invalidate_lock actually) since the mapping can be
> dirtied again without the filesystem's knowledge.
> 
> Am I missing something?

Well, one of us is!

Before:

fuse_open()
	invalidate_inode_pages2()
		folio_lock()
		folio_unmap_invalidate()
			folio_launder()
		folio_unlock()

After:

fuse_open()
	filemap_invalidate_pages()
		filemap_write_and_wait_range()
		invalidate_inode_pages2_range()
			folio_lock()
			folio_unmap_invalidate()
				folio_test_dirty()
			folio_unlock()

so what's the serialisation that the filesystem can perform in the first
case that it can't perform in the second case?

or alternatively, what's the serialisation that would be useful by
adding a lock/unlock of the invalidate_lock inside
filemap_invalidate_pages()?
