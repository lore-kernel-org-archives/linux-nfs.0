Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 58C813E1231
	for <linux-nfs@vger.kernel.org>; Thu, 15 Oct 2026 23:33:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792107192; cv=none; b=Wf30RWeWU+Qkn5qS67ggwaVDwqGLvF8TeiT9W4+y/i7GiNPHpYOArmJUnoBl8aj86ondyq5XUJKz3RSa8z8UycZtDfNUCH/EoogIHr5YiYy5sQ4XUXsEEd3Aiy15URtpTyDqH/gD0E553kreVEAIBKHFNIyubaw6c3ImkoVPuzQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792107192; c=relaxed/simple;
	bh=/6fdy2CVTJzgLgsJppjNRiivkMkPWBQtO6NwrvLfCjI=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=turazfzphVV4w3pbaS+DN4L+UaV6rrQdGb/8uCMzEIYwi/kMEhR3h12VRM4rz0IU6Qy2I+BdsTpA9LzIYxBM+0jhr4wpDeC4Cxdu4L40mJnIPMqYZpH26PIsFjTz+BE4hYTDVEg1y5Kxii8XKsj4tyb3apHhPQ4bN7ONa0AmQc8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=lCKps5B6; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="lCKps5B6"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AA0F21F000C4;
	Thu, 15 Oct 2026 23:33:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792107190;
	bh=9RMtPUFCuYN30zPTOxaGP7huxuPCnbVGVzaU0gv5SsI=;
	h=From:To:Cc:Subject:Date;
	b=lCKps5B6tN64QKfcqzZ+RvB8Bg9M2RNeDCYDu0l2x4NEpOBEv/Qt/WQS/GeVg5mSO
	 3woRdrHgR38uBxhq0wBN7zmc5rQ1M38acBff9t7a4ujmC14ahLM06ZVdOPiPg+MDZl
	 46mH4NBvArwphbtKGpiyhzm2plfvbxp77yigFieZdFhNhgIj13IHrXv1NUbSRmvowU
	 k48PKvIMOka8AQZJXw6we4g/Qx+uixODaHVHtlkom3rEBefzN3bF+D2F4hWWqGe/7q
	 TytPwN7eZHvftsj63ipPhEKRs6nEZFCnv1IQMEC0JWSC/EX7mH117tF6l7SB8ZXiVS
	 tFK7D6tQrSf+Q==
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
	linux-mm@kvack.org
Subject: [PATCH v4 00/10] NFSD: keep direct-mode I/O out of the page cache
Date: Thu, 15 Oct 2026 19:32:59 -0400
Message-ID: <20261015233309.42999-1-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Hi,

This series refines the heuristics NFSD_IO_DIRECT already uses, mostly
on the WRITE path and in one corner of the READ path: the io_cache_write
and io_cache_read modes where an aligned request goes to the filesystem
as O_DIRECT, with DONTCACHE for the parts a misaligned WRITE cannot issue
directly.

It does not knowingly undercut anything the existing upstream code is
built on.  An aligned WRITE is still one O_DIRECT write and an aligned
READ is still one O_DIRECT read.  A misaligned WRITE is still split into
a direct middle and buffered ends, and by default those ends are still
DONTCACHE where the filesystem supports it.  io_cache_read and
io_cache_write mean what they did, and nothing new is asked of the
filesystem.  What changes is where the split is cut and when it is worth
making, which READs are worth expanding, how often a synchronous WRITE
is persisted, and what happens to the page two misaligned WRITEs share.

1/10 is a stable fix.  A misaligned WRITE is split into a direct middle
and buffered ends, and the middle was cut at the filesystem's DIO offset
alignment.  Where the page is larger than that alignment (16 and 64 KiB
pages over 4096-byte blocks, or 4 KiB pages over 512-byte blocks) the
middle then starts or stops inside the page a buffered end writes, its
invalidation drops that page, and whichever of the two neighbouring
WRITEs comes second reads it back from the device.  A misaligned end is
now cut at a multiple of the larger of the alignment and the page size.
An end that is already DIO-aligned gets no buffered segment and stays
where it is, so a DIO-aligned WRITE is still issued direct on every page
size.  Such an end can share its page with a buffered neighbour, but
NFSD's direct WRITEs are synchronous and XFS holds its IOLOCK across
iomap_dio_rw(), the page cache invalidation after the write included,
so the neighbour cannot dirty that page in between and make the
invalidation fail.

2/10 also marks the direct middle IOCB_DONTCACHE, for when XFS
re-issues it as buffered I/O (-ENOTBLK) because something else has
dirtied page cache in its range, such as a local process writing the
exported file through mmap, which XFS's IOLOCK does not keep out.

3/10 splits a misaligned WRITE only for a direct middle of at least
direct_misaligned_min_bytes (debugfs, default 8192), and moves the
segment flag decisions into nfsd_write_dio_iters_init(), both from
Christoph's suggested diff.  The threshold counts bytes: with 1/10 a
split WRITE's middle is whole pages, and a threshold of two pages would
demand a 32 KiB middle on 16 KiB pages and 128 KiB on 64 KiB pages.

4/10 (Jonathan) adds direct_misaligned_dontcache (default Y), which
selects whether the parts that are not O_DIRECT are DONTCACHE or
cached.

5/10 stops expanding a READ smaller than its alignment into one or two
whole aligned device reads.  The check sits in nfsd_direct_read_ok(),
beside the last-operation-in-COMPOUND check now in nfsd-testing.

6/10 persists a FILE_SYNC or DATA_SYNC WRITE that is split, or issued
buffered, once after all of its segments, instead of once per segment:
one fsync where there were up to three.  A WRITE issued whole as
O_DIRECT keeps IOCB_DSYNC, so iomap can still complete a DATA_SYNC
overwrite with FUA writes.

7/10 is an mm patch: folio_mark_dropbehind() marks an existing folio
dropbehind and keeps WB_DONTCACHE_DIRTY balanced when the folio is
already dirty, as folio_mark_dirty() does for PG_dirty where
folio_set_dirty() only sets the flag.  Marking an already dirty folio
with folio_set_dropbehind() instead drives the counter negative, and
the DONTCACHE writeback kick then stops writing anything back for every
writer on that bdi_writeback.

8/10 is also mm: it reports WB_DONTCACHE_DIRTY in the bdi debugfs stats,
as BdiDontcacheDirty and per bdi_writeback as WbDontcacheDirty, summed
over the per-cpu batches since the flusher targets the summed value.
The counter drives the DONTCACHE writeback kick but was not reported
anywhere; this is how the balance 7/10 keeps was observed.  It carries
Fixes: for the commit that added the counter.

7/10 and 8/10 are Cc'd to linux-mm and need an mm ack.

9/10 calls folio_mark_dropbehind() to keep the page two misaligned
WRITEs share until both have written it, with no state in NFSD: 704
device reads for 42895 WRITEs where there were 45144 for 45664
(47008-byte records, 32 interleaved writers, 4 KiB pages), and on a
four-server pNFS flexfiles rig 0.003 device reads per record instead of
0.014-0.015, about 2.9 GiB of page-cache growth instead of 11 GiB, and
2.4% to 4.9% more write throughput.

10/10 adds tracepoints for how each direct-mode READ and WRITE was
serviced, and why a WRITE was not issued direct.

The series applies to cel/nfsd-testing (78c334bc5ae6) and each patch
builds with W=1 with no warnings.

Changes since v3:
- Dropped "NFSD: Enable return of an updated stable_how to NFS
  clients" and "NFSD: add direct-mode WRITE settings that persist each
  WRITE" (v3 8/9 and 9/9).  The rest of the series does not depend on
  them.
- New 1/10, NFSD: cut a misaligned direct-mode WRITE at page
  boundaries (Cc: stable).  v3 cut the direct middle where the DIO
  offset alignment falls, which is a page boundary only when that
  alignment is the page size.
- Rebased onto the current cel/nfsd-testing.  5/10's size check moved
  into nfsd_direct_read_ok().
- Descriptions, comments and nfsd-io-modes.rst corrected throughout,
  among them: 2/10 says what can still make XFS re-issue the middle
  buffered once 1/10 keeps it off the pages the buffered ends share;
  3/10 says why a WRITE misaligned in memory is not split; 4/10 no
  longer misstates what the split threshold decides.
- 3/10: the threshold is direct_misaligned_min_bytes (default 8192)
  instead of direct_misaligned_num_pages (default 2).  On 4 KiB pages
  the default is unchanged.  The debugfs file is renamed with its unit,
  so a value written to the old name is not read as bytes.
- 6/10: a WRITE issued whole as O_DIRECT keeps IOCB_DSYNC; v3 turned a
  DATA_SYNC overwrite into a plain write plus an fsync.
- New 7/10, mm: add folio_mark_dropbehind().  v3 marked an already
  dirty folio dropbehind directly; the clean that follows subtracts it
  from WB_DONTCACHE_DIRTY, which never counted it, so the counter
  drifted negative and stopped the DONTCACHE writeback kick for the
  whole bdi_writeback.
- New 8/10, mm: expose WB_DONTCACHE_DIRTY in bdi debugfs stats.  Reports
  the counter 7/10 keeps balanced; Fixes: Jeff's commit that added it.
- 9/10: claims a page only where a buffered segment covers it partly, at
  either end of any segment, so a multi-page start or end segment and a
  sub-page WRITE are handled; claims for a split WRITE at any DIO offset
  alignment, since 1/10 keeps the direct middle out of the claimed
  pages; does not claim when the mapping's minimum folio is larger than
  a page; allocates with __GFP_WRITE; does not mark a page a short
  write did not reach; a FILE_SYNC or DATA_SYNC WRITE marks its shared
  pages after its own fsync, when they are clean, so they are not
  counted as DONTCACHE dirty and do not wake the writeback kick.  The
  description no longer says marking must not be accounted or that the
  kick targets marked folios.
- 10/10: the DONTCACHE state is its own tracepoint argument instead of a
  bit ORed into the disposition (nsegs is dropped; it follows from the
  segment sizes); the redundant #include "vfs.h" is gone;
  NFSD_WRITE_DIO_NO_ALIGN is renamed NFSD_WRITE_DIO_NO_ALIGNMENT to
  match its string; mem_offset is 0 for a WRITE with no payload.

v3: https://lore.kernel.org/linux-nfs/20261001045502.48381-1-snitzer@kernel.org/
v2: https://lore.kernel.org/linux-nfs/20260929231329.22018-1-snitzer@kernel.org/
v1: https://lore.kernel.org/linux-nfs/20260929173423.16149-1-snitzer@kernel.org/

Thanks,
Mike

Jonathan Flynn (1):
  NFSD: add direct_misaligned_dontcache debugfs knob

Mike Snitzer (9):
  NFSD: cut a misaligned direct-mode WRITE at page boundaries
  NFSD: mark the direct middle of a split WRITE IOCB_DONTCACHE as well
  NFSD: only split a direct-mode WRITE for a worthwhile direct middle
  NFSD: do not use direct I/O for a READ smaller than its alignment
  NFSD: persist a synchronous direct-mode WRITE once, after all of its segments
  mm: add folio_mark_dropbehind() to mark a folio dropbehind and account it
  mm: expose WB_DONTCACHE_DIRTY in bdi debugfs stats
  NFSD: keep boundary page of a split direct-mode WRITE until both writers complete
  NFSD: add tracing for how direct-mode READ and WRITE are serviced

 .../filesystems/nfs/nfsd-io-modes.rst         |  93 +++++-
 fs/nfsd/debugfs.c                             |  25 ++
 fs/nfsd/nfsd.h                                |   2 +
 fs/nfsd/trace.h                               |  77 +++++
 fs/nfsd/vfs.c                                 | 265 +++++++++++++++---
 fs/nfsd/vfs.h                                 |   9 +
 include/linux/pagemap.h                       |   1 +
 mm/backing-dev.c                              |  11 +
 mm/filemap.c                                  |  31 ++
 9 files changed, 473 insertions(+), 41 deletions(-)


base-commit: 78c334bc5ae61d23ca1cc2e43079c620f1d40866
-- 
2.52.0

