Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 18E335867FB;
	Tue,  8 Sep 2026 16:35:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788885303; cv=none; b=TWCLuk8mIEZqzlBYxqCZiOAoQDEyc/ixydASo2+PcWiDTNQ8a0hZdNAJgNUGbkXPj3SfvLD91aJpBLJfjCSvOaQqODnNUAoYxg4UeOOPspRRnZwyHiCj0o5+ekS00/8AiVY1/97zhGtHUinA6bcK32IdbR2NBrWgfUBhNt0ncLg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788885303; c=relaxed/simple;
	bh=3VKlBFe+x8WGFZmVDefMmcUeOHpmqZfAKP6qTmYA9w0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=qqp6GfrHZtQdyLNT4JNnRS/9LPAGqi49ShhP6REGoOTWwsr3Vh2ycmY0DgS4Pt1fWvSY6JBwdnAxPS9M0Gieb7O9yDODYw3lNdpYIVsQlH+pP5RF+BT6DWM7eTikbBD5KIjovkdXKnrDssaQmxY+OEzgOLjZ+tGIzNVClZ0vIEI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=mPaHszmh; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="mPaHszmh"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 727F81F00A3A;
	Tue,  8 Sep 2026 16:35:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788885301;
	bh=AgO/ir7uwrG0++/T5HeOPy6QXU+5Ubmmn+fOgIVMqVk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=mPaHszmhpym88Dg85t7HCoDoEuhe0b0h13SjgKYa243+bOo6NoyHM1HUeja1dr9KX
	 6nd6UuMU4b4r3VTwX21lOixDrNUWCleblEtDjP9wmupDUG8/awWMGdoqFk3wNgR0Ay
	 m55pI47cKJ4zxfUzOyJVnqMZPHUOhowzgv1j0N+RxYh8xJTudO5o6xOJ4mR1CIp7yF
	 TdzKJtgk8scpZcUOHfA7i/Wo0gyGdW3tjBapowN3HF4FuaMr1I/QH6KaanipjmKyX+
	 3lE6TZYfeJb7vzi1FMQdd5KuKaWeDKWG52TFOSe9A9y8e44c18+NRcux+FbC/bDtB2
	 X5WBHwQ7HfDkg==
From: Mike Snitzer <snitzer@kernel.org>
To: linux-nfs@vger.kernel.org,
	linux-block@vger.kernel.org
Cc: dm-devel@lists.linux.dev,
	axboe@kernel.dk,
	cel@kernel.org,
	jlayton@kernel.org,
	david.flynn@hammerspace.com
Subject: [PATCH 2/4] zram: handle sub-page bvec segments without corrupting data
Date: Tue,  8 Sep 2026 12:34:45 -0400
Message-ID: <20260908163448.30841-11-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20260908163448.30841-1-snitzer@kernel.org>
References: <20260908163232.30774-1-snitzer@kernel.org>
 <20260908163448.30841-1-snitzer@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

zram's submit loops have two independent defects for a bvec whose
length is not PAGE_SIZE, and on a 4K-page kernel they compound into
silent full-page corruption for any ITER_BVEC direct I/O submitter
whose bio_vec array carries sub-page segments (bio_iov_bvec_set()
passes the caller's array through as-is).

First, on PAGE_SIZE == 4096 is_partial_io() is hardwired to false, on
the reasoning that logical_block_size == PAGE_SIZE guarantees
whole-page bvecs. It guarantees no such thing: queue limits constrain
a bio's starting sector and total size, not individual bvec lengths.
Every sub-page segment then takes the full-page fast path --
zram_write_page(zram, bvec->bv_page, index) consumes the entire page
and ignores bv_offset/bv_len completely -- so consecutive segments
that map to the same page index each rewrite the whole slot, and a
1 MiB write arriving as bv0=(684,3412) + 255x(0,4096) + (0,684) reads
back with every byte wrong while the write reports success. The read
side is equally exposed: zram_read_page() lands a full page in
bvec->bv_page, clobbering reader memory outside the bvec. Make
is_partial_io() honest on every page size; the partial-IO helpers it
routes to already exist and honor bv_offset/bv_len.

Second, the loops re-derive each segment's target page index and
in-page offset from iter.bi_sector, which bio_advance_iter_single()
advances by bytes >> SECTOR_SHIFT -- a sub-sector residue in any
segment length skews every subsequent segment's position while the
data cursor consumes the full length (the same defect just fixed in
brd). With partial detection made honest this would still misplace
data through the read-modify-write path. Track the device position as
a byte offset owned by the submit loop and advanced by the bytes each
segment actually processed.

Verified with a synthetic-bio reproducer: mid-page-offset geometries
(684, 160, 512) and the page-aligned control now all read back
byte-identical on a 4K-page kernel; before the fix the unaligned
geometries corrupted all 1 MiB silently.

With partial IO possible on every page size, the ZRAM_PARTIAL_IO
guard in read_from_bdev() is dead code -- drop it along with the
define.

Fixes: 1f7319c74275 ("zram: partial IO refactoring")
Fixes: 82ca875d2549 ("zram: refactor highlevel read and write handling")
Assisted-by: Claude:claude-fable-5
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 drivers/block/zram/zram_drv.c | 36 +++++++++++++++++------------------
 1 file changed, 18 insertions(+), 18 deletions(-)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 789c76dc8613..6c5ba814ba5b 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -217,18 +217,19 @@ static bool zram_can_store_page(struct zram *zram)
 	return !zram->limit_pages || alloced_pages <= zram->limit_pages;
 }
 
-#if PAGE_SIZE != 4096
+/*
+ * A whole-page bvec is required for the full-page fast paths, which
+ * consume bv_page outright and ignore bv_offset/bv_len.  The queue's
+ * logical_block_size == PAGE_SIZE only constrains a bio's starting
+ * sector and total size -- individual bvec lengths are not constrained
+ * by any queue limit, and ITER_BVEC direct I/O submitters pass the
+ * caller's bio_vec array through as-is (bio_iov_bvec_set()), so
+ * sub-page segments reach us on every PAGE_SIZE.
+ */
 static inline bool is_partial_io(struct bio_vec *bvec)
 {
 	return bvec->bv_len != PAGE_SIZE;
 }
-#define ZRAM_PARTIAL_IO		1
-#else
-static inline bool is_partial_io(struct bio_vec *bvec)
-{
-	return false;
-}
-#endif
 
 #if defined CONFIG_ZRAM_WRITEBACK || defined CONFIG_ZRAM_MULTI_COMP
 struct zram_pp_slot {
@@ -1510,11 +1511,8 @@ static int read_from_bdev(struct zram *zram, struct page *page,
 			  struct bio *parent)
 {
 	atomic64_inc(&zram->stats.bd_reads);
-	if (!parent) {
-		if (WARN_ON_ONCE(!IS_ENABLED(ZRAM_PARTIAL_IO)))
-			return -EIO;
+	if (!parent)
 		return read_from_bdev_sync(zram, page, index, blk_idx);
-	}
 	return read_from_bdev_async(zram, page, index, blk_idx, parent);
 }
 #else
@@ -2718,11 +2716,11 @@ static void zram_bio_read(struct zram *zram, struct bio *bio)
 {
 	unsigned long start_time = bio_start_io_acct(bio);
 	struct bvec_iter iter = bio->bi_iter;
+	loff_t pos = (loff_t)iter.bi_sector << SECTOR_SHIFT;
 
 	do {
-		unsigned long index = iter.bi_sector >> SECTORS_PER_PAGE_SHIFT;
-		u32 offset = (iter.bi_sector & (SECTORS_PER_PAGE - 1)) <<
-				SECTOR_SHIFT;
+		unsigned long index = pos >> PAGE_SHIFT;
+		u32 offset = pos & (PAGE_SIZE - 1);
 		struct bio_vec bv = bio_iter_iovec(bio, iter);
 
 		bv.bv_len = min_t(u32, bv.bv_len, PAGE_SIZE - offset);
@@ -2738,6 +2736,7 @@ static void zram_bio_read(struct zram *zram, struct bio *bio)
 		mark_slot_accessed(zram, index);
 		slot_unlock(zram, index);
 
+		pos += bv.bv_len;
 		bio_advance_iter_single(bio, &iter, bv.bv_len);
 	} while (iter.bi_size);
 
@@ -2749,11 +2748,11 @@ static void zram_bio_write(struct zram *zram, struct bio *bio)
 {
 	unsigned long start_time = bio_start_io_acct(bio);
 	struct bvec_iter iter = bio->bi_iter;
+	loff_t pos = (loff_t)iter.bi_sector << SECTOR_SHIFT;
 
 	do {
-		unsigned long index = iter.bi_sector >> SECTORS_PER_PAGE_SHIFT;
-		u32 offset = (iter.bi_sector & (SECTORS_PER_PAGE - 1)) <<
-				SECTOR_SHIFT;
+		unsigned long index = pos >> PAGE_SHIFT;
+		u32 offset = pos & (PAGE_SIZE - 1);
 		struct bio_vec bv = bio_iter_iovec(bio, iter);
 
 		bv.bv_len = min_t(u32, bv.bv_len, PAGE_SIZE - offset);
@@ -2768,6 +2767,7 @@ static void zram_bio_write(struct zram *zram, struct bio *bio)
 		mark_slot_accessed(zram, index);
 		slot_unlock(zram, index);
 
+		pos += bv.bv_len;
 		bio_advance_iter_single(bio, &iter, bv.bv_len);
 	} while (iter.bi_size);
 
-- 
2.52.0

