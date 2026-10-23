Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792753034;
	b=Cllku954NaFQniE6pxFVGOTJPj1MaQkg+R+PtP6ETzKv4hX92yhxX4p2jG92xNyFTnO2
	 QBcwW4ZW8ZIjTJwlp8gVrWIXQj5kNJfzGJ35aqL+7FOizFli43puLx+eQ/DbFc35Xl46l
	 BdWLq3ohyaSWLJ0L6q5W3woBw46xSjTebc9PsVyo8mVlZ21s/aSstVdqc7TKImlSZCiOA
	 pIWwdEDIsoTE+ppgyX8dV1ZWtFkyDXEYLbzpoea93trz8FHnE+Xkm2/HCgYDzD40ZGnxn
	 4n3TnPMNNunvOqeb433v/GXBc/fiw5ndbDoFi+epDExvh4K7CCtyvyWNI1y5p47tdug==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792753034;
	h=Received:DKIM-Signature:Message-ID:Subject:From:To:Cc:Date:
	 In-Reply-To:References:Autocrypt:Content-Type:
	 Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=AZy3vSXQuFsVXgDu4mp0Kw/AOG663vFWNbTt1QMJvQo=;
	b=1qd7b5bS7rZYDOq7ykpy6cNKZuL0P7/jx1Gr5rvyUl3FdIGMTn6OktT3hKZgg+UoxwNp
	 kdmXXXTA+fi/E6rMCerTcfXVs6R3A9Jwca4F63tpSePJg/OAJP4w7X0D+B/CLgFPjVr8R
	 0NAAxX5UOr+z9u8+tmuEmmdBRhrADb4Osx8m7cs5ddtrqJZMRyLibW2D6oKQH5LWC1ct+
	 YwcRDH5AyyZj+1y/OVUYIC4vOx5UcaHKEbny8ssrDpVu0XS9umiMfzYbSuUy/l3tEhePQ
	 Rp8YxI7Sw8mkGmMKXV9hs3m1G2qR5IfySdHNXo5tknGz8AMxz+L0beESNJN0lON8iww==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=clD++HFp;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 47FEF606A31B;
	Fri, 23 Oct 2026 10:57:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=clD++HFp
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E649F1F01825;
	Fri, 23 Oct 2026 10:57:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792753033;
	bh=AZy3vSXQuFsVXgDu4mp0Kw/AOG663vFWNbTt1QMJvQo=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=clD++HFpIMJt5lFVSwNArhp2/vBs1rRNdXKpSeyrbn2PGQCodef/gW7FnXsNXcipR
	 sb8xMFQ1PSwA2V6OuRZbg2rlDpqj1a06L8n/etzVQWUngdD7VCS5F8g1MS2Pj6hTQs
	 tn2bhz0DUoNpVyqGdWjwujA1C8N09H4spcItVHRK/cJFm7W9VxW5q2GxFOXq1w2+JQ
	 ZXEcs64hmuB5/TYhO7UyshFWiObRjNqgYngEFrlzV4jf5QxmapQ5zhzCv7+w1oaAki
	 L6ks2VOWkTti73T9soedlZHX3Rxe9VNqT7oS4r6AVsy0XsdKTxc+YTzGnhmbYJMVN1
	 E3eqpeHwVW81w==
Message-ID: <9b43a1aec170ee810ef5fd2a2ab1288bad6508fd.camel@kernel.org>
Subject: Re: [PATCH v8 0/7] mm, iomap, NFSD: stop uncached writes reading
 back shared pages
From: Jeff Layton <jlayton@kernel.org>
To: Mike Snitzer <snitzer@kernel.org>, Chuck Lever <cel@kernel.org>
Cc: linux-nfs@vger.kernel.org, NeilBrown <neil@brown.name>, Olga
 Kornievskaia	 <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom
 Talpey <tom@talpey.com>,  Christoph Hellwig	 <hch@lst.de>, Jens Axboe
 <axboe@kernel.dk>, Matthew Wilcox <willy@infradead.org>,  Jonathan Corbet	
 <corbet@lwn.net>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Date: Fri, 23 Oct 2026 06:57:09 -0400
In-Reply-To: <20261023024548.71123-1-snitzer@kernel.org>
References: <20261023024548.71123-1-snitzer@kernel.org>
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

On Thu, 2026-10-22 at 22:45 -0400, Mike Snitzer wrote:
> Hi,
>=20
> Please consider this v8 for the v7.5 development cycle, so that it can
> go upstream in the v7.5 merge window.
>=20
> An uncached (RWF_DONTCACHE) buffered write drops each page it writes
> once that page is written back.  A page the write covers only partly is
> shared with the neighbouring write, and once the first of the two has
> been written back the second has to read it back from disk before it
> can write its part.  32 threads writing interleaved records to one file
> on XFS (emulated 4Kn NVMe, 4 KiB pages), before and after 5/7:
>=20
>   record  pwritev2() flags          4 KiB device       MiB/s
>   bytes                             reads per write
>                                     before   after     before  after
>   47008   RWF_DONTCACHE             0.97     0.0005    831     2281
>   47008   RWF_DONTCACHE|RWF_DSYNC   0.99     0.0005    601     1227
>   6000    RWF_DONTCACHE             0.97     0.0001    121      488
>   6000    RWF_DONTCACHE|RWF_DSYNC   0.99     0.0002     90      206
>=20
> What is left after is metadata: 49152-byte records, which cover only
> whole pages, read 0.0005 per write either way.  The test program and
> script that produced this table, and how to run them, are in:
> https://lore.kernel.org/linux-nfs/atqJBS8MlYfeUU-t@kernel.org/
>=20
> 5/7 has the page cache keep such a page for the write that completes
> it.  6/7 lets a writer that syncs its own write, as NFSD does for a
> stable WRITE, complete those pages itself once the sync is done.  7/7
> is the NFSD change that uses it.  3/7 reports the DONTCACHE dirty count
> in the bdi debugfs stats, and 4/7 adds folio_mark_dropbehind(), which
> 5/7 and 6/7 use.
>=20
> 1/7 and 2/7 are fixes the review of v7 turned up in code that is
> already queued or upstream, and each stands on its own:
>=20
> - 1/7 fixes 80728157d1bd ("NFSD: cut a misaligned direct-mode WRITE at
>   page boundaries") in cel/nfsd-testing: where the mapping's smallest
>   folio is a block larger than a page, NFSD cut a WRITE's misaligned
>   ends inside a block, so the direct middle and a buffered end shared
>   it.  Chuck, maybe best to fold into 80728157d1bd ?
> - 2/7 fixes 88d6f128d06d ("mm: track DONTCACHE dirty pages per
>   bdi_writeback"), in v7.3: a cached lookup that clears the dropbehind
>   flag could take a folio off WB_DONTCACHE_DIRTY that was never counted
>   there, or leave one counted with nothing to uncount it.  It applies
>   to v7.3 as it is, if the mm side would rather take it alone.
>=20
> The prerequisite NFSD changes are staged in cel/nfsd-testing; this
> series applies on top of it at 6d13b7f74eec ("NFSD: Map every NFS_ACLv2
> reply status into aclstat2"), and each patch builds with W=3D1 with no
> warnings.
>=20
> 2/7 to 6/7 are mm, with small iomap changes in 5/7 and 6/7, and are
> Cc'd to linux-mm and linux-fsdevel.  If the mm and iomap maintainers
> are agreeable, their acks would let Chuck take the series through the
> nfsd tree.  But whatever approach the maintainers prefer for this kind
> of cross-subsystem merge is obviously fine.
>=20
> Changes since v7, from Jeff's review and the sashiko findings he
> relayed:
> - 1/7 and 2/7 are new (above).
> - 3/7 (v7 1/5): a comment dropped; Jeff's Reviewed-by.
> - 4/7 (v7 2/5): folio_mark_dropbehind() counted a folio as DONTCACHE
>   dirty when it found PG_dirty set, but PG_dirty is set before
>   folio_account_dirtied() counts the folio, without the folio lock, so
>   a folio marked in between was counted twice.  It now sets the flag
>   and tests the dirty tag, which is set in the same i_pages section that
>   counts the folio, under the i_pages lock.
> - 5/7 (v7 3/5): the edge is the smallest folio the mapping allows, a
>   page or a block where blocks are larger, both in iomap's test and in
>   what is marked: a larger folio found there, left by readahead or
>   another buffered write, is no longer marked whole.
> - 6/7 (v7 4/5): an edge already clean is dropped before the folio lock
>   is released, not after with a trylock that could miss it; and only
>   an edge-sized folio, as in 5/7.
> - 7/7 (v7 5/5): unchanged.
>=20
> Tested on XFS on an emulated 4Kn NVMe, 4 KiB pages, 32 threads of
> interleaved 47008-byte records (12288 bytes where noted), 4 KiB device
> reads per write, v7 against v8:
>=20
>                                              v7        v8
>   RWF_DONTCACHE over large folios
>     readahead left                          0.94      0.0026
>   RWF_DONTCACHE, 16 KiB blocks              1.62      0.0014
>     12288-byte records                      2.89      0.0004
>   NFS WRITEs through NFSD DIRECT,
>     16 KiB blocks                           3.46      0.0016
>=20
> (v7 in 128 MiB runs, v8 in 1 GiB runs; on 16 KiB blocks one block read
> back per write is 4.0 here.)  In every run of v8, BdiDontcacheDirty
> (3/7) was back at 0 after the final sync, including runs mixing
> uncached writes, cached writes and mmap stores on one file, and every
> record verified.
>=20
> v7: https://lore.kernel.org/linux-nfs/20261020220346.28020-1-snitzer@kern=
el.org/
> v6: https://lore.kernel.org/linux-nfs/atbfEbgMU6UGkn2X@kernel.org/
> v5: https://lore.kernel.org/linux-nfs/20261019150725.1507-1-snitzer@kerne=
l.org/
> v4: https://lore.kernel.org/linux-nfs/20261015233309.42999-1-snitzer@kern=
el.org/
> v3: https://lore.kernel.org/linux-nfs/20261001045502.48381-1-snitzer@kern=
el.org/
> v2: https://lore.kernel.org/linux-nfs/20260929231329.22018-1-snitzer@kern=
el.org/
> v1: https://lore.kernel.org/linux-nfs/20260929173423.16149-1-snitzer@kern=
el.org/
>=20
> Thanks,
> Mike
>=20
> Mike Snitzer (7):
>   NFSD: cut a misaligned direct-mode WRITE at the mapping's smallest foli=
o
>   mm: take a folio off WB_DONTCACHE_DIRTY only if it was counted there
>   mm: expose WB_DONTCACHE_DIRTY in bdi debugfs stats
>   mm: add folio_mark_dropbehind() to mark a folio dropbehind and account =
it
>   mm, iomap: keep a partly covered page until an uncached write completes=
 it
>   mm, iomap: let an uncached writer complete its shared pages itself
>   NFSD: drop a shared boundary page only once both WRITEs have written it
>=20
>  .../filesystems/nfs/nfsd-io-modes.rst         |  17 ++
>  fs/iomap/buffered-io.c                        |  20 +-
>  fs/iomap/trace.h                              |   3 +-
>  fs/nfsd/vfs.c                                 | 113 ++++++++--
>  include/linux/fs.h                            |   8 +-
>  include/linux/iomap.h                         |   1 +
>  include/linux/pagemap.h                       |  12 ++
>  mm/backing-dev.c                              |   6 +
>  mm/filemap.c                                  | 193 ++++++++++++++++--
>  9 files changed, 338 insertions(+), 35 deletions(-)
>=20
>=20
> base-commit: 6d13b7f74eec16e08d5e7f772ee119432a14ef2c

It might not hurt to have your LLM simplify the patch descriptions
here. I find that my appetite for reading claude-ish walls of text has
waned in recent weeks. This skill helps a lot:

    https://github.com/danyuchn/asd-ste100-skill

--=20
Jeff Layton <jlayton@kernel.org>
