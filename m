Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0B76B4D37C1
	for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 23:13:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790723622; cv=none; b=QY/H58XhD+fDbbVqG6w7myDhyUheA/B+C/Xst1zphOAcac0zX0pa7nXxLBawvkGYSJX9GG8WT6V7F6hDylHTjL80PZj9cy8Mnxo3ujT0jE5MXDGiRM3L/2Hhtmw8rrPfalBky/ILX2B4dtJ2h7ldFsyR6ihjDa6iSi+7ylPnXl0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790723622; c=relaxed/simple;
	bh=CW922jJTg21UZMlvRSMMSiSFMRtJdOGwkALCqNjCbcQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=C+cFfPELmrdZ/GtcEPcw7tTgWiXazeVa9wa4x9LPWcSD6OJgDNTNOdcELdKts2dh7vkAqeHA+Q3TMv+plVrFgmZmE2zlDoe4J09MtKbJ68IJ4C656wW1EWqRB9PUSEK/taMKaAnnV+kmItXIPKqRm8kVHdNJbxZ4NBrY65hio3U=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=U4swdE2f; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="U4swdE2f"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 985321F00893;
	Tue, 29 Sep 2026 23:13:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790723620;
	bh=O+c2qmUCL1NKQQL1rivawvKTEliod01KHhHQMSveFgk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=U4swdE2fcUF86XSRinKWUasSczogb7U6TS5JdMqNgGlYN6KPf5PApofXpKqjia4uO
	 e/0kQ2qF4h0zfrJ8rRRe4n05gkaDwsSUoxYhIibDLA3aTu4pVBzHpL4Q3h+rSR9Kz2
	 VZ0OOGUNdyg2uD2oCsMtjl9vFb09QJqhv0AExogjjc4v/tzgCZPdu2ZLUvlQoysqGS
	 mqCRrZLve01x3lS+fMElK5JVOKls8ClC2e5hCg087gZ/yTgACgjexcF3o/T0pLRk40
	 jdGq6H9v/5PU2EpXhKTLFWOYkswGV59B4uQIGqDEJcKgGbTgGz3X/Z/N2tuec9WxQh
	 zSNlw1d6lPTjw==
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 8/9] NFSD: add direct_misaligned_dontcache debugfs knob
Date: Tue, 29 Sep 2026 19:13:28 -0400
Message-ID: <20260929231329.22018-9-snitzer@kernel.org>
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

From: Jonathan Flynn <jonathan.flynn@hammerspace.com>

The parts of a direct-mode WRITE that cannot be direct I/O, the
misaligned prefix and suffix of a split WRITE and the whole WRITE when
it is not split, are issued IOCB_DONTCACHE so their pages are dropped
once written back.  That is the right default for the workloads a direct
mode is chosen for, but it is a policy rather than a requirement: a
workload that reads back what it just wrote, or that keeps rewriting the
same partial pages, is better served by those pages staying in the page
cache.

Add a bool debugfs knob, /sys/kernel/debug/nfsd/direct_misaligned_dontcache
(default Y), to choose between the two:

  Y: IOCB_DONTCACHE when the file system supports it, with a split's
     boundary page kept in the page cache until both WRITEs sharing it
     have written it (nfsd_write_dio_boundary_claim()).
  N: ordinary cached buffered I/O; nothing is claimed or marked, and the
     pages stay until reclaim.

The direct middle and the once-per-WRITE persist are unaffected.  The
knob is sampled once per WRITE, so a change takes effect immediately and
without a remount.  It sits beside io_cache_read and io_cache_write, the
other controls over how NFSD issues its I/O.

[snitzer: switched from using modparam to debugfs knob]

Signed-off-by: Jonathan Flynn <jonathan.flynn@hammerspace.com>
[snitzer: documented in nfsd-io-modes.rst]
Assisted-by: Claude:claude-opus-5[1m]
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 .../filesystems/nfs/nfsd-io-modes.rst         |  9 ++++++
 fs/nfsd/debugfs.c                             | 21 ++++++++++++++
 fs/nfsd/nfsd.h                                |  1 +
 fs/nfsd/vfs.c                                 | 28 ++++++++++++-------
 4 files changed, 49 insertions(+), 10 deletions(-)

diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentation/filesystems/nfs/nfsd-io-modes.rst
index 2ca606ddf5d51..f2c380ca000f7 100644
--- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
+++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
@@ -178,6 +178,15 @@ Misaligned WRITE:
     with how far concurrent writers drift apart, not with bytes
     written.
 
+    Whether those pages are dropped at all is a policy choice, selected
+    by /sys/kernel/debug/nfsd/direct_misaligned_dontcache (default Y).
+    Write N to issue the start and end segments, and the whole-WRITE
+    fallbacks, as ordinary cached buffered IO: nothing is claimed or
+    marked and the pages stay until reclaim, which suits a workload that
+    reads back or rewrites what it just wrote. The O_DIRECT middle
+    segment is unaffected. The knob is sampled once per WRITE, so a
+    change takes effect immediately.
+
     The O_DIRECT middle segment also carries the DONTCACHE flag. It has
     no effect while the IO really is O_DIRECT, but a filesystem may
     decide on its own to service the segment with buffered IO instead
diff --git a/fs/nfsd/debugfs.c b/fs/nfsd/debugfs.c
index 279e341a81ec1..2b728eac8532c 100644
--- a/fs/nfsd/debugfs.c
+++ b/fs/nfsd/debugfs.c
@@ -144,6 +144,24 @@ void nfsd_debugfs_exit(void)
  * Default 2.  Not yet tuned by benchmarking.
  */
 
+/*
+ * /sys/kernel/debug/nfsd/direct_misaligned_dontcache
+ *
+ * How a direct-mode WRITE issues the I/O that cannot be direct: the
+ * misaligned start and end of a split WRITE, and the whole WRITE when it
+ * is not split.
+ *
+ * Contents:
+ *   Y: DONTCACHE when the filesystem supports it, with the boundary page
+ *      of a split kept in the page cache only until both WRITEs sharing
+ *      it have written it
+ *   N: ordinary cached buffered IO, left in the page cache until
+ *      reclaim, for A/B comparison against the DONTCACHE path
+ *
+ * Sampled once per WRITE, so it takes effect immediately.  The direct
+ * middle segment is unaffected.
+ */
+
 void nfsd_debugfs_init(void)
 {
 	nfsd_top_dir = debugfs_create_dir("nfsd", NULL);
@@ -159,6 +177,9 @@ void nfsd_debugfs_init(void)
 
 	debugfs_create_u32("direct_misaligned_num_pages", 0644, nfsd_top_dir,
 			   &nfsd_direct_misaligned_num_pages);
+
+	debugfs_create_bool("direct_misaligned_dontcache", 0644, nfsd_top_dir,
+			    &nfsd_direct_misaligned_dontcache);
 #ifdef CONFIG_NFSD_V4
 	debugfs_create_bool("delegated_timestamps", 0644, nfsd_top_dir,
 			    &nfsd_delegts_enabled);
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 135e319e378d4..dff979ac370ba 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -145,6 +145,7 @@ enum {
 extern u64 nfsd_io_cache_read __read_mostly;
 extern u64 nfsd_io_cache_write __read_mostly;
 extern u32 nfsd_direct_misaligned_num_pages __read_mostly;
+extern bool nfsd_direct_misaligned_dontcache __read_mostly;
 
 extern int nfsd_max_blksize;
 
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 5fd850a29694f..7896e2e6c5855 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -54,6 +54,7 @@ bool nfsd_disable_splice_read __read_mostly;
 u64 nfsd_io_cache_read __read_mostly = NFSD_IO_BUFFERED;
 u64 nfsd_io_cache_write __read_mostly = NFSD_IO_BUFFERED;
 u32 nfsd_direct_misaligned_num_pages __read_mostly = 2;
+bool nfsd_direct_misaligned_dontcache __read_mostly = true;
 
 /**
  * nfserrno - Map Linux errnos to NFS errnos
@@ -1373,16 +1374,21 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	size_t prefix, middle, suffix;
 	loff_t offset = iocb->ki_pos;
 	unsigned int dontcache_flags = 0;
+	unsigned int buffered_flags;
 	unsigned int nsegs = 0;
 
 	if (nf->nf_file->f_op->fop_flags & FOP_DONTCACHE)
 		dontcache_flags = IOCB_DONTCACHE;
+	/* Buffered segments follow the knob; the direct middle does not. */
+	buffered_flags = READ_ONCE(nfsd_direct_misaligned_dontcache) ?
+			 dontcache_flags : 0;
 
 	/*
 	 * Whenever direct I/O cannot be used for the WRITE, fall back to a
-	 * single DONTCACHE buffered I/O when the file system supports it, so
-	 * the WRITE's pages are dropped from the page cache once written
-	 * back, and to a single cached buffered I/O otherwise.
+	 * single DONTCACHE buffered I/O when the file system supports it (and
+	 * nfsd_direct_misaligned_dontcache is set), so the WRITE's pages are
+	 * dropped from the page cache once written back, and to a single
+	 * cached buffered I/O otherwise.
 	 *
 	 * If the file system doesn't advertise any alignment requirements,
 	 * don't try to issue direct I/O at all.
@@ -1421,13 +1427,15 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	 * its page with the neighbouring WRITE; see
 	 * nfsd_write_dio_boundary_claim(), which nfsd_direct_write() calls right
 	 * before issuing each of them, for how the page is held for the
-	 * partner and dropped once both have written it.
+	 * partner and dropped once both have written it.  With
+	 * nfsd_direct_misaligned_dontcache=N both are plain cached writes and
+	 * nothing is held or dropped: the pages stay until reclaim.
 	 */
 	if (prefix) {
 		nfsd_write_dio_seg_init(&segments[nsegs], bvec,
 					nvecs, total, 0, prefix, iocb);
-		segments[nsegs].flags |= dontcache_flags;
-		segments[nsegs++].boundary = !!dontcache_flags;
+		segments[nsegs].flags |= buffered_flags;
+		segments[nsegs++].boundary = !!buffered_flags;
 	}
 
 	nfsd_write_dio_seg_init(&segments[nsegs], bvec, nvecs,
@@ -1458,8 +1466,8 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	if (suffix) {
 		nfsd_write_dio_seg_init(&segments[nsegs], bvec, nvecs, total,
 					prefix + middle, suffix, iocb);
-		segments[nsegs].flags |= dontcache_flags;
-		segments[nsegs++].boundary = !!dontcache_flags;
+		segments[nsegs].flags |= buffered_flags;
+		segments[nsegs++].boundary = !!buffered_flags;
 	}
 
 	return nsegs;
@@ -1473,8 +1481,8 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	 */
 	nfsd_write_dio_seg_init(&segments[0], bvec, nvecs, total, 0,
 				total, iocb);
-	segments[0].flags |= dontcache_flags;
-	segments[0].edges = !!dontcache_flags;
+	segments[0].flags |= buffered_flags;
+	segments[0].edges = !!buffered_flags;
 	return 1;
 }
 
-- 
2.52.0

