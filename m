Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 14E663E1CF8
	for <linux-nfs@vger.kernel.org>; Thu,  1 Oct 2026 04:55:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790830507; cv=none; b=TPsr6LNhEK43U0CukOSdaVP62GhUgoNW2Sk8Xgc7mC5YobwvnSAIn6xSKVMgYQKpOaC/lPIg6rkuKrdXV2WQAclHkEsPKTUMYolka/KfHcT7vN1UVYjbZuO4ifGGukbciLqDBtv0gswDDcq9GXPP85VqyIeJ7QszOYEV8NU1etc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790830507; c=relaxed/simple;
	bh=mY/ooVZP6H7cpZkp5zx4Wiueb6gZSJKJK0z9/IdeE7o=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=lvn+s5hAvM0DKG+mYeBwSs9jpqfwQkJg0OAsHUXdQpGc+JhPUWUcw+iVe5RhaNXB1cxUpiDdFPDjwlyseDCZagnIlOgU8qNkun7RR7TsoktsT9YjL8gGuAh5Plzspyhn/wBt28iHUZco56jpo1dAaiP7GXoNeJzz4RnSqdRa0hE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Jp+dOQ0k; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Jp+dOQ0k"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A90071F000FF;
	Thu,  1 Oct 2026 04:55:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790830505;
	bh=pM2UOopJHj8GBKMwea5dIVKPRb3y/naX0iMz5AMp9Fw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Jp+dOQ0keoUbfp4g/NBVVboJQIFK6RdnV02Ld1O60vHV5ZZqyBxwOJ0//CksHUQhQ
	 NY7zwU7Bn7FQ/nf7lgwZbLUZedjsB+XMdKPvQVtbwngOhiP9OuwcaeDhw1qEGSHRnj
	 fl4mlv8S55xYxwX5P/qFywIB7Yk/RP3Ij2uxRs19hMxGHHi0AlV+z6hY0d1O2yTeMO
	 F4YWCjIf1Cm2LS/aTgPVtjiWL92zVvgeV2O+40BftgxXv4O32e4ke4stVHJtLzIQ9D
	 3Jea0T17LuQ0bpLAggJszOnGHt3DMYbbB6CG2Q4d/Lf53sM6R+2aG13/4TWzWG1fCg
	 38CiTLjf6jLjg==
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: hch@lst.de,
	linux-nfs@vger.kernel.org
Subject: [PATCH v3 2/9] NFSD: only split a direct-mode WRITE for a worthwhile direct middle
Date: Thu,  1 Oct 2026 00:54:55 -0400
Message-ID: <20261001045502.48381-3-snitzer@kernel.org>
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

Splitting a misaligned direct-mode WRITE issues it as two or three
writes instead of one, and the direct write first writes back and
invalidates the page cache over its range.  When the DIO-aligned middle
is only a page or so, the WRITE is mostly its buffered prefix and
suffix anyway, and the direct middle adds that overhead plus the
invalidation that contends with a neighbouring WRITE's buffered segment
in the page they share.

Add direct_misaligned_num_pages (debugfs, default 2) and do not split a
WRITE that has a misaligned start or end and a middle smaller than that
many pages.  Such a WRITE is issued as a single buffered segment, like
the other WRITEs NFSD does not split.

Also decide each segment's IOCB_* flags in nfsd_write_dio_iters_init()
instead of in the write loop of nfsd_direct_write().  The flags do not
change: the loop already set IOCB_DONTCACHE on every segment without
IOCB_DIRECT when the file system supports FOP_DONTCACHE.

The threshold and the move of the flag decisions come from Christoph's
suggested diff [1].  Two of its choices are not taken.  It issued the
prefix, the suffix and a WRITE smaller than its alignment as cached
buffered I/O, to leave partial pages in place for read-modify-write;
this patch keeps the DONTCACHE policy already in the tree, and the next
patch makes that policy selectable.  It also split a WRITE whose
payload is misaligned in memory and issued the middle as DONTCACHE
buffered I/O; no part of such a WRITE can be direct I/O, so it is still
issued whole and treated like every other WRITE that cannot be.

Document in nfsd-io-modes.rst when NFSD does not split a WRITE.

Link: https://lore.kernel.org/linux-nfs/aRShjU_Ti7f2Ci7I@infradead.org/ [1]
Suggested-by: Christoph Hellwig <hch@infradead.org>
Assisted-by: Claude:claude-opus-5[1m]
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 .../filesystems/nfs/nfsd-io-modes.rst         | 13 ++++++
 fs/nfsd/debugfs.c                             | 11 +++++
 fs/nfsd/nfsd.h                                |  1 +
 fs/nfsd/vfs.c                                 | 41 +++++++++++--------
 4 files changed, 48 insertions(+), 18 deletions(-)

diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentation/filesystems/nfs/nfsd-io-modes.rst
index 60b0af9b7e49f..0a67ce9244d38 100644
--- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
+++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
@@ -132,6 +132,19 @@ Misaligned WRITE:
     does when it cannot invalidate page cache that overlaps the segment.
     The iomap_dio_invalidate_fail trace event reports such a fallback.
 
+    If NFSD does not split a misaligned WRITE, it issues the whole WRITE
+    as a single DONTCACHE buffered IO (normal buffered IO if the
+    filesystem lacks FOP_DONTCACHE). NFSD does not split a WRITE when:
+
+    - the filesystem advertises no DIO alignment;
+    - the WRITE is smaller than the larger of the offset and memory
+      alignments;
+    - the WRITE has a misaligned start or end and its DIO-aligned middle
+      is smaller than /sys/kernel/debug/nfsd/direct_misaligned_num_pages
+      pages (default 2);
+    - the WRITE payload is not aligned in memory to the block device's
+      dma_alignment, so the middle cannot be O_DIRECT either.
+
 Tracing:
     The nfsd_read_direct trace event shows how NFSD expands any
     misaligned READ to the next DIO-aligned block (on either end of the
diff --git a/fs/nfsd/debugfs.c b/fs/nfsd/debugfs.c
index 386fd1c54f527..0b3ddf28d2849 100644
--- a/fs/nfsd/debugfs.c
+++ b/fs/nfsd/debugfs.c
@@ -140,6 +140,17 @@ void nfsd_debugfs_init(void)
 
 	debugfs_create_file("io_cache_write", 0644, nfsd_top_dir, NULL,
 			    &nfsd_io_cache_write_fops);
+
+	/*
+	 * /sys/kernel/debug/nfsd/direct_misaligned_num_pages
+	 *
+	 * Minimum size, in pages, of the DIO-aligned middle segment for NFSD
+	 * to split a misaligned direct-mode WRITE.  A WRITE with a misaligned
+	 * start or end and a smaller middle is issued as a single buffered
+	 * segment.  The default value of this setting is 2.
+	 */
+	debugfs_create_u32("direct_misaligned_num_pages", 0644, nfsd_top_dir,
+			   &nfsd_direct_misaligned_num_pages);
 #ifdef CONFIG_NFSD_V4
 	debugfs_create_bool("delegated_timestamps", 0644, nfsd_top_dir,
 			    &nfsd_delegts_enabled);
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 8e8763ae7035c..70219d26b7404 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -145,6 +145,7 @@ enum {
 
 extern u64 nfsd_io_cache_read __read_mostly;
 extern u64 nfsd_io_cache_write __read_mostly;
+extern u32 nfsd_direct_misaligned_num_pages __read_mostly;
 
 bool nfsd_v4client(struct svc_rqst *rqstp);
 
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 1ccdac4693745..0b39f53e041e1 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -53,6 +53,7 @@
 bool nfsd_disable_splice_read __read_mostly;
 u64 nfsd_io_cache_read __read_mostly = NFSD_IO_BUFFERED;
 u64 nfsd_io_cache_write __read_mostly = NFSD_IO_BUFFERED;
+u32 nfsd_direct_misaligned_num_pages __read_mostly = 2;
 
 /**
  * nfserrno - Map Linux errnos to NFS errnos
@@ -1302,8 +1303,12 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	u32 mem_align = nf->nf_dio_mem_align;
 	size_t prefix, middle, suffix;
 	loff_t offset = iocb->ki_pos;
+	unsigned int dontcache_flags = 0;
 	unsigned int nsegs = 0;
 
+	if (nf->nf_file->f_op->fop_flags & FOP_DONTCACHE)
+		dontcache_flags = IOCB_DONTCACHE;
+
 	/*
 	 * Check if direct I/O is feasible for this write request.
 	 * If alignments are not available, the write is too small,
@@ -1321,12 +1326,16 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	middle = middle_end - prefix_end;
 	suffix = orig_end - middle_end;
 
-	if (!middle)
+	if (!middle ||
+	    ((prefix || suffix) &&
+	     middle < PAGE_SIZE * nfsd_direct_misaligned_num_pages))
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
@@ -1340,22 +1349,25 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	 */
 	if (iov_iter_bvec_offset(&segments[nsegs].iter) & (mem_align - 1))
 		goto no_dio;
-	segments[nsegs].flags |= IOCB_DIRECT;
 	/* In case the file system falls back to buffered I/O (-ENOTBLK). */
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
+	/*
+	 * Issue the whole WRITE as a single buffered segment, uncached when
+	 * the file system supports FOP_DONTCACHE.
+	 */
 	nfsd_write_dio_seg_init(&segments[0], bvec, nvecs, total, 0,
 				total, iocb);
+	segments[0].flags |= dontcache_flags;
 	return 1;
 }
 
@@ -1379,16 +1391,9 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
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

