Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793913839;
	b=gx1knNIGpfVE9WoUHbejrxsoUBaEakwVbIt9bqzwUe5qy9PqcXIZPBcjz0X7WWQCKEhR
	 ao6aFg0UK+QBLIzBxbr8KK9NbBFtOnuwYnbCpIpTVh37WCYoQ4U1FdGrcOaRZMEPrz09R
	 43BtI7Dj8Z6hchMZGRXvmDJ88DdHUf3rzQnH9VwD0R3hBDSPluvJ+7sBvfoyxWV3CMjis
	 oYyyOJ6INPnAuqDkXt8YCoTzeie/7YirM3n9WJbfBHUq9dEZm6kZDCIo+1wXykMEElZmQ
	 qBACWpqg4n4j4s/2xCkrpoq/cYPLjeu2TIqZgdVoYOK1PS89kPc/7JJFd5PjcV/utfQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793913839;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=GHNo6a8cM54H0KXv/W5SueN6cDG7j5EhzwqVFrjUQ3Q=;
	b=U1d31EPXcY4eHTBOWifPjsKjCkkPGpMSUerUxIcTLzTfWYaJjukTuQ1UxOT1kpNN27b6
	 cotzG+dWVnBl8iW2Eky2b2rzecPuzuuuVwDvz/F7vOYGqIddMt1qWSZWnGRop4StHYsnB
	 NLDW5lOZ4uYhywgJBcdz7JiN0TvcmncPcyaP24CzpeJLVVK6UZyS8CBrzc8q9IGb2Jev1
	 RU2j9hx1p7Xprlr+Szwr4fZ2zRrD3/5PAb6hzvczVx4VuQHagCJ3Ovuvztc5TtGzpsg0D
	 tCYaAx+4QSmSMH/XJJwoxmUTclcAinuZjGtqXCh55a/lE4Mfujf7rfBMUIoRPM2jpbA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BZ5kvDnQ;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8E89B606A326
	for <linux-nfs@vger.kernel.org>; Thu,  5 Nov 2026 21:23:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BZ5kvDnQ
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E9DF61F0089F;
	Thu,  5 Nov 2026 21:23:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793913839;
	bh=GHNo6a8cM54H0KXv/W5SueN6cDG7j5EhzwqVFrjUQ3Q=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=BZ5kvDnQHg5VBSpBPBZYXIgwVPzjc+HQ2hFbWhjpBLMrbp4eCxyhNQgayZZf25SiO
	 dPikCH3wLXN6SbYryrb7kDPt5mvmleUIoWfIELqY5AhDnl33evBs865zqWZ+Iwsx8w
	 NG2Evmj/OywRDk026a/Z9//vXO9pvY9uGF19JRTInO1KIAuTy3i3brXqbPQF2StyrA
	 ikzXv4WDB013KrpNf6dxJdlEwiXeoG82zMutA3yoPheSgEQJYe2vn2TT+p+/udEnsI
	 c6YmQcuy4w3eokxWzJakFYRATsGA3K7B9ozBoEosAmbkUqh5ahUXjzylVqdvqmN6Mj
	 670Mj1r1cQfpw==
Date: Thu, 5 Nov 2026 16:23:58 -0500
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>
Cc: Trond Myklebust <trondmy@kernel.org>, linux-nfs@vger.kernel.org,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: Re: [PATCH 03/11] NFSv4/flexfiles: cacheline align the per-stripe
 layoutstats
Message-ID: <auzz7kWlLrpeuurX@kernel.org>
References: <20261102191109.13470-1-snitzer@kernel.org>
 <20261102191109.13470-4-snitzer@kernel.org>
 <5a9801cf-b4af-4a04-8ebd-86ab9b5160f5@app.fastmail.com>
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
In-Reply-To: <5a9801cf-b4af-4a04-8ebd-86ab9b5160f5@app.fastmail.com>

On Thu, Nov 05, 2026 at 10:34:56AM -0500, Anna Schumaker wrote:
> Hi Mike,
> 
> On Mon, Nov 2, 2026, at 2:11 PM, Mike Snitzer wrote:
> > From: Mike Snitzer <snitzer@hammerspace.com>
> >
> > Moving the layoutstats lock into struct nfs4_ff_layout_ds_stripe stopped
> > stripes serialising on one spinlock, but it left them sharing cachelines
> > with each other.
> >
> > The lock and the statistics it guards sat at the tail of a struct whose
> > sizeof() was 296 and whose alignof() was only 8, so in mirror->dss[]
> > stripe i began at i * 296.  296 mod 64 = 40, so every stripe started 40
> > bytes further into a line than the last and no stripe's lock was line
> > aligned.  Acquiring stripe i's lock therefore invalidated the line
> > holding stripe i+1's lock and counters.  A RAID0-style layout -- one
> > mirror, many stripes -- is exactly the case the per-stripe lock was
> > introduced for, so this false sharing ate into the win.
> >
> > Align the first member of the guarded set.  That does two things: the
> > lock now starts on a line boundary, so the guarded set occupies lines of
> > its own and shares none with the read-mostly members above; and it raises
> > the struct's alignment to 64, which forces sizeof() up to a multiple of
> > 64 and makes the array stride line aligned.  The stride is what actually
> > separates stripe i from stripe i+1.
> >
> > Verified with pahole on flexfilelayout.o built with DWARF5.  The layout
> > is identical on x86_64, arm64 4K pages and arm64 64K pages -- cachelines
> > are 64 bytes on both architectures, so page size does not enter into it
> > -- and was taken with neither CONFIG_DEBUG_SPINLOCK nor
> > CONFIG_PROVE_LOCKING, both of which fatten spinlock_t and change it:
> >
> >   /* --- cacheline 3 boundary (192 bytes) --- */
> >   spinlock_t                 lock __aligned(64);  /*   192     4 */
> >   /* XXX 4 bytes hole */
> >   struct nfs4_ff_layoutstat  read_stat;           /*   200    72 */
> >   struct nfs4_ff_layoutstat  write_stat;          /*   272    72 */
> >   ktime_t                    start_time;          /*   344     8 */
> >   /* size: 384, cachelines: 6 */
> >   } __attribute__((__aligned__(64)));
> >
> > A read RPC now dirties two lines of its own stripe and a write three, and
> > neither disturbs a neighbouring stripe.  Later patches give each
> > direction a line of its own.
> >
> > Cost is 296 -> 384 bytes per stripe, i.e. 2816 bytes for a 32 stripe
> > layout, which is negligible beside the rest of the per-file layout state.
> > 384 is also a multiple of 128, so the stride holds for implementations
> > with a 128 byte coherency granule.
> >
> > Note that the alignment attribute only orders the stripes relative to the
> > start of mirror->dss[], not that array's own base.  The base is aligned
> > too, under either allocator kvmalloc() may pick for it:
> >
> >   - From the slab.  kmalloc() documents a size based alignment guarantee
> >     for power-of-two sizes only, but the smallest possible request is now
> >     384 bytes, and every kmalloc bucket at or above that is a power of
> >     two whose objects SLUB lays out at multiples of the object size from
> >     a page aligned slab, so the base is at least 512 byte aligned.  The
> >     exceptions, kmalloc-96 and kmalloc-192, are both smaller than one
> >     stripe and cannot be selected.
> >
> >   - From vmalloc.  A stripe array wide enough to need a high order
> >     allocation is served by the vmalloc() fallback instead, which returns
> >     page aligned memory.
> >
> > Either is comfortably more than the 64 bytes this needs.
> 
> This commit message is very wordy, and can probably be edited down.

OK, will fix. (I'll go over the entire series on this point.)

> >
> > Signed-off-by: Mike Snitzer <snitzer@hammerspace.com>
> > ---
> >  fs/nfs/flexfilelayout/flexfilelayout.h | 14 ++++++++++++--
> >  1 file changed, 12 insertions(+), 2 deletions(-)
> >
> > diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h 
> > b/fs/nfs/flexfilelayout/flexfilelayout.h
> > index 8fa2d8851166a..f48860450cf28 100644
> > --- a/fs/nfs/flexfilelayout/flexfilelayout.h
> > +++ b/fs/nfs/flexfilelayout/flexfilelayout.h
> > @@ -14,6 +14,7 @@
> >  #define FF_FLAGS_NO_IO_THRU_MDS  2
> >  #define FF_FLAGS_NO_READ_IO      4
> > 
> > +#include <linux/cache.h>
> >  #include <linux/refcount.h>
> >  #include "../pnfs.h"
> > 
> > @@ -86,8 +87,17 @@ struct nfs4_ff_layout_ds_stripe {
> >  	const struct cred __rcu		*ro_cred;
> >  	const struct cred __rcu		*rw_cred;
> >  	struct nfs_file_localio		nfl;
> > -	/* Protects read_stat, write_stat and start_time below */
> > -	spinlock_t			lock;
> > +	/*
> > +	 * Protects read_stat, write_stat and start_time below.
> > +	 *
> > +	 * Cacheline aligned so that the layoutstats accounting done on
> > +	 * every I/O to this stripe does not share cachelines with the
> > +	 * read-mostly members above, nor with the neighbouring stripes
> > +	 * in mirror->dss[]: aligning the first member of the guarded
> > +	 * set also rounds sizeof() up to a multiple of the cacheline,
> > +	 * which is what makes the array stride line-aligned.
> 
> Let's leave the original comment alone, since most of this information
> is  duplicated in the commit message and can be easily found with
> `git blame`.

Sure.

> > +	 */
> > +	spinlock_t			lock ____cacheline_aligned_in_smp;
> 
> Making this cacheline aligned seems like a good idea!

Yes, thanks.

Mike
