Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6F6D5339B3D
	for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 23:13:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790723613; cv=none; b=TQCWfm/LFwxqp82GY0tNW2uI2/xwAH9U7WLDnVjUxqU5rTbESw/gLZ7vqGnlx0B++G3uCWk7Y/nRI9h0FgNMALI7yA3rxCipgDB7S5EU9BnfZAquBNqoqKjAdwk1W5SkEDhW7PJnLva1zd6+PuenpDkz3UywDhRkf4GWePyy6OM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790723613; c=relaxed/simple;
	bh=oeBXhvhSReQO69T8Rorid++eaLd0ceJgw59rX1E3m1w=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=POPAbo7hKyK0w5IrzK4GL2f9OVDtzcWgqJ9cUFPnq1x00fbZQJG1SJAcQa8Y3fij2Vj9gXCYYyENcx0c/hRLdW3g13NYv13/8Kkz1EoFqEsNxZr7QpFPAYWxXfs56YGoaKSug8FKF9Wp+yLJTms804eNZf4TfBan8Wm8cCiojow=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=AtqjmtSH; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="AtqjmtSH"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E55221F00893;
	Tue, 29 Sep 2026 23:13:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790723612;
	bh=na33Rmqtd6Pbt5wZSN/KWTnG2ie/awJrLwNQWaUkKps=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=AtqjmtSHdFuQ5QZ8UrKM/Jrr7ITa0b3082vCYsJyqZU/C3eLaIyzJoBr97fGs/RMT
	 WwVL2AZY6yMyeABC4NmO2JGQXke8f4nyYI6T6+j1H06NJ0yihQYuCgZSzYT0N26FHe
	 Rvo7p28tc2Ql+mSGRtWaWPpAQTdtCz0SDLuM0AAV0OgEh3sIQzn4FtFvG43WCaB1n7
	 1zlMe75XN8efngBQ0or4WoqHP9PPQFIq1ciMUVAsT7okgV0y130VKWIPo+wR5qa7nK
	 H2aHP+Dmqq0rjWhXRYqhd+nUbpd8FvM52p2g0PUjMSFJ/y+pZr2zuajnSAwBzilpsD
	 EqoH58BsiqiCw==
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/9] NFSD: mark the direct middle of a split WRITE IOCB_DONTCACHE as well
Date: Tue, 29 Sep 2026 19:13:21 -0400
Message-ID: <20260929231329.22018-2-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20260929231329.22018-1-snitzer@kernel.org>
References: <20260929231329.22018-1-snitzer@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfsd_write_dio_iters_init() issues the DIO-aligned middle of a
misaligned WRITE with IOCB_DIRECT.  A file system is free to service
that request with buffered I/O instead: xfs_file_write_iter() retries
via xfs_file_buffered_write() with the same kiocb whenever
xfs_file_dio_write() returns -ENOTBLK, which iomap_dio_rw() produces
when the invalidation it runs before issuing the direct I/O cannot drop
page cache overlapping the range.

That happens routinely in a streaming misaligned WRITE workload with
more than one request in flight.  Request N's direct middle ends inside
the same page that request N+1's buffered prefix starts in.  If N+1's
prefix dirties that page between N's filemap_write_and_wait_range() and
N's invalidate_inode_pages2_range(), the invalidation returns -EBUSY,
iomap returns -ENOTBLK, and XFS re-issues N's entire middle, tens of
kilobytes, as a normal cached buffered write.  Nothing ever drops those
pages.  On a device with dma_alignment=3 (XFS then reports
dio_mem_align=4, which XDR-aligned RPC payloads always satisfy) this is
the only remaining path by which a stream of small misaligned WRITEs in
DIRECT mode fills the page cache.

Set IOCB_DONTCACHE on the middle segment alongside IOCB_DIRECT when the
file system supports FOP_DONTCACHE.  The direct path ignores the flag,
and generic_write_sync() only issues a harmless flusher kick; but if
the file system falls back to buffered I/O the write is now DONTCACHE
rather than cached.  The nfsd_write_direct trace event is unchanged
since it keys on IOCB_DIRECT; the fallback itself remains observable
via the iomap_dio_invalidate_fail event.

Fixes: 06c5c97293e3 ("NFSD: Implement NFSD_IO_DIRECT for NFS WRITE")
Assisted-by: Claude:claude-fable-5-1
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 Documentation/filesystems/nfs/nfsd-io-modes.rst | 10 ++++++++++
 fs/nfsd/vfs.c                                   |  9 +++++++++
 2 files changed, 19 insertions(+)

diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentation/filesystems/nfs/nfsd-io-modes.rst
index 0fd6e82478fe6..dc50c930f9762 100644
--- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
+++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
@@ -130,6 +130,16 @@ Misaligned WRITE:
     segments because using normal buffered IO offers significant RMW
     performance benefit when handling streaming misaligned WRITEs.
 
+    The O_DIRECT middle segment also carries the DONTCACHE flag. It has
+    no effect while the IO really is O_DIRECT, but a filesystem may
+    decide on its own to service the segment with buffered IO instead
+    (XFS does so when it cannot invalidate page cache that overlaps the
+    segment, which can happen when another WRITE's buffered start or
+    end segment dirties the shared boundary page at the same time).
+    The flag makes that fallback DONTCACHE buffered IO rather than
+    normal buffered IO. Such fallbacks are visible through the
+    iomap_dio_invalidate_fail trace event; see Tracing below.
+
 Tracing:
     The nfsd_read_direct trace event shows how NFSD expands any
     misaligned READ to the next DIO-aligned block (on either end of the
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index f9131827d391e..5b963f0e3b3f2 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1341,6 +1341,15 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	if (iov_iter_bvec_offset(&segments[nsegs].iter) & (mem_align - 1))
 		goto no_dio;
 	segments[nsegs].flags |= IOCB_DIRECT;
+	/*
+	 * Also mark the direct middle DONTCACHE: the file system may fall
+	 * back to buffered I/O on its own (e.g. XFS on -ENOTBLK when it
+	 * cannot invalidate page cache that a concurrent buffered prefix or
+	 * suffix of an adjacent WRITE just dirtied), and it reuses this kiocb
+	 * to do so.  On the direct path itself the flag is inert.
+	 */
+	if (nf->nf_file->f_op->fop_flags & FOP_DONTCACHE)
+		segments[nsegs].flags |= IOCB_DONTCACHE;
 	nsegs++;
 
 	if (suffix)
-- 
2.52.0

