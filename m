Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792422454;
	b=BVQ3e4Jv9+k97JoIMB/3PE2gqcPE2mxe/nNpS/G1lRnle6IqWRbdOosPnzoicgDoQSX0
	 AmzSe5zYdiOZYMGriLKZlkihlRTsxy06Ns481+mT58kSocxs6YeWS0omjGdIacDmmoaS8
	 fdE1AUf5PWKmtNeWoa4rfVJoAM+D6Z0ZFdupqR40MV+0k6Bq9sgScynBV7mxrbFZNh3Ho
	 6HmpAji2ugmpS7G85baTwOilrtiWGOLmesSIGAaZocT77Rmb+8KGtbvvC5KB+u0c8wwhC
	 ItjY9Yk5uYIHmDcfMU81772NzOhE5Ktubg2sCHyteJVSrHoldgXNHNBzlEt8DCwyBrQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792422454;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=kiNv3Fs6tQZWG0Ny9bcwpluAerNqnXAGy94LD61Np3o=;
	b=QLveZuyCrOv+28HMRYzsbhDVwL8DuAdH6J16M7QlPftRR8/3RX0CyjCi2N/R21nTG0Ze
	 4vVMQWwnarQUF9iF89Hvoy61TR0AcJlHa26rYZYr5cEOdv8OOSADuPgYlAxbjnp/PD3hT
	 SZf0E9KLLQDXwf76O+PnclUqbMAQMM3+yyhV6RfRDkZPS6Lx9AI5FFm+awBlVr+AhvZ83
	 CiVnVgeLWkFNVpuDv5v+Lmvs2ogrhBylZtHClym3T+rSRNG4vHJJ83B4+3KnI40V69fzu
	 960Bz2QV3qjILgyanRbp1fMH5zCG37a0MY/V2aOy3kwGaSPo24F9zbEOoI20ijB9bzQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=F8UQdjiS;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 853986084844;
	Mon, 19 Oct 2026 15:07:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=F8UQdjiS
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 13DC71F000C4;
	Mon, 19 Oct 2026 15:07:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792422454;
	bh=kiNv3Fs6tQZWG0Ny9bcwpluAerNqnXAGy94LD61Np3o=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=F8UQdjiSvX6CaazMSWZAExePS6fT6542S7uCVXGjNt+Qp7GGFASpc/JaOcsGP4fzj
	 ex09fN2jq+onXDfDAMtq9WCUpCTRgEQVRzb+ikTGNBKb1Vzv+a9utR5vWqQfpP8mux
	 5Ch0MU+rSqZ+yeo941OCu4VeE9Uulga0amYvKmEeGR16f2Ec8uqpbZNm70IGj5zPvT
	 kCoEUSRzaFgjc18HUhodlKnp/wOGQCwAJJ5JLgA5dmPOjkxBi0qIDWKoF5TylgphmW
	 zP89mPNsCEDtlwEfpKbnskyNGBtJ5FhmOK+Tb/6qrqaimnX88M1C0bLYJE3Dv1/SwP
	 /T+U3YIQ/4wKQ==
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
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: [PATCH v5 6/6] NFSD: drop a shared boundary page only once both WRITEs have written it
Date: Mon, 19 Oct 2026 11:07:25 -0400
Message-ID: <20261019150725.1507-7-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261019150725.1507-1-snitzer@kernel.org>
References: <20261019150725.1507-1-snitzer@kernel.org>
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
covers its first and last page only partly when it does not start or end
on a page boundary.  Such a page is shared with the neighbouring WRITE,
which may arrive before, after or at the same time, from any client.

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
filemap_dontcache_edge_completes() whether each page it covers only
partly has already been written by the neighbouring WRITE; once the
whole WRITE, its fsync included, is complete, it calls
filemap_dontcache_edge_complete() for those pages, which drops a clean
page at once.  An UNSTABLE WRITE marks them dirty, and the writeback
that cleans them, by the flusher or for the client's COMMIT, drops them.

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
Assisted-by: LLM
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 .../filesystems/nfs/nfsd-io-modes.rst         | 17 ++++
 fs/nfsd/vfs.c                                 | 99 ++++++++++++++++---
 2 files changed, 104 insertions(+), 12 deletions(-)

diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentation/filesystems/nfs/nfsd-io-modes.rst
index 11da2cee76fc..26e6dc18a151 100644
--- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
+++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
@@ -168,6 +168,23 @@ Misaligned WRITE:
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
     The nfsd_read_direct trace event shows how NFSD expands any
     misaligned READ to the next DIO-aligned block (on either end of the
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 0e937d116f39..9b5e158dc7a8 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1372,6 +1372,7 @@ static int wait_for_concurrent_writes(struct file *file)
 struct nfsd_write_dio_seg {
 	struct iov_iter			iter;
 	int				flags;
+	bool				claim;		/* completes shared pages */
 };
 
 static unsigned long
@@ -1391,6 +1392,65 @@ nfsd_write_dio_seg_init(struct nfsd_write_dio_seg *segment,
 		iov_iter_advance(&segment->iter, start);
 	iov_iter_truncate(&segment->iter, len);
 	segment->flags = iocb->ki_flags;
+	segment->claim = false;
+}
+
+/* The shared pages a segment completes, and how much of it was written. */
+struct nfsd_write_dio_hold {
+	loff_t	first, last;
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
+
+	hold->first = pos;
+	hold->last = pos + len - 1;
+	hold->complete_first = false;
+	hold->complete_last = false;
+	hold->written = 0;
+	if (seg->claim && len) {
+		bool one_page = (hold->first >> PAGE_SHIFT) ==
+				(hold->last >> PAGE_SHIFT);
+		bool head = hold->first & ~PAGE_MASK;
+		bool tail = (hold->last + 1) & ~PAGE_MASK;
+
+		/* Only a page the segment covers partly is shared. */
+		if (head || (one_page && tail))
+			hold->complete_first =
+				filemap_dontcache_edge_completes(mapping, hold->first);
+		if (!one_page && tail)
+			hold->complete_last =
+				filemap_dontcache_edge_completes(mapping, hold->last);
+	}
+}
+
+/* Drop the shared pages this WRITE was the second of two to write. */
+static void
+nfsd_write_dio_seg_release(struct file *file,
+			   const struct nfsd_write_dio_hold *hold)
+{
+	struct address_space *mapping = file->f_mapping;
+
+	if (hold->complete_first && hold->written)
+		filemap_dontcache_edge_complete(mapping, hold->first);
+	/* A short write did not reach the last page. */
+	if (hold->complete_last &&
+	    hold->written == hold->last - hold->first + 1)
+		filemap_dontcache_edge_complete(mapping, hold->last);
 }
 
 static unsigned int
@@ -1414,7 +1474,9 @@ nfsd_write_dio_iters_init(struct svc_rqst *rqstp, struct svc_fh *fhp,
 
 	if (nf->nf_file->f_op->fop_flags & FOP_DONTCACHE)
 		dontcache_flags = IOCB_DONTCACHE;
-	buffered_flags = nfsd_direct_misaligned_dontcache ? dontcache_flags : 0;
+	/* NFSD marks their shared pages itself, see nfsd_write_dio_seg_hold() */
+	buffered_flags = nfsd_direct_misaligned_dontcache && dontcache_flags ?
+			 dontcache_flags | IOCB_DONTCACHE_DEFER : 0;
 
 	/*
 	 * Check if direct I/O is feasible for this write request.
@@ -1462,7 +1524,8 @@ nfsd_write_dio_iters_init(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (prefix) {
 		nfsd_write_dio_seg_init(&segments[nsegs], bvec,
 					nvecs, total, 0, prefix, iocb);
-		segments[nsegs++].flags |= buffered_flags;
+		segments[nsegs].flags |= buffered_flags;
+		segments[nsegs++].claim = !!buffered_flags;
 	}
 
 	nfsd_write_dio_seg_init(&segments[nsegs], bvec, nvecs,
@@ -1489,7 +1552,8 @@ nfsd_write_dio_iters_init(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (suffix) {
 		nfsd_write_dio_seg_init(&segments[nsegs], bvec, nvecs, total,
 					prefix + middle, suffix, iocb);
-		segments[nsegs++].flags |= buffered_flags;
+		segments[nsegs].flags |= buffered_flags;
+		segments[nsegs++].claim = !!buffered_flags;
 	}
 	goto out;
 
@@ -1498,6 +1562,7 @@ nfsd_write_dio_iters_init(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	nfsd_write_dio_seg_init(&segments[0], bvec, nvecs, total, 0,
 				total, iocb);
 	segments[0].flags |= buffered_flags;
+	segments[0].claim = !!buffered_flags;
 	nsegs = 1;
 out:
 	trace_nfsd_write_dio_split(rqstp, fhp, offset, total, offset_align,
@@ -1511,12 +1576,13 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
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
@@ -1545,23 +1611,32 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 						segments[i].iter.count);
 
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

