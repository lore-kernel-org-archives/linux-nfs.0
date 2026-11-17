Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.133.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794936058;
	b=ja5SQRWVp4i9JObM+NlZl6liomzGE879hQSxMeNXdzbwBXh6QfNNsdz1rsY9RHXxCG26
	 w5azpIgplNmixcg0H/H9DjvKceEnYg9gi9GPIlCb5Tt/4Q7dtMrtYtIoKe4941gckGML1
	 ypS4w9eYlsSLtJg+nugyW73qYW4u1TYiIyQRbzdIMLr1uGe5S5+oRTN+dFO2OZeolkdY7
	 hhtc/k+dGYS6OMfocDJ1UCYPvuRr3xq3p/IydZMyXamsHEANTkg4XfkOvfC1Xuc5TEa1S
	 nQRwzBDZNtCATVur3FHgfvbXUMOrJ2I7qeu7lyoc6p4EbGaAs6yNRBrGJ4W97SCmESQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794936058;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:Received:From:To:Cc:Subject:Date:
	 Message-ID:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding:X-Scanned-By;
	bh=J7wCdXgrv/GASBeWrvieeh7ZX3txCEjhN85tsmVnc4U=;
	b=hKOtjahpBCsrXZ5g2XRM70B+yTdoArVQ+3/PEgkBlAIkp/G2Eo2sSaPAbU3JDrzwwHCk
	 ElGnX4Gg7PWG4h0p0JQgDJn8H9el6xNazIzGDe13YGarrLtH8TXsVpISciAFtvTtcYGQT
	 zW+kY65TCsE2xNO2w8hjC23ms75jbjXC3ID25aLlEJ44gnvWmhJXcNbwwyRWsSkucI22l
	 LJLg9R1OQQ6vwGIpuLdWHGbVk1ZSGVutvC19rKmSFnxue7slU6GQH1u2zRvKnAJFdsIEM
	 4dO8LB/sFmWGp7TDg3c4qIaieVKG1FuRtmsLFicPJ1wiEOV3572Cf9/TqBvQdaHs3jA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=dqmNDUrU;
	arc=none smtp.remote-ip=170.10.133.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 417A4606A33D
	for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2026 17:20:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 417A4606A33D
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=dqmNDUrU
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1794936056;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=J7wCdXgrv/GASBeWrvieeh7ZX3txCEjhN85tsmVnc4U=;
	b=dqmNDUrU0IBWsz8OtykqzPsYJSu0BehUKRw9Wh+QTVGvMnYk9xiMlhK8BuT2mxrYWjly85
	CIQbhxpXhJieVrmaI5FU6h13now9+KyrIwaQdXYyuIghos3jZoCAS54A806hB6SR/0NQ/R
	xsyoCtrebBiM/fOYxChYh2hkMGElb9E=
Received: from mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-652-Ah1YdkojP12GAEvZUC9QCg-1; Tue,
 17 Nov 2026 12:20:52 -0500
X-MC-Unique: Ah1YdkojP12GAEvZUC9QCg-1
X-Mimecast-MFC-AGG-ID: Ah1YdkojP12GAEvZUC9QCg_1794936045
Received: from mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.95])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 2292C1956054;
	Tue, 17 Nov 2026 17:20:44 +0000 (UTC)
Received: from dhowells-thinkpadp1gen8.rmtgb.csb (headnet04.pony-001.prod.iad2.dc.redhat.com [10.2.32.116])
	by mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 21CA5589;
	Tue, 17 Nov 2026 17:20:39 +0000 (UTC)
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
Subject: [PATCH v18 04/17] netfs: Add some tools for managing bvecq chains
Date: Tue, 17 Nov 2026 17:19:02 +0000
Message-ID: <20261117171958.2982801-5-dhowells@redhat.com>
In-Reply-To: <20261117171958.2982801-1-dhowells@redhat.com>
References: <20261117171958.2982801-1-dhowells@redhat.com>
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
X-Scanned-By: MIMEDefang 3.6 on 10.30.177.95

Provide a selection of tools for managing bvec queue chains and a memory
pool for writeback to draw upon if needed.  The tools include the
allocation, prepopulation and refcounting of bvecqs and bvecq chains.  When
a chain is being cleaned up, the memory segments will be appropriately
disposed off according to the flags on each bvecq in that chain, allowing
for mixed memory cleanup types.

A pair of memory pools is provided for emergency allocation under low
memory conditions.  The two pools are intended for use in different
circumstances with different usage characteristics.  The request-level pool
will be used by netfslib requests to build a rolling buffer as it goes
along, whereas the subrequest-level pool will be used by subrequests
(e.g. cifs can use it to allocate an encryption buffer).  Separate pools
are provided to avoid deadlocking between levels.

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
 fs/netfs/bvecq.c          | 414 ++++++++++++++++++++++++++++++++++++++
 fs/netfs/internal.h       |   5 +
 fs/netfs/main.c           |  46 ++++-
 fs/netfs/objects.c        |   1 -
 fs/netfs/rolling_buffer.c |   1 -
 fs/netfs/stats.c          |   6 +-
 include/linux/bvecq.h     | 145 +++++++++++++
 include/linux/netfs.h     |   1 +
 9 files changed, 616 insertions(+), 4 deletions(-)
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
index 000000000000..8ac2dc235258
--- /dev/null
+++ b/fs/netfs/bvecq.c
@@ -0,0 +1,414 @@
+// SPDX-License-Identifier: GPL-2.0-only
+/* Buffering helpers for bvec queues
+ *
+ * Copyright (C) 2026 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ */
+
+#include <linux/bvecq.h>
+#include <linux/semaphore.h>
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
+ * @flags: Pointer to the allocation flags
+ *
+ * Allocate a single bvecq node and initialise the header.  The allocation is
+ * rounded up to the size of the smallest slab granule that will accommodate it
+ * and all the remaining space is set as an inline slot array with max_slots
+ * set to the number of slots.  The slot array is not initialised.
+ *
+ * Note that the number of slots allocated is limited to USHRT_MAX.  If more
+ * than this are desired, a number of bvecqs should be chained.
+ *
+ * If *@flags includes %BVECQ_USE_REQ_POOL or %BVECQ_USE_SUBREQ_POOL, then an
+ * emergency mempool may be used for allocation.  If it does allocate from such
+ * a pool, the maximum number of slots available will be BVECQ_POOL_SLOTS which
+ * may be less than requested.  Also, if once of these flags is set, the
+ * function will not fail - though it may have to wait (though if
+ * %BVECQ_SHORT_OKAY is set, it may return early but will have at least one
+ * bveq in the allocation).
+ *
+ * Further, in order to access an emergency pool, the function must take a
+ * count from the semaphore that governs access to that pool.  When it has
+ * access to the pool, %BVECQ_HOLD_POOL_SEM is set in *@flags and the sem is
+ * held - and access allowed - until explicitly dropped.  The pool has more
+ * objects than the sem has counts, which means that there are always more
+ * objects in the pool than processes trying to allocate from it - guaranteeing
+ * that at least some progress can be made.
+ *
+ * Return: The node pointer or NULL on allocation failure.  BVECQ_HIT_OOM is
+ * set in *flags if an allocation failure occurs.
+ */
+struct bvecq *bvecq_alloc_one(size_t nr_slots, gfp_t gfp, unsigned int *flags)
+{
+	enum bvecq_pool from_pool = *flags & BVECQ__USE_POOL;
+	struct bvecq *bq;
+	size_t size;
+
+	/* Don't overrun ->max_slots or ->nr_slots. */
+	if (nr_slots > BVECQ_MAX_INLINE_SLOTS)
+		nr_slots = BVECQ_MAX_INLINE_SLOTS;
+
+	size = kmalloc_size_roundup(struct_size(bq, __bv, nr_slots));
+	gfp &= ~(GFP_ZONEMASK | __GFP_THISNODE);
+
+	if (from_pool != BVECQ_USE_NO_POOL) {
+		struct semaphore *sem = &netfs_bvecq_pool_sem[from_pool];
+		struct mempool *pool = &netfs_bvecq_pool[from_pool];
+		gfp_t gfp_temp = gfp;
+
+		gfp_temp |= __GFP_NOMEMALLOC | __GFP_NORETRY | __GFP_NOWARN;
+		gfp_temp &= ~(__GFP_DIRECT_RECLAIM | __GFP_IO);
+
+		if (size != BVECQ_POOL_SIZE) {
+			bq = kmalloc(size, gfp_temp);
+			if (bq) {
+				from_pool = BVECQ_USE_NO_POOL;
+				goto success;
+			}
+		} else {
+			bq = mempool_alloc_noreserve(pool, gfp_temp);
+			if (bq) {
+				goto success;
+			}
+		}
+		*flags |= BVECQ_HIT_OOM;
+
+		if (!(*flags & BVECQ_HOLD_POOL_SEM)) {
+			down(sem);
+			*flags |= BVECQ_HOLD_POOL_SEM;
+		}
+
+		bq = mempool_alloc(pool, gfp);
+		if (!bq)
+			return bq;
+		size = BVECQ_POOL_SIZE;
+	} else {
+		bq = kmalloc(size, gfp);
+		if (!bq) {
+			*flags |= BVECQ_HIT_OOM;
+			return bq;
+		}
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
+ * @flags: Pointer to the allocation flags
+ *
+ * Allocate a chain of bvecq nodes providing at least the requested cumulative
+ * number of slots.  Each node is a maximum of 4KiB in size.  If
+ * %BVECQ_SHORT_OKAY is set in *%flags, then the chain may be shortened on OOM.
+ *
+ * Return: The first node pointer or NULL on allocation failure.  BVECQ_HIT_OOM
+ * is set in *flags if an allocation failure occurs.
+ */
+struct bvecq *bvecq_alloc_chain(size_t nr_slots, gfp_t gfp, unsigned int *flags)
+{
+	struct bvecq *head = NULL, *tail = NULL;
+
+	_enter("%zu", nr_slots);
+	*flags &= ~BVECQ_HIT_OOM;
+
+	for (;;) {
+		struct bvecq *bq;
+
+		bq = bvecq_alloc_one(min(nr_slots, BVECQ_4KB_SLOTS), gfp, flags);
+		if (!bq)
+			goto oom;
+
+		if (tail)
+			bvecq_append(tail, bq);
+		else
+			head = bq;
+		tail = bq;
+		if (unlikely((*flags & BVECQ_HIT_OOM) && (*flags & BVECQ_SHORT_OKAY)) ||
+		    tail->max_slots >= nr_slots)
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
+ * @gfp: The allocation constraints
+ * @flags: Pointer to the allocation flags
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
+ * Return: The first node pointer or NULL on allocation failure.  BVECQ_HIT_OOM
+ * is set in *flags if a bvecq chain allocation failure occurs.
+ */
+struct bvecq *bvecq_alloc_buffer2(size_t size, unsigned int pre_slots, gfp_t gfp,
+				  unsigned int *flags)
+{
+	struct bvecq *head = NULL, *tail = NULL;
+	size_t count = pre_slots + DIV_ROUND_UP(size, PAGE_SIZE);
+
+	_enter("%zx,%zx,%u", size, count, pre_slots);
+
+	*flags &= ~BVECQ_HIT_OOM;
+	if (WARN_ON_ONCE(pre_slots > BVECQ_POOL_SLOTS))
+		return NULL;
+
+	do {
+		struct page **pages;
+		size_t unused, want, got, slot;
+
+		if (!tail || bvecq_is_full(tail)) {
+			struct bvecq *bq;
+
+			bq = bvecq_alloc_one(min(count, BVECQ_4KB_SLOTS), gfp, flags);
+			if (!bq)
+				goto oom;
+
+			if (tail)
+				bvecq_append(tail, bq);
+			else
+				head = bq;
+			tail = bq;
+
+			/* Need to clear pre slots and pages[], so just clear all. */
+			memset(tail->bv, 0, tail->max_slots * sizeof(tail->bv[0]));
+			tail->mem_type = BVECQ_MEM_ALLOCED;
+			tail->nr_slots = pre_slots;
+			count -= pre_slots;
+			pre_slots = 0;
+		}
+
+		if (!count)
+			break;
+
+		unused = tail->max_slots - tail->nr_slots;
+
+		/* We can put pages[] at the tail of bv[] as the elements are
+		 * smaller and we won't overrun if the slots are filled in
+		 * ascending order.
+		 */
+		pages = (struct page **)&tail->bv[tail->max_slots];
+		pages -= unused;
+
+		want = min(count, unused);
+		got = alloc_pages_bulk(gfp, want, pages);
+		if (!got) {
+			*flags |= BVECQ_HIT_OOM;
+			goto oom;
+		}
+
+		slot = tail->nr_slots;
+		for (int i = 0; i < got; i++)
+			bvec_set_page(&tail->bv[slot++], pages[i], PAGE_SIZE, 0);
+
+		bvecq_filled_to(tail, slot);
+		count -= got;
+
+		if (unlikely(*flags & BVECQ_HIT_OOM) && (*flags & BVECQ_SHORT_OKAY))
+			break;
+	} while (count > 0);
+
+out:
+	return head;
+oom:
+	if (*flags & BVECQ_SHORT_OKAY)
+		goto out;
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
+
+		if (bq->from_pool != BVECQ_USE_NO_POOL)
+			mempool_free(bq, &netfs_bvecq_pool[bq->from_pool]);
+		else
+			kfree(bq);
+	}
+}
+EXPORT_SYMBOL(bvecq_put);
+
+/**
+ * bvecq_pool_unlock - Clean up emergency pool access
+ * @flags: Pointer to current allocation flag state
+ *
+ * Clean up the emergency pool access semaphore state as obtained by the
+ * bvecq_alloc_* functions.
+ */
+void bvecq_pool_unlock(unsigned int *flags)
+{
+	if (*flags & BVECQ_HOLD_POOL_SEM) {
+		up(&netfs_bvecq_pool_sem[*flags & BVECQ__USE_POOL]);
+		*flags &= ~BVECQ_HOLD_POOL_SEM;
+	}
+}
+EXPORT_SYMBOL(bvecq_pool_unlock);
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
+	unsigned int alloc_flags = 0;
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
+			p = bvecq_alloc_one(BVECQ_POOL_SLOTS, gfp, &alloc_flags);
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
index 6b583152132f..10688314660f 100644
--- a/fs/netfs/internal.h
+++ b/fs/netfs/internal.h
@@ -11,6 +11,8 @@
 #include <linux/netfs.h>
 #include <linux/fscache.h>
 #include <linux/fscache-cache.h>
+#include <linux/mempool.h>
+#include <linux/semaphore.h>
 #include <trace/events/netfs.h>
 #include <trace/events/fscache.h>
 
@@ -46,6 +48,8 @@ extern spinlock_t netfs_proc_lock;
 extern mempool_t netfs_request_pool;
 extern mempool_t netfs_subrequest_pool;
 extern mempool_t netfs_folioq_pool;
+extern mempool_t netfs_bvecq_pool[4];
+extern struct semaphore netfs_bvecq_pool_sem[4];
 
 #ifdef CONFIG_PROC_FS
 static inline void netfs_proc_add_rreq(struct netfs_io_request *rreq)
@@ -205,6 +209,7 @@ extern atomic_t netfs_n_wh_retry_write_subreq;
 extern atomic_t netfs_n_wb_lock_skip;
 extern atomic_t netfs_n_wb_lock_wait;
 extern atomic_t netfs_n_folioq;
+extern atomic_t netfs_n_bvecq;
 
 int netfs_stats_show(struct seq_file *m, void *v);
 
diff --git a/fs/netfs/main.c b/fs/netfs/main.c
index 609e22e8f76a..a185419a4039 100644
--- a/fs/netfs/main.c
+++ b/fs/netfs/main.c
@@ -7,7 +7,6 @@
 
 #include <linux/module.h>
 #include <linux/export.h>
-#include <linux/mempool.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include "internal.h"
@@ -30,6 +29,9 @@ mempool_t netfs_request_pool;
 mempool_t netfs_subrequest_pool;
 mempool_t netfs_folioq_pool;
 
+mempool_t netfs_bvecq_pool[4]; /* unused (NO_POOL), REQ_POOL, SUBREQ_POOL, unused */
+struct semaphore netfs_bvecq_pool_sem[4];
+
 #ifdef CONFIG_PROC_FS
 LIST_HEAD(netfs_io_requests);
 DEFINE_SPINLOCK(netfs_proc_lock);
@@ -111,6 +113,42 @@ static int __init netfs_init(void)
 	if (mempool_init_kmalloc_pool(&netfs_folioq_pool, 100, sizeof(struct folio_queue)) < 0)
 		goto error_folioq_pool;
 
+	/* We set up multiple bvecq emergency pools: one for requests and one
+	 * for subrequests, though there may also need to be one for
+	 * reconnection.  This is needed to avoid deadlock as a process will
+	 * allocate for request and then for subrequest whilst still holding
+	 * the first alloc (and may go through reconnection whilst setting up a
+	 * subrequest).
+	 *
+	 * For the request pool, we allocate 100 bvecqs in the pool, but only
+	 * allow half that number of processes to access the pool at any one
+	 * time - which means at least one process will be able to access two
+	 * bvecqs.  Combined with accelerated issuing of subreqs be a process
+	 * using the pool, the pool should refill at a reasonable pace.
+	 *
+	 */
+	int nr_per_proc = 2;
+	int nr_procs = 50;
+
+	if (mempool_init_kmalloc_pool(&netfs_bvecq_pool[1], nr_per_proc * nr_procs,
+				      BVECQ_POOL_SIZE) < 0)
+		goto error_bvecq_pool_1;
+	sema_init(&netfs_bvecq_pool_sem[1], nr_procs);
+
+	/* For the subrequest pool, the allocation is expected to be set up in
+	 * one go and torn down in one go (e.g. allocating a cifs encryption
+	 * buffer) and an allocation may be quite large.  Support up to 16MiB of
+	 * bufferage in a single chain, and allow two concurrent chain
+	 * allocations.
+	 */
+	nr_per_proc = DIV_ROUND_UP((16 << 20) / PAGE_SIZE, BVECQ_POOL_SLOTS);
+	nr_procs = 2;
+
+	if (mempool_init_kmalloc_pool(&netfs_bvecq_pool[2], nr_per_proc * nr_procs,
+				      BVECQ_POOL_SIZE) < 0)
+		goto error_bvecq_pool_2;
+	sema_init(&netfs_bvecq_pool_sem[2], nr_procs);
+
 	netfs_request_slab = kmem_cache_create("netfs_request",
 					       sizeof(struct netfs_io_request), 0,
 					       SLAB_HWCACHE_ALIGN | SLAB_ACCOUNT,
@@ -163,6 +201,10 @@ static int __init netfs_init(void)
 error_reqpool:
 	kmem_cache_destroy(netfs_request_slab);
 error_req:
+	mempool_exit(&netfs_bvecq_pool[2]);
+error_bvecq_pool_2:
+	mempool_exit(&netfs_bvecq_pool[1]);
+error_bvecq_pool_1:
 	mempool_exit(&netfs_folioq_pool);
 error_folioq_pool:
 	return ret;
@@ -177,6 +219,8 @@ static void __exit netfs_exit(void)
 	kmem_cache_destroy(netfs_subrequest_slab);
 	mempool_exit(&netfs_request_pool);
 	kmem_cache_destroy(netfs_request_slab);
+	mempool_exit(&netfs_bvecq_pool[2]);
+	mempool_exit(&netfs_bvecq_pool[1]);
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
index 9a607c4e62dd..07c5f9165768 100644
--- a/fs/netfs/stats.c
+++ b/fs/netfs/stats.c
@@ -47,6 +47,7 @@ atomic_t netfs_n_wh_retry_write_subreq;
 atomic_t netfs_n_wb_lock_skip;
 atomic_t netfs_n_wb_lock_wait;
 atomic_t netfs_n_folioq;
+atomic_t netfs_n_bvecq;
 
 int netfs_stats_show(struct seq_file *m, void *v)
 {
@@ -88,10 +89,13 @@ int netfs_stats_show(struct seq_file *m, void *v)
 		   atomic_read(&netfs_n_rh_retry_read_subreq),
 		   atomic_read(&netfs_n_wh_retry_write_req),
 		   atomic_read(&netfs_n_wh_retry_write_subreq));
-	seq_printf(m, "Objs   : rr=%u sr=%u foq=%u wsc=%u\n",
+	seq_printf(m, "Objs   : rr=%u sr=%u bq=%u foq=%u bqs=%d,%d wsc=%u\n",
 		   atomic_read(&netfs_n_rh_rreq),
 		   atomic_read(&netfs_n_rh_sreq),
+		   atomic_read(&netfs_n_bvecq),
 		   atomic_read(&netfs_n_folioq),
+		   READ_ONCE(netfs_bvecq_pool_sem[1].count),
+		   READ_ONCE(netfs_bvecq_pool_sem[2].count),
 		   atomic_read(&netfs_n_wh_wstream_conflict));
 	seq_printf(m, "WbLock : skip=%u wait=%u\n",
 		   atomic_read(&netfs_n_wb_lock_skip),
diff --git a/include/linux/bvecq.h b/include/linux/bvecq.h
index 77fd07852c33..676cccb6ce2c 100644
--- a/include/linux/bvecq.h
+++ b/include/linux/bvecq.h
@@ -21,6 +21,20 @@ enum bvecq_mem {
 	BVECQ_MEM_ALLOCED,	/* Memory alloc'd by bvecq - can be freed/pooled */
 } __mode(byte);
 
+/*
+ * There are two emergency pools from which bvecqs can be allocated under OOM
+ * conditions.  These are intended for use in writeback where allocation is not
+ * typically allowed to fail.  One pool is for request-level allocs and one is
+ * for subreq-level allocs - having two pools prevents the two levels from
+ * blocking each other; further, the two pools can have different ratios and
+ * capacities.
+ */
+enum bvecq_pool {
+	BVECQ_USE_NO_POOL	= 0,	/* Don't use a pool */
+	BVECQ_USE_REQ_POOL	= 1,	/* Use the request-level pool */
+	BVECQ_USE_SUBREQ_POOL	= 2,	/* Use the subrequest-level pool */
+};
+
 /*
  * Segmented bio_vec queue.
  *
@@ -43,8 +57,139 @@ struct bvecq {
 	u16		max_slots;	/* Number of elements allocated in bv[] */
 	enum bvecq_mem	mem_type:3;	/* What sort of memory and how to free it */
 	bool		inline_bv:1;	/* T if __bv[] is being used */
+	enum bvecq_pool	from_pool;	/* Which pool the bvecq can be returned to (if any) */
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
+/* Allocation flags */
+#define BVECQ__USE_POOL		0x03	/* As enum bvecq_pool */
+#define BVECQ_SHORT_OKAY	0x04	/* A short alloc due to OOM is okay */
+#define BVECQ_HIT_OOM		0x08	/* OOM was hit during allocation (set by alloc func) */
+#define BVECQ_HOLD_POOL_SEM	0x10	/* The caller now holds a sem on the emergency pool */
+
+void bvecq_dump(const struct bvecq *bq);
+struct bvecq *bvecq_alloc_one(size_t nr_slots, gfp_t gfp, unsigned int *flags);
+struct bvecq *bvecq_alloc_chain(size_t nr_slots, gfp_t gfp, unsigned int *flags);
+struct bvecq *bvecq_alloc_buffer2(size_t size, unsigned int pre_slots, gfp_t gfp,
+				  unsigned int *flags);
+void bvecq_put(struct bvecq *bq);
+int bvecq_expand_buffer(struct bvecq **_buffer, size_t *_cur_size, size_t size, gfp_t gfp);
+void bvecq_pool_unlock(unsigned int *flags);
+
+/**
+ * bvecq_alloc_buffer - Allocate a bvecq chain and populate with buffers
+ * @size: Target size of the buffer (can be 0 for an empty buffer)
+ * @gfp: The allocation constraints
+ * @flags: Pointer to the allocation flags
+ *
+ * Wrapper around ``bvecq_alloc_buffer2()``.
+ *
+ * Return: The first node pointer or NULL on allocation failure.
+ */
+static inline struct bvecq *bvecq_alloc_buffer(size_t size, gfp_t gfp, unsigned int *flags)
+{
+	return bvecq_alloc_buffer2(size, 0, gfp, flags);
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
 

