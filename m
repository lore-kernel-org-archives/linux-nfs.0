Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793740685;
	b=gpO2z8Tb9Sqz/AiCO8IzVFm9Ldo2e+ICOshTqfSn3NxmTT9PMLgxAY+8Pt7rjVEvyINf
	 L8v4OwTRAswu0u4SHKpe2JFF37XouMCDSSjdiAhKYz5XjiiuxUAcIo/gHPMDvquE1Chev
	 0Hpz0bJQeOEXnvB1qRlZhWiibwgECLnzDHKe1YGlSRV2rMOsrZRzLMdHekqqpbVr8ogbR
	 O2EQ6kPRx4dLLx1YTC6F5vtQQZYnII/Egw8fspixeYyRF2sbTaKuJ1E+sSZ/0pEpJbb6G
	 pCBiLVQz8JMhdSqPV8WrbKztoVHKEdNtANRFjIvcJAdmSgJHZD1UdY53sYVU+vwF6JQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793740685;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=otN7QOjeo6dcKarm7LHPsOKbLf9K9HRa9TUg3MA/Yfs=;
	b=3CxjJTAnzvvAROybqLqrEprP/b6vCqzBUBx2+JJwddXir6Ie2x5ip22t+ylkYr1Mcpax
	 H03rPFKcKk8iKF5zpXm09HMKb8eT0uEmAipsYJx8pQo8rTduPoa0uSLfG6oRTdLbqtMOB
	 hzj3LqHcC9JQawbR/Hdh69FpDK286Ry6hTF5MaDyuLqQdq272IEOGQ3AqKax9gN+WcW/F
	 cJqSMjEEw1zqOPHViL02I1g3izBXVqzBNO+y4KbTffmAkkfdJDwQthGWoGYGQfZxLGSuV
	 /TKEdN8miB7ZXsRC0DItwPXzITzbjHtYsRlWZaDIYfq47dXKS9/r78b6qV9Vc1iHdBw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=MBSkZoy0;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B2051606A324;
	Tue,  3 Nov 2026 21:18:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=MBSkZoy0
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2D2C01F00A23;
	Tue,  3 Nov 2026 21:18:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793740684;
	bh=otN7QOjeo6dcKarm7LHPsOKbLf9K9HRa9TUg3MA/Yfs=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=MBSkZoy0pO7s2+hbeLhyMD3sMfHFSTTrR/RaK642/GIJRJYggdX4QHiN4Y9p+yg/L
	 C9m07sCRG1mgiLznHxqYibxTuQ/wYIc6aiV6EGjfDCiaAe/JQEiaY8g4a2ZXU2RFvn
	 vqX3HP1vIjqotF64KpWLbm8I4BPLPrk+GckPOG39CAQigeUK68LgmI6herlZxHWnPD
	 kXYoWzphYMozrJTkacMC9SsV9lINDQtnuTUexSAv0fsN5gk0ZpL1wP210a1gsTUB56
	 6tCHXKXMV3bI4Ke9B52+5YD6EBqLwVzHt892L0urWHvHoMF0+x0yIriTUMLNGPsHz5
	 QwMEy6l0vVDaQ==
From: Mike Snitzer <snitzer@kernel.org>
To: Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Cc: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	linux-nfs@vger.kernel.org,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Christoph Hellwig <hch@lst.de>,
	Jens Axboe <axboe@kernel.dk>,
	Jonathan Corbet <corbet@lwn.net>,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: [PATCH v10 7/7] NFSD: drop a shared boundary page only once both WRITEs have written it
Date: Tue,  3 Nov 2026 16:17:54 -0500
Message-ID: <20261103211754.35352-8-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261103211754.35352-1-snitzer@kernel.org>
References: <20261103211754.35352-1-snitzer@kernel.org>
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

NFSD splits a misaligned direct-mode WRITE into a direct middle and
buffered DONTCACHE ends.  Each end covers its first or last unit, the
smallest folio the mapping allows, only partly, and shares that unit
with the neighbouring WRITE.

Issue the buffered ends with IOCB_DONTCACHE_DEFER.  Before writing an
end, ask filemap_dontcache_edge_completes() whether the neighbouring
WRITE has written its part of each shared unit.  Once the WRITE, its
fsync included, is done, complete those units with
filemap_dontcache_edge_complete().  A short write completes a unit only
if it wrote its own part of it.

With this commit, 32 interleaved writers of 47008-byte records through
NFSD DIRECT read 0.0001 to 0.0002 blocks per WRITE, instead of reading
0.99 blocks per WRITE.  FILE_SYNC WRITEs no longer wake the DONTCACHE
writeback kick, where they woke it 23,000 to 65,000 times a run without
IOCB_DONTCACHE_DEFER.  On a four-server pNFS flexfiles rig, the page
cache grew by 2.9 GiB during the write phase instead of about 11 GiB.

Reported-by: Jonathan Flynn <jonathan.flynn@hammerspace.com>
Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---

Notes:
    Notes on questions from earlier reviews, with the code that answers each:
    
    - Unit size.  nfsd_write_dio_seg_hold() uses
      mapping_min_folio_nrbytes(), as iomap_get_folio() does (5/7).  The
      cut between the buffered ends and the direct middle is on the same
      boundary since commit b16607436d31 ("NFSD: cut a misaligned
      direct-mode WRITE at folio boundaries") in cel/nfsd-testing.
    - Short write.  NFSD completes the first edge only if written is at
      least first_len, and the last edge only if the write covered the
      whole segment.
    - Release after an error.  This is on purpose.  A segment whose write
      failed is not held: nheld increases only after a write that returns
      >= 0.  A held segment wrote its bytes, so its edges hold the data
      of both WRITEs.  After an fsync error the release still runs: the
      folio is clean when its writeback ends, and the helper drops it as
      DONTCACHE writeback would.  The error stays in the mapping and
      NFSD returns it.  The release changes only what stays cached,
      never data.
    - Unset fields.  For a segment that holds nothing,
      nfsd_write_dio_seg_hold() returns early and does not set
      first_len.  complete_first and complete_last are then false, so
      nfsd_write_dio_seg_release() does not read first_len.
    - Array size.  nsegs is at most 3, so nheld is at most 3 (holds[3]).

 .../filesystems/nfs/nfsd-io-modes.rst         |  17 +++
 fs/nfsd/vfs.c                                 | 106 ++++++++++++++++--
 2 files changed, 111 insertions(+), 12 deletions(-)

diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentation/filesystems/nfs/nfsd-io-modes.rst
index e6fd91cac9c77..57acc8f0407ee 100644
--- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
+++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
@@ -197,6 +197,23 @@ Misaligned WRITE:
     above. Set it to N for a workload that reads back or rewrites what
     it just wrote.
 
+    The page holding a start or end segment is shared with the
+    neighbouring WRITE, which may arrive before, after or at the same
+    time, from any client. So that the second WRITE to such a page does
+    not have to read it back from disk, the page cache keeps a page an
+    uncached write covers only partly, unmarked, for the write that
+    completes it. NFSD asks, immediately before writing a start or end
+    segment, whether the neighbouring WRITE has already written its
+    part; if it has, NFSD marks the page DONTCACHE once its own WRITE,
+    including its fsync, is complete, and the page is dropped. A page
+    whose neighbouring WRITE never arrives, or arrives at the same time,
+    stays cached until it is reclaimed. The first and last pages of a
+    WRITE that is not split are handled the same way.
+
+    None of this applies when the start and end segments are normal
+    buffered IO, or for a filesystem that does not use iomap for
+    buffered writes.
+
 Tracing:
     The nfsd_read_direct trace event marks a READ that NFSD issues as
     O_DIRECT. It records the offset and length the client requested.
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 269dc4968f197..5a2bd2f57620a 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1428,6 +1428,7 @@ static int wait_for_concurrent_writes(struct file *file)
 struct nfsd_write_dio_seg {
 	struct iov_iter			iter;
 	int				flags;
+	bool				claim;		/* completes shared pages */
 };
 
 static unsigned long
@@ -1447,6 +1448,78 @@ nfsd_write_dio_seg_init(struct nfsd_write_dio_seg *segment,
 		iov_iter_advance(&segment->iter, start);
 	iov_iter_truncate(&segment->iter, len);
 	segment->flags = iocb->ki_flags;
+	segment->claim = false;
+}
+
+/* The shared pages a segment completes, and how much of it was written. */
+struct nfsd_write_dio_hold {
+	loff_t	first, last;
+	size_t	first_len;	/* the segment's bytes in its first unit */
+	bool	complete_first, complete_last;
+	size_t	written;
+};
+
+/*
+ * A page that a buffered DONTCACHE segment covers only partly is shared with
+ * the neighbouring WRITE.  The page cache keeps it, unmarked, for the write
+ * that completes it; the segment is issued IOCB_DONTCACHE_DEFER so that this
+ * WRITE, not the page cache, marks it, once the whole WRITE, its fsync
+ * included, is complete.  Ask whether the neighbour has already written its
+ * part immediately before writing @seg: asking earlier gives the neighbour
+ * time to write its part and find this WRITE's part missing.
+ */
+static void
+nfsd_write_dio_seg_hold(struct file *file, const struct nfsd_write_dio_seg *seg,
+			loff_t pos, size_t len, struct nfsd_write_dio_hold *hold)
+{
+	struct address_space *mapping = file->f_mapping;
+	size_t unit, last_len;
+	loff_t mask, last_unit;
+	bool one_unit, head, tail;
+
+	hold->first = pos;
+	hold->last = pos + len - 1;
+	hold->complete_first = false;
+	hold->complete_last = false;
+	hold->written = 0;
+	if (!seg->claim || !len)
+		return;
+
+	/* The shared unit is the smallest folio the mapping allows. */
+	unit = mapping_min_folio_nrbytes(mapping);
+	mask = ~(loff_t)(unit - 1);
+	one_unit = (hold->first & mask) == (hold->last & mask);
+	head = hold->first & (unit - 1);
+	tail = (hold->last + 1) & (unit - 1);
+	last_unit = hold->last & mask;
+	last_len = (hold->last & (unit - 1)) + 1;
+
+	hold->first_len = min_t(size_t, len,
+				unit - (hold->first & (unit - 1)));
+	if (head || (one_unit && tail))
+		hold->complete_first =
+			filemap_dontcache_edge_completes(mapping, hold->first,
+							 hold->first_len);
+	if (!one_unit && tail)
+		hold->complete_last =
+			filemap_dontcache_edge_completes(mapping, last_unit,
+							 last_len);
+}
+
+/* Drop the shared pages this WRITE was the second of two to write. */
+static void
+nfsd_write_dio_seg_release(struct file *file,
+			   const struct nfsd_write_dio_hold *hold)
+{
+	struct address_space *mapping = file->f_mapping;
+
+	/* A short write may have stopped inside the first unit. */
+	if (hold->complete_first && hold->written >= hold->first_len)
+		filemap_dontcache_edge_complete(mapping, hold->first);
+	/* A short write did not reach the last unit. */
+	if (hold->complete_last &&
+	    hold->written == hold->last - hold->first + 1)
+		filemap_dontcache_edge_complete(mapping, hold->last);
 }
 
 static unsigned int
@@ -1469,7 +1542,9 @@ nfsd_write_dio_iters_init(struct svc_rqst *rqstp, struct svc_fh *fhp,
 
 	if (nf->nf_file->f_op->fop_flags & FOP_DONTCACHE)
 		dontcache_flags = IOCB_DONTCACHE;
-	buffered_flags = nfsd_direct_misaligned_dontcache ? dontcache_flags : 0;
+	/* NFSD marks their shared pages itself, see nfsd_write_dio_seg_hold() */
+	buffered_flags = nfsd_direct_misaligned_dontcache && dontcache_flags ?
+			 dontcache_flags | IOCB_DONTCACHE_DEFER : 0;
 
 	/*
 	 * Check if direct I/O is feasible for this write request.
@@ -1523,7 +1598,8 @@ nfsd_write_dio_iters_init(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (prefix) {
 		nfsd_write_dio_seg_init(&segments[nsegs], bvec,
 					nvecs, total, 0, prefix, iocb);
-		segments[nsegs++].flags |= buffered_flags;
+		segments[nsegs].flags |= buffered_flags;
+		segments[nsegs++].claim = !!buffered_flags;
 	}
 
 	nfsd_write_dio_seg_init(&segments[nsegs], bvec, nvecs,
@@ -1556,7 +1632,8 @@ nfsd_write_dio_iters_init(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (suffix) {
 		nfsd_write_dio_seg_init(&segments[nsegs], bvec, nvecs, total,
 					prefix + middle, suffix, iocb);
-		segments[nsegs++].flags |= buffered_flags;
+		segments[nsegs].flags |= buffered_flags;
+		segments[nsegs++].claim = !!buffered_flags;
 	}
 	return nsegs;
 
@@ -1565,6 +1642,7 @@ nfsd_write_dio_iters_init(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	nfsd_write_dio_seg_init(&segments[0], bvec, nvecs, total, 0,
 				total, iocb);
 	segments[0].flags |= buffered_flags;
+	segments[0].claim = !!buffered_flags;
 	return 1;
 }
 
@@ -1573,12 +1651,13 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		  struct nfsd_file *nf, unsigned int nvecs,
 		  unsigned long *cnt, struct kiocb *kiocb)
 {
+	struct nfsd_write_dio_hold holds[3];
 	struct nfsd_write_dio_seg segments[3];
 	struct file *file = nf->nf_file;
 	loff_t start = kiocb->ki_pos;
-	unsigned int nsegs, i;
+	unsigned int nsegs, nheld = 0, i;
+	ssize_t host_err = 0;
 	int sync_flags;
-	ssize_t host_err;
 	size_t expected;
 
 	nsegs = nfsd_write_dio_iters_init(rqstp, fhp, nf, rqstp->rq_bvec,
@@ -1608,23 +1687,26 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 					kiocb->ki_flags);
 
 		expected = iov_iter_count(&segments[i].iter);
-
+		nfsd_write_dio_seg_hold(file, &segments[i], kiocb->ki_pos,
+					expected, &holds[nheld]);
 		host_err = vfs_iocb_iter_write(file, kiocb, &segments[i].iter);
 		if (host_err < 0)
-			return host_err;
+			break;
+		holds[nheld++].written = host_err;
 		*cnt += host_err;
 		if (host_err < (ssize_t)expected)
 			break;	/* partial write */
 	}
 
-	if (sync_flags && *cnt) {
+	if (host_err >= 0 && sync_flags && *cnt)
 		host_err = vfs_fsync_range(file, start, start + *cnt - 1,
 					   !(sync_flags & IOCB_SYNC));
-		if (host_err < 0)
-			return host_err;
-	}
 
-	return 0;
+	/* Complete the shared units once the WRITE and its fsync are done. */
+	for (i = 0; i < nheld; i++)
+		nfsd_write_dio_seg_release(file, &holds[i]);
+
+	return host_err < 0 ? host_err : 0;
 }
 
 /**
-- 
2.52.0

