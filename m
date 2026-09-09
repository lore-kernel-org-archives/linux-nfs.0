Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 079FE5678D6;
	Wed,  9 Sep 2026 16:40:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788972008; cv=none; b=ikVE0m4uvnLSNcF3gSPCJHswDPY4YNIXQYMHtv6L05UpoxAKsOHF4e/rNxZF8vDOMtLnlp4pgu626Wcg2+PXAUPNattIG7J7R6nX6BIAJroBohJFEePMHOrNxzc6f8I50vP6hPzHqb/AdNwzpJRyFRf1/Fbl31f2wyNO17buvnA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788972008; c=relaxed/simple;
	bh=Q3a62DITx6p2rpjCsPoBsEChxkVRkk+RHPga/49RWJ0=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=MsINJWZ2CUeUQ2JJ2GNv09tiyyXI1x9Y4k3TpL5/h30kXJcoujepyQwkZ9M0B2JaqIwmgia4wOr1Tg53DvmVGTpNxFLUeE4RdBgRsnVDQA3wuvv7yorJXkQj2BMfVuKvxjAnKIwaKm0H4JLgrBYcR2L5GoEicyKg/Y/3we7h6RY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=QZZp+vqF; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="QZZp+vqF"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9BA0F1F000FF;
	Wed,  9 Sep 2026 16:40:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788972006;
	bh=KAHGFtRlrN1CWVcp9pjnFt0Ka/bdEYDhMQxnAwazJz0=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=QZZp+vqFGZPC7ofO92os4qIlPml8/fTYJ4NQeVBx82dhuBpuh75VYQ2lGnj862die
	 Tjj00SuiHsS7qkNJXthX6EtOJU/5G53vSP2knbWQQLPUBSQQ0+jK1xqHQMPHEzaCBf
	 R249TFSGXvrdOaDQyXLOwsJndHrz0G1p79oE9p5M535Cfd+E6EWenTAuxxzqXrBecS
	 ZdalF2rirAvbVu5NIwG4zSCTI0IaLDaLOhINkDsRSxgKnh3Ea6KzvGLLsNeVVH+rdu
	 e5VlTIv6LzAyycAb3XN09HgVT6tqpOe6btfIBJtyDQ9TXzEQzB3VYUL3lBfVkTZL6F
	 OwqraDlEyrlMQ==
Date: Wed, 9 Sep 2026 12:40:05 -0400
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-block@vger.kernel.org,
	dm-devel@lists.linux.dev, axboe@kernel.dk, jlayton@kernel.org,
	david.flynn@hammerspace.com
Subject: Re: [PATCH 4/4] nfsd: fall back to buffered I/O when a direct write
 gets -EINVAL
Message-ID: <aqGL5dh49toktgBI@kernel.org>
References: <20260908163232.30774-1-snitzer@kernel.org>
 <20260908163448.30841-1-snitzer@kernel.org>
 <20260908163448.30841-5-snitzer@kernel.org>
 <995a853c-2c54-4bd0-9708-f6e0c1be7fd5@slotpi15m67>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <995a853c-2c54-4bd0-9708-f6e0c1be7fd5@slotpi15m67>

On Tue, Sep 08, 2026 at 02:25:32PM -0400, Chuck Lever wrote:
> On 9/8/26 12:34 PM, Mike Snitzer wrote:
> > nfsd_dio_iter_is_aligned() approves a write iterator against the
> > file's STATX_DIOALIGN attributes (a whole-iterator iov_iter_alignment()
> > test against dio_mem_align), but the block stack applies stricter
> > geometry tests at bio split time: bio_split_io_at() checks each bvec's
> > offset and length against the queue's dma_alignment and may find no
> > valid block-size-aligned split at all. An ITER_BVEC WRITE payload can
> > pass the former and fail the latter: bio_iov_bvec_set() hands nfsd's
> > bvec array to the queue as-is, and the payload's first fragment starts
> > mid-page (the RPC header precedes it in the receive buffer), so the
> > iterator's interior page boundaries need not be logical-block aligned
> > and a bio the queue must split may have no valid split point. When
> > that happens, nfsd_direct_write() returned the -EINVAL to the client
> > as a failed WRITE (NFS4ERR_INVAL) -- for a perfectly valid request.
> >
> > Observed against a brd-backed nvme-loop XFS export (dio_mem_align=4)
> > with 1 MiB WRITEs, e.g. arriving as 65 bvecs with bv0=(408,15976):
> > the gate admits the iterator, the block layer rejects it, and every
> > large write on the affected connection errors out (dd: Invalid
> > argument).
> 
> Thanks for chasing this down. The bv0 numbers make the gate defect
> clear: 15976 is not a multiple of the logical block size, so the
> direct segment's first interior bvec boundary lands mid-sector. The
> boundaries after that are page boundaries, which are fine.
> 
> A small correction for the commit message: nfsd_dio_iter_is_aligned()
> doesn't exist. The gate is the first-bvec offset test in
> nfsd_write_dio_iters_init(), and it checks only that one offset
> against nf_dio_mem_align. Likewise bio_iov_bvec_set() is now
> bio_iov_iter_set().

As I'm sure you inferred, this patch was pulled out to the front as an
"upstream fixes" section -- of a broader series of changes David and I
have been developing to enhance SUNRPC to allow for wider use of
NFSD_DIRECT with TCP.  So that explains the inconsistency in functions
referenced.

> > Treat -EINVAL from the direct attempt as "not direct-able": restore the
> > segment's iterator and retry it as (uncached when FOP_DONTCACHE)
> > buffered I/O, the same fallback nfsd_write_dio_iters_init() picks for
> > geometries it rejects itself.
> 
> [ ... ]
> 
> > @@ -1467,6 +1469,33 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
> >  		expected = iov_iter_count(&segments[i].iter);
> >
> >  		host_err = vfs_iocb_iter_write(file, kiocb, &segments[i].iter);
> > +		if (unlikely(host_err == -EINVAL &&
> > +			     (kiocb->ki_flags & IOCB_DIRECT))) {
> 
> [ ... ]
> 
> > +			segments[i].iter = saved_iter;
> > +			kiocb->ki_flags &= ~IOCB_DIRECT;
> > +			if (file->f_op->fop_flags & FOP_DONTCACHE)
> > +				kiocb->ki_flags |= IOCB_DONTCACHE;
> > +			trace_nfsd_write_vector(rqstp, fhp, kiocb->ki_pos,
> > +						segments[i].iter.count);
> > +			host_err = vfs_iocb_iter_write(file, kiocb,
> > +						       &segments[i].iter);
> > +		}
> 
> Per our discussion last October:
> 
>   https://lore.kernel.org/linux-nfs/aPXihwGTiA7bqTsN@infradead.org/
> 
> The conclusion then was that -EINVAL from ->write_iter can come from
> a number of conditions in the filesystem, so NFSD can't treat it as
> meaning only that the I/O was misaligned. That still holds, so I'd
> rather not use -EINVAL to signal a retry. An -EINVAL that really is
> the filesystem rejecting the request would now cost a second full
> write attempt before surfacing anyway.

Yes, I do recall that exchange now thanks for the reminder!

> nfsd_write_dio_iters_init() already has the segment start and
> nf_dio_offset_align, and after the first bvec every boundary is
> page-aligned. If it also requires the first bvec's remaining length
> (from the segment start) to be a multiple of offset_align and takes
> the no_dio path otherwise, that rejects bv0=(408,15976) up front
> using only data NFSD already has.

Turns out the gate in nfsd_write_dio_iters_init() is perfectly fine
for existing upstream SUNRPC TCP, copied rq_pages payloads are always
one contiguous page-tiled run, and contiguous runs always split
validly.

It is only with the broader set of SUNRPC TCP changes, that are
actively in development, where the gate needs to be tightened up.
 
> What would help me understand the failure even better:
> 
> - Which -EINVAL in bio_split_io_at() fired: the per-bvec dma_alignment
>   test, or the zero-length result after ALIGN_DOWN()?

It's the ALIGN_DOWN-to-zero branch - the per-bvec dma_alignment test
provably can't fire on gate-admitted iterators. The trigger is an
interior bvec discontinuity that was made possible by our
in-development changes.

> - On the reproducer, how does stx_dio_offset_align compare with the
>   queue's logical_block_size?

They are equal, dio_offset_align=512 == logical_block_size=512
(dio_mem_align=4 from dma_alignment=3).

> If there turn out to be cases the gate can't predict from the statx
> data, that seems like a question for the block and fs folks about
> what error the filesystem should surface, rather than something to
> work around in NFSD.

There isn't anything that needs a more sweeping review/decision from
the community. Basically Claude got it wrong that this was an existing
upstream problem that needed fixing. Please drop this patch 4/4.

I'll tighten up the gate in the broader patchset that is in
development. I'll keep iterating on it and hopefully be able to share
it soon.

Thanks,
Mike
