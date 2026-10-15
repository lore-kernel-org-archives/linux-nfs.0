Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4AD3E3EA947
	for <linux-nfs@vger.kernel.org>; Thu, 15 Oct 2026 23:33:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792107197; cv=none; b=UEfggqCUT9c/1RtAuCMzKG/FCBFPWttHGKqmGpAJI0Xqu1lGmhwoPPix7Y9cLvKMJ07OByAUvOQ/qRh2u66C3JEpaIkj2Wujbw3bzUx8JaE0BiqWNn8fqpYzxQ9xB6sQyhlApOMBkKj5kQUaPuGKZWFHlnkKXTCJpmaKxsq1z6Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792107197; c=relaxed/simple;
	bh=TNXVt3RCDegR9OHEk2Lkai/a8HIcPTPpeX6cKfHvImw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=dzHa0KCPwrHXW9FR0jRs5yCPsOmlK8LSJOhVqlj/BeRCXG2Hxn9NopN9l6i39869UcXaQvSYQ4uDRToBdArAX7rL8GFlp73FC+D5+3ZcTFa9OdC/8rGPCJGm+9OyV3lFbDB19ca4vle4sdLoVbnKD+/HuB3sh5LnJC+s6ggl8uk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=jVUrcXJr; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="jVUrcXJr"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A1A8D1F000C4;
	Thu, 15 Oct 2026 23:33:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792107195;
	bh=rIXvUItkvC3iFQGlhX5ecnIhSGL49TpsiZWITMKCrrk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=jVUrcXJrD4hV/kTKKy/jyKReYXDl7pCqoRRW4W+yt9Ko3vWe92YgVwtrGoIzMFHxU
	 jLE52P0MlSqeYYFbIpDN71tlRC28KecQFCoA1r4p4C65rJlUKVE6/b9VR/BpRbrreu
	 TZOzQUOpBgKJgQwaoPfEhpLlP29wxwwLpX3xaqQdOFgg4Z+1vVi6MLenwFGCYN3YuW
	 TsrZaQk2J3ZXSi4vGLYCIlT8SkNaa8cji0prMScbFh8+YEHUCw6HzN0TP6B3oWrgrV
	 kD94UilK2EUrO+xvUjcdD85bUGWXqEr3qC4wIgD6vI25PeXWPNPOBTVvD/2fNcGHoB
	 /0iPuHT/qh7sg==
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
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: [PATCH v4 04/10] NFSD: add direct_misaligned_dontcache debugfs knob
Date: Thu, 15 Oct 2026 19:33:03 -0400
Message-ID: <20261015233309.42999-5-snitzer@kernel.org>
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

From: Jonathan Flynn <jonathan.flynn@hammerspace.com>

The parts of a direct-mode WRITE that are not O_DIRECT (the misaligned
start and end of a split WRITE, or the whole of a WRITE that is not
split) are issued IOCB_DONTCACHE when the file system sets
FOP_DONTCACHE.  That suits the workloads a direct mode is chosen for,
but it is a policy, not a requirement: a workload that reads back or
rewrites what it just wrote is better served by those pages staying
cached.

Add /sys/kernel/debug/nfsd/direct_misaligned_dontcache (default Y).  Set
to N, those parts are issued as normal buffered I/O.  The O_DIRECT
middle keeps IOCB_DONTCACHE either way.  With N, a WRITE that is not
split, including one whose payload is misaligned in memory, is cached in
full.  The knob sits beside direct_misaligned_min_bytes, which decides
whether a misaligned WRITE is split at all; this knob decides how the
parts that are not O_DIRECT are cached.

Signed-off-by: Jonathan Flynn <jonathan.flynn@hammerspace.com>
[snitzer: switched from a module parameter to a debugfs knob, moved
next to direct_misaligned_min_bytes, documented in nfsd-io-modes.rst]
Assisted-by: LLM
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 .../filesystems/nfs/nfsd-io-modes.rst         | 19 +++++++++++++------
 fs/nfsd/debugfs.c                             | 13 +++++++++++++
 fs/nfsd/nfsd.h                                |  1 +
 fs/nfsd/vfs.c                                 | 12 ++++++++----
 4 files changed, 35 insertions(+), 10 deletions(-)

diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentation/filesystems/nfs/nfsd-io-modes.rst
index eab35a9bbdb93..2679d85152dfc 100644
--- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
+++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
@@ -131,15 +131,17 @@ Misaligned WRITE:
     offset, so the O_DIRECT segment never shares a page with a buffered
     one; a start or end that is already DIO-aligned gets no buffered
     segment at all. If the filesystem supports FOP_DONTCACHE, the
-    misaligned segments are marked DONTCACHE.
-    So is the O_DIRECT segment, where the flag has no effect unless the
-    filesystem services it with buffered IO instead, as XFS does when it
-    cannot invalidate page cache that overlaps the segment. The
-    iomap_dio_invalidate_fail trace event reports such a fallback.
+    O_DIRECT segment is marked DONTCACHE, and so are the misaligned
+    segments unless direct_misaligned_dontcache is N (below). The flag
+    has no effect on the O_DIRECT segment unless the filesystem services
+    it with buffered IO instead, as XFS does when it cannot invalidate
+    page cache that overlaps the segment. The iomap_dio_invalidate_fail
+    trace event reports such a fallback.
 
     If NFSD does not split a misaligned WRITE, it issues the whole WRITE
     as a single DONTCACHE buffered IO (normal buffered IO if the
-    filesystem lacks FOP_DONTCACHE). NFSD does not split a WRITE when:
+    filesystem lacks FOP_DONTCACHE or direct_misaligned_dontcache is N).
+    NFSD does not split a WRITE when:
 
     - the filesystem advertises no DIO alignment;
     - the WRITE is smaller than the larger of the offset and memory
@@ -150,6 +152,11 @@ Misaligned WRITE:
     - the WRITE payload is not aligned in memory to the block device's
       dma_alignment, so the middle cannot be O_DIRECT either.
 
+    Writing N to /sys/kernel/debug/nfsd/direct_misaligned_dontcache
+    (default Y) issues the start and end segments, and a WRITE that is
+    not split, as normal buffered IO instead of DONTCACHE, which suits a
+    workload that reads back or rewrites what it just wrote.
+
 Tracing:
     The nfsd_read_direct trace event shows how NFSD expands any
     misaligned READ to the next DIO-aligned block (on either end of the
diff --git a/fs/nfsd/debugfs.c b/fs/nfsd/debugfs.c
index 02b0369f17648..80f53a4ada7bf 100644
--- a/fs/nfsd/debugfs.c
+++ b/fs/nfsd/debugfs.c
@@ -152,6 +152,19 @@ void nfsd_debugfs_init(void)
 	 */
 	debugfs_create_u32("direct_misaligned_min_bytes", 0644, nfsd_top_dir,
 			   &nfsd_direct_misaligned_min_bytes);
+
+	/*
+	 * /sys/kernel/debug/nfsd/direct_misaligned_dontcache
+	 *
+	 *   Y: the start and end segments of a split direct-mode WRITE, and
+	 *      a WRITE that is not split, use DONTCACHE buffered IO when the
+	 *      file system supports FOP_DONTCACHE
+	 *   N: those segments use normal buffered IO
+	 *
+	 * The default value of this setting is Y.
+	 */
+	debugfs_create_bool("direct_misaligned_dontcache", 0644, nfsd_top_dir,
+			    &nfsd_direct_misaligned_dontcache);
 #ifdef CONFIG_NFSD_V4
 	debugfs_create_bool("delegated_timestamps", 0644, nfsd_top_dir,
 			    &nfsd_delegts_enabled);
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index db81620bd5168..b520b51692b09 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -143,6 +143,7 @@ enum {
 extern u64 nfsd_io_cache_read __read_mostly;
 extern u64 nfsd_io_cache_write __read_mostly;
 extern u32 nfsd_direct_misaligned_min_bytes __read_mostly;
+extern bool nfsd_direct_misaligned_dontcache __read_mostly;
 
 bool nfsd_v4client(struct svc_rqst *rqstp);
 
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index a419eee401d9d..b596bd61f8cb7 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -55,6 +55,7 @@ bool nfsd_disable_splice_read __read_mostly;
 u64 nfsd_io_cache_read __read_mostly = NFSD_IO_BUFFERED;
 u64 nfsd_io_cache_write __read_mostly = NFSD_IO_BUFFERED;
 u32 nfsd_direct_misaligned_min_bytes __read_mostly = 8192;
+bool nfsd_direct_misaligned_dontcache __read_mostly = true;
 
 /**
  * nfserrno - Map Linux errnos to NFS errnos
@@ -1325,11 +1326,13 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	size_t prefix, middle, suffix;
 	loff_t offset = iocb->ki_pos;
 	unsigned int dontcache_flags = 0;
+	unsigned int buffered_flags;
 	unsigned int nsegs = 0;
 	u32 cut;
 
 	if (nf->nf_file->f_op->fop_flags & FOP_DONTCACHE)
 		dontcache_flags = IOCB_DONTCACHE;
+	buffered_flags = nfsd_direct_misaligned_dontcache ? dontcache_flags : 0;
 
 	/*
 	 * Check if direct I/O is feasible for this write request.
@@ -1368,7 +1371,7 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	if (prefix) {
 		nfsd_write_dio_seg_init(&segments[nsegs], bvec,
 					nvecs, total, 0, prefix, iocb);
-		segments[nsegs++].flags |= dontcache_flags;
+		segments[nsegs++].flags |= buffered_flags;
 	}
 
 	nfsd_write_dio_seg_init(&segments[nsegs], bvec, nvecs,
@@ -1392,7 +1395,7 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	if (suffix) {
 		nfsd_write_dio_seg_init(&segments[nsegs], bvec, nvecs, total,
 					prefix + middle, suffix, iocb);
-		segments[nsegs++].flags |= dontcache_flags;
+		segments[nsegs++].flags |= buffered_flags;
 	}
 
 	return nsegs;
@@ -1400,11 +1403,12 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
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

