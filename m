Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2E7E0339B3D
	for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 23:13:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790723623; cv=none; b=j/PGO5zsohmVUixKM6NXtHzqWghCROKfWvfQRXb4ljF9dYuXV3Zd99BI9MAo5q9FlyAWrdrWc0gZWhGMaKMPkBLt3XxAF+/MYrl2j4ou9Hmca/mUvwFoJMQXkY/5MAPUiEzkgIvoRkeT5mImY0OEGk5ERCZI3YclKBJzQoQJoAg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790723623; c=relaxed/simple;
	bh=X8CuEl3GJWG34quYdFbNDji6CC2EGrn+P+qyCC/IzYw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=rEg1Rfdr3nmdXt+fJ5DWFz0CO9HD0hGag6HI3BBKLO1y/gmU7vOv70kl5i4L/ZgJA/A1yiCJthQ5BoPsdxUhwqH6z9yYYg9W5oaKz7pf404sh2ycbEolA7S98cas+F9sksUc2WRdSW69sOX+/EwNJTd7vcLi9Anb7hh+N/J/lV0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=daoYuiG/; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="daoYuiG/"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D6F341F000FF;
	Tue, 29 Sep 2026 23:13:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790723622;
	bh=FxkeAhNI11TSA80XVXfkxYnckhuFYYjQK1ZqIaJ7Onc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=daoYuiG/ogo70/PgeqUEeQn39VZJBswjDyg2KfjtUaHNt7/bcpPkNyvpSuH/IiYky
	 NhJO1L3laP+zwtjUlbXk2FtEBfLcXhfJWDY/loRTpnQ8E02B9jEpIPqeP8QLJ3l25f
	 fTLia362zTxJwBUQunK82HMxIOx3ktW+bmO0sjCBPpbFViUNY6OHLEOUdJq8o6VVo7
	 qRClGh9BbbyEB2QvaQ6+YzkWpUeT600wdtSihetYlSVOgiu1jlXRJvH3YI5IJzUvM9
	 9cUljHx72XAu041TWHA56/lT5+BdexGeUurXq2FJtkqtJJJRrvxErCtp7FNqKuh4Jl
	 QLF9YXM2hNDrw==
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 9/9] NFSD: add tracing for how direct-mode READ and WRITE are serviced
Date: Tue, 29 Sep 2026 19:13:29 -0400
Message-ID: <20260929231329.22018-10-snitzer@kernel.org>
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

When io_cache_read or io_cache_write selects a direct I/O mode, a
request may still be serviced with DONTCACHE buffered or normal
buffered I/O, and a WRITE may be split into up to three segments that
each take a different path depending on the request's offset/length
alignment, the payload's memory alignment, and the filesystem's
FOP_DONTCACHE support.  Until now the only visibility was
nfsd_{read,write}_direct for O_DIRECT and nfsd_{read,write}_vector for
everything else, so the DONTCACHE and cached buffered cases were
indistinguishable and the reason a WRITE was not issued as direct I/O
was not recorded at all.

Add:

 - nfsd_write_dio_split, emitted once per direct-mode WRITE before any
   segment is issued.  It records the advertised offset and memory
   alignments, the payload's memory offset within its page, the start,
   middle and end segment sizes, the number of segments issued, and a
   disposition describing which path was taken (direct, no_alignment,
   too_small, no_middle, mem_misaligned), with a dontcache flag set
   when the buffered segments were issued IOCB_DONTCACHE, so a run with
   direct_misaligned_dontcache=N is distinguishable from one with the
   file system lacking FOP_DONTCACHE.

 - nfsd_write_dontcache and nfsd_read_dontcache, emitted for WRITE
   segments and READs serviced with IOCB_DONTCACHE.  nfsd_write_vector
   and nfsd_read_vector now fire only for normal buffered I/O.

The disposition enum lives in vfs.h so trace.h can reference it, and
TRACE_DEFINE_ENUM entries are provided for user-space decoding.

Document the new events in nfsd-io-modes.rst, including the iomap
iomap_dio_invalidate_fail event that reveals an O_DIRECT segment which
the filesystem silently serviced with buffered I/O.

Assisted-by: Claude:claude-fable-5-1
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 .../filesystems/nfs/nfsd-io-modes.rst         | 41 ++++++++-
 fs/nfsd/trace.h                               | 90 +++++++++++++++++++
 fs/nfsd/vfs.c                                 | 44 ++++++---
 fs/nfsd/vfs.h                                 | 22 +++++
 4 files changed, 183 insertions(+), 14 deletions(-)

diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentation/filesystems/nfs/nfsd-io-modes.rst
index f2c380ca000f7..6b1e9e10b47c2 100644
--- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
+++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
@@ -211,21 +211,56 @@ Misaligned WRITE:
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
+    The nfsd_write_dio_split trace event is emitted once per WRITE
+    serviced in a DIRECT IO mode, before any IO is issued, and records
+    how the WRITE was split: the offset and memory alignments the
+    filesystem advertised, the memory offset of the WRITE payload, the
+    sizes of the start, middle and end segments, the number of segments
+    actually issued, and a disposition naming the reason::
+
+      direct          aligned middle segment uses O_DIRECT
+      mem_misaligned  payload memory is misaligned; one buffered segment
+      no_alignment    filesystem advertises no DIO alignment; one
+                      buffered segment
+      too_small       WRITE is smaller than the larger of the two
+                      alignments; one buffered segment
+      no_middle       no (or too small) aligned middle; one buffered
+                      segment
+
+    Whether those buffered segments are DONTCACHE or normal buffered IO
+    is reported separately, by dontcache=1 or dontcache=0, because it is
+    the same answer for every disposition: the buffered segments are
+    DONTCACHE when the filesystem supports FOP_DONTCACHE. For the direct
+    disposition it describes the prefix and suffix of the split, the
+    middle being O_DIRECT.
+
+    Each segment then emits one of nfsd_write_direct (O_DIRECT),
+    nfsd_write_dontcache (DONTCACHE buffered IO) or nfsd_write_vector
+    (normal buffered IO) with the segment's offset and length.
 
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
+    iomap_dio_invalidate_fail indicates an O_DIRECT middle segment that
+    the filesystem silently serviced with normal buffered IO because it
+    could not invalidate overlapping page cache first.
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index 2ae7f150a72ce..0b8aa6c5d0772 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -15,6 +15,7 @@
 #include <trace/misc/fsnotify.h>
 #include <trace/misc/sunrpc.h>
 
+#include "vfs.h"
 #include "export.h"
 #include "nfsfh.h"
 #include "xdr4.h"
@@ -501,6 +502,7 @@ DEFINE_EVENT(nfsd_io_class, nfsd_##name,	\
 DEFINE_NFSD_IO_EVENT(read_start);
 DEFINE_NFSD_IO_EVENT(read_splice);
 DEFINE_NFSD_IO_EVENT(read_vector);
+DEFINE_NFSD_IO_EVENT(read_dontcache);
 DEFINE_NFSD_IO_EVENT(read_direct);
 DEFINE_NFSD_IO_EVENT(read_io_done);
 DEFINE_NFSD_IO_EVENT(read_done);
@@ -508,11 +510,99 @@ DEFINE_NFSD_IO_EVENT(write_start);
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
+TRACE_DEFINE_ENUM(NFSD_WRITE_DIO_NO_ALIGN);
+TRACE_DEFINE_ENUM(NFSD_WRITE_DIO_TOO_SMALL);
+TRACE_DEFINE_ENUM(NFSD_WRITE_DIO_NO_MIDDLE);
+
+#define show_nfsd_write_dio_disposition(x)				\
+	__print_symbolic(x,						\
+		{ NFSD_WRITE_DIO_DIRECT,	"direct" },		\
+		{ NFSD_WRITE_DIO_MEM_MISALIGNED, "mem_misaligned" },	\
+		{ NFSD_WRITE_DIO_NO_ALIGN,	"no_alignment" },	\
+		{ NFSD_WRITE_DIO_TOO_SMALL,	"too_small" },		\
+		{ NFSD_WRITE_DIO_NO_MIDDLE,	"no_middle" })
+
+/**
+ * nfsd_write_dio_split - how an NFSD_IO_DIRECT WRITE was split
+ *
+ * Emitted once per WRITE handled by nfsd_direct_write(), before any
+ * segment is issued. @prefix/@middle/@suffix are the byte counts of the
+ * three candidate segments (zero when not computed); @mem_offset is the
+ * offset within its page of the first byte of the WRITE payload, from
+ * which the middle segment's memory alignment is (@mem_offset + @prefix)
+ * masked by (@mem_align - 1).  @dontcache is whether the WRITE's buffered
+ * segments carry IOCB_DONTCACHE: the single segment of every non-direct
+ * disposition, and the prefix and suffix of a "direct" one.  It is ORed
+ * into @disposition by the caller, a tracepoint being limited to twelve
+ * arguments, and split back out into its own field here.
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
+		 u32 nsegs,
+		 unsigned int disposition),
+	TP_ARGS(rqstp, fhp, offset, len, offset_align, mem_align, mem_offset,
+		prefix, middle, suffix, nsegs, disposition),
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
+		__field(u32, nsegs)
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
+		__entry->nsegs = nsegs;
+		__entry->disposition = disposition & ~NFSD_WRITE_DIO_DONTCACHE;
+		__entry->dontcache = !!(disposition & NFSD_WRITE_DIO_DONTCACHE);
+	),
+	TP_printk("xid=0x%08x fh_hash=0x%08x offset=%llu len=%u "
+		  "offset_align=%u mem_align=%u mem_offset=%u "
+		  "prefix=%u middle=%u suffix=%u nsegs=%u disposition=%s "
+		  "dontcache=%u",
+		  __entry->xid, __entry->fh_hash,
+		  __entry->offset, __entry->len,
+		  __entry->offset_align, __entry->mem_align,
+		  __entry->mem_offset,
+		  __entry->prefix, __entry->middle, __entry->suffix,
+		  __entry->nsegs,
+		  show_nfsd_write_dio_disposition(__entry->disposition),
+		  __entry->dontcache)
+);
+
 DECLARE_EVENT_CLASS(nfsd_err_class,
 	TP_PROTO(struct svc_rqst *rqstp,
 		 struct svc_fh	*fhp,
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 7896e2e6c5855..3e7265b8de251 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1226,7 +1226,10 @@ __be32 nfsd_iter_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		base = 0;
 	}
 
-	trace_nfsd_read_vector(rqstp, fhp, offset, *count - total);
+	if (kiocb.ki_flags & IOCB_DONTCACHE)
+		trace_nfsd_read_dontcache(rqstp, fhp, offset, *count - total);
+	else
+		trace_nfsd_read_vector(rqstp, fhp, offset, *count - total);
 	iov_iter_bvec(&iter, ITER_DEST, rqstp->rq_bvec, v, *count - total);
 	host_err = vfs_iocb_iter_read(file, &kiocb, &iter);
 	return nfsd_finish_read(rqstp, fhp, file, offset, count, eof, host_err);
@@ -1363,7 +1366,8 @@ nfsd_write_dio_boundary_complete(struct file *file, loff_t pos)
 }
 
 static unsigned int
-nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
+nfsd_write_dio_iters_init(struct svc_rqst *rqstp, struct svc_fh *fhp,
+			  struct nfsd_file *nf, struct bio_vec *bvec,
 			  unsigned int nvecs, struct kiocb *iocb,
 			  unsigned long total,
 			  struct nfsd_write_dio_seg segments[3])
@@ -1371,7 +1375,8 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	u32 offset_align = nf->nf_dio_offset_align;
 	loff_t prefix_end, orig_end, middle_end;
 	u32 mem_align = nf->nf_dio_mem_align;
-	size_t prefix, middle, suffix;
+	size_t prefix = 0, middle = 0, suffix = 0;
+	enum nfsd_write_dio_disposition disposition;
 	loff_t offset = iocb->ki_pos;
 	unsigned int dontcache_flags = 0;
 	unsigned int buffered_flags;
@@ -1393,15 +1398,19 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	 * If the file system doesn't advertise any alignment requirements,
 	 * don't try to issue direct I/O at all.
 	 */
-	if (unlikely(!mem_align || !offset_align))
+	if (unlikely(!mem_align || !offset_align)) {
+		disposition = NFSD_WRITE_DIO_NO_ALIGN;
 		goto no_dio;
+	}
 
 	/*
 	 * If the I/O is smaller than the larger of the memory and logical
 	 * offset alignment, no part of it can be direct I/O.
 	 */
-	if (unlikely(total < max(offset_align, mem_align)))
+	if (unlikely(total < max(offset_align, mem_align))) {
+		disposition = NFSD_WRITE_DIO_TOO_SMALL;
 		goto no_dio;
+	}
 
 	prefix_end = round_up(offset, offset_align);
 	orig_end = offset + total;
@@ -1419,6 +1428,7 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	if (!middle ||
 	    ((prefix || suffix) &&
 	     middle < PAGE_SIZE * nfsd_direct_misaligned_num_pages)) {
+		disposition = NFSD_WRITE_DIO_NO_MIDDLE;
 		goto no_dio;
 	}
 
@@ -1452,8 +1462,10 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	 * middle, so issue the entire write as a single buffered segment:
 	 * splitting would only turn one buffered write into three.
 	 */
-	if (iov_iter_bvec_offset(&segments[nsegs].iter) & (mem_align - 1))
+	if (iov_iter_bvec_offset(&segments[nsegs].iter) & (mem_align - 1)) {
+		disposition = NFSD_WRITE_DIO_MEM_MISALIGNED;
 		goto no_dio;
+	}
 	/*
 	 * Also mark the direct middle DONTCACHE: the file system may fall
 	 * back to buffered I/O on its own (e.g. XFS on -ENOTBLK when it
@@ -1462,6 +1474,7 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	 * to do so.  On the direct path itself the flag is inert.
 	 */
 	segments[nsegs++].flags |= IOCB_DIRECT | dontcache_flags;
+	disposition = NFSD_WRITE_DIO_DIRECT;
 
 	if (suffix) {
 		nfsd_write_dio_seg_init(&segments[nsegs], bvec, nvecs, total,
@@ -1469,8 +1482,7 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 		segments[nsegs].flags |= buffered_flags;
 		segments[nsegs++].boundary = !!buffered_flags;
 	}
-
-	return nsegs;
+	goto out;
 
 no_dio:
 	/*
@@ -1483,7 +1495,14 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 				total, iocb);
 	segments[0].flags |= buffered_flags;
 	segments[0].edges = !!buffered_flags;
-	return 1;
+	nsegs = 1;
+out:
+	trace_nfsd_write_dio_split(rqstp, fhp, offset, total,
+				   offset_align, mem_align, bvec->bv_offset,
+				   prefix, middle, suffix, nsegs,
+				   disposition | (buffered_flags ?
+						  NFSD_WRITE_DIO_DONTCACHE : 0));
+	return nsegs;
 }
 
 /*
@@ -1533,8 +1552,8 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	sync = kiocb->ki_flags & IOCB_DSYNC;
 	datasync = !(kiocb->ki_flags & IOCB_SYNC);
 
-	nsegs = nfsd_write_dio_iters_init(nf, rqstp->rq_bvec, nvecs,
-					  kiocb, *cnt, segments);
+	nsegs = nfsd_write_dio_iters_init(rqstp, fhp, nf, rqstp->rq_bvec,
+					  nvecs, kiocb, *cnt, segments);
 
 	*cnt = 0;
 	for (i = 0; i < nsegs; i++) {
@@ -1542,6 +1561,9 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
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
index 6b352ca7f02b7..58f9ae26415dc 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -189,4 +189,26 @@ __be32		nfsd_permission(struct svc_cred *cred, struct svc_export *exp,
 
 void		nfsd_filp_close(struct file *fp);
 
+/*
+ * How nfsd_write_dio_iters_init() disposed of an NFSD_IO_DIRECT WRITE.
+ * "DONTCACHE segment" degrades to a cached segment when the file system
+ * lacks FOP_DONTCACHE.
+ */
+/*
+ * Which exit nfsd_write_dio_iters_init() took.  Whether the buffered
+ * segments carry IOCB_DONTCACHE is reported separately, by
+ * nfsd_write_dio_split's @dontcache, because it is the same answer for
+ * every exit below.
+ */
+enum nfsd_write_dio_disposition {
+	NFSD_WRITE_DIO_DIRECT,		/* aligned middle uses direct I/O */
+	NFSD_WRITE_DIO_MEM_MISALIGNED,	/* payload memory misaligned: one segment */
+	NFSD_WRITE_DIO_NO_ALIGN,	/* fs advertises no alignment: one segment */
+	NFSD_WRITE_DIO_TOO_SMALL,	/* len < max(offset_align, mem_align): one segment */
+	NFSD_WRITE_DIO_NO_MIDDLE,	/* no or tiny aligned middle: one segment */
+
+	/* ORed in: the WRITE's buffered segments carry IOCB_DONTCACHE */
+	NFSD_WRITE_DIO_DONTCACHE = 0x80,
+};
+
 #endif /* LINUX_NFSD_VFS_H */
-- 
2.52.0

