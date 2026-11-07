Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.133.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794067796;
	b=spqaemuwyQS6j21cmBiPxIazfOaNT56DhJCg1xuzrfsWLygX0R611aPewnd5I8IeZ65D
	 z39IuKfKMXzUC+fsDRO1QXouh/U9LTFq+0QpItqc2l2uas5PRq5uKG6/cnEXjO2RO9tkm
	 WOo5/ZGyaJNa9I9NGGyiJgISJn2b/eOCCxodss+2VCXhcueWfr4Vd1EMLGgqFnUGK+muX
	 utHkL0u7/3E5/3DSE5yBhZ6lmYJKjMGI4sQ/mXGhmkBiFwAxqiZcMfg8YW+LIt7OBEFPM
	 4IP/KF3/T/9ADXlul8lq6tDyWJjuNva/ZiAdwuMTCAjAI5Yym2W65rYO3J6NjSsizxg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794067796;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:Received:From:To:Cc:Subject:Date:
	 Message-ID:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding:X-Scanned-By;
	bh=ds/CmRasb5ajXWWe0vTjRxKuOJcvXny/YINIpNvKZEk=;
	b=5P78FrlPbX1gymm/ao3vsxu0Mf9xwfE1Hbcn1BN6gvaJ6BG4sWyhmbrWSm/L1cNwU+Ae
	 qNE+tjzlL3n6V54Vgj03J211916ZmGaaFCNxWHvWpHUpGZsPtDaK0dMrKP+L0GWsiTd6g
	 S1wnnTtmOISc26AGN0G1Vl5Ej4onZZ0HyKl8A7W2Xaz6dD4Hbi7eY7IxFWjLv1A9gP6aV
	 0LV4zNoj09uqHRAOTAb43kqqgUstvMH8aHuh2r4+gEYPpWSaqakp8CNvLwC0XXIO6MHjf
	 nh0yTA4xWrQDGtEwGKi8AClE0giGlTe4cNQilSxKkz98m7g2BhfzQ+SZyPv0eRPEiIA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=gLLQAMpm;
	arc=none smtp.remote-ip=170.10.133.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C4438606B792
	for <linux-nfs@vger.kernel.org>; Sat,  7 Nov 2026 16:09:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org C4438606B792
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=gLLQAMpm
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1794067794;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=ds/CmRasb5ajXWWe0vTjRxKuOJcvXny/YINIpNvKZEk=;
	b=gLLQAMpmNAI1AmIAQfJCYO7bkpVcm1LW4r4gb46nt1qcUDP8NIkzEARwisig3YTz86tH8V
	NLM7Io4cpOdYXco3baHF7J7heIqGFnBB5kKOj1Ly1roNQCPibpcbQb7nJMr1E4fHX0E0xr
	fZC9YsT3g4vCYcMH3XiiE26kCTTToyI=
Received: from mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-474-UMFVRpjgP02hKJOi-X-wDg-1; Sat,
 07 Nov 2026 11:09:51 -0500
X-MC-Unique: UMFVRpjgP02hKJOi-X-wDg-1
X-Mimecast-MFC-AGG-ID: UMFVRpjgP02hKJOi-X-wDg_1794067788
Received: from mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.93])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 93E6418004FE;
	Sat,  7 Nov 2026 16:09:48 +0000 (UTC)
Received: from dhowells-thinkpadp1gen8.rmtgb.csb (headnet04.pony-001.prod.iad2.dc.redhat.com [10.2.32.116])
	by mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id BCE101800284;
	Sat,  7 Nov 2026 16:09:44 +0000 (UTC)
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
	Christoph Hellwig <hch@infradead.org>
Subject: [PATCH v16 14/15] iov_iter: Remove ITER_FOLIOQ
Date: Sat,  7 Nov 2026 16:08:17 +0000
Message-ID: <20261107160823.1465553-15-dhowells@redhat.com>
In-Reply-To: <20261107160823.1465553-1-dhowells@redhat.com>
References: <20261107160823.1465553-1-dhowells@redhat.com>
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
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.93

Remove ITER_FOLIOQ as it's no longer used.

Signed-off-by: David Howells <dhowells@redhat.com>
Reviewed-by: Paulo Alcantara <pc@manguebit.org>
cc: Matthew Wilcox <willy@infradead.org>
cc: Christoph Hellwig <hch@infradead.org>
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 include/linux/iov_iter.h   |  65 +--------
 include/linux/uio.h        |  12 --
 lib/iov_iter.c             | 236 +-------------------------------
 lib/scatterlist.c          |  69 +---------
 lib/tests/kunit_iov_iter.c | 271 -------------------------------------
 5 files changed, 8 insertions(+), 645 deletions(-)

diff --git a/include/linux/iov_iter.h b/include/linux/iov_iter.h
index 79825cf84e58..e88930af7f36 100644
--- a/include/linux/iov_iter.h
+++ b/include/linux/iov_iter.h
@@ -11,7 +11,6 @@
 #include <linux/uio.h>
 #include <linux/bvec.h>
 #include <linux/bvecq.h>
-#include <linux/folio_queue.h>
 
 typedef size_t (*iov_step_f)(void *iter_base, size_t progress, size_t len,
 			     void *priv, void *priv2);
@@ -207,62 +206,6 @@ size_t iterate_bvecq(struct iov_iter *iter, size_t len, void *priv, void *priv2,
 	return progress;
 }
 
-/*
- * Handle ITER_FOLIOQ.
- */
-static __always_inline
-size_t iterate_folioq(struct iov_iter *iter, size_t len, void *priv, void *priv2,
-		      iov_step_f step)
-{
-	const struct folio_queue *folioq = iter->folioq;
-	unsigned int slot = iter->folioq_slot;
-	size_t progress = 0, skip = iter->iov_offset;
-
-	if (slot == folioq_nr_slots(folioq)) {
-		/* The iterator may have been extended. */
-		folioq = folioq->next;
-		slot = 0;
-	}
-
-	do {
-		struct folio *folio = folioq_folio(folioq, slot);
-		size_t part, remain = 0, consumed;
-		size_t fsize;
-		void *base;
-
-		if (!folio)
-			break;
-
-		fsize = folioq_folio_size(folioq, slot);
-		if (skip < fsize) {
-			base = kmap_local_folio(folio, skip);
-			part = umin(len, PAGE_SIZE - skip % PAGE_SIZE);
-			remain = step(base, progress, part, priv, priv2);
-			kunmap_local(base);
-			consumed = part - remain;
-			len -= consumed;
-			progress += consumed;
-			skip += consumed;
-		}
-		if (skip >= fsize) {
-			skip = 0;
-			slot++;
-			if (slot == folioq_nr_slots(folioq) && folioq->next) {
-				folioq = folioq->next;
-				slot = 0;
-			}
-		}
-		if (remain)
-			break;
-	} while (len);
-
-	iter->folioq_slot = slot;
-	iter->folioq = folioq;
-	iter->iov_offset = skip;
-	iter->count -= progress;
-	return progress;
-}
-
 /*
  * Handle ITER_XARRAY.
  */
@@ -374,8 +317,6 @@ size_t iterate_and_advance2(struct iov_iter *iter, size_t len, void *priv,
 		return iterate_kvec(iter, len, priv, priv2, step);
 	if (iov_iter_is_bvecq(iter))
 		return iterate_bvecq(iter, len, priv, priv2, step);
-	if (iov_iter_is_folioq(iter))
-		return iterate_folioq(iter, len, priv, priv2, step);
 	if (iov_iter_is_xarray(iter))
 		return iterate_xarray(iter, len, priv, priv2, step);
 	if (WARN_ON_ONCE(iov_iter_is_dmabuf_map(iter)))
@@ -412,8 +353,8 @@ size_t iterate_and_advance(struct iov_iter *iter, size_t len, void *priv,
  * buffer is presented in segments, which for kernel iteration are broken up by
  * physical pages and mapped, with the mapped address being presented.
  *
- * [!] Note This will only handle BVEC, KVEC, BVECQ, FOLIOQ, XARRAY and
- * DISCARD-type iterators; it will not handle UBUF or IOVEC-type iterators.
+ * [!] Note This will only handle BVEC, KVEC, BVECQ, XARRAY and DISCARD-type
+ * iterators; it will not handle UBUF or IOVEC-type iterators.
  *
  * A step functions, @step, must be provided, one for handling mapped kernel
  * addresses and the other is given user addresses which have the potential to
@@ -442,8 +383,6 @@ size_t iterate_and_advance_kernel(struct iov_iter *iter, size_t len, void *priv,
 		return iterate_kvec(iter, len, priv, priv2, step);
 	if (iov_iter_is_bvecq(iter))
 		return iterate_bvecq(iter, len, priv, priv2, step);
-	if (iov_iter_is_folioq(iter))
-		return iterate_folioq(iter, len, priv, priv2, step);
 	if (iov_iter_is_xarray(iter))
 		return iterate_xarray(iter, len, priv, priv2, step);
 	return iterate_discard(iter, len, priv, priv2, step);
diff --git a/include/linux/uio.h b/include/linux/uio.h
index f87e05033eac..3fc98542922e 100644
--- a/include/linux/uio.h
+++ b/include/linux/uio.h
@@ -11,7 +11,6 @@
 #include <uapi/linux/uio.h>
 
 struct page;
-struct folio_queue;
 struct dma_buf_io_map;
 
 typedef unsigned int __bitwise iov_iter_extraction_t;
@@ -28,7 +27,6 @@ enum iter_type {
 	ITER_BVEC,
 	ITER_KVEC,
 	ITER_BVECQ,
-	ITER_FOLIOQ,
 	ITER_XARRAY,
 	ITER_DISCARD,
 	ITER_DMABUF_MAP,
@@ -72,7 +70,6 @@ struct iov_iter {
 				const struct kvec *kvec;
 				const struct bio_vec *bvec;
 				const struct bvecq *bvecq;
-				const struct folio_queue *folioq;
 				struct xarray *xarray;
 				void __user *ubuf;
 				struct dma_buf_io_map *dmabuf_map;
@@ -83,7 +80,6 @@ struct iov_iter {
 	union {
 		unsigned long nr_segs;
 		u16 bvecq_slot;
-		u8 folioq_slot;
 		loff_t xarray_start;
 	};
 };
@@ -156,11 +152,6 @@ static inline bool iov_iter_is_bvecq(const struct iov_iter *i)
 	return iov_iter_type(i) == ITER_BVECQ;
 }
 
-static inline bool iov_iter_is_folioq(const struct iov_iter *i)
-{
-	return iov_iter_type(i) == ITER_FOLIOQ;
-}
-
 static inline bool iov_iter_is_xarray(const struct iov_iter *i)
 {
 	return iov_iter_type(i) == ITER_XARRAY;
@@ -314,9 +305,6 @@ void iov_iter_discard(struct iov_iter *i, unsigned int direction, size_t count);
 void iov_iter_bvec_queue(struct iov_iter *i, unsigned int direction,
 			 const struct bvecq *bvecq,
 			 unsigned int first_slot, unsigned int offset, size_t count);
-void iov_iter_folio_queue(struct iov_iter *i, unsigned int direction,
-			  const struct folio_queue *folioq,
-			  unsigned int first_slot, unsigned int offset, size_t count);
 void iov_iter_xarray(struct iov_iter *i, unsigned int direction, struct xarray *xarray,
 		     loff_t start, size_t count);
 void iov_iter_dmabuf_map(struct iov_iter *i, unsigned int direction,
diff --git a/lib/iov_iter.c b/lib/iov_iter.c
index e2e01a2e47fe..55525962a1d6 100644
--- a/lib/iov_iter.c
+++ b/lib/iov_iter.c
@@ -572,39 +572,6 @@ static void iov_iter_bvecq_advance(struct iov_iter *i, size_t by)
 	i->bvecq = bq;
 }
 
-static void iov_iter_folioq_advance(struct iov_iter *i, size_t size)
-{
-	const struct folio_queue *folioq = i->folioq;
-	unsigned int slot = i->folioq_slot;
-
-	if (!i->count)
-		return;
-	i->count -= size;
-
-	if (slot >= folioq_nr_slots(folioq)) {
-		folioq = folioq->next;
-		slot = 0;
-	}
-
-	size += i->iov_offset; /* From beginning of current segment. */
-	do {
-		size_t fsize = folioq_folio_size(folioq, slot);
-
-		if (likely(size < fsize))
-			break;
-		size -= fsize;
-		slot++;
-		if (slot >= folioq_nr_slots(folioq) && folioq->next) {
-			folioq = folioq->next;
-			slot = 0;
-		}
-	} while (size);
-
-	i->iov_offset = size;
-	i->folioq_slot = slot;
-	i->folioq = folioq;
-}
-
 void iov_iter_advance(struct iov_iter *i, size_t size)
 {
 	if (unlikely(i->count < size))
@@ -620,8 +587,6 @@ void iov_iter_advance(struct iov_iter *i, size_t size)
 		iov_iter_bvec_advance(i, size);
 	} else if (iov_iter_is_bvecq(i)) {
 		iov_iter_bvecq_advance(i, size);
-	} else if (iov_iter_is_folioq(i)) {
-		iov_iter_folioq_advance(i, size);
 	} else if (iov_iter_is_discard(i)) {
 		i->count -= size;
 	}
@@ -655,32 +620,6 @@ static void iov_iter_bvecq_revert(struct iov_iter *i, size_t unroll)
 	i->bvecq = bq;
 }
 
-static void iov_iter_folioq_revert(struct iov_iter *i, size_t unroll)
-{
-	const struct folio_queue *folioq = i->folioq;
-	unsigned int slot = i->folioq_slot;
-
-	for (;;) {
-		size_t fsize;
-
-		if (slot == 0) {
-			folioq = folioq->prev;
-			slot = folioq_nr_slots(folioq);
-		}
-		slot--;
-
-		fsize = folioq_folio_size(folioq, slot);
-		if (unroll <= fsize) {
-			i->iov_offset = fsize - unroll;
-			break;
-		}
-		unroll -= fsize;
-	}
-
-	i->folioq_slot = slot;
-	i->folioq = folioq;
-}
-
 void iov_iter_revert(struct iov_iter *i, size_t unroll)
 {
 	if (!unroll)
@@ -716,9 +655,6 @@ void iov_iter_revert(struct iov_iter *i, size_t unroll)
 	} else if (iov_iter_is_bvecq(i)) {
 		i->iov_offset = 0;
 		iov_iter_bvecq_revert(i, unroll);
-	} else if (iov_iter_is_folioq(i)) {
-		i->iov_offset = 0;
-		iov_iter_folioq_revert(i, unroll);
 	} else { /* same logics for iovec and kvec */
 		const struct iovec *iov = iter_iov(i);
 		while (1) {
@@ -768,8 +704,6 @@ size_t iov_iter_single_seg_count(const struct iov_iter *i)
 		}
 		return min(i->count, bq->bv[slot].bv_len - offset);
 	}
-	if (unlikely(iov_iter_is_folioq(i)))
-		return umin(folioq_folio_size(i->folioq, i->folioq_slot), i->count);
 	return i->count;
 }
 EXPORT_SYMBOL(iov_iter_single_seg_count);
@@ -836,36 +770,6 @@ void iov_iter_bvec_queue(struct iov_iter *i, unsigned int direction,
 }
 EXPORT_SYMBOL(iov_iter_bvec_queue);
 
-/**
- * iov_iter_folio_queue - Initialise an I/O iterator to use the folios in a folio queue
- * @i: The iterator to initialise.
- * @direction: The direction of the transfer.
- * @folioq: The starting point in the folio queue.
- * @first_slot: The first slot in the folio queue to use
- * @offset: The offset into the folio in the first slot to start at
- * @count: The size of the I/O buffer in bytes.
- *
- * Set up an I/O iterator to either draw data out of the pages attached to an
- * inode or to inject data into those pages.  The pages *must* be prevented
- * from evaporation, either by taking a ref on them or locking them by the
- * caller.
- */
-void iov_iter_folio_queue(struct iov_iter *i, unsigned int direction,
-			  const struct folio_queue *folioq, unsigned int first_slot,
-			  unsigned int offset, size_t count)
-{
-	BUG_ON(direction & ~1);
-	*i = (struct iov_iter) {
-		.iter_type = ITER_FOLIOQ,
-		.data_source = direction,
-		.folioq = folioq,
-		.folioq_slot = first_slot,
-		.count = count,
-		.iov_offset = offset,
-	};
-}
-EXPORT_SYMBOL(iov_iter_folio_queue);
-
 /**
  * iov_iter_xarray - Initialise an I/O iterator to use the pages in an xarray
  * @i: The iterator to initialise.
@@ -1027,8 +931,8 @@ unsigned long iov_iter_alignment(const struct iov_iter *i)
 	if (iov_iter_is_bvecq(i))
 		return iov_iter_alignment_bvecq(i);
 
-	/* With both xarray and folioq types, we're dealing with whole folios. */
-	if (iov_iter_is_folioq(i) || iov_iter_is_dmabuf_map(i))
+	/* With the xarray type, we're dealing with whole folios. */
+	if (iov_iter_is_dmabuf_map(i))
 		return i->iov_offset | i->count;
 	if (iov_iter_is_xarray(i))
 		return (i->xarray_start + i->iov_offset) | i->count;
@@ -1237,65 +1141,6 @@ static ssize_t iter_bvecq_get_pages(struct iov_iter *iter,
 	return extracted;
 }
 
-static ssize_t iter_folioq_get_pages(struct iov_iter *iter,
-				     struct page ***ppages, size_t maxsize,
-				     unsigned maxpages, size_t *_start_offset)
-{
-	const struct folio_queue *folioq = iter->folioq;
-	struct page **pages;
-	unsigned int slot = iter->folioq_slot;
-	size_t extracted = 0, count = iter->count, iov_offset = iter->iov_offset;
-
-	if (slot >= folioq_nr_slots(folioq)) {
-		folioq = folioq->next;
-		slot = 0;
-		if (WARN_ON(iov_offset != 0))
-			return -EIO;
-	}
-
-	maxpages = want_pages_array(ppages, maxsize, iov_offset & ~PAGE_MASK, maxpages);
-	if (!maxpages)
-		return -ENOMEM;
-	*_start_offset = iov_offset & ~PAGE_MASK;
-	pages = *ppages;
-
-	for (;;) {
-		struct folio *folio = folioq_folio(folioq, slot);
-		size_t offset = iov_offset, fsize = folioq_folio_size(folioq, slot);
-		size_t part = PAGE_SIZE - offset % PAGE_SIZE;
-
-		if (offset < fsize) {
-			part = umin(part, umin(maxsize - extracted, fsize - offset));
-			count -= part;
-			iov_offset += part;
-			extracted += part;
-
-			*pages = folio_page(folio, offset / PAGE_SIZE);
-			get_page(*pages);
-			pages++;
-			maxpages--;
-		}
-
-		if (maxpages == 0 || extracted >= maxsize)
-			break;
-
-		if (iov_offset >= fsize) {
-			iov_offset = 0;
-			slot++;
-			if (slot == folioq_nr_slots(folioq) && folioq->next) {
-				folioq = folioq->next;
-				slot = 0;
-			}
-		}
-	}
-
-	iter->count = count;
-	iter->iov_offset = iov_offset;
-	iter->folioq = folioq;
-	iter->folioq_slot = slot;
-	return extracted;
-}
-
 static ssize_t iter_xarray_populate_pages(struct page **pages, struct xarray *xa,
 					  pgoff_t index, unsigned int nr_pages)
 {
@@ -1449,8 +1294,6 @@ static ssize_t __iov_iter_get_pages_alloc(struct iov_iter *i,
 	}
 	if (iov_iter_is_bvecq(i))
 		return iter_bvecq_get_pages(i, pages, maxsize, maxpages, start);
-	if (iov_iter_is_folioq(i))
-		return iter_folioq_get_pages(i, pages, maxsize, maxpages, start);
 	if (iov_iter_is_xarray(i))
 		return iter_xarray_get_pages(i, pages, maxsize, maxpages, start);
 	return -EFAULT;
@@ -1569,11 +1412,6 @@ int iov_iter_npages(const struct iov_iter *i, int maxpages)
 		return bvec_npages(i, maxpages);
 	if (iov_iter_is_bvecq(i))
 		return iov_npages_bvecq(i, maxpages);
-	if (iov_iter_is_folioq(i)) {
-		unsigned offset = i->iov_offset % PAGE_SIZE;
-		int npages = DIV_ROUND_UP(offset + i->count, PAGE_SIZE);
-		return min(npages, maxpages);
-	}
 	if (iov_iter_is_xarray(i)) {
 		unsigned offset = (i->xarray_start + i->iov_offset) % PAGE_SIZE;
 		int npages = DIV_ROUND_UP(offset + i->count, PAGE_SIZE);
@@ -1941,68 +1779,6 @@ static ssize_t iov_iter_extract_bvecq_pages(struct iov_iter *iter,
 	return extracted;
 }
 
-/*
- * Extract a list of contiguous pages from an ITER_FOLIOQ iterator.  This does
- * not get references on the pages, nor does it get a pin on them.
- */
-static ssize_t iov_iter_extract_folioq_pages(struct iov_iter *i,
-					     struct page ***pages, size_t maxsize,
-					     unsigned int maxpages,
-					     iov_iter_extraction_t extraction_flags,
-					     size_t *offset0)
-{
-	const struct folio_queue *folioq = i->folioq;
-	struct page **p;
-	unsigned int nr = 0;
-	size_t extracted = 0, offset, slot = i->folioq_slot;
-
-	if (slot >= folioq_nr_slots(folioq)) {
-		folioq = folioq->next;
-		slot = 0;
-		if (WARN_ON(i->iov_offset != 0))
-			return -EIO;
-	}
-
-	offset = i->iov_offset & ~PAGE_MASK;
-	*offset0 = offset;
-
-	maxpages = want_pages_array(pages, maxsize, offset, maxpages);
-	if (!maxpages)
-		return -ENOMEM;
-	p = *pages;
-
-	for (;;) {
-		struct folio *folio = folioq_folio(folioq, slot);
-		size_t offset = i->iov_offset, fsize = folioq_folio_size(folioq, slot);
-		size_t part = PAGE_SIZE - offset % PAGE_SIZE;
-
-		if (offset < fsize) {
-			part = umin(part, umin(maxsize - extracted, fsize - offset));
-			i->count -= part;
-			i->iov_offset += part;
-			extracted += part;
-
-			p[nr++] = folio_page(folio, offset / PAGE_SIZE);
-		}
-
-		if (nr >= maxpages || extracted >= maxsize)
-			break;
-
-		if (i->iov_offset >= fsize) {
-			i->iov_offset = 0;
-			slot++;
-			if (slot == folioq_nr_slots(folioq) && folioq->next) {
-				folioq = folioq->next;
-				slot = 0;
-			}
-		}
-	}
-
-	i->folioq = folioq;
-	i->folioq_slot = slot;
-	return extracted;
-}
-
 /*
  * Extract a list of contiguous pages from an ITER_XARRAY iterator.  This does not
  * get references on the pages, nor does it get a pin on them.
@@ -2265,8 +2041,8 @@ static ssize_t iov_iter_extract_user_pages(struct iov_iter *i,
  *      added to the pages, but refs will not be taken.
  *      iov_iter_extract_will_pin() will return true.
  *
- *  (*) If the iterator is ITER_KVEC, ITER_BVEC, ITER_FOLIOQ or ITER_XARRAY, the
- *      pages are merely listed; no extra refs or pins are obtained.
+ *  (*) If the iterator is ITER_KVEC, ITER_BVEC, ITER_XARRAY, the pages are
+ *      merely listed; no extra refs or pins are obtained.
  *      iov_iter_extract_will_pin() will return 0.
  *
  * Note also:
@@ -2305,10 +2081,6 @@ ssize_t iov_iter_extract_pages(struct iov_iter *i,
 		return iov_iter_extract_bvecq_pages(i, pages, maxsize,
 						    maxpages, extraction_flags,
 						    offset0);
-	if (iov_iter_is_folioq(i))
-		return iov_iter_extract_folioq_pages(i, pages, maxsize,
-						     maxpages, extraction_flags,
-						     offset0);
 	if (iov_iter_is_xarray(i))
 		return iov_iter_extract_xarray_pages(i, pages, maxsize,
 						     maxpages, extraction_flags,
diff --git a/lib/scatterlist.c b/lib/scatterlist.c
index 23e5a180103b..b9a7298306d9 100644
--- a/lib/scatterlist.c
+++ b/lib/scatterlist.c
@@ -12,7 +12,6 @@
 #include <linux/bvec.h>
 #include <linux/bvecq.h>
 #include <linux/uio.h>
-#include <linux/folio_queue.h>
 
 /**
  * sg_nents - return total count of entries in scatterlist
@@ -1327,67 +1326,6 @@ static ssize_t extract_bvecq_to_sg(struct iov_iter *iter,
 	return ret;
 }
 
-/*
- * Extract up to sg_max folios from an FOLIOQ-type iterator and add them to
- * the scatterlist.  The pages are not pinned.
- */
-static ssize_t extract_folioq_to_sg(struct iov_iter *iter,
-				   ssize_t maxsize,
-				   struct sg_table *sgtable,
-				   unsigned int sg_max,
-				   iov_iter_extraction_t extraction_flags)
-{
-	const struct folio_queue *folioq = iter->folioq;
-	struct scatterlist *sg = sgtable->sgl + sgtable->nents;
-	unsigned int slot = iter->folioq_slot;
-	ssize_t ret = 0;
-	size_t offset = iter->iov_offset;
-
-	BUG_ON(!folioq);
-
-	if (slot >= folioq_nr_slots(folioq)) {
-		folioq = folioq->next;
-		if (WARN_ON_ONCE(!folioq))
-			return 0;
-		slot = 0;
-	}
-
-	do {
-		struct folio *folio = folioq_folio(folioq, slot);
-		size_t fsize = folioq_folio_size(folioq, slot);
-
-		if (offset < fsize) {
-			size_t part = umin(maxsize - ret, fsize - offset);
-
-			sg_set_page(sg, folio_page(folio, 0), part, offset);
-			sgtable->nents++;
-			sg++;
-			sg_max--;
-			offset += part;
-			ret += part;
-		}
-
-		if (offset >= fsize) {
-			offset = 0;
-			slot++;
-			if (slot >= folioq_nr_slots(folioq)) {
-				if (!folioq->next) {
-					WARN_ON_ONCE(ret < iter->count);
-					break;
-				}
-				folioq = folioq->next;
-				slot = 0;
-			}
-		}
-	} while (sg_max > 0 && ret < maxsize);
-
-	iter->folioq = folioq;
-	iter->folioq_slot = slot;
-	iter->iov_offset = offset;
-	iter->count -= ret;
-	return ret;
-}
-
 /*
  * Extract up to sg_max folios from an XARRAY-type iterator and add them to
  * the scatterlist.  The pages are not pinned.
@@ -1451,8 +1389,8 @@ static ssize_t extract_xarray_to_sg(struct iov_iter *iter,
  * addition of @sg_max elements.
  *
  * The pages referred to by UBUF- and IOVEC-type iterators are extracted and
- * pinned; BVEC-, BVECQ-, KVEC-, FOLIOQ- and XARRAY-type are extracted but
- * aren't pinned; DISCARD-type is not supported.
+ * pinned; BVEC-, BVECQ-, KVEC-, XARRAY-type are extracted but aren't pinned;
+ * DISCARD-type is not supported.
  *
  * No end mark is placed on the scatterlist; that's left to the caller.
  *
@@ -1487,9 +1425,6 @@ ssize_t extract_iter_to_sg(struct iov_iter *iter, size_t maxsize,
 	case ITER_BVECQ:
 		return extract_bvecq_to_sg(iter, maxsize, sgtable, sg_max,
 					   extraction_flags);
-	case ITER_FOLIOQ:
-		return extract_folioq_to_sg(iter, maxsize, sgtable, sg_max,
-					    extraction_flags);
 	case ITER_XARRAY:
 		return extract_xarray_to_sg(iter, maxsize, sgtable, sg_max,
 					    extraction_flags);
diff --git a/lib/tests/kunit_iov_iter.c b/lib/tests/kunit_iov_iter.c
index 2d831cabd4f6..19fc082e4cf3 100644
--- a/lib/tests/kunit_iov_iter.c
+++ b/lib/tests/kunit_iov_iter.c
@@ -13,7 +13,6 @@
 #include <linux/uio.h>
 #include <linux/bvec.h>
 #include <linux/bvecq.h>
-#include <linux/folio_queue.h>
 #include <linux/scatterlist.h>
 #include <linux/minmax.h>
 #include <linux/mman.h>
@@ -383,176 +382,6 @@ static void __init iov_kunit_copy_from_bvec(struct kunit *test)
 	KUNIT_SUCCEED(test);
 }
 
-static void iov_kunit_destroy_folioq(void *data)
-{
-	struct folio_queue *folioq, *next;
-
-	for (folioq = data; folioq; folioq = next) {
-		next = folioq->next;
-		kfree(folioq);
-	}
-}
-
-static void __init iov_kunit_load_folioq(struct kunit *test,
-					struct iov_iter *iter, int dir,
-					struct folio_queue *folioq,
-					struct page **pages, size_t npages)
-{
-	struct folio_queue *p = folioq;
-	size_t size = 0;
-	int i;
-
-	for (i = 0; i < npages; i++) {
-		if (folioq_full(p)) {
-			p->next = kzalloc_obj(struct folio_queue);
-			KUNIT_ASSERT_NOT_ERR_OR_NULL(test, p->next);
-			folioq_init(p->next, 0);
-			p->next->prev = p;
-			p = p->next;
-		}
-		folioq_append(p, page_folio(pages[i]));
-		size += PAGE_SIZE;
-	}
-	iov_iter_folio_queue(iter, dir, folioq, 0, 0, size);
-}
-
-static struct folio_queue *iov_kunit_create_folioq(struct kunit *test)
-{
-	struct folio_queue *folioq;
-
-	folioq = kzalloc_obj(struct folio_queue);
-	KUNIT_ASSERT_NOT_ERR_OR_NULL(test, folioq);
-	kunit_add_action_or_reset(test, iov_kunit_destroy_folioq, folioq);
-	folioq_init(folioq, 0);
-	return folioq;
-}
-
-/*
- * Test copying to a ITER_FOLIOQ-type iterator.
- */
-static void __init iov_kunit_copy_to_folioq(struct kunit *test)
-{
-	const struct kvec_test_range *pr;
-	struct iov_iter iter;
-	struct folio_queue *folioq;
-	struct page **spages, **bpages;
-	u8 *scratch, *buffer;
-	size_t bufsize, npages, size, copied;
-	int i, patt;
-
-	bufsize = 0x100000;
-	npages = bufsize / PAGE_SIZE;
-
-	folioq = iov_kunit_create_folioq(test);
-
-	scratch = iov_kunit_create_buffer(test, &spages, npages);
-	for (i = 0; i < bufsize; i++)
-		scratch[i] = pattern(i);
-
-	buffer = iov_kunit_create_buffer(test, &bpages, npages);
-	memset(buffer, 0, bufsize);
-
-	iov_kunit_load_folioq(test, &iter, READ, folioq, bpages, npages);
-
-	i = 0;
-	for (pr = kvec_test_ranges; pr->from >= 0; pr++) {
-		size = pr->to - pr->from;
-		KUNIT_ASSERT_LE(test, pr->to, bufsize);
-
-		iov_iter_folio_queue(&iter, READ, folioq, 0, 0, pr->to);
-		iov_iter_advance(&iter, pr->from);
-		copied = copy_to_iter(scratch + i, size, &iter);
-
-		KUNIT_EXPECT_EQ(test, copied, size);
-		KUNIT_EXPECT_EQ(test, iter.count, 0);
-		KUNIT_EXPECT_EQ(test, iter.iov_offset, pr->to % PAGE_SIZE);
-		i += size;
-		if (test->status == KUNIT_FAILURE)
-			goto stop;
-	}
-
-	/* Build the expected image in the scratch buffer. */
-	patt = 0;
-	memset(scratch, 0, bufsize);
-	for (pr = kvec_test_ranges; pr->from >= 0; pr++)
-		for (i = pr->from; i < pr->to; i++)
-			scratch[i] = pattern(patt++);
-
-	/* Compare the images */
-	for (i = 0; i < bufsize; i++) {
-		KUNIT_EXPECT_EQ_MSG(test, buffer[i], scratch[i], "at i=%x", i);
-		if (buffer[i] != scratch[i])
-			return;
-	}
-
-stop:
-	KUNIT_SUCCEED(test);
-}
-
-/*
- * Test copying from a ITER_FOLIOQ-type iterator.
- */
-static void __init iov_kunit_copy_from_folioq(struct kunit *test)
-{
-	const struct kvec_test_range *pr;
-	struct iov_iter iter;
-	struct folio_queue *folioq;
-	struct page **spages, **bpages;
-	u8 *scratch, *buffer;
-	size_t bufsize, npages, size, copied;
-	int i, j;
-
-	bufsize = 0x100000;
-	npages = bufsize / PAGE_SIZE;
-
-	folioq = iov_kunit_create_folioq(test);
-
-	buffer = iov_kunit_create_buffer(test, &bpages, npages);
-	for (i = 0; i < bufsize; i++)
-		buffer[i] = pattern(i);
-
-	scratch = iov_kunit_create_buffer(test, &spages, npages);
-	memset(scratch, 0, bufsize);
-
-	iov_kunit_load_folioq(test, &iter, READ, folioq, bpages, npages);
-
-	i = 0;
-	for (pr = kvec_test_ranges; pr->from >= 0; pr++) {
-		size = pr->to - pr->from;
-		KUNIT_ASSERT_LE(test, pr->to, bufsize);
-
-		iov_iter_folio_queue(&iter, WRITE, folioq, 0, 0, pr->to);
-		iov_iter_advance(&iter, pr->from);
-		copied = copy_from_iter(scratch + i, size, &iter);
-
-		KUNIT_EXPECT_EQ(test, copied, size);
-		KUNIT_EXPECT_EQ(test, iter.count, 0);
-		KUNIT_EXPECT_EQ(test, iter.iov_offset, pr->to % PAGE_SIZE);
-		i += size;
-	}
-
-	/* Build the expected image in the main buffer. */
-	i = 0;
-	memset(buffer, 0, bufsize);
-	for (pr = kvec_test_ranges; pr->from >= 0; pr++) {
-		for (j = pr->from; j < pr->to; j++) {
-			buffer[i++] = pattern(j);
-			if (i >= bufsize)
-				goto stop;
-		}
-	}
-stop:
-
-	/* Compare the images */
-	for (i = 0; i < bufsize; i++) {
-		KUNIT_EXPECT_EQ_MSG(test, scratch[i], buffer[i], "at i=%x", i);
-		if (scratch[i] != buffer[i])
-			return;
-	}
-
-	KUNIT_SUCCEED(test);
-}
-
 static void iov_kunit_destroy_bvecq(void *data)
 {
 	struct bvecq *bq, *next;
@@ -1124,85 +953,6 @@ static void __init iov_kunit_extract_pages_bvecq(struct kunit *test)
 	KUNIT_SUCCEED(test);
 }
 
-/*
- * Test the extraction of ITER_FOLIOQ-type iterators.
- */
-static void __init iov_kunit_extract_pages_folioq(struct kunit *test)
-{
-	const struct kvec_test_range *pr;
-	struct folio_queue *folioq;
-	struct iov_iter iter;
-	struct page **bpages, *pagelist[8], **pages = pagelist;
-	ssize_t len;
-	size_t bufsize, size = 0, npages;
-	int i, from;
-
-	bufsize = 0x100000;
-	npages = bufsize / PAGE_SIZE;
-
-	folioq = iov_kunit_create_folioq(test);
-
-	iov_kunit_create_buffer(test, &bpages, npages);
-	iov_kunit_load_folioq(test, &iter, READ, folioq, bpages, npages);
-
-	for (pr = kvec_test_ranges; pr->from >= 0; pr++) {
-		from = pr->from;
-		size = pr->to - from;
-		KUNIT_ASSERT_LE(test, pr->to, bufsize);
-
-		iov_iter_folio_queue(&iter, WRITE, folioq, 0, 0, pr->to);
-		iov_iter_advance(&iter, from);
-
-		do {
-			size_t offset0 = LONG_MAX;
-
-			for (i = 0; i < ARRAY_SIZE(pagelist); i++)
-				pagelist[i] = (void *)(unsigned long)0xaa55aa55aa55aa55ULL;
-
-			len = iov_iter_extract_pages(&iter, &pages, 100 * 1024,
-						     ARRAY_SIZE(pagelist), 0, &offset0);
-			KUNIT_EXPECT_GE(test, len, 0);
-			if (len < 0)
-				break;
-			KUNIT_EXPECT_LE(test, len, size);
-			KUNIT_EXPECT_EQ(test, iter.count, size - len);
-			if (len == 0)
-				break;
-			size -= len;
-			KUNIT_EXPECT_GE(test, (ssize_t)offset0, 0);
-			KUNIT_EXPECT_LT(test, offset0, PAGE_SIZE);
-
-			for (i = 0; i < ARRAY_SIZE(pagelist); i++) {
-				struct page *p;
-				ssize_t part = min_t(ssize_t, len, PAGE_SIZE - offset0);
-				int ix;
-
-				KUNIT_ASSERT_GE(test, part, 0);
-				ix = from / PAGE_SIZE;
-				KUNIT_ASSERT_LT(test, ix, npages);
-				p = bpages[ix];
-				KUNIT_EXPECT_PTR_EQ(test, pagelist[i], p);
-				KUNIT_EXPECT_EQ(test, offset0, from % PAGE_SIZE);
-				from += part;
-				len -= part;
-				KUNIT_ASSERT_GE(test, len, 0);
-				if (len == 0)
-					break;
-				offset0 = 0;
-			}
-
-			if (test->status == KUNIT_FAILURE)
-				goto stop;
-		} while (iov_iter_count(&iter) > 0);
-
-		KUNIT_EXPECT_EQ(test, size, 0);
-		KUNIT_EXPECT_EQ(test, iter.count, 0);
-	}
-
-stop:
-	KUNIT_SUCCEED(test);
-}
-
 /*
  * Test the extraction of ITER_XARRAY-type iterators.
  */
@@ -1446,23 +1196,6 @@ static void __init iov_kunit_iter_to_sg_bvecq(struct kunit *test)
 	iov_kunit_iter_to_sg_check(test, &iter, bufsize, &data);
 }
 
-static void __init iov_kunit_iter_to_sg_folioq(struct kunit *test)
-{
-	struct iov_kunit_iter_to_sg_data data;
-	struct folio_queue *folioq;
-	struct iov_iter iter;
-	size_t bufsize;
-
-	bufsize = 0x200000;
-	iov_kunit_iter_to_sg_init(test, bufsize, false, &data);
-
-	folioq = iov_kunit_create_folioq(test);
-	iov_kunit_load_folioq(test, &iter, READ, folioq, data.pages,
-			      data.npages);
-
-	iov_kunit_iter_to_sg_check(test, &iter, bufsize, &data);
-}
-
 static void __init iov_kunit_iter_to_sg_xarray(struct kunit *test)
 {
 	struct iov_kunit_iter_to_sg_data data;
@@ -1501,19 +1234,15 @@ static struct kunit_case __refdata iov_kunit_cases[] = {
 	KUNIT_CASE(iov_kunit_copy_from_bvec),
 	KUNIT_CASE(iov_kunit_copy_to_bvecq),
 	KUNIT_CASE(iov_kunit_copy_from_bvecq),
-	KUNIT_CASE(iov_kunit_copy_to_folioq),
-	KUNIT_CASE(iov_kunit_copy_from_folioq),
 	KUNIT_CASE(iov_kunit_copy_to_xarray),
 	KUNIT_CASE(iov_kunit_copy_from_xarray),
 	KUNIT_CASE(iov_kunit_extract_pages_kvec),
 	KUNIT_CASE(iov_kunit_extract_pages_bvec),
 	KUNIT_CASE(iov_kunit_extract_pages_bvecq),
-	KUNIT_CASE(iov_kunit_extract_pages_folioq),
 	KUNIT_CASE(iov_kunit_extract_pages_xarray),
 	KUNIT_CASE(iov_kunit_iter_to_sg_kvec),
 	KUNIT_CASE(iov_kunit_iter_to_sg_bvec),
 	KUNIT_CASE(iov_kunit_iter_to_sg_bvecq),
-	KUNIT_CASE(iov_kunit_iter_to_sg_folioq),
 	KUNIT_CASE(iov_kunit_iter_to_sg_xarray),
 	KUNIT_CASE(iov_kunit_iter_to_sg_ubuf),
 	{}

