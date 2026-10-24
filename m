Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792879919;
	b=qqEQYflGAt/SeL0Ne/VJpYWOqyWsofoUTvKdiiR6Y9hwPQGXofC9bSzuCzgqC49VPzds
	 euQ9Ly5kKmVi0oGLQpWjj1s0uWcUh/GCuqfa2aM91KJs9HSKmTlkT9wVsw9KaqXmXAuAE
	 nSw1/XTpVUAoIWN7ZhucY/bcRpUjFwxkBn+dbdo/rJG+89AEmgDt6eXx7bhU4x0jNXf/d
	 Ar3sNJaGT0z2g/Crw5SjMJAnfyRA3M/TIfthHwG1WttBFV1RafXJy54xzWiNURkKHbRjQ
	 bmauDubXeS5nxm/HlDAuKBtC2JcF0QzwA4CF5z4qcUW76dmCvcFn2pBYzppSMwh35nw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792879919;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=jSAZlkK8u8bIT9ohYzbadLzKlW+54JyBofI826wUuVo=;
	b=aNR0Z+uHnP2PgCLp5xXA5kVeZNCLNzPmkpIa55xk3dnz8xLzcRnjmSZIN9UCL9ZjukQh
	 3gf6SuaxPJgd4D7WdZbkKvNduWb8yzMuc+mi9IsxE3K8XF4dBgR1Uhu40OQWfHybTGoRc
	 HdGUtuWzShmEryibNPuvhzrxfiM+2xldjXnkn7XkPs7Lr2m8YvkKEOIe/DNfKtHJcoKzR
	 KHSCbBVprhvFyQG7kjWoa4JO9fH0wCArmWEFrc39ojvAUMb0Kak4h7iWHKWHZNYe2IPq9
	 1ZypcdqFCtWsEtZ9/KFVyXxeVUYErkhMAWbuS8qtR9KuA/3Cj6Bx81HOzzy2xpkGqxg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=I7hDkjD1;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A239D606A333;
	Sat, 24 Oct 2026 22:11:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=I7hDkjD1
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F253A1F01825;
	Sat, 24 Oct 2026 22:11:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792879918;
	bh=jSAZlkK8u8bIT9ohYzbadLzKlW+54JyBofI826wUuVo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=I7hDkjD17iue31q93CXnuxpczfRgw5InRcI8O6jtyhH/fs4HqpOSsUekawAOpO3cp
	 pQi9jrt8/eA3qaJ8xQDpOA0ypqe70W2WzrNnFJmAa3L/maOTM4XE8CCZ1Mu3fp9Oux
	 GlFBwvGtB/ZkTUMoTNYZpBXUG1vhlcDRMuwFBI9eT2BZvGa+bav2xe89O+W1uvVKGG
	 0E4tMuyKBWtqe3ObUZ4czMcB/HfZ3v/5kJU+0mvzbgZCGsdaCs6j/iFbTzVChJCrAs
	 gXExTFAY6tCjgwWpuiLcC4Rg8kzwrK+Gar1oC6ST2F9P7XpxeDmC2v1VoDEKtKr39F
	 F57F8LLY/DGtA==
From: Mike Snitzer <snitzer@kernel.org>
To: Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Cc: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	linux-nfs@vger.kernel.org,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Christoph Hellwig <hch@lst.de>,
	Jens Axboe <axboe@kernel.dk>,
	Jonathan Corbet <corbet@lwn.net>
Subject: [PATCH v9 4/6] mm, iomap: keep a partly covered page until an uncached write completes it
Date: Sat, 24 Oct 2026 18:11:50 -0400
Message-ID: <20261024221152.6965-5-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261024221152.6965-1-snitzer@kernel.org>
References: <20261024221152.6965-1-snitzer@kernel.org>
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

An uncached (RWF_DONTCACHE) buffered write marks drop-behind every folio
it creates, so writeback drops each one as soon as this write's data is
on disk.  A page the write covers only partly is usually shared with the
neighbouring write, the one that ends or starts in it.  Once the first
of the two has been written back, the page is gone, and the second has
to read the block back from disk before it can write its part: one read
per misaligned write.

Measured locally on XFS (emulated 4Kn NVMe, 4 KiB pages), 32 threads
writing interleaved records to one file with pwritev2(), 1 GiB per run,
before and after this patch:

  record  flags                     4 KiB device       MiB/s
  bytes                             reads per write
                                    before   after     before  after
  47008   RWF_DONTCACHE             0.97     0.0005    831     2281
  47008   RWF_DONTCACHE|RWF_DSYNC   0.99     0.0005    601     1227
  6000    RWF_DONTCACHE             0.97     0.0001    121      488
  6000    RWF_DONTCACHE|RWF_DSYNC   0.99     0.0002     90      206

Before this patch every write waited for its read, and because XFS holds
its IOLOCK exclusively across a buffered write, the other 31 writers
waited too: both record sizes ran at about 20 thousand writes a second,
one device read per write; after it only metadata is read.  With
RWF_DSYNC each write still waits for its own sync, so the gain is
smaller: the uncached write now runs as fast as the same write without
RWF_DONTCACHE, 1237 and 209 MiB/s against 1227 and 206 in the table.
Records of 49152 bytes, which cover only whole pages, read only that
metadata, 0.0005 per write, before and after.

NFSD DIRECT issues the misaligned ends of a WRITE as buffered uncached
segments and gains the same way.  Without any handling of the shared
page, 32 interleaved writers of 47008-byte records read 45144 blocks
for 45664 WRITEs; with this patch, and no NFSD code for the shared page,
0.0001 to 0.0008 blocks per WRITE whether each record is sent as one
FILE_SYNC WRITE, as two one after the other, as two together, or as two
UNSTABLE.  The page cache then marks the completed page while it is
still dirty, so each segment of a stable WRITE wakes the DONTCACHE
writeback kick (23 to 65 thousand rounds a run); the next two patches
let NFSD mark it after its sync instead.

Let the write path say which pages a write covers only partly
(FGP_DONTCACHE_EDGE) and get such a page as the smallest folio the
mapping allows: a single page, or a single block where the mapping's
minimum folio order makes the block larger than a page, which is then
the unit two writes share.  iomap sets it when the write starts inside
that unit or ends before its end, testing against
mapping_min_folio_nrbytes().  A folio created for it is not marked, so
writing back this write's part does not drop it.  A folio found
uptodate is the neighbour's, already written: this write completes it,
so mark it, under the folio lock and before its own data goes in, and
the writeback that cleans both writes' data drops it.  The folio lock
orders the two writes, so the second always finds the first's data in
place.  A folio found there that is larger than that unit, left by
readahead or another buffered write, holds more than the two writes
share and cannot be dropped in part: it is not marked, and stays cached
as it would without this change.

Some file systems track uptodate per block, as iomap does for blocks
smaller than the folio.  There a folio is uptodate only once all its
blocks are.  So the edge that a write completes is not yet uptodate when
the write looks it up.  folio_dontcache_edge_written() also accepts such
a folio.  The neighbour wrote its part if every block that this write
does not cover in full is uptodate (->is_partially_uptodate).
iomap_get_folio() marks an edge that passes this test.  This matters for
4 KiB blocks on 16 or 64 KiB pages, and for blocks smaller than 4 KiB
pages.

A page whose neighbour never writes, such as the last page of a file,
stays cached until reclaim.  A partly covered page another task had
cached and that is uptodate is now dropped after the write's writeback,
where before an uncached write never dropped a page it did not create.

The mark is set when the lookup finds the folio, before iomap validates
the iomap.  If the iomap is stale and a fatal signal stops the retry, the
folio keeps the mark although this write did not complete it.  Writeback
cleans the folio before it drops it, and the application's retry reads
the folio back once.  The lookup cannot undo the mark: a folio an earlier
write marked returns early, so the lookup cannot tell whether it set the
mark.

Only iomap file systems say which pages a write covers partly so far;
write_begin_get_folio() users such as ext4 and the NFS client do not.
With blocks smaller than a page, a write that crosses an extent boundary
inside a page asks for it as two partly covered halves, so the page,
though one write covers it whole, stays cached until reclaim.

Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---

Notes:
    Notes on the v8 review questions, with the code that answers each:
    
    - Mark before iomap validation.  The commit message states this
      limit.  The cost is one read of the folio on the application's
      retry.  Writeback cleans the folio before the page cache drops it,
      so data is safe.
    - Blocks smaller than the folio.  folio_dontcache_edge_written()
      calls ->is_partially_uptodate() only for the blocks this write
      does not cover in full.  iomap_get_folio() returns the folio
      locked (FGP_WRITEBEGIN includes FGP_LOCK), so the helper reads the
      per-block state under the folio lock.  iomap_get_folio() tests
      IS_ERR() before it uses the folio.
    - Larger folios.  filemap_dontcache_edge_unit() accepts only a folio
      of mapping_min_folio_nrpages().  iomap_get_folio() limits len to
      the unit, so fgf_set_order() asks for no more than one unit at an
      edge.
    - Page cache mark.  __filemap_get_folio_mpol() marks an edge only
      with FGP_LOCK set, so folio_mark_dropbehind() always has the folio
      locked.
    - Stale dirty tag.  folio_mark_dropbehind() tests PG_dirty and the
      tag (3/6), so a clean folio with a stale tag is not counted.
    - File systems that do not use iomap_get_folio() never set
      FGP_DONTCACHE_EDGE, so their behaviour does not change.

 fs/iomap/buffered-io.c  | 32 +++++++++++++++--
 include/linux/pagemap.h |  6 ++++
 mm/filemap.c            | 78 ++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 112 insertions(+), 4 deletions(-)

diff --git a/fs/iomap/buffered-io.c b/fs/iomap/buffered-io.c
index 0a5ebfda90f12..eb1f7f019a852 100644
--- a/fs/iomap/buffered-io.c
+++ b/fs/iomap/buffered-io.c
@@ -798,16 +798,42 @@ EXPORT_SYMBOL_GPL(iomap_is_partially_uptodate);
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
+		/*
+		 * The smallest folio the mapping allows, a page or a block
+		 * where the block is larger, that this write covers only
+		 * partly is shared with a neighbouring write: get it as just
+		 * that, which is kept until the write that completes it.
+		 */
+		if (off || len < unit) {
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
+	 * The page cache marks an edge it finds uptodate.  With blocks
+	 * smaller than the folio, the edge this write completes is not
+	 * uptodate yet: mark it if its other blocks are.
+	 */
+	if ((fgp & FGP_DONTCACHE_EDGE) &&
+	    !IS_ERR(folio) && !folio_test_uptodate(folio) &&
+	    folio_dontcache_edge_written(folio, pos, len))
+		folio_mark_dropbehind(folio);
+	return folio;
 }
 EXPORT_SYMBOL_GPL(iomap_get_folio);
 
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 3012bd95812a1..0b151c1201082 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -701,6 +701,10 @@ pgoff_t page_cache_prev_miss(struct address_space *mapping,
  * * %FGP_NOWAIT - Don't block on the folio lock.
  * * %FGP_STABLE - Wait for the folio to be stable (finished writeback)
  * * %FGP_DONTCACHE - Uncached buffered IO
+ * * %FGP_DONTCACHE_EDGE - With %FGP_DONTCACHE: the write covers this page
+ *   only partly, and a neighbouring write may complete it.  A folio created
+ *   for it is not marked drop-behind; a folio found uptodate is, as the
+ *   write that completes it.
  * * %FGP_WRITEBEGIN - The flags to use in a filesystem write_begin()
  *   implementation.
  */
@@ -715,6 +719,7 @@ typedef unsigned int __bitwise fgf_t;
 #define FGP_FOR_MMAP		((__force fgf_t)0x00000040)
 #define FGP_STABLE		((__force fgf_t)0x00000080)
 #define FGP_DONTCACHE		((__force fgf_t)0x00000100)
+#define FGP_DONTCACHE_EDGE	((__force fgf_t)0x00000200)
 #define FGF_GET_ORDER(fgf)	(((__force unsigned)fgf) >> 26)	/* top 6 bits */
 
 #define FGP_WRITEBEGIN		(FGP_LOCK | FGP_WRITE | FGP_CREAT | FGP_STABLE)
@@ -1311,6 +1316,7 @@ void folio_end_writeback(struct folio *folio);
 void folio_end_writeback_no_dropbehind(struct folio *folio);
 void folio_end_dropbehind(struct folio *folio);
 void folio_mark_dropbehind(struct folio *folio);
+bool folio_dontcache_edge_written(struct folio *folio, loff_t pos, size_t len);
 void folio_wait_stable(struct folio *folio);
 void __folio_mark_dirty(struct folio *folio, struct address_space *, int warn);
 void folio_account_cleaned(struct folio *folio, struct bdi_writeback *wb);
diff --git a/mm/filemap.c b/mm/filemap.c
index d0e4d1788fd40..d7bbea442a019 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1686,6 +1686,62 @@ void folio_mark_dropbehind(struct folio *folio)
 }
 EXPORT_SYMBOL_GPL(folio_mark_dropbehind);
 
+/*
+ * Is @folio the unit two writes share at an edge: the smallest folio the
+ * mapping allows, a single page or, where the block is larger, a single
+ * block?  A larger folio, left by readahead or another buffered write, holds
+ * more than that unit and is not marked for an edge.
+ */
+static bool filemap_dontcache_edge_unit(struct address_space *mapping,
+					struct folio *folio)
+{
+	return folio_nr_pages(folio) == mapping_min_folio_nrpages(mapping);
+}
+
+/**
+ * folio_dontcache_edge_written - has the neighbouring write written its part?
+ * @folio: a locked folio, the edge two uncached writes share
+ * @pos: file offset of the first byte this write covers in @folio
+ * @len: bytes this write covers in @folio
+ *
+ * An uptodate folio has.  Where the file system tracks uptodate per block, a
+ * folio is uptodate only once all its blocks are, so the folio a write is
+ * about to complete is not yet uptodate.  Its neighbour has then written its
+ * part if every block that this write does not cover in full is uptodate.
+ *
+ * Return: true if @folio is an edge unit and its neighbour has written its
+ * part of it.
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
@@ -2069,6 +2125,19 @@ struct folio *__filemap_get_folio_mpol(struct address_space *mapping,
 
 	if (fgp_flags & FGP_STABLE)
 		folio_wait_stable(folio);
+
+	/*
+	 * An uncached write that covers this folio only partly, finding it
+	 * uptodate, is the write that completes it: the neighbouring write
+	 * that left it here has written its part.  Mark it now, under the
+	 * folio lock, so the writeback that cleans both writes' data drops it.
+	 * Not a folio larger than the edge the two writes share, which holds
+	 * more than they wrote and cannot be dropped in part.
+	 */
+	if ((fgp_flags & FGP_DONTCACHE) && (fgp_flags & FGP_DONTCACHE_EDGE) &&
+	    (fgp_flags & FGP_LOCK) && folio_test_uptodate(folio) &&
+	    filemap_dontcache_edge_unit(mapping, folio))
+		folio_mark_dropbehind(folio);
 no_page:
 	if (!folio && (fgp_flags & FGP_CREAT)) {
 		unsigned int min_order = mapping_min_folio_order(mapping);
@@ -2106,7 +2175,14 @@ struct folio *__filemap_get_folio_mpol(struct address_space *mapping,
 			/* Init accessed so avoid atomic mark_page_accessed later */
 			if (fgp_flags & FGP_ACCESSED)
 				__folio_set_referenced(folio);
-			if (fgp_flags & FGP_DONTCACHE)
+			/*
+			 * A folio the write covers only partly is left
+			 * unmarked, so that writing back this write's part
+			 * does not drop it before a neighbouring write has
+			 * written the rest.
+			 */
+			if ((fgp_flags & FGP_DONTCACHE) &&
+			    !(fgp_flags & FGP_DONTCACHE_EDGE))
 				__folio_set_dropbehind(folio);
 
 			err = filemap_add_folio(mapping, folio, index, gfp);
-- 
2.52.0

