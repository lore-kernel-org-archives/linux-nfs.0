Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AE0524D17B3
	for <linux-nfs@vger.kernel.org>; Thu,  1 Oct 2026 09:13:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790846004; cv=none; b=qP4TViEOPUE9Kii0PlrDYcUpsR2Co7Yuia1aiiE+cRxBDwLmp9/6J4CvEuWF/P8DkchVUSX7BMq4SAuKbanWZqY9k8mI1a8wdOLebGaLyNI5oTXU+PE6KkM2GbE5LA+qBbtd/wycveMQpRPv8Ip/cbTp6oCqAP91gmfZEtzyKPM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790846004; c=relaxed/simple;
	bh=VckK+hm4cI2RJ93/hh9U++X+nvttZ8YSjyXHACMuXrg=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=mQgkR6vMVWmtqLFCw2gmSOdgWLMsRcriHlAQjJpAiE4gfvscd5MOp9sAV9InTsg5i04IPYVtt+GhoSzaGL4s3/EYyHNiWS8rbGTCdBjCHIZ57zVB3GkEZKA72/zwuvELkDYq5CxJxxMXzHYOmSC0/6V52ESVa5jlaW/qCNES8l4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=SloDrc27; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="SloDrc27"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1790846000;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=JwvoN5wl8W1Ocn83q68vasqu8aC8HjbXczmir5xZdmI=;
	b=SloDrc27/VMM5gaeQ+qCjsDM3eM5a3SHeasKzrDd9LgUV7SBgSRfsON1zt0IKkaB7SS1cR
	2nEy0hGbl9whFqwSVDHnV7Ln9FCByFCd8eNgfW+tkccPK3E+/2vcK7IwAo/VrkXgpa1crk
	V5v/q1nDVLFcUJ08jk/FxrlWvJms/SU=
Received: from mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-22-ZJKBd0IaMNeYgUF5NYKw8Q-1; Thu,
 01 Oct 2026 05:13:17 -0400
X-MC-Unique: ZJKBd0IaMNeYgUF5NYKw8Q-1
X-Mimecast-MFC-AGG-ID: ZJKBd0IaMNeYgUF5NYKw8Q_1790845994
Received: from mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.111])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id C4D691954198;
	Thu,  1 Oct 2026 09:13:13 +0000 (UTC)
Received: from warthog.com (unknown [10.44.32.54])
	by mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id D0CE318005B3;
	Thu,  1 Oct 2026 09:13:08 +0000 (UTC)
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
Subject: [PATCH v15 03/10] netfs: Add some tools for managing bvecq chains
Date: Thu,  1 Oct 2026 10:12:31 +0100
Message-ID: <20261001091239.3343034-4-dhowells@redhat.com>
In-Reply-To: <20261001091239.3343034-1-dhowells@redhat.com>
References: <20261001091239.3343034-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.111

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

Signed-off-by: David Howells <dhowells@redhat.com>
Reviewed-by: Paulo Alcantara <pc@manguebit.org>
cc: Matthew Wilcox <willy@infradead.org>
cc: Christoph Hellwig <hch@infradead.org>
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 fs/netfs/Makefile     |   1 +
 fs/netfs/bvecq.c      | 344 ++++++++++++++++++++++++++++++++++++++++++
 fs/netfs/internal.h   |   2 +
 fs/netfs/main.c       |   8 +
 fs/netfs/stats.c      |   4 +-
 include/linux/bvecq.h | 116 ++++++++++++++
 include/linux/netfs.h |   1 +
 7 files changed, 475 insertions(+), 1 deletion(-)
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
index 000000000000..5b747f6b5938
--- /dev/null
+++ b/fs/netfs/bvecq.c
@@ -0,0 +1,344 @@
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
+		int skipz = 0;
+
+		pr_notice("BQ[%u] %u/%u\n", b, bq->nr_slots, bq->max_slots);
+		for (int s = 0; s < bq->nr_slots; s++) {
+			const struct bio_vec *bv = &bq->bv[s];
+
+			if (!bv->bv_page && !bv->bv_len && skipz < 2) {
+				skipz = 1;
+				continue;
+			}
+			if (skipz == 1)
+				pr_notice("BQ[%u:00-%02u] ...\n", b, s - 1);
+			skipz = 2;
+			pr_notice("BQ[%u:%02u] %10lx %04x %04x %u\n",
+				  b, s,
+				  bv->bv_page ? page_to_pfn(bv->bv_page) : 0,
+				  bv->bv_offset, bv->bv_len,
+				  bv->bv_page ? page_count(bv->bv_page) : 0);
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
+	const size_t pool_size = struct_size_t(struct bvecq, __bv, BVECQ_POOL_SLOTS);
+	size_t size;
+	bool from_pool = false;
+
+	size = kmalloc_size_roundup(struct_size(bq, __bv, nr_slots));
+	gfp &= ~(GFP_ZONEMASK | __GFP_THISNODE);
+
+	if (for_writeback) {
+		if (size != pool_size) {
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
+		size = pool_size;
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
+		.max_slots	= (size - sizeof(*bq)) / sizeof(bq->__bv[0]),
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
+ * @pre_slots slots unset.  The pre-slots must all fit into the the first
+ * bvecq.
+ *
+ * The pages allocated may be compound pages larger than PAGE_SIZE and thus
+ * occupy fewer slots.  The pages have their refcounts set to 1 and can be
+ * passed to MSG_SPLICE_PAGES.
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
index b8591abc90a9..dd20a9f201be 100644
--- a/fs/netfs/internal.h
+++ b/fs/netfs/internal.h
@@ -45,6 +45,7 @@ extern struct list_head netfs_io_requests;
 extern spinlock_t netfs_proc_lock;
 extern mempool_t netfs_request_pool;
 extern mempool_t netfs_subrequest_pool;
+extern mempool_t netfs_bvecq_pool;
 extern mempool_t netfs_folioq_pool;
 
 #ifdef CONFIG_PROC_FS
@@ -203,6 +204,7 @@ extern atomic_t netfs_n_wh_retry_write_subreq;
 extern atomic_t netfs_n_wb_lock_skip;
 extern atomic_t netfs_n_wb_lock_wait;
 extern atomic_t netfs_n_folioq;
+extern atomic_t netfs_n_bvecq;
 
 int netfs_stats_show(struct seq_file *m, void *v);
 
diff --git a/fs/netfs/main.c b/fs/netfs/main.c
index 609e22e8f76a..5c8517a66dde 100644
--- a/fs/netfs/main.c
+++ b/fs/netfs/main.c
@@ -28,6 +28,7 @@ static struct kmem_cache *netfs_request_slab;
 static struct kmem_cache *netfs_subrequest_slab;
 mempool_t netfs_request_pool;
 mempool_t netfs_subrequest_pool;
+mempool_t netfs_bvecq_pool;
 mempool_t netfs_folioq_pool;
 
 #ifdef CONFIG_PROC_FS
@@ -111,6 +112,10 @@ static int __init netfs_init(void)
 	if (mempool_init_kmalloc_pool(&netfs_folioq_pool, 100, sizeof(struct folio_queue)) < 0)
 		goto error_folioq_pool;
 
+	if (mempool_init_kmalloc_pool(&netfs_bvecq_pool, 100,
+				      struct_size_t(struct bvecq, __bv, BVECQ_POOL_SLOTS)) < 0)
+		goto error_bvecq_pool;
+
 	netfs_request_slab = kmem_cache_create("netfs_request",
 					       sizeof(struct netfs_io_request), 0,
 					       SLAB_HWCACHE_ALIGN | SLAB_ACCOUNT,
@@ -163,6 +168,8 @@ static int __init netfs_init(void)
 error_reqpool:
 	kmem_cache_destroy(netfs_request_slab);
 error_req:
+	mempool_exit(&netfs_bvecq_pool);
+error_bvecq_pool:
 	mempool_exit(&netfs_folioq_pool);
 error_folioq_pool:
 	return ret;
@@ -177,6 +184,7 @@ static void __exit netfs_exit(void)
 	kmem_cache_destroy(netfs_subrequest_slab);
 	mempool_exit(&netfs_request_pool);
 	kmem_cache_destroy(netfs_request_slab);
+	mempool_exit(&netfs_bvecq_pool);
 	mempool_exit(&netfs_folioq_pool);
 }
 module_exit(netfs_exit);
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
index 77fd07852c33..b984aaa44908 100644
--- a/include/linux/bvecq.h
+++ b/include/linux/bvecq.h
@@ -43,8 +43,124 @@ struct bvecq {
 	u16		max_slots;	/* Number of elements allocated in bv[] */
 	enum bvecq_mem	mem_type:3;	/* What sort of memory and how to free it */
 	bool		inline_bv:1;	/* T if __bv[] is being used */
+	bool		from_pool:1;	/* T if bvecq from mempool */
 	struct bio_vec	*bv;		/* Pointer to array of page fragments */
 	struct bio_vec	__bv[];		/* Default array (if ->inline_bv) */
 };
 
+/* Number of slots in a 512-byte mempool-backed bvecq. */
+#define BVECQ_POOL_SLOTS ((512 - sizeof(struct bvecq)) / sizeof(struct bio_vec))
+
+/* Number of slots in a 4K bvecq. */
+#define BVECQ_4KB_SLOTS  ((4096 - sizeof(struct bvecq)) / sizeof(struct bio_vec))
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
+ * Wrapper around %bvecq_alloc_buffer2().
+ */
+static inline struct bvecq *bvecq_alloc_buffer(size_t size, gfp_t gfp, bool for_writeback)
+{
+	return bvecq_alloc_buffer2(size, 0, gfp, for_writeback);
+}
+
+/**
+ * bvecq_get - Get a ref on a bvecq
+ * @bq: The bvecq to get a ref on
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
+ * Return the next bvecq in a chain, using an appropriate barrier to protect
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
index 67e010b6994b..1723bcda86ba 100644
--- a/include/linux/netfs.h
+++ b/include/linux/netfs.h
@@ -17,6 +17,7 @@
 #include <linux/workqueue.h>
 #include <linux/fs.h>
 #include <linux/pagemap.h>
+#include <linux/bvecq.h>
 #include <linux/uio.h>
 #include <linux/rolling_buffer.h>
 

