Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A93653ECBED
	for <linux-nfs@vger.kernel.org>; Thu,  1 Oct 2026 04:55:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790830510; cv=none; b=VuNUw0tdpltIcf4FFWiU9GmSL7lvZMPilLB6jIA0szeErF53iArJq0CWgaUoV1CX3LzeYxEf1xBmLPfD0pHQzFCP+XAlv5SeHL3oQAd6tKg5+PYv/8Ls0puLcax7MKpKPp874AZLoWfp5VStu2BL0U9ZGctRq5Rtaz3XfEH1p0o=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790830510; c=relaxed/simple;
	bh=2Rii6wmIEFM6Jl8PimxsUfYiAl62lbArIY0E35LSkyw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Ri8cpvs/5fFyjRcTXfNDDeLXwNeafERN2BTirUPiqxsi7dxw0BkOPpWkitvOPPfRbtru6126C4LHn1Ak4MYKi8H/B1bfHCSkUSjweRWESjQAdHaz1Y3Wdf74kMjD07QhZv0AeXhJQOJC9gkHUMYwjFnx7xfHH03zrjgWwY+dCe0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Iz1VH9c3; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Iz1VH9c3"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5F7271F00898;
	Thu,  1 Oct 2026 04:55:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790830509;
	bh=m7qzs1V5yaDDqQNx9UNrsw68OMi87V5O7cbJ79Qwc7o=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Iz1VH9c3bl6XcOjR8c3h0dltwVEahGRF0w2gZ08bEHONPgwHk5P94SBNYUB4F/jF+
	 yl6AZ5Wl1ze4tL/EYawXX2bHQP+QKUDT4z0QDWlbASI+ZpFJOZ5dQYnMPOIlCmNgp2
	 JnC6q3Ey3FpN2h1THDrLv4xRrxzquFdfFy/GWnshEN1OJRWU6CEKFIAmIqsaq8BOgm
	 18UnxNMbAr/loAzLkXoPIeBeleZA/LHwdUNata6+f0qlO6I8Z6tHnUU1m3pOH/JiAw
	 yV/+JsjwCbb2yEe+K8c2jYFov3o7LpMTNqYCIo/9O6lVG8Us1z8y6fQaeq5AejClji
	 YEjvTUPjmDOwA==
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: hch@lst.de,
	linux-nfs@vger.kernel.org
Subject: [PATCH v3 5/9] NFSD: persist a synchronous direct-mode WRITE once, after all of its segments
Date: Thu,  1 Oct 2026 00:54:58 -0400
Message-ID: <20261001045502.48381-6-snitzer@kernel.org>
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

nfsd_direct_write() may issue a WRITE as up to three segments: a
buffered prefix, a direct middle and a buffered suffix.  For a
FILE_SYNC or DATA_SYNC WRITE the kiocb carries IOCB_DSYNC and every
segment inherits it, so generic_write_sync() runs a range
fsync after each segment: up to three cache flushes and log forces per
WRITE, and each one writes back and drops the boundary page it just
touched.

Strip IOCB_DSYNC and IOCB_SYNC from the per-segment flags and persist
the WRITE once with vfs_fsync_range() over the bytes actually written,
after the last segment.  Durability is unchanged: the reply is not sent
until the fsync completes, and datasync mirrors the previous per-segment
choice (IOCB_SYNC present means metadata too).  An fsync failure is
returned like a write failure.

Besides the fewer flushes, this puts the sync under NFSD's control,
which a later commit uses to keep the boundary pages of a split WRITE
cached until the partner WRITE completes them.

Assisted-by: Claude:claude-fable-5-1
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 Documentation/filesystems/nfs/nfsd-io-modes.rst |  3 +++
 fs/nfsd/vfs.c                                   | 15 ++++++++++++++-
 2 files changed, 17 insertions(+), 1 deletion(-)

diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentation/filesystems/nfs/nfsd-io-modes.rst
index 12679001c7bec..686b106b96f1b 100644
--- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
+++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
@@ -152,6 +152,9 @@ Misaligned WRITE:
     - the WRITE payload is not aligned in memory to the block device's
       dma_alignment, so the middle cannot be O_DIRECT either.
 
+    A FILE_SYNC or DATA_SYNC WRITE is persisted once after all of its
+    segments are written, not once per segment.
+
     Writing N to /sys/kernel/debug/nfsd/direct_misaligned_dontcache
     (default Y) issues the start and end segments, and a WRITE that is
     not split, as normal buffered IO instead of DONTCACHE, which suits a
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index e1d294aceb6bd..592415900403f 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1383,16 +1383,22 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 {
 	struct nfsd_write_dio_seg segments[3];
 	struct file *file = nf->nf_file;
+	loff_t start = kiocb->ki_pos;
+	bool sync, datasync;
 	unsigned int nsegs, i;
 	ssize_t host_err;
 	size_t expected;
 
+	/* Persist a synchronous WRITE once, after all of its segments. */
+	sync = kiocb->ki_flags & IOCB_DSYNC;
+	datasync = !(kiocb->ki_flags & IOCB_SYNC);
+
 	nsegs = nfsd_write_dio_iters_init(nf, rqstp->rq_bvec, nvecs,
 					  kiocb, *cnt, segments);
 
 	*cnt = 0;
 	for (i = 0; i < nsegs; i++) {
-		kiocb->ki_flags = segments[i].flags;
+		kiocb->ki_flags = segments[i].flags & ~(IOCB_DSYNC | IOCB_SYNC);
 		if (kiocb->ki_flags & IOCB_DIRECT)
 			trace_nfsd_write_direct(rqstp, fhp, kiocb->ki_pos,
 						segments[i].iter.count);
@@ -1410,6 +1416,13 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			break;	/* partial write */
 	}
 
+	if (sync && *cnt) {
+		host_err = vfs_fsync_range(file, start, start + *cnt - 1,
+					   datasync);
+		if (host_err < 0)
+			return host_err;
+	}
+
 	return 0;
 }
 
-- 
2.52.0

