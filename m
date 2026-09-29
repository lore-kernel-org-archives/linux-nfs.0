Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 662ED3E8340
	for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 23:13:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790723612; cv=none; b=h6zfP+OKD0G9jRIlY+E2pZgBImD4uK5jbjoiSS4zYxHhaQ+Oaj9joQQDHRUZouIsvqkfM1o/RZdSXjhrsZmrYXJEtRRv/UdIUWjgWKzA78gyreC8JsAuq0zeiA5LaWfpJRUVXUTDp65cSjxc3krbSK6CE9l6m10vavHGj7rjefE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790723612; c=relaxed/simple;
	bh=jfzohE8GFzZA+C8nsnSPZu+NlRaUno4DBkcglACkMS0=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=pmke72yEnhwHqMyQ6xRXSxTvs1hCgrZfhXnwLQ2xOUiRrEni5+250yzlhXXMuDtFM0y9+307ogehVhsnoP+FgaOkoaKvVLCOGaAZMRAuRjcTxsAqxeZVFmhH+NHihRWZIjtWITAhTihC3FF348i1vhsrbKv60f2kpec62nnrWi8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=KjTh7CZz; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="KjTh7CZz"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AF5241F000FF;
	Tue, 29 Sep 2026 23:13:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790723610;
	bh=Dzz2N9MheGKNxkzIu7BppS9ufY7xt51RhLF3vAuVUAU=;
	h=From:To:Cc:Subject:Date;
	b=KjTh7CZznmhrlOU33GOZv4SqGBgUqoCQNwpcn6rG+Djeouk0y5zp0gsRGrL06rjod
	 W/dGu1j4C6J3YWoDiEw9uNE31fpMDd78I/vHos9GFBQwCLbvsTS5F3wp3j7Nn4wMC8
	 xZMnV0lrMQU3ZvKHtJyvHpMleX4cR9/dl1bJzHtW+2WjwcArW4I2Rhdq7WZABFr3F1
	 NRdN0P2ZMfym9kOxLJNKbqrtxKXY3XYHyGbjJk3uabxmYRT9By2Pa13sZ5D0ZmbUQD
	 ec6pgsFy7wtyDqpK7gfdmZ7bRJ4yfuuNLIavIYyBeAGOyNdm1uTEMNj5lS8qmJv1fC
	 IiTMVt4RmYitg==
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/9] NFSD: keep direct-mode I/O out of the page cache and elide COMMITs
Date: Tue, 29 Sep 2026 19:13:20 -0400
Message-ID: <20260929231329.22018-1-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Hi,

What this advance is, precisely.  It is not "NFSD uses DONTCACHE".  It
is NFSD's direct write path - io_cache_write modes 2, 3 and 4, where
an aligned WRITE goes to the filesystem as O_DIRECT - with DONTCACHE
used only for the buffered fragments a misaligned WRITE cannot issue
directly.  The page cache is bypassed for the bulk of the data and
bounded for the remainder.  That distinction runs through everything
below, and it is exactly what separates this from io_cache_write=1,
which is plain buffered DONTCACHE with no direct I/O at all and does
not reach this code.

nfsd-next already issues what a direct-mode READ or WRITE cannot do
directly as DONTCACHE.  Within that path, this series changes when
direct I/O is attempted at all, closes the one case where a direct
middle could still land in the page cache, lets a WRITE report the
stability it actually has so the client skips its COMMIT, keeps the
page two misaligned WRITEs share until both have written it, and adds
tracepoints that show which path each request took.

Patches 1-3 cover what cannot or should not be direct: the direct
middle of a split WRITE is also marked IOCB_DONTCACHE, for when XFS
falls back to buffered I/O (-ENOTBLK); a WRITE is split only when that
buys a worthwhile direct middle (direct_misaligned_num_pages, default
2); and, on the READ side, a READ smaller than its alignment no longer
costs a full aligned device read.

Patch 4 is Chuck's "Enable return of an updated stable_how to NFS
clients", reworked onto the @iocb_flags argument nfsd_write() now takes
in nfsd-next.  The Reviewed-by tags from its first posting are dropped
because the argument changed.

Patch 5 adds io_cache_write modes 3 and 4, which issue direct I/O like
NFSD_IO_DIRECT and raise the reply's stable_how to at least DATA_SYNC
or FILE_SYNC.  On a pNFS flexfiles share where every write is split
across two data servers, the COMMITs alone cost NFSD_IO_DIRECT 31% more
server CPU and 42% more client CPU for the same bytes.

Patch 6 persists a synchronous direct-mode WRITE once, after all of its
segments, instead of up to three fsyncs per WRITE.

Patch 7 keeps the page that two misaligned WRITEs share in the page
cache until both have written it, so the second one no longer has to
read it back from disk: with 32 interleaved writers, 704 device reads
for 42895 WRITEs where there were 45144 for 45664.

Patch 8 (Jonathan) adds the direct_misaligned_dontcache debugfs knob,
default Y; set to N, the parts of a direct-mode WRITE that cannot be
direct use cached buffered I/O instead of DONTCACHE.

Patch 9 adds tracepoints for how each direct-mode READ and WRITE was
serviced, including why a WRITE was not direct.

Documentation/filesystems/nfs/nfsd-io-modes.rst is updated throughout.
The series applies to cel/nfsd-next (ac04dab23b5f) and each patch
builds cleanly with W=1.

Changes since v1:
- Dropped v1's patch 1, "NFSD: interlock the use of NFSD_IO_DIRECT for
  NFS READ and WRITE".  io_cache_read and io_cache_write stay
  independent: tying them together would rule out defaults that differ
  by direction, such as direct WRITE with buffered READ.
- Rewrote the introduction above to say precisely which path this
  series changes.  v1's said the series makes direct-mode I/O fall back
  to DONTCACHE; nfsd-next already does that.
- No change to the remaining nine patches; patch 5 now applies without
  the interlock beneath it, which changes only its context.

v1: https://lore.kernel.org/linux-nfs/20260929173423.16149-1-snitzer@kernel.org/

All review appreciated, thanks.
Mike

Chuck Lever (1):
  NFSD: Enable return of an updated stable_how to NFS clients

Jonathan Flynn (1):
  NFSD: add direct_misaligned_dontcache debugfs knob

Mike Snitzer (7):
  NFSD: mark the direct middle of a split WRITE IOCB_DONTCACHE as well
  NFSD: only split a direct-mode WRITE for a worthwhile direct middle
  NFSD: do not use direct I/O for a READ smaller than its alignment
  NFSD: let a direct-mode WRITE raise stable_how and elide the client's COMMIT
  NFSD: persist a synchronous direct-mode WRITE once, after all of its segments
  NFSD: keep boundary page of a split direct-mode WRITE until both writers complete
  NFSD: add tracing for how direct-mode READ and WRITE are serviced

 .../filesystems/nfs/nfsd-io-modes.rst         | 129 ++++++-
 fs/nfsd/debugfs.c                             |  40 +++
 fs/nfsd/nfs3proc.c                            |  16 +-
 fs/nfsd/nfs4proc.c                            |  15 +-
 fs/nfsd/nfsd.h                                |   4 +
 fs/nfsd/nfsproc.c                             |   3 +-
 fs/nfsd/trace.h                               |  90 +++++
 fs/nfsd/vfs.c                                 | 318 +++++++++++++++---
 fs/nfsd/vfs.h                                 |  26 +-
 fs/nfsd/xdr3.h                                |   2 +-
 10 files changed, 582 insertions(+), 61 deletions(-)

-- 
2.52.0

