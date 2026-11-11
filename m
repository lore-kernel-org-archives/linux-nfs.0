Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.129.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794429071;
	b=qDyJ6CaHjz+5SM0jVW42TS0pw6xPHNfWslvTVYKNblN+ShQ4foiOL0zoeSDIjvmTW4GL
	 m+LJjUk8ai1Kd8sTyFEqcpi+fG+zfwvizt4SZWXkcuFecGVKB1UHBp02UYug3xq0YarIE
	 e7wDcMIybd1fqPGEXGQ90fSXpK9enDyVq+nyEHir/lA+dPyQVIHKA1qoyOhweN3htFtKo
	 ML7VFqKpNy9BV7IGDcNis/np6f+8dQVQpHJX3wcSxHrwjW68Ix9i4A1Vc0Ld9aPzeEItr
	 3GKhZGtIM/HqjokuMIxNiLbGBEN3ybZ9Kr1ZqNNBF2iNXN5To81/UQ4cBCiPgTnn4gA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794429071;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:Received:From:To:Cc:Subject:Date:
	 Message-ID:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding:X-Scanned-By;
	bh=y05w8RTRoHE8Xsl6ARcJkhTZQN3Ma6lgqbdlmK2Ejtw=;
	b=tjxSinMAi1kxcdckUH/sS1hQLGEEaKA+Z8O3W8uDRH+GEoTX5xfB36NWbo0/pTWTsCjT
	 fkQviSwq6c+mV4nuro7gqVNIpgCl9ZtaxOFA4Meo4i9ELEgFl12FwSH9h2cwBRJ0OOFum
	 43Ixqw6aycwG1FBs/Hy9sp7cMMb8Clg9Tg/+MUY6h/ozTJWogeK3YSirdgl28pvnksrW8
	 lVknpro/FtXbU/Fto8PXU8OyB1+/pyOj+yAhWavHjGJBaotv1K0PskgFQYKFWnakmMgO2
	 YBBx5zYnq4wtVYxrdsEjuls8PJIla9o0m4Lyakeo7vcisDzq+jWHHdiMNzJF3j2uFng==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=gR8RKKpj;
	arc=none smtp.remote-ip=170.10.129.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DD5CD606A335
	for <linux-nfs@vger.kernel.org>; Wed, 11 Nov 2026 20:31:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org DD5CD606A335
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=gR8RKKpj
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1794429069;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=y05w8RTRoHE8Xsl6ARcJkhTZQN3Ma6lgqbdlmK2Ejtw=;
	b=gR8RKKpj1IsO8JRycdnRIRYvZRIqxn4pGtLJjg7IKPM5G2g3hELPtfSSByyAip+7VnFMfQ
	t4DpX7ned7CoIeLSA6oAH6w9OFcBSUH5rJDaWNgytibsNYV78cXORBwiqY+vYi1SCODjBP
	F/r0b2RnD/nzMGL6VJQlSbwYsl7rwls=
Received: from mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-261-78GAYSBYPPiE-sVOsn5VHQ-1; Wed,
 11 Nov 2026 15:31:06 -0500
X-MC-Unique: 78GAYSBYPPiE-sVOsn5VHQ-1
X-Mimecast-MFC-AGG-ID: 78GAYSBYPPiE-sVOsn5VHQ_1794429063
Received: from mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.4])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 5103919560AE;
	Wed, 11 Nov 2026 20:31:02 +0000 (UTC)
Received: from dhowells-thinkpadp1gen8.rmtgb.csb (headnet04.pony-001.prod.iad2.dc.redhat.com [10.2.32.116])
	by mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id E17C830000D3;
	Wed, 11 Nov 2026 20:30:56 +0000 (UTC)
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
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Jens Axboe <axboe@kernel.dk>,
	Christoph Hellwig <hch@infradead.org>,
	linux-block@vger.kernel.org
Subject: [PATCH v17 03/17] iov_iter: Add a segmented queue of bio_vec[]
Date: Wed, 11 Nov 2026 20:30:16 +0000
Message-ID: <20261111203034.2126314-4-dhowells@redhat.com>
In-Reply-To: <20261111203034.2126314-1-dhowells@redhat.com>
References: <20261111203034.2126314-1-dhowells@redhat.com>
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
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.4

Add the concept of a segmented queue of bio_vec[] arrays.  This allows an
indefinite quantity of elements to be handled and allows things like
network filesystems and crypto drivers to glue bits on the ends without
having to reallocate the array.

The bvecq struct that defines each segment also carries capacity/usage
information along with flags indicating whether the constituent memory
regions need freeing or unpinning.  The bvecq structs are refcounted to
allow a queue to be extracted in batches and split between a number of
subrequests.

The bvecq can have the bio_vec[] it manages allocated in with it, but this
is not required.  A flag is provided for if this is the case as comparing
->bv to ->__bv is not sufficient to detect this case.

Add an iterator type ITER_BVECQ for it.  This is intended to replace
ITER_FOLIOQ (and ITER_XARRAY).

Note that the prev pointer is only really needed for iov_iter_revert() and
could be dispensed with if struct iov_iter contained the head information
as well as the current point.

Signed-off-by: David Howells <dhowells@redhat.com>
Reviewed-by: Paulo Alcantara (Red Hat) <pc@manguebit.org>
cc: Alexander Viro <viro@zeniv.linux.org.uk>
cc: Matthew Wilcox <willy@infradead.org>
cc: Jens Axboe <axboe@kernel.dk>
cc: Christoph Hellwig <hch@infradead.org>
cc: linux-block@vger.kernel.org
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 MAINTAINERS                |   1 +
 include/linux/bvecq.h      |  50 +++++
 include/linux/iov_iter.h   |  74 ++++++-
 include/linux/uio.h        |  11 +
 lib/iov_iter.c             | 435 ++++++++++++++++++++++++++++++++++++-
 lib/scatterlist.c          |  67 +++++-
 lib/tests/kunit_iov_iter.c | 277 +++++++++++++++++++++++
 7 files changed, 909 insertions(+), 6 deletions(-)
 create mode 100644 include/linux/bvecq.h

diff --git a/MAINTAINERS b/MAINTAINERS
index 93abbb315065..6fa777744163 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -10385,6 +10385,7 @@ S:	Supported
 F:	Documentation/filesystems/caching/
 F:	Documentation/filesystems/netfs_library.rst
 F:	fs/netfs/
+F:	include/linux/bvecq.h
 F:	include/linux/fscache*.h
 F:	include/linux/netfs.h
 F:	include/trace/events/fscache.h
diff --git a/include/linux/bvecq.h b/include/linux/bvecq.h
new file mode 100644
index 000000000000..77fd07852c33
--- /dev/null
+++ b/include/linux/bvecq.h
@@ -0,0 +1,50 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/* Implementation of a segmented queue of bio_vec[].
+ *
+ * Copyright (C) 2026 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ */
+
+#ifndef _LINUX_BVECQ_H
+#define _LINUX_BVECQ_H
+
+#include <linux/bvec.h>
+
+/*
+ * The type of memory retention used by the elements in bvecq->bv[] and how to
+ * clean it up.
+ */
+enum bvecq_mem {
+	BVECQ_MEM_EXTERNAL,	/* Externally retained memory - no freeing */
+	BVECQ_MEM_PAGECACHE,	/* Ref'd pagecache pages - must put */
+	BVECQ_MEM_GUP,		/* Pinned memory from get_user_pages() - unpin */
+	BVECQ_MEM_ALLOCED,	/* Memory alloc'd by bvecq - can be freed/pooled */
+} __mode(byte);
+
+/*
+ * Segmented bio_vec queue.
+ *
+ * These can be linked together to form messages of indefinite length and
+ * iterated over with an ITER_BVECQ iterator.  The list is non-circular; next
+ * and prev are NULL at the ends.
+ *
+ * The bv pointer points to the bio_vec array; this may be __bv if allocated
+ * together.  The caller is responsible for determining whether or not this is
+ * the case as the array pointed to by bv may be follow on directly from the
+ * bvecq by accident of allocation (ie. ->bv == ->__bv is *not* sufficient to
+ * determine this).
+ */
+struct bvecq {
+	struct bvecq	*next;		/* Next bvec in the list or NULL */
+	struct bvecq	*prev;		/* Prev bvec in the list or NULL */
+	refcount_t	ref;
+	u32		priv;		/* Private data */
+	u16		nr_slots;	/* Number of elements in bv[] used */
+	u16		max_slots;	/* Number of elements allocated in bv[] */
+	enum bvecq_mem	mem_type:3;	/* What sort of memory and how to free it */
+	bool		inline_bv:1;	/* T if __bv[] is being used */
+	struct bio_vec	*bv;		/* Pointer to array of page fragments */
+	struct bio_vec	__bv[];		/* Default array (if ->inline_bv) */
+};
+
+#endif /* _LINUX_BVECQ_H */
diff --git a/include/linux/iov_iter.h b/include/linux/iov_iter.h
index 2f91884d733b..79825cf84e58 100644
--- a/include/linux/iov_iter.h
+++ b/include/linux/iov_iter.h
@@ -10,6 +10,7 @@
 
 #include <linux/uio.h>
 #include <linux/bvec.h>
+#include <linux/bvecq.h>
 #include <linux/folio_queue.h>
 
 typedef size_t (*iov_step_f)(void *iter_base, size_t progress, size_t len,
@@ -141,6 +142,71 @@ size_t iterate_bvec(struct iov_iter *iter, size_t len, void *priv, void *priv2,
 	return progress;
 }
 
+/*
+ * Handle ITER_BVECQ.
+ */
+static __always_inline
+size_t iterate_bvecq(struct iov_iter *iter, size_t len, void *priv, void *priv2,
+		     iov_step_f step)
+{
+	const struct bvecq *bq = iter->bvecq;
+	unsigned int slot = iter->bvecq_slot;
+	size_t progress = 0, skip = iter->iov_offset;
+
+	do {
+		const struct bio_vec *bvec;
+		struct page *page;
+		size_t poff, plen;
+		void *base;
+
+		if (slot >= bq->nr_slots) {
+			if (!bq->next)
+				break;
+			bq = bq->next;
+			slot = 0;
+			continue;
+		}
+
+		bvec = &bq->bv[slot];
+		/*
+		 * The caller must ensure that a slot with bv_len>0 has a valid
+		 * bv_page.
+		 */
+		page = bvec->bv_page + (bvec->bv_offset + skip) / PAGE_SIZE;
+		poff = (bvec->bv_offset + skip) % PAGE_SIZE;
+		plen = min(bvec->bv_len - skip, len);
+
+		while (plen > 0) {
+			size_t part, remain, consumed;
+
+			part = min(plen, PAGE_SIZE - poff);
+			base = kmap_local_page(page) + poff;
+			remain = step(base, progress, part, priv, priv2);
+			kunmap_local(base);
+
+			consumed = part - remain;
+			progress += consumed;
+			skip += consumed;
+			len -= consumed;
+			if (!len || remain)
+				goto stop;
+			page++;
+			poff = 0;
+			plen -= consumed;
+		}
+
+		skip = 0;
+		slot++;
+	} while (len);
+
+stop:
+	iter->bvecq_slot = slot;
+	iter->bvecq = bq;
+	iter->iov_offset = skip;
+	iter->count -= progress;
+	return progress;
+}
+
 /*
  * Handle ITER_FOLIOQ.
  */
@@ -306,6 +372,8 @@ size_t iterate_and_advance2(struct iov_iter *iter, size_t len, void *priv,
 		return iterate_bvec(iter, len, priv, priv2, step);
 	if (iov_iter_is_kvec(iter))
 		return iterate_kvec(iter, len, priv, priv2, step);
+	if (iov_iter_is_bvecq(iter))
+		return iterate_bvecq(iter, len, priv, priv2, step);
 	if (iov_iter_is_folioq(iter))
 		return iterate_folioq(iter, len, priv, priv2, step);
 	if (iov_iter_is_xarray(iter))
@@ -344,8 +412,8 @@ size_t iterate_and_advance(struct iov_iter *iter, size_t len, void *priv,
  * buffer is presented in segments, which for kernel iteration are broken up by
  * physical pages and mapped, with the mapped address being presented.
  *
- * [!] Note This will only handle BVEC, KVEC, FOLIOQ, XARRAY and DISCARD-type
- * iterators; it will not handle UBUF or IOVEC-type iterators.
+ * [!] Note This will only handle BVEC, KVEC, BVECQ, FOLIOQ, XARRAY and
+ * DISCARD-type iterators; it will not handle UBUF or IOVEC-type iterators.
  *
  * A step functions, @step, must be provided, one for handling mapped kernel
  * addresses and the other is given user addresses which have the potential to
@@ -372,6 +440,8 @@ size_t iterate_and_advance_kernel(struct iov_iter *iter, size_t len, void *priv,
 		return iterate_bvec(iter, len, priv, priv2, step);
 	if (iov_iter_is_kvec(iter))
 		return iterate_kvec(iter, len, priv, priv2, step);
+	if (iov_iter_is_bvecq(iter))
+		return iterate_bvecq(iter, len, priv, priv2, step);
 	if (iov_iter_is_folioq(iter))
 		return iterate_folioq(iter, len, priv, priv2, step);
 	if (iov_iter_is_xarray(iter))
diff --git a/include/linux/uio.h b/include/linux/uio.h
index 638c1116e912..f87e05033eac 100644
--- a/include/linux/uio.h
+++ b/include/linux/uio.h
@@ -27,6 +27,7 @@ enum iter_type {
 	ITER_IOVEC,
 	ITER_BVEC,
 	ITER_KVEC,
+	ITER_BVECQ,
 	ITER_FOLIOQ,
 	ITER_XARRAY,
 	ITER_DISCARD,
@@ -70,6 +71,7 @@ struct iov_iter {
 				const struct iovec *__iov;
 				const struct kvec *kvec;
 				const struct bio_vec *bvec;
+				const struct bvecq *bvecq;
 				const struct folio_queue *folioq;
 				struct xarray *xarray;
 				void __user *ubuf;
@@ -80,6 +82,7 @@ struct iov_iter {
 	};
 	union {
 		unsigned long nr_segs;
+		u16 bvecq_slot;
 		u8 folioq_slot;
 		loff_t xarray_start;
 	};
@@ -148,6 +151,11 @@ static inline bool iov_iter_is_discard(const struct iov_iter *i)
 	return iov_iter_type(i) == ITER_DISCARD;
 }
 
+static inline bool iov_iter_is_bvecq(const struct iov_iter *i)
+{
+	return iov_iter_type(i) == ITER_BVECQ;
+}
+
 static inline bool iov_iter_is_folioq(const struct iov_iter *i)
 {
 	return iov_iter_type(i) == ITER_FOLIOQ;
@@ -303,6 +311,9 @@ void iov_iter_kvec(struct iov_iter *i, unsigned int direction, const struct kvec
 void iov_iter_bvec(struct iov_iter *i, unsigned int direction, const struct bio_vec *bvec,
 			unsigned long nr_segs, size_t count);
 void iov_iter_discard(struct iov_iter *i, unsigned int direction, size_t count);
+void iov_iter_bvec_queue(struct iov_iter *i, unsigned int direction,
+			 const struct bvecq *bvecq,
+			 unsigned int first_slot, unsigned int offset, size_t count);
 void iov_iter_folio_queue(struct iov_iter *i, unsigned int direction,
 			  const struct folio_queue *folioq,
 			  unsigned int first_slot, unsigned int offset, size_t count);
diff --git a/lib/iov_iter.c b/lib/iov_iter.c
index fa4fe2e92383..e2e01a2e47fe 100644
--- a/lib/iov_iter.c
+++ b/lib/iov_iter.c
@@ -538,6 +538,40 @@ static void iov_iter_iovec_advance(struct iov_iter *i, size_t size)
 	i->__iov = iov;
 }
 
+static void iov_iter_bvecq_advance(struct iov_iter *i, size_t by)
+{
+	const struct bvecq *bq = i->bvecq;
+	unsigned int slot = i->bvecq_slot;
+
+	if (!i->count)
+		return;
+	i->count -= by;
+
+	by += i->iov_offset; /* From beginning of current segment. */
+	do {
+		size_t len;
+
+		if (slot >= bq->nr_slots) {
+			if (!bq->next)
+				break;
+			bq = bq->next;
+			slot = 0;
+			continue;
+		}
+
+		len = bq->bv[slot].bv_len;
+
+		if (likely(by < len))
+			break;
+		by -= len;
+		slot++;
+	} while (by);
+
+	i->iov_offset = by;
+	i->bvecq_slot = slot;
+	i->bvecq = bq;
+}
+
 static void iov_iter_folioq_advance(struct iov_iter *i, size_t size)
 {
 	const struct folio_queue *folioq = i->folioq;
@@ -584,6 +618,8 @@ void iov_iter_advance(struct iov_iter *i, size_t size)
 		iov_iter_iovec_advance(i, size);
 	} else if (iov_iter_is_bvec(i)) {
 		iov_iter_bvec_advance(i, size);
+	} else if (iov_iter_is_bvecq(i)) {
+		iov_iter_bvecq_advance(i, size);
 	} else if (iov_iter_is_folioq(i)) {
 		iov_iter_folioq_advance(i, size);
 	} else if (iov_iter_is_discard(i)) {
@@ -592,6 +628,33 @@ void iov_iter_advance(struct iov_iter *i, size_t size)
 }
 EXPORT_SYMBOL(iov_iter_advance);
 
+static void iov_iter_bvecq_revert(struct iov_iter *i, size_t unroll)
+{
+	const struct bvecq *bq = i->bvecq;
+	unsigned int slot = i->bvecq_slot;
+
+	for (;;) {
+		size_t len;
+
+		if (slot == 0) {
+			bq = bq->prev;
+			slot = bq->nr_slots;
+			continue;
+		}
+		slot--;
+
+		len = bq->bv[slot].bv_len;
+		if (unroll <= len) {
+			i->iov_offset = len - unroll;
+			break;
+		}
+		unroll -= len;
+	}
+
+	i->bvecq_slot = slot;
+	i->bvecq = bq;
+}
+
 static void iov_iter_folioq_revert(struct iov_iter *i, size_t unroll)
 {
 	const struct folio_queue *folioq = i->folioq;
@@ -650,6 +713,9 @@ void iov_iter_revert(struct iov_iter *i, size_t unroll)
 			}
 			unroll -= n;
 		}
+	} else if (iov_iter_is_bvecq(i)) {
+		i->iov_offset = 0;
+		iov_iter_bvecq_revert(i, unroll);
 	} else if (iov_iter_is_folioq(i)) {
 		i->iov_offset = 0;
 		iov_iter_folioq_revert(i, unroll);
@@ -680,9 +746,30 @@ size_t iov_iter_single_seg_count(const struct iov_iter *i)
 		if (iov_iter_is_bvec(i))
 			return min(i->count, i->bvec->bv_len - i->iov_offset);
 	}
+	if (!i->count)
+		return 0;
+	if (unlikely(iov_iter_is_bvecq(i))) {
+		const struct bvecq *bq = i->bvecq;
+		unsigned int slot = i->bvecq_slot;
+		size_t offset = i->iov_offset;
+
+		for (;;) {
+			while (slot >= bq->nr_slots) {
+				bq = bq->next;
+				if (!bq)
+					return 0;
+				slot = 0;
+				offset = 0;
+			}
+			if (bq->bv[slot].bv_len > offset)
+				break;
+			slot++;
+			offset = 0;
+		}
+		return min(i->count, bq->bv[slot].bv_len - offset);
+	}
 	if (unlikely(iov_iter_is_folioq(i)))
-		return !i->count ? 0 :
-			umin(folioq_folio_size(i->folioq, i->folioq_slot), i->count);
+		return umin(folioq_folio_size(i->folioq, i->folioq_slot), i->count);
 	return i->count;
 }
 EXPORT_SYMBOL(iov_iter_single_seg_count);
@@ -719,6 +806,36 @@ void iov_iter_bvec(struct iov_iter *i, unsigned int direction,
 }
 EXPORT_SYMBOL(iov_iter_bvec);
 
+/**
+ * iov_iter_bvec_queue - Initialise an I/O iterator to use a segmented bvec queue
+ * @i: The iterator to initialise.
+ * @direction: The direction of the transfer.
+ * @bvecq: The starting point in the bvec queue.
+ * @first_slot: The first slot in the bvec queue to use
+ * @offset: The offset into the bvec in the first slot to start at
+ * @count: The size of the I/O buffer in bytes.
+ *
+ * Set up an I/O iterator to either draw data out of the buffers attached to an
+ * inode or to inject data into those buffers.  The pages *must* be prevented
+ * from evaporation by the caller, by taking a ref or a lock on them or by
+ * cleaning them up after the I/O is complete.
+ */
+void iov_iter_bvec_queue(struct iov_iter *i, unsigned int direction,
+			 const struct bvecq *bvecq, unsigned int first_slot,
+			 unsigned int offset, size_t count)
+{
+	WARN_ON(direction & ~(READ | WRITE));
+	*i = (struct iov_iter) {
+		.iter_type	= ITER_BVECQ,
+		.data_source	= direction,
+		.bvecq		= bvecq,
+		.bvecq_slot	= first_slot,
+		.count		= count,
+		.iov_offset	= offset,
+	};
+}
+EXPORT_SYMBOL(iov_iter_bvec_queue);
+
 /**
  * iov_iter_folio_queue - Initialise an I/O iterator to use the folios in a folio queue
  * @i: The iterator to initialise.
@@ -855,6 +972,39 @@ static unsigned long iov_iter_alignment_bvec(const struct iov_iter *i)
 	return res;
 }
 
+static unsigned long iov_iter_alignment_bvecq(const struct iov_iter *iter)
+{
+	const struct bvecq *bq;
+	unsigned long res = 0;
+	unsigned int slot = iter->bvecq_slot;
+	size_t skip = iter->iov_offset;
+	size_t size = iter->count;
+
+	if (!size)
+		return res;
+
+	for (bq = iter->bvecq; bq; bq = bq->next) {
+		for (; slot < bq->nr_slots; slot++) {
+			const struct bio_vec *bvec = &bq->bv[slot];
+			size_t part = min(bvec->bv_len - skip, size);
+
+			if (part) {
+				res |= bvec->bv_offset + skip;
+				res |= part;
+			}
+
+			size -= part;
+			if (size == 0)
+				return res;
+			skip = 0;
+		}
+
+		slot = 0;
+	}
+
+	return res;
+}
+
 unsigned long iov_iter_alignment(const struct iov_iter *i)
 {
 	if (likely(iter_is_ubuf(i))) {
@@ -874,6 +1024,8 @@ unsigned long iov_iter_alignment(const struct iov_iter *i)
 
 	if (iov_iter_is_bvec(i))
 		return iov_iter_alignment_bvec(i);
+	if (iov_iter_is_bvecq(i))
+		return iov_iter_alignment_bvecq(i);
 
 	/* With both xarray and folioq types, we're dealing with whole folios. */
 	if (iov_iter_is_folioq(i) || iov_iter_is_dmabuf_map(i))
@@ -930,6 +1082,161 @@ static int want_pages_array(struct page ***res, size_t size,
 	return count;
 }
 
+/*
+ * Count the number of virtually contiguous pages coming up next in an
+ * ITER_BVECQ iterator, up to the specified maxima.
+ */
+static unsigned int iter_count_bvecq_pages(const struct iov_iter *iter,
+					   size_t maxsize,
+					   unsigned int maxpages)
+{
+	const struct bvecq *bvecq = iter->bvecq;
+	unsigned int slot = iter->bvecq_slot;
+	ssize_t remain = umin(maxsize, iter->count);
+	size_t count = 0, offset = iter->iov_offset;
+
+	do {
+		const struct bio_vec *bv;
+		size_t boff, blen;
+
+		if (slot >= bvecq->nr_slots) {
+			if (!bvecq->next) {
+				WARN_ON_ONCE(remain > 0);
+				break;
+			}
+			bvecq = bvecq->next;
+			slot = 0;
+			offset = 0;
+			continue;
+		}
+
+		bv = &bvecq->bv[slot++];
+		boff = bv->bv_offset;
+		blen = bv->bv_len;
+
+		/* bv_page is not allowed to be NULL unless bv_len == 0. */
+		if (WARN_ON_ONCE(!bv->bv_page && blen > 0))
+			break;
+		if (!PAGE_ALIGNED(boff) && count > 0)
+			break;
+
+		boff += offset;
+		blen -= offset;
+		offset = 0;
+		if (!blen)
+			continue;
+
+		blen = umin(blen, remain);
+		remain -= blen;
+		blen += offset_in_page(boff);
+		count += DIV_ROUND_UP(blen, PAGE_SIZE);
+
+		if (!PAGE_ALIGNED(blen))
+			break;
+	} while (remain > 0 && count < maxpages);
+
+	return min(count, maxpages);
+}
+
+/*
+ * Get a list of virtually contiguous pages from an ITER_BVECQ iterator and pin
+ * them.
+ */
+static ssize_t iter_bvecq_get_pages(struct iov_iter *iter,
+				    struct page ***ppages, size_t maxsize,
+				    unsigned int maxpages, size_t *_start_offset)
+{
+	const struct bvecq *bvecq = iter->bvecq;
+	struct page **pages;
+	unsigned int slot = iter->bvecq_slot, nr = 0;
+	size_t extracted = 0, offset = iter->iov_offset;
+
+	for (;;) {
+		if (slot >= bvecq->nr_slots) {
+			if (!bvecq->next)
+				return 0;
+			bvecq = bvecq->next;
+			slot = 0;
+			offset = 0;
+			continue;
+		}
+		if (offset >= bvecq->bv[slot].bv_len) {
+			slot++;
+			offset = 0;
+			continue;
+		}
+		break;
+	}
+
+	/* Count the next run of virtually contiguous pages. */
+	maxpages = iter_count_bvecq_pages(iter, maxsize, maxpages);
+	if (!maxpages)
+		return 0;
+
+	maxpages = want_pages_array(ppages, maxsize,
+				    (bvecq->bv[slot].bv_offset + offset) & ~PAGE_MASK,
+				    maxpages);
+	if (!maxpages)
+		return -ENOMEM;
+	pages = *ppages;
+
+	/* Now transcribe the page pointers. */
+	do {
+		const struct bio_vec *bv;
+		size_t boff, blen;
+
+		if (slot >= bvecq->nr_slots) {
+			if (!bvecq->next) {
+				WARN_ON_ONCE(extracted < iter->count);
+				break;
+			}
+			bvecq = bvecq->next;
+			slot = 0;
+			offset = 0;
+			continue;
+		}
+
+		bv = &bvecq->bv[slot];
+		boff = bv->bv_offset;
+		blen = bv->bv_len;
+
+		/* bv_page is not allowed to be NULL unless bv_len == 0. */
+
+		if (offset < blen) {
+			struct folio *folio;
+			size_t poff = (boff + offset) % PAGE_SIZE;
+			size_t part = min(maxsize - extracted, blen - offset);
+			size_t pix = (boff + offset) / PAGE_SIZE;
+
+			if (poff + part > PAGE_SIZE)
+				part = PAGE_SIZE - poff;
+
+			if (!extracted)
+				*_start_offset = poff;
+
+			/* Get a ref on the page if it's not a slab page. */
+			folio = page_folio(bv->bv_page + pix);
+			if (!folio_test_slab(folio))
+				folio_get(folio);
+
+			pages[nr++] = bv->bv_page + pix;
+			offset += part;
+			extracted += part;
+		}
+
+		if (offset >= blen) {
+			offset = 0;
+			slot++;
+		}
+	} while (nr < maxpages && extracted < maxsize);
+
+	iter->bvecq = bvecq;
+	iter->bvecq_slot = slot;
+	iter->iov_offset = offset;
+	iter->count -= extracted;
+	return extracted;
+}
+
 static ssize_t iter_folioq_get_pages(struct iov_iter *iter,
 				     struct page ***ppages, size_t maxsize,
 				     unsigned maxpages, size_t *_start_offset)
@@ -1140,6 +1447,8 @@ static ssize_t __iov_iter_get_pages_alloc(struct iov_iter *i,
 		}
 		return maxsize;
 	}
+	if (iov_iter_is_bvecq(i))
+		return iter_bvecq_get_pages(i, pages, maxsize, maxpages, start);
 	if (iov_iter_is_folioq(i))
 		return iter_folioq_get_pages(i, pages, maxsize, maxpages, start);
 	if (iov_iter_is_xarray(i))
@@ -1212,6 +1521,38 @@ static int bvec_npages(const struct iov_iter *i, int maxpages)
 	return npages;
 }
 
+static size_t iov_npages_bvecq(const struct iov_iter *iter, size_t maxpages)
+{
+	const struct bvecq *bq;
+	unsigned int slot = iter->bvecq_slot;
+	size_t npages = 0;
+	size_t skip = iter->iov_offset;
+	size_t size = iter->count;
+
+	for (bq = iter->bvecq; bq; bq = bq->next) {
+		for (; slot < bq->nr_slots; slot++) {
+			const struct bio_vec *bvec = &bq->bv[slot];
+			size_t offs = (bvec->bv_offset + skip) % PAGE_SIZE;
+			size_t part = min(bvec->bv_len - skip, size);
+
+			if (part) {
+				npages += DIV_ROUND_UP(offs + part, PAGE_SIZE);
+				if (npages >= maxpages)
+					goto out;
+			}
+
+			size -= part;
+			if (!size)
+				goto out;
+			skip = 0;
+		}
+
+		slot = 0;
+	}
+out:
+	return umin(npages, maxpages);
+}
+
 int iov_iter_npages(const struct iov_iter *i, int maxpages)
 {
 	if (unlikely(!i->count))
@@ -1226,6 +1567,8 @@ int iov_iter_npages(const struct iov_iter *i, int maxpages)
 		return iov_npages(i, maxpages);
 	if (iov_iter_is_bvec(i))
 		return bvec_npages(i, maxpages);
+	if (iov_iter_is_bvecq(i))
+		return iov_npages_bvecq(i, maxpages);
 	if (iov_iter_is_folioq(i)) {
 		unsigned offset = i->iov_offset % PAGE_SIZE;
 		int npages = DIV_ROUND_UP(offset + i->count, PAGE_SIZE);
@@ -1514,6 +1857,90 @@ void iov_iter_restore(struct iov_iter *i, struct iov_iter_state *state)
 }
 EXPORT_SYMBOL_FOR_MODULES(iov_iter_restore, "vmw_vsock_virtio_transport_common");
 
+/*
+ * Extract a list of virtually contiguous pages from an ITER_BVECQ iterator.
+ * This does not get references on the pages, nor does it get a pin on them.
+ */
+static ssize_t iov_iter_extract_bvecq_pages(struct iov_iter *iter,
+					    struct page ***pages, size_t maxsize,
+					    unsigned int maxpages,
+					    iov_iter_extraction_t extraction_flags,
+					    size_t *offset0)
+{
+	const struct bvecq *bvecq;
+	struct page **p;
+	unsigned int slot, nr = 0;
+	size_t extracted = 0, offset;
+
+	/* Count the next run of virtually contiguous pages. */
+	maxpages = iter_count_bvecq_pages(iter, maxsize, maxpages);
+	if (!maxpages)
+		return 0;
+
+	if (!*pages) {
+		*pages = kvmalloc_array(maxpages, sizeof(struct page *), GFP_KERNEL);
+		if (!*pages)
+			return -ENOMEM;
+	}
+
+	p = *pages;
+
+	/* Now transcribe the page pointers. */
+	extracted = 0;
+	bvecq = iter->bvecq;
+	offset = iter->iov_offset;
+	slot = iter->bvecq_slot;
+
+	do {
+		const struct bio_vec *bv;
+		size_t boff, blen;
+
+		if (slot >= bvecq->nr_slots) {
+			if (!bvecq->next) {
+				WARN_ON_ONCE(extracted < iter->count);
+				break;
+			}
+			bvecq = bvecq->next;
+			slot = 0;
+			offset = 0;
+			continue;
+		}
+
+		bv = &bvecq->bv[slot];
+		boff = bv->bv_offset;
+		blen = bv->bv_len;
+
+		/* bv_page is not allowed to be NULL unless bv_len == 0. */
+
+		if (offset < blen) {
+			size_t part = umin(maxsize - extracted, blen - offset);
+			size_t poff = (boff + offset) % PAGE_SIZE;
+			size_t pix = (boff + offset) / PAGE_SIZE;
+
+			if (poff + part > PAGE_SIZE)
+				part = PAGE_SIZE - poff;
+
+			if (!extracted)
+				*offset0 = poff;
+
+			p[nr++] = bv->bv_page + pix;
+			offset += part;
+			extracted += part;
+		}
+
+		if (offset >= blen) {
+			offset = 0;
+			slot++;
+		}
+	} while (nr < maxpages && extracted < maxsize);
+
+	iter->bvecq = bvecq;
+	iter->bvecq_slot = slot;
+	iter->iov_offset = offset;
+	iter->count -= extracted;
+	return extracted;
+}
+
 /*
  * Extract a list of contiguous pages from an ITER_FOLIOQ iterator.  This does
  * not get references on the pages, nor does it get a pin on them.
@@ -1874,6 +2301,10 @@ ssize_t iov_iter_extract_pages(struct iov_iter *i,
 		return iov_iter_extract_bvec_pages(i, pages, maxsize,
 						   maxpages, extraction_flags,
 						   offset0);
+	if (iov_iter_is_bvecq(i))
+		return iov_iter_extract_bvecq_pages(i, pages, maxsize,
+						    maxpages, extraction_flags,
+						    offset0);
 	if (iov_iter_is_folioq(i))
 		return iov_iter_extract_folioq_pages(i, pages, maxsize,
 						     maxpages, extraction_flags,
diff --git a/lib/scatterlist.c b/lib/scatterlist.c
index 6ea40d2e6247..23e5a180103b 100644
--- a/lib/scatterlist.c
+++ b/lib/scatterlist.c
@@ -10,6 +10,7 @@
 #include <linux/highmem.h>
 #include <linux/kmemleak.h>
 #include <linux/bvec.h>
+#include <linux/bvecq.h>
 #include <linux/uio.h>
 #include <linux/folio_queue.h>
 
@@ -1267,6 +1268,65 @@ static ssize_t extract_kvec_to_sg(struct iov_iter *iter,
 	return ret;
 }
 
+/*
+ * Extract up to sg_max folios from an BVECQ-type iterator and add them to
+ * the scatterlist.  The pages are not pinned.
+ */
+static ssize_t extract_bvecq_to_sg(struct iov_iter *iter,
+				   ssize_t maxsize,
+				   struct sg_table *sgtable,
+				   unsigned int sg_max,
+				   iov_iter_extraction_t extraction_flags)
+{
+	const struct bvecq *bvecq = iter->bvecq;
+	struct scatterlist *sg = sgtable->sgl + sgtable->nents;
+	unsigned int slot = iter->bvecq_slot;
+	ssize_t ret = 0;
+	size_t offset = iter->iov_offset;
+
+	maxsize = umin(maxsize, iov_iter_count(iter));
+
+	while (sg_max > 0 && ret < maxsize) {
+		const struct bio_vec *bv;
+		size_t blen, part;
+
+		if (slot >= bvecq->nr_slots) {
+			if (!bvecq->next) {
+				WARN_ON_ONCE(ret < iter->count);
+				break;
+			}
+			bvecq = bvecq->next;
+			slot = 0;
+			offset = 0;
+			continue;
+		}
+
+		bv = &bvecq->bv[slot];
+		blen = bv->bv_len;
+
+		if (offset >= blen) {
+			offset = 0;
+			slot++;
+			continue;
+		}
+
+		part = umin(maxsize - ret, blen - offset);
+
+		sg_set_page(sg, bv->bv_page, part, bv->bv_offset + offset);
+		sgtable->nents++;
+		sg++;
+		sg_max--;
+		offset += part;
+		ret += part;
+	}
+
+	iter->bvecq = bvecq;
+	iter->bvecq_slot = slot;
+	iter->iov_offset = offset;
+	iter->count -= ret;
+	return ret;
+}
+
 /*
  * Extract up to sg_max folios from an FOLIOQ-type iterator and add them to
  * the scatterlist.  The pages are not pinned.
@@ -1391,8 +1451,8 @@ static ssize_t extract_xarray_to_sg(struct iov_iter *iter,
  * addition of @sg_max elements.
  *
  * The pages referred to by UBUF- and IOVEC-type iterators are extracted and
- * pinned; BVEC-, KVEC-, FOLIOQ- and XARRAY-type are extracted but aren't
- * pinned; DISCARD-type is not supported.
+ * pinned; BVEC-, BVECQ-, KVEC-, FOLIOQ- and XARRAY-type are extracted but
+ * aren't pinned; DISCARD-type is not supported.
  *
  * No end mark is placed on the scatterlist; that's left to the caller.
  *
@@ -1424,6 +1484,9 @@ ssize_t extract_iter_to_sg(struct iov_iter *iter, size_t maxsize,
 	case ITER_KVEC:
 		return extract_kvec_to_sg(iter, maxsize, sgtable, sg_max,
 					  extraction_flags);
+	case ITER_BVECQ:
+		return extract_bvecq_to_sg(iter, maxsize, sgtable, sg_max,
+					   extraction_flags);
 	case ITER_FOLIOQ:
 		return extract_folioq_to_sg(iter, maxsize, sgtable, sg_max,
 					    extraction_flags);
diff --git a/lib/tests/kunit_iov_iter.c b/lib/tests/kunit_iov_iter.c
index b4ad38d1a4bd..1f5c72b4c4d6 100644
--- a/lib/tests/kunit_iov_iter.c
+++ b/lib/tests/kunit_iov_iter.c
@@ -12,6 +12,7 @@
 #include <linux/mm.h>
 #include <linux/uio.h>
 #include <linux/bvec.h>
+#include <linux/bvecq.h>
 #include <linux/folio_queue.h>
 #include <linux/scatterlist.h>
 #include <linux/minmax.h>
@@ -552,6 +553,183 @@ static void iov_kunit_copy_from_folioq(struct kunit *test)
 	KUNIT_SUCCEED(test);
 }
 
+static void iov_kunit_destroy_bvecq(void *data)
+{
+	struct bvecq *bq, *next;
+
+	for (bq = data; bq; bq = next) {
+		next = bq->next;
+		/* The pages are freed by vmap with VM_MAP_PUT_PAGES. */
+		kfree(bq);
+	}
+}
+
+static struct bvecq *iov_kunit_alloc_bvecq(struct kunit *test, unsigned int max_slots)
+{
+	struct bvecq *bq;
+
+	bq = kzalloc(struct_size(bq, __bv, max_slots), GFP_KERNEL);
+	KUNIT_ASSERT_NOT_ERR_OR_NULL(test, bq);
+	bq->max_slots = max_slots;
+	bq->bv = bq->__bv;
+	bq->inline_bv = true;
+	return bq;
+}
+
+static struct bvecq *iov_kunit_create_bvecq(struct kunit *test, unsigned int max_slots)
+{
+	struct bvecq *bq;
+
+	bq = iov_kunit_alloc_bvecq(test, max_slots);
+	kunit_add_action_or_reset(test, iov_kunit_destroy_bvecq, bq);
+	return bq;
+}
+
+static void iov_kunit_load_bvecq(struct kunit *test,
+				 struct iov_iter *iter, int dir,
+				 struct bvecq *bq_head,
+				 struct page **pages, size_t npages)
+{
+	struct bvecq *bq = bq_head;
+	size_t size = 0;
+
+	for (int i = 0; i < npages; i++) {
+		if (bq->nr_slots >= bq->max_slots) {
+			bq->next = iov_kunit_alloc_bvecq(test, 13);
+			bq->next->prev = bq;
+			bq = bq->next;
+		}
+		bvec_set_page(&bq->bv[bq->nr_slots], pages[i], PAGE_SIZE, 0);
+		bq->nr_slots++;
+		size += PAGE_SIZE;
+	}
+	iov_iter_bvec_queue(iter, dir, bq_head, 0, 0, size);
+}
+
+/*
+ * Test copying to a ITER_BVECQ-type iterator.
+ */
+static void iov_kunit_copy_to_bvecq(struct kunit *test)
+{
+	const struct kvec_test_range *pr;
+	struct iov_iter iter;
+	struct bvecq *bq;
+	struct page **spages, **bpages;
+	u8 *scratch, *buffer;
+	size_t bufsize, npages, size, copied;
+	int i, patt;
+
+	bufsize = 0x100000;
+	npages = bufsize / PAGE_SIZE;
+
+	bq = iov_kunit_create_bvecq(test, 13);
+
+	scratch = iov_kunit_create_buffer(test, &spages, npages);
+	for (i = 0; i < bufsize; i++)
+		scratch[i] = pattern(i);
+
+	buffer = iov_kunit_create_buffer(test, &bpages, npages);
+	memset(buffer, 0, bufsize);
+
+	iov_kunit_load_bvecq(test, &iter, READ, bq, bpages, npages);
+
+	i = 0;
+	for (pr = kvec_test_ranges; pr->from >= 0; pr++) {
+		size = pr->to - pr->from;
+		KUNIT_ASSERT_LE(test, pr->to, bufsize);
+
+		iov_iter_bvec_queue(&iter, READ, bq, 0, 0, pr->to);
+		iov_iter_advance(&iter, pr->from);
+		copied = copy_to_iter(scratch + i, size, &iter);
+
+		KUNIT_EXPECT_EQ(test, copied, size);
+		KUNIT_EXPECT_EQ(test, iter.count, 0);
+		i += size;
+		if (test->status == KUNIT_FAILURE)
+			goto stop;
+	}
+
+	/* Build the expected image in the scratch buffer. */
+	patt = 0;
+	memset(scratch, 0, bufsize);
+	for (pr = kvec_test_ranges; pr->from >= 0; pr++)
+		for (i = pr->from; i < pr->to; i++)
+			scratch[i] = pattern(patt++);
+
+	/* Compare the images */
+	for (i = 0; i < bufsize; i++) {
+		KUNIT_EXPECT_EQ_MSG(test, buffer[i], scratch[i], "at i=%x", i);
+		if (buffer[i] != scratch[i])
+			return;
+	}
+
+stop:
+	KUNIT_SUCCEED(test);
+}
+
+/*
+ * Test copying from a ITER_BVECQ-type iterator.
+ */
+static void iov_kunit_copy_from_bvecq(struct kunit *test)
+{
+	const struct kvec_test_range *pr;
+	struct iov_iter iter;
+	struct bvecq *bq;
+	struct page **spages, **bpages;
+	u8 *scratch, *buffer;
+	size_t bufsize, npages, size, copied;
+	int i, j;
+
+	bufsize = 0x100000;
+	npages = bufsize / PAGE_SIZE;
+
+	bq = iov_kunit_create_bvecq(test, 13);
+
+	buffer = iov_kunit_create_buffer(test, &bpages, npages);
+	for (i = 0; i < bufsize; i++)
+		buffer[i] = pattern(i);
+
+	scratch = iov_kunit_create_buffer(test, &spages, npages);
+	memset(scratch, 0, bufsize);
+
+	iov_kunit_load_bvecq(test, &iter, READ, bq, bpages, npages);
+
+	i = 0;
+	for (pr = kvec_test_ranges; pr->from >= 0; pr++) {
+		size = pr->to - pr->from;
+		KUNIT_ASSERT_LE(test, pr->to, bufsize);
+
+		iov_iter_bvec_queue(&iter, WRITE, bq, 0, 0, pr->to);
+		iov_iter_advance(&iter, pr->from);
+		copied = copy_from_iter(scratch + i, size, &iter);
+
+		KUNIT_EXPECT_EQ(test, copied, size);
+		KUNIT_EXPECT_EQ(test, iter.count, 0);
+		i += size;
+	}
+
+	/* Build the expected image in the main buffer. */
+	i = 0;
+	memset(buffer, 0, bufsize);
+	for (pr = kvec_test_ranges; pr->from >= 0; pr++) {
+		for (j = pr->from; j < pr->to; j++) {
+			buffer[i++] = pattern(j);
+			if (i >= bufsize)
+				goto stop;
+		}
+	}
+stop:
+
+	/* Compare the images */
+	for (i = 0; i < bufsize; i++) {
+		KUNIT_EXPECT_EQ_MSG(test, scratch[i], buffer[i], "at i=%x", i);
+		if (scratch[i] != buffer[i])
+			return;
+	}
+
+	KUNIT_SUCCEED(test);
+}
+
 static void iov_kunit_destroy_xarray(void *data)
 {
 	struct xarray *xarray = data;
@@ -867,6 +1045,85 @@ static void iov_kunit_extract_pages_bvec(struct kunit *test)
 	KUNIT_SUCCEED(test);
 }
 
+/*
+ * Test the extraction of ITER_BVECQ-type iterators.
+ */
+static void iov_kunit_extract_pages_bvecq(struct kunit *test)
+{
+	const struct kvec_test_range *pr;
+	struct iov_iter iter;
+	struct bvecq *bq;
+	struct page **bpages, *pagelist[8], **pages = pagelist;
+	ssize_t len;
+	size_t bufsize, size = 0, npages;
+	int i, from;
+
+	bufsize = 0x100000;
+	npages = bufsize / PAGE_SIZE;
+
+	bq = iov_kunit_create_bvecq(test, 13);
+
+	iov_kunit_create_buffer(test, &bpages, npages);
+	iov_kunit_load_bvecq(test, &iter, READ, bq, bpages, npages);
+
+	for (pr = kvec_test_ranges; pr->from >= 0; pr++) {
+		from = pr->from;
+		size = pr->to - from;
+		KUNIT_ASSERT_LE(test, pr->to, bufsize);
+
+		iov_iter_bvec_queue(&iter, WRITE, bq, 0, 0, pr->to);
+		iov_iter_advance(&iter, from);
+
+		do {
+			size_t offset0 = LONG_MAX;
+
+			for (i = 0; i < ARRAY_SIZE(pagelist); i++)
+				pagelist[i] = (void *)(unsigned long)0xaa55aa55aa55aa55ULL;
+
+			len = iov_iter_extract_pages(&iter, &pages, 100 * 1024,
+						     ARRAY_SIZE(pagelist), 0, &offset0);
+			KUNIT_EXPECT_GE(test, len, 0);
+			if (len < 0)
+				break;
+			KUNIT_EXPECT_LE(test, len, size);
+			KUNIT_EXPECT_EQ(test, iter.count, size - len);
+			if (len == 0)
+				break;
+			size -= len;
+			KUNIT_EXPECT_GE(test, (ssize_t)offset0, 0);
+			KUNIT_EXPECT_LT(test, offset0, PAGE_SIZE);
+
+			for (i = 0; i < ARRAY_SIZE(pagelist); i++) {
+				struct page *p;
+				ssize_t part = min_t(ssize_t, len, PAGE_SIZE - offset0);
+				int ix;
+
+				KUNIT_ASSERT_GE(test, part, 0);
+				ix = from / PAGE_SIZE;
+				KUNIT_ASSERT_LT(test, ix, npages);
+				p = bpages[ix];
+				KUNIT_EXPECT_PTR_EQ(test, pagelist[i], p);
+				KUNIT_EXPECT_EQ(test, offset0, from % PAGE_SIZE);
+				from += part;
+				len -= part;
+				KUNIT_ASSERT_GE(test, len, 0);
+				if (len == 0)
+					break;
+				offset0 = 0;
+			}
+
+			if (test->status == KUNIT_FAILURE)
+				goto stop;
+		} while (iov_iter_count(&iter) > 0);
+
+		KUNIT_EXPECT_EQ(test, size, 0);
+		KUNIT_EXPECT_EQ(test, iter.count, 0);
+	}
+
+stop:
+	KUNIT_SUCCEED(test);
+}
+
 /*
  * Test the extraction of ITER_FOLIOQ-type iterators.
  */
@@ -1171,6 +1428,22 @@ static void iov_kunit_iter_to_sg_bvec(struct kunit *test)
 	iov_kunit_iter_to_sg_check(test, &iter, bufsize, &data);
 }
 
+static void iov_kunit_iter_to_sg_bvecq(struct kunit *test)
+{
+	struct iov_kunit_iter_to_sg_data data;
+	struct iov_iter iter;
+	struct bvecq *bq;
+	size_t bufsize;
+
+	bufsize = 0x200000;
+	iov_kunit_iter_to_sg_init(test, bufsize, false, &data);
+
+	bq = iov_kunit_create_bvecq(test, 13);
+	iov_kunit_load_bvecq(test, &iter, READ, bq, data.pages, data.npages);
+
+	iov_kunit_iter_to_sg_check(test, &iter, bufsize, &data);
+}
+
 static void iov_kunit_iter_to_sg_folioq(struct kunit *test)
 {
 	struct iov_kunit_iter_to_sg_data data;
@@ -1224,16 +1497,20 @@ static struct kunit_case iov_kunit_cases[] = {
 	KUNIT_CASE(iov_kunit_copy_from_kvec),
 	KUNIT_CASE(iov_kunit_copy_to_bvec),
 	KUNIT_CASE(iov_kunit_copy_from_bvec),
+	KUNIT_CASE(iov_kunit_copy_to_bvecq),
+	KUNIT_CASE(iov_kunit_copy_from_bvecq),
 	KUNIT_CASE(iov_kunit_copy_to_folioq),
 	KUNIT_CASE(iov_kunit_copy_from_folioq),
 	KUNIT_CASE(iov_kunit_copy_to_xarray),
 	KUNIT_CASE(iov_kunit_copy_from_xarray),
 	KUNIT_CASE(iov_kunit_extract_pages_kvec),
 	KUNIT_CASE(iov_kunit_extract_pages_bvec),
+	KUNIT_CASE(iov_kunit_extract_pages_bvecq),
 	KUNIT_CASE(iov_kunit_extract_pages_folioq),
 	KUNIT_CASE(iov_kunit_extract_pages_xarray),
 	KUNIT_CASE(iov_kunit_iter_to_sg_kvec),
 	KUNIT_CASE(iov_kunit_iter_to_sg_bvec),
+	KUNIT_CASE(iov_kunit_iter_to_sg_bvecq),
 	KUNIT_CASE(iov_kunit_iter_to_sg_folioq),
 	KUNIT_CASE(iov_kunit_iter_to_sg_xarray),
 	KUNIT_CASE(iov_kunit_iter_to_sg_ubuf),

