Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794362175;
	b=Dmi07gILBZkAZDP6fXsmMzLyUPwPsWulAS9Sq1iK7TYiAxicUxDjARvwuljYKYEXUvmD
	 pakp4JBaV74LUNES/ED9d1ulsaUwCzlQdcsi3NBaGt9bHT3wGCVAvHLtqGxmzOkoCqn+C
	 fYBQxLdBzCjh5yjB5AKtZuUCxQn4eLBt09p6U8aetWKaxgS2WOQMooOfp5Pu3iaZ6uJWC
	 7NUE6uqTZgwDMAf83oJ4byf6clCkLbn6ZbDEBHSNA+BHMS9m6CO72lkwwfK38gzP+Lr10
	 sIxCTRWh+TVQYJm/e/R3HbdCrepgBe4hThvvfR1SGFMdTl9pnG+MPShc158BNUm7N2g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794362175;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=YXUgD80E6LY7kMauMUCaEczYLx2euvAhpzVNS87w6sI=;
	b=Xa4k9U6XXoUAIk5Fd1hCZpbVd0V+7u5BJg0bOitTIlO+Z8kA4YwL7r2/i/KdYENWTZab
	 DpTiYIH39Vy2d+wpo9c4+Dok10VHP7gVDYI8nuOG11Djpfb4LjR5Je6asWL1oRFGif6+E
	 alOdPTDOCcjSyVuYmZrrbdpoca+5bNbJhA1XNIP3M0uTJENzB4qr38VOegkdD52lk57eQ
	 HVL96EtO75AMhGySOddEWJd7K7py7WRyoGj+kXuBq0v/MDuMlup+Tbfil8MSF91lYQvBY
	 kpngAhglJ2i/p/g3HG/2wbYf2uKs3KdSPvvmhMtZXngGfjZ2M4EWkwv2rKzs+OteVbw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=F90a1CzM;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C0CF0606A330;
	Wed, 11 Nov 2026 01:56:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=F90a1CzM
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 19E1D1F00A07;
	Wed, 11 Nov 2026 01:56:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794362175;
	bh=YXUgD80E6LY7kMauMUCaEczYLx2euvAhpzVNS87w6sI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=F90a1CzMJBN/ZRXEq4FpiozYUX0jnBIYJLLZ0jYwGXlkEIXWPjX5jADnPV6Jr5z7v
	 M1rkg9CS21HWuVOnrSlr0UnlBQKqA6Q0d6Degb3a6YE2OxZjddgPIf3SmvV/PUk+6B
	 yL6c2ThD8Fn28FG1/fK3Rr2pqRAqGzGNHdYiWlrGsNSf7nS8XcaURFraOQm43pcUHN
	 eHpB93h5zqozpGPSdbptg/QfQHTK/C2L5qRRxua6S0E3t/ZW9lEgU7UyX/ZoHHCTl2
	 EOFNL297DphlCN8iFuKrGNUGu/soD/A5LNcz2Zptxbm1cEs+ZxLVlU9P+4PmIaulqc
	 QDXZ1RZgjmlyA==
From: Mike Snitzer <snitzer@kernel.org>
To: Matthew Wilcox <willy@infradead.org>,
	Jan Kara <jack@suse.cz>,
	linux-mm@kvack.org,
	Christian Brauner <brauner@kernel.org>,
	linux-fsdevel@vger.kernel.org
Cc: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v11 5/7] mm, iomap: keep a partially covered page until a DONTCACHE write completes it
Date: Tue, 10 Nov 2026 20:56:05 -0500
Message-ID: <20261111015607.46338-6-snitzer@kernel.org>
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
index a54d0fbd37222..afba94b33dcc6 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1686,6 +1686,52 @@ void folio_mark_dropbehind(struct folio *folio)
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
@@ -2078,6 +2124,15 @@ struct folio *__filemap_get_folio_mpol(struct address_space *mapping,
 
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
@@ -2115,7 +2170,9 @@ struct folio *__filemap_get_folio_mpol(struct address_space *mapping,
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

