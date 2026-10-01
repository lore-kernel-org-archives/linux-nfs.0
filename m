Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E189B379EDA
	for <linux-nfs@vger.kernel.org>; Thu,  1 Oct 2026 04:55:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790830512; cv=none; b=N9emLKyrGJ+XjnjJ78mC7rE8Q8pdR7p7tqKj5e42Pt2lZ/VUs3LI85C5DKPmi5IYJuglyAPaVPrcfVTKO9VOkp62i90jQ+wBle9t/VG3wkTjir5VjafzRV1UgSjamwXnoVYCxtXdeoAwl8Vo8mcYv1eTCswvI+1lFUBRgUU2u1I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790830512; c=relaxed/simple;
	bh=/zGbSHc+dCkC5A04UxP+5CJpeF6aDPuMSwwXMgOfiN0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=qti/MMccqcfwbcCNf9aoYD4HILJ2cstR/v6zD+QRZ3sU40LDrclGdzb+j+6fdkq8tOhP9/knI3NKKijbKXmhcQDhzlDhfdiQ7tcQZV5fwQHSQk7iFj1B5kDIet2PScD3UCuP2aYD4yDgCvnDWqIG5oTO8VPrl8HJ6Q91EaNHLVc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=DM3DhA29; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="DM3DhA29"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 93C341F000FF;
	Thu,  1 Oct 2026 04:55:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790830510;
	bh=l4m/49rXZys4opMsgWT5jP1+LM2B10Iv4ntLJWRXP4o=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=DM3DhA299PP6fskbTugerg/WW4nuSWjmmaNEd+a7YSW9/nqo/OaTc9wMyLAW2ouI0
	 fj4D/m3FRssis7Yj1S+yCDfO0g4K8xjJO5rWXbkQsgnsOAAl74BHfOgdVLE6jFjcn6
	 XsOiYXVjTNlgLwGoxWOl7++L7kWQLsUcOIMiAfJxn/dpsoejEudwDpUkC3jNLUpp4L
	 nvTZLKOz5ewVzT9pxOjdRiYWTxCv2p+3hpGGMEstxkeFMNbSuQQWMjtf3F66MgzshY
	 qguhQjNt1hz+BEX2/SPHFlvC7+vcaUA5Ur2tsKrvDNR7qtec910RhcUFbdnVh5M8f3
	 izwx7+tpn9bGw==
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: hch@lst.de,
	linux-nfs@vger.kernel.org
Subject: [PATCH v3 6/9] NFSD: keep boundary page of a split direct-mode WRITE until both writers complete
Date: Thu,  1 Oct 2026 00:54:59 -0400
Message-ID: <20261001045502.48381-7-snitzer@kernel.org>
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

A direct-mode WRITE whose ends are not aligned for direct I/O is split
into a buffered prefix, a direct middle and a buffered suffix, and the
prefix and suffix are issued IOCB_DONTCACHE so their pages are dropped
once written back.  The page holding such a segment is shared by two
WRITEs, the one ending in it and the one starting in it, which may
arrive in either order, from different clients, at the same time.  If
it is dropped as soon as the first writer's data is written back, the
second has to read the block from disk before it can complete it: one
4 KiB read per WRITE.  With many clients interleaving small misaligned
O_DIRECT records into one shared file, that was 0.81 device reads per
record (585 GiB read while writing 8.1 TiB).

Keep the page until both writers have had it, with no state in NFSD.
Immediately before a boundary segment is written,
nfsd_write_dio_boundary_claim() puts an empty folio in the page cache
if there is not one there already.  The folio is inserted unmarked: a
DONTCACHE write only marks a folio it allocated itself, so neither
writer marks this one and it is never counted in WB_DONTCACHE_DIRTY,
which is what the DONTCACHE writeback kick targets.

The add is atomic, so of two concurrent partners exactly one gets the
folio.  The other finds it (-EEXIST), is therefore the second of the
two, and once its data is in the page
nfsd_write_dio_boundary_complete() marks the folio dropbehind.  The
mark must follow the write, because a clean marked folio is dropped by
whatever writeback completes next, and must not be accounted, because
a counted folio is handed straight back to the kick.  Whichever
writeback then cleans the page drops it: the WRITE's own sync for
FILE_SYNC and DATA_SYNC, the flusher or the client's COMMIT for
UNSTABLE.

A WRITE that is not split is issued as one buffered DONTCACHE segment.
Its first and last pages are shared with the neighbouring WRITEs in the
same way, and are claimed the same way.  Nothing is claimed when
direct_misaligned_dontcache is N, since those pages are then cached.

Measured with 32 interleaved writers over an emulated 4Kn NVMe,
direct_misaligned_dontcache=Y and io_cache_write=4 (the
NFSD_IO_DIRECT_WRITE_FILE_SYNC mode added in a later commit), each arm
starting from a freshly made file system.  47008-byte records, which
split: 704 device reads for 42895 WRITEs, against 45144 for 45664 WRITEs
without this patch.  6000-byte records, which are not split: 385 reads
against 196589.  The DONTCACHE flusher stays idle in both, and 81 of the
written file's 524066 pages are still resident afterwards.

On a four-server pNFS flexfiles rig, three clients writing 47008-byte
records for 240 s against 640 nfsd threads per server: device reads
fall from 0.014-0.015 per record to 0.003, page-cache growth over the
write phase falls from about 11 GiB to 2.9 GiB, and write throughput
rises by 2.4% to 4.9% across NFSD_IO_DIRECT and the two modes added
in a later commit, with read throughput unchanged.
Keeping every boundary page cached instead, with
direct_misaligned_dontcache=N, grows the page cache by about 630 GiB
over the same runs.

Reported-by: Jonathan Flynn <jonathan.flynn@hammerspace.com>
Assisted-by: Claude:claude-opus-5[1m]
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 .../filesystems/nfs/nfsd-io-modes.rst         | 11 +++
 fs/nfsd/vfs.c                                 | 87 ++++++++++++++++++-
 2 files changed, 94 insertions(+), 4 deletions(-)

diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentation/filesystems/nfs/nfsd-io-modes.rst
index 686b106b96f1b..683e3a81d4de1 100644
--- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
+++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
@@ -155,6 +155,17 @@ Misaligned WRITE:
     A FILE_SYNC or DATA_SYNC WRITE is persisted once after all of its
     segments are written, not once per segment.
 
+    The page holding a start or end segment is shared with the
+    neighbouring WRITE, which may arrive before, after or at the same
+    time, from any client. So that the second WRITE to such a page does
+    not have to read it back from disk, NFSD puts an empty page there
+    immediately before writing a start or end segment, if there is not
+    one already, without marking it DONTCACHE. The WRITE that finds the
+    page already there marks it DONTCACHE once it has written it, and
+    the next writeback drops it. The first and last pages of a WRITE
+    that is not split are handled the same way. None of this applies
+    when direct_misaligned_dontcache is N.
+
     Writing N to /sys/kernel/debug/nfsd/direct_misaligned_dontcache
     (default Y) issues the start and end segments, and a WRITE that is
     not split, as normal buffered IO instead of DONTCACHE, which suits a
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 592415900403f..5a54ef664da43 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1272,6 +1272,8 @@ static int wait_for_concurrent_writes(struct file *file)
 struct nfsd_write_dio_seg {
 	struct iov_iter			iter;
 	int				flags;
+	bool				boundary;	/* prefix or suffix */
+	bool				edges;		/* unsplit WRITE */
 };
 
 static unsigned long
@@ -1291,6 +1293,54 @@ nfsd_write_dio_seg_init(struct nfsd_write_dio_seg *segment,
 		iov_iter_advance(&segment->iter, start);
 	iov_iter_truncate(&segment->iter, len);
 	segment->flags = iocb->ki_flags;
+	segment->boundary = false;
+	segment->edges = false;
+}
+
+/*
+ * The page holding a misaligned start or end of a WRITE is shared with the
+ * neighbouring WRITE.  Put an unmarked folio there if there is none: a
+ * DONTCACHE write marks only a folio it allocates, so neither WRITE marks
+ * this one and no writeback drops it before the other WRITE has written it.
+ *
+ * Return: true if a folio was already there.  This WRITE is then the
+ * second of the two and calls nfsd_write_dio_boundary_complete() after
+ * writing the page.
+ */
+static bool
+nfsd_write_dio_boundary_claim(struct file *file, loff_t pos)
+{
+	struct address_space *mapping = file->f_mapping;
+	gfp_t gfp = mapping_gfp_mask(mapping);
+	struct folio *folio;
+	int err;
+
+	folio = filemap_alloc_folio(gfp, 0, NULL);
+	if (!folio)
+		return false;
+	err = filemap_add_folio(mapping, folio, pos >> PAGE_SHIFT, gfp);
+	if (!err)
+		folio_unlock(folio);
+	folio_put(folio);
+	return err == -EEXIST;
+}
+
+/*
+ * Both WRITEs have written the page: mark it so the writeback that cleans
+ * it drops it.  folio_set_dropbehind() does not count the folio in
+ * WB_DONTCACHE_DIRTY.
+ */
+static void
+nfsd_write_dio_boundary_complete(struct file *file, loff_t pos)
+{
+	struct folio *folio;
+
+	folio = __filemap_get_folio(file->f_mapping, pos >> PAGE_SHIFT,
+				    FGP_DONTCACHE, 0);
+	if (IS_ERR(folio))
+		return;
+	folio_set_dropbehind(folio);
+	folio_put(folio);
 }
 
 static unsigned int
@@ -1338,7 +1388,8 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	if (prefix) {
 		nfsd_write_dio_seg_init(&segments[nsegs], bvec,
 					nvecs, total, 0, prefix, iocb);
-		segments[nsegs++].flags |= buffered_flags;
+		segments[nsegs].flags |= buffered_flags;
+		segments[nsegs++].boundary = !!buffered_flags;
 	}
 
 	nfsd_write_dio_seg_init(&segments[nsegs], bvec, nvecs,
@@ -1359,7 +1410,8 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	if (suffix) {
 		nfsd_write_dio_seg_init(&segments[nsegs], bvec, nvecs, total,
 					prefix + middle, suffix, iocb);
-		segments[nsegs++].flags |= buffered_flags;
+		segments[nsegs].flags |= buffered_flags;
+		segments[nsegs++].boundary = !!buffered_flags;
 	}
 
 	return nsegs;
@@ -1373,6 +1425,7 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	nfsd_write_dio_seg_init(&segments[0], bvec, nvecs, total, 0,
 				total, iocb);
 	segments[0].flags |= buffered_flags;
+	segments[0].edges = !!buffered_flags;
 	return 1;
 }
 
@@ -1383,8 +1436,8 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 {
 	struct nfsd_write_dio_seg segments[3];
 	struct file *file = nf->nf_file;
-	loff_t start = kiocb->ki_pos;
-	bool sync, datasync;
+	loff_t start = kiocb->ki_pos, seg_pos, seg_last;
+	bool sync, datasync, complete_first, complete_last;
 	unsigned int nsegs, i;
 	ssize_t host_err;
 	size_t expected;
@@ -1408,9 +1461,35 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 
 		expected = iov_iter_count(&segments[i].iter);
 
+		/*
+		 * Claim just before the write: an earlier claim gives the
+		 * partner WRITE time to complete the page and drop it first.
+		 */
+		seg_pos = kiocb->ki_pos;
+		seg_last = seg_pos + expected - 1;
+		complete_first = false;
+		complete_last = false;
+		if (segments[i].boundary) {
+			complete_first = nfsd_write_dio_boundary_claim(file,
+								       seg_pos);
+		} else if (segments[i].edges) {
+			/* A page the segment covers entirely is not shared. */
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

