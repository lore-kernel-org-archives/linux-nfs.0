Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BC20B3B6C09
	for <linux-nfs@vger.kernel.org>; Thu, 15 Oct 2026 23:33:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792107194; cv=none; b=ivsJqiZL7dpAF+0P+wovvUxpx3esunTGoFu5cYK2IxncZAaB9cy4CPt89b1c0ao6jwtgOeQ2daPrcY6ZnlSoTBQsnFwrP9KbfG8/5kfPuuR+z9b/yN6TRx0Bv08Tn5+gqha0YCHdzEYH14UoTQsVLfu6fbnXuC0S8ALPMt5TV3c=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792107194; c=relaxed/simple;
	bh=rPPchc8YkPv71W2v7JQ9ARHJ3n9B/YsRgHHvUiG/5yk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Qchmni0dEvhWy3QFqJeHV6B3ndfuTWkEo++4423aM0yNxJNajWf/uq/skMf4GiGFWE10LP1n70GqJJQ2+dt51/tCZ3sZgsTEspmGE0E9K1Gq7VxWaZRP8HYtcwMl0Lm2C8c/H6eZZpCUbvZggmUXzy8GpJ31nMBhltFup0bkZdk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Odmx9CmP; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Odmx9CmP"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 349521F000C4;
	Thu, 15 Oct 2026 23:33:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792107193;
	bh=9QPU6aTL0OhHiRAhc/6gebYSbVWMh+1NkswTXRHKaRE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Odmx9CmPFhY9YSSBeZTOnQKy9tG4SZRh28xpZE9lBhig2MHoHxWkS9LicYeGGZKnk
	 AklHAR8gyucQlczqC/PZrQcX03XN/uBnoK4XZa6Yi8EBgS31P5ZWtEEB581HAfAs8W
	 W7e+JXLvBdOXdBnFNAKCpM6HATgDbQ8kRsYv/pRuVyMg62VrICk8wDJcu1YVvk00s6
	 Ra5Oedi0GckHGIl3eBRA/N0YSxT/zV1xOqONo0br6MpZNjGqqAsu9a/G9SrDc67H9g
	 Xs10Q2sL9YgzvzP+A4EFJTkLDAp5OwNDaj1FXywRGk587sd2LaKwWfcLh11eae77PV
	 zMas6m17Mr2Tg==
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
Subject: [PATCH v4 02/10] NFSD: mark the direct middle of a split WRITE IOCB_DONTCACHE as well
Date: Thu, 15 Oct 2026 19:33:01 -0400
Message-ID: <20261015233309.42999-3-snitzer@kernel.org>
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

nfsd_write_dio_iters_init() marks the DIO-aligned middle of a misaligned
WRITE IOCB_DIRECT, and nfsd_direct_write() issues it that way.  A file
system may service that request with buffered I/O instead:
xfs_file_write_iter() retries through xfs_file_buffered_write() with the
same kiocb when xfs_file_dio_write() returns -ENOTBLK, which
iomap_dio_rw() does when it cannot invalidate page cache overlapping the
range.

Since the previous commit, the middle of a split WRITE shares no page
with the buffered ends of its neighbours, so a streaming misaligned
WRITE workload no longer causes this by itself.  It still happens
whenever something dirties a page in the middle's range between its
writeback and its invalidation without taking the lock the file system
holds across a direct write: a local process writing the exported file
through mmap, which XFS's IOLOCK does not keep out, or, on a file system
that does not hold such a lock for the length of a direct write, an
overlapping WRITE that is issued buffered as a whole (too small to
split, or its payload misaligned in memory) or a local buffered writer.
All of the middle, nearly the whole WRITE, is then re-issued as a cached
buffered write that nothing ever drops.

Set IOCB_DONTCACHE on the middle segment alongside IOCB_DIRECT when
the file system supports FOP_DONTCACHE.  The direct path ignores the
flag; a buffered fallback now drops its pages once written back.  Say
so in nfsd-io-modes.rst.

Fixes: 06c5c97293e3 ("NFSD: Implement NFSD_IO_DIRECT for NFS WRITE")
Assisted-by: LLM
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 Documentation/filesystems/nfs/nfsd-io-modes.rst | 4 ++++
 fs/nfsd/vfs.c                                   | 3 +++
 2 files changed, 7 insertions(+)

diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentation/filesystems/nfs/nfsd-io-modes.rst
index 1916b2eee58ad..f9b63f1a33990 100644
--- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
+++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
@@ -132,6 +132,10 @@ Misaligned WRITE:
     one; a start or end that is already DIO-aligned gets no buffered
     segment at all. If the filesystem supports FOP_DONTCACHE, the
     misaligned segments are marked DONTCACHE.
+    So is the O_DIRECT segment, where the flag has no effect unless the
+    filesystem services it with buffered IO instead, as XFS does when it
+    cannot invalidate page cache that overlaps the segment. The
+    iomap_dio_invalidate_fail trace event reports such a fallback.
 
 Tracing:
     The nfsd_read_direct trace event shows how NFSD expands any
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index ed5903c3becac..bd3dab36e2962 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1375,6 +1375,9 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	if (iov_iter_bvec_offset(&segments[nsegs].iter) & (mem_align - 1))
 		goto no_dio;
 	segments[nsegs].flags |= IOCB_DIRECT;
+	/* In case the file system falls back to buffered I/O (-ENOTBLK). */
+	if (nf->nf_file->f_op->fop_flags & FOP_DONTCACHE)
+		segments[nsegs].flags |= IOCB_DONTCACHE;
 	nsegs++;
 
 	if (suffix)
-- 
2.52.0

