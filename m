Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792429831;
	b=NJRk5XziPLuVquMRRjb0o3gbvl0ZHPnWb5Cv6b1FJ/fRfeQqQvH9J/wqwcdEGQZNVcIX
	 nT273R+m0TFMvKtiivATuZKC4GaiR5Aekh5aiSpm5C3BIpJeHg5NpzH5UiipBPAcgyfiw
	 F9Svk2U35l377hjTDiD8/GJwtR8Jq/J3NI9qgbpKHDTBc3oVxZqtL0Lgxq5bU77MsWxfw
	 FKhxIQpwlvK8CoK05i3etorJntLWAHjYPyFXT+Ax/KECxjhdJVhw6QghU7SyQFcPLxPa9
	 jYEuNIUtseF/7xRJOb/uJAgKyPH/N7BvLtWIMlTPNuutQyFrwhCQIatW1qX3JqPz8gA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792429831;
	h=Received:DKIM-Signature:Message-ID:Subject:From:To:Cc:Date:
	 In-Reply-To:References:Autocrypt:Content-Type:
	 Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=CdxKoYX6MBGmuglBv9ThU/eVqYxOtC/3iRjWSvQFnlA=;
	b=GH7cRtraM2C1aIm5FG9nRdHvjwXCRW+Z3o1A1On4/jqGmadix5QLrgwoUajIxb58mXtV
	 kVQc9NA74L5YAlQ0jisb5PVi73XByNuRwpaoe85C2Msoxk9GIfZ68DjzomN8LB0Ndqhv/
	 MF4E/vZhMS/fVDVsNq8Xt0r2R1TjxbSO6xT5TZIkZnSDi47MvvapEHwoWvfXDFpMBKKkk
	 RIfosnZtHJDCqlfj31FkUdSK2vXqnfz9Dh2Nc3sjtWrf7UMqLREBU+0wWdeQOy70bYUDm
	 vsGvF1V7kkLXvhTlX1U+lKQ+xhSL9RsY7r2qDOydLbY9TxgGWhquuM6W72I3Bs0sj4Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=n6ApIA12;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 35127606A31D;
	Mon, 19 Oct 2026 17:10:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=n6ApIA12
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 16FAD1F000C4;
	Mon, 19 Oct 2026 17:10:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792429831;
	bh=CdxKoYX6MBGmuglBv9ThU/eVqYxOtC/3iRjWSvQFnlA=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=n6ApIA12i6Uvx+NaUHuj2gBiTsPc7yTGwXaQ7Z5jpCqER3PjAF/NrnGzMj9UAh5xz
	 hcKj/5KBkjgAAt9jm8ALKIn5t3OuY2A7st/sIHuqt89H7QTyeRQPuBYMVj0A4yOqL5
	 6SBuPewEhUts0i7HAcuYDNxGg+9c12FZK3uvEwG4pWLBRj9b2VZMqUouKAvY9f9NFM
	 UDVrs7k7s5R1K50BQ25Lvtfn2ut2vCq57lgof6lBaUXGVThvmorRMtmSvjdOeVjk7+
	 Nwd+0RnpLBcPKzlIRJGOb/JLUe8a5w3qy4lWz+wUoerwb4FnXP70aZKw+Q5oTAebK0
	 uNnxaZqFAx1yQ==
Message-ID: <084de93aac1adeb011e8ff05f1d7625ee75372df.camel@kernel.org>
Subject: Re: [PATCH v5 1/6] NFSD: add tracing for how direct-mode READ and
 WRITE are serviced
From: Jeff Layton <jlayton@kernel.org>
To: Mike Snitzer <snitzer@kernel.org>, Chuck Lever <cel@kernel.org>
Cc: linux-nfs@vger.kernel.org, NeilBrown <neil@brown.name>, Olga
 Kornievskaia	 <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom
 Talpey <tom@talpey.com>,  Christoph Hellwig	 <hch@lst.de>, Jens Axboe
 <axboe@kernel.dk>, Matthew Wilcox <willy@infradead.org>, 
	linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Date: Mon, 19 Oct 2026 13:10:28 -0400
In-Reply-To: <20261019150725.1507-2-snitzer@kernel.org>
References: <20261019150725.1507-1-snitzer@kernel.org>
	 <20261019150725.1507-2-snitzer@kernel.org>
Autocrypt: addr=jlayton@kernel.org; prefer-encrypt=mutual;
 keydata=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
 QZIQXVeAA+smfTT0tDrisj1U5x6ZB9b3nBg65kc=
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-2.fc44) 
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0

On Mon, 2026-10-19 at 11:07 -0400, Mike Snitzer wrote:
> When io_cache_read or io_cache_write selects a direct I/O mode, a
> request may still be serviced with DONTCACHE buffered or normal
> buffered I/O, and a WRITE may be split into up to three segments that
> each take a different path depending on the request's offset/length
> alignment, the payload's memory alignment, the filesystem's
> FOP_DONTCACHE support, direct_misaligned_min_bytes and
> direct_misaligned_dontcache.  Until now the only visibility was
> nfsd_{read,write}_direct for O_DIRECT and nfsd_{read,write}_vector for
> everything else, so the DONTCACHE and cached buffered cases were
> indistinguishable and the reason a WRITE was not issued as direct I/O
> was not recorded at all.
>=20
> Add:
>=20
>  - nfsd_write_dio_split, emitted once per direct-mode WRITE before any
>    segment is issued.  It records the advertised offset and memory
>    alignments, the payload's offset within its first page, the start,
>    middle and end segment sizes, a disposition naming the path taken
>    (direct, no_alignment, too_small, no_middle, mem_misaligned), and
>    whether buffered segments are issued IOCB_DONTCACHE.
>=20
>  - nfsd_write_dontcache and nfsd_read_dontcache, emitted for WRITE
>    segments and READs serviced with IOCB_DONTCACHE.  nfsd_write_vector
>    and nfsd_read_vector now fire only for normal buffered I/O.
>=20
> The disposition enum lives in vfs.h, which trace.h already includes.
>=20
> Document the new events in nfsd-io-modes.rst, together with iomap's
> iomap_dio_invalidate_fail event, which reports an O_DIRECT segment that
> the filesystem serviced with buffered I/O instead.
>=20
> Assisted-by: LLM
> Signed-off-by: Mike Snitzer <snitzer@kernel.org>
> ---
>  .../filesystems/nfs/nfsd-io-modes.rst         | 38 ++++++++-
>  fs/nfsd/trace.h                               | 77 +++++++++++++++++++
>  fs/nfsd/vfs.c                                 | 47 ++++++++---
>  fs/nfsd/vfs.h                                 |  9 +++
>  4 files changed, 156 insertions(+), 15 deletions(-)
>=20
> diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentat=
ion/filesystems/nfs/nfsd-io-modes.rst
> index 0a5f4ef14a8a..11da2cee76fc 100644
> --- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
> +++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
> @@ -171,21 +171,53 @@ Misaligned WRITE:
>  Tracing:
>      The nfsd_read_direct trace event shows how NFSD expands any
>      misaligned READ to the next DIO-aligned block (on either end of the
> -    original READ, as needed).
> +    original READ, as needed). A READ that is serviced with buffered IO
> +    instead emits nfsd_read_dontcache (DONTCACHE buffered IO) or
> +    nfsd_read_vector (normal buffered IO).
> =20
>      This combination of trace events is useful for READs::
> =20
>        echo 1 > /sys/kernel/tracing/events/nfsd/nfsd_read_vector/enable
> +      echo 1 > /sys/kernel/tracing/events/nfsd/nfsd_read_dontcache/enabl=
e
>        echo 1 > /sys/kernel/tracing/events/nfsd/nfsd_read_direct/enable
>        echo 1 > /sys/kernel/tracing/events/nfsd/nfsd_read_io_done/enable
>        echo 1 > /sys/kernel/tracing/events/xfs/xfs_file_direct_read/enabl=
e
> =20
> -    The nfsd_write_direct trace event shows how NFSD splits a given
> -    misaligned WRITE into a DIO-aligned middle segment.
> +    The nfsd_write_dio_split trace event is emitted once per WRITE in a
> +    DIRECT IO mode, before any IO is issued. It records the alignments
> +    the filesystem advertised, the payload's offset in its first page,
> +    the sizes of the start, middle and end segments, and a
> +    disposition::
> +
> +      direct          the aligned middle segment uses O_DIRECT
> +      mem_misaligned  payload memory is misaligned; not split
> +      no_alignment    the filesystem advertises no DIO alignment; not sp=
lit
> +      too_small       smaller than the larger of the offset and memory
> +                      alignments; not split
> +      no_middle       no aligned middle, or a misaligned start or end
> +                      with a middle smaller than
> +                      direct_misaligned_min_bytes bytes; not split
> +
> +    dontcache=3D1 means any buffered segment is issued DONTCACHE: the st=
art
> +    and end segments of a split WRITE, or the whole of a WRITE that is
> +    not split. It is 0 when direct_misaligned_dontcache is N or the
> +    filesystem lacks FOP_DONTCACHE, and is reported even for a WRITE
> +    that has no buffered segment.
> +
> +    Each segment then emits nfsd_write_direct (O_DIRECT),
> +    nfsd_write_dontcache (DONTCACHE buffered IO) or nfsd_write_vector
> +    (normal buffered IO).
> =20
>      This combination of trace events is useful for WRITEs::
> =20
>        echo 1 > /sys/kernel/tracing/events/nfsd/nfsd_write_opened/enable
> +      echo 1 > /sys/kernel/tracing/events/nfsd/nfsd_write_dio_split/enab=
le
>        echo 1 > /sys/kernel/tracing/events/nfsd/nfsd_write_direct/enable
> +      echo 1 > /sys/kernel/tracing/events/nfsd/nfsd_write_dontcache/enab=
le
> +      echo 1 > /sys/kernel/tracing/events/nfsd/nfsd_write_vector/enable
>        echo 1 > /sys/kernel/tracing/events/nfsd/nfsd_write_io_done/enable
>        echo 1 > /sys/kernel/tracing/events/xfs/xfs_file_direct_write/enab=
le
> +      echo 1 > /sys/kernel/tracing/events/iomap/iomap_dio_invalidate_fai=
l/enable
> +
> +    iomap_dio_invalidate_fail reports an O_DIRECT middle segment that
> +    the filesystem serviced with buffered IO instead.
> diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
> index e0908cb21c4e..e2615cfdf6b7 100644
> --- a/fs/nfsd/trace.h
> +++ b/fs/nfsd/trace.h
> @@ -501,6 +501,7 @@ DEFINE_EVENT(nfsd_io_class, nfsd_##name,	\
>  DEFINE_NFSD_IO_EVENT(read_start);
>  DEFINE_NFSD_IO_EVENT(read_splice);
>  DEFINE_NFSD_IO_EVENT(read_vector);
> +DEFINE_NFSD_IO_EVENT(read_dontcache);
>  DEFINE_NFSD_IO_EVENT(read_direct);
>  DEFINE_NFSD_IO_EVENT(read_io_done);
>  DEFINE_NFSD_IO_EVENT(read_done);
> @@ -508,11 +509,87 @@ DEFINE_NFSD_IO_EVENT(write_start);
>  DEFINE_NFSD_IO_EVENT(write_opened);
>  DEFINE_NFSD_IO_EVENT(write_direct);
>  DEFINE_NFSD_IO_EVENT(write_vector);
> +DEFINE_NFSD_IO_EVENT(write_dontcache);
>  DEFINE_NFSD_IO_EVENT(write_io_done);
>  DEFINE_NFSD_IO_EVENT(write_done);
>  DEFINE_NFSD_IO_EVENT(commit_start);
>  DEFINE_NFSD_IO_EVENT(commit_done);
> =20
> +TRACE_DEFINE_ENUM(NFSD_WRITE_DIO_DIRECT);
> +TRACE_DEFINE_ENUM(NFSD_WRITE_DIO_MEM_MISALIGNED);
> +TRACE_DEFINE_ENUM(NFSD_WRITE_DIO_NO_ALIGNMENT);
> +TRACE_DEFINE_ENUM(NFSD_WRITE_DIO_TOO_SMALL);
> +TRACE_DEFINE_ENUM(NFSD_WRITE_DIO_NO_MIDDLE);
> +
> +#define show_nfsd_write_dio_disposition(x)				\
> +	__print_symbolic(x,						\
> +		{ NFSD_WRITE_DIO_DIRECT,	"direct" },		\
> +		{ NFSD_WRITE_DIO_MEM_MISALIGNED, "mem_misaligned" },	\
> +		{ NFSD_WRITE_DIO_NO_ALIGNMENT,	"no_alignment" },	\
> +		{ NFSD_WRITE_DIO_TOO_SMALL,	"too_small" },		\
> +		{ NFSD_WRITE_DIO_NO_MIDDLE,	"no_middle" })
> +
> +/*
> + * Emitted once per direct-mode WRITE, before any segment is issued.
> + * prefix, middle and suffix are zero when not computed.  mem_offset is
> + * the offset of the payload within its first page.
> + */
> +TRACE_EVENT(nfsd_write_dio_split,
> +	TP_PROTO(struct svc_rqst *rqstp,
> +		 struct svc_fh *fhp,
> +		 u64 offset,
> +		 u32 len,
> +		 u32 offset_align,
> +		 u32 mem_align,
> +		 u32 mem_offset,
> +		 u32 prefix,
> +		 u32 middle,
> +		 u32 suffix,
> +		 enum nfsd_write_dio_disposition disposition,
> +		 bool dontcache),
> +	TP_ARGS(rqstp, fhp, offset, len, offset_align, mem_align, mem_offset,
> +		prefix, middle, suffix, disposition, dontcache),
> +	TP_STRUCT__entry(
> +		__field(u32, xid)
> +		__field(u32, fh_hash)
> +		__field(u64, offset)
> +		__field(u32, len)
> +		__field(u32, offset_align)
> +		__field(u32, mem_align)
> +		__field(u32, mem_offset)
> +		__field(u32, prefix)
> +		__field(u32, middle)
> +		__field(u32, suffix)
> +		__field(unsigned int, disposition)
> +		__field(bool, dontcache)
> +	),
> +	TP_fast_assign(
> +		__entry->xid =3D be32_to_cpu(rqstp->rq_xid);
> +		__entry->fh_hash =3D knfsd_fh_hash(&fhp->fh_handle);
> +		__entry->offset =3D offset;
> +		__entry->len =3D len;
> +		__entry->offset_align =3D offset_align;
> +		__entry->mem_align =3D mem_align;
> +		__entry->mem_offset =3D mem_offset;
> +		__entry->prefix =3D prefix;
> +		__entry->middle =3D middle;
> +		__entry->suffix =3D suffix;
> +		__entry->disposition =3D disposition;
> +		__entry->dontcache =3D dontcache;
> +	),
> +	TP_printk("xid=3D0x%08x fh_hash=3D0x%08x offset=3D%llu len=3D%u "
> +		  "offset_align=3D%u mem_align=3D%u mem_offset=3D%u "
> +		  "prefix=3D%u middle=3D%u suffix=3D%u disposition=3D%s "
> +		  "dontcache=3D%u",
> +		  __entry->xid, __entry->fh_hash,
> +		  __entry->offset, __entry->len,
> +		  __entry->offset_align, __entry->mem_align,
> +		  __entry->mem_offset,
> +		  __entry->prefix, __entry->middle, __entry->suffix,
> +		  show_nfsd_write_dio_disposition(__entry->disposition),
> +		  __entry->dontcache)
> +);
> +
>  DECLARE_EVENT_CLASS(nfsd_err_class,
>  	TP_PROTO(struct svc_rqst *rqstp,
>  		 struct svc_fh	*fhp,
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 32136cd32af9..0e937d116f39 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -1323,7 +1323,10 @@ __be32 nfsd_iter_read(struct svc_rqst *rqstp, stru=
ct svc_fh *fhp,
>  	}
>  	rqstp->rq_next_page =3D page;
> =20
> -	trace_nfsd_read_vector(rqstp, fhp, offset, *count - total);
> +	if (kiocb.ki_flags & IOCB_DONTCACHE)
> +		trace_nfsd_read_dontcache(rqstp, fhp, offset, *count - total);
> +	else
> +		trace_nfsd_read_vector(rqstp, fhp, offset, *count - total);

It would be nicer if we could embed the above conditional in something
that is only enabled when the tracepoints are enabled. What would you
think about making those conditional tracepoints, a'la
TRACE_EVENT_CONDITION()? Then the ki_flags tests are only done when the
tracepoints are enabled.

Alternately you could turn all of those into a single trace_nfsd_read
tracepoint that also records ki_flags.

>  	iov_iter_bvec(&iter, ITER_DEST, rqstp->rq_bvec, v, *count - total);
>  	host_err =3D vfs_iocb_iter_read(file, &kiocb, &iter);
>  	return nfsd_finish_read(rqstp, fhp, file, offset, count, eof, host_err)=
;
> @@ -1391,7 +1394,8 @@ nfsd_write_dio_seg_init(struct nfsd_write_dio_seg *=
segment,
>  }
> =20
>  static unsigned int
> -nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
> +nfsd_write_dio_iters_init(struct svc_rqst *rqstp, struct svc_fh *fhp,
> +			  struct nfsd_file *nf, struct bio_vec *bvec,
>  			  unsigned int nvecs, struct kiocb *iocb,
>  			  unsigned long total,
>  			  struct nfsd_write_dio_seg segments[3])
> @@ -1399,7 +1403,9 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, str=
uct bio_vec *bvec,
>  	u32 offset_align =3D nf->nf_dio_offset_align;
>  	loff_t prefix_end, orig_end, middle_end;
>  	u32 mem_align =3D nf->nf_dio_mem_align;
> -	size_t prefix, middle, suffix;
> +	size_t prefix =3D 0, middle =3D 0, suffix =3D 0;
> +	enum nfsd_write_dio_disposition disposition;
> +	u32 mem_offset =3D nvecs ? bvec->bv_offset : 0;
>  	loff_t offset =3D iocb->ki_pos;
>  	unsigned int dontcache_flags =3D 0;
>  	unsigned int buffered_flags;
> @@ -1415,9 +1421,14 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, st=
ruct bio_vec *bvec,
>  	 * If alignments are not available, the write is too small,
>  	 * or no alignment can be found, fall back to buffered I/O.
>  	 */
> -	if (unlikely(!mem_align || !offset_align) ||
> -	    unlikely(total < max(offset_align, mem_align)))
> +	if (unlikely(!mem_align || !offset_align)) {
> +		disposition =3D NFSD_WRITE_DIO_NO_ALIGNMENT;
>  		goto no_dio;
> +	}
> +	if (unlikely(total < max(offset_align, mem_align))) {
> +		disposition =3D NFSD_WRITE_DIO_TOO_SMALL;
> +		goto no_dio;
> +	}
> =20
>  	orig_end =3D offset + total;
> =20
> @@ -1443,8 +1454,10 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, st=
ruct bio_vec *bvec,
> =20
>  	if (!middle ||
>  	    ((prefix || suffix) &&
> -	     middle < nfsd_direct_misaligned_min_bytes))
> +	     middle < nfsd_direct_misaligned_min_bytes)) {
> +		disposition =3D NFSD_WRITE_DIO_NO_MIDDLE;
>  		goto no_dio;
> +	}
> =20
>  	if (prefix) {
>  		nfsd_write_dio_seg_init(&segments[nsegs], bvec,
> @@ -1462,28 +1475,35 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, s=
truct bio_vec *bvec,
>  	 * the first bvec, all subsequent bvecs start at bv_offset zero
>  	 * (page-aligned). Therefore, only the first bvec is checked.
>  	 */
> -	if (iov_iter_bvec_offset(&segments[nsegs].iter) & (mem_align - 1))
> +	if (iov_iter_bvec_offset(&segments[nsegs].iter) & (mem_align - 1)) {
> +		disposition =3D NFSD_WRITE_DIO_MEM_MISALIGNED;
>  		goto no_dio;
> +	}
>  	/*
>  	 * IOCB_DONTCACHE matters only if the file system falls back to
>  	 * buffered I/O (-ENOTBLK).
>  	 */
>  	segments[nsegs++].flags |=3D IOCB_DIRECT | dontcache_flags;
> +	disposition =3D NFSD_WRITE_DIO_DIRECT;
> =20
>  	if (suffix) {
>  		nfsd_write_dio_seg_init(&segments[nsegs], bvec, nvecs, total,
>  					prefix + middle, suffix, iocb);
>  		segments[nsegs++].flags |=3D buffered_flags;
>  	}
> -
> -	return nsegs;
> +	goto out;
> =20
>  no_dio:
>  	/* Issue the whole WRITE as a single buffered segment. */
>  	nfsd_write_dio_seg_init(&segments[0], bvec, nvecs, total, 0,
>  				total, iocb);
>  	segments[0].flags |=3D buffered_flags;
> -	return 1;
> +	nsegs =3D 1;
> +out:
> +	trace_nfsd_write_dio_split(rqstp, fhp, offset, total, offset_align,
> +				   mem_align, mem_offset, prefix, middle,
> +				   suffix, disposition, !!buffered_flags);
> +	return nsegs;
>  }
> =20
>  static noinline_for_stack int
> @@ -1499,8 +1519,8 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct sv=
c_fh *fhp,
>  	ssize_t host_err;
>  	size_t expected;
> =20
> -	nsegs =3D nfsd_write_dio_iters_init(nf, rqstp->rq_bvec, nvecs,
> -					  kiocb, *cnt, segments);
> +	nsegs =3D nfsd_write_dio_iters_init(rqstp, fhp, nf, rqstp->rq_bvec,
> +					  nvecs, kiocb, *cnt, segments);
> =20
>  	/*
>  	 * Persist a split synchronous WRITE once, after all of its
> @@ -1517,6 +1537,9 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct sv=
c_fh *fhp,
>  		if (kiocb->ki_flags & IOCB_DIRECT)
>  			trace_nfsd_write_direct(rqstp, fhp, kiocb->ki_pos,
>  						segments[i].iter.count);
> +		else if (kiocb->ki_flags & IOCB_DONTCACHE)
> +			trace_nfsd_write_dontcache(rqstp, fhp, kiocb->ki_pos,
> +						   segments[i].iter.count);
>  		else
>  			trace_nfsd_write_vector(rqstp, fhp, kiocb->ki_pos,
>  						segments[i].iter.count);
> diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
> index 1f05c83a3ea6..e2a7c1c44949 100644
> --- a/fs/nfsd/vfs.h
> +++ b/fs/nfsd/vfs.h
> @@ -230,4 +230,13 @@ __be32		nfsd_permission(struct svc_cred *cred, struc=
t svc_export *exp,
> =20
>  void		nfsd_filp_close(struct file *fp);
> =20
> +/* The path nfsd_write_dio_iters_init() took for a direct-mode WRITE. */
> +enum nfsd_write_dio_disposition {
> +	NFSD_WRITE_DIO_DIRECT,
> +	NFSD_WRITE_DIO_MEM_MISALIGNED,
> +	NFSD_WRITE_DIO_NO_ALIGNMENT,
> +	NFSD_WRITE_DIO_TOO_SMALL,
> +	NFSD_WRITE_DIO_NO_MIDDLE,
> +};
> +
>  #endif /* LINUX_NFSD_VFS_H */

--=20
Jeff Layton <jlayton@kernel.org>
