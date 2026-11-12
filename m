Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794510562;
	b=MEIP1iN27bCFRPrhjgNkIQHJ+tmvMSxvPMvk/uS3rIZHYU0EdMM7q9+B9FWliOrXh41D
	 YLQt5zHkl88FT8Y2v2cNhfm/d2FuAkU72bid+q2CoGhrewqiApwJ0txJtJKO0l33aWCUQ
	 acNDQ6XkeHfqfVnykkI8GwQ+v+reNj+XGgCDyoG7XXjEmfRqSSNSUAZr9SXKLNAp9G5/D
	 kyH5BXdDOdl56CbqR1q5xoeMr+thIxrMKdp9YO2hh/Z1ShY3YXNLibkFBfzBSZwRc2uVi
	 DNfmrboHxDjJEBfGwpMYd+ggRYP93iqrspnx2FNhGE7GjBGUCY9WjaPzC+AE6e3mbvw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794510562;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=V+/O66vOIJn5ijFaSp7HX/S1Bk099vXk/XA1u/OHn9Q=;
	b=u+gKDc7jcbtCPeCdHhVEP9IaQQuUgAd1hapCYYIloTVeke+B0FAIxRTimFkvF7x3aVTa
	 APApYHRPcG7a+RHY0hEtEajD0OOVjEZfXapOgpa1SfRs2gZis4JYBWB3gCta1waGntlSm
	 X4qUXrx/WFSZnzwGYbUdcHwSiSbUPkmmQr2w5mqVdrsrCmDu4Ri0ek29GSURjGhsWKAG7
	 mVTqEUIpdZxaOO+Up5SNmy/pnevfaZ1OtVRdFa7xAOL6TodA4OJo94bgoMExSo0eJui4l
	 PobjASbkVcBWBRwnOxE/6Lk8V54+0n4P3Hx2/pD2IBopUrBcQdvj4tfvTpDIQ68k5Ew==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=f9F397oP;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BE026606A334;
	Thu, 12 Nov 2026 19:09:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=f9F397oP
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3316B1F0092A;
	Thu, 12 Nov 2026 19:09:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794510562;
	bh=V+/O66vOIJn5ijFaSp7HX/S1Bk099vXk/XA1u/OHn9Q=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=f9F397oPy6N5bUBCrwUsOiN2tdL5sZXloEHMj76LkPva2qf2Tgx10tX7uTMpuc4jx
	 vnVuRDj3/7Vaa7Q3dcKi+NBZrJgXJrdjXIB3dlweBC7mc8hAbAr38DIGL8xDiJP4CD
	 4BTDlcZgavOBUC3+dtZo69v5rdToy6PP72+B1a3rqltdu6mjAY/jScaVRkoJ5PRmIR
	 /wx5Sc4f3jGLQ/Yv1FboB7KFNNJQD7+UKv6lrAbXK0DmRygggKKakaKO4SQa44w6qV
	 RYyhEQZh5hFawK4Lm6ZkR7qsoqPt9ER2yIQgPUT7WhVF/AsDisF5UauX81WmwDRQqN
	 x9oZBXp4oQRUg==
From: Mike Snitzer <snitzer@kernel.org>
To: Matthew Wilcox <willy@infradead.org>,
	Jan Kara <jack@suse.cz>,
	linux-mm@kvack.org,
	Christian Brauner <brauner@kernel.org>,
	linux-fsdevel@vger.kernel.org
Cc: Mike Snitzer <snitzer@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v12 5/7] mm, iomap: keep a partially covered page until a DONTCACHE write completes it
Date: Thu, 12 Nov 2026 14:09:08 -0500
Message-ID: <20261112190911.84702-6-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261112190911.84702-1-snitzer@kernel.org>
References: <20261112190911.84702-1-snitzer@kernel.org>
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

An RWF_DONTCACHE buffered write goes through the page cache like any
buffered write.  It marks every folio it creates dropbehind, so
writeback drops the folio as soon as the data of the write is on disk.
A write that starts or ends inside a folio covers that folio only
partially.  Usually another write covers the rest of the folio.  An
example is the next record of a file written in records that are not a
multiple of the page size.  Writeback can drop the folio before the
other write writes its part.  Then the other write must first read the
folio back from disk: one read per misaligned write.

Add FGP_DONTCACHE_EDGE for the lookup of such a folio.  iomap sets it
when a write starts or ends inside the smallest folio the mapping
allows.  A folio created for an edge is not marked dropbehind.  A folio
found uptodate already holds the data of the other write, so this write
completes it.  Mark it with folio_mark_dropbehind() under the folio
lock, and the writeback that cleans the data of both writes drops it.
With blocks smaller than the folio, the edge is not uptodate yet, so
folio_dontcache_edge_written() also accepts a folio whose blocks outside
this write are uptodate.  A larger folio, such as one from readahead, is
left alone.

The kernel cannot know if another write will come, and this commit does
not assume it.  It reads only the uptodate state of the folio.  An edge
that no other write completes, such as the last page of a file, stays
cached until reclaim.  Writeback drops all other folios of the write, as
before.

With this commit, 32 threads write interleaved 47008-byte records to
one XFS file with RWF_DONTCACHE.  Device reads per write fell from 0.97
to 0.0005, and throughput rose from 831 to 2281 MiB/s.  47008 bytes is
the transfer size of IO500's ior-hard, in which each rank writes
interleaved records to one shared file.  Any record size that is not a
multiple of the page size has the same problem.  With 6000-byte records,
device reads per write fell from 0.97 to 0.0001, and throughput rose
from 121 to 488 MiB/s.

Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 fs/iomap/buffered-io.c  | 26 +++++++++++++++---
 include/linux/pagemap.h |  5 ++++
 mm/filemap.c            | 59 ++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 86 insertions(+), 4 deletions(-)

diff --git a/fs/iomap/buffered-io.c b/fs/iomap/buffered-io.c
index d6e2f1ded5ca6..28431192fb2e3 100644
--- a/fs/iomap/buffered-io.c
+++ b/fs/iomap/buffered-io.c
@@ -798,16 +798,36 @@ EXPORT_SYMBOL_GPL(iomap_is_partially_uptodate);
  */
 struct folio *iomap_get_folio(struct iomap_iter *iter, loff_t pos, size_t len)
 {
+	struct address_space *mapping = iter->inode->i_mapping;
 	fgf_t fgp = FGP_WRITEBEGIN;
+	struct folio *folio;
 
 	if (iter->flags & IOMAP_NOWAIT)
 		fgp |= FGP_NOWAIT;
-	if (iter->flags & IOMAP_DONTCACHE)
+	if (iter->flags & IOMAP_DONTCACHE) {
+		size_t unit = mapping_min_folio_nrbytes(mapping);
+		size_t off = pos & (unit - 1);
+
 		fgp |= FGP_DONTCACHE;
+		/* Another write may cover the rest of this unit. */
+		if (off || iter->len < unit) {
+			fgp |= FGP_DONTCACHE_EDGE;
+			len = min_t(size_t, len, unit - off);
+		}
+	}
 	fgp |= fgf_set_order(len);
 
-	return __filemap_get_folio(iter->inode->i_mapping, pos >> PAGE_SHIFT,
-			fgp, mapping_gfp_mask(iter->inode->i_mapping));
+	folio = __filemap_get_folio(mapping, pos >> PAGE_SHIFT, fgp,
+				    mapping_gfp_mask(mapping));
+	/*
+	 * With blocks smaller than the folio, an edge is not uptodate
+	 * until this write completes it.
+	 */
+	if ((fgp & FGP_DONTCACHE_EDGE) &&
+	    !IS_ERR(folio) && !folio_test_uptodate(folio) &&
+	    folio_dontcache_edge_written(folio, pos, len))
+		folio_mark_dropbehind(folio);
+	return folio;
 }
 EXPORT_SYMBOL_GPL(iomap_get_folio);
 
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 3f5295d6fd73b..07f7f5190c24c 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -698,6 +698,9 @@ pgoff_t page_cache_prev_miss(struct address_space *mapping,
  * * %FGP_NOWAIT - Don't block on the folio lock.
  * * %FGP_STABLE - Wait for the folio to be stable (finished writeback)
  * * %FGP_DONTCACHE - Uncached buffered IO
+ * * %FGP_DONTCACHE_EDGE - With %FGP_DONTCACHE: the write covers the folio
+ *   only partially.  A new folio is not marked dropbehind, one found
+ *   uptodate is.
  * * %FGP_WRITEBEGIN - The flags to use in a filesystem write_begin()
  *   implementation.
  */
@@ -712,6 +715,7 @@ typedef unsigned int __bitwise fgf_t;
 #define FGP_FOR_MMAP		((__force fgf_t)0x00000040)
 #define FGP_STABLE		((__force fgf_t)0x00000080)
 #define FGP_DONTCACHE		((__force fgf_t)0x00000100)
+#define FGP_DONTCACHE_EDGE	((__force fgf_t)0x00000200)
 #define FGF_GET_ORDER(fgf)	(((__force unsigned)fgf) >> 26)	/* top 6 bits */
 
 #define FGP_WRITEBEGIN		(FGP_LOCK | FGP_WRITE | FGP_CREAT | FGP_STABLE)
@@ -1307,6 +1311,7 @@ void folio_end_writeback(struct folio *folio);
 void folio_end_writeback_no_dropbehind(struct folio *folio);
 void folio_end_dropbehind(struct folio *folio);
 void folio_mark_dropbehind(struct folio *folio);
+bool folio_dontcache_edge_written(struct folio *folio, loff_t pos, size_t len);
 void folio_wait_stable(struct folio *folio);
 void __folio_mark_dirty(struct folio *folio, struct address_space *, int warn);
 void folio_account_cleaned(struct folio *folio, struct bdi_writeback *wb);
diff --git a/mm/filemap.c b/mm/filemap.c
index 196c385f29801..6740b860939e7 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1696,6 +1696,52 @@ void folio_mark_dropbehind(struct folio *folio)
 }
 EXPORT_SYMBOL_GPL(folio_mark_dropbehind);
 
+/* The unit two writes share is the smallest folio the mapping allows. */
+static bool filemap_dontcache_edge_unit(struct address_space *mapping,
+					struct folio *folio)
+{
+	return folio_nr_pages(folio) == mapping_min_folio_nrpages(mapping);
+}
+
+/**
+ * folio_dontcache_edge_written - has another write written the rest?
+ * @folio: locked edge folio
+ * @pos: file offset of the first byte this write covers in @folio
+ * @len: bytes this write covers in @folio
+ *
+ * Return: true if @folio is an edge unit that is uptodate, or whose blocks
+ * that this write does not cover in full are uptodate.
+ */
+bool folio_dontcache_edge_written(struct folio *folio, loff_t pos, size_t len)
+{
+	struct address_space *mapping = folio->mapping;
+	size_t size = folio_size(folio);
+	size_t from, to, bs;
+
+	VM_WARN_ON_ONCE_FOLIO(!folio_test_locked(folio), folio);
+
+	if (!mapping || !filemap_dontcache_edge_unit(mapping, folio))
+		return false;
+	if (folio_test_uptodate(folio))
+		return true;
+	if (!mapping->a_ops->is_partially_uptodate)
+		return false;
+
+	/* The blocks this write covers in full are [from, to). */
+	bs = i_blocksize(mapping->host);
+	from = offset_in_folio(folio, pos);
+	to = min(from + len, size);
+	from = round_up(from, bs);
+	to = round_down(to, bs);
+	if (from && !mapping->a_ops->is_partially_uptodate(folio, 0, from))
+		return false;
+	if (to < size &&
+	    !mapping->a_ops->is_partially_uptodate(folio, to, size - to))
+		return false;
+	return true;
+}
+EXPORT_SYMBOL_GPL(folio_dontcache_edge_written);
+
 /**
  * folio_end_writeback_no_dropbehind - End writeback against a folio.
  * @folio: The folio.
@@ -2088,6 +2134,15 @@ struct folio *__filemap_get_folio_mpol(struct address_space *mapping,
 
 	if (fgp_flags & FGP_STABLE)
 		folio_wait_stable(folio);
+
+	/*
+	 * An uptodate edge holds the part of the other write, so this write
+	 * completes it.
+	 */
+	if ((fgp_flags & FGP_DONTCACHE) && (fgp_flags & FGP_DONTCACHE_EDGE) &&
+	    (fgp_flags & FGP_LOCK) && folio_test_uptodate(folio) &&
+	    filemap_dontcache_edge_unit(mapping, folio))
+		folio_mark_dropbehind(folio);
 no_page:
 	if (!folio && (fgp_flags & FGP_CREAT)) {
 		unsigned int min_order = mapping_min_folio_order(mapping);
@@ -2125,7 +2180,9 @@ struct folio *__filemap_get_folio_mpol(struct address_space *mapping,
 			/* Init accessed so avoid atomic mark_page_accessed later */
 			if (fgp_flags & FGP_ACCESSED)
 				__folio_set_referenced(folio);
-			if (fgp_flags & FGP_DONTCACHE)
+			/* A new edge waits for the write that completes it. */
+			if ((fgp_flags & FGP_DONTCACHE) &&
+			    !(fgp_flags & FGP_DONTCACHE_EDGE))
 				__folio_set_dropbehind(folio);
 
 			err = filemap_add_folio(mapping, folio, index, gfp);
-- 
2.52.0

