Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.222.176
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792533839;
	b=Y0nVRWLKX8Fm6UwYLX04MHsqI+UB3d/wacZWskdQniCqaT9f7oI4ltyu4ODglhYIZgQ1
	 xjysYrN/XBLmaZtFqQ+k1OMrF1I3ZINQDfHENf9IUVQMrMUTGBId3eAUeksxbMu4UCyw7
	 3/Mj4+yq39eew8AGngar9MKGmdVmw3kMjIKh7sVBkRORzYJViEsBgTaL35zeQUkIHH7ht
	 xFhaR9CN1HxLRsXP3PxuaY/VsDRYYnZkFozoq0siUqAJURPfcCxfuUycE0oauIXsR2rEk
	 S+yztYiGGn35DeDZpEWyCJJ9xKSiox51msn9BnD5geD0EGAWVWTLCWtHbdwOE5uVPTg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792533839;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:Sender:From:
	 X-Google-Original-From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=fUJUf2XHU25x2noX8Uf7Y4DKlKoCjH6yK/uRcd1adlc=;
	b=PL+zhdNirSu1C9uh6fnL3ruE4+9frLlllF1IfTDJ1sZ6wOdIsjDpmzQgbGTBr+vw+BHd
	 EF4bmSEftdqrgaYckNTMwcpy/8lubx6xcE7sEyztbkQ+hrZ2H1SA1E9DRuS3kqYpjU8vI
	 OflHaVZvX3F4fGQSc1vjLJcS9mb8H1QDWhoknw5dG3Jh/B5wkfqsZt8C/0Y1tJsBZrFq9
	 KaiOmybz0WQwhB/RIGZqBjcFXTkbvx8+tmlWOgWEWn7uaW2hiZfbMucRPeBozXjjTi5L7
	 XGdG30U6cJsZsMH9esfPedQDi9rlLXToAdtWQx1Qy/ZWyFgXwGaG8kcJAvUy+Z39+lA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=S87XOc+f;
	arc=none smtp.remote-ip=209.85.222.176
Received: from mail-qk1-f176.google.com (mail-qk1-f176.google.com [209.85.222.176])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2B240606A321
	for <linux-nfs@vger.kernel.org>; Tue, 20 Oct 2026 22:03:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 2B240606A321
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=S87XOc+f
Received: by mail-qk1-f176.google.com with SMTP id af79cd13be357-93f22a8515eso9063585a.2
        for <linux-nfs@vger.kernel.org>; Tue, 20 Oct 2026 15:03:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1792533835; x=1793138635; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=fUJUf2XHU25x2noX8Uf7Y4DKlKoCjH6yK/uRcd1adlc=;
        b=S87XOc+fpSc0QHOrR7CVqvEHtxJyIa52EU8shL7lwcNsZNWxX1O+6/LgKt7OD/NtlT
         O0gPLighqYIcvpXUU53TiWSizaBEblR8gfEXdg/1/Q/AYrq7pNoMzrfSYNIgC+0VM/d5
         Ey+r5BcchPFDVtGuMFtfr7vLfkZiZvB48WdJCoSkTdfP/kjMNa9fLQ5US4wb97ZmZL+N
         Y5L+MogARPSsmiiaEUXoOkysybzSwjoqP8emF3lWCOG/6DwTWG2d4HNx7i+KvwW4zLzC
         9MJLjr6lWWD70xOJPNf4mRjElEVr6NQ8762XZNTShKdrk0Sc66VuVP8W/mi29mCnsnpi
         OVWg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792533835; x=1793138635;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=fUJUf2XHU25x2noX8Uf7Y4DKlKoCjH6yK/uRcd1adlc=;
        b=oi2Wz0l84XWvyeKkePNg9rM6lnSY54AaUFKjBALpBeuWLqOwau/w6fLGhox8MVUtYw
         BiCaBSFJQxtfMux9UUMtNMOy+iEO6ZTl05TjpcmqoC6KEZz7Dr/tzXB5fymgEB0zQ2Fv
         96EZWDccK9V20sOGEySrLidWhcmRBf+zukKe+9PteVaxxL0cGx/6svXFiFW+T+ljvJN4
         SED6Csou2xnpqA+e81vQ29XhRPEw3k0kwbEBECRDSUeZSctCSp+d0ceZ2WD/hc/U13zJ
         OZheFvcnjAZJb/xrN7phj7hOkKjGUWwAieGpfA2iUW880cSnvsw5nUxkzaZCqDLgvcTK
         Y4Bw==
X-Gm-Message-State: AFq9FYJUEx1tlL9qrBocHp/+zBIi7a+n8rXz8acb4X8lI25+KAP8S0fU
	Xv8a33KFVoL3FgFueHo60XrnGZ5hIrEui3+vNIFg5DC/x1cs4bIc837L+Xxl0nVvPJhdyGBpLPH
	U8f3I
X-Gm-Gg: AYBFou1YV4x4wTQ1E/gthmvKDkg55fbBJPgQRtHSR8hPml9G7kBkeqgGMmPaSzGW59A
	+/Ug9m46LOz8wTso2hIO+TCrSiRF2Z7vlFuX/c1RVuIcfPYHvuvOLMvm5xRgObmjkXUAPWcL2B4
	rK51vj/TjeBgtWLjXkoGBzOsfUM4NsxATvqqNHwWT5dGY/XeTQP/mxJ2HDWGbSpLqK/sXQUbwdR
	wqAeX6/LqU1etTg1O1lfUOl9OIwroNHr4qJ1lIibN0dRbwWHaV8tBty7mY6X9GJMN4RjRCy/n9p
	k6s3Y9yAN772v7K9S8Olvgg7Io0NM0yhabPG+04JaJ/64E3uruHn20vAewG3TMPFMaQy7ENOy3c
	Hd0SRUUVS0QjzyHGrd7riY2c+DWwnFfQOnqOAkKp7QDTcoNUPCYCvfAiR8SA8WQY6Utr/7BMx/M
	Lte2S9Gwe0qw6N+0HLXJkC0wfDh9CUoloonhLq5hl8ZPOWpUka9dz4lCS5X5R3SuLIjehhZUD4N
	I/U6yz2I8OzWOr9zw/6NXTdNggrsNVOme0MhR61Vjt5TlXdI6sP3QjdGZ91dVHZjo00TGqK+g==
X-Received: by 2002:a05:620a:4544:b0:93c:b6db:8c with SMTP id af79cd13be357-93f57dbe877mr120645885a.0.1792533834228;
        Tue, 20 Oct 2026 15:03:54 -0700 (PDT)
Received: from localhost (pool-68-160-167-46.bstnma.fios.verizon.net. [68.160.167.46])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-93f56d98577sm88755085a.9.2026.10.20.15.03.53
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 20 Oct 2026 15:03:53 -0700 (PDT)
Sender: Mike Snitzer <mike.snitzer@hammerspace.com>
From: Mike Snitzer <snitzer@hammerspace.com>
X-Google-Original-From: Mike Snitzer <snitzer@kernel.org>
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
	Jonathan Corbet <corbet@lwn.net>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: [PATCH v7 4/5] mm, iomap: let an uncached writer complete its shared pages itself
Date: Tue, 20 Oct 2026 18:03:45 -0400
Message-ID: <20261020220346.28020-5-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261020220346.28020-1-snitzer@kernel.org>
References: <20261020220346.28020-1-snitzer@kernel.org>
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

The write that completes a page an uncached write covers only partly
marks it drop-behind as it writes, while the page is dirty, so the page
counts as DONTCACHE dirty and the DONTCACHE writeback kick writes it
back.  A writer that syncs its write itself, once, after several
segments -- NFSD answering a stable WRITE, the NFS client's LOCALIO path
-- issues each segment without IOCB_DSYNC, so every segment's kick
writes back pages its own sync is about to write.  Measured with NFSD
DIRECT and 32 writers of 47008-byte records: with the previous patch
alone, 23,000 to 65,000 kick rounds a run, where NFSD marking the pages
itself after its sync had taken 51 to 274; with this patch and NFSD
using it, a FILE_SYNC WRITE wakes the kick not at all.

Let such a writer complete those pages itself.  IOCB_DONTCACHE_DEFER
(IOMAP_DONTCACHE_DEFER, FGP_DONTCACHE_DEFER) leaves a partly covered page
unmarked even when the write finds it uptodate.  Right before writing such
a page the writer asks filemap_dontcache_edge_completes() whether it is
uptodate already, which means the neighbouring write has written its part
and this write completes it; once the write and its sync are done,
filemap_dontcache_edge_complete() marks it and, clean, drops it at once.

Two writes that arrive together may both find the page absent before
either has written; that page is then left cached until reclaim, which
the folio-lock ordering of the default path avoids.

Assisted-by: LLM
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 fs/iomap/buffered-io.c  |  4 +++
 fs/iomap/trace.h        |  3 ++-
 include/linux/fs.h      |  8 +++++-
 include/linux/iomap.h   |  1 +
 include/linux/pagemap.h |  6 +++++
 mm/filemap.c            | 58 ++++++++++++++++++++++++++++++++++++++++-
 6 files changed, 77 insertions(+), 3 deletions(-)

diff --git a/fs/iomap/buffered-io.c b/fs/iomap/buffered-io.c
index 780a0186045d..5ca82000e2ec 100644
--- a/fs/iomap/buffered-io.c
+++ b/fs/iomap/buffered-io.c
@@ -811,6 +811,8 @@ struct folio *iomap_get_folio(struct iomap_iter *iter, loff_t pos, size_t len)
 		 */
 		if (offset_in_page(pos) || len < PAGE_SIZE) {
 			fgp |= FGP_DONTCACHE_EDGE;
+			if (iter->flags & IOMAP_DONTCACHE_DEFER)
+				fgp |= FGP_DONTCACHE_DEFER;
 			len = min_t(size_t, len, PAGE_SIZE - offset_in_page(pos));
 		}
 	}
@@ -1318,6 +1320,8 @@ iomap_file_buffered_write(struct kiocb *iocb, struct iov_iter *i,
 		iter.flags |= IOMAP_NOWAIT;
 	if (iocb->ki_flags & IOCB_DONTCACHE)
 		iter.flags |= IOMAP_DONTCACHE;
+	if (iocb->ki_flags & IOCB_DONTCACHE_DEFER)
+		iter.flags |= IOMAP_DONTCACHE_DEFER;
 
 	while ((ret = iomap_iter(&iter, ops)) > 0)
 		iter.status = iomap_write_iter(&iter, i, write_ops);
diff --git a/fs/iomap/trace.h b/fs/iomap/trace.h
index e1ea8392cf47..4f0343eeed1b 100644
--- a/fs/iomap/trace.h
+++ b/fs/iomap/trace.h
@@ -104,7 +104,8 @@ DEFINE_RANGE_EVENT(iomap_zero_iter);
 	{ IOMAP_UNSHARE,	"UNSHARE" }, \
 	{ IOMAP_DAX,		"DAX" }, \
 	{ IOMAP_ATOMIC,		"ATOMIC" }, \
-	{ IOMAP_DONTCACHE,	"DONTCACHE" }
+	{ IOMAP_DONTCACHE,	"DONTCACHE" }, \
+	{ IOMAP_DONTCACHE_DEFER, "DONTCACHE_DEFER" }
 
 #define IOMAP_F_FLAGS_STRINGS \
 	{ IOMAP_F_NEW,		"NEW" }, \
diff --git a/include/linux/fs.h b/include/linux/fs.h
index f9d1e05e8ae6..ad181b6ce6b4 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -357,6 +357,11 @@ struct readahead_control;
 /* kiocb is a read or write operation submitted by fs/aio.c. */
 #define IOCB_AIO_RW		(1 << 22)
 #define IOCB_HAS_METADATA	(1 << 23)
+/*
+ * With IOCB_DONTCACHE: the caller completes the pages the write covers only
+ * partly itself, see filemap_dontcache_edge_complete().
+ */
+#define IOCB_DONTCACHE_DEFER	(1 << 24)
 
 /* for use in trace events */
 #define TRACE_IOCB_STRINGS \
@@ -374,7 +379,8 @@ struct readahead_control;
 	{ IOCB_NOIO,		"NOIO" }, \
 	{ IOCB_ALLOC_CACHE,	"ALLOC_CACHE" }, \
 	{ IOCB_AIO_RW,		"AIO_RW" }, \
-	{ IOCB_HAS_METADATA,	"AIO_HAS_METADATA" }
+	{ IOCB_HAS_METADATA,	"AIO_HAS_METADATA" }, \
+	{ IOCB_DONTCACHE_DEFER,	"DONTCACHE_DEFER" }
 
 struct kiocb {
 	struct file		*ki_filp;
diff --git a/include/linux/iomap.h b/include/linux/iomap.h
index bc7ae6327dbf..f3509d495a92 100644
--- a/include/linux/iomap.h
+++ b/include/linux/iomap.h
@@ -212,6 +212,7 @@ struct iomap_write_ops {
 #endif /* CONFIG_FS_DAX */
 #define IOMAP_ATOMIC		(1 << 9) /* torn-write protection */
 #define IOMAP_DONTCACHE		(1 << 10)
+#define IOMAP_DONTCACHE_DEFER	(1 << 11) /* see IOCB_DONTCACHE_DEFER */
 
 /*
  * Return the existing mapping at pos, or reserve space starting at pos for up
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 0c1d6bd09aa0..a0a67e4c940b 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -705,6 +705,9 @@ pgoff_t page_cache_prev_miss(struct address_space *mapping,
  *   only partly, and a neighbouring write may complete it.  A folio created
  *   for it is not marked drop-behind; a folio found uptodate is, as the
  *   write that completes it.
+ * * %FGP_DONTCACHE_DEFER - With %FGP_DONTCACHE_EDGE: the caller completes the
+ *   page itself (filemap_dontcache_edge_complete()), so a folio found uptodate
+ *   is not marked either.
  * * %FGP_WRITEBEGIN - The flags to use in a filesystem write_begin()
  *   implementation.
  */
@@ -720,6 +723,7 @@ typedef unsigned int __bitwise fgf_t;
 #define FGP_STABLE		((__force fgf_t)0x00000080)
 #define FGP_DONTCACHE		((__force fgf_t)0x00000100)
 #define FGP_DONTCACHE_EDGE	((__force fgf_t)0x00000200)
+#define FGP_DONTCACHE_DEFER	((__force fgf_t)0x00000400)
 #define FGF_GET_ORDER(fgf)	(((__force unsigned)fgf) >> 26)	/* top 6 bits */
 
 #define FGP_WRITEBEGIN		(FGP_LOCK | FGP_WRITE | FGP_CREAT | FGP_STABLE)
@@ -1316,6 +1320,8 @@ void folio_end_writeback(struct folio *folio);
 void folio_end_writeback_no_dropbehind(struct folio *folio);
 void folio_end_dropbehind(struct folio *folio);
 void folio_mark_dropbehind(struct folio *folio);
+bool filemap_dontcache_edge_completes(struct address_space *mapping, loff_t pos);
+void filemap_dontcache_edge_complete(struct address_space *mapping, loff_t pos);
 void folio_wait_stable(struct folio *folio);
 void __folio_mark_dirty(struct folio *folio, struct address_space *, int warn);
 void folio_account_cleaned(struct folio *folio, struct bdi_writeback *wb);
diff --git a/mm/filemap.c b/mm/filemap.c
index 0397ec771547..7d7c56a42643 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1675,6 +1675,61 @@ void folio_mark_dropbehind(struct folio *folio)
 }
 EXPORT_SYMBOL_GPL(folio_mark_dropbehind);
 
+/**
+ * filemap_dontcache_edge_completes - will this write complete a shared page?
+ * @mapping: the file's mapping
+ * @pos: any byte offset within the page
+ *
+ * For an uncached writer that completes the pages it covers only partly
+ * itself (IOCB_DONTCACHE_DEFER).  Call right before writing such a page: it
+ * is in the page cache and uptodate when the neighbouring write has already
+ * written its part, and this write then completes it.  Two writes that
+ * arrive together may both find it absent; the page is then left cached,
+ * unmarked, until reclaim.
+ *
+ * Return: true if the caller is to call filemap_dontcache_edge_complete()
+ * once its write, including any sync of it, is done.
+ */
+bool filemap_dontcache_edge_completes(struct address_space *mapping, loff_t pos)
+{
+	struct folio *folio;
+	bool ret;
+
+	/* FGP_DONTCACHE: a plain lookup would clear a drop-behind mark. */
+	folio = __filemap_get_folio(mapping, pos >> PAGE_SHIFT, FGP_DONTCACHE, 0);
+	if (IS_ERR(folio))
+		return false;
+	ret = folio_test_uptodate(folio);
+	folio_put(folio);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(filemap_dontcache_edge_completes);
+
+/**
+ * filemap_dontcache_edge_complete - drop a shared page both writes have written
+ * @mapping: the file's mapping
+ * @pos: any byte offset within the page
+ *
+ * Mark the page drop-behind.  If it is already written back, drop it now;
+ * otherwise the writeback that cleans it drops it.  A dirty page marked here
+ * counts as DONTCACHE dirty and wakes the DONTCACHE writeback kick, so a
+ * caller that syncs its write calls this after the sync.
+ */
+void filemap_dontcache_edge_complete(struct address_space *mapping, loff_t pos)
+{
+	struct folio *folio;
+
+	folio = __filemap_get_folio(mapping, pos >> PAGE_SHIFT,
+				    FGP_LOCK | FGP_DONTCACHE, 0);
+	if (IS_ERR(folio))
+		return;
+	folio_mark_dropbehind(folio);
+	folio_unlock(folio);
+	folio_end_dropbehind(folio);
+	folio_put(folio);
+}
+EXPORT_SYMBOL_GPL(filemap_dontcache_edge_complete);
+
 /**
  * folio_end_writeback_no_dropbehind - End writeback against a folio.
  * @folio: The folio.
@@ -2024,7 +2079,8 @@ struct folio *__filemap_get_folio_mpol(struct address_space *mapping,
 	 * folio lock, so the writeback that cleans both writes' data drops it.
 	 */
 	if ((fgp_flags & FGP_DONTCACHE) && (fgp_flags & FGP_DONTCACHE_EDGE) &&
-	    (fgp_flags & FGP_LOCK) && folio_test_uptodate(folio))
+	    !(fgp_flags & FGP_DONTCACHE_DEFER) && (fgp_flags & FGP_LOCK) &&
+	    folio_test_uptodate(folio))
 		folio_mark_dropbehind(folio);
 no_page:
 	if (!folio && (fgp_flags & FGP_CREAT)) {
-- 
2.52.0

