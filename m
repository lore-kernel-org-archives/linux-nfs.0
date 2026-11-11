Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794362177;
	b=q1xs4PEH2gB8JqfgH9RsEN7OE0VqztmeMyqAkTDlkweWCnqmdUSP5Eeb9QU+Q8IJbWyB
	 TCG7UULGvtI6h4jxNqiTpO5/MjY+3X6tcDhWJcCAqTstPeLWekG/kzkR/JceJqQL7ZacU
	 ruyipsaDXN3kxVC6Cl0zmVxLiBPGbMqvESJXjOHsFwKuhHk8A5a370tVMbwaTKQj2J7u/
	 V1iBzbJdyalSTWQwwu3TozUdZcQeYWSw6T5ONn+tc1UHqJQTH3sOwxVeLeEv3+bmSQ2hX
	 QaxGaxtaqpaJqU0YZTUO0vwzcqIpsX4LQwcMFc4/i+TF5LVhhG5JMvRgYZdcpH6nrVg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794362177;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=hd4RGh+Kitd+bKI3dRT1HwwrBybf/ObmgK+7t63TdZ8=;
	b=Q5Hk5ZW4yETHHXRKP6+0LjXG4G1bNaoB3D0rBvlqMu70lhhWAPb3CakWbGoZNPwTKTdk
	 y6J1Q33a6lD6eAbmiPkVR7UCrDs7Hjs3I57hwlpF0Qexi6EU/e5VXNiiQSs/TtlXAkoGH
	 WGHF0ZMrqhRW+msSOh9zwURco+hzKCsnOjsSbukTniAbqey70jC8DecKaSsmlIF9VnqMW
	 6I35Bj1mnAr6tNghRCWMTizNoTMyoAt1SwuYneHQJo89gU6vrV3DU3YMXH68zQIGdES61
	 Z6HtOHM1I+BGGYpNOCs6cp3hknwJoXZ0bEHp2EYMPT2tAxROE/SAry7Chzh71KBwqGQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=EnQ6Rlsb;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 437B3606A337;
	Wed, 11 Nov 2026 01:56:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=EnQ6Rlsb
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9872E1F00A05;
	Wed, 11 Nov 2026 01:56:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794362176;
	bh=hd4RGh+Kitd+bKI3dRT1HwwrBybf/ObmgK+7t63TdZ8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=EnQ6RlsbSRdzDxacWioYu09+SEo5DOgPspa6g+xn0IrH+/5NLcaREuHfT4ip5k2Da
	 TFky5tYZP3XbEhBIiuUWFemU41ld0ANrKKTwgprH5BFAVAuO4ZWyQoAK7FGrAmdV1d
	 MQvTjwd/kpmUC2wpW445KzfUSkWUlaB3hDS4P8dFqHKdm+mA27p0gh6tOypKYYX0WM
	 B3SpZNDcpRI8S/vMgOw83GM+r6eJdubi5vUqvd5tk0Xr5ebggqo8HZ7WnGcF5udrPS
	 qrZZr/OHJOYrU+XCUfEN12rm1is1/yW36pRc+6z9S2uIOb1P2Rh+Nym584B4CEZ5pY
	 UnQpXOiVBYIqg==
From: Mike Snitzer <snitzer@kernel.org>
To: Matthew Wilcox <willy@infradead.org>,
	Jan Kara <jack@suse.cz>,
	linux-mm@kvack.org,
	Christian Brauner <brauner@kernel.org>,
	linux-fsdevel@vger.kernel.org
Cc: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v11 6/7] mm, iomap: let a DONTCACHE writer complete its shared pages itself
Date: Tue, 10 Nov 2026 20:56:06 -0500
Message-ID: <20261111015607.46338-7-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261111015607.46338-1-snitzer@kernel.org>
References: <20261111015607.46338-1-snitzer@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

With the previous commit, the write that completes a shared folio marks
it while it is still dirty.  The folio then counts as DONTCACHE dirty
and wakes the DONTCACHE writeback kick.  Some callers sync once, after
writing several segments.  NFSD does this for a WRITE that the client
sends as FILE_SYNC or DATA_SYNC.  Such a caller wakes the kick once per
segment, for pages that its own sync is about to write.

Add IOCB_DONTCACHE_DEFER (with IOMAP_DONTCACHE_DEFER and
FGP_DONTCACHE_DEFER).  The write leaves the folios it covers only
partially unmarked, and the caller completes them itself.  Called right
before the write, filemap_dontcache_edge_completes() tells the caller
whether the other write that shares the folio already wrote its part.
Called once the write and its sync are done,
filemap_dontcache_edge_complete() waits for writeback in flight.  Then
it marks a dirty folio and kicks writeback, or drops a clean unmapped
folio at once.  A clean mapped folio stays cached, as
filemap_end_dropbehind() leaves a mapped folio.

Two writes that arrive together may both find the folio absent.  The
folio then stays cached until reclaim.

IOCB_DONTCACHE_DEFER enables NFSD, in a later commit, to avoid waking
the DONTCACHE writeback kick.

Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 fs/iomap/buffered-io.c  |  6 +++-
 fs/iomap/trace.h        |  3 +-
 include/linux/fs.h      |  5 ++-
 include/linux/iomap.h   |  1 +
 include/linux/pagemap.h |  6 ++++
 mm/filemap.c            | 73 +++++++++++++++++++++++++++++++++++++++--
 6 files changed, 89 insertions(+), 5 deletions(-)

diff --git a/fs/iomap/buffered-io.c b/fs/iomap/buffered-io.c
index 28431192fb2e3..053fe39dec595 100644
--- a/fs/iomap/buffered-io.c
+++ b/fs/iomap/buffered-io.c
@@ -812,6 +812,8 @@ struct folio *iomap_get_folio(struct iomap_iter *iter, loff_t pos, size_t len)
 		/* Another write may cover the rest of this unit. */
 		if (off || iter->len < unit) {
 			fgp |= FGP_DONTCACHE_EDGE;
+			if (iter->flags & IOMAP_DONTCACHE_DEFER)
+				fgp |= FGP_DONTCACHE_DEFER;
 			len = min_t(size_t, len, unit - off);
 		}
 	}
@@ -823,7 +825,7 @@ struct folio *iomap_get_folio(struct iomap_iter *iter, loff_t pos, size_t len)
 	 * With blocks smaller than the folio, an edge is not uptodate
 	 * until this write completes it.
 	 */
-	if ((fgp & FGP_DONTCACHE_EDGE) &&
+	if ((fgp & FGP_DONTCACHE_EDGE) && !(fgp & FGP_DONTCACHE_DEFER) &&
 	    !IS_ERR(folio) && !folio_test_uptodate(folio) &&
 	    folio_dontcache_edge_written(folio, pos, len))
 		folio_mark_dropbehind(folio);
@@ -1333,6 +1335,8 @@ iomap_file_buffered_write(struct kiocb *iocb, struct iov_iter *i,
 		iter.flags |= IOMAP_NOWAIT;
 	if (iocb->ki_flags & IOCB_DONTCACHE)
 		iter.flags |= IOMAP_DONTCACHE;
+	if (iocb->ki_flags & IOCB_DONTCACHE_DEFER)
+		iter.flags |= IOMAP_DONTCACHE_DEFER;
 
 	while ((ret = iomap_iter(&iter, ops)) > 0)
 		iter.status = iomap_write_iter(&iter, i, write_ops);
diff --git a/fs/iomap/trace.h b/fs/iomap/trace.h
index e1ea8392cf47d..4f0343eeed1b4 100644
--- a/fs/iomap/trace.h
+++ b/fs/iomap/trace.h
@@ -104,7 +104,8 @@ DEFINE_RANGE_EVENT(iomap_zero_iter);
 	{ IOMAP_UNSHARE,	"UNSHARE" }, \
 	{ IOMAP_DAX,		"DAX" }, \
 	{ IOMAP_ATOMIC,		"ATOMIC" }, \
-	{ IOMAP_DONTCACHE,	"DONTCACHE" }
+	{ IOMAP_DONTCACHE,	"DONTCACHE" }, \
+	{ IOMAP_DONTCACHE_DEFER, "DONTCACHE_DEFER" }
 
 #define IOMAP_F_FLAGS_STRINGS \
 	{ IOMAP_F_NEW,		"NEW" }, \
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 99caef43ff3c4..19aaba0bf41f9 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -357,6 +357,8 @@ struct readahead_control;
 /* kiocb is a read or write operation submitted by fs/aio.c. */
 #define IOCB_AIO_RW		(1 << 22)
 #define IOCB_HAS_METADATA	(1 << 23)
+/* With IOCB_DONTCACHE: see filemap_dontcache_edge_complete() */
+#define IOCB_DONTCACHE_DEFER	(1 << 24)
 
 /* for use in trace events */
 #define TRACE_IOCB_STRINGS \
@@ -374,7 +376,8 @@ struct readahead_control;
 	{ IOCB_NOIO,		"NOIO" }, \
 	{ IOCB_ALLOC_CACHE,	"ALLOC_CACHE" }, \
 	{ IOCB_AIO_RW,		"AIO_RW" }, \
-	{ IOCB_HAS_METADATA,	"AIO_HAS_METADATA" }
+	{ IOCB_HAS_METADATA,	"AIO_HAS_METADATA" }, \
+	{ IOCB_DONTCACHE_DEFER,	"DONTCACHE_DEFER" }
 
 struct kiocb {
 	struct file		*ki_filp;
diff --git a/include/linux/iomap.h b/include/linux/iomap.h
index 5254430844b2c..fcef97e64a0bd 100644
--- a/include/linux/iomap.h
+++ b/include/linux/iomap.h
@@ -212,6 +212,7 @@ struct iomap_write_ops {
 #endif /* CONFIG_FS_DAX */
 #define IOMAP_ATOMIC		(1 << 9) /* torn-write protection */
 #define IOMAP_DONTCACHE		(1 << 10)
+#define IOMAP_DONTCACHE_DEFER	(1 << 11) /* see IOCB_DONTCACHE_DEFER */
 
 /*
  * Return the existing mapping at pos, or reserve space starting at pos for up
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 07f7f5190c24c..74ae4914b5820 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -701,6 +701,8 @@ pgoff_t page_cache_prev_miss(struct address_space *mapping,
  * * %FGP_DONTCACHE_EDGE - With %FGP_DONTCACHE: the write covers the folio
  *   only partially.  A new folio is not marked dropbehind, one found
  *   uptodate is.
+ * * %FGP_DONTCACHE_DEFER - With %FGP_DONTCACHE_EDGE: a folio found uptodate is
+ *   not marked either, the caller completes it.
  * * %FGP_WRITEBEGIN - The flags to use in a filesystem write_begin()
  *   implementation.
  */
@@ -716,6 +718,7 @@ typedef unsigned int __bitwise fgf_t;
 #define FGP_STABLE		((__force fgf_t)0x00000080)
 #define FGP_DONTCACHE		((__force fgf_t)0x00000100)
 #define FGP_DONTCACHE_EDGE	((__force fgf_t)0x00000200)
+#define FGP_DONTCACHE_DEFER	((__force fgf_t)0x00000400)
 #define FGF_GET_ORDER(fgf)	(((__force unsigned)fgf) >> 26)	/* top 6 bits */
 
 #define FGP_WRITEBEGIN		(FGP_LOCK | FGP_WRITE | FGP_CREAT | FGP_STABLE)
@@ -1312,6 +1315,9 @@ void folio_end_writeback_no_dropbehind(struct folio *folio);
 void folio_end_dropbehind(struct folio *folio);
 void folio_mark_dropbehind(struct folio *folio);
 bool folio_dontcache_edge_written(struct folio *folio, loff_t pos, size_t len);
+bool filemap_dontcache_edge_completes(struct address_space *mapping,
+				      loff_t pos, size_t len);
+void filemap_dontcache_edge_complete(struct address_space *mapping, loff_t pos);
 void folio_wait_stable(struct folio *folio);
 void __folio_mark_dirty(struct folio *folio, struct address_space *, int warn);
 void folio_account_cleaned(struct folio *folio, struct bdi_writeback *wb);
diff --git a/mm/filemap.c b/mm/filemap.c
index afba94b33dcc6..b8d34abe55671 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1732,6 +1732,75 @@ bool folio_dontcache_edge_written(struct folio *folio, loff_t pos, size_t len)
 }
 EXPORT_SYMBOL_GPL(folio_dontcache_edge_written);
 
+/**
+ * filemap_dontcache_edge_completes - will this write complete a shared folio?
+ * @mapping: the file's mapping
+ * @pos: file offset of the first byte the write covers in the folio
+ * @len: bytes the write covers in the folio
+ *
+ * For an IOCB_DONTCACHE_DEFER write: call right before the write.
+ *
+ * Return: true if the caller must call filemap_dontcache_edge_complete() once
+ * the write, and any sync of it, is done.
+ */
+bool filemap_dontcache_edge_completes(struct address_space *mapping,
+				      loff_t pos, size_t len)
+{
+	struct folio *folio;
+	bool ret;
+
+	/* FGP_DONTCACHE keeps a mark, FGP_LOCK guards the block state. */
+	folio = __filemap_get_folio(mapping, pos >> PAGE_SHIFT,
+				    FGP_LOCK | FGP_DONTCACHE, 0);
+	if (IS_ERR(folio))
+		return false;
+	ret = folio_dontcache_edge_written(folio, pos, len);
+	folio_unlock(folio);
+	folio_put(folio);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(filemap_dontcache_edge_completes);
+
+/**
+ * filemap_dontcache_edge_complete - drop a folio both writes have written
+ * @mapping: the file's mapping
+ * @pos: any byte offset within the folio
+ *
+ * Call once the write, and any sync of it, is done.  A dirty folio is marked
+ * for the writeback that cleans it, and a clean unmapped folio is dropped now.
+ * A clean mapped folio stays cached, as filemap_end_dropbehind() leaves it.
+ */
+void filemap_dontcache_edge_complete(struct address_space *mapping, loff_t pos)
+{
+	struct folio *folio;
+	bool kick = false;
+
+	folio = __filemap_get_folio(mapping, pos >> PAGE_SHIFT,
+				    FGP_LOCK | FGP_DONTCACHE, 0);
+	if (IS_ERR(folio))
+		return;
+	if (!filemap_dontcache_edge_unit(mapping, folio))
+		goto out;
+	/* Writeback in flight was submitted unmarked and would not drop it. */
+	folio_wait_writeback(folio);
+	if (folio_test_dirty(folio)) {
+		folio_mark_dropbehind(folio);
+		kick = true;
+	} else if (!folio_mapped(folio)) {
+		/*
+		 * Drop it now, unmarked: a mark cleared outside the i_pages
+		 * lock could miss a store that counts the folio.
+		 */
+		folio_unmap_invalidate(mapping, folio, 0);
+	}
+out:
+	folio_unlock(folio);
+	folio_put(folio);
+	if (kick)
+		filemap_dontcache_kick_writeback(mapping);
+}
+EXPORT_SYMBOL_GPL(filemap_dontcache_edge_complete);
+
 /**
  * folio_end_writeback_no_dropbehind - End writeback against a folio.
  * @folio: The folio.
@@ -2130,8 +2199,8 @@ struct folio *__filemap_get_folio_mpol(struct address_space *mapping,
 	 * completes it.
 	 */
 	if ((fgp_flags & FGP_DONTCACHE) && (fgp_flags & FGP_DONTCACHE_EDGE) &&
-	    (fgp_flags & FGP_LOCK) && folio_test_uptodate(folio) &&
-	    filemap_dontcache_edge_unit(mapping, folio))
+	    !(fgp_flags & FGP_DONTCACHE_DEFER) && (fgp_flags & FGP_LOCK) &&
+	    folio_test_uptodate(folio) && filemap_dontcache_edge_unit(mapping, folio))
 		folio_mark_dropbehind(folio);
 no_page:
 	if (!folio && (fgp_flags & FGP_CREAT)) {
-- 
2.52.0

