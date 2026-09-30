Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7382D48820E
	for <linux-nfs@vger.kernel.org>; Wed, 30 Sep 2026 12:54:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790772870; cv=none; b=HLMStnAfJdKF/1d32ES3TFfDtqsMsNTBNmlx2mORAza6w5cIM5eZHUM5TXKU18pUMM3NbsAMv7quPQTf82KcdX3fIOpVddFZDX1efg10CuTJILO77oQOOTAL1V169mMaS2DVh7lAihA/9D6GCt7qdcaf5izbekjhYql73DDnDVw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790772870; c=relaxed/simple;
	bh=3PE9CrdVTqQ6/gUcJ20Pv9nmGM59anQMvmvAqTaBklY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=RBZcp9/L185b4GmHs4+5mwTneDn7AR2D68VQCAp3A5vCyAeX6l66RH3qjM25GO3BZJMBMobpr11bUkf2omFKIkBVl9JfyUNdgW4pggNgzug3nCU3T94fbjE4dFyC9XjLivq0Mkh7Tsl4zG5b1VGfwJe/xnrwilCR9KpV2ElBDRQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=go/K/pkY; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="go/K/pkY"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1790772852;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=EK8MOZrQOIxl2Eo5QBua6BTCtSlN2wn0GWbOIzT467Y=;
	b=go/K/pkYZM7ZViWEW04W842QEVKqJPXLAzFp4Rdk9dVQLB1VLpHBtJatm32AIr8Et4L2g2
	kSuLItzN/jn5BN7b0+wi7yNRnI8T8cBp0NN+VyRDmx6EL1urFW0cSxl3EhoMK6eLpEvufe
	Q9pUHVsWhVfejjArSJIo+96O3RFM7s8=
Received: from mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-378-piTk_puMNka0iCWJ80a1hQ-1; Wed,
 30 Sep 2026 08:54:08 -0400
X-MC-Unique: piTk_puMNka0iCWJ80a1hQ-1
X-Mimecast-MFC-AGG-ID: piTk_puMNka0iCWJ80a1hQ_1790772846
Received: from mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.95])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 07D5A1977334;
	Wed, 30 Sep 2026 12:54:06 +0000 (UTC)
Received: from warthog.com (unknown [10.44.32.54])
	by mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 0BC725BC;
	Wed, 30 Sep 2026 12:53:59 +0000 (UTC)
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
Subject: [PATCH v14 09/10] iov_iter: Remove ITER_FOLIOQ
Date: Wed, 30 Sep 2026 13:52:44 +0100
Message-ID: <20260930125247.3232130-10-dhowells@redhat.com>
In-Reply-To: <20260930125247.3232130-1-dhowells@redhat.com>
References: <20260930125247.3232130-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.6 on 10.30.177.95

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
 5 files changed, 7 insertions(+), 646 deletions(-)

diff --git a/include/linux/iov_iter.h b/include/linux/iov_iter.h
index ec0aa2893689..39ffd5878f50 100644
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
 	return iterate_discard(iter, len, priv, priv2, step);
@@ -410,8 +351,8 @@ size_t iterate_and_advance(struct iov_iter *iter, size_t len, void *priv,
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
@@ -440,8 +381,6 @@ size_t iterate_and_advance_kernel(struct iov_iter *iter, size_t len, void *priv,
 		return iterate_kvec(iter, len, priv, priv2, step);
 	if (iov_iter_is_bvecq(iter))
 		return iterate_bvecq(iter, len, priv, priv2, step);
-	if (iov_iter_is_folioq(iter))
-		return iterate_folioq(iter, len, priv, priv2, step);
 	if (iov_iter_is_xarray(iter))
 		return iterate_xarray(iter, len, priv, priv2, step);
 	return iterate_discard(iter, len, priv, priv2, step);
diff --git a/include/linux/uio.h b/include/linux/uio.h
index 2d75a267da86..8d82a8258ef1 100644
--- a/include/linux/uio.h
+++ b/include/linux/uio.h
@@ -11,7 +11,6 @@
 #include <uapi/linux/uio.h>
 
 struct page;
-struct folio_queue;
 
 typedef unsigned int __bitwise iov_iter_extraction_t;
 
@@ -27,7 +26,6 @@ enum iter_type {
 	ITER_BVEC,
 	ITER_KVEC,
 	ITER_BVECQ,
-	ITER_FOLIOQ,
 	ITER_XARRAY,
 	ITER_DISCARD,
 };
@@ -70,7 +68,6 @@ struct iov_iter {
 				const struct kvec *kvec;
 				const struct bio_vec *bvec;
 				const struct bvecq *bvecq;
-				const struct folio_queue *folioq;
 				struct xarray *xarray;
 				void __user *ubuf;
 			};
@@ -80,7 +77,6 @@ struct iov_iter {
 	union {
 		unsigned long nr_segs;
 		u16 bvecq_slot;
-		u8 folioq_slot;
 		loff_t xarray_start;
 	};
 };
@@ -153,11 +149,6 @@ static inline bool iov_iter_is_bvecq(const struct iov_iter *i)
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
@@ -306,9 +297,6 @@ void iov_iter_discard(struct iov_iter *i, unsigned int direction, size_t count);
 void iov_iter_bvec_queue(struct iov_iter *i, unsigned int direction,
 			 const struct bvecq *bvecq,
 			 unsigned int first_slot, unsigned int offset, size_t count);
-void iov_iter_folio_queue(struct iov_iter *i, unsigned int direction,
-			  const struct folio_queue *folioq,
-			  unsigned int first_slot, unsigned int offset, size_t count);
 void iov_iter_xarray(struct iov_iter *i, unsigned int direction, struct xarray *xarray,
 		     loff_t start, size_t count);
 ssize_t iov_iter_get_pages2(struct iov_iter *i, struct page **pages,
diff --git a/lib/iov_iter.c b/lib/iov_iter.c
index 6b093069b005..72cef6a79c3e 100644
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
@@ -619,8 +586,6 @@ void iov_iter_advance(struct iov_iter *i, size_t size)
 		iov_iter_bvec_advance(i, size);
 	} else if (iov_iter_is_bvecq(i)) {
 		iov_iter_bvecq_advance(i, size);
-	} else if (iov_iter_is_folioq(i)) {
-		iov_iter_folioq_advance(i, size);
 	} else if (iov_iter_is_discard(i)) {
 		i->count -= size;
 	}
@@ -654,32 +619,6 @@ static void iov_iter_bvecq_revert(struct iov_iter *i, size_t unroll)
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
@@ -714,9 +653,6 @@ void iov_iter_revert(struct iov_iter *i, size_t unroll)
 	} else if (iov_iter_is_bvecq(i)) {
 		i->iov_offset = 0;
 		iov_iter_bvecq_revert(i, unroll);
-	} else if (iov_iter_is_folioq(i)) {
-		i->iov_offset = 0;
-		iov_iter_folioq_revert(i, unroll);
 	} else { /* same logics for iovec and kvec */
 		const struct iovec *iov = iter_iov(i);
 		while (1) {
@@ -766,8 +702,6 @@ size_t iov_iter_single_seg_count(const struct iov_iter *i)
 		}
 		return min(i->count, bq->bv[slot].bv_len - offset);
 	}
-	if (unlikely(iov_iter_is_folioq(i)))
-		return umin(folioq_folio_size(i->folioq, i->folioq_slot), i->count);
 	return i->count;
 }
 EXPORT_SYMBOL(iov_iter_single_seg_count);
@@ -833,36 +767,6 @@ void iov_iter_bvec_queue(struct iov_iter *i, unsigned int direction,
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
@@ -1006,9 +910,7 @@ unsigned long iov_iter_alignment(const struct iov_iter *i)
 	if (iov_iter_is_bvecq(i))
 		return iov_iter_alignment_bvecq(i);
 
-	/* With both xarray and folioq types, we're dealing with whole folios. */
-	if (iov_iter_is_folioq(i))
-		return i->iov_offset | i->count;
+	/* With the xarray type, we're dealing with whole folios. */
 	if (iov_iter_is_xarray(i))
 		return (i->xarray_start + i->iov_offset) | i->count;
 
@@ -1216,65 +1118,6 @@ static ssize_t iter_bvecq_get_pages(struct iov_iter *iter,
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
@@ -1428,8 +1271,6 @@ static ssize_t __iov_iter_get_pages_alloc(struct iov_iter *i,
 	}
 	if (iov_iter_is_bvecq(i))
 		return iter_bvecq_get_pages(i, pages, maxsize, maxpages, start);
-	if (iov_iter_is_folioq(i))
-		return iter_folioq_get_pages(i, pages, maxsize, maxpages, start);
 	if (iov_iter_is_xarray(i))
 		return iter_xarray_get_pages(i, pages, maxsize, maxpages, start);
 	return -EFAULT;
@@ -1548,11 +1389,6 @@ int iov_iter_npages(const struct iov_iter *i, int maxpages)
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
@@ -1919,68 +1755,6 @@ static ssize_t iov_iter_extract_bvecq_pages(struct iov_iter *iter,
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
@@ -2243,8 +2017,8 @@ static ssize_t iov_iter_extract_user_pages(struct iov_iter *i,
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
@@ -2283,10 +2057,6 @@ ssize_t iov_iter_extract_pages(struct iov_iter *i,
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
index a3aeeca6ed58..a2a83ba613fd 100644
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
@@ -1430,23 +1180,6 @@ static void __init iov_kunit_iter_to_sg_bvec(struct kunit *test)
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
@@ -1485,18 +1218,14 @@ static struct kunit_case __refdata iov_kunit_cases[] = {
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
-	KUNIT_CASE(iov_kunit_iter_to_sg_folioq),
 	KUNIT_CASE(iov_kunit_iter_to_sg_xarray),
 	KUNIT_CASE(iov_kunit_iter_to_sg_ubuf),
 	{}

