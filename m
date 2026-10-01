Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2946950B43C
	for <linux-nfs@vger.kernel.org>; Thu,  1 Oct 2026 09:13:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790846035; cv=none; b=c2XR1Bv7ReTQuTAr9InNM5o+omaD7LEcOeF8Qcv5nbBqCIqBGNdEFGU7m1uY1AyJ3uLtuEgjNSbOGvaSm8T/LCYx2c1YezLtc9KMdMcWq/vHS/Qt4e1n2rJRbobsGh9HLMNkRsN3J67Uo3lF+7SXMxqpVgPS0KlFqWAJgutMUN4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790846035; c=relaxed/simple;
	bh=0Sozx+gbKNPnpZvS6LZgd9kwag5s5+8CCdfljhrrT9Q=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=KuxhY+XcoTEAG/v8kdnCVi5DZIhyEasFDV8OZx3l9BPyloMozixrGe75mCODIwXDNX5a/PYSG3hDbYBjZAbiXunNyKjqogbFw4xhCXdfPW3oU/R5VTxOHK1MyYK4yRmyQSo/5z4whGrrDkoqCNp+ld+zJemIdNIc+4JfB1b4+c8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=AmBdn0Ec; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="AmBdn0Ec"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1790846029;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=7j9dDrAT1lOMXbWdn6MRoc2CDvTEtHFwEAiPwNAM+UQ=;
	b=AmBdn0EckRp9L7DEQgiX1MIeMEb9+0ZJJkRUxfaJ4uPppV2qo35MZXkHL8DBW1BWNmKNJK
	3FE1rCMHxBzTe/izAQ143ypdHDBPq2ztpgcCFkk0ZCTEBJ1coexTFu2IPZWF4ubKKref9w
	ivIoZ/78AcENnLmoUpL6hXKdgBxvOdY=
Received: from mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-475-tnL8_SuLPuaWdp3_dY1tog-1; Thu,
 01 Oct 2026 05:13:46 -0400
X-MC-Unique: tnL8_SuLPuaWdp3_dY1tog-1
X-Mimecast-MFC-AGG-ID: tnL8_SuLPuaWdp3_dY1tog_1790846024
Received: from mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.93])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id DFCEA193E898;
	Thu,  1 Oct 2026 09:13:43 +0000 (UTC)
Received: from warthog.com (unknown [10.44.32.54])
	by mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id DC55B180029C;
	Thu,  1 Oct 2026 09:13:37 +0000 (UTC)
From: David Howells <dhowells@redhat.com>
To: Christian Brauner <christian@brauner.io>
Cc: David Howells <dhowells@redhat.com>,
	Paulo Alcantara <pc@manguebit.org>,
	Matthew Wilcox <willy@infradead.org>,
	Namjae Jeon <linkinjeon@kernel.org>,
	Marc Dionne <marc.dionne@auristor.com>,
	Stefan Metzmacher <metze@samba.org>,
	Eric Van Hensbergen <ericvh@kernel.org>,
	Dominique Martinet <asmadeus@codewreck.org>,
	Ilya Dryomov <idryomov@gmail.com>,
	netfs@lists.linux.dev,
	linux-afs@lists.infradead.org,
	linux-cifs@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	ceph-devel@vger.kernel.org,
	v9fs@lists.linux.dev,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Shyam Prasad N <sprasad@microsoft.com>,
	Tom Talpey <tom@talpey.com>,
	Christoph Hellwig <hch@infradead.org>
Subject: [PATCH v15 07/10] netfs: Switch folioq to bvecq
Date: Thu,  1 Oct 2026 10:12:35 +0100
Message-ID: <20261001091239.3343034-8-dhowells@redhat.com>
In-Reply-To: <20261001091239.3343034-1-dhowells@redhat.com>
References: <20261001091239.3343034-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.93

In netfslib, perform more or less a straight switch from using folio_queue
to using bvecq to hold the lists of folios involved in various sorts of
buffered read and in buffered writeback.

It's not quite a straight swap, however, because:

 (1) The bveq_alloc_*() routines want to know if the callers is doing
     writeback for emergency pool use.

 (2) folio_queue includes a fixed capacity folio_batch, but bvecq has a
     variable size bio_vec array.

 (3) folio_queue has a set of per-folio marks that are mostly unused; the
     one exception is for netfs_prefetch_for_write() - but the marked folio
     is then ignored because no_unlock_folio points to it (and the bvecq
     mem cleanup type can handle that anyway).  This will become an issue
     if/when netfs_prefetch_for_write() expands the read to cope with large
     cache granularity.

 (4) The bvecq API doesn't have functions to get a folio's length or to
     clear a folio pointer by slot, instead accessing the bio_vec array
     directly.  Also bvecq stores the folio length in bv_len instead of
     storing the folio orders.

 (5) rolling_buffer_bulk_load_from_ra() needs to work a bit differently as
     the folio_queue contains a folio_batch and bvecq doesn't.

 (6) rolling_buffer_delete_spent() has to clear the bvecq->next pointer
     before putting the bvecq to avoid rolling up the entire list.  On the
     other hand, rolling_buffer_clear() just needs to put the tail.

Signed-off-by: David Howells <dhowells@redhat.com>
Reviewed-by: Paulo Alcantara <pc@manguebit.org>
cc: Matthew Wilcox <willy@infradead.org>
cc: Namjae Jeon <linkinjeon@kernel.org>
cc: Shyam Prasad N <sprasad@microsoft.com>
cc: Tom Talpey <tom@talpey.com>
cc: Christoph Hellwig <hch@infradead.org>
cc: linux-cifs@vger.kernel.org
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 fs/netfs/buffered_read.c       |  34 ++++----
 fs/netfs/iterator.c            |  33 ++++----
 fs/netfs/read_collect.c        |  48 +++++------
 fs/netfs/read_pgpriv2.c        |  26 +++---
 fs/netfs/read_retry.c          |  29 +++----
 fs/netfs/rolling_buffer.c      | 143 ++++++++++++++-------------------
 fs/netfs/write_collect.c       |  26 +++---
 fs/netfs/write_issue.c         |  16 ++--
 include/linux/rolling_buffer.h |  42 ++++------
 include/trace/events/netfs.h   |   2 +-
 10 files changed, 184 insertions(+), 215 deletions(-)

diff --git a/fs/netfs/buffered_read.c b/fs/netfs/buffered_read.c
index e30bde80276a..aa1e4f8d46ab 100644
--- a/fs/netfs/buffered_read.c
+++ b/fs/netfs/buffered_read.c
@@ -215,7 +215,7 @@ static void netfs_issue_read(struct netfs_io_request *rreq,
  * otherwise we set the deprecated PG_private_2.
  */
 static void netfs_mark_copy_to_cache(struct netfs_io_request *rreq,
-				     struct folio_queue **fq,
+				     struct bvecq **bq,
 				     unsigned int *offset,
 				     int *slot,
 				     size_t len,
@@ -225,21 +225,21 @@ static void netfs_mark_copy_to_cache(struct netfs_io_request *rreq,
 		struct folio *folio;
 		size_t fsize, overlap;
 
-		if (!*fq)
+		if (!*bq)
 			break;
-		if (*slot >= folioq_count(*fq)) {
-			*fq = (*fq)->next;
+		if (!bvecq_acquire_slot(*bq, *slot)) {
+			*bq = bvecq_next(*bq);
 			*slot = 0;
 			*offset = 0;
 			continue;
 		}
 
 		/* Determine how much the subreq overlaps the folio, if at all. */
-		fsize = folioq_folio_size(*fq, *slot);
+		fsize = (*bq)->bv[*slot].bv_len;
 		overlap = min(len, fsize - *offset);
 
 		if (overlap > 0 && copy) {
-			folio = folioq_folio(*fq, *slot);
+			folio = bvec_folio(&(*bq)->bv[*slot]);
 			if (netfs_using_pgpriv2(rreq)) {
 				if (!folio_test_private_2(folio))
 					folio_start_private_2(folio);
@@ -275,7 +275,7 @@ static void netfs_read_to_pagecache(struct netfs_io_request *rreq)
 		.cached_to[1]	= ULLONG_MAX,
 	};
 	struct fscache_occupancy *occ = &_occ;
-	struct folio_queue *fq = rreq->buffer.tail;
+	struct bvecq *bq = rreq->buffer.tail;
 	unsigned int offset = 0;
 	ssize_t size = rreq->len;
 	uoff_t start = rreq->start;
@@ -408,10 +408,10 @@ static void netfs_read_to_pagecache(struct netfs_io_request *rreq)
 		if (size <= 0)
 			netfs_all_subreqs_queued(rreq);
 
-		if (fq) {
+		if (bq) {
 			/* See if the cache indicated this should be cached. */
 			copy = test_bit(NETFS_SREQ_COPY_TO_CACHE, &subreq->flags);
-			netfs_mark_copy_to_cache(rreq, &fq, &slot, &offset, slice, copy);
+			netfs_mark_copy_to_cache(rreq, &bq, &slot, &offset, slice, copy);
 		}
 
 		trace_netfs_sreq(subreq, netfs_sreq_trace_submit);
@@ -479,8 +479,7 @@ void netfs_readahead(struct readahead_control *ractl)
 	 * acquires a ref on each folio that we will need to release later -
 	 * but we don't want to do that until after we've started the I/O.
 	 */
-	added = rolling_buffer_bulk_load_from_ra(&rreq->buffer, ractl,
-						 rreq->debug_id, rreq->gfp);
+	added = rolling_buffer_bulk_load_from_ra(&rreq->buffer, ractl, rreq->gfp);
 	if (added < 0) {
 		ret = added;
 		goto cleanup_free;
@@ -503,15 +502,14 @@ EXPORT_SYMBOL(netfs_readahead);
 /*
  * Create a rolling buffer with a single occupying folio.
  */
-static int netfs_create_singular_buffer(struct netfs_io_request *rreq, struct folio *folio,
-					unsigned int rollbuf_flags)
+static int netfs_create_singular_buffer(struct netfs_io_request *rreq, struct folio *folio)
 {
 	ssize_t added;
 
-	if (rolling_buffer_init(&rreq->buffer, rreq->debug_id, ITER_DEST, rreq->gfp) < 0)
+	if (rolling_buffer_init(&rreq->buffer, ITER_DEST, rreq->gfp, false) < 0)
 		return -ENOMEM;
 
-	added = rolling_buffer_append(&rreq->buffer, folio, rollbuf_flags, rreq->gfp);
+	added = rolling_buffer_append(&rreq->buffer, folio, rreq->gfp);
 	if (added < 0)
 		return added;
 	rreq->submitted = rreq->start + added;
@@ -661,7 +659,7 @@ int netfs_read_folio(struct file *file, struct folio *folio)
 	trace_netfs_read(rreq, rreq->start, rreq->len, netfs_read_trace_readpage);
 
 	/* Set up the output buffer */
-	ret = netfs_create_singular_buffer(rreq, folio, 0);
+	ret = netfs_create_singular_buffer(rreq, folio);
 	if (ret < 0)
 		goto discard;
 
@@ -818,7 +816,7 @@ int netfs_write_begin(struct netfs_inode *ctx,
 	trace_netfs_read(rreq, pos, len, netfs_read_trace_write_begin);
 
 	/* Set up the output buffer */
-	ret = netfs_create_singular_buffer(rreq, folio, 0);
+	ret = netfs_create_singular_buffer(rreq, folio);
 	if (ret < 0)
 		goto error_put;
 
@@ -883,7 +881,7 @@ int netfs_prefetch_for_write(struct file *file, struct folio *folio,
 	trace_netfs_read(rreq, start, flen, netfs_read_trace_prefetch_for_write);
 
 	/* Set up the output buffer */
-	ret = netfs_create_singular_buffer(rreq, folio, NETFS_ROLLBUF_PAGECACHE_MARK);
+	ret = netfs_create_singular_buffer(rreq, folio);
 	if (ret < 0)
 		goto error_put;
 
diff --git a/fs/netfs/iterator.c b/fs/netfs/iterator.c
index eb1efb17f53a..31748526d568 100644
--- a/fs/netfs/iterator.c
+++ b/fs/netfs/iterator.c
@@ -245,33 +245,34 @@ static size_t netfs_limit_xarray(const struct iov_iter *iter, size_t start_offse
 }
 
 /*
- * Select the span of a folio queue iterator we're going to use.  Limit it by
- * both maximum size and maximum number of segments.  Returns the size of the
- * span in bytes.
+ * Select the span of a bvecq iterator we're going to use.  Limit it by both
+ * maximum size and maximum number of segments.  Returns the size of the span
+ * in bytes.
  */
-static size_t netfs_limit_folioq(const struct iov_iter *iter, size_t start_offset,
-				 size_t max_size, size_t max_segs)
+static size_t netfs_limit_bvecq(const struct iov_iter *iter, size_t start_offset,
+				size_t max_size, size_t max_segs)
 {
-	const struct folio_queue *folioq = iter->folioq;
+	const struct bvecq *bq = iter->bvecq;
 	unsigned int nsegs = 0;
-	unsigned int slot = iter->folioq_slot;
+	unsigned int slot = iter->bvecq_slot;
 	size_t span = 0, n = iter->count;
 
-	if (WARN_ON(!iov_iter_is_folioq(iter)) ||
+	if (WARN_ON(!iov_iter_is_bvecq(iter)) ||
 	    WARN_ON(start_offset > n) ||
 	    n == 0)
 		return 0;
 	max_size = umin(max_size, n - start_offset);
 
-	if (slot >= folioq_nr_slots(folioq)) {
-		folioq = folioq->next;
+	if (!bvecq_acquire_slot(bq, slot)) {
+		bq = bvecq_next(bq);
 		slot = 0;
 	}
 
 	start_offset += iter->iov_offset;
 	do {
-		size_t flen = folioq_folio_size(folioq, slot);
+		size_t flen;
 
+		flen = bq->bv[slot].bv_len;
 		if (start_offset < flen) {
 			span += flen - start_offset;
 			nsegs++;
@@ -283,11 +284,11 @@ static size_t netfs_limit_folioq(const struct iov_iter *iter, size_t start_offse
 			break;
 
 		slot++;
-		if (slot >= folioq_nr_slots(folioq)) {
-			folioq = folioq->next;
+		if (!bvecq_acquire_slot(bq, slot)) {
+			bq = bvecq_next(bq);
 			slot = 0;
 		}
-	} while (folioq);
+	} while (bq);
 
 	return umin(span, max_size);
 }
@@ -295,8 +296,8 @@ static size_t netfs_limit_folioq(const struct iov_iter *iter, size_t start_offse
 size_t netfs_limit_iter(const struct iov_iter *iter, size_t start_offset,
 			size_t max_size, size_t max_segs)
 {
-	if (iov_iter_is_folioq(iter))
-		return netfs_limit_folioq(iter, start_offset, max_size, max_segs);
+	if (iov_iter_is_bvecq(iter))
+		return netfs_limit_bvecq(iter, start_offset, max_size, max_segs);
 	if (iov_iter_is_bvec(iter))
 		return netfs_limit_bvec(iter, start_offset, max_size, max_segs);
 	if (iov_iter_is_xarray(iter))
diff --git a/fs/netfs/read_collect.c b/fs/netfs/read_collect.c
index 2625efd48a9b..961b76e37a02 100644
--- a/fs/netfs/read_collect.c
+++ b/fs/netfs/read_collect.c
@@ -63,11 +63,11 @@ void netfs_cancel_copy_to_cache(struct netfs_io_request *rreq, struct folio *fol
  * dirty and let writeback handle it.
  */
 static void netfs_unlock_read_folio(struct netfs_io_request *rreq,
-				    struct folio_queue *folioq,
+				    struct bvecq *bq,
 				    int slot)
 {
 	struct netfs_folio *finfo;
-	struct folio *folio = folioq_folio(folioq, slot);
+	struct folio *folio = bvec_folio(&bq->bv[slot]);
 
 	if (unlikely(folio_pos(folio) < rreq->abandon_to)) {
 		trace_netfs_folio(folio, netfs_folio_trace_abandon);
@@ -98,7 +98,7 @@ static void netfs_unlock_read_folio(struct netfs_io_request *rreq,
 			trace_netfs_folio(folio, netfs_folio_trace_read_done);
 		}
 
-		folioq_clear(folioq, slot);
+		bq->bv[slot].bv_page = NULL;
 	} else {
 		// TODO: Use of PG_private_2 is deprecated.
 		if (folio_test_private_2(folio))
@@ -114,7 +114,7 @@ static void netfs_unlock_read_folio(struct netfs_io_request *rreq,
 		folio_unlock(folio);
 	}
 
-	folioq_clear(folioq, slot);
+	bq->bv[slot].bv_page = NULL;
 }
 
 /*
@@ -122,21 +122,22 @@ static void netfs_unlock_read_folio(struct netfs_io_request *rreq,
  */
 void netfs_read_set_unlock_at(struct netfs_io_request *rreq)
 {
-	struct folio_queue *folioq = rreq->buffer.tail;
+	const struct bvecq *bq = rreq->buffer.tail;
 	unsigned int slot = rreq->buffer.first_tail_slot;
 	size_t cleaned_to = rreq->cleaned_to - rreq->start;
 	size_t progress_at = cleaned_to;
 	size_t minimum = 256 * 1024;
 
 	while (progress_at < rreq->len) {
-		if (slot >= folioq_count(folioq)) {
-			folioq = folioq->next;
-			if (!folioq)
+		if (!bvecq_acquire_slot(bq, slot)) {
+			bq = bvecq_next(bq);
+			if (!bq)
 				break;
 			slot = 0;
+			continue;
 		}
 
-		progress_at += folioq_folio_size(folioq, slot);
+		progress_at += bq->bv[slot].bv_len;
 		if (progress_at - cleaned_to >= minimum)
 			break;
 		slot++;
@@ -152,7 +153,7 @@ void netfs_read_set_unlock_at(struct netfs_io_request *rreq)
 static void netfs_read_unlock_folios(struct netfs_io_request *rreq,
 				     unsigned int *notes)
 {
-	struct folio_queue *folioq = rreq->buffer.tail;
+	struct bvecq *bq = rreq->buffer.tail;
 	unsigned int slot = rreq->buffer.first_tail_slot;
 	uoff_t collected_to = rreq->collected_to;
 
@@ -161,9 +162,9 @@ static void netfs_read_unlock_folios(struct netfs_io_request *rreq,
 
 	// TODO: Begin decryption
 
-	if (slot >= folioq_nr_slots(folioq)) {
-		folioq = rolling_buffer_delete_spent(&rreq->buffer);
-		if (!folioq) {
+	while (!bvecq_acquire_slot(bq, slot)) {
+		bq = rolling_buffer_delete_spent(&rreq->buffer);
+		if (!bq) {
 			WRITE_ONCE(rreq->progress_at, rreq->len);
 			return;
 		}
@@ -182,13 +183,13 @@ static void netfs_read_unlock_folios(struct netfs_io_request *rreq,
 		uoff_t fpos, fend;
 		size_t fsize;
 
-		folio = folioq_folio(folioq, slot);
+		folio = bvec_folio(&bq->bv[slot]);
 		if (WARN_ONCE(!folio_test_locked(folio),
 			      "R=%08x: folio %lx is not locked\n",
 			      rreq->debug_id, folio->index))
 			trace_netfs_folio(folio, netfs_folio_trace_not_locked);
 
-		fsize = folioq_folio_size(folioq, slot);
+		fsize = bq->bv[slot].bv_len;
 		fpos = folio_pos(folio);
 		fend = fpos + fsize;
 
@@ -198,29 +199,28 @@ static void netfs_read_unlock_folios(struct netfs_io_request *rreq,
 		if (collected_to < fend)
 			break;
 
-		netfs_unlock_read_folio(rreq, folioq, slot);
+		netfs_unlock_read_folio(rreq, bq, slot);
 		WRITE_ONCE(rreq->cleaned_to, fpos + fsize);
 		*notes |= MADE_PROGRESS;
 
-		/* Clean up the head folioq.  If we clear an entire folioq, then
-		 * we can get rid of it provided it's not also the tail folioq
+		/* Clean up the head bq.  If we clear an entire bq, then
+		 * we can get rid of it provided it's not also the tail bq
 		 * being filled by the issuer.
 		 */
-		folioq_clear(folioq, slot);
+		bq->bv[slot].bv_page = NULL;
 		slot++;
-		if (slot >= folioq_nr_slots(folioq)) {
-			folioq = rolling_buffer_delete_spent(&rreq->buffer);
-			if (!folioq)
+		while (!bvecq_acquire_slot(bq, slot)) {
+			bq = rolling_buffer_delete_spent(&rreq->buffer);
+			if (!bq)
 				goto done;
 			slot = 0;
-			trace_netfs_folioq(folioq, netfs_trace_folioq_read_progress);
 		}
 
 		if (fpos + fsize >= collected_to)
 			break;
 	}
 
-	rreq->buffer.tail = folioq;
+	rreq->buffer.tail = bq;
 done:
 	rreq->buffer.first_tail_slot = slot;
 
diff --git a/fs/netfs/read_pgpriv2.c b/fs/netfs/read_pgpriv2.c
index 5280b606fda4..f8e5667e278e 100644
--- a/fs/netfs/read_pgpriv2.c
+++ b/fs/netfs/read_pgpriv2.c
@@ -53,7 +53,7 @@ static void netfs_pgpriv2_copy_folio(struct netfs_io_request *creq, struct folio
 	trace_netfs_folio(folio, netfs_folio_trace_store_copy);
 
 	/* Attach the folio to the rolling buffer. */
-	if (rolling_buffer_append(&creq->buffer, folio, 0, creq->gfp) < 0) {
+	if (rolling_buffer_append(&creq->buffer, folio, creq->gfp) < 0) {
 		set_bit(NETFS_RREQ_CANCEL_CACHING, &creq->flags);
 		folio_end_private_2(folio);
 		return;
@@ -173,13 +173,15 @@ void netfs_pgpriv2_end_copy_to_cache(struct netfs_io_request *rreq)
  */
 bool netfs_pgpriv2_unlock_copied_folios(struct netfs_io_request *creq)
 {
-	struct folio_queue *folioq = creq->buffer.tail;
+	struct bvecq *bq = creq->buffer.tail;
 	unsigned int slot = creq->buffer.first_tail_slot;
 	uoff_t collected_to = creq->collected_to;
 	bool made_progress = false;
 
-	if (slot >= folioq_nr_slots(folioq)) {
-		folioq = rolling_buffer_delete_spent(&creq->buffer);
+	while (!bvecq_acquire_slot(bq, slot)) {
+		bq = rolling_buffer_delete_spent(&creq->buffer);
+		if (!bq)
+			return false;
 		slot = 0;
 	}
 
@@ -188,7 +190,7 @@ bool netfs_pgpriv2_unlock_copied_folios(struct netfs_io_request *creq)
 		uoff_t fpos, fend;
 		size_t fsize, flen;
 
-		folio = folioq_folio(folioq, slot);
+		folio = bvec_folio(&bq->bv[slot]);
 		if (WARN_ONCE(!folio_test_private_2(folio),
 			      "R=%08x: folio %lx is not marked private_2\n",
 			      creq->debug_id, folio->index))
@@ -211,15 +213,15 @@ bool netfs_pgpriv2_unlock_copied_folios(struct netfs_io_request *creq)
 		creq->cleaned_to = fpos + fsize;
 		made_progress = true;
 
-		/* Clean up the head folioq.  If we clear an entire folioq, then
-		 * we can get rid of it provided it's not also the tail folioq
+		/* Clean up the head bq.  If we clear an entire bq, then
+		 * we can get rid of it provided it's not also the tail bq
 		 * being filled by the issuer.
 		 */
-		folioq_clear(folioq, slot);
+		bq->bv[slot].bv_page = NULL;
 		slot++;
-		if (slot >= folioq_nr_slots(folioq)) {
-			folioq = rolling_buffer_delete_spent(&creq->buffer);
-			if (!folioq)
+		while (!bvecq_acquire_slot(bq, slot)) {
+			bq = rolling_buffer_delete_spent(&creq->buffer);
+			if (!bq)
 				goto done;
 			slot = 0;
 		}
@@ -228,7 +230,7 @@ bool netfs_pgpriv2_unlock_copied_folios(struct netfs_io_request *creq)
 			break;
 	}
 
-	creq->buffer.tail = folioq;
+	creq->buffer.tail = bq;
 done:
 	creq->buffer.first_tail_slot = slot;
 	return made_progress;
diff --git a/fs/netfs/read_retry.c b/fs/netfs/read_retry.c
index 5bd8dee5a834..142c3fb8dab1 100644
--- a/fs/netfs/read_retry.c
+++ b/fs/netfs/read_retry.c
@@ -291,7 +291,7 @@ void netfs_retry_reads(struct netfs_io_request *rreq)
  */
 void netfs_unlock_abandoned_read_pages(struct netfs_io_request *rreq)
 {
-	struct folio_queue *p;
+	struct bvecq *p;
 
 	/* We have to wait for readahead refs to have been released before we
 	 * can unlock any folios as the ref-dropper walks i_pages and the only
@@ -301,24 +301,25 @@ void netfs_unlock_abandoned_read_pages(struct netfs_io_request *rreq)
 		netfs_wait_for_put_ra_refs(rreq);
 
 	for (p = rreq->buffer.tail; p; p = p->next) {
-		for (int slot = 0; slot < folioq_count(p); slot++) {
-			struct folio *folio = folioq_folio(p, slot);
+		for (int slot = rreq->buffer.first_tail_slot;
+		     bvecq_acquire_slot(p, slot);
+		     slot++) {
+			struct folio *folio;
 
-			if (!folio)
+			if (!p->bv[slot].bv_page)
 				continue;
+
+			folio = bvec_folio(&p->bv[slot]);
 			netfs_cancel_copy_to_cache(rreq, folio);
 
-			if (!folioq_is_marked2(p, slot)) {
-				if (folio == rreq->no_unlock_folio &&
-				    test_bit(NETFS_RREQ_NO_UNLOCK_FOLIO,
-					     &rreq->flags)) {
-					_debug("no unlock");
-				} else {
-					trace_netfs_folio(folio,
-						netfs_folio_trace_abandon);
-					folio_unlock(folio);
-				}
+			if (folio == rreq->no_unlock_folio &&
+			    test_bit(NETFS_RREQ_NO_UNLOCK_FOLIO, &rreq->flags)) {
+				_debug("no unlock");
+			} else {
+				trace_netfs_folio(folio, netfs_folio_trace_abandon);
+				folio_unlock(folio);
 			}
 		}
+		rreq->buffer.first_tail_slot = 0;
 	}
 }
diff --git a/fs/netfs/rolling_buffer.c b/fs/netfs/rolling_buffer.c
index d30d5ef6d86e..76429fbb6920 100644
--- a/fs/netfs/rolling_buffer.c
+++ b/fs/netfs/rolling_buffer.c
@@ -63,45 +63,46 @@ EXPORT_SYMBOL(netfs_folioq_free);
  * that the pointers can be independently driven by the producer and the
  * consumer.
  */
-int rolling_buffer_init(struct rolling_buffer *roll, unsigned int rreq_id,
-			unsigned int direction, gfp_t gfp)
+int rolling_buffer_init(struct rolling_buffer *roll, unsigned int direction,
+			gfp_t gfp, bool for_writeback)
 {
-	struct folio_queue *fq;
+	struct bvecq *bq;
+
+	roll->for_writeback = for_writeback;
 
-	fq = netfs_folioq_alloc(rreq_id, gfp, netfs_trace_folioq_rollbuf_init);
-	if (!fq)
+	bq = bvecq_alloc_one(BVECQ_POOL_SLOTS, gfp, for_writeback);
+	if (!bq)
 		return -ENOMEM;
 
-	roll->head = fq;
-	roll->tail = fq;
-	iov_iter_folio_queue(&roll->iter, direction, fq, 0, 0, 0);
+	roll->head = bq;
+	roll->tail = bq;
+	iov_iter_bvec_queue(&roll->iter, direction, bq, 0, 0, 0);
 	return 0;
 }
 
 /*
- * Add another folio_queue to a rolling buffer if there's no space left.
+ * Add another bvecq to a rolling buffer if there's no space left.
  */
 int rolling_buffer_make_space(struct rolling_buffer *roll, gfp_t gfp)
 {
-	struct folio_queue *fq, *head = roll->head;
+	struct bvecq *bq, *head = roll->head;
 
-	if (!folioq_full(head))
+	if (!bvecq_is_full(head))
 		return 0;
 
-	fq = netfs_folioq_alloc(head->rreq_id, gfp, netfs_trace_folioq_make_space);
-	if (!fq)
+	bq = bvecq_alloc_one(BVECQ_POOL_SLOTS, gfp, roll->for_writeback);
+	if (!bq)
 		return -ENOMEM;
-	fq->prev = head;
 
-	roll->head = fq;
-	if (folioq_full(head)) {
+	roll->head = bq;
+	if (bvecq_is_full(head)) {
 		/* Make sure we don't leave the master iterator pointing to a
 		 * block that might get immediately consumed.
 		 */
-		if (roll->iter.folioq == head &&
-		    roll->iter.folioq_slot == folioq_nr_slots(head)) {
-			roll->iter.folioq = fq;
-			roll->iter.folioq_slot = 0;
+		if (roll->iter.bvecq == head &&
+		    roll->iter.bvecq_slot == head->nr_slots) {
+			roll->iter.bvecq = bq;
+			roll->iter.bvecq_slot = 0;
 		}
 	}
 
@@ -110,7 +111,7 @@ int rolling_buffer_make_space(struct rolling_buffer *roll, gfp_t gfp)
 	 * [!] NOTE: After we set head->next, the consumer is at liberty to
 	 * immediately delete the old head.
 	 */
-	smp_store_release(&head->next, fq);
+	bvecq_append(head, bq);
 	return 0;
 }
 
@@ -119,55 +120,59 @@ int rolling_buffer_make_space(struct rolling_buffer *roll, gfp_t gfp)
  */
 ssize_t rolling_buffer_bulk_load_from_ra(struct rolling_buffer *roll,
 					 struct readahead_control *ractl,
-					 unsigned int rreq_id, gfp_t gfp)
+					 gfp_t gfp)
 {
-	struct folio_queue *fq;
-	ssize_t loaded = 0;
+	struct bvecq *bq;
+	size_t loaded = 0;
 
 	while (ractl->_nr_pages - ractl->_batch_count > 0) {
+		struct page **pages;
 		unsigned int nr;
 
-		/* Allocate a folioq to put some folios into and attach it to
+		/* Allocate a bvecq to put some folios into and attach it to
 		 * the rolling buffer.
 		 */
-		fq = netfs_folioq_alloc(rreq_id, gfp,
-					netfs_trace_folioq_make_space);
-		if (!fq)
+		bq = bvecq_alloc_one(BVECQ_POOL_SLOTS, gfp, false);
+		if (!bq)
 			goto nomem_unlock;
-		fq->prev = roll->head;
+		bq->mem_type = BVECQ_MEM_EXTERNAL; /* Folio cleanup handled separately. */
+
 		if (!roll->tail)
-			roll->tail = fq;
+			roll->tail = bq;
 		else
-			roll->head->next = fq;
-		roll->head = fq;
+			bvecq_append(roll->head, bq);
+		roll->head = bq;
 
-		/* Get a batch of folios and note their orders. */
-		nr = __readahead_batch(ractl, (struct page **)fq->vec.folios,
-				       folioq_nr_slots(fq));
+		/* Get a bunch of folios and note their sizes. */
+		pages = (struct page **)(bq->bv + bq->max_slots);
+		pages -= bq->max_slots;
+		nr = __readahead_batch(ractl, pages, bq->max_slots);
 		if (WARN_ON_ONCE(!nr))
 			break;
-		fq->vec.nr = nr;
 
 		for (int slot = 0; slot < nr; slot++) {
-			struct folio *folio = folioq_folio(fq, slot);
-			unsigned int order;
+			struct folio *folio = page_folio(pages[slot]);
+			size_t len = folio_size(folio);
 
-			order = folio_order(folio);
-			fq->orders[slot] = order;
-			loaded += PAGE_SIZE << order;
+			bvec_set_folio(&bq->bv[slot], folio, len, 0);
+			loaded += len;
 			trace_netfs_folio(folio, netfs_folio_trace_read);
 		}
+
+		bvecq_filled_to(bq, nr);
 	}
 
 	WRITE_ONCE(roll->iter.count, loaded);
-	iov_iter_folio_queue(&roll->iter, ITER_DEST, roll->tail, 0, 0, loaded);
+	iov_iter_bvec_queue(&roll->iter, ITER_DEST, roll->tail, 0, 0, loaded);
 	return loaded;
 
 nomem_unlock:
-	for (fq = roll->tail; fq; fq = fq->next) {
-		for (int slot = 0; slot < folioq_count(fq); slot++) {
-			folio_unlock(fq->vec.folios[slot]);
-			folioq_mark(fq, slot);
+	for (bq = roll->tail; bq; bq = bq->next) {
+		for (int slot = 0; slot < bq->nr_slots; slot++) {
+			struct folio *folio = bvec_folio(&bq->bv[slot]);
+
+			folio_unlock(folio);
+			folio_put(folio);
 		}
 	}
 	rolling_buffer_clear(roll);
@@ -180,7 +185,7 @@ ssize_t rolling_buffer_bulk_load_from_ra(struct rolling_buffer *roll,
  * Append a folio to the rolling buffer.
  */
 ssize_t rolling_buffer_append(struct rolling_buffer *roll, struct folio *folio,
-			      unsigned int flags, gfp_t gfp)
+			      gfp_t gfp)
 {
 	ssize_t size = folio_size(folio);
 	int slot;
@@ -188,16 +193,11 @@ ssize_t rolling_buffer_append(struct rolling_buffer *roll, struct folio *folio,
 	if (rolling_buffer_make_space(roll, gfp) < 0)
 		return -ENOMEM;
 
-	slot = folioq_append(roll->head, folio);
-	if (flags & ROLLBUF_MARK_1)
-		folioq_mark(roll->head, slot);
-	if (flags & ROLLBUF_MARK_2)
-		folioq_mark2(roll->head, slot);
+	slot = roll->head->nr_slots;
+	bvec_set_folio(&roll->head->bv[slot], folio, size, 0);
+	bvecq_filled_to(roll->head, slot + 1);
 
 	WRITE_ONCE(roll->iter.count, roll->iter.count + size);
-
-	/* Store the counter after setting the slot. */
-	smp_store_release(&roll->next_head_slot, slot);
 	return size;
 }
 
@@ -206,44 +206,23 @@ ssize_t rolling_buffer_append(struct rolling_buffer *roll, struct folio *folio,
  * don't return the last buffer to keep the pointers independent, but return
  * NULL instead.
  */
-struct folio_queue *rolling_buffer_delete_spent(struct rolling_buffer *roll)
+struct bvecq *rolling_buffer_delete_spent(struct rolling_buffer *roll)
 {
-	struct folio_queue *spent = roll->tail, *next = READ_ONCE(spent->next);
+	struct bvecq *spent = roll->tail, *next = bvecq_next(spent);
 
 	if (!next)
 		return NULL;
 	next->prev = NULL;
-	netfs_folioq_free(spent, netfs_trace_folioq_delete);
 	roll->tail = next;
+	spent->next = NULL;
+	bvecq_put(spent);
 	return next;
 }
 
 /*
- * Clear out a rolling queue.  Folios that have mark 1 set are put.
+ * Clear out a rolling queue.
  */
 void rolling_buffer_clear(struct rolling_buffer *roll)
 {
-	struct folio_batch fbatch;
-	struct folio_queue *p;
-
-	folio_batch_init(&fbatch);
-
-	while ((p = roll->tail)) {
-		roll->tail = p->next;
-		for (int slot = 0; slot < folioq_count(p); slot++) {
-			struct folio *folio = folioq_folio(p, slot);
-
-			if (!folio)
-				continue;
-			if (folioq_is_marked(p, slot)) {
-				trace_netfs_folio(folio, netfs_folio_trace_put);
-				if (!folio_batch_add(&fbatch, folio))
-					folio_batch_release(&fbatch);
-			}
-		}
-
-		netfs_folioq_free(p, netfs_trace_folioq_clear);
-	}
-
-	folio_batch_release(&fbatch);
+	bvecq_put(roll->tail);
 }
diff --git a/fs/netfs/write_collect.c b/fs/netfs/write_collect.c
index 6e8ea534230d..91b42820c892 100644
--- a/fs/netfs/write_collect.c
+++ b/fs/netfs/write_collect.c
@@ -114,11 +114,11 @@ int netfs_folio_written_back(struct folio *folio)
 static void netfs_writeback_unlock_folios(struct netfs_io_request *wreq,
 					  unsigned int *notes)
 {
-	struct folio_queue *folioq = wreq->buffer.tail;
+	struct bvecq *bq = wreq->buffer.tail;
 	unsigned int slot = wreq->buffer.first_tail_slot;
 	uoff_t collected_to = wreq->collected_to;
 
-	if (WARN_ON_ONCE(!folioq)) {
+	if (WARN_ON_ONCE(!bq)) {
 		pr_err("[!] Writeback unlock found empty rolling buffer!\n");
 		netfs_dump_request(wreq);
 		return;
@@ -130,9 +130,9 @@ static void netfs_writeback_unlock_folios(struct netfs_io_request *wreq,
 		return;
 	}
 
-	if (slot >= folioq_nr_slots(folioq)) {
-		folioq = rolling_buffer_delete_spent(&wreq->buffer);
-		if (!folioq)
+	while (!bvecq_acquire_slot(bq, slot)) {
+		bq = rolling_buffer_delete_spent(&wreq->buffer);
+		if (!bq)
 			return;
 		slot = 0;
 	}
@@ -143,7 +143,7 @@ static void netfs_writeback_unlock_folios(struct netfs_io_request *wreq,
 		uoff_t fpos, fend;
 		size_t fsize, flen;
 
-		folio = folioq_folio(folioq, slot);
+		folio = bvec_folio(&bq->bv[slot]);
 		if (WARN_ONCE(!folio_test_writeback(folio),
 			      "R=%08x: folio %lx is not under writeback\n",
 			      wreq->debug_id, folio->index))
@@ -166,15 +166,15 @@ static void netfs_writeback_unlock_folios(struct netfs_io_request *wreq,
 		wreq->cleaned_to = fpos + fsize;
 		*notes |= MADE_PROGRESS;
 
-		/* Clean up the head folioq.  If we clear an entire folioq, then
-		 * we can get rid of it provided it's not also the tail folioq
+		/* Clean up the head bq.  If we clear an entire bq, then
+		 * we can get rid of it provided it's not also the tail bq
 		 * being filled by the issuer.
 		 */
-		folioq_clear(folioq, slot);
+		bq->bv[slot].bv_page = NULL;
 		slot++;
-		if (slot >= folioq_nr_slots(folioq)) {
-			folioq = rolling_buffer_delete_spent(&wreq->buffer);
-			if (!folioq)
+		while (!bvecq_acquire_slot(bq, slot)) {
+			bq = rolling_buffer_delete_spent(&wreq->buffer);
+			if (!bq)
 				goto done;
 			slot = 0;
 		}
@@ -183,7 +183,7 @@ static void netfs_writeback_unlock_folios(struct netfs_io_request *wreq,
 			break;
 	}
 
-	wreq->buffer.tail = folioq;
+	wreq->buffer.tail = bq;
 done:
 	wreq->buffer.first_tail_slot = slot;
 }
diff --git a/fs/netfs/write_issue.c b/fs/netfs/write_issue.c
index 486dddf7308b..92cc9b4ffced 100644
--- a/fs/netfs/write_issue.c
+++ b/fs/netfs/write_issue.c
@@ -107,7 +107,9 @@ struct netfs_io_request *netfs_create_write_req(struct address_space *mapping,
 	ictx = netfs_inode(wreq->inode);
 	if (is_cacheable)
 		fscache_begin_write_operation(&wreq->cache_resources, netfs_i_cookie(ictx));
-	if (rolling_buffer_init(&wreq->buffer, wreq->debug_id, ITER_SOURCE, wreq->gfp) < 0)
+	if (rolling_buffer_init(&wreq->buffer, ITER_SOURCE, wreq->gfp,
+				(origin == NETFS_WRITEBACK ||
+				 origin == NETFS_WRITEBACK_SINGLE)) < 0)
 		goto nomem;
 
 	wreq->cleaned_to = wreq->start;
@@ -162,12 +164,12 @@ void netfs_prepare_write(struct netfs_io_request *wreq,
 	struct netfs_io_subrequest *subreq;
 	struct iov_iter *wreq_iter = &wreq->buffer.iter;
 
-	/* Make sure we don't point the iterator at a used-up folio_queue
-	 * struct being used as a placeholder to prevent the queue from
-	 * collapsing.  In such a case, extend the queue.
+	/* Make sure we don't point the iterator at a used-up bvecq struct
+	 * being used as a placeholder to prevent the queue from collapsing.
+	 * In such a case, extend the queue.
 	 */
-	if (iov_iter_is_folioq(wreq_iter) &&
-	    wreq_iter->folioq_slot >= folioq_nr_slots(wreq_iter->folioq))
+	if (iov_iter_is_bvecq(wreq_iter) &&
+	    !bvecq_acquire_slot(wreq_iter->bvecq, wreq_iter->bvecq_slot))
 		rolling_buffer_make_space(&wreq->buffer, wreq->gfp);
 
 	subreq = netfs_alloc_subrequest(wreq, stream->source);
@@ -450,7 +452,7 @@ static int netfs_write_folio(struct netfs_io_request *wreq,
 	}
 
 	/* Attach the folio to the rolling buffer. */
-	rolling_buffer_append(&wreq->buffer, folio, 0, wreq->gfp);
+	rolling_buffer_append(&wreq->buffer, folio, wreq->gfp);
 
 	/* Move the submission point forward to allow for write-streaming data
 	 * not starting at the front of the page.  We don't do write-streaming
diff --git a/include/linux/rolling_buffer.h b/include/linux/rolling_buffer.h
index a97f7cfaacaa..5c0bc4221f01 100644
--- a/include/linux/rolling_buffer.h
+++ b/include/linux/rolling_buffer.h
@@ -8,49 +8,35 @@
 #ifndef _ROLLING_BUFFER_H
 #define _ROLLING_BUFFER_H
 
-#include <linux/folio_queue.h>
+#include <linux/bvecq.h>
 #include <linux/uio.h>
 
 /*
- * Rolling buffer.  Whilst the buffer is live and in use, folios and folio
- * queue segments can be added to one end by one thread and removed from the
- * other end by another thread.  The buffer isn't allowed to be empty; it must
- * always have at least one folio_queue in it so that neither side has to
- * modify both queue pointers.
+ * Rolling buffer.  Whilst the buffer is live and in use, folios and bvecq
+ * segments can be added to one end by one thread and removed from the other
+ * end by another thread.  The buffer isn't allowed to be empty; it must always
+ * have at least one bvecq in it so that neither side has to modify both queue
+ * pointers.
  *
  * The iterator in the buffer is extended as buffers are inserted.  It can be
  * snapshotted to use a segment of the buffer.
  */
 struct rolling_buffer {
-	struct folio_queue	*head;		/* Producer's insertion point */
-	struct folio_queue	*tail;		/* Consumer's removal point */
+	struct bvecq		*head;		/* Producer's insertion point */
+	struct bvecq		*tail;		/* Consumer's removal point */
 	struct iov_iter		iter;		/* Iterator tracking what's left in the buffer */
-	u8			next_head_slot;	/* Next slot in ->head */
 	u8			first_tail_slot; /* First slot in ->tail */
+	bool			for_writeback;	/* T if being used for writeback */
 };
 
-/*
- * Snapshot of a rolling buffer.
- */
-struct rolling_buffer_snapshot {
-	struct folio_queue	*curr_folioq;	/* Queue segment in which current folio resides */
-	unsigned char		curr_slot;	/* Folio currently being read */
-	unsigned char		curr_order;	/* Order of folio */
-};
-
-/* Marks to store per-folio in the internal folio_queue structs. */
-#define ROLLBUF_MARK_1	BIT(0)
-#define ROLLBUF_MARK_2	BIT(1)
-
-int rolling_buffer_init(struct rolling_buffer *roll, unsigned int rreq_id,
-			unsigned int direction, gfp_t gfp);
+int rolling_buffer_init(struct rolling_buffer *roll, unsigned int direction,
+			gfp_t gfp, bool for_writeback);
 int rolling_buffer_make_space(struct rolling_buffer *roll, gfp_t gfp);
 ssize_t rolling_buffer_bulk_load_from_ra(struct rolling_buffer *roll,
 					 struct readahead_control *ractl,
-					 unsigned int rreq_id, gfp_t gfp);
-ssize_t rolling_buffer_append(struct rolling_buffer *roll, struct folio *folio,
-			      unsigned int flags, gfp_t gfp);
-struct folio_queue *rolling_buffer_delete_spent(struct rolling_buffer *roll);
+					 gfp_t gfp);
+ssize_t rolling_buffer_append(struct rolling_buffer *roll, struct folio *folio, gfp_t gfp);
+struct bvecq *rolling_buffer_delete_spent(struct rolling_buffer *roll);
 void rolling_buffer_clear(struct rolling_buffer *roll);
 
 static inline void rolling_buffer_advance(struct rolling_buffer *roll, size_t amount)
diff --git a/include/trace/events/netfs.h b/include/trace/events/netfs.h
index bf1e1f185b05..41f7f0733bfa 100644
--- a/include/trace/events/netfs.h
+++ b/include/trace/events/netfs.h
@@ -398,7 +398,7 @@ TRACE_EVENT(netfs_sreq,
 		    __entry->len	= sreq->len;
 		    __entry->transferred = sreq->transferred;
 		    __entry->start	= sreq->start;
-		    __entry->slot	= sreq->io_iter.folioq_slot;
+		    __entry->slot	= sreq->io_iter.bvecq_slot;
 			   ),
 
 	    TP_printk("R=%08x[%x] %s %s f=%03x s=%llx %zx/%zx s=%u e=%d",

