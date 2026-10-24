Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792879921;
	b=PzFY8deP0kNyJ4IxBET2zHgWjZ1p+wp5y7LdFGCWxbO8SG1IKLg1g20ljyV5GzxrhrsT
	 SuW33CPEXJECtLrxNMml3ttPJ05g5RqeiWvY8HrHlX15vlUXWj2Jwk964vQkThaPOQUTb
	 oypSvlo8Q6UCVUpbycAn/eNCGVn2wXa1IQaIeVBVUkzWLuwYrgp+M6zg8Hivmt/YOsOHV
	 Cs+MbNGLWZxEiBm6f3qcVg2yP9jg4vZuYfUL186Jo3Y2Da6mFVMDP2Y2Q97GKG5fEvk5E
	 BiPeFsb/Kczjrk1o3xmHfyl49NaIbKvhnD8j09PaSE9pXheBN1hmae16/8tLXtIOq5w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792879921;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=+uHt5ugACxF92GmAXG21dbtKzmG3MWXoLirSoj5NyQs=;
	b=mm6RlD85r3rKVUmD3GVk5fE7zLPrg3fbEjFWk/B6VAyikk4+Y8cyMjcZ1GAc+sQjlbwW
	 ClU9UTG5My44905eZIBuE03w2PY4Cvomo0G9GWu7DudXNgSvDWQQGof6yk4NT/6DUCL1X
	 WMrIafknA2ivZQp6FmblfvHRimiFLKZBY3NA2/P9cl5W+fZQnJGHFxkNx3Y5Wt3m7Qkd+
	 wGAoHz+JhvZ+g66/NF0AW5CR7a3LGgRvYITziXxRWuhkkZ7c4XyouI/l4sJpURobqJiVQ
	 ZoR7yrD1Cq3Acd/hJgFdX20jj3WCOhRyP22mbHvMVli9bsDasXqeslkWurep/qXVdJA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=WX9VXTnC;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 022B2606A33A;
	Sat, 24 Oct 2026 22:12:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=WX9VXTnC
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 719491F031E6;
	Sat, 24 Oct 2026 22:12:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792879920;
	bh=+uHt5ugACxF92GmAXG21dbtKzmG3MWXoLirSoj5NyQs=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=WX9VXTnCxua7vslZA+8lU7rQ0XUIpOvTThiZ/q65RXWa7tfplGStvdZnyGWRuvTFk
	 xaLNEckzMMDI9drFF3vG1Id3n8z8Mgi2jRHaUbGcEhiBaPs+55OrF3+guqxOqpCuBx
	 SXptlYVzHShCXjC20M8jlkPA4vdunJln+piRZ603RaRSOwkR5RWT3Dj0d0ATYO3fvu
	 CwRPN4xDOga0t9ku6TE4aXtxxVJREhLav6iI2e/yjopBskaR2bwEeqJY+ksgp+k5hi
	 M5uLNoSrROzqI+bIZ+QtEoNyqRmQ7NJfXkWilpT6BwOiNq7BMfI5bVpEnKwjlXwPMo
	 XyW0ZfNCCM7yQ==
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
Subject: [PATCH v9 6/6] NFSD: drop a shared boundary page only once both WRITEs have written it
Date: Sat, 24 Oct 2026 18:11:52 -0400
Message-ID: <20261024221152.6965-7-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261024221152.6965-1-snitzer@kernel.org>
References: <20261024221152.6965-1-snitzer@kernel.org>
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

A buffered DONTCACHE segment of a direct-mode WRITE -- the misaligned
start or end of a split WRITE, or the whole of one too small to split --
covers its first and last unit only partly when it does not start or end
on a unit boundary.  The unit is the smallest folio the mapping allows: a
page, or a block where the block is larger than a page.  Such a unit is
shared with the neighbouring WRITE, which may arrive before, after or at
the same time, from any client.

The page cache keeps a page an uncached write covers only partly for the
write that completes it ("mm, iomap: keep a partly covered page until an
uncached write completes it"), so the second WRITE does not have to read
it back from disk.  Left at that, the page cache marks the page drop-
behind while it is still dirty, which counts it as DONTCACHE dirty and
wakes the DONTCACHE writeback kick for every segment of a stable WRITE,
only to write back what NFSD's single fsync is about to write.

Issue the buffered segments IOCB_DONTCACHE_DEFER and mark the pages here
instead ("mm, iomap: let an uncached writer complete its shared pages
itself").  Immediately before writing a segment, NFSD asks
filemap_dontcache_edge_completes() whether the neighbouring WRITE wrote
its part of each unit that the segment covers only partly.  It passes the
range that the segment covers in that unit.  Once the whole WRITE, its
fsync included, is complete, it calls filemap_dontcache_edge_complete()
for those units, which drops a clean one at once.  A short write that
stopped inside the segment's first unit has not written its part of that
edge, so NFSD completes the first edge only when the write reached the
end of the segment's bytes in that unit.  An UNSTABLE WRITE marks the
units dirty, and the writeback that cleans them, by the flusher or for
the client's COMMIT, drops them.

A page whose neighbouring WRITE never arrives, such as the last page of
the file, or arrives at the same time, so that neither finds the other's
part, stays cached until it is reclaimed.  Nothing changes when the
buffered segments are normal buffered I/O (direct_misaligned_dontcache
is N, or the file system lacks FOP_DONTCACHE); the page cache keeps
partly covered pages only for file systems that use iomap for buffered
writes.

Measured with 32 interleaved writers of 47008-byte records over an
emulated 4Kn NVMe with 4 KiB pages, NFSD DIRECT with
direct_misaligned_dontcache=Y, each run from a freshly made file system:
device reads per WRITE are 0.0001-0.0002 whether each record is one
FILE_SYNC WRITE, two sent one after the other, two sent together, or two
sent UNSTABLE, against 45144 reads for 45664 WRITEs with no shared-page
handling, and the DONTCACHE writeback kick does not run at all for the
FILE_SYNC WRITEs.

On a four-server pNFS flexfiles rig (x86_64, 4 KiB logical blocks), three
clients writing 47008-byte records for 240 s against 640 nfsd threads per
server, keeping the shared page took device reads from 0.014-0.015 per
record to 0.003, page-cache growth over the write phase from about
11 GiB to 2.9 GiB, and write throughput up by 2.4% to 4.9%, with read
throughput unchanged.  Keeping every boundary page cached instead, with
direct_misaligned_dontcache=N, grows the page cache by about 630 GiB over
the same runs.

Reported-by: Jonathan Flynn <jonathan.flynn@hammerspace.com>
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---

Notes:
    Notes on the v8 review questions, with the code that answers each:
    
    - Unit size.  nfsd_write_dio_seg_hold() uses
      mapping_min_folio_nrbytes(), as iomap_get_folio() does (4/6).  A
      block larger than the page is one unit in both places.
    - Short write.  NFSD completes the first edge only if written is at
      least first_len.  It completes the last edge only if the write
      covered the whole segment.
    - Release after an error.  NFSD does this on purpose.  A segment
      whose write failed is not held: nheld increases only after a write
      that returns >= 0.  A held segment wrote its bytes, so its edges
      contain the data of both WRITEs.  After an fsync error, the
      release still runs: the folio is clean when its writeback ends,
      and the helper drops it as DONTCACHE writeback would.  The error
      stays in the mapping and NFSD returns it.  The release changes
      only what stays cached, never data.
    - Unset fields.  For a segment that holds nothing,
      nfsd_write_dio_seg_hold() returns early, and first_len is not set.
      complete_first and complete_last are then false, so
      nfsd_write_dio_seg_release() does not read first_len.
    - Array size.  nsegs is at most 3, so nheld is at most 3 (holds[3]).
    - Two WRITEs that arrive together.  The commit message states this
      limit: the page stays cached until reclaim.

 .../filesystems/nfs/nfsd-io-modes.rst         |  17 +++
 fs/nfsd/vfs.c                                 | 116 ++++++++++++++++--
 2 files changed, 121 insertions(+), 12 deletions(-)

diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentation/filesystems/nfs/nfsd-io-modes.rst
index 0e69b5fdd6756..9c663ce97c48f 100644
--- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
+++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
@@ -167,6 +167,23 @@ Misaligned WRITE:
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
index 9219f8eb386d0..0b62c4659e547 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1387,6 +1387,7 @@ static int wait_for_concurrent_writes(struct file *file)
 struct nfsd_write_dio_seg {
 	struct iov_iter			iter;
 	int				flags;
+	bool				claim;		/* completes shared pages */
 };
 
 static unsigned long
@@ -1406,6 +1407,82 @@ nfsd_write_dio_seg_init(struct nfsd_write_dio_seg *segment,
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
+	/*
+	 * The unit two writes share is the smallest folio the mapping allows:
+	 * a page, or a block where the block is larger.  Only a unit the
+	 * segment covers partly is shared.
+	 */
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
@@ -1428,7 +1505,9 @@ nfsd_write_dio_iters_init(struct svc_rqst *rqstp, struct svc_fh *fhp,
 
 	if (nf->nf_file->f_op->fop_flags & FOP_DONTCACHE)
 		dontcache_flags = IOCB_DONTCACHE;
-	buffered_flags = nfsd_direct_misaligned_dontcache ? dontcache_flags : 0;
+	/* NFSD marks their shared pages itself, see nfsd_write_dio_seg_hold() */
+	buffered_flags = nfsd_direct_misaligned_dontcache && dontcache_flags ?
+			 dontcache_flags | IOCB_DONTCACHE_DEFER : 0;
 
 	/*
 	 * Check if direct I/O is feasible for this write request.
@@ -1483,7 +1562,8 @@ nfsd_write_dio_iters_init(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (prefix) {
 		nfsd_write_dio_seg_init(&segments[nsegs], bvec,
 					nvecs, total, 0, prefix, iocb);
-		segments[nsegs++].flags |= buffered_flags;
+		segments[nsegs].flags |= buffered_flags;
+		segments[nsegs++].claim = !!buffered_flags;
 	}
 
 	nfsd_write_dio_seg_init(&segments[nsegs], bvec, nvecs,
@@ -1516,7 +1596,8 @@ nfsd_write_dio_iters_init(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (suffix) {
 		nfsd_write_dio_seg_init(&segments[nsegs], bvec, nvecs, total,
 					prefix + middle, suffix, iocb);
-		segments[nsegs++].flags |= buffered_flags;
+		segments[nsegs].flags |= buffered_flags;
+		segments[nsegs++].claim = !!buffered_flags;
 	}
 	return nsegs;
 
@@ -1525,6 +1606,7 @@ nfsd_write_dio_iters_init(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	nfsd_write_dio_seg_init(&segments[0], bvec, nvecs, total, 0,
 				total, iocb);
 	segments[0].flags |= buffered_flags;
+	segments[0].claim = !!buffered_flags;
 	return 1;
 }
 
@@ -1533,12 +1615,13 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
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
@@ -1567,23 +1650,32 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
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
+	/*
+	 * Mark the pages this WRITE shares with its neighbours for dropping
+	 * only once the WRITE is complete, including its fsync if it has one.
+	 * A page marked while still dirty is counted as DONTCACHE dirty and
+	 * wakes the DONTCACHE writeback kick; a page marked once clean is
+	 * simply dropped.
+	 */
+	for (i = 0; i < nheld; i++)
+		nfsd_write_dio_seg_release(file, &holds[i]);
+
+	return host_err < 0 ? host_err : 0;
 }
 
 /**
-- 
2.52.0

