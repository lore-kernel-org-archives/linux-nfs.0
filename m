Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 09508478875
	for <linux-nfs@vger.kernel.org>; Thu,  8 Oct 2026 08:48:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791449322; cv=none; b=MrSk6qUNBd/5lHY6A8rKqXrrSN0tbEbOzHa964qQGALDtPTyx5Z+jbyFG4JHQz/qtU7KOn6taHcRHg9KwryM14wK45ez86/Ua7mN2LFRdkLoUBfUANGiYWlfP7tmHx8vq7cChyd2sKSF/AfegcITYjkyGswZ9ugTqD/VKo5LTog=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791449322; c=relaxed/simple;
	bh=ClCUdk81cZk4pVxj+ERQ4XC4vdFYrCdEayQPaaNm4mo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Fbv+bqfSMrS9tAmRqEYpAmTIWuDwmZM6faxK254PyMZKEqhDpRD+UcyhnfKjbRiHuwrSQnLe5UazE1lhuHNIexxEJlQ6thiCh1zuySiZObG9YfgcwbZ0d34wPy2pdV9xnBVOwexV6hX4JN3lpay9Bnprd7qwKImwPXdf4umcucU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=De08tYHD; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="De08tYHD"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1791449320;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=dhUChjftbbUORUyJn0QdHcvziOACv2RyPij5apElEWE=;
	b=De08tYHDR9ueXtcN3hFEs4Rpey9UC/KHky+Xp81rD/htEBkcgZXk/CVmgCaRVyjc3shpUr
	t9zbvLT/9Ec3zOCcd5+RtlwM3/7pJ6woBB7zcSPW0EphlPh7Itvb5tBO8Uo10bFH8KH35+
	ahTPhkQ1oFaHinRxFNSZSvD5jvwNeGM=
Received: from mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-471-56UnQx3PMY-7lhUedwrqgg-1; Thu,
 08 Oct 2026 04:48:33 -0400
X-MC-Unique: 56UnQx3PMY-7lhUedwrqgg-1
X-Mimecast-MFC-AGG-ID: 56UnQx3PMY-7lhUedwrqgg_1791449311
Received: from mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.12])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 489691809CAD;
	Thu,  8 Oct 2026 08:48:31 +0000 (UTC)
Received: from warthog.com (unknown [10.44.32.90])
	by mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 8983E1956086;
	Thu,  8 Oct 2026 08:48:26 +0000 (UTC)
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
	linux-kernel@vger.kernel.org
Subject: [PATCH v16 8/8] netfs: Remove netfs_extract_user_iter()
Date: Thu,  8 Oct 2026 09:47:20 +0100
Message-ID: <20261008084722.963948-9-dhowells@redhat.com>
In-Reply-To: <20261008084722.963948-1-dhowells@redhat.com>
References: <20261008084722.963948-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.12

Remove netfs_extract_user_iter() as it has been replaced with
netfs_extract_iter().

Signed-off-by: David Howells <dhowells@redhat.com>
Reviewed-by: Paulo Alcantara <pc@manguebit.org>
cc: Matthew Wilcox <willy@infradead.org>
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 fs/netfs/iterator.c   | 297 ------------------------------------------
 include/linux/netfs.h |   5 -
 2 files changed, 302 deletions(-)

diff --git a/fs/netfs/iterator.c b/fs/netfs/iterator.c
index d9ff6646d5d1..5e9de06c1cad 100644
--- a/fs/netfs/iterator.c
+++ b/fs/netfs/iterator.c
@@ -155,300 +155,3 @@ ssize_t netfs_extract_iter(struct iov_iter *orig, size_t max_len, size_t max_pag
 
 }
 EXPORT_SYMBOL_GPL(netfs_extract_iter);
-
-#if 0 // TODO: Remove in subsequent patch
-/**
- * netfs_extract_user_iter - Extract the pages from a user iterator into a bvec
- * @orig: The original iterator
- * @orig_len: The amount of iterator to copy
- * @new: The iterator to be set up
- * @extraction_flags: Flags to qualify the request
- *
- * Extract the page fragments from the given amount of the source iterator and
- * build up a second iterator that refers to all of those bits.  This allows
- * the original iterator to be disposed of.
- *
- * @extraction_flags can have ITER_ALLOW_P2PDMA set to request peer-to-peer DMA be
- * allowed on the pages extracted.
- *
- * On success, the number of elements in the bvec is returned, the original
- * iterator will have been advanced by the amount extracted.
- *
- * The iov_iter_extract_mode() function should be used to query how cleanup
- * should be performed.
- */
-ssize_t netfs_extract_user_iter(struct iov_iter *orig, size_t orig_len,
-				struct iov_iter *new,
-				iov_iter_extraction_t extraction_flags)
-{
-	struct bio_vec *bv = NULL;
-	struct page **pages;
-	unsigned int cur_npages;
-	unsigned int max_pages;
-	unsigned int npages = 0;
-	unsigned int i;
-	ssize_t ret = 0;
-	size_t count = orig_len, offset, len;
-	size_t bv_size, pg_size;
-
-	if (WARN_ON_ONCE(!iter_is_ubuf(orig) && !iter_is_iovec(orig)))
-		return -EIO;
-
-	max_pages = iov_iter_npages(orig, INT_MAX);
-	bv_size = array_size(max_pages, sizeof(*bv));
-	bv = kvmalloc(bv_size, GFP_KERNEL);
-	if (!bv)
-		return -ENOMEM;
-
-	/* Put the page list at the end of the bvec list storage.  bvec
-	 * elements are larger than page pointers, so as long as we work
-	 * 0->last, we should be fine.
-	 */
-	pg_size = array_size(max_pages, sizeof(*pages));
-	pages = (void *)bv + bv_size - pg_size;
-
-	while (count && npages < max_pages) {
-		ret = iov_iter_extract_pages(orig, &pages, count,
-					     max_pages - npages, extraction_flags,
-					     &offset);
-		if (unlikely(ret <= 0)) {
-			ret = ret ?: -EIO;
-			break;
-		}
-
-		if (WARN(ret > count,
-			 "%s: extract_pages overrun %zd > %zu bytes\n",
-			 __func__, ret, count)) {
-			ret = -EIO;
-			break;
-		}
-
-		cur_npages = DIV_ROUND_UP(offset + ret, PAGE_SIZE);
-		if (WARN(cur_npages > max_pages - npages,
-			 "%s: extract_pages overrun %u > %u pages\n",
-			 __func__, npages + cur_npages, max_pages)) {
-			ret = -EIO;
-			break;
-		}
-
-		count -= ret;
-		ret += offset;
-
-		for (i = 0; i < cur_npages; i++) {
-			len = ret > PAGE_SIZE ? PAGE_SIZE : ret;
-			bvec_set_page(bv + npages + i, *pages++, len - offset, offset);
-			ret -= len;
-			offset = 0;
-		}
-
-		npages += cur_npages;
-	}
-
-	/* Note: Don't try to clean up after EIO.  Either we got no pages, so
-	 * nothing to clean up, or we got a buffer overrun, memory corruption
-	 * and can't trust the stuff in the buffer (a WARN was emitted).
-	 */
-
-	if (ret < 0 && (ret == -ENOMEM || npages == 0)) {
-		for (i = 0; i < npages; i++)
-			unpin_user_page(bv[i].bv_page);
-		kvfree(bv);
-		return ret;
-	}
-
-	iov_iter_bvec(new, orig->data_source, bv, npages, orig_len - count);
-	return npages;
-}
-EXPORT_SYMBOL_GPL(netfs_extract_user_iter);
-
-/*
- * Select the span of a bvec iterator we're going to use.  Limit it by both maximum
- * size and maximum number of segments.  Returns the size of the span in bytes.
- */
-static size_t netfs_limit_bvec(const struct iov_iter *iter, size_t start_offset,
-			       size_t max_size, size_t max_segs)
-{
-	const struct bio_vec *bvecs = iter->bvec;
-	unsigned int nbv = iter->nr_segs, ix = 0, nsegs = 0;
-	size_t len, span = 0, n = iter->count;
-	size_t skip = iter->iov_offset + start_offset;
-
-	if (WARN_ON(!iov_iter_is_bvec(iter)) ||
-	    WARN_ON(start_offset > n) ||
-	    n == 0)
-		return 0;
-
-	while (n && ix < nbv && skip) {
-		len = bvecs[ix].bv_len;
-		if (skip < len)
-			break;
-		skip -= len;
-		n -= len;
-		ix++;
-	}
-
-	while (n && ix < nbv) {
-		len = min3(n, bvecs[ix].bv_len - skip, max_size);
-		span += len;
-		nsegs++;
-		ix++;
-		if (span >= max_size || nsegs >= max_segs)
-			break;
-		skip = 0;
-		n -= len;
-	}
-
-	return min(span, max_size);
-}
-
-/*
- * Select the span of a kvec iterator we're going to use.  Limit it by both
- * maximum size and maximum number of segments.  Returns the size of the span
- * in bytes.
- */
-static size_t netfs_limit_kvec(const struct iov_iter *iter, size_t start_offset,
-			       size_t max_size, size_t max_segs)
-{
-	const struct kvec *kvecs = iter->kvec;
-	unsigned int nkv = iter->nr_segs, ix = 0, nsegs = 0;
-	size_t len, span = 0, n = iter->count;
-	size_t skip = iter->iov_offset + start_offset;
-
-	if (WARN_ON(!iov_iter_is_kvec(iter)) ||
-	    WARN_ON(start_offset > n) ||
-	    n == 0)
-		return 0;
-
-	while (n && ix < nkv && skip) {
-		len = kvecs[ix].iov_len;
-		if (skip < len)
-			break;
-		skip -= len;
-		n -= len;
-		ix++;
-	}
-
-	while (n && ix < nkv) {
-		len = min3(n, kvecs[ix].iov_len - skip, max_size);
-		span += len;
-		nsegs++;
-		ix++;
-		if (span >= max_size || nsegs >= max_segs)
-			break;
-		skip = 0;
-		n -= len;
-	}
-
-	return min(span, max_size);
-}
-
-/*
- * Select the span of an xarray iterator we're going to use.  Limit it by both
- * maximum size and maximum number of segments.  It is assumed that segments
- * can be larger than a page in size, provided they're physically contiguous.
- * Returns the size of the span in bytes.
- */
-static size_t netfs_limit_xarray(const struct iov_iter *iter, size_t start_offset,
-				 size_t max_size, size_t max_segs)
-{
-	struct folio *folio;
-	unsigned int nsegs = 0;
-	uoff_t pos = iter->xarray_start + iter->iov_offset;
-	pgoff_t index = pos / PAGE_SIZE;
-	size_t span = 0, n = iter->count;
-
-	XA_STATE(xas, iter->xarray, index);
-
-	if (WARN_ON(!iov_iter_is_xarray(iter)) ||
-	    WARN_ON(start_offset > n) ||
-	    n == 0)
-		return 0;
-	max_size = min(max_size, n - start_offset);
-
-	rcu_read_lock();
-	xas_for_each(&xas, folio, ULONG_MAX) {
-		size_t offset, flen, len;
-		if (xas_retry(&xas, folio))
-			continue;
-		if (WARN_ON(xa_is_value(folio)))
-			break;
-		if (WARN_ON(folio_test_hugetlb(folio)))
-			break;
-
-		flen = folio_size(folio);
-		offset = offset_in_folio(folio, pos);
-		len = min(max_size, flen - offset);
-		span += len;
-		nsegs++;
-		if (span >= max_size || nsegs >= max_segs)
-			break;
-	}
-
-	rcu_read_unlock();
-	return min(span, max_size);
-}
-
-/*
- * Select the span of a bvecq iterator we're going to use.  Limit it by both
- * maximum size and maximum number of segments.  Returns the size of the span
- * in bytes.
- */
-static size_t netfs_limit_bvecq(const struct iov_iter *iter, size_t start_offset,
-				size_t max_size, size_t max_segs)
-{
-	const struct bvecq *bq = iter->bvecq;
-	unsigned int nsegs = 0;
-	unsigned int slot = iter->bvecq_slot;
-	size_t span = 0, n = iter->count;
-
-	if (WARN_ON(!iov_iter_is_bvecq(iter)) ||
-	    WARN_ON(start_offset > n) ||
-	    n == 0)
-		return 0;
-	max_size = umin(max_size, n - start_offset);
-
-	if (!bvecq_acquire_slot(bq, slot)) {
-		bq = bvecq_next(bq);
-		slot = 0;
-	}
-
-	start_offset += iter->iov_offset;
-	do {
-		size_t flen;
-
-		flen = bq->bv[slot].bv_len;
-		if (start_offset < flen) {
-			span += flen - start_offset;
-			nsegs++;
-			start_offset = 0;
-		} else {
-			start_offset -= flen;
-		}
-		if (span >= max_size || nsegs >= max_segs)
-			break;
-
-		slot++;
-		if (!bvecq_acquire_slot(bq, slot)) {
-			bq = bvecq_next(bq);
-			slot = 0;
-		}
-	} while (bq);
-
-	return umin(span, max_size);
-}
-
-size_t netfs_limit_iter(const struct iov_iter *iter, size_t start_offset,
-			size_t max_size, size_t max_segs)
-{
-	if (iov_iter_is_bvecq(iter))
-		return netfs_limit_bvecq(iter, start_offset, max_size, max_segs);
-	if (iov_iter_is_bvec(iter))
-		return netfs_limit_bvec(iter, start_offset, max_size, max_segs);
-	if (iov_iter_is_xarray(iter))
-		return netfs_limit_xarray(iter, start_offset, max_size, max_segs);
-	if (iov_iter_is_kvec(iter))
-		return netfs_limit_kvec(iter, start_offset, max_size, max_segs);
-	BUG();
-}
-EXPORT_SYMBOL(netfs_limit_iter);
-#endif
diff --git a/include/linux/netfs.h b/include/linux/netfs.h
index f3249d0573c4..0340c9ee587b 100644
--- a/include/linux/netfs.h
+++ b/include/linux/netfs.h
@@ -460,11 +460,6 @@ void netfs_put_subrequest(struct netfs_io_subrequest *subreq,
 ssize_t netfs_extract_iter(struct iov_iter *orig, size_t max_len, size_t max_pages,
 			   struct bvecq **_bvecq_head,
 			   iov_iter_extraction_t extraction_flags, gfp_t gfp);
-ssize_t netfs_extract_user_iter(struct iov_iter *orig, size_t orig_len,
-				struct iov_iter *new,
-				iov_iter_extraction_t extraction_flags);
-size_t netfs_limit_iter(const struct iov_iter *iter, size_t start_offset,
-			size_t max_size, size_t max_segs);
 void netfs_prepare_write_failed(struct netfs_io_subrequest *subreq);
 void netfs_write_subrequest_terminated(void *_op, ssize_t transferred_or_error);
 

