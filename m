Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D6E0936DA0D
	for <linux-nfs@vger.kernel.org>; Thu,  1 Oct 2026 04:55:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790830505; cv=none; b=jQt6EHmFwmjR6KG8sr5ceUgiW7aWOePCYncXIffCUJszvFrsxB5ZIJIl2LfeSCO8uKyHbnl9GC+eYrQjFXfAE1oKNVRP1c5eUOWQhzmFRknQg81TGWVZvA/0tC6xoU6ThHc5eJj31mQ9uaD6vhjTpJ2b7pWEwFDkcNGXuWn6CiY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790830505; c=relaxed/simple;
	bh=jPJEtfwD0+0M1X6TyqoKrDkebAwgN3n1uDOcoDoZWk4=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=iprmA2uO9J+ubcAXiHzOG5s1pVNAYWfmvSWVfn2+86TFqY47r6QprDLf5oBAlNrbbEukg9aMbKxEcNqYh4gRMr0G2msJ0+NUuHbaoc6T8fMWHTCUbAWy2/3bralN48YmgKP5MyRnUGRQchCaSiGJx2eQbDFG6pj/puTZf8NWBEE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=kqtWNwgT; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="kqtWNwgT"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2F06E1F000FF;
	Thu,  1 Oct 2026 04:55:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790830503;
	bh=9C+n9Rs9taRb7n0USDD+NQ7sMKw5MPwVUGcGcNix3eI=;
	h=From:To:Cc:Subject:Date;
	b=kqtWNwgT6nAWo0VMlZ00C+Tc4EdfaYN+tZcKdwbZTuSGX2YgsmvtOY1Th1HDMt9cL
	 nFb+IL1bGF23hxconnP54eDmYTlca8/oWQREwxkQqRXNl6NkPp2Y5/xxUkF87J9NVb
	 kX/gV+EdXenxQybye6xCCR7kjK4reHhVS+VZIvPA2owZ7sHY4yIFKh9b7AEHNn86JN
	 htxjrvCClV9lwzwL4rk4lLSOHjtEyQD8XwOWbv1hCk+Za1nIMU3H3rRhvu8v0hzY9f
	 NE5F1NLmyvFwqx5C/7VnuwnALluqNsdsXGq0QGv1bVsjcd81DI/AXR+dCLsirSxKlN
	 yUPC6380pAXtw==
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: hch@lst.de,
	linux-nfs@vger.kernel.org
Subject: [PATCH v3 0/9] NFSD: keep direct-mode I/O out of the page cache
Date: Thu,  1 Oct 2026 00:54:53 -0400
Message-ID: <20261001045502.48381-1-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Hi,

This series changes NFSD's direct write path: io_cache_write modes
where an aligned WRITE goes to the filesystem as O_DIRECT, with
DONTCACHE for the parts a misaligned WRITE cannot issue directly.

1/9 marks the direct middle of a split WRITE IOCB_DONTCACHE, for when
XFS re-issues it buffered (-ENOTBLK).  It carries Fixes: and rewrites
the stale nfsd-io-modes.rst sentence in place, so a stable tree
carrying only this patch reads consistently.

2/9 splits a misaligned WRITE only for a direct middle of at least
direct_misaligned_num_pages (default 2).  3/9 (Jonathan) adds
direct_misaligned_dontcache, which selects whether the parts that are
not O_DIRECT are DONTCACHE or cached.

4/9 stops expanding a READ smaller than its alignment into a full
aligned device read.

5/9 persists a synchronous direct-mode WRITE once, after all of its
segments, instead of once per segment.  6/9 keeps the page two
misaligned WRITEs share until both have written it: 704 device reads
for 42895 WRITEs where there were 45144 for 45664.  7/9 adds
tracepoints for how each direct-mode READ and WRITE was serviced.

8/9 and 9/9 are separable and come last for that reason.  8/9 is
Chuck's "Enable return of an updated stable_how to NFS clients",
reworked onto @iocb_flags.  9/9 adds two opt-in io_cache_write modes
that persist every direct-mode WRITE before replying and report
NFS_DATA_SYNC or NFS_FILE_SYNC, so the client sends no COMMIT.  A
client can get the same result by sending FILE_SYNC itself, so 1-7
stand without them.

The series applies to cel/nfsd-testing (32eb1a60b456) and each patch
builds with W=1 with no warnings.

Changes since v2:
- Rebased onto cel/nfsd-testing; 8/9 now applies to the xdrgen
  nfsd_proc_write().
- 1/9: replaces the "DONTCACHE buffered IO is _not_ used" sentence
  instead of adding a paragraph that contradicted it.
- 2/9: the description now opens with the cost a small middle adds,
  says the IOCB_* flags only move (the write loop already set
  IOCB_DONTCACHE), and says which parts of Christoph's diff are taken
  and why the DONTCACHE policy and the memory-misaligned collapse are
  not.  The DONTCACHE explanation is one comment at no_dio; the
  debugfs comment sits on the debugfs_create_u32() call; "three
  segments" is now "two or three".
- Reordered: direct_misaligned_dontcache moved up to 3/9, beside
  direct_misaligned_num_pages, and the boundary-page patch (now 6/9)
  adds its own fields.  The two stable_how patches moved to the end
  (8/9, 9/9), since nothing before them depends on them.
- 8/9: the async export option clears a local copy, so the reply to a
  FILE_SYNC or DATA_SYNC WRITE to an async export is never lowered
  (RFC 1813 3.3.7).  The description says where NFSv3 and NFSv4 map
  the result, and no longer says O_DIRECT persists data.
- 9/9: retitled.  The description says an UNSTABLE O_DIRECT write is not
  durable, that NFSD_IO_DIRECT is unchanged, and that the new modes cost
  a flush per WRITE.  They are worth it only where each COMMIT covers
  about one WRITE.
- Comments and documentation trimmed throughout.

v2: https://lore.kernel.org/linux-nfs/20260929231329.22018-1-snitzer@kernel.org/
v1: https://lore.kernel.org/linux-nfs/20260929173423.16149-1-snitzer@kernel.org/

Thanks,
Mike

Chuck Lever (1):
  NFSD: Enable return of an updated stable_how to NFS clients

Jonathan Flynn (1):
  NFSD: add direct_misaligned_dontcache debugfs knob

Mike Snitzer (7):
  NFSD: mark the direct middle of a split WRITE IOCB_DONTCACHE as well
  NFSD: only split a direct-mode WRITE for a worthwhile direct middle
  NFSD: do not use direct I/O for a READ smaller than its alignment
  NFSD: persist a synchronous direct-mode WRITE once, after all of its segments
  NFSD: keep boundary page of a split direct-mode WRITE until both writers complete
  NFSD: add tracing for how direct-mode READ and WRITE are serviced
  NFSD: add direct-mode WRITE settings that persist each WRITE

 .../filesystems/nfs/nfsd-io-modes.rst         |  97 ++++++-
 fs/nfsd/debugfs.c                             |  28 ++
 fs/nfsd/nfs3proc.c                            |  16 +-
 fs/nfsd/nfs4proc.c                            |  15 +-
 fs/nfsd/nfsd.h                                |   4 +
 fs/nfsd/nfsproc.c                             |   3 +-
 fs/nfsd/trace.h                               |  85 +++++++
 fs/nfsd/vfs.c                                 | 239 +++++++++++++++---
 fs/nfsd/vfs.h                                 |  18 +-
 fs/nfsd/xdr3.h                                |   2 +-
 10 files changed, 449 insertions(+), 58 deletions(-)


base-commit: 32eb1a60b456980761cf7a9cee8f907fdc08afb8
-- 
2.52.0

