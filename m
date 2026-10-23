Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792716842;
	b=J0DiinaN45ppqWR8wf7DI+cJqTIMaKTT/3TVIsAK5NfsOGLyf8tczEqTmjQcaThlytQy
	 83+MYJJoZq5EEE2JElfTihhELxG+eEVxhehWa7ZQnI4ybXawlMx2SgxJPdyjvQiaqC55c
	 MSs6US2ZMMU1WVREB9jGqxsk65vFHVbDmSyhvfeP/vKdOMgWG/GlzjR/KIGHebhSQirFR
	 TGjRy3SGulQyK1k8gcUTM1veDyXNybVHeC/kQ+/4Qz0I60++WrjH/RHjMUsN9axgUe3PT
	 lwZJuk8AB5IUOc3EzLITdaeGMaXWFpYNVgRp7qsdEHUxFioo8pFseex+q3gO8mGPiuw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792716842;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=nYW9SB9bemiFfYhVQt1sKLx4FrVO5SfLiirdrRHkEdY=;
	b=LIH1asld3kLKjk/KqoY5B5eHIipJC6NxFSU36W2zhBQdt65ZdQZ+Vrlza05WpoMTfD5m
	 SOk5720JVSH72IJBjs/08H2rz8VHGEl+ohphEYDHMnUqDBnH/9xO8HweyS5DduhAcOxDI
	 qfeac/KBaBOivCzwtt6PrWrNue2v18It+qMfS1YZjnAA9oojpNmEadGLEEEJb5s82Uz8q
	 tOd8W/yggrAUYvgHxk81n0PHSpo4GHBowlGrTdDmAz2lDn6naoHHCeDMjUXeYsrhNmaF3
	 +sItJRmiHQKR5ewETiNaIsK5iTOdmgHvv/lgXLzFGaZ3zav+p98E7KBmzWa7PazfzVQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ckQTyi5t;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 230BC606A319;
	Fri, 23 Oct 2026 00:54:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ckQTyi5t
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7C6BE1F01825;
	Fri, 23 Oct 2026 00:54:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792716841;
	bh=nYW9SB9bemiFfYhVQt1sKLx4FrVO5SfLiirdrRHkEdY=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=ckQTyi5tq4/uNcGqzn0KrC0dZAdPhP/AtBfqNIwiBRoxxCCUvlBw4H1j+3rB3M53r
	 jpJQZCRg9VLrGMFib3wkr2lp8KeoljEIShPdDkA3ryT0MmkYynXQawdcEx171/gsDc
	 KUc3enj+LPcxyRMpLzF1bY7CzpZPRiq+oM7b036qeX0DhVbxhesZ4ZGlBCu3Jw/7px
	 v5Aa+OZT3wA/Zm5LV59lZsIocOLhltNd8hqgejsmGrhBZJcT7fECtijN8iylmXOYpY
	 LQGALnFQQe2Tn26eRXn7ZUBDzU9rnDcE8EhPLzf67NPrQFbns2cx+RElemCH3D5lZb
	 FYrI1CATMzysg==
Date: Thu, 22 Oct 2026 20:54:00 -0400
From: Mike Snitzer <snitzer@kernel.org>
To: Jeff Layton <jlayton@kernel.org>
Cc: Mike Snitzer <snitzer@hammerspace.com>, Chuck Lever <cel@kernel.org>,
	linux-nfs@vger.kernel.org, NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>,
	Matthew Wilcox <willy@infradead.org>,
	Jonathan Corbet <corbet@lwn.net>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v7 4/5] mm, iomap: let an uncached writer complete its
 shared pages itself
Message-ID: <atqwKE2fJ1mH3s4p@kernel.org>
References: <20261020220346.28020-1-snitzer@kernel.org>
 <20261020220346.28020-5-snitzer@kernel.org>
 <39b14c2a978ec71138492debe95d883aebc3cfe5.camel@kernel.org>
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
In-Reply-To: <39b14c2a978ec71138492debe95d883aebc3cfe5.camel@kernel.org>

On Wed, Oct 21, 2026 at 06:54:14AM -0400, Jeff Layton wrote:
> 
> 2 comments from Chuck's sashiko on this one:
> 
> [Severity: Low]
> Could filemap_dontcache_edge_complete() in mm/filemap.c avoid missing the
> immediate drop when another task acquires the folio lock between
> folio_unlock() and folio_end_dropbehind()? In that case folio_end_dropbehind()
> fails its folio_trylock() and does not retry; if the folio is already clean,
> there may be no later writeback completion to drop it, so it can remain cached
> until unrelated activity or reclaim.

Yes.  There was no reason to let go of the lock first: the folio is
locked and we are in task context, so v8 drops it with
filemap_end_dropbehind() before the unlock, as folio_end_dropbehind()
does once its trylock succeeds.

> [Severity: Medium]
> Could filemap_dontcache_edge_complete() in mm/filemap.c restrict marking to
> the boundary page when the mapping returns a large folio? iomap_get_folio()
> in fs/iomap/buffered-io.c limits a partial edge request to one page, but the
> mapping's minimum folio order can still cause __filemap_get_folio_mpol() to
> return a multi-page folio, or the lookup can find an existing large folio.
> This helper then marks the entire folio for drop-behind. For example, if a
> caller uses deferred completion on an XFS mapping with a minimum folio order,
> marking one edge can account the whole dirty folio for DONTCACHE writeback or
> invalidate the whole clean, unmapped folio. Could this path handle only the
> page covered by the completed edge?

Also right, and it applied to 3/5 as well: the folio a write finds
uptodate there was marked whole in the same way.  3/5 only creates the
edge as a single page; a lookup can find a larger folio that readahead
or an earlier buffered write left, and dropping it drops everything in
it, including other edges whose second write hasn't come yet, which
then pay the read-back this series is meant to remove.  A folio can't
be dropped in part, so v8 marks a found folio only when it is the
smallest the mapping allows, folio_nr_pages(folio) ==
mapping_min_folio_nrpages(mapping): a single page, or a single block
where the block is larger than a page, which is then the unit two
writes share.  A larger folio is left unmarked, cached until reclaim
as it is without the series.  That is in 3/5's lookup and in both 4/5
helpers.

Looking at that turned up two more places that used the page where the
smallest folio is the unit, both fixed in v8:

- 3/5's iomap change decided that a write covers its first or last page
  only partly by page offset, so on a mapping whose blocks are larger
  than a page a write starting on a page boundary inside a block didn't
  ask for its block as an edge.  It now tests against
  mapping_min_folio_nrbytes().
- NFSD cuts a misaligned end of a direct-mode WRITE on a page boundary
  (80728157d1bd, "NFSD: cut a misaligned direct-mode WRITE at page
  boundaries", in Chuck's nfsd-testing), so there the direct middle and
  a buffered end could share a block.  v8 has a fix for that at the
  front, so the end is cut at the smallest folio as well.

Measured on XFS on an emulated 4Kn NVMe, 4 KiB pages, 32 threads writing
interleaved 47008-byte records, 1 GiB, 4 KiB reads per write from the
device, v7 against v8:

                                                v7        v8
  RWF_DONTCACHE over large folios readahead
    left (pages resident after)          0.94 (6%)  0.0026 (100%)
  RWF_DONTCACHE, 16 KiB blocks              1.62    0.0014
    (12288-byte records)                    2.89    0.0004
  NFS WRITEs through NFSD DIRECT,
    16 KiB blocks                           3.46    0.0016

(v7 in 128 MiB runs, v8 in 1 GiB runs; 16384-byte records, which cover
only whole blocks, read 0 either way.  On 16 KiB blocks one block read
back per write is 4.0 here.)

Thanks,
Mike
