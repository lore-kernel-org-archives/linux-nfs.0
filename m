Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1FA5840B0F2
	for <linux-nfs@vger.kernel.org>; Mon, 10 Aug 2026 14:48:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786373336; cv=none; b=ZEL7V0r1iAjpB84HfODRmDzrXaRQaJ00tP/u3UAspY2WugisGP3DnWK1OrdBMu6fbRa6uzFx7zgb+2gvSMHasi+w6wsp4bWGjn9araBoecRMgJ7rksbv8ejKSm+4jB2tNkCwlvVuEJwELWsfGuAAMNZjtIXCtJg39SwOxC+t404=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786373336; c=relaxed/simple;
	bh=/VLzmM9DW0Ypset+JB8TQ4jU0o2IL4IGG5SSckShR88=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=a/Wg1ttIKBsWOzmS55jhNjYcbpNpiRlesG5m+GxtYh9Co1O+X5JlxeU5aZksWPHGctcpLhddCSEYDMRg9tZQ/Scypza/QmI410ET1uKbu0or3ThDAhQZhZGOdHgzC+1cBKXz/SHrpLlokLFIZbzLk30ZphZXMn79YDOSlQYYO0Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=cGTKI8Qg; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="cGTKI8Qg"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1786373334;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=w7ShGW+upZHR5mu8dwZINAuw/Lvw06ThB7+ja2GcOFA=;
	b=cGTKI8Qg5SYL3DNlGqrBz2/8R+kgCRwA9DYBmjh+jPdhfsmuBtQa0kacFj7AbgI4Ll9kM5
	uL1NcZX/xfBCWo1fRvxFcAzk9OAZBjj/5mEIwGCQICkL+IpglRS+Id4DWtUK1/gXiv79J0
	ut0NNhrw7DU46ebzj3YcN1/sKd8tV4A=
Received: from mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-115-pyJjQk5AMY6R7tA3wSApew-1; Mon,
 10 Aug 2026 10:48:47 -0400
X-MC-Unique: pyJjQk5AMY6R7tA3wSApew-1
X-Mimecast-MFC-AGG-ID: pyJjQk5AMY6R7tA3wSApew_1786373324
Received: from mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.111])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 3F3201800655;
	Mon, 10 Aug 2026 14:48:44 +0000 (UTC)
Received: from warthog.procyon.org.com (unknown [10.44.32.44])
	by mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 5092D180034C;
	Mon, 10 Aug 2026 14:48:38 +0000 (UTC)
From: David Howells <dhowells@redhat.com>
To: Christian Brauner <christian@brauner.io>,
	Matthew Wilcox <willy@infradead.org>,
	Christoph Hellwig <hch@infradead.org>
Cc: David Howells <dhowells@redhat.com>,
	Paulo Alcantara <pc@manguebit.org>,
	Jens Axboe <axboe@kernel.dk>,
	Leon Romanovsky <leon@kernel.org>,
	Steve French <sfrench@samba.org>,
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
Subject: [PATCH v9 05/26] iov_iter: Make iov_iter_get_pages*() wrap iov_iter_extract_pages()
Date: Mon, 10 Aug 2026 15:47:22 +0100
Message-ID: <20260810144746.574036-6-dhowells@redhat.com>
In-Reply-To: <20260810144746.574036-1-dhowells@redhat.com>
References: <20260810144746.574036-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.111

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
index c2484551a4e8..31afc9687eb6 100644
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
+		if (!folio_test_slab(folio))
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

