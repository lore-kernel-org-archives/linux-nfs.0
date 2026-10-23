Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792764729;
	b=RmmKQ4u2GhBwihw/+XTaBGNsAVcLXJ1nhQWBjQHHWNQrX3H9XyZZoPnoTtmEm8riNddz
	 zgo0+3CpbGPodUjdlhnAD3INbo5LbJ5wQdlLYf0SuC7rKTUDwKxVPl50RNoX5RsmebAZ9
	 /e7iq3CAp9KGk+8Ef5uTGUx3iAGAiMM+zeaPVsIBhhatmBoxiC+ZI2ibLck9C4exGZ/fU
	 7wasXawtHB1LSNvlLbI6QWodXPCDg8tbN6k8yzEVgLWF0ptusqE9Re94CkTcPPCLvFo8U
	 vrMH4eJP2pf2Y13XYtpyCtFMaKMJVZQse55i+xu3e7EJtXxTZCJq68mmPTYw6HmN7bw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792764729;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=cIhIHAuUJsyJ2bLrJWbRfcrJhHgsjoA+0BiCek5rlmE=;
	b=CUmFCmOOG9bVoEFhfFKen5kzJ/yC9fY2PA8JG2lfSHfoLNrLimW0PBejIJy7EBI0nQoG
	 K9yBuJBeZKm5np+aFC8UTCGoHsy1ESVCNLnZphJsGAZoisV39IDVcziyzWOAXaxu6lAiD
	 j7oBtuhzlgf9EbQ+Gs44jonyAV39TuyF+3IBKJPjfD0FZLyIsIwWuBx6HTTaYvMqDjkor
	 Ey2CyG98EtjprjJx/9j5kY22ro2ka440bMAifWeSqQZwasrWO5FiQKm4tglf9dJMpwaf5
	 VHO4KgShX4zwNtMV5U4xO926XxRRqPHRhHyvCLb7/uPamInhoRzpKMrOfjS42RWhTeA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BOy3ZWYR;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 335D1606A31D;
	Fri, 23 Oct 2026 14:12:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BOy3ZWYR
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 82AB21F01825;
	Fri, 23 Oct 2026 14:12:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792764728;
	bh=cIhIHAuUJsyJ2bLrJWbRfcrJhHgsjoA+0BiCek5rlmE=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=BOy3ZWYRjoveUK8W+po/jFDD8LEHrWegphHy+k3GAc2Tp0axnnLdExP1eTTEGh0Lh
	 MrH8vx1kjtCygjUfbn3TzevSKCul04wT+xi9OqT4tOKCkDeV8lK47HIc35kYuDgR+1
	 drrnZQj46R1o8M20sfl44ttj2UKZgs8tUUS3Yh9cg8ShLS4GJzmOq3I+tp6lC391p3
	 7VY8442ECb45QnMpkfKWKJUpc62mCty2ja2eOhekv1A84DyUGBuaP50zrVjz2zeZ0Y
	 wJ8GmKp+QXcc14ysTKGe/U/362HGnxMEE9zp/rtrGr3ITbSiS06hVLYQY7qIQNICXi
	 yFvHORASiS2zw==
Date: Fri, 23 Oct 2026 10:12:07 -0400
From: Mike Snitzer <snitzer@kernel.org>
To: Jeff Layton <jlayton@kernel.org>
Cc: Chuck Lever <cel@kernel.org>, linux-nfs@vger.kernel.org,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>,
	Matthew Wilcox <willy@infradead.org>,
	Jonathan Corbet <corbet@lwn.net>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v8 0/7] mm, iomap, NFSD: stop uncached writes reading
 back shared pages
Message-ID: <attrN9__XXJNSfuW@kernel.org>
References: <20261023024548.71123-1-snitzer@kernel.org>
 <9b43a1aec170ee810ef5fd2a2ab1288bad6508fd.camel@kernel.org>
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
In-Reply-To: <9b43a1aec170ee810ef5fd2a2ab1288bad6508fd.camel@kernel.org>

On Fri, Oct 23, 2026 at 06:57:09AM -0400, Jeff Layton wrote:
> 
> It might not hurt to have your LLM simplify the patch descriptions
> here. I find that my appetite for reading claude-ish walls of text has
> waned in recent weeks. This skill helps a lot:
> 
>     https://github.com/danyuchn/asd-ste100-skill

Thanks, I've now trained my claude monkey with it. But I'm sure it'll
still throw feces periodically.

Also, I've reviewed the sashiko review of this v8, that you kindly
forwarded this morning, and 3 of the 7 issues it flagged were real.

I don't want to spam the lists more than I already have by immediately
posting v9... but it has needed changes, blech.  I'll at least wait to
see if Chuck picks up 1/7 to fold into the commit it fixes which is
already staged in cel/nfsd-testing (and if so I'll move Chuck and Jeff
to cc and upgrade -mm and -fsdevel to the To: for v9's posting...)

But here is the changelog for pending v9, in case it helps reviewers
side-step reporting something in v8 that is already addressed in v9:

Changes since v8, from the sashiko findings Jeff Layton relayed:
- 2/7 and 4/7: a folio is counted in WB_DONTCACHE_DIRTY only when both
  PG_dirty and its dirty tag are set.  v8 tested the tag alone.
  __folio_cancel_dirty() clears PG_dirty but leaves the tag, so a
  cancelled folio that stays cached kept a stale tag.  2/7 then
  uncounted such a folio twice, and 4/7 counted it and never uncounted
  it.
- 7/7: NFSD finds the edges a buffered segment shares by the mapping's
  smallest folio, as iomap does, not by page.  On 16 KiB blocks, a WRITE
  written as one buffered segment can have page-aligned ends inside a
  block.  Nothing completed those edges, and the folios stayed cached
  until reclaim.  NFSD also completes a segment's first edge only when
  the write reached the end of the segment's bytes in that unit.  A
  short write that stopped inside the unit had not written its part.
- 1/7 and 5/7: a paragraph each on a limit the review raised.  1/7
  cannot keep a larger cached folio, left by readahead, from spanning
  the cut.  5/7 marks the folio before iomap validates the iomap.  A
  stale iomap stopped by a fatal signal then leaves a mark on a folio
  this write did not complete.  Both cost one read-back and no data.
- 3/7 and 6/7: unchanged.

Longer form for the fixes that fell out from the v8 sashiko review:

2/7, the stale dirty tag: real.  __folio_cancel_dirty() uncounts a
dropbehind folio and clears PG_dirty, but leaves PAGECACHE_TAG_DIRTY
set.  Only writeback and truncation clear the tag, and writeback skips
a clean folio.  So a cancelled folio that stays cached keeps a stale
tag, and my clear path uncounted it a second time.  The same stale tag
made folio_mark_dropbehind() in 4/7 count a clean folio that nothing
would uncount.  v9 tests PG_dirty as well as the tag in both places.
A folio is counted only when both are set.  The race the tag closes
stays closed.  A dirtier that has set PG_dirty but not yet counted the
folio has not set the tag either.

7/7, the PAGE_SIZE edge tests: real.  On 16 KiB blocks, a WRITE written
as one buffered segment can have page-aligned ends inside a block.
iomap left those edges for NFSD to complete, and NFSD never asked about
them.  Those folios stayed cached until reclaim.  v9 finds the edges by the
mapping's smallest folio, as iomap does.  Measured on the loop device,
whose dma_alignment of 511 makes every TCP payload memory-misaligned.
NFSD then writes each WRITE as one buffered segment.  32 writers of
12288-byte records: v8 left all 32,736 pages of a 128 MiB file
resident.  v9 leaves 1,348 of 262,080 pages of a 1 GiB file, 0.5%.

7/7, the short write that completes the first edge: real, and the cost
is one read-back on the retry.  v9 completes the first edge only when
the write reached the end of the segment's bytes in that unit.
