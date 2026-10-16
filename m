Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5916B2D73A0
	for <linux-nfs@vger.kernel.org>; Fri, 16 Oct 2026 11:03:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792148598; cv=none; b=DdHHUJWVDObV5ZolpZwluBCG3id49AOOqg2g3G1MsEgDQf///C++YFmtsm3HhliHoG3cf56m4V99uow2pR8VryPBaSuAV/jAGiQd2nhvWkgQ06b1Zemc/oTbIxWlfaA4R/jF/O9Hx75otMKLpHFbmVpFkNAfUSBuTsPH4s2JGeg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792148598; c=relaxed/simple;
	bh=58G/+W1Wi4mQ4JWlG0+W3Nz9aZYhBZeLkQH/fuZBaNg=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=JHj6dLkDUPfZakRJyub5t4RKlQUblvkmJyr/wO5kwNN/DZ0UCyFSTNK+YWCQXvNzRpHb0g1mLlMxoR1lBJIJWA0QdXIUQxPkNQDm34enR6tuYDcqnWsRnPc+D6ZZWWfIO5qLpzs+a9vlVYpz9DiOwTI6vk3fEftp5CddGuG3c3w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=MoBoEUP6; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="MoBoEUP6"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1FE5A1F000C4;
	Fri, 16 Oct 2026 11:03:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792148597;
	bh=8cxG5taJNBRbjBHfFTq1k8rf2KFZX0Hm/kBR9/jgpHU=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=MoBoEUP6iaqjek9TSUwTiYKc1GSA1nH7lUCWQP+28WGzyCOiPTzUFJPCPdJ8DYOqD
	 pFv8bHOmBvu5B0b7c2UvlW3t7LuBws22DdRWcQeaIyPeSZGjyctuR0ILHf7LbNMRlW
	 EycpkxArVTdlg1/fK2RcgvWLKZtCbD3PfoPYyINqlPVQG7dq/4oqFMqB48yF5TicrB
	 PP9DIR2HkxNmExH3FirZozMKE8dPbQZ4GvStkDwZCiteNlXdE9+hu1kU6Jg1Yhe76c
	 jrVqzOqkVUJlFMElZqmh2VlcM2YOcl6fscU7YNdSVpEo7i8+saXe0DZPdyFJBBmUnz
	 5khg5gKTUbEvg==
Message-ID: <13ffd6a9929976935ed2052fecc85a7345a07c36.camel@kernel.org>
Subject: Re: [PATCH v4 03/10] NFSD: only split a direct-mode WRITE for a
 worthwhile direct middle
From: Jeff Layton <jlayton@kernel.org>
To: Mike Snitzer <snitzer@kernel.org>, Chuck Lever <cel@kernel.org>
Cc: linux-nfs@vger.kernel.org, NeilBrown <neil@brown.name>, Olga
 Kornievskaia	 <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom
 Talpey <tom@talpey.com>,  Christoph Hellwig	 <hch@lst.de>, Jens Axboe
 <axboe@kernel.dk>, Matthew Wilcox <willy@infradead.org>, 
	linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>
Date: Fri, 16 Oct 2026 07:03:13 -0400
In-Reply-To: <20261015233309.42999-4-snitzer@kernel.org>
References: <20261015233309.42999-1-snitzer@kernel.org>
	 <20261015233309.42999-4-snitzer@kernel.org>
Autocrypt: addr=jlayton@kernel.org; prefer-encrypt=mutual;
 keydata=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
 QZIQXVeAA+smfTT0tDrisj1U5x6ZB9b3nBg65kc=
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-2.fc44) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Thu, 2026-10-15 at 19:33 -0400, Mike Snitzer wrote:
> Splitting a misaligned direct-mode WRITE issues it as two or three
> writes instead of one, and the direct write first writes back and
> invalidates the page cache over its range.  When the DIO-aligned middle
> is small, the WRITE is mostly its buffered prefix and suffix anyway, and
> the direct middle only adds that overhead.
>=20
> Add direct_misaligned_min_bytes (debugfs, default 8192) and do not split
> a WRITE that has a misaligned start or end and a middle smaller than that
> many bytes.  Such a WRITE is issued as a single buffered segment, like
> the other WRITEs NFSD does not split.
>=20
> The gate counts bytes, not pages.  What it weighs, the cost of three I/Os
> against one, does not change with the page size, and since a misaligned
> WRITE's middle is cut at page boundaries, the middle of such a WRITE is
> whole pages: a gate of two pages would demand a 32 KiB middle on 16 KiB
> pages and 128 KiB on 64 KiB pages before splitting at all.  On 4 KiB
> pages the default is two pages.
>=20
> Also decide each segment's IOCB_* flags in nfsd_write_dio_iters_init()
> instead of in the write loop of nfsd_direct_write().  The flags do not
> change: the loop already set IOCB_DONTCACHE on every segment without
> IOCB_DIRECT when the file system supports FOP_DONTCACHE.
>=20
> The threshold, counted there in pages, and the move of the flag
> decisions come from Christoph's suggested diff [1].  Two of its choices
> are not taken.  It issued the prefix, the suffix and any WRITE it did
> not split, whether smaller than its alignment or with a middle below the
> threshold, as cached buffered I/O, to leave partial pages in place for
> read-modify-write; this patch keeps the DONTCACHE policy already in the
> tree, and a later commit makes that policy selectable.  It also split a
> WRITE whose payload is misaligned in memory and issued the middle as
> DONTCACHE buffered I/O, so that a large middle stayed out of the page
> cache while the cached ends stayed in it.  Here the prefix and suffix
> are DONTCACHE as well, so that split would issue the same uncached
> buffered I/O as two or three writes instead of one; such a WRITE is
> issued whole, like every other WRITE NFSD does not split.
>=20
> Document in nfsd-io-modes.rst when NFSD does not split a WRITE.
>=20
> Link: https://lore.kernel.org/linux-nfs/aRShjU_Ti7f2Ci7I@infradead.org/ [=
1]
> Suggested-by: Christoph Hellwig <hch@infradead.org>
> Assisted-by: LLM
> Signed-off-by: Mike Snitzer <snitzer@kernel.org>
> ---
>  .../filesystems/nfs/nfsd-io-modes.rst         | 13 ++++++
>  fs/nfsd/debugfs.c                             | 12 +++++
>  fs/nfsd/nfsd.h                                |  1 +
>  fs/nfsd/vfs.c                                 | 46 +++++++++++--------
>  4 files changed, 53 insertions(+), 19 deletions(-)
>=20
> diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentat=
ion/filesystems/nfs/nfsd-io-modes.rst
> index f9b63f1a33990..eab35a9bbdb93 100644
> --- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
> +++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
> @@ -137,6 +137,19 @@ Misaligned WRITE:
>      cannot invalidate page cache that overlaps the segment. The
>      iomap_dio_invalidate_fail trace event reports such a fallback.
> =20
> +    If NFSD does not split a misaligned WRITE, it issues the whole WRITE
> +    as a single DONTCACHE buffered IO (normal buffered IO if the
> +    filesystem lacks FOP_DONTCACHE). NFSD does not split a WRITE when:
> +
> +    - the filesystem advertises no DIO alignment;
> +    - the WRITE is smaller than the larger of the offset and memory
> +      alignments;
> +    - the WRITE has a misaligned start or end and its DIO-aligned middle
> +      is smaller than /sys/kernel/debug/nfsd/direct_misaligned_min_bytes
> +      bytes (default 8192);
> +    - the WRITE payload is not aligned in memory to the block device's
> +      dma_alignment, so the middle cannot be O_DIRECT either.
> +
>  Tracing:
>      The nfsd_read_direct trace event shows how NFSD expands any
>      misaligned READ to the next DIO-aligned block (on either end of the
> diff --git a/fs/nfsd/debugfs.c b/fs/nfsd/debugfs.c
> index 386fd1c54f527..02b0369f17648 100644
> --- a/fs/nfsd/debugfs.c
> +++ b/fs/nfsd/debugfs.c
> @@ -140,6 +140,18 @@ void nfsd_debugfs_init(void)
> =20
>  	debugfs_create_file("io_cache_write", 0644, nfsd_top_dir, NULL,
>  			    &nfsd_io_cache_write_fops);
> +
> +	/*
> +	 * /sys/kernel/debug/nfsd/direct_misaligned_min_bytes
> +	 *
> +	 * Minimum size, in bytes, of the DIO-aligned middle segment for NFSD
> +	 * to split a misaligned direct-mode WRITE.  A WRITE with a misaligned
> +	 * start or end and a smaller middle is issued as a single buffered
> +	 * segment.  It is in bytes so that it means the same on every page
> +	 * size.  The default value of this setting is 8192.
> +	 */
> +	debugfs_create_u32("direct_misaligned_min_bytes", 0644, nfsd_top_dir,
> +			   &nfsd_direct_misaligned_min_bytes);


This is fine for now, but (FYI) I'm working on a patch series to add
r/wiomode=3D export options, so we'll be able to set the iomode on a per-
export basis in the future.

At that point, we may want to move this and the io_cache_*=3D settings to
netlink and nfsdctl, so admins will be able to define it in
/etc/nfs.conf. That may also be an argument for making this a per-net
setting instead of global

>  #ifdef CONFIG_NFSD_V4
>  	debugfs_create_bool("delegated_timestamps", 0644, nfsd_top_dir,
>  			    &nfsd_delegts_enabled);
> diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
> index d824d2c390294..db81620bd5168 100644
> --- a/fs/nfsd/nfsd.h
> +++ b/fs/nfsd/nfsd.h
> @@ -142,6 +142,7 @@ enum {
> =20
>  extern u64 nfsd_io_cache_read __read_mostly;
>  extern u64 nfsd_io_cache_write __read_mostly;
> +extern u32 nfsd_direct_misaligned_min_bytes __read_mostly;
> =20
>  bool nfsd_v4client(struct svc_rqst *rqstp);
> =20
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index bd3dab36e2962..a419eee401d9d 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -54,6 +54,7 @@
>  bool nfsd_disable_splice_read __read_mostly;
>  u64 nfsd_io_cache_read __read_mostly =3D NFSD_IO_BUFFERED;
>  u64 nfsd_io_cache_write __read_mostly =3D NFSD_IO_BUFFERED;
> +u32 nfsd_direct_misaligned_min_bytes __read_mostly =3D 8192;
> =20
>  /**
>   * nfserrno - Map Linux errnos to NFS errnos
> @@ -1323,9 +1324,13 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, st=
ruct bio_vec *bvec,
>  	u32 mem_align =3D nf->nf_dio_mem_align;
>  	size_t prefix, middle, suffix;
>  	loff_t offset =3D iocb->ki_pos;
> +	unsigned int dontcache_flags =3D 0;
>  	unsigned int nsegs =3D 0;
>  	u32 cut;
> =20
> +	if (nf->nf_file->f_op->fop_flags & FOP_DONTCACHE)
> +		dontcache_flags =3D IOCB_DONTCACHE;
> +
>  	/*
>  	 * Check if direct I/O is feasible for this write request.
>  	 * If alignments are not available, the write is too small,
> @@ -1355,12 +1360,16 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, s=
truct bio_vec *bvec,
>  	middle =3D middle_end - prefix_end;
>  	suffix =3D orig_end - middle_end;
> =20
> -	if (!middle)
> +	if (!middle ||
> +	    ((prefix || suffix) &&
> +	     middle < nfsd_direct_misaligned_min_bytes))
>  		goto no_dio;
> =20
> -	if (prefix)
> -		nfsd_write_dio_seg_init(&segments[nsegs++], bvec,
> +	if (prefix) {
> +		nfsd_write_dio_seg_init(&segments[nsegs], bvec,
>  					nvecs, total, 0, prefix, iocb);
> +		segments[nsegs++].flags |=3D dontcache_flags;
> +	}
> =20
>  	nfsd_write_dio_seg_init(&segments[nsegs], bvec, nvecs,
>  				total, prefix, middle, iocb);
> @@ -1374,22 +1383,28 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, s=
truct bio_vec *bvec,
>  	 */
>  	if (iov_iter_bvec_offset(&segments[nsegs].iter) & (mem_align - 1))
>  		goto no_dio;
> -	segments[nsegs].flags |=3D IOCB_DIRECT;
> -	/* In case the file system falls back to buffered I/O (-ENOTBLK). */
> -	if (nf->nf_file->f_op->fop_flags & FOP_DONTCACHE)
> -		segments[nsegs].flags |=3D IOCB_DONTCACHE;
> -	nsegs++;
> +	/*
> +	 * IOCB_DONTCACHE matters only if the file system falls back to
> +	 * buffered I/O (-ENOTBLK).
> +	 */
> +	segments[nsegs++].flags |=3D IOCB_DIRECT | dontcache_flags;
> =20
> -	if (suffix)
> -		nfsd_write_dio_seg_init(&segments[nsegs++], bvec, nvecs, total,
> +	if (suffix) {
> +		nfsd_write_dio_seg_init(&segments[nsegs], bvec, nvecs, total,
>  					prefix + middle, suffix, iocb);
> +		segments[nsegs++].flags |=3D dontcache_flags;
> +	}
> =20
>  	return nsegs;
> =20
>  no_dio:
> -	/* No DIO alignment possible - pack into single non-DIO segment. */
> +	/*
> +	 * Issue the whole WRITE as a single buffered segment, uncached when
> +	 * the file system supports FOP_DONTCACHE.
> +	 */
>  	nfsd_write_dio_seg_init(&segments[0], bvec, nvecs, total, 0,
>  				total, iocb);
> +	segments[0].flags |=3D dontcache_flags;
>  	return 1;
>  }
> =20
> @@ -1413,16 +1428,9 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct s=
vc_fh *fhp,
>  		if (kiocb->ki_flags & IOCB_DIRECT)
>  			trace_nfsd_write_direct(rqstp, fhp, kiocb->ki_pos,
>  						segments[i].iter.count);
> -		else {
> +		else
>  			trace_nfsd_write_vector(rqstp, fhp, kiocb->ki_pos,
>  						segments[i].iter.count);
> -			/*
> -			 * Mark the I/O buffer as evict-able to reduce
> -			 * memory contention.
> -			 */
> -			if (nf->nf_file->f_op->fop_flags & FOP_DONTCACHE)
> -				kiocb->ki_flags |=3D IOCB_DONTCACHE;
> -		}
> =20
>  		expected =3D iov_iter_count(&segments[i].iter);
> =20

--=20
Jeff Layton <jlayton@kernel.org>
