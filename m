Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A72203B774F
	for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 23:13:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790723615; cv=none; b=mAmKDBr4T4+AyGq0S7YBWbrLCsaugrB50IE9Ar4Ui3RLxGtozofQz/Hc3n7OOquTFGq1OWtJEcHJ0tz4Dc+o0aEP/cV0EUnQkQ6SgsykmXqXBLrp/bQmFAsdU4eigIvOX2s4/9x0FJoqquFYVM50R6vsG3PbQSW8W1YmFweqIEY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790723615; c=relaxed/simple;
	bh=CIBs6H6Q68MMIiSAlwQSzDGCOYdR7HIoInvR4qbR3jw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=RcXpavxzVneTOJpDpCjHWI/k0Ji2c0Ivi1ut8VRvePfAAR+XqedQbrRGvrLEojRev3ppUJCYnwvWYgIiHybP7YdG0g6Ay0pGK9Ei0xph399sIuGhiovABQEYrwRnBV7LafIunQiAK5I2VXzn7Xe+j6fpREYpv71mpSVfR6RmGt4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=VLQv6L0a; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="VLQv6L0a"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2BFCC1F00898;
	Tue, 29 Sep 2026 23:13:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790723613;
	bh=E37QYiXzEyMMTucrz9eXaS2tEgPHGW/PlGLxiMyrd3s=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=VLQv6L0aQh+vSl25AwjhTghVw1WNUHK+TLAqaeZ6Wr0GsM3eYFaqekZ+ojw1QZ7/H
	 p2jETu58aMlGla1M81jr23FdvHW6D6tTnDULdURMTZpPpbN/WlcKWzvvvxneJssYPx
	 niRz6G7jQhvvDFQ6CgIDeqZQ1mNg1SB3paLW+G2wVzCkCeCxKAcpt5xKyoDPYMoMoe
	 x+g+LQVtBKu3Hr1UanaaTJNlgtdqowhafnW9Xia7alaq/wWV5N7SItGl5xgcRlDaZl
	 vPXgCqbG+6frsKnC3Xc19lkcwNbKqrpbNaaMV/jYLPoP3KIhHBU/6KGHDSg25kyU+s
	 s6A6LEq0hCDLg==
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/9] NFSD: only split a direct-mode WRITE for a worthwhile direct middle
Date: Tue, 29 Sep 2026 19:13:22 -0400
Message-ID: <20260929231329.22018-3-snitzer@kernel.org>
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

nfsd_write_dio_iters_init() decides how a WRITE issued in a direct mode
is carried out: split into a buffered prefix, a direct middle and a
buffered suffix, or issued whole as a single buffered segment.

Only split when the split buys direct I/O for a worthwhile middle.  Add
direct_misaligned_num_pages (debugfs knob, default 2) and decline to
split when the aligned middle is smaller than that many pages and the
WRITE has a prefix or a suffix.  A WRITE whose payload memory is
misaligned for the block device already declines: no segment of it can
be direct I/O, so a split would only turn one buffered write into
three.

Decide every segment's flags in nfsd_write_dio_iters_init() rather than
in the write loop.  The buffered prefix and suffix of a split WRITE,
and the whole WRITE when it is not split, are issued IOCB_DONTCACHE
when the file system supports FOP_DONTCACHE and as plain buffered I/O
otherwise: the operator chose a direct mode to keep NFSD out of the
page cache, so a WRITE that cannot be direct gets the next best thing.

Document it in the "Misaligned WRITE" section of nfsd-io-modes.rst.

Suggested-by: Christoph Hellwig <hch@infradead.org>
Assisted-by: Claude:claude-opus-5[1m]
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 .../filesystems/nfs/nfsd-io-modes.rst         | 17 ++++-
 fs/nfsd/debugfs.c                             | 14 ++++
 fs/nfsd/nfsd.h                                |  1 +
 fs/nfsd/vfs.c                                 | 73 +++++++++++++------
 4 files changed, 79 insertions(+), 26 deletions(-)

diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentation/filesystems/nfs/nfsd-io-modes.rst
index dc50c930f9762..fef062f24c525 100644
--- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
+++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
@@ -126,9 +126,9 @@ Misaligned WRITE:
     middle and end as needed. The large middle segment is DIO-aligned
     and the start and/or end are misaligned. Buffered IO is used for the
     misaligned segments and O_DIRECT is used for the middle DIO-aligned
-    segment. DONTCACHE buffered IO is _not_ used for the misaligned
-    segments because using normal buffered IO offers significant RMW
-    performance benefit when handling streaming misaligned WRITEs.
+    segment. If the underlying filesystem supports FOP_DONTCACHE, the
+    misaligned segments use DONTCACHE buffered IO so that their pages
+    are dropped from the page cache once written back.
 
     The O_DIRECT middle segment also carries the DONTCACHE flag. It has
     no effect while the IO really is O_DIRECT, but a filesystem may
@@ -140,6 +140,17 @@ Misaligned WRITE:
     normal buffered IO. Such fallbacks are visible through the
     iomap_dio_invalidate_fail trace event; see Tracing below.
 
+    Whenever no part of a WRITE can use O_DIRECT, the whole WRITE is
+    issued as a single DONTCACHE buffered IO (normal buffered IO if the
+    filesystem lacks FOP_DONTCACHE). This covers: a filesystem that
+    advertises no DIO alignment requirements at all; a WRITE smaller
+    than the larger of the offset and memory alignments; a WRITE whose
+    DIO-aligned middle segment is smaller than
+    /sys/kernel/debug/nfsd/direct_misaligned_num_pages pages (default 2)
+    while also having a misaligned start or end; and a WRITE whose
+    payload memory is not aligned to the block device's dma_alignment,
+    which rules out O_DIRECT for the middle segment as well.
+
 Tracing:
     The nfsd_read_direct trace event shows how NFSD expands any
     misaligned READ to the next DIO-aligned block (on either end of the
diff --git a/fs/nfsd/debugfs.c b/fs/nfsd/debugfs.c
index 386fd1c54f527..398e400d64038 100644
--- a/fs/nfsd/debugfs.c
+++ b/fs/nfsd/debugfs.c
@@ -128,6 +128,17 @@ void nfsd_debugfs_exit(void)
 	nfsd_top_dir = NULL;
 }
 
+/*
+ * /sys/kernel/debug/nfsd/direct_misaligned_num_pages
+ *
+ * The smallest DIO-aligned middle segment, in pages, that is worth
+ * splitting a misaligned direct-mode WRITE into three segments for.  A
+ * WRITE whose middle is smaller than this, and which has a misaligned
+ * start or end, is issued as a single buffered segment instead.
+ *
+ * Default 2.  Not yet tuned by benchmarking.
+ */
+
 void nfsd_debugfs_init(void)
 {
 	nfsd_top_dir = debugfs_create_dir("nfsd", NULL);
@@ -140,6 +151,9 @@ void nfsd_debugfs_init(void)
 
 	debugfs_create_file("io_cache_write", 0644, nfsd_top_dir, NULL,
 			    &nfsd_io_cache_write_fops);
+
+	debugfs_create_u32("direct_misaligned_num_pages", 0644, nfsd_top_dir,
+			   &nfsd_direct_misaligned_num_pages);
 #ifdef CONFIG_NFSD_V4
 	debugfs_create_bool("delegated_timestamps", 0644, nfsd_top_dir,
 			    &nfsd_delegts_enabled);
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index a145294c59c87..a2d72434160af 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -142,6 +142,7 @@ enum {
 
 extern u64 nfsd_io_cache_read __read_mostly;
 extern u64 nfsd_io_cache_write __read_mostly;
+extern u32 nfsd_direct_misaligned_num_pages __read_mostly;
 
 extern int nfsd_max_blksize;
 
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 5b963f0e3b3f2..e3ce66bce00d4 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -53,6 +53,7 @@
 bool nfsd_disable_splice_read __read_mostly;
 u64 nfsd_io_cache_read __read_mostly = NFSD_IO_BUFFERED;
 u64 nfsd_io_cache_write __read_mostly = NFSD_IO_BUFFERED;
+u32 nfsd_direct_misaligned_num_pages __read_mostly = 2;
 
 /**
  * nfserrno - Map Linux errnos to NFS errnos
@@ -1302,15 +1303,29 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	u32 mem_align = nf->nf_dio_mem_align;
 	size_t prefix, middle, suffix;
 	loff_t offset = iocb->ki_pos;
+	unsigned int dontcache_flags = 0;
 	unsigned int nsegs = 0;
 
+	if (nf->nf_file->f_op->fop_flags & FOP_DONTCACHE)
+		dontcache_flags = IOCB_DONTCACHE;
+
 	/*
-	 * Check if direct I/O is feasible for this write request.
-	 * If alignments are not available, the write is too small,
-	 * or no alignment can be found, fall back to buffered I/O.
+	 * Whenever direct I/O cannot be used for the WRITE, fall back to a
+	 * single DONTCACHE buffered I/O when the file system supports it, so
+	 * the WRITE's pages are dropped from the page cache once written
+	 * back, and to a single cached buffered I/O otherwise.
+	 *
+	 * If the file system doesn't advertise any alignment requirements,
+	 * don't try to issue direct I/O at all.
 	 */
-	if (unlikely(!mem_align || !offset_align) ||
-	    unlikely(total < max(offset_align, mem_align)))
+	if (unlikely(!mem_align || !offset_align))
+		goto no_dio;
+
+	/*
+	 * If the I/O is smaller than the larger of the memory and logical
+	 * offset alignment, no part of it can be direct I/O.
+	 */
+	if (unlikely(total < max(offset_align, mem_align)))
 		goto no_dio;
 
 	prefix_end = round_up(offset, offset_align);
@@ -1321,12 +1336,27 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	middle = middle_end - prefix_end;
 	suffix = orig_end - middle_end;
 
-	if (!middle)
+	/*
+	 * If there is no aligned middle section, or the aligned part is too
+	 * small to be worth the split (direct_misaligned_num_pages), issue a
+	 * single buffered I/O write instead of splitting up the write.
+	 */
+	if (!middle ||
+	    ((prefix || suffix) &&
+	     middle < PAGE_SIZE * nfsd_direct_misaligned_num_pages)) {
 		goto no_dio;
+	}
 
-	if (prefix)
-		nfsd_write_dio_seg_init(&segments[nsegs++], bvec,
+	/*
+	 * The prefix and suffix are buffered I/O by definition.  Mark them
+	 * uncached when possible so their folios are dropped once written
+	 * back rather than lingering in the page cache.
+	 */
+	if (prefix) {
+		nfsd_write_dio_seg_init(&segments[nsegs], bvec,
 					nvecs, total, 0, prefix, iocb);
+		segments[nsegs++].flags |= dontcache_flags;
+	}
 
 	nfsd_write_dio_seg_init(&segments[nsegs], bvec, nvecs,
 				total, prefix, middle, iocb);
@@ -1337,10 +1367,13 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	 * bvecs generated from RPC receive buffers are contiguous: After
 	 * the first bvec, all subsequent bvecs start at bv_offset zero
 	 * (page-aligned). Therefore, only the first bvec is checked.
+	 *
+	 * If the memory is not aligned, direct I/O is impossible for the
+	 * middle, so issue the entire write as a single buffered segment:
+	 * splitting would only turn one buffered write into three.
 	 */
 	if (iov_iter_bvec_offset(&segments[nsegs].iter) & (mem_align - 1))
 		goto no_dio;
-	segments[nsegs].flags |= IOCB_DIRECT;
 	/*
 	 * Also mark the direct middle DONTCACHE: the file system may fall
 	 * back to buffered I/O on its own (e.g. XFS on -ENOTBLK when it
@@ -1348,20 +1381,21 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	 * suffix of an adjacent WRITE just dirtied), and it reuses this kiocb
 	 * to do so.  On the direct path itself the flag is inert.
 	 */
-	if (nf->nf_file->f_op->fop_flags & FOP_DONTCACHE)
-		segments[nsegs].flags |= IOCB_DONTCACHE;
-	nsegs++;
+	segments[nsegs++].flags |= IOCB_DIRECT | dontcache_flags;
 
-	if (suffix)
-		nfsd_write_dio_seg_init(&segments[nsegs++], bvec, nvecs, total,
+	if (suffix) {
+		nfsd_write_dio_seg_init(&segments[nsegs], bvec, nvecs, total,
 					prefix + middle, suffix, iocb);
+		segments[nsegs++].flags |= dontcache_flags;
+	}
 
 	return nsegs;
 
 no_dio:
-	/* No DIO alignment possible - pack into single non-DIO segment. */
+	/* No DIO possible - pack into a single uncached (if possible) segment. */
 	nfsd_write_dio_seg_init(&segments[0], bvec, nvecs, total, 0,
 				total, iocb);
+	segments[0].flags |= dontcache_flags;
 	return 1;
 }
 
@@ -1385,16 +1419,9 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		if (kiocb->ki_flags & IOCB_DIRECT)
 			trace_nfsd_write_direct(rqstp, fhp, kiocb->ki_pos,
 						segments[i].iter.count);
-		else {
+		else
 			trace_nfsd_write_vector(rqstp, fhp, kiocb->ki_pos,
 						segments[i].iter.count);
-			/*
-			 * Mark the I/O buffer as evict-able to reduce
-			 * memory contention.
-			 */
-			if (nf->nf_file->f_op->fop_flags & FOP_DONTCACHE)
-				kiocb->ki_flags |= IOCB_DONTCACHE;
-		}
 
 		expected = iov_iter_count(&segments[i].iter);
 
-- 
2.52.0

