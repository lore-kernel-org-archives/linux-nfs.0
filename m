Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 032164AA402
	for <linux-nfs@vger.kernel.org>; Thu, 15 Oct 2026 23:33:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792107196; cv=none; b=r7Uj6aI07nxQbRlIn8CWAm7FNAUheawoqIzC45i2gmZyeP2XUwezU7ZGaumWrqXyghWTUkgfT/s+jSqnAT4zUtOTObKjZ32vzeG0McWnNvKREyaW1w20jKXo0AHDe7Nv+8vNldoBkXRuf4YE+kEhVGkeeLirNiEIg2dISqqRmS4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792107196; c=relaxed/simple;
	bh=pH1aavDN7blRZuRug2EgeNFmG1NB3eqnqJZfEs0imGQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=E99tbbHxjV6oNQsqXA69iUfcMSBaYqOc+keW34ZRwV34XdFta0MZpG12ZunlixC4Sdf1P2wVvAGvF0ZtbHN1byLqWPnW43JiPnfuh1fAebNB8KlAoJXRH564TxqhEvzrWVleFRvWg6sisqe5hXlDEejXLvPJZr8PSFLg8kpZ2RM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=B//psEQW; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="B//psEQW"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6D47A1F000C5;
	Thu, 15 Oct 2026 23:33:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792107194;
	bh=XFOCc0VSdNc0cHBxC5EnZMiNIFzOFbGe0LmlYJb7AAE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=B//psEQWAtsi4Sd9kWhFsqexJxobRTD4hC1mcMpLs2UEKlb2QdFEkTuyw6OXeWfLh
	 oo6Y14CL0QEL/90mWt+EakF+geRpj3Bo/9nJVU/Okuh2hq9PKyGnh7lfldYL1YeW1l
	 cUfW07cPrJ4S+eeLC81tkienpPVUY/4QRWE2levRtNOnYZCxSAtXDykvankGou4bqA
	 KUUCv5ZXgR9dVbTS+MTzjgd2QmmoRIqY9R2QnE+xm7Ej2EE51v1iuNlm6W40UHB7b4
	 OjLIS1L0vXBXC9aRx7UOO/xhcBQR7NedS2Rbmu/hIbQpRCpB4twmDx5tXmH1jAs+Rk
	 M2mT3BLKLP8Ew==
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
	Christoph Hellwig <hch@infradead.org>
Subject: [PATCH v4 03/10] NFSD: only split a direct-mode WRITE for a worthwhile direct middle
Date: Thu, 15 Oct 2026 19:33:02 -0400
Message-ID: <20261015233309.42999-4-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261015233309.42999-1-snitzer@kernel.org>
References: <20261015233309.42999-1-snitzer@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Splitting a misaligned direct-mode WRITE issues it as two or three
writes instead of one, and the direct write first writes back and
invalidates the page cache over its range.  When the DIO-aligned middle
is small, the WRITE is mostly its buffered prefix and suffix anyway, and
the direct middle only adds that overhead.

Add direct_misaligned_min_bytes (debugfs, default 8192) and do not split
a WRITE that has a misaligned start or end and a middle smaller than that
many bytes.  Such a WRITE is issued as a single buffered segment, like
the other WRITEs NFSD does not split.

The gate counts bytes, not pages.  What it weighs, the cost of three I/Os
against one, does not change with the page size, and since a misaligned
WRITE's middle is cut at page boundaries, the middle of such a WRITE is
whole pages: a gate of two pages would demand a 32 KiB middle on 16 KiB
pages and 128 KiB on 64 KiB pages before splitting at all.  On 4 KiB
pages the default is two pages.

Also decide each segment's IOCB_* flags in nfsd_write_dio_iters_init()
instead of in the write loop of nfsd_direct_write().  The flags do not
change: the loop already set IOCB_DONTCACHE on every segment without
IOCB_DIRECT when the file system supports FOP_DONTCACHE.

The threshold, counted there in pages, and the move of the flag
decisions come from Christoph's suggested diff [1].  Two of its choices
are not taken.  It issued the prefix, the suffix and any WRITE it did
not split, whether smaller than its alignment or with a middle below the
threshold, as cached buffered I/O, to leave partial pages in place for
read-modify-write; this patch keeps the DONTCACHE policy already in the
tree, and a later commit makes that policy selectable.  It also split a
WRITE whose payload is misaligned in memory and issued the middle as
DONTCACHE buffered I/O, so that a large middle stayed out of the page
cache while the cached ends stayed in it.  Here the prefix and suffix
are DONTCACHE as well, so that split would issue the same uncached
buffered I/O as two or three writes instead of one; such a WRITE is
issued whole, like every other WRITE NFSD does not split.

Document in nfsd-io-modes.rst when NFSD does not split a WRITE.

Link: https://lore.kernel.org/linux-nfs/aRShjU_Ti7f2Ci7I@infradead.org/ [1]
Suggested-by: Christoph Hellwig <hch@infradead.org>
Assisted-by: LLM
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 .../filesystems/nfs/nfsd-io-modes.rst         | 13 ++++++
 fs/nfsd/debugfs.c                             | 12 +++++
 fs/nfsd/nfsd.h                                |  1 +
 fs/nfsd/vfs.c                                 | 46 +++++++++++--------
 4 files changed, 53 insertions(+), 19 deletions(-)

diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentation/filesystems/nfs/nfsd-io-modes.rst
index f9b63f1a33990..eab35a9bbdb93 100644
--- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
+++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
@@ -137,6 +137,19 @@ Misaligned WRITE:
     cannot invalidate page cache that overlaps the segment. The
     iomap_dio_invalidate_fail trace event reports such a fallback.
 
+    If NFSD does not split a misaligned WRITE, it issues the whole WRITE
+    as a single DONTCACHE buffered IO (normal buffered IO if the
+    filesystem lacks FOP_DONTCACHE). NFSD does not split a WRITE when:
+
+    - the filesystem advertises no DIO alignment;
+    - the WRITE is smaller than the larger of the offset and memory
+      alignments;
+    - the WRITE has a misaligned start or end and its DIO-aligned middle
+      is smaller than /sys/kernel/debug/nfsd/direct_misaligned_min_bytes
+      bytes (default 8192);
+    - the WRITE payload is not aligned in memory to the block device's
+      dma_alignment, so the middle cannot be O_DIRECT either.
+
 Tracing:
     The nfsd_read_direct trace event shows how NFSD expands any
     misaligned READ to the next DIO-aligned block (on either end of the
diff --git a/fs/nfsd/debugfs.c b/fs/nfsd/debugfs.c
index 386fd1c54f527..02b0369f17648 100644
--- a/fs/nfsd/debugfs.c
+++ b/fs/nfsd/debugfs.c
@@ -140,6 +140,18 @@ void nfsd_debugfs_init(void)
 
 	debugfs_create_file("io_cache_write", 0644, nfsd_top_dir, NULL,
 			    &nfsd_io_cache_write_fops);
+
+	/*
+	 * /sys/kernel/debug/nfsd/direct_misaligned_min_bytes
+	 *
+	 * Minimum size, in bytes, of the DIO-aligned middle segment for NFSD
+	 * to split a misaligned direct-mode WRITE.  A WRITE with a misaligned
+	 * start or end and a smaller middle is issued as a single buffered
+	 * segment.  It is in bytes so that it means the same on every page
+	 * size.  The default value of this setting is 8192.
+	 */
+	debugfs_create_u32("direct_misaligned_min_bytes", 0644, nfsd_top_dir,
+			   &nfsd_direct_misaligned_min_bytes);
 #ifdef CONFIG_NFSD_V4
 	debugfs_create_bool("delegated_timestamps", 0644, nfsd_top_dir,
 			    &nfsd_delegts_enabled);
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index d824d2c390294..db81620bd5168 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -142,6 +142,7 @@ enum {
 
 extern u64 nfsd_io_cache_read __read_mostly;
 extern u64 nfsd_io_cache_write __read_mostly;
+extern u32 nfsd_direct_misaligned_min_bytes __read_mostly;
 
 bool nfsd_v4client(struct svc_rqst *rqstp);
 
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index bd3dab36e2962..a419eee401d9d 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -54,6 +54,7 @@
 bool nfsd_disable_splice_read __read_mostly;
 u64 nfsd_io_cache_read __read_mostly = NFSD_IO_BUFFERED;
 u64 nfsd_io_cache_write __read_mostly = NFSD_IO_BUFFERED;
+u32 nfsd_direct_misaligned_min_bytes __read_mostly = 8192;
 
 /**
  * nfserrno - Map Linux errnos to NFS errnos
@@ -1323,9 +1324,13 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	u32 mem_align = nf->nf_dio_mem_align;
 	size_t prefix, middle, suffix;
 	loff_t offset = iocb->ki_pos;
+	unsigned int dontcache_flags = 0;
 	unsigned int nsegs = 0;
 	u32 cut;
 
+	if (nf->nf_file->f_op->fop_flags & FOP_DONTCACHE)
+		dontcache_flags = IOCB_DONTCACHE;
+
 	/*
 	 * Check if direct I/O is feasible for this write request.
 	 * If alignments are not available, the write is too small,
@@ -1355,12 +1360,16 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	middle = middle_end - prefix_end;
 	suffix = orig_end - middle_end;
 
-	if (!middle)
+	if (!middle ||
+	    ((prefix || suffix) &&
+	     middle < nfsd_direct_misaligned_min_bytes))
 		goto no_dio;
 
-	if (prefix)
-		nfsd_write_dio_seg_init(&segments[nsegs++], bvec,
+	if (prefix) {
+		nfsd_write_dio_seg_init(&segments[nsegs], bvec,
 					nvecs, total, 0, prefix, iocb);
+		segments[nsegs++].flags |= dontcache_flags;
+	}
 
 	nfsd_write_dio_seg_init(&segments[nsegs], bvec, nvecs,
 				total, prefix, middle, iocb);
@@ -1374,22 +1383,28 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	 */
 	if (iov_iter_bvec_offset(&segments[nsegs].iter) & (mem_align - 1))
 		goto no_dio;
-	segments[nsegs].flags |= IOCB_DIRECT;
-	/* In case the file system falls back to buffered I/O (-ENOTBLK). */
-	if (nf->nf_file->f_op->fop_flags & FOP_DONTCACHE)
-		segments[nsegs].flags |= IOCB_DONTCACHE;
-	nsegs++;
+	/*
+	 * IOCB_DONTCACHE matters only if the file system falls back to
+	 * buffered I/O (-ENOTBLK).
+	 */
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
+	/*
+	 * Issue the whole WRITE as a single buffered segment, uncached when
+	 * the file system supports FOP_DONTCACHE.
+	 */
 	nfsd_write_dio_seg_init(&segments[0], bvec, nvecs, total, 0,
 				total, iocb);
+	segments[0].flags |= dontcache_flags;
 	return 1;
 }
 
@@ -1413,16 +1428,9 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
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

