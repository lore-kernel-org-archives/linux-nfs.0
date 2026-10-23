Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792723557;
	b=TZVjN+dlC31mAkwmORnuYSJUrv6+7aKTwHfncaNK+pGhN5vhirZY8xUWgw2PUvKaxrkF
	 VVf9VYzqcEM1nvl8COyoJxXvCdpOw20NApPGf31vmffMOxWgCkHhcOMyJkqT5WiTFZJRN
	 K1qZPVIluOOgBe/6xHZC/lQYTpfuSgVEM5Pfh9YluZNLcpKd412clWtQxc9JFPYxUFtiV
	 CMiebbdWjvXs20KYXWYh8Ppc5YUcYyOBxrNNVSoXcoEIGI+U+aVP2VY9wexYIpZsy7Ju4
	 SQgcFnhTYL9aWg/TJSEhYdRGw2WSiCwBWM9UQ0adJd8RX9YZEs/gTWiib2zb8glP5BA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792723557;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=i+LCRyvu/R0wTzZRZEFob59r20QzB8GOilM+8NDrD+M=;
	b=2jDPZE/w+8SzGgi31ev8J5jb5DaASQneskKK20l8ywU6rN8dq5PBftrbS5FzSv+Dt/bQ
	 uTYsnSkFAtdG4gCD5GtxdPvgEWkJBQY1GHzx/eELh4miM0oCPR6rAo2RyqUV8bbmEGHHd
	 r4OklTsIbt+8ccdxLYKSDe0u7nDLG4mbsb4KrSI4XbjnXpZVnWwFHpMb2y8Q/DPIMFlpF
	 qZb0c1FiUbAXDe+wiHpSj5gJRWw/ietX8+elXrxAGk9pmh+pkvtmImbPM47YvbwH6ZZ9Z
	 dIh5wWI9zYus/JKP/LvQOfwTN2iL3/EgszZJV2DJWtbr84C6ibDj/m6P/dl+/lRdzWg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=bQkzUF9W;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DF60C606A32F;
	Fri, 23 Oct 2026 02:45:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=bQkzUF9W
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4F55B1F01828;
	Fri, 23 Oct 2026 02:45:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792723556;
	bh=i+LCRyvu/R0wTzZRZEFob59r20QzB8GOilM+8NDrD+M=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=bQkzUF9W51kZu+BBHbr5t/7lLpCt9/5kBfLhP3OVbir9qLy/OOeuyxT5ldyEasEJu
	 UPuvjpOyPiqen+AAni99AldYCpPVHZrqJA606lvb4GTztjV5ZIDfE8ur39jB1sD4NK
	 QEJroCzO5tO6/EnVoLn/ffrDJT3n3baqAJTd75UXUSqX2JOsf604ifcnv6T5SxT/Hy
	 oziXVAG4prWsg9XtSrzsTcyDnCZ9yAR1XAvnd9NgvKP/yReQeOGNqmiFjcE56L+wZW
	 huyT3waqnubjRRfFOIVkQHYWs8TQrjaw9/xFcjBytRrmJ2vK2vB5ul70tdNJwjHJcI
	 qaYoAwsR0FHMg==
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
	Jonathan Corbet <corbet@lwn.net>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: [PATCH v8 5/7] mm, iomap: keep a partly covered page until an uncached write completes it
Date: Thu, 22 Oct 2026 22:45:46 -0400
Message-ID: <20261023024548.71123-6-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261023024548.71123-1-snitzer@kernel.org>
References: <20261023024548.71123-1-snitzer@kernel.org>
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

A page whose neighbour never writes, such as the last page of a file,
stays cached until reclaim.  A partly covered page another task had
cached and that is uptodate is now dropped after the write's writeback,
where before an uncached write never dropped a page it did not create.

Only iomap file systems say which pages a write covers partly so far;
write_begin_get_folio() users such as ext4 and the NFS client do not.
With blocks smaller than a page, a write that crosses an extent boundary
inside a page asks for it as two partly covered halves, so the page,
though one write covers it whole, stays cached until reclaim.

Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 fs/iomap/buffered-io.c  | 16 +++++++++++++++-
 include/linux/pagemap.h |  5 +++++
 mm/filemap.c            | 34 +++++++++++++++++++++++++++++++++-
 3 files changed, 53 insertions(+), 2 deletions(-)

diff --git a/fs/iomap/buffered-io.c b/fs/iomap/buffered-io.c
index 0a5ebfda90f1..86f884c9f8f2 100644
--- a/fs/iomap/buffered-io.c
+++ b/fs/iomap/buffered-io.c
@@ -802,8 +802,22 @@ struct folio *iomap_get_folio(struct iomap_iter *iter, loff_t pos, size_t len)
 
 	if (iter->flags & IOMAP_NOWAIT)
 		fgp |= FGP_NOWAIT;
-	if (iter->flags & IOMAP_DONTCACHE)
+	if (iter->flags & IOMAP_DONTCACHE) {
+		size_t unit = mapping_min_folio_nrbytes(iter->inode->i_mapping);
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
 
 	return __filemap_get_folio(iter->inode->i_mapping, pos >> PAGE_SHIFT,
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 3012bd95812a..0c1d6bd09aa0 100644
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
diff --git a/mm/filemap.c b/mm/filemap.c
index 0c76ee5750b3..1494e42e609f 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1683,6 +1683,18 @@ void folio_mark_dropbehind(struct folio *folio)
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
 /**
  * folio_end_writeback_no_dropbehind - End writeback against a folio.
  * @folio: The folio.
@@ -2063,6 +2075,19 @@ struct folio *__filemap_get_folio_mpol(struct address_space *mapping,
 
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
@@ -2100,7 +2125,14 @@ struct folio *__filemap_get_folio_mpol(struct address_space *mapping,
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

