Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A1DA357ED9D;
	Tue,  8 Sep 2026 16:32:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788885157; cv=none; b=A+++p75Sbneoj+h8tf8ihbtBAHSTNQkYDruyxAcHGr1Dmch6uqFYxN+4rVxCw6BbAKWtN1zckhdW3i/HBdkgRlRwRF2H24MxN/uOFKl3cbO0p3zONNXg9q175AQAkqzDF0nSJkascVidIrJ4pzfK7XzCsroEK/NDmxMajUkTVY8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788885157; c=relaxed/simple;
	bh=XX6rU9AXcLahomsQVLdjJ+9Cqt0a2cXjYI+5BXbnZ00=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=HJ6P7sW/RDBbLFjJbrCdbwsceRV5bRz/uMcT+qgpI5qFMUjQ6OMdG7aEoNEYaWDehk0gJc46UTgTWZDwGbdkRZ4dI59PYM4JJAITg9gB7NyiB5KdnpmKN9I70hpw1hCXc2SC3tQWk2OXgXa3+GdwOqo1zNK3xOFAIcYc8RRx2iQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ZbsXqkJ7; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ZbsXqkJ7"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E01791F00A3D;
	Tue,  8 Sep 2026 16:32:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788885155;
	bh=efnCfQHpikgWrQThhbZWuGy0HSmCAahwMimpqUFqCT8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=ZbsXqkJ7dOyymZqMxKwKG7ZVMWvZY41kvsKalFgL7jJlbIzhzX+yNsopyZUISjhQO
	 EMiSzThsXgcchXxmuIXs6nuT2hXuukFFmV0rIrXzK07fVaphlaI2im+kyTUmMFmd8I
	 b8rZrTgXl3Li6ALIUw0CiBiULYRZEoE2p/uYi54PCTJCLQipygLhhbEgkCsPpI8Fcb
	 ZminQAmpI2D6WSP9Q44h2XmUTk5KZUAg+RnD5kfueX7uCnxgCaM9rqgW9yTk3e/Nmv
	 rjYxvB7R4VG8cF2twIoMxm7VPdNFGwmppNHfQa/xT9LtRSOXeSTnQytO06VxKYksN/
	 BYFkpRc7DJHCA==
From: Mike Snitzer <snitzer@kernel.org>
To: linux-nfs@vger.kernel.org,
	linux-block@vger.kernel.org
Cc: dm-devel@lists.linux.dev,
	axboe@kernel.dk,
	cel@kernel.org,
	jlayton@kernel.org,
	david.flynn@hammerspace.com
Subject: [PATCH 1/4] brd: iterate the bio by byte position, not bi_sector
Date: Tue,  8 Sep 2026 12:32:19 -0400
Message-ID: <20260908163232.30774-2-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20260908163232.30774-1-snitzer@kernel.org>
References: <20260908163232.30774-1-snitzer@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

brd_rw_bvec() takes the device position from bio->bi_iter.bi_sector,
which bio_advance_iter_single() advances by bytes >> SECTOR_SHIFT. For
a bvec whose length is not a multiple of the sector size the sector
cursor silently loses the sub-sector residue while the data cursor
(bi_bvec_done/bi_size) consumes the full length -- from that segment
on, data is written at a device offset short of where it belongs, and
every subsequent byte lands shifted with no error reported anywhere.

Such bvec geometry is legal at the submitter: ITER_BVEC direct I/O
passes the caller's bio_vec array through as-is (bio_iov_bvec_set()),
so e.g. NFSD's NFSD_IO_DIRECT write path hands XFS/iomap a payload
whose first fragment starts mid-page (the RPC header precedes it in
the receive buffer) and whose fragment lengths are not sector
multiples. A 1 MiB write arriving as bv0=(160,16224) + 63x(0,16384) +
(0,160) reproduces on brd as: first 15872 = ALIGN_DOWN(16224, 512)
bytes correct, everything after shifted forward by 352 = 16224 - 15872
bytes -- while the write completes successfully. Any NFSD_IO_DIRECT
(or other kernel bvec direct I/O) write to a brd-backed filesystem is
exposed; request-based drivers are unaffected because nothing in the
request path does per-bvec sector arithmetic.

Track the device position as a byte offset owned by the submit loop
and advanced by the number of bytes each segment actually processed,
instead of re-deriving it from the skewed bi_sector. Verified with a
synthetic-bio reproducer over brd directly and through nvme-loop:
mid-page-offset geometries and the page-aligned control now all read
back byte-identical, and 20 fresh NFS connections x 16 MiB of O_DIRECT
writes over an XFS-on-nvme-loop-on-brd export complete with zero data
mismatches (previously most connections corrupted).

Fixes: 3185444f0504 ("brd: split I/O at page boundaries")
Assisted-by: Claude:claude-fable-5
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 drivers/block/brd.c | 29 +++++++++++++++++++++++------
 1 file changed, 23 insertions(+), 6 deletions(-)

diff --git a/drivers/block/brd.c b/drivers/block/brd.c
index 00cc8122068f..4011538cecaf 100644
--- a/drivers/block/brd.c
+++ b/drivers/block/brd.c
@@ -134,12 +134,24 @@ static void brd_free_pages(struct brd_device *brd)
 /*
  * Process a single segment.  The segment is capped to not cross page boundaries
  * in both the bio and the brd backing memory.
+ *
+ * The device position is @pos, a byte offset maintained by the caller --
+ * not bio->bi_iter.bi_sector: bio_advance_iter_single() advances bi_sector
+ * by bytes >> SECTOR_SHIFT, so a bvec whose length is not a multiple of the
+ * sector size silently skews bi_sector against the bytes actually consumed
+ * and corrupts everything that follows.  Byte-granular bvec boundaries
+ * reach us from ITER_BVEC direct I/O submitters whose caller's bio_vec
+ * array is passed through as-is (bio_iov_bvec_set()).
+ *
+ * Returns the number of bytes processed, or 0 on error (the bio has then
+ * been completed).
  */
-static bool brd_rw_bvec(struct brd_device *brd, struct bio *bio)
+static unsigned int brd_rw_bvec(struct brd_device *brd, struct bio *bio,
+				loff_t pos)
 {
 	struct bio_vec bv = bio_iter_iovec(bio, bio->bi_iter);
-	sector_t sector = bio->bi_iter.bi_sector;
-	u32 offset = (sector & (PAGE_SECTORS - 1)) << SECTOR_SHIFT;
+	sector_t sector = pos >> SECTOR_SHIFT;
+	u32 offset = pos & (PAGE_SIZE - 1);
 	blk_opf_t opf = bio->bi_opf;
 	struct page *page;
 	void *kaddr;
@@ -167,14 +179,14 @@ static bool brd_rw_bvec(struct brd_device *brd, struct bio *bio)
 	bio_advance_iter_single(bio, &bio->bi_iter, bv.bv_len);
 	if (page)
 		put_page(page);
-	return true;
+	return bv.bv_len;
 
 out_error:
 	if (PTR_ERR(page) == -ENOMEM && (opf & REQ_NOWAIT))
 		bio_wouldblock_error(bio);
 	else
 		bio_io_error(bio);
-	return false;
+	return 0;
 }
 
 static void brd_do_discard(struct brd_device *brd, sector_t sector, u32 size)
@@ -202,6 +214,7 @@ static void brd_do_discard(struct brd_device *brd, sector_t sector, u32 size)
 static void brd_submit_bio(struct bio *bio)
 {
 	struct brd_device *brd = bio->bi_bdev->bd_disk->private_data;
+	loff_t pos;
 
 	if (unlikely(op_is_discard(bio->bi_opf))) {
 		brd_do_discard(brd, bio->bi_iter.bi_sector,
@@ -210,9 +223,13 @@ static void brd_submit_bio(struct bio *bio)
 		return;
 	}
 
+	pos = (loff_t)bio->bi_iter.bi_sector << SECTOR_SHIFT;
 	do {
-		if (!brd_rw_bvec(brd, bio))
+		unsigned int len = brd_rw_bvec(brd, bio, pos);
+
+		if (!len)
 			return;
+		pos += len;
 	} while (bio->bi_iter.bi_size);
 
 	bio_endio(bio);
-- 
2.52.0

