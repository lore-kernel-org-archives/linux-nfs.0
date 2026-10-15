Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 436143F410D
	for <linux-nfs@vger.kernel.org>; Thu, 15 Oct 2026 23:33:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792107193; cv=none; b=C+M2+sl5HDVrQPqUCUTAqCeITchSjtqff8f2aLzAXRxOJ0Al+6p1eY+RFT3dITcZ99WIFsos86KIS/Jg2hhqXEHgOofdb4yMcU+k3z99IZCFoZ79QXlOr9W6sRqtRJCC8DLYd3CiJ3H3HAR23rtRQtVPVScEq57h0oMzjQtv4DI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792107193; c=relaxed/simple;
	bh=ru43zY+ptqs1q0hQ+82XHvX2Uz1hE8Ec0UNzIGxZTl0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=P6gNe29M7slOYnsAV0+3612cLWpoaE8vLVYdbkx0WVulVRuoK4uLLxY+bZPZ3VjOXvviFTHPwlFNkYV3KfUIp77bmckbIi8yiPBLog3pv0cVScBhvk19+B0X+lK8CwBseDXOD0F+y95QcpkRx41RTbiYHCBpzVxFqBnksxz4CS8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=be41zlYX; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="be41zlYX"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EB8B11F000C5;
	Thu, 15 Oct 2026 23:33:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792107192;
	bh=yrooXPF1hhM/MoxFNqM1PlbQKoKP+pEqMYFgXl1fs10=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=be41zlYXUQwD44Jok0NtpSZ7o7ilsOn6jKjPFtuvyJHNm3+kodNq4v40to+kjFRdj
	 ZARjFHoJQIv2iv98pPQxGx57CCiP5L6T4m5JO3TJJff1ic+46QKwKTTizNXPy5pr9W
	 GJ/VtgUSaQN4LqJPxmsPEoaLpOPjsR2pSDr3t6qkDhG+6it/oST3jJm+tlBxJQb/EX
	 khz2+kHpIpKpudb2QsVoD4d8AjDP0bZRXJ6shDv4HM4WgZ/J/qfyHneU5iUUHGFzme
	 ki/0SoGnV8vR0QbGGqEhw2j1yvbY0t2oE5EFuLsrhVKLy/vNaKMiTXi5CKK7yuKk38
	 Hpbrkzcv7z1aw==
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
	linux-mm@kvack.org
Subject: [PATCH v4 01/10] NFSD: cut a misaligned direct-mode WRITE at page boundaries
Date: Thu, 15 Oct 2026 19:33:00 -0400
Message-ID: <20261015233309.42999-2-snitzer@kernel.org>
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

nfsd_write_dio_iters_init() splits a misaligned direct-mode WRITE into a
direct middle and buffered ends so that as little of it as possible goes
through the page cache.  That only works if direct and buffered I/O never
meet inside a page: the direct middle invalidates the page cache over its
range, so a middle that starts or stops inside the page a buffered end
writes has that page dropped, and whichever of the two neighbouring
WRITEs comes second has to read it back from the device.

The middle was cut at the file system's direct I/O offset alignment:

	prefix_end = round_up(offset, offset_align);
	middle_end = round_down(orig_end, offset_align);

On 4 KiB pages over 4096-byte blocks that alignment is the page size,
the cut is a page boundary, and the problem cannot arise.  It is broken
wherever the page is larger than the alignment: 16 and 64 KiB pages over
4096-byte blocks, and 4 KiB pages over 512-byte blocks.  There a
misaligned WRITE costs a read per shared page on top of its three I/Os.

Cut each end of a WRITE on its own:

- an end that is already an offset_align multiple needs no buffered
  segment, and the middle starts or stops there, mid-page or not.  A
  WRITE aligned to the device stays entirely direct at every page size;
- a misaligned end needs a buffered segment whatever is done, and that
  segment now runs to the nearest page boundary inside the WRITE.

That is one rule: a misaligned end is cut at a multiple of the larger of
offset_align and PAGE_SIZE, which are both powers of two.

The segments still tile exactly the bytes of the WRITE: a buffered end
grows inward, at the middle's expense, never outward.  A misaligned WRITE
that holds no whole page has no middle and is issued as one buffered
segment.  Where the offset alignment is a page-size multiple nothing
changes.

nfsd-io-modes.rst said that DONTCACHE is not used for the misaligned
segments, which the write loop already contradicted: every segment
without IOCB_DIRECT gets IOCB_DONTCACHE when the file system supports
it.  Replace that sentence with one that says so, next to one that
describes the new cut.

Fixes: 06c5c97293e3 ("NFSD: Implement NFSD_IO_DIRECT for NFS WRITE")
Cc: stable@vger.kernel.org
Assisted-by: LLM
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 Documentation/filesystems/nfs/nfsd-io-modes.rst |  9 ++++++---
 fs/nfsd/vfs.c                                   | 13 +++++++++++++
 2 files changed, 19 insertions(+), 3 deletions(-)

diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentation/filesystems/nfs/nfsd-io-modes.rst
index 0fd6e82478fe6..1916b2eee58ad 100644
--- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
+++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
@@ -126,9 +126,12 @@ Misaligned WRITE:
     middle and end as needed. The large middle segment is DIO-aligned
     and the start and/or end are misaligned. Buffered IO is used for the
     misaligned segments and O_DIRECT is used for the middle DIO-aligned
-    segment. DONTCACHE buffered IO is _not_ used for the misaligned
-    segments because using normal buffered IO offers significant RMW
-    performance benefit when handling streaming misaligned WRITEs.
+    segment. A misaligned start or end segment runs to the nearest page
+    boundary inside the WRITE, not just to the nearest DIO-aligned
+    offset, so the O_DIRECT segment never shares a page with a buffered
+    one; a start or end that is already DIO-aligned gets no buffered
+    segment at all. If the filesystem supports FOP_DONTCACHE, the
+    misaligned segments are marked DONTCACHE.
 
 Tracing:
     The nfsd_read_direct trace event shows how NFSD expands any
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index f4069da853725..ed5903c3becac 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1324,6 +1324,7 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	size_t prefix, middle, suffix;
 	loff_t offset = iocb->ki_pos;
 	unsigned int nsegs = 0;
+	u32 cut;
 
 	/*
 	 * Check if direct I/O is feasible for this write request.
@@ -1338,6 +1339,18 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	orig_end = offset + total;
 	middle_end = round_down(orig_end, offset_align);
 
+	/*
+	 * The direct middle invalidates the page cache over its range, so it
+	 * must not share a page with a buffered end.  An aligned end needs no
+	 * buffered segment; a misaligned one is cut on a page boundary even
+	 * where the offset alignment is finer than a page.
+	 */
+	cut = max_t(u32, offset_align, PAGE_SIZE);
+	if (prefix_end != offset)
+		prefix_end = min(round_up(offset, cut), orig_end);
+	if (middle_end != orig_end)
+		middle_end = max(round_down(orig_end, cut), prefix_end);
+
 	prefix = prefix_end - offset;
 	middle = middle_end - prefix_end;
 	suffix = orig_end - middle_end;
-- 
2.52.0

