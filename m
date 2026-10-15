Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B68944A441F
	for <linux-nfs@vger.kernel.org>; Thu, 15 Oct 2026 23:33:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792107199; cv=none; b=NYLSpSizxvtcOmjhJLck7Ig5oN7He4YkL9bWpgRKG2YikBG98r02F8zfedLy7oLNycMe4zJCPq3MiXLTb2p2sB21LFN69mEos213Xpm04TUXZLDDDGkLD6Ct3VHKNz8zGm63wLkTYebktAFwxJZoTHfTiN98gsYJQbgKsv2oZTo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792107199; c=relaxed/simple;
	bh=QqBUav8oXeue5ROG8hZcMqVSL4lem2lZepOpScjxtOo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=AeNd0tPq0vastx4w3kxxfKrCdUAjyxJgbF4KvVsCoEQW1ZA9SY8Bf50ld9GC2cKn00Y/OGpUP0Jg1gpP+Qpn69PEPQPAsqJhTJbYDOMcsZ0k9+jwyW2NupWrWgZwlYuiJu1rtnq1qs/VWaZ02U+jQAo7FRnc4zdb/pTWINfGRXg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=mfPATXj0; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="mfPATXj0"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2DD9B1F000C4;
	Thu, 15 Oct 2026 23:33:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792107198;
	bh=GBemQGCyU69s/WwVOcpeFu3LvfmHsaYEii5qBAWj8sU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=mfPATXj0eeL7I/tBnomc8jXLBJvcptUsUIIYEFBrrlRLnm4cvc3GaA2dbhlVLw3qL
	 dEijXgXG8BD4+HA8/PAMwN4hhY7gzJQDkiTqay9tCJV6MWYSn4V0f2LdHrZj4CzHZc
	 f3F6cmfNIPgyVlqoMeUk77YI/V+xuyrbdteztkeKJ2pU1cJ0xoXYTRzyx6MCLb/4lS
	 HQ9eiMzmnITZlfJOLi9FrFQRV8mut60fZzLLONV8Gcel2gBPYG7GMiPchDk30Zjw1u
	 OxZBpnYqSmEhuSydt+VBWsTQcVJUCydlaBbeQnnax0DzOsHxjMK+u7IKCOZfHkCtRi
	 CeiNr35uGOLgQ==
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
Subject: [PATCH v4 06/10] NFSD: persist a synchronous direct-mode WRITE once, after all of its segments
Date: Thu, 15 Oct 2026 19:33:05 -0400
Message-ID: <20261015233309.42999-7-snitzer@kernel.org>
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

nfsd_direct_write() may issue a WRITE as up to three segments: a
buffered prefix, a direct middle and a buffered suffix.  For a
FILE_SYNC or DATA_SYNC WRITE the kiocb carries IOCB_DSYNC and every
segment inherits it, so generic_write_sync() runs a range fsync after
each segment: up to three cache flushes and log forces per WRITE.

Strip IOCB_DSYNC and IOCB_SYNC from the per-segment flags of a split
WRITE, and of an unsplit buffered WRITE, and persist the WRITE once with
vfs_fsync_range() over the bytes actually written, after the last
segment.  Durability is unchanged: the reply is not sent until the
fsync completes, and datasync mirrors the previous per-segment choice
(IOCB_SYNC present means metadata too).  An fsync failure is returned
like a write failure.

A WRITE issued whole as direct I/O keeps its flags: iomap already
completes it in one step, and can complete a DATA_SYNC overwrite of
allocated blocks with FUA writes and no cache flush.

Besides the fewer flushes, the sync now runs after the last segment is
written.  A later commit relies on that order: it marks the page shared
with a neighbouring WRITE for dropping only after writing it, and the
WRITE's own fsync is then the writeback that drops the page.

Assisted-by: LLM
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 .../filesystems/nfs/nfsd-io-modes.rst         |  4 +++-
 fs/nfsd/vfs.c                                 | 20 ++++++++++++++++++-
 2 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentation/filesystems/nfs/nfsd-io-modes.rst
index 90bf1038453cc..c1cc974640cfe 100644
--- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
+++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
@@ -141,7 +141,9 @@ Misaligned WRITE:
     has no effect on the O_DIRECT segment unless the filesystem services
     it with buffered IO instead, as XFS does when it cannot invalidate
     page cache that overlaps the segment. The iomap_dio_invalidate_fail
-    trace event reports such a fallback.
+    trace event reports such a fallback. A split FILE_SYNC or DATA_SYNC
+    WRITE is persisted once, after all of its segments are written, not
+    once per segment.
 
     If NFSD does not split a misaligned WRITE, it issues the whole WRITE
     as a single DONTCACHE buffered IO (normal buffered IO if the
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 7e65328de7c86..249358256d2f5 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1426,16 +1426,27 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 {
 	struct nfsd_write_dio_seg segments[3];
 	struct file *file = nf->nf_file;
+	loff_t start = kiocb->ki_pos;
 	unsigned int nsegs, i;
+	int sync_flags;
 	ssize_t host_err;
 	size_t expected;
 
 	nsegs = nfsd_write_dio_iters_init(nf, rqstp->rq_bvec, nvecs,
 					  kiocb, *cnt, segments);
 
+	/*
+	 * Persist a synchronous WRITE once, after all of its segments.  A
+	 * WRITE issued whole as direct I/O keeps IOCB_DSYNC, so iomap can
+	 * still complete a DATA_SYNC overwrite with FUA writes.
+	 */
+	sync_flags = kiocb->ki_flags & (IOCB_DSYNC | IOCB_SYNC);
+	if (nsegs == 1 && (segments[0].flags & IOCB_DIRECT))
+		sync_flags = 0;
+
 	*cnt = 0;
 	for (i = 0; i < nsegs; i++) {
-		kiocb->ki_flags = segments[i].flags;
+		kiocb->ki_flags = segments[i].flags & ~sync_flags;
 		if (kiocb->ki_flags & IOCB_DIRECT)
 			trace_nfsd_write_direct(rqstp, fhp, kiocb->ki_pos,
 						segments[i].iter.count);
@@ -1453,6 +1464,13 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			break;	/* partial write */
 	}
 
+	if (sync_flags && *cnt) {
+		host_err = vfs_fsync_range(file, start, start + *cnt - 1,
+					   !(sync_flags & IOCB_SYNC));
+		if (host_err < 0)
+			return host_err;
+	}
+
 	return 0;
 }
 
-- 
2.52.0

