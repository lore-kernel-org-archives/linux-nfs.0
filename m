Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794510565;
	b=3wMTBuPqoYlrsn6F0MRHKJSm+dC4fWO0tOkynvHG+ftvLJnZH80ub0RcAVT9Yt4UYbKx
	 +o45JdzGrti6X+ij8ab2qMe9T19SYqbh6tj7g5pmSFHg/K0HIgi6wSonv8XSpg/BfHaed
	 c/sNTBEPj1JPGFWspxlMlLC/tvSa6CmhItw2x6vrNs/LaGoFII/nKsX78yPQni2ujOZu8
	 IIvWsUYXm9VjFQolW0qDb9Xfr/P5ttfM+FthKQ8j217hXrsopQYYbouYk2NHqlYCnH0az
	 CPHLtpOXDFeUb/w7AlSsSYvrH/WbOKpmuXXU/2cyxWDvEH3Rl5jNRSMfYVLfIHez74Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794510565;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=5Xh7OUWxH7/Z2MjS4LsAa9wrkIt4sMqjtGquIPmbAwY=;
	b=ziIxBhop9DF7pXHq+L9cgEtzmRmKAoi7rksRbTpwdTjbEfQlKuB1iTMoj5dAw/H7f2XU
	 Vuf/uY+3zCUmqGZgI7ARFJmD0qO0lkeDXgVyWT4QRLvDowhCN8QPbBuW5WFFoW/Vv/GmF
	 RbBl+Y6LdNEUWU0jNYqQEyEEeEZbHgOeaUcJ0Uf/+S7DW8pSSHT6VN39/hMtylgWeQKpw
	 7N81CtvoP1BqBRJYq6uBLKfj9SQGuum5JmPrV2Sc6WrKwM4iaO9kN8brcbxX1Z3+ZyjI2
	 fBQKWVmp7Rzuk0abM1zPJaSwnyK26av9n58BtrD/HLq0HKkF3Wgmfrj54u6gsJUuqzg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=VPtcIKMQ;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 046F9606A881;
	Thu, 12 Nov 2026 19:09:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=VPtcIKMQ
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A60E51F00934;
	Thu, 12 Nov 2026 19:09:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794510564;
	bh=5Xh7OUWxH7/Z2MjS4LsAa9wrkIt4sMqjtGquIPmbAwY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=VPtcIKMQJCty8E1gJW+4pBjqbJ4pE+xqWEZYfqs5lEAvsmCRwKcLOzrTIDpBxH8dF
	 Q0I6fYazf6E3ycfjpWX20yR4/W4uFZsnF81MFjmCqh5xP6UtGkCiapGRPnAetR7FcM
	 aViX7wjl5AHFfgoPelLYuMeaGB8UqoaLEiZRspNLjQPLANfw3tCTKQKLIhQjJvwNGh
	 CxcTS1ut0cm9ynKACGiSO10MW1G2Wm8kZQtvbVEK/Er/LSX0D3XuoY5+zYJG0SLxuI
	 gr1hFh4MiwNGDaaVtR/upg1eY7LPkfZ98dROCzOQLHU6W19Ryl/mTb/9pu9O3jCcWg
	 iqSH9uv0FKIwQ==
From: Mike Snitzer <snitzer@kernel.org>
To: Matthew Wilcox <willy@infradead.org>,
	Jan Kara <jack@suse.cz>,
	linux-mm@kvack.org,
	Christian Brauner <brauner@kernel.org>,
	linux-fsdevel@vger.kernel.org
Cc: Mike Snitzer <snitzer@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	linux-nfs@vger.kernel.org,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: [PATCH v12 7/7] NFSD: drop a shared boundary page only once both WRITEs have written it
Date: Thu, 12 Nov 2026 14:09:10 -0500
Message-ID: <20261112190911.84702-8-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261112190911.84702-1-snitzer@kernel.org>
References: <20261112190911.84702-1-snitzer@kernel.org>
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

NFSD splits a misaligned direct-mode WRITE into a direct middle and
buffered DONTCACHE ends.  Each end covers its first or last unit, the
smallest folio the mapping allows, only partially.  The other WRITE that
covers the rest of that unit shares it.

Issue the buffered ends with IOCB_DONTCACHE_DEFER.  Before writing an
end, ask filemap_dontcache_edge_completes() whether the other WRITE has
written its part of each shared unit.  Once the WRITE is done, complete
those units with filemap_dontcache_edge_complete().  If the client sent
the WRITE as FILE_SYNC or DATA_SYNC, that is after the one
vfs_fsync_range() that NFSD runs over the whole WRITE.  An UNSTABLE
WRITE has no fsync, so its units are completed while still dirty.  A
short write completes a unit only if it wrote its own part of it.

With this commit, 32 interleaved writers of 47008-byte records through
NFSD DIRECT read 0.0001 to 0.0002 blocks per WRITE.  Before, they read
0.99 blocks per WRITE.  FILE_SYNC WRITEs no longer wake the DONTCACHE
writeback kick, where they woke it 23,000 to 65,000 times a run without
IOCB_DONTCACHE_DEFER.  On a four-server pNFS flexfiles rig, the page
cache grew by 2.9 GiB during the write phase instead of about 11 GiB.

47008 bytes is the transfer size of IO500's ior-hard, in which each rank
writes interleaved records to one shared file with O_DIRECT.  The Linux
client sends an O_DIRECT write that fits in one WRITE as FILE_SYNC.

Reported-by: Jonathan Flynn <jonathan.flynn@hammerspace.com>
Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 .../filesystems/nfs/nfsd-io-modes.rst         |  18 +++
 fs/nfsd/vfs.c                                 | 107 ++++++++++++++++--
 2 files changed, 113 insertions(+), 12 deletions(-)

diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentation/filesystems/nfs/nfsd-io-modes.rst
index 28235eceb0c7d..9fd3b929a240c 100644
--- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
+++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
@@ -197,6 +197,24 @@ Misaligned WRITE:
     above. Set it to N for a workload that reads back or rewrites what
     it just wrote.
 
+    The page holding a start or end segment is shared with the other
+    WRITE that covers the rest of the page, which may arrive before,
+    after or at the same time, from any client. So that the second WRITE
+    to such a page does not have to read it back from disk, the page
+    cache keeps a page a DONTCACHE write covers only partially,
+    unmarked, for the write that completes it. NFSD asks, immediately
+    before writing a start or end segment, whether the other WRITE has
+    already written its part; if it has, NFSD marks the page DONTCACHE
+    once its own WRITE, including its fsync, is complete, and the page
+    is dropped. A page that no other WRITE completes, or that the other
+    WRITE writes at the same time, stays cached until it is reclaimed.
+    The first and last pages of a WRITE that is not split are handled
+    the same way.
+
+    None of this applies when the start and end segments are normal
+    buffered IO, or for a filesystem that does not use iomap for
+    buffered writes.
+
 Tracing:
     The nfsd_read_direct trace event marks a READ that NFSD issues as
     O_DIRECT. It records the offset and length the client requested.
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index b0d754142eab5..2ebee92f28da6 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1437,6 +1437,7 @@ static int wait_for_concurrent_writes(struct file *file)
 struct nfsd_write_dio_seg {
 	struct iov_iter			iter;
 	int				flags;
+	bool				claim;		/* completes shared pages */
 };
 
 static unsigned long
@@ -1456,6 +1457,79 @@ nfsd_write_dio_seg_init(struct nfsd_write_dio_seg *segment,
 		iov_iter_advance(&segment->iter, start);
 	iov_iter_truncate(&segment->iter, len);
 	segment->flags = iocb->ki_flags;
+	segment->claim = false;
+}
+
+/* The shared pages a segment completes, and how much of it was written. */
+struct nfsd_write_dio_hold {
+	loff_t	first, last;
+	size_t	first_len;	/* the segment's bytes in its first unit */
+	bool	complete_first, complete_last;
+	size_t	written;
+};
+
+/*
+ * A page that a buffered DONTCACHE segment covers only partially is shared
+ * with the other WRITE that covers the rest of the page.  The page cache keeps
+ * it, unmarked, for the write that completes it; the segment is issued
+ * IOCB_DONTCACHE_DEFER so that this WRITE, not the page cache, marks it, once
+ * the whole WRITE, its fsync included, is complete.  Ask whether the other
+ * WRITE has already written its part immediately before writing @seg: asking
+ * earlier gives the other WRITE time to write its part and find this WRITE's
+ * part missing.
+ */
+static void
+nfsd_write_dio_seg_hold(struct file *file, const struct nfsd_write_dio_seg *seg,
+			loff_t pos, size_t len, struct nfsd_write_dio_hold *hold)
+{
+	struct address_space *mapping = file->f_mapping;
+	size_t unit, last_len;
+	loff_t mask, last_unit;
+	bool one_unit, head, tail;
+
+	hold->first = pos;
+	hold->last = pos + len - 1;
+	hold->complete_first = false;
+	hold->complete_last = false;
+	hold->written = 0;
+	if (!seg->claim || !len)
+		return;
+
+	/* The shared unit is the smallest folio the mapping allows. */
+	unit = mapping_min_folio_nrbytes(mapping);
+	mask = ~(loff_t)(unit - 1);
+	one_unit = (hold->first & mask) == (hold->last & mask);
+	head = hold->first & (unit - 1);
+	tail = (hold->last + 1) & (unit - 1);
+	last_unit = hold->last & mask;
+	last_len = (hold->last & (unit - 1)) + 1;
+
+	hold->first_len = min_t(size_t, len,
+				unit - (hold->first & (unit - 1)));
+	if (head || (one_unit && tail))
+		hold->complete_first =
+			filemap_dontcache_edge_completes(mapping, hold->first,
+							 hold->first_len);
+	if (!one_unit && tail)
+		hold->complete_last =
+			filemap_dontcache_edge_completes(mapping, last_unit,
+							 last_len);
+}
+
+/* Drop the shared pages this WRITE was the second of two to write. */
+static void
+nfsd_write_dio_seg_release(struct file *file,
+			   const struct nfsd_write_dio_hold *hold)
+{
+	struct address_space *mapping = file->f_mapping;
+
+	/* A short write may have stopped inside the first unit. */
+	if (hold->complete_first && hold->written >= hold->first_len)
+		filemap_dontcache_edge_complete(mapping, hold->first);
+	/* A short write did not reach the last unit. */
+	if (hold->complete_last &&
+	    hold->written == hold->last - hold->first + 1)
+		filemap_dontcache_edge_complete(mapping, hold->last);
 }
 
 static unsigned int
@@ -1478,7 +1552,9 @@ nfsd_write_dio_iters_init(struct svc_rqst *rqstp, struct svc_fh *fhp,
 
 	if (nf->nf_file->f_op->fop_flags & FOP_DONTCACHE)
 		dontcache_flags = IOCB_DONTCACHE;
-	buffered_flags = nfsd_direct_misaligned_dontcache ? dontcache_flags : 0;
+	/* NFSD marks their shared pages itself, see nfsd_write_dio_seg_hold() */
+	buffered_flags = nfsd_direct_misaligned_dontcache && dontcache_flags ?
+			 dontcache_flags | IOCB_DONTCACHE_DEFER : 0;
 
 	/*
 	 * Check if direct I/O is feasible for this write request.
@@ -1532,7 +1608,8 @@ nfsd_write_dio_iters_init(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (prefix) {
 		nfsd_write_dio_seg_init(&segments[nsegs], bvec,
 					nvecs, total, 0, prefix, iocb);
-		segments[nsegs++].flags |= buffered_flags;
+		segments[nsegs].flags |= buffered_flags;
+		segments[nsegs++].claim = !!buffered_flags;
 	}
 
 	nfsd_write_dio_seg_init(&segments[nsegs], bvec, nvecs,
@@ -1565,7 +1642,8 @@ nfsd_write_dio_iters_init(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (suffix) {
 		nfsd_write_dio_seg_init(&segments[nsegs], bvec, nvecs, total,
 					prefix + middle, suffix, iocb);
-		segments[nsegs++].flags |= buffered_flags;
+		segments[nsegs].flags |= buffered_flags;
+		segments[nsegs++].claim = !!buffered_flags;
 	}
 	return nsegs;
 
@@ -1574,6 +1652,7 @@ nfsd_write_dio_iters_init(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	nfsd_write_dio_seg_init(&segments[0], bvec, nvecs, total, 0,
 				total, iocb);
 	segments[0].flags |= buffered_flags;
+	segments[0].claim = !!buffered_flags;
 	return 1;
 }
 
@@ -1582,12 +1661,13 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		  struct nfsd_file *nf, unsigned int nvecs,
 		  unsigned long *cnt, struct kiocb *kiocb)
 {
+	struct nfsd_write_dio_hold holds[3];
 	struct nfsd_write_dio_seg segments[3];
 	struct file *file = nf->nf_file;
 	loff_t start = kiocb->ki_pos;
-	unsigned int nsegs, i;
+	unsigned int nsegs, nheld = 0, i;
+	ssize_t host_err = 0;
 	int sync_flags;
-	ssize_t host_err;
 	size_t expected;
 
 	nsegs = nfsd_write_dio_iters_init(rqstp, fhp, nf, rqstp->rq_bvec,
@@ -1617,23 +1697,26 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 					kiocb->ki_flags);
 
 		expected = iov_iter_count(&segments[i].iter);
-
+		nfsd_write_dio_seg_hold(file, &segments[i], kiocb->ki_pos,
+					expected, &holds[nheld]);
 		host_err = vfs_iocb_iter_write(file, kiocb, &segments[i].iter);
 		if (host_err < 0)
-			return host_err;
+			break;
+		holds[nheld++].written = host_err;
 		*cnt += host_err;
 		if (host_err < (ssize_t)expected)
 			break;	/* partial write */
 	}
 
-	if (sync_flags && *cnt) {
+	if (host_err >= 0 && sync_flags && *cnt)
 		host_err = vfs_fsync_range(file, start, start + *cnt - 1,
 					   !(sync_flags & IOCB_SYNC));
-		if (host_err < 0)
-			return host_err;
-	}
 
-	return 0;
+	/* Complete the shared units once the WRITE and its fsync are done. */
+	for (i = 0; i < nheld; i++)
+		nfsd_write_dio_seg_release(file, &holds[i]);
+
+	return host_err < 0 ? host_err : 0;
 }
 
 /**
-- 
2.52.0

