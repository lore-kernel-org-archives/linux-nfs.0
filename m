Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2BC46560AD7;
	Tue,  8 Sep 2026 16:34:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788885296; cv=none; b=Vonw0+mJ9CSDY+4i14j3Chwps9EnTQG1wZhvkPFYeqVfXrPt0dxYwXc5AMbn3vQvUEsNh+NqjXOGP+24igXSzLcWDhl0vZso08/ZV8NDjlScO5G7jzAWce0XNocsz57dZKo881Qz1fK25CeqX64Cszd/4tFeCbwpYotv9aWzYfg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788885296; c=relaxed/simple;
	bh=5i+DjODG2Vn+ENnztQsjucuDKcGHxTtx/bVEF2T39YY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Xf2oLzaPz/C/pXW8INyFDvKGiKdD8YQseAJJZLUkTDv4DGo/59OB/z+vmV4xio9U7qiadTEmN9l+fx9h/gTDSY+WpvOxnKwNUBw4mP/gl+C9uQ4KuK1vqjDoS0qHmHJcn2MEDSz/usoFMr+wPtASJM9eH2xmNmmdzTuHdYaISRQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=FBCZTDBT; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="FBCZTDBT"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D33FA1F00A3E;
	Tue,  8 Sep 2026 16:34:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788885294;
	bh=0WJcgkfcno4f1O7TMV8JyGGCah/7XTybzUEDXaHNkpk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=FBCZTDBTwCzg7pL0CRw8pqAd53ToUFi628Ne63v9vdN8n8OYITXzQpHq/h9ycdsPn
	 AuwrEbLZG4ULG0NiOtWJ16x4KvGzFzMw2OLLqIDWiuxfHCa+1ZQT+Mj3fxMjd8naKg
	 OHmEFjZOI2nEz0RSAVWLCIfIed/hYSTk1QjTpZ7rObCkSF1dHCrXYc62a6eEwsUotZ
	 Q/SQv8A5bMr7VPh1EXjvbcJuCeyPrNyYdn9L3cnZ6oSNStaXN2pkOp0c1xM/ejWWju
	 i6lXHWVfXXsUUyCT/RtC9p7nnqSg0dJxhFgCNqezvIIt0IkwkrX1WzcYFbgo4ECc1R
	 NJ1u8EWlp+4iw==
From: Mike Snitzer <snitzer@kernel.org>
To: linux-nfs@vger.kernel.org,
	linux-block@vger.kernel.org
Cc: dm-devel@lists.linux.dev,
	axboe@kernel.dk,
	cel@kernel.org,
	jlayton@kernel.org,
	david.flynn@hammerspace.com
Subject: [PATCH 4/4] nfsd: fall back to buffered I/O when a direct write gets -EINVAL
Date: Tue,  8 Sep 2026 12:34:39 -0400
Message-ID: <20260908163448.30841-5-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20260908163448.30841-1-snitzer@kernel.org>
References: <20260908163232.30774-1-snitzer@kernel.org>
 <20260908163448.30841-1-snitzer@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfsd_dio_iter_is_aligned() approves a write iterator against the
file's STATX_DIOALIGN attributes (a whole-iterator iov_iter_alignment()
test against dio_mem_align), but the block stack applies stricter
geometry tests at bio split time: bio_split_io_at() checks each bvec's
offset and length against the queue's dma_alignment and may find no
valid block-size-aligned split at all. An ITER_BVEC WRITE payload can
pass the former and fail the latter: bio_iov_bvec_set() hands nfsd's
bvec array to the queue as-is, and the payload's first fragment starts
mid-page (the RPC header precedes it in the receive buffer), so the
iterator's interior page boundaries need not be logical-block aligned
and a bio the queue must split may have no valid split point. When
that happens, nfsd_direct_write() returned the -EINVAL to the client
as a failed WRITE (NFS4ERR_INVAL) -- for a perfectly valid request.

Observed against a brd-backed nvme-loop XFS export (dio_mem_align=4)
with 1 MiB WRITEs, e.g. arriving as 65 bvecs with bv0=(408,15976):
the gate admits the iterator, the block layer rejects it, and every
large write on the affected connection errors out (dd: Invalid
argument).

Treat -EINVAL from the direct attempt as "not direct-able": restore the
segment's iterator and retry it as (uncached when FOP_DONTCACHE)
buffered I/O, the same fallback nfsd_write_dio_iters_init() picks for
geometries it rejects itself.

The failed attempt must be assumed to have left the iterator advanced:
 ->write_iter() advances it while building and submitting bios before
the split-time rejection can fire, and vfs_iocb_iter_write() does not
revert on error. That is why the restore is a struct copy taken before
the attempt -- it snapshots the complete cursor by value (iov_offset,
count, bvec, nr_segs; the underlying bio_vec array is never mutated by
iteration), where iov_iter_revert() would need a byte count that an
error return does not provide. ki_pos is only advanced on success
(iomap_dio_complete() bumps it under ret > 0), so the retry lands at
the original offset, and any sectors a partially-split attempt already
reached are rewritten with the same data. The retry emits
nfsd_write_vector after the original nfsd_write_direct, so a fallback
is visible in tracing as the pair.

With this fix the same rig survives 30 fresh connections x 16 MiB of
page-aligned O_DIRECT client writes with zero client-visible errors
(fallback observed on 20 of 30 connections).

Fixes: 06c5c97293e3 ("NFSD: Implement NFSD_IO_DIRECT for NFS WRITE")
Assisted-by: Claude:claude-fable-5
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 fs/nfsd/vfs.c | 29 +++++++++++++++++++++++++++++
 1 file changed, 29 insertions(+)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 1af4f77f82fc..f43bbd0ae731 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1456,6 +1456,8 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 
 	*cnt = 0;
 	for (i = 0; i < nsegs; i++) {
+		struct iov_iter saved_iter = segments[i].iter;
+
 		kiocb->ki_flags = segments[i].flags;
 		if (kiocb->ki_flags & IOCB_DIRECT)
 			trace_nfsd_write_direct(rqstp, fhp, kiocb->ki_pos,
@@ -1467,6 +1469,33 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		expected = iov_iter_count(&segments[i].iter);
 
 		host_err = vfs_iocb_iter_write(file, kiocb, &segments[i].iter);
+		if (unlikely(host_err == -EINVAL &&
+			     (kiocb->ki_flags & IOCB_DIRECT))) {
+			/*
+			 * nfsd_dio_iter_is_aligned() approves the iterator
+			 * against the file's STATX_DIOALIGN attributes, but
+			 * the block stack applies stricter geometry tests at
+			 * split time (bio_split_io_at() checks each bvec's
+			 * offset and length against the queue's dma_alignment
+			 * and may find no valid block-size-aligned split).
+			 * A receive-buffer iterator can pass the former and
+			 * still fail the latter at split time, so treat
+			 * -EINVAL from the direct attempt as "not direct-able"
+			 * and retry the segment as (uncached) buffered I/O
+			 * rather than failing the WRITE.  ki_pos is not
+			 * advanced on error, and any sectors the failed
+			 * attempt already reached are rewritten with the
+			 * same data.
+			 */
+			segments[i].iter = saved_iter;
+			kiocb->ki_flags &= ~IOCB_DIRECT;
+			if (file->f_op->fop_flags & FOP_DONTCACHE)
+				kiocb->ki_flags |= IOCB_DONTCACHE;
+			trace_nfsd_write_vector(rqstp, fhp, kiocb->ki_pos,
+						segments[i].iter.count);
+			host_err = vfs_iocb_iter_write(file, kiocb,
+						       &segments[i].iter);
+		}
 		if (host_err < 0)
 			return host_err;
 		*cnt += host_err;
-- 
2.52.0

