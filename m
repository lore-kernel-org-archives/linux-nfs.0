Received: from mail-qk2-f39.google.com (mail-qk2-f39.google.com [74.125.230.231])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9136E5581FD
	for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 17:34:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.230.231
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790703277; cv=none; b=NGKfslZWDgY2pfaSs8FJcTsQpSn5d/rvcV5BhKIgY7uDpEdkli5Gvq3TBgTHtRymBTJ89X46PlaBMZY5fRbPl69ZAohdNdxSjT+u9PjN4pTfih8dT8Nvi0aWGlGHB91EI1n5c1Duyrjo/iakua4cbWliJ3kzUY5f3FvHF8mzBE8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790703277; c=relaxed/simple;
	bh=j4eixhClnB96LsDsWT+4Ju1kUQv+7tFtNIPbLjkLJf4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=c9fptBnm6Qzt1h1gFLKvMueIu5hT+nICVSDo9kzrVOmpVFlBZIL3vByjhTH0gcUsOmn+tsIhcj7DsiKjPlfAeLaezoiGYlmkh9E/TX64p+fDOEKl8Dubncg+tdiVZSMdxPY0RM/kyv1a6Fb56fo8XztjZpSxK8cvv+4ipIL2xfI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=cZ2uQhLD; arc=none smtp.client-ip=74.125.230.231
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="cZ2uQhLD"
Received: by mail-qk2-f39.google.com with SMTP id d75a77b69052e-5333294b8a1so36186541cf.2
        for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 10:34:35 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1790703274; x=1791308074; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=cQG/PfyzVLihwaxdaoB9/dWldkFsYMu36HU0oZdvBjk=;
        b=cZ2uQhLDge/MefWzi7ftdm2I01Tvl5iC3Huuc5skUEMrKyWta8ceZoG+rGzxT8jPUC
         FvTQWW5DOIBAkSuhtjTOjro95xWgH289jkDjfOxAL8OuvuDguT81asKaSaoW1pMf8D3O
         mnOXcMTuZ+/w+CsZ+OA0CVXp/rz7jWbZlwM3JzYsr8HWhPvFWEH/z4kCE6h5stoOwtOC
         XxvS4+9R6rc/2sQpi9n4BIkRqwjb2eJv9VW8kydKapLL1EMLuEgM8zQVlEx+mz+fCyJ7
         9hH5vPqYuOvgIc/MguQxMi3ESt3aYyyluO+quXr7PAQAS59g+hBl0dRznxy7FIa/shDK
         h0kQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790703274; x=1791308074;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=cQG/PfyzVLihwaxdaoB9/dWldkFsYMu36HU0oZdvBjk=;
        b=p2Q8FcEy0h4jtMbu431DoCU8LbsTsggQBO4eA6iajrjrGG64XjEWiIUTO04nE6vvQk
         B9YAG+0b5Psl1jAblE+aylNueXp7d69Dl/rE1oWNe+R+j3J7tgs8PpxS3prUblnMsipE
         F1YKou9cwanMLPep1HmqohXQ+52PrmP+CFoc1vJzzXs7tzKXEsyVMmKHNSJXkZzaZjOG
         s8zfUkj9uNHsbTm7mB6VZq5uRjhLwReqfhamdu7mLrPjFYdg2XaccD2PlMzpM2NCICgx
         nFIaICgMCUiJqYMsKvV2wDCS4iewd/TCUqeo4gYVrJH9PvrBVhz5CJ3uNRSXfeNomO54
         utXQ==
X-Gm-Message-State: AFuF++lcBK0DdFY5JcQn7goiiv0DNawQJVkRSMcntAshTeMr8DWVosGm
	jHcuOg5yTpGZV4oAmdu6+jEggFaeKpVKAY+4IhWhiYFq6PFxd6sKxUYeX/WolTPbti4=
X-Gm-Gg: AYBFou29v3oFJmW2TZAWUJj6U28KXfABYHmsp5U9vogxlm3/21qzd5ufcIQoPDKKuC/
	URhoREHcEThNCPYqKSk5iygSS4SOiiDTdFFXJd91z0n8E5geSNvoxlPhOj54w8DRlAgWYGBRCDf
	Chal/t+U42CYllDo77SUC+klitnb57WIhpwYz6oTOoD6TXKIM07x/86hgZLqb+zU8ivKNn9BgzQ
	Poyv4Yf7aFNwP7AnOuUL4L9emjhr0bZksOs32CSNRcv+f7VhFbpanS2dW0yxttjBpypsseGnAnl
	236FwC66zgbkuJ2hcRYo9t3Rv/K6ZH8xuocs1gxN50Uu1EQhJvGaDHDJlrA3Qxvzc98iJ74wA8Q
	b2njUaGxBGLH7fKmw60YaxMqs0B9lFZWLvw2MVaI5cXgSwi+6ly+FrzwpVhEPzUUcFRiDJ6C0+e
	RbKlI1OFwoaU3g62B4pdKvZGjJm5R4r0rFCiNS/bcKhwEybXEIInRPWAkOh8+SHB0aAuVBWmIcU
	TMJUU+WQt63PhL5tzFdgIYLrpRLzL3E3ozA7USCW8GgSLrutI46NhxfY/lTOryO53CkrKRRuQ==
X-Received: by 2002:ac8:690e:0:b0:533:3af3:43b6 with SMTP id d75a77b69052e-5333af34e63mr177871661cf.38.1790703273996;
        Tue, 29 Sep 2026 10:34:33 -0700 (PDT)
Received: from localhost (pool-68-160-167-46.bstnma.fios.verizon.net. [68.160.167.46])
        by smtp.gmail.com with ESMTPSA id d75a77b69052e-53369c4dfe3sm356181cf.31.2026.09.29.10.34.33
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 29 Sep 2026 10:34:33 -0700 (PDT)
Sender: Mike Snitzer <mike.snitzer@hammerspace.com>
From: Mike Snitzer <snitzer@hammerspace.com>
X-Google-Original-From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 08/10] NFSD: keep boundary page of a split direct-mode WRITE until both writers complete
Date: Tue, 29 Sep 2026 13:34:21 -0400
Message-ID: <20260929173423.16149-9-snitzer@kernel.org>
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

A direct-mode WRITE whose ends are not aligned for direct I/O is split
into a buffered prefix, a direct middle and a buffered suffix, and the
prefix and suffix are issued IOCB_DONTCACHE so their pages are dropped
once written back. The page holding such a segment is shared by exactly
two WRITEs, the one ending in it and the one starting in it, which may
arrive in either order, from different clients, at the same time. If it
is dropped as soon as the first writer's data is written back, the
second has to read the block from disk before it can complete it: one
4 KiB read per WRITE. With many clients interleaving small misaligned
O_DIRECT records into one shared file, that was 0.81 device reads per
record (585 GiB read while writing 8.1 TiB).

Keep the page until both writers have had it, with no state in NFSD and
no knowledge of how clients stripe their I/O. Immediately before a
boundary segment is written, nfsd_write_dio_boundary_claim() puts an
empty folio in the page cache if there is not one there already. The
folio is inserted unmarked, which is what makes this work: a DONTCACHE
write only marks a folio it allocated itself, so neither writer's write
marks this one and it never enters WB_DONTCACHE_DIRTY. That counter is
what the DONTCACHE writeback kick targets, and a boundary page counted
there is written back, and then dropped, in the gap between the two
WRITEs that share it.

The add is atomic, so of two concurrent partners exactly one gets the
folio. The other one finds it (-EEXIST) and is therefore the second of
the two: it completes the page, and once its data is in it
nfsd_write_dio_boundary_complete() marks the folio dropbehind. The mark
has to come after the write, because a clean marked folio is dropped by
whatever writeback completes next, and it has to stay unaccounted,
because counting a folio marked while dirty hands the page straight
back to the kick. Whichever writeback cleans the page then drops it:
the WRITE's own sync for FILE_SYNC and DATA_SYNC, the flusher or the
client's COMMIT for UNSTABLE.

A WRITE that cannot use direct I/O at all (memory-misaligned payload,
or too small for a direct middle) is issued as one buffered DONTCACHE
segment. Its first and last pages are shared with the neighbouring
WRITEs in the same way, and are claimed the same way.

Measured with 32 interleaved writers over an emulated 4Kn NVMe,
io_cache_write=4, direct_misaligned_dontcache=Y, each arm starting from
a freshly made file system. 47008-byte records, which split: 704 device
reads for 42895 WRITEs, against 45144 for 45664 WRITEs with the
mechanism compiled out. 6000-byte records, which never get a direct
middle and so are one buffered segment whose end pages are shared: 385
reads against 196589. The DONTCACHE flusher stays idle in both, and the
pages are dropped: 81 of the written file's 524066 pages are still
resident afterwards.

On a four-server pNFS flexfiles rig, three clients writing 47008-byte
records for 240 s against 640 nfsd threads per server, compared with
the same servers before this change: device reads fall from 0.014-0.015
per record to 0.003, page-cache growth over the write phase falls from
about 11 GiB to 2.9 GiB, and write throughput rises by 2.4% to 4.9%
across NFSD_IO_DIRECT and both stable_how floors, with read throughput
unchanged. Records of that size always take the split path, since their
direct middle is at least 38818 bytes, so the figures are the split
path alone; the whole-WRITE fallback needs records below about 12 KB to
come into play. Keeping every boundary page cached instead, which a
later commit makes possible with a direct_misaligned_dontcache=N
debugfs knob, grows the page cache by about 630 GiB over the same
runs.

Reported-by: Jonathan Flynn <jonathan.flynn@hammerspace.com>
Assisted-by: Claude:claude-opus-5[1m]
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 .../filesystems/nfs/nfsd-io-modes.rst         |  28 ++++
 fs/nfsd/vfs.c                                 | 131 ++++++++++++++++--
 2 files changed, 151 insertions(+), 8 deletions(-)

diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentation/filesystems/nfs/nfsd-io-modes.rst
index 548eca7cdb518..7263570668260 100644
--- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
+++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
@@ -185,6 +185,34 @@ Misaligned WRITE:
     misaligned segments use DONTCACHE buffered IO so that their pages
     are dropped from the page cache once written back.
 
+    A FILE_SYNC or DATA_SYNC WRITE (requested by the client, or imposed
+    as the floor by NFSD_IO_DIRECT_WRITE_FILE_SYNC and
+    NFSD_IO_DIRECT_WRITE_DATA_SYNC) is persisted once, after all of its
+    segments have been written, rather than after each segment.
+
+    The page holding a start or end segment is shared by exactly two
+    WRITEs, the one ending in it and the one starting in it, which may
+    arrive in either order, from different clients, and at the same
+    time. Both segments are issued as DONTCACHE buffered IO, so the page
+    would be dropped as soon as the first writer's data is written back,
+    leaving the second to read it back. Immediately before writing a
+    start or end segment NFSD therefore puts an empty page in the page
+    cache if there is not one already. That page is not marked "drop
+    behind" when it is created, so it does not count towards the
+    DONTCACHE writeback backlog and the writeback kick does not write it
+    back, and drop it, between the two WRITEs that share it.
+
+    Whichever WRITE finds the page already there is the second of the
+    two: it completes the page and marks it "drop behind" once its data
+    is in it, so whichever writeback cleans it afterwards (the WRITE's
+    own sync for FILE_SYNC or DATA_SYNC, the flusher or the client's
+    COMMIT for UNSTABLE) drops it. A WRITE that gets no direct middle at
+    all is issued as a single buffered DONTCACHE segment, and its first
+    and last pages are shared and handled the same way. The retained
+    page cache is the set of half-written boundary pages, which grows
+    with how far concurrent writers drift apart, not with bytes
+    written.
+
     The O_DIRECT middle segment also carries the DONTCACHE flag. It has
     no effect while the IO really is O_DIRECT, but a filesystem may
     decide on its own to service the segment with buffered IO instead
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 827dfe0b5dac7..5fd850a29694f 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1271,6 +1271,8 @@ static int wait_for_concurrent_writes(struct file *file)
 struct nfsd_write_dio_seg {
 	struct iov_iter			iter;
 	int				flags;
+	bool				boundary;	/* prefix or suffix of a split */
+	bool				edges;		/* buffered fallback: partial end pages */
 };
 
 static unsigned long
@@ -1290,6 +1292,73 @@ nfsd_write_dio_seg_init(struct nfsd_write_dio_seg *segment,
 		iov_iter_advance(&segment->iter, start);
 	iov_iter_truncate(&segment->iter, len);
 	segment->flags = iocb->ki_flags;
+	segment->boundary = false;
+	segment->edges = false;
+}
+
+/**
+ * nfsd_write_dio_boundary_claim - claim the page a boundary segment shares
+ * @file: the file being written
+ * @pos: any byte offset within the page
+ *
+ * The page holding a misaligned prefix or suffix is shared by exactly two
+ * WRITEs, the one ending in it and the one starting in it, which may arrive
+ * in either order, from different clients, at the same time.  Put an empty
+ * folio there if there is not one already: it is inserted unmarked, so
+ * neither writer's DONTCACHE write marks it (a DONTCACHE write only marks a
+ * folio it allocated itself) and it never enters WB_DONTCACHE_DIRTY, which
+ * is what would otherwise arm the DONTCACHE writeback kick and have the
+ * flusher write the page back, and drop it, between the two WRITEs.
+ *
+ * The add is atomic, so of two concurrent partners exactly one gets the
+ * folio.  If it cannot be allocated the segment is an ordinary DONTCACHE
+ * write and the page is dropped after writeback as before.
+ *
+ * Return: true if this WRITE is the second of the two and must call
+ * nfsd_write_dio_boundary_complete() once its segment has been written.
+ */
+static bool
+nfsd_write_dio_boundary_claim(struct file *file, loff_t pos)
+{
+	struct address_space *mapping = file->f_mapping;
+	pgoff_t index = pos >> PAGE_SHIFT;
+	gfp_t gfp = mapping_gfp_mask(mapping);
+	struct folio *folio;
+	int err;
+
+	folio = filemap_alloc_folio(gfp, 0, NULL);
+	if (!folio)
+		return false;
+	err = filemap_add_folio(mapping, folio, index, gfp);
+	if (!err) {
+		/* First writer: the page is in place, waiting for the partner. */
+		folio_unlock(folio);
+		folio_put(folio);
+		return false;
+	}
+	folio_put(folio);
+	return err == -EEXIST;
+}
+
+/*
+ * The second writer's data is in the page: mark it so the next writeback
+ * that cleans it drops it.  This must follow the write, because a clean
+ * marked folio is dropped by whatever writeback completes next, and it uses
+ * folio_set_dropbehind() rather than an accounted setter, because counting a
+ * folio marked while dirty arms the DONTCACHE writeback kick and the page is
+ * then written back, and dropped, before its partner has written it.
+ */
+static void
+nfsd_write_dio_boundary_complete(struct file *file, loff_t pos)
+{
+	struct address_space *mapping = file->f_mapping;
+	struct folio *folio;
+
+	folio = __filemap_get_folio(mapping, pos >> PAGE_SHIFT, FGP_DONTCACHE, 0);
+	if (IS_ERR(folio))
+		return;
+	folio_set_dropbehind(folio);
+	folio_put(folio);
 }
 
 static unsigned int
@@ -1348,14 +1417,17 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	}
 
 	/*
-	 * The prefix and suffix are buffered I/O by definition.  Mark them
-	 * uncached when possible so their folios are dropped once written
-	 * back rather than lingering in the page cache.
+	 * The prefix and suffix are buffered I/O by definition.  Each shares
+	 * its page with the neighbouring WRITE; see
+	 * nfsd_write_dio_boundary_claim(), which nfsd_direct_write() calls right
+	 * before issuing each of them, for how the page is held for the
+	 * partner and dropped once both have written it.
 	 */
 	if (prefix) {
 		nfsd_write_dio_seg_init(&segments[nsegs], bvec,
 					nvecs, total, 0, prefix, iocb);
-		segments[nsegs++].flags |= dontcache_flags;
+		segments[nsegs].flags |= dontcache_flags;
+		segments[nsegs++].boundary = !!dontcache_flags;
 	}
 
 	nfsd_write_dio_seg_init(&segments[nsegs], bvec, nvecs,
@@ -1386,16 +1458,23 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	if (suffix) {
 		nfsd_write_dio_seg_init(&segments[nsegs], bvec, nvecs, total,
 					prefix + middle, suffix, iocb);
-		segments[nsegs++].flags |= dontcache_flags;
+		segments[nsegs].flags |= dontcache_flags;
+		segments[nsegs++].boundary = !!dontcache_flags;
 	}
 
 	return nsegs;
 
 no_dio:
-	/* No DIO possible - pack into a single uncached (if possible) segment. */
+	/*
+	 * No DIO possible - pack into a single buffered segment.  Where it
+	 * does not start or end on a page boundary, its first and last pages
+	 * are shared with the neighbouring WRITEs like a prefix or suffix and
+	 * are held the same way (nfsd_write_dio_boundary_claim()).
+	 */
 	nfsd_write_dio_seg_init(&segments[0], bvec, nvecs, total, 0,
 				total, iocb);
 	segments[0].flags |= dontcache_flags;
+	segments[0].edges = !!dontcache_flags;
 	return 1;
 }
 
@@ -1423,8 +1502,8 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	struct nfsd_write_dio_seg segments[3];
 	int floor_iocb_flags = 0;
 	struct file *file = nf->nf_file;
-	loff_t start = kiocb->ki_pos;
-	bool sync, datasync;
+	loff_t start = kiocb->ki_pos, seg_pos, seg_last;
+	bool sync, datasync, complete_first, complete_last;
 	unsigned int nsegs, i;
 	ssize_t host_err;
 	size_t expected;
@@ -1461,9 +1540,45 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 
 		expected = iov_iter_count(&segments[i].iter);
 
+		/*
+		 * Claim the boundary page immediately before writing it, not
+		 * when the WRITE is split. Nothing is held across the write:
+		 * the claim leaves the page in the page cache unmarked, and
+		 * claiming it earlier would give the partner WRITE the time a
+		 * direct middle takes to complete the page and have it
+		 * dropped before this segment writes it.
+		 */
+		seg_pos = kiocb->ki_pos;
+		seg_last = seg_pos + expected - 1;
+		complete_first = false;
+		complete_last = false;
+		if (segments[i].boundary) {
+			complete_first = nfsd_write_dio_boundary_claim(file,
+								       seg_pos);
+		} else if (segments[i].edges) {
+			/*
+			 * A whole-WRITE buffered segment shares its first page
+			 * with the previous WRITE if it does not start on a page
+			 * boundary, and its last page with the next one if it
+			 * does not end on one; a page it covers entirely is its
+			 * own.
+			 */
+			if (seg_pos & ~PAGE_MASK)
+				complete_first = nfsd_write_dio_boundary_claim(
+							file, seg_pos);
+			if (((seg_last + 1) & ~PAGE_MASK) &&
+			    (seg_last >> PAGE_SHIFT) != (seg_pos >> PAGE_SHIFT))
+				complete_last = nfsd_write_dio_boundary_claim(
+							file, seg_last);
+		}
+
 		host_err = vfs_iocb_iter_write(file, kiocb, &segments[i].iter);
 		if (host_err < 0)
 			return host_err;
+		if (complete_first)
+			nfsd_write_dio_boundary_complete(file, seg_pos);
+		if (complete_last)
+			nfsd_write_dio_boundary_complete(file, seg_last);
 		*cnt += host_err;
 		if (host_err < (ssize_t)expected)
 			break;	/* partial write */
-- 
2.52.0

