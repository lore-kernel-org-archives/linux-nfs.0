Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792804320;
	b=aBqhBYVyzlguhGcOvtg4CiMS/iN+85M3bnaAU6vZqLB9w36z5txsUlP/jGYPDI+B7Mdn
	 XARNDpw0n1ia1USfroISpZkrKL7GCQ7+TSHLTGZLZQI9H2VWcLG/7bEBffTgdZyaZoPT5
	 h3Ba0HnZcYtcBDC0XXVdlcYcM6Ue08UsnSYcppM1PYMdU3knm07DSX7yui06X79smNrPI
	 /bc+8U5BvEU7iuMBjreOpnrCG9PzVhiH/k7ieS3ckhO/yKlHlzdzzrc8uFhOJhcoPq/Xf
	 r674OEMb8vA/l8nXHHkz7k02jfvKTmXf9F1Z4RQma4yvXWI9axiSAiKMx0jOPX63r7w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792804320;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=qqcjA7DNdTq+xZwtRnwCLNkrsUov1CecwEVrKr3pes8=;
	b=fOPEd1nUNKPjYGTzvqD75K8jAbw1b/g+gtxSSIjMPlPybsOxnzO4K+4PuGdDM4imfAIX
	 XsMZawLYp7ERslcD89NndleVBkB/JuKTCa6C2VCtjqaE1/rxYeJpfAgnZWst1Z/uLvNA/
	 F0UlValE+7oHibhuH+unxf0ZyYfMq538snvLU9GZ4Lo4RLk+m450jLAm/dDxYKfsOqUZF
	 idzASwNakx4QhHNJVUXAvRHFudfPDVyZXcb4i3BdVbf+rc1F/PXapO0+iVy2PjDhUVYKC
	 9m/o+/3MOMACf6yd30tmf0bCODnrS2hhLQVXfxBRvECdOoqmSuNZLExxQ9YLmjSne3A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=JB9GbvwY;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C7E8C606A31A;
	Sat, 24 Oct 2026 01:11:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=JB9GbvwY
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2E6E51F01825;
	Sat, 24 Oct 2026 01:11:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792804319;
	bh=qqcjA7DNdTq+xZwtRnwCLNkrsUov1CecwEVrKr3pes8=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=JB9GbvwYUPYu2AenF8uiR5+l/yJlmYsyVbpE5bjdXpbiNpcMEu4A+zbRAGiFuQrKV
	 lAH9sjVruL0NoEC4b45IRnzOd+ue2Xg+QmfwVwdYKi57DDN35Nt2+OJZaqWOUknrJF
	 kpGU8VWhL87l2F0PgDsav9PgAEIQZn7q9mXAxEpuSTyrtl7A73SwzQQ+1RI+37OKXR
	 b7kBNAdR9lsOR1Mg0J8REHrYPrSUqd5mP8jZxguQa9TGrklVdop/NKfhivSBCynqxm
	 TAk2zyy5KVGDryqPIFGoyLvQO1kJhmq6BrRtqj1l1+VuBF0yLVT6fpdhHMkTgKa8Kp
	 mHe3pNskHcJxA==
Date: Fri, 23 Oct 2026 21:11:58 -0400
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>,
	"Matthew Wilcox (Oracle)" <willy@infradead.org>,
	Jonathan Corbet <corbet@lwn.net>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v8 1/7] NFSD: cut a misaligned direct-mode WRITE at the
 mapping's smallest folio
Message-ID: <atwF3s3-VtUkooZI@kernel.org>
References: <20261023024548.71123-1-snitzer@kernel.org>
 <20261023024548.71123-2-snitzer@kernel.org>
 <36498551-15ee-4a55-9757-54aa8a07085a@app.fastmail.com>
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
In-Reply-To: <36498551-15ee-4a55-9757-54aa8a07085a@app.fastmail.com>

On Fri, Oct 23, 2026 at 01:45:21PM -0400, Chuck Lever wrote:
> 
> 
> On Thu, Oct 22, 2026, at 10:45 PM, Mike Snitzer wrote:
> > nfsd_write_dio_iters_init() cuts a misaligned end of a direct-mode
> > WRITE at a multiple of the larger of offset_align and PAGE_SIZE, so
> > that the direct middle, which invalidates the page cache over its
> > range, never shares a page with a buffered end.  But where the
> > mapping's minimum folio order makes the smallest folio a block larger
> > than a page, the page cache holds that block as one folio: an end cut
> > on a page boundary inside a block leaves the middle and the buffered
> > end in the same folio.  The middle's invalidation then drops the folio
> > the end wrote, and whichever of the two neighbouring WRITEs comes second
> > reads the block back.
> >
> > Cut a misaligned end at a multiple of the smallest folio the mapping
> > allows as well.  Where that is a page, nothing changes.
> >
> > Fixes: 80728157d1bd ("NFSD: cut a misaligned direct-mode WRITE at page 
> > boundaries")
> > Signed-off-by: Mike Snitzer <snitzer@kernel.org>
> > ---
> >  fs/nfsd/vfs.c | 14 ++++++++------
> >  1 file changed, 8 insertions(+), 6 deletions(-)
> >
> > diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> > index 9219f8eb386d..ade00dabef18 100644
> > --- a/fs/nfsd/vfs.c
> > +++ b/fs/nfsd/vfs.c
> > @@ -1452,13 +1452,15 @@ nfsd_write_dio_iters_init(struct svc_rqst 
> > *rqstp, struct svc_fh *fhp,
> > 
> >  	/*
> >  	 * The direct middle invalidates the page cache over its range, so it
> > -	 * must not share a page with a buffered end.  An aligned end needs no
> > -	 * buffered segment; a misaligned one is cut on a page boundary even
> > -	 * where the offset alignment is finer than a page.  A WRITE may end
> > -	 * at OFFSET_MAX, so the prefix is sized as a distance rather than
> > -	 * by rounding @offset up, which could wrap.
> > +	 * must not share a folio with a buffered end.  An aligned end needs no
> > +	 * buffered segment; a misaligned one is cut on a boundary of the
> > +	 * smallest folio the mapping allows, a page or, where the block is
> > +	 * larger, a block, even where the offset alignment is finer.  A WRITE
> > +	 * may end at OFFSET_MAX, so the prefix is sized as a distance rather
> > +	 * than by rounding @offset up, which could wrap.
> >  	 */
> > -	cut = max_t(u32, offset_align, PAGE_SIZE);
> > +	cut = max3(offset_align, PAGE_SIZE,
> > +		   mapping_min_folio_nrbytes(nf->nf_file->f_mapping));
> >  	prefix_end = offset;
> >  	if (!IS_ALIGNED(offset, offset_align))
> >  		prefix_end += min_t(loff_t, cut - (offset & (cut - 1)), total);
> > -- 
> > 2.52.0
> 
> PAGE_SIZE looks dead in the max3(). mapping_min_folio_nrbytes() is always
> at least PAGE_SIZE, so the cut is just max(offset_align, min folio). The
> new commit message and comment both describe three independent bounds, but
> the accurate statement is two: the DIO offset alignment and the mapping's
> smallest folio.
> 
> Also I would like to keep the helper's unsigned long type instead of
> narrowing to u32.
> 
> Post an updated version of the v7 patch so we can test and review that
> as a single change. This will also archive that revision in the lore
> archive. This will likely result in merge conflicts with subsequent
> patches in the series. If those are just comment conflicts I can fix
> those up when I apply the revised version.
> 
> Do not include the new revision of this patch in v9. v9 is now patches
> destined for the MM tree(s) while this patch goes to NFSD.

v7 didn't have this 1/7 patch.  But seems you're saying the fix for
nfsd-testing commit 80728157d1bd (which started as v4 1/10) would be
to have max_t() use mapping_min_folio_nrbytes(nf->nf_file->f_mapping)
instead of PAGE_SIZE?

I think you're saying post a revised version of commit 80728157d1bd as
a standalone NFSD patch?  I can check if it causes the other patches
you've staged to have conflicts (but like you say, should be simple to
resolve).

Thanks,
Mike
