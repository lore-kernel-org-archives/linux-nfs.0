Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A3AF1418A3F
	for <linux-nfs@vger.kernel.org>; Thu,  1 Oct 2026 04:55:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790830508; cv=none; b=nG2amfXiqoajlFq/DpUM/ZYz+MdMZw5NUUrIWilXbc2tTqQ724hKt7mabXMpnxtD1N6yW0UcrNGLFH8QAwb3UysK0osL4zSvVCXvEGAbtzQPSoM63FR3wHD3fdusxGyS27UELrdsFXCmHiFnE4HCJTvZfXQ4fKwKuA243Y3L+Og=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790830508; c=relaxed/simple;
	bh=LNUa7HRxR3pHU4gwYQw7cQm81ck/VDWbaLsFmMhQv7o=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=sfYcN1CUr3MYWGM+wiy2cVS96Lqg2tSom8zUx4UFmjZ5azj3IHc8DH0rxRbrtTd2nGfKy+sBE28NqyIr3kgZUmGjxYq5QA7aibm1EPOQuMcp5xRkOajFwY+aL9CxfZ6dSzEZWNYltsMtvQTbsHyqAv4yy7J982tDd3jPfTGTmR8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=RslO98HK; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="RslO98HK"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EB4781F00898;
	Thu,  1 Oct 2026 04:55:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790830507;
	bh=o1DZzd0hSaa6sN+KD14OcJYIjPzpG206LHwqpQiRu7A=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=RslO98HKpjCdfQQqu5zC4EuIBmdc1uB98Tswezn8IIoDsPaZfffacwRZZMcQPSZNx
	 t0AnpCk5zs9QLIY8c4E8CoAvAxnUisJVq1wYMdBr68XDnTwrjk4G9eBLJ1Kv1fHs+5
	 Cfsz+RBkuJDItq0XdRYlBursMfmDhbwK9fcNO8qrOu+C5JN7miF/8ZI+k31tTFMReF
	 e/kzOO2v8bRfRB94ma6hfCDxzdF1Gxm/po7SIDEstMvGAifYuIg3Nw0dEPcov68b2Z
	 f0LBUKkk/r7NrC2TP2MzLPDv7H0k3Mme6b5eMJpyXEq2vZNrhoLr2yjMmpzhlpcF+s
	 iP4qHMEPvKdzw==
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: hch@lst.de,
	linux-nfs@vger.kernel.org
Subject: [PATCH v3 3/9] NFSD: add direct_misaligned_dontcache debugfs knob
Date: Thu,  1 Oct 2026 00:54:56 -0400
Message-ID: <20261001045502.48381-4-snitzer@kernel.org>
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

From: Jonathan Flynn <jonathan.flynn@hammerspace.com>

The parts of a direct-mode WRITE that are not O_DIRECT, the misaligned
start and end of a split WRITE and a WRITE that is not split, are
issued IOCB_DONTCACHE when the file system supports it.  That suits
the workloads a direct mode is chosen for, but it is a policy, not a
requirement: a workload that reads back or rewrites what it just wrote
is better served by those pages staying cached.

Add /sys/kernel/debug/nfsd/direct_misaligned_dontcache (default Y).
Set to N, those parts are issued as normal buffered I/O.  The O_DIRECT
middle keeps IOCB_DONTCACHE either way.  It sits beside
direct_misaligned_num_pages, which decides how much of a misaligned
WRITE is O_DIRECT; this knob decides how the rest is cached.

Signed-off-by: Jonathan Flynn <jonathan.flynn@hammerspace.com>
[snitzer: switched from a module parameter to a debugfs knob, moved
next to direct_misaligned_num_pages, documented in nfsd-io-modes.rst]
Assisted-by: Claude:claude-opus-5[1m]
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 .../filesystems/nfs/nfsd-io-modes.rst          | 18 +++++++++++++-----
 fs/nfsd/debugfs.c                              | 12 ++++++++++++
 fs/nfsd/nfsd.h                                 |  1 +
 fs/nfsd/vfs.c                                  | 13 +++++++++----
 4 files changed, 35 insertions(+), 9 deletions(-)

diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentation/filesystems/nfs/nfsd-io-modes.rst
index 0a67ce9244d38..9b1a9e7b09cef 100644
--- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
+++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
@@ -126,11 +126,13 @@ Misaligned WRITE:
     middle and end as needed. The large middle segment is DIO-aligned
     and the start and/or end are misaligned. Buffered IO is used for the
     misaligned segments and O_DIRECT is used for the middle DIO-aligned
-    segment. If the filesystem supports FOP_DONTCACHE, every segment is
-    marked DONTCACHE. The flag has no effect on the O_DIRECT segment
-    unless the filesystem services it with buffered IO instead, as XFS
-    does when it cannot invalidate page cache that overlaps the segment.
-    The iomap_dio_invalidate_fail trace event reports such a fallback.
+    segment. If the filesystem supports FOP_DONTCACHE, the O_DIRECT
+    segment is marked DONTCACHE, and so are the misaligned segments
+    unless direct_misaligned_dontcache is N (below). The flag has no
+    effect on the O_DIRECT segment unless the filesystem services it
+    with buffered IO instead, as XFS does when it cannot invalidate page
+    cache that overlaps the segment. The iomap_dio_invalidate_fail trace
+    event reports such a fallback.
 
     If NFSD does not split a misaligned WRITE, it issues the whole WRITE
     as a single DONTCACHE buffered IO (normal buffered IO if the
@@ -145,6 +147,12 @@ Misaligned WRITE:
     - the WRITE payload is not aligned in memory to the block device's
       dma_alignment, so the middle cannot be O_DIRECT either.
 
+    Writing N to /sys/kernel/debug/nfsd/direct_misaligned_dontcache
+    (default Y) issues the start and end segments, and a WRITE that is
+    not split, as normal buffered IO instead of DONTCACHE, which suits a
+    workload that reads back or rewrites what it just wrote. The O_DIRECT
+    middle segment keeps its DONTCACHE flag either way.
+
 Tracing:
     The nfsd_read_direct trace event shows how NFSD expands any
     misaligned READ to the next DIO-aligned block (on either end of the
diff --git a/fs/nfsd/debugfs.c b/fs/nfsd/debugfs.c
index 0b3ddf28d2849..d5b714dd0fbc6 100644
--- a/fs/nfsd/debugfs.c
+++ b/fs/nfsd/debugfs.c
@@ -151,6 +151,18 @@ void nfsd_debugfs_init(void)
 	 */
 	debugfs_create_u32("direct_misaligned_num_pages", 0644, nfsd_top_dir,
 			   &nfsd_direct_misaligned_num_pages);
+
+	/*
+	 * /sys/kernel/debug/nfsd/direct_misaligned_dontcache
+	 *
+	 *   Y: the parts of a direct-mode WRITE that are not O_DIRECT use
+	 *      DONTCACHE buffered IO when the file system supports it
+	 *   N: those parts use normal buffered IO
+	 *
+	 * The default value of this setting is Y.
+	 */
+	debugfs_create_bool("direct_misaligned_dontcache", 0644, nfsd_top_dir,
+			    &nfsd_direct_misaligned_dontcache);
 #ifdef CONFIG_NFSD_V4
 	debugfs_create_bool("delegated_timestamps", 0644, nfsd_top_dir,
 			    &nfsd_delegts_enabled);
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 70219d26b7404..1c17f96012523 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -146,6 +146,7 @@ enum {
 extern u64 nfsd_io_cache_read __read_mostly;
 extern u64 nfsd_io_cache_write __read_mostly;
 extern u32 nfsd_direct_misaligned_num_pages __read_mostly;
+extern bool nfsd_direct_misaligned_dontcache __read_mostly;
 
 bool nfsd_v4client(struct svc_rqst *rqstp);
 
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 0b39f53e041e1..1304953c684b7 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -54,6 +54,7 @@ bool nfsd_disable_splice_read __read_mostly;
 u64 nfsd_io_cache_read __read_mostly = NFSD_IO_BUFFERED;
 u64 nfsd_io_cache_write __read_mostly = NFSD_IO_BUFFERED;
 u32 nfsd_direct_misaligned_num_pages __read_mostly = 2;
+bool nfsd_direct_misaligned_dontcache __read_mostly = true;
 
 /**
  * nfserrno - Map Linux errnos to NFS errnos
@@ -1304,10 +1305,13 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	size_t prefix, middle, suffix;
 	loff_t offset = iocb->ki_pos;
 	unsigned int dontcache_flags = 0;
+	unsigned int buffered_flags;
 	unsigned int nsegs = 0;
 
 	if (nf->nf_file->f_op->fop_flags & FOP_DONTCACHE)
 		dontcache_flags = IOCB_DONTCACHE;
+	buffered_flags = READ_ONCE(nfsd_direct_misaligned_dontcache) ?
+			 dontcache_flags : 0;
 
 	/*
 	 * Check if direct I/O is feasible for this write request.
@@ -1334,7 +1338,7 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	if (prefix) {
 		nfsd_write_dio_seg_init(&segments[nsegs], bvec,
 					nvecs, total, 0, prefix, iocb);
-		segments[nsegs++].flags |= dontcache_flags;
+		segments[nsegs++].flags |= buffered_flags;
 	}
 
 	nfsd_write_dio_seg_init(&segments[nsegs], bvec, nvecs,
@@ -1355,7 +1359,7 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	if (suffix) {
 		nfsd_write_dio_seg_init(&segments[nsegs], bvec, nvecs, total,
 					prefix + middle, suffix, iocb);
-		segments[nsegs++].flags |= dontcache_flags;
+		segments[nsegs++].flags |= buffered_flags;
 	}
 
 	return nsegs;
@@ -1363,11 +1367,12 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 no_dio:
 	/*
 	 * Issue the whole WRITE as a single buffered segment, uncached when
-	 * the file system supports FOP_DONTCACHE.
+	 * the file system supports FOP_DONTCACHE and
+	 * direct_misaligned_dontcache is set.
 	 */
 	nfsd_write_dio_seg_init(&segments[0], bvec, nvecs, total, 0,
 				total, iocb);
-	segments[0].flags |= dontcache_flags;
+	segments[0].flags |= buffered_flags;
 	return 1;
 }
 
-- 
2.52.0

