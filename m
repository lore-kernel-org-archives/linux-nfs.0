Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BB8D3339B3D
	for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 23:13:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790723621; cv=none; b=IxqrUCcDu0cQzBYHmuSYRaOwRu+C8smmlOuzSG67aJnxjb0tg4RGmMHKKX2uzFDDDs5V58hltzgS/9Pqt/5BpcF7L3ECqCKYIACloHEIL7Flou8tLo6cYaxac/kwyaRzBBgNMb1CiYO4T0C1wqaMLRtAIH842e927JtUX0UcPEI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790723621; c=relaxed/simple;
	bh=y/lbMSwo9YHeo1geKCkuaiY2/vNNqnE9EddotefIcHE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=bn+0XAZmKfgSL8d2ejIEuxvMeMdCId03A4p1fTlqWhuwX7P3hxOp5GICGeGUHIkinU0kgGaXK3flYLT2hazdRPZXX/+E3oIHUj9UnP1stXVHnl6iI5aj47GMyQDM87HQ42KdfR8iyAZQSSq7g2g+7cJzJ/0/GFtMDSyO/aCMxk0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=W5K7v+Ey; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="W5K7v+Ey"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5F7BF1F000FF;
	Tue, 29 Sep 2026 23:13:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790723619;
	bh=1L0vG5rEfGdl/LYNAGO2wRTEZsTljJpU0guGOFRGzrQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=W5K7v+Eyp27hXyFcokgvznXsfZqiU2nYydW09T5BapNt7JUmf2BBHvnmqInuUoVID
	 XKJpqhReIRKnbSLj+ziln3juill2IG/msws2v9dhTALz9J7w242Le//X5WSm/TqWCN
	 vjZsuIqQ35Kciva1ffEQLt7tSbpV5GMLgrbOCLRRqwzod4zgqzLk2TgGk9DMfKKkyi
	 WCgTRtb6oH2yghwE7yJpmTSPTCYqV4ZyY8T9U4Wt3/zEhrNDMCPnl1Hh2Cv2Jv3kPZ
	 0BSQPVoGQxy69jkA1UTVJENRI48W/pOnF4kok8ClUtZeroMSz8cMCkaXzemGmBIupm
	 PxFVQQQpAfDeA==
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 7/9] NFSD: keep boundary page of a split direct-mode WRITE until both writers complete
Date: Tue, 29 Sep 2026 19:13:27 -0400
Message-ID: <20260929231329.22018-8-snitzer@kernel.org>
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

A direct-mode WRITE whose ends are not aligned for direct I/O is split
into a buffered prefix, a direct middle and a buffered suffix, and the
prefix and suffix are issued IOCB_DONTCACHE so their pages are dropped
once written back. The page holding such a segment is shared by exactly
two WRITEs, the one ending in it and the one starting in it, which may
arrive in either order, from different clients, at the same time. If it
is dropped as soon as the first writer's data is written back, the
second has to read the block from disk before it can complete it: one
4 KiB read per WRITE. With many clients interleaving small misaligned
O_DIRECT records into one shared file, that was 0.81 device reads per
record (585 GiB read while writing 8.1 TiB).

Keep the page until both writers have had it, with no state in NFSD and
no knowledge of how clients stripe their I/O. Immediately before a
boundary segment is written, nfsd_write_dio_boundary_claim() puts an
empty folio in the page cache if there is not one there already. The
folio is inserted unmarked, which is what makes this work: a DONTCACHE
write only marks a folio it allocated itself, so neither writer's write
marks this one and it never enters WB_DONTCACHE_DIRTY. That counter is
what the DONTCACHE writeback kick targets, and a boundary page counted
there is written back, and then dropped, in the gap between the two
WRITEs that share it.

The add is atomic, so of two concurrent partners exactly one gets the
folio. The other one finds it (-EEXIST) and is therefore the second of
the two: it completes the page, and once its data is in it
nfsd_write_dio_boundary_complete() marks the folio dropbehind. The mark
has to come after the write, because a clean marked folio is dropped by
whatever writeback completes next, and it has to stay unaccounted,
because counting a folio marked while dirty hands the page straight
back to the kick. Whichever writeback cleans the page then drops it:
the WRITE's own sync for FILE_SYNC and DATA_SYNC, the flusher or the
client's COMMIT for UNSTABLE.

A WRITE that cannot use direct I/O at all (memory-misaligned payload,
or too small for a direct middle) is issued as one buffered DONTCACHE
segment. Its first and last pages are shared with the neighbouring
WRITEs in the same way, and are claimed the same way.

Measured with 32 interleaved writers over an emulated 4Kn NVMe,
io_cache_write=4, direct_misaligned_dontcache=Y, each arm starting from
a freshly made file system. 47008-byte records, which split: 704 device
reads for 42895 WRITEs, against 45144 for 45664 WRITEs with the
mechanism compiled out. 6000-byte records, which never get a direct
middle and so are one buffered segment whose end pages are shared: 385
reads against 196589. The DONTCACHE flusher stays idle in both, and the
pages are dropped: 81 of the written file's 524066 pages are still
resident afterwards.

On a four-server pNFS flexfiles rig, three clients writing 47008-byte
records for 240 s against 640 nfsd threads per server, compared with
the same servers before this change: device reads fall from 0.014-0.015
per record to 0.003, page-cache growth over the write phase falls from
about 11 GiB to 2.9 GiB, and write throughput rises by 2.4% to 4.9%
across NFSD_IO_DIRECT and both stable_how floors, with read throughput
unchanged. Records of that size always take the split path, since their
direct middle is at least 38818 bytes, so the figures are the split
path alone; the whole-WRITE fallback needs records below about 12 KB to
come into play. Keeping every boundary page cached instead, which a
later commit makes possible with a direct_misaligned_dontcache=N
debugfs knob, grows the page cache by about 630 GiB over the same
runs.

Reported-by: Jonathan Flynn <jonathan.flynn@hammerspace.com>
Assisted-by: Claude:claude-opus-5[1m]
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 .../filesystems/nfs/nfsd-io-modes.rst         |  28 ++++
 fs/nfsd/vfs.c                                 | 131 ++++++++++++++++--
 2 files changed, 151 insertions(+), 8 deletions(-)

diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentation/filesystems/nfs/nfsd-io-modes.rst
index 9ee94cfa546d8..2ca606ddf5d51 100644
--- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
+++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
@@ -150,6 +150,34 @@ Misaligned WRITE:
     misaligned segments use DONTCACHE buffered IO so that their pages
     are dropped from the page cache once written back.
 
+    A FILE_SYNC or DATA_SYNC WRITE (requested by the client, or imposed
+    as the floor by NFSD_IO_DIRECT_WRITE_FILE_SYNC and
+    NFSD_IO_DIRECT_WRITE_DATA_SYNC) is persisted once, after all of its
+    segments have been written, rather than after each segment.
+
+    The page holding a start or end segment is shared by exactly two
+    WRITEs, the one ending in it and the one starting in it, which may
+    arrive in either order, from different clients, and at the same
+    time. Both segments are issued as DONTCACHE buffered IO, so the page
+    would be dropped as soon as the first writer's data is written back,
+    leaving the second to read it back. Immediately before writing a
+    start or end segment NFSD therefore puts an empty page in the page
+    cache if there is not one already. That page is not marked "drop
+    behind" when it is created, so it does not count towards the
+    DONTCACHE writeback backlog and the writeback kick does not write it
+    back, and drop it, between the two WRITEs that share it.
+
+    Whichever WRITE finds the page already there is the second of the
+    two: it completes the page and marks it "drop behind" once its data
+    is in it, so whichever writeback cleans it afterwards (the WRITE's
+    own sync for FILE_SYNC or DATA_SYNC, the flusher or the client's
+    COMMIT for UNSTABLE) drops it. A WRITE that gets no direct middle at
+    all is issued as a single buffered DONTCACHE segment, and its first
+    and last pages are shared and handled the same way. The retained
+    page cache is the set of half-written boundary pages, which grows
+    with how far concurrent writers drift apart, not with bytes
+    written.
+
     The O_DIRECT middle segment also carries the DONTCACHE flag. It has
     no effect while the IO really is O_DIRECT, but a filesystem may
     decide on its own to service the segment with buffered IO instead
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 827dfe0b5dac7..5fd850a29694f 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1271,6 +1271,8 @@ static int wait_for_concurrent_writes(struct file *file)
 struct nfsd_write_dio_seg {
 	struct iov_iter			iter;
 	int				flags;
+	bool				boundary;	/* prefix or suffix of a split */
+	bool				edges;		/* buffered fallback: partial end pages */
 };
 
 static unsigned long
@@ -1290,6 +1292,73 @@ nfsd_write_dio_seg_init(struct nfsd_write_dio_seg *segment,
 		iov_iter_advance(&segment->iter, start);
 	iov_iter_truncate(&segment->iter, len);
 	segment->flags = iocb->ki_flags;
+	segment->boundary = false;
+	segment->edges = false;
+}
+
+/**
+ * nfsd_write_dio_boundary_claim - claim the page a boundary segment shares
+ * @file: the file being written
+ * @pos: any byte offset within the page
+ *
+ * The page holding a misaligned prefix or suffix is shared by exactly two
+ * WRITEs, the one ending in it and the one starting in it, which may arrive
+ * in either order, from different clients, at the same time.  Put an empty
+ * folio there if there is not one already: it is inserted unmarked, so
+ * neither writer's DONTCACHE write marks it (a DONTCACHE write only marks a
+ * folio it allocated itself) and it never enters WB_DONTCACHE_DIRTY, which
+ * is what would otherwise arm the DONTCACHE writeback kick and have the
+ * flusher write the page back, and drop it, between the two WRITEs.
+ *
+ * The add is atomic, so of two concurrent partners exactly one gets the
+ * folio.  If it cannot be allocated the segment is an ordinary DONTCACHE
+ * write and the page is dropped after writeback as before.
+ *
+ * Return: true if this WRITE is the second of the two and must call
+ * nfsd_write_dio_boundary_complete() once its segment has been written.
+ */
+static bool
+nfsd_write_dio_boundary_claim(struct file *file, loff_t pos)
+{
+	struct address_space *mapping = file->f_mapping;
+	pgoff_t index = pos >> PAGE_SHIFT;
+	gfp_t gfp = mapping_gfp_mask(mapping);
+	struct folio *folio;
+	int err;
+
+	folio = filemap_alloc_folio(gfp, 0, NULL);
+	if (!folio)
+		return false;
+	err = filemap_add_folio(mapping, folio, index, gfp);
+	if (!err) {
+		/* First writer: the page is in place, waiting for the partner. */
+		folio_unlock(folio);
+		folio_put(folio);
+		return false;
+	}
+	folio_put(folio);
+	return err == -EEXIST;
+}
+
+/*
+ * The second writer's data is in the page: mark it so the next writeback
+ * that cleans it drops it.  This must follow the write, because a clean
+ * marked folio is dropped by whatever writeback completes next, and it uses
+ * folio_set_dropbehind() rather than an accounted setter, because counting a
+ * folio marked while dirty arms the DONTCACHE writeback kick and the page is
+ * then written back, and dropped, before its partner has written it.
+ */
+static void
+nfsd_write_dio_boundary_complete(struct file *file, loff_t pos)
+{
+	struct address_space *mapping = file->f_mapping;
+	struct folio *folio;
+
+	folio = __filemap_get_folio(mapping, pos >> PAGE_SHIFT, FGP_DONTCACHE, 0);
+	if (IS_ERR(folio))
+		return;
+	folio_set_dropbehind(folio);
+	folio_put(folio);
 }
 
 static unsigned int
@@ -1348,14 +1417,17 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	}
 
 	/*
-	 * The prefix and suffix are buffered I/O by definition.  Mark them
-	 * uncached when possible so their folios are dropped once written
-	 * back rather than lingering in the page cache.
+	 * The prefix and suffix are buffered I/O by definition.  Each shares
+	 * its page with the neighbouring WRITE; see
+	 * nfsd_write_dio_boundary_claim(), which nfsd_direct_write() calls right
+	 * before issuing each of them, for how the page is held for the
+	 * partner and dropped once both have written it.
 	 */
 	if (prefix) {
 		nfsd_write_dio_seg_init(&segments[nsegs], bvec,
 					nvecs, total, 0, prefix, iocb);
-		segments[nsegs++].flags |= dontcache_flags;
+		segments[nsegs].flags |= dontcache_flags;
+		segments[nsegs++].boundary = !!dontcache_flags;
 	}
 
 	nfsd_write_dio_seg_init(&segments[nsegs], bvec, nvecs,
@@ -1386,16 +1458,23 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	if (suffix) {
 		nfsd_write_dio_seg_init(&segments[nsegs], bvec, nvecs, total,
 					prefix + middle, suffix, iocb);
-		segments[nsegs++].flags |= dontcache_flags;
+		segments[nsegs].flags |= dontcache_flags;
+		segments[nsegs++].boundary = !!dontcache_flags;
 	}
 
 	return nsegs;
 
 no_dio:
-	/* No DIO possible - pack into a single uncached (if possible) segment. */
+	/*
+	 * No DIO possible - pack into a single buffered segment.  Where it
+	 * does not start or end on a page boundary, its first and last pages
+	 * are shared with the neighbouring WRITEs like a prefix or suffix and
+	 * are held the same way (nfsd_write_dio_boundary_claim()).
+	 */
 	nfsd_write_dio_seg_init(&segments[0], bvec, nvecs, total, 0,
 				total, iocb);
 	segments[0].flags |= dontcache_flags;
+	segments[0].edges = !!dontcache_flags;
 	return 1;
 }
 
@@ -1423,8 +1502,8 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	struct nfsd_write_dio_seg segments[3];
 	int floor_iocb_flags = 0;
 	struct file *file = nf->nf_file;
-	loff_t start = kiocb->ki_pos;
-	bool sync, datasync;
+	loff_t start = kiocb->ki_pos, seg_pos, seg_last;
+	bool sync, datasync, complete_first, complete_last;
 	unsigned int nsegs, i;
 	ssize_t host_err;
 	size_t expected;
@@ -1461,9 +1540,45 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 
 		expected = iov_iter_count(&segments[i].iter);
 
+		/*
+		 * Claim the boundary page immediately before writing it, not
+		 * when the WRITE is split. Nothing is held across the write:
+		 * the claim leaves the page in the page cache unmarked, and
+		 * claiming it earlier would give the partner WRITE the time a
+		 * direct middle takes to complete the page and have it
+		 * dropped before this segment writes it.
+		 */
+		seg_pos = kiocb->ki_pos;
+		seg_last = seg_pos + expected - 1;
+		complete_first = false;
+		complete_last = false;
+		if (segments[i].boundary) {
+			complete_first = nfsd_write_dio_boundary_claim(file,
+								       seg_pos);
+		} else if (segments[i].edges) {
+			/*
+			 * A whole-WRITE buffered segment shares its first page
+			 * with the previous WRITE if it does not start on a page
+			 * boundary, and its last page with the next one if it
+			 * does not end on one; a page it covers entirely is its
+			 * own.
+			 */
+			if (seg_pos & ~PAGE_MASK)
+				complete_first = nfsd_write_dio_boundary_claim(
+							file, seg_pos);
+			if (((seg_last + 1) & ~PAGE_MASK) &&
+			    (seg_last >> PAGE_SHIFT) != (seg_pos >> PAGE_SHIFT))
+				complete_last = nfsd_write_dio_boundary_claim(
+							file, seg_last);
+		}
+
 		host_err = vfs_iocb_iter_write(file, kiocb, &segments[i].iter);
 		if (host_err < 0)
 			return host_err;
+		if (complete_first)
+			nfsd_write_dio_boundary_complete(file, seg_pos);
+		if (complete_last)
+			nfsd_write_dio_boundary_complete(file, seg_last);
 		*cnt += host_err;
 		if (host_err < (ssize_t)expected)
 			break;	/* partial write */
-- 
2.52.0

