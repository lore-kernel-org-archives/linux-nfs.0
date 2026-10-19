Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792422449;
	b=QlwtRqiT/mYlN/oGTejhmnrnJiz1l8JpA0oO8GZhGlt8guvQ5bLLmjbftmt/sAZgPenv
	 OV/H8J4zbAQ5iT2pA4f6Zc1NHL4V6T4D9Bn7+fHVbYksnH0ulbVnw1E6UWnqMrcfPm0D2
	 aGBa6Qpl2mlrJsdkfqck606OLK+hkdCukwXwEbGF3PVHm5OxrISx0Sh8OOuYUC+rMhkLt
	 OY2wiSu0b/UdxAotAP76K1GULmOVycR9IIthcNSEegfBEVUjiBnSfnl/en4Cq52bIFd0F
	 DWaslHW4ecIiNfhAEBZVrq99efc4O7syA1WE++a1aYj+khD/zFsOXMUOlblMQnrBNzQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792422449;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=0hOg2i79IwKo0Y5Q+OgE6JXIx9i3XNaUZPWYs4I/bAY=;
	b=T4W9mOWZFHRwblkgUiDAUuhD8ayLBQsMWz3mRzEX39B6GHC7dowTTWELMJqm+8QQ5TRn
	 BaQUagTp1bxY73KlWSIAI/hNscGgdgLNs2gpRZWdNjxLY/c9nJQ/Ox0fzwXIeb9kfXstr
	 N7pvRgsp6yu4pknAkk9eglRZXSyTCZXWR5k1qzt8w2R891XJMGFq/FdHAhfAn1T0CSR+m
	 HshJ7o3y1gxqsQwnNg5Xs/rWL+6FheW9+xSOZp9rOV/mUoZjmttj6d3wEYMZpXnEv9FG5
	 DNm4Kch//Zab66wYbOpxvx8ETcldUcEHfyNOAVB8H9VLeuOevDsGXBmjJug++LhZHCQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=WkHIjGMn;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9D21E6083435;
	Mon, 19 Oct 2026 15:07:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=WkHIjGMn
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0DE2E1F000C5;
	Mon, 19 Oct 2026 15:07:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792422448;
	bh=0hOg2i79IwKo0Y5Q+OgE6JXIx9i3XNaUZPWYs4I/bAY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=WkHIjGMnWtAotlwjZv20dfxOm0u8uniThVMNB9KqQZ9lsnn+DNIZgDtYSgp0B5edA
	 Gn1GHI1p4J93L8uOUxb5aYea7/VttzplGMr3zrXLCp00t+HhTZzU3y3hhe+pVnHJcE
	 kcYrVA0zbl6gcHjgcYQlxhk2NEk2vP/pIhLGCzPA0En1qKvLI6koGbUUX8DM8IWKuP
	 0nzLRsLBDYqxo4A16jUPfWVdQoHK1AMH+xYg77tM5FwdWzL6w8qqAWO3hoC3GIZ4h9
	 J0t0abQoDBgT6zA60ccSCp5+MHZdLqeXcO0p4voKet+1K868iP5sH+dH9fqQW3KmVn
	 sHtGKAa2TBSjQ==
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
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: [PATCH v5 1/6] NFSD: add tracing for how direct-mode READ and WRITE are serviced
Date: Mon, 19 Oct 2026 11:07:20 -0400
Message-ID: <20261019150725.1507-2-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261019150725.1507-1-snitzer@kernel.org>
References: <20261019150725.1507-1-snitzer@kernel.org>
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

When io_cache_read or io_cache_write selects a direct I/O mode, a
request may still be serviced with DONTCACHE buffered or normal
buffered I/O, and a WRITE may be split into up to three segments that
each take a different path depending on the request's offset/length
alignment, the payload's memory alignment, the filesystem's
FOP_DONTCACHE support, direct_misaligned_min_bytes and
direct_misaligned_dontcache.  Until now the only visibility was
nfsd_{read,write}_direct for O_DIRECT and nfsd_{read,write}_vector for
everything else, so the DONTCACHE and cached buffered cases were
indistinguishable and the reason a WRITE was not issued as direct I/O
was not recorded at all.

Add:

 - nfsd_write_dio_split, emitted once per direct-mode WRITE before any
   segment is issued.  It records the advertised offset and memory
   alignments, the payload's offset within its first page, the start,
   middle and end segment sizes, a disposition naming the path taken
   (direct, no_alignment, too_small, no_middle, mem_misaligned), and
   whether buffered segments are issued IOCB_DONTCACHE.

 - nfsd_write_dontcache and nfsd_read_dontcache, emitted for WRITE
   segments and READs serviced with IOCB_DONTCACHE.  nfsd_write_vector
   and nfsd_read_vector now fire only for normal buffered I/O.

The disposition enum lives in vfs.h, which trace.h already includes.

Document the new events in nfsd-io-modes.rst, together with iomap's
iomap_dio_invalidate_fail event, which reports an O_DIRECT segment that
the filesystem serviced with buffered I/O instead.

Assisted-by: LLM
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 .../filesystems/nfs/nfsd-io-modes.rst         | 38 ++++++++-
 fs/nfsd/trace.h                               | 77 +++++++++++++++++++
 fs/nfsd/vfs.c                                 | 47 ++++++++---
 fs/nfsd/vfs.h                                 |  9 +++
 4 files changed, 156 insertions(+), 15 deletions(-)

diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentation/filesystems/nfs/nfsd-io-modes.rst
index 0a5f4ef14a8a..11da2cee76fc 100644
--- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
+++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
@@ -171,21 +171,53 @@ Misaligned WRITE:
 Tracing:
     The nfsd_read_direct trace event shows how NFSD expands any
     misaligned READ to the next DIO-aligned block (on either end of the
-    original READ, as needed).
+    original READ, as needed). A READ that is serviced with buffered IO
+    instead emits nfsd_read_dontcache (DONTCACHE buffered IO) or
+    nfsd_read_vector (normal buffered IO).
 
     This combination of trace events is useful for READs::
 
       echo 1 > /sys/kernel/tracing/events/nfsd/nfsd_read_vector/enable
+      echo 1 > /sys/kernel/tracing/events/nfsd/nfsd_read_dontcache/enable
       echo 1 > /sys/kernel/tracing/events/nfsd/nfsd_read_direct/enable
       echo 1 > /sys/kernel/tracing/events/nfsd/nfsd_read_io_done/enable
       echo 1 > /sys/kernel/tracing/events/xfs/xfs_file_direct_read/enable
 
-    The nfsd_write_direct trace event shows how NFSD splits a given
-    misaligned WRITE into a DIO-aligned middle segment.
+    The nfsd_write_dio_split trace event is emitted once per WRITE in a
+    DIRECT IO mode, before any IO is issued. It records the alignments
+    the filesystem advertised, the payload's offset in its first page,
+    the sizes of the start, middle and end segments, and a
+    disposition::
+
+      direct          the aligned middle segment uses O_DIRECT
+      mem_misaligned  payload memory is misaligned; not split
+      no_alignment    the filesystem advertises no DIO alignment; not split
+      too_small       smaller than the larger of the offset and memory
+                      alignments; not split
+      no_middle       no aligned middle, or a misaligned start or end
+                      with a middle smaller than
+                      direct_misaligned_min_bytes bytes; not split
+
+    dontcache=1 means any buffered segment is issued DONTCACHE: the start
+    and end segments of a split WRITE, or the whole of a WRITE that is
+    not split. It is 0 when direct_misaligned_dontcache is N or the
+    filesystem lacks FOP_DONTCACHE, and is reported even for a WRITE
+    that has no buffered segment.
+
+    Each segment then emits nfsd_write_direct (O_DIRECT),
+    nfsd_write_dontcache (DONTCACHE buffered IO) or nfsd_write_vector
+    (normal buffered IO).
 
     This combination of trace events is useful for WRITEs::
 
       echo 1 > /sys/kernel/tracing/events/nfsd/nfsd_write_opened/enable
+      echo 1 > /sys/kernel/tracing/events/nfsd/nfsd_write_dio_split/enable
       echo 1 > /sys/kernel/tracing/events/nfsd/nfsd_write_direct/enable
+      echo 1 > /sys/kernel/tracing/events/nfsd/nfsd_write_dontcache/enable
+      echo 1 > /sys/kernel/tracing/events/nfsd/nfsd_write_vector/enable
       echo 1 > /sys/kernel/tracing/events/nfsd/nfsd_write_io_done/enable
       echo 1 > /sys/kernel/tracing/events/xfs/xfs_file_direct_write/enable
+      echo 1 > /sys/kernel/tracing/events/iomap/iomap_dio_invalidate_fail/enable
+
+    iomap_dio_invalidate_fail reports an O_DIRECT middle segment that
+    the filesystem serviced with buffered IO instead.
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index e0908cb21c4e..e2615cfdf6b7 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -501,6 +501,7 @@ DEFINE_EVENT(nfsd_io_class, nfsd_##name,	\
 DEFINE_NFSD_IO_EVENT(read_start);
 DEFINE_NFSD_IO_EVENT(read_splice);
 DEFINE_NFSD_IO_EVENT(read_vector);
+DEFINE_NFSD_IO_EVENT(read_dontcache);
 DEFINE_NFSD_IO_EVENT(read_direct);
 DEFINE_NFSD_IO_EVENT(read_io_done);
 DEFINE_NFSD_IO_EVENT(read_done);
@@ -508,11 +509,87 @@ DEFINE_NFSD_IO_EVENT(write_start);
 DEFINE_NFSD_IO_EVENT(write_opened);
 DEFINE_NFSD_IO_EVENT(write_direct);
 DEFINE_NFSD_IO_EVENT(write_vector);
+DEFINE_NFSD_IO_EVENT(write_dontcache);
 DEFINE_NFSD_IO_EVENT(write_io_done);
 DEFINE_NFSD_IO_EVENT(write_done);
 DEFINE_NFSD_IO_EVENT(commit_start);
 DEFINE_NFSD_IO_EVENT(commit_done);
 
+TRACE_DEFINE_ENUM(NFSD_WRITE_DIO_DIRECT);
+TRACE_DEFINE_ENUM(NFSD_WRITE_DIO_MEM_MISALIGNED);
+TRACE_DEFINE_ENUM(NFSD_WRITE_DIO_NO_ALIGNMENT);
+TRACE_DEFINE_ENUM(NFSD_WRITE_DIO_TOO_SMALL);
+TRACE_DEFINE_ENUM(NFSD_WRITE_DIO_NO_MIDDLE);
+
+#define show_nfsd_write_dio_disposition(x)				\
+	__print_symbolic(x,						\
+		{ NFSD_WRITE_DIO_DIRECT,	"direct" },		\
+		{ NFSD_WRITE_DIO_MEM_MISALIGNED, "mem_misaligned" },	\
+		{ NFSD_WRITE_DIO_NO_ALIGNMENT,	"no_alignment" },	\
+		{ NFSD_WRITE_DIO_TOO_SMALL,	"too_small" },		\
+		{ NFSD_WRITE_DIO_NO_MIDDLE,	"no_middle" })
+
+/*
+ * Emitted once per direct-mode WRITE, before any segment is issued.
+ * prefix, middle and suffix are zero when not computed.  mem_offset is
+ * the offset of the payload within its first page.
+ */
+TRACE_EVENT(nfsd_write_dio_split,
+	TP_PROTO(struct svc_rqst *rqstp,
+		 struct svc_fh *fhp,
+		 u64 offset,
+		 u32 len,
+		 u32 offset_align,
+		 u32 mem_align,
+		 u32 mem_offset,
+		 u32 prefix,
+		 u32 middle,
+		 u32 suffix,
+		 enum nfsd_write_dio_disposition disposition,
+		 bool dontcache),
+	TP_ARGS(rqstp, fhp, offset, len, offset_align, mem_align, mem_offset,
+		prefix, middle, suffix, disposition, dontcache),
+	TP_STRUCT__entry(
+		__field(u32, xid)
+		__field(u32, fh_hash)
+		__field(u64, offset)
+		__field(u32, len)
+		__field(u32, offset_align)
+		__field(u32, mem_align)
+		__field(u32, mem_offset)
+		__field(u32, prefix)
+		__field(u32, middle)
+		__field(u32, suffix)
+		__field(unsigned int, disposition)
+		__field(bool, dontcache)
+	),
+	TP_fast_assign(
+		__entry->xid = be32_to_cpu(rqstp->rq_xid);
+		__entry->fh_hash = knfsd_fh_hash(&fhp->fh_handle);
+		__entry->offset = offset;
+		__entry->len = len;
+		__entry->offset_align = offset_align;
+		__entry->mem_align = mem_align;
+		__entry->mem_offset = mem_offset;
+		__entry->prefix = prefix;
+		__entry->middle = middle;
+		__entry->suffix = suffix;
+		__entry->disposition = disposition;
+		__entry->dontcache = dontcache;
+	),
+	TP_printk("xid=0x%08x fh_hash=0x%08x offset=%llu len=%u "
+		  "offset_align=%u mem_align=%u mem_offset=%u "
+		  "prefix=%u middle=%u suffix=%u disposition=%s "
+		  "dontcache=%u",
+		  __entry->xid, __entry->fh_hash,
+		  __entry->offset, __entry->len,
+		  __entry->offset_align, __entry->mem_align,
+		  __entry->mem_offset,
+		  __entry->prefix, __entry->middle, __entry->suffix,
+		  show_nfsd_write_dio_disposition(__entry->disposition),
+		  __entry->dontcache)
+);
+
 DECLARE_EVENT_CLASS(nfsd_err_class,
 	TP_PROTO(struct svc_rqst *rqstp,
 		 struct svc_fh	*fhp,
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 32136cd32af9..0e937d116f39 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1323,7 +1323,10 @@ __be32 nfsd_iter_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	}
 	rqstp->rq_next_page = page;
 
-	trace_nfsd_read_vector(rqstp, fhp, offset, *count - total);
+	if (kiocb.ki_flags & IOCB_DONTCACHE)
+		trace_nfsd_read_dontcache(rqstp, fhp, offset, *count - total);
+	else
+		trace_nfsd_read_vector(rqstp, fhp, offset, *count - total);
 	iov_iter_bvec(&iter, ITER_DEST, rqstp->rq_bvec, v, *count - total);
 	host_err = vfs_iocb_iter_read(file, &kiocb, &iter);
 	return nfsd_finish_read(rqstp, fhp, file, offset, count, eof, host_err);
@@ -1391,7 +1394,8 @@ nfsd_write_dio_seg_init(struct nfsd_write_dio_seg *segment,
 }
 
 static unsigned int
-nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
+nfsd_write_dio_iters_init(struct svc_rqst *rqstp, struct svc_fh *fhp,
+			  struct nfsd_file *nf, struct bio_vec *bvec,
 			  unsigned int nvecs, struct kiocb *iocb,
 			  unsigned long total,
 			  struct nfsd_write_dio_seg segments[3])
@@ -1399,7 +1403,9 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	u32 offset_align = nf->nf_dio_offset_align;
 	loff_t prefix_end, orig_end, middle_end;
 	u32 mem_align = nf->nf_dio_mem_align;
-	size_t prefix, middle, suffix;
+	size_t prefix = 0, middle = 0, suffix = 0;
+	enum nfsd_write_dio_disposition disposition;
+	u32 mem_offset = nvecs ? bvec->bv_offset : 0;
 	loff_t offset = iocb->ki_pos;
 	unsigned int dontcache_flags = 0;
 	unsigned int buffered_flags;
@@ -1415,9 +1421,14 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	 * If alignments are not available, the write is too small,
 	 * or no alignment can be found, fall back to buffered I/O.
 	 */
-	if (unlikely(!mem_align || !offset_align) ||
-	    unlikely(total < max(offset_align, mem_align)))
+	if (unlikely(!mem_align || !offset_align)) {
+		disposition = NFSD_WRITE_DIO_NO_ALIGNMENT;
 		goto no_dio;
+	}
+	if (unlikely(total < max(offset_align, mem_align))) {
+		disposition = NFSD_WRITE_DIO_TOO_SMALL;
+		goto no_dio;
+	}
 
 	orig_end = offset + total;
 
@@ -1443,8 +1454,10 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 
 	if (!middle ||
 	    ((prefix || suffix) &&
-	     middle < nfsd_direct_misaligned_min_bytes))
+	     middle < nfsd_direct_misaligned_min_bytes)) {
+		disposition = NFSD_WRITE_DIO_NO_MIDDLE;
 		goto no_dio;
+	}
 
 	if (prefix) {
 		nfsd_write_dio_seg_init(&segments[nsegs], bvec,
@@ -1462,28 +1475,35 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	 * the first bvec, all subsequent bvecs start at bv_offset zero
 	 * (page-aligned). Therefore, only the first bvec is checked.
 	 */
-	if (iov_iter_bvec_offset(&segments[nsegs].iter) & (mem_align - 1))
+	if (iov_iter_bvec_offset(&segments[nsegs].iter) & (mem_align - 1)) {
+		disposition = NFSD_WRITE_DIO_MEM_MISALIGNED;
 		goto no_dio;
+	}
 	/*
 	 * IOCB_DONTCACHE matters only if the file system falls back to
 	 * buffered I/O (-ENOTBLK).
 	 */
 	segments[nsegs++].flags |= IOCB_DIRECT | dontcache_flags;
+	disposition = NFSD_WRITE_DIO_DIRECT;
 
 	if (suffix) {
 		nfsd_write_dio_seg_init(&segments[nsegs], bvec, nvecs, total,
 					prefix + middle, suffix, iocb);
 		segments[nsegs++].flags |= buffered_flags;
 	}
-
-	return nsegs;
+	goto out;
 
 no_dio:
 	/* Issue the whole WRITE as a single buffered segment. */
 	nfsd_write_dio_seg_init(&segments[0], bvec, nvecs, total, 0,
 				total, iocb);
 	segments[0].flags |= buffered_flags;
-	return 1;
+	nsegs = 1;
+out:
+	trace_nfsd_write_dio_split(rqstp, fhp, offset, total, offset_align,
+				   mem_align, mem_offset, prefix, middle,
+				   suffix, disposition, !!buffered_flags);
+	return nsegs;
 }
 
 static noinline_for_stack int
@@ -1499,8 +1519,8 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	ssize_t host_err;
 	size_t expected;
 
-	nsegs = nfsd_write_dio_iters_init(nf, rqstp->rq_bvec, nvecs,
-					  kiocb, *cnt, segments);
+	nsegs = nfsd_write_dio_iters_init(rqstp, fhp, nf, rqstp->rq_bvec,
+					  nvecs, kiocb, *cnt, segments);
 
 	/*
 	 * Persist a split synchronous WRITE once, after all of its
@@ -1517,6 +1537,9 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		if (kiocb->ki_flags & IOCB_DIRECT)
 			trace_nfsd_write_direct(rqstp, fhp, kiocb->ki_pos,
 						segments[i].iter.count);
+		else if (kiocb->ki_flags & IOCB_DONTCACHE)
+			trace_nfsd_write_dontcache(rqstp, fhp, kiocb->ki_pos,
+						   segments[i].iter.count);
 		else
 			trace_nfsd_write_vector(rqstp, fhp, kiocb->ki_pos,
 						segments[i].iter.count);
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 1f05c83a3ea6..e2a7c1c44949 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -230,4 +230,13 @@ __be32		nfsd_permission(struct svc_cred *cred, struct svc_export *exp,
 
 void		nfsd_filp_close(struct file *fp);
 
+/* The path nfsd_write_dio_iters_init() took for a direct-mode WRITE. */
+enum nfsd_write_dio_disposition {
+	NFSD_WRITE_DIO_DIRECT,
+	NFSD_WRITE_DIO_MEM_MISALIGNED,
+	NFSD_WRITE_DIO_NO_ALIGNMENT,
+	NFSD_WRITE_DIO_TOO_SMALL,
+	NFSD_WRITE_DIO_NO_MIDDLE,
+};
+
 #endif /* LINUX_NFSD_VFS_H */
-- 
2.52.0

