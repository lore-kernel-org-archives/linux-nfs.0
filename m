Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.133.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794067739;
	b=Emo0rIc9gv4iiwr8vjc7VGkDWaE1MU8mwvgp8+TAB1S6zBzYAu6tvvX00TX7yp/E/UQ/
	 zQkXXY5ATo+K234sPNEdtQsywZsrAgrI5JpUomdoL49Rgaa2d8XVQNhjKS4e3q4o4L9l2
	 BfUpgcnBbzCDkhJeUTE74nwEn2jUDCsSS1qY5qdIKK4STjnuo55rHk5by98opFcS6GCI+
	 7FjGQxt39WTDH4jkNQ2oWowxB054GQBQeb/ltmrHdme+AhBJLfeqXcWC33b5kMG8mbBjq
	 hQ6o4zb65VEffDTS70mTKoHatTWA3UMHWcqZQ789M5BSttGNqWO7HHo6+KbbTnwF1cQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794067739;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:Received:From:To:Cc:Subject:Date:
	 Message-ID:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding:X-Scanned-By;
	bh=19FMpgMsQ6QmsMAQtPOKm0azqt5YIVp+lf8tjkbmslE=;
	b=G799eeOUt7BUDi0smRpVDgNkv/Z3A4oRusvGSrhSqih8MlfoUDAZrEFmFrh4umlZhD/4
	 oQnGlZhKkbLYlu+9bhhCA6dFKmgaBJlsXPfHEvgdIp8/UG9HAZ5aDWYX9E/Sdu+xfXDLQ
	 thHgApia2c01H9VbQjWAI2eZTZ8jj4MWEe19c/9QzyR+i3BqJcCRc7F5wu/hqBfqr2J3H
	 IIC9yKkmktXrTGUU5s31QKZ352Xvsrqfs1gicGdCaOvR1ApRHgIhODSZBune+XQqRRhgg
	 S/5EwZklG/7O/qxiHDtz4xAZuL2Y9IoYGu/dkSBglzBGLJ6DwuCJd5tG9DxveMy/mgQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b="Z44XG4/9";
	arc=none smtp.remote-ip=170.10.133.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 14BF3608363B
	for <linux-nfs@vger.kernel.org>; Sat,  7 Nov 2026 16:08:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 14BF3608363B
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=Z44XG4/9
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1794067738;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=19FMpgMsQ6QmsMAQtPOKm0azqt5YIVp+lf8tjkbmslE=;
	b=Z44XG4/93O7Bs+EuTWzj+IFP6oMz2tPTHlvfTPlx11cvWH8qKBZ7YhT4bI940voFDXi5Em
	8FBsvgkvkG5hCkUmH3GRz/5wXFY6Z/nDHECzD6W4nEq6po0BUOW/hrfWeGoXoIFO1oS8+i
	PlCw6tNi+fOeL55ZP4rPPcYJ7UbLkf8=
Received: from mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-682-rwuYzV8-Na2C3YLLQjYwcg-1; Sat,
 07 Nov 2026 11:08:52 -0500
X-MC-Unique: rwuYzV8-Na2C3YLLQjYwcg-1
X-Mimecast-MFC-AGG-ID: rwuYzV8-Na2C3YLLQjYwcg_1794067730
Received: from mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.17])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 0131E18004FE;
	Sat,  7 Nov 2026 16:08:50 +0000 (UTC)
Received: from dhowells-thinkpadp1gen8.rmtgb.csb (headnet04.pony-001.prod.iad2.dc.redhat.com [10.2.32.116])
	by mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id D5573195604B;
	Sat,  7 Nov 2026 16:08:45 +0000 (UTC)
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
Subject: [PATCH v16 03/15] netfs: Add some tools for managing bvecq chains
Date: Sat,  7 Nov 2026 16:08:06 +0000
Message-ID: <20261107160823.1465553-4-dhowells@redhat.com>
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
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.17

Provide a selection of tools for managing bvec queue chains and a memory
pool for writeback to draw upon if needed.  The tools include the
allocation, prepopulation and refcounting of bvecqs and bvecq chains.  When
a chain is being cleaned up, the memory segments will be appropriately
disposed off according to the flags on each bvecq in that chain, allowing
for mixed memory cleanup types.

The main use for this is to replace the use of both folio_queues and
kvmalloc'd bio_vec arrays in netfslib and creating a structure that allows
network filesystems to easily build an entire message by gluing bits of
protocol on either side of the bvecq chains and also glue chains together
for sparse writes and compound operations.  This allows TCP-based
transports to pass a message in a single sendmsg() call and avoid corking
as this makes things more efficient.

This will also be used to do things like creating an encryption buffer in
cifs or a directory content buffer in afs.

Note that these tools are placed in netfslib for the moment, but can be
moved to lib/ later if any non-netfslib code starts to use them.  The
iov_iter bits don't depend on these tools and must live in the core.

Signed-off-by: David Howells <dhowells@redhat.com>
Reviewed-by: Paulo Alcantara <pc@manguebit.org>
cc: Matthew Wilcox <willy@infradead.org>
cc: Christoph Hellwig <hch@infradead.org>
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 fs/netfs/Makefile         |   1 +
 fs/netfs/bvecq.c          | 355 ++++++++++++++++++++++++++++++++++++++
 fs/netfs/internal.h       |   3 +
 fs/netfs/main.c           |   8 +-
 fs/netfs/objects.c        |   1 -
 fs/netfs/rolling_buffer.c |   1 -
 fs/netfs/stats.c          |   4 +-
 include/linux/bvecq.h     | 124 +++++++++++++
 include/linux/netfs.h     |   1 +
 9 files changed, 494 insertions(+), 4 deletions(-)
 create mode 100644 fs/netfs/bvecq.c

diff --git a/fs/netfs/Makefile b/fs/netfs/Makefile
index 54834cde7e56..b1ea4439c1bb 100644
--- a/fs/netfs/Makefile
+++ b/fs/netfs/Makefile
@@ -3,6 +3,7 @@
 netfs-y := \
 	buffered_read.o \
 	buffered_write.o \
+	bvecq.o \
 	direct_read.o \
 	direct_write.o \
 	iterator.o \
diff --git a/fs/netfs/bvecq.c b/fs/netfs/bvecq.c
new file mode 100644
index 000000000000..06adb44ea93f
--- /dev/null
+++ b/fs/netfs/bvecq.c
@@ -0,0 +1,355 @@
+// SPDX-License-Identifier: GPL-2.0-only
+/* Buffering helpers for bvec queues
+ *
+ * Copyright (C) 2026 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ */
+
+#include <linux/bvecq.h>
+#include "internal.h"
+
+void bvecq_dump(const struct bvecq *bq)
+{
+	int b = 0;
+
+	for (; bq; bq = bvecq_next(bq), b++) {
+		pr_notice("BQ[%u] %u/%u\n", b, bq->nr_slots, bq->max_slots);
+		for (int s = 0; s < bq->nr_slots; s++) {
+			const struct bio_vec *bv = &bq->bv[s];
+
+			if (!IS_ERR_OR_NULL(bv->bv_page))
+				pr_notice("BQ[%u:%02u] %10lx %04x %04x %u\n",
+					  b, s,
+					  page_to_pfn(bv->bv_page),
+					  bv->bv_offset, bv->bv_len,
+					  page_count(bv->bv_page));
+			else
+				pr_notice("BQ[%u:%02u] -          %04x %04x\n",
+					  b, s, bv->bv_offset, bv->bv_len);
+		}
+	}
+}
+EXPORT_SYMBOL(bvecq_dump);
+
+/**
+ * bvecq_alloc_one - Allocate a single bvecq node with unpopulated slots
+ * @nr_slots: Number of slots to allocate
+ * @gfp: The allocation constraints.
+ * @for_writeback: True if allocating for writeback
+ *
+ * Allocate a single bvecq node and initialise the header.  The allocation is
+ * rounded up to the size of the smallest slab granule that will accommodate it
+ * and all the remaining space is set as an inline slot array with max_slots
+ * set to the number of slots.  The slot array is not initialised.
+ *
+ * Note that the number of slots allocated is limited to USHRT_MAX.  If more
+ * than this are desired, a number of bvecqs should be chained.
+ *
+ * If @for_writeback is set, then the emergency mempool may be used for
+ * allocation.  If it does allocate from that pool, the maximum number of slots
+ * available will be BVECQ_POOL_SLOTS which may be less than requested.  Also,
+ * if @for_writeback is set, the function will not fail - though it may have to
+ * wait.
+ *
+ * Return: The node pointer or NULL on allocation failure.
+ */
+struct bvecq *bvecq_alloc_one(size_t nr_slots, gfp_t gfp, bool for_writeback)
+{
+	struct bvecq *bq;
+	size_t size;
+	bool from_pool = false;
+
+	/* Don't overrun ->max_slots or ->nr_slots. */
+	if (nr_slots > BVECQ_MAX_INLINE_SLOTS)
+		nr_slots = BVECQ_MAX_INLINE_SLOTS;
+
+	size = kmalloc_size_roundup(struct_size(bq, __bv, nr_slots));
+	gfp &= ~(GFP_ZONEMASK | __GFP_THISNODE);
+
+	if (for_writeback) {
+		if (size != BVECQ_POOL_SIZE) {
+			gfp_t gfp_temp = gfp;
+
+			gfp_temp |= __GFP_NOMEMALLOC | __GFP_NORETRY | __GFP_NOWARN;
+			gfp_temp &= ~(__GFP_DIRECT_RECLAIM | __GFP_IO);
+			bq = kmalloc(size, gfp_temp);
+			if (bq)
+				goto success;
+		}
+
+		bq = mempool_alloc(&netfs_bvecq_pool, gfp);
+		if (!bq)
+			return bq;
+		from_pool = true;
+		size = BVECQ_POOL_SIZE;
+	} else {
+		bq = kmalloc(size, gfp);
+		if (!bq)
+			return bq;
+	}
+
+success:
+	*bq = (struct bvecq) {
+		.ref		= REFCOUNT_INIT(1),
+		.bv		= bq->__bv,
+		.inline_bv	= true,
+		.max_slots	= min((size - sizeof(*bq)) / sizeof(bq->__bv[0]),
+				      BVECQ_MAX_INLINE_SLOTS),
+		.from_pool	= from_pool,
+	};
+	netfs_stat(&netfs_n_bvecq);
+	return bq;
+}
+EXPORT_SYMBOL(bvecq_alloc_one);
+
+/**
+ * bvecq_alloc_chain - Allocate an unpopulated bvecq chain
+ * @nr_slots: Number of slots to allocate
+ * @gfp: The allocation constraints.
+ * @for_writeback: True if allocating for writeback
+ *
+ * Allocate a chain of bvecq nodes providing at least the requested cumulative
+ * number of slots.  Each node is a maximum of 4KiB in size.
+ *
+ * Return: The first node pointer or NULL on allocation failure.
+ */
+struct bvecq *bvecq_alloc_chain(size_t nr_slots, gfp_t gfp, bool for_writeback)
+{
+	struct bvecq *head = NULL, *tail = NULL;
+
+	_enter("%zu", nr_slots);
+
+	for (;;) {
+		struct bvecq *bq;
+
+		bq = bvecq_alloc_one(min(nr_slots, BVECQ_4KB_SLOTS), gfp, for_writeback);
+		if (!bq)
+			goto oom;
+
+		if (tail)
+			bvecq_append(tail, bq);
+		else
+			head = bq;
+		tail = bq;
+		if (tail->max_slots >= nr_slots)
+			break;
+		nr_slots -= tail->max_slots;
+	}
+
+	return head;
+oom:
+	bvecq_put(head);
+	return NULL;
+}
+EXPORT_SYMBOL(bvecq_alloc_chain);
+
+/**
+ * bvecq_alloc_buffer2 - Allocate a bvecq chain and populate with buffers
+ * @size: Target size of the buffer (can be 0 for an empty buffer)
+ * @pre_slots: Number of preamble slots to set aside
+ * @gfp: The allocation constraints.
+ * @for_writeback: True if allocating for writeback
+ *
+ * Allocate a chain of bvecq nodes and populate the slots with sufficient pages
+ * to provide at least the requested amount of space, leaving the first
+ * @pre_slots slots unset.  The pre-slots must all fit into the first bvecq.
+ * Note that any memory segments set in the pre_slots will be freed as
+ * specified by BVECQ_MEM_ALLOCED.
+ *
+ * The caller should assume that the pages allocated may be compound pages
+ * larger than PAGE_SIZE and thus occupy fewer slots.  The pages have their
+ * refcounts set to 1 and can be passed to MSG_SPLICE_PAGES.
+ *
+ * Return: The first node pointer or NULL on allocation failure.
+ */
+struct bvecq *bvecq_alloc_buffer2(size_t size, unsigned int pre_slots, gfp_t gfp,
+				  bool for_writeback)
+{
+	struct bvecq *head = NULL, *p = NULL;
+	size_t nr_per_bq = BVECQ_POOL_SLOTS;
+	size_t count = pre_slots + DIV_ROUND_UP(size, PAGE_SIZE);
+
+	_enter("%zx,%zx,%u", size, count, pre_slots);
+
+	if (WARN_ON_ONCE(pre_slots > nr_per_bq))
+		return NULL;
+
+	head = bvecq_alloc_chain(count, gfp, for_writeback);
+	if (!head)
+		return NULL;
+
+	p = head;
+	do {
+		struct page **pages;
+		size_t unused, want, got, slot;
+
+		if (!count)
+			break;
+		if (WARN_ON_ONCE(!p))
+			goto oom;
+
+		if (p->nr_slots == 0) {
+			/* Need to clear pre slots and pages[], so just clear all. */
+			memset(p->bv, 0, p->max_slots * sizeof(p->bv[0]));
+			p->mem_type = BVECQ_MEM_ALLOCED;
+			p->nr_slots = pre_slots;
+			count -= pre_slots;
+			pre_slots = 0;
+			if (!count)
+				break;
+		}
+
+		if (p->nr_slots >= p->max_slots) {
+			p = p->next;
+			continue;
+		}
+		unused = p->max_slots - p->nr_slots;
+
+		/* We can put pages[] at the tail of bv[] as the elements are
+		 * smaller and we won't overrun if the slots are filled in
+		 * ascending order.
+		 */
+		pages = (struct page **)&p->bv[p->max_slots];
+		pages -= unused;
+
+		want = min(count, unused);
+		got = alloc_pages_bulk(gfp, want, pages);
+		if (!got)
+			goto oom;
+
+		slot = p->nr_slots;
+		for (int i = 0; i < got; i++)
+			bvec_set_page(&p->bv[slot++], pages[i], PAGE_SIZE, 0);
+
+		bvecq_filled_to(p, slot);
+		count -= got;
+	} while (count > 0);
+
+	return head;
+oom:
+	bvecq_put(head);
+	return NULL;
+}
+EXPORT_SYMBOL(bvecq_alloc_buffer2);
+
+/*
+ * Free the page pointed to by a slot as necessary.
+ */
+static void bvecq_free_slot(struct bvecq *bq, unsigned int slot)
+{
+	struct page *page = bq->bv[slot].bv_page;
+
+	if (!page)
+		return;
+
+	switch (bq->mem_type) {
+	case BVECQ_MEM_EXTERNAL:
+		break;
+	case BVECQ_MEM_PAGECACHE:
+		put_page(page);
+		break;
+	case BVECQ_MEM_GUP:
+		unpin_user_page(page);
+		break;
+	case BVECQ_MEM_ALLOCED:
+		__free_pages(page, compound_order(page));
+		break;
+	default:
+		WARN_ON_ONCE(1);
+		break;
+	}
+}
+
+/**
+ * bvecq_put - Put a ref on a bvec queue
+ * @bq: The start of the folio queue to free
+ *
+ * Put the ref(s) on the nodes in a bvec queue, freeing up the node and the
+ * page fragments it points to as the refcounts become zero.
+ */
+void bvecq_put(struct bvecq *bq)
+{
+	struct bvecq *next;
+
+	for (; bq; bq = next) {
+		if (!refcount_dec_and_test(&bq->ref))
+			break;
+		for (int slot = 0; slot < bq->nr_slots; slot++)
+			bvecq_free_slot(bq, slot);
+		next = bq->next;
+		netfs_stat_d(&netfs_n_bvecq);
+		if (bq->from_pool)
+			mempool_free(bq, &netfs_bvecq_pool);
+		else
+			kfree(bq);
+	}
+}
+EXPORT_SYMBOL(bvecq_put);
+
+/**
+ * bvecq_expand_buffer - Allocate buffer space into a bvec queue
+ * @_buffer: Pointer to the bvecq chain to expand (may point to a NULL; updated).
+ * @_cur_size: Current size of the buffer (updated).
+ * @size: Target size of the buffer.
+ * @gfp: The allocation constraints.
+ *
+ * Append extra pages to a buffer to increase its capacity to the @size
+ * specified.  If the current tail has space, but is not of the
+ * BVECQ_MEM_ALLOCED memory type, a separate bvecq will be allocated to hold
+ * the new memory.
+ *
+ * Return: 0 on success or -ENOMEM on failure.  Note that in the case of
+ * failure, the buffer may have been partially expanded. In any event,
+ * *@_cur_size will be updated to the new buffer size.
+ */
+int bvecq_expand_buffer(struct bvecq **_buffer, size_t *_cur_size, size_t size, gfp_t gfp)
+{
+	struct bvecq *tail = *_buffer;
+
+	size = round_up(size, PAGE_SIZE);
+	if (tail)
+		while (tail->next)
+			tail = tail->next;
+
+	while (*_cur_size < size) {
+		struct page *page;
+		size_t need = size - *_cur_size;
+		gfp_t gfp_add;
+		int order = 0;
+
+		if (!tail || bvecq_is_full(tail) || tail->mem_type != BVECQ_MEM_ALLOCED) {
+			struct bvecq *p;
+
+			p = bvecq_alloc_one(BVECQ_POOL_SLOTS, gfp, false);
+			if (!p)
+				return -ENOMEM;
+			if (tail)
+				bvecq_append(tail, p);
+			else
+				*_buffer = p;
+			tail = p;
+			p->mem_type = BVECQ_MEM_ALLOCED;
+		}
+
+		if (need > PAGE_SIZE)
+			order = umin(ilog2(need) - PAGE_SHIFT, MAX_PAGECACHE_ORDER);
+
+		gfp_add = 0;
+		if (order > 0)
+			gfp_add |= __GFP_NORETRY | __GFP_NOWARN;
+		page = alloc_pages(gfp | __GFP_COMP | gfp_add, order);
+		if (!page && order > 0) {
+			page = alloc_pages(gfp | __GFP_COMP, 0);
+			order = 0;
+		}
+		if (!page)
+			return -ENOMEM;
+
+		bvec_set_page(&tail->bv[tail->nr_slots], page, PAGE_SIZE << order, 0);
+		*_cur_size += PAGE_SIZE << order;
+		bvecq_filled_to(tail, tail->nr_slots + 1);
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(bvecq_expand_buffer);
diff --git a/fs/netfs/internal.h b/fs/netfs/internal.h
index 6b583152132f..d554468bf694 100644
--- a/fs/netfs/internal.h
+++ b/fs/netfs/internal.h
@@ -11,6 +11,7 @@
 #include <linux/netfs.h>
 #include <linux/fscache.h>
 #include <linux/fscache-cache.h>
+#include <linux/mempool.h>
 #include <trace/events/netfs.h>
 #include <trace/events/fscache.h>
 
@@ -45,6 +46,7 @@ extern struct list_head netfs_io_requests;
 extern spinlock_t netfs_proc_lock;
 extern mempool_t netfs_request_pool;
 extern mempool_t netfs_subrequest_pool;
+extern mempool_t netfs_bvecq_pool;
 extern mempool_t netfs_folioq_pool;
 
 #ifdef CONFIG_PROC_FS
@@ -205,6 +207,7 @@ extern atomic_t netfs_n_wh_retry_write_subreq;
 extern atomic_t netfs_n_wb_lock_skip;
 extern atomic_t netfs_n_wb_lock_wait;
 extern atomic_t netfs_n_folioq;
+extern atomic_t netfs_n_bvecq;
 
 int netfs_stats_show(struct seq_file *m, void *v);
 
diff --git a/fs/netfs/main.c b/fs/netfs/main.c
index 609e22e8f76a..3c796fe4280f 100644
--- a/fs/netfs/main.c
+++ b/fs/netfs/main.c
@@ -7,7 +7,6 @@
 
 #include <linux/module.h>
 #include <linux/export.h>
-#include <linux/mempool.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include "internal.h"
@@ -28,6 +27,7 @@ static struct kmem_cache *netfs_request_slab;
 static struct kmem_cache *netfs_subrequest_slab;
 mempool_t netfs_request_pool;
 mempool_t netfs_subrequest_pool;
+mempool_t netfs_bvecq_pool;
 mempool_t netfs_folioq_pool;
 
 #ifdef CONFIG_PROC_FS
@@ -111,6 +111,9 @@ static int __init netfs_init(void)
 	if (mempool_init_kmalloc_pool(&netfs_folioq_pool, 100, sizeof(struct folio_queue)) < 0)
 		goto error_folioq_pool;
 
+	if (mempool_init_kmalloc_pool(&netfs_bvecq_pool, 100, BVECQ_POOL_SIZE) < 0)
+		goto error_bvecq_pool;
+
 	netfs_request_slab = kmem_cache_create("netfs_request",
 					       sizeof(struct netfs_io_request), 0,
 					       SLAB_HWCACHE_ALIGN | SLAB_ACCOUNT,
@@ -163,6 +166,8 @@ static int __init netfs_init(void)
 error_reqpool:
 	kmem_cache_destroy(netfs_request_slab);
 error_req:
+	mempool_exit(&netfs_bvecq_pool);
+error_bvecq_pool:
 	mempool_exit(&netfs_folioq_pool);
 error_folioq_pool:
 	return ret;
@@ -177,6 +182,7 @@ static void __exit netfs_exit(void)
 	kmem_cache_destroy(netfs_subrequest_slab);
 	mempool_exit(&netfs_request_pool);
 	kmem_cache_destroy(netfs_request_slab);
+	mempool_exit(&netfs_bvecq_pool);
 	mempool_exit(&netfs_folioq_pool);
 }
 module_exit(netfs_exit);
diff --git a/fs/netfs/objects.c b/fs/netfs/objects.c
index 4b8d20559b0e..6d7839c0498d 100644
--- a/fs/netfs/objects.c
+++ b/fs/netfs/objects.c
@@ -6,7 +6,6 @@
  */
 
 #include <linux/slab.h>
-#include <linux/mempool.h>
 #include "internal.h"
 
 static void netfs_free_request(struct work_struct *work);
diff --git a/fs/netfs/rolling_buffer.c b/fs/netfs/rolling_buffer.c
index d30d5ef6d86e..4347c99452d8 100644
--- a/fs/netfs/rolling_buffer.c
+++ b/fs/netfs/rolling_buffer.c
@@ -6,7 +6,6 @@
  */
 
 #include <linux/bitops.h>
-#include <linux/mempool.h>
 #include <linux/pagemap.h>
 #include <linux/rolling_buffer.h>
 #include <linux/slab.h>
diff --git a/fs/netfs/stats.c b/fs/netfs/stats.c
index 9a607c4e62dd..a10d34f88597 100644
--- a/fs/netfs/stats.c
+++ b/fs/netfs/stats.c
@@ -47,6 +47,7 @@ atomic_t netfs_n_wh_retry_write_subreq;
 atomic_t netfs_n_wb_lock_skip;
 atomic_t netfs_n_wb_lock_wait;
 atomic_t netfs_n_folioq;
+atomic_t netfs_n_bvecq;
 
 int netfs_stats_show(struct seq_file *m, void *v)
 {
@@ -88,9 +89,10 @@ int netfs_stats_show(struct seq_file *m, void *v)
 		   atomic_read(&netfs_n_rh_retry_read_subreq),
 		   atomic_read(&netfs_n_wh_retry_write_req),
 		   atomic_read(&netfs_n_wh_retry_write_subreq));
-	seq_printf(m, "Objs   : rr=%u sr=%u foq=%u wsc=%u\n",
+	seq_printf(m, "Objs   : rr=%u sr=%u bq=%u foq=%u wsc=%u\n",
 		   atomic_read(&netfs_n_rh_rreq),
 		   atomic_read(&netfs_n_rh_sreq),
+		   atomic_read(&netfs_n_bvecq),
 		   atomic_read(&netfs_n_folioq),
 		   atomic_read(&netfs_n_wh_wstream_conflict));
 	seq_printf(m, "WbLock : skip=%u wait=%u\n",
diff --git a/include/linux/bvecq.h b/include/linux/bvecq.h
index 77fd07852c33..d9d3dd487a27 100644
--- a/include/linux/bvecq.h
+++ b/include/linux/bvecq.h
@@ -43,8 +43,132 @@ struct bvecq {
 	u16		max_slots;	/* Number of elements allocated in bv[] */
 	enum bvecq_mem	mem_type:3;	/* What sort of memory and how to free it */
 	bool		inline_bv:1;	/* T if __bv[] is being used */
+	bool		from_pool:1;	/* T if bvecq from mempool */
 	struct bio_vec	*bv;		/* Pointer to array of page fragments */
 	struct bio_vec	__bv[];		/* Default array (if ->inline_bv) */
 };
 
+/* Number of slots in a 512-byte mempool-backed bvecq. */
+#define BVECQ_POOL_SIZE 512
+#define BVECQ_POOL_SLOTS ((BVECQ_POOL_SIZE - sizeof(struct bvecq)) / sizeof(struct bio_vec))
+
+/* Number of slots in a 4K bvecq. */
+#define BVECQ_4KB_SLOTS  ((4096 - sizeof(struct bvecq)) / sizeof(struct bio_vec))
+
+/* Maximum number of slots in an inline allocation */
+#define BVECQ_MAX_INLINE_SLOTS USHRT_MAX
+
+void bvecq_dump(const struct bvecq *bq);
+struct bvecq *bvecq_alloc_one(size_t nr_slots, gfp_t gfp, bool for_writeback);
+struct bvecq *bvecq_alloc_chain(size_t nr_slots, gfp_t gfp, bool for_writeback);
+struct bvecq *bvecq_alloc_buffer2(size_t size, unsigned int pre_slots, gfp_t gfp,
+				  bool for_writeback);
+void bvecq_put(struct bvecq *bq);
+int bvecq_expand_buffer(struct bvecq **_buffer, size_t *_cur_size, size_t size, gfp_t gfp);
+
+/**
+ * bvecq_alloc_buffer - Allocate a bvecq chain and populate with buffers
+ * @size: Target size of the buffer (can be 0 for an empty buffer)
+ * @gfp: The allocation constraints.
+ * @for_writeback: True if allocating for writeback
+ *
+ * Wrapper around ``bvecq_alloc_buffer2()``.
+ *
+ * Return: The first node pointer or NULL on allocation failure.
+ */
+static inline struct bvecq *bvecq_alloc_buffer(size_t size, gfp_t gfp, bool for_writeback)
+{
+	return bvecq_alloc_buffer2(size, 0, gfp, for_writeback);
+}
+
+/**
+ * bvecq_get - Get a ref on a bvecq
+ * @bq: The bvecq to get a ref on
+ *
+ * Return: @bq.
+ */
+static inline struct bvecq *bvecq_get(struct bvecq *bq)
+{
+	refcount_inc(&bq->ref);
+	return bq;
+}
+
+/**
+ * bvecq_is_full - Determine if a bvecq is full
+ * @bvecq: The object to query
+ *
+ * Return: true if full; false if not.
+ */
+static inline bool bvecq_is_full(const struct bvecq *bvecq)
+{
+	return bvecq->nr_slots >= bvecq->max_slots;
+}
+
+/**
+ * bvecq_filled_to - Release filled slots with release barrier
+ * @bvecq: The object modified
+ * @to: The latest slot filled + 1
+ */
+static inline void bvecq_filled_to(struct bvecq *bvecq, unsigned int to)
+{
+	/* Set the slot counter after filling the slot */
+	smp_store_release(&bvecq->nr_slots, to);
+}
+
+/**
+ * bvecq_nr_slots_acquire - Get the number of filled slots with acquire barrier
+ * @bvecq: The object to query
+ *
+ * Return: The number of filled slots
+ */
+static inline unsigned int bvecq_nr_slots_acquire(const struct bvecq *bvecq)
+{
+	/* Read the slot counter before looking at the slot */
+	return smp_load_acquire(&bvecq->nr_slots);
+}
+
+/**
+ * bvecq_acquire_slot - Determine if a slot is valid with acquire barrier
+ * @bvecq: The object to query
+ * @slot: The next slot
+ *
+ * Return: true if valid; false if might not be valid
+ */
+static inline bool bvecq_acquire_slot(const struct bvecq *bvecq, unsigned int slot)
+{
+	/* Read the slot counter before looking at the slot */
+	return slot < bvecq_nr_slots_acquire(bvecq);
+}
+
+/**
+ * bvecq_append - Get the next bvecq with appropriate barrier
+ * @to: The bvecq to append to
+ * @add: The bvecq to append
+ *
+ * Attach a new bvecq to a chain using an appropriate barrier to protect the
+ * write.
+ *
+ * [!] Note that this function transfers the caller's ref to the chain.
+ */
+static inline void bvecq_append(struct bvecq *to, struct bvecq *add)
+{
+	add->prev = to;
+
+	/* Make sure the initialisation is stored before the next pointer. */
+	smp_store_release(&to->next, add);
+}
+
+/**
+ * bvecq_next - Get the next bvecq with appropriate barrier
+ * @bq: The bvecq to start from
+ *
+ * Return: The next bvecq in a chain, using an appropriate barrier to protect
+ * the access.
+ */
+static inline struct bvecq *bvecq_next(const struct bvecq *bq)
+{
+	/* Read the contents of the next node after the pointer to it. */
+	return smp_load_acquire(&bq->next);
+}
+
 #endif /* _LINUX_BVECQ_H */
diff --git a/include/linux/netfs.h b/include/linux/netfs.h
index e5961450f3f1..2cf1163aafa6 100644
--- a/include/linux/netfs.h
+++ b/include/linux/netfs.h
@@ -17,6 +17,7 @@
 #include <linux/workqueue.h>
 #include <linux/fs.h>
 #include <linux/pagemap.h>
+#include <linux/bvecq.h>
 #include <linux/uio.h>
 #include <linux/rolling_buffer.h>
 

