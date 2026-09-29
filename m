Received: from mail-qv2-f12.google.com (mail-qv2-f12.google.com [74.125.230.140])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 69341544D63
	for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 17:34:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.230.140
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790703272; cv=none; b=ckouEdh8UvWlvEatPdvBZ6VFOsG46eLppHaWrARxWmUFzLBGx8y8ienRfYHuDrYGGRO6etWGbE5MYRuwpqunGMw/gNuuHiadoGyjemJcSGTs6qY4u8quY+SvcUDRayTgq2uq9JNmtH/R1dL1Wj5q1Kzsq7Dco3iIjSbHsTOkx3s=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790703272; c=relaxed/simple;
	bh=yhnH9HJBhAW+q/aIlmMil3hMDwoE+Asy7k7fA14RsdI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=IeR9vPkSxQq6vCJIG72M315kXhH2OKkmTi+P3oDuNaq0ysE5QLnNRBM5BJDX049XMWzNxz092cBywFSg/e6WqnM1kpXbkiM0OL8+i1e12iZPCHq/WqgbKxR8rLJV9Cqrx91PAD6Vx9Rbf8E0HmrmFjHFx6PGf6Jos7/pUNAso48=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=hLCWyflG; arc=none smtp.client-ip=74.125.230.140
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="hLCWyflG"
Received: by mail-qv2-f12.google.com with SMTP id 6a1803df08f44-9107051ba26so22535396d6.1
        for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 10:34:30 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1790703269; x=1791308069; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=mYI/E6nH8Avza42X/mUhO4h7RnQsnlTGvIeotf0grYc=;
        b=hLCWyflGWAYMVIg1BFIlkFj9f3/Iz4/GNeDBQ4aEYnRoWgb9DzAMgJ8HD+R8TRx5Hx
         TqYmsmr0z2bvb/taNL+JJKCmRJb/1t8zY6c6WQ17l+JNYAkhmvPVjgs2IyhT8JkU9tz0
         LZFgK7OLh9cw95TfY49B2gJ+lOISdlZ7gNhoTaViTJs/oypRgPejrAxjt+kemupy8/RE
         jhvQqNJBhSCL4XJ8sL004Hm08A0G5vXAXN6cypkJU+SP6dMbDuY8MQCk7A22huUZakG8
         Xe/MRw73TBFcbttlnojCfqkD02su3F5P8BBofMOKWDdeFbt5+bbfdUGONf1AXsF0A1io
         CJQQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790703269; x=1791308069;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=mYI/E6nH8Avza42X/mUhO4h7RnQsnlTGvIeotf0grYc=;
        b=PUSD6/EeJjw4NyYiA/qpMBbq4yueSg9cr1tHYDJr9TEDumT3kEe7Ac99r7ZiazbvKc
         KwFMqy27tRs25/6g4W9ikskQkH6YbQKhfMEYa20iZGJGPv3VC8rm1gUJsVmvtJCR01yS
         pWLetzd71zBtcFrZRQiuzwfCCfQVwJT/ELagZsEc0Sq/1wEPuyiET0N69tz9VnoNAKtF
         7vpBQbNZPFRGGs6UgzckNlnY6HLnubXhIiHusNV6mS8Cm5etpEjDsj3sAnmp/DkuTpTy
         12kQfF/wnrgV6foVrdyfeN1oWLB8MnWL2cf70SGZ5jKTwR03Y+3Xbwq5/E6mcXAaWZtL
         EQEw==
X-Gm-Message-State: AFuF++maH7vDCmMih1l4nrgJbLVwep7ASEggv4g+EMXwhz8e9ttFtQBK
	9hDO/6Re7m3AVJImlLacRbFZZ8mppACTXte2hZtOZ/pAZJhiNKPxfAs1+VGD/KsPZV4=
X-Gm-Gg: AYBFou239Q2kkmimq1oj2SfWxkxRQ1SbZHKlAnhmXGLiqOXhRrlbjfmTMO59kvNRZAl
	TM3KT6t7dQjS6dtEXg9yD58ueKYUoFwxFTmZoP6y/lJLIGOM1xCbEWo0MV6mfejWP+2ReUcGAmQ
	pi2cEMpjcuiNeNssTwpK9ntjh7HVZl45BH3nj/9O4fPhrvTU6Ari5+r0pMIzB8+VYAelNOSVh2z
	W93JyKR6hactIQcdhyg8/ST+geBOVmaU4BjpC/304VXma7JhptBSCJZxtuAZrmQvSjVrLe5rI89
	su961WuIjtzDP8C7US0PP9w6TikLs/XIPxT7OErMXDSfvIVKeo8GAmwPFgmoNzdNC0UPxPHR4mc
	volu5hLWzwKZlmjPddpG6zfXyXm2f33Oc459GXAtiWYNp+jfaPczMnLcCD3JTJgndUXTdzmXVjK
	uvg5nwYxvOegcR09xUVh/LcWCdO8FBiB2Shy4QIhBJjeg0zptCRWJzRkWsvdgAYf6IfK5OBqLGe
	rDEri/59WjGAu5D4cNTj0JIFCc+F3dvl0LuYaVSMulOaxgWbPM9fuTCNkvTKae53Qxb1KjnEA==
X-Received: by 2002:a05:6214:250d:b0:917:9400:e713 with SMTP id 6a1803df08f44-9179400e997mr23957106d6.6.1790703268428;
        Tue, 29 Sep 2026 10:34:28 -0700 (PDT)
Received: from localhost (pool-68-160-167-46.bstnma.fios.verizon.net. [68.160.167.46])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-917987e9aadsm464546d6.23.2026.09.29.10.34.27
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 29 Sep 2026 10:34:28 -0700 (PDT)
Sender: Mike Snitzer <mike.snitzer@hammerspace.com>
From: Mike Snitzer <snitzer@hammerspace.com>
X-Google-Original-From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 03/10] NFSD: only split a direct-mode WRITE for a worthwhile direct middle
Date: Tue, 29 Sep 2026 13:34:16 -0400
Message-ID: <20260929173423.16149-4-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20260929173423.16149-1-snitzer@kernel.org>
References: <20260929173423.16149-1-snitzer@kernel.org>
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
index c15983e634a3e..f4e7cee5ee159 100644
--- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
+++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
@@ -161,9 +161,9 @@ Misaligned WRITE:
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
@@ -175,6 +175,17 @@ Misaligned WRITE:
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
index 995872a1a7f87..afa41bf2d8189 100644
--- a/fs/nfsd/debugfs.c
+++ b/fs/nfsd/debugfs.c
@@ -170,6 +170,17 @@ void nfsd_debugfs_exit(void)
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
@@ -182,6 +193,9 @@ void nfsd_debugfs_init(void)
 
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

