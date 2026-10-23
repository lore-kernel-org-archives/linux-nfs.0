Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792723550;
	b=KL5FtjJ+UPY7pwigfJYZepcjneKB7/wbimLUGVeE4nbH28zspol5KTQB+iTRhkEHN5OW
	 n9sU+nwkB0Lr4Dt0IZPucQVdohiHlrEYSrAmoQfS9f5yz1a4r3TGb3gS2ZqsJT/5ztR5g
	 xh5UJyareCBwTe8OXpncYeRMnRefYhe92Ew7Az2whkp12Z7fG52Y2BesBRYCPPAyBYiSW
	 FcK6yoWBBTDmGoJGiDOzmakJUnYhT1zLZ8k4bgkfH26nGk/8IAKBMfgtdT3cFfBHi/f9o
	 n9ldBI+iUriv5pqmXU0Uh5J3cOAytGc2zo1fYf1TdE9Jxu8s29+Aga0yC1/Y95528JA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792723550;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:Content-Transfer-Encoding;
	bh=ousMmCqm8kZo/1f4oQY4+VQpMSnqXjb9BPVok/hW1j0=;
	b=hGW4oz1cuCUqHBkJ/ReLBQ/v1hzNbuvSLYN7hO+uHGp3/X7gFBXh9so/e5LdwFMGmFn4
	 qgm/XY49dOcpWBy1z+evxUtw1RI++hwqpwcX4kNQP3sXu7DvzKG/GBuZ+g7B2f/UfJXxG
	 2lLrd40ImBTMVTdE+mUJV6qxr/zmoGqL5vfr0jfcbIQ+tHdhowK5Mp+m4vRGOvsYrrbWm
	 0KdJYAdvvhyS7yODRkh4sA45uxVq6JvPi/cZ/Q2gTFKm6xNxUSzvgWHYVfkn587gt4Sa5
	 BOey6FG7Cx5JcpXTqdIoqXrzRUMKekJh43lsTQX91PoHCujX7ir5K4zcKkQxDMeyoPQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=eO8F7a8Y;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 87539606A319;
	Fri, 23 Oct 2026 02:45:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=eO8F7a8Y
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DA1D61F01829;
	Fri, 23 Oct 2026 02:45:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792723550;
	bh=ousMmCqm8kZo/1f4oQY4+VQpMSnqXjb9BPVok/hW1j0=;
	h=From:To:Cc:Subject:Date;
	b=eO8F7a8YFqj61z0gglHJ463L52JSnLHr22JUgDiyed1l8OmW5P4JQZI/3vXGdRxBB
	 sTJSQC6xsXK950SshppPD2K19ixEvNmRZEGXS7UwfloaPJnM4EzuUDeJ9Ipa0U25Tx
	 d38T5wtcrO5Kn8V0sveNxDnGnvdWbTc6TuJC6kvRRNm4MuJg2mmlHZF1ac575onGha
	 8crHb0YyQ2i0WPIJGT9arW38XLfqnafGoMlKYzrtYPe57TIiLdGYH0aajDBPkq4XjK
	 B5ZyT64yjIho+2O7/kL++9pGYxkF0HjrNwON69asVujIls7sGtZbC1Co7XlfY6HZl2
	 zJGGzGsfN9Hng==
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Christoph Hellwig <hch@lst.de>,
	Jens Axboe <axboe@kernel.dk>,
	Matthew Wilcox <willy@infradead.org>,
	Jonathan Corbet <corbet@lwn.net>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: [PATCH v8 0/7] mm, iomap, NFSD: stop uncached writes reading back shared pages
Date: Thu, 22 Oct 2026 22:45:41 -0400
Message-ID: <20261023024548.71123-1-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Hi,

Please consider this v8 for the v7.5 development cycle, so that it can
go upstream in the v7.5 merge window.

An uncached (RWF_DONTCACHE) buffered write drops each page it writes
once that page is written back.  A page the write covers only partly is
shared with the neighbouring write, and once the first of the two has
been written back the second has to read it back from disk before it
can write its part.  32 threads writing interleaved records to one file
on XFS (emulated 4Kn NVMe, 4 KiB pages), before and after 5/7:

  record  pwritev2() flags          4 KiB device       MiB/s
  bytes                             reads per write
                                    before   after     before  after
  47008   RWF_DONTCACHE             0.97     0.0005    831     2281
  47008   RWF_DONTCACHE|RWF_DSYNC   0.99     0.0005    601     1227
  6000    RWF_DONTCACHE             0.97     0.0001    121      488
  6000    RWF_DONTCACHE|RWF_DSYNC   0.99     0.0002     90      206

What is left after is metadata: 49152-byte records, which cover only
whole pages, read 0.0005 per write either way.  The test program and
script that produced this table, and how to run them, are in:
https://lore.kernel.org/linux-nfs/atqJBS8MlYfeUU-t@kernel.org/

5/7 has the page cache keep such a page for the write that completes
it.  6/7 lets a writer that syncs its own write, as NFSD does for a
stable WRITE, complete those pages itself once the sync is done.  7/7
is the NFSD change that uses it.  3/7 reports the DONTCACHE dirty count
in the bdi debugfs stats, and 4/7 adds folio_mark_dropbehind(), which
5/7 and 6/7 use.

1/7 and 2/7 are fixes the review of v7 turned up in code that is
already queued or upstream, and each stands on its own:

- 1/7 fixes 80728157d1bd ("NFSD: cut a misaligned direct-mode WRITE at
  page boundaries") in cel/nfsd-testing: where the mapping's smallest
  folio is a block larger than a page, NFSD cut a WRITE's misaligned
  ends inside a block, so the direct middle and a buffered end shared
  it.  Chuck, maybe best to fold into 80728157d1bd ?
- 2/7 fixes 88d6f128d06d ("mm: track DONTCACHE dirty pages per
  bdi_writeback"), in v7.3: a cached lookup that clears the dropbehind
  flag could take a folio off WB_DONTCACHE_DIRTY that was never counted
  there, or leave one counted with nothing to uncount it.  It applies
  to v7.3 as it is, if the mm side would rather take it alone.

The prerequisite NFSD changes are staged in cel/nfsd-testing; this
series applies on top of it at 6d13b7f74eec ("NFSD: Map every NFS_ACLv2
reply status into aclstat2"), and each patch builds with W=1 with no
warnings.

2/7 to 6/7 are mm, with small iomap changes in 5/7 and 6/7, and are
Cc'd to linux-mm and linux-fsdevel.  If the mm and iomap maintainers
are agreeable, their acks would let Chuck take the series through the
nfsd tree.  But whatever approach the maintainers prefer for this kind
of cross-subsystem merge is obviously fine.

Changes since v7, from Jeff's review and the sashiko findings he
relayed:
- 1/7 and 2/7 are new (above).
- 3/7 (v7 1/5): a comment dropped; Jeff's Reviewed-by.
- 4/7 (v7 2/5): folio_mark_dropbehind() counted a folio as DONTCACHE
  dirty when it found PG_dirty set, but PG_dirty is set before
  folio_account_dirtied() counts the folio, without the folio lock, so
  a folio marked in between was counted twice.  It now sets the flag
  and tests the dirty tag, which is set in the same i_pages section that
  counts the folio, under the i_pages lock.
- 5/7 (v7 3/5): the edge is the smallest folio the mapping allows, a
  page or a block where blocks are larger, both in iomap's test and in
  what is marked: a larger folio found there, left by readahead or
  another buffered write, is no longer marked whole.
- 6/7 (v7 4/5): an edge already clean is dropped before the folio lock
  is released, not after with a trylock that could miss it; and only
  an edge-sized folio, as in 5/7.
- 7/7 (v7 5/5): unchanged.

Tested on XFS on an emulated 4Kn NVMe, 4 KiB pages, 32 threads of
interleaved 47008-byte records (12288 bytes where noted), 4 KiB device
reads per write, v7 against v8:

                                             v7        v8
  RWF_DONTCACHE over large folios
    readahead left                          0.94      0.0026
  RWF_DONTCACHE, 16 KiB blocks              1.62      0.0014
    12288-byte records                      2.89      0.0004
  NFS WRITEs through NFSD DIRECT,
    16 KiB blocks                           3.46      0.0016

(v7 in 128 MiB runs, v8 in 1 GiB runs; on 16 KiB blocks one block read
back per write is 4.0 here.)  In every run of v8, BdiDontcacheDirty
(3/7) was back at 0 after the final sync, including runs mixing
uncached writes, cached writes and mmap stores on one file, and every
record verified.

v7: https://lore.kernel.org/linux-nfs/20261020220346.28020-1-snitzer@kernel.org/
v6: https://lore.kernel.org/linux-nfs/atbfEbgMU6UGkn2X@kernel.org/
v5: https://lore.kernel.org/linux-nfs/20261019150725.1507-1-snitzer@kernel.org/
v4: https://lore.kernel.org/linux-nfs/20261015233309.42999-1-snitzer@kernel.org/
v3: https://lore.kernel.org/linux-nfs/20261001045502.48381-1-snitzer@kernel.org/
v2: https://lore.kernel.org/linux-nfs/20260929231329.22018-1-snitzer@kernel.org/
v1: https://lore.kernel.org/linux-nfs/20260929173423.16149-1-snitzer@kernel.org/

Thanks,
Mike

Mike Snitzer (7):
  NFSD: cut a misaligned direct-mode WRITE at the mapping's smallest folio
  mm: take a folio off WB_DONTCACHE_DIRTY only if it was counted there
  mm: expose WB_DONTCACHE_DIRTY in bdi debugfs stats
  mm: add folio_mark_dropbehind() to mark a folio dropbehind and account it
  mm, iomap: keep a partly covered page until an uncached write completes it
  mm, iomap: let an uncached writer complete its shared pages itself
  NFSD: drop a shared boundary page only once both WRITEs have written it

 .../filesystems/nfs/nfsd-io-modes.rst         |  17 ++
 fs/iomap/buffered-io.c                        |  20 +-
 fs/iomap/trace.h                              |   3 +-
 fs/nfsd/vfs.c                                 | 113 ++++++++--
 include/linux/fs.h                            |   8 +-
 include/linux/iomap.h                         |   1 +
 include/linux/pagemap.h                       |  12 ++
 mm/backing-dev.c                              |   6 +
 mm/filemap.c                                  | 193 ++++++++++++++++--
 9 files changed, 338 insertions(+), 35 deletions(-)


base-commit: 6d13b7f74eec16e08d5e7f772ee119432a14ef2c
-- 
2.52.0

