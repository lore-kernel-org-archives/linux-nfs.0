Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 735FE3D6477
	for <linux-nfs@vger.kernel.org>; Wed, 30 Sep 2026 21:44:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790804695; cv=none; b=rFSs0XjJ06BgH13vuXhp9/9JuF0fjBq4Ms0zbr9VBfypZsljEzBirCtsIWmXEp3KDvfKAd8DtkIp31qfyZpPmLj6QiRrkTLEobPWKte4Yj2JnVjL6pKWCQUl1utV8XPQ1tgC08VJqUuuYQLgniZeXMFNHy2eBk4SzY3vprigUIc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790804695; c=relaxed/simple;
	bh=JXPk5HnXHNBXCgo9gdR2Zeq4EZlcpQLfSqIbxmqn5gc=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=KBHKd22AnWJR8G0GumRS1gXxi25WD4uLzrDirMceM+b64GKJYduWA+8M9y/xrXobqOkIbAURq+yCa+tJg7R7ySP0yZa7N2LNpFYb7rO3XJKC0wToyaJHqmEfu35I5iHKOi/m+Kktrq1VSYG0eeitSSEnJGqF3sV+vt8uJE2EBr8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=l9SeEgOt; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="l9SeEgOt"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C8C9D1F00898
	for <linux-nfs@vger.kernel.org>; Wed, 30 Sep 2026 21:44:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790804693;
	bh=aikNFsdjXi2D0G5haGVTv3poTjdeG2zJ5S3HU8si8QU=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=l9SeEgOtzrSbWUdXauY+tyPSvkcF4grDLIYhKdgTRE+3MTkoqmp6nxwOwOQzTp3Q7
	 rt/jE258y3TLdOdWzP2pzo0n2ps8v1PistxvXYZC8oL8SNQ8SoVccbdgNIKoI6cv9N
	 q6+jlRRbLoZUvq5uFIUVVTogkECONTpCVqIjgfFG7sIu3x/8AYzRXXhVC/8vUYXeMs
	 fb0iiMwstwqqaSxWoCGj29ZZh9mdMIGQxpxRF1AKLM/41ueyokzqE+nSH4EXokTkBh
	 ZobV87C2rrszLuJidFf2IEHYD/s9bW2cFqQt62PlDXpWS1ZpKQLMXIPSRCjmHqSRoG
	 2ODk1VOTzFr9A==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id F0BDBF40066;
	Wed, 30 Sep 2026 17:44:51 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Wed, 30 Sep 2026 17:44:51 -0400
X-ME-Sender: <xms:04K9avvGrVrit33waYuIQNWO7Q921VQLpecZ-Rco1al0YIWYQm-cFw>
    <xme:04K9arQOtrHba_QrFaBqvbnZkLpgBykgZlES-Hv6cjLRCczeu52_UP05nfvVMd2gl
    _rL-TU3-meLsvrgZGhRomU6Qo-1mlCW3KOVC5YPE9qZo94sbcZbEadZ>
X-ME-Proxy-Cause: dmFkZTFmIkI7uuaaQ7CL9XNPpOZ9gZ4GPCXiDfKR6OTq5F5f19HdRN7b3I80SCUc4iB9pt
    aiysPAygq2INACu3XRHnSXDahoMJYrdHbCCOrTVrkqr+0s9qJxSHITSGr8e7rN34ElxgMa
    DsSbdkM5HmF3+go16WH3lNcXBK4Nnf63inEm6tZZAUhlVmMikVzBqb5udEEjZAwD6K4x0D
    fdyA0VDWSL9pahJ7V0l1lDj+kn0mUMC9N5AcQ/ThV4Qos5GmVbvoPJJTwCtixImkUnj8LM
    9f30Bu795LLtKQO9/2kWPwNkCsiK4RNCa+Syp9cURCAxrN1snMWn0eyDH8Ijt1/W2c9pqZ
    rN8dd6fotpcMEzV8jSUK9abl0KOyRoTY0zckh80QJbzCRpN4w9O0o6QCzUIlDGHaG27Igm
    6wrJbvPrBiwf9UWEwLDYfpNjsuZGdM0gcbnAGwh+6qNRMuiBuBMVisXStWwwIha7VUle0T
    ClJPNnZp3RsydBLoYNh8YKjWgKNw3aBEpU/vLd6co0qAidBcZzTkx8XG8nPkeGsLhtmIDD
    mH13NBZfZNsLc/Ig4M0DmV8PJ9YT6EAMOV5iieMiU9BRWDpi7yLRCt+Oo4c+LTaGGjCuQf
    E6I02fY6oZ164m/lmA72PDl5/5fB99Lru4CHu/SF5cHrfBkg15LE0kLgHhiQ
X-ME-Proxy: <xmx:04K9ajrDBwjIPa_GmvaWxcF6KednLFZDNL9IqMuHA2j7NK6tDU5sgA>
    <xmx:04K9ala_9pLQpXjI2nbUm1r5G0KlyUNz7uriu8H0OtnuaNTVEs-vFA>
    <xmx:04K9ajQ3oKQFJ1J2-w8k-HnetN6kUPNuvdWUe-9vQPtsTPvGc7cNhg>
    <xmx:04K9ak66URBUq5NDl7OM2bXoNQoHPANaoHxxTefkbrXrBmt0fzHlbQ>
    <xmx:04K9agxx6THDHOT34_NOBlJW3p-P6p2Fjz8IlPmn18JF2enlOIrXUIPh>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id D49EE780070; Wed, 30 Sep 2026 17:44:51 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AB5hLE8lq3aN
Date: Wed, 30 Sep 2026 14:44:31 -0700
From: "Chuck Lever" <cel@kernel.org>
To: "Mike Snitzer" <snitzer@kernel.org>
Cc: "Jeff Layton" <jlayton@kernel.org>, linux-nfs@vger.kernel.org
Message-Id: <0e847c11-3b01-4cae-8e93-2b42f655fd7e@slotpi15m67>
In-Reply-To: <20260929231329.22018-3-snitzer@kernel.org>
References: <20260929231329.22018-1-snitzer@kernel.org>
 <20260929231329.22018-3-snitzer@kernel.org>
Subject: Re: [PATCH v2 2/9] NFSD: only split a direct-mode WRITE for a worthwhile
 direct middle
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

commit 26f3b4748d5f5019c9136254f0cef206f60254db
Author: Mike Snitzer <snitzer@kernel.org>

NFSD: only split a direct-mode WRITE for a worthwhile direct middle

This commit adds a direct_misaligned_num_pages debugfs knob and declines
to split a misaligned direct-mode WRITE when its aligned middle is smaller
than that many pages.  It also moves the per-segment IOCB flag decision
out of the write loop in nfsd_direct_write() and into
nfsd_write_dio_iters_init().

Link: https://patch.msgid.link/20260929231329.22018-3-snitzer@kernel.org

There are two categories of findings here. First, the commit message and
code comments appear to have some missing information and factual errors.
Second, the patch as written does not fully reflect Christoph's original
suggestion. I'd like the patch to carry some justification of what is
missing or different. Sorry for the length.


>     nfsd_write_dio_iters_init() decides how a WRITE issued in a direct mode
>     is carried out: split into a buffered prefix, a direct middle and a
>     buffered suffix, or issued whole as a single buffered segment.
>
>     Only split when the split buys direct I/O for a worthwhile middle.  Add
>     direct_misaligned_num_pages (debugfs knob, default 2) and decline to
>     split when the aligned middle is smaller than that many pages and the
>     WRITE has a prefix or a suffix.  A WRITE whose payload memory is
>     misaligned for the block device already declines: no segment of it can
>     be direct I/O, so a split would only turn one buffered write into
>     three.
>
>     Decide every segment's flags in nfsd_write_dio_iters_init() rather than
>     in the write loop.  The buffered prefix and suffix of a split WRITE,
>     and the whole WRITE when it is not split, are issued IOCB_DONTCACHE
>     when the file system supports FOP_DONTCACHE and as plain buffered I/O
>     otherwise: the operator chose a direct mode to keep NFSD out of the
>     page cache, so a WRITE that cannot be direct gets the next best thing.
>
>     Document it in the "Misaligned WRITE" section of nfsd-io-modes.rst.

The first paragraph describes what nfsd_write_dio_iters_init() already
does.  What is missing is the cost that makes a small middle not worth a
split.  Could the description open with that instead?

The third paragraph reads as if IOCB_DONTCACHE on the prefix, the suffix
and the unsplit WRITE is new.  Before this patch, the loop in
nfsd_direct_write() already did this:

		else {
			trace_nfsd_write_vector(rqstp, fhp, kiocb->ki_pos,
						segments[i].iter.count);
			/*
			 * Mark the I/O buffer as evict-able to reduce
			 * memory contention.
			 */
			if (nf->nf_file->f_op->fop_flags & FOP_DONTCACHE)
				kiocb->ki_flags |= IOCB_DONTCACHE;
		}

Every segment without IOCB_DIRECT got IOCB_DONTCACHE when the file system
sets FOP_DONTCACHE.  So the flags do not change; only where they are
decided does.  Could the paragraph say that, and drop the justification
for behavior that already exists?

Related: the fourth paragraph does not mention that the rst sentence this
patch removes ("DONTCACHE buffered IO is _not_ used for the misaligned
segments ...") was already wrong against that loop.  Worth saying so.

>     Suggested-by: Christoph Hellwig <hch@infradead.org>

This points at Christoph's whiteboard diff from last November:

  https://lore.kernel.org/linux-nfs/aRShjU_Ti7f2Ci7I@infradead.org/

That diff is where the middle-size threshold and the move of the flag
decisions into nfsd_write_dio_iters_init() come from, so the tag is
earned.  But that diff also chose cached buffered I/O, on purpose, for
the prefix, the suffix, and a WRITE smaller than its alignment, to leave
their partial pages in place for read-modify-write.  Only the case where
the file system advertises no alignment got DONTCACHE.  This patch keeps
the opposite policy, the one already in the tree.  A reader who follows
the tag finds a diff that disagrees with the code.  The description
should say which parts are taken from that diff and that the DONTCACHE
choice is not one of them.

Jonathan's 8/9 is where that choice becomes a setting.  Reading 2/9 on
its own, the policy looks fixed; five patches later it turns out to be
a knob that sits beside the one this patch adds.  Could 8/9 move up to
sit right after this one? Or, can 2/9 follow 7/9?

As posted it also sets the boundary and edges fields that 7/9 introduces,
so it cannot move as is.  But the knob itself needs only the
buffered_flags selection; 7/9 can then add the boundary and edges
assignments when it adds the fields.  That puts the two
direct_misaligned_* knobs and their documentation next to each other,
and the description of each can point at the other.

"a split would only turn one buffered write into three": a WRITE with only
a prefix or only a suffix splits into two segments.  The same phrase
appears in a vfs.c comment and in the debugfs.c comment below.

> diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentation/filesystems/nfs/nfsd-io-modes.rst
> index dc50c930f976..fef062f24c52 100644
> --- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
> +++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst

[ ... ]

> @@ -140,6 +140,17 @@ Misaligned WRITE:
>      normal buffered IO. Such fallbacks are visible through the
>      iomap_dio_invalidate_fail trace event; see Tracing below.
>
> +    Whenever no part of a WRITE can use O_DIRECT, the whole WRITE is
> +    issued as a single DONTCACHE buffered IO (normal buffered IO if the
> +    filesystem lacks FOP_DONTCACHE). This covers: a filesystem that
> +    advertises no DIO alignment requirements at all; a WRITE smaller
> +    than the larger of the offset and memory alignments; a WRITE whose
> +    DIO-aligned middle segment is smaller than
> +    /sys/kernel/debug/nfsd/direct_misaligned_num_pages pages (default 2)
> +    while also having a misaligned start or end; and a WRITE whose
> +    payload memory is not aligned to the block device's dma_alignment,
> +    which rules out O_DIRECT for the middle segment as well.

"Whenever no part of a WRITE can use O_DIRECT" does not describe the third
case in this list.  A WRITE whose middle is smaller than
direct_misaligned_num_pages could use O_DIRECT for that middle; NFSD
chooses not to.  Could this open with when NFSD does not split, rather
than when it cannot?  For example:

    If NFSD does not split a misaligned WRITE, it issues the whole
    WRITE as a single DONTCACHE buffered IO (normal buffered IO if the
    filesystem lacks FOP_DONTCACHE). NFSD does not split a WRITE in
    these cases: ...

> diff --git a/fs/nfsd/debugfs.c b/fs/nfsd/debugfs.c
> index 386fd1c54f52..398e400d6403 100644
> --- a/fs/nfsd/debugfs.c
> +++ b/fs/nfsd/debugfs.c
> @@ -128,6 +128,17 @@ void nfsd_debugfs_exit(void)
>  	nfsd_top_dir = NULL;
>  }
>
> +/*
> + * /sys/kernel/debug/nfsd/direct_misaligned_num_pages
> + *
> + * The smallest DIO-aligned middle segment, in pages, that is worth
> + * splitting a misaligned direct-mode WRITE into three segments for.  A
> + * WRITE whose middle is smaller than this, and which has a misaligned
> + * start or end, is issued as a single buffered segment instead.
> + *
> + * Default 2.  Not yet tuned by benchmarking.
> + */
> +
>  void nfsd_debugfs_init(void)
>  {
>  	nfsd_top_dir = debugfs_create_dir("nfsd", NULL);

This comment block sits above nfsd_debugfs_init() with a blank line after
it, attached to nothing.  The other knob comments in this file sit
directly above what they describe.  Could it move onto the
debugfs_create_u32() call, or onto the variable's definition in vfs.c?

"into three segments" has the same two-or-three problem as the commit
message, and the sentence ends on "for".  "Not yet tuned by benchmarking"
is a note about the development process that will go stale in the tree.
Something like:

/*
 * /sys/kernel/debug/nfsd/direct_misaligned_num_pages
 *
 * Minimum size, in pages, of the DIO-aligned middle segment for NFSD
 * to split a misaligned direct-mode WRITE.  A WRITE with a misaligned
 * start or end and a smaller middle is issued as a single buffered
 * segment.  The default value of this setting is 2.
 */

> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index fa9d9810485d..050a840546fa 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c

[ ... ]

> @@ -1302,15 +1303,29 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
>  	u32 mem_align = nf->nf_dio_mem_align;
>  	size_t prefix, middle, suffix;
>  	loff_t offset = iocb->ki_pos;
> +	unsigned int dontcache_flags = 0;
>  	unsigned int nsegs = 0;
>
> +	if (nf->nf_file->f_op->fop_flags & FOP_DONTCACHE)
> +		dontcache_flags = IOCB_DONTCACHE;
> +
>  	/*
> -	 * Check if direct I/O is feasible for this write request.
> -	 * If alignments are not available, the write is too small,
> -	 * or no alignment can be found, fall back to buffered I/O.
> +	 * Whenever direct I/O cannot be used for the WRITE, fall back to a
> +	 * single DONTCACHE buffered I/O when the file system supports it, so
> +	 * the WRITE's pages are dropped from the page cache once written
> +	 * back, and to a single cached buffered I/O otherwise.
> +	 *
> +	 * If the file system doesn't advertise any alignment requirements,
> +	 * don't try to issue direct I/O at all.
>  	 */
> -	if (unlikely(!mem_align || !offset_align) ||
> -	    unlikely(total < max(offset_align, mem_align)))
> +	if (unlikely(!mem_align || !offset_align))
> +		goto no_dio;

After this patch, nfsd_write_dio_iters_init() explains what DONTCACHE
does three times: here, above the prefix segment, and at the no_dio
label.  Each one says the same thing in different words, and a reader has
to check all three to be sure they agree.

This first one is also in the wrong place.  It describes what happens at
no_dio, but it sits above the first of four gotos to that label.  And
"Whenever direct I/O cannot be used" is not accurate for the
direct_misaligned_num_pages case below, where direct I/O is possible and
NFSD declines it.

The second paragraph restates the if statement under it.

Could all of this collapse into one comment at the no_dio label?

/*
 * Issue the whole WRITE as a single buffered segment, uncached when
 * the file system supports FOP_DONTCACHE.
 */

Then nothing needs to be said here, or at most a single line naming the
case.

> +
> +	/*
> +	 * If the I/O is smaller than the larger of the memory and logical
> +	 * offset alignment, no part of it can be direct I/O.
> +	 */
> +	if (unlikely(total < max(offset_align, mem_align)))
>  		goto no_dio;
>
>  	prefix_end = round_up(offset, offset_align);
> @@ -1321,12 +1336,27 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,

[ ... ]

> +	/*
> +	 * The prefix and suffix are buffered I/O by definition.  Mark them
> +	 * uncached when possible so their folios are dropped once written
> +	 * back rather than lingering in the page cache.
> +	 */
> +	if (prefix) {
> +		nfsd_write_dio_seg_init(&segments[nsegs], bvec,
>  					nvecs, total, 0, prefix, iocb);
> +		segments[nsegs++].flags |= dontcache_flags;
> +	}

"by definition" adds nothing to the first sentence, and the second
sentence is the DONTCACHE explanation again.  With the single no_dio
comment above, does this comment add anything over the code under it?

>
>  	nfsd_write_dio_seg_init(&segments[nsegs], bvec, nvecs,
>  				total, prefix, middle, iocb);
> @@ -1337,10 +1367,13 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
>  	 * bvecs generated from RPC receive buffers are contiguous: After
>  	 * the first bvec, all subsequent bvecs start at bv_offset zero
>  	 * (page-aligned). Therefore, only the first bvec is checked.
> +	 *
> +	 * If the memory is not aligned, direct I/O is impossible for the
> +	 * middle, so issue the entire write as a single buffered segment:
> +	 * splitting would only turn one buffered write into three.
>  	 */

"into three" again; two or three.

Christoph's diff treated this case differently.  When the memory is
misaligned but the aligned middle is large enough, it kept the split and
issued the middle as DONTCACHE buffered I/O when the file system supports
it, collapsing to a single write only when it does not.  That matters
once 8/9 is applied: with direct_misaligned_dontcache=N, the split is
the only way a large middle stays out of the page cache while the ends
stay in it, and collapsing here makes the whole WRITE cached.  Was
dropping that branch deliberate?  If it was, the description should say
why.

[ ... ]

>  no_dio:
> -	/* No DIO alignment possible - pack into single non-DIO segment. */
> +	/* No DIO possible - pack into a single uncached (if possible) segment. */

This line runs past 80 columns.  The replacement comment suggested above
fits, if the DONTCACHE explanation lands here.

>  	nfsd_write_dio_seg_init(&segments[0], bvec, nvecs, total, 0,
>  				total, iocb);
> +	segments[0].flags |= dontcache_flags;
>  	return 1;
>  }

-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
