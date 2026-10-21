Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792580067;
	b=OugJI6m13xhmnkbhhzKSNX9rslsqSV0i1mZZo6TE5bWSXF7e/a/vrzbPTCUbx0IgcQIV
	 Yim47yAruIh0gK+IpVykLsCcKIgjxNtGl2ud9GQ8AZoGverE3tEyKucT8aST+mjTg1MX8
	 +Ju4HR80rTAF2+a29cWUDe1dOHEQ1WSpRRoFh59oAcEgGKMrnuXkCXqBfdfc7BlyN3bTt
	 pG3yQfSYVgKbCHd7dGDJZH35rr6uOQ64AkweQHyk3mJGjdH2lOnrdtcbMyKDQWHLAgRnt
	 S1wPGU1cmWtbNE1WJOLato1wc+4dgwwEubJDpxCzxu1LlJoQHouE0v7/s0ZyAKB0f4g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792580067;
	h=Received:DKIM-Signature:Message-ID:Subject:From:To:Cc:Date:
	 In-Reply-To:References:Autocrypt:Content-Type:
	 Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=zCYVniZFly3PgMtnN2QXPJZFmZMEuBDbCk5iztknPcQ=;
	b=1cPTSKAleihaQU49OUzyEy6naPpysu/J1e6yfogmJ5DhSM7Yp7EoMoeuJoJVQtwZ5HiI
	 XFN2I7ZMmEjlU0+RVAKvlees/7KZApnKA/aMT5jft26299L5Wk5eMbNSLxTt47LG6Y4Vb
	 6dmCHF2IiKS46p2amrq7NJub8kW1pZaYEWgJ1eOU8cx16+6TEIt07tunZMr4NSSirpHBq
	 MTQ4KEUFl2Rx3DV3d3rfTDX9JNeFLc7RkZj86hgdlMeAe7Kah8YxL6WnEXowDQqpGG9dH
	 MWIzN7sXcFdXkfUi2Xqw+IWEmTgcl4pJoH8X7l1+QSrrkV7IVF69zo8jmI/J7PKKJNQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=VqkODNi8;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3DA19606A319;
	Wed, 21 Oct 2026 10:54:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=VqkODNi8
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BA3CF1F000CA;
	Wed, 21 Oct 2026 10:54:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792580066;
	bh=zCYVniZFly3PgMtnN2QXPJZFmZMEuBDbCk5iztknPcQ=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=VqkODNi8gJ70pwQfR6D9EDRyyxh5axW1MkIbPK59SPJng2jOcAaDxxj6UidmBWK8y
	 Ran5QHkny0jU2tYLwBvYSIYMmygsM0M3ewvMd6KQ9OdPTPfhCQPaPk00K65yybWs69
	 tsEzAtdcMFEX4W3LMK9kExNfLKDGbLiGX04x6aUoJfZNdzjXbGUf4a8r+6nT8f8euH
	 G57xqiGVa197xfKUd23Ds+1mZ4aWvdzrSLoRD7kU/kDD/3vWPJIhEIqRhRvKjz0M2f
	 texQDr/1r48IjnfkpPRE2UekhbdhrNuLrDtthl8mEToqcNNAihqZRkUYqycCKATyZv
	 O+8wuEk1gOWRg==
Message-ID: <39b14c2a978ec71138492debe95d883aebc3cfe5.camel@kernel.org>
Subject: Re: [PATCH v7 4/5] mm, iomap: let an uncached writer complete its
 shared pages itself
From: Jeff Layton <jlayton@kernel.org>
To: Mike Snitzer <snitzer@hammerspace.com>, Chuck Lever <cel@kernel.org>
Cc: linux-nfs@vger.kernel.org, NeilBrown <neil@brown.name>, Olga
 Kornievskaia	 <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom
 Talpey <tom@talpey.com>,  Christoph Hellwig	 <hch@lst.de>, Jens Axboe
 <axboe@kernel.dk>, Matthew Wilcox <willy@infradead.org>,  Jonathan Corbet	
 <corbet@lwn.net>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Date: Wed, 21 Oct 2026 06:54:14 -0400
In-Reply-To: <20261020220346.28020-5-snitzer@kernel.org>
References: <20261020220346.28020-1-snitzer@kernel.org>
	 <20261020220346.28020-5-snitzer@kernel.org>
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

On Tue, 2026-10-20 at 18:03 -0400, Mike Snitzer wrote:
> The write that completes a page an uncached write covers only partly
> marks it drop-behind as it writes, while the page is dirty, so the page
> counts as DONTCACHE dirty and the DONTCACHE writeback kick writes it
> back.  A writer that syncs its write itself, once, after several
> segments -- NFSD answering a stable WRITE, the NFS client's LOCALIO path
> -- issues each segment without IOCB_DSYNC, so every segment's kick
> writes back pages its own sync is about to write.  Measured with NFSD
> DIRECT and 32 writers of 47008-byte records: with the previous patch
> alone, 23,000 to 65,000 kick rounds a run, where NFSD marking the pages
> itself after its sync had taken 51 to 274; with this patch and NFSD
> using it, a FILE_SYNC WRITE wakes the kick not at all.
>=20
> Let such a writer complete those pages itself.  IOCB_DONTCACHE_DEFER
> (IOMAP_DONTCACHE_DEFER, FGP_DONTCACHE_DEFER) leaves a partly covered page
> unmarked even when the write finds it uptodate.  Right before writing suc=
h
> a page the writer asks filemap_dontcache_edge_completes() whether it is
> uptodate already, which means the neighbouring write has written its part
> and this write completes it; once the write and its sync are done,
> filemap_dontcache_edge_complete() marks it and, clean, drops it at once.
>=20
> Two writes that arrive together may both find the page absent before
> either has written; that page is then left cached until reclaim, which
> the folio-lock ordering of the default path avoids.
>=20
> Assisted-by: LLM
> Signed-off-by: Mike Snitzer <snitzer@kernel.org>
> ---
>  fs/iomap/buffered-io.c  |  4 +++
>  fs/iomap/trace.h        |  3 ++-
>  include/linux/fs.h      |  8 +++++-
>  include/linux/iomap.h   |  1 +
>  include/linux/pagemap.h |  6 +++++
>  mm/filemap.c            | 58 ++++++++++++++++++++++++++++++++++++++++-
>  6 files changed, 77 insertions(+), 3 deletions(-)
>=20
> diff --git a/fs/iomap/buffered-io.c b/fs/iomap/buffered-io.c
> index 780a0186045d..5ca82000e2ec 100644
> --- a/fs/iomap/buffered-io.c
> +++ b/fs/iomap/buffered-io.c
> @@ -811,6 +811,8 @@ struct folio *iomap_get_folio(struct iomap_iter *iter=
, loff_t pos, size_t len)
>  		 */
>  		if (offset_in_page(pos) || len < PAGE_SIZE) {
>  			fgp |=3D FGP_DONTCACHE_EDGE;
> +			if (iter->flags & IOMAP_DONTCACHE_DEFER)
> +				fgp |=3D FGP_DONTCACHE_DEFER;
>  			len =3D min_t(size_t, len, PAGE_SIZE - offset_in_page(pos));
>  		}
>  	}
> @@ -1318,6 +1320,8 @@ iomap_file_buffered_write(struct kiocb *iocb, struc=
t iov_iter *i,
>  		iter.flags |=3D IOMAP_NOWAIT;
>  	if (iocb->ki_flags & IOCB_DONTCACHE)
>  		iter.flags |=3D IOMAP_DONTCACHE;
> +	if (iocb->ki_flags & IOCB_DONTCACHE_DEFER)
> +		iter.flags |=3D IOMAP_DONTCACHE_DEFER;
> =20
>  	while ((ret =3D iomap_iter(&iter, ops)) > 0)
>  		iter.status =3D iomap_write_iter(&iter, i, write_ops);
> diff --git a/fs/iomap/trace.h b/fs/iomap/trace.h
> index e1ea8392cf47..4f0343eeed1b 100644
> --- a/fs/iomap/trace.h
> +++ b/fs/iomap/trace.h
> @@ -104,7 +104,8 @@ DEFINE_RANGE_EVENT(iomap_zero_iter);
>  	{ IOMAP_UNSHARE,	"UNSHARE" }, \
>  	{ IOMAP_DAX,		"DAX" }, \
>  	{ IOMAP_ATOMIC,		"ATOMIC" }, \
> -	{ IOMAP_DONTCACHE,	"DONTCACHE" }
> +	{ IOMAP_DONTCACHE,	"DONTCACHE" }, \
> +	{ IOMAP_DONTCACHE_DEFER, "DONTCACHE_DEFER" }
> =20
>  #define IOMAP_F_FLAGS_STRINGS \
>  	{ IOMAP_F_NEW,		"NEW" }, \
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index f9d1e05e8ae6..ad181b6ce6b4 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -357,6 +357,11 @@ struct readahead_control;
>  /* kiocb is a read or write operation submitted by fs/aio.c. */
>  #define IOCB_AIO_RW		(1 << 22)
>  #define IOCB_HAS_METADATA	(1 << 23)
> +/*
> + * With IOCB_DONTCACHE: the caller completes the pages the write covers =
only
> + * partly itself, see filemap_dontcache_edge_complete().
> + */
> +#define IOCB_DONTCACHE_DEFER	(1 << 24)
> =20
>  /* for use in trace events */
>  #define TRACE_IOCB_STRINGS \
> @@ -374,7 +379,8 @@ struct readahead_control;
>  	{ IOCB_NOIO,		"NOIO" }, \
>  	{ IOCB_ALLOC_CACHE,	"ALLOC_CACHE" }, \
>  	{ IOCB_AIO_RW,		"AIO_RW" }, \
> -	{ IOCB_HAS_METADATA,	"AIO_HAS_METADATA" }
> +	{ IOCB_HAS_METADATA,	"AIO_HAS_METADATA" }, \
> +	{ IOCB_DONTCACHE_DEFER,	"DONTCACHE_DEFER" }
> =20
>  struct kiocb {
>  	struct file		*ki_filp;
> diff --git a/include/linux/iomap.h b/include/linux/iomap.h
> index bc7ae6327dbf..f3509d495a92 100644
> --- a/include/linux/iomap.h
> +++ b/include/linux/iomap.h
> @@ -212,6 +212,7 @@ struct iomap_write_ops {
>  #endif /* CONFIG_FS_DAX */
>  #define IOMAP_ATOMIC		(1 << 9) /* torn-write protection */
>  #define IOMAP_DONTCACHE		(1 << 10)
> +#define IOMAP_DONTCACHE_DEFER	(1 << 11) /* see IOCB_DONTCACHE_DEFER */
> =20
>  /*
>   * Return the existing mapping at pos, or reserve space starting at pos =
for up
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index 0c1d6bd09aa0..a0a67e4c940b 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -705,6 +705,9 @@ pgoff_t page_cache_prev_miss(struct address_space *ma=
pping,
>   *   only partly, and a neighbouring write may complete it.  A folio cre=
ated
>   *   for it is not marked drop-behind; a folio found uptodate is, as the
>   *   write that completes it.
> + * * %FGP_DONTCACHE_DEFER - With %FGP_DONTCACHE_EDGE: the caller complet=
es the
> + *   page itself (filemap_dontcache_edge_complete()), so a folio found u=
ptodate
> + *   is not marked either.
>   * * %FGP_WRITEBEGIN - The flags to use in a filesystem write_begin()
>   *   implementation.
>   */
> @@ -720,6 +723,7 @@ typedef unsigned int __bitwise fgf_t;
>  #define FGP_STABLE		((__force fgf_t)0x00000080)
>  #define FGP_DONTCACHE		((__force fgf_t)0x00000100)
>  #define FGP_DONTCACHE_EDGE	((__force fgf_t)0x00000200)
> +#define FGP_DONTCACHE_DEFER	((__force fgf_t)0x00000400)
>  #define FGF_GET_ORDER(fgf)	(((__force unsigned)fgf) >> 26)	/* top 6 bits=
 */
> =20
>  #define FGP_WRITEBEGIN		(FGP_LOCK | FGP_WRITE | FGP_CREAT | FGP_STABLE)
> @@ -1316,6 +1320,8 @@ void folio_end_writeback(struct folio *folio);
>  void folio_end_writeback_no_dropbehind(struct folio *folio);
>  void folio_end_dropbehind(struct folio *folio);
>  void folio_mark_dropbehind(struct folio *folio);
> +bool filemap_dontcache_edge_completes(struct address_space *mapping, lof=
f_t pos);
> +void filemap_dontcache_edge_complete(struct address_space *mapping, loff=
_t pos);
>  void folio_wait_stable(struct folio *folio);
>  void __folio_mark_dirty(struct folio *folio, struct address_space *, int=
 warn);
>  void folio_account_cleaned(struct folio *folio, struct bdi_writeback *wb=
);
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 0397ec771547..7d7c56a42643 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -1675,6 +1675,61 @@ void folio_mark_dropbehind(struct folio *folio)
>  }
>  EXPORT_SYMBOL_GPL(folio_mark_dropbehind);
> =20
> +/**
> + * filemap_dontcache_edge_completes - will this write complete a shared =
page?
> + * @mapping: the file's mapping
> + * @pos: any byte offset within the page
> + *
> + * For an uncached writer that completes the pages it covers only partly
> + * itself (IOCB_DONTCACHE_DEFER).  Call right before writing such a page=
: it
> + * is in the page cache and uptodate when the neighbouring write has alr=
eady
> + * written its part, and this write then completes it.  Two writes that
> + * arrive together may both find it absent; the page is then left cached=
,
> + * unmarked, until reclaim.
> + *
> + * Return: true if the caller is to call filemap_dontcache_edge_complete=
()
> + * once its write, including any sync of it, is done.
> + */
> +bool filemap_dontcache_edge_completes(struct address_space *mapping, lof=
f_t pos)
> +{
> +	struct folio *folio;
> +	bool ret;
> +
> +	/* FGP_DONTCACHE: a plain lookup would clear a drop-behind mark. */
> +	folio =3D __filemap_get_folio(mapping, pos >> PAGE_SHIFT, FGP_DONTCACHE=
, 0);
> +	if (IS_ERR(folio))
> +		return false;
> +	ret =3D folio_test_uptodate(folio);
> +	folio_put(folio);
> +	return ret;
> +}
> +EXPORT_SYMBOL_GPL(filemap_dontcache_edge_completes);
> +
> +/**
> + * filemap_dontcache_edge_complete - drop a shared page both writes have=
 written
> + * @mapping: the file's mapping
> + * @pos: any byte offset within the page
> + *
> + * Mark the page drop-behind.  If it is already written back, drop it no=
w;
> + * otherwise the writeback that cleans it drops it.  A dirty page marked=
 here
> + * counts as DONTCACHE dirty and wakes the DONTCACHE writeback kick, so =
a
> + * caller that syncs its write calls this after the sync.
> + */
> +void filemap_dontcache_edge_complete(struct address_space *mapping, loff=
_t pos)
> +{
> +	struct folio *folio;
> +
> +	folio =3D __filemap_get_folio(mapping, pos >> PAGE_SHIFT,
> +				    FGP_LOCK | FGP_DONTCACHE, 0);
> +	if (IS_ERR(folio))
> +		return;
> +	folio_mark_dropbehind(folio);
> +	folio_unlock(folio);
> +	folio_end_dropbehind(folio);
> +	folio_put(folio);
> +}
> +EXPORT_SYMBOL_GPL(filemap_dontcache_edge_complete);
> +
>  /**
>   * folio_end_writeback_no_dropbehind - End writeback against a folio.
>   * @folio: The folio.
> @@ -2024,7 +2079,8 @@ struct folio *__filemap_get_folio_mpol(struct addre=
ss_space *mapping,
>  	 * folio lock, so the writeback that cleans both writes' data drops it.
>  	 */
>  	if ((fgp_flags & FGP_DONTCACHE) && (fgp_flags & FGP_DONTCACHE_EDGE) &&
> -	    (fgp_flags & FGP_LOCK) && folio_test_uptodate(folio))
> +	    !(fgp_flags & FGP_DONTCACHE_DEFER) && (fgp_flags & FGP_LOCK) &&
> +	    folio_test_uptodate(folio))
>  		folio_mark_dropbehind(folio);
>  no_page:
>  	if (!folio && (fgp_flags & FGP_CREAT)) {

2 comments from Chuck's sashiko on this one:

[Severity: Low]
Could filemap_dontcache_edge_complete() in mm/filemap.c avoid missing the
immediate drop when another task acquires the folio lock between
folio_unlock() and folio_end_dropbehind()? In that case folio_end_dropbehin=
d()
fails its folio_trylock() and does not retry; if the folio is already clean=
,
there may be no later writeback completion to drop it, so it can remain cac=
hed
until unrelated activity or reclaim.

[Severity: Medium]
Could filemap_dontcache_edge_complete() in mm/filemap.c restrict marking to
the boundary page when the mapping returns a large folio? iomap_get_folio()
in fs/iomap/buffered-io.c limits a partial edge request to one page, but th=
e
mapping's minimum folio order can still cause __filemap_get_folio_mpol() to
return a multi-page folio, or the lookup can find an existing large folio.
This helper then marks the entire folio for drop-behind. For example, if a
caller uses deferred completion on an XFS mapping with a minimum folio orde=
r,
marking one edge can account the whole dirty folio for DONTCACHE writeback =
or
invalidate the whole clean, unmapped folio. Could this path handle only the
page covered by the completed edge?

--=20
Jeff Layton <jlayton@kernel.org>
