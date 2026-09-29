Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E40274D37C1
	for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 23:13:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790723616; cv=none; b=mJ/8Y2cfJtXhB+F8Mgp3/apMw4YO1TOgtN+YSxG5xVFMwYI5IxklRX3VQ1Qx/oZN4tvWYCj2msIFAxSW7EihBb2LWaIm90oF6N0dJ1Eljq4xVWc+LT72PcAowLuOzOezJsNfY++z+zCLg9oxY3WSwWhAoFAa+buOPl+5yRGnzbY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790723616; c=relaxed/simple;
	bh=vI8XU3LuAzZSOo3muxedzlw9jsHi/NzcEfAc2/tP04I=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=XfR1D7cq8Qx9S20Hjy7jFxl6ZKV9f98hkM9b181WIKCJUW/6L+/VlvulYemQkuUOIGy8aO8T4EovnwPArkcF0u7enDv6lLaTgViwkdagiN+Hz4oBq0sxejmfge7mFqbdXO4b59UiSBEDSCM6OKWcfXwC9tYfkUAzHJDI2qf+Cms=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=RZs4aISp; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="RZs4aISp"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6BBC01F000FF;
	Tue, 29 Sep 2026 23:13:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790723614;
	bh=wQ3yDBZy6xy0squruJN0aV2kKknTXfaYl8Oi2CiiOqw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=RZs4aISpj+hXJhYecoVauOZ5/7IHLie52Qg4QpemTXl49S2hNTCaxYHRPlUgU1AQo
	 UWktYPBl/8nCgmVjChmiZc4Y1eivAfh0nw8sc3/6rpzYqKD41VaqdooTGxDxhJjHAu
	 ApcUs33APa+YYges79IdnU0jzgnTf0j+Edahw7PbJzIPbzskTD3x/vTEnAkAvD5UF3
	 4DGFvouO+iXEV7gLsxjT977FrVBcaAkFsSWHZ64abOVJyutkB9XVrOwADDDRAuXBhJ
	 +dw1Hvw7y61LuueBI2Fi1Xqs8x9SwBSxSX2NGy9NX+abMEG7Caxj/hn8Up5mWrQgiT
	 EWDI7FUQ7vwNg==
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 3/9] NFSD: do not use direct I/O for a READ smaller than its alignment
Date: Tue, 29 Sep 2026 19:13:23 -0400
Message-ID: <20260929231329.22018-4-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20260929231329.22018-1-snitzer@kernel.org>
References: <20260929231329.22018-1-snitzer@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfsd_direct_read() expands a misaligned READ out to DIO-aligned
boundaries: it reads from round_down(offset, dio_read_offset_align) to
round_up(offset + count, dio_read_offset_align) and returns only the
requested bytes from within that window.  When the READ is smaller than
the alignment, that window is always at least one full alignment unit,
and two when the READ straddles a boundary, so a few hundred bytes of
payload can cost a 4K or 64K device read.

Decline direct I/O for those.  A READ smaller than
dio_read_offset_align now falls through to the DONTCACHE path, which
issues DONTCACHE buffered I/O when the file system supports
FOP_DONTCACHE and normal buffered I/O otherwise.  This mirrors the
WRITE side, which already declines direct I/O for a WRITE smaller than
the larger of its offset and memory alignments.

Only dio_read_offset_align is consulted, because the READ path fills
page-aligned pages from rq_bvec and so has no memory alignment to
satisfy.  The threshold only bites when the file system advertises a
large alignment; where it reports 512 almost no READ is excluded.

Document it in the "Misaligned READ" section of nfsd-io-modes.rst.

Assisted-by: Claude:claude-opus-5[1m]
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 Documentation/filesystems/nfs/nfsd-io-modes.rst | 7 +++++++
 fs/nfsd/vfs.c                                   | 6 +++---
 2 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentation/filesystems/nfs/nfsd-io-modes.rst
index fef062f24c525..d6ebb82f10b48 100644
--- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
+++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
@@ -121,6 +121,13 @@ Misaligned READ:
     verified to have proper offset/len (logical_block_size) and
     dma_alignment checking.
 
+    A READ smaller than dio_read_offset_align is not issued as O_DIRECT
+    at all. Expanding it would read a whole alignment unit, or two when
+    the READ straddles a boundary, to return those few bytes. Such a
+    READ is issued as DONTCACHE buffered IO instead (normal buffered IO
+    if the filesystem lacks FOP_DONTCACHE), mirroring the WRITE that is
+    smaller than its own alignment.
+
 Misaligned WRITE:
     If NFSD_IO_DIRECT is used, split any misaligned WRITE into a start,
     middle and end as needed. The large middle segment is DIO-aligned
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index e3ce66bce00d4..1d2b03cb42963 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1186,7 +1186,7 @@ __be32 nfsd_iter_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		      unsigned int base, u32 *eof)
 {
 	struct file *file = nf->nf_file;
-	unsigned long v, total;
+	unsigned long v, total = *count;
 	struct iov_iter iter;
 	struct kiocb kiocb;
 	ssize_t host_err;
@@ -1199,7 +1199,8 @@ __be32 nfsd_iter_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		break;
 	case NFSD_IO_DIRECT:
 		/* When dio_read_offset_align is zero, dio is not supported */
-		if (nf->nf_dio_read_offset_align && !rqstp->rq_res.page_len)
+		if (nf->nf_dio_read_offset_align && !rqstp->rq_res.page_len &&
+		    total >= nf->nf_dio_read_offset_align)
 			return nfsd_direct_read(rqstp, fhp, nf, offset,
 						count, eof);
 		fallthrough;
@@ -1212,7 +1213,6 @@ __be32 nfsd_iter_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	kiocb.ki_pos = offset;
 
 	v = 0;
-	total = *count;
 	while (total && v < rqstp->rq_maxpages &&
 	       rqstp->rq_next_page < rqstp->rq_page_end) {
 		len = min_t(size_t, total, PAGE_SIZE - base);
-- 
2.52.0

