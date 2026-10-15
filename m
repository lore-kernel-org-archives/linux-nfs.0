Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 228CB3EA947
	for <linux-nfs@vger.kernel.org>; Thu, 15 Oct 2026 23:33:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792107203; cv=none; b=jaeQClQKEZeSV70uMoj04DH9T/2x8U8nt/pudXLrCeL+W4w0Pk47Dvyl1N2QnbVUB3xFWLMwMKQME49sDYGlIMevdgAuFDIQNMc2BtSuYou847/0MY5NdXXfvGCayTQFjj6WHEyr9SvVqjqW0LPURHTHtfN2HnOyRFRsW8UekVU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792107203; c=relaxed/simple;
	bh=U2GwAZ6AwTMZl5iSSEJP20q2Nu5fZuh11PV+ZMo/Dh4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=I9zXZOYEzHGXt7aqqTlCkGRlmKAkaKYXNyI+75cXMuiCIvwzPl25Nl/qtLWzFDj0ZtffuvUSTwrW98OxKJGwxfc7DEXh7ioXg4I9Ti0Y8GyeOb/RWpYV4GBIidT49C/tanfJNnU1A7QiaPdlqqTMzq93XxsZyMU0k6qTwbphljc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Z2je8z7s; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Z2je8z7s"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id ACDDA1F000C5;
	Thu, 15 Oct 2026 23:33:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792107201;
	bh=YfyeEUHyd4kLq4coIZb9OAJrpttuLdkMMmABH9f9qoE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Z2je8z7sZRJOfND9pNEt4Ixs0vkz+ZIakcVeu9pcTjzD7LosnZd/EJrH5SJAtcDuT
	 M7lhsFzWwCaC5PQdWGAVDWZY12Ndvue6Yns1caHQpo2Jqqrcus1f2OA9MMhaVFYW5n
	 n7TZ1TNU1kdjHkD8oxveN34wMu4qVa9+Ri2kZG04QOIi1Hcm6uZZOs/9Oq4tbhHs4t
	 gQSuF/LvcNI9B454U8rZaR3cuarMvG2olI8f/S0lcQx79StLxHxyJmrD7vDzdW4IBY
	 oINvFscaODB+ViqtIPObHT0zqm5blkJ3V6V6y5LZCXaabBNhaLOnItvhHg6Mvzt8t+
	 i/cyp7dfPguvQ==
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
Subject: [PATCH v4 09/10] NFSD: keep boundary page of a split direct-mode WRITE until both writers complete
Date: Thu, 15 Oct 2026 19:33:08 -0400
Message-ID: <20261015233309.42999-10-snitzer@kernel.org>
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
Immediately before a buffered DONTCACHE segment is written,
nfsd_write_dio_boundary_claim() puts an empty folio in the page cache
at each end of the segment that covers its page only partly, if there
is not one there already.  The folio is inserted unmarked: a DONTCACHE
write marks only a folio it allocates itself, so neither writer marks
this one and no writeback completion drops it.

The add is atomic, so of two concurrent partners exactly one gets the
folio.  The other finds it (-EEXIST), is therefore the second of the
two, and once its data is in the page nfsd_write_dio_boundary_complete()
marks the folio with folio_mark_dropbehind().  The mark must follow
the write: set while the first writer's data is still dirty or under
writeback, it would have that writeback drop the folio before the
second writer's data is in it.

A WRITE marks its shared pages only once it is complete.  A FILE_SYNC or
DATA_SYNC WRITE marks them after its own fsync, when they are clean, and
nfsd_write_dio_boundary_complete() drops them at once.  Marking them
while still dirty would count them in WB_DONTCACHE_DIRTY and wake the
DONTCACHE writeback kick, only to write back what the fsync is about to
write.  An UNSTABLE WRITE marks them dirty, and the writeback that
cleans them, by the flusher or for the client's COMMIT, drops them.

A WRITE that is not split is issued as one buffered DONTCACHE segment,
and its partly covered first and last pages are claimed the same way.
A WRITE smaller than a page has one page, which may be shared with both
neighbours; it is kept until the second of them has written it.

The state lives in the page cache.  A claimed page whose partner never
arrives, such as the last page of the file, or that is removed before
the partner arrives, by truncate, reclaim or another client's direct
WRITE, is never marked and stays cached until it is reclaimed.  The
direct middle invalidates the page cache over its range, but a split
WRITE's misaligned ends are cut on page boundaries, so the middle never
reaches a claimed page.  Nothing is claimed when the buffered segments
are normal buffered I/O (direct_misaligned_dontcache is N, or the file
system lacks FOP_DONTCACHE), or when the mapping's minimum folio size is
larger than a page.

Measured with 32 interleaved writers over an emulated 4Kn NVMe with 4
KiB pages, direct_misaligned_dontcache=Y and every WRITE persisted as
FILE_SYNC before its reply, each arm starting from a freshly made file
system.  47008-byte records, which split: 704 device reads for 42895
WRITEs, against 45144 for 45664 WRITEs without this patch.  6000-byte
records, which are not split: 385 reads against 196589.  81 of the
written file's 524066 pages are still resident afterwards.  With
47008-byte records the DONTCACHE writeback kick ran 692 times in 15 s
with the pages marked after the fsync, against 24800 times when they
were marked as soon as they were written.

On a four-server pNFS flexfiles rig (x86_64, 4 KiB logical blocks),
three clients writing 47008-byte records for 240 s against 640 nfsd
threads per server: device reads fall from 0.014-0.015 per record to
0.003, page-cache growth over the write phase falls from about 11 GiB to
2.9 GiB, and write throughput rises by 2.4% to 4.9% whether the WRITEs
are answered UNSTABLE, DATA_SYNC or FILE_SYNC, with read throughput
unchanged.  Keeping every boundary page cached instead, with
direct_misaligned_dontcache=N, grows the page cache by about 630 GiB
over the same runs.

Reported-by: Jonathan Flynn <jonathan.flynn@hammerspace.com>
Assisted-by: LLM
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 .../filesystems/nfs/nfsd-io-modes.rst         |  15 ++
 fs/nfsd/vfs.c                                 | 141 ++++++++++++++++--
 2 files changed, 145 insertions(+), 11 deletions(-)

diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentation/filesystems/nfs/nfsd-io-modes.rst
index c1cc974640cfe..278c0487b5bb2 100644
--- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
+++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
@@ -164,6 +164,21 @@ Misaligned WRITE:
     not split, as normal buffered IO instead of DONTCACHE, which suits a
     workload that reads back or rewrites what it just wrote.
 
+    The page holding a start or end segment is shared with the
+    neighbouring WRITE, which may arrive before, after or at the same
+    time, from any client. So that the second WRITE to such a page does
+    not have to read it back from disk, NFSD puts an empty page there
+    immediately before writing a start or end segment, if there is not
+    one already, without marking it DONTCACHE. The WRITE that finds the
+    page already there marks it DONTCACHE once it has written it, and
+    the writeback that then cleans it drops it. A page whose neighbouring
+    WRITE never arrives stays cached until it is reclaimed. The first and
+    last pages of a WRITE that is not split are handled the same way.
+
+    None of this applies when the start and end segments are normal
+    buffered IO, or when the filesystem's block size is larger than the
+    page size.
+
 Tracing:
     The nfsd_read_direct trace event shows how NFSD expands any
     misaligned READ to the next DIO-aligned block (on either end of the
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 249358256d2f5..d899d00714b1a 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -26,6 +26,7 @@
 #include <linux/xattr.h>
 #include <linux/jhash.h>
 #include <linux/pagemap.h>
+#include <linux/backing-dev.h>
 #include <linux/slab.h>
 #include <linux/uaccess.h>
 #include <linux/exportfs.h>
@@ -1300,6 +1301,7 @@ static int wait_for_concurrent_writes(struct file *file)
 struct nfsd_write_dio_seg {
 	struct iov_iter			iter;
 	int				flags;
+	bool				claim;		/* keep shared pages */
 };
 
 static unsigned long
@@ -1319,6 +1321,110 @@ nfsd_write_dio_seg_init(struct nfsd_write_dio_seg *segment,
 		iov_iter_advance(&segment->iter, start);
 	iov_iter_truncate(&segment->iter, len);
 	segment->flags = iocb->ki_flags;
+	segment->claim = false;
+}
+
+/*
+ * A page that a buffered segment covers only partly is shared with the
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
+	/* A folio larger than a page holds more than the shared page. */
+	if (mapping_min_folio_order(mapping))
+		return false;
+	if (mapping_can_writeback(mapping))
+		gfp |= __GFP_WRITE;
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
+ * Both WRITEs have written the page: mark it so that the writeback that
+ * cleans it drops it.
+ */
+static void
+nfsd_write_dio_boundary_complete(struct file *file, loff_t pos)
+{
+	struct folio *folio;
+
+	folio = __filemap_get_folio(file->f_mapping, pos >> PAGE_SHIFT,
+				    FGP_LOCK | FGP_DONTCACHE, 0);
+	if (IS_ERR(folio))
+		return;
+	folio_mark_dropbehind(folio);
+	folio_unlock(folio);
+	/* Already written back: drop it now, as its writeback would have. */
+	folio_end_dropbehind(folio);
+	folio_put(folio);
+}
+
+/* The shared pages a segment claimed, and how much of it was written. */
+struct nfsd_write_dio_hold {
+	loff_t	first, last;
+	bool	complete_first, complete_last;
+	size_t	written;
+};
+
+/*
+ * Claim the pages @seg shares with the neighbouring WRITEs, immediately
+ * before writing it: an earlier claim gives the partner WRITE time to
+ * complete the page and have it dropped first.
+ */
+static void
+nfsd_write_dio_seg_hold(struct file *file, const struct nfsd_write_dio_seg *seg,
+			loff_t pos, size_t len, struct nfsd_write_dio_hold *hold)
+{
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
+				nfsd_write_dio_boundary_claim(file, hold->first);
+		if (!one_page && tail)
+			hold->complete_last =
+				nfsd_write_dio_boundary_claim(file, hold->last);
+	}
+}
+
+/* Mark the shared pages this WRITE was the second of two to write. */
+static void
+nfsd_write_dio_seg_release(struct file *file,
+			   const struct nfsd_write_dio_hold *hold)
+{
+	if (hold->complete_first && hold->written)
+		nfsd_write_dio_boundary_complete(file, hold->first);
+	/* A short write did not reach the last page. */
+	if (hold->complete_last &&
+	    hold->written == hold->last - hold->first + 1)
+		nfsd_write_dio_boundary_complete(file, hold->last);
 }
 
 static unsigned int
@@ -1378,7 +1484,8 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	if (prefix) {
 		nfsd_write_dio_seg_init(&segments[nsegs], bvec,
 					nvecs, total, 0, prefix, iocb);
-		segments[nsegs++].flags |= buffered_flags;
+		segments[nsegs].flags |= buffered_flags;
+		segments[nsegs++].claim = !!buffered_flags;
 	}
 
 	nfsd_write_dio_seg_init(&segments[nsegs], bvec, nvecs,
@@ -1402,7 +1509,8 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	if (suffix) {
 		nfsd_write_dio_seg_init(&segments[nsegs], bvec, nvecs, total,
 					prefix + middle, suffix, iocb);
-		segments[nsegs++].flags |= buffered_flags;
+		segments[nsegs].flags |= buffered_flags;
+		segments[nsegs++].claim = !!buffered_flags;
 	}
 
 	return nsegs;
@@ -1416,6 +1524,7 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	nfsd_write_dio_seg_init(&segments[0], bvec, nvecs, total, 0,
 				total, iocb);
 	segments[0].flags |= buffered_flags;
+	segments[0].claim = !!buffered_flags;
 	return 1;
 }
 
@@ -1424,12 +1533,13 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
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
 
 	nsegs = nfsd_write_dio_iters_init(nf, rqstp->rq_bvec, nvecs,
@@ -1455,23 +1565,32 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
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

