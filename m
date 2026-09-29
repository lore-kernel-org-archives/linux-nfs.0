Received: from mail-qk2-f40.google.com (mail-qk2-f40.google.com [74.125.230.232])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0932F5592EC
	for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 17:34:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.230.232
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790703278; cv=none; b=k0vcrMaCGOfQf8iDLRByYDVsRudJve14VzYkJxWAwbKMtH5xMxZudhTWcmXWWgFFq2CKKAEc4FG377WF2frsGjne6KFE6VJPBliQ71965PUxezj+Hta9Ak1H3hay3hByu2Xe/Qcxq58/8GDfgKkrDWeX31BfupjRa1v10mzIlKo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790703278; c=relaxed/simple;
	bh=ACDy3opzH69ce1LKYi+BHeDfmQ1hDiSwTORTZXz2xds=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=mpt57DcqM9IgRQki6IhaVLFpD276VfYAq7j0kpuWAXZSD4doXlyVF6jyNYVfmNj3p2kRnj0ah5WxzBpL0gVmKNc1rUnsKb0RMdAqJuT7xZsoIcxySwGpd7GVVXoPufGTxhJ7mjbAVDhB8VK+NiZWI4s4M9b5s3L1LhY5Yhl046A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=SLNVfuen; arc=none smtp.client-ip=74.125.230.232
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="SLNVfuen"
Received: by mail-qk2-f40.google.com with SMTP id af79cd13be357-93c5f7af3e1so307686085a.3
        for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 10:34:36 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1790703276; x=1791308076; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=EAnbLKmgvTayOCP5C57/Wbguwy3WJi0dSvcRfLT05S8=;
        b=SLNVfuenHZJgvifnlDLn6prhqVTNoQkkWwi5KHjTBEttZizgfSghVHkq0IaMwR/PD1
         DurlsEnuukW8m/N6XFpANfZoQy8xL1IDdtrk/RfHVRLj3o8zTMwuSBQ9lCY/7zKltPq1
         eXAdqKmoUPrfGIsYFQCXKPZ6P/OUmbqMX6v9ZGdA8oaIwXVYTLM2Y00kWFqDWSvm6szy
         UrYlnJZdhrBSf2fKYeB3Y0FqnaVl0E4umZWG/RWhRO1CfOHOwaduNdCwwwKlmVhaLOl/
         WE/hmMTvmWgCyKKUdkoTj80NySNrOKdENGhR129vqH/2QYR69pxdUh9ODhnT0rZusvO/
         xlXQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790703276; x=1791308076;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=EAnbLKmgvTayOCP5C57/Wbguwy3WJi0dSvcRfLT05S8=;
        b=0IJ7IwS+BKvNPjLM3Hs/jVP6ZKyOk/gR3Myh0kLhxcUlDxBb4fl0oKdUSFoioHrAHd
         Knr3RxwZBCh9PsYGGuIEzVej5JGgfpIrNcxfoSSoD34ueiRDZ5k8S2FKCYS+2OtlS3XV
         t8GLveoNy2BGyCxiSx1UeSkjMjNlyEFAY8gJyG2t8WrMDYx+n1FUe3ZooLeHRo7hrHv7
         ztgjczSZtyhZKdzd7yMvmcsZjOx6y1Li0yWWoc5CKaJB48IEU80Ivms5on2JRgglKZpj
         5UNnuRcR1f85kej3HtRjSE071DPBckQuM4M0PuX/3gbdlMCJkhA2x9ovQhAiJ7atyXO3
         g+CA==
X-Gm-Message-State: AFuF++nSvQCf66czCuDERNJyWQMIfwPCMOONukZWxzGtE1CFSWldm/ng
	vSFLa+ahWcSrLAwX4i2OlQPXyBhCPULmSEQT/WS4bpK2gGcG19/AAB6ZWMyIQSragts=
X-Gm-Gg: AYBFou2YnQzy0Q9KeRFzPh2U4s3oT3FyjxLfSzqtdAJ482P5QwHd7Kb0yJVW/NLl/Ym
	NKOvuSMhz19G6j3kGFg+aw4jHmQPTQf83Hsh2ckxAE1pczeTfFozBiT8epGOsn1Yk7aaBn4/y6I
	j6QAyG3AvMF284bbsnKF9i07GNtstrf8z3hVXRNkYR9SzSixq24X1L1tB8AIO9gbY7lCSmknxOM
	jLlMYhLKpSlhQB5tOeNvHrFCTsbMz0+qy61D937/7k9WAXptLa1JNa+RMXgIWFoBSeuDz2v4niJ
	FcB9ZsdDD+p/3rX7KPBVUrtiqE/HgJVf9rtmD/qNJvi5Z3BX+akZ9QqPXB3mPqizOoJvu2m0lly
	xxWAm+e+D/yxkkG7tSTKLUOeF8L4bNlLkMiHBQNL9JVaHyP7B/OH1HCVHsoRwubaBY8o5P9vKlR
	WojGjicomco0d5ixEZDD35Ca3BkK2o+zJuI+eMtbhf+tBXbOOcbHwCaEeAXKVE7xk6p4ovx5yDF
	b53utNn3/5mep0uO4qKEsC0BiwTyGqOBwHw0y6xvJx2qLdXIQF+XFhlXHlVLpeb4Y9nxTV3SQze
	AuqfVXcM
X-Received: by 2002:a05:620a:44c5:b0:93c:89c4:6531 with SMTP id af79cd13be357-93c9fae40d8mr43210685a.22.1790703275409;
        Tue, 29 Sep 2026 10:34:35 -0700 (PDT)
Received: from localhost (pool-68-160-167-46.bstnma.fios.verizon.net. [68.160.167.46])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-93c9f463f56sm22836485a.14.2026.09.29.10.34.35
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 29 Sep 2026 10:34:35 -0700 (PDT)
Sender: Mike Snitzer <mike.snitzer@hammerspace.com>
From: Mike Snitzer <snitzer@hammerspace.com>
X-Google-Original-From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 09/10] NFSD: add direct_misaligned_dontcache debugfs knob
Date: Tue, 29 Sep 2026 13:34:22 -0400
Message-ID: <20260929173423.16149-10-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20260929173423.16149-1-snitzer@kernel.org>
References: <20260929173423.16149-1-snitzer@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Jonathan Flynn <jonathan.flynn@hammerspace.com>

The parts of a direct-mode WRITE that cannot be direct I/O, the
misaligned prefix and suffix of a split WRITE and the whole WRITE when
it is not split, are issued IOCB_DONTCACHE so their pages are dropped
once written back.  That is the right default for the workloads a direct
mode is chosen for, but it is a policy rather than a requirement: a
workload that reads back what it just wrote, or that keeps rewriting the
same partial pages, is better served by those pages staying in the page
cache.

Add a bool debugfs knob, /sys/kernel/debug/nfsd/direct_misaligned_dontcache
(default Y), to choose between the two:

  Y: IOCB_DONTCACHE when the file system supports it, with a split's
     boundary page kept in the page cache until both WRITEs sharing it
     have written it (nfsd_write_dio_boundary_claim()).
  N: ordinary cached buffered I/O; nothing is claimed or marked, and the
     pages stay until reclaim.

The direct middle and the once-per-WRITE persist are unaffected.  The
knob is sampled once per WRITE, so a change takes effect immediately and
without a remount.  It sits beside io_cache_read and io_cache_write, the
other controls over how NFSD issues its I/O.

Signed-off-by: Jonathan Flynn <jonathan.flynn@hammerspace.com>
[snitzer: documented in nfsd-io-modes.rst]
[snitzer: switched from using modparam to debugfs knob]
Assisted-by: Claude:claude-opus-5[1m]
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 .../filesystems/nfs/nfsd-io-modes.rst         |  9 ++++++
 fs/nfsd/debugfs.c                             | 21 ++++++++++++++
 fs/nfsd/nfsd.h                                |  1 +
 fs/nfsd/vfs.c                                 | 28 ++++++++++++-------
 4 files changed, 49 insertions(+), 10 deletions(-)

diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentation/filesystems/nfs/nfsd-io-modes.rst
index 7263570668260..b2685dfadbffb 100644
--- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
+++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
@@ -213,6 +213,15 @@ Misaligned WRITE:
     with how far concurrent writers drift apart, not with bytes
     written.
 
+    Whether those pages are dropped at all is a policy choice, selected
+    by /sys/kernel/debug/nfsd/direct_misaligned_dontcache (default Y).
+    Write N to issue the start and end segments, and the whole-WRITE
+    fallbacks, as ordinary cached buffered IO: nothing is claimed or
+    marked and the pages stay until reclaim, which suits a workload that
+    reads back or rewrites what it just wrote. The O_DIRECT middle
+    segment is unaffected. The knob is sampled once per WRITE, so a
+    change takes effect immediately.
+
     The O_DIRECT middle segment also carries the DONTCACHE flag. It has
     no effect while the IO really is O_DIRECT, but a filesystem may
     decide on its own to service the segment with buffered IO instead
diff --git a/fs/nfsd/debugfs.c b/fs/nfsd/debugfs.c
index 603a608b03c54..1ae2597b9c34a 100644
--- a/fs/nfsd/debugfs.c
+++ b/fs/nfsd/debugfs.c
@@ -186,6 +186,24 @@ void nfsd_debugfs_exit(void)
  * Default 2.  Not yet tuned by benchmarking.
  */
 
+/*
+ * /sys/kernel/debug/nfsd/direct_misaligned_dontcache
+ *
+ * How a direct-mode WRITE issues the I/O that cannot be direct: the
+ * misaligned start and end of a split WRITE, and the whole WRITE when it
+ * is not split.
+ *
+ * Contents:
+ *   Y: DONTCACHE when the filesystem supports it, with the boundary page
+ *      of a split kept in the page cache only until both WRITEs sharing
+ *      it have written it
+ *   N: ordinary cached buffered IO, left in the page cache until
+ *      reclaim, for A/B comparison against the DONTCACHE path
+ *
+ * Sampled once per WRITE, so it takes effect immediately.  The direct
+ * middle segment is unaffected.
+ */
+
 void nfsd_debugfs_init(void)
 {
 	nfsd_top_dir = debugfs_create_dir("nfsd", NULL);
@@ -201,6 +219,9 @@ void nfsd_debugfs_init(void)
 
 	debugfs_create_u32("direct_misaligned_num_pages", 0644, nfsd_top_dir,
 			   &nfsd_direct_misaligned_num_pages);
+
+	debugfs_create_bool("direct_misaligned_dontcache", 0644, nfsd_top_dir,
+			    &nfsd_direct_misaligned_dontcache);
 #ifdef CONFIG_NFSD_V4
 	debugfs_create_bool("delegated_timestamps", 0644, nfsd_top_dir,
 			    &nfsd_delegts_enabled);
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 135e319e378d4..dff979ac370ba 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -145,6 +145,7 @@ enum {
 extern u64 nfsd_io_cache_read __read_mostly;
 extern u64 nfsd_io_cache_write __read_mostly;
 extern u32 nfsd_direct_misaligned_num_pages __read_mostly;
+extern bool nfsd_direct_misaligned_dontcache __read_mostly;
 
 extern int nfsd_max_blksize;
 
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 5fd850a29694f..7896e2e6c5855 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -54,6 +54,7 @@ bool nfsd_disable_splice_read __read_mostly;
 u64 nfsd_io_cache_read __read_mostly = NFSD_IO_BUFFERED;
 u64 nfsd_io_cache_write __read_mostly = NFSD_IO_BUFFERED;
 u32 nfsd_direct_misaligned_num_pages __read_mostly = 2;
+bool nfsd_direct_misaligned_dontcache __read_mostly = true;
 
 /**
  * nfserrno - Map Linux errnos to NFS errnos
@@ -1373,16 +1374,21 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	size_t prefix, middle, suffix;
 	loff_t offset = iocb->ki_pos;
 	unsigned int dontcache_flags = 0;
+	unsigned int buffered_flags;
 	unsigned int nsegs = 0;
 
 	if (nf->nf_file->f_op->fop_flags & FOP_DONTCACHE)
 		dontcache_flags = IOCB_DONTCACHE;
+	/* Buffered segments follow the knob; the direct middle does not. */
+	buffered_flags = READ_ONCE(nfsd_direct_misaligned_dontcache) ?
+			 dontcache_flags : 0;
 
 	/*
 	 * Whenever direct I/O cannot be used for the WRITE, fall back to a
-	 * single DONTCACHE buffered I/O when the file system supports it, so
-	 * the WRITE's pages are dropped from the page cache once written
-	 * back, and to a single cached buffered I/O otherwise.
+	 * single DONTCACHE buffered I/O when the file system supports it (and
+	 * nfsd_direct_misaligned_dontcache is set), so the WRITE's pages are
+	 * dropped from the page cache once written back, and to a single
+	 * cached buffered I/O otherwise.
 	 *
 	 * If the file system doesn't advertise any alignment requirements,
 	 * don't try to issue direct I/O at all.
@@ -1421,13 +1427,15 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	 * its page with the neighbouring WRITE; see
 	 * nfsd_write_dio_boundary_claim(), which nfsd_direct_write() calls right
 	 * before issuing each of them, for how the page is held for the
-	 * partner and dropped once both have written it.
+	 * partner and dropped once both have written it.  With
+	 * nfsd_direct_misaligned_dontcache=N both are plain cached writes and
+	 * nothing is held or dropped: the pages stay until reclaim.
 	 */
 	if (prefix) {
 		nfsd_write_dio_seg_init(&segments[nsegs], bvec,
 					nvecs, total, 0, prefix, iocb);
-		segments[nsegs].flags |= dontcache_flags;
-		segments[nsegs++].boundary = !!dontcache_flags;
+		segments[nsegs].flags |= buffered_flags;
+		segments[nsegs++].boundary = !!buffered_flags;
 	}
 
 	nfsd_write_dio_seg_init(&segments[nsegs], bvec, nvecs,
@@ -1458,8 +1466,8 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	if (suffix) {
 		nfsd_write_dio_seg_init(&segments[nsegs], bvec, nvecs, total,
 					prefix + middle, suffix, iocb);
-		segments[nsegs].flags |= dontcache_flags;
-		segments[nsegs++].boundary = !!dontcache_flags;
+		segments[nsegs].flags |= buffered_flags;
+		segments[nsegs++].boundary = !!buffered_flags;
 	}
 
 	return nsegs;
@@ -1473,8 +1481,8 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	 */
 	nfsd_write_dio_seg_init(&segments[0], bvec, nvecs, total, 0,
 				total, iocb);
-	segments[0].flags |= dontcache_flags;
-	segments[0].edges = !!dontcache_flags;
+	segments[0].flags |= buffered_flags;
+	segments[0].edges = !!buffered_flags;
 	return 1;
 }
 
-- 
2.52.0

