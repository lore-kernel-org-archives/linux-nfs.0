Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 33DBC36DA0D
	for <linux-nfs@vger.kernel.org>; Thu,  1 Oct 2026 04:55:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790830513; cv=none; b=O2QjvLLsDfrcUTTgSSahko5TaCHZSlwEkNyAT/ukhcj8e2RdPgVZRjrkrDj5QiXA4g4o6J6mEi3cza/D61GPAkF1jIRuQiDUH8dvcH5HH8Gb7gC4SroV6XPb9fdnRPSlsC7x6ze283eAkYmXRXWN7CGGDV2g4lCmgYLLqm4jpk0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790830513; c=relaxed/simple;
	bh=cQVyLls9m4/7tOyNYmSHUPCDkm3adUdgREEljXmlviU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=FumhO/n6JuC7O/AJaRK9nC2dEyWrXwdL063Qo/I0U8iaBFTMFwiQ5i6qSgS+tdwtTJnbsXlfZ312iwTSjTvl8IW03XPUV8fYrmDtBNztW4zBGs3j5bfKnlyq7qDoZ3CxMd3MOXqZJc+FCWFJ3DLPFaMJt6S3t/3hgK1h0dmFSEI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=KAj4fRrp; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="KAj4fRrp"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C64911F00898;
	Thu,  1 Oct 2026 04:55:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790830512;
	bh=cNVv8qsABCpgMfUVoTS3hPlEAkHOEzke3PH5lfYtbO0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=KAj4fRrpnibkcAAwJGdHtVIkBh07e+iUog4qGDjshMUnCXOe/khvZzYhMj+LddBe1
	 OsmG5XYRSIV/IGQOHK276fX8DSHEhcSS2gcBo0frGMcSPEMIcNcjC1zV/q9BUp4PAf
	 lsmvsuvf7OWTyNZL0FlnRVeajPKm3Qd2pDAM1BTBKLHM44IX22WJdV8XJ864oAed6F
	 I+2GIT9hZIwvLww1EIMibLYL1XmmJQdeCMKaT/D1Phz+e3KgvsapA6uKJ99x/9sDYB
	 0ul2J9Gx2LYUcTFUTx+cW+5Ar2+GP4Clv/Kmh4t/+mWkDDL+9QwYrdcrOScepCKq2E
	 I9na029YcXVcA==
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: hch@lst.de,
	linux-nfs@vger.kernel.org
Subject: [PATCH v3 7/9] NFSD: add tracing for how direct-mode READ and WRITE are serviced
Date: Thu,  1 Oct 2026 00:55:00 -0400
Message-ID: <20261001045502.48381-8-snitzer@kernel.org>
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

When io_cache_read or io_cache_write selects a direct I/O mode, a
request may still be serviced with DONTCACHE buffered or normal
buffered I/O, and a WRITE may be split into up to three segments that
each take a different path depending on the request's offset/length
alignment, the payload's memory alignment, the filesystem's
FOP_DONTCACHE support and direct_misaligned_dontcache.  Until now the only visibility was
nfsd_{read,write}_direct for O_DIRECT and nfsd_{read,write}_vector for
everything else, so the DONTCACHE and cached buffered cases were
indistinguishable and the reason a WRITE was not issued as direct I/O
was not recorded at all.

Add:

 - nfsd_write_dio_split, emitted once per direct-mode WRITE before any
   segment is issued.  It records the advertised offset and memory
   alignments, the payload's offset within its first page, the start,
   middle and end segment sizes, the number of segments issued, a
   disposition naming the path taken (direct, no_alignment, too_small,
   no_middle, mem_misaligned), and whether the buffered segments were
   issued IOCB_DONTCACHE.

 - nfsd_write_dontcache and nfsd_read_dontcache, emitted for WRITE
   segments and READs serviced with IOCB_DONTCACHE.  nfsd_write_vector
   and nfsd_read_vector now fire only for normal buffered I/O.

The disposition enum lives in vfs.h so trace.h can reference it.

Document the new events in nfsd-io-modes.rst, including the iomap
iomap_dio_invalidate_fail event that reveals an O_DIRECT segment which
the filesystem silently serviced with buffered I/O.

Assisted-by: Claude:claude-fable-5-1
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 .../filesystems/nfs/nfsd-io-modes.rst         | 34 +++++++-
 fs/nfsd/trace.h                               | 85 +++++++++++++++++++
 fs/nfsd/vfs.c                                 | 48 ++++++++---
 fs/nfsd/vfs.h                                 | 14 +++
 4 files changed, 166 insertions(+), 15 deletions(-)

diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentation/filesystems/nfs/nfsd-io-modes.rst
index 683e3a81d4de1..11938caee14ca 100644
--- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
+++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
@@ -175,21 +175,49 @@ Misaligned WRITE:
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
+    the sizes of the start, middle and end segments, the number of
+    segments issued, and a disposition::
+
+      direct          the aligned middle segment uses O_DIRECT
+      mem_misaligned  payload memory is misaligned; not split
+      no_alignment    the filesystem advertises no DIO alignment; not split
+      too_small       smaller than the larger alignment; not split
+      no_middle       no aligned middle, or one smaller than
+                      direct_misaligned_num_pages; not split
+
+    dontcache=1 means the buffered segments were DONTCACHE: the start and
+    end segments of a direct WRITE, or the whole of one that was not
+    split.
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
index ad106d627fe72..89b1962dacfb1 100644
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
@@ -508,11 +510,94 @@ DEFINE_NFSD_IO_EVENT(write_start);
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
+ * nfsd_write_dio_split - how a direct-mode WRITE was split
+ *
+ * Emitted once per direct-mode WRITE, before any segment is issued.
+ * @prefix, @middle and @suffix are zero when not computed.  @mem_offset
+ * is the offset of the payload within its first page.  The DONTCACHE
+ * bit arrives in @disposition because a tracepoint takes at most twelve
+ * arguments.
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
index 5a54ef664da43..ec52c67c4380d 100644
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
@@ -1344,7 +1347,8 @@ nfsd_write_dio_boundary_complete(struct file *file, loff_t pos)
 }
 
 static unsigned int
-nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
+nfsd_write_dio_iters_init(struct svc_rqst *rqstp, struct svc_fh *fhp,
+			  struct nfsd_file *nf, struct bio_vec *bvec,
 			  unsigned int nvecs, struct kiocb *iocb,
 			  unsigned long total,
 			  struct nfsd_write_dio_seg segments[3])
@@ -1352,7 +1356,8 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	u32 offset_align = nf->nf_dio_offset_align;
 	loff_t prefix_end, orig_end, middle_end;
 	u32 mem_align = nf->nf_dio_mem_align;
-	size_t prefix, middle, suffix;
+	size_t prefix = 0, middle = 0, suffix = 0;
+	enum nfsd_write_dio_disposition disposition;
 	loff_t offset = iocb->ki_pos;
 	unsigned int dontcache_flags = 0;
 	unsigned int buffered_flags;
@@ -1368,9 +1373,14 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	 * If alignments are not available, the write is too small,
 	 * or no alignment can be found, fall back to buffered I/O.
 	 */
-	if (unlikely(!mem_align || !offset_align) ||
-	    unlikely(total < max(offset_align, mem_align)))
+	if (unlikely(!mem_align || !offset_align)) {
+		disposition = NFSD_WRITE_DIO_NO_ALIGN;
 		goto no_dio;
+	}
+	if (unlikely(total < max(offset_align, mem_align))) {
+		disposition = NFSD_WRITE_DIO_TOO_SMALL;
+		goto no_dio;
+	}
 
 	prefix_end = round_up(offset, offset_align);
 	orig_end = offset + total;
@@ -1382,8 +1392,10 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 
 	if (!middle ||
 	    ((prefix || suffix) &&
-	     middle < PAGE_SIZE * nfsd_direct_misaligned_num_pages))
+	     middle < PAGE_SIZE * nfsd_direct_misaligned_num_pages)) {
+		disposition = NFSD_WRITE_DIO_NO_MIDDLE;
 		goto no_dio;
+	}
 
 	if (prefix) {
 		nfsd_write_dio_seg_init(&segments[nsegs], bvec,
@@ -1402,10 +1414,13 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	 * the first bvec, all subsequent bvecs start at bv_offset zero
 	 * (page-aligned). Therefore, only the first bvec is checked.
 	 */
-	if (iov_iter_bvec_offset(&segments[nsegs].iter) & (mem_align - 1))
+	if (iov_iter_bvec_offset(&segments[nsegs].iter) & (mem_align - 1)) {
+		disposition = NFSD_WRITE_DIO_MEM_MISALIGNED;
 		goto no_dio;
+	}
 	/* In case the file system falls back to buffered I/O (-ENOTBLK). */
 	segments[nsegs++].flags |= IOCB_DIRECT | dontcache_flags;
+	disposition = NFSD_WRITE_DIO_DIRECT;
 
 	if (suffix) {
 		nfsd_write_dio_seg_init(&segments[nsegs], bvec, nvecs, total,
@@ -1413,8 +1428,7 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 		segments[nsegs].flags |= buffered_flags;
 		segments[nsegs++].boundary = !!buffered_flags;
 	}
-
-	return nsegs;
+	goto out;
 
 no_dio:
 	/*
@@ -1426,7 +1440,14 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
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
 
 static noinline_for_stack int
@@ -1446,8 +1467,8 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	sync = kiocb->ki_flags & IOCB_DSYNC;
 	datasync = !(kiocb->ki_flags & IOCB_SYNC);
 
-	nsegs = nfsd_write_dio_iters_init(nf, rqstp->rq_bvec, nvecs,
-					  kiocb, *cnt, segments);
+	nsegs = nfsd_write_dio_iters_init(rqstp, fhp, nf, rqstp->rq_bvec,
+					  nvecs, kiocb, *cnt, segments);
 
 	*cnt = 0;
 	for (i = 0; i < nsegs; i++) {
@@ -1455,6 +1476,9 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
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
index 38f7d36bd4da2..4b352a48a8af2 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -229,4 +229,18 @@ __be32		nfsd_permission(struct svc_cred *cred, struct svc_export *exp,
 
 void		nfsd_filp_close(struct file *fp);
 
+/*
+ * The path nfsd_write_dio_iters_init() took for a direct-mode WRITE.
+ * NFSD_WRITE_DIO_DONTCACHE is ORed in when its buffered segments carry
+ * IOCB_DONTCACHE.
+ */
+enum nfsd_write_dio_disposition {
+	NFSD_WRITE_DIO_DIRECT,
+	NFSD_WRITE_DIO_MEM_MISALIGNED,
+	NFSD_WRITE_DIO_NO_ALIGN,
+	NFSD_WRITE_DIO_TOO_SMALL,
+	NFSD_WRITE_DIO_NO_MIDDLE,
+	NFSD_WRITE_DIO_DONTCACHE = 0x80,
+};
+
 #endif /* LINUX_NFSD_VFS_H */
-- 
2.52.0

