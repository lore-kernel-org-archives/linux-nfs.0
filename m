Received: from casper.infradead.org (casper.infradead.org [90.155.50.34])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7D09A2EA732;
	Thu,  4 Jun 2026 14:46:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=90.155.50.34
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780584403; cv=none; b=nYCgH+12EcwSHr53FlXnGbFBYs/M5z4cU8SEGFH8l4bvlzfGjKf1Qxui73hyqfhCDmYmg8rO7jE3rIi2Omt/WTjOnARItL7LwVTwFzoVnwU8FGBmUnhcZr3Crm1YqPnJNyzeJ9bQcS7wWHlGB0D/mZ02g659AaTRdYv0YZbMb3M=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780584403; c=relaxed/simple;
	bh=kUWiuBPrxX5exwSfkCtfd/7XL6RB7gxIWFebCVnPH+o=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=CDtUT33FqSpfxCRlqFR1WRslNubLxUu7ci2cXZKqm9UaA3L6VfGIkdXH2J3uQ43Itk8yvR/kIHeaZyWWPztXzqYre2QdZ/+ORf7nct7Y0iEjSFzhQbuAz1gDY4F8YVbBJ/+fuzkPFEjnb7mRVIzAnyaQcv41e4m7Ow7VEA15bIo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=pass smtp.mailfrom=infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=niy8gQ+G; arc=none smtp.client-ip=90.155.50.34
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="niy8gQ+G"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=casper.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=V97EjziPWX7/aWg2UdD5uDnb3HG95TQLDqrOqOVej0g=; b=niy8gQ+GsklXMudI64cl6QUE5W
	PusadtssOexwTK1gOY6YfSiIZk8qPfZMLZqZKDbr2D9LPzlERlOwh09zygRqx6HxjXCXGcJdtAmMZ
	POnFqCq8OdkcmIyEb3PuLPIJ/nK6lenV0stesjXWfqY6rKtaoE3LSDfNLS78swMmacO3n535Gxceq
	wKrVGtNXL+RjdTXGduiuwW/Q4ykv06GRzswmQ0A/KbL0BfZHRne1PUTDKZ+lC8lW4UKqno0rOScRt
	IfLWtpjB3ixeK+TFnCGQOcwvyFIDtsJICOpf/lUWnYXrasc19dnYxhzIBgS838XtY6oODL/hZp1Im
	/tbghusA==;
Received: from willy by casper.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wV9Kt-000000064Qn-0gwN;
	Thu, 04 Jun 2026 14:46:19 +0000
Date: Thu, 4 Jun 2026 15:46:19 +0100
From: Matthew Wilcox <willy@infradead.org>
To: Theodore Tso <tytso@mit.edu>
Cc: Mike Rapoport <rppt@kernel.org>, Jan Kara <jack@suse.com>,
	Mark Fasheh <mark@fasheh.com>, Joel Becker <jlbec@evilplan.org>,
	Joseph Qi <joseph.qi@linux.alibaba.com>,
	Ryusuke Konishi <konishi.ryusuke@gmail.com>,
	Viacheslav Dubeyko <slava@dubeyko.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>,
	Dave Kleikamp <shaggy@kernel.org>,
	Miklos Szeredi <miklos@szeredi.hu>,
	Andreas Hindborg <a.hindborg@kernel.org>,
	Breno Leitao <leitao@debian.org>, Kees Cook <kees@kernel.org>,
	"Tigran A. Aivazian" <aivazian.tigran@gmail.com>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	ocfs2-devel@lists.linux.dev, linux-nilfs@vger.kernel.org,
	linux-nfs@vger.kernel.org, jfs-discussion@lists.sourceforge.net,
	linux-ext4@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 10/17] jbd2: replace __get_free_pages() with kmalloc()
Message-ID: <aiGPu2XwaM31fvl9@casper.infradead.org>
References: <20260523-b4-fs-v1-0-275e36a83f0e@kernel.org>
 <20260523-b4-fs-v1-10-275e36a83f0e@kernel.org>
 <yfzx3jgzwesernofl7mzixa2mhjfii5v3o7yapghtmozixrpfu@6bsh7iixyiov>
 <aiEX4UTxEnBTjVKo@kernel.org>
 <ximvn6jwgtam665a4droqkp73o55kwvd5uukyidwjesmysobth@oe7rigpsjfkz>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ximvn6jwgtam665a4droqkp73o55kwvd5uukyidwjesmysobth@oe7rigpsjfkz>

I'm hoping you'll take my "Remove special jbd2 slabs" patch instead of
this one, but answering here anyway ...

On Thu, Jun 04, 2026 at 10:05:52AM -0400, Theodore Tso wrote:
> On Thu, Jun 04, 2026 at 09:14:57AM +0300, Mike Rapoport wrote:
> > There's no memory overhead when order == 1.
> > As for the CPU overhead, the difference for the fast path allocations is
> > not measurable and for the slow path it is anyway determined by the amount
> > of reclaim involved rather than by what allocator is used.
> 
> Thanks for confirming!
> 
> > Larger allocations (> PAGE_SIZE * 2) go straight to the page allocator.

That is a detail subject to change.  I have some ideas ...

What users are guaranteed is that kmalloc returns physically contiguous
memory.  And that if it's a power-of-two that it's naturally aligned.

> Another question: Today, we can either use kmalloc() (or
> __get_free_pages, previously) or vmalloc().  Is there a way a file
> system can say, "give me physically contiguous pages if possible, but
> if it's too hard --- with some TBD to specify what 'too hard' means or
> can be specified --- fall back to a vmalloc-style approach, with the
> page table / TLB overhead that this might imply"?
> 
> I suppose we could do it with kmalloc() with some flags which to
> prevent forced reclaim / compaction, and if that fails, then fall back
> to vmalloc().  Is there a better way?

I think we'd like to avoid doing that.  A lot of code has various
workarounds for deficiencies in the memory allocator (some of which have
been fixed and thus the workarounds only complicate matters).  If the
memory allocator(s) aren't providing what you need (be it performance
under load, fragmentation avoidance or whatever), it's best to get that
fixed rather than having fallback paths.

There have been people who have suggested "What if folios could be
physically discontiguous", and sometimes I've hhumoured them, but the
simplifications enabled by requiring folios to be contiguous are quite
immense.

We've been trying to move in the direction of exposing more high-level
APIs so people can say "I want to allocate 10MB of memory but it doesn't
need to be contiguous" and have the allocator either fail the whole
thing up front or make efforts to ensure that you get the whole 10MB.
It's a lot more efficient than calling get_free_page() 2500 times
and possibly having reclaim run a dozen different times.

(anyone else try to create a brd that's actually larger than system ram?
;-)
