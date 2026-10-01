Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 73ABC379EDA
	for <linux-nfs@vger.kernel.org>; Thu,  1 Oct 2026 04:55:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790830509; cv=none; b=Cc5zMwwY14UyNwFERULji4wgEwD7iX44MW8Al8kTPxU8j+s0Ltq9bJ0qI90pd6u+MYtraZWi63JvVpG7vAVt/ivbvTgV86ePNRUKlRrXdXB0Hc93/HG5PAYOdE7xH2I0s3e8xUQNShxawclF+X3pTyJrjE8iTkdvWRxjEpZCwBY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790830509; c=relaxed/simple;
	bh=qYMim7BaHt+AgxbVIt1P+gRBESKeZ+wZYCIX3ENdd/M=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=XclYgQTtAtMw9dkGpDmSEPrEib8OLnOAHus+iDpr0FdqQx/GDaOQrn0/LiwT6GM+IKhaDdTX6zp5sOgzuiliLFo7xQbTSDEXSSQXi6lkhk+pBtabqpAcMFTmq/CwhmJ/CsTnA4mKHZcTj6JjK/ys6srg+9SfGVaR1GSK9sIbQm8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=WQ0ILQzu; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="WQ0ILQzu"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2BD321F000FF;
	Thu,  1 Oct 2026 04:55:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790830508;
	bh=lwlERiJ/fJfvvS8JRwJQstdsuhNcNfaBBg3zmNY7dJU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=WQ0ILQzuiLVd/zx3tlbZ8BcrRO94ztypfOxgOm3WwXAaxnmfMSROsNXlv1IeaHPIi
	 H0KTpm7+AAA5rmwnFuhQVV41IePaMXmAJO4zpTn3z9hf8wDff3cUPugwwpF0uGdaon
	 Alc7qBJtJ61SU8EqVtE3PXwfEZBwAL/mp2qr51Mf1144VvEoyXuEf0jj/fnl1tLaFY
	 syjmJ8AjbFgeCPgthWJoGnjEI1GHyjKUvPAEg1HuTp73aSPXzH8can2mcA/pHL1yW8
	 SUilrE3h9Wpw5SzzBRBwowVV55iC837iWMHmaViGVly130V1vROZ04YXt/Bk//YO0D
	 D8V8nd3GhFlwg==
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: hch@lst.de,
	linux-nfs@vger.kernel.org
Subject: [PATCH v3 4/9] NFSD: do not use direct I/O for a READ smaller than its alignment
Date: Thu,  1 Oct 2026 00:54:57 -0400
Message-ID: <20261001045502.48381-5-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261001045502.48381-1-snitzer@kernel.org>
References: <20261001045502.48381-1-snitzer@kernel.org>
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
 Documentation/filesystems/nfs/nfsd-io-modes.rst | 5 +++++
 fs/nfsd/vfs.c                                   | 6 +++---
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentation/filesystems/nfs/nfsd-io-modes.rst
index 9b1a9e7b09cef..12679001c7bec 100644
--- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
+++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
@@ -121,6 +121,11 @@ Misaligned READ:
     verified to have proper offset/len (logical_block_size) and
     dma_alignment checking.
 
+    A READ smaller than dio_read_offset_align is not expanded: it would
+    read one or two whole alignment units to return fewer bytes than
+    one. It is issued as DONTCACHE buffered IO instead (normal buffered
+    IO if the filesystem lacks FOP_DONTCACHE).
+
 Misaligned WRITE:
     If NFSD_IO_DIRECT is used, split any misaligned WRITE into a start,
     middle and end as needed. The large middle segment is DIO-aligned
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 1304953c684b7..e1d294aceb6bd 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1187,7 +1187,7 @@ __be32 nfsd_iter_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		      unsigned int base, u32 *eof)
 {
 	struct file *file = nf->nf_file;
-	unsigned long v, total;
+	unsigned long v, total = *count;
 	struct iov_iter iter;
 	struct kiocb kiocb;
 	ssize_t host_err;
@@ -1200,7 +1200,8 @@ __be32 nfsd_iter_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		break;
 	case NFSD_IO_DIRECT:
 		/* When dio_read_offset_align is zero, dio is not supported */
-		if (nf->nf_dio_read_offset_align && !rqstp->rq_res.page_len)
+		if (nf->nf_dio_read_offset_align && !rqstp->rq_res.page_len &&
+		    total >= nf->nf_dio_read_offset_align)
 			return nfsd_direct_read(rqstp, fhp, nf, offset,
 						count, eof);
 		fallthrough;
@@ -1213,7 +1214,6 @@ __be32 nfsd_iter_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	kiocb.ki_pos = offset;
 
 	v = 0;
-	total = *count;
 	while (total && v < rqstp->rq_maxpages &&
 	       rqstp->rq_next_page < rqstp->rq_page_end) {
 		len = min_t(size_t, total, PAGE_SIZE - base);
-- 
2.52.0

