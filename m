Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2A0954A5EC6
	for <linux-nfs@vger.kernel.org>; Thu, 15 Oct 2026 23:33:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792107204; cv=none; b=glALROipLEswOsTBUjEUh77sS0wsN7fNhh0gflgAkV7+sAHd5IrwJB+Y26xXv8vhJ9b0+NXVbfbkDpr2lbYv8t7qMaXq7j6mq/FE1en+ma8PXEbaL9DMlxFbOMpGXbinyXBveG3QR5Y1WMHtIKqtHYT/pH86Q6G05znjEFgqPAE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792107204; c=relaxed/simple;
	bh=5XLwJ8pz1DqAqb+oeyNatoG21U06CdYRgYrKWNDQ+CA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=tl89fm/iWj29ZjQv5vkAKwQD7coEmkbeKXmeHgO/QvtFGh+dt0MbCcYsn4W+9xyQ+RPE31XlE1vys+rwIpgshHKpxZockUodnoplX+Abf2Y0hJiafSsqhqF1Kc2XHE3Hxl5sjlDTZeNhgc9sYkPE/R68W7ikn2YtMv1ro4/skEY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=XQuUPKki; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="XQuUPKki"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D79B21F000C4;
	Thu, 15 Oct 2026 23:33:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792107203;
	bh=vO0aU+Ggic5anKiHOHkUq0jfIagPPjKPDfb5kf4RyGA=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=XQuUPKkiweJ2diIuJQyxI8qBmaGNR2RjaXAIl28JpvbM2hZmECcDEmH/lamfi7Vaj
	 JurrEaNXjGhWEBlPcbraMXHDc/uyCYarzi4BuOHqYOkaX3RJkK3j8R76tHdqoVv9R6
	 APb4hBM3Q8XQdh2bxlRpk0NotoA1HdWfIpHjoi+zwPsULYw8JdpFpY97A2ffjMLf4L
	 G+IQ5Mu/UF+/RV1mtGCKwiyuFz/5jK7iQHZOdRZnbw/ilxzSb1beaS74zEdxIaj4ZU
	 sBYTZPZLnSKh3CH3omSriRpNwk1IvbRHAXiNjWLFyMhbmljfx2c8ynDEIejBifw279
	 XOC67b3bEANWQ==
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
Subject: [PATCH v4 10/10] NFSD: add tracing for how direct-mode READ and WRITE are serviced
Date: Thu, 15 Oct 2026 19:33:09 -0400
Message-ID: <20261015233309.42999-11-snitzer@kernel.org>
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
index 278c0487b5bb2..2a648cedf2588 100644
--- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
+++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
@@ -182,21 +182,53 @@ Misaligned WRITE:
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
index e5d19c6f48a2c..8783c092b6338 100644
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
index d899d00714b1a..d56b2f01b1cfd 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1255,7 +1255,10 @@ __be32 nfsd_iter_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
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
@@ -1428,7 +1431,8 @@ nfsd_write_dio_seg_release(struct file *file,
 }
 
 static unsigned int
-nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
+nfsd_write_dio_iters_init(struct svc_rqst *rqstp, struct svc_fh *fhp,
+			  struct nfsd_file *nf, struct bio_vec *bvec,
 			  unsigned int nvecs, struct kiocb *iocb,
 			  unsigned long total,
 			  struct nfsd_write_dio_seg segments[3])
@@ -1436,7 +1440,9 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
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
@@ -1452,9 +1458,14 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
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
 
 	prefix_end = round_up(offset, offset_align);
 	orig_end = offset + total;
@@ -1478,8 +1489,10 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 
 	if (!middle ||
 	    ((prefix || suffix) &&
-	     middle < nfsd_direct_misaligned_min_bytes))
+	     middle < nfsd_direct_misaligned_min_bytes)) {
+		disposition = NFSD_WRITE_DIO_NO_MIDDLE;
 		goto no_dio;
+	}
 
 	if (prefix) {
 		nfsd_write_dio_seg_init(&segments[nsegs], bvec,
@@ -1498,13 +1511,16 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
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
@@ -1512,8 +1528,7 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 		segments[nsegs].flags |= buffered_flags;
 		segments[nsegs++].claim = !!buffered_flags;
 	}
-
-	return nsegs;
+	goto out;
 
 no_dio:
 	/*
@@ -1525,7 +1540,12 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 				total, iocb);
 	segments[0].flags |= buffered_flags;
 	segments[0].claim = !!buffered_flags;
-	return 1;
+	nsegs = 1;
+out:
+	trace_nfsd_write_dio_split(rqstp, fhp, offset, total, offset_align,
+				   mem_align, mem_offset, prefix, middle,
+				   suffix, disposition, !!buffered_flags);
+	return nsegs;
 }
 
 static noinline_for_stack int
@@ -1542,8 +1562,8 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	int sync_flags;
 	size_t expected;
 
-	nsegs = nfsd_write_dio_iters_init(nf, rqstp->rq_bvec, nvecs,
-					  kiocb, *cnt, segments);
+	nsegs = nfsd_write_dio_iters_init(rqstp, fhp, nf, rqstp->rq_bvec,
+					  nvecs, kiocb, *cnt, segments);
 
 	/*
 	 * Persist a synchronous WRITE once, after all of its segments.  A
@@ -1560,6 +1580,9 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
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
index eb75e4c823185..8f6349233c892 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -229,4 +229,13 @@ __be32		nfsd_permission(struct svc_cred *cred, struct svc_export *exp,
 
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

