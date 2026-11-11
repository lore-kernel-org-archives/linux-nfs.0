Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794362169;
	b=NHZWkKbeUSKgVA5KOSW1++TobESkSB0PvcgW5Xpc2c4JfkMDguTLrpZwGepaRZVYh4fd
	 ooMBpJlPh5SXtoF/3nKk3955ef77QQr3wPeBAxV24LR97SoCLOpT/31BldgD+tQK0m9UQ
	 c911Hmcs1Bvdd0kxyWwB6ndd1sVIUexdteDZ/ckcgSSt9tfwPOMYVfQxC4Xpezu7BCm+2
	 Uv1D7z4hoCvL84jPam9V3Rn13ea4farLGMgqfSj7FHl2eLhYObxNggeb7zEX5x8wl9ecl
	 oC3tlVeFHIVp0DsKzkuZj41CArOO9VpTuFEAkcpGFn7F5m0Eq99JDFWpE1F/OfjdZPQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794362169;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:Content-Transfer-Encoding;
	bh=U33p1bWUYQ2rMJhKB3AhFOc4JmHWhcjAfKKn9UYYW08=;
	b=BvXHHKYXkTKXF6BuMxDV5bBE/kmYiXDKZ9YRaax3HD+Oh99Io3LgZscLIObuIWt4BgrE
	 o4N3Ig7sYnsQ4FwjjZRGfXCqea1lOJGP3ntnfRYZ35c3cb1rgd6MyW165J1/sYSmZmV4e
	 oOL/6MY2AH/hHM1DZmou06JFCJuKOHh3Fi+gxbFGNqQ/N5sUkNyXLAfkaR2Exjkus/E4R
	 6/lvz5yCzuRqJVPB04LMXWzN8W795MLgR7sKosAYpoHtvL6K5bwZyZbICbd2bxbWQQpM9
	 vEGhHhyqIFz5bTGMBsRQLZSHsSTEPr5gKnHEB2CWm3KnDrN30r7K2F1olVD0M11jpbg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=SOTP3HHV;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 95C2F606A31C;
	Wed, 11 Nov 2026 01:56:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=SOTP3HHV
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DA1B71F0089F;
	Wed, 11 Nov 2026 01:56:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794362169;
	bh=U33p1bWUYQ2rMJhKB3AhFOc4JmHWhcjAfKKn9UYYW08=;
	h=From:To:Cc:Subject:Date;
	b=SOTP3HHV7YUQ350EbayIS9J8d/YQ86XYhp5JqV2Yt98M7khwvj3Ri7cbJes4lIcD+
	 E3Sc538FKteqioboUMUW/wAmESPF99IAqazgCvvFUfGjlGrUkAQCJFH3+HaGjXObjl
	 0DkuFe8xSZL5zYyshiuur3aJPRuDhUEKAlM9tlhLw9t/aHfLqhSJlBOupg/MYRj1cc
	 UCcRfCv3pPex3tkkM1dcuK606Y63g++bOg1SQELN5/kZHGcdo6gXPIwqRi1V9WuURg
	 tSRyVuROiMBe9bLXNVl98oWo4JY+8z8i3X5wCCXBepqXwnEflUHnSdPUGW5eccFEAp
	 aMWtLdDYwiqgA==
From: Mike Snitzer <snitzer@kernel.org>
To: Matthew Wilcox <willy@infradead.org>,
	Jan Kara <jack@suse.cz>,
	linux-mm@kvack.org,
	Christian Brauner <brauner@kernel.org>,
	linux-fsdevel@vger.kernel.org
Cc: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v11 0/7] mm, iomap, NFSD: stop DONTCACHE writes reading back shared pages
Date: Tue, 10 Nov 2026 20:56:00 -0500
Message-ID: <20261111015607.46338-1-snitzer@kernel.org>
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

An RWF_DONTCACHE write is buffered IO: its data goes through the page
cache, and writeback drops each folio once the folio is written back.
A write that starts or ends inside a folio covers that folio only
partially.  Usually another write covers the rest of the folio.  If
writeback drops the folio before the other write writes its part, the
other write must first read the folio back from disk.  32 threads
writing interleaved records to one XFS file, 4 KiB pages, before and
after 5/7:

  record  pwritev2() flags          4 KiB device       MiB/s
  bytes                             reads per write
                                    before   after     before  after
  47008   RWF_DONTCACHE             0.97     0.0005    831     2281
  47008   RWF_DONTCACHE|RWF_DSYNC   0.99     0.0005    601     1227
  6000    RWF_DONTCACHE             0.97     0.0001    121      488
  6000    RWF_DONTCACHE|RWF_DSYNC   0.99     0.0002     90      206

47008 bytes is the transfer size of IO500's ior-hard, in which each
rank writes interleaved records to one shared file.  Any record size
that is not a multiple of the page size has the same problem.  6000
bytes is a second example.

The test program and script: https://lore.kernel.org/linux-nfs/atqJBS8MlYfeUU-t@kernel.org/

- 1/7 moves code into a helper, with no functional change.
- 2/7 fixes 88d6f128d06d ("mm: track DONTCACHE dirty pages per
  bdi_writeback"), in v7.3: WB_DONTCACHE_DIRTY could drift.
- 3/7 reports WB_DONTCACHE_DIRTY in the bdi debugfs stats.
- 4/7 adds folio_mark_dropbehind() for a folio that is already dirty.
- 5/7 keeps a partially covered folio until the write that completes it.
- 6/7 lets a writer that syncs its own write complete those folios
  itself, after the sync.
- 7/7 makes NFSD do that for the misaligned ends of a direct-mode WRITE.

Merging: Chuck suggested taking the series through the mm tree.  1/7 to
6/7 apply cleanly to each of these mm branches:

  mm-unstable  93d7a816a2df ("fs/proc/task_mmu: fix lost maps entries above 2^63")
  mm-new       488f62a72b8e ("riscv: mm: fix concurrency in mark_new_valid_map()")
  mm-stable    fa4ad798f6f6 ("Merge tag 'for-7.4-rc1-tag' of git://git.kernel.org/pub/scm/linux/kernel/git/kdave/linux")

7/7 needs the NFSD direct-mode changes that are in cel/nfsd-testing.
The whole series applies to cel/nfsd-testing at f7ef2ce48812 ("SUNRPC:
Load the GSS module by OID only when the mechanism is missing"), where
each patch builds with W=1 with no warnings.  So 7/7 could follow in
the nfsd tree once the mm part is merged.

Changes since v10:
- Two fixes, from sashiko's review of v10 6/7
  (https://lore.kernel.org/r/sashiko-outbox-198089@kernel.org):
  - 5/7: iomap decides whether a unit is an edge from what is left of
    the whole write (iter->len), not of the current extent.  With blocks
    smaller than the folio, an extent boundary can split a unit that the
    write covers in full.  v10 then looked the unit up as two edges.
    With IOCB_DONTCACHE_DEFER, nothing marked the unit, and it stayed
    cached until reclaim.
  - 6/7: filemap_dontcache_edge_complete() leaves a clean mapped folio
    unmarked, as filemap_end_dropbehind() leaves a mapped folio.  v10
    marked it dropbehind, but no writeback was to clean it.
- The commit messages and code comments use different terms.  They say
  RWF_DONTCACHE, DONTCACHE or dropbehind, and "the other write that
  covers the rest of the folio".
- 5/7 says that an RWF_DONTCACHE write goes through the page cache.  It
  says that the kernel cannot know if another write will come, and what
  stays cached when no other write comes.  It names IO500's ior-hard as
  the source of the 47008-byte records, and adds the 6000-byte result.
- 6/7 and 7/7 say which WRITEs NFSD syncs: a WRITE that the client
  sends as FILE_SYNC or DATA_SYNC gets one vfs_fsync_range() over the
  whole WRITE.  An UNSTABLE WRITE gets none.  7/7 also says that the
  Linux client sends an O_DIRECT write that fits in one WRITE as
  FILE_SYNC.
- Christoph's Reviewed-by on 1/7.  Jeff's Reviewed-by of v10 is carried
  on 2/7, 3/7, 4/7 and 7/7, where only comments changed.  It is dropped
  from 5/7 and 6/7, which have the fixes above.
- The review notes below the --- line are dropped.
- Rebased on the current cel/nfsd-testing.

v10: https://lore.kernel.org/linux-nfs/20261103211754.35352-1-snitzer@kernel.org/
v9: https://lore.kernel.org/linux-nfs/20261024221152.6965-1-snitzer@kernel.org/
v8: https://lore.kernel.org/linux-nfs/20261023024548.71123-1-snitzer@kernel.org/
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
  mm: move clearing the dropbehind flag of a found folio into a helper
  mm: take a folio off WB_DONTCACHE_DIRTY only if it was counted there
  mm: expose WB_DONTCACHE_DIRTY in bdi debugfs stats
  mm: add folio_mark_dropbehind() to mark a folio dropbehind and account it
  mm, iomap: keep a partially covered page until a DONTCACHE write completes it
  mm, iomap: let a DONTCACHE writer complete its shared pages itself
  NFSD: drop a shared boundary page only once both WRITEs have written it

 .../filesystems/nfs/nfsd-io-modes.rst         |  18 ++
 fs/iomap/buffered-io.c                        |  30 ++-
 fs/iomap/trace.h                              |   3 +-
 fs/nfsd/vfs.c                                 | 107 ++++++++-
 include/linux/fs.h                            |   5 +-
 include/linux/iomap.h                         |   1 +
 include/linux/pagemap.h                       |  12 +
 mm/backing-dev.c                              |   6 +
 mm/filemap.c                                  | 207 ++++++++++++++++--
 9 files changed, 358 insertions(+), 31 deletions(-)


base-commit: f7ef2ce48812080b87572a2f0fdec93cb2d2a629
-- 
2.52.0

