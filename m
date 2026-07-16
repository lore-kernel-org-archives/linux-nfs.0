Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C954640B366
	for <linux-nfs@vger.kernel.org>; Thu, 16 Jul 2026 10:31:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784197916; cv=none; b=hfhbLrym3354hQx1UFEyW+rop4OMCko6ZdZTFWJFj2DE9LRWSMXSlsOxMeBF1C/evAjqrMjDsoPcE7jS1fpmKswAvMFQ7+i/3dHIDG+zB3cUjO8dlszxa0VdMz/2torWWke3sOwc80Tg57eoXjk3PPT3o03A+oCN9dqd9gczw5U=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784197916; c=relaxed/simple;
	bh=NcUaqBzHCis3djLz/qcYAcZcAGdVz6H7SYtBxpRwlmY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=laL8f4/fEQ4HA3rGV9QdlBpGpW/nURcMc8Y5QnEKF7cw9dK1nFNA43dCRUgZwAbklwbgHHJbV0/7Tecral2jkhfLL6E6xG17oGcw/Ww2Xhn0iHl9VaDghoutwfPaqA9+f1Rkyuup5rvu7z6MZWUmjwIdQBMPvSJoPUXvXkeIMi0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=B1CtGFJl; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="B1CtGFJl"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1784197913;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=7Fv5rulOjmryJj6V2MCdrtyuJkDEiNTp/9U34fHP0yo=;
	b=B1CtGFJlenOzwu5B9R3TkeKGEDsJl+HuSq1Yp8Swqy0u2esbldOSA4P9/lJxnKC7L6wyPB
	aMUwkM7TMUf1mEe2QxWQDn7MI8dhf8KW9yWwDjusLtFYkMDHo7pQfSIiUQqneQtAPaIWK6
	FxlE4lYgbv4qTQ6n7t1c66+xP2O1CII=
Received: from mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-48-1OPBBfVtOYCTqPmGCPuWIg-1; Thu,
 16 Jul 2026 06:31:49 -0400
X-MC-Unique: 1OPBBfVtOYCTqPmGCPuWIg-1
X-Mimecast-MFC-AGG-ID: 1OPBBfVtOYCTqPmGCPuWIg_1784197906
Received: from mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.12])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 55E571956077;
	Thu, 16 Jul 2026 10:31:46 +0000 (UTC)
Received: from warthog.procyon.org.com (unknown [10.44.33.159])
	by mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 0F9371956042;
	Thu, 16 Jul 2026 10:31:39 +0000 (UTC)
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
	linux-kernel@vger.kernel.org
Subject: [PATCH v6 07/24] netfs: Add a function to extract from an iter into a bvecq
Date: Thu, 16 Jul 2026 11:30:06 +0100
Message-ID: <20260716103030.3065561-8-dhowells@redhat.com>
In-Reply-To: <20260716103030.3065561-1-dhowells@redhat.com>
References: <20260716103030.3065561-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.12

Add a function to extract a slice of data from an iterator of any type into
a bvec queue chain.

Signed-off-by: David Howells <dhowells@redhat.com>
cc: Paulo Alcantara <pc@manguebit.org>
cc: Matthew Wilcox <willy@infradead.org>
cc: Christoph Hellwig <hch@infradead.org>
cc: Steve French <sfrench@samba.org>
cc: linux-cifs@vger.kernel.org
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 fs/netfs/iterator.c   | 143 ++++++++++++++++++++++++++++++++++++++++++
 include/linux/netfs.h |   3 +
 2 files changed, 146 insertions(+)

diff --git a/fs/netfs/iterator.c b/fs/netfs/iterator.c
index b375567e0520..ead1efa004e7 100644
--- a/fs/netfs/iterator.c
+++ b/fs/netfs/iterator.c
@@ -13,6 +13,149 @@
 #include <linux/netfs.h>
 #include "internal.h"
 
+/**
+ * netfs_extract_iter - Extract virtually contiguous pages from an iterator into a bvecq
+ * @orig: The original iterator
+ * @max_len: Maximum number of bytes to extract
+ * @max_pages: Maximum number of pages to extract
+ * @fpos: Starting file position to label the bvecq with
+ * @_bvecq_head: Where to cache the bvec queue
+ * @extraction_flags: Flags to qualify the request
+ *
+ * Extract virtually contiguous page fragments from the source iterator up to
+ * the given maxima and build bvec queue that refers to all of those bits.
+ * This allows the original iterator to disposed of.
+ *
+ * @extraction_flags can have ITER_ALLOW_P2PDMA set to request peer-to-peer DMA be
+ * allowed on the pages extracted.
+ *
+ * On success or partial success, the amount of data in the bvec is returned,
+ * the original iterator will have been advanced by the amount extracted.
+ *
+ * If an error occurs and no pages are extracted, an error will be returned and
+ * any allocated bvecq will be freed.  If there is no data to be extracted (or
+ * @max_len or @max_pages are zero), a single empty bvecq will be returned.
+ *
+ * The bvecq segments are marked with indications on how to get clean up the
+ * extracted fragments.
+ */
+ssize_t netfs_extract_iter(struct iov_iter *orig, size_t max_len, size_t max_pages,
+			   unsigned long long fpos, struct bvecq **_bvecq_head,
+			   iov_iter_extraction_t extraction_flags)
+{
+	struct bvecq *bq_tail = NULL, *bq;
+	ssize_t ret = 0;
+	size_t extracted = 0;
+
+	_enter("{%u,%zx},%zx", orig->iter_type, orig->count, max_len);
+
+	*_bvecq_head = NULL;
+	if (max_len > orig->count)
+		max_len = orig->count;
+	if (WARN_ON_ONCE(!max_len || !max_pages))
+		goto alloc_empty;
+
+	max_pages = iov_iter_npages(orig, max_pages);
+	if (!max_pages)
+		goto alloc_empty;
+
+	do {
+		bq = bvecq_alloc_one(max_pages, GFP_NOFS);
+		if (!bq) {
+			ret = -ENOMEM;
+			break;
+		}
+		if (user_backed_iter(orig))
+			bq->mem_type = iov_iter_extract_will_pin(orig) ?
+				BVECQ_MEM_GUP : BVECQ_MEM_PAGECACHE;
+		bq->prev	= bq_tail;
+		bq->fpos	= fpos + extracted;
+
+		if (bq_tail)
+			bq_tail->next = bq;
+		else
+			*_bvecq_head = bq;
+		bq_tail = bq;
+
+		if (max_len == 0)
+			break;
+
+		struct bio_vec *bv = bq->bv;
+		unsigned int slot = 0;
+		do {
+			struct page **pages;
+			ssize_t got;
+			size_t offset;
+			size_t space = bq->max_slots - slot;
+			size_t bv_size = array_size(bq->max_slots, sizeof(*bv));
+			size_t pg_size = array_size(space, sizeof(*pages));
+
+			/* Put the page list at the end of the bvec list
+			 * storage.  bvec elements are larger than page
+			 * pointers, so as long as we work 0->last, we should
+			 * be fine.
+			 */
+			pages = (void *)bv + bv_size - pg_size;
+
+			got = iov_iter_extract_pages(orig, &pages, max_len,
+						     min(space, max_pages),
+						     extraction_flags, &offset);
+			if (got < 0) {
+				ret = got;
+				goto out;
+			}
+
+			if (got == 0) {
+				pr_err("extract_pages gave nothing from %zu, %zu\n",
+				       extracted, max_len);
+				ret = -EIO;
+				goto out;
+			}
+
+			if (WARN(got > max_len,
+				 "%s: extract_pages overrun %zd > %zu bytes\n",
+				 __func__, got, max_len)) {
+				ret = -EIO;
+				goto out;
+			}
+
+			extracted += got;
+			max_len -= got;
+
+			do {
+				size_t len = umin(got, PAGE_SIZE - offset);
+
+				BUG_ON(slot >= bq->max_slots);
+
+				bvec_set_page(&bq->bv[slot], *pages++, len, offset);
+				slot++;
+				max_pages--;
+				got -= len;
+				offset = 0;
+			} while (got > 0);
+
+			bvecq_filled_to(bq, slot);
+		} while (max_len > 0 && max_pages > 0 && !bvecq_is_full(bq));
+
+	} while (max_len > 0 && max_pages > 0);
+
+out:
+	if (extracted || ret == 0)
+		return extracted;
+	bvecq_put(*_bvecq_head);
+	*_bvecq_head = NULL;
+	return ret;
+
+alloc_empty:
+	bq = bvecq_alloc_one(1, GFP_NOFS);
+	if (!bq)
+		return -ENOMEM;
+	*_bvecq_head = bq;
+	return 0;
+
+}
+EXPORT_SYMBOL_GPL(netfs_extract_iter);
+
 /**
  * netfs_extract_user_iter - Extract the pages from a user iterator into a bvec
  * @orig: The original iterator
diff --git a/include/linux/netfs.h b/include/linux/netfs.h
index 2999c4b7e6a9..787670c2e134 100644
--- a/include/linux/netfs.h
+++ b/include/linux/netfs.h
@@ -439,6 +439,9 @@ void netfs_get_subrequest(struct netfs_io_subrequest *subreq,
 			  enum netfs_sreq_ref_trace what);
 void netfs_put_subrequest(struct netfs_io_subrequest *subreq,
 			  enum netfs_sreq_ref_trace what);
+ssize_t netfs_extract_iter(struct iov_iter *orig, size_t max_len, size_t max_pages,
+			   unsigned long long fpos, struct bvecq **_bvecq_head,
+			   iov_iter_extraction_t extraction_flags);
 ssize_t netfs_extract_user_iter(struct iov_iter *orig, size_t orig_len,
 				struct iov_iter *new,
 				iov_iter_extraction_t extraction_flags);

