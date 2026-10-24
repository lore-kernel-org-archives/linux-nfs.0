Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792869144;
	b=0Bn4lC9bWe2oUoJlIPFuz7ikCeBA84EsmeXIVv0xsBuKfqdS3YAcGSCn15fzzedskDhT
	 Yov3FoIlG1vEmXoQPQ6ZvHhn//OQ4Jt/CRYLs+OGvpm7cf30plcRjNr87La0EdFeZ1JZF
	 8Yw8SMk2GRx902NLCy6HXQUtSHA/ADml0w2HsjWZZ9S4dBdmshgSZzLZyX5HZ0xKvPrBr
	 fwy7Rcf9qxyCEtIbu99O7y89Z9wyRjuTMGHm2bAlki/a8n5GmleZT8u9EHShTwrUvUgV9
	 ufpFhHW19b2QTDHyFzBNL0xgKQUs9RctCtMDxe2uy5YzGgzlOtZbPOzX03NvVetNOyA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792869144;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 MIME-Version:Content-Type:Content-Disposition;
	bh=tWWiAhD1q3SGqZytIYj8Vfqab8KfOk5ANJFgDlntlxg=;
	b=B/0k3vj9+vQ6Lb8W3ZK4IDkhWlhKRTzz1O0H+xZuGgiBeFHVEeL+sEPIcEO0GNKTkTpL
	 NSYsNvXHX0wvdDmK0VK78NajDHuNz6bEXPMf+oqyw794pcpuZT0QjWQv4TNOIIhY0TSr+
	 UWWYX5Vb0DIEJyOd7BmO14eWSwSy3UuVdP3/YMG0qgKELvo1PEWgf7PfJPNWiXTSsq0St
	 hU8RzGaCzRgga7vbjmA+ElsCoNjRh3mSpARME1Gx1kYR3pb+vhIL8NVQecvnFTU16vSNv
	 hc7SUmAt8kR+8LJT/U6rKnTa6DjrxFr+vKSSbH8aozC9RteaZLWbIH65YLlOgfMHUQg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=k4vB6PT7;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F0711606A31A;
	Sat, 24 Oct 2026 19:12:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=k4vB6PT7
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4B5A01F01825;
	Sat, 24 Oct 2026 19:12:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792869143;
	bh=tWWiAhD1q3SGqZytIYj8Vfqab8KfOk5ANJFgDlntlxg=;
	h=Date:From:To:Cc:Subject;
	b=k4vB6PT74tlNmxhi9L2GOANsPAVqfX1q2JmIvaC2bdL0QQzOXPu91DEM+YEY8YmL7
	 Ipn+cIXjJJj92UpMbUzvspL0eLaZHA8WyBl9grp+FeepHs0AZnPwVytpeFbtHaP3s7
	 qcE5YOJW23SbpEB3S75h3GCouQSguWnZgE2FuztQv8N77fweEp9pyqXMEu6/68CCPR
	 0zEY8OoEA8qIul/i2czY+AkLUo8+RlW77envDwY21N0biXqvJCAFcQeePCioHJjz/1
	 1Mi4JIs/NL1A7o25TPjX9YiUoWKFry33ar3PRFcxFFXf0UJkCbKBLhBMfxghp/9gl+
	 jF8UX1y1CZ1Hw==
Date: Sat, 24 Oct 2026 15:12:22 -0400
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>,
	"Matthew Wilcox (Oracle)" <willy@infradead.org>,
	Jonathan Corbet <corbet@lwn.net>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: [PATCH cel/nfsd-testing replacement] NFSD: cut a misaligned
 direct-mode WRITE at folio boundaries
Message-ID: <at0DFod8CcUfus2S@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

nfsd_write_dio_iters_init() splits a misaligned direct-mode WRITE into a
direct middle and buffered ends.  Then as little of the WRITE as
possible goes through the page cache.  That works only if direct and
buffered I/O never meet inside a folio.  The direct middle invalidates
the page cache over its range.  So a middle that starts or stops inside
the folio of a buffered end drops that folio.  Then the second of the
two neighbouring WRITEs reads it back from the device.

The middle was cut at the file system's direct I/O offset alignment:

        prefix_end = round_up(offset, offset_align);
        middle_end = round_down(orig_end, offset_align);

Where that alignment is a multiple of the smallest folio the mapping
allows, the cut is a folio boundary, and the problem cannot occur.  This
is the case for 4 KiB pages over 4096-byte blocks.  It is broken where
the smallest folio is larger than the alignment.  Examples are 16 and
64 KiB pages over 4096-byte blocks, and 4 KiB pages over 512-byte
blocks.

Another is a block larger than the page, which the page cache holds as
one folio.  There a misaligned WRITE costs a read per shared folio on
top of its three I/Os.

Cut each end of a WRITE on its own:

- an end that is already an offset_align multiple needs no buffered
  segment, and the middle starts or stops there, inside a folio or not.
  A WRITE aligned to the device stays fully direct at every page size.
- a misaligned end needs a buffered segment in any case.  That segment
  now runs to the nearest boundary of the smallest folio inside the
  WRITE.

That is one rule: a misaligned end is cut at a multiple of the larger of
offset_align and mapping_min_folio_nrbytes().  Both are powers of two.

The segments still tile exactly the bytes of the WRITE: a buffered end
grows inward, at the middle's expense, never outward.  A misaligned
WRITE that holds no whole folio of the smallest size has no middle, and
is issued as one buffered segment.  Where offset_align is a multiple of
the smallest folio, nothing changes.

A folio larger than the smallest that the mapping allows can still span
the cut.  Readahead or an earlier buffered write can leave one, and only
the lookup that finds it learns its size.  The direct middle then
invalidates it as a whole, and the neighbouring WRITE reads its part
back once.  Direct I/O always has that read-back for a cached folio, and
the cut cannot prevent it.

nfsd-io-modes.rst said that DONTCACHE is not used for the misaligned
segments.  The write loop already contradicted that: every segment
without IOCB_DIRECT gets IOCB_DONTCACHE when the file system supports
it.  Replace that sentence with one that says so, next to one that
describes the new cut.

Fixes: 06c5c97293e3 ("NFSD: Implement NFSD_IO_DIRECT for NFS WRITE")
Cc: stable@vger.kernel.org
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
This replaces 80728157d1bd ("NFSD: cut a misaligned direct-mode WRITE at
page boundaries") in cel/nfsd-testing.  Changes from that commit:

- the cut is max_t(unsigned long, offset_align,
  mapping_min_folio_nrbytes(nf->nf_file->f_mapping)).  PAGE_SIZE is
  gone, and cut keeps the helper's unsigned long type.
- the subject, the commit message, the comment and nfsd-io-modes.rst
  name two bounds: the DIO offset alignment and the mapping's smallest
  folio.

It also takes the place of v8 1/7, which will not be in v9.

Heads-up for applying the commits after 80728157d1bd: of the 27 in
cel/nfsd-testing (6d13b7f74eec), only fcd8823db80e ("NFSD: only split a
direct-mode WRITE for a worthwhile direct middle") conflicts, in
nfsd-io-modes.rst.  Take its paragraph with "page" changed to "folio" in
"nearest page boundary" and "never shares a page".  Nothing conflicts in
code.  The other 26 apply cleanly, and the result differs from
cel/nfsd-testing only in this change.

 .../filesystems/nfs/nfsd-io-modes.rst         |  9 ++++++---
 fs/nfsd/vfs.c                                 | 20 +++++++++++++++++--
 2 files changed, 24 insertions(+), 5 deletions(-)

diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentation/filesystems/nfs/nfsd-io-modes.rst
index 0fd6e82478fe6..8f5e6872f1004 100644
--- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
+++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
@@ -126,9 +126,12 @@ Misaligned WRITE:
     middle and end as needed. The large middle segment is DIO-aligned
     and the start and/or end are misaligned. Buffered IO is used for the
     misaligned segments and O_DIRECT is used for the middle DIO-aligned
-    segment. DONTCACHE buffered IO is _not_ used for the misaligned
-    segments because using normal buffered IO offers significant RMW
-    performance benefit when handling streaming misaligned WRITEs.
+    segment. A misaligned start or end segment runs to the nearest folio
+    boundary inside the WRITE, not just to the nearest DIO-aligned
+    offset, so the O_DIRECT segment never shares a folio with a buffered
+    one; a start or end that is already DIO-aligned gets no buffered
+    segment at all. If the filesystem supports FOP_DONTCACHE, the
+    misaligned segments are marked DONTCACHE.
 
 Tracing:
     The nfsd_read_direct trace event shows how NFSD expands any
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index c4b32e41b4c5e..f18309d4609b7 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1396,6 +1396,7 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	size_t prefix, middle, suffix;
 	loff_t offset = iocb->ki_pos;
 	unsigned int nsegs = 0;
+	unsigned long cut;
 
 	/*
 	 * Check if direct I/O is feasible for this write request.
@@ -1406,9 +1407,24 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	    unlikely(total < max(offset_align, mem_align)))
 		goto no_dio;
 
-	prefix_end = round_up(offset, offset_align);
 	orig_end = offset + total;
-	middle_end = round_down(orig_end, offset_align);
+
+	/*
+	 * The direct middle invalidates the page cache over its range, so it
+	 * must not share a folio with a buffered end.  An aligned end needs no
+	 * buffered segment.  A misaligned one is cut on a boundary of the
+	 * smallest folio the mapping allows, even where the offset alignment
+	 * is finer.  A WRITE may end at OFFSET_MAX, so the prefix is sized as
+	 * a distance rather than by rounding @offset up, which could wrap.
+	 */
+	cut = max_t(unsigned long, offset_align,
+		    mapping_min_folio_nrbytes(nf->nf_file->f_mapping));
+	prefix_end = offset;
+	if (!IS_ALIGNED(offset, offset_align))
+		prefix_end += min_t(loff_t, cut - (offset & (cut - 1)), total);
+	middle_end = orig_end;
+	if (!IS_ALIGNED(orig_end, offset_align))
+		middle_end = max(round_down(orig_end, cut), prefix_end);
 
 	prefix = prefix_end - offset;
 	middle = middle_end - prefix_end;

base-commit: 4e84914d70a0194e18bba6d814cfe71b340aadc8
-- 
2.52.0

