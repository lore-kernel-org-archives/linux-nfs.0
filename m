Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 068CD3803F4
	for <linux-nfs@vger.kernel.org>; Thu,  1 Oct 2026 04:55:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790830506; cv=none; b=A21AhOTIgxFQUGuORAXBQB/5nJ+uGCzPUm8BdoyXgmqZ481hspgK9xd6dW+qBQN6atgcFre/BkIntgXvewuU17a10QNttyaP/2vFpkANP4DW5d1uWcfcUlvb7RRluAGsRN0AB5E8QbNawvAioI6f/l2jKGzaJAFjX6UuIpM6UR4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790830506; c=relaxed/simple;
	bh=/fmpFYSiuu/n67mxgvNxYwoNxR/Vhwp+hO2cdQPkefM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=FEvykdkNpo7+tY5kLDhJgPHvWBXTwcSeHpuO3xpESp7RIgRkUvyOGXESTAOaaGDIQN4G8CMe3on/FjP2Qos+Jbh8uLrmAHmyV56oI92klZ0PCSQ1XB3rcW3KOVvEIMtkyXpmzoi89xgNwxTZDsUcUD/UBDF7THd2jBrL8SKl8yY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=T/ADQKS0; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="T/ADQKS0"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6E3941F00898;
	Thu,  1 Oct 2026 04:55:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790830504;
	bh=mwIFU7RQjl7yYOxHo65fE7ZJzaKR7cUWIGGQMRpoBJY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=T/ADQKS0KPLSVbjvjAXj9fx5ZcVRjqFHImBJguXzVidnXQK6BRdpG3d+ZrrkCy6Ug
	 Ii1FQU2UYvlh49zT67nUJxrhywP2Wo5NJsCgMRxEg939Tfrw0J9BCmmHl2nOjuQg2W
	 HASJJSjkfZ9QnJbFxwX/R7KECe1Gli1RRDy0XCt9Z1qLdSf/5OsaRRRZ3qx2yUWPh3
	 h6qM8T368NHJUvtyVAjERSsYBS4sEswACIHIHJX3ZqqrcPEfB5U7p8LhA+evPyhJJv
	 1HItt7Upowr/TJXXtrJMPzH56gYkio1TqG45dqoPu7zGyG9qzBjiudePL76+BC1G2p
	 EfFAks0YwFg3g==
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: hch@lst.de,
	linux-nfs@vger.kernel.org
Subject: [PATCH v3 1/9] NFSD: mark the direct middle of a split WRITE IOCB_DONTCACHE as well
Date: Thu,  1 Oct 2026 00:54:54 -0400
Message-ID: <20261001045502.48381-2-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261001045502.48381-1-snitzer@kernel.org>
References: <20261001045502.48381-1-snitzer@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfsd_write_dio_iters_init() issues the DIO-aligned middle of a
misaligned WRITE with IOCB_DIRECT.  A file system may service that
request with buffered I/O instead: xfs_file_write_iter() retries
through xfs_file_buffered_write() with the same kiocb when
xfs_file_dio_write() returns -ENOTBLK, which iomap_dio_rw() does when
it cannot invalidate page cache overlapping the range.

In a streaming misaligned WRITE workload with more than one request in
flight this happens routinely.  Request N's direct middle ends in the
page where request N+1's buffered prefix starts.  If N+1 dirties that
page between N's writeback and N's invalidation, the invalidation
fails and XFS re-issues all of N's middle, tens of kilobytes, as a
cached buffered write that nothing ever drops.

Set IOCB_DONTCACHE on the middle segment alongside IOCB_DIRECT when
the file system supports FOP_DONTCACHE.  The direct path ignores the
flag; a buffered fallback now drops its pages once written back.

nfsd-io-modes.rst said that DONTCACHE is not used for the misaligned
segments, which the write loop already contradicted: every segment
without IOCB_DIRECT gets IOCB_DONTCACHE when the file system supports
it.  Replace that sentence with one that covers all three segments.

Fixes: 06c5c97293e3 ("NFSD: Implement NFSD_IO_DIRECT for NFS WRITE")
Assisted-by: Claude:claude-fable-5-1
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 Documentation/filesystems/nfs/nfsd-io-modes.rst | 8 +++++---
 fs/nfsd/vfs.c                                   | 3 +++
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentation/filesystems/nfs/nfsd-io-modes.rst
index 0fd6e82478fe6..60b0af9b7e49f 100644
--- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
+++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
@@ -126,9 +126,11 @@ Misaligned WRITE:
     middle and end as needed. The large middle segment is DIO-aligned
     and the start and/or end are misaligned. Buffered IO is used for the
     misaligned segments and O_DIRECT is used for the middle DIO-aligned
-    segment. DONTCACHE buffered IO is _not_ used for the misaligned
-    segments because using normal buffered IO offers significant RMW
-    performance benefit when handling streaming misaligned WRITEs.
+    segment. If the filesystem supports FOP_DONTCACHE, every segment is
+    marked DONTCACHE. The flag has no effect on the O_DIRECT segment
+    unless the filesystem services it with buffered IO instead, as XFS
+    does when it cannot invalidate page cache that overlaps the segment.
+    The iomap_dio_invalidate_fail trace event reports such a fallback.
 
 Tracing:
     The nfsd_read_direct trace event shows how NFSD expands any
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 4584d5b94feed..1ccdac4693745 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1341,6 +1341,9 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	if (iov_iter_bvec_offset(&segments[nsegs].iter) & (mem_align - 1))
 		goto no_dio;
 	segments[nsegs].flags |= IOCB_DIRECT;
+	/* In case the file system falls back to buffered I/O (-ENOTBLK). */
+	if (nf->nf_file->f_op->fop_flags & FOP_DONTCACHE)
+		segments[nsegs].flags |= IOCB_DONTCACHE;
 	nsegs++;
 
 	if (suffix)

base-commit: 32eb1a60b456980761cf7a9cee8f907fdc08afb8
-- 
2.52.0

