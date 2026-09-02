Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E70C33815D3
	for <linux-nfs@vger.kernel.org>; Wed,  2 Sep 2026 17:35:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788370508; cv=none; b=kaj5LBY3424Op5ijKIsNqJzy7LogugcFeLz4H9SA0lmhf78h2G3zpFu67uaJeDkFPBDpXQm4h9nABG05upUFo7Z2ePB6c7RRDwVymauj/sQr80cnZ7s0by4jlaSSk2woJhpqGNK9WrImbHQYJZP9VN8rhf+m2UR+R8dSQbgtyHA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788370508; c=relaxed/simple;
	bh=esZ0egzSdQgbWRTOxXN3HQzk26x8mR73kg8Ev4U6xOw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=e3dv5JJ5U5sgPhL0dHIEG0agtzgVrnpD+loLbHRKQbeNadYkEDB50Eb+GaxszFQMCyIGPayW9Tmetk4pIxbHpDyubAYz0ufV4FsieuFWOWyYENwrF3tHgOGx5B8R1UhAtDOse0aiYPA+xdFCG19hHJsYuGfKYB+JF7j06+tB5fE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=OHdpBSgH; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="OHdpBSgH"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788370503;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=+4L7c83X+Ffi3wC3+QbS4Vmd+jV/02+jwWAc0sXzVnc=;
	b=OHdpBSgHKAPA67D6sYq/tDCrN/4ag19cEkiIXY0okQz3tyzDulT32rwDGqorffI5+OSgLS
	yi8WquclIACyi67L/CQ1A9LtsEKgyu25dDQfzGRQeoUJyMaetvV4v6aeOslrVyBzLCIb0Z
	AWR8duHKp2ORe3OwLgpBbimsTacCAZ8=
Received: from mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-341-0YRdZTbnPbShm3R9fpXffA-1; Wed,
 02 Sep 2026 13:34:59 -0400
X-MC-Unique: 0YRdZTbnPbShm3R9fpXffA-1
X-Mimecast-MFC-AGG-ID: 0YRdZTbnPbShm3R9fpXffA_1788370496
Received: from mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.4])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 1D140195396F;
	Wed,  2 Sep 2026 17:34:56 +0000 (UTC)
Received: from warthog.com (unknown [10.44.32.158])
	by mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id DAEC23000DA3;
	Wed,  2 Sep 2026 17:34:49 +0000 (UTC)
From: David Howells <dhowells@redhat.com>
To: Paulo Alcantara <pc@manguebit.org>
Cc: David Howells <dhowells@redhat.com>,
	Christian Brauner <christian@brauner.io>,
	Matthew Wilcox <willy@infradead.org>,
	Christoph Hellwig <hch@infradead.org>,
	Jens Axboe <axboe@kernel.dk>,
	Leon Romanovsky <leon@kernel.org>,
	Namjae Jeon <linkinjeon@kernel.org>,
	ChenXiaoSong <chenxiaosong@chenxiaosong.com>,
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
	linux-erofs@lists.ozlabs.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-block@vger.kernel.org
Subject: [PATCH v11 06/36] iov_iter: Make iov_iter_get_pages*() wrap iov_iter_extract_pages()
Date: Wed,  2 Sep 2026 18:33:18 +0100
Message-ID: <20260902173350.3468672-7-dhowells@redhat.com>
In-Reply-To: <20260902173350.3468672-1-dhowells@redhat.com>
References: <20260902173350.3468672-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.4

Make iov_iter_get_pages*() wrap iov_iter_extract_pages() for kernel
iterator types (e.g. ITER_BVEC, ITER_FOLIOQ, ITER_XARRAY).  The pages
obtained have their refcounts incremented afterwards if they're not slab
pages.  ITER_KVEC is left returning -EFAULT.

Signed-off-by: David Howells <dhowells@redhat.com>
Reviewed-by: Paulo Alcantara (Red Hat) <pc@manguebit.org>
cc: Matthew Wilcox <willy@infradead.org>
cc: Christoph Hellwig <hch@infradead.org>
cc: Jens Axboe <axboe@kernel.dk>
cc: linux-block@vger.kernel.org
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 lib/iov_iter.c | 164 ++++++-------------------------------------------
 1 file changed, 19 insertions(+), 145 deletions(-)

diff --git a/lib/iov_iter.c b/lib/iov_iter.c
index c489569a5815..a16b86fd0278 100644
--- a/lib/iov_iter.c
+++ b/lib/iov_iter.c
@@ -910,118 +910,34 @@ static int want_pages_array(struct page ***res, size_t size,
 	return count;
 }
 
-static ssize_t iter_folioq_get_pages(struct iov_iter *iter,
+/*
+ * Wrap iov_iter_extract_pages() and then pin the non-slab pages we got back.
+ * This only works for non-user iterator types as get_pages uses get_user_pages
+ * not pin_user_pages.
+ */
+static ssize_t iter_get_kernel_pages(struct iov_iter *iter,
 				     struct page ***ppages, size_t maxsize,
 				     unsigned maxpages, size_t *_start_offset)
 {
-	const struct folio_queue *folioq = iter->folioq;
 	struct page **pages;
-	unsigned int slot = iter->folioq_slot;
-	size_t extracted = 0, count = iter->count, iov_offset = iter->iov_offset;
+	ssize_t ret, done;
 
-	if (slot >= folioq_nr_slots(folioq)) {
-		folioq = folioq->next;
-		slot = 0;
-		if (WARN_ON(iov_offset != 0))
-			return -EIO;
-	}
+	ret = iov_iter_extract_pages(iter, ppages, maxsize, maxpages,
+				     0, _start_offset);
+	if (ret <= 0)
+		return ret;
 
-	maxpages = want_pages_array(ppages, maxsize, iov_offset & ~PAGE_MASK, maxpages);
-	if (!maxpages)
-		return -ENOMEM;
-	*_start_offset = iov_offset & ~PAGE_MASK;
 	pages = *ppages;
+	for (done = ret + *_start_offset; done > 0; done -= PAGE_SIZE) {
+		struct folio *folio = page_folio(*pages);
 
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
-static ssize_t iter_xarray_populate_pages(struct page **pages, struct xarray *xa,
-					  pgoff_t index, unsigned int nr_pages)
-{
-	XA_STATE(xas, xa, index);
-	struct folio *folio;
-	unsigned int ret = 0;
-
-	rcu_read_lock();
-	for (folio = xas_load(&xas); folio; folio = xas_next(&xas)) {
-		if (xas_retry(&xas, folio))
-			continue;
-
-		/* Has the folio moved or been split? */
-		if (unlikely(folio != xas_reload(&xas))) {
-			xas_reset(&xas);
-			continue;
-		}
-
-		pages[ret] = folio_file_page(folio, xas.xa_index);
-		folio_get(folio);
-		if (++ret == nr_pages)
-			break;
+		if (!folio_test_slab(folio) && !folio_test_large_kmalloc(folio))
+			folio_get(folio);
+		pages++;
 	}
-	rcu_read_unlock();
 	return ret;
 }
 
-static ssize_t iter_xarray_get_pages(struct iov_iter *i,
-				     struct page ***pages, size_t maxsize,
-				     unsigned maxpages, size_t *_start_offset)
-{
-	unsigned nr, offset, count;
-	pgoff_t index;
-	loff_t pos;
-
-	pos = i->xarray_start + i->iov_offset;
-	index = pos >> PAGE_SHIFT;
-	offset = pos & ~PAGE_MASK;
-	*_start_offset = offset;
-
-	count = want_pages_array(pages, maxsize, offset, maxpages);
-	if (!count)
-		return -ENOMEM;
-	nr = iter_xarray_populate_pages(*pages, i->xarray, index, count);
-	if (nr == 0)
-		return 0;
-
-	maxsize = min_t(size_t, nr * PAGE_SIZE - offset, maxsize);
-	i->iov_offset += maxsize;
-	i->count -= maxsize;
-	return maxsize;
-}
-
 /* must be done on non-empty ITER_UBUF or ITER_IOVEC one */
 static unsigned long first_iovec_segment(const struct iov_iter *i, size_t *size)
 {
@@ -1044,22 +960,6 @@ static unsigned long first_iovec_segment(const struct iov_iter *i, size_t *size)
 	BUG(); // if it had been empty, we wouldn't get called
 }
 
-/* must be done on non-empty ITER_BVEC one */
-static struct page *first_bvec_segment(const struct iov_iter *i,
-				       size_t *size, size_t *start)
-{
-	struct page *page;
-	size_t skip = i->iov_offset, len;
-
-	len = i->bvec->bv_len - skip;
-	if (*size > len)
-		*size = len;
-	skip += i->bvec->bv_offset;
-	page = i->bvec->bv_page + skip / PAGE_SIZE;
-	*start = skip % PAGE_SIZE;
-	return page;
-}
-
 static ssize_t __iov_iter_get_pages_alloc(struct iov_iter *i,
 		   struct page ***pages, size_t maxsize,
 		   unsigned int maxpages, size_t *start)
@@ -1095,36 +995,10 @@ static ssize_t __iov_iter_get_pages_alloc(struct iov_iter *i,
 		iov_iter_advance(i, maxsize);
 		return maxsize;
 	}
-	if (iov_iter_is_bvec(i)) {
-		struct page **p;
-		struct page *page;
 
-		page = first_bvec_segment(i, &maxsize, start);
-		n = want_pages_array(pages, maxsize, *start, maxpages);
-		if (!n)
-			return -ENOMEM;
-		p = *pages;
-		for (int k = 0; k < n; k++) {
-			struct folio *folio = page_folio(page + k);
-			p[k] = page + k;
-			if (!folio_test_slab(folio))
-				folio_get(folio);
-		}
-		maxsize = min_t(size_t, maxsize, n * PAGE_SIZE - *start);
-		i->count -= maxsize;
-		i->iov_offset += maxsize;
-		if (i->iov_offset == i->bvec->bv_len) {
-			i->iov_offset = 0;
-			i->bvec++;
-			i->nr_segs--;
-		}
-		return maxsize;
-	}
-	if (iov_iter_is_folioq(i))
-		return iter_folioq_get_pages(i, pages, maxsize, maxpages, start);
-	if (iov_iter_is_xarray(i))
-		return iter_xarray_get_pages(i, pages, maxsize, maxpages, start);
-	return -EFAULT;
+	if (iov_iter_is_kvec(i))
+		return -EFAULT;
+	return iter_get_kernel_pages(i, pages, maxsize, maxpages, start);
 }
 
 ssize_t iov_iter_get_pages2(struct iov_iter *i, struct page **pages,

